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
            required(:reports).filled
            required(:encoding).filled
          end
        end

        def call(params)
          return generate_report if params.valid?

          redirect_to routes.path(:fond_report)
        end

        private

        def generate_report
          result = Okkama::Interactors::GenerateFondReport.new(params: params[:fond_report]).call
          self.format = :zip
          self.body = result.zip_file
          self.headers.merge!('Content-Disposition' => "attachment; filename=report-#{date_format}.zip")
          # redirect_to routes.path(:fond_reports)
        end

        def date_format
          Time.now.strftime('%d-%m-%Y-%H-%M')
        end
      end
    end
  end
end
