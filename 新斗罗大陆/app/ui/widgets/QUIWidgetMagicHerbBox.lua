--
-- Author: Kumo.Wang
-- 仙品itembox
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbBox = class("QUIWidgetMagicHerbBox", QUIWidget)

local QUIWidgetMagicHerbStar = import("..widgets.QUIWidgetMagicHerbStar")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRemote = import("...models.QRemote")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")

QUIWidgetMagicHerbBox.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetMagicHerbBox:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_box.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)}
	}

	QUIWidgetMagicHerbBox.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.isAnimation = false --是否动画显示
	if options then
		self._heroId = options.heroId
		self._pos = options.pos
	end
	self._inPack = false

	self:_init()
end

function QUIWidgetMagicHerbBox:onEnter()
end

function QUIWidgetMagicHerbBox:onExit()
end

function QUIWidgetMagicHerbBox:getContentSize()
	return self._ccbOwner.node_mask:getContentSize()
end

function QUIWidgetMagicHerbBox:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg_1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_selected, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_level, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_level_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_level, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_count, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_count_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_count, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_frame, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_frame, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_wear, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_wear1, self._glLayerIndex)--
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_wear2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_lock, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_lock, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_state, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_state, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_noWear, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_star, self._glLayerIndex)
	if self._starWidget then
		self._glLayerIndex = self._starWidget:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_subtract, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_quality, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetMagicHerbBox:setInPack(inPack)
	self._inPack = inPack
end

function QUIWidgetMagicHerbBox:setHeroId( heroId )
	if heroId ~= self._heroId then
		self._heroId = heroId
		self:_init()
	end
end

function QUIWidgetMagicHerbBox:resetAll()
	self:_reset()
end

function QUIWidgetMagicHerbBox:setInfo( sid )
	self:_init()
	self._magicHerbSid = sid
	local maigcHerb = remote.magicHerb:getMaigcHerbItemBySid( sid )
	self:setMagicHerbInfo(maigcHerb)
end

function QUIWidgetMagicHerbBox:setMagicHerbInfo(maigcHerb)
	if maigcHerb and next(maigcHerb) then
		--等级
		local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(maigcHerb.itemId)
		local maigcHerbItemConfig = db:getItemByID(maigcHerb.itemId)
		self._ccbOwner.tf_level:setString(maigcHerb.level)
		local  breedLevel = maigcHerb.breedLevel or 0
		local aptitude = remote.magicHerb:getAptitudeByIdAndBreedLv(maigcHerb.itemId,maigcHerb.breedLevel)

		-- self._ccbOwner.sp_level_bg:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
		self._ccbOwner.node_level:setVisible(true)
		self._itemId = magicHerbConfig.id
		--框
		self:setItemFrame(aptitude,nil,maigcHerbItemConfig)
	    --名字
	    local nameStr = magicHerbConfig.name
	
	    local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour]]
	    if breedLevel == remote.magicHerb.BREED_LV_MAX then
	    	fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour + 1]]
		elseif breedLevel > 0 then
			nameStr = nameStr.."+"..breedLevel
	    end

    	self._ccbOwner.tf_name:setString(nameStr)
	    self._ccbOwner.tf_name:setVisible(true)

        self._ccbOwner.tf_name:setColor(fontColor)
        self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	    --品质
	    self:_showSabc(aptitude)
	    --图标
	    self:_setItemIconByItemConfig(maigcHerbItemConfig)
	    self._ccbOwner.node_wear:setVisible(false)
	    --星级
	    if not self._starWidget then
	    	self._starWidget = QUIWidgetMagicHerbStar.new()
	    	self._ccbOwner.node_star:addChild(self._starWidget)
	    end
	    self._starWidget:setStar(maigcHerb.grade)
	    self._ccbOwner.node_star:setVisible(true)
	    -- 标记装备状态
		self._ccbOwner.node_state:setVisible(maigcHerb.actorId ~= 0 and self._inPack)
		-- 选择状态
		self._ccbOwner.sp_subtract:setVisible(self._isSelected)
	end
