// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

I18n.defaultLocale = "zh-CN";
I18n.locale = "zh-CN";
I18n.currentLocale();

function hide_or_show(div_id)
{
    if ($(div_id).style.display == 'none'){
        $(div_id).show()
    } else {
        $(div_id).hide()
    }
}
