local data_item_item = require("data.data_item_item")

local BaseScene = require("game.BaseScene")
local HeroList = class("HeroList", BaseScene)

local TAB_TAG = {XIAKE = 1, SOUL = 2}
local COMMON_VIEW = 1
local SALE_VIEW = 2
local LISTVIEW_TAG = 100

function HeroList:SendReq()
	RequestHelper.getHeroList({
	callback = function(data)
		self._cost = {
		data["4"],
		data["5"]
		}
		self:init(data)
		if offset ~= nil then
		end
	end
	})
end

function HeroList:resetPos()
	local xiedai = self._rootnode.xiedai
	local curNum = self._rootnode.curNum
	local sign = self._rootnode.sign
	local maxNum = self._rootnode.maxNum
	curNum:setPosition(xiedai:getPositionX() + xiedai:getContentSize().width, xiedai:getPositionY())
	sign:setPosition(curNum:getPositionX() + curNum:getContentSize().width, xiedai:getPositionY())
	maxNum:setPosition(sign:getPositionX() + sign:getContentSize().width, xiedai:getPositionY())
end

function HeroList:setCurNum(num)
	self._rootnode.curNum:setString(num)
	self:resetPos()
end

function HeroList:setMaxNum(num)
	self._rootnode.maxNum:setString(num)
	self:resetPos()
end

function HeroList:onSaleView()
	self.sellTable = {}
	self.sellIndex = {}
	self.viewType = SALE_VIEW
	self._rootnode.tab1:setVisible(false)
	self._rootnode.tab2:setVisible(false)
	self._rootnode.tab3:setVisible(false)
	self._rootnode.tag:setVisible(false)
	self._rootnode.expandBtn:setVisible(false)
	self._rootnode.sellBtn:setVisible(false)
	self._rootnode.sellStarBtn:setVisible(true)
	self._rootnode.backBtn:setVisible(true)
	self._rootnode.sell_title:setVisible(true)
	self.sellFrame:setVisible(true)
	self._rootnode.numTag:setVisible(false)
	self._rootnode.bottomNode:setVisible(false)
	self:refreshSellAbleList()
	self.sellMoney = 0
	self.sellFrame:setRightNum(0)
	self.sellFrame:setLeftNum(0)
end

function HeroList:onCommonView()
	self.viewType = COMMON_VIEW
	self._rootnode.tab1:setVisible(true)
	self._rootnode.tab2:setVisible(true)
	self._rootnode.tab3:setVisible(false)
	self:checkHasDot()
	self._rootnode.expandBtn:setVisible(true)
	self._rootnode.sellBtn:setVisible(true)
	self._rootnode.sellStarBtn:setVisible(false)
	self._rootnode.backBtn:setVisible(false)
	self._rootnode.sell_title:setVisible(false)
	self.sellFrame:setVisible(false)
	self._rootnode.numTag:setVisible(true)
	self._rootnode.bottomNode:setVisible(true)
	self:refreshCommonList()
end

