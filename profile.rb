class Profile
  attr_accessor :bio, :job, :schools

  def initialize(profile_hash:)
    @bio = profile_hash['bio']
    @job = find_job(job_hash: profile_hash['jobs'][0])
    @schools = profile_hash['schools'].collect{ |school| school['name'] }
  end

  def find_job(job_hash:)
    return nil unless job_hash
    key = job_hash.keys[0]
    job_hash[key]['name'] if key
  end

  def all_text
    [job, schools.join(' '), bio].join("\n")
  end
end