local BaseScene = require("game.BaseScene")
local FriendScene = class("FriendScene", BaseScene)

local ORANGE_COLOR = cc.c3b(255, 210, 0)
local GREEN_COLOR = cc.c3b(0, 219, 52)
local FRIEND_TYPE = 1
local RECOMMEND_TYPE = 2
local NAILI_TYPE = 3
local REQUEST_TYPE = 4
local MAX_TAB_NUM = 5
local RED_NUM_TAG = 29

function FriendScene:ctor(tag)
	FriendScene.super.ctor(self, {
	contentFile = "friend/friend_list_bg.ccbi",
	subTopFile = "friend/friend_up_tab.ccbi"
	})
	
	ResMgr.removeBefLayer()
	game.runningScene = self
	self.tab = 1
	self.tableViewVec = {}
	FriendModel.initReq({
	callback = function()
		self:init()
		self:updateTab()
	end
	})
end

function FriendScene:init()
	self:initTableviews()
	self:initDetailNode()
	self:initTab()
	self:initTimeNode()
end

function FriendScene:initTimeNode()
	self.timeNode = display.newNode()
	self:addChild(self.timeNode)
	FriendModel.chatListReq()
	self.timeNode:schedule(function()
		FriendModel.chatListReq()
	end,
	FriendModel.REQ_INTERVAL)
end

function FriendScene:initTab()
	local tabs = {}
	self.redBgs = {}
	for i = 1, MAX_TAB_NUM do
		tabs[i] = self._rootnode["tab" .. i]
		local tabBtn = self._rootnode["tab" .. i]
		tabBtn:addHandleOfControlEvent(function()
			if self.isAllow then
				self.tab = i
				self:updateTab(i)
			end
		end,
		CCControlEventTouchUpInside)
		
		local redbg = display.newSprite("ui/new_btn/red_num_bg.png")
		redbg:setPosition(tabBtn:getContentSize().width * 0.75, tabBtn:getContentSize().height - 5)
		redbg:setVisible(false)
		local numLabel = ui.newTTFLabel({
		text = "1",
		font = FONTS_NAME.font_fzcy,
		size = 18
		})
		numLabel:setPosition(redbg:getContentSize().width / 2, redbg:getContentSize().height / 2)
		redbg:addChild(numLabel)
		numLabel:setTag(RED_NUM_TAG)
		self.redBgs[i] = redbg
		tabBtn:addChild(redbg)
		self:updateTabNum(i)
		
	end
end
function FriendScene:initTableviews()
	self.initTabAlready = true
	for i = 1, MAX_TAB_NUM do
		
		local node = self._rootnode["node_" .. i]
		if node ~= nil then
			node:retain()
		end
		local tableBgSize = self._rootnode.list_view:getContentSize()
		local curTablePosY = 0
		for nodeCount = 1, 2 do
			local curNode = self._rootnode["node_" .. i .. "_" .. nodeCount]
			if curNode ~= nil then
				tableBgSize.height = tableBgSize.height - curNode:getContentSize().height
				if nodeCount == 1 then
					curTablePosY = curNode:getContentSize().height
				end
			end
		end
		local listWorldPos = self._rootnode.list_view:convertToWorldSpace(ccp(0, curTablePosY))
		local tableRect = cc.rect(listWorldPos.x, listWorldPos.y, tableBgSize.width, tableBgSize.height)
		local function createFunc(idx)
			local item = require("game.Friend.FriendCell").new(i)
			return item:create({
			tableViewRect = tableRect,
			id = idx + 1
			})
		end
		local refreshFunc = function(cell, idx)
			cell:refresh(idx + 1)
		end
		local dataList = FriendModel.getList(i)
		local itemList = require("utility.TableViewExt").new({
		size = tableBgSize,
		direction = kCCScrollViewDirectionVertical,
		createFunc = createFunc,
		refreshFunc = refreshFunc,
		cellNum = #dataList,
		cellSize = require("game.Friend.FriendCell").new(i):getContentSize()
		})
		self._rootnode.list_view:addChild(itemList)
		itemList:setPosition(0, curTablePosY)
		self.tableViewVec[i] = itemList
		
	end