end

function QUIWidgetMagicHerbBox:setSketchByItemId( itemId )
	self:_init()
	self._itemId = itemId
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo then
		--图标
	    self:_setItemIconByItemConfig(itemInfo)
	    self._ccbOwner.node_wear:setVisible(false)

		local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(itemInfo.id)
		if magicHerbConfig and next(magicHerbConfig) then
			--框
			self:setItemFrame(magicHerbConfig.aptitude,nil,itemInfo)
		    --名字
		    self._ccbOwner.tf_name:setString(magicHerbConfig.name)
		    self._ccbOwner.tf_name:setVisible(true)
		    local fontColor = COLORS.A
	        self._ccbOwner.tf_name:setColor(fontColor)
	        self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
		    --品质
		    self:_showSabc(magicHerbConfig.aptitude)
		else
			--框
			self:setItemFrame(nil, itemInfo.colour , nil)
		end
	end
end

function QUIWidgetMagicHerbBox:setItemByItemId( itemId, itemCount, selectedCount )
	self:_init()
	self._itemId = itemId
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo then
		--數量
		if itemCount == nil then
	    	self._itemCount = remote.items:getItemsNumByID(itemId)
	    else
	    	self._itemCount = itemCount
		end
	    if self._itemCount > 0 then
	    	if selectedCount then
		    	self._ccbOwner.tf_count:setString(selectedCount.."/"..self._itemCount)
		    else
		    	self._ccbOwner.tf_count:setString(self._itemCount)
		    end
			self:setItemCountScale(self._itemCount)
		    -- self._ccbOwner.sp_count_bg:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
		    self._ccbOwner.sp_count_bg:setVisible(false)
		    self._ccbOwner.node_count:setVisible(true)
	   	end
		--图标
	    self:_setItemIconByItemConfig(itemInfo)
	    self._ccbOwner.node_wear:setVisible(false)
	    --框
		self:setItemFrame(nil, itemInfo.colour,itemInfo)
		--名字
	    self._ccbOwner.tf_name:setString(itemInfo.name)
	    self._ccbOwner.tf_name:setVisible(true)
	    local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemInfo.colour]]
        self._ccbOwner.tf_name:setColor(fontColor)
        self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	end
end

-- 用於查看其他玩家的仙品
function QUIWidgetMagicHerbBox:setMagicHerbInfoByInfo(magicHerbInfo, isUnlock)
	self:_reset()

	self._ccbOwner.node_bg:setVisible(true)
	self._ccbOwner.node_frame:setVisible(true)

	self._ccbOwner.node_btn:setVisible(false)

	if not isUnlock then
		local unlockTeamLevel = remote.magicHerb:getUnlockTeamLevel()
		self._ccbOwner.tf_lock:setString(unlockTeamLevel.."级\n开启")
		self._ccbOwner.node_lock:setVisible(true)
	else
		self._ccbOwner.tf_noWear:setVisible(true)
	end

	if magicHerbInfo and next(magicHerbInfo) then
		self._ccbOwner.tf_noWear:setVisible(false)
		--等级
		self._ccbOwner.tf_level:setString(magicHerbInfo.level)
		-- self._ccbOwner.sp_level_bg:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
		self._ccbOwner.node_level:setVisible(true)
		local  breedLevel = magicHerbInfo.breedLevel or 0
		local aptitude = remote.magicHerb:getAptitudeByIdAndBreedLv(magicHerbInfo.itemId,magicHerbInfo.breedLevel)
		local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbInfo.itemId)
		local nameStr = 0

		if magicHerbConfig and next(magicHerbConfig) then
	    	nameStr = magicHerbConfig.name
		end

	    local itemConfig = db:getItemByID(magicHerbInfo.itemId)
	    local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[1]]
	    if itemConfig then
	    	--图标
		    self:_setItemIconByItemConfig(itemConfig)
		    self._ccbOwner.node_wear:setVisible(false)
		    fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]
	   	end


		self:setItemFrame(aptitude ,nil ,itemConfig)
		self:_showSabc(aptitude)
	    
	    if breedLevel == remote.magicHerb.BREED_LV_MAX then
	    	fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour + 1]]
		elseif breedLevel > 0 then
			nameStr = nameStr.."+"..breedLevel
	    end
		self._ccbOwner.tf_name:setString(nameStr)
		self._ccbOwner.tf_name:setVisible(true)
		self._ccbOwner.tf_name:setColor(fontColor)
		self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)


	    --星级
	    if not self._starWidget then
	    	self._starWidget = QUIWidgetMagicHerbStar.new()
	    	self._ccbOwner.node_star:addChild(self._starWidget)
	    end
	    self._starWidget:setStar(magicHerbInfo.grade)
	    self._ccbOwner.node_star:setVisible(true)
	end
