local data_item_item = require("data.data_item_item")
local BaseScene = require("game.BaseScene")
local CheatsList = class("CheatsList", BaseScene)

local TAB_TAG = {MIJI = 1, SOUL = 2}
local COMMON_VIEW = 1
local SALE_VIEW = 2
local LISTVIEW_TAG = 100

function CheatsList:ctor(tag)
	game.runningScene = self
	
	CheatsList.super.ctor(self, {
	contentFile = "hero/hero_list_bg.ccbi",
	subTopFile = "hero/hero_up_tab.ccbi"
	})
	
	if tag == nil or tag < 0 or tag > 2 then
		self._currentTab = TAB_TAG.MIJI
	else
		self._currentTab = tag
	end
	
	self:setNodeEventEnabled(true)
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_main_menu.plist", "ui/ui_main_menu.pvr.ccz")
	self.viewType = COMMON_VIEW
	resetctrbtnString(self._rootnode.tab1, common:getLanguageString("@Cheats"))
	resetctrbtnString(self._rootnode.tab2, common:getLanguageString("@sz_suipian"))
	self._rootnode.tab3:setVisible(false)
	self._bExit = false
	self._rootnode.tag:setPositionX(display.width * 0.5)
	self._rootnode.tag:setZOrder(1000)
	self:checkHasDot()
	self:initControlBtn()
	self.listView = self._rootnode.listView
	self.scrollLayerNode = display.newNode()
	self.listView:addChild(self.scrollLayerNode)
	self.commonList = {}
	self:sendReq()
end

function CheatsList:initControlBtn()
	self._rootnode.sellStarBtn:setVisible(false)
	self._rootnode.sellBtn:setVisible(false)
	
	--扩展背包
	self.extendBtn = self._rootnode.expandBtn
	self.extendBtn:setPositionX(self._rootnode.sellBtn:getPositionX())
	self.extendBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:extend()
	end,
	CCControlEventTouchUpInside)
	
	--图鉴
	self.tujianBtn = self._rootnode.tujianBtn
	self.tujianBtn:setVisible(false)
	self.tujianBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_HANDBOOK_CHEATS)
	end,
	CCControlEventTouchUpInside)
	
end

--[[背包扩展]]
function CheatsList:extend()
	local function _callback(data)
		if string.len(data["0"]) == 0 then
			local bagCountMax = data["1"]
			local costGold = data["2"]
			local curGold = data["3"]
			game.player:setBagCountMax(bagCountMax)
			game.player:setGold(curGold)
			self:updateLabel()
			self:setMaxNum(bagCountMax)
			self._cost[1] = data["4"]
			self._cost[2] = data["5"]
			show_tip_label("恭喜您已开启5个秘笈背包位置")
			PostNotice(NoticeKey.MainMenuScene_Update)
		else
			CCMessageBox(data["0"], "Error")
		end
	end
	if self._cost[1] ~= -1 then
		local layer = require("utility.CostTipMsgBox").new({
		tip = common:getLanguageString("@OpenLocation", self._cost[2]),
		listener = function()
			if game.player.m_gold >= self._cost[1] then
				RequestHelper.extendBag({
				type = BAG_TYPE.cheats,
				callback = function(data)
					if _callback ~= nil then
						_callback(data)
					end
				end
				})
			else
				ResMgr.showErr(2300007)
			end
		end,
		cost = self._cost[1]
		})
		self:addChild(layer, 100)
	else
		show_tip_label("秘笈背包空间已达上限")
	end
end

--[[请求数据]]
function CheatsList:sendReq()
	CheatsModel.getCheatsListInfo({
	callback = function(data)
		self._cost = {
		data["4"],
		data["5"]
		}
		self:init(data)
	end,
	errback = function()
		TutoMgr.active()
	end
	})
end

function CheatsList:createCollectLayer(debrisId)
	local collectLayer = require("game.Hero.CollectLayer").new(debrisId, ResMgr.CHEATS)
	self:addChild(collectLayer, 103)
end

