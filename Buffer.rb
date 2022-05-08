require './compariphore'
class Buffer
  def initialize(size)
    @compariphore = Compariphore.new(size)
    @size = size
    @data = []
  end

  def <<(data)
    @data[@compariphore.signal % @size] = data
  end

  def >>
    index = @compariphore.release % @size
    datum = @data[index]
    @data[index] = nil
    datum
  end
end
