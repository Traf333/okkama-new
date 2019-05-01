# frozen_string_literal: true

require 'features_helper'

describe 'Visit fond reports' do
  it 'is successful' do
    visit '/fond_reports'

    expect(page).to have_content('Fond Reports')
  end
end
