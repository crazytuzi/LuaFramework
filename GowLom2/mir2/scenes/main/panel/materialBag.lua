local item = import("..common.item")
local materialBag = class("materialBag", function ()
	return display.newNode()
end)

table.merge(bag, {})

local innerBgWidth = 454
local innerBgHeight = 342
local offsetYInnerBg = 64
local maxFrameNum = 48
materialBag.ctor = function (self, _result)
	self.operatingItemData = nil
	self._supportMove = true
	self.currentFrameNum = _result.FmaxCount
	self.tItemsData = _result.FList
	self.tItems = {}
	self.tLocks = {}
	local bg = res.get2("pic/panels/bag/matBg.png"):anchor(0, 0):addto(self)
	self.bg = bg

	self.size(self, cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height)):anchor(0, 1):pos(bg.getContentSize(bg).width - 10, display.height)
	an.newLabel("材料背包", 22, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):pos(bg.getw(bg)/2, bg.geth(bg) - 28):addto(bg)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot3, 1, 1):pos(self.getw(self) - 14, self.geth(self) - 14):addto(bg):setName("bag_close")

	local function helpBtnCB()
		sound.playSound("103")

		local texts = {
			{
				"1.材料物品可放入材料背包，放入后自动堆叠。可放入的材料有书页、虔诚挂坠、精力水晶、声望礼包等。\n"
			},
			{
				"2.材料背包中的材料不会被爆出。\n"
			},
			{
				"3.角色达到44级、62级、80级时可免费扩充16格材料背包格。\n"
			},
			{
				"4.材料背包中的物品不会被带到跨服服务器中。\n"
			}
		}
		local msgbox = an.newMsgbox(texts)

		return 
	end

	an.newBtn(res.gettex2("pic/common/question.png"), slot3, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}):pos(38, 38):addTo(self.bg)
	display.newNode():size(451, 342):pos(24, 68):add2(bg):enableClick(function ()
		return 
	end)
	self.createFrameItems(slot0, _result.FList, self.currentFrameNum)
	an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		sound.playSound("103")
		self:createFrameItems(self.tItemsData, self.currentFrameNum)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn71.png"),
		label = {
			"整理",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).pos(slot4, 445, 40):add2(bg)
	an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		sound.playSound("103")
		self:clickExpendSpace()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn71.png"),
		label = {
			"扩充",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).pos(slot4, 370, 40):add2(bg)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ChangeItemMaterStorage, self, self.onSM_ChangeItemMaterStorage)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ExpandMaterStorage, self, self.onSM_ExpandMaterStorage)

	return 
end
materialBag.idx2pos = function (self, idx)
	idx = idx - 1
	local h = idx%8
	local v = math.modf(idx/8)

	return h*56 + 53, v*56 - 379
end
materialBag.pos2idx = function (self, x, y)
	local h = math.floor((x - 53 + 28)/56)
	local v = math.floor((y - 379 + 28)/56)

	if 0 <= v and v < 6 and 0 <= h and h < 8 then
		return v*8 + h + 1
	end

	return -1
end
materialBag.createFrameItems = function (self, _itemsDataList, _openedFrameNum)
	self.tItems = {}

	if self.nodeFrame then
		self.nodeFrame:removeSelf()

		self.nodeFrame = nil
	end

	self.nodeFrame = display.newNode():addTo(self.bg)

	for i = 1, maxFrameNum, 1 do
		local x, y = self.idx2pos(self, i)

		res.get2("pic/panels/bag/itembg.png"):anchor(0.5, 0.5):addTo(self.nodeFrame, 1):pos(x, y)

		if _openedFrameNum < i then
			self.tLocks[i] = an.newBtn(res.gettex2("pic/panels/storage/icon_lock_bg.png"), function ()
				sound.playSound("103")
				self:clickExpendSpace()

				return 
			end).addTo(slot10, self.nodeFrame, 1):pos(x, y)
		end
	end

	for i, v in ipairs(_itemsDataList) do
		setmetatable(v, {
			__index = gItemOp
		})
		v.decodedCallback(v)
	end

	table.sort(_itemsDataList, function (a, b)
		if a.getVar(a, "stdMode") == b.getVar(b, "stdMode") then
			if a.getVar(a, "name") == b.getVar(b, "name") then
				return a.FDura < b.FDura
			else
				return def.items.name2Index[a.getVar(a, "name")] < def.items.name2Index[b.getVar(b, "name")]
			end
		else
			return a.getVar(a, "stdMode") < b.getVar(b, "stdMode")
		end

		return 
	end)

	for i, v in ipairs(item) do
		local x, y = self.idx2pos(self, i)
		self.tItems[i] = item.new(v, self, {
			idx = i
		}):addTo(self.nodeFrame, 2):pos(x, y)
	end

	return 
end
materialBag.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		self.operatingItemData = item.data
		local rsb = DefaultClientMessage(CM_ChangeItemMaterStorage)
		rsb.FNpcId = 0
		rsb.FItemIdent = item.data.FItemIdent
		rsb.FiActType = 1

		MirTcpClient:getInstance():postRsb(rsb)
	elseif form == "materialBag" then
		local putIdx = self.pos2idx(self, x/self.getScale(self), y/self.getScale(self))

		if 1 <= putIdx and putIdx <= self.currentFrameNum then
			local srcIdx = item.params.idx
			local srcItem = self.tItems[srcIdx]
			local putItem = self.tItems[putIdx]
			item.params.idx = putIdx

			item.pos(item, self.idx2pos(self, putIdx))

			if putItem then
				putItem.params.idx = srcIdx

				putItem.pos(putItem, self.idx2pos(self, srcIdx))
			end

			self.tItems[putIdx] = self.tItems[srcIdx]
			self.tItems[srcIdx] = self.tItems[putIdx]

			return true, true
		else
			return false, true
		end
	end

	return 
