# frozen_string_literal: true

RSpec.describe Carbonyte::Support::Logging::LogstashFormatter do
  let(:buffer) { StringIO.new }
  let(:logger) { Logger.new(buffer) }
  let(:log_message) { JSON.parse(buffer.string) }

  before { logger.formatter = described_class.new }

  context 'when provided a simple string' do
    it 'logs it as message' do
      logger.info 'test'
      expect(log_message).to have_key('@timestamp')
      expect(log_message['message']).to eq('test')
      expect(log_message['severity']).to eq('INFO')
    end
  end

  context 'when provided a hash' do
    it 'adds it to the logstash event' do
      logger.info({ a: 'test', b: 2 })
      expect(log_message).to have_key('@timestamp')
      expect(log_message['a']).to eq('test')
      expect(log_message['b']).to eq(2)
      expect(log_message['severity']).to eq('INFO')
    end
  end

  context 'with tagged logging' do
    let(:logger) { ActiveSupport::TaggedLogging.new(Logger.new(buffer)) }
    let(:tags) { %w[TAG1 TAG2] }

    it 'adds tags to the logstash event' do
      logger.tagged(*tags) do
        logger.info 'test'
      end
      expect(log_message).to have_key('@timestamp')
      expect(log_message['severity']).to eq('INFO')
      expect(log_message['message']).to eq('test')
      expect(log_message['tags']).to eq(tags)
    end
  end
end
