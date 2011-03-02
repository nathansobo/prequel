class Class
  def remove_class
    parent.send(:remove_const, name.demodulize)
  end
end