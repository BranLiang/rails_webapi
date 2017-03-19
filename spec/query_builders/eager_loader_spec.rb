require 'rails_helper'

RSpec.describe EagerLoader do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }
  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  let(:scope) { Book.all }
  let(:params) { {} }
  let(:eager_loader) { EagerLoader.new(scope, params) }
  let(:eager_loaded) { eager_loader.load }

  before do
    allow(BookPresenter).to(
      receive(:relations).and_return(['publisher', 'author'])
    )
    books
  end

  describe '#related_to' do
    context 'without any parameters' do
      it 'does not include relations' do
        expect(eager_loaded).to eq scope
      end
    end

    context 'with valid parameters "embed=publisher"' do
      let(:params) { HashWithIndifferentAccess.new({ 'embed' => 'publisher' }) }

      it 'should eager load the publisher for books' do
        expect(eager_loaded.first.association(:publisher)).to be_loaded
      end
    end

    context 'with valid parameters "include=author"' do
      let(:params) { HashWithIndifferentAccess.new({ 'include' => 'author' }) }

      it 'should eager load the author for books' do
        expect(eager_loaded.first.association(:author)).to be_loaded
      end
    end

    context 'with valid parameters "embed=publisher&include=author"' do
      let(:params) { HashWithIndifferentAccess.new({ 'include' => 'author', 'embed' => 'publisher' }) }

      it 'should eager load both publisher and author' do
        expect(eager_loaded.first.association(:author)).to be_loaded
        expect(eager_loaded.first.association(:publisher)).to be_loaded
      end
    end

    context 'with invalid parameters "include=fake"' do
      let(:params) { HashWithIndifferentAccess.new({ 'include' => 'fake' }) }

      it 'raise a QueryBuilderError exception' do
        expect { eager_loaded }.to raise_error(QueryBuilderError)
      end
    end
  end
end
