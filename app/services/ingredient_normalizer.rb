class IngredientNormalizer
  UNICODE_FRACTIONS = "¼½¾⅓⅔⅛⅜⅝⅞⅕⅖⅗⅘⅙⅚"

  UNITS = %w[
    cups? tablespoons? tbsps? teaspoons? tsps? pounds? lbs? ounces? oz
    grams? g kilograms? kg milliliters? ml liters? l pinch(?:es)? dash(?:es)?
    cloves? cans? packages? pkgs? slices? sticks? bunch(?:es)? heads?
    quarts? qts? pints? pts? sprigs? stalks? ears? fillets? leaves? drops?
  ].join("|").freeze

  NUMBER = /(?:\d+[\d\/.\s]*|[#{UNICODE_FRACTIONS}]+)/
  LEADING_QUANTITY = /\A\s*(?:#{NUMBER}\s*(?:-\s*#{NUMBER})?\s*)?(?:(?:#{UNITS})\b\.?\s*)?(?:of\s+)?/i
  LEADING_PARENTHETICAL = /\A\(([^)]*)\)\s*/
  LEADING_FILLER_WORDS = /\A(?:to taste|such as)\s*/i

  def self.call(raw_text)
    new(raw_text).normalize
  end

  def initialize(raw_text)
    @raw_text = raw_text.to_s.strip
  end

  def normalize
    text = strip_leading_quantity(@raw_text)
    text = text.split(/,| - |\(/).first.to_s.strip
    text = text.sub(LEADING_FILLER_WORDS, "")
    text.downcase.strip.gsub(/\s+/, " ")
  end

  private

  def strip_leading_quantity(text)
    3.times do
      stripped = text.sub(LEADING_QUANTITY, "").strip
      stripped = stripped.sub(LEADING_PARENTHETICAL, "").strip
      break if stripped == text
      text = stripped
    end
    text
  end
end