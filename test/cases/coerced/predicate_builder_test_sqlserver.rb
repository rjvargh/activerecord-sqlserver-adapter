require 'cases/helper_sqlserver'
require 'models/topic'
require 'models/sqlserver/topic'

module ActiveRecord
  class PredicateBuilderTest < ActiveRecord::TestCase

    COERCED_TESTS = [:test_registering_new_handlers]

    include ARTest::SQLServer::CoercedTest

    def test_coerced_registering_new_handlers
      ActiveRecord::PredicateBuilder.register_handler(Regexp, proc do |column, value|
        Arel::Nodes::InfixOperation.new('~', column, value.source)
      end)

      assert_match %r{\[topics\].\[title\] ~ N'rails'}i, Topic.where(title: /rails/).to_sql
    end
  end
end