end

function QUIWidgetMagicHerbBox:setItemFrame(aptitude, itemColor,itemConfig)
	if aptitude == nil and itemColor == nil then 
    	self._ccbOwner.node_frame:setVisible(false)
		return 
	end
	local spriteFrame

  	local isCircle = false
	if itemConfig == nil or  ITEM_CONFIG_TYPE.MAGICHERB_WILD == itemConfig.type or ITEM_CONFIG_TYPE.MAGICHERB == itemConfig.type then
		isCircle = true
	end
	if isCircle then
		if (aptitude and aptitude >= APTITUDE.SS) or (itemColor and itemColor == 6) then
			spriteFrame = QSpriteFrameByKey("magicHerbFrame", "red")
		elseif (aptitude and aptitude >= APTITUDE.S) or (itemColor and itemColor == 5) then
			-- s, s+, ss
			spriteFrame = QSpriteFrameByKey("magicHerbFrame", "orange")
		elseif (aptitude and aptitude >= APTITUDE.A) or (itemColor and itemColor == 4) then
			-- a, a+
			spriteFrame = QSpriteFrameByKey("magicHerbFrame", "purple")
		else
			spriteFrame = QSpriteFrameByKey("magicHerbFrame", "normal")
		end
		self._ccbOwner.node_frame:setScale(0.7)
		self._ccbOwner.node_frame:setPositionY(4)
	else
		spriteFrame = QResPath("color_frame_default")[1]
		if itemColor then
			spriteFrame = QSpriteFrameByPath(QResPath("color_frame_"..EQUIPMENT_QUALITY[itemColor])[1])
		elseif itemConfig.colour then
			spriteFrame = QSpriteFrameByPath(QResPath("color_frame_"..EQUIPMENT_QUALITY[tonumber(itemConfig.colour)])[1])
		end
		self._ccbOwner.node_frame:setScale(1.05)
		self._ccbOwner.node_frame:setPositionY(0)
	end

    if spriteFrame then
    	self._ccbOwner.sp_frame:setDisplayFrame(spriteFrame)
    end
    self._ccbOwner.node_frame:setVisible(true)
end

function QUIWidgetMagicHerbBox:hideName()
	self._ccbOwner.tf_name:setVisible(false)
end

function QUIWidgetMagicHerbBox:setNameFormat(str1, str2)
	local name = self._ccbOwner.tf_name:getString()
	name = string.gsub(name, str1, str2)
	self._ccbOwner.tf_name:setString(name)
end

function QUIWidgetMagicHerbBox:hideSabc()
	self._ccbOwner.node_quality:setVisible(false)
end

function QUIWidgetMagicHerbBox:hideLevel()
	self._ccbOwner.node_level:setVisible(false)
end

function QUIWidgetMagicHerbBox:hideStar()
	self._ccbOwner.node_star:setVisible(false)
end

function QUIWidgetMagicHerbBox:hideCount()
	self._ccbOwner.node_count:setVisible(false)
end

