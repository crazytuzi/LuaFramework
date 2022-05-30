require("game.scenes.MainMenuLayer")

local BaseLayer = class("BaseLayer", function ()
	return display.newLayer()
end)

function BaseLayer:ctor(param)
	self:setNodeEventEnabled(true)
	self:setBottomBtnEnabled(false)
	ResMgr.createBefTutoMask(self)
	local BOTTOM_HEIGHT = 115.2
	local TOP_HEIGHT = 72
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
	local _adjustSize = param.adjustSize or CCSizeMake(0, 0)
	local _topFile = param.topFile
	local _scaleMode = param.scaleMode or 0
	self._isHideBottom = false
	if param.isHideBottom ~= nil then
		self._isHideBottom = param.isHideBottom
	end
	self._isOther = false
	if param.isOther ~= nil then
		self._isOther = param.isOther
	end
	if self._isHideBottom then
		CENTER_HEIGHT = CENTER_HEIGHT + BOTTOM_HEIGHT
		BOTTOM_HEIGHT = 0
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("public/window_scene", proxy, self._rootnode)
	node:setContentSize(CCSizeMake(display.width, display.height))
	node:setPosition(display.cx, display.cy)
	self:addChild(node, 3)
	if _topFile then
		self._rootnode.topNode:removeSelf()
		local bottomNode = CCBuilderReaderLoad(_topFile, proxy, self._rootnode)
		bottomNode:setPosition(display.cx, display.height)
		self:addChild(bottomNode, 2)
	else
		local topNode = CCBuilderReaderLoad("public/top_frame.ccbi", proxy, self._rootnode)
		self._rootnode.topNode:addChild(topNode)
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
		contentNode = CCBuilderReaderLoad(_contentFile, proxy, self._rootnode, self, CCSizeMake(display.width + _adjustSize.width, h + _adjustSize.height))
		self:addChild(contentNode, 1)
		contentNode:setPosition(display.width / 2, BOTTOM_HEIGHT)
	end
	if _bgImagePath then
		local bg
		if param.useScale9 == false then
			bg = display.newSprite(_bgImagePath)
		else
			bg = display.newScale9Sprite(_bgImagePath)
		end
		if _scaleMode == 0 then
			bg:setAnchorPoint(0.5, 0)
			if _imageFromBottom then
				local topH = 0
				if subTopNode then
					topH = subTopNode:getContentSize().height
				end
				bg:setContentSize(CCSizeMake(display.width, display.height - TOP_HEIGHT - topH))
				bg:setPosition(display.width / 2, 0)
			else
				bg:setContentSize(CCSizeMake(display.width, h))
				bg:setPosition(display.width / 2, BOTTOM_HEIGHT)
			end
		else
			if display.width / bg:getContentSize().width > h / bg:getContentSize().height then
				bg:setScale(display.width / bg:getContentSize().width)
			else
				bg:setScale(h / bg:getContentSize().height)
			end
			bg:setPosition(display.width / 2, BOTTOM_HEIGHT + h / 2)
		end
		if string.find(_bgImagePath, "common_bg.png") then
			local hw = display.newSprite("ui_common/common_huawen.png")
			hw:setPosition(display.width * 0.514, bg:getContentSize().height)
			hw:setAnchorPoint(ccp(0.5, 1))
			bg:addChild(hw)
			local bg2 = display.newScale9Sprite("ui_common/common_bg2.png")
			bg2:setContentSize(CCSizeMake(display.width + 40, bg:getContentSize().height + 12))
			bg2:setPosition(display.width / 2, bg:getContentSize().height / 2)
			bg:addChild(bg2)
		end
		self:addChild(bg, 0)
	end
	if not self._isHideBottom then
		if _bottomFile then
			local bottomNode = CCBuilderReaderLoad(_bottomFile, proxy, self._rootnode)
			bottomNode:setPosition(display.cx, 0)
			self:addChild(bottomNode, 2)
		else
			local bottomNode = CCBuilderReaderLoad("public/bottom_frame.ccbi", proxy, self._rootnode)
			self._rootnode.bottomNode:addChild(bottomNode)
			local tuBtn = self._rootnode.battleBtn
			local arrayBtn = self._rootnode.formSettingBtn
			self._jiantouEff = LoadUI("mainmenu/navigtion.ccbi", self._rootnode)
			self._jiantouEff:setVisible(false)
			self._jiantouEff:setPosition(tuBtn:getContentSize().width / 2, tuBtn:getContentSize().height / 2)
			tuBtn:addChild(self._jiantouEff, 100)
			local items = {
			"mainSceneBtn",
			"formSettingBtn",
			"battleBtn",
			"activityBtn",
			"bagBtn",
			"shopBtn"
			}
			for k, v in pairs(G_BOTTOM_BTN) do
				if GameStateManager.currentState == v and 2 < GameStateManager.currentState then
					self._rootnode[items[k]]:selected()
					local data_config_config = require("data.data_config_config")
					if k ~= 3 and game.player.getLevel() >= data_config_config[1].tip_jianghu_level_begin and game.player.getLevel() < data_config_config[1].tip_jianghu_level then
						self._jiantouEff:setVisible(true)
						self._rootnode.mJianTouNode:setVisible(false)
					end
					break
				end
			end
			local items = {
			"mainSceneBtn",
			"formSettingBtn",
			"battleBtn",
			"activityBtn",
			"bagBtn",
			"shopBtn"
			}
			for k, v in pairs(G_BOTTOM_BTN) do
				if GameStateManager.currentState == v and 2 < GameStateManager.currentState then
					self._rootnode[items[k]]:selected()
					local data_config_config = require("data.data_config_config")
					if k ~= 3 and game.player.getLevel() >= data_config_config[1].tip_jianghu_level_begin and game.player.getLevel() < data_config_config[1].tip_jianghu_level then
						if self._jiantouEff then
							self._jiantouEff:setVisible(true)
						end
						self._rootnode.mJianTouNode:setVisible(false)
					end
					break
				end
			end
			printf("注册底部按钮事件")
			BottomBtnEvent.registerBottomEvent(self._rootnode)
		end
	end
	function self.getCenterHeightWithSubTop()
		return h
	end
