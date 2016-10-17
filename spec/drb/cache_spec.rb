require 'spec_helper'

describe DRb::Cache do
  it 'has a version number' do
    expect(DRb::Cache::VERSION).not_to be nil
  end
end