function QUIWidgetMagicHerbBox:setStarNum( num )
	--星级
    if not self._starWidget then
    	self._starWidget = QUIWidgetMagicHerbStar.new()
    	self._ccbOwner.node_star:addChild(self._starWidget)
    end
    self._starWidget:setStar(num)
	self._ccbOwner.node_star:setVisible(true)
end

-- 選擇作為升星飼料（或分解對象），全選或全部取消
function QUIWidgetMagicHerbBox:onSelectChangeForFood()
	self._isSelected = not self._isSelected
	self._ccbOwner.sp_subtract:setVisible(self._isSelected)
	return self._isSelected
end

function QUIWidgetMagicHerbBox:onAddFood( addNum )
	local totalNum
	if self._itemCount then
		totalNum = self._itemCount
	else
		totalNum = 1
	end
	if not addNum then addNum = totalNum end
	self._selectedCountForFood = self._selectedCountForFood + addNum
	if self._selectedCountForFood > totalNum then
		self._selectedCountForFood = totalNum
	end
	self._isSelected = self._selectedCountForFood > 0
	self._ccbOwner.sp_subtract:setVisible(self._isSelected)
	return self._isSelected
end

function QUIWidgetMagicHerbBox:onSubFood( subNum )
	if not subNum then subNum = 1 end
	self._selectedCountForFood = self._selectedCountForFood - subNum
	if self._selectedCountForFood < 0 then self._selectedCountForFood = 0 end
	self._isSelected = self._selectedCountForFood > 0
	self._ccbOwner.sp_subtract:setVisible(self._isSelected)
	return self._isSelected
end

function QUIWidgetMagicHerbBox:getIsSelectedForFood()
	return self._isSelected
end

function QUIWidgetMagicHerbBox:setSelectedFoodNum( num )
	self._selectedCountForFood = num
end

function QUIWidgetMagicHerbBox:getSelectedFoodNum()
	return self._selectedCountForFood
end

function QUIWidgetMagicHerbBox:setSelectedForFood( boo )
	self._isSelected = boo
	self._ccbOwner.sp_subtract:setVisible(self._isSelected)
end

-- 仅用于破碎仙草
function QUIWidgetMagicHerbBox:setItemSelectedCount(selectedCount)
	if not self._itemId or not self._itemCount or not selectedCount then return end

	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	if itemInfo.type == ITEM_CONFIG_TYPE.MAGICHERB then return end

	self._ccbOwner.tf_count:setString(selectedCount.."/"..self._itemCount)

	self:setItemCountScale(self._itemCount)
end

function QUIWidgetMagicHerbBox:setItemCountScale(selectedCount)
	self._ccbOwner.tf_count:setScale(1)
	local width = self._ccbOwner.tf_count:getContentSize().width
	if width > 70 then
		self._ccbOwner.tf_count:setScale(70/width)
	end
end

function QUIWidgetMagicHerbBox:selected(b)
	self._ccbOwner.node_selected:setVisible(b)
end

function QUIWidgetMagicHerbBox:setIndex(index)
	self._index = index
end

function QUIWidgetMagicHerbBox:getIndex()
	return self._index
end

function QUIWidgetMagicHerbBox:setBoxScale(scale)
	if scale == nil then return end
	self._ccbOwner.node_box:setScale(scale)
end

function QUIWidgetMagicHerbBox:setPromptIsOpen(boo)
	self._promptTipIsOpen = boo
end

function QUIWidgetMagicHerbBox:_showSabc(aptitude)
	if not aptitude then return end

	local aptitudeInfo = db:getSABCByQuality(aptitude)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
	self._ccbOwner.node_quality:setVisible(true)
end

function QUIWidgetMagicHerbBox:_setItemIconByItemConfig(config)
  	local isCircle = false
	if ITEM_CONFIG_TYPE.MAGICHERB_WILD == config.type or ITEM_CONFIG_TYPE.MAGICHERB == config.type then
		isCircle = true
	end
	self:_setItemIcon(config.icon ,isCircle)
end


