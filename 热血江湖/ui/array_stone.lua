-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone = i3k_class("wnd_array_stone", ui.wnd_base)


function wnd_array_stone:ctor()
	self._freeTimes = 0
	self._isTransform = false
	self._countTime = 1
	self._selectState = 0
	self._selectIndex = {#i3k_db_array_stone_common.prefixSelect, #i3k_db_array_stone_common.suffixSelect}
	self._newStones = {}
	self._oldStones = {}
	self._showUI = 0
	self._lastStones = {}
	self._lastRecycle = false
	self._playPray = false
	self._prayCount = 0
	self._curUnlockId = 0
	self._amuletId = 0
	self._animateCo = nil
end

function wnd_array_stone:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.prayBtn:onClick(self, self.onPrayBtn)
	self._layout.vars.amuletBtn:onClick(self, self.onAmuletBtn)
	self._layout.vars.prayOnceBtn:onClick(self, self.onPrayOnce)
	self._layout.vars.stoneSuitBtn:onClick(self, self.onStoneSuit)
	self._layout.vars.transformBtn:onClick(self, self.onAutoTransform)
	self._layout.vars.archiveBtn:onClick(self, self.onArchiveBtn)
	self._layout.vars.addExpBtn:onClick(self, self.onAddPrayExpBtn)
	self._layout.vars.recycleBtn:onClick(self, self.onBatchRecycleBtn)
	self._layout.vars.propertyBtn:onClick(self, self.onAmuletProperty)
	for k = 1, g_ARRAY_STONE_PRAY_HOLE do
		self._layout.vars["prayPoint"..k]:onClick(self, self.onUnlockNode, k)
	end
	for k = 1, g_ARRAY_STONE_MAX_EQUIP do
		self._layout.vars["amuletBtn"..k]:onClick(self, self.showStoneInfo, {id = 0, inBag = 2, position = k})
	end
	self._select = 
	{
		i3k_db_array_stone_common.prefixSelect,
		i3k_db_array_stone_common.suffixSelect,
	}
	for k = 1, #self._select do
		self._layout.vars["selectBtn"..k]:onClick(self, self.onSelectBtn, k)
	end
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
	local textColor = { -- 页签文本颜色 选择和为被选中状态
		{"ffcf571c", "ffffd27c"}, -- 主色和描边
		{"ffffc898", "ffa06448"}
	}
	self._layout.vars.prayBtn:setTitleTextColor(textColor)
	self._layout.vars.amuletBtn:setTitleTextColor(textColor)
end

function wnd_array_stone:refresh()
	self._layout.anis.c_ry1.play()
	local info = g_i3k_game_context:getArrayStoneData()
	self._freeTimes = info.freeTimes
	if self._freeTimes == 0 then
		self._layout.vars.countdown:setText(i3k_get_string(18401))
	end
	self._isTransform = info.conversion
	self._oldStones = i3k_clone(info.bag)
	for k = 1, 2 do
		self._layout.vars["selectText"..k]:setText(self._select[k][#self._select[k]])
	end
	--self:setArrayStonePrayPercent()
	self:updatePrayLevel()
	self:updateStoneBag()
	self:onPrayBtn()
	self:updatePrayRedPoint()
end

function wnd_array_stone:updatePrayLevel()
	local info = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
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
	self._layout.vars.transformNode:setVisible(level >= i3k_db_array_stone_common.transformLvl)
end

--背包刷新
function wnd_array_stone:updateStoneBag()
	local stoneBag = self:sortStones()
	self._layout.vars.stoneScroll:removeAllChildren()
	local children = self._layout.vars.stoneScroll:addItemAndChild("ui/widgets/zfsmwt", 4, #stoneBag)
	local position = self:getEquipStonPosition()
	local showRecycle = false
	for k, v in ipairs(stoneBag) do
		local node = children[k]
		node.vars.stoneBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_array_stone_cfg[v.id].rank, false))
		node.vars.stoneIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[v.id].stoneIcon))
		node.vars.stoneCount:setText("x"..v.count)
		node.vars.newIcon:setVisible(v.isNew == 1)
		node.vars.level:setText(i3k_get_string(18403, i3k_db_array_stone_cfg[v.id].level))
		node.vars.stoneBtn:onClick(self, self.showStoneInfo, {id = v.id, inBag = 1, position = position})
		if i3k_db_array_stone_cfg[v.id].level == 1 then
			showRecycle = true
		end
	end
	self._layout.vars.recycleBtn:setVisible(showRecycle)
	if next(stoneBag) then
		self._layout.vars.emptyBagTips:hide()
	else
		self._layout.vars.emptyBagTips:show()
		if self._selectIndex[1] == #i3k_db_array_stone_common.prefixSelect and self._selectIndex[2] == #i3k_db_array_stone_common.suffixSelect then
			self._layout.vars.emptyBagTips:setText(i3k_get_string(18448))
		else
			self._layout.vars.emptyBagTips:setText(i3k_get_string(18449))
		end
	end
