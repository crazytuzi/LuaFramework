local BaseScene = require("game.BaseSceneExt")
local RankListScene = class("RankListScene", BaseScene)
--[[
local RankListScene = class("RankListScene", function()
	display.addSpriteFramesWithFile("ui/rank_list.plist", "ui/rank_list.png")
	return require("game.BaseSceneExt").new({
	bottomFile = "public/bottom_frame.ccbi",
	topFile = "nbhuodong/nbhuodong_top.ccbi"
	})
end)
]]

function RankListScene:ctor()
	display.addSpriteFramesWithFile("ui/rank_list.plist", "ui/rank_list.png")
	RankListScene.super.ctor(self, {
	bottomFile = "public/bottom_frame.ccbi",
	topFile = "nbhuodong/nbhuodong_top.ccbi"
	})
	
	self.layerTable = {}
	self.listType = 1
	local viewSize = cc.size(display.width, self:getContentHeight())
	self.baseNode = display.newNode()
	self.baseNode:setContentSize(viewSize)
	self.baseNode:setPosition(display.cx, self:getBottomHeight())
	self:addChild(self.baseNode)
	local proxy = CCBProxy:create()
	local contentNode = CCBuilderReaderLoad("rankList/rank_list_bg.ccbi", proxy, self._rootnode, self, viewSize)
	self.baseNode:addChild(contentNode)
	self.tableScaleBgSize = cc.size(display.width * 0.95, self:getContentHeight() - self._rootnode.up_node:getContentSize().height)
	self.tableViewSize = cc.size(self.tableScaleBgSize.width, self.tableScaleBgSize.height * 0.96)
	local listWorldPos = self._rootnode.table_bg:convertToWorldSpace(ccp(0, 0))
	self.tableRect = cc.rect(listWorldPos.x, listWorldPos.y, display.width, self.tableScaleBgSize.height)
	self._rootnode.table_scale_bg:setContentSize(self.tableScaleBgSize)
	self:initHead()
	self:updateLayer()
end

function RankListScene:sendListReq(type)
	RankListModel.sendListReq({
	callback = function()
		self:initListByType(type)
		self:initUpDetail(type)
	end,
	listType = type
	})
end

function RankListScene:initUpDetail(type)
	if self.listType ~= type then
		if self.layerTable[type] then
			self.layerTable[type]:setVisible(false)
		end
		return
	end
	local myRankData = RankListModel.getMyRank(type)
	local curRank = myRankData.rank
	local rankNode = self._rootnode["ttf_" .. type .. "_1"]
	if curRank ~= nil and curRank ~= 0 then
		rankNode:setString(curRank)
	else
		rankNode:setString("")
		local norecord = ResMgr.createShadowMsgTTF({
		text = common:getLanguageString("@OverRank2000"),
		color = cc.c3b(255, 222, 0),
		size = 24
		})
		norecord:align(display.LEFT_CENTER, rankNode:getPosition())
		rankNode:getParent():addChild(norecord)
	end
	local rightTTF
	if type == 1 then
		rightTTF = myRankData.grade
	elseif type == 2 then
		rightTTF = myRankData.attack
	elseif type == 3 then
		rightTTF = myRankData.battleStars
	elseif type == 4 then
		rightTTF = myRankData.prestige
	end
	self._rootnode["ttf_" .. type .. "_2"]:setString(rightTTF)
	if self._rootnode["right_icon_" .. type] ~= nil then
		local iconPos = ccp(self._rootnode["ttf_" .. type .. "_2"]:getPositionX() + self._rootnode["ttf_" .. type .. "_2"]:getContentSize().width, self._rootnode["ttf_" .. type .. "_2"]:getPositionY())
		self._rootnode["right_icon_" .. type]:setPosition(iconPos)
	end
	if type == 1 then
		alignNodesOneByOne(self._rootnode.label1, self._rootnode.ttf_1_1)
		alignNodesOneByOne(self._rootnode.label2, self._rootnode.ttf_1_2)
	elseif type == 2 then
		alignNodesOneByOne(self._rootnode.label3, self._rootnode.ttf_2_1)
		alignNodesOneByOne(self._rootnode.label4, self._rootnode.ttf_2_2)
	elseif type == 3 then
		alignNodesOneByOne(self._rootnode.label5, self._rootnode.ttf_3_1)
		alignNodesOneByOne(self._rootnode.label6, self._rootnode.ttf_3_2)
		alignNodesOneByOne(self._rootnode.ttf_3_2, self._rootnode.right_icon_3)
	elseif type == 4 then
		alignNodesOneByOne(self._rootnode.label7, self._rootnode.ttf_4_1)
		alignNodesOneByOne(self._rootnode.label8, self._rootnode.ttf_4_2)
		alignNodesOneByOne(self._rootnode.ttf_4_2, self._rootnode.right_icon_4)
	end
