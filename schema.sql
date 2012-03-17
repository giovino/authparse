DROP TABLE IF EXISTS authdata;
CREATE TABLE authdata (
    id INTEGER PRIMARY KEY,
    type TEXT,
    user TEXT,
    ip_address TEXT,
    date_first_seen TEXT,
    date_last_seen TEXT
);

DROP TABLE IF EXISTS authuser;
CREATE TABLE authuser (
    user TEXT PRIMARY KEY,
    email TEXT
);

-- INSERT INTO authuser VALUES ('user1', 'user1@example.com')
