local BaseSceneExt = class("BaseSceneExt", function()
	return display.newScene("BaseSceneExt")
end)

function BaseSceneExt:ctor(param)
	local _contentFile = param.contentFile
	local _bottomFile = param.bottomFile
	local _topFile = param.topFile
	local _adjustSize = param.adjustSize or cc.size(0, 0)
	game.runningScene = self
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local _topL = 0
	local _bottomL = 0
	local topNode
	if _topFile then
		topNode = CCBuilderReaderLoad(_topFile, self._proxy, self._rootnode)
		topNode:setPosition(display.cx, display.height)
		self:addChild(topNode, 2)
		if self._rootnode.topNodeHeight then
			_topL = self._rootnode.topNodeHeight:getContentSize().height
		elseif self._rootnode.topFrameNode then
			_topL = self._rootnode.topFrameNode:getContentSize().height
		end
	end
	local bottomNode
	if _bottomFile then
		bottomNode = CCBuilderReaderLoad(_bottomFile, self._proxy, self._rootnode)
		bottomNode:setPosition(display.cx, 0)
		self:addChild(bottomNode, 2)
		if self._rootnode.bottomNodeHeight then
			_bottomL = self._rootnode.bottomNodeHeight:getContentSize().height
		elseif self._rootnode.bottomMenuNode then
			_bottomL = self._rootnode.bottomMenuNode:getContentSize().height
		end
	end
	local contentNode
	if _contentFile then
		printf("content node")
		contentNode = CCBuilderReaderLoad(_contentFile, self._proxy, self._rootnode, self, CCSizeMake(display.width + _adjustSize.width, display.height - _topL - _bottomL + _adjustSize.height))
		self:addChild(contentNode, 1)
		contentNode:setPosition(display.width / 2, _bottomL)
	end
	if self._rootnode.zhandouliLabel then
		self._rootnode.zhandouliLabel:setString(tostring(game.player:getBattlePoint()))
	end
	if self._rootnode.goldLabel then
		self._rootnode.goldLabel:setString(tostring(game.player:getGold()))
	end
	if self._rootnode.silverLabel then
		self._rootnode.silverLabel:setString(tostring(game.player:getSilver()))
	end
	function self.getContentHeight(_)
		return display.height - _topL - _bottomL
	end
	function self.getBottomHeight(_)
		return _bottomL
	end
	function self.getTopHeight(_)
		return _topL
	end
	BottomBtnEvent.registerBottomEvent(self._rootnode)
	local broadcastBg = self._rootnode.broadcast_tag
	if broadcastBg ~= nil then
		game.broadcast:reSet(broadcastBg)
	end
	if self._rootnode.nowTimeLabel then
		self._rootnode.nowTimeLabel:setString(GetSystemTime())
		self._rootnode.nowTimeLabel:schedule(function()
			self._rootnode.nowTimeLabel:setString(GetSystemTime())
		end,
		60)
	end
	
	self:refreshChoukaNotice()
	local tuBtn = self._rootnode.battleBtn
	if not tuBtn then
		return
	end
	self._jiantouEff = LoadUI("mainmenu/navigtion.ccbi", self._rootnode)
	self._jiantouEff:setVisible(false)
	self._jiantouEff:setPosition(tuBtn:getContentSize().width / 2, tuBtn:getContentSize().height / 2)
	tuBtn:addChild(self._jiantouEff, 100)
	local data_config_config = require("data.data_config_config")
	if game.player.getLevel() >= data_config_config[1].tip_jianghu_level_begin and game.player.getLevel() < data_config_config[1].tip_jianghu_level then
		self._jiantouEff:setVisible(true)
		self._rootnode.mJianTouNode:setVisible(false)
	end
	local tuBtn = self._rootnode.battleBtn
	display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
	local _jiangHuBtnNotice = display.newSprite("#toplayer_mail_tip.png")
	_jiangHuBtnNotice:setAnchorPoint(CCPointMake(1, 1))
	_jiangHuBtnNotice:setPosition(tuBtn:getContentSize().width, tuBtn:getContentSize().height)
	_jiangHuBtnNotice:setVisible(false)
	tuBtn:addChild(_jiangHuBtnNotice, 100)
	if _jiangHuBtnNotice ~= nil then
		if 0 < game.player:getJiangHuBoxNum() then
			_jiangHuBtnNotice:setVisible(true)
		else
			_jiangHuBtnNotice:setVisible(false)
		end
	end
	addbackevent(self)
end

function BaseSceneExt:refreshChoukaNotice()
	local choukaNotice = self._rootnode.chouka_notice
	if choukaNotice ~= nil then
		if game.player:getChoukaNum() > 0 then
			choukaNotice:setVisible(true)
		else
			choukaNotice:setVisible(false)
		end
	end
end

function BaseSceneExt:regNotice()
	RegNotice(self, function()
		local goldLabel = self._rootnode.goldLabel
		if goldLabel ~= nil then
			goldLabel:runAction(transition.sequence({
			CCScaleTo:create(0.2, 2),
			CCCallFunc:create(function()
				goldLabel:setString(tostring(game.player:getGold()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Gold)
	
	RegNotice(self, function()
		local silverLabel = self._rootnode.silverLabel
		if silverLabel ~= nil then
			silverLabel:runAction(transition.sequence({
			CCScaleTo:create(0.2, 1.1),
			CCCallFunc:create(function()
				silverLabel:setString(tostring(game.player:getSilver()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Silver)
	
	RegNotice(self, function()
		self:setBottomBtnEnabled(false)
	end,
	NoticeKey.LOCK_BOTTOM)
	
	RegNotice(self, function()
		self:setBottomBtnEnabled(true)
	end,
	NoticeKey.UNLOCK_BOTTOM)
end

function BaseSceneExt:setBottomBtnEnabled(bEnabled)
	ResMgr.isBottomEnabled = bEnabled
	BottomBtnEvent.setTouchEnabled(bEnabled)
end

function BaseSceneExt:unregNotice()
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Silver)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Gold)
	UnRegNotice(self, NoticeKey.BottomLayer_Chouka)
	UnRegNotice(self, NoticeKey.BottomLayer_JiangHu)
	UnRegNotice(self, NoticeKey.BottomLayer_ZhenRong)
	UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
	UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
end


function BaseSceneExt:onEnter()
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>BaseSceneExt:onEnter<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
end

function BaseSceneExt:onExit()
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>BaseSceneExt:onExit<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
end


return BaseSceneExt