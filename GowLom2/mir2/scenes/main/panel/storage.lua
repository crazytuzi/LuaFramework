local item = import("..common.item")
local common = import("..common.common")
local storage = class("storage", function ()
	return display.newNode()
end)

table.merge(slot2, {
	merchant,
	quick,
	tabs,
	currentTab,
	gridCnt,
	gridMax
})

storage.ctor = function (self, result)
	self._scale = self.getScale(self)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	self.merchant = result.FnpcId
	self.quick = false
	self.gridMax = 48
	local bg = res.get2("pic/panels/bag/newbg.png"):anchor(0, 0):addto(self)
	self.bg = bg

	an.newLabel("仓库", 22, 0, {
		color = cc.c3b(210, 177, 156)
	}):anchor(0.5, 0.5):pos(bg.getw(bg)/2, bg.geth(bg) - 28):addto(bg)
	self.size(self, bg.getContentSize(bg)):pos(display.left + 30, display.height - 50 - bg.getContentSize(bg).height)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot3, 1, 1):pos(bg.getw(bg) - 14, bg.geth(bg) - 14):addto(self, 2)
	display.newNode():size(451, 342):pos(24, 68):add2(bg):enableClick(function ()
		return 
	end)

	local quickBtn = nil
	quickBtn = an.newBtn(res.gettex2("pic/common/btn10.png"), function (event)
		self.quick = not self.quick

		return 
	end, {
		manual = true,
		label = {
			"快速存取",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		select = {
			res.gettex2("pic/common/btn11.png")
		}
	}).addTo(slot4, self, 2):pos(20, 40):anchor(0, 0.5)

	an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		if g_data.client:checkLastTime("orderStorage", 1) then
			g_data.client:setLastTime("orderStorage", true)
			self:copybak()
			self:reload()
		else
			main_scene.ui:tip("你整理的太快了。")
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn71.png"),
		label = {
			"整理",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).pos(slot4, 445, 40):add2(self, 2)

	self.gridCnt = result.FmaxCount
	self.items = {}
	self.itemDatas = {}

	if result.FList then
		for k, v in ipairs(result.FList) do
			setmetatable(v, {
				__index = gItemOp
			})
			v.decodedCallback(v)
		end
	end

	self.itemDatasBak = result.FList or {}

	self.copybak(self)

	local strs = {
		"壹",
		"贰",
		"叁",
		"肆"
	}
	self.tabs = common.tabs(self, {
		ox = 3,
		strokeSize = 1,
		oy = 10,
		strs = strs,
		lc = {
			normal = def.colors.Ca6a197,
			select = def.colors.Cf0c896
		}
	}, function (idx, btn)
		self.currentTab = idx

		self:reload()

		return 
	end, {
		tabTp = 1,
		pos = {
			offset = 70,
			x = 5,
			y = bg.getContentSize(slot2).height - 50,
			anchor = cc.p(1, 1)
		}
	})

	if main_scene.ground.player then
		self.x = main_scene.ground.player.x
		self.y = main_scene.ground.player.y
	end

	main_scene.ui:hidePanel("npc")
	main_scene.ui:showPanel("bag")
	main_scene.ui.panels.bag:resetPanelPosition("storage")
	main_scene.ui.panels.bag:setScaleMul(1)

	return 
end
storage.copybak = function (self)
	self.itemDatas = {}

	for i, v in ipairs(self.itemDatasBak) do
		if g_data.player:isAuthen() then
			self.itemDatas[i] = v
		else
			self.itemDatas[i + ((self.gridMax/2 < i and self.gridMax/2) or 0)] = v
		end
	end

	return 
end
storage.onCleanup = function (self)
	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:resetPanelPosition("left")
	end

	return 
end
storage.reload = function (self)
	for k, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	if self.tabNode then
		self.tabNode:removeSelf()

		self.tabNode = nil
	end

	self.tabNode = display.newNode():addTo(self.bg)

	for i = 1, self.gridMax, 1 do
		local idx = i + (self.currentTab - 1)*self.gridMax
		local x, y = self.idx2pos(self, idx)

		if self.gridIsOpen(self, idx) then
			res.get2("pic/panels/bag/itembg.png"):addTo(self.tabNode, 1):pos(x, y)

			local v = self.itemDatas[idx]

			if v then
				self.items[i] = item.new(v, self, {
					idx = idx
				}):addto(self.tabNode, 2):pos(x, y)
			end
		else
			local item = res.get2("pic/panels/storage/icon_lock_bg.png"):addto(self.tabNode, 2):pos(x, y)
			item.block = true
			self.items[i] = item
		end
	end

	return 
end
storage.idx2pos = function (self, idx)
	idx = idx - 1 - (self.currentTab - 1)*self.gridMax
	local h = idx%8
	local v = math.modf(idx/8)

	return h*56 + 53, v*56 - 379
end
storage.pos2idx = function (self, x, y)
	local h = math.floor((x - 53 + 28)/56)
	local v = math.floor((y - 379 + 28)/56)

	if 0 <= v and v < 6 and 0 <= h and h < 8 then
		return v*8 + h + 1 + (self.currentTab - 1)*self.gridMax
	end

	return -1
end
storage.gridIsOpen = function (self, idx)
	local open = idx <= self.gridCnt

	if not g_data.player:isAuthen() then
		open = (idx < self.gridMax/2 and true) or ((self.gridMax/2 >= idx or idx > self.gridMax or false) and idx <= self.gridCnt + self.gridMax/2)
	end

	return open
end
storage.addItem = function (self, data)
	self.itemDatasBak[#self.itemDatasBak + 1] = data

	local function add(idx)
		self.itemDatas[idx] = data
		local belongTab = math.ceil(idx/self.gridMax)

		if belongTab ~= self.currentTab then
			self.tabs.click(belongTab)
		else
			local itemidx = (idx - 1)%self.gridMax + 1
			self.items[itemidx] = item.new(data, self, {
				idx = idx
			}):addto(self, 2):pos(self:idx2pos(idx))
		end

		return 
	end

	for i = 1, self.gridMax*4, 1 do
		if not self.itemDatas[i] then
			if g_data.player.isAuthen(slot7) then
				add(i)

				break
			elseif i <= self.gridMax/2 or self.gridMax < i then
				add(i)

				break
			end
		end
	end

	return 
end
storage.delItem = function (self, makeIndex)
	for k, v in pairs(self.items) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			self.items[k]:removeSelf()

			self.items[k] = nil

			break
		end
	end

	return 
end
storage.findItem = function (self, idx)
	for k, v in pairs(self.items) do
		if not v.block and idx == v.params.idx then
			return v
		end
	end

	return 
end
storage.delItemData = function (self, makeIndex)
	for k, v in pairs(self.itemDatas) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.itemDatas[k] = nil

			break
		end
	end

	for i, v in ipairs(self.itemDatasBak) do
		if v.FItemIdent == tonumber(makeIndex) then
			table.remove(self.itemDatasBak, i)

			break
		end
	end

	return 
end
storage.changePos = function (self, idx1, idx2)
	self.itemDatas[idx2] = self.itemDatas[idx1]
	self.itemDatas[idx1] = self.itemDatas[idx2]

	return 
end
storage.duraChange = function (self, makeIndex, dura, duraMax, price)
	for k, v in pairs(self.itemDatas) do
		if v.FItemIdent == tonumber(makeIndex) then
			v.FDura = dura
			v.FDuraMax = duraMax

			break
		end
	end

	for k, v in ipairs(self.itemDatasBak) do
		if v.FItemIdent == tonumber(makeIndex) then
			v.FDura = dura
			v.FDuraMax = duraMax

			break
		end
	end

	for k, v in pairs(self.items) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			v.duraChange(v)

			break
		end
	end

	return 
end
storage.putInItem = function (self, item)
	if not g_data.client.storageItem then
		local data = item.data

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data.FItemIdent)
		end

		g_data.bag:delItem(data.FItemIdent)
		g_data.client:setStorageItem(data)

		local rsb = DefaultClientMessage(CM_ChangeStoreItem)
		rsb.FItemIdent = data.FItemIdent
		rsb.FNpcId = self.merchant
		rsb.FiStoreType = 0
		rsb.FiActType = 1

		MirTcpClient:getInstance():postRsb(rsb)
	end

	return 
end
storage.getBackItem = function (self, item)
	if not g_data.client.storageGetBackItem then
		local data = item.data

		self.delItem(self, data.FItemIdent)
		self.delItemData(self, data.FItemIdent)
		g_data.client:setStorageGetBackItem(data)

		local rsb = DefaultClientMessage(CM_ChangeStoreItem)
		rsb.FItemIdent = data.FItemIdent
		rsb.FNpcId = self.merchant
		rsb.FiStoreType = 0
		rsb.FiActType = 2

		MirTcpClient:getInstance():postRsb(rsb)
	end

	return 
end
storage.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		self.putInItem(self, item)
	elseif form == "storage" then
		local putIdx = self.pos2idx(self, x/self.getScale(self), y/self.getScale(self))

		if putIdx == -1 or item.params.idx == putIdx or self.gridMax*4 < putIdx then
			return 
		end

		if not self.gridIsOpen(self, putIdx) then
			return 
		end

		local srcIdx = item.params.idx

		local function canPileUp(data1, data2)
			if data1 and data2 and data1.isCanPileUp(data1, data2) then
				return true
			end

			return false
		end

		local srcItem = self.findItem(slot0, srcIdx)
		local putItem = self.findItem(self, putIdx)

		if putItem and canPileUp(srcItem.data, putItem.data) then
			local item1 = putItem.data
			local makeIndex2 = srcItem.data.FItemIdent

			if item1.isNeedResetPos(item1, srcItem.data) then
				putItem.pos(putItem, self.idx2pos(self, putIdx))
				srcItem.pos(srcItem, self.idx2pos(self, srcIdx))
			end

			local rsb = DefaultClientMessage(CM_ITEM_PILEUP)
			rsb.FitemIdent1 = item1.FItemIdent
			rsb.FitemIdent2 = makeIndex2

			MirTcpClient:getInstance():postRsb(rsb)
			g_data.player:setIsinPileUping(true)
		else
			item.params.idx = putIdx

			item.pos(item, self.idx2pos(self, putIdx))

			if putItem then
				putItem.params.idx = srcIdx

				putItem.pos(putItem, self.idx2pos(self, srcIdx))
			end

			putIdx = (putIdx - 1)%self.gridMax + 1
			srcIdx = (srcIdx - 1)%self.gridMax + 1
			self.items[putIdx] = srcItem
			self.items[srcIdx] = putItem

			self.changePos(self, srcIdx, putIdx)
		end

		return true
	end

	return 
end
storage.spaceChanged = function (self, spaceCount)
	if type(spaceCount) == "number" then
		self.gridCnt = spaceCount

		self.reload(self)
	end

	return 
end

return storage
