local CommonItem = import("..common.item")
local CommonItemInfo = import("..common.itemInfo")
local drumUpgrade = import(".drumUpgrade")
local stateEffectConfig = def.stateEffectCfg
local arenaRankReward = class("arenaRankReward", import(".panelBase"))
arenaRankReward.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.params = params
	self.contentView = nil
	self.rewardList = nil
	self.spItemInfo = nil
	self.pageIndex = 1
	self.showCount = 4
	self.showList = {}

	return 
end
arenaRankReward.onEnter = function (self)
	self.initPanelUI(self, {
		title = "排名奖励",
		bg = "pic/common/tabbg.png",
		modalView = false,
		titleOffsetY = -4,
		closeOffsetY = -4,
		size = cc.size(385, 375)
	})
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(16, 60):size(352, 260):addTo(self.bg)

	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(344, 42)):anchor(0.5, 0.5):pos(192.5, 295):add2(self.bg)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0.5, 0.5):pos(130, 295):add2(self.bg)
	an.newLabel("排名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(73.75, 295):add2(self.bg, 2)
	an.newLabel("奖励", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(250.75, 295):add2(self.bg, 2)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:switchPage(self.pageIndex - 1)

		return 
	end, {
		label = {
			"上一页",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot2, self.bg:getw()/2 - 77, 38):addto(self.bg)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:switchPage(self.pageIndex + 1)

		return 
	end, {
		label = {
			"下一页",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot2, self.bg:getw()/2 + 77, 38):addto(self.bg)

	for i = 1, self.showCount, 1 do
		local cellBgFrame = res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		slot7 = display.newScale9Sprite(cellBgFrame):anchor(0.5, 0.5):pos(self.bg:getw()/2, i*52 - 300):size(345, 52):addTo(self.bg)
	end

	self.bindNetEvent(self, SM_ArenaReqRewardList, self.onSM_ArenaReqRewardList)

	local rsb = DefaultClientMessage(CM_ArenaReqRewardList)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
arenaRankReward.onCloseWindow = function (self)
	return self.super.onCloseWindow(self)
end
arenaRankReward.switchPage = function (self, nIndex)
	if self.contentView then
		self.contentView:removeSelf()

		self.contentView = nil
	end

	self.contentView = display.newNode():addTo(self.bg)
	self.showList = self.showList or {}

	if nIndex < 1 then
		nIndex = 1
	end

	if #self.showList < nIndex then
		nIndex = #self.showList or nIndex
	end

	self.pageIndex = nIndex

	if not self.showList[nIndex] then
		return 
	end

	local function splitAtr(attrstr)
		local atrTable = {}
		local atrs = string.split(attrstr, "/")

		for k, v in ipairs(atrs) do
			local oneAtr = string.split(v, "|")

			if #oneAtr == 2 then
				atrTable[#atrTable + 1] = {
					oneAtr[1],
					tonumber(oneAtr[2])
				}
			end
		end

		return atrTable
	end

	for k, v in ipairs(self.showList[nIndex]) do
		local strTxt = ""
		local strColor = def.colors.Cf0c896

		if v.Frankfrom == v.Frankto then
			strTxt = "第" .. self.numToGBK(slot0, v.Frankfrom) .. "名"

			if v.Frankfrom == 1 then
				strColor = def.colors.Ccf15e1
			end

			if v.Frankfrom == 2 then
				strColor = def.colors.C3794fb
			end

			if v.Frankfrom == 3 then
				strColor = def.colors.C32b16c
			end
		else
			strTxt = v.Frankfrom .. "~" .. v.Frankto .. "名"
		end

		an.newLabel(strTxt, 18, 0, {
			color = strColor
		}):anchor(0.5, 0.5):pos(75, k*52 - 300):add2(self.contentView)

		local itemListView = an.newScroll(130.5, k*52 - 300, 233.3, 52, {
			dir = 2
		}):add2(self.contentView):anchor(0, 0.5)

		itemListView.enableTouch(itemListView, false)

		local theItems = splitAtr(v.Freward)
		local special = common.getSpecialItemIcon()

		for _k, _v in pairs(theItems) do
			local itemName = _v[1]
			local itemNum = _v[2]
			local itemImage = display.newSprite(res.gettex2("pic/common/itembg2.png")):anchor(0, 0.5):pos((_k - 1)*50, 26):add2(itemListView)

			if special[itemName] then
				local pos = {
					x = (_k - 1)*50 + 230,
					y = k*52 - 350
				}

				self.addSpecialItem(self, itemImage, itemName, itemNum, pos)
			else
				local itemIdx = def.items.getItemIdByName(itemName)

				if itemIdx then
					self.addItem(self, itemImage, def.items.getStdItemById(itemIdx), itemNum)
				end
			end
		end
	end

	return 
end
arenaRankReward.addSpecialItem = function (self, parentNode, itemName, itemNum, pos)
	local special = common.getSpecialItemIcon()
	local looks = nil

	if special[itemName] then
		looks = special[itemName]
	end

	if looks then
		local itemI = res.get("items", looks):addto(parentNode):anchor(0.5, 0.5):pos(parentNode.getw(parentNode)/2, parentNode.geth(parentNode)/2)

		if 0 < tonumber(itemNum) then
			an.newLabel(itemNum, 11, 1, {
				color = cc.c3b(0, 255, 0)
			}):anchor(1, 0):pos(43, 5):add2(itemI, 2)
		end

		parentNode.setTouchEnabled(parentNode, true)
		parentNode.setTouchSwallowEnabled(parentNode, true)
		parentNode.addNodeEventListener(parentNode, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(self.bg, 2):anchor(0.5, 0.5):pos(pos.x, pos.y)
				self.contentView.itemInfo = bg
				local infoT = an.newLabel(itemName, 24, 0):addTo(bg):pos(10, 4)

				bg.size(bg, infoT.getw(infoT) + 20, infoT.geth(infoT) + 8)

				return true
			elseif event.name == "ended" and self.contentView.itemInfo then
				self.contentView.itemInfo:removeSelf()

				self.contentView.itemInfo = nil
			end

			return 
		end)
	end

	return 
end
arenaRankReward.addItem = function (self, parentNode, itemData, itemNum)
	if not itemData then
		return 
	end

	if 0 < itemNum then
		itemData.FDura = itemNum
	end

	local equipItem = CommonItem.new(itemData, self, {
		scroll = true,
		donotMove = true,
		idx = idx
	}):add2(parentNode, 2):pos(parentNode.getw(parentNode)/2, parentNode.geth(parentNode)/2)

	equipItem.setLocalZOrder(equipItem, 2)

	return 
end
arenaRankReward.numToGBK = function (self, num)
	local TXT_NUM = {
		"一",
		"二",
		"三",
		"四",
		"五",
		"六",
		"七",
		"八",
		"九",
		"十"
	}

	return TXT_NUM[num] or ""
end
arenaRankReward.onSM_ArenaReqRewardList = function (self, result)
	if result and result.Fres == 0 then
		self.rewardList = result.Flist or {}
		self.showList = {}

		for k, v in ipairs(self.rewardList) do
			local showIdx = math.ceil(k/self.showCount)
			self.showList[showIdx] = self.showList[showIdx] or {}

			table.insert(self.showList[showIdx], v)
		end

		self.switchPage(self, 1)
	end

	return 
end

return arenaRankReward