end

function wnd_array_stone:sortStones()
	local stones = {}
	for k, v in pairs(self._newStones) do
		if self:selectIsAdd(k) then
			table.insert(stones, {id = k, count = v, isNew = 1, level = i3k_db_array_stone_cfg[k].level})
		end
	end
	for k, v in pairs(self._oldStones) do
		if self:selectIsAdd(k) then
			table.insert(stones, {id = k, count = v, isNew = 0, level = i3k_db_array_stone_cfg[k].level})
		end
	end
	table.sort(stones, function(a, b)
		if a.isNew == b.isNew then
			if a.level == b.level then
				return a.id < b.id
			else
				return a.level > b.level
			end
		else
			return a.isNew > b.isNew
		end
	end)
	return stones
end

function wnd_array_stone:selectIsAdd(id)
	local isAdd = true
	if self._selectIndex[1] ~= #i3k_db_array_stone_common.prefixSelect then
		if i3k_db_array_stone_cfg[id].prefixId ~= self._selectIndex[1] then
			isAdd = false
		end
	end
	if self._selectIndex[2] ~= #i3k_db_array_stone_common.suffixSelect then
		if i3k_db_array_stone_cfg[id].suffixId ~= self._selectIndex[2] then
			isAdd = false
		end
	end
	return isAdd
end

function wnd_array_stone:showStoneInfo(sender, stoneInfo)
	if stoneInfo.inBag == 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWInfo, stoneInfo.id, stoneInfo.inBag, stoneInfo.position)
	else
		local info = g_i3k_game_context:getArrayStoneData()
		local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
		if info.equips[stoneInfo.position] and info.equips[stoneInfo.position] ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWInfo)
			g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWInfo, info.equips[stoneInfo.position], stoneInfo.inBag, stoneInfo.position)
		elseif stoneInfo.position > i3k_db_array_stone_level[level].equipStoneCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18457))
		end
	end
end

--筛选
function wnd_array_stone:onSelectBtn(sender, id)
	if self._selectState == id then
		self._layout.vars["selectRoot"..id]:hide()
		self._selectState = 0
	elseif self._selectState == 0 then
		self._layout.vars["selectRoot"..id]:show()
		self:updateSelectScroll(id)
	else
		self._layout.vars.selectRoot1:hide()
		self._layout.vars.selectRoot2:hide()
		self._layout.vars["selectRoot"..id]:show()
		self:updateSelectScroll(id)
	end
end

function wnd_array_stone:updateSelectScroll(id)
	self._selectState = id
	self._layout.vars["selectScroll"..id]:removeAllChildren()
	for k, v in ipairs(self._select[id]) do
		local node = require("ui/widgets/zfssxt")()
		node.vars.selectBtn:onClick(self, self.onChangeSelect, k)
		node.vars.name:setText(v)
		self._layout.vars["selectScroll"..id]:addItem(node)
	end
end

function wnd_array_stone:onChangeSelect(sender, index)
	self._selectIndex[self._selectState] = index
	self._layout.vars["selectText"..self._selectState]:setText(self._select[self._selectState][index])
	self._layout.vars["selectRoot"..self._selectState]:hide()
	self._selectState = 0
	self:updateStoneBag()
end
--筛选end

