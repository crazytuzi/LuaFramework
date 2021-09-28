module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_baguaSacrifaceSplit = i3k_class("wnd_baguaSacrifaceSplit", ui.wnd_base)

function wnd_baguaSacrifaceSplit:ctor()
	self._maxCount = 0
	self._current_num = 0
	self._curID = 0
	self._gainCount = 0
	self._gainId = 0
end 

function wnd_baguaSacrifaceSplit:configure()
	local weight = self._layout.vars
	weight.imgBK:onClick(self, self.onCloseUI)
	weight.jia_btn:onClick(self, self.onAddBt)
	weight.jian_btn:onClick(self, self.onSubBt)
	weight.max_btn:onClick(self, self.onMaxBt)
	weight.cancel_btn:onClick(self, self.onCloseUI)
	weight.ok_btn:onClick(self, self.onOKBt)
end

function wnd_baguaSacrifaceSplit:refresh(id)
	local weight = self._layout.vars
	local gainId, gainCount = g_i3k_db.i3k_db_get_bagua_sacriface_gain_id_count(id)
	local flag = g_i3k_game_context:IsFemaleRole()
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	local weight = self._layout.vars
	self._curID = id
	self._gainCount = gainCount
	self._gainId = gainId
	weight.icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, flag))
	weight.bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	weight.suo1:setVisible(id > 0)
	weight.name1:setTextColor(g_i3k_get_color_by_rank(item_rank))
	weight.name1:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	weight.icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(gainId, flag))
	weight.bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(gainId))
	weight.suo2:setVisible(id > 0)
	item_rank = g_i3k_db.i3k_db_get_common_item_rank(gainId)
	weight.name2:setTextColor(g_i3k_get_color_by_rank(item_rank))
	weight.name2:setText(g_i3k_db.i3k_db_get_common_item_name(gainId))
	self._current_num = 1
	self._maxCount = g_i3k_game_context:GetCommonItemCount(id)
	self:refreshSplitText()
end

function wnd_baguaSacrifaceSplit:refreshSplitText()
	local weight = self._layout.vars
	weight.sale_count:setText(self._current_num)
	weight.count1:setText("x" .. self._current_num)
	weight.count2:setText("x" .. self._current_num * self._gainCount)
end

function wnd_baguaSacrifaceSplit:onAddBt()
	local curCount = self._current_num
	self._current_num = self._current_num + 1
	self._current_num = self._current_num > self._maxCount and self._maxCount or self._current_num
	
	if curCount ~= self._current_num then
		self:refreshSplitText()
	end
end

function wnd_baguaSacrifaceSplit:onSubBt()
	local curCount = self._current_num
	self._current_num = self._current_num - 1
	self._current_num = self._current_num < 1 and 1 or self._current_num
	
	if curCount ~= self._current_num then
		self:refreshSplitText()
	end
end

function wnd_baguaSacrifaceSplit:onMaxBt()
	if self._current_num ~= self._maxCount then
		self._current_num = self._maxCount
		self:refreshSplitText()
	end
end

function wnd_baguaSacrifaceSplit:onOKBt()
	local isEnough = g_i3k_game_context:IsBagEnough({[self._gainId] = self._current_num * self._gainCount})
	
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
		return

	end

	i3k_sbean.sacrifaceSplit({[self._curID] = self._current_num}, {{id = self._gainId, count = self._current_num * self._gainCount}})
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_baguaSacrifaceSplit.new();
	wnd:create(layout);
	return wnd;
end
