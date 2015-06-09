module CC
  module Analyzer
    module Formatters
      autoload :Formatter,  "cc/analyzer/formatters/formatter"
      autoload :JSONFormatter, "cc/analyzer/formatters/json_formatter"
      autoload :PlainTextFormatter,  "cc/analyzer/formatters/plain_text_formatter"

      FORMATTERS = {
        json: JSONFormatter,
        text: PlainTextFormatter,
      }.freeze

      def self.resolve(name)
        FORMATTERS[name.to_sym].new or raise InvalidFormatterError, "'#{name}' is not a valid formatter. Valid options are: #{FORMATTERS.keys.join(", ")}"
      end
    end
  end
end