function HeroList:refreshCommonList()
	self.commonList = HeroModel.totalTable
	self.heroTable:setVisible(true)
	self.sellHeroTable:setVisible(false)
	if self.heroDebrisList ~= nil then
		self.heroDebrisList:setVisible(false)
	end
	self.heroTable:resetListByNumChange(#self.commonList)
end

function HeroList:refreshSellAbleList()
	self.heroTable:setVisible(false)
	self.sellHeroTable:setVisible(true)
	if self.heroDebrisList ~= nil then
		self.heroDebrisList:setVisible(false)
	end
	self.sellList = HeroModel.getSellAbleTable()
	self.sellHeroTable:resetCellNum(#self.sellList, false, false)
end

function HeroList:init(data)
	self.sellTable = {}
	self:resetPos()
	HeroModel.setHeroTable(data["1"])
	self.sellList = HeroModel.getSellAbleTable()
	local maxHeroNum = data["3"]
	self:setMaxNum(maxHeroNum)
	local sellBtn = self._rootnode.sellBtn
	local boardBg = self._rootnode.heroListBg
	local numTag = self._rootnode.numTag
	numTag:setZOrder(20)
	
	--出售
	self._rootnode.sellBtn:addHandleOfControlEvent(function(sender,eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:onSaleView()
	end,
	CCControlEventTouchUpInside)
	
	--返回
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender,eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onCommonView()
	end,
	CCControlEventTouchUpInside)
	
	self:updateLabel()
	local function updateDebriList()
		RequestHelper.getHeroDebrisList({
		callback = function(listData)
			HeroModel.debrisData = listData["1"]
			local ret = false
			function sort(a,b)
				local aItem = data_item_item[a.itemId]
				local bItem = data_item_item[b.itemId]
				local scoreA = aItem.quality * 0x00010000
				local scoreB = bItem.quality * 0x00010000
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
			table.sort(HeroModel.debrisData, sort)
			
			if ret then
				self._rootnode.tag:setVisible(true)
			else
				self._rootnode.tag:setVisible(false)
				game.player:setXiakeNum(0)
			end
			
			local function createCollectLayer(debrisId)
				local collectLayer = require("game.Hero.CollectLayer").new(debrisId)
				self:addChild(collectLayer, 103)
			end
			local function hechengLayer(hechengData)
				RequestHelper.sendHeChengHeroRes({
				callback = function(listData)
					if listData["5"] == true then
						ResMgr.showMsg(2)
					elseif string.len(listData["0"]) > 0 then
						CCMessageBox(listData["0"], "Tip")
					else
						do
							local isFull = listData["3"] or false
							if not isFull then
								self.upDebrisFunc()
								show_tip_label(common:getLanguageString("@HeroCompoundSucceed"))
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
			local function createFunc(idx)
				local item = require("game.Hero.HeroDebrisCell").new()
				return item:create({
				id = idx,
				viewSize = cc.size(boardBg:getContentSize().width, boardBg:getContentSize().height * 0.95),
				createDiaoLuoLayer = createCollectLayer,
				hechengFunc = hechengLayer
				})
			end
			
			local refreshFunc = function(cell, idx)
				cell:refresh(idx + 1)
			end
			if self.isFirstDebrisList == nil then
				self.isFirstDebrisList = false
				self.heroDebrisList = nil
				local itemList = require("utility.TableViewExt").new({
				size = self._rootnode.heroListBg:getContentSize(),
				direction = kCCScrollViewDirectionVertical,
				createFunc = createFunc,
				refreshFunc = refreshFunc,
				cellNum = #HeroModel.debrisData,
				cellSize = require("game.Hero.HeroDebrisCell").new():getContentSize(),
				scrollFunc = function()
				end
				})
				self.heroDebrisList = itemList
				self.scrollLayerNode:addChild(itemList)
			else
				self.heroDebrisList:resetCellNum(#HeroModel.debrisData, false, false)
			end
			self:setCurNum(#HeroModel.debrisData)
			self.heroTable:setVisible(false)
			self.heroDebrisList:setVisible(true)
			self.sellHeroTable:setVisible(false)
		end
		})
	end
	self.upDebrisFunc = updateDebriList
	self.sellMoney = 0
	local function changeSoldMoney(num)
		if self.sellMoney + num >= 0 then
			self.sellMoney = self.sellMoney + num
			self.sellFrame:setRightNum(self.sellMoney)
		end
	end
	local function addSellItemFunc(itemId, index)
		self.sellIndex[index] = true
		self.sellTable[#self.sellTable + 1] = itemId
		self.sellFrame:setLeftNum(#self.sellTable)
	end
	local function removeSellItemFunc(itemId, index)
		self.sellIndex[index] = false
		for i = 1, #self.sellTable do
			if self.sellTable[i] == itemId then
				table.remove(self.sellTable, i)
			end
		end
		self.sellFrame:setLeftNum(#self.sellTable)
	end
	
	local function clearSellData()
		self.sellList = HeroModel.getSellAbleTable()
		for i = 1, #self.sellTable do
			local j = 1
			while j <= #self.commonList do
				if self.sellTable[i] == self.commonList[j]._id then
					table.remove(self.commonList, j)
				else
					j = j + 1
				end
			end
			--[[
			for j = 1, #self.commonList do
				if self.sellTable[i] == self.commonList[j]._id then
					table.remove(self.commonList, j)
					break
				end
			end
			]]
		end
		HeroModel.totalTable = self.commonList
		self.sellList = HeroModel.getSellAbleTable()
		self.sellIndex = {}
		self:refreshSellAbleList()
		self.sellMoney = 0
		self.sellTable = {}
		self.sellFrame:setRightNum(0)
		self.sellFrame:setLeftNum(0)
		self:setCurNum(#self.commonList)
	end
	local function sellFunc()
		local sellStr = ""
		if #self.sellTable == 0 then
			ResMgr.showErr(200023)
		else
			for i = 1, #self.sellTable do
				if #sellStr ~= 0 then
					sellStr = sellStr .. "," .. self.sellTable[i]
				else
					sellStr = sellStr .. self.sellTable[i]
				end
			end
			RequestHelper.sendSellCardRes({
			callback = function(data)
				clearSellData()
				show_tip_label(common:getLanguageString("@HeroSellSucceed") .. data["1"][1] .. common:getLanguageString("@SilverLabel"))
				game.player.m_silver = data["1"][2]
				self._rootnode.silverLabel:setString(data["1"][2])
				PostNotice(NoticeKey.MainMenuScene_Update)
				PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			end,
			ids = sellStr
			})
		end
	end
	self.sellFunc = sellFunc
	local function onTabBtn(tag)
		if self.firstTabBtn ~= nil then
			if self.tabId ~= tag then
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
			end
		else
			self.firstTabBtn = false
		end
		if TAB_TAG.XIAKE == tag then
			if self.tabId == 2 then
				self.tabId = 1
				--PageMemoModel.clear("equipTable")
				--PageMemoModel.clear("equipSellTable")
				self:SendReq()
			end
			sellBtn:setVisible(true)
			self.extendBtn:setVisible(true)
			self._rootnode.numTag:setVisible(true)
			do
				local function updateTableFunc()
					self.heroTable:resetCellNum(#HeroModel.totalTable, false, false)
				end
				local function resetList()
					self.heroTable:resetCellNum(#HeroModel.totalTable)
					self.sellHeroTable:resetCellNum(#self.sellList)
					self:setCurNum(#HeroModel.totalTable)
				end
				local function createJinjieLayer(objId, index, closeListener)
					local offset = self.heroTable:getContentOffset()
					local beginNum = self.heroTable:getCellNum()
					local jinJieLayer = require("game.Hero.HeroJinJie").new({
					incomeType = 1,
					listInfo = {
					id = objId,
					updateTableFunc = updateTableFunc,
					listData = HeroModel.totalTable,
					cellIndex = index,
					heroTable = self.heroTable,
					resetList = resetList,
					upNumFunc = function(num)
						self:setCurNum(num)
					end
					},
					removeListener = function()
						resetList()
						if closeListener then
							closeListener()
						end
						local endNum = self.heroTable:getCellNum()
						local offHeight = require("game.Hero.HeroListCell").new():getContentSize().height
						offset.y = offset.y + offHeight * (beginNum - endNum)
						self.heroTable:setContentOffset(offset)
						self:SendReq()
						self:reloadBroadcast()
					end
					})
					game.runningScene:addChild(jinJieLayer, 1000)
				end
				local function createQiangHuaLayer(objId, index, closeListener)
					local offset = self.heroTable:getContentOffset()
					local beginNum = self.heroTable:getCellNum()
					local qianghuaLayer = require("game.Hero.HeroQiangHuaLayer").new({
					id = objId,
					listData = HeroModel.totalTable,
					visibleBg = boardBg,
					tableView = self.heroTable,
					index = index,
					resetList = resetList,
					upNumFunc = function(num)
						self:setCurNum(num)
					end,
					removeListener = function(isQiangHua)
						self:reloadBroadcast()
						if closeListener then
							closeListener()
						end
						local endNum = self.heroTable:getCellNum()
						local offHeight = require("game.Hero.HeroListCell").new():getContentSize().height
						offset.y = offset.y + offHeight * (beginNum - endNum)
						self.isQiangHua = isQiangHua
						--dump("dumdddd")
						--dump(self.isQiangHua)
						self:SendReq(offset)
						self:reloadBroadcast()
						if isQiangHua == true then
							self.heroTable:setContentOffset(offset)
						end
					end
					})
					game.runningScene:addChild(qianghuaLayer, 1000)
				end
				local function onHeroInfoLayer(index)
					if self.viewType == SALE_VIEW then
						local cellData = self.sellList[index]
						local itemInfo = require("game.Huodong.ItemInformation").new({
						id = cellData.resId,
						type = 8
						})
						display.getRunningScene():addChild(itemInfo, 100000)
					else
						do
							local offset = self.heroTable:getContentOffset()
							local layer = require("game.Hero.HeroInfoLayer").new({
							info = {
							resId = HeroModel.totalTable[index].resId,
							levelLimit = 8888,
							objId = HeroModel.totalTable[index]._id
							},
							cellIndex = index,
							createJinjieLayer = createJinjieLayer,
							createQiangHuaLayer = createQiangHuaLayer,
							removeListener = function()
								self:updateLabel()
								self.heroTable:reloadData()
								self.heroTable:setContentOffset(offset)
							end
							}, 2)
							game.runningScene:addChild(layer, 1000)
						end
					end
				end
				local function createFunc(idx)
					local item = require("game.Hero.HeroListCell").new()
					return item:create({
					id = idx,
					viewSize = cc.size(self:getContentSize().width, self:getContentSize().height * 0.95),
					listData = HeroModel.totalTable,
					saleData = self.sellList,
					viewType = SALE_VIEW,
					choseTable = self.sellTable,
					changeSoldMoney = changeSoldMoney,
					addSellItem = addSellItemFunc,
					removeSellItem = removeSellItemFunc,
					createJinjieListenr = createJinjieLayer,
					createQiangHuaListener = createQiangHuaLayer,
					onHeadIcon = onHeroInfoLayer,
					isSel = self.sellIndex[idx + 1]
					})
				end
				
				local function createHeroFunc(idx)
					local item = require("game.Hero.HeroListCell").new()
					return item:create({
					id = idx,
					viewSize = cc.size(self:getContentSize().width, self:getContentSize().height * 0.95),
					listData = HeroModel.totalTable,
					saleData = self.sellList,
					viewType = COMMON_VIEW,
					choseTable = self.sellTable,
					changeSoldMoney = changeSoldMoney,
					addSellItem = addSellItemFunc,
					removeSellItem = removeSellItemFunc,
					createJinjieListenr = createJinjieLayer,
					createQiangHuaListener = createQiangHuaLayer,
					onHeadIcon = onHeroInfoLayer,
					isSel = self.sellIndex[idx + 1]
					})
				end
				
				local function refreshFunc(cell, idx)
					cell:refresh(idx, COMMON_VIEW, self.sellIndex[idx + 1])
				end
				
				local function refreshSellFunc(cell, idx)
					cell:refresh(idx, SALE_VIEW, self.sellIndex[idx + 1])
				end
				
				self.sellList = HeroModel.getSellAbleTable()
				if self.isFirstInitHeroTable == nil then
					self.isFirstInitHeroTable = false
					self.heroTable = nil
					self.sellHeroTable = nil
					--侠客列表
					self.heroTable = require("utility.TableViewExt").new({
					size = self._rootnode.heroListBg:getContentSize(),
					direction = kCCScrollViewDirectionVertical,
					createFunc = createHeroFunc,
					refreshFunc = refreshFunc,
					cellNum = #HeroModel.totalTable,
					cellSize = require("game.Hero.HeroListCell").new():getContentSize(),
					scrollFunc = function()
					end
					})
					--卖出列表
					self.sellHeroTable = require("utility.TableViewExt").new({
					size = self._rootnode.heroListBg:getContentSize(),
					direction = kCCScrollViewDirectionVertical,
					createFunc = createFunc,
					refreshFunc = refreshSellFunc,
					cellNum = #self.sellList,
					cellSize = require("game.Hero.HeroListCell").new():getContentSize(),
					scrollFunc = function()
					end
					})
					self.scrollLayerNode:addChild(self.heroTable)
					self.scrollLayerNode:addChild(self.sellHeroTable)
					self.sellHeroTable:setVisible(false)
				else
					if self.isQiangHua == true then
						self.heroTable:resetCellNum(#HeroModel.totalTable, false, false)
					else
						self.heroTable:resetCellNum(#HeroModel.totalTable)
					end
					self.sellHeroTable:resetCellNum(#self.sellList)
				end
				self:setCurNum(#HeroModel.totalTable)
				local cell = self.heroTable:cellAtIndex(0)
				if cell ~= nil then
					self.jinjieBtn = cell:getJinjieBtn()
					self.headBtn = cell:getHeadIcon()
					TutoMgr.addBtn("herolist_zhujue_jinjie_btn", self.jinjieBtn)
					TutoMgr.addBtn("herolist_zhujue_head_btn", self.headBtn)
					TutoMgr.active()
				end
			end
		elseif TAB_TAG.SOUL == tag then
			self._rootnode.numTag:setVisible(false)
			sellBtn:setVisible(false)
			self.extendBtn:setVisible(false)
			local function createCollectLayer()
				local collectLayer = require("game.Hero.CollectLayer").new()
				self:addChild(collectLayer, 103)
			end
			self.tabId = 2
			self.extendBtn:setVisible(false)
			sellBtn:setVisible(false)
			updateDebriList()
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
	--TutoMgr.addBtn("herolist_zhujue_jinjie_btn", self.jinjieBtn)
	--TutoMgr.addBtn("herolist_zhujue_head_btn", self.headBtn)
	--TutoMgr.active()
end

function HeroList:ctor(tag)
	game.runningScene = self
	HeroList.super.ctor(self, {
	contentFile = "hero/hero_list_bg.ccbi",
	subTopFile = "hero/hero_up_tab.ccbi"
	})
	
	ResMgr.createBefTutoMask(self)
	if tag == nil or tag < 0 or tag > 2 then
		self._currentTab = TAB_TAG.XIAKE
	else
		self._currentTab = tag
	end
	self:setNodeEventEnabled(true)
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_main_menu.plist", "ui/ui_main_menu.pvr.ccz")
	self.viewType = COMMON_VIEW
	self._rootnode.tag:setPositionX(display.width * 0.5)
	self._rootnode.tag:setZOrder(1000)
	self:checkHasDot()
	local iconSprite = display.newSprite("#mm_silver.png")
	self.sellFunc = nil
	self.sellFrame = require("utility.SellFrame").new({
	leftTitle = common:getLanguageString("@Selected"),
	rightTitle = common:getLanguageString("@TotalSell"),
	icon = iconSprite,
	sellFunc = function()
		self.sellFunc()
	end
	})
	self:addChild(self.sellFrame, 1)
	self.extendBtn = self._rootnode.expandBtn
	local function extend(...)
		RequestHelper.extendBag({
		type = 8,
		callback = function(data)
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
				ResMgr.showErr(200025)
				PostNotice(NoticeKey.MainMenuScene_Update)
			else
				CCMessageBox(data["0"], "Error")
			end
		end
		})
	end
	
	--扩展
	self._rootnode.expandBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._cost[1] ~= -1 then
			local layer = require("utility.CostTipMsgBox").new({
			tip = common:getLanguageString("@OpenLocation", self._cost[2]),
			listener = function()
				if game.player.m_gold >= self._cost[1] then
					extend()
				else
					ResMgr.showErr(2300007)
				end
			end,
			cost = self._cost[1]
			})
			self:addChild(layer, 100)
		else
			ResMgr.showErr(200024)
		end
	end,
	CCControlEventTouchUpInside)
	
	local function quickChoseFunc(selTable)
		for i = 1, #selTable do
			if selTable[i] == true then
				for j = 1, #self.sellList do
					if self.sellList[j].star == i then
						self.sellIndex[j] = true
						local isExist = false
						for k = 1, #self.sellTable do
							if self.sellTable[k] == self.sellList[j]._id then
								isExist = true
								break
							end
						end
						if isExist ~= true then
							self.sellTable[#self.sellTable + 1] = self.sellList[j]._id
						end
					end
				end
			end
		end
		local num = 0
		local curMoney = 0
		for k, v in pairs(self.sellIndex) do
			if v == true then
				num = num + 1
				curMoney = curMoney + ResMgr.getCardData(self.sellList[k].resId).price
			end
		end
		self.sellFrame:setRightNum(curMoney)
		self.sellFrame:setLeftNum(num)
		self.sellHeroTable:resetCellNum(#self.sellList, false, false)
	end
	
	--按星级出售
	self._rootnode.sellStarBtn:addHandleOfControlEvent(function(eventName, sender)
		self._rootnode.sellStarBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local small = CCScaleTo:create(0.1, 0.8)
		local bigger = CCScaleTo:create(0.1, 1)
		self._rootnode.sellStarBtn:runAction(transition.sequence({small, bigger}))
		local heroQuickSel = require("game.Hero.HeroQuickChose").new(quickChoseFunc, function()
			self._rootnode.sellStarBtn:setEnabled(true)
		end)
		display:getRunningScene():addChild(heroQuickSel, 10)
	end,
	CCControlEventTouchUpInside)
	
	self.listView = self._rootnode.listView
	self.scrollLayerNode = display.newNode()
	self.listView:addChild(self.scrollLayerNode)
	self.commonList = {}
	self.sellList = {}
	self.sellIndex = {}
	self:SendReq()
	self._bExit = false
	self._rootnode.tab3:setVisible(false)
end

function HeroList:reloadBroadcast()
	local broadcastBg = self._rootnode.broadcast_tag
	game.broadcast:reSet(broadcastBg)
end

function HeroList:checkHasDot()
	if game.player:getXiakeNum() > 0 then
		self._rootnode.tag:setVisible(true)
	else
		self._rootnode.tag:setVisible(false)
	end
end

function HeroList:updateLabel()
	self._rootnode.goldLabel:setString(game.player:getGold())
	self._rootnode.silverLabel:setString(game.player:getSilver())
end

function HeroList:onEnter()
	game.runningScene = self
	HeroList.super.onEnter(self)
	
	TutoMgr.addBtn("zhujiemian_btn_shouye", self._rootnode.mainSceneBtn)
	TutoMgr.addBtn("zhujiemian_btn_zhenrong", self._rootnode.formSettingBtn)
	TutoMgr.addBtn("zhenrong_btn_fuben", self._rootnode.battleBtn)
	TutoMgr.addBtn("zhujiemian_btn_huodong", self._rootnode.activityBtn)
	TutoMgr.addBtn("zhujiemian_btn_beibao", self._rootnode.bagBtn)
	TutoMgr.addBtn("zhujiemian_btn_shangcheng", self._rootnode.shopBtn)
	
	if self.isActive ~= nil then
		ResMgr.createBefTutoMask(self)
		TutoMgr.active()
	else
		self.isActive = true
	end
end

function HeroList:onExit()
	self._bExit = true
	HeroList.super.onExit(self)
	TutoMgr.removeBtn("herolist_zhujue_jinjie_btn")
	TutoMgr.removeBtn("herolist_zhujue_head_btn")
	TutoMgr.removeBtn("zhujiemian_btn_shouye")
	TutoMgr.removeBtn("zhujiemian_btn_zhenrong")
	TutoMgr.removeBtn("zhujiemian_btn_huodong")
	TutoMgr.removeBtn("zhujiemian_btn_beibao")
	TutoMgr.removeBtn("zhujiemian_btn_shangcheng")
end

return HeroList