# -*- coding: utf-8 -*-
require "spec_helper"

describe Tudou do
  let(:list_url) {"http://www.tudou.com/plcover/M9ovmjs6fkw/"}
  let(:lid)      {15632178}
  before {FactoryGirl.create :user, :teacher}

  describe Tudou::Importer do
    describe "#import" do
      let(:importer) {Tudou::Importer.new list_url}
      subject        {importer}

      it {expect {importer.import}.to change {Course.count}.by(1)}
      it {expect {importer.import}.to change {Chapter.count}.by(importer.list.items.count)}
      it {expect {importer.import}.to change {CourseWare.count}.by(importer.list.items.count)}
    end
  end

  describe Tudou::List do
    let(:parser) {Tudou::List.new(list_url)}
    subject      {parser}

    its(:title) {should eq "法语公开课"}
    its(:lid)   {should be lid}

    describe "#items" do
      let(:items) {parser.items}
      subject     {items}

      it {should be_an Array}
      its(:first) {should be_an Tudou::Item}

      describe Tudou::Item do
        subject {items.first}
        
        its(:code) {should eq "bOcUBCwbpbs"}
        its(:desc) {should include "一口好听的法语"}
      end
    end
  end
end