--祈言
function wnd_array_stone:onPrayBtn(sender)
	if self._showUI ~= 1 then
		self._showUI = 1
		self:setArrayStonePrayPercent()
		self._layout.anis.c_jiesuo.stop()
		self._layout.vars.prayNode:show()
		self._layout.vars.amuletNode:hide()
		self._layout.vars.prayBtn:stateToPressed(true)
		self._layout.vars.amuletBtn:stateToNormal(true)
		self._layout.vars.archiveBtn:show()
		self._layout.vars.prayDesc:setText(i3k_get_string(18404))
		self:updatePrayRootData()
		self:updatePrayNode()
	end
end

function wnd_array_stone:updatePrayRootData()
	if self._showUI == 1 then
		local info = g_i3k_game_context:getArrayStoneData()
		local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
		for k = 1, 2 do
			if i3k_db_array_stone_level[level].costItems[k] then
				local id = i3k_db_array_stone_level[level].costItems[k].id
				local count = i3k_db_array_stone_level[level].costItems[k].count
				self._layout.vars["itemIcon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
				self._layout.vars["itemCount"..k]:setText(g_i3k_game_context:GetCommonItemCanUseCount(id) .. "/" .. count)
				if self._freeTimes == 0 then
					self._layout.vars["itemCount"..k]:setText(g_i3k_game_context:GetCommonItemCanUseCount(id) .. "/0")
					self._layout.vars["itemCount"..k]:setTextColor(g_COLOR_VALUE_GREEN)
				else
					self._layout.vars["itemCount"..k]:setText(g_i3k_game_context:GetCommonItemCanUseCount(id) .. "/" .. count)
					self._layout.vars["itemCount"..k]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(id) >= count))
				end
				self._layout.vars["itemBtn"..k]:onClick(self, self.showItemInfo, id)
			else
				--self._layout.vars["gradeIcon"..k]:hide()
			end
		end
		self._layout.vars.transformIcon:setVisible(info.conversion)
	end
end

