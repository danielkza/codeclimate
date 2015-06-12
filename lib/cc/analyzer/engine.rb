require "posix/spawn"

module CC
  module Analyzer
    class Engine
      attr_reader :name

      TIMEOUT = 15 * 60 # 15m

      def initialize(name, metadata, code_path, config_path, label)
        @name = name
        @metadata = metadata
        @code_path = code_path
        @config_path = config_path
        @label = label.to_s
      end

      def run(stdout_io, stderr_io = StringIO.new)
        pid, _, out, err = POSIX::Spawn.popen4(*docker_run_command)

        t_out = Thread.new do
          out.each_line("\0") do |chunk|
            stdout_io.write(chunk.chomp("\0"))
          end
        end

        t_err = Thread.new do
          err.each_line do |line|
            if stderr_io
              stderr_io.write(line)
            end
          end
        end

        pid, status = Process.waitpid2(pid)

        if status.exitstatus > 0
          stdout_io.failed(stderr_io.string)
        end
      ensure
        t_out.join if t_out
        t_err.join if t_err
      end

      private

      def docker_run_command
        [
          "docker", "run",
          "--rm",
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--memory", 512_000_000.to_s, # bytes
          "--memory-swap", "-1",
          "--net", "none",
          "--volume", "#{@code_path}:/code:ro",
          "--volume", "#{@config_path}:/config.json:ro",
          @metadata["image_name"],
          @metadata["command"], # String or Array
        ].flatten.compact
      end
    end
  end
end