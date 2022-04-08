CREATE TABLE IF NOT EXISTS items (
    id int auto_increment primary key,
    Kind varchar(40),
    CollectionName varchar(100),
    TrackName varchar(100),
    CollectionPrice float,
    TrackPrice float,
    PrimaryGenreName varchar(100),
    TrackCount int,
    TrackNumber int,
    ReleaseDate datetime
)