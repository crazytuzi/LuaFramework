-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_suicong_uplvl_tips= i3k_class("wnd_suicong_uplvl_tips",ui.wnd_base)

LAYER_SCSJTIPS = "ui/widgets/scsjt"
--等级图片
local LEVELICON = {109,110,111,112,113,114,115,116,117,118} 
--属性描述
local ShenBing_Property = {1001,1015,1016}
local Pet_Property = {1001,1002,1003,1004,1005,1006,1007}

function wnd_suicong_uplvl_tips:ctor()
end

function wnd_suicong_uplvl_tips:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.level1 = widgets.level1
	self.level2 = widgets.level2
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_suicong_uplvl_tips:refresh(upLvlType, data)
	self.scroll:removeAllChildren()	
	local oldData = data.oldData
	local newData = data.newData
	local level = data.lvl
	if level < 10 then
		level = level % 10
		self.level1:hide()
		self.level2:show()
		self.level2:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[level]))
	else
		self.level1:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/10)]))
		local tag = level%10 == 0 and 10 or level%10
		self.level2:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	end
	
	if upLvlType == g_ShengbingUpLevel then
		for i=1,3 do
			local _layer = require(LAYER_SCSJTIPS)()
			local widget = _layer.vars
			widget.attribute_name:setText(i3k_db_prop_id[ShenBing_Property[i]].desc)
			widget.old_value:setText(oldData[i])
			widget.new_value:setText(newData[i])
			self.scroll:addItem(_layer)
		end
	elseif upLvlType == g_SuiCongUpLevel then
		for i=1,7 do	
			local _layer = require(LAYER_SCSJTIPS)()
			local widget = _layer.vars
			widget.attribute_name:setText(i3k_db_prop_id[Pet_Property[i]].desc)
			widget.old_value:setText(oldData[i])
			widget.new_value:setText(newData[i])
			self.scroll:addItem(_layer)
		end
	end
end

--[[function wnd_suicong_uplvl_tips:closeButton(sender,eventType)
	g_i3k_ui_mgr:CloseUI(eUIID_PetWeaponUpLvl)
end--]]

function wnd_create(layout)
	local wnd = wnd_suicong_uplvl_tips.new()
		wnd:create(layout)
	return wnd
end
