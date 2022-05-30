local COST_TYPE = {silver = 1, gold = 2}
local yColor = cc.c3b(255, 222, 0)

local GuildDadianContributeItem = class("GuildDadianContributeItem", function()
	return CCTableViewCell:new()
end)

function GuildDadianContributeItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("guild/guild_dadian_contribute_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
	end
	return self._contentSz
end

function GuildDadianContributeItem:getId()
	return self._id
end

function GuildDadianContributeItem:setBtnEnabled(bEnabled)
	self._rootnode.contributeBtn:setEnabled(bEnabled)
end

function GuildDadianContributeItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local hasContribute = param.hasContribute
	local contributeFunc = param.contributeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_dadian_contribute_item.ccbi", proxy, self._rootnode)
	node:setPosition(0, viewSize.height / 2)
	self:addChild(node)
	self:createTTF(common:getLanguageString("@Consume"), FONT_COLOR.WHITE, self._rootnode, "msg_lbl_1_1")
	self:createTTF(common:getLanguageString("@Increase"), FONT_COLOR.WHITE, self._rootnode, "msg_lbl_2_1")
	self:createTTF(common:getLanguageString("@Guildfinancing"), FONT_COLOR.WHITE, self._rootnode, "msg_lbl_2_3")
	self:createTTF(common:getLanguageString("@Increase"), FONT_COLOR.WHITE, self._rootnode, "msg_lbl_3_1")
	self:createTTF(common:getLanguageString("@PersonalTR"), cc.c3b(0, 219, 52), self._rootnode, "msg_lbl_3_3")
	self:refreshItem(itemData)
	
	local contributeBtn = self._rootnode.contributeBtn
	if hasContribute == true then
		contributeBtn:setEnabled(false)
	elseif hasContribute == false then
		--捐赠
		contributeBtn:setEnabled(true)
		contributeBtn:addHandleOfControlEvent(function(eventName, sender)
			if contributeFunc ~= nil then
				contributeFunc(self)
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end,
		CCControlEventTouchUpInside)
	end
	return self
end

function GuildDadianContributeItem:createTTF(text, color, nodes, name)
	local lbl = ui.newTTFLabelWithShadow({
	text = text,
	size = 18,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = color,
	shadowColor = FONT_COLOR.BLACK,
	})
	ResMgr.replaceKeyLableEx(lbl, nodes, name, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildDadianContributeItem:getShadowLblWidth(node)
	return node:getContentSize().width
end

function GuildDadianContributeItem:refresh(itemData)
	self:refreshItem(itemData)
end

function GuildDadianContributeItem:refreshItem(itemData)
	self._id = itemData.id
	local iconName = "#guild_dd_coin_icon_" .. tostring(self._id) .. ".png"
	self._rootnode.coin_icon:setDisplayFrame(display.newSprite(iconName):getDisplayFrame())
	--local titleName = "#guild_dd_title_icon_" .. tostring(self._id) .. ".png"
	--self._rootnode.title_icon:setDisplayFrame(display.newSprite(titleName):getDisplayFrame())
	
	--增加公会的
	local addLbl = self:createTTF(tostring(itemData.addmoney), yColor, self._rootnode,"msg_lbl_2_2")
	addLbl:setPositionX(addLbl:getPositionX() - addLbl:getContentSize().width / 2)
	--自己的
	local selfLbl = self:createTTF(tostring(itemData.requirements), yColor, self._rootnode,"msg_lbl_3_2")
	selfLbl:setPositionX(selfLbl:getPositionX()- selfLbl:getContentSize().width / 2)
	
	local color, needCoinStr
	if itemData.type == COST_TYPE.silver then
		color = cc.c3b(22, 255, 255)
		needCoinStr = tostring(itemData.number) .. " " .. common:getLanguageString("@SilverLabel")
	elseif itemData.type == COST_TYPE.gold then
		color = yColor
		needCoinStr = tostring(itemData.number) .. " " .. common:getLanguageString("@Goldlabel")
	end
	self:createTTF(needCoinStr, color, self._rootnode, "msg_lbl_1_2")
	self._rootnode.msg_lbl_1_2:setPositionX(self._rootnode.msg_lbl_1_1:getPositionX() + self:getShadowLblWidth(self._rootnode.msg_lbl_1_1))
	
	self._rootnode.msg_lbl_2_2:setPositionX(self._rootnode.msg_lbl_2_1:getPositionX() + self:getShadowLblWidth(self._rootnode.msg_lbl_2_1))
	self._rootnode.msg_lbl_2_3:setPositionX(self._rootnode.msg_lbl_2_2:getPositionX() + self:getShadowLblWidth(self._rootnode.msg_lbl_2_2))
	
	self._rootnode.msg_lbl_3_2:setPositionX(self._rootnode.msg_lbl_3_1:getPositionX() + self:getShadowLblWidth(self._rootnode.msg_lbl_3_1))
	self._rootnode.msg_lbl_3_3:setPositionX(self._rootnode.msg_lbl_3_2:getPositionX() + self:getShadowLblWidth(self._rootnode.msg_lbl_3_2))
end

return GuildDadianContributeItem