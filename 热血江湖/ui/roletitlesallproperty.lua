module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_roleTitlesAllProperty = i3k_class("wnd_roleTitlesAllProperty", ui.wnd_base)

local LAYER_TIPS	= "ui/widgets/chtipst2"

function wnd_roleTitlesAllProperty:ctor()
	self.allTitleValue = {}
end



function wnd_roleTitlesAllProperty:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.desText = widgets.desText
end
function wnd_roleTitlesAllProperty:onShowData()
	local validTitle = g_i3k_game_context:GetValidTitleInfo()
	local property = {}
	for k, v in pairs(validTitle) do
		local cfg = i3k_db_title_base[v]
		if cfg then
			local attribute = {}
			local value = {}
			attribute[1] = cfg.attribute1
			attribute[2] = cfg.attribute2
			attribute[3] = cfg.attribute3
			attribute[4] = cfg.attribute4
			attribute[5] = cfg.attribute5
			value[1]     = cfg.value1
			value[2]     = cfg.value2
			value[3]     = cfg.value3
			value[4]     = cfg.value4
			value[5]     = cfg.value5
			for i=1, 5 do
				if attribute[i] then
					if i3k_db_prop_id[attribute[i]] then
						if property[attribute[i]] then
							property[attribute[i]] = property[attribute[i]] + value[i]
						else
							property[attribute[i]] = value[i]
						end
					end
				end
			end
		end
	end
	for i,e in pairs(property) do
		local _layer = require(LAYER_TIPS)()
		local widget = _layer.vars
		widget.path_pos:setText(i3k_db_prop_id[i].desc)
		widget.path_name:setText(i3k_get_prop_show(i,e))
		self.scroll:addItem(_layer)
	end
end

function wnd_roleTitlesAllProperty:refresh()
	self.desText:setText(i3k_get_string(15544))
	self:onShowData()
end



function wnd_roleTitlesAllProperty:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleTitlesAllProperty)
end

function wnd_create(layout)
	local wnd = wnd_roleTitlesAllProperty.new();
		wnd:create(layout);

	return wnd;
end