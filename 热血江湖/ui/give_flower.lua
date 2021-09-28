-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/add_sub");

-------------------------------------------------------

wnd_give_flower = i3k_class("wnd_give_flower",ui.wnd_add_sub)

local flowerID = g_i3k_db.i3k_db_get_common_cfg().give_flower.flowerID

function wnd_give_flower:ctor()
	self.id = 0
	self.name = ""
end

function wnd_give_flower:configure()
	local widgets = self._layout.vars
	
	self.head_bg = widgets.head_bg
	self.item_icon = widgets.item_icon
	self.player_name = widgets.player_name
	self.item_desc = widgets.item_desc
	self.player_lvl = widgets.player_lvl
	self.give_count = widgets.give_count
	self.give_count:addEventListener(function(EventType)
		if EventType == "ended" then
			local str = tonumber(self.give_count:getText()) or 1
			if str > self.current_add_num then
				str = self.current_add_num
			end
			if str > g_edit_box_max then
				str = g_edit_box_max
			end
			if str < 1 then
				str = 1
			end
			self.current_num = str
			self.give_count:setText(self.current_num)
		end
	end)

	widgets.cancel:onClick(self, self.cancelBtn)
	widgets.ok:onClick(self, self.okBtn)
	
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	self.current_num = 1	--当前实际的数值 
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)
end

function wnd_give_flower:setSaleMoneyCount(count)
	self.give_count:setText(count)
end

function wnd_give_flower:updatefun()
	self._fun = function()
		if self.current_num > g_edit_box_max then
			self.current_num = g_edit_box_max
		end
		if self.current_num < 1 then
			self.current_num = 1
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_GiveFlower,"setSaleMoneyCount",self.current_num)
	end
end 

function wnd_give_flower:refresh(player)
	self.id = player.id
	self.name = player.name
	self.current_add_num = g_i3k_game_context:GetCommonItemCanUseCount(flowerID)
	self.item_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(player.iconId, true))
	self.player_name:setText(player.name)
	self.head_bg:setImage(g_i3k_get_head_bg_path(player.bwType, player.headBorder))
	self.player_lvl:setText(string.format("%s级", player.level))
	local desc = string.format("当前拥有玫瑰：%s", self.current_add_num)
	self.item_desc:setText(desc)
	if self.current_num > g_edit_box_max then
		self.current_num = g_edit_box_max
	end
	if self.current_num < 1 then
		self.current_num = 1
	end
	self.give_count:setText(self.current_num)
	self:updatefun()
end

function wnd_give_flower:okBtn(sender)
	i3k_sbean.give_flower(self.id, self.current_num, self.name)
	g_i3k_ui_mgr:CloseUI(eUIID_GiveFlower)
end

function wnd_give_flower:cancelBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GiveFlower)
end

function wnd_create(layout)
	local wnd = wnd_give_flower.new()
		wnd:create(layout)
	return wnd
end
