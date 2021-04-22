--
-- Author: Your Name
-- Date: 2014-07-10 18:54:20
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetItemsBox = class("QUIWidgetItemsBox", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItmePrompt = import(".QUIWidgetItmePrompt") 
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetHeroHeadStar = import("..widgets.QUIWidgetHeroHeadStar")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

QUIWidgetItemsBox.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetItemsBox.EVENT_BEGAIN = "ITEM_EVENT_BEGAIN"
QUIWidgetItemsBox.EVENT_END = "ITEM_EVENT_END"
QUIWidgetItemsBox.EVENT_MINUS_CLICK = "EVENT_MINUS_CLICK"

QUIWidgetItemsBox.CRICLE = "CRICLE"
QUIWidgetItemsBox.SCRAP = "SCRAP"
QUIWidgetItemsBox.RECT = "RECT"
QUIWidgetItemsBox.MAGICHERB = "MAGICHERB"

QUIWidgetItemsBox.rect_frame = QResPath("rect_frame")
QUIWidgetItemsBox.color_frame = {}
QUIWidgetItemsBox.color_frame["default"] = QResPath("color_frame_default")
QUIWidgetItemsBox.color_frame["white"] = QResPath("color_frame_white")
QUIWidgetItemsBox.color_frame["green"] = QResPath("color_frame_green")
QUIWidgetItemsBox.color_frame["blue"] = QResPath("color_frame_blue")
QUIWidgetItemsBox.color_frame["purple"] = QResPath("color_frame_purple")
QUIWidgetItemsBox.color_frame["orange"] = QResPath("color_frame_orange")
QUIWidgetItemsBox.color_frame["red"] = QResPath("color_frame_red")
QUIWidgetItemsBox.color_frame["yellow"] = QResPath("color_frame_yellow")
QUIWidgetItemsBox.circle_frame = QResPath("circle_frame")

QUIWidgetItemsBox.color_frame["spar"] = QResPath("color_frame_spar")

function QUIWidgetItemsBox:ctor(options)
	local ccbFile = "ccb/Widget_ItemBox.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerMinus", callback = handler(self, self._onTriggerMinus)},
        {ccbCallbackName = "onTriggerNewMinus",callback = handler(self,self._onTriggerNewMinus)},
    }
	QUIWidgetItemsBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    -- setShadow5(self._ccbOwner.tf_goods_num)
	
    self:setNodeVisible(self._ccbOwner.node_goods,true)
    self:setTFText(self._ccbOwner.tf_goods_num,"")
    self:setNodeVisible(self._ccbOwner.node_mask,false)

	self.icon = CCSprite:create()
	self._ccbOwner.node_icon:addChild(self.icon)

	self.gloryTypeIcon = CCSprite:create(QResPath("itemBoxGloryTowerTypeIcon"))
	self._ccbOwner.sp_gloryTowerType:addChild(self.gloryTypeIcon)

    self:resetAll()
    self.promptTipIsOpen = false
    self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.tf_noWear:setVisible(false)
	self._nameWidth = 120
	self._colorIndex = 1
	self._isNeedshadow = true
	self._magicHerbSid = nil
end

function QUIWidgetItemsBox:setNeedshadow( boo )
	self._isNeedshadow = boo
	TFSetDisableOutline(self._ccbOwner.tf_goods_name, not boo)
end

function QUIWidgetItemsBox:setName(itemName)
	self:setTFText(self._ccbOwner.tf_goods_name, itemName)
end

function QUIWidgetItemsBox:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_select_piece, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_light, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_light_acitivity, self._glLayerIndex)--
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_back, self._glLayerIndex)--
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_bj, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_scrap_bj, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self.icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_mask, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_mask_scrap, self._glLayerIndex)
	
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_bar, self._glLayerIndex)--
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_rect_normal, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_break, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_rect, self._glLayerIndex)
	
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_scrap, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_scrap_normal, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_gray_state, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.minus, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_goods, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_goods_num, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_goods_new, self._glLayerIndex)	
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_sign_light, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_effect, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_star, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.talentIconParent, self._glLayerIndex)
	if self._talentIcon then
		self._glLayerIndex = q.nodeAddGLLayer(self._talentIcon, self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_pingzhi, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.red_tip, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_noWear, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_goods_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_gloryTowerType, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self.gloryTypeIcon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_plus, self._glLayerIndex)

	return self._glLayerIndex
end

function QUIWidgetItemsBox:setPromptIsOpen(value)
  self.promptTipIsOpen = value
end

function QUIWidgetItemsBox:getItemId()
	return self._itemID
end

function QUIWidgetItemsBox:getItemType()
	return self._itemType
end

