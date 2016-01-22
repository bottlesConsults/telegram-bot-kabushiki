require_relative '../src/command_handler'
require 'csv'

RSpec.describe('CommandHandler') do

  subject {CommandHandler.new(nil)}

  before(:each) do
    @header = {:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}}
    stub_const('CURRENCY_PATH', 'spec/data/currency.csv')
    stub_const('STOCK_PATH', 'spec/data/stock.csv')
    stub_const('CHART_IMAGE_PATH', 'spec/data/tmp.jpg')
  end

  it '#list' do
    result = "D05.SI    *DBS Bank*    Finance\nO39.SI    *OCBC Bank*    Finance\nU11.SI    *UOB Bank*    Finance\nK71U.SI    *Keppel Reit*    REIT\nD5IU.SI    *Lippo Malls Trust*    REIT\n";
    response = subject.list('')
    expect(response).to eql(result)
  end

  context '#charts' do
    it 'returns nil' do
      expect(subject.charts('S68.SI')).to eql(nil)
      expect(subject.charts('Singapore')).to eql(nil)
      # expect(subject.charts('')). eql(nil) #handled by bot level
    end

    it 'returns results for finance' do
      result = "D05.SI *$13.88* 📈 +0.10, +0.73%, DBS Bank\nO39.SI *$7.72* 📈 +0.15, +1.98%, OCBC Bank\nU11.SI *$17.62* 📈 +0.55, +3.22%, UOB Bank\n"
      allow(ApiHandler).to receive(:get_chart).with("D05.SI,O39.SI,U11.SI").and_return(true)

      stub_request(:get, "#{PRICE_PATH}f=nsl1.csv&s=D05.SI,O39.SI,U11.SI").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/charts_finance.txt'), :headers => {})

      expect(subject.charts('finance')).to eql(result)
    end
  end

  context '#rate' do
    it 'returns nil' do
      expect(subject.rate('')).to eql(nil)
      expect(subject.rate('yrs')).to eql(nil)
      expect(subject.rate('abcde')).to eql(nil)
      expect(subject.rate('abcdef')).to eql(nil)
    end

    it 'returns result for usdcny' do
      param = 'usdcny'
      result = "_USD 1 = CNY 6.5793 📉_\n\n#{CHART_PATH}s=#{param}=x"
      stub_request(:get, "#{PRICE_PATH}f=nsl1.csv&s=#{param}=x").
              with(@header).
              to_return(:status => 200, :body => File.open("spec/data/rate_valid_long.txt"), :headers => {})

      expect(subject.rate(param)).to eql(result)
    end

    it 'returns results for usd' do
      param = 'usdsgd'
      result = "_USD 1 = SGD 1.888 📉_\n\n#{CHART_PATH}s=#{param}=x"
      stub_request(:get, "#{PRICE_PATH}f=nsl1.csv&s=#{param}=x").
              with(@header).
              to_return(:status => 200, :body => File.open("spec/data/rate_valid_short.txt"), :headers => {})

      expect(subject.rate('usd')).to eql(result)
    end
  end


  context '#stat' do
    it 'returns nil for invalid symbol' do
      param = 'SINGAPORE'
      allow(ApiHandler).to receive(:get_chart).with(param).and_return(true)
      stub_request(:get, "#{PRICE_PATH}f=nsl1rd.csv&s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/stat_invalid.txt'), :headers => {})
      stub_request(:get, "#{NEWS_PATH}s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/news_invalid.txt'), :headers => {})

      expect(subject.stat(param)).to eql(nil)
    end

    it 'returns data for predefined symbol' do
      param = 'O39.SI'
      result = "OCBC Bank O39.SI\n📈  *$1.11*  0.0333  \n[dividend]   *$N/A*\n[pe ratio]   *$2.22*\n[volume]     *44400*\n\n[Coal found](www.coal.com/news123.html)\n06 Oct 2015 03:31:39 GMT\n\n"
      allow(ApiHandler).to receive(:get_chart).with(param).and_return(true)
      stub_request(:get, "#{PRICE_PATH}f=nsl1rd.csv&s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/stat_predefined.txt'), :headers => {})
      stub_request(:get, "#{NEWS_PATH}s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/news_valid.txt'), :headers => {})

      expect(subject.stat(param)).to eql(result)
    end

    it 'returns data for predefined symbol' do
      param = 'S11.SI'
      result = "POSB S11.SI\n📈  *$1.11*  0.0333  \n[dividend]   *$N/A*\n[pe ratio]   *$2.22*\n[volume]     *44400*\n\n[Coal found](www.coal.com/news123.html)\n06 Oct 2015 03:31:39 GMT\n\n"
      allow(ApiHandler).to receive(:get_chart).with(param).and_return(true)
      stub_request(:get, "#{PRICE_PATH}f=nsl1rd.csv&s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/stat_dynamic.txt'), :headers => {})
      stub_request(:get, "#{NEWS_PATH}s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/news_valid.txt'), :headers => {})

      expect(subject.stat(param)).to eql(result)
    end
  end

  context '#stock' do
    # expect(subject.stat('')).to eql(nil) #handled at bot level
    it 'returns nil for invalid symbol' do
      param = 'bank'
      stub_request(:get, "#{PRICE_PATH}f=nsl1.csv&s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open("spec/data/stock_#{param}.txt"), :headers => {})

      expect(subject.stock(param)).to eql(nil)
    end

    it 'returns data for existing symbol' do
      param = 'D05.SI'
      result = "#{param} *$88.99* 📈 0.66, , DBS Bank\n"
      stub_request(:get, "#{PRICE_PATH}f=nsl1.csv&s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/stock_predefined.txt'), :headers => {})

      expect(subject.stock(param)).to eql(result)
    end

    it 'returns data for predefined symbol' do
      param = 'GOOG'
      result = "#{param} *$6.82* 📈 0.0766, , Google\n"
      stub_request(:get, "#{PRICE_PATH}f=nsl1.csv&s=#{param}").
              with(@header).
              to_return(:status => 200, :body => File.open('spec/data/stock_dynamic.txt'), :headers => {})

      expect(subject.stock(param)).to eql(result)
    end
  end
end

