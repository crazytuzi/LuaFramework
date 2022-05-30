local BaseScene = class("BaseScene", function ()
	return display.newScene("BaseScene")
end)

function BaseScene:ctor(param)
	game.runningScene = self
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>BaseScene:ctor<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	self:setBottomBtnEnabled(false)
	
	if param.showBefLayer then
		ResMgr.createBefTutoMask(self)
	end
	
	--顶部框和底部框固定	
	self.TOP_HEIGHT = 72
	self.TOP_SUB_HEIGHT = 0
	self.BOTTOM_HEIGHT = 0--115.2
	self.CENTER_HEIGHT = 0
	
	self.getTopHeight = function (_)
		return self.TOP_HEIGHT
	end
	
	self.getBottomHeight = function (_)
		return self.BOTTOM_HEIGHT
	end
	
	self.getCenterHeight = function (_)
		return self.CENTER_HEIGHT
	end
	
	self.getCenterHeightWithSubTop = function (_)
		return self.CENTER_HEIGHT
	end
	
	local _contentFile = param.contentFile
	local _subTopFile  = param.subTopFile
	local _bottomFile  = param.bottomFile
	local _bgImagePath = param.bgImage
	local _imageFromBottom = param.imageFromBottom
	local _adjustSize = param.adjustSize or cc.size(0, 0)
	local _topFile = param.topFile
	local _scaleMode = param.scaleMode or 0
	
	local loadDefBottom = false
	
	if _topFile == nil then
		_topFile = "public/top_frame.ccbi"
	end
	
	if _bottomFile == nil then
		loadDefBottom = true
		_bottomFile = "public/bottom_frame.ccbi"
	end
	
	--[[是否隐藏底部按钮]]
	local _isHideBottom = false
	if param.isHideBottom ~= nil then
		_isHideBottom = param.isHideBottom
	end
	
	--[[是否显示体力]]
	local _isOther = false
	if param.isOther ~= nil then
		_isOther = param.isOther
	end
	
	local proxy = CCBProxy:create()
	self._rootnode = {}
	--local node = CCBuilderReaderLoad("public/window_scene.ccbi", proxy, self._rootnode)
	--node:setContentSize(cc.size(display.width, display.height))
	--node:setPosition(display.cx, display.cy)
	--self:addChild(node, 3)
	
	--上部条

	
	
	if _topFile then
		local topNode = CCBuilderReaderLoad(_topFile, proxy, self._rootnode)
		topNode:align(display.TOP_CENTER, display.cx, display.height)
		:addTo(self, 2)
		self._rootnode["topNode"] = topNode
		if self._rootnode["topNodeHeight"] then
			self.TOP_HEIGHT = self._rootnode["topNodeHeight"]:getContentSize().height
		elseif self._rootnode["topFrameNode"] then
			self.TOP_HEIGHT = self._rootnode["topFrameNode"]:getContentSize().height
		end
	end
	
	--上部偏下的条
	local subTopNode
	if _subTopFile then
		subTopNode = CCBuilderReaderLoad(_subTopFile, proxy, self._rootnode)
		subTopNode:align(display.TOP_CENTER, display.cx, display.height - self.TOP_HEIGHT)
		:addTo(self, 2)
		self.TOP_SUB_HEIGHT = subTopNode:getCascadeBoundingBox().height
	end
	
	--是否替换下部的按钮	
	if not _isHideBottom then
		local bottomNode = CCBuilderReaderLoad(_bottomFile, proxy, self._rootnode)
		bottomNode:align(display.BOTTOM_CENTER, display.cx, 0)
		:addTo(self, 3)
		self._rootnode["bottomNode"] = bottomNode
		if self._rootnode["bottomNodeHeight"] then
			self.BOTTOM_HEIGHT = self._rootnode["bottomNodeHeight"]:getContentSize().height
		elseif self._rootnode["bottomMenuNode"] then
			self.BOTTOM_HEIGHT = self._rootnode["bottomMenuNode"]:getContentSize().height
		end
	end
	
	self.CENTER_HEIGHT = display.height - self.BOTTOM_HEIGHT - self.TOP_HEIGHT - self.TOP_SUB_HEIGHT
	
	if not _isHideBottom and loadDefBottom then
		print("注册底部按钮事件")
		BottomBtnEvent.registerBottomEvent(self._rootnode)
		-- 高亮选择中的底部按钮
		BottomBtnEvent.lightenBottomMenu(self._rootnode)
		
		-- 高亮选择中的底部按钮
		--for k,v in pairs(G_BOTTOM_BTN) do
		--	if(GameStateManager.currentState == v and GameStateManager.currentState > GAME_STATE.STATE_MAIN_MENU) then
		--		self._rootnode[G_BOTTOM_BTN_NAME[k]]:selected()
		--		break
		--	end
		--end
	end
	
	--内容框	
	if _contentFile then
		local contentNode = CCBuilderReaderLoad(_contentFile, proxy, self._rootnode, self, cc.size(display.width + _adjustSize.width, self.CENTER_HEIGHT + _adjustSize.height))
		contentNode:align(display.CENTER_BOTTOM, display.cx, self.BOTTOM_HEIGHT)
		contentNode:addTo(self, 1)
	end
	
	--背景
	if _bgImagePath then
		local bg = display.newScale9Sprite(_bgImagePath)
		if _scaleMode == 0 then
			bg:setAnchorPoint(0.5, 0)
			if _imageFromBottom then
				local topH = 0
				if subTopNode then
					topH = subTopNode:getContentSize().height
				end
				bg:setContentSize(cc.size(display.width, display.height - self.TOP_HEIGHT - topH))
				bg:setPosition(display.width / 2, 0)
			else
				bg:setContentSize(cc.size(display.width, self.CENTER_HEIGHT))
				bg:setPosition(display.width / 2, self.BOTTOM_HEIGHT)
			end
			
		else
			if display.width / bg:getContentSize().width > self.CENTER_HEIGHT / bg:getContentSize().height then
				bg:setScale(display.width / bg:getContentSize().width)
			else
				bg:setScale(self.CENTER_HEIGHT / bg:getContentSize().height)
			end
			--bg:setAnchorPoint(0.5, 0)
			bg:setPosition(display.width / 2, self.BOTTOM_HEIGHT + self.CENTER_HEIGHT / 2)
		end
		
		if string.find(_bgImagePath, "common_bg.png") then local hw = display.newSprite("ui_common/common_huawen.png")
			hw:setPosition(display.width * 0.514, bg:getContentSize().height)
			hw:setAnchorPoint(cc.p(0.5, 1))
			bg:addChild(hw)
			
			local bg2 = display.newScale9Sprite("ui_common/common_bg2.png")
			bg2:setContentSize(cc.size(display.width + 40, bg:getContentSize().height + 12))
			bg2:setPosition(display.width / 2, bg:getContentSize().height / 2)
			bg:addChild(bg2)
		end
		self:addChild(bg, 0)
	end
	
	local function setStringByCheck(str, text)
		if str then
			str:setString(text)
		end
	end
	setStringByCheck(self._rootnode["zhandouliLabel"], tostring(game.player:getBattlePoint()))
	if _isOther then
		setStringByCheck(self._rootnode["naili_Label"], game.player:getNaili())
		setStringByCheck(self._rootnode["tili_Label"], game.player:getStrength())
		self._rootnode["goldLabel"] = nil
		self._rootnode["silverLabel"] = nil
	else
		setStringByCheck(self._rootnode["goldLabel"], tostring(game.player:getGold()))
		setStringByCheck(self._rootnode["silverLabel"], tostring(game.player:getSilver()))
	end
	
	--[[
	local broadcastBg = self._rootnode["broadcast_tag"]
	if broadcastBg ~= nil then
		game.broadcast:reSet(broadcastBg)
	end
	]]
	
	if self._rootnode["nowTimeLabel"] then
		self._rootnode["nowTimeLabel"]:setString(GetSystemTime())
		self._rootnode["nowTimeLabel"]:schedule(function ()
			self._rootnode["nowTimeLabel"]:setString(GetSystemTime())
		end,
		60)
	end
	
	self:refreshChoukaNotice()
	addbackevent(self)
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>加载完成<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
end

