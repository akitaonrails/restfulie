require 'spec_helper'
require 'medie'

describe Medie::OpenSearch::Descriptor do
   
  context "unmarshalling one url documents" do
  
    before do
      xml = '<?xml version="1.0" encoding="UTF-8"?>
      <OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">
        <ShortName>Restbuy</ShortName>
        <Description>Restbuy search engine.</Description>
        <Tags>restbuy</Tags>
        <Contact>admin@restbuy.com</Contact>
        <Url type="application/atom+xml"  template="http://localhost:3000/products?q={searchTerms}&amp;pw={startPage?}&amp;format=atom" />
      </OpenSearchDescription>'
      @descriptor = Medie::OpenSearch::Driver.unmarshal(xml)
    end
  
    it "should unmarshall opensearch xml descriptions" do
      @descriptor.use("application/atom+xml").host.should == URI.parse("http://localhost:3000/products")
      @descriptor.use("application/atom+xml").params_pattern.should == "q={searchTerms}&pw={startPage?}&format=atom"
      @descriptor.use("application/atom+xml").headers["Accept"].should == "application/atom+xml"
    end
  
  end

end