function CheatsList:hechengLayer(hechengData)
	RequestHelper.sendHeChengHeroRes({
	callback = function(listData)
		if listData["5"] == true then
			show_tip_label("您的秘笈背包已满")
		elseif string.len(listData["0"]) > 0 then
			CCMessageBox(listData["0"], "Tip")
		else
			do
				local isFull = listData["3"] or false
				if not isFull then
					self:updateDebriList()
					show_tip_label(common:getLanguageString("@CheatsCompoundSucceed"))
				else
					do
						local bagObj = listData["4"]
						local function extendBag(data)
							self:setMaxNum(checkint(self._rootnode.maxNum:getString()) + bagObj[1].size)
							if bagObj[1].curCnt < data["1"] then
								table.remove(bagObj, 1)
							else
								bagObj[1].cost = data["4"]
								bagObj[1].size = data["5"]
							end
							if #bagObj > 0 then
								self:addChild(require("utility.LackBagSpaceLayer").new({
								bagObj = bagObj,
								callback = function(data)
									extendBag(data)
								end
								}), MAX_ZORDER)
							else
								isFull = false
							end
						end
						if isFull then
							self:addChild(require("utility.LackBagSpaceLayer").new({
							bagObj = bagObj,
							callback = function(data)
								extendBag(data)
							end
							}), MAX_ZORDER)
						end
					end
				end
			end
		end
	end,
	id = hechengData.id,
	num = hechengData.num
	})
end