function BaseScene:onEnter()
	game.runningScene = self
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>BaseScene:onEnter<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	local broadcastBg = self._rootnode["broadcast_tag"]
	if broadcastBg ~= nil then
		game.broadcast:reSet(broadcastBg)
	end
	self:regNotice()
end

function BaseScene:onExit()
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>BaseScene:onExit<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	self:unregNotice()
end

function BaseScene:setBroadcast()
	local broadcastBg = self._rootnode.broadcast_tag
	if broadcastBg ~= nil then
		game.broadcast:reSet(broadcastBg)
	end
end

function BaseScene:refreshChoukaNotice()
	local choukaNotice = self._rootnode["chouka_notice"]
	if choukaNotice ~= nil then
		if game.player:getChoukaNum() > 0 then
			choukaNotice:setVisible(true)
		else
			choukaNotice:setVisible(false)
		end
	end
end

function BaseScene:regNotice()
	
	RegNotice(self,
	function ()
		local goldLbl = self._rootnode["goldLabel"]
		if goldLbl ~= nil and checkint(goldLbl:getString()) ~= game.player:getGold() then
			goldLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 2),
			CCCallFunc:create(function ()
				goldLbl:setString(tostring(game.player:getGold()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Gold)
	
	RegNotice(self,
	function ()
		local silverLbl = self._rootnode["silverLabel"]
		if silverLbl ~= nil and checkint(silverLbl:getString()) ~= game.player:getSilver() then
			silverLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 1.1),
			CCCallFunc:create(function ()
				silverLbl:setString(tostring(game.player:getSilver()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Silver)
	
	RegNotice(self,
	function ()
		local tiliLbl = self._rootnode["tili_Label"]
		if tiliLbl ~= nil and checkint(tiliLbl:getString()) ~= game.player:getStrength() then
			tiliLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 1.1),
			CCCallFunc:create(function ()
				tiliLbl:setString(tostring(game.player:getStrength()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Tili)
	
	RegNotice(self,
	function ()
		local nailiLbl = self._rootnode["naili_Label"]
		if nailiLbl ~= nil and checkint(nailiLbl:getString()) ~= game.player:getNaili() then
			nailiLbl:runAction(transition.sequence({
			CCScaleTo:create(0.2, 1.1),
			CCCallFunc:create(function ()
				nailiLbl:setString(tostring(game.player:getNaili()))
			end),
			CCScaleTo:create(0.1, 1)
			}))
		end
	end,
	NoticeKey.CommonUpdate_Label_Naili)
	
	RegNotice(self,
	function ()
		print("-------------------->事件接受_设置底部开关状态 : 关")
		self:setBottomBtnEnabled(false)
	end,
	NoticeKey.LOCK_BOTTOM)
	
	RegNotice(self,
	function ()
		print("-------------------->事件接受_设置底部开关状态 : 开")
		self:setBottomBtnEnabled(true)
	end,
	NoticeKey.UNLOCK_BOTTOM)
	
end

function BaseScene:unregNotice()
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Silver)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Gold)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Tili)
	UnRegNotice(self, NoticeKey.CommonUpdate_Label_Naili)
	UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
	UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
end

function BaseScene:setBottomBtnEnabled(bEnabled)
	if bEnabled then
		print("-------------------->设置底部开关状态 : 开")
	else
		print("-------------------->设置底部开关状态 : 关")
	end
	ResMgr.isBottomEnabled = bEnabled
	BottomBtnEvent.setTouchEnabled(bEnabled)
end

return BaseScene