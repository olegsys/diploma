package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"html/template"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"time"
)

type SearchMap struct {
	CollectionName   string    `json:"collectionName"`
	CollectionPrice  float64   `json:"collectionPrice"`
	Kind             string    `json:"kind"`
	PrimaryGenreName string    `json:"primaryGenreName"`
	ReleaseDate      time.Time `json:"releaseDate"`
	TrackCount       float64   `json:"trackCount"`
	TrackName        string    `json:"trackName"`
	TrackNumber      float64   `json:"trackNumber"`
	TrackPrice       float64   `json:"trackPrice"`
}
type SearchResult struct {
	ResultCount int         `json:"resultCount"`
	Results     []SearchMap `json:"results"`
}
type Handler struct {
	DB   *sql.DB
	Tmpl *template.Template
}

var (
	opsImported = promauto.NewCounter(prometheus.CounterOpts{
		Name: "ops_imported",
		Help: "Number of imported Records",
	})
)

func Search(query, country string) (*SearchResult, error) {
	u := url.Values{}
	u["term"] = []string{query}
	u["limit"] = []string{"200"}
	res, err := http.Get("https://itunes.apple.com/search?" + u.Encode())
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	ret := SearchResult{}
	err = json.NewDecoder(res.Body).Decode(&ret)
	if err != nil {
		return nil, err
	}
	return &ret, nil
}

func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	items := []*SearchMap{}
	rows, err := h.DB.Query("SELECT Kind, CollectionName, TrackName, CollectionPrice, TrackPrice, PrimaryGenreName, TrackCount, TrackNumber, ReleaseDate FROM items ORDER BY trackPrice DESC")
	logError(err)
	for rows.Next() {
		record := &SearchMap{}
		err = rows.Scan(&record.Kind, &record.CollectionName, &record.TrackName, &record.CollectionPrice, &record.TrackPrice, &record.PrimaryGenreName, &record.TrackCount, &record.TrackNumber, &record.ReleaseDate)
		logError(err)
		items = append(items, record)
	}
	rows.Close()

	err = h.Tmpl.ExecuteTemplate(w, "index.html", struct {
		Items []*SearchMap
	}{
		Items: items,
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func (h *Handler) Import(w http.ResponseWriter, r *http.Request) {
	response, err := Search("pink+floyd", "US")
	if err != nil {
		log.Fatal(err)
	}
	for _, record := range response.Results {
		result, err := h.DB.Exec(
			"INSERT INTO items (Kind, CollectionName, TrackName, CollectionPrice, TrackPrice, PrimaryGenreName, TrackCount, TrackNumber, ReleaseDate ) VALUES (?,?,?,?,?,?,?,?,?)",
			record.Kind, record.CollectionName, record.TrackName, record.CollectionPrice, record.TrackPrice, record.PrimaryGenreName, record.TrackCount, record.TrackNumber, record.ReleaseDate,
		)
		logError(err)
		affected, err := result.RowsAffected()
		opsImported.Add(float64(affected))
	}
	http.Redirect(w, r, "/", http.StatusFound)
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("Error loading .env file")
	}
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		os.Getenv("MYSQL_USERNAME"),
		os.Getenv("MYSQL_PASSWORD"),
		os.Getenv("MYSQL_HOSTNAME"),
		os.Getenv("MYSQL_PORT"),
		os.Getenv("MYSQL_DATABASE"),
	)
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("failed to connect database %s", err)
	}
	db.SetMaxOpenConns(10)
	err = db.Ping()
	if err != nil {
		panic(err)
	}

	// Running migrations
	driver, err := mysql.WithInstance(db, &mysql.Config{})
	if err != nil {
		log.Fatalf("Can't get mysql driver: %v", err)
	}
	migr, err := migrate.NewWithDatabaseInstance("file://./migrations", "mysql", driver)
	if err != nil {
		log.Fatalf("Can't get migration object: %v", err)
	}
	err = migr.Up()
	logError(err)

	appPort := fmt.Sprintf(":%v", os.Getenv("APP_PORT"))
	dir, _ := os.Getwd()
	handlers := &Handler{
		DB:   db,
		Tmpl: template.Must(template.ParseFiles(filepath.Join(dir, "templates", "index.html"))),
	}
	r := mux.NewRouter()
	r.HandleFunc("/", handlers.List).Methods("GET")
	r.HandleFunc("/import", handlers.Import).Methods("GET")
	r.Handle("/metrics", promhttp.Handler())
	log.Printf("starting server at %s", appPort)
	err = http.ListenAndServe(appPort, r)
	logError(err)
}

func logError(err error) {
	if err != nil {
		log.Println(err)
	}
}
