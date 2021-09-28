-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedFightProp = i3k_class("wnd_steedFightProp", ui.wnd_base)
local Proptipst = "ui/widgets/qztipst"
function wnd_steedFightProp:ctor()

end

function wnd_steedFightProp:configure()
	local widgets 		= self._layout.vars;
	self.scroll 		= widgets.scroll
	self.power			= widgets.power
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_steedFightProp:refresh(property)
	self:updateScroll(property);
end

function wnd_steedFightProp:Sort(tbl)
	local _cmp = function(d1, d2)
		return d1.propID < d2.propID;
	end
	table.sort(tbl, _cmp);
end

function wnd_steedFightProp:updateScroll(property)
	self.power:setText(g_i3k_db.i3k_db_get_battle_power(property,true));
	local sortProp = {}
	for k,v in pairs(property) do
		table.insert(sortProp, { propID = k, propValue = v });
	end
	self:Sort(sortProp);
	self.scroll:removeAllChildren()
	for k, v in ipairs(sortProp) do
		local heroProperty = require(Proptipst)()
		local widget = heroProperty.vars
		local icon = g_i3k_db.i3k_db_get_property_icon(v.propID)
		widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		widget.btn:onTouchEvent(self,self.showTips,v.propID)
		widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(v.propID))
		widget.propertyValue:setText(i3k_get_prop_show(v.propID, v.propValue))
		self.scroll:addItem(heroProperty)	
	end
end

function wnd_create(layout)
	local wnd = wnd_steedFightProp.new();
		wnd:create(layout);
	return wnd;
end