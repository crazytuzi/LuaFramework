local FormSettingCard = class("FormSettingCard", function ()
	return display.newNode()
end)

local TouchCard = class("TouchCard", function (param)
	return require("game.Object.CardObj").new(param)
end)

function TouchCard:ctor(param)
	self:setTag(123)
end

function FormSettingCard:ctor(param)
	local _data = param.data
	local _touchBegan = param.touchBegan
	local _touchMove = param.touchMove
	local _touchEnd = param.touchEnd
	local _index = param.index
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("formation/formation_setting_card.ccbi", proxy, rootnode)
	self:addChild(node, 1)
	local _bOpen = true
	local _bg = rootnode.imageSprite
	local _sz = _bg:getContentSize()
	local _pos = cc.p(_sz.width / 2, _sz.height / 2)
	_bg:setTouchEnabled(true)
	rootnode.lvNum_node:setVisible(false)
	local nameLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 20,
	shadowColor = FONT_COLOR.BLACK
	})
	
	rootnode.nameNode:addChild(nameLabel)
	nameLabel:setPosition(nameLabel:getContentSize().width / 2, 0)
	
	local _toucheBg = tolua.cast(cc.Layer:create(),"cc.Layer")
	_toucheBg:setTouchEnabled(true)
	self:addChild(_toucheBg)
	
	local image
	local function touchBegan(event)
		if self:isInCard(event.x, event.y) then
			if _bOpen then
				image = _bg:getChildByTag(123)
				if image then
					_touchBegan({
					cardnode = self,
					image = image,
					event = event
					})
					return true
				end
			else
				show_tip_label(common:getLanguageString("@LocationXOpen", self:getOpenLv()))
			end
			_touchBegan({cardnode = self, event = event})
			return false
		end
		return false
	end
	local function touchMoved(event)
		if image then
			_touchMove({
			cardnode = self,
			image = image,
			event = event
			})
		end
	end
	local function touchEnded(event)
		if image then
			_touchEnd({
			cardnode = self,
			image = image,
			event = event
			})
		end
	end
	function self.setTouchEnabled(_, b)
		_toucheBg:setTouchEnabled(b)
	end
	
	local prevX
	local prevY
	_toucheBg:registerScriptTouchHandler(function (eventname, x, y)
		local event = {name = eventname, x = x, y = y, prevX = prevX, prevY = prevY}
		prevX = x
		prevY = y
		if event.name == "began" then
			return touchBegan(event)
		elseif event.name == "moved" then
			touchMoved(event)
		elseif event.name == "ended" then
			touchEnded(event)
		end
	end)
	
	function self.equipCard(_, cardData)
		if _bOpen and type(cardData) == "table" then
			rootnode.lvLabel:setString(tostring(cardData.level))
			rootnode.lvNum_node:setVisible(true)
			local card = TouchCard.new({
			id = cardData.resId,
			cls = cardData.cls,
			lv = cardData.level,
			star = cardData.star,
			fashionId = cardData.fashionId
			})
			card:setPosition(_pos)
			_bg:addChild(card)
			if cardData.resId == 1 or cardData.resId == 2 then
				nameLabel:setString(game.player:getPlayerName())
			else
				nameLabel:setString(card:getName())
			end
			nameLabel:setColor(NAME_COLOR[card:getStar(card:getStar())])
			if card:getCls() > 0 then
				rootnode.clsLabel:setString(string.format("+%d", card:getCls()))
				rootnode.clsLabel:setPosition(nameLabel:getContentSize().width / 2, 0)
			else
				rootnode.clsLabel:setString("")
			end
		end
	end
	
	function self.getTargetPos()
		return _pos
	end
	
	function self.isInCard(_, x, y)
		if cc.rectContainsPoint(cc.rect(0, 0, _sz.width, _sz.height), _bg:convertToNodeSpace(cc.p(x, y))) then
			return true
		else
			return false
		end
	end
	
	function self.getHeroImage()
		return _bg:getChildByTag(123)
	end
	
	function self.addHeroImage(_, card)
		if card then
			_bg:addChild(card)
			rootnode.lvLabel:setString(tostring(card:getLv()))
			rootnode.lvNum_node:setVisible(true)
			if card:getResId() == 1 or card:getResId() == 2 then
				nameLabel:setString(game.player:getPlayerName())
			else
				nameLabel:setString(card:getName())
			end
			nameLabel:setColor(NAME_COLOR[card:getStar(card:getStar())])
			if card:getCls() > 0 then
				rootnode.clsLabel:setString(string.format("+%d", card:getCls()))
				rootnode.clsLabel:setPosition(nameLabel:getContentSize().width / 2, 0)
			else
				rootnode.clsLabel:setString("")
			end
		else
			rootnode.lvLabel:setString("0")
			rootnode.lvNum_node:setVisible(false)
			nameLabel:setString("")
			rootnode.clsLabel:setString("")
		end
	end
	
	function self.empty(_)
		if _bg:getChildByTag(123) then
			return false
		end
		return true
	end
	
	function self.getIndex(_)
		return _index
	end
	
	function self.isOpen(_)
		return _bOpen
	end
	
	self:equipCard(_data)
	self._bg = _bg
	
end

function FormSettingCard:switchWithCard(touchCard, x, y)
	if self:isOpen() then
		local cardA = self:getHeroImage()
		local cardB = touchCard:getHeroImage()
		if cardA == cardB then
			return false
		end
		if cardA then
			cardA:retain()
			cardA:removeFromParentAndCleanup(false)
		end
		cardB:retain()
		cardB:removeFromParentAndCleanup(false)
		cardB:setPosition(self._bg:convertToNodeSpace(cc.p(x, y)))
		self:addHeroImage(cardB)
		touchCard:addHeroImage(cardA)
		cardB:release()
		if cardA then
			cardA:release()
		end
		return true
	else
		show_tip_label(common:getLanguageString("@LocationXOpen", self:getOpenLv()))
		return false
	end
end

return FormSettingCard