CREATE TABLE "books" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "title" TEXT,
    "author" TEXT,
    "year_pub" INTEGER,
    "created_at" TEXT,
    "updated_at" TEXT
);


BEGIN TRANSACTION;
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('The secret diaries', 'John Doe', '2010', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('Gardens for dry climates', 'Jane Doe', '1999', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('DoeScript: a primer', 'O''Reilly', '2013', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('There''s no life on Venus', 'Fred Bloggs', '2010', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('Letters from Paris', 'Ann Onymous', '2011', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('Halfway to nowhere', 'John Doe', '1996', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('A test too far', 'John Doe', '1996', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('The 1995 diaries', 'John Doe', '1996', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('Counting sheep', 'John Doe', '1996', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('An estranged husband', 'Jane Doe', '1996', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('This year of plenty', 'Fred Bloggs', '1996', NULL, NULL);
insert into books ("title", "author", "year_pub", "created_at", "updated_at") values ('A recursive glance', 'John Doe', '2012', NULL, NULL);
COMMIT;

