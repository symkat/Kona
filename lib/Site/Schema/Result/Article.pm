package Site::Schema::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Site::Schema::Result::Article

=cut

__PACKAGE__->table("article");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'article_id_seq'

=head2 uri

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 live_revision

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "article_id_seq",
  },
  "uri",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "live_revision",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("article_uri_key", ["uri"]);

=head1 RELATIONS

=head2 article_revision

Type: belongs_to

Related object: L<Site::Schema::Result::ArticleRevision>

=cut

__PACKAGE__->belongs_to(
  "article_revision",
  "Site::Schema::Result::ArticleRevision",
  { article_id => "id", revision => "live_revision" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 article_revisions

Type: has_many

Related object: L<Site::Schema::Result::ArticleRevision>

=cut

__PACKAGE__->has_many(
  "article_revisions",
  "Site::Schema::Result::ArticleRevision",
  { "foreign.article_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-10-31 20:12:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yMG+RK4ypCeZ17zcY8ZKgw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
