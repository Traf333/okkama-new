# frozen_string_literal: true

require 'csv'

module Web
  module Controllers
    module SubscriptionCancelling
      class Create
        include Web::Action

        params do
          required(:subscription_cancelling).schema do
            required(:transactions).filled
            required(:report).filled
          end
        end

        def call(params)
          return generate_report if params.valid?

          redirect_to routes.path(:subscription_cancelling)
        end

        private

        def generate_report
          result = SubscriptionCancellingReport.new(params: params[:subscription_cancelling]).call
          self.format = :csv
          self.body = result.body
          headers.merge!('Content-Disposition' => "attachment; filename=subscription-cancelling-report-#{date_format}.csv")
        end

        def date_format
          Time.now.strftime('%d-%m-%Y-%H-%M')
        end
      end
    end
  end
end
