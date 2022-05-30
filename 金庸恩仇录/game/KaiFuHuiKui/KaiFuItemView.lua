local data_item_item = require("data.data_item_item")
local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")
local data_missiondefine_missiondefine = require("data.data_missiondefine_missiondefine")
local MAX_ZORDER = 1111
local KaiFuItemView = class("KaiFuItemView", function ()
	return CCTableViewCell:new()
end)
function KaiFuItemView:getContentSize()
	return cc.size(620, 185)
end
function KaiFuItemView:getIconNum()
	return 1
end
function KaiFuItemView:getIcon(index)
	return self._clickIcon
end
function KaiFuItemView:getIconData(index)
	return self._clickData
end
function KaiFuItemView:refreshItem(param)
	self._type = param.type
	self:removeAllChildren()
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/kaifukuanghuan_item.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0, 0))
	self:addChild(node, 0, 111)
	self._rootnode.touchNode:setZOrder(100)
	self._rootnode.touchNode:setTouchEnabled(true)
	local posX = 0
	local posY = 0
	self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
		posX = event.x
		posY = event.y
	end)
	self._data = param.itemData.rewords
	self._itemData = param.itemData
	local boardWidth = self._rootnode.listview:getContentSize().width
	local boardHeight = self._rootnode.listview:getContentSize().height
	local function createFunc(index)
		local item = require("game.KaiFuHuiKui.KaiFuCell").new()
		return item:create({
		index = index,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		itemData = self._data[index + 1],
		confirmFunc = showBuyBox
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = self._data[index + 1],
		confirmFunc = showBuyBox
		})
	end
	local cellContentSize = require("game.KaiFuHuiKui.KaiFuCell").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = CCSizeMake(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._data,
	cellSize = cellContentSize,
	direction = kCCScrollViewDirectionHorizontal,
	touchFunc = function (cell)
		for i = 1, cell:getIconNum() do
			local icon = cell:getIcon(i)
			local pos = icon:convertToNodeSpace(ccp(posX, posY))
			if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
				self._clickIcon = icon
				self._clickData = cell:getIconData()
				break
			end
		end
	end
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.listview:setZOrder(101)
	self._rootnode.listview:addChild(self.ListTable)
	self._rootnode.listview:setPositionY(self._rootnode.listview:getPositionY() + 5)
	self._rootnode.title:setString(self._itemData.dis)
	local function updateFunc(data)
		self._rootnode.rewardBtn:setVisible(false)
		self._rootnode.getok:setVisible(true)
		local dataTemp = {}
		for k, v in pairs(data.probs) do
			local temp = {}
			temp.id = v.id
			temp.num = v.n
			temp.type = v.t
			temp.iconType = ResMgr.getResType(v.t)
			if temp.type == 8 then
				temp.name = require("data.data_card_card")[v.id].name
			else
				temp.name = require("data.data_item_item")[v.id].name
			end
			table.insert(dataTemp, temp)
		end
		local msgBox = require("game.Huodong.RewardMsgBox").new({
		title = common:getLanguageString("@RewardList"),
		cellDatas = dataTemp
		})
		CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
		if param.confirmFunc then
			param.confirmFunc(self._itemData.achid, self._itemData.type)
		end
		self._itemData.state = 3
		game.player:updateMainMenu({
		silver = data.silver,
		gold = data.gold
		})
		PostNotice(NoticeKey.MainMenuScene_Update)
		require("game.Spirit.SpiritCtrl").clear()
	end
	self._rootnode.rewardBtn:addHandleOfControlEvent(function (eventName, sender)
		local function selectFunction(index)
			RequestHelper.kaifukuanghuan.getItem({
			callback = function (data)
				dump(data)
				if data["0"] ~= "" then
					dump(data["0"])
				elseif data.rtnObj.checkBag and #data.rtnObj.checkBag > 0 then
					local layer = require("utility.LackBagSpaceLayer").new({
					bagObj = data.rtnObj.checkBag
					})
					CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
				else
					updateFunc(data.rtnObj)
				end
			end,
			dayIndex = self._itemData.dayIndex,
			option = index or 0,
			id = self._itemData.achid,
			type = self._type
			})
		end
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if self._itemData.type == 2 or self._itemData.type == 6 then
			local disLayer = require("game.KaiFuHuiKui.KaiFuGetView").new({
			itemData = self._data,
			discription = self._itemData.description,
			commitFuc = selectFunction,
			type = self._itemData.type,
			_type = self._type
			})
			CCDirector:sharedDirector():getRunningScene():addChild(disLayer, 1000)
			return
		end
		selectFunction()
	end,
	CCControlEventTouchUpInside)
	self._rootnode["goto"]:addHandleOfControlEvent(function (eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(data_missiondefine_missiondefine[self._itemData.achid].navigation)
	end,
	CCControlEventTouchUpInside)
	self._rootnode.gocharge:addHandleOfControlEvent(function (eventName, sender)
		local chongzhiLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
		game.runningScene:addChild(chongzhiLayer, MAX_ZORDER)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	if self._itemData.type == 1 then
		self._rootnode["rewardBtn"]:setVisible(self._itemData.state ~= 3)
		self._rootnode["rewardBtn"]:setEnabled(self._itemData.state == 2)
	elseif self._itemData.type == 2 then
		self._rootnode["rewardBtn"]:setVisible(self._itemData.state ~= 3)
		self._rootnode["rewardBtn"]:setEnabled(self._itemData.state == 2)
	elseif self._itemData.type == 3 then
		if data_missiondefine_missiondefine[self._itemData.achid].navigation then
			self._rootnode["goto"]:setVisible(self._itemData.state == 1)
			self._rootnode["rewardBtn"]:setVisible(self._itemData.state == 2)
		else
			self._rootnode["nook"]:setVisible(self._itemData.state == 1)
			self._rootnode["rewardBtn"]:setVisible(self._itemData.state == 2)
		end
	elseif self._itemData.type == 4 then
	elseif self._itemData.type == 5 or self._itemData.type == 6 then
		self._rootnode.gocharge:setVisible(self._itemData.state == 1)
		self._rootnode.rewardBtn:setVisible(self._itemData.state == 2)
	end
	self._rootnode.getok:setVisible(self._itemData.state == 3)
	if self._itemData.isshow == 1 then
		if tonumber(self._itemData.curStep) >= tonumber(self._itemData.totalStep) then
			self._itemData.curStep = self._itemData.totalStep
		end
		self._rootnode.title:setString(self._itemData.dis .. "(" .. self._itemData.curStep .. "/" .. self._itemData.totalStep .. ")")
	end
	if KAIFU_ISSHOW_CONST then
		self._rootnode.rewardBtn:setVisible(false)
		self._rootnode.goto:setVisible(false)
		self._rootnode.gocharge:setVisible(false)
		self._rootnode.nook:setVisible(false)
		self._rootnode.getok:setVisible(false)
		if self._itemData.state == 1 then
			self._rootnode.nook:setVisible(true)
		elseif self._itemData.state == 3 then
			self._rootnode.getok:setVisible(true)
		elseif self._itemData.state == 2 then
			self._rootnode.rewardBtn:setVisible(true)
		end
	end
end

function KaiFuItemView:getRewardBtn()
	return self._rootnode.rewardBtn
end

function KaiFuItemView:create(param)
	self:refreshItem(param)
	return self
end

function KaiFuItemView:refresh(param)
	self:refreshItem(param)
end
return KaiFuItemView