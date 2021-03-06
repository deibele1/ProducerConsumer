require './Buffer.rb'

$readers = 5
$writers = 10
$writes = 10
$buffer = 3

buffer = Buffer.new($buffer)
run = true;
$writers = $writers.times.map { |integer| Thread.new { $writes.times { |write| buffer << "#{write} written by writer #{integer}" } } }
$readers = $readers.times.map { |integer| Thread.new { puts("Reader #{integer} processed: #{buffer.>>}") while run } }
$writers.each(&:join)
run = false
$readers.each(&:join)
