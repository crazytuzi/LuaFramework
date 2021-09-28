local CrossPVPFlowerRankLayer = class("CrossPVPFlowerRankLayer", UFCCSModelLayer)

local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPFlowerRankItem = require("app.scenes.crosspvp.CrossPVPFlowerRankItem")

function CrossPVPFlowerRankLayer.show(caller)
	local layer = CrossPVPFlowerRankLayer.new("ui_layout/crosspvp_FlowerRankLayer.json", Colors.modelColor, caller)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossPVPFlowerRankLayer:ctor(json, color, caller)
	self._caller    = caller
	self._hasSetRank= false
	self._rankList 	= {}
	self._isApplied = G_Me.crossPVPData:isApplied() 	-- 我是否有参赛资格（有的话要显示我的排名）
	self._myField 	= G_Me.crossPVPData:getBattlefield()-- 我所在的赛场
	self.super.ctor(self, json, color)
end

function CrossPVPFlowerRankLayer:onLayerLoad()
	self:_initBetNum()
	self:_initListView()
	self:_initTabs()

	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClose))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClose))
end

function CrossPVPFlowerRankLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- pop in
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- 如果我参赛，默认先跳到我所在赛场的排行，否则就跳到第一个
	if self._isApplied then
		self._tabs:checked("CheckBox_" .. self._myField)
	else
		self._tabs:checked("CheckBox_" .. CrossPVPConst.BATTLE_FIELD_NUM)
	end
end

function CrossPVPFlowerRankLayer:_initBetNum()
	self:showTextWithLabel("Label_MyFlowerNum", tostring(G_Me.crossPVPData:getNumGetFlower()))
	self:showTextWithLabel("Label_MyEggNum", tostring(G_Me.crossPVPData:getNumGetEgg()))
end

function CrossPVPFlowerRankLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	for i = CrossPVPConst.BATTLE_FIELD_NUM, 1, -1 do
		self._tabs:add("CheckBox_" .. i, nil, "Label_" .. i)
	end
end

function CrossPVPFlowerRankLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return CrossPVPFlowerRankItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1, self._rankList[self._selField][index + 1])
		end)
	end

	self._listView:reloadWithLength(0)
end

function CrossPVPFlowerRankLayer:_reloadListView()
	self._listView:reloadWithLength(#self._rankList[self._selField])
end

-- 当拉到新的鲜花鸡蛋榜数据后，检查下是否需要同步到当前投注对象的鲜花鸡蛋数
function CrossPVPFlowerRankLayer:_updateCurBetTarget(data)
	local flowerTarget = G_Me.crossPVPData:getFlowerTarget()
	local eggTarget    = G_Me.crossPVPData:getEggTarget()

	if flowerTarget or eggTarget then
		local flowerUpdated = flowerTarget == nil
		local eggUpdated 	= eggTarget == nil
		for i, v in ipairs(data.ranks) do
			if flowerTarget then
				if tostring(flowerTarget.id) == tostring(v.id) and
				   tostring(flowerTarget.sid) == tostring(v.sid) then
				   G_Me.crossPVPData:updateBetTargetNum(CrossPVPConst.BET_FLOWER, v.sp3)
				   flowerUpdated = true
				end
			end

			if eggTarget then
				if tostring(eggTarget.id) == tostring(v.id) and
				   tostring(eggTarget.sid) == tostring(v.sid) then
				   G_Me.crossPVPData:updateBetTargetNum(CrossPVPConst.BET_EGG, v.sp4)
				   eggUpdated = true
				end
			end

			if flowerUpdated and eggUpdated then
				return
			end
		end
	end
end

function CrossPVPFlowerRankLayer:_onRcvRankList(data)
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK)
	self._rankList[self._selField] = clone(data.ranks)

	-- 当拉到新的鲜花鸡蛋榜数据后，检查下是否需要同步到当前投注对象的鲜花鸡蛋数
	self:_updateCurBetTarget(data)

	-- sort by flower number
	local sortFunc = function(a, b)
		return a.sp3 > b.sp3
	end
	table.sort(self._rankList[self._selField], sortFunc)

	-- set my rank, and update my flower / egg num
	if not self._hasSetRank then
		if not self._isApplied then
			self:showTextWithLabel("Label_MyRankNum", G_lang:get("LANG_NOT_IN_RANKING_LIST"))
			self._hasSetRank = true
		elseif self._selField == self._myField then
			local myID = G_Me.userData.id
			local myServer =  G_PlatformProxy:getLoginServer().id
			local myRank = 0

			for i, v in ipairs(self._rankList[self._selField]) do
				if tostring(v.id) == tostring(myID) and tostring(v.sid) == tostring(myServer) then
					myRank = i

					-- 更新我被扔鲜花鸡蛋的数量，以及buff加成
					G_Me.crossPVPData:updateMyFlowerEggNum(v.sp3, v.sp4)
					self._caller:_updateMyBuff()
					break
				end
			end

			local strRank = myRank > 0 and tostring(myRank) or G_lang:get("LANG_NOT_IN_RANKING_LIST")
			self:showTextWithLabel("Label_MyRankNum", strRank)
			self._hasSetRank = true
		end
	end

	self:_reloadListView()
end

function CrossPVPFlowerRankLayer:_onTabChecked(btnName)
	self._selField = self:getWidgetByName(btnName):getTag()

	local dataList = self._rankList[self._selField]
	if dataList and #dataList > 0 then
		self:_reloadListView()
	else
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK, self._onRcvRankList, self)
		G_HandlersManager.crossPVPHandler:sendGetLastRank(self._selField, 0, 100)
	end
end

function CrossPVPFlowerRankLayer:_onTabUnchecked()

end

function CrossPVPFlowerRankLayer:_onClose()
	self:animationToClose()
end

return CrossPVPFlowerRankLayer