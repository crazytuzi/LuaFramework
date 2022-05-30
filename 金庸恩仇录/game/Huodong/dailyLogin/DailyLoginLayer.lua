local ZORDER = 100
local listViewDisH = 95

local DailyLoginLayer = class("DailyLoginLayer", function()
	return require("utility.ShadeLayer").new()
end)

function DailyLoginLayer:getDailyLoginInfo()
	RequestHelper.dailyLoginReward.getInfo({
	callback = function(data)
		dump(data)
		self:init(data)
	end
	})
end

function DailyLoginLayer:onReward(cell)
	if self.isFull then
		self:addChild(require("utility.LackBagSpaceLayer").new({
		bagObj = self.bagObj,
		callback = function()
			self.isFull = false
		end
		}), ZORDER)
	else
		RequestHelper.dailyLoginReward.getReward({
		callback = function(data)
			cell:setRewardEnabled(true)
			if string.len(data["0"]) > 0 then
				show_tip_label(data["0"])
			else
				self.isSign = true
				cell:getReward(self.isSign)
				game.player:updateMainMenu({
				silver = data["1"].silver,
				gold = data["1"].gold
				})
				PostNotice(NoticeKey.MainMenuScene_Update)
				game.player:setQiandaoNum(game.player:getQiandaoNum() - 1)
				PostNotice(NoticeKey.MainMenuScene_Qiandao)
				local title = common:getLanguageString("GetRewards")
				local index = cell:getIdx() + 1
				local msgBox = require("game.Huodong.RewardMsgBox").new({
				title = title,
				cellDatas = self.cellDatas[index].itemData,
				confirmFunc = function()
					TutoMgr.active()
				end
				})
				self:addChild(msgBox, ZORDER)
			end
		end,
		day = cell:getIdx() + 1
		})
	end
end

function DailyLoginLayer:onInformation(param)
	if self._curInfoIndex ~= -1 then
		return
	end
	local index = param.index
	self._curInfoIndex = index
	local iconIdx = param.iconIndex
	local icon_data = self.cellDatas[index + 1].itemData[iconIdx]
	if icon_data then
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = icon_data.id,
		type = icon_data.type,
		name = icon_data.name,
		describe = icon_data.describe,
		endFunc = function()
			self._curInfoIndex = -1
		end
		})
		self:addChild(itemInfo, ZORDER)
	end
end

function DailyLoginLayer:init(data)
	if string.len(data["0"]) > 0 then
		CCMessageBox(data["0"], "Tip")
		return
	end
	local data_item_item = require("data.data_item_item")
	local curDay = data["1"]
	self.isFull = data["2"] or false
	self.isSign = data["3"]
	self.giftList = data["4"]
	self.bagObj = data["5"]
	self.cellDatas = {}
	for _, v in ipairs(self.giftList) do
		local itemData = {}
		for i, j in ipairs(v.item) do
			local item = data_item_item[j.id]
			local iconType = ResMgr.getResType(j.type)
			if iconType == ResMgr.HERO then
				item = ResMgr.getCardData(j.id)
			end
			table.insert(itemData, {
			id = j.id,
			type = j.type,
			name = item.name,
			describe = item.describe,
			iconType = iconType,
			num = j.num or 0
			})
		end
		table.insert(self.cellDatas, {
		id = v.id,
		itemData = itemData
		})
	end
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height - listViewDisH
	local function createFunc(index)
		local item = require("game.Huodong.dailyLogin.DailyLoginCell").new()
		return item:create({
		id = index,
		totalDays = #self.cellDatas,
		curDay = curDay,
		isSign = self.isSign,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		cellData = self.cellDatas[index + 1],
		rewardListener = handler(self, DailyLoginLayer.onReward),
		informationListener = handler(self, DailyLoginLayer.onInformation)
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = self.cellDatas[index + 1].itemData
		})
	end
	local cellContentSize = require("game.Huodong.dailyLogin.DailyLoginCell").new():getContentSize()
	self._rootnode.touchNode:setTouchEnabled(true)
	local posX = 0
	local posY = 0
	self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
		posX = event.x
		posY = event.y
	end)
	self.ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.cellDatas,
	cellSize = cellContentSize,
	touchFunc = function(cell,x,y)
		local idx = cell:getIdx()
		for i = 1, 4 do
			local icon = cell:getIcon(i)
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				self:onInformation({index = idx, iconIndex = i})
				break
			end
		end
	end
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self.ListTable)
	local tutoCell = self.ListTable:cellAtIndex(0)
	local tutoBtn = tutoCell:getTutoBtn()
	if tutoBtn ~= nil then
		TutoMgr.addBtn("qiandao_page_lingqu_btn", tutoBtn)
	end
	local pageCount = self.ListTable:getViewSize().height / cellContentSize.height
	local maxMove = #self.cellDatas - pageCount
	local tmpDay = curDay - 1
	if maxMove < tmpDay then
		tmpDay = maxMove
	end
	local curIndex = maxMove - tmpDay
	self.ListTable:setContentOffset(CCPoint(0, -(curIndex * cellContentSize.height)))
	TutoMgr.active()
end

function DailyLoginLayer:onExit()
	TutoMgr.removeBtn("qiandao_page_lingqu_btn")
	TutoMgr.removeBtn("qiandao_page_close_btn")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

function DailyLoginLayer:ctor(data)
	self._curInfoIndex = -1
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self:setNodeEventEnabled(true)
	local node = CCBuilderReaderLoad("reward/normal_reward_bg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@CheckInReward"))
	
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		sender:runAction(transition.sequence({
		CCCallFunc:create(function()
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			self:removeSelf()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	TutoMgr.addBtn("qiandao_page_close_btn", self._rootnode.tag_close)
	self:init(data)
end

return DailyLoginLayer