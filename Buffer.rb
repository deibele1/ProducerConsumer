require 'set'
class Buffer
  def initialize(size)
    @read = Mutex.new
    @write = Mutex.new
    @size = size
    @write_point = 0
    @read_point = 0
    @buffer = []
    @waiting_writers = []
    @waiting_readers = []
    @readers_set = Set.new
  end

  def <<(data)
    @write.lock
    @read.lock
    while @write_point - @size > @read_point
      @waiting_writers << Thread.current
      @read.unlock
      @write.unlock
      wait
      @write.lock
      @read.lock
    end
    @read.unlock
    @buffer[@write_point] = data
    @write_point += 1
    next_thread = @waiting_readers.shift
    if next_thread
      Thread.pass until next_thread.stop?
      next_thread.wakeup
    end
    @write.unlock
  end

  def >>
    @readers_set.add(Thread.current)
    @write.lock
    @read.lock
    while @write_point == @read_point
      @waiting_readers << Thread.current
      @read.unlock
      @write.unlock
      wait
      @write.lock
      @read.lock
    end
    @write.unlock
    result = @buffer[@read_point]
    @read_point += 1
    next_thread = @waiting_writers.shift
    if next_thread
      Thread.pass until next_thread.stop?
      next_thread.wakeup
    end
    @read.unlock
    result
  end

  def wait
    sleep
  end

  def close
    define_singleton_method :wait do
      Thread.current.kill
    end
    @readers_set.each(&:wakeup)
    @readers_set.each(&:join)
  end
end
