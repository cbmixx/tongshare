function add_members(data)
{
    /*if(data.empty)
    {
        alert(I18n.t('tongshare.sharing.add_empty'));
    }*/ //this alert is too stupid

    clear_errors();

    list = $('new_members');
    for(var i = 0; i < data.valid.size(); i++)
    {       
        var_item = data.valid[i];

        if($('new_member_' + var_item.id) != null)
        {
            $('new_member_' + var_item.id).remove();
        }

        li = new Element("li", {
            "id": "new_member_" + var_item.id
            });

        li.insert("<a href=\"javascript: del_member(" + var_item.id + ")\" class=\"del\">x</a>");
        li.insert("&nbsp;&nbsp;<span class=\"name\">" + var_item.name + "</span>");
        li.insert("<input type=\"hidden\" name=\"members[]\" value=\"" + var_item.id + "\">");
        list.insert(li);
    }

    if(data.dummy != null && data.dummy.size() > 0)
    {
        list = $('new_members');
        for(i = 0; i < data.dummy.size(); i++)
        {
            var_item = data.dummy[i];

            if($('new_dummy_' + var_item) != null)
            {
                continue;
            }

            li = new Element("li", {
                "id": "new_dummy_" + var_item
                });

            li.insert("<a href=\"javascript: del_dummy(" + var_item + ")\" class=\"del\">\u2717</a>");
            li.insert("&nbsp;&nbsp;<span class=\"name\">" + var_item + "</span>");
            li.insert("<input type=\"hidden\" name=\"dummy[]\" value=\"" + var_item + "\">");
            list.insert(li);
        }
    }

    if(data.new_email != null && data.new_email.size() > 0)
    {
        list = $('new_members');
        for(i = 0; i < data.new_email.size(); i++)
        {
            var_item = data.new_email[i];

            if($('new_email_' + var_item) != null)
            {
                continue;
            }

            li = new Element("li", {
                "id": "new_email_" + var_item
                });

            li.insert("<a href=\"javascript: del_new_email('" + var_item + "')\" class=\"del\">\u2717</a>");
            li.insert("&nbsp;&nbsp;<span class=\"name\">" + var_item + "</span>");
            li.insert("<input type=\"hidden\" name=\"new_email[]\" value=\"" + var_item + "\">");
            list.insert(li);
        }
    }

    show_errors("invalid", data.invalid);
    show_errors("parse_errored", data.parse_errored);

    toggle_nil_prompt();

    clear_raw_string();
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
    $("errors_parse_errored_container").hide();
    $("errors_invalid").innerHTML = "";
    $("errors_parse_errored").innerHTML = "";
}

function del_member(id)
{
    var_item = $('new_member_' + id);
    var_item.remove();
    toggle_nil_prompt();
}

function del_dummy(name)
{
    var_item = $('new_dummy_' + name);
    var_item.remove();
    toggle_nil_prompt();
}

function del_new_email(email)
{
    var_item = $('new_email_' + email);
    var_item.remove();
    toggle_nil_prompt();
}

function toggle_nil_prompt()
{
    if($('new_members').empty())
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

    if ($('raw_string').getValue().length > 0)
    {
        /*alert(I18n.t('tongshare.sharing.add_forgot'));
        $('add_members_submit').focus();*/

        //try automatic
        $('add_members_submit').click();
        alert(I18n.t('tongshare.sharing.add_forgot'));

        return false;
    }

    if (form.getInputs('hidden','members[]').size() == 0 && form.getInputs('hidden', 'dummy[]').size() == 0 && form.getInputs('hidden', 'new_email[]').size() == 0)
    {
        $('add_members_submit').focus();
        //return confirm(I18n.t('tongshare.sharing.empty'));
        alert(I18n.t('tongshare.sharing.add_empty'));
        return false;
    }
    else
    {
        return true;
    }
}

function clear_raw_string()
{
    $('raw_string').setValue("");
}

function raw_string_onkeyup(e)
{
    if (e.keyCode === 13 && e.ctrlKey)
    {
        $('add_members_submit').click();
    }
}

function raw_string_onblur()    //invoke when raw_string lose focus
{
    $('add_members_submit').click();
}

function toggle_conflict(id)
{
    Effect.toggle('conflict_' + id, 'slide', {duration: 0.5});
}

function confirmComboValue()
{
    friends_combo.confirmValue();
    groups_combo.confirmValue();
}

function clear()
{
    list = $('new_members');
    children = list.childElements();
    for(i=0; i<children.size(); i++)
        children[i].remove();
    toggle_nil_prompt();
}

function checkNewGroup(){
    if (groups_combo.getSelectedValue() == 'new'){
        $('group_name').value = '';
        $('group_name_container').show();
    }
    else{
        $('group_name_container').hide();
        $('group_name').value = groups_combo.getSelectedText();
    }
}
