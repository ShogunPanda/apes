#
# This file is part of the apes gem. Copyright (C) 2016 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Apes::Validators::BaseValidator do
  class BaseMockValidationValidator < Apes::Validators::BaseValidator
    def check_valid?(_)
      false
    end
  end
  
  class BaseMockModel
    include ActiveModel::Validations
    include Apes::Model
    
    attr_reader :field, :other_field
    validates :field, "base_mock_validation" => {message: "ERROR"}
    validates :other_field, "base_mock_validation" => {default_message: "DEFAULT", additional: true}
  end
  
  describe "#validate_each" do
    it "should correctly record messages" do
      subject = BaseMockModel.new
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["ERROR"]})
      expect(subject.additional_errors.to_hash).to eq({other_field: ["DEFAULT"]})
    end
  end
end

describe Apes::Validators::UuidValidator do
  class UUIDMockModel
    include ActiveModel::Validations
    include Apes::Model
    
    attr_accessor :field
    validates :field, "apes/validators/uuid" => true
  end
  
  describe "#validate_each" do
    it "should correctly validate fields" do
      subject = UUIDMockModel.new
      
      subject.field = "d250e78f-887a-4da2-8b4f-59f61c809bed"
      subject.validate
      expect(subject.errors.to_hash).to eq({})
      
      subject.field = "100"
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid UUID"]})
    end
  end
end

describe Apes::Validators::ReferenceValidator do
  class ReferenceMockOtherModel
    SECONDARY_QUERY = "name = :id"
  end

  class ReferenceMockModel
    include ActiveModel::Validations
    include Apes::Model

    attr_accessor :field
    validates :field, "apes/validators/reference" => {class_name: "reference_mock_other_model"}
  end

  describe "#validate_each" do
    before(:each) do
      allow(ReferenceMockOtherModel).to receive(:find_with_any).and_return(false)
    end

    it "should correctly validate fields" do
      subject = ReferenceMockModel.new
      subject.field = 100
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid ReferenceMockOtherModel (cannot find a ReferenceMockOtherModel with id \"100\")"]})
    end

    it "should correctly validate fields when they are array" do
      subject = ReferenceMockModel.new
      subject.field = [100, 101]
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid ReferenceMockOtherModel (cannot find a ReferenceMockOtherModel with id \"100\")", "must be a valid ReferenceMockOtherModel (cannot find a ReferenceMockOtherModel with id \"101\")"]})
    end
  end
end

describe Apes::Validators::EmailValidator do
  class EmailMockModel
    include ActiveModel::Validations
    include Apes::Model
    
    attr_accessor :field
    validates :field, "apes/validators/email" => true
  end
  
  describe "#validate_each" do
    it "should correctly validate fields" do
      subject = EmailMockModel.new
      subject.field = 100
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid email"]})
    end
  end
end

describe Apes::Validators::BooleanValidator do
  class BooleanMockModel
    include ActiveModel::Validations
    include Apes::Model
    
    attr_accessor :field
    validates :field, "apes/validators/boolean" => true
  end
  
  describe ".parse" do
    it "should correctly parse a value" do
      expect(Apes::Validators::BooleanValidator.parse("YES")).to be_truthy
      expect(Apes::Validators::BooleanValidator.parse("OTHER")).to be_falsey
    end
    
    it "should raise errors if asked to" do
      expect(Apes::Validators::BooleanValidator.parse(nil, raise_errors: true)).to be_falsey
      expect { Apes::Validators::BooleanValidator.parse("", raise_errors: true) }.to raise_error(ArgumentError, "Invalid boolean value \"\".")
      expect { Apes::Validators::BooleanValidator.parse("FOO", raise_errors: true) }.to raise_error(ArgumentError, "Invalid boolean value \"FOO\".")
    end
  end
  
  describe "#validate_each" do
    it "should correctly validate fields" do
      subject = BooleanMockModel.new
      subject.field = 100
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid truthy/falsey value"]})
    end
  end
end

describe Apes::Validators::PhoneValidator do
  class PhoneMockModel
    include ActiveModel::Validations
    include Apes::Model
    
    attr_accessor :field
    validates :field, "apes/validators/phone" => true
  end
  
  describe "#validate_each" do
    it "should correctly validate fields" do
      subject = PhoneMockModel.new
      
      subject.field = "+1 650-762-4637"
      subject.validate
      expect(subject.errors.to_hash).to eq({})
      
      subject.field = "FOO"
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid phone"]})
    end
  end
end

describe Apes::Validators::ZipCodeValidator do
  class ZipCodeMockModel
    include ActiveModel::Validations
    include Apes::Model
    
    attr_accessor :field
    validates :field, "apes/validators/zip_code" => true
  end
  
  describe "#validate_each" do
    it "should correctly validate fields" do
      subject = ZipCodeMockModel.new
      
      subject.field = "12345"
      subject.validate
      expect(subject.errors.to_hash).to eq({})
      
      subject.field = "12345-6789"
      subject.validate
      expect(subject.errors.to_hash).to eq({})
      
      
      subject.field = "100"
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid ZIP code"]})
    end
  end
end

describe Apes::Validators::TimestampValidator do
  class TimestampMockModel
    include ActiveModel::Validations
    include Apes::Model
    
    attr_accessor :field, :other_field
    validates :field, "apes/validators/timestamp" => true
    validates :other_field, "apes/validators/timestamp" => {formats: ["%Y"]}
  end
  
  describe ".parse" do
    it "should parse respecting formats, using ISO-8601 formats by default" do
      ISO8601 = "%FT%T%z".freeze
      FULL_ISO8601 = "%FT%T.%L%z".freeze

      allow(Apes::RuntimeConfiguration).to receive(:timestamp_formats).and_return({default: "%FT%T%z", full: "%FT%T.%L%z", clean: "%Y%m%dT%H%M%S.%L%z", clean_full: "%Y%m%dT%H%M%S.%L%z"})
      expect(Apes::Validators::TimestampValidator.parse("2016-05-04T03:02:01+06:00")).to eq(DateTime.civil(2016, 5, 4, 3, 2, 1, "+6"))
      expect(Apes::Validators::TimestampValidator.parse("2016-05-04T03:02:01.789-05:00")).to eq(DateTime.civil(2016, 5, 4, 3, 2, 1.789, "-5"))
      expect(Apes::Validators::TimestampValidator.parse("2016-05-04")).to be_nil
      expect(Apes::Validators::TimestampValidator.parse("2016-05-04+06:00", formats: ["%F%z"])).to eq(DateTime.civil(2016, 5, 4, 0, 0, 0, "+6"))
    end
    
    it "should raise errors if asked to" do
      expect { Apes::Validators::TimestampValidator.parse("2016-05-04", raise_errors: true) } .to raise_error(ArgumentError, "Invalid timestamp \"2016-05-04\".")
    end
  end
  
  describe "#validate_each" do
    it "should correctly validate fields" do
      subject = TimestampMockModel.new
      subject.field = 2016
      subject.other_field = "xxxx"
      subject.validate
      expect(subject.errors.to_hash).to eq({field: ["must be a valid ISO 8601 timestamp"], other_field: ["must be a valid ISO 8601 timestamp"]})
      
      subject.field = Time.now
      subject.other_field = "2016"
      subject.validate
      expect(subject.errors.to_hash).to eq({})
    end
  end
end