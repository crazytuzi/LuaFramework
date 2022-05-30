require("game.guild.utility.GuildBottomBtnEvent")

local GuildBaseScene = class("GuildBaseScene", function()
	return display.newScene("GuildBaseScene")
end)

function GuildBaseScene:ctor(param)
	local BOTTOM_HEIGHT = 110
	local TOP_HEIGHT = 72
	local _isOther = false
	if param.isOther ~= nil then
		_isOther = param.isOther
	end
	if _isOther == true then
		TOP_HEIGHT = 152
	end
	local CENTER_HEIGHT = display.height - BOTTOM_HEIGHT - TOP_HEIGHT
	self.centerHeight = CENTER_HEIGHT
	function self.getTopHeight(_)
		return TOP_HEIGHT
	end
	function self.getBottomHeight(_)
		return BOTTOM_HEIGHT
	end
	function self.getCenterHeight(_)
		return CENTER_HEIGHT
	end
	local _contentFile = param.contentFile
	local _subTopFile = param.subTopFile
	local _bottomFile = param.bottomFile
	local _bgImagePath = param.bgImage
	local _imageFromBottom = param.imageFromBottom
	local _adjustSize = param.adjustSize or cc.size(0, 0)
	local _topFile = param.topFile
	local _scaleMode = not param.scaleMode and 0
	local _isHideBottom = false
	if param.isHideBottom ~= nil then
		_isHideBottom = param.isHideBottom
	end
	if _isHideBottom then
		CENTER_HEIGHT = CENTER_HEIGHT + BOTTOM_HEIGHT
		BOTTOM_HEIGHT = 0
	end
	game.runningScene = self
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_window_scene", proxy, self._rootnode)
	node:setContentSize(cc.size(display.width, display.height))
	node:setPosition(display.cx, display.cy)
	self:addChild(node, 3)
	
	if _topFile then
		--self._rootnode.topNode:setVisible(false)
		self._rootnode.topNode:removeFromParent(false)
		local topNode = CCBuilderReaderLoad(_topFile, proxy, self._rootnode)
		topNode:setPosition(display.cx, display.height)
		self:addChild(topNode, 2)
	end
	
	local subTopNode
	if _subTopFile then
		subTopNode = CCBuilderReaderLoad(_subTopFile, proxy, self._rootnode)
		subTopNode:setPosition(display.cx, display.height - TOP_HEIGHT)
		self:addChild(subTopNode, 2)
	end
	local h = CENTER_HEIGHT
	if _contentFile then
		if subTopNode then
			h = h - subTopNode:getContentSize().height
		end
		local contentNode
		contentNode = CCBuilderReaderLoad(_contentFile, proxy, self._rootnode, self, cc.size(display.width + _adjustSize.width, h + _adjustSize.height))
		self:addChild(contentNode, 1)
		contentNode:setPosition(display.cx, BOTTOM_HEIGHT)
	end
	
	if _bgImagePath then
		local bg = display.newScale9Sprite(_bgImagePath)
		if _scaleMode == 0 then
			bg:setAnchorPoint(0.5, 0)
			if _imageFromBottom then
				local topH = 0
				if subTopNode then
					topH = subTopNode:getContentSize().height
				end
				bg:setContentSize(cc.size(display.width, display.height - TOP_HEIGHT - topH))
				bg:setPosition(display.cx, 0)
			else
				bg:setContentSize(cc.size(display.width, h))
				bg:setPosition(display.cx, BOTTOM_HEIGHT)
			end
		else
			if display.width / bg:getContentSize().width > h / bg:getContentSize().height then
				bg:setScale(display.width / bg:getContentSize().width)
			else
				bg:setScale(h / bg:getContentSize().height)
			end
			bg:setPosition(display.cx, BOTTOM_HEIGHT + h / 2)
		end
		if string.find(_bgImagePath, "common_bg.png") then
			local hw = display.newSprite("ui_common/common_huawen.png")
			hw:setPosition(display.width * 0.514, bg:getContentSize().height)
			hw:setAnchorPoint(cc.p(0.5, 1))
			bg:addChild(hw)
			local bg2 = display.newScale9Sprite("ui_common/common_bg2.png")
			bg2:setContentSize(cc.size(display.width + 40, bg:getContentSize().height + 12))
			bg2:setPosition(display.cx, bg:getContentSize().height / 2)
			bg:addChild(bg2)
		end
		self:addChild(bg, 0)
	end
	
	self._bottomNode = nil
	if not _isHideBottom then
		if _bottomFile ~= nil then
			--self._rootnode["bottomNode"]:setVisible(false)
			self._rootnode.bottomNode:removeFromParent(false)
			local bottomNode = CCBuilderReaderLoad(_bottomFile, proxy, self._rootnode)
			bottomNode:setPosition(display.cx, 0)
			self._bottomNode = bottomNode
			self:addChild(bottomNode, 2)
		else
			printf(common:getLanguageString("@RegBtnEvent"))
		end
		GuildBottomBtnEvent.registerBottomEvent(self._rootnode)
	else
		--self._rootnode["bottomNode"]:setVisible(false)
		self._rootnode.bottomNode:removeFromParent(false)
	end
	
	self._rootnode.zhandouliLabel:setString(tostring(game.player:getBattlePoint()))
	if _isOther == false then
		self._rootnode.goldLabel:setString(tostring(game.player:getGold()))
		self._rootnode.silverLabel:setString(tostring(game.player:getSilver()))
	end
	if self._rootnode.chat_btn ~= nil then
		if game.player:getAppOpenData().b_liaotian == APPOPEN_STATE.close then
			self._rootnode.chat_btn:setVisible(false)
		else
			self._rootnode.chat_btn:setVisible(true)
		end
	end
	
	function self.getCenterHeightWithSubTop()
		return h
	end
	
	if self._rootnode.nowTimeLabel then
		self._rootnode.nowTimeLabel:setString(GetSystemTime())
		self._rootnode.nowTimeLabel:schedule(function()
			self._rootnode.nowTimeLabel:setString(GetSystemTime())
		end,
		60)
	end
	self:checkApplyNum()
	
	addbackevent(self)
