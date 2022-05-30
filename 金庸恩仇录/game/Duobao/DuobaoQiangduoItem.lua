local DuobaoQiangduoItem = class("DuobaoQiangduoItem", function()
	return CCTableViewCell:new()
end)

function DuobaoQiangduoItem:getContentSize()
	return cc.size(620, 180)
end

function DuobaoQiangduoItem:getTutoBtn()
	return self._rootnode.qiangduoBtn
end

function DuobaoQiangduoItem:getTenTutoBtn()
	return self._rootnode.qiangduo10Btn
end

function DuobaoQiangduoItem:updateItem(itemData)
	self._itemData = itemData
	self._rootnode.lvLbl:setString("LV." .. tostring(self._itemData.lv))
	self._rootnode.player_name:setColor(cc.c3b(99, 47, 8))
	self._rootnode.player_name:setString(self._itemData.name)
	local easyType = self._itemData.easyType
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	self._rootnode.probability_icon:setDisplayFrame(display.newSprite("#db_probability_" .. easyType .. ".png"):getDisplayFrame())
	local cardData = self._itemData.card
	if #cardData <= 0 then
		CCMessageBox(common:getLanguageString("@ServerBackDataError"), "Server Data Error")
	end
	for i = 1, 3 do
		local icon = self._rootnode["icon_" .. i]
		if cardData[i] then
			ResMgr.refreshIcon({
			itemBg = icon,
			id = cardData[i].resId,
			resType = ResMgr.HERO
			})
		else
			icon:setVisible(false)
		end
	end
	if self._itemData.type == 2 then
		self._rootnode.qiangduo10Btn:setVisible(true)
	else
		self._rootnode.qiangduo10Btn:setVisible(false)
	end
end

function DuobaoQiangduoItem:create(param)
	display.addSpriteFramesWithFile("ui/2015_03_18.plist", "ui/2015_03_18.png")
	local viewSize = param.viewSize
	self._snatchListener = param.snatchListener
	local _rob10Listener = param.rob10Listener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("duobao/duobao_qiangduo_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	self:updateItem(param.itemData)
	
	local qiangduoBtn = self._rootnode.qiangduoBtn
	self._rootnode.qiangduoBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		ResMgr.oppName = self._itemData.name
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		qiangduoBtn:setEnabled(false)
		self._snatchListener(self:getIdx() + 1)
		qiangduoBtn:setEnabled(true)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.qiangduo10Btn:addHandleOfControlEvent(function()
		_rob10Listener(self:getIdx() + 1)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	return self
end

function DuobaoQiangduoItem:refresh(itemData)
	self:updateItem(itemData)
end

return DuobaoQiangduoItem