require_relative 'spec_helper'

describe Kramdown::Converter::AsciiDoc do
  let(:opts) { Kramdown::Converter::AsciiDoc::DEFAULT_PARSER_OPTS }
  let(:doc) { Kramdown::Document.new input, opts }
  let(:root) { doc.root }
  subject { described_class.send :new, root, {} }

  describe '#convert_p' do
    context 'when paragraph is normal' do
      let :input do
        <<~EOS.chomp
        A normal paragraph.
        EOS
      end
      let :expected do
        <<~EOS.chomp
        A normal paragraph.\n\n
        EOS
      end
      it 'should leave paragraph as is' do
        (expect subject.convert_p root.children.first, {}).to eq expected
      end
    end

    context 'when paragraph starts with admonition label' do
      let :input do
        <<~EOS.chomp
        Note: Remember the milk!
        EOS
      end
      let :expected do
        <<~EOS.chomp
        NOTE: Remember the milk!\n\n
        EOS
      end
      it 'should promote paragraph to admonition paragraph' do
        (expect subject.convert_p root.children.first, {}).to eq expected
      end
    end

    context 'when paragraph starts with emphasized admonition label' do
      let :input do
        <<~EOS.chomp
        *Note:* Remember the milk!
        EOS
      end
      let :expected do
        <<~EOS.chomp
        NOTE: Remember the milk!\n\n
        EOS
      end
      it 'should promote paragraph to admonition paragraph' do
        (expect subject.convert_p root.children.first, {}).to eq expected
      end
    end

    context 'when paragraph starts with strong admonition label' do
      let :input do
        <<~EOS.chomp
        **Note:** Remember the milk!
        EOS
      end
      let :expected do
        <<~EOS.chomp
        NOTE: Remember the milk!\n\n
        EOS
      end
      it 'should promote paragraph to admonition paragraph' do
        (expect subject.convert_p root.children.first, {}).to eq expected
      end
    end

    context 'when paragraph starts with emphasized admonition label and colon is outside of formatted text' do
      let :input do
        <<~EOS.chomp
        *Note*: Remember the milk!
        EOS
      end
      let :expected do
        <<~EOS.chomp
        NOTE: Remember the milk!\n\n
        EOS
      end
      it 'should promote paragraph to admonition paragraph' do
        (expect subject.convert_p root.children.first, {}).to eq expected
      end
    end
  end

  describe '#convert_ul' do
    context 'when not nested' do
      let :input do
        <<~EOS.chomp
        * bread
        * milk
        * eggs
        EOS
      end
      let :expected do
        <<~EOS
        * bread
        * milk
        * eggs\n
        EOS
      end
      it 'should convert to lines with leading asterisks' do
        (expect subject.convert_ul root.children.first, {}).to eq expected
      end
    end

    context 'when nested' do
      let :input do
        <<~EOS.chomp
        * bread
          * white
          * sourdough
          * rye
        * milk
          * 2%
          * whole
          * soy
        * eggs
          * white
          * brown
        EOS
      end
      let :expected do
        <<~EOS
        * bread
         ** white
         ** sourdough
         ** rye
        * milk
         ** 2%
         ** whole
         ** soy
        * eggs
         ** white
         ** brown\n
        EOS
      end
      it 'should increase number of asterisks per level' do
        (expect subject.convert_ul root.children.first, {}).to eq expected
      end
    end
  end

  describe '#convert_img' do
    context 'when image is inline' do
      let(:input) { 'See the ![Rate of Growth](rate-of-growth.png)' }

      it 'should convert to inline image' do
        expected = 'image:rate-of-growth.png[Rate of Growth]'
        p = root.children.first
        (expect subject.convert_img p.children.last, { parent: p }).to eq expected
      end

      it 'should put inline image adjacent to text' do
        expected = %(See the image:rate-of-growth.png[Rate of Growth]\n\n)
        (expect subject.convert_p root.children.first, {}).to eq expected
      end
    end

    context 'when image is only element in paragraph' do
      let(:input) { '![Rate of Growth](rate-of-growth.png)' }

      it 'should convert to block image' do
        expected = %(image::rate-of-growth.png[Rate of Growth]\n\n)
        (expect subject.convert_p root.children.first, {}).to eq expected
      end
    end
  end

  describe '#convert_codeblock' do
    context 'when code block is fenced' do
      let :input do
        <<~EOS.chomp
        ```
        All your code.
        
        Belong to us.
        ```
        EOS
      end
      let :expected do
        <<~EOS.chomp
        ----
        All your code.
        
        Belong to us.
        ----\n\n
        EOS
      end
      it 'should convert to listing block' do
        (expect subject.convert_codeblock root.children.first, {}).to eq expected
      end
    end

    context 'when code block is fenced with language' do
      let :input do
        <<~EOS.chomp
        ```java
        public class AllYourCode {
          public String getBelongsTo() {
            return "Us.";
          }
        }
        ```
        EOS
      end
      let :expected do
        <<~EOS.chomp
        [source,java]
        ----
        public class AllYourCode {
          public String getBelongsTo() {
            return "Us.";
          }
        }
        ----\n\n
        EOS
      end
      it 'should convert to source block with language' do
        (expect subject.convert_codeblock root.children.first, {}).to eq expected
      end
    end
  end

  describe '#convert_codeblock' do
    context 'when horizontal rule is found' do
      let(:input) { '---' }
      let(:expected) { %('''\n\n) }
      it 'should convert to thematic break' do
        (expect subject.convert_hr root.children.first, {}).to eq expected
      end
    end
  end

  describe '#convert_native' do
    let(:input) { '<p><b>bold</b> <em>italic</em> <code>mono</code></p>' }
    let(:expected) { '*bold* _italic_ `mono`' }
    it 'should convert HTML to formatted AsciiDoc' do
      (expect doc.to_asciidoc).to eq expected
    end
  end
end
