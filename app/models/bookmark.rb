class Bookmark < ActiveRecord::Base
  attr_accessible :user_id, :mark, :count

  MAX_BOOKMARKS_PER_USER = 64
  
  def increase_count
    self.count += 1
    save!
    Bookmark.adjust(self.user_id)
  end

  def self.add_new_mark(user_id, mark)
    Bookmark.create(:user_id => user_id, :mark => mark, :count => 0)
    Bookmark.adjust(user_id)
  end

  def self.old_one_count(user_id)
    return Bookmark.count_by_sql "SELECT COUNT(*) FROM bookmarks WHERE user_id=#{user_id} AND count > 0"
  end

  def self.new_one_count(user_id)
    return Bookmark.count_by_sql "SELECT COUNT(*) FROM bookmarks WHERE user_id=#{user_id} AND count = 0"
  end

  def self.adjust(user_id)
    while (old_one_count(user_id) > MAX_BOOKMARKS_PER_USER)
      Bookmark.find(:first, :conditions => ["user_id = ? AND count > 0", user_id],
        :order => 'updated_at').destroy
    end
    while (new_one_count(user_id) > MAX_BOOKMARKS_PER_USER)
      Bookmark.find(:first, :conditions => ["user_id = ? AND count = 0", user_id],
        :order => 'updated_at').destroy      
    end
  end
end
