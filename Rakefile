Lib = "DataMutators"
TestDir = "test"

# General parameters that the user can set from the command line.
Julia = ENV["minreps"] || "julia"
MinReps = (ENV["minreps"] || 30).to_i
MaxReps = (ENV["maxreps"] || 1000).to_i
MaxRepTime = (ENV["maxreptime"] || 1.0).to_f
Verbosity = ENV["verbosity"] || 2
MoreFactor = (ENV["morefactor"] || 10).to_i
MostFactor = (ENV["mostfactor"] || 1000).to_i
TimedTestMinFactor = (ENV["timedminfactor"] || 10).to_i
TimedTestMaxFactor = (ENV["timedmaxfactor"] || 1000).to_i

MainFile = "src/#{Lib}.jl"
BaseCommand = "#{Julia} --color=yes -L #{MainFile}"

desc "AutoTest testing"
task :atest do
  sh "#{BaseCommand} test/run_autotests.jl"
end

Command = "#{Julia} --color=yes -L src/#{Lib}.jl"
Command03 = "julia03 --color=yes -L src/#{Lib}.jl"

desc "Run normal (fast) tests"
task :runtest do
  sh "#{Command} test/runtests.jl"
end

desc "Run normal (fast) tests on julia 0.3"
task :runtest03 do
  sh "#{Command03} test/runtests.jl"
end

desc "Run slow tests"
task :runslowtest do
  sh "#{Command} test/runslowtests.jl"
end

desc "Run all tests"
task :runalltest => [:runtest, :runslowtest]

desc "Compare optimizers on standard, example problems"
task :compare_optimizers do
  sh "#{Command} -L test/helper.jl test/test_compare_optimizers.jl"
end

def filter_latest_changed_files(filenames, numLatestChangedToInclude = 1)
  filenames.sort_by{ |f| File.mtime(f) }[-numLatestChangedToInclude, numLatestChangedToInclude]
end

desc "Run only the latest changed test file"
task :t do
  latest_changed_test_file = filter_latest_changed_files Dir["test/**/test*.jl"]
  sh "#{Command} -L test/helper.jl #{latest_changed_test_file.first}"
end

desc "Run and create code coverage information"
task :coverage do
  sh "#{Command} --code-coverage test/runtests.jl"
end

desc "Clear build files etc"
task :clobber do
  Dir['**/*.jl.cov'].each do |f|
    puts "Deleting #{f}"
    File.delete(f)
  end
end

task :at => :runalltest
task :st => :runslowtest

task :default => :runtest

def loc_of_files(files)
  lines = files.map {|fn| File.readlines(fn)}
  nonblanklines = lines.map {|ls| ls.select {|line| line.strip.length > 0}}
  loc = lines.map {|ls| ls.length}.inject(0) {|s,e| s+e}
  nbloc = nonblanklines.map {|ls| ls.length}.inject(0) {|s,e| s+e}
  return loc, nbloc, files.length
end

desc "Count LOC"
task :loc do
  srcloc, srcnbloc, numsrcfiles = loc_of_files(Dir["src/**/*.jl"])
  testloc, testnbloc, numtestfiles = loc_of_files(Dir["test/**/*.jl"])
  puts "Source files: #{numsrcfiles} files\t\t#{srcloc} LOC\t\t(#{srcnbloc} non-blank LOC)"
  puts "Test   files: #{numtestfiles} files\t\t#{testloc} LOC\t\t(#{testnbloc} non-blank LOC)"
  if testloc > 0 && srcloc > 0
    puts("Test to code ratio:\t\t%.3f   \t\t(%.3f)" % [(testloc.to_f/srcloc), (testnbloc.to_f/srcnbloc)])
  end
end