function QUIWidgetItemsBox:resetAll()
	-- self:hideAllColor()
	self._selectNode = self._ccbOwner.node_select
	self._ccbOwner.node_select_piece:setVisible(false)
	self:selected(false)
	self:setNodeVisible(self._ccbOwner.icon,false)
	self.icon:setVisible(false)
	self:setTFText(self._ccbOwner.tf_goods_num,"")
	self:setTFText(self._ccbOwner.tf_goods_name,"")
	self._ccbOwner.tf_goods_num:setScale(1)
	self:setNodeVisible(self._ccbOwner.node_goods_new,false)
	self._ccbOwner.node_bar:setVisible(false)
	self._ccbOwner.node_break:setVisible(false)
	self._ccbOwner.node_scrap:setVisible(false)
	self._ccbOwner.node_mask:setVisible(false)
	self._ccbOwner.node_scrap_bj:setVisible(false)
	self._ccbOwner.node_bj:setVisible(false)
	self._ccbOwner.node_gray_state:setVisible(false)
	self._ccbOwner.node_expired:setVisible(false)
	self._ccbOwner.node_award:setVisible(false)
	self._ccbOwner.node_magicHerb:setVisible(false)
	self._ccbOwner.node_award:setVisible(false)
	self._ccbOwner.node_award_has:setVisible(false)
	self._ccbOwner.node_first:setVisible(false)

	self._colorType = QUIWidgetItemsBox.RECT
	self._talentIcon = nil
	self._ccbOwner.talentIconParent:removeAllChildren()
	self._ccbOwner.node_pingzhi:removeAllChildren()
	self.gloryTypeIcon:setVisible(false)
	self._ccbOwner.sp_plus:setVisible(false)
	self._ccbOwner.sp_special:setVisible(false)
	self._ccbOwner.sp_yilingqu:setVisible(false)
	self._ccbOwner.sp_unlock:setVisible(false)

	self:setNodeVisible(self._ccbOwner.node_mask_scrap,false)
	if self._star ~= nil then
		self._star:setStar(-1)
	end
    self:setColor("default", QUIWidgetItemsBox.RECT)
end

function QUIWidgetItemsBox:getContentSize()
	return self._ccbOwner.sprite_back:getContentSize()
end
function QUIWidgetItemsBox:boundingBox( )
	-- body
	
	local scalex = self:getScaleX() or 1
	local scaley = self:getScaleY() or 1
	local size = self._ccbOwner.sprite_back:getContentSize()
	return {origin={x = 0, y = 0}, size = {width = (size.width + 16) * scalex, height = (size.height + 16) * scaley}}

end

function QUIWidgetItemsBox:onEnter()
	self._ccbOwner.sprite_back:setTouchEnabled(true)
	self._ccbOwner.sprite_back:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self._ccbOwner.sprite_back:setTouchSwallowEnabled(true)
	self._ccbOwner.sprite_back:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))

	self._ccbOwner.minus:setTouchEnabled(true)
	self._ccbOwner.minus:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self._ccbOwner.minus:setTouchSwallowEnabled(true)
	self._ccbOwner.minus:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTriggerMinus))

	self._itemNumScroll = QTextFiledScrollUtils.new()
end

function QUIWidgetItemsBox:onExit()
	self._ccbOwner.sprite_back:setTouchEnabled(false)
	self._ccbOwner.sprite_back:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)

	self:removeEffect()

   	if self._itemNumScroll then
        self._itemNumScroll:stopUpdate()
        self._itemNumScroll = nil
    end

	self:removeAllEventListeners()
	if self.promptTipIsOpen ~= false then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBox.EVENT_END , eventTarget = self})
	end
end

function QUIWidgetItemsBox:setBoxScale(scale)
	if scale == nil then return end
	self._ccbOwner.node_box:setScale(scale)
end

function QUIWidgetItemsBox:setColor(name, colorType)
	self._colorType = colorType or QUIWidgetItemsBox.RECT
	--保存品质序号 在config QIDEA_QUALITY_COLOR中查询
	local index = 0 
	for i,colourName in ipairs(EQUIPMENT_QUALITY) do
		if colourName == name then
			index = i
			break
		end
	end
	index = math.max(index,1)
	index = math.min(index,6)
	self._colorIndex = index
	local colour = name or "default"
	if QUIWidgetItemsBox.color_frame[colour] ~= nil then
		if self._colorType == QUIWidgetItemsBox.SCRAP then
			self._selectNode = self._ccbOwner.node_select_piece
			self._ccbOwner.node_bar:setVisible(false)
			self._ccbOwner.node_bj:setVisible(false)
			self._ccbOwner.node_scrap_bj:setVisible(true)
			self._ccbOwner.node_scrap:setVisible(true)
			self:addSpriteFrame(self._ccbOwner.node_scrap_normal, QUIWidgetItemsBox.color_frame[colour][2])
		elseif self._colorType == QUIWidgetItemsBox.CRICLE then
			self._selectNode = self._ccbOwner.node_select
			self._ccbOwner.node_bar:setVisible(true)
			self._ccbOwner.node_bj:setVisible(false)
			self._ccbOwner.node_scrap_bj:setVisible(false)
			self:addSpriteFrame(self._ccbOwner.node_rect_normal, QUIWidgetItemsBox.color_frame[colour][3])
		elseif self._colorType == QUIWidgetItemsBox.RECT then
			self._selectNode = self._ccbOwner.node_select
			self._ccbOwner.node_bar:setVisible(true)
			self._ccbOwner.node_bj:setVisible(true)
			self._ccbOwner.node_scrap_bj:setVisible(false)
			self:addSpriteFrame(self._ccbOwner.node_rect_normal, QUIWidgetItemsBox.color_frame[colour][1])
		elseif self._colorType == QUIWidgetItemsBox.MAGICHERB then
			self._selectNode = self._ccbOwner.node_magicHerb_selected
			self._ccbOwner.node_magicHerb:setVisible(true)
	    	self._ccbOwner.node_bar:setVisible(false)
			self._ccbOwner.node_bj:setVisible(false)
			self._ccbOwner.node_scrap_bj:setVisible(false)
			self._ccbOwner.node_scrap:setVisible(false)
		end
	end
end

