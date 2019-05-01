# frozen_string_literal: true

require 'csv'

module Web
  module Controllers
    module FondReport
      class Create
        include Web::Action

        params do
          required(:report).schema do
            required(:source).filled
            # required(:reports).filled
          end
        end

        def call(params)
          return generate_report if params.valid?

          redirect_to routes.path(:fond_report)
        end

        private

        def generate_report
          # result = Okkama::Interactors::GenerateFondReport.new(params: params[:report]).call
          source = CSV.read(params.get(:report, :source, :tempfile), col_sep: ';', headers: true)
          self.format = :csv
          self.body = source.to_csv
          # redirect_to routes.path(:fond_reports)
        end
      end
    end
  end
end
