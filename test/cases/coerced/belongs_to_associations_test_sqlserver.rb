require 'cases/helper_sqlserver'

class BelongsToAssociationsTestSQLServer < ActiveRecord::TestCase
end

class BelongsToAssociationsTest < ActiveRecord::TestCase

  COERCED_TESTS = [:test_belongs_to_with_primary_key_joins_on_correct_column]

  include ARTest::SQLServer::CoercedTest

  def test_coerced_belongs_to_with_primary_key_joins_on_correct_column
    sql = Client.joins(:firm_with_primary_key).to_sql
    assert_no_match(/\[firm_with_primary_keys_companies\]\.\[id\]/, sql)
    assert_match(/\[firm_with_primary_keys_companies\]\.\[name\]/, sql)
  end


end
