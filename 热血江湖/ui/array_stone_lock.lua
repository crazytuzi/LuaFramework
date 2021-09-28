-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_lock = i3k_class("wnd_array_stone_lock", ui.wnd_base)



function wnd_array_stone_lock:ctor()
	self._selectState = {} --set
	self._lockStone = {} --set
	self._allStones = {}
end

function wnd_array_stone_lock:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.sureLockBtn:onClick(self, self.onSureLock)
	for k = 1, i3k_db_array_stone_common.maxStonesuffix do
		self._layout.vars["chooseAllBtn"..k]:onClick(self, self.onChooseAllBtn, k)
	end
	self._layout.vars.scroll:setBounceEnabled(false)
end

function wnd_array_stone_lock:refresh()
	local info = g_i3k_game_context:getArrayStoneData()
	self._lockStone = i3k_clone(info.locks)
	self:getAllStones()
	self:updateLockStoneScroll()
	self:refreshAllLockIcons()
	for k = 1, i3k_db_array_stone_common.maxStonePrefix do
		self._layout.vars["prefix"..k]:setText(i3k_db_array_stone_common.prefixSelect[k])
	end
	for k = 1, i3k_db_array_stone_common.maxStonesuffix do
		self._layout.vars["suffix"..k]:setText(i3k_db_array_stone_common.suffixSelect[k])
	end
end

--这个只要每次打开ui的时候调用一次即可
function wnd_array_stone_lock:getAllStones()
	for k, v in pairs(i3k_db_array_stone_cfg) do
		if v.level == 1 then
			table.insert(self._allStones, v)
		end
	end
	table.sort(self._allStones, function(a, b)
		if a.suffixId == b.suffixId then
			return a.prefixId < b.prefixId
		else
			return a.suffixId < b.suffixId
		end
	end)
end

function wnd_array_stone_lock:updateLockStoneScroll()
	self._layout.vars.scroll:removeAllChildren()
	local children = self._layout.vars.scroll:addItemAndChild("ui/widgets/zfssdt1", i3k_db_array_stone_common.maxStonePrefix, #self._allStones)
	for k, v in ipairs(children) do
		v.vars.stoneBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_array_stone_cfg[self._allStones[k].id].rank, false))
		v.vars.stoneIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[self._allStones[k].id].stoneIcon))
		v.vars.stoneLock:setVisible(self._lockStone[self._allStones[k].id])
		v.vars.stoneBtn:onClick(self, self.onChooseStone, {node = v, index = k})
		v.vars.stoneCount:hide()
	end
end

function wnd_array_stone_lock:refreshAllLockIcons()
	for i = 1, i3k_db_array_stone_common.maxStonesuffix do
		local isLockAll = true
		for k = (i - 1) * i3k_db_array_stone_common.maxStonePrefix + 1, i * i3k_db_array_stone_common.maxStonePrefix do
			if not self._lockStone[self._allStones[k].id] then
				isLockAll = false
				break
			end
		end
		if isLockAll then
			self._selectState[i] = true
			self._layout.vars["chooseAllIcon"..i]:show()
		end
	end
end

function wnd_array_stone_lock:onChooseStone(sender, stone)
	if self._lockStone[self._allStones[stone.index].id] then
		self._lockStone[self._allStones[stone.index].id] = nil
		stone.node.vars.stoneLock:hide()
		local index = math.ceil(stone.index / i3k_db_array_stone_common.maxStonePrefix)
		self._selectState[index] = false
		self._layout.vars["chooseAllIcon"..index]:hide()
	else
		self._lockStone[self._allStones[stone.index].id] = true
		stone.node.vars.stoneLock:show()
		local index = math.ceil(stone.index / i3k_db_array_stone_common.maxStonePrefix)
		local isLockAll = true
		for k = (index - 1) * i3k_db_array_stone_common.maxStonePrefix + 1, index * i3k_db_array_stone_common.maxStonePrefix do
			if not self._lockStone[self._allStones[k].id] then
				isLockAll = false
				break
			end
		end
		if isLockAll then
			self._selectState[index] = true
			self._layout.vars["chooseAllIcon"..index]:show()
		end
	end
end

function wnd_array_stone_lock:onChooseAllBtn(sender, index)
	if self._selectState[index] then
		self._selectState[index] = false
		self._layout.vars["chooseAllIcon"..index]:hide()
		for k = (index - 1) * i3k_db_array_stone_common.maxStonePrefix + 1, index * i3k_db_array_stone_common.maxStonePrefix do
			self._lockStone[self._allStones[k].id] = nil
		end
	else
		self._selectState[index] = true
		self._layout.vars["chooseAllIcon"..index]:show()
		for k = (index - 1) * i3k_db_array_stone_common.maxStonePrefix + 1, index * i3k_db_array_stone_common.maxStonePrefix do
			self._lockStone[self._allStones[k].id] = true
		end
	end
	self:updateLockStoneScroll()
end

function wnd_array_stone_lock:onSureLock(sender)
	i3k_sbean.array_stone_ciphertext_lock(self._lockStone)
end

function wnd_create(layout)
	local wnd = wnd_array_stone_lock.new()
	wnd:create(layout)
	return wnd
end
