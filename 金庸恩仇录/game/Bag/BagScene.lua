require("game.Bag.BagCtrl")
local data_item_item = require("data.data_item_item")
local RequestInfo = require("network.RequestInfo")

local BaseScene = require("game.BaseScene")
local BagScene = class("ItemChooseScene", BaseScene)

local MAX_ZODER = 10000
local VIEW_TYPE = {
BAG_ITEM = 1,
BAG_SKILL = 2,
BAG_GIFT = 3
}

local Item = {
[VIEW_TYPE.BAG_ITEM] = require("game.Bag.BagItem"),
[VIEW_TYPE.BAG_SKILL] = require("game.Bag.SkillItem"),
[VIEW_TYPE.BAG_GIFT] = require("game.Bag.BagItem")
}

function BagScene:onTab(tag)
	self._curView = tag
	self._showType = 1
	self._cap[self._curView][1] = #self._item[self._curView]
	if self._updateSKill then
		self:requestSkillList(function()
			self:updateBageItem()
		end)
	else
		self:updateBageItem()
	end
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
end

function BagScene:ctor(tag)
	BagScene.super.ctor(self, {
	contentFile = "public/window_content_scene.ccbi",
	subTopFile = "bag/bag_tab_view.ccbi",
	bgImage = "ui_common/common_bg.png",
	imageFromBottom = true
	})
	
	ResMgr.removeBefLayer()
	if tag == nil or type(tag) ~= "number" or tag < 0 or tag > 2 then
		self._curView = VIEW_TYPE.BAG_ITEM
	else
		self._curView = tag
	end
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("public/item_num_view.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, self:getBottomHeight())
	self:addChild(node, 3)
	node = CCBuilderReaderLoad("bag/bag_bottom_frame.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, 0)
	self:addChild(node, 4)
	local function onTabBtn(tag)
		self:onTab(tag)
	end
	self._rootnode.saleInfoView:setVisible(false)
	self._rootnode.bottomNode:setVisible(true)
	CtrlBtnGroupAsMenu({
	self._rootnode.tab1,
	self._rootnode.tab2,
	self._rootnode.tab3
	}, function(idx)
		onTabBtn(idx)
	end,
	self._curView)
	
	--扩展背包
	self._rootnode.extendBtn:registerScriptTapHandler(function()
		if self._cost[self._curView][1] ~= -1 then
			self._rootnode.extendBtn:setEnabled(false)
			local box = require("utility.CostTipMsgBox").new({
			tip = common:getLanguageString("@BagCostTips", self._cost[self._curView][1], tostring(self._cost[self._curView][2])),
			cancelListener = function()
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
				self._rootnode.extendBtn:setEnabled(true)
			end,
			listener = function()
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				self._rootnode.extendBtn:setEnabled(true)
				if game.player:getGold() >= self._cost[self._curView][1] then
					if self._curView == VIEW_TYPE.BAG_ITEM then
						self:extend(BAG_TYPE.daoju)
					elseif self._curView == VIEW_TYPE.BAG_GIFT then
						self:extend(BAG_TYPE.lipin)
					else
						self:extend(BAG_TYPE.wuxue)
					end
				else
					show_tip_label(data_error_error[400004].prompt)
				end
			end,
			cost = self._cost[self._curView][1]
			})
			self:addChild(box, 100)
		elseif self._curView == VIEW_TYPE.BAG_ITEM then
			show_tip_label(data_error_error[300018].prompt)
		elseif self._curView == VIEW_TYPE.BAG_GIFT then
			show_tip_label(data_error_error[300028].prompt)
		elseif self._curView == VIEW_TYPE.BAG_SKILL then
			show_tip_label(data_error_error[300019].prompt)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end)
	
	--卖出
	self._rootnode.sellBtn:registerScriptTapHandler(function()
		self:onSaleView()
		self._rootnode.saleView:setVisible(true)
		self._rootnode.useView:setVisible(false)
		self._rootnode.numTagNode:setVisible(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end)
	
	--返回
	self._rootnode.returnBtn:addHandleOfControlEvent(function()
		self:onUseView()
		self._rootnode.saleView:setVisible(false)
		self._rootnode.useView:setVisible(true)
		self._rootnode.numTagNode:setVisible(true)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	
	local function onConfirmSell()
		local ids = {}
		for k, v in pairs(self._chooseItems) do
			if v == true then
				if self._curView == VIEW_TYPE.BAG_ITEM then
					table.insert(ids, self._canSaleItems[k].itemId)
				elseif self._curView == VIEW_TYPE.BAG_GIFT then
					table.insert(ids, self._canSaleItems[k].itemId)
				elseif self._curView == VIEW_TYPE.BAG_SKILL then
					table.insert(ids, self._canSaleItems[k]._id)
				end
			end
		end
		if #ids == 0 then
			local tipContext
			if self._curView == VIEW_TYPE.BAG_ITEM then
				tipContext = common:getLanguageString("@OneProp")
			elseif self._curView == VIEW_TYPE.BAG_GIFT then
				tipContext = common:getLanguageString("@OneProp")
			elseif self._curView == VIEW_TYPE.BAG_SKILL then
				tipContext = common:getLanguageString("@OneKungfu")
			end
			show_tip_label(tipContext)
			return
		end
		if self._curView == VIEW_TYPE.BAG_ITEM then
			RequestHelper.sell({
			ids = ids,
			callback = function(data)
				if string.len(data["0"]) > 0 then
				else
					show_tip_label(common:getLanguageString("@GetSilverCoin", tostring(data["1"])))
					game.player:setSilver(data["2"])
					PostNotice(NoticeKey.CommonUpdate_Label_Silver)
					self:updateList()
				end
			end
			})
		elseif self._curView == VIEW_TYPE.BAG_SKILL then
			local req = RequestInfo.new({
			modulename = "skill",
			funcname = "sell",
			param = {ids = ids},
			oklistener = function(data)
				show_tip_label(common:getLanguageString("@GetSilverCoin", tostring(data["1"])))
				game.player:setSilver(data["2"])
				PostNotice(NoticeKey.CommonUpdate_Label_Silver)
				self:updateList()
			end
			})
			RequestHelperV2.request(req)
		end
	end
	
	--确定卖出
	self._rootnode.confirSellBtn:addHandleOfControlEvent(function()
		onConfirmSell()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	
	self._item = {}
	self._cap = {}
	self._cost = {}
end

function BagScene:extend(extType)
	RequestHelper.extendBag({
	callback = function(data)
		dump(data)
		if string.len(data["0"]) > 0 then
			CCMessageBox(data["0"], "Error")
		else
			local bagCountMax = data["1"]
			local curGold = data["3"]
			if extType == BAG_TYPE.wuxue then
				self._cost[VIEW_TYPE.BAG_SKILL][1] = data["4"]
				self._cost[VIEW_TYPE.BAG_SKILL][2] = data["5"]
				self._cap[VIEW_TYPE.BAG_SKILL][2] = bagCountMax
			elseif extType == BAG_TYPE.daoju then
				self._cost[VIEW_TYPE.BAG_ITEM][1] = data["4"]
				self._cost[VIEW_TYPE.BAG_ITEM][2] = data["5"]
				self._cap[VIEW_TYPE.BAG_ITEM][2] = bagCountMax
			elseif extType == BAG_TYPE.lipin then
				self._cost[VIEW_TYPE.BAG_GIFT][1] = data["4"]
				self._cost[VIEW_TYPE.BAG_GIFT][2] = data["5"]
				self._cap[VIEW_TYPE.BAG_GIFT][2] = bagCountMax
			end
			self._rootnode.maxNumLabel:setString(self._cap[self._curView][2] or 0)
			game.player:setGold(curGold)
			PostNotice(NoticeKey.CommonUpdate_Label_Gold)
		end
	end,
	type = tostring(extType)
	})
end

function BagScene:requestSkillList(callback)
	self._updateSKill = false
	RequestHelper.getKongFuList({
	callback = function(data)
		if #data["0"] > 0 then
			show_tip_label(data["0"])
		else
			game.player:setSkills(data["1"])
			self._item[VIEW_TYPE.BAG_SKILL] = game.player:getSkills()
			self._cap[VIEW_TYPE.BAG_SKILL] = {
			data["2"],
			data["3"]
			}
			self._cost[VIEW_TYPE.BAG_SKILL] = {
			data["4"],
			data["5"]
			}
			callback()
		end
	end
	})
end

function BagScene:request()
	local reqs = {}
	local function listSortFunc(lh, rh)
		if lh.cid > 0 and rh.cid == 0 then
			return true
		elseif data_item_item[lh.resId].pos ~= 101 and data_item_item[lh.resId].pos ~= 102 and (data_item_item[rh.resId].pos == 101 or data_item_item[rh.resId].pos == 102) then
			return true
		else
			return false
		end
	end
	table.insert(reqs, RequestInfo.new({
	modulename = "skill",
	funcname = "list",
	param = {},
	oklistener = function(data)
		game.player:setSkills(data["1"])
		self._item[VIEW_TYPE.BAG_SKILL] = game.player:getSkills()
		self._cap[VIEW_TYPE.BAG_SKILL] = {
		data["2"],
		data["3"]
		}
		self._cost[VIEW_TYPE.BAG_SKILL] = {
		data["4"],
		data["5"]
		}
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "packet",
	funcname = "list",
	param = {},
	oklistener = function(data)
		self._item[VIEW_TYPE.BAG_ITEM] = data["1"]
		self._cap[VIEW_TYPE.BAG_ITEM] = {
		data["2"],
		data["3"]
		}
		self._cost[VIEW_TYPE.BAG_ITEM] = {
		data["4"],
		data["5"]
		}
	end
	}))
	table.insert(reqs, RequestInfo.new({
	modulename = "gift",
	funcname = "list",
	param = {},
	oklistener = function(data)
		self._item[VIEW_TYPE.BAG_GIFT] = data["1"]
		self._cap[VIEW_TYPE.BAG_GIFT] = {
		data["2"],
		data["3"]
		}
		self._cost[VIEW_TYPE.BAG_GIFT] = {
		data["4"],
		data["5"]
		}
	end
	}))
	RequestHelperV2.request2(reqs, function()
		self:updateBageItem()
	end)
end

function BagScene:removeItem(id)
	for k, v in ipairs(self._item[self._curView]) do
		if self._curView == VIEW_TYPE.BAG_ITEM then
			if v.itemId == id then
				table.remove(self._item[self._curView], k)
				break
			end
		elseif self._curView == VIEW_TYPE.BAG_SKILL then
			if v._id == id then
				table.remove(self._item[self._curView], k)
				break
			end
		elseif self._curView == VIEW_TYPE.BAG_GIFT and v.itemId == id then
			table.remove(self._item[self._curView], k)
			break
		end
	end
	for k, v in ipairs(self._canSaleItems) do
		if self._curView == VIEW_TYPE.BAG_ITEM then
			if v.itemId == id then
				table.remove(self._canSaleItems, k)
				break
			end
		elseif self._curView == VIEW_TYPE.BAG_SKILL then
			if v._id == id then
				table.remove(self._canSaleItems, k)
				break
			end
		elseif self._curView == VIEW_TYPE.BAG_GIFT and v._id == id then
			table.remove(self._canSaleItems, k)
			break
		end
	end
end

function BagScene:updateList()
	local ids = {}
	for k, v in pairs(self._chooseItems) do
		if v == true then
			if self._curView == VIEW_TYPE.BAG_ITEM then
				table.insert(ids, self._canSaleItems[k].itemId)
			elseif self._curView == VIEW_TYPE.BAG_SKILL then
				table.insert(ids, self._canSaleItems[k]._id)
			elseif self._curView == VIEW_TYPE.BAG_GIFT then
				table.insert(ids, self._canSaleItems[k]._id)
			end
		end
	end
	for _, v in pairs(ids) do
		self:removeItem(v)
	end
	self._chooseNum = 0
	self._saleMoney = 0
	self._rootnode.selectedLabel:setString(tostring(self._chooseNum))
	self._rootnode.costMaxLabel:setString(tostring(self._saleMoney))
	self._cap[self._curView][1] = #self._item[self._curView]
	self._rootnode.curNumLabel:setString(tostring(self._cap[self._curView][1]))
	self._chooseItems = {}
	self._bagItemList:resetCellNum(#self._canSaleItems, false, false)
end

function BagScene:getSaleItems()
	if self._canSaleItems then
		for i = 1, #self._canSaleItems do
			table.remove(self._canSaleItems, 1)
		end
	else
		self._canSaleItems = {}
	end
	for _, v in ipairs(self._item[self._curView]) do
		if self._curView == VIEW_TYPE.BAG_ITEM then
			if data_item_item[v.itemId].sale == 1 then
				table.insert(self._canSaleItems, v)
			end
		elseif self._curView == VIEW_TYPE.BAG_SKILL then
			if data_item_item[v.resId].sale == 1 and v.pos == 0 then
				table.insert(self._canSaleItems, v)
			end
		elseif self._curView == VIEW_TYPE.BAG_GIFT and data_item_item[v.itemId].sale == 1 then
			table.insert(self._canSaleItems, v)
		end
	end
end

function BagScene:bagFull(info)
	local cleanupFunc
	if info[1].type == BAG_TYPE.wuxue then
		function cleanupFunc(data)
			self:onTab(VIEW_TYPE.BAG_SKILL)
		end
	end
	self:addChild(require("utility.LackBagSpaceLayer").new({bagObj = info, cleanup = cleanupFunc}), 100)
end

function BagScene:showReward(items)
	local itemData = {}
	local msg = common:getLanguageString("@Get")
	for k, v in ipairs(items) do
		local itemInfo = data_item_item[v.id]
		if v.t == ITEM_TYPE.xiake then
			local data_card_card = require("data.data_card_card")
			itemInfo = data_card_card[v.id]
		elseif v.t == ITEM_TYPE.chongwu then
			local data_pet_pet = require("data.data_pet_pet")
			itemInfo = data_pet_pet[v.id]
		elseif v.t == ITEM_TYPE.cheats then
			local data_cheats_cheats = require("data.data_miji_miji")
			itemInfo = data_cheats_cheats[v.id]
			--elseif v.t == ITEM_TYPE.shizhuang then
			--	local data_fashion_fashion = require("data.data_fashion_fashion")
			--	itemInfo = data_fashion_fashion[v.id]
		end
		if v.t ~= nil and v.t == 0 then
			msg = msg .. tostring(v.n) .. " "
			msg = msg .. itemInfo.name
		else
			local iconType = ResMgr.getResType(v.t) or ResMgr.ITEM
			table.insert(itemData, {
			id = v.id,
			type = itemInfo.type,
			name = itemInfo.name,
			describe = itemInfo.describe,
			iconType = iconType,
			num = v.n or 0
			})
			if itemInfo.type == BAG_TYPE.wuxue then
				self._updateSKill = true
			end
		end
	end
	if #itemData > 0 then
		local title = common:getLanguageString("@GetRewards")
		local msgBox = require("game.Huodong.RewardMsgBox").new({
		title = title,
		cellDatas = itemData,
		isShowConfirmBtn = true
		})
		self:addChild(msgBox, MAX_ZODER)
	elseif #items > 0 then
		show_tip_label(msg)
	end
end

function BagScene:onUse(item, cnt, name)
	RequestHelper.useItem({
	callback = function(data)
		if #data["0"] > 0 then
			show_tip_label(data_error_error[tonumber(data["0"])].prompt)
		else
			if data["5"] then
				self:bagFull(data["6"])
				return
			end
			if #data["1"][self._curView] ~= #self._item[self._curView] then
				self._item = data["1"]
				self._bagItemList:resetCellNum(#self._item[self._curView], false, false)
			else
				self._item = data["1"]
				self._bagItemList:resetCellNum(#self._item[self._curView], true, false)
			end
			local baseInfo = data_item_item[item.itemId]
			if baseInfo.effecttype == 8 then
				show_tip_label(common:getLanguageString("@NameSucceed"))
			end
			self:getSaleItems()
			local items = data["2"]
			if type(items) == "table" then
				self:showReward(items)
			end
			self._cap[self._curView][1] = #data["1"][self._curView]
			self._rootnode.curNumLabel:setString(tostring(self._cap[self._curView][1]))
			if data["3"] ~= game.player:getGold() then
				game.player:setGold(data["3"])
				PostNotice(NoticeKey.CommonUpdate_Label_Gold)
			end
			if data["4"] ~= game.player:getSilver() then
				game.player:setSilver(data["4"])
				PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			end
		end
		RequestHelper.getBaseInfo({
		callback = function(data)
			local basedata = data["1"]
			local param = {
			silver = basedata.silver,
			gold = basedata.gold,
			lv = basedata.level,
			zhanli = basedata.attack,
			vip = basedata.vip
			}
			param.exp = basedata.exp[1]
			param.maxExp = basedata.exp[2]
			param.naili = basedata.resisVal[1]
			param.maxNaili = basedata.resisVal[2]
			param.tili = basedata.physVal[1]
			param.maxTili = basedata.physVal[2]
			param.name = basedata.name
			game.player:updateMainMenu(param)
			local checkAry = data["2"]
			game.player:updateNotification(checkAry)
		end
		})
	end,
	id = item.itemId,
	num = cnt,
	name = name or ""
	})
end

function BagScene:onBtn(cell, tag)
	local function onUse()
		local itemData = self._item[self._curView][cell:getIdx() + 1]
		local baseInfo = data_item_item[itemData.itemId]
		if baseInfo.level > game.player:getLevel() then
			show_tip_label(common:getLanguageString("@LevelNotEnough"))
			return
		elseif baseInfo.type == ITEM_TYPE.lipin and baseInfo.bag == BAG_TYPE.lipin then
			GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
		elseif baseInfo.type == ITEM_TYPE.daoju and baseInfo.effecttype == 8 then
			local useCountBox = require("game.Setting.ChangeNameBox").new({
			name = baseInfo.name,
			havenum = itemData.itemCnt,
			expend = expend,
			listener = function(num, name)
				self:onUse(itemData, num, name)
			end
			})
			game.runningScene:addChild(useCountBox, 1000)
		elseif baseInfo.type == ITEM_TYPE.daoju and (baseInfo.effecttype == 9 or baseInfo.effecttype == 10) then
			local selectBox = require("game.Bag.BagSelectBox").new({
			effecttype = baseInfo.effecttype,
			baseInfo = baseInfo,
			confirmFunc = function(name)
				self:onUse(itemData, 1, name)
			end
			})
			game.runningScene:addChild(selectBox, 1000)
		elseif baseInfo.type == ITEM_TYPE.daoju and (baseInfo.effecttype == 98 or baseInfo.effecttype == 99)then
			self:onUse(itemData, 1, name)
		else
			local expend = {}
			if baseInfo.expend then
				expend.id = baseInfo.expend[1]
				expend.num = 0
				for k, v in ipairs(self._item[self._curView]) do
					if v.itemId == baseInfo.expend[1] then
						expend.num = v.itemCnt
					end
				end
			end
			if itemData.itemCnt == 1 and (expend.num and 1 < expend.num or expend.num == nil) then
				self:onUse(itemData, 1)
			elseif 1 <= itemData.itemCnt and expend.num and expend.num == 0 then
				show_tip_label(common:getLanguageString("@NumberNotEnough", data_item_item[expend.id].name))
			else
				local useCountBox = require("game.Bag.UseCountBox").new({
				name = baseInfo.name,
				havenum = itemData.itemCnt,
				expend = expend,
				listener = function(num)
					self:onUse(itemData, num)
				end
				})
				game.runningScene:addChild(useCountBox, 1000)
			end
		end
	end
	local function getSkillInfo(callback)
		RequestHelper.sendKongFuQiangHuaRes({
		callback = function(data)
			if #data["0"] > 0 then
				show_tip_label(data["0"] .. ",请重试... ...")
			elseif callback then
				callback(data)
			end
		end,
		op = 1,
		cids = self._item[self._curView][cell:getIdx() + 1]._id
		})
	end
	local function onQiangHu()
		local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")
		if self._item[self._curView][cell:getIdx() + 1].level >= data_shangxiansheding_shangxiansheding[4].level then
			show_tip_label(common:getLanguageString("@KungfuMax"))
			return
		end
		local req = RequestInfo.new({
		modulename = "skill",
		funcname = "qianghua",
		param = {
		op = 1,
		cids = self._item[self._curView][cell:getIdx() + 1]._id
		},
		oklistener = function(data)
			data["1"]._id = self._item[self._curView][cell:getIdx() + 1]._id
			local layer = require("game.skill.SkillQiangHuaLayer").new({
			info = data["1"],
			callback = function()
				for k, v in pairs(self._item[self._curView]) do
					if v._id == data["1"]._id then
						v.curExp = data["1"].exp
						v.level = data["1"].lv
						v.baseRate = data["1"].baseRate
						break
					end
				end
				self:getSaleItems()
				self._cap[self._curView][1] = #self._item[self._curView]
				self._rootnode.curNumLabel:setString(self._cap[self._curView][1] or 0)
				self._bagItemList:resetCellNum(#self._item[self._curView], false, false)
			end
			})
			self:addChild(layer, 10)
			game.player:setSilver(data["2"])
		end
		})
		RequestHelperV2.request(req)
	end
	local function onJingLian()
		local req = RequestInfo.new({
		modulename = "skill",
		funcname = "refine",
		param = {
		op = 1,
		id = self._item[self._curView][cell:getIdx() + 1]._id
		},
		oklistener = function(data)
			dump(self._item[self._curView][cell:getIdx() + 1])
			if data.allow == 1 then
				local baseInfo = {
				_id = self._item[self._curView][cell:getIdx() + 1]._id,
				resId = self._item[self._curView][cell:getIdx() + 1].resId
				}
				local layer = require("game.skill.SkillRefineLayer").new({
				refineInfo = data,
				baseInfo = baseInfo,
				callback = function(bRequest)
					if bRequest then
						self:request()
					end
				end
				})
				game.runningScene:addChild(layer, 100)
			else
				show_tip_label(common:getLanguageString("@KungfuNotRefine"))
			end
			dump(data)
		end
		})
		RequestHelperV2.request(req)
	end
	local function onInfo()
		local a
		if self._showType == 1 then
			a = self._item[self._curView][cell:getIdx() + 1]
		else
			a = self._canSaleItems[cell:getIdx() + 1]
		end
		local infoLayer
		if self._curView == VIEW_TYPE.BAG_ITEM or self._curView == VIEW_TYPE.BAG_GIFT then
			local item = data_item_item[a.itemId]
			infoLayer = require("game.Huodong.ItemInformation").new({
			id = a.itemId,
			type = item.type,
			name = item.name,
			describe = item.describe,
			endFunc = function()
			end
			})
		elseif self._curView == VIEW_TYPE.BAG_SKILL then
			infoLayer = require("game.skill.BaseSkillInfoLayer").new({
			index = self._index,
			subIndex = tag,
			info = a,
			listener = function()
				self._cap[self._curView][1] = #self._item[self._curView]
				self._rootnode.curNumLabel:setString(self._cap[self._curView][1] or 0)
				self:getSaleItems()
				self._bagItemList:resetCellNum(#self._item[self._curView], false, false)
			end
			})
		end
		if infoLayer then
			self:addChild(infoLayer, 10)
		end
	end
	if self._curView == VIEW_TYPE.BAG_ITEM or self._curView == VIEW_TYPE.BAG_GIFT then
		if tag == 1 then
			onUse()
		elseif tag == 2 then
			onInfo()
		end
	elseif self._curView == VIEW_TYPE.BAG_SKILL then
		if tag == 1 then
			onQiangHu()
		elseif tag == 2 then
			onJingLian()
		elseif tag == 3 and self._showType == 1 then
			onInfo()
		end
	end
end

function BagScene:updateBageItem()
	self._canSaleItems = {}
	self._rootnode.maxNumLabel:setString(self._cap[self._curView][2] or 0)
	self._rootnode.curNumLabel:setString(self._cap[self._curView][1] or 0)
	self:getSaleItems()
	self._showType = 1
	local function createFunc(idx)
		local item = Item[self._curView].new()
		idx = idx + 1
		if self._showType == 1 then
			return item:create({
			itemData = self._item[self._curView][idx],
			viewSize = self._rootnode.listView:getContentSize(),
			idx = idx,
			itemType = self._showType,
			useListener = handler(self, BagScene.onBtn),
			bChoose = self._chooseItems[idx]
			})
		else
			return item:create({
			itemData = self._canSaleItems[idx],
			viewSize = self._rootnode.listView:getContentSize(),
			idx = idx,
			itemType = self._showType,
			bChoose = self._chooseItems[idx]
			})
		end
	end
	self._chooseItems = {}
	local function refreshFunc(cell, idx)
		idx = idx + 1
		if self._showType == 1 then
			cell:refresh({
			itemData = self._item[self._curView][idx],
			itemType = self._showType,
			bChoose = self._chooseItems[idx],
			idx = idx
			})
		else
			cell:refresh({
			itemData = self._canSaleItems[idx],
			itemType = self._showType,
			bChoose = self._chooseItems[idx],
			idx = idx
			})
		end
	end
	self._chooseNum = 0
	self._saleMoney = 0
	local function onTouchCell(cell)
		if self._showType == 1 then
			return
		end
		local idx = cell:getIdx() + 1
		local count, money
		if self._curView == VIEW_TYPE.BAG_ITEM then
			count = self._canSaleItems[idx].itemCnt
			money = data_item_item[self._canSaleItems[idx].itemId].price
		elseif self._curView == VIEW_TYPE.BAG_SKILL then
			count = 1
			local data_kongfu_kongfu = require("data.data_kongfu_kongfu")
			local silver = (data_kongfu_kongfu[self._canSaleItems[idx].level + 1].sumexp[self._canSaleItems[idx].star] + self._canSaleItems[idx].curExp) * 5 * (self._canSaleItems[idx].star - 1)
			silver = silver + data_item_item[self._canSaleItems[idx].resId].price
			money = silver
		elseif self._curView == VIEW_TYPE.BAG_GIFT then
			count = self._canSaleItems[idx].itemCnt
			money = data_item_item[self._canSaleItems[idx].itemId].price
		end
		if self._chooseItems[idx] then
			self._chooseItems[idx] = false
			self._chooseNum = self._chooseNum - 1
			self._saleMoney = self._saleMoney - money * count
		else
			self._chooseItems[idx] = true
			self._chooseNum = self._chooseNum + 1
			self._saleMoney = self._saleMoney + money * count
		end
		cell:touch(self._chooseItems[idx])
		self._rootnode.selectedLabel:setString(tostring(self._chooseNum))
		self._rootnode.costMaxLabel:setString(tostring(self._saleMoney))
	end
	if self._bagItemList then
		self._bagItemList:removeSelf()
	end
	self._bagItemList = require("utility.TableViewExt").new({
	size = self._rootnode.listView:getContentSize(),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._item[self._curView],
	cellSize = Item[self._curView].new():getContentSize(),
	touchFunc = onTouchCell
	})
	self._bagItemList:setPosition(0, 0)
	self._rootnode.listView:addChild(self._bagItemList)
	self._rootnode.selectedLabel:setString(tostring(self._chooseNum))
	self._rootnode.costMaxLabel:setString(tostring(self._saleMoney))
end

function BagScene:onSaleView()
	self._showType = 2
	self._chooseItems = {}
	self:updateList()
	self._rootnode.saleInfoView:setVisible(true)
	self._rootnode.bottomNode:setVisible(false)
end

function BagScene:onUseView()
	self._showType = 1
	self._bagItemList:resetCellNum(#self._item[self._curView], false, false)
	self._rootnode.saleInfoView:setVisible(false)
	self._rootnode.bottomNode:setVisible(true)
end

function BagScene:onEnter()
	game.runningScene = self
	--self:regNotice()
	BagScene.super.onEnter(self)
	if self._bExit then
		local broadcastBg = self._rootnode.broadcast_tag
		game.broadcast:reSet(broadcastBg)
	end
	if self._bExit then
		self._bagItemList:resetCellNum(#self._item[self._curView], false, false)
		self._bExit = false
	end
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function BagScene:initdata(data1, data2, data3)
	game.player:setSkills(data1["1"])
	self._item[VIEW_TYPE.BAG_SKILL] = game.player:getSkills()
	self._cap[VIEW_TYPE.BAG_SKILL] = {
	data1["2"],
	data1["3"]
	}
	self._cost[VIEW_TYPE.BAG_SKILL] = {
	data1["4"],
	data1["5"]
	}
	self._item[VIEW_TYPE.BAG_ITEM] = data2["1"]
	self._cap[VIEW_TYPE.BAG_ITEM] = {
	data2["2"],
	data2["3"]
	}
	self._cost[VIEW_TYPE.BAG_ITEM] = {
	data2["4"],
	data2["5"]
	}
	self._item[VIEW_TYPE.BAG_GIFT] = data3["1"]
	self._cap[VIEW_TYPE.BAG_GIFT] = {
	data3["2"],
	data3["3"]
	}
	self._cost[VIEW_TYPE.BAG_GIFT] = {
	data3["4"],
	data3["5"]
	}
	self:updateBageItem()
end

function BagScene:onEnterTransitionFinish()
	
end

function BagScene:onExit()
	--self:unregNotice()
	BagScene.super.onExit(self)
	self._bExit = true
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return BagScene