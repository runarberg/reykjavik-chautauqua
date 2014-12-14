CREATE TABLE themes (
       name     varchar PRIMARY KEY,
       year     integer,
       month    integer
);

CREATE TABLE posts (
       id       serial,
       theme    varchar REFERENCES themes,
       title    varchar NOT NULL,
       content  varchar NOT NULL,
       author   varchar,
       datetime timestamp,
       PRIMARY KEY (theme, title)
);

CREATE TABLE comments (
       id       serial  PRIMARY KEY,
       theme    varchar,
       post     varchar,
       content  varchar NOT NULL,
       author   varchar,
       datetime timestamp,
       FOREIGN KEY (theme, post) REFERENCES posts
);

CREATE TABLE posts_revisions (
       id       serial,
       revision integer,
       theme    varchar,
       title    varchar,
       content  varchar NOT NULL,
       author   varchar,
       origtime timestamp,
       edittime timestamp,
       PRIMARY KEY (theme, title, revision),
       FOREIGN KEY (theme, title) REFERENCES posts
);

CREATE TABLE comments_revisions (
       id         serial,
       comment_id integer REFERENCES comments,
       revision   integer,
       theme      varchar,
       post       varchar,
       content    varchar NOT NULL,
       author     varchar,
       origtime   timestamp,
       edittime   timestamp,
       PRIMARY KEY (comment_id, revision)
);
