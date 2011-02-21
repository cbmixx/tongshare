require 'test_helper'

class AuthHelperTest < ActionView::TestCase
  test "encrypt-decrypte" do
    e = encrypt("Topsecret", AuthController::SECRET)
    pp e
    d = decrypt(e, AuthController::SECRET)
    assert d == "Topsecret"
  end

  test "general" do
    pp auth_path_with_password("2007011324", "Topsecret", "http://localhost:3000")
  end
end
