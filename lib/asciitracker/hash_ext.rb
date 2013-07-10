class Hash;def /(key);self[key];end end

class Hash
  # _why's hash implant with a twist: the difference is to throw a
  # NoMethodError instead returning nil when asking for a non-existing value 
  def method_missing(m,*a)
    if m.to_s =~ /=$/
      self[$`.to_sym] = a[0]
    elsif a.empty?
      self[m]
    else
      raise NoMethodError, "#{m}"
    end
  end
end
