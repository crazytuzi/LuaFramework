display.addSpriteFramesWithFile("ui_icon_frame.plist", "ui_icon_frame.png")

local IconObj = class("IconObj", function()
	return display.newNode()
end)

function IconObj:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("public/public_icon.ccbi", proxy, self._rootnode)
	node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	self:addChild(node, 1)
	self:setContentSize(node:getContentSize())
	self:setAnchorPoint(0.5, 0.5)
	
	self.levelLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 18,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLableEx(self.levelLabel, self._rootnode, "lvLabel", 0, 0)
	self.levelLabel:align(display.RIGHT_CENTER)
	
	self.nameLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLable(self.nameLabel, self._rootnode.heroNameLabel, 0, 0)
	self.nameLabel:align(display.LEFT_CENTER)
	
	self.clsLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 18,
	color = cc.c3b(0, 228, 62),
	shadowColor = FONT_COLOR.BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	})
	
	ResMgr.replaceKeyLable(self.clsLabel, self._rootnode.heroNameLabel, 0, 0)
	self.clsLabel:align(display.LEFT_CENTER)
	
	self:refresh(param)
end
function IconObj:setState(a)
	if a == 1 then
		self._rootnode.maskSprite:setVisible(true)
		self._rootnode.tipLabel:setString(common:getLanguageString("@InBattle"))
		self._rootnode.tipLabel:setColor(cc.c3b(0, 228, 62))
	elseif a == 0 then
		self._rootnode.maskSprite:setVisible(true)
		self._rootnode.tipLabel:setString(common:getLanguageString("@Dead"))
		self._rootnode.tipLabel:setColor(cc.c3b(255, 62, 0))
	elseif a == 3 then
		self._rootnode.maskSprite:setVisible(true)
		self._rootnode.tipLabel:setString(common:getLanguageString("@Joined"))
		self._rootnode.tipLabel:setColor(cc.c3b(255, 62, 0))
	elseif a == 4 then
		self._rootnode.maskSprite:setVisible(true)
		self._rootnode.tipLabel:setString(common:getLanguageString("@zhuzhen_Joined"))
		self._rootnode.tipLabel:setColor(cc.c3b(255, 62, 0))
	else
		self._rootnode.maskSprite:setVisible(false)
	end
end
function IconObj:refresh(param)
	local id = param.id
	if id then
		local card
		if type(id) == "number" then
			card = ResMgr.getCardData(id)
		elseif type(id) == "table" then
			card = id
		end
		if card then
			local cls = param.cls or 0
			local path = "hero/icon/" .. card.arr_icon[cls + 1] .. ".png"
			local star = card.star[cls + 1]
			self._rootnode.bgSprite:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_bg_%d.png", star)))
			self._rootnode.iconSprite:setDisplayFrame(display.newSprite(path):getDisplayFrame())
			self._rootnode.boardSprite:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_board_%d.png", star)))
			local name = card.name
			if id == 1 or id == 2 then
				name = game.player:getPlayerName()
			end
			self.nameLabel:setString(name)
			self.nameLabel:setColor(NAME_COLOR[star])
			self._rootnode.jobSprite:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_%s.png", card.job)))
			self.levelLabel:setString(tostring(param.level or 20))
			local  width = self.nameLabel:getContentSize().width
			if cls > 0 then
				self.clsLabel:setString("+" .. tostring(cls))
				width = width  + self.clsLabel:getContentSize().width
				local x = self._rootnode.heroNameLabel:getPositionX() - width/2
				self.nameLabel:setPositionX(x)
				self.clsLabel:setPositionX(x + self.nameLabel:getContentSize().width)				
			else
				self.clsLabel:setString("")
				self.nameLabel:setPositionX(self._rootnode.heroNameLabel:getPositionX() - self.nameLabel:getContentSize().width/2)
			end
			
			local redBar = self._rootnode.redBar
			if param.hp then
				redBar:setVisible(true)
				local greenBar = self._rootnode.greenBar
				if param.hp[1] == 0 then
					param.state = 0
				end
				local rect = redBar:getTextureRect()
				local scaleHP = param.hp[1] / param.hp[2]
				scaleHP = math.min(1, scaleHP)
				scaleHP = math.max(0, scaleHP)
				greenBar:setScaleX(scaleHP)
			else
				redBar:setVisible(false)
			end
		end
	end
	self:setState(param.state)
end

return IconObj