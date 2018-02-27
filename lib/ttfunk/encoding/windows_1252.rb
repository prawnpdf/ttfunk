# frozen_string_literal: true

module TTFunk
  module Encoding
    class Windows1252
      TO_UNICODE =
        Hash[*(0..255).zip((0..255)).flatten]
        .update(
          0x80 => 0x20AC, 0x82 => 0x201A, 0x83 => 0x0192, 0x84 => 0x201E,
          0x85 => 0x2026, 0x86 => 0x2020, 0x87 => 0x2021, 0x88 => 0x02C6,
          0x89 => 0x2030, 0x8A => 0x0160, 0x8B => 0x2039, 0x8C => 0x0152,
          0x8E => 0x017D, 0x91 => 0x2018, 0x92 => 0x2019, 0x93 => 0x201C,
          0x94 => 0x201D, 0x95 => 0x2022, 0x96 => 0x2013, 0x97 => 0x2014,
          0x98 => 0x02DC, 0x99 => 0x2122, 0x9A => 0x0161, 0x9B => 0x203A,
          0x9C => 0x0152, 0x9E => 0x017E, 0x9F => 0x0178
        ).freeze

      FROM_UNICODE = TO_UNICODE.invert.freeze

      def self.covers?(character)
        !FROM_UNICODE[character].nil?
      end

      def self.to_utf8(string)
        to_unicode_codepoints(string.unpack('C*')).pack('U*')
      end

      def self.to_unicode(string)
        to_unicode_codepoints(string.unpack('C*')).pack('n*')
      end

      def self.from_utf8(string)
        from_unicode_codepoints(string.unpack('U*')).pack('C*')
      end

      def self.from_unicode(string)
        from_unicode_codepoints(string.unpack('n*')).pack('C*')
      end

      def self.to_unicode_codepoints(array)
        array.map { |code| TO_UNICODE[code] }
      end

      def self.from_unicode_codepoints(array)
        array.map { |code| FROM_UNICODE[code] || 0 }
      end
    end
  end
end
