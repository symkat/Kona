Kona
=====

What Is Kona
-------------

Kona is a wiki written in Perl based on DBIx::Class, Plack::Request,
with a bit of my own magic tossed in.  Its primary reason for existing
is split between wanting to make something generic like a wiki in this 
type of an environment and my dissatisfaction in current wiki products.

Kona?
----------

Its name got based on this conversation:

    <SymKat>  Name my project, what do I call a wiki?
    <Friend>  Kona.
    <SymKat>  After the coffee?
    <Friend>  Yes, Hawaiian, wiki, hula hula.
    <SymKat>  I think you have won.

Depedencies
-------------

### Programs
* PostgreSQL
* lighttpd
* Perl

### CPAN Modules
* local::lib
* strictures
* indirect
* Template
* Text::MultiMarkdown
* DBIx::Class
* DBIx::Class::Schema::Loader
* DBIx::Class::TimeStamp
* DBD::Pg
* Plack
* DateTime
* DateTime::Format::Pg
* File::MMagic
* FCGI::ProcManager

Installation
--------------

1. Install depedencies.  To install the CPAN Modules, I recommend cpanminus.
1. Configure PostgreSQL:
    1. Create a user and database.
    1. Import conf/sql/schema-*.sql;
    1. Edit configuration in conf/development.yaml to include authentication credentials.
1. Configure lighttpd based on the configuration file conf/lighttpd.conf
1. Run the app via command: plackup -s FCGI -l 127.0.0.1:8080 dispatch.fcgi

Author
---------
* [SymKat](http://symkat.com/)

Contributors
------------------
* [Ryan Voots](http://www.simcop2387.info/) -- HTML/CSS
