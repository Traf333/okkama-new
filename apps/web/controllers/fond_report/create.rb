# frozen_string_literal: true

require 'csv'

module Web
  module Controllers
    module FondReport
      class Create
        include Web::Action

        params do
          required(:fond_report).schema do
            required(:source).filled
            required(:report).filled
          end
        end

        def call(params)
          return generate_report if params.valid?

          redirect_to routes.path(:fond_report)
        end

        private

        def generate_report
          result = Okkama::Interactors::GenerateFondReport.new(params: params[:fond_report]).call
          self.format = :csv
          self.body = result.csv
          self.headers.merge!('Content-Disposition' => "attachment; filename=report-#{Date.today}.csv")
          # redirect_to routes.path(:fond_reports)
        end
      end
    end
  end
end
