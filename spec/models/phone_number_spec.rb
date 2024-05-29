require 'rails_helper'

RSpec.describe PhoneNumber, type: :model do
  describe 'should have belongs_to association' do
    it { should belong_to(:account) }
  end
end
