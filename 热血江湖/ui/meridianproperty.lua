-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_meridianProperty = i3k_class("wnd_meridianProperty",ui.wnd_base)
local Proptipst = "ui/widgets/jingmaitipst"
local Tipst = "ui/widgets/wuhuntipst2"
local Property = { ePropID_EquipLevel, ePropID_MeridianHPIncrease, ePropID_MeridianHPUpper, ePropID_ReviveArmorPercent};
function wnd_meridianProperty:ctor()

end

function wnd_meridianProperty:configure(...)
	local widgets = self._layout.vars
	self.propertyScroll = widgets.scroll;
	self.power			= widgets.power;
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_meridianProperty:Sort(tbl)
	local _cmp = function(d1, d2)
		return d1.propID < d2.propID;
	end
	table.sort(tbl, _cmp);
end

function wnd_meridianProperty:refresh()
	local hero = i3k_game_get_player_hero()
	local power = hero:AppraiseMeridian();
	if power then
		self.power:setText(power)
	end
	local property = g_i3k_game_context:getMeridianPotentialAttr()
	local sortProp = {}
	for k,v in pairs(property) do
		table.insert(sortProp, { propID = k, propValue = v });
	end
	self:Sort(sortProp);
	self.propertyScroll:removeAllChildren()
	for k, v in ipairs(sortProp) do
		local isShow = true;
		for i,e in ipairs(Property) do
			if v.propID == e then
				isShow = false;
				break;
			end
		end
		if isShow then
			local heroProperty = require(Proptipst)()
			local widget = heroProperty.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(v.propID)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.btn:onTouchEvent(self,self.showTips,v.propID)
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(v.propID))
			widget.propertyValue:setText(i3k_get_prop_show(v.propID, v.propValue))
			self.propertyScroll:addItem(heroProperty)
		end
	end
	for k, v in ipairs(sortProp) do
		local isShow = true;
		for i,e in ipairs(Property) do
			if v.propID == e then
				isShow = false;
				break;
			end
		end
		if not isShow then
			local property = require(Tipst)()
			local widget = property.vars;
			local value = i3k_get_prop_show(v.propID, v.propValue);
			if v.propID == ePropID_MeridianHPUpper then
				value = (i3k_get_prop_show(v.propID, v.propValue) / 10000).."万";
			end
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(v.propID).." :"..value)
			widget.propertyName:setTextColor(g_COLOR_VALUE_GREEN)
			self.propertyScroll:addItem(property)
		end
	end
	local cfg = i3k_db_meridians.potentia
	for k, v in pairs(g_i3k_game_context:getMeridianPotential()) do --ai触发类型显示
		if cfg[k][v].talentType == eMP_AiTriggerType then
			local node = require(Tipst)()
			node.vars.propertyName:setText(i3k_get_string(17243, cfg[k][v].name, v))
			node.vars.propertyName:setTextColor(g_COLOR_VALUE_GREEN)
			self.propertyScroll:addItem(node)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_meridianProperty.new()
	wnd:create(layout)
	return wnd
end
