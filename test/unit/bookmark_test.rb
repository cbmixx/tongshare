require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  test "limitation" do
    marks = []
    for i in 0...Bookmark::MAX_BOOKMARKS_PER_USER*2
      Bookmark.add_new_mark(1, marks[i] = SecureRandom.hex(16))
    end
    assert Bookmark.new_one_count(1) == Bookmark::MAX_BOOKMARKS_PER_USER
    for i in Bookmark::MAX_BOOKMARKS_PER_USER...Bookmark::MAX_BOOKMARKS_PER_USER*2
      Bookmark.find_by_user_id_and_mark(1, marks[i]).increase_count
    end
    assert Bookmark.old_one_count(1) == Bookmark::MAX_BOOKMARKS_PER_USER
    for i in 0...Bookmark::MAX_BOOKMARKS_PER_USER
      Bookmark.add_new_mark(1, marks[i] = SecureRandom.hex(16))
    end
    assert Bookmark.new_one_count(1) == Bookmark::MAX_BOOKMARKS_PER_USER
    assert Bookmark.old_one_count(1) == Bookmark::MAX_BOOKMARKS_PER_USER
    Bookmark.find_by_user_id_and_mark(1, marks[0]).increase_count
    assert Bookmark.find_by_user_id_and_mark(1, marks[Bookmark::MAX_BOOKMARKS_PER_USER]).nil?
    assert !Bookmark.find_by_user_id_and_mark(1, marks[0]).nil?
    assert Bookmark.new_one_count(1) == Bookmark::MAX_BOOKMARKS_PER_USER-1
    assert Bookmark.old_one_count(1) == Bookmark::MAX_BOOKMARKS_PER_USER
  end
end
