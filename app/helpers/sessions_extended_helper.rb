module SessionsExtendedHelper
  def login_type_selector(type, checked = false)
    radio = radio_button_tag('login_type', type, checked)
    label = label_tag("login_type_#{type}", I18n.t("activerecord.attributes.user_identifier.#{type}"))
    radio + label
  end
end
