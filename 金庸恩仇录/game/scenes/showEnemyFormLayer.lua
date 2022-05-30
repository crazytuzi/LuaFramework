local showEnemyFormLayer = class("", function()
	return require("utility.ShadeLayer").new()
end)

local lifeShowTag = 7251

function showEnemyFormLayer:ctor(param)
	self:setNodeEventEnabled(true)
	local _info = param.info
	local _title = param.title or ""
	local _confirmFunc = param.confirmFunc
	local _leftFunc = param.leftFunc
	local _rightFunc = param.rightFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_form_layer", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(_title)
	self._rootnode.tag_close:addHandleOfControlEvent(function()
		self:removeSelf()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	local btnVisible = function(btn, callFunc)
		if callFunc then
			btn:addHandleOfControlEvent(function()
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				callFunc()
			end,
			CCControlEventTouchUpInside)
			btn:setVisible(true)
		else
			btn:setVisible(false)
		end
	end
	btnVisible(self._rootnode.enterBtn, _confirmFunc)
	btnVisible(self._rootnode.leftBtn, _leftFunc)
	btnVisible(self._rootnode.rightBtn, _rightFunc)
	self._rootnode.zdlLabel:setString(tostring(_info.combat))
	ResMgr.oppName = _info.name
	local heroNameLabel = ui.newTTFLabelWithOutline({
	text = _info.name,
	font = FONTS_NAME.font_fzcy,
	size = 20,
	color = NAME_COLOR[_info.cards[1].star or 3],
	outlineColor = cc.c3b(255, 255, 255),
	align = ui.TEXT_ALIGN_LEFT
	})
	
	heroNameLabel:align(display.LEFT_CENTER)
	ResMgr.replaceKeyLableEx(heroNameLabel, self._rootnode, "playerNameLabel", 0, 0)	
	
	for i = 1, 6 do
		self._rootnode[string.format("headIcon_%d", i)]:setVisible(false)
	end
	
	for i = 1, 6 do
		if _info.cards[i] then
			local _baseInfo = ResMgr.getCardData(_info.cards[i].resId)
			local name
			if _info.cards[i].resId == 1 or _info.cards[i].resId == 2 then
				name = _info.name
			else
				name = _baseInfo.name
			end
			
			dump(_info)			
			
			local node = display.newNode()
			local namelabel = self._rootnode[string.format("heroNameLabel_%d", _info.cards[i].pos)]
			local x, y = namelabel:getPosition()
			namelabel:getParent():addChild(node)
			node:setPosition(x, y)
			
			local heroNameLabel = ui.newTTFLabelWithShadow({
			text = name,
			font = FONTS_NAME.font_fzcy,
			size = 18,
			color = NAME_COLOR[_info.cards[i].star],
			align = ui.TEXT_ALIGN_CENTER,
			shadowColor = FONT_COLOR.BLACK
			})
			node:addChild(heroNameLabel)
			if _info.cards[i].cls > 0 then
				local clsLabel = ui.newTTFLabelWithShadow({
				text = "+" .. tostring(_info.cards[i].cls),
				font = FONTS_NAME.font_fzcy,
				size = 18,
				color = cc.c3b(0, 228, 62),
				align = ui.TEXT_ALIGN_CENTER,
				shadowColor = FONT_COLOR.BLACK
				})
				heroNameLabel:setPosition(-clsLabel:getContentSize().width / 2, 0)
				clsLabel:setPosition(heroNameLabel:getContentSize().width / 2, 0)
				node:addChild(clsLabel)
			end
			
			local iconSprite = self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]
			ResMgr.refreshIcon({
			id = _baseInfo.id,
			resType = ResMgr.HERO,
			cls = _info.cards[i].cls,
			itemBg = iconSprite
			})
			local jobIcon = display.newSprite(string.format("#icon_frame_%d.png", _baseInfo.job))
			jobIcon:setPosition(15, 15)
			jobIcon:setScale(0.7)
			iconSprite:addChild(jobIcon)
			local levelLabel = ui.newTTFLabelWithShadow({
			text = tostring(_info.cards[i].level),
			font = FONTS_NAME.font_fzcy,
			size = 20,
			align = ui.TEXT_ALIGN_RIGHT,
			shadowColor = FONT_COLOR.BLACK
			})
			local iconSpriteSize = iconSprite:getContentSize()
			levelLabel:setPosition(iconSpriteSize.width - 4, 13)
			self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]:addChild(levelLabel)
			self._rootnode[string.format("headIcon_%d", _info.cards[i].pos)]:setVisible(true)
			iconSprite:removeChildByTag(lifeShowTag)
			if _info.cards[i].curLife then
				display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")
				local lifeBg = display.newSprite("#icon_bar_red.png")
				iconSprite:addChild(lifeBg)
				lifeBg:setTag(lifeShowTag)
				lifeBg:setPosition(iconSpriteSize.width * 0.5, -40)
				if _info.cards[i].curLife == 0 then
					local graySprite = display.newSprite("ui_common/icon_mask.png")
					iconSprite:addChild(graySprite)
					graySprite:setPosition(iconSpriteSize.width * 0.5, iconSpriteSize.height * 0.5)
					local deadLabel = ui.newTTFLabelWithShadow({
					text = common:getLanguageString("@Dead"),
					font = FONTS_NAME.font_fzcy,
					size = 20,
					color = cc.c3b(255, 62, 0),
					align = ui.TEXT_ALIGN_CENTER,
					shadowColor = FONT_COLOR.BLACK
					})
					iconSprite:addChild(deadLabel)
					deadLabel:setPosition(iconSpriteSize.width * 0.5, iconSpriteSize.height * 0.5)
				else
					local lifeBar = display.newSprite("#icon_bar_green.png")
					lifeBg:addChild(lifeBar)
					lifeBar:setAnchorPoint(0, 0)
					lifeBar:setScaleX(_info.cards[i].curLife / _info.cards[i].maxLife)
				end
			end
		end
	end
end

return showEnemyFormLayer