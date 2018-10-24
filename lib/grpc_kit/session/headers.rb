# frozen_string_literal: true

require 'grpc_kit/session/duration'

module GrpcKit
  module Session
    Headers = Struct.new(
      :metadata,
      :path,
      :grpc_encoding,
      :grpc_status,
      :status_message,
      :timeout,
      :method,
      :http_status,
    ) do

      RESERVED_HEADERS = [
        'content-type',
        'user-agent',
        'grpc-message-type',
        'grpc-encoding',
        'grpc-message',
        'grpc-status',
        'grpc-status-details-bin',
        'te'
      ].freeze

      METADATA_ACCEPTABLE_HEADER = %w[authority user-agent].freeze
      def initialize
        super({}) # set metadata empty hash
      end

      def add(key, val)
        case key
        when ':path'
          self.path = val
        when ':status'
          self.http_status = Integer(val)
        when 'content-type'
          # TODO
          metadata[key] = val
        when 'grpc-encoding'
          self.grpc_encoding = val
        when 'grpc-status'
          self.grpc_status = val
        when 'grpc-timeout'
          self.timeout = Duration.decode(val)
        when 'grpc-message'
          self.status_message = val
        when 'grpc-status-details-bin'
          # TODO
          GrpcKit.logger.warn('grpc-status-details-bin is unsupported header now')
        else
          if RESERVED_HEADERS.include?(key) && !METADATA_ACCEPTABLE_HEADER.include?(key)
            return
          end

          metadata[key] = val
        end
      end
    end
  end
end
