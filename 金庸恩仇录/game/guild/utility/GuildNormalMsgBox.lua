require("data.data_error_error")

local GuildNormalMsgBox = class("GuildNormalMsgBox", function()
	return require("utility.ShadeLayer").new()
end)

function GuildNormalMsgBox:setBtnEnabled(bEnaled)
	self._rootnode.single_confirmBtn:setEnabled(bEnaled)
	self._rootnode.confirmBtn:setEnabled(bEnaled)
	self._rootnode.cancelBtn:setEnabled(bEnaled)
	self._rootnode.tag_close:setEnabled(bEnaled)
end

function GuildNormalMsgBox:ctor(param)
	local title = param.title
	local msg = param.msg
	local isSingleBtn = param.isSingleBtn
	local confirmFunc = param.confirmFunc
	local cancelFunc = param.cancelFunc
	local isBuyExtraBuild = param.isBuyExtraBuild
	local extraCostGold = param.extraCostGold
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/guild/guild_normal_msgBox.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(title)
	if isBuyExtraBuild ~= nil and isBuyExtraBuild == true then
		local textBg = self._rootnode.text_bg
		local text = common:getLanguageString("@PurchaseAdditional", extraCostGold, common:getLanguageString("@Putongewaicishu"))
		local showSize = textBg:getContentSize()
		local infoNode = getRichText(text, showSize.width * 0.6)
		local infoSize = infoNode:getContentSize()
		textBg:addChild(infoNode)
		infoNode:setPosition((showSize.width - infoSize.width) * 0.5, showSize.height * 0.5)
	else
		self._rootnode.msg_lbl:setVisible(true)
		self._rootnode.msg_lbl:setString(msg)
	end
	
	local function closeFunc()
		if cancelFunc ~= nil then
			cancelFunc()
		end
		self:removeSelf()
	end
	local function confirm()
		if confirmFunc ~= nil then
			self:setBtnEnabled(false)
			confirmFunc(self)
		end
	end
	if isSingleBtn == true then
		self._rootnode.single_confirmBtn:setVisible(true)
		self._rootnode.normal_btn_node:setVisible(false)
		self._rootnode.single_confirmBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			confirm()
		end,
		CCControlEventTouchUpInside)
		
	else
		--
		self._rootnode.single_confirmBtn:setVisible(false)
		self._rootnode.normal_btn_node:setVisible(true)
		self._rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			closeFunc()
		end,
		CCControlEventTouchUpInside)
		
		--»∑»œ
		self._rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			confirm()
		end,
		CCControlEventTouchUpInside)
		
	end
	
	--πÿ±’
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
end

return GuildNormalMsgBox