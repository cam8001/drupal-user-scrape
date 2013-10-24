module Kernel
  private
  alias open_test_original_open open # :nodoc:
  class << self
    alias open_test_original_open open # :nodoc:
  end

  def open(name, *rest, &block) # :doc:
    p 'Used our module.'
    open_test_original_open(name, *rest, &block)
  end
end

open('/tmp/foo.txt')
