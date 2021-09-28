-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_batch_recycle = i3k_class("wnd_array_stone_batch_recycle", ui.wnd_base)

function wnd_array_stone_batch_recycle:ctor()
	self._chooseAllLock = false
	self._chooseStones = {}
end

function wnd_array_stone_batch_recycle:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.chooseLockBtn:onClick(self, self.onOpenChooseLock)
	self._layout.vars.allUnlockBtn:onClick(self, self.onChooseAllUnlock)
	self._layout.vars.chooseAllBtn:onClick(self, self.onChooseAllBtn)
	self._layout.vars.batchRecycle:onClick(self, self.onBatchRecycle)
end

function wnd_array_stone_batch_recycle:refresh()
	self._chooseAllLock = false
	self._chooseStones = {}
	self:updateChooseScroll()
	self._layout.vars.recycleScroll:removeAllChildren()
	self._layout.vars.energyCount:setText(0)
	self._layout.vars.allUnlockIcon:setVisible(self._chooseAllLock)
	self._layout.vars.energyIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_STONE_ENERGY, g_i3k_game_context:IsFemaleRole()))
	self._layout.vars.energyLock:setVisible(false)
end

function wnd_array_stone_batch_recycle:updateChooseScroll()
	local info = g_i3k_game_context:getArrayStoneData()
	self._layout.vars.chooseScroll:removeAllChildren()
	for k, v in pairs(info.bag) do
		if i3k_db_array_stone_cfg[k].level == 1 then
			local node = require("ui/widgets/zfssdt")()
			node.id = k
			node.count = v
			node.vars.selectBtn:onClick(self, self.onSelectStone, {node = node, id = k})
			--node.vars.itemBtn:onClick(self, self.onItemInfo, k)
			node.vars.itemBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_array_stone_cfg[k].rank, false))
			node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[k].stoneIcon))
			node.vars.itemLock:setVisible(false)
			node.vars.itemName:setText(i3k_db_array_stone_cfg[k].name .. "x" .. v)
			node.vars.itemName:setTextColor(g_i3k_get_color_by_rank(i3k_db_array_stone_cfg[k].rank))
			node.vars.energyCount:setText(i3k_db_array_stone_cfg[k].recycleEnergy * v)
			node.vars.energyIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_STONE_ENERGY, g_i3k_game_context:IsFemaleRole()))
			node.vars.energyLock:setVisible(false)
			node.vars.selectIcon:setVisible(self._chooseStones[k])
			self._layout.vars.chooseScroll:addItem(node)
		end
	end
end

function wnd_array_stone_batch_recycle:onSelectStone(sender, cfg)
	if self._chooseStones[cfg.id] then
		cfg.node.vars.selectIcon:setVisible(false)
		self._chooseStones[cfg.id] = nil
	else
		cfg.node.vars.selectIcon:setVisible(true)
		local info = g_i3k_game_context:getArrayStoneData()
		self._chooseStones[cfg.id] = info.bag[cfg.id]
	end
	self:updateRecycleScroll()
end

function wnd_array_stone_batch_recycle:updateRecycleScroll()
	self._layout.vars.recycleScroll:removeAllChildren()
	local recycle = {}
	for k, v in pairs(self._chooseStones) do
		table.insert(recycle, {id = k, count = v})
	end
	local children = self._layout.vars.recycleScroll:addItemAndChild("ui/widgets/zfssdt1", 5, #recycle)
	local allEnergy = 0
	for k, v in ipairs(children) do
		--v.vars.stoneBtn:onClick(self, self.onStoneBtn, v.id)
		v.vars.stoneBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_array_stone_cfg[recycle[k].id].rank, false))
		v.vars.stoneIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[recycle[k].id].stoneIcon))
		v.vars.stoneLock:setVisible(false)
		v.vars.stoneCount:setText("x"..recycle[k].count)
		allEnergy = allEnergy + recycle[k].count * i3k_db_array_stone_cfg[recycle[k].id].recycleEnergy
	end
	self._layout.vars.energyCount:setText(allEnergy)
end
--[[
function wnd_array_stone_batch_recycle:onStoneBtn(sender, id)
	
end
--]]
function wnd_array_stone_batch_recycle:onChooseAllUnlock(sender)
	self._chooseAllLock = not self._chooseAllLock
	if self._chooseAllLock then
		local info = g_i3k_game_context:getArrayStoneData()
		local children = self._layout.vars.chooseScroll:getAllChildren()
		for k, v in ipairs(children) do
			if info.locks[v.id] then
				self._chooseStones[v.id] = nil
				v.vars.selectIcon:setVisible(false)
			else
				self._chooseStones[v.id] = v.count
				v.vars.selectIcon:setVisible(true)
			end
		end
		self:updateRecycleScroll()
	else
		self._chooseStones = {}
		local children = self._layout.vars.chooseScroll:getAllChildren()
		for k, v in ipairs(children) do
			v.vars.selectIcon:setVisible(false)
		end
		self:updateRecycleScroll()
	end
	self._layout.vars.allUnlockIcon:setVisible(self._chooseAllLock)
end

function wnd_array_stone_batch_recycle:onChooseAllBtn(sender)
	local children = self._layout.vars.chooseScroll:getAllChildren()
	local isAllSel = true
	for k,v in ipairs(children) do
		if not v.vars.selectIcon:isVisible() then
			isAllSel = false
			break
		end
	end
	for k, v in ipairs(children) do
		v.vars.selectIcon:setVisible(not isAllSel)
	end
	local info = g_i3k_game_context:getArrayStoneData()
	for k, v in pairs(info.bag) do
		if i3k_db_array_stone_cfg[k].level == 1 then
			self._chooseStones[k] = not isAllSel and v or nil
		end
	end
	self._chooseAllLock = false
	self._layout.vars.allUnlockIcon:setVisible(self._chooseAllLock)
	self:updateRecycleScroll()
end

function wnd_array_stone_batch_recycle:onBatchRecycle(sender)
	if next(self._chooseStones) then
		local stones = i3k_clone(self._chooseStones)
		i3k_sbean.array_stone_ciphertext_destroy(stones)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18423))
	end
end

function wnd_array_stone_batch_recycle:onOpenChooseLock(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneLock)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneLock)
end

--[[function wnd_array_stone_batch_recycle:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end--]]

function wnd_create(layout)
	local wnd = wnd_array_stone_batch_recycle.new()
	wnd:create(layout)
	return wnd
end