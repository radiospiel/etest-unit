class String
  # taken from active-support
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  def camelize(first_letter = :upper)
    camelized = gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    if first_letter == :lower
      camelized.gsub!(/^./) { $1.downcase }
    end
    camelized
  end
end
