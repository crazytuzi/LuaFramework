-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_martialSoulProp = i3k_class("wnd_martialSoulProp", ui.wnd_base)
local Proptipst = "ui/widgets/wuhuntipst"
function wnd_martialSoulProp:ctor()
	
end

function wnd_martialSoulProp:configure()
	local widgets = self._layout.vars;
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.propertyScroll = widgets.scroll
end

function wnd_martialSoulProp:refresh(id)
	self:UpdateProperty();
end

function wnd_martialSoulProp:Sort(tbl)
	local _cmp = function(d1, d2)
		return d1.propID < d2.propID;
	end
	table.sort(tbl, _cmp);
end

function wnd_martialSoulProp:UpdateProperty()
	local property = g_i3k_game_context:GetWeaponSoulPropData()
	local sortProp = {}
	for k,v in pairs(property) do
		table.insert(sortProp, { propID = k, propValue = v });
	end
	self:Sort(sortProp);
	self.propertyScroll:removeAllChildren()
	for k, v in ipairs(sortProp) do
		local heroProperty = require(Proptipst)()
		local widget = heroProperty.vars
		local icon = g_i3k_db.i3k_db_get_property_icon(v.propID)
		widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		--widget.btn:onTouchEvent(self,self.showTips,v.propID)
		widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(v.propID))
		widget.propertyValue:setText(i3k_get_prop_show(v.propID, v.propValue))
		self.propertyScroll:addItem(heroProperty)	
	end
end

--[[function wnd_martialSoulProp:Confirm(sender)
	
end--]]

function wnd_create(layout)
	local wnd = wnd_martialSoulProp.new();
		wnd:create(layout);
	return wnd;
end