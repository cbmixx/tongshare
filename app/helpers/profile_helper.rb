module ProfileHelper
  RENREN_PROFILE_PATH = "/var/www/renren/"

  # returns [num_selection(profile), renren_urls, photo_urls, department]
  def find_profiles(user)
    thu_no = user.get_thu_no
    return nil if (thu_no.nil? || user.user_extra.nil?)
    Dir.chdir(RENREN_PROFILE_PATH)
    filenames = Dir['*'+thu_no.to_s]
    return nil if (filenames.nil? || filenames.size == 0)
    filename = filenames[0]

    file = File.open(filename + '/info.txt')
    lines = file.readlines
    department = lines[2]
    #TODO high school in the future

    return nil if (lines.size <= 6)

    num_selection = lines[6].to_i
    renren_urls = []
    photo_urls = []
    for i in 0...num_selection
      renren_urls << lines[7 + i*3]
      photo_urls << lines[8 + i*3]
    end

    return [num_selection, renren_urls, photo_urls, department]
  end
end
