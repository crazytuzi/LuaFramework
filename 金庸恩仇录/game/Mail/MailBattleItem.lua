require("utility.richtext.richText")
require("game.Biwu.BiwuFuc")
local BattleType = {
none = 0,
arena = 1,
duobao = 2,
biwu = 3
}

local MailBattleItem = class("MailBattleItem", function()
	return CCTableViewCell:new()
end)

function MailBattleItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("mail/mail_battle_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
	end
	return self._contentSz
end

function MailBattleItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local getMoreMailFunc = param.getMoreMailFunc
	self._mailTotalNum = param.totalNum
	self._curMailNum = param.curMailNum
	self._isCanShowMoreBtn = param.isCanShowMoreBtn
	self._id = param.id
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("mail/mail_battle_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	self:refreshItem(itemData)
	
	self._rootnode.duobaoBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if itemData.battleType == BattleType.arena then
			GameStateManager:ChangeState(GAME_STATE.STATE_ARENA)
		elseif itemData.battleType == BattleType.duobao then
			GameStateManager:ChangeState(GAME_STATE.STATE_DUOBAO)
		elseif itemData.battleType == BattleType.biwu then
			GameStateManager:ChangeState(GAME_STATE.STATE_BIWU)
		end
	end,
	CCControlEventTouchUpInside)
	
	return self
end

function MailBattleItem:refresh(param)
	self._id = param.id
	self:refreshItem(param.itemData)
end

function MailBattleItem:refreshItem(itemData)
	if itemData ~= nil then
		self._battleType = itemData.battleType
	end
	if self._isCanShowMoreBtn and self._id == self._curMailNum then
		self._rootnode.normal_node:setVisible(false)
		self._rootnode.getMore_tag:setVisible(true)
	else
		self._rootnode.normal_node:setVisible(true)
		self._rootnode.getMore_tag:setVisible(false)
		self._rootnode.time_lbl:setString(tostring(itemData.disDay))
		self._rootnode.title_lbl:setString(tostring(itemData.title))
		local duobaoBtn = self._rootnode.duobaoBtn
		if itemData.battleType == BattleType.arena then
			duobaoBtn:setVisible(true)
			resetctrbtnString(duobaoBtn, common:getLanguageString("@Goarena"))
		elseif itemData.battleType == BattleType.duobao then
			duobaoBtn:setVisible(true)
			resetctrbtnString(duobaoBtn, common:getLanguageString("@Gorob"))
		elseif itemData.battleType == BattleType.biwu then
			duobaoBtn:setVisible(true)
			resetctrbtnString(duobaoBtn, common:getLanguageString("@Gobiwu"))
		else
			duobaoBtn:setVisible(false)
			self._rootnode.content_bng:setContentSize(cc.size(600, self._rootnode.content_bng:getContentSize().height))
			self._rootnode.content_tag:setContentSize(cc.size(580, self._rootnode.content_tag:getContentSize().height))
		end
		local contentNode = self._rootnode.content_tag
		contentNode:removeAllChildren()
		local richHtmlText = itemData.richHtmlText
		local infoNode = getRichText(richHtmlText, contentNode:getContentSize().width)
		infoNode:setPosition(0, contentNode:getContentSize().height - 30)
		contentNode:addChild(infoNode)
	end
end

return MailBattleItem