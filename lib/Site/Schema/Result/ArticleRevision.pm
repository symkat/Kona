package Site::Schema::Result::ArticleRevision;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Site::Schema::Result::ArticleRevision

=cut

__PACKAGE__->table("article_revision");

=head1 ACCESSORS

=head2 article_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 revision

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 address

  data_type: 'inet'
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 content

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "article_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "revision",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "address",
  { data_type => "inet", is_nullable => 0 },
  "title",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "content",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("article_id", "revision");

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<Site::Schema::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "Site::Schema::Result::Article",
  {
    "foreign.id" => "self.article_id",
    "foreign.live_revision" => "self.revision",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 article

Type: belongs_to

Related object: L<Site::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "article",
  "Site::Schema::Result::Article",
  { id => "article_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-10-31 20:12:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:J1+qUralb54AgTS9RrZo/w

__PACKAGE__->has_many(
  "articles",
  "Site::Schema::Result::Article",
  {
    "foreign.id" => "self.article_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
