CREATE TABLE article (
    id                  serial          PRIMARY KEY,
    uri                 varchar         not null unique,
    created             timestamp       not null default now(),
    live_revision       int
);

CREATE TABLE article_revision (
    article_id          int             references article(id),
    revision            int             not null default 1,
    updated             timestamp       not null default now(),
    address             inet            not null,
    title               varchar         not null,
    content             text            not null,
    PRIMARY KEY ( article_id, revision )
);

/* Someone's A Little Too Dependant */
ALTER TABLE article ADD FOREIGN KEY (id, live_revision) REFERENCES article_revision(article_id, revision);
