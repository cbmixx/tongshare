function add_members(data)
{
    clear_errors();

    list = $('new_members');
    for(var i = 0; i < data.valid.size(); i++)
    {       
        item = data.valid[i];

        if($('new_member_' + item.id) != null)
        {
            continue;
        }

        li = new Element("li", {
            "id": "new_member_" + item.id
            });
        li.insert("<span class=\"name\">" + item.name + "</span>");
        li.insert("&nbsp;&nbsp;<a href=\"javascript: del_member(" + item.id + ")\" class=\"del\">\u2717</a>");
        li.insert("<input type=\"hidden\" name=\"members[]\" value=\"" + item.id + "\">");
        list.insert(li);
    }

    if(data.dummy != null && data.dummy.size() > 0)
    {
        $('new_dummy_container').show();
        list = $('new_dummy');
        for(i = 0; i < data.dummy.size(); i++)
        {
            item = data.dummy[i];

            if($('new_dummy_' + item) != null)
            {
                continue;
            }

            li = new Element("li", {
                "id": "new_dummy_" + item
                });
            li.insert("<span class=\"name\">" + item + "</span>");
            li.insert("&nbsp;&nbsp;<a href=\"javascript: del_dummy(" + item + ")\" class=\"del\">\u2717</a>");
            li.insert("<input type=\"hidden\" name=\"dummy[]\" value=\"" + item + "\">");
            list.insert(li);
        }
    }

    show_errors("invalid", data.invalid);
    show_errors("duplicated", data.duplicated);
    show_errors("parse_errored", data.parse_errored);

    toggle_nil_prompt();
}

function show_errors(type, data)
{
    if(data != null && data.size() > 0)
    {
        $("errors_" + type + "_container").show();
        list = $("errors_" + type);
        for(var i = 0; i < data.size(); i++)
        {
            list.insert("<li>" + data[i] + "</li>");
        }
    }
}

function clear_errors()
{
    $("errors_invalid_container").hide();
    $("errors_duplicated_container").hide();
    $("errors_parse_errored_container").hide();
    $("errors_invalid").innerHTML = "";
    $("errors_duplicated").innerHTML = "";
    $("errors_parse_errored").innerHTML = "";
}

function del_member(id)
{
    item = $('new_member_' + id);
    item.remove();
    toggle_nil_prompt();
}

function del_dummy(name)
{
    item = $('new_dummy_' + name);
    item.remove();
    if($('new_dummy').empty())
    {
        $('new_dummy_container').hide();
    }
    toggle_nil_prompt();
}

function toggle_nil_prompt()
{
    if($('new_dummy').empty() && $('new_members').empty())
    {
        $('new_member_nil').show();
    }
    else
    {
        $('new_member_nil').hide();
    }
}

function checkFormValid(form)
{
    if (form.getInputs('hidden','members[]').size() == 0 && form.getInputs('hidden', 'dummy[]').size() == 0)
    {
        alert(I18n.t('tongshare.sharing.empty'));
        return false;
    }
    else
    {
        return true;
    }
}