require 'spec_helper'

module PaulBunyan
  RSpec.describe Railtie do
    describe 'initializer "initialize_logger.logging"' do
      it 'must extend the logger with ActiveSupport::TaggedLogging' do
        # Since we're extending an instance of a class it's hard to actually
        # check for the module in the ancestry chain. respond_to? should be a
        # good enough proxy for it though.
        expect(PaulBunyan.logger.primary_logger).to respond_to(:tagged)
      end
    end

    describe '#unsubscribe_default_log_subscribers' do
      before do
        @action_controller_subscriber = ActiveSupport::LogSubscriber.subscribers.find{|s|
          s.class == ActionController::LogSubscriber
        }

        Railtie.instance.unsubscribe_default_log_subscribers
      end

      after do
        # replace any subscriptions we may have blown away so the next test
        # can be assured of a clean slate
        ActionController::LogSubscriber.attach_to(
          :action_controller,
          @action_controller_subscriber
        )
      end

      it 'must remove the ActionController::LogSubscriber subscription to process_action' do
        expect(subscriber_classes_for('process_action.action_controller')).
          to_not include ActionController::LogSubscriber
      end

      it 'must leave the ActionController::LogSubscriber subscription to deep_munge.action_controller in place' do
        # I don't expect that we'll ever care to unsubcribe the logger
        # non-event so we'll use it as a check to ensure we don't
        # clobber all of the listeners, only the ones we care about
        expect(subscriber_classes_for('logger.action_controller')).
          to include ActionController::LogSubscriber
      end
    end
  end
end
