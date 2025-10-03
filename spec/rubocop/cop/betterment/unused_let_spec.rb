# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::UnusedLet, :config do
  it 'registers an offense and autocorrects unused let' do
    expect_offense(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }
        ^^^^^^^^^^^^^^^^^^^ Unused let definition `foo`. Remove it or use it in your tests.

        it 'does something' do
          expect(true).to be_truthy
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe MyClass do

        it 'does something' do
          expect(true).to be_truthy
        end
      end
    RUBY
  end

  it 'registers an offense when other lets are used' do
    expect_offense(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }
        let(:baz) { 'qux' }
        ^^^^^^^^^^^^^^^^^^^ Unused let definition `baz`. Remove it or use it in your tests.

        it 'uses foo' do
          expect(foo).to eq('bar')
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }

        it 'uses foo' do
          expect(foo).to eq('bar')
        end
      end
    RUBY
  end

  it 'registers an offense in nested context' do
    expect_offense(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }

        context 'nested' do
          let(:baz) { 'qux' }
          ^^^^^^^^^^^^^^^^^^^ Unused let definition `baz`. Remove it or use it in your tests.

          it 'uses foo' do
            expect(foo).to eq('bar')
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }

        context 'nested' do

          it 'uses foo' do
            expect(foo).to eq('bar')
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for let!' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe MyClass do
        let!(:foo) { 'bar' }

        it { expect(true).to be_truthy }
      end
    RUBY
  end

  it "does not register an offense for let that is used" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }

        specify { foo }
      end
    RUBY
  end

  it 'does not register an offense for let used in another let' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }
        let(:baz) { foo.upcase }

        it { expect(baz).to eq('BAR') }
      end
    RUBY
  end

  it 'does not register an offense for let used in nested context' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe MyClass do
        let(:foo) { 'bar' }

        context 'nested' do
          it { expect(foo).to eq('bar') }
        end
      end
    RUBY
  end

  it 'registers an offense for let in one context not used in sibling context' do
    expect_offense(<<~RUBY)
      RSpec.describe MyClass do
        context 'first' do
          let(:foo) { 'bar' }
          ^^^^^^^^^^^^^^^^^^^ Unused let definition `foo`. Remove it or use it in your tests.
        end

        context 'second' do
          it { expect(foo).to eq('bar') }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe MyClass do
        context 'first' do
        end

        context 'second' do
          it { expect(foo).to eq('bar') }
        end
      end
    RUBY
  end
end
