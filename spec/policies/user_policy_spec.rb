require 'rails_helper'

describe UserPolicy do
  subject { described_class }

  permissions :create? do
    it 'grants access' do
      expect(subject).to permit(nil, User.new)
    end
  end

  permissions :index? do
    it 'denies access if user is not admin' do
      expect(subject).not_to permit(build(:user), User.new)
    end

    it 'grants access if user is admin' do
      expect(subject).to permit(build(:admin), User.new)
    end
  end

  permissions :show?, :update?, :destroy? do
    it 'denies access if user is not admin and not the same user' do
      expect(subject).not_to permit(build(:user), User.new)
    end

    it 'grants access if user is admin' do
      expect(subject).to permit(build(:admin), User.new)
    end

    it 'grants access if user the current user' do
      user = create(:user)
      expect(subject).to permit(user, user)
    end
  end
end
