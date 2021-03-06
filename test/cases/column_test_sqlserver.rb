# encoding: UTF-8
require 'cases/helper_sqlserver'

class ColumnTestSQLServer < ActiveRecord::TestCase

  describe 'ActiveRecord::ConnectionAdapters::SQLServer::Type' do

    let(:obj) { SSTestDatatype.new }

    Type = ActiveRecord::ConnectionAdapters::SQLServer::Type

    def new_obj ; SSTestDatatype.new ; end
    def column(name) ; SSTestDatatype.columns_hash[name] ; end
    def assert_obj_set_and_save(attribute, value)
      obj.send :"#{attribute}=", value
      obj.send(attribute).must_equal value
      obj.save!
      obj.reload.send(attribute).must_equal value
    end

    # http://msdn.microsoft.com/en-us/library/ms187752.aspx

    # Exact Numerics

    it 'int(4) PRIMARY KEY' do
      col = column('id')
      col.sql_type.must_equal          'int(4)'
      col.null.must_equal              false
    end

    it 'bigint(8)' do
      col = column('bigint')
      col.sql_type.must_equal           'bigint(8)'
      col.null.must_equal               true
      col.default.must_equal            42
      obj.bigint.must_equal             42
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::BigInteger
      type.type.must_equal              :integer
      type.must_be                      :number?
      type.limit.must_equal             8
      assert_obj_set_and_save :bigint, -9_223_372_036_854_775_808
      assert_raises(RangeError) { new_obj.bigint = -9_223_372_036_854_775_809 }
      assert_obj_set_and_save :bigint, 9_223_372_036_854_775_807
      assert_raises(RangeError) { new_obj.bigint = 9_223_372_036_854_775_808 }
    end

    it 'int(4)' do
      col = column('int')
      col.sql_type.must_equal           'int(4)'
      col.null.must_equal               true
      col.default.must_equal            42
      obj.int.must_equal                42
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Integer
      type.type.must_equal              :integer
      type.must_be                      :number?
      type.limit.must_equal             4
      assert_obj_set_and_save :int, -2_147_483_648
      assert_raises(RangeError) { new_obj.int = -2_147_483_649 }
      assert_obj_set_and_save :int, 2_147_483_647
      assert_raises(RangeError) { new_obj.int = 2_147_483_648 }
    end

    it 'smallint(2)' do
      col = column('smallint')
      col.sql_type.must_equal           'smallint(2)'
      col.null.must_equal               true
      col.default.must_equal            42
      obj.smallint.must_equal           42
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::SmallInteger
      type.type.must_equal              :integer
      type.must_be                      :number?
      type.limit.must_equal             2
      assert_obj_set_and_save :smallint, -32_768
      assert_raises(RangeError) { new_obj.smallint = -32_769 }
      assert_obj_set_and_save :smallint, 32_767
      assert_raises(RangeError) { new_obj.smallint = 32_768 }
    end

    it 'tinyint(1)' do
      col = column('tinyint')
      col.sql_type.must_equal           'tinyint(1)'
      col.null.must_equal               true
      col.default.must_equal            42
      obj.tinyint.must_equal            42
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::TinyInteger
      type.type.must_equal              :integer
      type.must_be                      :number?
      type.limit.must_equal             1
      assert_obj_set_and_save :tinyint, 0
      assert_raises(RangeError) { new_obj.tinyint = -1 }
      assert_obj_set_and_save :tinyint, 255
      assert_raises(RangeError) { new_obj.tinyint = 256 }
    end

    it 'bit' do
      col = column('bit')
      col.sql_type.must_equal           'bit'
      col.null.must_equal               true
      col.default.must_equal            true
      obj.bit.must_equal                true
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Boolean
      type.type.must_equal              :boolean
      type.wont_be                      :number?
      type.limit.must_equal             nil
      obj.bit = 0
      obj.bit.must_equal false
      obj.save!
      obj.reload.bit.must_equal false
      obj.bit = '1'
      obj.bit.must_equal true
      obj.save!
      obj.reload.bit.must_equal true
    end

    it 'decimal(9,2)' do
      col = column('decimal_9_2')
      col.sql_type.must_equal           'decimal(9,2)'
      col.null.must_equal               true
      col.default.must_equal            BigDecimal('12345.01')
      obj.decimal_9_2.must_equal        BigDecimal('12345.01')
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Decimal
      type.type.must_equal              :decimal
      type.must_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         9
      type.scale.must_equal             2
      obj.decimal_9_2 = '1234567.8901'
      obj.decimal_9_2.must_equal        BigDecimal('1234567.8901') # Cast from user one day.
      obj.save!
      obj.reload.decimal_9_2.must_equal BigDecimal('1234567.89')
    end

    it 'decimal(16,4)' do
      col = column('decimal_16_4')
      col.sql_type.must_equal           'decimal(16,4)'
      col.default.must_equal            BigDecimal('1234567.89')
      obj.decimal_16_4.must_equal       BigDecimal('1234567.89')
      col.default_function.must_equal   nil
      type = col.cast_type
      type.precision.must_equal         16
      type.scale.must_equal             4
      obj.decimal_16_4 = '1234567.8901001'
      obj.decimal_16_4.must_equal        BigDecimal('1234567.8901001') # Cast from user one day.
      obj.save!
      obj.reload.decimal_16_4.must_equal BigDecimal('1234567.8901')
    end

    it 'numeric(18,0)' do
      col = column('numeric_18_0')
      col.sql_type.must_equal           'numeric(18,0)'
      col.null.must_equal               true
      col.default.must_equal            BigDecimal('191')
      obj.numeric_18_0.must_equal       BigDecimal('191')
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Decimal
      type.type.must_equal              :decimal
      type.must_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         18
      type.scale.must_equal             0
      obj.numeric_18_0 = '192.1'
      obj.numeric_18_0.must_equal        BigDecimal('192.1') # Cast from user one day.
      obj.save!
      obj.reload.numeric_18_0.must_equal BigDecimal('192')
    end

    it 'numeric(36,2)' do
      col = column('numeric_36_2')
      col.sql_type.must_equal           'numeric(36,2)'
      col.null.must_equal               true
      col.default.must_equal            BigDecimal('12345678901234567890.01')
      obj.numeric_36_2.must_equal       BigDecimal('12345678901234567890.01')
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Decimal
      type.type.must_equal              :decimal
      type.must_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         36
      type.scale.must_equal             2
      obj.numeric_36_2 = '192.123'
      obj.numeric_36_2.must_equal        BigDecimal('192.123') # Cast from user one day.
      obj.save!
      obj.reload.numeric_36_2.must_equal BigDecimal('192.12')
    end

    it 'money' do
      col = column('money')
      col.sql_type.must_equal           'money'
      col.null.must_equal               true
      col.default.must_equal            BigDecimal('4.20')
      obj.money.must_equal              BigDecimal('4.20')
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Money
      type.type.must_equal              :money
      type.must_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         19
      type.scale.must_equal             4
      obj.money = '922337203685477.58061'
      obj.money.must_equal              BigDecimal('922337203685477.58061')
      obj.save!
      obj.reload.money.must_equal       BigDecimal('922337203685477.5806')
    end

    it 'smallmoney' do
      col = column('smallmoney')
      col.sql_type.must_equal           'smallmoney'
      col.null.must_equal               true
      col.default.must_equal            BigDecimal('4.20')
      obj.smallmoney.must_equal         BigDecimal('4.20')
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::SmallMoney
      type.type.must_equal              :money
      type.must_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         10
      type.scale.must_equal             4
      obj.smallmoney = '214748.36461'
      obj.smallmoney.must_equal        BigDecimal('214748.36461')
      obj.save!
      obj.reload.smallmoney.must_equal BigDecimal('214748.3646')
    end

    # Approximate Numerics
    # Float limits are adjusted to 24 or 53 by the database as per http://msdn.microsoft.com/en-us/library/ms173773.aspx
    # Floats with a limit of <= 24 are reduced to reals by sqlserver on creation.

    it 'float(53)' do
      col = column('float')
      col.sql_type.must_equal           'float(53)'
      col.null.must_equal               true
      col.default.must_equal            123.00000001
      obj.float.must_equal              123.00000001
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Float
      type.type.must_equal              :float
      type.must_be                      :number?
      type.limit.must_equal             53
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      obj.float = '214748.36461'
      obj.float.must_equal        214748.36461
      obj.save!
      obj.reload.float.must_equal 214748.36461
    end

    it 'float(25)' do
      col = column('float_25')
      col.sql_type.must_equal           'float(53)'
      col.null.must_equal               true
      col.default.must_equal            420.11
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Float
      type.type.must_equal              :float
      type.limit.must_equal             53
    end

    it 'real(24)' do
      col = column('real')
      col.sql_type.must_equal           'real(24)'
      col.null.must_equal               true
      col.default.must_be_close_to      123.45, 0.01
      obj.real.must_be_close_to         123.45, 0.01
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Float
      type.type.must_equal              :float
      type.must_be                      :number?
      type.limit.must_equal             24
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      obj.real = '214748.36461'
      obj.real.must_be_close_to         214748.36461, 0.01
      obj.save!
      obj.reload.real.must_be_close_to  214748.36461, 0.01
    end

    # Date and Time

    it 'date' do
      col = column('date')
      col.sql_type.must_equal           'date'
      col.null.must_equal               true
      col.default.must_equal            '0001-01-01' # TODO: None type casted default. Really want Date.civil(0001, 1, 1).
      obj.date.must_equal               Date.civil(0001, 1, 1)
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Date
      type.type.must_equal              :date
      type.wont_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Can cast strings.
      obj.date = '0001-01-01'
      obj.date.must_equal               Date.civil(0001, 1, 1)
      obj.save!
      obj.reload.date.must_equal        Date.civil(0001, 1, 1)
      # Can keep and return assigned date.
      assert_obj_set_and_save :date, Date.civil(1972, 04, 14)
      # Can accept and cast time objects.
      obj.date = Time.utc(2010, 4, 14, 12, 34, 56, 3000)
      obj.date.must_equal               Date.civil(2010, 4, 14)
      obj.save!
      obj.reload.date.must_equal        Date.civil(2010, 4, 14)
    end

    it 'datetime' do
      col = column('datetime')
      col.sql_type.must_equal           'datetime'
      col.null.must_equal               true
      col.default.must_equal            Time.utc(1753, 01, 01, 00, 00, 00, 000)
      obj.datetime.must_equal           Time.utc(1753, 01, 01, 00, 00, 00, 000)
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::DateTime
      type.type.must_equal              :datetime
      type.wont_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Can save .003 seconds and return again.
      obj.datetime = Time.utc(2010, 01, 01, 12, 34, 56, 3000)
      obj.datetime.must_equal           Time.utc(2010, 01, 01, 12, 34, 56, 3000), "Microseconds were <#{obj.datetime.usec}> vs <3000>"
      obj.save!
      obj.reload.datetime.must_equal    Time.utc(2010, 01, 01, 12, 34, 56, 3000), "Microseconds were <#{obj.reload.datetime.usec}> vs <3000>"
      # Will cast to true DB value on attribute write, save and return again.
      obj.datetime = Time.utc(2010, 01, 01, 12, 34, 56, 234567)
      obj.datetime.must_equal           Time.utc(2010, 01, 01, 12, 34, 56, 233000), "Microseconds were <#{obj.datetime.usec}> vs <233000>"
      obj.save!
      obj.reload.datetime.must_equal    Time.utc(2010, 01, 01, 12, 34, 56, 233000), "Microseconds were <#{obj.reload.datetime.usec}> vs <233000>"
    end

    it 'smalldatetime' do
      col = column('smalldatetime')
      col.sql_type.must_equal           'smalldatetime'
      col.null.must_equal               true
      col.default.must_equal            Time.utc(1901, 01, 01, 15, 45, 00, 000)
      obj.smalldatetime.must_equal      Time.utc(1901, 01, 01, 15, 45, 00, 000)
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::SmallDateTime
      type.type.must_equal              :datetime
      type.wont_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Will remove fractional seconds and return again.
      obj.smalldatetime = Time.utc(2078, 06, 05, 4, 20, 00, 3000)
      obj.smalldatetime.must_equal          Time.utc(2078, 06, 05, 4, 20, 00, 0), "Microseconds were <#{obj.smalldatetime.usec}> vs <0>"
      obj.save!
      obj.reload.smalldatetime.must_equal   Time.utc(2078, 06, 05, 4, 20, 00, 0), "Microseconds were <#{obj.reload.smalldatetime.usec}> vs <0>"
    end

    it 'time(2)' do
      col = column('time_2')
      col.sql_type.must_equal           'time(2)'
      col.null.must_equal               true
      col.default.must_equal            nil
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Time
      type.type.must_equal              :time
      type.wont_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         2
      type.scale.must_equal             nil
      # Always uses ActiveRecord's 2000-01-01 convention too.
      obj.time_2 = Time.utc(2015, 01, 10, 15, 45, 00, 0)
      obj.time_2.must_equal             Time.utc(2000, 01, 01, 15, 45, 00, 0)
      obj.save!
      obj.reload.time_2.must_equal      Time.utc(2000, 01, 01, 15, 45, 00, 0)
      # Midnight the beggining of the day.
      obj.time_2 = Time.utc(2000, 01, 01).midnight.change(usec: 0)
      obj.time_2.must_equal             Time.utc(2000, 01, 01, 00, 00, 00, 0)
      obj.save!
      obj.reload.time_2.must_equal      Time.utc(2000, 01, 01, 00, 00, 00, 0)
      # The end of day.
      obj.time_2 = Time.utc(2000, 01, 01).end_of_day.change(usec: 0)
      obj.time_2.must_equal             Time.utc(2000, 01, 01, 23, 59, 59, 0)
      obj.save!
      obj.reload.time_2.must_equal      Time.utc(2000, 01, 01, 23, 59, 59, 0)
      # Time's #usec precision (barely in 2 precision equal to 0.03 seconds)
      obj.time_2 = Time.utc(2000, 01, 01, 15, 45, 00, 30000)
      obj.time_2.must_equal             Time.utc(2000, 01, 01, 15, 45, 00, 30000), "Microseconds were <#{obj.time_2.usec}> vs <30000>"
      obj.save!
      obj.reload.time_2.must_equal      Time.utc(2000, 01, 01, 15, 45, 00, 30000), "Microseconds were <#{obj.reload.time_2.usec}> vs <30000>"
      # Time's #usec precision (below 2 precision)
      obj.time_2 = Time.utc(2000, 01, 01, 15, 45, 00, 4000)
      obj.time_2.must_equal             Time.utc(2000, 01, 01, 15, 45, 00, 0), "Microseconds were <#{obj.time_2.usec}> vs <0>"
      obj.save!
      obj.reload.time_2.must_equal      Time.utc(2000, 01, 01, 15, 45, 00, 0), "Microseconds were <#{obj.reload.time_2.usec}> vs <0>"
    end

    it 'time(7)' do
      col = column('time_7')
      col.sql_type.must_equal           'time(7)'
      col.null.must_equal               true
      col.default.must_equal            nil
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Time
      type.type.must_equal              :time
      type.wont_be                      :number?
      type.limit.must_equal             nil
      type.precision.must_equal         7
      type.scale.must_equal             nil
      # Time's #usec precision (low)
      obj.time_7 = Time.utc(2000, 01, 01, 15, 45, 00, 300)
      obj.time_7.must_equal             Time.utc(2000, 01, 01, 15, 45, 00, 300), "Microseconds were <#{obj.time_7.usec}> vs <300>"
      obj.save!
      obj.reload.time_7.must_equal      Time.utc(2000, 01, 01, 15, 45, 00, 300), "Microseconds were <#{obj.reload.time_7.usec}> vs <300>"
      # Time's #usec precision (high)
      obj.time_7 = Time.utc(2000, 01, 01, 15, 45, 00, 234567)
      obj.time_7.must_equal             Time.utc(2000, 01, 01, 15, 45, 00, 234567), "Microseconds were <#{obj.time_7.usec}> vs <234567>"
      obj.save!
      obj.reload.time_7.must_equal      Time.utc(2000, 01, 01, 15, 45, 00, 234567), "Microseconds were <#{obj.reload.time_7.usec}> vs <234567>"
    end

    # Character Strings

    it 'char(10)' do
      col = column('char_10')
      col.sql_type.must_equal           'char(10)'
      col.null.must_equal               true
      col.default.must_equal            '1234567890'
      obj.char_10.must_equal            '1234567890'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Char
      type.type.must_equal              :string
      type.wont_be                      :number?
      type.limit.must_equal             10
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      obj.char_10 = '012345'
      obj.char_10.strip.must_equal         '012345'
      obj.save!
      obj.reload.char_10.strip.must_equal  '012345'
    end

    it 'varchar(50)' do
      col = column('varchar_50')
      col.sql_type.must_equal           'varchar(50)'
      col.null.must_equal               true
      col.default.must_equal            'test varchar_50'
      obj.varchar_50.must_equal         'test varchar_50'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Varchar
      type.type.must_equal              :string
      type.wont_be                      :number?
      type.limit.must_equal             50
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      assert_obj_set_and_save :varchar_50, 'Hello World'
    end

    it 'varchar(max)' do
      col = column('varchar_max')
      col.sql_type.must_equal           'varchar(max)'
      col.null.must_equal               true
      col.default.must_equal            'test varchar_max'
      obj.varchar_max.must_equal        'test varchar_max'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::VarcharMax
      type.type.must_equal              :text
      type.wont_be                      :number?
      type.limit.must_equal             2_147_483_647
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      assert_obj_set_and_save :varchar_max, 'Hello World'
    end

    it 'text' do
      col = column('text')
      col.sql_type.must_equal           'text'
      col.null.must_equal               true
      col.default.must_equal            'test text'
      obj.text.must_equal               'test text'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Text
      type.type.must_equal              :text
      type.wont_be                      :number?
      type.limit.must_equal             2_147_483_647
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      assert_obj_set_and_save :text, 'Hello World'
    end

    # Unicode Character Strings

    it 'nchar(10)' do
      col = column('nchar_10')
      col.sql_type.must_equal           'nchar(10)'
      col.null.must_equal               true
      col.default.must_equal            '12345678åå'
      obj.nchar_10.must_equal           '12345678åå'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::UnicodeChar
      type.type.must_equal              :string
      type.wont_be                      :number?
      type.limit.must_equal             10
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      obj.nchar_10 = "五六"
      obj.nchar_10.strip.must_equal         "五六"
      obj.save!
      obj.reload.nchar_10.strip.must_equal  "五六"
    end

    it 'nvarchar(50)' do
      col = column('nvarchar_50')
      col.sql_type.must_equal           'nvarchar(50)'
      col.null.must_equal               true
      col.default.must_equal            'test nvarchar_50 åå'
      obj.nvarchar_50.must_equal        'test nvarchar_50 åå'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::UnicodeVarchar
      type.type.must_equal              :string
      type.wont_be                      :number?
      type.limit.must_equal             50
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      assert_obj_set_and_save :nvarchar_50, "一二34五六"
    end

    it 'nvarchar(max)' do
      col = column('nvarchar_max')
      col.sql_type.must_equal           'nvarchar(max)'
      col.null.must_equal               true
      col.default.must_equal            'test nvarchar_max åå'
      obj.nvarchar_max.must_equal       'test nvarchar_max åå'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::UnicodeVarcharMax
      type.type.must_equal              :text
      type.wont_be                      :number?
      type.limit.must_equal             2_147_483_647
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      assert_obj_set_and_save :nvarchar_max, "一二34五六"
    end

    it 'ntext' do
      col = column('ntext')
      col.sql_type.must_equal           'ntext'
      col.null.must_equal               true
      col.default.must_equal            'test ntext åå'
      obj.ntext.must_equal              'test ntext åå'
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::UnicodeText
      type.type.must_equal              :text
      type.wont_be                      :number?
      type.limit.must_equal             2_147_483_647
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      assert_obj_set_and_save :ntext, "一二34五六"
    end

    # Binary Strings

    let(:binary_file) { File.join ARTest::SQLServer.test_root_sqlserver, 'fixtures', '1px.gif' }
    let(:binary_data) { File.open(binary_file, 'rb') { |f| f.read } }

    it 'binary(49)' do
      col = column('binary_49')
      col.sql_type.must_equal           'binary(49)'
      col.null.must_equal               true
      col.default.must_equal            nil
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Binary
      type.type.must_equal              :binary
      type.wont_be                      :number?
      type.limit.must_equal             49
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      binary_data.encoding.must_equal Encoding::BINARY
      binary_data.length.must_equal 49
      obj.binary_49 = binary_data
      obj.binary_49.must_equal binary_data
      obj.save!
      obj.reload.binary_49.must_equal binary_data
    end

    it 'varbinary(49)' do
      col = column('varbinary_49')
      col.sql_type.must_equal           'varbinary(49)'
      col.null.must_equal               true
      col.default.must_equal            nil
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::Varbinary
      type.type.must_equal              :binary
      type.wont_be                      :number?
      type.limit.must_equal             49
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      binary_data_20 = binary_data.to(20)
      binary_data_20.encoding.must_equal Encoding::BINARY
      obj.varbinary_49 = binary_data_20
      obj.varbinary_49.must_equal binary_data_20
      obj.save!
      obj.reload.varbinary_49.must_equal binary_data_20
    end

    it 'varbinary(max)' do
      col = column('varbinary_max')
      col.sql_type.must_equal           'varbinary(max)'
      col.null.must_equal               true
      col.default.must_equal            nil
      col.default_function.must_equal   nil
      type = col.cast_type
      type.must_be_instance_of          Type::VarbinaryMax
      type.type.must_equal              :binary
      type.wont_be                      :number?
      type.limit.must_equal             2_147_483_647
      type.precision.must_equal         nil
      type.scale.must_equal             nil
      # Basic set and save.
      binary_data.encoding.must_equal Encoding::BINARY
      assert_obj_set_and_save :varbinary_max, binary_data
    end

  end

end