end

function GuildBaseScene:checkApplyNum()
	if self._rootnode then
		local notice = self._rootnode.apply_notice
		if notice ~= nil then
			if game.player:getGuildApplyNum() > 0 then
				notice:setVisible(true)
			else
				notice:setVisible(false)
			end
		end
	end
end

function GuildBaseScene:regNotice()
	RegNotice(self, function()
		local goldLbl = self._rootnode.goldLabel
		if goldLbl ~= nil and checkint(goldLbl:getString()) ~= game.player:getGold() then
			goldLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 2),
			CCCallFunc:create(function()
				goldLbl:setString(tostring(game.player:getGold()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Gold)
	
	RegNotice(self, function()
		local silverLbl = self._rootnode.silverLabel
		if silverLbl ~= nil and checkint(silverLbl:getString()) ~= game.player:getSilver() then
			silverLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 1.1),
			CCCallFunc:create(function()
				silverLbl:setString(tostring(game.player:getSilver()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Silver)
	
	RegNotice(self, function()
		local tiliLbl = self._rootnode.tili_Label
		if tiliLbl ~= nil and checkint(tiliLbl:getString()) ~= game.player:getStrength() then
			tiliLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 1.1),
			CCCallFunc:create(function()
				tiliLbl:setString(tostring(game.player:getStrength()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Tili)
	
	RegNotice(self, function()
		local nailiLbl = self._rootnode.naili_Label
		if nailiLbl ~= nil and checkint(nailiLbl:getString()) ~= game.player:getNaili() then
			nailiLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 1.1),
			CCCallFunc:create(function()
				nailiLbl:setString(tostring(game.player:getNaili()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Naili)
	
	RegNotice(self, function()
		self:setBottomBtnEnabled(false)
	end,
	NoticeKey.LOCK_BOTTOM)
	
	RegNotice(self, function()
		self:setBottomBtnEnabled(true)
		printf("post UNLOCK_BOTTOM")
	end,
	NoticeKey.UNLOCK_BOTTOM)
	
	RegNotice(self, handler(self, GuildBaseScene.checkApplyNum), NoticeKey.CHECK_GUILD_APPLY_NUM)
end

function GuildBaseScene:unregNotice()
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Silver)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Gold)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Tili)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Naili)
	UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
	UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
	UnRegNotice(self, NoticeKey.CHECK_GUILD_APPLY_NUM)
end

function GuildBaseScene:onEnter()
	game.runningScene = self
	game.broadcast:reSet(self._rootnode.broadcast_tag)
	self:regNotice()
end

function GuildBaseScene:onExit()
	self:unregNotice()
end

function GuildBaseScene:setBottomBtnEnabled(bEnabled)
	GuildBottomBtnEvent.setTouchEnabled(bEnabled)
end

return GuildBaseScene