end

function FriendScene:onMoreBtn()
	FriendModel.updateRecommendList()
end

function FriendScene:onRecieveAll()
	FriendModel.getAllNailiReq()
end

function FriendScene:onAgreeAll()
	FriendModel.acceptAllReq()
end

function FriendScene:onRejectAll()
	FriendModel.rejectAll()
end

function FriendScene:upSearchType()
	for i = 1, 2 do
		if i == FriendModel.searchType + 1 then
			self._rootnode["search_" .. tostring(i)]:selected()
		else
			self._rootnode["search_" .. tostring(i)]:unselected()
		end
	end
end

function FriendScene:initSearch()
	FriendModel.searchType = FRIEND_SERACH.BY_ID
	for i = 1, 2 do
		self._rootnode["search_" .. tostring(i)]:registerScriptTapHandler(function(tag)
			if FriendModel.searchType ~= i - 1 then
				FriendModel.searchType = i - 1
				FriendModel.isSearch = false
				self:cleanSearchContent()
				if i == 1 then
					self._editBox:setPlaceHolder(common:getLanguageString("@FriendIdSearch"))
				else
					self._editBox:setPlaceHolder(common:getLanguageString("@FriendNickSearch"))
				end
			end
			self:upSearchType()
		end)
	end
	
	ResMgr.setControlBtnEvent(self._rootnode.search_btn, function()
		self:startSearch()
	end)
	
	self:initEditBox()
	self:upSearchType()
end

function FriendScene:cleanSearchContent()
	FriendModel.searchContent = ""
	self._editBox:setText("")
end

function FriendScene:startSearch()
	FriendModel.searchContent = tostring(self._editBox:getText())
	FriendModel.startSearch()
end

function FriendScene:cleanEditBox()
	if self._editBox ~= nil then
		self._editBox:removeSelf()
		self._editBox = nil
	end
end

function FriendScene:initEditBox()
	local boxSize = self._rootnode.ed_box:getContentSize()
	self._editBox = ui.newEditBox({
	image = "#text_frame.png",
	size = boxSize,
	x = self._rootnode.ed_box:getPositionX() + boxSize.width / 2,
	y = self._rootnode.ed_box:getPositionY()
	})
	self._rootnode.ed_box:getParent():addChild(self._editBox)
	self._editBox:setFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setFontColor(FONT_COLOR.WHITE)
	self._editBox:setMaxLength(FriendModel.MAX_NAME_LEN)
	self._editBox:setPlaceHolder(common:getLanguageString("@FriendIdSearch"))
	self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	self.isAllow = true
	local function editboxEventHandler(eventType)
		if eventType == "began" then
			self.isAllow = false
			self._editBox:setEnabled(false)
		elseif eventType == "ended" then
			self.isAllow = true
			self._editBox:setEnabled(true)
			self.isAllow = true
		elseif eventType == "changed" then
		elseif eventType == "return" then
		end
	end
	self._editBox:registerScriptEditBoxHandler(editboxEventHandler)
end

function FriendScene:initDetailNode()
	self:initSearch()
	ResMgr.setControlBtnEvent(self._rootnode.more_btn, function()
		self:onMoreBtn()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.receive_all, function()
		self:onRecieveAll()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.agree_all, function()
		self:onAgreeAll()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.reject_all, function()
		self:onRejectAll()
	end)
	local orX, orY = self._rootnode.rest_claim_time:getPosition()
	local orNode = self._rootnode.rest_claim_time:getParent()
	self.restNaili = ResMgr.createShadowMsgTTF({
	size = 26,
	text = common:getLanguageString("@TodayTimeLeft"),
	color =  cc.c3b(255, 255, 255)
	})
	orNode:addChild(self.restNaili)
	self.restNaili:align(display.LEFT_CENTER, orX, orY)
	
	self.restNailiNum = ResMgr.createShadowMsgTTF({
	size = 26,
	text = "0",
	color = cc.c3b(0, 219, 52)
	})
	orNode:addChild(self.restNailiNum)
	self.restNailiNum:align(display.LEFT_CENTER, orX + self.restNaili:getContentSize().width, orY)
	
	for i = 1, MAX_TAB_NUM do
		self:updateDownByIndex(i)
	end
	
