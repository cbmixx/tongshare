// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

I18n.defaultLocale = "zh-CN";
I18n.locale = "zh-CN";
I18n.currentLocale();

function show_repeat_options(type, div_id)
{
    if (div_id == null)
    {
        div_id = 'repeat_options';
    }

    if (type == "NONE" && $(div_id).visible())
    {
        Effect.BlindUp(div_id, {duration: 0.2});
    }
    else if (type != "NONE" && ! $(div_id).visible())
    {
        Effect.BlindDown(div_id, {duration: 0.2});
    }

    $("repeat_legend").innerHTML = I18n.t("tongshare.event.recurrence." + type.toLowerCase());

    if(type != "NONE")
    {
        $("interval_suffix").innerHTML = I18n.t("tongshare.event.recurrence.interval_suffix_" + type.toLowerCase());
    }

    switch(type)
    {
        case "NONE":
            $("rrule_days_panel").hide();
            break;

        case "WEEKLY":
            $("rrule_days_panel").show();
            break;  //TODO: show specific options for different types

        case "DAILY":
            $("rrule_days_panel").hide();
            break;
    }
}
