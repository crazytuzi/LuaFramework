local BaseScene = require("game.BaseScene")
local HandBook = class("HandBook", BaseScene)
--[[
local HandBook = class("HandBook", function()
	return require("game.BaseScene").new({
	contentFile = "handbook/handbook_bg.ccbi",
	subTopFile = "handbook/handbook_up_tab.ccbi"
	})
end)
]]

local XIAKE = 1
local EQUIP = 2
local WUXUE = 3
local CHEATS = 4

local sumTab = 3

function HandBook:SendReq()
	RequestHelper.getHandBook({
	flag = 7,
	callback = function(data)
		HandBookModel.init(data)
		self:init()
	end
	})
end

function HandBook:init()
	self._index = 0
	self.subTag = {}
	self.subNode = {}
	self.mainNode = {}
	local function onMainTabBtn(tag)
		self.curTag = tag
		self:changeTabTo(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		for i = 1, sumTab do
			if i == tag then
				self._rootnode["btns_" .. i]:setVisible(true)
				self.mainNode[i]:setVisible(true)
			else
				self._rootnode["btns_" .. i]:setVisible(false)
				self.mainNode[i]:setVisible(false)
			end
		end
	end
	HandBookModel.viewBg = self._rootnode.dark_bg
	local darkHeight = self.getCenterHeight() - self._rootnode.up_bar:getContentSize().height - self._rootnode.mid_node:getContentSize().height - 30
	local darkWidth = self._rootnode.dark_bg:getContentSize().width
	self.innerBgSize = cc.size(darkWidth, darkHeight)
	self._rootnode.dark_bg:setPreferredSize(self.innerBgSize)
	for i = 1, sumTab do
		self.subNode[i] = {}
		self.mainNode[i] = display.newNode()
		self._rootnode.cur_bar_bg:addChild(self.mainNode[i])
		self._rootnode.cur_bar_bg:setTouchEnabled(true)
		self._rootnode.cur_bar_bg:setTouchSwallowEnabled(true)
		for j = 1, 5 do
			if self._rootnode["tab_" .. i .. "_" .. j] ~= nil then
				self.subNode[i][j] = display.newNode()
				self._rootnode["tab_" .. i .. "_" .. j]:registerScriptTapHandler(function(tag)
					self:onSubBtn(i, j)
				end)
			else
				break
			end
		end
		self:initMainBar(i)
	end
	
	CtrlBtnGroupAsMenu({
	self._rootnode.tag_node_1,
	self._rootnode.tag_node_2,
	self._rootnode.tag_node_3
	},
	onMainTabBtn,
	self.initTab or 1)
	
	onMainTabBtn(self.initTab or 1)
	
end

function HandBook:initSubNode(i, j)
	local subNode = display.newNode()
	subNode:setTag(j)
	self.mainNode[i]:addChild(subNode)
	local exNum, maxNum = HandBookModel.getSubTabNum(i, j)
	local subBar = display.newProgressTimer("#hand_green_bar.png", display.PROGRESS_TIMER_BAR)
	local cur_bar_bg_size = self._rootnode.cur_bar_bg:getContentSize()
	
	subBar:setMidpoint(cc.p(0, 0.5))
	subBar:setBarChangeRate(cc.p(1, 0))
	subBar:setPosition(cur_bar_bg_size.width / 2, cur_bar_bg_size.height / 2)
	subBar:setPercentage(exNum / maxNum * 100)
	subNode:addChild(subBar)
	
	local numTTF = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@ProcessToFinish", exNum, maxNum),
	size = 16,
	font = FONTS_NAME.font_fzcy,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER
	})
	numTTF:align(display.CENTER, cur_bar_bg_size.width/2, cur_bar_bg_size.height / 2 - 2)
	subNode:addChild(numTTF)
	
	local curData = HandBookModel.getSubData(i, j)
	local curScroll = require("game.HandBook.HandBookScroll").new({
	size = self.innerBgSize,
	data = curData
	})
	curScroll:setPosition(-28, 45 - self.innerBgSize.height)
	subNode:addChild(curScroll)
	subNode:setVisible(false)
	subNode._scroll = curScroll
end

function HandBook:setSub(tag, sub, see)
	local node = self.mainNode[tag]:getChildByTag(sub)
	if node then
		node:setVisible(see)
		node._scroll:setVisibleEnable(see)
	end
end

function HandBook:initMainBar(i)
	
	local curNum, maxNum = HandBookModel.getMainTabNum(i)
	local numBar = display.newProgressTimer("#hand_blue_bar.png", display.PROGRESS_TIMER_BAR)
	numBar:setMidpoint(cc.p(0, 0.5))
	numBar:setBarChangeRate(cc.p(1, 0))
	numBar:setAnchorPoint(cc.p(0, 0))
	numBar:setPercentage(curNum / maxNum * 100)
	local barbg = self._rootnode["bar_bg_" .. i]
	barbg:addChild(numBar)
	
	local numTTF = ui.newTTFLabelWithShadow({
	text = curNum .. "/" .. maxNum,
	size = 16,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	barbg:addChild(numTTF)
	numTTF:align(display.CENTER, barbg:getContentSize().width/2 - 5, barbg:getContentSize().height / 2 - 2)
end

function HandBook:changeTabTo(tag)
	self:onSubBtn(tag, self.subTag[tag] or 1)
end

function HandBook:ctor(msg)
	
	HandBook.super.ctor(self, {
	contentFile = "handbook/handbook_bg.ccbi",
	subTopFile = "handbook/handbook_up_tab.ccbi"
	})
	
	
	if msg then
		self.initTab = msg.tab
	end
	game.runningScene = self
	ResMgr.removeBefLayer()
	
	--·µ»Ø
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	self:SendReq()
end

function HandBook:onSubBtn(tag, subTag)
	if self._index > 0 then
		local oldTag = math.floor(self._index/10)
		local oldSub = self._index - oldTag *10
		local oldBtn = self._rootnode["tab_" .. oldTag .. "_" .. oldSub]
		oldBtn:unselected()
		self:setSub(oldTag, oldSub, false)
	end
	
	local realindex = tag * 10 + subTag
	if realindex > 0 then
		local curBtn = self._rootnode["tab_" .. tag .. "_" .. subTag]
		curBtn:selected()
		if self.mainNode[tag]:getChildByTag(subTag) == nil then
			self:initSubNode(tag, subTag)
		end
		self:setSub(tag, subTag, true)
	end
	self._index = realindex
	self.subTag[tag] = subTag
end

function HandBook:onEnter()
	HandBook.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	--[[
	if self._bExit then
		self._bExit = false
		local broadcastBg = self._rootnode.broadcast_tag
		game.broadcast:reSet(broadcastBg)
	end
	]]
end

function HandBook:onExit()
	HandBook.super.onExit(self)
	self._bExit = true
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HandBook