--[[
	设置突破
]]
function QUIWidgetItemsBox:setBreak(level)
	level = tonumber(level)
	if level == nil then level = 0 end
	if QUIWidgetItemsBox.rect_frame[level+1] ~= nil then
		self._ccbOwner.sp_rect:setVisible(true)
		self:addSpriteFrame(self._ccbOwner.sp_rect, QUIWidgetItemsBox.rect_frame[level+1])
	end
	self._ccbOwner.node_break:setVisible(true)
end

--[[
	@param ccbfile 要加载的动画ccb文件
	@param isfront 是否在前面显示
]]
function QUIWidgetItemsBox:showBoxEffect(ccbFile, isfront, offsetX, offsetY, scale)
	if offsetX == nil then offsetX = 0 end
	if offsetY == nil then offsetY = 0 end
	if scale == nil then scale = 1 end
	if self._effectFile == nil then
		self._effectFile = CCBuilderReaderLoad(ccbFile, CCBProxy:create(), {})
		self._effectFile:setScale(scale)
		if isfront == true then
			self._ccbOwner.node_sign_light:addChild(self._effectFile)
		else
			self._ccbOwner.node_light:addChild(self._effectFile)
		end
		local pos = ccp(self._effectFile:getPosition())
		self._effectFile:setPosition(pos.x + offsetX, pos.y + offsetY)

	end
end

--添加一个特效 框
function QUIWidgetItemsBox:addChildToNodeSignLight( node )
	-- body
	if node then
		self._ccbOwner.node_sign_light:addChild(node)
	end
end

--移除动画 
function QUIWidgetItemsBox:removeEffect()
	if self._effectFile ~= nil then
		self._effectFile:removeFromParent()
		self._effectFile = nil
	end
end

function QUIWidgetItemsBox:showEffect()
	if self._itemType == ITEM_TYPE.ITEM then
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemID)

		if itemInfo.type == ITEM_CONFIG_TYPE.SOUL or itemInfo.highlight == 2  then
			if itemInfo.colour == ITEM_QUALITY_INDEX.BLUE then
				self:showBoxEffect("Widget_AchieveHero_light_blue.ccbi")
			elseif itemInfo.colour == ITEM_QUALITY_INDEX.PURPLE then
				self:showBoxEffect("Widget_AchieveHero_light_purple.ccbi")
			elseif itemInfo.colour == ITEM_QUALITY_INDEX.ORANGE then
				self:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
			elseif itemInfo.colour == ITEM_QUALITY_INDEX.RED then
				self:showBoxEffect("Widget_AchieveHero_light_red.ccbi")
			end
		elseif itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
			local sabcInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(itemInfo.gemstone_quality)
			if sabcInfo ~= nil and sabcInfo.lower == "s" then
				self:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
			end
		elseif itemInfo.id == 601002 then
			self:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
		elseif itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE or itemInfo.highlight == 1 then
			self:showBoxEffect("effects/Auto_Skill_light.ccbi", true, 0, -5, 1.2)
		end
	end
	if self._itemType == ITEM_TYPE.HERO then
		self:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
	end
end

function QUIWidgetItemsBox:setGloryTowerType( boo )
	if boo then
		if self.gloryTypeIcon == nil then
			self.gloryTypeIcon = CCSprite:create(QResPath("itemBoxGloryTowerTypeIcon"))
		end
		self.gloryTypeIcon:setVisible(true)
	else
		self.gloryTypeIcon:setVisible(false)
	end
end

function QUIWidgetItemsBox:setGoodsInfoByID(itemID, goodsNum )
	-- body
	local itemType = remote.items:getItemType(itemID)
	if itemType ~= nil and  itemType ~= ITEM_TYPE.ITEM then
		self:setGoodsInfo(itemID, itemType, goodsNum)
	else
		self:setGoodsInfo(itemID, ITEM_TYPE.ITEM, goodsNum)
	end
end

--xuriu: 使用scorllView时可使用此接口
function QUIWidgetItemsBox:setInfo(param)
	self:setGoodsInfo(param.itemID or param.itemId, param.itemType, param.count, param.froceShow)

	if param.index ~= nil then
		self:setIndex(param.index)
	end
	if param.redTip ~= nil then
		self:showRedTips(param.redTip)
	end
	if param.addLine ~= nil then
		self:setBackPackLine(param.addLine)
	end
	if self._selectPosition ~= nil and self._selectPosition ~= 0 then
		self:selected(self._selectPosition == param.index)
	end
end

function QUIWidgetItemsBox:setGoodsInfo(itemID, itemType, goodsNum, froceShow, isBackPack)
	self._itemID = itemID
	self._itemType = remote.items:getItemType(itemType)
	self:resetAll()
	self._name = ""
	if self._itemType == ITEM_TYPE.ITEM then 
  		self:_showAsItem(itemID, goodsNum, froceShow)
	elseif self._itemType == ITEM_TYPE.GEMSTONE then 
  		self:_showAsGemstone(itemID, goodsNum, froceShow)
	elseif self._itemType == ITEM_TYPE.HERO then
  		self:_showAsHero(itemID, goodsNum, froceShow)
	elseif self._itemType == ITEM_TYPE.ZUOQI then
		self:_showAsMount(itemID, goodsNum, froceShow)
	elseif self._itemType == ITEM_TYPE.ARTIFACT then
		self:_showAsItem(itemID, goodsNum, froceShow)
	elseif self._itemType == ITEM_TYPE.SPAR then
		self:_showAsSpar(itemID, goodsNum, froceShow)
	elseif self._itemType == ITEM_TYPE.MAGICHERB then
		self:_showAsMagicHerb(itemID, goodsNum, froceShow)
	else
		self:_showAsResouce(goodsNum, froceShow)
	end

	local skinStatus = remote.heroSkin:checkItemSkinByItem(itemID)
	if skinStatus == remote.heroSkin.ITEM_SKIN_ACTIVATED then
		self:setAwardName('已激活',skinStatus)
	elseif skinStatus == remote.heroSkin.ITEM_SKIN_HAS and not isBackPack then
		self:setAwardName('已拥有', skinStatus)
	end
	local headStatus = remote.headProp:checkItemHeadByItem(itemID)
	if headStatus == remote.headProp.ITEM_HEAD_ACTIVATED then
		self:setAwardName('已激活',headStatus)
	elseif headStatus == remote.headProp.ITEM_HEAD_HAS and not isBackPack then
		self:setAwardName('已拥有', headStatus)
	end	
