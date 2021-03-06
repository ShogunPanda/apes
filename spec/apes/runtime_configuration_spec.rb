#
# This file is part of the apes gem. Copyright (C) 2016 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Apes::RuntimeConfiguration do
  describe ".root" do
    it "should get the information from RubyGems" do
      expect(Apes::RuntimeConfiguration.root).to be_a(String)
    end
  end

  describe ".rails_root" do
    it "should get the information from Rails" do
      stub_const("Rails", {root: "/ABC"}.ensure_access(:dotted))
      expect(Apes::RuntimeConfiguration.rails_root).to eq("/ABC")
    end

    it "should fallback to a default" do
      allow(Rails).to receive(:root).and_raise(RuntimeError)

      expect(Apes::RuntimeConfiguration.rails_root).to be_nil
      expect(Apes::RuntimeConfiguration.rails_root("DEFAULT")).to eq("DEFAULT")
    end
  end

  describe ".gems_root" do
    it "should get the information from Rails" do
      expect(Apes::RuntimeConfiguration.gems_root).to be_a(String)
    end

    it "should fallback to a default" do
      allow(Gem).to receive(:loaded_specs).and_raise(RuntimeError)

      expect(Apes::RuntimeConfiguration.gems_root).to be_nil
      expect(Apes::RuntimeConfiguration.gems_root("DEFAULT")).to eq("DEFAULT")
    end
  end

  describe ".environment" do
    it "should get the information from Rails secrets" do
      stub_const("Rails", {env: "FOO"}.ensure_access(:dotted))
      expect(Apes::RuntimeConfiguration.environment).to eq("FOO")
    end

    it "should fallback to a default" do
      allow(Rails).to receive(:env).and_raise(RuntimeError)
      expect(Apes::RuntimeConfiguration.environment).to eq("development")
      expect(Apes::RuntimeConfiguration.environment("DEFAULT")).to eq("DEFAULT")
    end
  end

  describe ".environment" do
    it "should check if Rails is in development" do
      stub_const("Rails", {env: "development"}.ensure_access(:dotted))
      expect(Apes::RuntimeConfiguration.development?).to be_truthy

      stub_const("Rails", {env: "FOO"}.ensure_access(:dotted))
      expect(Apes::RuntimeConfiguration.development?).to be_falsey
    end
  end

  describe ".jwt_token" do
    it "should get the information from Rails secrets" do
      stub_const("Rails", {application: {secrets: {jwt: "SECRET"}}}.ensure_access(:dotted))
      expect(Apes::RuntimeConfiguration.jwt_token).to eq("SECRET")
    end

    it "should fallback to a default" do
      expect(Apes::RuntimeConfiguration.jwt_token).to eq("secret")
      expect(Apes::RuntimeConfiguration.jwt_token("DEFAULT")).to eq("DEFAULT")
    end
  end

  describe ".cors_source" do
    it "should get the information from Rails secrets" do
      stub_const("Rails", {application: {secrets: {cors_source: "SOURCE"}}}.ensure_access(:dotted))
      expect(Apes::RuntimeConfiguration.cors_source).to eq("SOURCE")
    end
  
    it "should fallback to a default" do
      expect(Apes::RuntimeConfiguration.cors_source).to eq("http://localhost")
      expect(Apes::RuntimeConfiguration.cors_source("DEFAULT")).to eq("DEFAULT")
    end
  end

  describe ".timestamp_formats" do
    it "should get the information from Rails secrets" do
      stub_const("Rails", {application: {config: {timestamp_formats: {a: 1}}}}.ensure_access(:dotted))
      expect(Apes::RuntimeConfiguration.timestamp_formats).to eq({a: 1})
    end

    it "should fallback to a default" do
      expect(Apes::RuntimeConfiguration.timestamp_formats).to eq({})
      expect(Apes::RuntimeConfiguration.timestamp_formats("DEFAULT")).to eq("DEFAULT")
    end
  end
end