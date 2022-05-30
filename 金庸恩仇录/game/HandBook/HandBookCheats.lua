local HandBookCheats = class("HandBookCheats", function()
	return require("game.BaseScene").new({
	contentFile = "handbook/handbook_bg_cheats.ccbi",
	subTopFile = "handbook/handbook_up_cheats_tab.ccbi"
	})
end)
local XINFA = 1
local JUEXUE = 2

function HandBookCheats:SendReq()
	RequestHelper.getHandBook({
	flag = 16,
	callback = function(data)
		--dump(data)
		HandBookModel.init(data)
		self:init()
	end
	})
end

function HandBookCheats:init()
	self.subTag = {}
	self.subNode = {}
	self.mainNode = {}
	local function onMainTabBtn(tag)
		self.curTag = tag
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		for i = 1, 2 do
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
	for i = 1, 2 do
		self.subNode[i] = {}
		self.mainNode[i] = display.newNode()
		self._rootnode.cur_bar_bg:addChild(self.mainNode[i])
		self._rootnode.cur_bar_bg:setTouchEnabled(true)
		self._rootnode.cur_bar_bg:setTouchSwallowEnabled(true)
		self:onSubBtn(i, 1)
	end
	CtrlBtnGroupAsMenu({
	self._rootnode.tag_node_1,
	self._rootnode.tag_node_2
	}, onMainTabBtn, self.initTab or 1)
	onMainTabBtn(1)
end

function HandBookCheats:initSubNode(i, j)
	local subNode = display.newNode()
	subNode:setTag(j)
	self.mainNode[i]:addChild(subNode)
	local exNum, maxNum = HandBookModel.getSubTabNum(4, i)
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
	local curData = HandBookModel.getSubData(4, i)
	local curScroll = require("game.HandBook.HandBookScroll").new({
	size = self.innerBgSize,
	data = curData
	})
	subNode.scroll = curScroll
	curScroll:setVisibleEnable(false)
	curScroll:align(display.LEFT_BOTTOM, -28, 45 - self.innerBgSize.height)
	subNode:addChild(curScroll)
end

function HandBookCheats:ctor(msg)
	game.runningScene = self
	if msg then
		self.initTab = msg.tab
	end
	ResMgr.removeBefLayer()
	
	--·µ»Ø
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		pop_scene()
		GameStateManager:resetState()
	end,
	CCControlEventTouchUpInside)
	
	self:SendReq()
end
function HandBookCheats:onSubBtn(tag, subTag)
	if self.subTag[tag] ~= subTag then
		self.subTag[tag] = subTag
		for j = 1, 1 do
			if j == subTag then
				if self.mainNode[tag]:getChildByTag(j) == nil then
					self:initSubNode(tag, j)
				end
				self.mainNode[tag]:getChildByTag(j):setVisible(true)
			else
				curBtn:unselected()
				if self.mainNode[tag]:getChildByTag(j) ~= nil then
					self.mainNode[tag]:getChildByTag(j):setVisible(false)
				end
			end
		end
	end
end

function HandBookCheats:onEnter()
	self:regNotice()
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	self:setBroadcast()
end

function HandBookCheats:onExit()
	self:unregNotice()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HandBookCheats