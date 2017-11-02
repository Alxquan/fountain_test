gem 'pry'
require 'pry'

class HiringManager
  def initialize(file_name)
    @stats_array = []
    @stages = []
    @applicants = {}
    @hired = []
    @rejected = []
    input_file = File.open(file_name)
    @instructions = input_file.map { |line| line.split }
  end

  def process
    @instructions.each do |args|
      cmd = args.shift
      self.send(cmd.downcase, *args)
    end

    output = File.open("output.txt", "w")
    output.write @stats_array.join("\n")
    output.close
  end

  def define(*stage_names)
    interview_stages = %w[ManualReview PhoneInterview BackgroundCheck DocumentSigning]

    stage_names.select!{ |stage| interview_stages.include? stage}
    @stages = stage_names
    @stats_array << "DEFINE #{stage_names.join(" ")}"
  end

  def create(email)
    unless @applicants.key?(email)
      @applicants[email] = 0
      @stats_array << "CREATE #{email}"
    else
      @stats_array << "Duplicate applicant"
    end
  end

  def advance(email, stage_name = nil)
    current_stage = @applicants[email]
    if stage_name == nil
      next_stage = current_stage + 1
    else
      next_stage = @stages.index(stage_name)
    end

    if next_stage > current_stage && next_stage < @stages.count
      @applicants[email] = next_stage
      @stats_array << "ADVANCE #{email}"
    else
      @stats_array << "Already in #{stage_name}"
    end
  end

  def decide(email, decision)
    current_stage = @applicants[email]
    last_stage = @stages.count - 1
    if decision == "1" &&  current_stage == last_stage
      @hired << email
      @applicants.delete(email)
      @stats_array << "Hired #{email}"
    elsif decision == "1" && current_stage != last_stage
      @stats_array << "Failed to decide for #{email}"
    else
      @rejected << email
      @applicants.delete(email)
      @stats_array << "Rejected #{email}"
    end
  end

  def stats
    stats = []
    @stages.each_with_index do |stage, index|
      apps_at_stage = @applicants.select { |_ , i| i == index }
      total = apps_at_stage.count
      stats << "#{stage} #{total}"
    end
    @stats_array << "#{stats.join(" ")} Hired #{@hired.count} Rejected #{@rejected.count}"
  end

end

HiringManager.new("input.txt").process

