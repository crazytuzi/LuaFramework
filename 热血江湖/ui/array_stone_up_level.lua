-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_up_level = i3k_class("wnd_array_stone_up_level", ui.wnd_base)

function wnd_array_stone_up_level:ctor()
	self._curLevel = 1
	self._co = nil
end

function wnd_array_stone_up_level:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.batchUse:onClick(self, self.onBatchUseItems)
	self._layout.vars.leftBtn:onClick(self, self.onLeftBtn)
	self._layout.vars.rightBtn:onClick(self, self.onRightBtn)
end

function wnd_array_stone_up_level:refresh()
	self._layout.vars.desc:setText(i3k_get_string(18424))
	self:updatePrayLevel()
	self:updateItemScroll()
end

function wnd_array_stone_up_level:updatePrayLevel()
	local info = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
	self._curLevel = level
	self._layout.vars.prayLevel:setText(i3k_get_string(18402, level))
	if level >= #i3k_db_array_stone_level then
		self._layout.vars.prayLoading:setPercent(100)
		self._layout.vars.prayPercent:hide()
		self._layout.vars.maxIcon:show()
	else
		self._layout.vars.prayPercent:show()
		self._layout.vars.maxIcon:hide()
		local needExp = 0
		local lastExp = 0
		if level > 1 then
			lastExp = i3k_db_array_stone_level[level - 1].needExp
			needExp = i3k_db_array_stone_level[level].needExp - i3k_db_array_stone_level[level - 1].needExp
		else
			lastExp = 0
			needExp = i3k_db_array_stone_level[1].needExp
		end
		self._layout.vars.prayLoading:setPercent((info.exp - lastExp) / needExp * 100)
		self._layout.vars.prayPercent:setText((info.exp - lastExp) .. "/" .. needExp)
	end
	self:updatePrayAddition()
end

function wnd_array_stone_up_level:updateItemScroll()
	self._layout.vars.scroll:removeAllChildren()
	for k, v in ipairs(i3k_db_array_stone_common.itemId) do
		local node = require("ui/widgets/zfszyt2")()
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(v)
		node.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v, g_i3k_game_context:IsFemaleRole()))
		node.vars.itemLock:setVisible(false)
		node.vars.noneIcon:setVisible(g_i3k_game_context:GetCommonItemCanUseCount(v) <= 0)
		node.vars.energy:setText(cfg.args1)
		node.vars.itemCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(v))
		node.vars.itemBtn:onTouchEvent(self, self.onUseItemBtn, v)
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_array_stone_up_level:onUseItemBtn(sender, eventType, id)
	if eventType == ccui.TouchEventType.began then
		if g_i3k_game_context:GetCommonItemCanUseCount(id) <= 0 then
			g_i3k_ui_mgr:ShowCommonItemInfo(id)
		else
			local info = g_i3k_game_context:getArrayStoneData()
			local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
			if level >= #i3k_db_array_stone_level then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18425))
			else
				i3k_sbean.array_stone_mantra_uplvl({[id] = 1})
				self._co = g_i3k_coroutine_mgr:StartCoroutine(function()
					while true do
						g_i3k_coroutine_mgr.WaitForSeconds(0.3)
						if g_i3k_game_context:GetCommonItemCanUseCount(id) <= 0 then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18426))
							return false
						end
						local info = g_i3k_game_context:getArrayStoneData()
						local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
						if level >= #i3k_db_array_stone_level then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18425))
							return false
						end
						i3k_sbean.array_stone_mantra_uplvl({[id] = 1})
					end
				end)
			end
		end
	elseif eventType == ccui.TouchEventType.ended then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
	elseif eventType == ccui.TouchEventType.canceled then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
	end
end

function wnd_array_stone_up_level:onBatchUseItems(sender)
	local info = g_i3k_game_context:getArrayStoneData()
	if info.exp >= i3k_db_array_stone_level[#i3k_db_array_stone_level - 1].needExp then return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18427)) end
	local items = {}
	for i,v in ipairs(i3k_db_array_stone_common.itemId) do
		local have = g_i3k_game_context:GetCommonItemCanUseCount(v)
		if have > 0 then table.insert(items, {id = v, count = have, energy = i3k_db_new_item[v].args1}) end
	end
	if #items == 0 then return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18428)) end
	local result = g_i3k_db.i3k_db_get_array_stone_one_key_use_items(info.exp, items)
	i3k_sbean.array_stone_mantra_uplvl(result)
end

function wnd_array_stone_up_level:updatePrayAddition()
	self._layout.vars.level:setText(i3k_get_string(18402, self._curLevel))
	self._layout.vars.equipCountText:setText(i3k_get_string(18429))
	self._layout.vars.equipCount:setText(i3k_db_array_stone_level[self._curLevel].equipStoneCount)
	self._layout.vars.propAddText:setText(i3k_get_string(18430))
	self._layout.vars.propAdd:setText(i3k_db_array_stone_level[self._curLevel].propertyRate / 100 .. "%")
	self._layout.vars.energyText:setText(i3k_get_string(18479))
	self._layout.vars.energyText:setVisible(self._curLevel >= i3k_db_array_stone_common.transformLvl)
	self._layout.vars.page:setText(i3k_db_array_stone_level[self._curLevel].pageText)
	local unlockCount = i3k_clone(i3k_db_array_stone_common.holeCount)
	for k, v in ipairs(i3k_db_array_stone_unlock_hole) do
		if self._curLevel < v.needLevel then
			break
		else
			unlockCount = v.holePosition
		end
	end
	self._layout.vars.holeCount:setText(i3k_get_string(18431, unlockCount))
	self._layout.vars.rateTitle:setText(i3k_get_string(18432))
	for k = 1, 10 do
		if i3k_db_array_stone_level[self._curLevel].dropRate[k] then
			self._layout.vars["stone"..k]:setText(i3k_db_array_stone_common.prefixSelect[k])
			self._layout.vars["rate"..k]:setText(string.format("%.2f%%", i3k_db_array_stone_level[self._curLevel].dropRate[k] / 100))
		else
			self._layout.vars["stone"..k]:hide()
			self._layout.vars["rate"..k]:hide()
		end
	end
end

function wnd_array_stone_up_level:onLeftBtn(sender)
	if self._curLevel > 1 then
		self._curLevel = self._curLevel - 1
		self:updatePrayAddition()
	end
end

function wnd_array_stone_up_level:onRightBtn(sender)
	if self._curLevel < #i3k_db_array_stone_level then
		self._curLevel = self._curLevel + 1
		self:updatePrayAddition()
	end
end

--使用成功之后刷新
function wnd_array_stone_up_level:updateUseItemScroll()
	local children = self._layout.vars.scroll:getAllChildren()
	for k, v in ipairs(i3k_db_array_stone_common.itemId) do
		local node = children[k]
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(v)
		node.vars.noneIcon:setVisible(g_i3k_game_context:GetCommonItemCanUseCount(v) <= 0)
		node.vars.itemCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(v))
		--node.vars.itemBtn:onTouchEvent(self, self.onUseItemBtn, v)
	end
end

function wnd_array_stone_up_level:onHide()
	if self._co then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
	end
end

function wnd_create(layout)
	local wnd = wnd_array_stone_up_level.new()
	wnd:create(layout)
	return wnd
end
