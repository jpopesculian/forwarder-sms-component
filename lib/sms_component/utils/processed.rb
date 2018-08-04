module SmsComponent
  module Utils
    class Processed
      include Log::Dependency

      dependency :store

      def self.configure(receiver, attr_name: nil)
        attr_name ||= :processed
        instance = build
        receiver.public_send("#{attr_name}=", instance)
      end

      def self.build
        instance = new
        instance.configure
        instance
      end

      def configure
        Store.configure(self)
      end

      def call(message)
        id = get_id(message)
        position = message.metadata.global_position
        projection = store.fetch(id)
        if current?(projection, position)
          return true, Proc.new {
            logger.info(tag: :ignored) { "Event ignored (Event: #{message.message_type}, ID: #{id}, #{projection_position(projection)} -> #{position}" }
          }
        end
        return false, Proc.new {}
      end

      private

      def get_id(message)
        message.sms_id
      end

      def current?(projection, position)
        projection.current?(position)
      end

      def projection_position(projection)
        projection.meta_position
      end
    end
  end
end
