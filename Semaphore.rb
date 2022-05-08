class Semaphore
  def initialize
    @mutex = Mutex.new
    @count = 0
  end

  def signal
    @mutex.synchronize do
      @count += 1
    end
  end

  def release
    @mutex.synchronize do
      @count -= 1
      @count + 1
    end
  end

  def synchronize(&block)
    @mutex.synchronize(&block)
  end

  def peek
    @count
  end

  def -(other)
    @mutex.synchronize do
      other.synchronize do
        @count - other.peek
      end
    end
  end

  def +(other)
    @mutex.synchronize do
      other.synchronize do
        @count + other.peek
      end
    end
  end
end