end

--当作Hero来显示
function QUIWidgetItemsBox:_showAsHero(itemID, goodsNum, froceShow)
	local heroDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(itemID)
	if nil ~= heroDisplay then 
		self._name = heroDisplay.name
		self:_setItemIconAndCount(heroDisplay.icon, goodsNum, froceShow)
		self:_showSoulStar()
		for _,value in ipairs(HERO_SABC) do
	        if value.aptitude == tonumber(heroDisplay.aptitude) then
				self:setColor(value.color, QUIWidgetItemsBox.RECT)
				break
	        end
	    end
	end
end

--当作暗器来显示
function QUIWidgetItemsBox:_showAsMount(itemID, goodsNum, froceShow)
	local heroDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(itemID)
	if nil ~= heroDisplay then 
		self._name = heroDisplay.name
		self:_setItemIconAndCount(heroDisplay.icon, goodsNum, froceShow)
		for _,value in ipairs(HERO_SABC) do
	        if value.aptitude == tonumber(heroDisplay.aptitude) then
				self:setColor(value.color, QUIWidgetItemsBox.RECT)
				break
	        end
	    end
	end
end

--当作item来显示
function QUIWidgetItemsBox:_showAsItem(itemID, goodsNum, froceShow)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	if itemInfo == nil then return end
	self._name = itemInfo.name
	if itemInfo.break_through ~= nil then
		self:setBreak(itemInfo.break_through)
	elseif itemInfo.type == ITEM_CONFIG_TYPE.SOUL then
		local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemID)
		if actorId == nil then return end
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.SCRAP)
		self:_showSoulFragStar()
	elseif itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.SCRAP)
		local sabcInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(itemInfo.gemstone_quality)
		if sabcInfo ~= nil then
			self:showSabc(sabcInfo.lower)
		end
	elseif itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.CRICLE)
		local sabcInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(itemInfo.gemstone_quality)
		if sabcInfo ~= nil then
			self:showSabc(sabcInfo.lower)
		end
	elseif itemInfo.type == ITEM_CONFIG_TYPE.ZUOQI then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.SCRAP)
		local sabcInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(itemInfo.gemstone_quality)
		if sabcInfo ~= nil then
			self:showSabc(sabcInfo.lower)
		end
	elseif itemInfo.type == ITEM_CONFIG_TYPE.ARTIFACT_PIECE then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.SCRAP)
		local targetItems = remote.items:getItemsByMaterialId(itemID)
		if targetItems ~= nil and #targetItems == 1 then
			local itemId = targetItems[1].item_id
			local actorId = remote.artifact:getActorIdByArtifactId(itemId)
			if actorId ~= nil then
				local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
				self:showSabc(aptitudeInfo.lower)
			end
		end
	elseif itemInfo.type == ITEM_CONFIG_TYPE.ARTIFACT then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.RECT)
		local actorId = remote.artifact:getActorIdByArtifactId(itemID)
		if actorId ~= nil then
			local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
			self:showSabc(aptitudeInfo.lower)
		end
	elseif itemInfo.type == ITEM_CONFIG_TYPE.SPAR_PIECE then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.SCRAP)
	elseif itemInfo.type == ITEM_CONFIG_TYPE.GARNET or itemInfo.type == ITEM_CONFIG_TYPE.OBSIDIAN then
		self:_showAsSpar(itemID, goodsNum, froceShow)

	elseif itemInfo.type == ITEM_CONFIG_TYPE.MAGICHERB then
		self:_showAsMagicHerb(itemID, goodsNum, froceShow)
	elseif itemInfo.type == ITEM_CONFIG_TYPE.SOULSPIRIT_PIECE then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.SCRAP)
		self:_showSoulFragStar()
	elseif itemInfo.type == ITEM_CONFIG_TYPE.GODARM_PIECE then
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.SCRAP)
		self:showGodArmTanlent()
	else
		self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.RECT)
	end
	self:_setItemIconAndCount(itemInfo.icon, goodsNum, froceShow)
end

function QUIWidgetItemsBox:replaceColorFrame( spriteFrame, itemInfo )
	-- body
	if spriteFrame and itemInfo then
		if itemInfo.type == ITEM_CONFIG_TYPE.SOUL then
			self._ccbOwner.node_scrap_normal:setDisplayFrame(spriteFrame)
		elseif itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
			self._ccbOwner.node_scrap_normal:setDisplayFrame(spriteFrame)
		elseif itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE then
			self._ccbOwner.node_rect_normal:setDisplayFrame(spriteFrame)
			
		elseif itemInfo.type == ITEM_CONFIG_TYPE.ZUOQI then
			self._ccbOwner.node_scrap_normal:setDisplayFrame(spriteFrame)
		else
			self._ccbOwner.node_rect_normal:setDisplayFrame(spriteFrame)
		end
	end
