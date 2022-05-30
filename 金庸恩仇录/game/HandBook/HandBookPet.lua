local HandBookPet = class("HandBookCheats", function()
	return require("game.BaseScene").new({
	contentFile = "handbook/handbook_bg_cheats.ccbi",
	subTopFile = "handbook/handbook_up_cheats_tab.ccbi"
	})
end)
--[[
local XINFA = 1
local JUEXUE = 2
]]
function HandBookPet:SendReq()
	RequestHelper.getHandBook({
	flag = 8,
	callback = function(data)
		HandBookModel.init(data)
		self:init()
	end
	})
end

function HandBookPet:init()
	self.subTag = {}
	self.subNode = {}
	self.mainNode = {}
	local function onMainTabBtn(tag)
		--GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		self.curTag = tag
		for i = 1, 1 do
			if i == tag then
				self.mainNode[i]:getChildByTag(1).scroll:setVisibleEnable(true)
				self.mainNode[i]:setVisible(true)
			else
				self.mainNode[i]:getChildByTag(1).scroll:setVisibleEnable(false)
				self.mainNode[i]:setVisible(false)
			end
		end
	end
	
	HandBookModel.viewBg = self._rootnode.dark_bg
	local darkHeight = self:getCenterHeight() - 25
	local darkWidth = self._rootnode.dark_bg:getContentSize().width
	self.innerBgSize = cc.size(darkWidth, darkHeight)
	self._rootnode.dark_bg:setPreferredSize(self.innerBgSize)
	
	for i = 1, 1 do
		self.subNode[i] = {}
		self.mainNode[i] = display.newNode()
		self._rootnode.cur_bar_bg:addChild(self.mainNode[i])
		self._rootnode.cur_bar_bg:setTouchEnabled(true)
		self._rootnode.cur_bar_bg:setTouchSwallowEnabled(true)
		self:onSubBtn(i, 1)
	end
	--[[
	CtrlBtnGroupAsMenu({
	self._rootnode.tag_node_1
	--self._rootnode.tag_node_2
	}, onMainTabBtn, self.initTab or 1)
	]]
	onMainTabBtn(1)
end

function HandBookPet:initSubNode(i, j)
	local subNode = display.newNode()
	subNode:setTag(j)
	self.mainNode[i]:addChild(subNode)
	local exNum, maxNum = HandBookModel.getSubTabNum(5, i)
	local subBar = display.newProgressTimer("#hand_green_bar.png", display.PROGRESS_TIMER_BAR)
	subBar:setMidpoint(cc.p(0, 0.5))
	subBar:setBarChangeRate(cc.p(1, 0))
	subBar:setPosition(self._rootnode.cur_bar_bg:getContentSize().width / 2, self._rootnode.cur_bar_bg:getContentSize().height / 2)
	subBar:setPercentage(exNum / maxNum * 100)
	subNode:addChild(subBar)
	
	local numTTF = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@ProcessToFinish", exNum, maxNum),
	size = 16,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	})
	numTTF:setPosition(self._rootnode.cur_bar_bg:getContentSize().width / 2, self._rootnode.cur_bar_bg:getContentSize().height / 2 - 2)
	subNode:addChild(numTTF)
	local curData = HandBookModel.getSubData(5, i)
	local curScroll = require("game.HandBook.HandBookScroll").new({
	size = self.innerBgSize,
	data = curData
	})
	subNode.scroll = curScroll
	curScroll:setVisibleEnable(false)
	curScroll:align(display.LEFT_BOTTOM, -28, 45 - self.innerBgSize.height)
	subNode:addChild(curScroll)
end

function HandBookPet:ctor(msg)
	game.runningScene = self
	if msg then
		self.initTab = msg.tab
	end
	ResMgr.removeBefLayer()
	
	self._rootnode.tag_node_1:setVisible(false)
	self._rootnode.tag_node_2:setVisible(false)
	--·µ»Ø
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		pop_scene()
		GameStateManager:resetState()
	end,
	CCControlEventTouchUpInside)
	
	self:SendReq()
end

function HandBookPet:onSubBtn(tag, subTag)
	if self.subTag[tag] ~= subTag then
		self.subTag[tag] = subTag
		for j = 1, 1 do
			if j == subTag then
				if self.mainNode[tag]:getChildByTag(j) == nil then
					self:initSubNode(tag, j)
				end
				self.mainNode[tag]:getChildByTag(j):setVisible(true)
			else
				if self.mainNode[tag]:getChildByTag(j) ~= nil then
					self.mainNode[tag]:getChildByTag(j):setVisible(false)
				end
			end
		end
	end
end

function HandBookPet:onEnter()
	self:regNotice()
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	self:setBroadcast()
end

function HandBookPet:onExit()
	self:unregNotice()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HandBookPet