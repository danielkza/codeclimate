require 'spec_helper'

module CC::Analyzer::Formatters
  describe PlainTextFormatter do
    describe "#write" do
      it "raises an error" do
        formatter = PlainTextFormatter.new
        data = {"type" => "thing"}.to_json

        lambda { formatter.write(data) }.must_raise(RuntimeError, "Invalid type found: thing")
      end
    end

    describe "#finished" do
      it "outputs a breakdown" do
        issue = Factory.sample_issue
        formatter = PlainTextFormatter.new
        formatter.write(issue.to_json)

        stdout, stderr = capture_io do
          formatter.finished
        end

        stdout.must_match("accumulator.rb (1 issue)")
        stdout.must_match("Missing top-level class documentation comment")
      end
    end
  end
end
