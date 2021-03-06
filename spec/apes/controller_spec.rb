#
# This file is part of the apes gem. Copyright (C) 2016 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Apes::Controller do
  describe "#handle_cors", type: :controller do
    it "should render the right content" do
      expect(subject).to receive(:render).with(nothing: true, status: :no_content)
      subject.handle_cors
    end
  end
  
  describe "#default_url_options" do
    it "should always mark the host as needed in URLs" do
      allow(Apes::RuntimeConfiguration).to receive(:development?).and_return(true)
      expect(subject).to receive(:request).and_return(OpenStruct.new(url: "http://localhost"))
      expect(subject.default_url_options[:only_path]).to be_falsey
    end
  end
  
  describe "#render_error" do
    it "should render the right template" do
      expect(subject).to receive(:render).with("errors/403", status: :forbidden)
      subject.render_error(:forbidden, ["1", "2"])
      expect(subject.instance_variable_get(:@errors)).to eq(["1", "2"])
      
      expect(subject).to receive(:render).with("errors/404", status: 404)
      subject.render_error(404, ["3", "4"])
      expect(subject.instance_variable_get(:@errors)).to eq(["3", "4"])
    end
  end
  
  describe "#render_default_views (private)" do
    it "should render the object template if a object is set" do
      subject.instance_variable_set(:@object, "FOO")
      expect(subject).to receive(:render).with("/object")
      subject.send(:render_default_views, RuntimeError.new)
    end
    
    it "should render the collection template if a collection is set" do
      subject.instance_variable_set(:@objects, "FOO")
      expect(subject).to receive(:render).with("/collection")
      subject.send(:render_default_views, RuntimeError.new)
    end
    
    it "should fallback to the default handler otherwise" do
      expect(subject).to receive(:error_handle_exception).with(an_instance_of(RuntimeError))
      subject.send(:render_default_views, RuntimeError.new)
    end
  end
end