function QUIWidgetMagicHerbBox:_setItemIcon(respath ,isCircle)
	if respath ~= nil and #respath > 0 then
		if self._icon == nil then
			self._icon = CCSprite:create()
			self._ccbOwner.node_icon:removeAllChildren()
			self._ccbOwner.node_icon:addChild(self._icon)
		end

		self._icon:setVisible(true)
		self._icon:setScale(1)
		self._icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		if isCircle then
			self._icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
		else
			self._icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorRectangle)
		end
		self._icon:setOpacity(1 * 255)
		

		if isCircle then
			local size = self._icon:getContentSize()
			local size2 = self._ccbOwner.node_mask:getContentSize()
			local scaleX = self._ccbOwner.node_mask:getScaleX()
			local scaleY = self._ccbOwner.node_mask:getScaleY()

			if size.width ~= size2.width then
				self._icon:setScaleX(size2.width * scaleX/size.width)
			end
			if size.height ~= size2.height then
				self._icon:setScaleY(size2.height * scaleY/size.height)
			end
		end

	end
end

function QUIWidgetMagicHerbBox:_reset()
	self._icon = CCSprite:create()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(self._icon)

	self._ccbOwner.node_mask:setVisible(false)
	self._ccbOwner.node_bg:setVisible(false)
	self._ccbOwner.node_selected:setVisible(false)
	self._ccbOwner.node_level:setVisible(false)
	self._ccbOwner.node_count:setVisible(false)
	self._ccbOwner.node_frame:setVisible(false)
	self._ccbOwner.node_wear:setVisible(false)
	self._ccbOwner.node_lock:setVisible(false)
	self._ccbOwner.node_state:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.sp_subtract:setVisible(false)
	self._ccbOwner.node_quality:setVisible(false)
	self._ccbOwner.node_btn:setVisible(false)
	self._ccbOwner.sp_tips:setVisible(false)
	self._ccbOwner.tf_noWear:setVisible(false)

	local spriteFrame = QSpriteFrameByKey("magicHerbFrame", "normal")
    if spriteFrame then
    	self._ccbOwner.sp_frame:setDisplayFrame(spriteFrame)
    end
end

function QUIWidgetMagicHerbBox:_init()
	self:_reset()

	self._isSelected = false

	self._ccbOwner.node_bg:setVisible(true)
	self._ccbOwner.node_frame:setVisible(true)
	self._selectedCountForFood = 0
	self._itemCount = nil
	
	if not remote.magicHerb:checkMagicHerbUnlock() then
		self._isUnLock = false
		local unlockTeamLevel = remote.magicHerb:getUnlockTeamLevel()
		self._ccbOwner.tf_lock:setString(unlockTeamLevel.."级\n开启")
		self._ccbOwner.node_lock:setVisible(true)
	else
		self._isUnLock = true
		if self._heroId then
			self._ccbOwner.node_btn:setVisible(true)
			self._ccbOwner.node_wear:setVisible(true)
			self._ccbOwner.node_star:setVisible(false)
		end
	end
end

function QUIWidgetMagicHerbBox:setRedTipStatus(isEnable)
	if isEnable == nil then isEnable = false end

	self._ccbOwner.sp_tips:setVisible(isEnable)	
end

function QUIWidgetMagicHerbBox:setTouchEnabled(isEnable)
	self._ccbOwner.node_btn:setVisible(isEnable)
end

function QUIWidgetMagicHerbBox:_onTriggerClick()
	print("QUIWidgetMagicHerbBox:_onTriggerClick() ", self._promptTipIsOpen, self._itemId)
	if self._promptTipIsOpen then
		app.tip:itemTip(ITEM_TYPE.ITEM, self._itemId)
	else
		self:dispatchEvent({name = QUIWidgetMagicHerbBox.EVENT_CLICK, pos = self._pos, actorId = self._heroId, sid = self._magicHerbSid, itemId = self._itemId, index = self._index})
	end
end

function QUIWidgetMagicHerbBox:getClassName()
	return "QUIWidgetMagicHerbBox"
end

return QUIWidgetMagicHerbBox