function wnd_array_stone:updatePrayNode()
	local info = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
	for k = 1, g_ARRAY_STONE_PRAY_HOLE do
		self._layout.vars["prayLock"..k]:setVisible(k > info.holeCnt)
		self._layout.vars["prayAni"..k]:setVisible(k <= info.holeCnt)
		if self._lastRecycle then
			if self._lastStones[k] then
				self._layout.vars["prayIcon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_STONE_ENERGY, g_i3k_game_context:IsFemaleRole()))
				self._layout.vars["prayEnergy"..k]:setText(i3k_db_array_stone_cfg[self._lastStones[k]].recycleEnergy)
				self._layout.vars["prayEnergyBg"..k]:show()
			else
				self._layout.vars["prayEnergyBg"..k]:hide()
			end
		else
			self._layout.vars["prayEnergyBg"..k]:hide()
			if self._lastStones[k] then
				self._layout.vars["prayIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[self._lastStones[k]].stoneIcon))
			end
		end
	end
	for k, v in ipairs(i3k_db_array_stone_unlock_hole) do
		if v.holePosition == info.holeCnt + 1 and level >= v.needLevel then
			self._layout.vars["prayRed"..v.holePosition]:show()
		else
			self._layout.vars["prayRed"..v.holePosition]:hide()
		end
	end
end

function wnd_array_stone:updatePraySuccessAnimate()
	local info = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
	for k = 1, #self._lastStones do
		self._layout.vars["prayEnergyBg"..k]:hide()
		self._layout.vars["prayIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(2396))--空图片
	end
	for k, v in ipairs(i3k_db_array_stone_unlock_hole) do
		if v.holePosition == info.holeCnt + 1 and level >= v.needLevel then
			self._layout.vars["prayRed"..v.holePosition]:show()
		else
			self._layout.vars["prayRed"..v.holePosition]:hide()
		end
	end
	g_i3k_coroutine_mgr:StopCoroutine(self._animateCo)
	self._animateCo = g_i3k_coroutine_mgr:StartCoroutine(function()
		for k = 1, #self._lastStones do
			self._layout.anis.c_fydjtx.stop()
			local pos = self._layout.vars["prayBg"..k]:getParent():convertToWorldSpace(self._layout.vars["prayBg"..k]:getPosition())
			local parent = self._layout.vars.equipAni:getParent()
			self._layout.vars.equipAni:setPosition(parent:convertToNodeSpace(cc.p(pos.x, pos.y)))
			self._layout.anis.c_fydjtx.play()
			if self._lastRecycle then
				if self._lastStones[k] then
					self._layout.vars["prayIcon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_STONE_ENERGY, g_i3k_game_context:IsFemaleRole()))
					self._layout.vars["prayEnergy"..k]:setText(i3k_db_array_stone_cfg[self._lastStones[k]].recycleEnergy)
					self._layout.vars["prayEnergyBg"..k]:show()
				else
					self._layout.vars["prayEnergyBg"..k]:hide()
				end
			else
				self._layout.vars["prayEnergyBg"..k]:hide()
				if self._lastStones[k] then
					self._layout.vars["prayIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[self._lastStones[k]].stoneIcon))
				end
			end
			g_i3k_coroutine_mgr.WaitForSeconds(0.3)
		end
		g_i3k_coroutine_mgr:StopCoroutine(self._animateCo)
	end)
end

function wnd_array_stone:onPrayOnce(sender)
	local info = g_i3k_game_context:getArrayStoneData()
	if self._freeTimes >= 1 then
		local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
		local costItems = i3k_db_array_stone_level[level].costItems
		for k, v in ipairs(costItems) do
			if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18405))
			end
		end
		i3k_sbean.array_stone_prayer(self._freeTimes, costItems)
	else
		i3k_sbean.array_stone_prayer(self._freeTimes)
	end
end

function wnd_array_stone:updateStonePray(stones)
	self._lastStones = stones
	self._lastRecycle = self._isTransform
	for k, v in pairs(self._newStones) do
		if not self._oldStones[k] then
			self._oldStones[k] = 0
		end
		self._oldStones[k] = self._oldStones[k] + v
	end
	self._newStones = {}
	--目前免费次数只有一次
	if self._freeTimes == 0 then
		self._freeTimes = 1
	end
	if self._isTransform then
		
	else
		for k, v in ipairs(stones) do
			if not self._oldStones[v] then
				if not self._newStones[v] then
					self._newStones[v] = 0
				end
				self._newStones[v] = self._newStones[v] + 1
			else
				self._oldStones[v] = self._oldStones[v] + 1
			end
		end
		self:updateStoneBag()
	end
	if self._showUI == 1 then
		self:updatePrayRootData()
		self:updatePraySuccessAnimate()
	end
	self:updatePrayLevel()
end

--置换之后 --合成之后 回收 --不会覆盖原来的新的 会产生新的
function wnd_array_stone:updateStonesUncover(adds, subs)
	if adds then
		for i,v in ipairs(adds) do
			if not self._oldStones[v.id] or self._oldStones[v.id] == 0 then--旧的没有
				if not self._newStones[v.id] then
					self._newStones[v.id] = v.count 
				else
					self._newStones[v.id] = self._newStones[v.id] + v.count
				end
			else
				self._oldStones[v.id] = self._oldStones[v.id] + v.count
			end
		end
	end
	if subs then
		for i,v in ipairs(subs) do
			if v.count ~= 0 then
				if self._newStones[v.id] and self._newStones[v.id] ~= 0 then
					self._newStones[v.id] = self._newStones[v.id] - v.count
					subs[i].count = 0
					if self._newStones[v.id] == 0 then
						self._newStones[v.id] = nil
					end
				end
			end
		end
		for i,v in ipairs(subs) do
			if v.count ~= 0 then
				if self._oldStones[v.id] and self._oldStones[v.id] ~= 0 then
					self._oldStones[v.id] = self._oldStones[v.id] - v.count
					if self._oldStones[v.id] == 0 then
						self._oldStones[v.id] = nil
					end
					subs[i].count = 0
				end
			end
		end
	end
	self:updateStoneBag()
end
--下阵之后 不会产生新的
function wnd_array_stone:updateStonesAfterUnEquip(adds, subs)
	if adds then
		for i,v in ipairs(adds) do
			if not self._oldStones[v.id] or self._oldStones[v.id] == 0 then--旧的没有
				if not self._newStones[v.id] or self._oldStones[v.id] == 0 then --新的也没有
					self._oldStones[v.id] = v.count
				else
					self._newStones[v.id] = self._newStones[v.id] + v.count
				end
			else
				self._oldStones[v.id] = self._oldStones[v.id] + v.count
			end
		end
	end
	if subs then
		for i,v in ipairs(subs) do
			if self._oldStones[v.id] then
				self._oldStones[v.id] = self._oldStones[v.id] - v.count
				self._oldStones[v.id] = self._oldStones[v.id] ~= 0 and self._oldStones[v.id] or nil
				v.count = 0
			end
		end
		for i,v in ipairs(subs) do
			if self._newStones[v.id] then
				self._newStones[v.id] = self._newStones[v.id] - v.count
				self._newStones[v.id] = self._newStones[v.id] ~= 0 and self._newStones[v.id] or nil
			end
		end
	end
	self:updateStoneBag()
end

--符印
function wnd_array_stone:onAmuletBtn(sender)
	if self._showUI ~= 2 then
		g_i3k_coroutine_mgr:StopCoroutine(self._animateCo)
		self._layout.anis.c_fydjtx.stop()
		self._showUI = 2
		self._playPray = false
		self._prayCount = 0
		self._layout.anis.c_jiesuo.stop()
		if self._amuletId ~= 0 then
			self:playUnlockAmuletAni()
		end
		self._layout.vars.prayNode:hide()
		self._layout.vars.amuletNode:show()
		self._layout.vars.prayBtn:stateToNormal(true)
		self._layout.vars.amuletBtn:stateToPressed(true)
		self._layout.vars.archiveBtn:hide()
		self._layout.vars.amuletDesc:setText(i3k_get_string(18406))
		self:updateAmuletRootData()
	end
end

function wnd_array_stone:updateAmuletRootData()
	if self._showUI == 2 then
		local info = g_i3k_game_context:getArrayStoneData()
		local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
		local equipCount = i3k_db_array_stone_level[level].equipStoneCount
		local haveEquip = 0
		for k = 1, g_ARRAY_STONE_MAX_EQUIP do
			self._layout.vars["amuletLock"..k]:hide()
			self._layout.vars["stoneLevelBg"..k]:hide()
			if info.equips[k] and info.equips[k] ~= 0 then
				--self._layout.vars["amuletBg"..k]:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_array_stone_cfg[info.equips[k]].rank, false))
				self._layout.vars["amuletIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[info.equips[k]].stoneIcon))
				self._layout.vars["stoneLevelBg"..k]:show()
				self._layout.vars["stoneLevel"..k]:setText(i3k_get_string(18403, i3k_db_array_stone_cfg[info.equips[k]].level))
				haveEquip = haveEquip + 1
			elseif k <= equipCount then
				--self._layout.vars["amuletBg"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(2396))
				self._layout.vars["amuletIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(2396))
			else
				self._layout.vars["amuletLock"..k]:show()
			end
		end
		self._layout.vars.equipCount:setText(i3k_get_string(18407, haveEquip, equipCount))
	end
end

function wnd_array_stone:getEquipStonPosition()
	local info = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
	local equipCount = i3k_db_array_stone_level[level].equipStoneCount
	for k = 1, equipCount do
		if info.equips[k] and info.equips[k] ~= 0 then
			
		else
			return k
		end
	end
	return 0
end


function wnd_array_stone:onAutoTransform(sender)
	local info = g_i3k_game_context:getArrayStoneData()
	i3k_sbean.array_stone_set_conversion(info.conversion and 0 or 1)
end

function wnd_array_stone:changeTransformIcon(state)
	self._layout.vars.transformIcon:setVisible(state)
	self._isTransform = state
end

function wnd_array_stone:onUnlockNode(sender, id)
	local info = g_i3k_game_context:getArrayStoneData()
	if id > info.holeCnt then
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneUnlockHole)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneUnlockHole, id)
	end
end

function wnd_array_stone:onArchiveBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneArchive)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneArchive)
end

