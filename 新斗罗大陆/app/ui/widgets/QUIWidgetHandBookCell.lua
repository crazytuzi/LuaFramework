--
-- Author: Kumo.Wang
-- 图鉴列表cell
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetHandBookCell = class("QUIWidgetHandBookCell", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

QUIWidgetHandBookCell.EVENT_HERO_FRAMES_CLICK = "EVENT_HERO_FRAMES_CLICK"

function QUIWidgetHandBookCell:ctor(options)
	local ccbFile = "ccb/Widget_HandBook_Cell.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHandBookCell", callback = handler(self, self._onTriggerHandBookCell)},
		{ccbCallbackName = "onTriggerAdmire", callback = handler(self, self._onTriggerAdmire)},
	}
	QUIWidgetHandBookCell.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetHandBookCell:onEnter()
end

function QUIWidgetHandBookCell:onExit()
end

--刷新当前信息显示
function QUIWidgetHandBookCell:refreshInfo()
	self:setInfo({actorId = self._actorId})
end

function QUIWidgetHandBookCell:refreshAdmireInfo(isAnimation)
	self:_setAdmireInfo(isAnimation)
end

function QUIWidgetHandBookCell:setInfo(param)
	self._actorId = tonumber(param.actorId) or 0
	self._handBookType = remote.handBook:getHandBookTypeByActorID(self._actorId)
	self._aptitudeInfo = remote.handBook:getHeroAptitudeInfoByActorID(self._actorId)
	self._heroHandBookConfig = remote.handBook:getHeroHandBookConfigByActorID(self._actorId)
	-- print("QUIWidgetHandBookCell:setInfo()  ", self._actorId, self._handBookType)
	-- QPrintTable(self._aptitudeInfo)

	self:_setHeroInfo()
	self:_setAdmireInfo()
end

function QUIWidgetHandBookCell:isShowMask()
	return self._handBookType == remote.handBook.THEIR_HERO
end

function QUIWidgetHandBookCell:getName()
	return "QUIWidgetHandBookCell"
end

function QUIWidgetHandBookCell:getHero()
	return self._actorId
end

function QUIWidgetHandBookCell:setFramePos(pos)
	self._pos = pos
end

function QUIWidgetHandBookCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHandBookCell:_setAdmireInfo(isAnimation)
	local admireInfo = remote.handBook:getAdmireInfoByActorID( self._actorId )
	if admireInfo then
		if isAnimation and admireInfo.isAdmire then
			self:_showHeartAnimation()
		else
			self._ccbOwner.sp_admire_on:setVisible(admireInfo.isAdmire)
			self._ccbOwner.sp_admire_off:setVisible(not admireInfo.isAdmire)
		end
		self._ccbOwner.tf_admire_count:setString(remote.handBook:getTotalAdmireCount(admireInfo.totalAdmireCount))
	else
		self._ccbOwner.sp_admire_on:setVisible(false)
		self._ccbOwner.sp_admire_off:setVisible(true)
		self._ccbOwner.tf_admire_count:setString(0)
	end
end

function QUIWidgetHandBookCell:_showHeartAnimation()
    local ccbFile = remote.handBook:getHeartAnimation()
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, nil, function()
        	self:_setAdmireInfo()
        end, false)
end

function QUIWidgetHandBookCell:_setHeroInfo()
	local heroInfo = remote.handBook:getHeroInfoByActorID(self._actorId)
	if heroInfo then
		self._ccbOwner.tf_hero_name:setString(heroInfo.name)
		self._ccbOwner.tf_hero_name:setVisible(true)
		self:_setHeroCard()
	else
		self._ccbOwner.tf_hero_name:setVisible(false)
	end

	self._ccbOwner.node_their:setVisible(self._handBookType == remote.handBook.THEIR_HERO)

	self:_setProfession()
	self:_setSABC()
	-- self:_setFrameColour()
	self:_autoLayout()
end

function QUIWidgetHandBookCell:_setProfession()
	if self._handBookType == remote.handBook.OFFLINE_HERO then return end
	if self._actorId == nil then return end

    if self._professionalIcon == nil then 
	    self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
	    self._ccbOwner.node_hero_profession:addChild(self._professionalIcon)
	end
	self._spriteIconWidth = self._professionalIcon:getContentSize().width
    self._professionalIcon:setHero(self._actorId)
end

function QUIWidgetHandBookCell:_autoLayout()
	-- local heroInfo = remote.handBook:getHeroInfoByActorID(self._actorId)
	-- print(" QUIWidgetHandBookCell:_autoLayout() self._spriteIconWidth = ", heroInfo.name, self._spriteIconWidth)
	if self._spriteIconWidth then
		local tfWidth = self._ccbOwner.tf_hero_name:getContentSize().width

		self._ccbOwner.tf_hero_name:setPositionX(self._spriteIconWidth/2)
		self._ccbOwner.node_hero_profession:setPositionX(self._ccbOwner.tf_hero_name:getPositionX() - tfWidth/2 - self._spriteIconWidth/2)
	end
end

