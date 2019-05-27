# frozen_string_literal: true

module TextHelpers
  def strip_leading_spaces(str)
    # isolate leading spaces for all lines then choose the shortest, i.e. the
    # number of leading spaces all the lines have in common
    min_leader_len = str.scan(/^(\s+)/).flatten.min_by(&:length).length

    # remove the first min_leader_len leading spaces from each line
    str.gsub(/^\s{#{min_leader_len}}/, '')
  end
end