end

--当作Gemstone来显示 
--tip: 只显示为绿色 如果需要其他自己调用setColor
function QUIWidgetItemsBox:_showAsGemstone(itemID, goodsNum, froceShow)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	self._name = itemInfo.name
	self:setColor(EQUIPMENT_QUALITY[2], QUIWidgetItemsBox.CRICLE)
	local sabcInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(itemInfo.gemstone_quality)
	if sabcInfo ~= nil then
		self:showSabc(sabcInfo.lower)
	end
	self:_setItemIconAndCount(itemInfo.icon, 0, froceShow)
end

--当作Resouce来显示
function QUIWidgetItemsBox:_showAsResouce(goodsNum, froceShow)
	local icon,name = remote.items:getURLForItem(self._itemType)
	local wallet = remote.items:getWalletByType(self._itemType)
	if name ~= nil then
		self._name = name
	end
	if icon ~= nil then
		self:_setItemIconAndCount(icon, goodsNum, froceShow)
		if wallet then
			self:setColor(EQUIPMENT_QUALITY[wallet.colour], QUIWidgetItemsBox.RECT)
		end
	end
end

--当做晶石显示
function QUIWidgetItemsBox:_showAsSpar(itemID, goodsNum, froceShow)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	self._name = itemInfo.name
	self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.CRICLE)
	self:_setItemIconAndCount(itemInfo.icon, goodsNum, froceShow)
	local starNum = 1
	if itemInfo.gemstone_quality == APTITUDE.SS then
		starNum = 0
	end
	self:_setStar(starNum)
end

--当做仙品显示
function QUIWidgetItemsBox:_showAsMagicHerb(itemID, goodsNum, froceShow)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	local config = remote.magicHerb:getMagicHerbConfigByid(itemInfo.id)
	local aptitude = config.aptitude
	local spriteFrame
	local sprite
	if aptitude >= 20 then
		-- s, s+, ss
		spriteFrame = QSpriteFrameByKey("magicHerbFrame", "orange")
	elseif aptitude >= 15 then
		-- a, a+
		spriteFrame = QSpriteFrameByKey("magicHerbFrame", "purple")
	else
		spriteFrame = QSpriteFrameByKey("magicHerbFrame", "normal")
	end

    if spriteFrame then
    	sprite = CCSprite:createWithSpriteFrame(spriteFrame)
    end
    if sprite then
    	self._ccbOwner.node_magicHerb:removeAllChildren()
    	self._ccbOwner.node_magicHerb:addChild(sprite)
    end

	local sabcInfo = db:getSABCByQuality(aptitude)
	if sabcInfo ~= nil then
		self:showSabc(sabcInfo.lower)
	end
	
	self._name = itemInfo.name
	self:setColor(EQUIPMENT_QUALITY[itemInfo.colour], QUIWidgetItemsBox.MAGICHERB)
	self:_setItemIconAndCount(itemInfo.icon, 0, froceShow)
end

--设置item基本信息
function QUIWidgetItemsBox:_setItemIconAndCount(respath, goodsNum, froceShow)
	if goodsNum == nil then goodsNum = 0 end
  	if respath ~= nil then
  		self:setItemIcon(respath)
  	end
  	if froceShow == nil then froceShow = false end
  	if froceShow == true or goodsNum > 0 then
  		self:setItemCount(goodsNum)
	else
		self:setTFText(self._ccbOwner.tf_goods_num,"")
  	end
end


function QUIWidgetItemsBox:setItemCount(str)
	-- body
	self:setNodeVisible(self._ccbOwner.node_goods,true)
	self:setNodeVisible(self._ccbOwner.node_goods_new,false)

	self:setTFText(self._ccbOwner.tf_goods_num,str)
	local numSize = self._ccbOwner.tf_goods_num:getContentSize()
	local boxSize = self._ccbOwner.node_scrap_normal:getContentSize()
	local scale = (boxSize.width - 20)/numSize.width
	if scale < 1 then
		self._ccbOwner.tf_goods_num:setScale(scale)
	else
		self._ccbOwner.tf_goods_num:setScale(1)
	end
end

function QUIWidgetItemsBox:setNewItemCount(num,count)
	-- COLORS N
	self:setNodeVisible(self._ccbOwner.node_goods,false)
	self:setNodeVisible(self._ccbOwner.node_goods_new,true)
	local color = num>=count and COLORS.b or COLORS.N
	self:setTFText(self._ccbOwner.tf_goods_neednum,"/"..(count or 0))
	self:setTFText(self._ccbOwner.tf_goods_havenum,num)
	self._ccbOwner.tf_goods_havenum:setColor(color)
	local numSize1 = self._ccbOwner.tf_goods_neednum:getContentSize()
	local numSize2 = self._ccbOwner.tf_goods_havenum:getContentSize()
	self._ccbOwner.tf_goods_havenum:setPositionX(self._ccbOwner.tf_goods_neednum:getPositionX() - numSize1.width)

	local boxSize = self._ccbOwner.node_scrap_normal:getContentSize()
	local scale = (boxSize.width - 20)/(numSize1.width + numSize2.width)
	if scale < 1 then
		self._ccbOwner.tf_goods_neednum:setScale(scale)
		self._ccbOwner.tf_goods_havenum:setScale(scale)
	else
		self._ccbOwner.tf_goods_neednum:setScale(1)
		self._ccbOwner.tf_goods_havenum:setScale(1)
	end	
