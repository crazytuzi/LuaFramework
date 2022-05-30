local PosHero = class("PosHero", function()
	return display.newNode()
end)

function PosHero:ctor(param)
	local _info = param.info
	local _index = param.index or 1
	local _listener = param.listener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_hero_pos", proxy, self._rootnode)
	self:addChild(node)
	if _info and _info.cards then
		local randomIndex = math.random(1, #_info.cards)
		for k, v in ipairs(_info.cards) do
			if v.id == _info.showId then
				randomIndex = k
				break
			end
		end
		local randomHero = _info.cards[randomIndex]
		--dump(randomHero)
		local sprite = ResMgr.getHeroMidImage(randomHero.cardId, randomHero.cls, randomHero.fashionId)
		if sprite then
			self._rootnode.imageSprite:setDisplayFrame(sprite:getDisplayFrame())
		end
		
		--czy
		self._rootnode.touchNode:setTouchEnabled(true)
		self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" and _listener then
				self._rootnode.touchNode:setTouchEnabled(false)
				_listener(_index)
				self:performWithDelay(function()
					self._rootnode.touchNode:setTouchEnabled(true)
				end,
				1)
			end
		end)
	end
	self.floorName = ui.newTTFLabelWithShadow({
	text = _index .. common:getLanguageString("@Ceng"),
	font = FONTS_NAME.font_fzcy,
	size = 18,
	align = ui.TEXT_ALIGN_LEFT,
	color = cc.c3b(254, 249, 0),
	shadowColor = FONT_COLOR.BLACK,
	})
	ResMgr.replaceKeyLableEx(self.floorName, self._rootnode, "floorLabel", 0, 0)
	self.floorName:align(display.CENTER)
end

function PosHero:failFlag()
	self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame("huashan_board_0.png"))
end

function PosHero:showSelfHero(info)
	self.floorName = ui.newTTFLabelWithShadow({
	text = game.player:getPlayerName(),
	font = FONTS_NAME.font_fzcy,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	color = NAME_COLOR[info.star or 4],
	shadowColor = FONT_COLOR.BLACK,
	})
	ResMgr.replaceKeyLableEx(self.floorName, self._rootnode, "floorLabel", 0, -2)
	self.floorName:align(display.CENTER)
	
	self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame("huashan_name_bg.png"))
	--dump(info)
	if info.cardId ~= nil and info.cls ~= nil then
		local sprite = ResMgr.getHeroMidImage(info.cardId, info.cls, game.player:getFashionId())
		self._rootnode.imageSprite:setDisplayFrame(sprite:getDisplayFrame())
	end
end

function PosHero:showTmpSelf(info)
	local sprite = ResMgr.getHeroMidImage(info.cardId, info.cls, game.player:getFashionId())
	local imageSprite = self._rootnode.imageSprite
	imageSprite:addChild(sprite)
	sprite:setPosition(imageSprite:getContentSize().width / 2, imageSprite:getContentSize().height / 2)
	sprite:runAction(transition.sequence({
	CCFadeOut:create(0.8),
	CCRemoveSelf:create()
	}))
end

return PosHero