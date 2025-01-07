# require Tiex our testing module
import_file("~/.miex_helpers.exs")

# run mix tasks by name
# mx("format")
# also you can run &r/0 to recompile and format
# import_file("~/.miex.exs")

IO.puts("current PID is:")
IO.inspect(self())
