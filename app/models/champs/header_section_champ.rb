class Champs::HeaderSectionChamp < Champ
  def search_terms
    # The user cannot enter any information here so it doesn’t make much sense to search
  end

  def section_index
    siblings
      .filter { |c| c.type_champ == TypeDeChamp.type_champs.fetch(:header_section) }
      .take_while { |c| c != self }
      .push(self)
      .reduce([0, 0, 0]) do |index, c|
      level = c.type_de_champ.level.to_i
      level -= 1 if level > 0
      r = level > 0 ? index[0..(level - 1)] : []
      r << index[level].to_i + 1
    end.reject(&:zero?).join('.')
  end
end
