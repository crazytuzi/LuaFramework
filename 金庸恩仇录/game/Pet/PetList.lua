local data_item_item = require("data.data_item_item")

local BaseScene = require("game.BaseScene")
local PetList = class("PetList", BaseScene)

local TAB_TAG = {XIAKE = 1, SOUL = 2}
local COMMON_VIEW = 1
local SALE_VIEW = 2
local LISTVIEW_TAG = 100

function PetList:SendReq()
	RequestHelper.getPetList({
	callback = function(data)
		local a = data
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

function PetList:virtualData()
	local data = {}
	data[1] = {
	resId = 10001,
	pos = 0,
	cls = 3,
	level = 40,
	lock = 0,
	battle = {}
	}
	data[2] = {
	resId = 10002,
	pos = 0,
	cls = 2,
	level = 11,
	lock = 0,
	battle = {}
	}
	data[3] = {
	resId = 10003,
	pos = 0,
	cls = 3,
	level = 33,
	lock = 0,
	battle = {}
	}
	data[4] = {
	resId = 10004,
	pos = 0,
	cls = 0,
	level = 51,
	lock = 0,
	battle = {}
	}
	data[5] = {
	resId = 10005,
	pos = 0,
	cls = 0,
	level = 13,
	lock = 0,
	battle = {}
	}
	data[6] = {
	resId = 10006,
	pos = 0,
	cls = 0,
	level = 22,
	lock = 0,
	battle = {}
	}
	data[7] = {
	resId = 10007,
	pos = 0,
	cls = 2,
	level = 50,
	lock = 0,
	battle = {}
	}
	local result = {}
	result["1"] = data
	result["3"] = 30
	return result
end

function PetList:resetPos()
	local xiedai = self._rootnode.xiedai
	local curNum = self._rootnode.curNum
	local sign = self._rootnode.sign
	local maxNum = self._rootnode.maxNum
	curNum:setPosition(xiedai:getPositionX() + xiedai:getContentSize().width, xiedai:getPositionY())
	sign:setPosition(curNum:getPositionX() + curNum:getContentSize().width, xiedai:getPositionY())
	maxNum:setPosition(sign:getPositionX() + sign:getContentSize().width, xiedai:getPositionY())
end

function PetList:setCurNum(num)
	self._rootnode.curNum:setString(num)
	self:resetPos()
end

function PetList:setMaxNum(num)
	self._rootnode.maxNum:setString(num)
	self:resetPos()
end

function PetList:onSaleView()
	self.sellTable = {}
	self.sellIndex = {}
	self.viewType = SALE_VIEW
	self._rootnode.tab1:setVisible(false)
	self._rootnode.tab2:setVisible(false)
	self._rootnode.tag:setVisible(false)
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

function PetList:onCommonView()
	self.viewType = COMMON_VIEW
	self._rootnode.tab1:setVisible(true)
	self._rootnode.tab2:setVisible(true)
	self:checkHasDot()
	self._rootnode.sellBtn:setVisible(false)
	self._rootnode.sellStarBtn:setVisible(false)
	self._rootnode.backBtn:setVisible(false)
	self._rootnode.sell_title:setVisible(false)
	self.sellFrame:setVisible(false)
	self._rootnode.numTag:setVisible(true)
	self._rootnode.bottomNode:setVisible(true)
	self:refreshCommonList()
end

function PetList:refreshCommonList()
	self.commonList = PetModel.totalTable
	self.heroTable:setVisible(true)
	self.sellHeroTable:setVisible(false)
	if self.heroDebrisList ~= nil then
		self.heroDebrisList:setVisible(false)
	end
	self.heroTable:resetListByNumChange(#self.commonList)
end

function PetList:refreshSellAbleList()
	self.heroTable:setVisible(false)
	self.sellHeroTable:setVisible(true)
	if self.heroDebrisList ~= nil then
		self.heroDebrisList:setVisible(false)
	end
	self.sellList = PetModel.getSellAbleTable()
	self.sellHeroTable:resetCellNum(#self.sellList, false, false)
end

function PetList:updateDebriList()
	if self.hasGotPetDebrisList then
		self.heroTable:setVisible(false)
		self.heroDebrisList:setVisible(true)
		self.sellHeroTable:setVisible(false)
		return
	end
	local boardBg = self._rootnode.heroListBg
	RequestHelper.getPetDebrisList({
	callback = function(listData)
		local debrisList = listData["1"]
		PetModel.setPetDebrisData(debrisList)
		self.hasGotPetDebrisList = true
		local ret = false
		function comps(a,b)
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
		table.sort(debrisList, comps)
		for k, v in pairs(debrisList) do
			local cut = v.itemCnt
			local itemId = v.itemId
			local limitNum = data_item_item[itemId].para1
			if cut >= limitNum then
				ret = true
			end
		end
		if ret then
			self._rootnode.tag:setVisible(true)
		else
			self._rootnode.tag:setVisible(false)
			game.player:setPetNum(0)
		end
		local function createCollectLayer(debrisId)
			local collectLayer = require("game.Hero.CollectLayer").new(debrisId, ResMgr.PET)
			self:addChild(collectLayer, 103)
		end
		local function hechengLayer(hechengData)
			RequestHelper.sendHeChengHeroRes({
			callback = function(listData)
				if listData["5"] == true then
					ResMgr.showMsg(34)
				elseif string.len(listData["0"]) > 0 then
					CCMessageBox(listData["0"], "Tip")
				else
					do
						local isFull = listData["3"] or false
						if not isFull then
							local tips = common:getLanguageString("@pet") .. common:getLanguageString("@composeSuc")
							show_tip_label(tips)
							PetModel.updatePetDebrisData(hechengData.id, 0 - hechengData.num)
							local petDebrisList = PetModel.getPetDebrisData()
							self.heroDebrisList:resetCellNum(#petDebrisList, false, false)
							local boo = false
							for k, v in pairs(petDebrisList) do
								local cut = v.itemCnt
								local itemId = v.itemId
								local limitNum = data_item_item[itemId].para1
								if cut >= limitNum then
									boo = true
									break
								end
							end
							if boo then
								self._rootnode.tag:setVisible(true)
							else
								self._rootnode.tag:setVisible(false)
								game.player:setPetNum(0)
							end
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
									}), 99999)
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
			local item = require("game.Pet.PetDebrisCell").new()
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
		local petDebrisList = PetModel.getPetDebrisData()
		if self.isFirstDebrisList == nil then
			self.isFirstDebrisList = false
			self.heroDebrisList = nil
			local itemList = require("utility.TableViewExt").new({
			size = self._rootnode.heroListBg:getContentSize(),
			direction = kCCScrollViewDirectionVertical,
			createFunc = createFunc,
			refreshFunc = refreshFunc,
			cellNum = #petDebrisList,
			cellSize = require("game.Pet.PetDebrisCell").new():getContentSize(),
			scrollFunc = function()
			end
			})
			self.heroDebrisList = itemList
			self.scrollLayerNode:addChild(itemList)
		else
			self.heroDebrisList:resetCellNum(#petDebrisList, false, false)
		end
		self:setCurNum(#debrisList)
		self.heroTable:setVisible(false)
		self.heroDebrisList:setVisible(true)
		self.sellHeroTable:setVisible(false)
	end
	})
end

function PetList:init(data)
	self.sellTable = {}
	local petData = data["1"]
	local a = #petData
	PetModel.setPetTable(petData)
	self.sellList = PetModel.getSellAbleTable()
	local maxHeroNum = data["3"]
	self:setMaxNum(maxHeroNum)
	local numTag = self._rootnode.numTag
	numTag:setZOrder(20)
	
	--卖出
	self._rootnode.sellBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:onSaleView()
	end,
	CCControlEventTouchUpInside)
	
	--返回
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onCommonView()
	end,
	CCControlEventTouchUpInside)
	
	self:updateLabel()
	self.sellMoney = 0
	local function clearSellData()
		self.sellList = PetModel.getSellAbleTable()
		for i = 1, #self.sellTable do
			for j = 1, #self.commonList do
				if self.sellTable[i] == self.commonList[j]._id then
					table.remove(self.commonList, j)
					break
				end
			end
		end
		PetModel.totalTable = self.commonList
		self.sellList = PetModel.getSellAbleTable()
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
			RequestHelper.sendSellPetRes({
			callback = function(data)
				clearSellData()
				local a = data
				show_tip_label(common:getLanguageString("@HeroSellSucceed") .. data.show .. common:getLanguageString("@SilverLabel"))
				game.player.m_silver = data.silver
				self._rootnode.silverLabel:setString(data.silver)
				PostNotice(NoticeKey.MainMenuScene_Update)
				PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			end,
			ids = sellStr
			})
		end
	end
	self.sellFunc = sellFunc
	local function initTab()
		CtrlBtnGroupAsMenu({
		self._rootnode.tab1,
		self._rootnode.tab2
		}, function(idx)
			self:onTabBtn(idx)
		end)
	end
	if self.isFirst == nil then
		self.isFirst = true
		initTab()
	end
	self:onTabBtn(self._currentTab)
	self:onCommonView()
	TutoMgr.addBtn("herolist_zhujue_jinjie_btn", self.jinjieBtn)
	TutoMgr.addBtn("herolist_zhujue_head_btn", self.headBtn)
	TutoMgr.active()
end

function PetList:onTabBtn(tag)
	if self.firstTabBtn ~= nil then
		if self.tabId ~= tag then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		end
	else
		self.firstTabBtn = false
	end
	local sellBtn = self._rootnode.sellBtn
	local boardBg = self._rootnode.heroListBg
	if TAB_TAG.XIAKE == tag then
		if self.tabId == 2 then
			self.tabId = 1
			self:SendReq()
		end
		sellBtn:setVisible(true)
		self._rootnode.numTag:setVisible(true)
		do
			
			local function updateTableFunc()
				self.heroTable:resetCellNum(#PetModel.totalTable, false, false)
			end
			
			local function resetList()
				self.heroTable:resetCellNum(#PetModel.totalTable)
				self.sellHeroTable:resetCellNum(#self.sellList)
				self:setCurNum(#PetModel.totalTable)
			end
			
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
			
			local function createJinjieLayer(objId, index, closeListener)
				local offset = self.heroTable:getContentOffset()
				local beginNum = self.heroTable:getCellNum()
				local jinJieLayer = require("game.Pet.PetJinJie").new({
				incomeType = 1,
				listInfo = {
				id = objId,
				updateTableFunc = updateTableFunc,
				listData = PetModel.totalTable,
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
					local offHeight = require("game.Pet.PetListCell").new():getContentSize().height
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
				local qianghuaLayer = require("game.Pet.PetQiangHuaLayer").new({
				id = objId,
				listData = PetModel.totalTable,
				index = index,
				resetList = resetList,
				removeListener = function(isQiangHua)
					self:reloadBroadcast()
					if closeListener then
						closeListener()
					end
					local endNum = self.heroTable:getCellNum()
					local offHeight = require("game.Pet.PetListCell").new():getContentSize().height
					offset.y = offset.y + offHeight * (beginNum - endNum)
					self.isQiangHua = isQiangHua
					dump("dumdddd")
					dump(self.isQiangHua)
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
					type = 14
					})
					display.getRunningScene():addChild(itemInfo, 1000)
				else
					do
						local beginNum = self.heroTable:getCellNum()
						local offset = self.heroTable:getContentOffset()
						local layer = require("game.Pet.PetInfoLayer").new({
						cellIndex = index,
						createJinjieLayer = createJinjieLayer,
						createQiangHuaLayer = createQiangHuaLayer,
						removeListener = function()
							self:updateLabel()
							self.heroTable:reloadData()
							local endNum = self.heroTable:getCellNum()
							local offHeight = require("game.Pet.PetListCell").new():getContentSize().height
							offset.y = offset.y + offHeight * (beginNum - endNum)
							self:reloadBroadcast()
							self.heroTable:setContentOffset(offset)
						end
						}, 2)
						game.runningScene:addChild(layer, 1000)
					end
				end
			end
			
			local function createFunc(idx)
				local item = require("game.Pet.PetListCell").new()
				return item:create({
				id = idx,
				viewSize = cc.size(self:getContentSize().width, self:getContentSize().height * 0.95),
				listData = PetModel.totalTable,
				saleData = self.sellList,
				viewType = self.viewType,
				choseTable = self.sellTable,
				changeSoldMoney = changeSoldMoney,
				addSellItem = addSellItemFunc,
				removeSellItem = removeSellItemFunc,
				createJinjieListenr = createJinjieLayer,
				createQiangHuaListener = createQiangHuaLayer,
				onHeadIcon = onHeroInfoLayer
				})
			end
			local function refreshFunc(cell, idx)
				cell:refresh(idx, COMMON_VIEW, self.sellIndex[idx + 1])
			end
			local function refreshSellFunc(cell, idx)
				cell:refresh(idx, SALE_VIEW, self.sellIndex[idx + 1])
			end
			self.sellList = PetModel.getSellAbleTable()
			if self.isFirstInitHeroTable == nil then
				self.isFirstInitHeroTable = false
				self.heroTable = nil
				self.sellHeroTable = nil
				self.heroTable = require("utility.TableViewExt").new({
				size = self._rootnode.heroListBg:getContentSize(),
				direction = kCCScrollViewDirectionVertical,
				createFunc = createFunc,
				refreshFunc = refreshFunc,
				cellNum = #PetModel.totalTable,
				cellSize = require("game.Pet.PetListCell").new():getContentSize(),
				scrollFunc = function()
				end
				})
				self.sellHeroTable = require("utility.TableViewExt").new({
				size = self._rootnode.heroListBg:getContentSize(),
				direction = kCCScrollViewDirectionVertical,
				createFunc = createFunc,
				refreshFunc = refreshSellFunc,
				cellNum = #self.sellList,
				cellSize = require("game.Pet.PetListCell").new():getContentSize(),
				scrollFunc = function()
				end
				})
				self.scrollLayerNode:addChild(self.heroTable)
				self.scrollLayerNode:addChild(self.sellHeroTable)
				self.sellHeroTable:setVisible(false)
			else
				if self.isQiangHua == true then
					self.heroTable:resetCellNum(#PetModel.totalTable, false, false)
				else
					self.heroTable:resetCellNum(#PetModel.totalTable)
				end
				self.sellHeroTable:resetCellNum(#self.sellList)
			end
			local cell = self.heroTable:cellAtIndex(0)
			if cell ~= nil then
				self.jinjieBtn = cell:getJinjieBtn()
				self.headBtn = cell:getHeadIcon()
			end
			self:setCurNum(#PetModel.totalTable)
		end
	elseif TAB_TAG.SOUL == tag then
		self._rootnode.numTag:setVisible(false)
		sellBtn:setVisible(false)
		local function createCollectLayer()
			local collectLayer = require("game.Hero.CollectLayer").new()
			self:addChild(collectLayer, 103)
		end
		self.tabId = 2
		sellBtn:setVisible(false)
		self:updateDebriList()
	else
		assert(false, "PetList onTabBtn Tag Error!")
	end
	self._currentTab = tag
end

function PetList:ctor(tag)
	game.runningScene = self
	PetList.super.ctor(self, {
	contentFile = "pet/pet_list_bg.ccbi",
	subTopFile = "pet/pet_up_tab.ccbi"
	})
	
	ResMgr.createBefTutoMask(self)
	if tag == nil or tag < 0 or tag > 2 then
		self._currentTab = TAB_TAG.XIAKE
	else
		self._currentTab = tag
	end
	self:setNodeEventEnabled(true)
	self.hasGotPetDebrisList = false
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_main_menu.plist", "ui/ui_main_menu.png")
	self.viewType = COMMON_VIEW
	self._rootnode.backBtn:setVisible(false)
	self._rootnode.tag:setZOrder(1000)
	self:checkHasDot()
	self.sellFunc = nil
	self.sellFrame = require("utility.SellFrame").new({
	leftTitle = common:getLanguageString("@selectedPet"),
	rightTitle = common:getLanguageString("@TotalSell"),
	icon = iconSprite,
	sellFunc = function()
		self.sellFunc()
	end
	})
	self:addChild(self.sellFrame, 1)
	local function extend(...)
		RequestHelper.extendBag({
		type = BAG_TYPE.chongwu,
		callback = function(data)
			if string.len(data["0"]) == 0 then
				local bagCountMax = data["1"]
				local costGold = data["2"]
				local curGold = data["3"]
				game.player:setBagCountMax(bagCountMax)
				game.player:setGold(curGold)
				self:updateLabel()
				self:setMaxNum(bagCountMax)
				local tips = common:getLanguageString("@openDesc", self._cost[2], common:getLanguageString("@pet"))
				show_tip_label(tips)
				self._cost[1] = data["4"]
				self._cost[2] = data["5"]
				PostNotice(NoticeKey.MainMenuScene_Update)
			else
				CCMessageBox(data["0"], "Error")
			end
		end
		})
	end
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
				curMoney = curMoney + ResMgr.getPetData(self.sellList[k].resId).price
			end
		end
		self.sellFrame:setRightNum(curMoney)
		self.sellFrame:setLeftNum(num)
		self.sellHeroTable:resetCellNum(#self.sellList, false, false)
	end
	
	--按星级卖出
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
	
	
	--图鉴
	local btn = ResMgr.newUIButton({
	image = "ui/new_btn/tujian.png",
	imageSelected = "ui/new_btn/tujian.png",
	imageDisabled = "ui/new_btn/tujian.png",
	tag = 1,
	handle = function()	
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_HANDBOOK_PET)
	end
	})
	
	local x, y = self._rootnode.lianhuaBtn:getPosition()
	local size = self._rootnode.lianhuaBtn:getContentSize()
	btn:setPosition(x - 120, y)
	self._rootnode.lianhuaBtn:getParent():addChild(btn)
	
	--炼化
	self._rootnode.lianhuaBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_LIANHUALU)
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
end

function PetList:reloadBroadcast()
	local broadcastBg = self._rootnode.broadcast_tag
	game.broadcast:reSet(broadcastBg)
end

function PetList:checkHasDot()
	if game.player:getPetNum() > 0 then
		self._rootnode.tag:setVisible(true)
	else
		self._rootnode.tag:setVisible(false)
	end
end

function PetList:updateLabel()
	self._rootnode.goldLabel:setString(game.player:getGold())
	self._rootnode.silverLabel:setString(game.player:getSilver())
end

function PetList:onEnter()
	game.runningScene = self
	PetList.super.onEnter(self)
	TutoMgr.addBtn("herolist_zhujue_jinjie_btn", self.jinjieBtn)
	TutoMgr.addBtn("herolist_zhujue_head_btn", self.headBtn)
	TutoMgr.addBtn("zhujiemian_btn_shouye", self._rootnode.mainSceneBtn)
	TutoMgr.addBtn("zhujiemian_btn_zhenrong", self._rootnode.formSettingBtn)
	TutoMgr.addBtn("zhenrong_btn_fuben", self._rootnode.battleBtn)
	TutoMgr.addBtn("zhujiemian_btn_huodong", self._rootnode.activityBtn)
	TutoMgr.addBtn("zhujiemian_btn_beibao", self._rootnode.bagBtn)
	TutoMgr.addBtn("zhujiemian_btn_shangcheng", self._rootnode.shopBtn)
	dump("herolistononon")
	self._rootnode.sell_title:setEnabled(false)
	if self.isActive ~= nil then
		ResMgr.createBefTutoMask(self)
		TutoMgr.active()
	else
		self.isActive = true
	end
end

function PetList:onExit()
	self._bExit = true
	PetList.super.onExit(self)
	TutoMgr.removeBtn("herolist_zhujue_jinjie_btn")
	TutoMgr.removeBtn("herolist_zhujue_head_btn")
	TutoMgr.removeBtn("zhujiemian_btn_shouye")
	TutoMgr.removeBtn("zhujiemian_btn_zhenrong")
	TutoMgr.removeBtn("zhujiemian_btn_huodong")
	TutoMgr.removeBtn("zhujiemian_btn_beibao")
	TutoMgr.removeBtn("zhujiemian_btn_shangcheng")
end

return PetList