function wnd_array_stone:onStoneSuit(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneSuit)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneSuit)
end

function wnd_array_stone:onAddPrayExpBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneUpLevel)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneUpLevel)
end

function wnd_array_stone:onBatchRecycleBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneBatchRecycle)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneBatchRecycle)
end

function wnd_array_stone:onAmuletProperty(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneAmuletProp)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneAmuletProp)
end

function wnd_array_stone:onUpdate(dTime)
	if self._freeTimes >= 1 and self._showUI == 1 then
		self._countTime = self._countTime + dTime
		if self._countTime >= 1 then
			self._countTime = 0
			--self._layout.vars.countdown:setText(i3k_get_next_stone_pray_countdown())
			self._layout.vars.countdown:setText(i3k_get_string(18450))
		end
	end
	
	if self._playPray then
		self._prayCount = self._prayCount + dTime
		self._layout.vars.progress:setPercent((self._curUnlockId - 1 + self._prayCount / 1) * g_ARRAY_STONE_PRAY_HOLE * 1.01)
		if self._prayCount >= 1 then
			self._playPray = false
			self._prayCount = 0
			self._layout.anis.c_jiesuo.play()
		end
	end
end

function wnd_array_stone:updatePrayFreeTimes()
	self._freeTimes = 0
	self._layout.vars.countdown:setText(i3k_get_string(18410))
	self:updatePrayRedPoint()