function CheatsList:initDebriList()
	local initDebriList = CheatsModel.debrisList
	local function createFunc(idx)
		local item = require("game.Equip.EquipV2.EquipDebrisCellVTwo").new()
		return item:create({
		id = idx,
		viewSize = cc.size(self._rootnode.heroListBg:getContentSize().width, self._rootnode.heroListBg:getContentSize().height * 0.95),
		createDiaoLuoLayer = function(debrisId)
			self:createCollectLayer(debrisId)
		end,
		hechengFunc = function(data)
			self:hechengLayer(data)
		end,
		resType = ResMgr.CHEATS,
		listData = CheatsModel.debrisList
		})
	end
	local refreshFunc = function(cell, idx)
		cell:refresh(idx + 1, CheatsModel.debrisList)
	end
	if self.isFirstDebrisList == nil then
		self.isFirstDebrisList = false
		self.cheatsDebrisList = nil
		self.cheatsDebrisList = require("utility.TableViewExt").new({
		size = self._rootnode.heroListBg:getContentSize(),
		direction = kCCScrollViewDirectionVertical,
		createFunc = createFunc,
		refreshFunc = refreshFunc,
		cellNum = #CheatsModel.debrisList,
		cellSize = require("game.Equip.EquipV2.EquipDebrisCellVTwo").new():getContentSize(),
		scrollFunc = function()
		end
		})
		self.scrollLayerNode:addChild(self.cheatsDebrisList)
	else
		self.cheatsDebrisList:resetCellNum(#CheatsModel.debrisList, false, false)
	end
	self.cheatsTable:setVisible(false)
	self.cheatsDebrisList:setVisible(true)
end

function CheatsList:updateDebriList()
	CheatsModel.getCheatsDebrisList({
	callback = function(listData)
		local ret = false
		local debrisList = listData["1"]
		function comps(a,b)
			local aItem = data_item_item[a.itemId]
			local bItem = data_item_item[b.itemId]
			if aItem == nil or bItem == nil then
				return false
			end
			local scoreA = aItem.quality * 0x00010000 + (0x8f00 - aItem.order)
			local scoreB = bItem.quality * 0x00010000 + (0x8f00 - bItem.order)
			if a.itemCnt >= aItem.para1 then
				scoreA = scoreA + 0x80000000
				ret = true
			end
			if b.itemCnt >= bItem.para1 then
				scoreB = scoreB + 0x80000000
				ret = true
			end
			return scoreA > scoreB
		end
		table.sort(debrisList, comps)
		--[[
		local ret = false
		for k, v in pairs(debrisList) do
			local cut = v.itemCnt
			local itemId = v.itemId
			local limitNum = data_item_item[itemId].para1
			if cut >= limitNum then
				ret = true
				break
			end
		end
		]]
		if ret then
			self._rootnode.tag:setVisible(true)
		else
			self._rootnode.tag:setVisible(false)
			CheatsModel.setCheatsNum(0)
		end
		self:initDebriList()
	end,
	errback = function()
	end
	})
end

function CheatsList:init(data)
	self:resetPos()
	local maxHeroNum = data["3"]
	self:setMaxNum(maxHeroNum)
	self._rootnode.numTag:setZOrder(20)
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onCommonView()
	end,
	CCControlEventTouchUpInside)
	
	--前往闯荡
	self._rootnode.onListGoto:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		GameStateManager:ChangeState(GAME_STATE.STATE_CHUANGDANG)
	end,
	CCControlEventTouchUpInside)
	
	self:updateLabel()
	local function onTabBtn(tag)
		if self.firstTabBtn ~= nil then
			if self.tabId ~= tag then
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
			end
		else
			self.firstTabBtn = false
		end
		if TAB_TAG.MIJI == tag then
			if self.tabId == TAB_TAG.SOUL then
				self.tabId = TAB_TAG.MIJI
				self:sendReq()
			end
			self.extendBtn:setVisible(true)
			self.tujianBtn:setVisible(true)
			self._rootnode.numTag:setVisible(true)
			do
				local function updateTableFunc()
					self.cheatsTable:resetCellNum(#CheatsModel.totalTable, false, false)
				end
				local function resetList()
					self.cheatsTable:resetCellNum(#CheatsModel.totalTable)
					self:setCurNum(#CheatsModel.totalTable)
					if #self.commonList == 0 then
						self._rootnode.noListView:setVisible(true)
					else
						self._rootnode.noListView:setVisible(false)
					end
				end
				
				--秘籍详情
				local function showCheatsInfoLayer(index)
					local offset = self.cheatsTable:getContentOffset()
					local beginNum = self.cheatsTable:getCellNum()
					local layer = require("game.Cheats.CheatsInfoLayer").new({
					id = CheatsModel.totalTable[index].id,
					removeListener = function()
						resetList()
						local endNum = self.cheatsTable:getCellNum()
						local offHeight = require("game.Cheats.CheatsListCell").new():getContentSize().height
						offset.y = offset.y + offHeight * (beginNum - endNum)
						self.cheatsTable:setContentOffset(offset)
						self:reloadBroadcast()
					end
					}, 2)
					game.runningScene:addChild(layer, 1000)
				end
				
				--秘籍研习
				local function showCheatsJinJieLayer(index)
					local offset = self.cheatsTable:getContentOffset()
					local beginNum = self.cheatsTable:getCellNum()
					local jinJieLayer = require("game.Cheats.CheatsJinJie").new({
					id = CheatsModel.totalTable[index].id,
					removeListener = function()
						resetList()
						local endNum = self.cheatsTable:getCellNum()
						local offHeight = require("game.Cheats.CheatsListCell").new():getContentSize().height
						offset.y = offset.y + offHeight * (beginNum - endNum)
						self.cheatsTable:setContentOffset(offset)
						self:reloadBroadcast()
					end
					})
					game.runningScene:addChild(jinJieLayer, 1000)
				end
				
				local function createFunc(idx)
					local item = require("game.Cheats.CheatsListCell").new()
					return item:create({
					index = idx + 1,
					showCheatsInfoLayer = showCheatsInfoLayer,
					showCheatsJinJieLayer = showCheatsJinJieLayer
					})
				end
				
				local refreshFunc = function(cell, idx)
					cell:refresh(idx + 1)
				end
				
				if self.isFirstInitcheatsTable == nil then
					self.isFirstInitcheatsTable = false
					self.cheatsTable = nil
					self.cheatsTable = require("utility.TableViewExt").new({
					size = self._rootnode.heroListBg:getContentSize(),
					direction = kCCScrollViewDirectionVertical,
					createFunc = createFunc,
					refreshFunc = refreshFunc,
					cellNum = #CheatsModel.totalTable,
					cellSize = require("game.Cheats.CheatsListCell").new():getContentSize(),
					scrollFunc = function()
					end
					})
					self.scrollLayerNode:addChild(self.cheatsTable)
				elseif self.isQiangHua == true then
					self.cheatsTable:resetCellNum(#CheatsModel.totalTable, false, false)
				else
					self.cheatsTable:resetCellNum(#CheatsModel.totalTable)
				end
				self:setCurNum(#CheatsModel.totalTable)
			end
		elseif TAB_TAG.SOUL == tag then
			self._rootnode.numTag:setVisible(false)
			self.extendBtn:setVisible(false)
			self.tujianBtn:setVisible(false)
			self._rootnode.noListView:setVisible(false)
			self.tabId = TAB_TAG.SOUL
			self.extendBtn:setVisible(false)
			self:updateDebriList()
		else
			assert(false, "HeroList onTabBtn Tag Error!")
		end
		self._currentTab = tag
	end
	local function initTab()
		CtrlBtnGroupAsMenu({
		self._rootnode.tab1,
		self._rootnode.tab2
		}, onTabBtn)
	end
	if self.isFirst == nil then
		self.isFirst = true
		initTab()
	end
	onTabBtn(self._currentTab)
	self:onCommonView()
	TutoMgr.active()
end

function CheatsList:resetPos()
	local xiedai = self._rootnode.xiedai
	local curNum = self._rootnode.curNum
	local sign = self._rootnode.sign
	local maxNum = self._rootnode.maxNum
	curNum:setPosition(xiedai:getPositionX() + xiedai:getContentSize().width, xiedai:getPositionY())
	sign:setPosition(curNum:getPositionX() + curNum:getContentSize().width, xiedai:getPositionY())
	maxNum:setPosition(sign:getPositionX() + sign:getContentSize().width, xiedai:getPositionY())
end

function CheatsList:setCurNum(num)
	self._rootnode.curNum:setString(num)
	self:resetPos()
end

function CheatsList:setMaxNum(num)
	self._rootnode.maxNum:setString(num)
	self:resetPos()
end

function CheatsList:onCommonView()
	self.viewType = COMMON_VIEW
	self._rootnode.tab1:setVisible(true)
	self._rootnode.tab2:setVisible(true)
	self._rootnode.tab3:setVisible(false)
	self:checkHasDot()
	self._rootnode.expandBtn:setVisible(true)
	self._rootnode.backBtn:setVisible(false)
	self._rootnode.numTag:setVisible(true)
	self._rootnode.bottomNode:setVisible(true)
	self:refreshCommonList()
end

function CheatsList:refreshCommonList()
	self.commonList = CheatsModel.totalTable
	self.cheatsTable:setVisible(true)
	if #self.commonList == 0 then
		self._rootnode.noListView:setVisible(true)
	else
		self._rootnode.noListView:setVisible(false)
	end
	if self.cheatsDebrisList ~= nil then
		self.cheatsDebrisList:setVisible(false)
	end
	self.cheatsTable:resetListByNumChange(#self.commonList)
end

function CheatsList:reloadBroadcast()
	local broadcastBg = self._rootnode.broadcast_tag
	game.broadcast:reSet(broadcastBg)
end

function CheatsList:checkHasDot()
	if CheatsModel.getCheatsNum() > 0 then
		self._rootnode.tag:setVisible(true)
	else
		self._rootnode.tag:setVisible(false)
	end
end

function CheatsList:updateLabel()
	self._rootnode.goldLabel:setString(game.player:getGold())
	self._rootnode.silverLabel:setString(game.player:getSilver())
end

function CheatsList:onEnter()
	game.runningScene = self
	CheatsList.super.onEnter(self)
	--self:regNotice()
	if self._bExit then
		self._bExit = false
		self:reloadBroadcast()
	end
	if self.isActive ~= nil then
		ResMgr.createBefTutoMask(self)
		TutoMgr.active()
	else
		self.isActive = true
	end
end

function CheatsList:onExit()
	self._bExit = true
	--self:unregNotice()
	CheatsList.super.onExit(self)
end

return CheatsList