end

function FriendScene:updateTab()
	for i = 1, MAX_TAB_NUM do
		local node = self._rootnode["node_" .. i]
		if i == self.tab then
			if node ~= nil and node:getParent() == nil then
				self._rootnode.infoView:addChild(node)
				node:setVisible(true)
			end
			self.tableViewVec[i]:setVisible(true)
			self._rootnode["tab" .. i]:setEnabled(false)
		else
			if node ~= nil then
				node:removeSelf()
			end
			self.tableViewVec[i]:setVisible(false)
			self._rootnode["tab" .. i]:setEnabled(true)
		end
	end
end

function FriendScene:updateTabNum(index)
	local showNum = 0
	local dataList = FriendModel.getList(index)
	if index == 1 then
		showNum = FriendModel.getChatNum()
	elseif index == 2 or index == 5 then
	else
		showNum = #dataList
	end
	if showNum > 0 then
		self.redBgs[index]:setVisible(true)
		self.redBgs[index]:getChildByTag(RED_NUM_TAG):setString(tostring(showNum))
	else
		self.redBgs[index]:setVisible(false)
	end
end

function FriendScene:updateByIndex(index)
	local dataList = FriendModel.getList(index)
	self.tableViewVec[index]:reArrangeCell(#dataList)
	self:updateTabNum(index)
	self:updateDownByIndex(index)
end

function FriendScene:updateDownByIndex(index)
	if index == FRIEND_TYPE then
		self:updateFriendNum()
	elseif index == NAILI_TYPE then
		self:updateNailiDown()
	elseif index == REQUEST_TYPE then
		self:updateReqDown()
	end
end

function FriendScene:updateFriendNum()
	local data_config_config = require("data.data_config_config")
	local dataList = FriendModel.getList(FRIEND_TYPE)
	local curNum = #dataList
	local maxNum = data_config_config[1].max_friend_num
	self._rootnode.curNum:setString(curNum)
	self._rootnode.maxNum:setString(maxNum)
	local xiedai = self._rootnode.xiedai
	local curNum = self._rootnode.curNum
	local sign = self._rootnode.sign
	local maxNum = self._rootnode.maxNum
	curNum:setPosition(xiedai:getPositionX() + xiedai:getContentSize().width, xiedai:getPositionY())
	sign:setPosition(curNum:getPositionX() + curNum:getContentSize().width, xiedai:getPositionY())
	maxNum:setPosition(sign:getPositionX() + sign:getContentSize().width, xiedai:getPositionY())
end

function FriendScene:updateNailiDown()
	local restNum = FriendModel.restNailiNum
	self.restNailiNum:setString(restNum)
	if restNum > 0 then
		self._rootnode.receive_all:setEnabled(true)
	else
		self._rootnode.receive_all:setEnabled(false)
	end
end

function FriendScene:updateReqDown()
	local dataList = FriendModel.getList(REQUEST_TYPE)
	if #dataList > 0 then
	else
	end
end

function FriendScene:reloadBroadcast()
	local broadcastBg = self._rootnode.broadcast_tag
	game.broadcast:reSet(broadcastBg)
end

function FriendScene:updateLabel()
	self._rootnode.goldLabel:setString(game.player:getGold())
	self._rootnode.silverLabel:setString(game.player:getSilver())
end

function FriendScene:onEnter()
	game.runningScene = self
	FriendScene.super.onEnter(self)
	RegNotice(self, function(event, index)
		self:updateByIndex(tonumber(index))
	end,
	NoticeKey.UPDATE_FRIEND)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function FriendScene:onExit()
	self._bExit = true
	FriendScene.super.onExit(self)
	UnRegNotice(self, NoticeKey.UPDATE_FRIEND)
	if self.initTabAlready == true then
		for i = 1, 4 do
			self._rootnode["node_" .. i]:release()
		end
	end
end

return FriendScene