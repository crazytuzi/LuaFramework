local MAX_ZORDER = 1111

local LeijiLoginLayer = class("LeijiLoginLayer", function()
	return display.newNode()
end)

function LeijiLoginLayer:getStatusData()
	RequestHelper.leijiLogin.getStatusData({
	callback = function(data)
		self:initData(data)
	end
	})
end

function LeijiLoginLayer:ctor(param)
	local viewSize = param.viewSize
	self._rewardDatas = param.rewardDatas
	dump(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/leijiLogin_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(node)
	local titleIcon = self._rootnode.title_icon
	local msgNode = self._rootnode.msg_node
	self._rootnode.msg_node:setPositionY(titleIcon:getPositionY() - titleIcon:getContentSize().height + 5)
	local listBgHeight = viewSize.height - titleIcon:getContentSize().height - msgNode:getContentSize().height + 15
	local listBg = display.newScale9Sprite("#month_item_bg_bg.png", 0, 0, CCSize(viewSize.width, listBgHeight))
	listBg:setAnchorPoint(0.5, 0)
	listBg:setPosition(display.cx, 0)
	node:addChild(listBg)
	self._listViewSize = cc.size(viewSize.width * 0.98, listBgHeight - 25)
	self._listViewNode = display.newNode()
	self._listViewNode:setContentSize(self._listViewSize)
	self._listViewNode:setAnchorPoint(0.5, 0.5)
	self._listViewNode:setPosition(display.cx, listBgHeight / 2)
	listBg:addChild(self._listViewNode)
	self:getStatusData()
end

function LeijiLoginLayer:initData(data)
	self._hasGetAry = data.hasGet
	self._hasLoginDays = data.days
	local activeTime = data.activeTime
	self._rootnode.time_lbl_2:setString(tostring(self._hasLoginDays))
	arrangeTTFByPosX({
	self._rootnode.time_lbl_2,
	self._rootnode.time_lbl_3
	})
	local starTime = activeTime[1] or ""
	local endTime = activeTime[2] or ""
	local timeStr = common:getLanguageString("@ActivityTime", starTime, endTime)
	local timeLbl = ResMgr.createShadowMsgTTF({
	text = timeStr,
	color = cc.c3b(0, 219, 52),
	shadowColor = cc.c3b(0, 0, 0),
	size = 20
	})
	
	ResMgr.replaceKeyLableEx(timeLbl, self._rootnode, "time_lbl", 0, 0)
	timeLbl:align(display.CENTER)
	
	self.startCellIndex = 1
	if #self._hasGetAry < self._hasLoginDays then
		table.sort(self._hasGetAry, function(a, b)
			return a < b
		end)
		local perCellIndex = 1
		for i = 1, self._hasLoginDays do
			if i > #self._hasGetAry then
				self.startCellIndex = i
				break
			end
			if i < self._hasGetAry[i] then
				self.startCellIndex = i
				break
			end
		end
	end
	self:initRewardListView()
end

function LeijiLoginLayer:initRewardListView()
	local function getReward(cell)
		RequestHelper.leijiLogin.getReward({
		day = cell:getDay(),
		callback = function(data)
			if data.result == 1 then
				game.player:updateMainMenu({
				gold = data.gold,
				silver = data.silver
				})
				table.insert(self._hasGetAry, cell:getDay())
				cell:getReward(self._hasGetAry)
				local title = common:getLanguageString("@GetRewards")
				local msgBox = require("game.Huodong.RewardMsgBox").new({
				title = title,
				cellDatas = self._rewardDatas[cell:getIdx() + 1].itemData
				})
				game.runningScene:addChild(msgBox, MAX_ZORDER)
			end
			
		end
		})
	end
	local function createFunc(index)
		local item = require("game.nbactivity.LeijiLogin.LeijiLoginItem").new()
		return item:create({
		viewSize = self._listViewSize,
		cellDatas = self._rewardDatas[index + 1],
		hasGetAry = self._hasGetAry,
		hasLoginDays = self._hasLoginDays,
		rewardListener = function(cell)
			getReward(cell)
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(self._rewardDatas[index + 1])
	end
	local cellContentSize = require("game.nbactivity.LeijiLogin.LeijiLoginItem").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = self._listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._rewardDatas,
	cellSize = cellContentSize
	})
	self.ListTable:setPosition(0, 0)
	self._listViewNode:addChild(self.ListTable)
	local pageCount = self.ListTable:getViewSize().height / cellContentSize.height
	local maxMove = #self._rewardDatas - pageCount
	local tmpDay = self.startCellIndex - 1
	if maxMove < tmpDay then
		tmpDay = maxMove
	end
	local curIndex = maxMove - tmpDay
	self.ListTable:setContentOffset(cc.p(0, -(curIndex * cellContentSize.height)))
end

return LeijiLoginLayer