end

function wnd_array_stone:showItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_array_stone:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18409))
end

function wnd_array_stone:updatePrayRedPoint()
	self._layout.vars.prayRed1:setVisible(g_i3k_game_context:getArrayStoneRedPointShow())
	self._layout.vars.prayRed2:setVisible(g_i3k_game_context:getArrayStoneRedPointShow())
end

function wnd_array_stone:playUnlockPrayAni(unlockId)
	--local pos = self._layout.vars["prayBg"..unlockId]:getPosition()
	self._curUnlockId = unlockId
	local pos = self._layout.vars["prayBg"..unlockId]:getParent():convertToWorldSpace(self._layout.vars["prayBg"..unlockId]:getPosition())
	local parent = self._layout.vars.unlockAni:getParent()
	self._layout.vars.unlockAni:setPosition(parent:convertToNodeSpace(cc.p(pos.x, pos.y)))
	if self._showUI == 1 then
		self._playPray = true
	end
end

function wnd_array_stone:setUnlockAmuletId(id)
	self._amuletId = id
	if self._showUI == 2 then
		self:playUnlockAmuletAni()
	end
end

function wnd_array_stone:playUnlockAmuletAni()
	local pos = self._layout.vars["amuletBg"..self._amuletId]:getParent():convertToWorldSpace(self._layout.vars["amuletBg"..self._amuletId]:getPosition())
	local parent = self._layout.vars.unlockAni:getParent()
	self._layout.vars.unlockAni:setPosition(parent:convertToNodeSpace(cc.p(pos.x, pos.y)))
	self._layout.anis.c_jiesuo.play()
	self._amuletId = 0
end

function wnd_array_stone:updateEquipAnimate(index)
	if self._showUI == 2 then
		local pos = self._layout.vars["amuletBg"..index]:getParent():convertToWorldSpace(self._layout.vars["amuletBg"..index]:getPosition())
		local parent = self._layout.vars.equipAni:getParent()
		self._layout.vars.equipAni:setPosition(parent:convertToNodeSpace(cc.p(pos.x, pos.y)))
		self._layout.anis.c_fydjtx.play()
	end
end

function wnd_array_stone:setArrayStonePrayPercent()
	local info = g_i3k_game_context:getArrayStoneData()
	self._layout.vars.progress:setPercent(info.holeCnt * g_ARRAY_STONE_PRAY_HOLE * 1.01)
end

function wnd_array_stone:onHide()
	g_i3k_coroutine_mgr:StopCoroutine(self._animateCo)
end

function wnd_create(layout)
	local wnd = wnd_array_stone.new()
	wnd:create(layout)
	return wnd
end
