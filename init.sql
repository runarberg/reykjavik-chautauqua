CREATE TABLE themes (
       name     varchar PRIMARY KEY
);

CREATE TABLE posts (
       id       serial,
       theme    varchar REFERENCES themes,
       title    varchar NOT NULL,
       content  varchar NOT NULL,
       PRIMARY KEY (theme, title)
);

CREATE TABLE comments (
       id       serial  PRIMARY KEY,
       theme    varchar,
       post     varchar,
       content  varchar NOT NULL,
       FOREIGN KEY (theme, post) REFERENCES posts
);