end

function RankListScene:initListByType(type)
	local listData = RankListModel.getList(type)
	local function createFunc(idx)
		local item = require("game.RankListScene.RankListCell").new(i)
		return item:create({
		tableViewRect = self.tableRect,
		id = idx + 1,
		cellType = type
		})
	end
	local refreshFunc = function(cell, idx)
		cell:refresh(idx + 1)
	end
	local cellSize = require("game.RankListScene.RankListCell").new():getContentSize()
	local expandSize = cc.size(cellSize.width, cellSize.height + 10)
	local itemList = require("utility.TableViewExt").new({
	size = self.tableViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #listData,
	cellSize = expandSize
	})
	self._rootnode.table_bg:addChild(itemList)
	itemList:setPosition(0, 5)
	self.layerTable[type] = itemList
end

function RankListScene:uptoIndexByCheck(index)
	if index == 4 then
		ResMgr.runFuncByOpenCheck({
		openKey = OPENCHECK_TYPE.JingJiChang,
		openFunc = function()
			self:updateByIndex(index)
		end
		})
	else
		self:updateByIndex(index)
	end
end

function RankListScene:updateByIndex(index)
	if self.listType ~= index then
		self.listType = index
		self:updateLayer()
	end
end

function RankListScene:initHead()
	local icons = {
	"lvl_rank_icon",
	"battle_rank_icon",
	"jianghu_rank_icon",
	"arena_rank_icon"
	}
	self._data = {}
	for i = 1, #icons do
		local curData = {}
		curData.icon = icons[i]
		self._data[#self._data + 1] = curData
	end
	local function createFunc(index)
		local item = require("game.nbactivity.ActivityItem").new()
		return item:create({
		viewSize = cc.size(self._rootnode.headList:getContentSize().width, self._rootnode.headList:getContentSize().height),
		itemData = self._data[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		local selected = false
		if index == self._cellIndex then
			selected = true
		end
		cell:refresh(self._data[index + 1], selected)
	end
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.headList:getContentSize().width, self._rootnode.headList:getContentSize().height),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._data,
	cellSize = require("game.nbactivity.ActivityItem").new():getContentSize(),
	touchFunc = function(cell)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		local id = cell:getId()
		local index = cell:getIdx() + 1
		self:uptoIndexByCheck(index)
	end
	})
	self._rootnode.headList:addChild(self._scrollItemList)
end

function RankListScene:updateLayer()
	self._cellIndex = self.listType - 1
	for i = 0, self._scrollItemList:getCellNum() - 1 do
		local item = self._scrollItemList:cellAtIndex(i)
		if item ~= nil then
			if self._cellIndex == i then
				item:setSelected(true)
			else
				item:setSelected(false)
			end
		end
	end
	for i = 1, 4 do
		if self.listType == i then
			if self.layerTable[i] ~= nil then
				self.layerTable[i]:setVisible(true)
				self.layerTable[i]:reloadData()
			else
				self:sendListReq(i)
			end
			self._rootnode["node_" .. i]:setVisible(true)
		else
			if self.layerTable[i] ~= nil then
				self.layerTable[i]:setVisible(false)
			end
			self._rootnode["node_" .. i]:setVisible(false)
		end
	end
end

function RankListScene:onEnter()
	ResMgr.removeBefLayer()
	--self:regNotice()
	RankListScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function RankListScene:onExit()
	--self:unregNotice()
	RankListScene.super.onExit(self)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return RankListScene