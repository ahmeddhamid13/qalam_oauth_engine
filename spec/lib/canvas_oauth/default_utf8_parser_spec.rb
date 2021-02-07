require 'spec_helper'

describe CanvasOauth::DefaultUTF8Parser do
  describe "#parse" do
    it "forces the body passed in to UTF-8 if it is ASCII_8BIT" do
      body = String.new("I am some text", encoding: Encoding::ASCII_8BIT)

      parser = CanvasOauth::DefaultUTF8Parser.new(body, "text/plain")
      expect(body).to receive(:force_encoding).with("UTF-8")
      parser.parse
    end

    it "does not force the body passed in to UTF-8 if not ASCII_8BIT" do
      body = String.new("I am some text", encoding: Encoding::US_ASCII)

      parser = CanvasOauth::DefaultUTF8Parser.new(body, "text/plain")
      expect(body).not_to receive(:force_encoding)
      parser.parse
    end
  end
end