end

function QUIWidgetItemsBox:hideNumber()
	self._ccbOwner.tf_goods_num:setVisible(false)
end

function QUIWidgetItemsBox:showNumber()
	self._ccbOwner.tf_goods_num:setVisible(true)
end

--设置icon
function QUIWidgetItemsBox:setItemIcon(respath)
	if respath~=nil and #respath > 0 then
		if self.icon == nil then
			self.icon = CCSprite:create()
			self._ccbOwner.node_icon:addChild(self.icon)
		end

		self.icon:setVisible(true)
		self.icon:setScale(1)
		self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		
		if self._colorType == QUIWidgetItemsBox.SCRAP then
			setNodeShaderProgram(self.icon, qShader.Q_ProgramPositionTextureColorHead)
			self.icon:setOpacity(0.8 * 255)
		elseif self._colorType == QUIWidgetItemsBox.CRICLE then
			setNodeShaderProgram(self.icon, qShader.Q_ProgramPositionTextureColorCircle)
			self.icon:setOpacity(1 * 255)
		elseif self._colorType == QUIWidgetItemsBox.MAGICHERB then
			setNodeShaderProgram(self.icon, qShader.Q_ProgramPositionTextureColorCircle)
			self.icon:setOpacity(1 * 255)
		else
			setNodeShaderProgram(self.icon, qShader.CC_ProgramPositionTextureColor)
			self.icon:setOpacity(1 * 255)
		end
		
		local size = self.icon:getContentSize()
		local size2 = self._ccbOwner.node_mask:getContentSize()
		local scaleX = self._ccbOwner.node_mask:getScaleX()
		local scaleY = self._ccbOwner.node_mask:getScaleY()
		if self._colorType == QUIWidgetItemsBox.MAGICHERB then
			scaleX = scaleX*1.1
			scaleY = scaleY*1.1
		end
		if size.width ~= size2.width then
			self.icon:setScaleX(size2.width * scaleX/size.width)
		end
		if size.height ~= size2.height then
			self.icon:setScaleY(size2.height * scaleY/size.height)
		end
	end
end

function QUIWidgetItemsBox:getItemName()
	return self._name
end

function QUIWidgetItemsBox:showItemName()
	if self._name == nil then return end
	local name = self._name
	self._ccbOwner.tf_goods_name:setScale(1)
	local nameCount = #name
	local i = 1
	if i > nameCount then return end
	local pos = 0
	local halfPos = 0
	local sixPos = 0
	local specialPos = 0
	local specialStr = "("
	local specialStr1 = "·"
    while true do 
        local c = string.sub(name,i,i)
        local b = string.byte(c)
        if b > 128 then
        	if specialStr == string.sub(name,i,i+3) then
        		specialPos = i-1
        	elseif specialStr1 == string.sub(name,i,i+1) then
        		specialPos = i-1
        	end
            i = i + 3
        	pos = pos + 1
        else
        	if specialStr == c then
        		specialPos = i-1
        	end
            i = i + 1
        	pos = pos + 0.5
        end
        if pos >= 5 and sixPos == 0 then
        	sixPos = i-1
        end
        if i >= nameCount/2 and halfPos == 0 then
        	halfPos = i-1
        end
        if i > nameCount then
        	break
        end
    end

    local autoWarpPos = nil
    if pos > 5 then
    	if pos > 10 then
			autoWarpPos = halfPos
		else
			autoWarpPos = sixPos
		end
	end
    if specialPos ~= 0 and autoWarpPos ~= nil and specialPos < autoWarpPos then
    	autoWarpPos = specialPos
	end
	self._ccbOwner.tf_goods_name:setHorizontalAlignment(kCCTextAlignmentLeft)
	if autoWarpPos ~= nil then
		name = string.sub(name, 1, autoWarpPos).."\n"..string.sub(name, autoWarpPos+1)
		if autoWarpPos < nameCount/2 then
			self._ccbOwner.tf_goods_name:setHorizontalAlignment(kCCTextAlignmentCenter)
		end
	end
	self:setTFText(self._ccbOwner.tf_goods_name, name)
	local widthNum = self._ccbOwner.tf_goods_name:getContentSize().width
	if widthNum > self._nameWidth then
		self._ccbOwner.tf_goods_name:setScale(self._nameWidth/widthNum)
	end
	local fontColor = EQUIPMENT_COLOR[self._colorIndex]
	self._ccbOwner.tf_goods_name:setColor(fontColor)
	if self._isNeedshadow then
		self._ccbOwner.tf_goods_name = setShadowByFontColor(self._ccbOwner.tf_goods_name, fontColor)
	else
		TFSetDisableOutline(self._ccbOwner.tf_goods_name, true)
	end
end

function QUIWidgetItemsBox:showShowGoodsName()
	self._ccbOwner.tf_goods_name:setVisible(true)
end

function QUIWidgetItemsBox:setShowGoodsNameColor(fontColor)
	self._ccbOwner.tf_goods_name:setColor(fontColor)
end

function QUIWidgetItemsBox:setGoodsNamePosY(posY)
	self._ccbOwner.tf_goods_name:setPositionY(posY)

end

function QUIWidgetItemsBox:setGoodsNameScale(scale)
	self._ccbOwner.tf_goods_name:setScale(scale)
