-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_property_tips = i3k_class("wnd_shen_bing_property_tips", ui.wnd_base)

function wnd_shen_bing_property_tips:ctor()
end

function wnd_shen_bing_property_tips:configure()
	local widget = self._layout.vars
	
	self.grade_pro = widget.grade_pro
	self.atk_pro = widget.atk_pro
	self.def_pro = widget.def_pro
	self.hp_pro = widget.hp_pro
	self.crit_tou = widget.crit_tou
	self.bgRoot = widget.bgRoot
	
	self.grade_num = widget.grade_num
	self.atk_num = widget.atk_num
	self.def_num = widget.def_num
	self.hp_num = widget.hp_num
	self.crit_num = widget.crit_num
	
	self.grade_image = widget.grade_image
	self.atk_image = widget.atk_image
	self.def_image = widget.def_image
	self.hp_image = widget.hp_image
	self.crit_image = widget.crit_image
end
function wnd_shen_bing_property_tips:refresh(data)
	local widget = self._layout.vars
	
	self.grade_num:setText(data.grade)
	self.atk_num:setText(data.attack)
	self.def_num:setText(data.defense)
	self.hp_num:setText(data.hp)
	
	widget.grade_image:setImage(g_i3k_db.i3k_db_get_icon_path(1023))
	self.atk_image:setImage(g_i3k_db.i3k_db_get_icon_path(1021))
	self.def_image:setImage(g_i3k_db.i3k_db_get_icon_path(1022))
	self.hp_image:setImage(g_i3k_db.i3k_db_get_icon_path(144))
	
	if data.tou == 0 then
		self.crit_num:setText(data.crit)
		self.crit_tou:setText("暴击")
		self.crit_image:setImage(g_i3k_db.i3k_db_get_icon_path(149))
	elseif data.crit == 0 then
		self.crit_tou:setText("韧性")
		self.crit_num:setText(data.tou)
		self.crit_image:setImage(g_i3k_db.i3k_db_get_icon_path(150))
	end
	
end

function wnd_create(layout)
	local wnd = wnd_shen_bing_property_tips.new()
		wnd:create(layout)
	return wnd
end