end
materialBag.getBackItem = function (self, item)
	self.operatingItemData = item.data
	local rsb = DefaultClientMessage(CM_ChangeItemMaterStorage)
	rsb.FNpcId = 0
	rsb.FItemIdent = item.data.FItemIdent
	rsb.FiActType = 2

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
materialBag.onSM_ChangeItemMaterStorage = function (self, result, protoId)
	if result.FiActType == 1 then
		if result.Flag == 1 then
			g_data.bag:delItem(self.operatingItemData.FItemIdent)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:delItem(self.operatingItemData.FItemIdent)
			end

			self.addItem(self, self.operatingItemData)
		elseif result.Flag == 3 then
			main_scene.ui:tip("该物品无法放入材料背包")
		elseif result.Flag == 2 then
			main_scene.ui:tip("材料背包已满，放入失败")
		end
	elseif result.FiActType == 2 then
		if result.Flag == 1 then
			self.delItem(self, self.operatingItemData.FItemIdent)
		else
			main_scene.ui:tip("背包已满，放入失败")

			for k, v in pairs(self.tItems) do
				if self.operatingItemData.FItemIdent == v.data.FItemIdent then
					local x, y = self.idx2pos(self, v.params.idx)

					v.pos(v, x, y)
				end
			end
		end
	end

	return 
end
materialBag.onSM_ExpandMaterStorage = function (self, result, protoId)
	if self.currentFrameNum < result.FSpaceCount then
		main_scene.ui:tip("材料背包扩充成功")

		self.currentFrameNum = result.FSpaceCount

		for k, v in pairs(self.tLocks) do
			if k <= self.currentFrameNum then
				self.tLocks[k]:removeSelf()

				self.tLocks[k] = nil
			end
		end

		self.createFrameItems(self, self.tItemsData, self.currentFrameNum)
	else
		main_scene.ui:tip("扩充失败")
	end

	return 
end
materialBag.addItem = function (self, data)
	for i = 1, maxFrameNum, 1 do
		if not self.tItems[i] then
			setmetatable(data, {
				__index = gItemOp
			})

			self.tItems[i] = item.new(data, self, {
				idx = i
			}):addto(self.nodeFrame, 2):pos(self.idx2pos(self, i))

			break
		end
	end

	self.PileUpItem(self)

	self.tItemsData[#self.tItemsData + 1] = data

	return 
end
materialBag.delItem = function (self, makeIndex)
	for k, v in pairs(self.tItems) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			self.tItems[k]:removeSelf()

			self.tItems[k] = nil

			for m, n in pairs(self.tItemsData) do
				if n.FItemIdent == tonumber(makeIndex) then
					table.remove(self.tItemsData, m)
				end
			end

			break
		end
	end

	return 
end
materialBag.duraChange = function (self, makeIndex, dura, duraMax, price)
	for k, v in pairs(self.tItems) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			v.data.FDura = dura
			v.data.FDuraMax = duraMax

			v.duraChange(v)

			break
		end
	end

	return 
end
materialBag.AutoItemAdd = function (self, item)
	for i, v in pairs(self.tItems) do
		if v.data:isCanPileUp(item.data) then
			return {
				v.data,
				item.data
			}
		end
	end

	return 
end
materialBag.PileUpNext = function (self)
	if g_data.player.inPileUping then
		return false
	end

	for i, v in pairs(self.tItems) do
		local ret = self.AutoItemAdd(self, v)

		if ret then
			return ret
		end
	end

	return 
end
materialBag.PileUpItem = function (self)
	if not g_data.player.IsSplliteItem then
		local ret = self.PileUpNext(self)

		if type(ret) == "table" and #ret == 2 then
			local rsb = DefaultClientMessage(CM_ITEM_PILEUP)
			rsb.FitemIdent1 = ret[2].FItemIdent
			rsb.FitemIdent2 = ret[1].FItemIdent

			MirTcpClient:getInstance():postRsb(rsb)
			g_data.player:setIsinPileUping(true)
		end
	end

	g_data.player:setIsSplliting(false)

	return 
end
materialBag.clickExpendSpace = function (self)
	if self.currentFrameNum == 48 then
		main_scene.ui:tip("材料背包已扩充至上限")
	else
		local requiredLv = ""

		if self.currentFrameNum == 16 then
			requiredLv = 62
		elseif self.currentFrameNum == 32 then
			requiredLv = 80
		end

		local texts = {
			{
				"确认"
			},
			{
				"免费",
				display.COLOR_RED
			},
			{
				"扩充"
			},
			{
				"16格材料背包",
				display.COLOR_RED
			},
			{
				"吗?\n"
			},
			{
				"(需角色达到"
			},
			{
				requiredLv .. "级",
				display.COLOR_RED
			},
			{
				")"
			}
		}

		an.newMsgbox(texts, function (idx)
			if idx == 1 then
				if requiredLv <= g_data.player.ability.FLevel then
					local rsb = DefaultClientMessage(CM_ExpandMaterStorage)
					rsb.FSpaceCount = 16

					MirTcpClient:getInstance():postRsb(rsb)
				else
					main_scene.ui:tip("扩充失败，等级不足")
				end
			end

			return 
		end, {
			title = "提示",
			center = true,
			hasCancel = true,
			btnTexts = {
				"确定",
				"取消"
			}
		})
	end

	return 
end

return materialBag