function QUIWidgetHandBookCell:_setSABC()
	self._ccbOwner.node_aptitude:setVisible(false)
	if self._handBookType == remote.handBook.OFFLINE_HERO then return end

	if self._aptitudeInfo and self._aptitudeInfo.lower then
    	q.setAptitudeShow(self._ccbOwner, self._aptitudeInfo.lower)
		self._ccbOwner.node_aptitude:setVisible(true)
	end
end

function QUIWidgetHandBookCell:_setFrameColour()
	self._ccbOwner.node_frame:removeAllChildren()
	local path
	if self._handBookType ~= remote.handBook.OFFLINE_HERO and self._aptitudeInfo then
		path = remote.handBook:getFrameByAptitude(self._aptitudeInfo.aptitude)
	else
		path = remote.handBook:getFrameByAptitude()
	end
	if path then
		local spFrame = CCScale9Sprite:create(path)
		spFrame:setContentSize(CCSize(192, 308))
		self._ccbOwner.node_frame:addChild(spFrame)
	end
end

function QUIWidgetHandBookCell:_setHeroCard( isSketch )
    self._ccbOwner.node_card:removeAllChildren()
    if isSketch or self._handBookType == remote.handBook.OFFLINE_HERO then
    	local sexBoo = self._heroHandBookConfig.sex == 1 and true or false
    	local spMask = nil
	    local maskPath = remote.handBook:getSketchByBoo(sexBoo)
	    if maskPath then
		    spMask = CCSprite:create(maskPath)
		    -- spMask:retain()
		end
    	self._ccbOwner.node_card:addChild(spMask)
    else
    	local sprite = CCSprite:create()
    	-- sprite:retain()
    	local _heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    	local _cardPath = ""
		if _heroInfo and _heroInfo.skinId and _heroInfo.skinId > 0 then
			local skinConfig = remote.heroSkin:getHeroSkinBySkinId(self._actorId, _heroInfo.skinId)
	        if skinConfig.skins_handBook then
	        	-- print("use skin handBookCard", self._actorId, skinConfig.skins_name)
	        	_cardPath = skinConfig.skins_handBook
	        	local frame = QSpriteFrameByPath(_cardPath)
	        	if frame then
					sprite:setDisplayFrame(frame)
				end
				if skinConfig.handBook_display then
					local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinConfig.handBook_display)
					local _isturn = skinDisplaySetConfig.isturn or 1
					if skinDisplaySetConfig.x then
						sprite:setPositionX(skinDisplaySetConfig.x)
					end
					if skinDisplaySetConfig.y then
						sprite:setPositionY(skinDisplaySetConfig.y)
					end
					if skinDisplaySetConfig.scale then
						sprite:setScaleX(_isturn * skinDisplaySetConfig.scale)
						sprite:setScaleY(skinDisplaySetConfig.scale)
					end
					if skinDisplaySetConfig.rotation then
						sprite:setRotation(skinDisplaySetConfig.rotation)
					end
				end
	        end
		end
		if _cardPath == "" then
			local dialogDisplay = remote.handBook:getDialogDisplayByActorID(self._actorId)
	    	if dialogDisplay and dialogDisplay.handBook_card then
	    		_cardPath = dialogDisplay.handBook_card
	    		local frame = QSpriteFrameByPath(_cardPath)
				sprite:setDisplayFrame(frame)
				sprite:setPosition(dialogDisplay.handBook_x, dialogDisplay.handBook_y)
				sprite:setScaleX(dialogDisplay.handBook_isturn * dialogDisplay.handBook_scale)
				sprite:setScaleY(dialogDisplay.handBook_scale)
				sprite:setRotation(dialogDisplay.handBook_rotation)
			else
				self:_setHeroCard(true)
				return
			end
		end

	    local size = self._ccbOwner.card_size:getContentSize()
	    local ccclippingNode = CCClippingNode:create()
	    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
	    layer:setPosition(-size.width/2, -size.height/2)
	    ccclippingNode:setAlphaThreshold(1)
	    ccclippingNode:setStencil(layer)
	    ccclippingNode:addChild(sprite)
	    self._ccbOwner.node_card:addChild(ccclippingNode)
    end
end

-- function QUIWidgetHandBookCell:_getMaskDrawNode()
-- 	-- print("QUIWidgetHandBookCell:_getMaskDrawNode() ", remote.handBook.maskDrawNode)
-- 	if remote.handBook.maskDrawNode then return remote.handBook.maskDrawNode end
-- 	local vertices = {}
--     for i = 1, 12, 1 do
--         local node = self._ccbOwner["node_mask_"..i]
--         local pos = ccp(node:getPosition())
--         table.insert(vertices, {pos.x, pos.y})
--     end

--     local param = {}
--     local drawNode = CCDrawNode:create()
--     drawNode:clear()
--     drawNode:drawPolygon(vertices, param)
--     remote.handBook.maskDrawNode = drawNode
--     remote.handBook.maskDrawNode:retain()
--     return remote.handBook.maskDrawNode
-- end

function QUIWidgetHandBookCell:_onTriggerHandBookCell()

end

function QUIWidgetHandBookCell:_onTriggerAdmire()

end

return QUIWidgetHandBookCell
