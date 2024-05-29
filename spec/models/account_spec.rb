require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'should have has_many association' do
    it { should have_many(:phone_numbers).dependent(:destroy) }
  end
end