end


function QUIWidgetItemsBox:_showSoulFragStar()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemID)
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	self:setTalentIcon(characher)
	local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
	self:showSabc(aptitudeInfo.lower)
end

function QUIWidgetItemsBox:setTalentIcon(characher)
	if characher == nil or characher.func == nil then return end

    if self._talentIcon == nil then 
	    self._talentIcon = QUIWidgetHeroProfessionalIcon.new()
	    self._ccbOwner.talentIconParent:addChild(self._talentIcon)
	end
    self._talentIcon:setHero(characher.id)
end

function QUIWidgetItemsBox:showGodArmTanlent()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemID)
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local jobIconPath = remote.godarm:getGodarmJobPath(characher.label)

    if jobIconPath then
    	local godArmSprite = CCSprite:create(jobIconPath)
    	self._ccbOwner.talentIconParent:addChild(godArmSprite)
    end
end

function QUIWidgetItemsBox:showSabc( quality )
	self._ccbOwner.node_pingzhi:removeAllChildren()
	local icon = CCSprite:create(QResPath("itemBoxPingZhi_"..quality))
	if icon then
		if quality == "a+" or quality == "ss" or quality == "ss+" then
			icon:setPositionX(10)
		end
		self._ccbOwner.node_pingzhi:addChild(icon)
	end
end

function QUIWidgetItemsBox:hideSabc()
	self._ccbOwner.node_pingzhi:removeAllChildren()
end
function QUIWidgetItemsBox:setSoulFragStar(state)
	-- self._ccbOwner.node_star:setVisible(state or false)
end

function QUIWidgetItemsBox:hideTalentIcon()
	self._talentIcon = nil
	self._ccbOwner.talentIconParent:removeAllChildren()
end

function QUIWidgetItemsBox:_showSoulStar()
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._itemID)
	self:setTalentIcon(characher)
end

-- xurui
-- 物品数量发生变化时，滚动显示
function QUIWidgetItemsBox:_scrollItemNum(oldNum, newNum)
	if self._itemNumScroll and oldNum and newNum then
		self._itemNumScroll:addUpdate(oldNum, newNum, handler(self, self._onItemNumUpdate), 17/30)
	end
end

function QUIWidgetItemsBox:scrollItemAddNum(addNum)
	local oldNum = tonumber(self._ccbOwner.tf_goods_num:getString()) or 0
	if self._itemNumScroll and addNum then
		self._ccbOwner.tf_goods_num:setVisible(true)
		self._itemNumScroll:addUpdate(oldNum, oldNum+addNum, handler(self, self._onItemNumUpdate), 17/30)
	end
end

function QUIWidgetItemsBox:_onItemNumUpdate(value)
	self:setTFText(self._ccbOwner.tf_goods_num,math.ceil(value))
end

function QUIWidgetItemsBox:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIWidgetItemsBox:setTFText(node, str)
	if node ~= nil then
		node:setString(str)
		node:setVisible(str ~= "")
	end
end

function QUIWidgetItemsBox:showMinusButton(visible)
	self._ccbOwner.minus:setVisible(visible)
end

--暗器令雕刻用
function QUIWidgetItemsBox:showMustMinusButton( visible )
	self._ccbOwner.node_scrap:setVisible(visible)
	self._ccbOwner.node_scrap_normal:setVisible(false)
	self._ccbOwner.minus:setVisible(visible)
	self._ccbOwner.btn_minus:setVisible(visible)
	self._ccbOwner.btn_minus:setEnabled(visible)
end

function QUIWidgetItemsBox:showEnchantIcon(visible, level)
	-- self._ccbOwner.enchantNode:setVisible(visible)
	-- self._ccbOwner.enchantLevel:setString(level)
end

--������ʾ��ɫС��ͷ
function QUIWidgetItemsBox:showGreenTips(b)
	if self._animationGreenTips == nil then
		self._animationGreenTips = QUIWidget.new("ccb/effects/shoujizhong.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationGreenTips)
	end
	self._animationGreenTips:setVisible(b)
end

function QUIWidgetItemsBox:setIndex(position)
	self._itemPosition = position
end

function QUIWidgetItemsBox:getIndex()
	return self._itemPosition
end

function QUIWidgetItemsBox:selected(b)
	self._selectNode:setVisible(b)
	-- local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemID)
	-- if itemInfo and (itemInfo.type == ITEM_CONFIG_TYPE.SOUL or itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE or itemInfo.type == ITEM_CONFIG_TYPE.ZUOQI) then
	-- 	self._ccbOwner.node_select_piece:setVisible(b)
	-- else
	-- 	self._ccbOwner.node_select:setVisible(b)
	-- end
end

function QUIWidgetItemsBox:setSelectPosition(pos)
	self._selectPosition = pos
end

function QUIWidgetItemsBox:showRedTips(state)
	self._ccbOwner.red_tip:setVisible(state)
end 

