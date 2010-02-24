
local cosmo = require "cosmo"
local json = require "json"

local _M = {}

local form_preamble = cosmo.compile[=[
  <form $if{ id }[[ id = "$id" ]] action = "$url" method = "post">
]=]

local text_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <input name = "$name" type = "text" size = "$size" $attrs[[ $name = "$value" ]]/>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local textarea_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <textarea name = "$name" cols = "$width" rows = "$height" $attrs[[ $name = "$value" ]]></textarea>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local checkbox_control = cosmo.compile[=[$if{label}[[<p>$label ]]
    <input name = "$name" type = "checkbox" value = "1" $attrs[[ $name = "$value" ]]/>
    $if{ flash }[[<span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local richtext_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <textarea name = "$name" cols = "$width" rows = "$height" $attrs[[ $name = "$value" ]]></textarea>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]]
]=]

local combobox_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <select name = "$name" $if{size}[[size = "$size"]] $attrs[[ $name = "$value" ]]></select>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local radiogroup_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <div name = "$name" $attrs[[ $name = "$value" ]]></div>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local detailbox_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <div name = "$name" $attrs[[ $name = "$value" ]]>
      <div name = "detail"></div><br/>
      <button name = "add">Add New</button>
    </div>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local checkgroup_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <div name = "$name" $attrs[[ $name = "$value" ]]></div>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local multibox_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <select multiple = "true" name = "$name" $if{size}[[size = "$size"]] $attrs[[ $name = "$value" ]]></select>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]] ]=]

local tagbox_control = cosmo.compile[=[$if{label}[[<p>$label<br/>]]
    <div name = "$name">
      <input name = "$(name)_text" type = "text" size = "$size" $attrs[[ $name = "$value" ]]/> 
      <button name = "$(name)_button" $attrs[[ $name = "$value" ]]>Add</button><br/>
      <ul $attrs[[ $name = "$value" ]]></ul>
    </div>
    $if{ flash }[[<br/><span name = "$(name)_flash"  $flash[[ $name = "$value" ]]></span>]]$if{label}[[</p>]]
]=]

local button_control = cosmo.compile[=[<button name = "$name" value = "1" $attrs[[ $name = "$value" ]]>$label</button>]=]

local form_postamble = cosmo.compile[=[
  </form>
  <script type = "text/javascript">
    $$(document).ready(function() {
       var fields = { $concat{ fields }[['$name': new ajaxforms.$type($json{ attrs })]]
      };
       var buttons = { $concat{ buttons }[['$name': new ajaxforms.$type($json{ attrs })]]
      };
      var form = new ajaxforms.Form($if{ id }[[$$('#$id')]][[$dom]], '$url', fields, buttons);
      $if{ not hidden }[[ form.load($if{obj}[[$json{obj}]]); ]]
    });
  </script>
]=]

local form_flash = cosmo.compile[=[<div name = "flash" $attrs[[ $name = "$value" ]]></div>]=]

local field_flash = cosmo.compile[=[<span name = "$(name)_flash"  $attrs[[ $name = "$value" ]]></span>]=]

