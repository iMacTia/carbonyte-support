# frozen_string_literal: true

module Carbonyte
  module Support
    module Logging
      # LogstashFormatter can be used with any logger to format the log data in logstash form.
      # If the data is a string, then this is simply added as "message".
      # If data is a Hash, this will be used to build the logstash event payload.
      # It also supports ActiveSupport::TaggedLogging if added to the project.
      class LogstashFormatter
        # Includes ActiveSupport::TaggedLogging::Formatter if it exists.
        # This adds the `tagged` and `current_tags` methods.
        include ActiveSupport::TaggedLogging::Formatter if defined?(ActiveSupport::TaggedLogging)

        def call(severity, time, progname, data)
          load_dependencies

          event = LogStash::Event.new(prepare_data(data, severity, time, progname))

          "#{event.to_json}\n"
        end

        def prepare_data(data, severity, _time, _progname)
          data = { message: data } unless data.is_a?(Hash)
          data[:severity] = severity
          data[:tags] = current_tags if respond_to?(:current_tags)
          data
        end

        def load_dependencies
          require 'logstash-event'
        rescue LoadError
          puts 'You need to install the logstash-event gem to use the logstash output.'
          raise
        end
      end
    end
  end
end
