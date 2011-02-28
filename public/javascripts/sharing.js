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
        li.insert("<a href=\"javascript: del_member(" + item.id + ")\" class=\"del\">删除</a>");
        li.insert("<input type=\"hidden\" name=\"members[]\" value=\"" + item.id + "\">");
        list.insert(li);
    }

    show_errors("dummy", data.dummy);
    show_errors("invalid", data.invalid);
    show_errors("parse_errored", data.parse_errored);
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
    $("errors_dummy_container").hide();
    $("errors_invalid_container").hide();
    $("errors_parse_errored_container").hide();
    $("errors_dummy").innerHTML = "";
    $("errors_invalid").innerHTML = "";
    $("errors_parse_errored").innerHTML = "";
}

function del_member(id)
{
    item = $('new_member_' + id);
    item.remove();
}