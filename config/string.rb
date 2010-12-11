# encoding: utf-8

class String
  # Converts the Greek Unicode characters contained in the string
  # to latin ones (aka greeklish) and returns self.
  # For unobstructive conversion call the non-bang method 'greeklish'
  #
  # example:
  #   puts 'αβγδεζηθικλμνξοπρστυφχψω άέήίϊΐόύ ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ ABCDEFGHIJKLMNOPQRSTUVXYZ'.greeklish
  # returns:
  #   avgdezhthiklmnksoprstyfxpsw aehiiioy AVGDEZHTHIKLMNKSOPRSTYFXPSW ABCDEFGHIJKLMNOPQRSTUVXYZ
  def greeklish!
    mapping_table = {
        'ά' => 'a', 'α' => 'a', 'Α' => 'A', 'Ά' => 'A',
        'β' => 'v', 'Β' => 'V',
        'γ' => 'g', 'Γ' => 'G',
        'δ' => 'd', 'Δ' => 'D',
        'έ' => 'e', 'ε' => 'e', 'Ε' => 'E', 'Έ' => 'E',
        'ζ' => 'z', 'Ζ' => 'Z',
        'ή' => 'h', 'η' => 'h', 'Η' => 'H', 'Ή' => 'H',
        'θ' => 'th', 'Θ' => 'TH',
        'ί' => 'i', 'ϊ' => 'i', 'ΐ' => 'i', 'ι' => 'i', 'Ι' => 'I', 'Ί' => 'I',
        'κ' => 'k', 'Κ' => 'K',
        'λ' => 'l', 'Λ' => 'L',
        'μ' => 'm', 'Μ' => 'M',
        'ν' => 'n', 'Ν' => 'N',
        'ξ' => 'x', 'Ξ' => 'X',
        'ό' => 'o', 'ο' => 'o', 'Ό' => 'O','Ο' => 'O',
        'π' => 'p', 'Π' => 'P',
        'ρ' => 'r', 'Ρ' => 'R',
        'σ' => 's', 'Σ' => 'S', 'ς' => 's',
        'τ' => 't', 'Τ' => 'T',
        'ύ' => 'y', 'υ' => 'y', 'Ύ' => 'Y','Υ' => 'Y',
        'φ' => 'f', 'Φ' => 'F',
        'χ' => 'x', 'Χ' => 'X',
        'ψ' => 'ps', 'Ψ' => 'PS',
        'ώ' => 'w', 'ω' => 'w', 'Ώ' => 'W','Ω' => 'W'
    }

    i = 0
    self.each_char do |char|
      self[i] = (mapping_table[char] ? mapping_table[char] : char)
      i += 1
    end

    self[0..i-1]
  end

  # Returns a new string which is converted from Greek Unicode characters
  # to latin ones (aka greeklish)
  def greeklish
    self.dup.greeklish!
  end
end

