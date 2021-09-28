-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_unlock_hole = i3k_class("wnd_array_stone_unlock_hole", ui.wnd_base)

function wnd_array_stone_unlock_hole:ctor()
	self._isExUnlocked = false
	self._isEnoughLevel = false
	self._level = 0
	self._holePos = 0
	self._holeDbInfo = {}
end

function wnd_array_stone_unlock_hole:configure()
	self._layout.vars.close_btn2:onClick(self, self.onCloseUI)
	self._layout.vars.up_btn2:onClick(self, self.onUnlockBtn)
end

--刷新解孔界面
function wnd_array_stone_unlock_hole:refresh(holePos)
	self._holePos = holePos
	local info = g_i3k_game_context:getArrayStoneData()
	self._level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
	for k, v in ipairs(i3k_db_array_stone_unlock_hole) do
		if v.holePosition == holePos then
			self._holeDbInfo = v
			break
		end
	end
	self._isExUnlocked = info.holeCnt == holePos - 1
	self._layout.vars.powerCan:setVisible(info.holeCnt == holePos - 1)
	self._layout.vars.powerNo:setVisible(info.holeCnt ~= holePos - 1)
	self._layout.vars.wuxunCan:setVisible(self._level >= self._holeDbInfo.needLevel)
	self._layout.vars.wuxunNo:setVisible(self._level < self._holeDbInfo.needLevel)
	self._layout.vars.condition1:setText(i3k_get_string(18455))
	self._layout.vars.condition2:setText(i3k_get_string(18456))
	self:refreshItems()
end

function wnd_array_stone_unlock_hole:refreshItems()
	self._layout.vars.scroll:removeAllChildren()
	self._layout.vars.wuxunLabel:setText(self._level.."/"..self._holeDbInfo.needLevel)
	for k, v in ipairs(self._holeDbInfo.needItems) do
		if v.id ~= 0 then
			local node = require("ui/widgets/zfsdjt")()
			node.vars.itemBtn:onClick(self, self.showItemInfo, v.id)
			node.vars.itemCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id).."/"..v.count)
			node.vars.itemCount:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= v.count))
			node.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			self._layout.vars.scroll:addItem(node)
		end
	end
end

--解锁按钮
function wnd_array_stone_unlock_hole:onUnlockBtn(sender)
	if self._isExUnlocked and self._level >= self._holeDbInfo.needLevel  then
		for k, v in ipairs(self._holeDbInfo.needItems) do
			if v.id ~= 0 then
				if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
					return g_i3k_ui_mgr:PopupTipMessage("道具不足")
				end
			end
		end
		i3k_sbean.array_stone_unlock_hole(self._holePos, self._holeDbInfo.needItems)
	else
		g_i3k_ui_mgr:PopupTipMessage("未达到解锁条件")
	end
end

function wnd_array_stone_unlock_hole:showItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_array_stone_unlock_hole.new()
	wnd:create(layout)
	return wnd
end