local function tab2list(tab)
  if tab then
    local list = {}
    for k, v in pairs(tab) do list[#list+1] = { name = k, value = v } end
    return list
  end
end

local function make_field(id, args, type)
  local field = { name = args.field, type = type, attrs = {} }
  for k, v in pairs(args) do 
    if not field[k] then
      field.attrs[k] = v
    end
  end
  return field
end

local function make_button(args, type)
  local field = { name = args.id, type = type, attrs = { name = args.id } }
  for k, v in pairs(args) do 
    if not field[k] then
      field.attrs[k] = v
    end
  end
  return field
end

local function make_control(template, args, defaults)
  local control = { name = args.field, flash = tab2list(args.flash), 
		    concat = cosmo.concat, ["if"] = cosmo.cif, attrs = {} }
  if args.attrs then
    for k, v in pairs(args.attrs) do
      control.attrs[#control.attrs+1] = { name = k, value = v }
    end
    args.attrs = nil
  end
  for k, v in pairs(args) do
    if not control[k] then
      control[k] = v
    end
  end
  for k, v in pairs(defaults) do
    if not control[k] then
      control[k] = v
    end
  end
  return template(control)
end

local button_types = {
  post = "SaveButton",
  post_redirect = "SaveRedirectButton",
  link = "RedirectButton",
  post_redirect_inline = "SaveRedirectInlineButton",
  post_redirect_result = "SaveRedirectResultButton",
  reset = "ResetButton",
  delete_self = "DetailDeleteButton"
}

function _M.form(args)
  local id, url = args.id, args.url
  cosmo.yield(form_preamble{ id = id, url = url, ["if"] = cosmo.cif }, true)
  local fields, buttons = {}, {}
  local env = {
    flash = function(args)
	      local attrs = {}
	      for k, v in pairs(args) do attrs[#attrs+1] = { name = k, value = v } end
	      return form_flash{ attrs = attrs }
	    end,
    flash_for = function(args)
	      local attrs = {}
	      local field = args.field
	      args.field = nil
	      for k, v in pairs(args) do attrs[#attrs+1] = { name = k, value = v } end
	      return field_flash{ name = field, attrs = attrs }
	    end,
    text = function (args)
	     fields[#fields+1] = make_field(id, args, "TextBox")
	     return make_control(text_control, args, { size = 100 })
	   end,
    textarea = function (args)
		 fields[#fields+1] = make_field(id, args, "TextBox")
		 return make_control(textarea_control, args, { width = 100, height = 10 })
	       end,
    richtext = function (args)
		 fields[#fields+1] = make_field(id, args, "RichTextBox")
		 return make_control(richtext_control, args, { width = 100, height = 10 })
	       end,
    check = function (args)
	      fields[#fields+1] = make_field(id, args, "CheckBox")
	      return make_control(checkbox_control, args, {})
	    end,
    combo = function (args)
	      fields[#fields+1] = make_field(id, args, "ComboBox")
	      return make_control(combobox_control, args, {})
	    end,
    radio = function (args)
	      fields[#fields+1] = make_field(id, args, "RadioGroup")
	      return make_control(radiogroup_control, args, {})
	    end,
    detail = function (args)
	      fields[#fields+1] = make_field(id, args, "DetailBox")
	      return make_control(detailbox_control, args, {})
	    end,
    checkgroup = function (args)
	           fields[#fields+1] = make_field(id, args, "CheckGroup")
	           return make_control(radiogroup_control, args, {})
	         end,
    multi = function (args)
	      fields[#fields+1] = make_field(id, args, "ListBox")
	      return make_control(multibox_control, args, { size = 5 })
	    end,
    tag = function (args)
	    fields[#fields+1] = make_field(id, args, "TagBox")
	    return make_control(tagbox_control, args, { size = 50 })
	  end,
    date = function (args)
	     fields[#fields+1] = make_field(id, args, "DatePicker")
	     return make_control(text_control, args, { size = 10 })
	  end,
    button = function (args)
	       local attrs = {}
	       if args.attrs then
		 for k, v in pairs(args.attrs) do
		   attrs[#attrs+1] = { name = k, value = v }
		 end
		 args.attrs = nil
	       end
	       buttons[#buttons+1] = make_button(args, button_types[args.action]) 
	       return button_control{ name = args.id, label = args.label, disabled = args.disabled,
				      attrs = attrs }
	     end
  }
  env.widgets = env
  cosmo.yield(env)
  cosmo.yield(form_postamble{ id = id, url = url, concat = cosmo.concat, buttons = buttons, 
			      fields = fields, ["if"] = cosmo.cif, obj = args.obj, hidden = args.hidden,
			      json = function (args) return json.encode(args[1]) end }, true)
end

return _M
