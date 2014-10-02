module Commands
  module Approval
    class InitiateCartApproval < Commands::Base
      def perform(params)

        begin
          cart = Cart.initialize_cart_with_items(params).reload.decorate
          if params['approvalGroup'] && !params['approvalGroup'].blank?
            cart.process_approvals_from_approval_group unless cart.approvals.any?
          else
            cart.process_approvals_without_approval_group(params)
          end

          cart.import_cart_properties(params['properties'])
          cart.import_cart_items(params['cartItems'])
          cart.import_initial_comments(params['initiationComment']) unless params['initiationComment'].blank?
          # cart.deliver_approval_emails
          c2 = cart.instance_variable_get(:@object)
          c3 = cart.object
          # Rails.logger.debug "***c2***", c2
           Rails.logger.debug c3
          return c3
        rescue => error
          raise "Something went wrong: #{error}"
        end

      end
    end
  end
end