function QUIWidgetItemsBox:_onTouch(event)
	if event.name == "began" then 
		self._startPosX = event.x
		self._startPosY = event.y
		self._isPatch = true
		-- self:dispatchEvent({name = QUIWidgetItemsBox.EVENT_BEGAIN})
		-- if self.promptTipIsOpen ~= false then
			-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBox.EVENT_BEGAIN , eventTarget = self, itemID=self._itemID, itemType = self._itemType})
		-- end	
		return true
	elseif event.name == "moved" then	
		if self._isPatch == true then
			if self._startPosX ~= nil and math.abs(event.x - self._startPosX) > 10 then
				self._isPatch = false
			elseif self._startPosY ~= nil and math.abs(event.y - self._startPosY) > 10 then
				self._isPatch = false
			end
		end
	elseif event.name == "ended" or event.name == "cancelled" then 
		self:dispatchEvent({name = QUIWidgetItemsBox.EVENT_END})
		if self.promptTipIsOpen ~= false and not(self._itemID == nil and self._itemType == nil) then
			-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBox.EVENT_END , eventTarget = self})
			if self._isPatch then
    			app.sound:playSound("common_small")
				app.tip:itemTip(self._itemType, self._itemID)
			end
		end
		self:_onTriggerClick()
		self._startPosX = nil
		self._startPosY = nil
		self._isPatch = nil
	end
end

function QUIWidgetItemsBox:setMagicHerbSid( sid )
	self._magicHerbSid = sid
end

function QUIWidgetItemsBox:_onTriggerClick()
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBox.EVENT_CLICK , itemID = self._itemID, index = self._itemPosition})
	self:dispatchEvent({name = QUIWidgetItemsBox.EVENT_CLICK, itemID = self._itemID, index = self._itemPosition, sid = self._magicHerbSid})
end

function QUIWidgetItemsBox:_onTriggerMinus(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then 
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBox.EVENT_MINUS_CLICK , itemID = self._itemID})
	end
end

function QUIWidgetItemsBox:_onTriggerNewMinus( )
	self:dispatchEvent({name = QUIWidgetItemsBox.EVENT_MINUS_CLICK, itemID = self._itemID})
end

function QUIWidgetItemsBox:setRateActivityState(state, num)
	if state == nil then return end
	self._ccbOwner.node_up:setVisible(state)
	if num and tonumber(num) and num ~= 2 then
		self._ccbOwner.tf_up_num:setString(num.."倍")
	else
		self._ccbOwner.tf_up_num:setString("双倍")
	end
end

function QUIWidgetItemsBox:setItemTag(str)
	if str == nil then return end

	self._ccbOwner.node_up:setVisible(true)
	self._ccbOwner.tf_up_num:setString(str)
end

function QUIWidgetItemsBox:addSpriteFrame(sp, frameName)
	if string.find(frameName, "%.plist") ~= nil then
		sp:setDisplayFrame(QSpriteFrameByPath(frameName))
	else
		local texture = CCTextureCache:sharedTextureCache():addImage(frameName)
		if texture then
			sp:setTexture(texture)
			local size = texture:getContentSize()
			local rect = CCRectMake(0, 0, size.width, size.height)
			sp:setTextureRect(rect)
		end
	end
end

function QUIWidgetItemsBox:setBackPackLine(state)
	if state == false and self._line ~= nil then
		self._line:removeFromParent()
		self._line = nil
	elseif state and self._line == nil then
	    self._line = CCBuilderReaderLoad("ccb/Widget_Baoshi_Packsack_xian.ccbi", CCBProxy:create(), {})
	    local contentSize = self:getContentSize()
	    self._line:setPosition(ccp(contentSize.width*2 - 10, -contentSize.height+10))
		self:getView():addChild(self._line)
	end
end

function QUIWidgetItemsBox:_setStar(starNum)
	if self._star == nil then
    	self._star = QUIWidgetHeroHeadStar.new({})
    	self:getView():addChild(self._star:getView())
    end
    self._star:setPositionY(-self:getContentSize().height/2)
    self._star:setScale(0.8)
    if starNum == 0 then
    	self._star:setEmptyStar()
    else
    	self._star:setStar(starNum, false)
    end
	self:getView():setVisible(starNum>=0)
end

-- 过期提醒
function QUIWidgetItemsBox:setOverdue(overdue)
	local isOverdue = overdue or false
	self._ccbOwner.node_expired:setVisible(isOverdue)
end

-- 过期提醒
function QUIWidgetItemsBox:setFirstAward(isFirst)
	local isOverdue = isFirst or false
	self._ccbOwner.node_first:setVisible(isFirst)
end

-- 设置标签
function QUIWidgetItemsBox:setAwardName(name,skinStatus)
	self._ccbOwner.node_award:setVisible(true)
	self._ccbOwner.tf_award_name:setString(name)
	if skinStatus then
		if skinStatus == remote.heroSkin.ITEM_SKIN_ACTIVATED then
			self._ccbOwner.node_award:setVisible(true)
			self._ccbOwner.node_award_has:setVisible(false)
		elseif skinStatus == remote.heroSkin.ITEM_SKIN_HAS then
			self._ccbOwner.node_award:setVisible(false)
			self._ccbOwner.node_award_has:setVisible(true)
			self._ccbOwner.tf_award_name_has:setString(name)
		end
	end
end
function QUIWidgetItemsBox:isShowPlus( boo )
	self._ccbOwner.sp_plus:setVisible(boo)
end

function QUIWidgetItemsBox:showLock( boo )
	self._ccbOwner.sp_unlock:setVisible(boo)
end

function QUIWidgetItemsBox:showSpecial( boo )
	self._ccbOwner.sp_special:setVisible(boo)
end

function QUIWidgetItemsBox:showIsGetAwards(boo)
	self._ccbOwner.sp_yilingqu:setVisible(boo)
end

function QUIWidgetItemsBox:getClassName()
	return "QUIWidgetItemsBox"
end

return QUIWidgetItemsBox