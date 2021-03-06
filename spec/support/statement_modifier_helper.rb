# frozen_string_literal: true

module StatementModifierHelper
  def check_empty(cop, keyword)
    inspect_source(<<-RUBY.strip_indent)
      #{keyword} cond
      end
    RUBY
    expect(cop.offenses).to be_empty
  end

  def check_really_short(cop, keyword)
    inspect_source(<<-RUBY.strip_indent)
      #{keyword} a
        b
      end
    RUBY
    expect(cop.messages).to eq(
      ["Favor modifier `#{keyword}` usage when having a single-line body."]
    )
    expect(cop.offenses.map { |o| o.location.source }).to eq([keyword])
  end

  def autocorrect_really_short(keyword)
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      #{keyword} a
        b
      end
    RUBY
    expect(corrected).to eq "b #{keyword} a\n"
  end

  def check_too_long(cop, keyword)
    # This statement is one character too long to fit.
    condition = 'a' * (40 - keyword.length)
    body = 'b' * 37
    expect("  #{body} #{keyword} #{condition}".length).to eq(81)

    inspect_source(<<-RUBY.strip_margin('|'))
      |  #{keyword} #{condition}
      |    #{body}
      |  end
    RUBY

    expect(cop.offenses).to be_empty
  end

  def check_short_multiline(cop, keyword)
    inspect_source(<<-RUBY.strip_indent)
      #{keyword} ENV['COVERAGE']
        require 'simplecov'
        SimpleCov.start
      end
    RUBY
    expect(cop.messages).to be_empty
  end
end
