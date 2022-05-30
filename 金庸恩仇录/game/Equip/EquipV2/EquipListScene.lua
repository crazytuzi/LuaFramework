local data_config_config = require("data.data_config_config")
local data_equipquench_equipquench = require("data.data_equipquench_equipquench")
local data_item_item = require("data.data_item_item")

local MAX_ZORDER = 100000
local TAB_TAG = {
EQUIP = 1,
SHIZHUANG = 2,
DEBRIS =3,
}
local COMMON_VIEW = 1
local SALE_VIEW = 2
local LISTVIEW_TAG = 100

local BaseScene = require("game.BaseScene")
local EquipListScene = class("EquipListScene", BaseScene)

function EquipListScene:SendReq()
	RequestHelper.getEquipList({
	callback = function(data)
		if #data["0"] > 0 then
			show_tip_label(#data["0"])
		else
			self._cost = {
			data["4"],
			data["5"]
			}
			game.player:setEquipments(data["1"])
			self:init(data)
		end
	end
	})
end

function EquipListScene:resetPos()
	local xiedai = self._rootnode.xiedai
	local curNum = self._rootnode.curNum
	local sign = self._rootnode.sign
	local maxNum = self._rootnode.maxNum
	curNum:setPosition(xiedai:getPositionX() + xiedai:getContentSize().width, xiedai:getPositionY())
	sign:setPosition(curNum:getPositionX() + curNum:getContentSize().width, xiedai:getPositionY())
	maxNum:setPosition(sign:getPositionX() + sign:getContentSize().width, xiedai:getPositionY())
end

function EquipListScene:setCurNum(num)
	self._rootnode.curNum:setString(num)
	self:resetPos()
end

function EquipListScene:setMaxNum(num)
	self._rootnode.maxNum:setString(num)
	self:resetPos()
end

function EquipListScene:onSaleView()
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
	self.isAllowScroll = false
	self.equipSellTable:resetCellNum(#self.sellList)
	self.isAllowScroll = true
	self.equipSellTable:setVisible(true)
	self.equipTable:setVisible(false)
	self.sellMoney = 0
	self.sellFrame:setRightNum(0)
	self.sellFrame:setLeftNum(0)
end

function EquipListScene:onCommonView()
	self.viewType = COMMON_VIEW
	self._rootnode.tab1:setVisible(true)
	self._rootnode.tab2:setVisible(true)
	self._rootnode.tab3:setVisible(true)
	if self._currentTab == TAB_TAG.SHIZHUANG then
		self._rootnode.expandBtn:setVisible(false)
	else
		self._rootnode.expandBtn:setVisible(true)
	end
	self._rootnode.sellBtn:setVisible(true)
	self._rootnode.sellStarBtn:setVisible(false)
	self._rootnode.backBtn:setVisible(false)
	self._rootnode.sell_title:setVisible(false)
	self.sellFrame:setVisible(false)
	self._rootnode.numTag:setVisible(true)
	self._rootnode.bottomNode:setVisible(true)
	self.equipTable:resetCellNum(#self.commonList)
	self.equipSellTable:setVisible(false)
	self.equipTable:setVisible(true)
	self:checkHasDot()
end

function EquipListScene:getSellMoney()
	local curMoney = 0
	local num = 0
	for k, v in pairs(self.sellIndex) do
		if self.sellIndex[k] then
			num = num + 1
			curMoney = curMoney + self.sellList[k].silver
		end
	end
	self.sellFrame:setRightNum(curMoney)
	self.sellFrame:setLeftNum(num)
end

function EquipListScene:init(data)
	self.sellTable = {}
	--local list = data["1"]
	self.nameList = data["6"]
	--self.commonList = list or {}
	self.commonList = game.player:getNormalEquipments()
	--local list = self.commonList
	
	local function addCulianAttr(index, pos, order)
		local baseData = game.player:getCulianAttr(index, pos)
		if baseData then
			local keys = {
			"arr_hp",
			"arr_attack",
			"arr_defense",
			"arr_defenseM"
			}
			local cls = baseData.cls
			local itemdataT = {}
			local itemData = {}
			for k, v in pairs(keys) do
				if data_equipquench_equipquench[pos][v][cls] ~= 0 then
					self.commonList[order].base[k] = math.ceil(self.commonList[order].base[k] * (1 + data_equipquench_equipquench[pos][v][cls] / 10000))
				end
			end
		end
	end
	for k, v in pairs(self.commonList) do
		addCulianAttr(v.pos, v.subpos, k)
	end
	EquipModel.sort(self.commonList)
	self.sellList = {}
	for i = 1, #self.commonList do
		local isSale = data_item_item[self.commonList[i].resId].sale
		if isSale ~= nil and isSale ~= 0 and self.commonList[i].pos == 0 then
			self.sellList[#self.sellList + 1] = self.commonList[i]
		end
	end
	local maxEquipNum = data["3"]
	self:setMaxNum(maxEquipNum)
	local sellBtn = self._rootnode.sellBtn
	local extendBtn = self._rootnode.expandBtn
	local boardBg = self._rootnode.heroListBg
	local function quickChoseFunc(selTable)
		for i = 1, #selTable do
			if selTable[i] then
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
		self:getSellMoney()
		self.equipSellTable:resetCellNum(#self.sellList)
	end
	if self._bInit ~= true then
		--按星级卖出
		self._rootnode.sellStarBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self._rootnode.sellStarBtn:setEnabled(false)
			ResMgr.delayFunc(0.5, function()
				self._rootnode.sellStarBtn:setEnabled(true)
			end,
			self)
			local heroQuickSel = require("game.Equip.EquipV2.EquipQuickChose").new(quickChoseFunc)
			display:getRunningScene():addChild(heroQuickSel, 10)
		end,
		CCControlEventTouchUpInside)
	end
	
	local numTag = self._rootnode.numTag
	numTag:setZOrder(20)
	if self._bInit ~= true then
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
		
	end
	local function updateLabel()
		self._rootnode.goldLabel:setString(game.player:getGold())
		self._rootnode.silverLabel:setString(game.player:getSilver())
	end
	local function extend(...)
		RequestHelper.extendBag({
		type = 1,
		callback = function(data)
			dump(data)
			if #data["0"] == 0 then
				local bagCountMax = data["1"]
				local costGold = data["2"]
				local curGold = data["3"]
				self._cost[1] = data["4"]
				self._cost[2] = data["5"]
				game.player:setBagCountMax(bagCountMax)
				game.player:setGold(curGold)
				updateLabel()
				self:setMaxNum(bagCountMax)
				ResMgr.showErr(500014)
				PostNotice(NoticeKey.MainMenuScene_Update)
			else
				CCMessageBox(data["0"], "Error")
			end
		end
		})
	end
	if self._bInit ~= true then
		self._rootnode.expandBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if self._cost[1] ~= -1 then
				local box = require("utility.CostTipMsgBox").new({
				tip = common:getLanguageString("@OpenLocation", self._cost[2]),
				listener = function()
					if game.player.m_gold >= self._cost[1] then
						extend()
					else
						ResMgr.showErr(400004)
					end
				end,
				cost = self._cost[1]
				})
				game.runningScene:addChild(box, 1001)
			else
				ResMgr.showErr(500012)
			end
		end,
		CCControlEventTouchUpInside)
		
	end
	updateLabel()
	local function updateShiZhuangList()
		local max_shizhuang_num = data_config_config[1].max_shizhuang_num
		local data = self.shiZhuangData
		local datanum = #self.shiZhuangData
		local function qianghuacb(idx)
			local function callback(idx, param, sliver, cyls_num)
				self.shiZhuangData[idx] = param
				data = self.shiZhuangData
				self.equipTable:reloadCell(idx - 1, {
				idx = idx,
				viewType = self.viewType,
				data = param
				})
				self.cylsNum = cyls_num
				FashionModel.setCylsNum(cyls_num)
				updateLabel()
			end
			self.cylsNum = FashionModel.getCylsNum()
			local qianghuaLayer = require("game.shizhuang.SZQiangHuaLayer").new({
			idx = idx,
			data = data[idx],
			cyls_num = self.cylsNum,
			cb = callback
			})
			game.runningScene:addChild(qianghuaLayer, 1000)
		end
		
		self:setCurNum(datanum)
		self:setMaxNum(max_shizhuang_num)
		local function createFunc(idx)
			idx = idx + 1
			local item = require("game.Equip.EquipV2.EquipSZListCellVTwo").new()
			return item:create({
			idx = idx,
			viewType = 1,
			callBack = qianghuacb,
			data = data[idx]
			})
		end
		local function refreshFunc(cell, idx)
			idx = idx + 1
			cell:refresh({
			idx = idx,
			viewType = 1,
			data = data[idx]
			})
		end
		
		self.equipTable = nil
		self.equipTable = require("utility.TableViewExt").new({
		size = cc.size(self.listView:getContentSize().width, self.listView:getContentSize().height),
		direction = kCCScrollViewDirectionVertical,
		createFunc = createFunc,
		refreshFunc = refreshFunc,
		cellNum = datanum,
		cellSize = require("game.Equip.EquipV2.EquipSZListCellVTwo").new():getContentSize()
		})
		self.scrollLayerNode:removeAllChildren()
		self.scrollLayerNode:addChild(self.equipTable)
	end
	
	local function updateDebriList()
		RequestHelper.getEquipDebrisList({
		callback = function(listData)
			if #listData["0"] > 0 then
				show_tip_label(listData["0"])
				return
			end
			self.scrollLayerNode:removeAllChildren()
			local debrisList = {}
			local t = listData["1"]
			local ret = false
			
			for k, v in pairs(t) do
				--local cut = v.itemCnt
				local itemId = v.itemId
				if data_item_item[itemId] then
					table.insert(debrisList, v)
					--local limitNum = data_item_item[itemId].para1
					--if cut >= limitNum then
					--	ret = true
					--end
				else
					dump("itemid: " ..itemId)
				end
			end
			
			function comps(a,b)
				local aItem = data_item_item[a.itemId]
				local bItem = data_item_item[b.itemId]
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
			
			if ret then
				self._rootnode.tag:setVisible(true)
			else
				self._rootnode.tag:setVisible(false)
				game.player:setEquipmentsNum(0)
			end
			
			local function createCollectLayer(levelInfo)
				local collectLayer = require("game.Hero.CollectLayer").new(levelInfo, ResMgr.EQUIP)
				self:addChild(collectLayer, 103)
			end
			local function hechengLayer(hechengData)
				dump(hechengData)
				RequestHelper.sendHeChengEquipRes({
				callback = function(listData)
					dump(listData)
					if listData["5"] == true then
						ResMgr.showMsg(3)
					elseif string.len(listData["0"]) > 0 then
						CCMessageBox(listData["0"], "Tip")
					else
						local isFull = listData["3"] or false
						if not isFull then
							self.upDebrisFunc()
							local tip = require("utility.NormalBanner").new({
							tipContext = common:getLanguageString("@composeSuc")
							})
							tip:setPosition(display.cx, display.cy)
							self:addChild(tip, MAX_ZORDER)
						else
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
									}),
									MAX_ZORDER)
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
								}),
								MAX_ZORDER)
							end
						end
					end
				end,
				id = hechengData.id,
				num = hechengData.num
				})
			end
			local function createFunc(idx)
				local item = require("game.Equip.EquipV2.EquipDebrisCellVTwo").new()
				return item:create({
				id = idx,
				viewSize = cc.size(self:getContentSize().width, self:getContentSize().height * 0.95),
				createDiaoLuoLayer = createCollectLayer,
				hechengFunc = hechengLayer,
				listData = debrisList
				})
			end
			local function refreshFunc(cell, idx)
				cell:refresh(idx + 1, debrisList)
			end
			self.itemList = nil
			self.itemList = require("utility.TableViewExt").new({
			size = cc.size(self.listView:getContentSize().width, self.listView:getContentSize().height),
			direction = kCCScrollViewDirectionVertical,
			createFunc = createFunc,
			refreshFunc = refreshFunc,
			cellNum = #debrisList,
			cellSize = require("game.Equip.EquipV2.EquipDebrisCellVTwo").new():getContentSize(),
			scrollFunc = function()
			end
			})
			self:setCurNum(#debrisList)
			self.scrollLayerNode:addChild(self.itemList)
		end
		})
	end
	self.upDebrisFunc = updateDebriList
	self.sellMoney = 0
	local function changeSoldMoney(num)
		self:getSellMoney()
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
		for i = 1, #self.sellTable do
			for j = 1, #self.sellList do
				if self.sellTable[i] == self.sellList[j]._id then
					table.remove(self.sellList, j)
					break
				end
			end
		end
		for i = 1, #self.sellTable do
			for j = 1, #self.commonList do
				if self.sellTable[i] == self.commonList[j]._id then
					table.remove(self.commonList, j)
					break
				end
			end
		end
		self.sellMoney = 0
		self.sellTable = {}
		self.sellIndex = {}
		self.equipTable:resetCellNum(#self.commonList, false, false)
		self.equipSellTable:resetCellNum(#self.sellList, false, false)
		self.sellFrame:setRightNum(0)
		self.sellFrame:setLeftNum(0)
		self:setCurNum(#self.commonList)
	end
	local function sellFunc()
		local sellStr = ""
		if #self.sellTable == 0 then
			ResMgr.showErr(500011)
		else
			for i = 1, #self.sellTable do
				if #sellStr ~= 0 then
					sellStr = sellStr .. "," .. self.sellTable[i]
				else
					sellStr = sellStr .. self.sellTable[i]
				end
			end
			RequestHelper.sendSellEquipRes({
			callback = function(data)
				dump(data)
				if #data["0"] > 0 then
					show_tip_label(data["0"])
				else
					game.player.m_silver = data["1"][2]
					show_tip_label(common:getLanguageString("@SellSuccess", data["1"][1]))
					self._rootnode.silverLabel:setString(data["1"][2])
					PostNotice(NoticeKey.MainMenuScene_Update)
				end
				clearSellData()
			end,
			ids = sellStr
			})
		end
	end
	
	self.sellFunc = sellFunc
	
	local function onTabBtn(tag)
		if self._reqData == true and self._currentTab > 0 then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		end
		
		local lastTag = self._currentTab
		self._currentTab = tag
		if TAB_TAG.EQUIP == tag  then
			if lastTag == TAB_TAG.DEBRIS then
				PageMemoModel.clear("equipTable")
				PageMemoModel.clear("equipSellTable")
				self._reqData = true
				self:SendReq()
				return
			end
			sellBtn:setVisible(true)
			extendBtn:setVisible(true)
			self._rootnode.numTag:setVisible(true)
			local function createXiLianLayer(indexId)
				local layer = require("game.Equip.FormEquipXiLianLayer").new({
				info = self.commonList[indexId + 1],
				listener = function()
					local cell = self.equipTable:cellAtIndex(indexId)
					cell:refresh(indexId, self.viewType, self.commonList[indexId + 1])
				end
				})
				game.runningScene:addChild(layer, 103)
			end
			local function createQiangHuaLayer(indexId)
				local layer = require("game.Equip.FormEquipQHLayer").new({
				info = self.commonList[indexId + 1],
				listener = function(isQiangHua)
					local cell = self.equipTable:cellAtIndex(indexId)
					EquipModel.sort(self.commonList)
					if isQianghua == true then
						self.equipTable:resetCellNum(#self.commonList, false, false)
					else
						self.equipTable:resetCellNum(#self.commonList)
					end
				end
				})
				game.runningScene:addChild(layer, 103)
			end
			local function createEquipInfoLayer(index)
				dump(self.commonList[index + 1])
				if self.viewType == COMMON_VIEW then
					local _info = self.commonList[index + 1]
					_info.role = game.player.m_formation["1"][1]
					local layer = require("game.Equip.CommonEquipInfoLayer").new({
					info = _info,
					listener = function()
						local cell = self.equipTable:cellAtIndex(index)
						cell:refresh(index, self.viewType, self.sellIndex[index + 1])
					end,
					hasAdd = true,
					index = self.commonList[index + 1].pos,
					subIndex = self.commonList[index + 1].subpos
					}, 2)
					game.runningScene:addChild(layer, 10)
				else
					local cellData = self.sellList[index + 1]
					local itemInfo = require("game.Huodong.ItemInformation").new({
					id = cellData.resId,
					type = 1
					})
					display.getRunningScene():addChild(itemInfo, 100000)
				end
			end
			local function createFunc(idx)
				local item = require("game.Equip.EquipV2.EquipListCellVTwo").new()
				return item:create({
				id = idx,
				viewSize = cc.size(self:getContentSize().width, self:getContentSize().height * 0.95),
				listData = self.commonList,
				nameData = self.nameList,
				saleData = self.sellList,
				viewType = self.viewType,
				choseTable = self.sellIndex,
				changeSoldMoney = changeSoldMoney,
				addSellItem = addSellItemFunc,
				removeSellItem = removeSellItemFunc,
				createXiLianListenr = createXiLianLayer,
				createQiangHuaListener = createQiangHuaLayer,
				createEquipInfoLayer = createEquipInfoLayer
				})
			end
			
			local function refreshFunc(cell, idx)
				cell:refresh(idx, COMMON_VIEW, self.sellIndex[idx + 1])
			end
			
			self.equipTable = nil
			self.equipTable = require("utility.TableViewExt").new({
			size = cc.size(self:getContentSize().width, self.getCenterHeightWithSubTop()),
			direction = kCCScrollViewDirectionVertical,
			createFunc = createFunc,
			refreshFunc = refreshFunc,
			cellNum = #self.commonList,
			cellSize = require("game.Equip.EquipV2.EquipListCellVTwo").new():getContentSize(),
			scrollFunc = function()
				PageMemoModel.saveOffset("equipTable", self.equipTable)
			end
			})
			
			local function refreshSellFunc(cell, idx)
				cell:refresh(idx, SALE_VIEW, self.sellIndex[idx + 1])
			end
			self.equipSellTable = nil
			self.equipSellTable = require("utility.TableViewExt").new({
			size = cc.size(self:getContentSize().width, self.getCenterHeightWithSubTop()),
			direction = kCCScrollViewDirectionVertical,
			createFunc = createFunc,
			refreshFunc = refreshSellFunc,
			cellNum = #self.sellList,
			cellSize = require("game.Equip.EquipV2.EquipListCellVTwo").new():getContentSize(),
			scrollFunc = function()
				PageMemoModel.saveOffset("equipSellTable", self.equipSellTable)
			end
			})
			
			PageMemoModel.resetOffset("equipTable", self.equipTable)
			PageMemoModel.resetOffset("equipSellTable", self.equipSellTable)
			
			self:setCurNum(#self.commonList)
			self.scrollLayerNode:removeAllChildren()
			self.scrollLayerNode:addChild(self.equipTable)
			self.scrollLayerNode:addChild(self.equipSellTable)
			self.equipSellTable:setVisible(false)
		elseif TAB_TAG.DEBRIS == tag then
			self._rootnode.numTag:setVisible(false)
			sellBtn:setVisible(false)
			extendBtn:setVisible(false)
			updateDebriList()
		elseif TAB_TAG.SHIZHUANG == tag then
			self._rootnode.numTag:setVisible(true)
			sellBtn:setVisible(false)
			extendBtn:setVisible(false)
			self.cylsNum = FashionModel.getCylsNum()
			if (lastTag == TAB_TAG.DEBRIS) then
				RequestHelper.getEquipList({
				callback = function(data)
					if #data["0"] > 0 then
						show_tip_label(#data["0"])
					else
						self._cost = {
						data["4"],
						data["5"]
						}
						game.player:setEquipments(data["1"])
						self.shiZhuangData = FashionModel.getFashionList()
						updateShiZhuangList()
					end
				end
				})
			else
				self.shiZhuangData = FashionModel.getFashionList()
				updateShiZhuangList()
			end
			
			--获取翠云彩缎数量
			FashionModel.getListReq(function(list, num)
				self.cylsNum = num
			end)
			
		else
			assert(false, "EquipListScene onTabBtn Tag Error!")
		end
		self._currentTab = tag
	end
	
	local function initTab()
		CtrlBtnGroupAsMenu({
		self._rootnode.tab1,
		self._rootnode.tab2,
		self._rootnode.tab3
		}, onTabBtn)
	end
	
	if self._bInit ~= true then
		initTab()
	end
	
	onTabBtn(self._initTag)
	self:onCommonView()
	self._bInit = true
	self._reqData = false
end

function EquipListScene:checkHasDot()
	if game.player:getEquipmentsNum() > 0 then
		self._rootnode.tag:setVisible(true)
	else
		self._rootnode.tag:setVisible(false)
	end
end

function EquipListScene:ctor(tag)
	EquipListScene.super.ctor(self, {
	contentFile = "equip/equip_list_bg.ccbi",
	subTopFile = "hero/hero_up_tab.ccbi"
	})
	
	ResMgr.removeBefLayer()
	if tag == nil or tag < 0 or tag > 2 then
		self._initTag = TAB_TAG.EQUIP
	else
		self._initTag = tag
	end
	self._currentTab = 0
	display.addSpriteFramesWithFile("ui/ui_main_menu.plist", "ui/ui_main_menu.pvr.ccz")
	self.viewType = COMMON_VIEW
	self._rootnode.sellStarBtn:setVisible(false)
	resetctrbtnString(self._rootnode.tab1, common:getLanguageString("@Equit"))
	resetctrbtnString(self._rootnode.tab2, common:getLanguageString("@shizhuang"))
	resetctrbtnString(self._rootnode.tab3, common:getLanguageString("@sz_suipian"))
	self._rootnode.tab2:setPositionX(display.width * 0.36)
	self._rootnode.tab3:setPositionX(display.width * 0.58)
	self._rootnode.tag:setPositionX(display.width * 0.69)
	local iconSprite = display.newSprite("#mm_silver.png", x, y, params)
	self.sellFunc = nil
	self.sellFrame = require("utility.SellFrame").new({
	leftTitle = common:getLanguageString("@SelectOK"),
	rightTitle = common:getLanguageString("@TotalSell"),
	icon = iconSprite,
	sellFunc = function()
		self.sellFunc()
	end
	})
	self:addChild(self.sellFrame, 1)
	self.listView = self._rootnode.listView
	self.baseNode = display.newNode()
	self.listView:addChild(self.baseNode)
	self.scrollLayerNode = display.newNode()
	self.baseNode:addChild(self.scrollLayerNode)
	self.commonList = {}
	self.sellList = {}
	self.sellIndex = {}
	self.bExit = false
	self.equipTable = nil
	self:SendReq()
	self:checkHasDot()
end

function EquipListScene:onEnter()
	self.bExit = false
	game.runningScene = self
	EquipListScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function EquipListScene:onExit()
	EquipListScene.super.onExit(self)
	PageMemoModel.clear("equipDebirs")
	PageMemoModel.clear("equipTable")
	PageMemoModel.clear("equipSellTable")
	HeroSettingModel.cardIndex = 0
	self.bExit = true
end

function EquipListScene:reloadBroadcast()
	local broadcastBg = self._rootnode.broadcast_tag
	game.broadcast:reSet(broadcastBg)
end

return EquipListScene