end

local setStringByCheck = function (str, text)
	if str then
		str:setString(text)
	end
end

function BaseLayer:refreshTopText()
	setStringByCheck(self._rootnode.zhandouliLabel, tostring(game.player:getBattlePoint()))
	if self._isOther then
		setStringByCheck(self._rootnode.naili_Label, game.player:getNaili())
		setStringByCheck(self._rootnode.tili_Label, game.player:getStrength())
		self._rootnode.goldLabel = nil
		self._rootnode.silverLabel = nil
	else
		setStringByCheck(self._rootnode.goldLabel, tostring(game.player:getGold()))
		setStringByCheck(self._rootnode.silverLabel, tostring(game.player:getSilver()))
	end
	
	local broadcastBg = self._rootnode.broadcast_tag
	if broadcastBg ~= nil then
		game.broadcast:reSet(broadcastBg)
	end
	
	if self._rootnode.nowTimeLabel then
		self._rootnode.nowTimeLabel:setString(GetSystemTime())
		self._rootnode.nowTimeLabel:schedule(function ()
			self._rootnode.nowTimeLabel:setString(GetSystemTime())
		end,
		60)
	end
	if not self._isHideBottom and self._rootnode.battleBtn then
		self:refreshChoukaNotice()
		local _jiangHuBtnNoticeTag = 8647
		local tuBtn = self._rootnode.battleBtn
		local _jiangHuBtnNotice = tuBtn:getChildByTag(_jiangHuBtnNoticeTag)
		if not _jiangHuBtnNotice then
			display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
			_jiangHuBtnNotice = display.newSprite("#toplayer_mail_tip.png")
			_jiangHuBtnNotice:setAnchorPoint(CCPointMake(1, 1))
			_jiangHuBtnNotice:setPosition(tuBtn:getContentSize().width, tuBtn:getContentSize().height)
			_jiangHuBtnNotice:setVisible(false)
			tuBtn:addChild(_jiangHuBtnNotice, 100)
			_jiangHuBtnNotice:setTag(_jiangHuBtnNoticeTag)
		end
		if _jiangHuBtnNotice ~= nil then
			if game.player:getJiangHuBoxNum() > 0 then
				_jiangHuBtnNotice:setVisible(true)
			else
				_jiangHuBtnNotice:setVisible(false)
			end
		end
	end
	if self._rootnode.formSettingBtn then
		addPrompt(self._rootnode)
	end
end

function BaseLayer:refreshChoukaNotice()
	local choukaNotice = self._rootnode.chouka_notice
	if choukaNotice ~= nil then
		if game.player:getChoukaNum() > 0 then
			choukaNotice:setZOrder(2)
			choukaNotice:setVisible(true)
		else
			choukaNotice:setVisible(false)
		end
	end
end

function BaseLayer:regNotice()
	local updateFunction = function (updateLabel, scaleTo1, scaleTime1, scaleTo2, scaleTime2, valueFun)
		if updateLabel ~= nil and checkint(updateLabel:getString()) ~= valueFun() then
			updateLabel:runAction(transition.sequence({
			CCScaleTo:create(scaleTo1, scaleTime1),
			CCCallFunc:create(function ()
				updateLabel:setString(tostring(valueFun()))
			end),
			CCScaleTo:create(scaleTo2, scaleTime2)
			}))
		end
	end
	
	RegNotice(self, function ()
		updateFunction(self._rootnode.goldLabel, 0.2, 2, 0.1, 1, game.player.getGold)
	end,
	
	NoticeKey.CommonUpdate_Label_Gold)
	RegNotice(self, function ()
		updateFunction(self._rootnode.silverLabel, 0.2, 1.1, 0.1, 1, game.player.getSilver)
	end,
	NoticeKey.CommonUpdate_Label_Silver)
	RegNotice(self, function ()
		updateFunction(self._rootnode.tili_Label, 0.2, 1.1, 0.1, 1, game.player.getStrength)
	end,
	NoticeKey.CommonUpdate_Label_Tili)
	RegNotice(self, function ()
		updateFunction(self._rootnode.naili_Label, 0.2, 1.1, 0.1, 1, game.player.getNaili)
	end,
	NoticeKey.CommonUpdate_Label_Naili)
	RegNotice(self, function ()
		self:setBottomBtnEnabled(false)
	end,
	NoticeKey.LOCK_BOTTOM)
	RegNotice(self, function ()
		self:setBottomBtnEnabled(true)
	end,
	NoticeKey.UNLOCK_BOTTOM)
end

function BaseLayer:unregNotice()
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Silver)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Gold)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Tili)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Naili)
	UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
	UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
end

function BaseLayer:setBottomBtnEnabled(bEnabled)
	ResMgr.isBottomEnabled = bEnabled
	BottomBtnEvent.setTouchEnabled(bEnabled)
end

return BaseLayer