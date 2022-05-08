require './Semaphore'
class Compariphore
  def initialize(max)
    @max = max.freeze
    @mutex = Mutex.new
    @read = Mutex.new
    @write = Mutex.new
    @bottom = Semaphore.new
    @top = Semaphore.new
  end

  def diff
    @mutex.synchronize do
      @top - @bottom
    end
  end

  def bottom
    @bottom.peek
  end

  def top
    @top.peek
  end

  def signal
    @write.synchronize do
      @top.signal
      Thread.pass until diff < @max
      @top.peek
    end
  end

  def release
    @read.synchronize do
      @bottom.signal
      Thread.pass until diff > 0
      @bottom.peek
    end

  end

end
