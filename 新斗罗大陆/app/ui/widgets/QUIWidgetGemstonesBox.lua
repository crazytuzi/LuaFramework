local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstonesBaseBox = import("..widgets.QUIWidgetGemstonesBaseBox")
local QUIWidgetGemstonesBox = class("QUIWidgetGemstonesBox", QUIWidgetGemstonesBaseBox)
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")
local QUIWidgetHeroHeadStar = import(".QUIWidgetHeroHeadStar")

QUIWidgetGemstonesBox.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetGemstonesBox:ctor(options)
	local ccbFile = "ccb/Widget_baoshi_head.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetGemstonesBox._onTriggerTouch)},
    }
	QUIWidgetGemstonesBox.super.ctor(self, ccbFile, callBacks, options)

	self._nameWidth = 120

    self._ccbOwner.sp_icon:setVisible(false)
    self._ccbOwner.node_tips:setVisible(false)
    self:setNameVisible(false)
    self:setName("")
    self:setState(remote.gemstone.GEMSTONE_NONE)
    self:setBreakTips(true)
    self:setStrengthTips(true)
    self:setTips(false)

end

function QUIWidgetGemstonesBox:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_normal, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_break, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_wear1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_wear2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_lock, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_quality, self._glLayerIndex)
	if self._qualityWidget then
		self._glLayerIndex = self._qualityWidget:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godlevel_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godlevel, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_godLevel, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_level_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_strengthen, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_refine_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_refine, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mask, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_state, self._glLayerIndex)--
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_subtract, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_tips, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_hero_star, self._glLayerIndex)

	return self._glLayerIndex
end

--设置位置
function QUIWidgetGemstonesBox:setPos(pos)
	self._pos = pos
	local config = app.unlock:getConfigByKey("UNLOCK_GEMSTONE_"..self._pos)
	if config == nil then return end
	self._ccbOwner.tf_lock:setString(config.hero_level.."级\n开启")
end

function QUIWidgetGemstonesBox:getIndex()
	return self._pos
end

--设置是否选中
function QUIWidgetGemstonesBox:selected(b)
	self._ccbOwner.node_select:setVisible(b)
end

--设置是否变暗
function QUIWidgetGemstonesBox:setGray(b)
	self._ccbOwner.node_gray:setVisible(b)
end

--xurui: set item info 
function QUIWidgetGemstonesBox:setInfo(param)
	if param then
		self:setGemstoneInfo(param.gemstoneInfo or {})
		self:setPos(param.index or {})
		if param.userState ~= nil then
			self:setStateDescVisible(param.userState)
		end
		if self._selectPosition ~= nil and self._selectPosition ~= 0 then
			self:selected(self._selectPosition == param.index)
		end
	end
end

--xurui:set select position
function QUIWidgetGemstonesBox:setSelectPosition(pos)
	self._selectPosition = pos
end

--设置宝石信息
function QUIWidgetGemstonesBox:setGemstoneInfo(gemstone)
	if gemstone == nil then return end
	self._gemstone = gemstone
	local godLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local mixLevel = gemstone.mix_level or 0
	local refineLevel = gemstone.refine_level or 0
	local itemConfig = db:getItemByID(gemstone.itemId)
	self:setName(itemConfig.name or "")
	local itemId , quality , iconPath = remote.gemstone:getGemstoneTransferInfoByData(gemstone)
	-- print("QUIWidgetGemstonesBox:setGemstoneInfo"..iconPath)
	self._itemId = itemId
	self._quality = quality
	self:setQuality(remote.gemstone:getSABC(quality).lower)
	self:setItemIcon(iconPath)
	self:setStrengthen(gemstone.level)
	self:setBreakLevel(gemstone.craftLevel)

	self:setGodLevel(godLevel)
	self:setMixLevel(mixLevel)
	self:setRefineLevel(refineLevel, mixLevel > 0 or refineLevel > 0)
end

function QUIWidgetGemstonesBox:getGemstoneInfo()
	return self._gemstone or {}
end

function QUIWidgetGemstonesBox:getQuality()
	return self._quality or APTITUDE.C

end

function QUIWidgetGemstonesBox:setItemIdByData(itemId , godLevel , mixLevel)
	local itemId , quality , iconPath = remote.gemstone:getGemstoneTransferInfoByData({itemId = itemId , godLevel = godLevel , mix_level = mixLevel})
	self._itemId = itemId
	self._quality = quality
	self:setQuality(remote.gemstone:getSABC(quality).lower)
	self:setItemIcon(iconPath)
end


--设置图标
function QUIWidgetGemstonesBox:setItemId(itemId)
	self._itemId = itemId
	local itemConfig = db:getItemByID(itemId)
	self:setItemIcon(itemConfig.icon)


	-- -- self._itemId = itemId
	-- if self._icon then
	-- 	self._icon:removeFromParent()
	-- 	self._icon = nil
	-- end	

	-- --设置图标
	-- local itemConfig = db:getItemByID(itemId)
	-- self._icon = display.newSprite(itemConfig.icon)
	-- self._ccbOwner.node_icon:addChild(self._icon)
	-- self._icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
end


function QUIWidgetGemstonesBox:setItemIcon(iconPath)
	if self._icon == nil  then
		self._icon = display.newSprite()
		self._ccbOwner.node_icon:addChild(self._icon)
	end	
	QSetDisplayFrameByPath(self._icon , iconPath)
	self._icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
end


function QUIWidgetGemstonesBox:cleanBox()
	self:setQuality()
	self:setGodLevel()
	self:setMixLevel()
	self:setRefineLevel(0, false)
end

--设置强化等级
function QUIWidgetGemstonesBox:setStrengthen(level)
	-- body
	if level == 0 then 
		level = "" 
		self._ccbOwner.node_strengthen:setVisible(false)
	else
		self._ccbOwner.node_strengthen:setVisible(true)
	end
	self._ccbOwner.tf_strengthen:setString(tostring(level))
end

--设置突破等级
function QUIWidgetGemstonesBox:setBreakLevel(breakLevel)
	local iconPath
	if breakLevel then
		iconPath = QResPath("circle_frame")[breakLevel+1]
	end
	if not iconPath then
		iconPath = QResPath("circle_frame_normal")
	end
	local texture = CCTextureCache:sharedTextureCache():addImage(iconPath)
	if texture then
		self._ccbOwner.sp_break:setTexture(texture)
	end
end

--设置品质等级
function QUIWidgetGemstonesBox:setQuality(quality,godlevel)
	if self._qualityWidget == nil then
		self._qualityWidget = QUIWidgetQualitySmall.new()
		self._ccbOwner.node_quality:addChild(self._qualityWidget)
	end
	-- print("魂骨品质等级---quality=",quality)
	if quality then
		self._qualityWidget:setQuality(quality)
		if godlevel and godlevel >= GEMSTONE_MAXADVANCED_LEVEL then
			self._qualityWidget:setQuality("ss")
		end
	else
		self._qualityWidget:cleanQuality()
	end
end

function QUIWidgetGemstonesBox:setGodLevel(godlevel)
	if godlevel and godlevel > 0 then
		-- godlevel = godlevel + 1
		self._ccbOwner.node_godlevel:setVisible(true)
		if godlevel > GEMSTONE_MAXADVANCED_LEVEL then	
			local grade = godlevel - GEMSTONE_MAXADVANCED_LEVEL
			local iconPath = QResPath("god_skill")[grade]
			QSetDisplaySpriteByPath(self._ccbOwner.sp_godlevel,iconPath)
			self._ccbOwner.sp_godlevel:setVisible(true)
			self._ccbOwner.tf_godLevel:setString("")				
		elseif godlevel < GEMSTONE_MAXADVANCED_LEVEL then
			local advanced = math.floor(godlevel/5)
			self._ccbOwner.tf_godLevel:setString(q.getRomanNumberalsByInt(advanced).."阶")
			local color = EQUIPMENT_QUALITY[advanced + 1 ]
			self._ccbOwner.tf_godLevel:setColor(BREAKTHROUGH_COLOR_LIGHT[color])	
			self._ccbOwner.sp_godlevel:setVisible(false)
		else
			self._ccbOwner.node_godlevel:setVisible(false)
		end
	else
		self._ccbOwner.node_godlevel:setVisible(false)
	end
end


function QUIWidgetGemstonesBox:setMixLevel(mixlevel, isShowEffect , callback)
	self._ccbOwner.node_hero_star:setVisible(mixlevel and mixlevel > 0)

	if mixlevel and mixlevel > 0 then
	   	if self._star == nil then
	    	self._star = QUIWidgetHeroHeadStar.new({})
	    	self._ccbOwner.node_hero_star:addChild(self._star:getView())
	    end
	    if callback then
	    	self._star:setStarEffect(mixlevel, isShowEffect , callback)
	    else
	    	self._star:setStar(mixlevel, isShowEffect)
	    end
	end
end

-- 设置精炼等级
function QUIWidgetGemstonesBox:setRefineLevel(refineLevel, showLevel)
	if not app.unlock:checkLock("UNLOCK_GEMSTONE_REFINE",false) then
		self._ccbOwner.node_refine:setVisible(false)
		return
	end

	self._ccbOwner.node_refine:setVisible(showLevel)
	local fontColor = self:_getRefineLevelColor(refineLevel)
	self._ccbOwner.tf_refine:setColor(fontColor)
	self._ccbOwner.tf_refine = setShadowByFontColor(self._ccbOwner.tf_refine, fontColor)
	self._ccbOwner.tf_refine:setString("精" .. refineLevel)
end

-- 获取精炼文本颜色
function QUIWidgetGemstonesBox:_getRefineLevelColor(refineLevel)
	local fontColor = QIDEA_QUALITY_COLOR.WHITE
	if not refineLevel or refineLevel == 0 then
		fontColor = QIDEA_QUALITY_COLOR.WHITE
	elseif refineLevel <= 2 then
		fontColor = QIDEA_QUALITY_COLOR.GREEN
	elseif refineLevel <= 4 then
		fontColor = QIDEA_QUALITY_COLOR.BLUE
	elseif refineLevel <= 6 then
		fontColor = QIDEA_QUALITY_COLOR.PURPLE
	elseif refineLevel <= 8 then
		fontColor = QIDEA_QUALITY_COLOR.ORANGE
	elseif refineLevel <= 10 then
		fontColor = QIDEA_QUALITY_COLOR.RED
	end
	
	return fontColor
end

-- 设置奖励界面的名字
function QUIWidgetGemstonesBox:showItemName()
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	local name = itemInfo.name or ""
	self._ccbOwner.tf_name:setScale(1)
	local nameCount = #name
	local i = 1
	local pos = 0
	local halfPos = 0
	local sixPos = 0
	local specialPos = 0
	local specialStr = "("
    while true do 
        local c = string.sub(name,i,i)
        local b = string.byte(c)
        if b > 128 then
        	if specialStr == string.sub(name,i,i+3) then
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
    if specialPos ~= 0 and specialPos < autoWarpPos then
    	autoWarpPos = specialPos
	end
	self._ccbOwner.tf_name:setHorizontalAlignment(kCCTextAlignmentLeft)
	if autoWarpPos ~= nil then
		name = string.sub(name, 1, autoWarpPos).."\n"..string.sub(name, autoWarpPos+1)
		if autoWarpPos < nameCount/2 then
			self._ccbOwner.tf_name:setHorizontalAlignment(kCCTextAlignmentCenter)
		end
	end
	self._ccbOwner.tf_name:setString(name)
	local widthNum = self._ccbOwner.tf_name:getContentSize().width
	if widthNum > self._nameWidth then
		self._ccbOwner.tf_name:setScale(self._nameWidth/widthNum)
	end
	self._ccbOwner.tf_name:setColor(BREAKTHROUGH_COLOR_LIGHT[remote.gemstone:getSABC(itemInfo.gemstone_quality).color])
	self:setNameVisible(true)
end

--设置名称
function QUIWidgetGemstonesBox:setName(name,isgod)
	if isgod then
		self._ccbOwner.tf_ss_name:setString(name)
		self._ccbOwner.tf_name:setString("")
	else
		self._ccbOwner.tf_name:setString(name)
		self._ccbOwner.tf_ss_name:setString("")
	end
end

--设置名称颜色
function QUIWidgetGemstonesBox:setNameColor(color)
	self._ccbOwner.tf_name:setColor(color)
	self._ccbOwner.tf_ss_name:setColor(color)
end

--获取名称
function QUIWidgetGemstonesBox:getName()
	return self._ccbOwner.tf_name
end

--设置是否显示名称
function QUIWidgetGemstonesBox:setNameVisible(b)
	self._ccbOwner.tf_name:setVisible(b)
	self._ccbOwner.tf_ss_name:setVisible(b)
end

--替换掉本身的name
function QUIWidgetGemstonesBox:setNameNode(tf_name)
	local nameVisible = self._ccbOwner.tf_name:isVisible()
	local nameValue = self._ccbOwner.tf_name:getString() or ""
	self:setNameVisible(false)
	self._ccbOwner.tf_name = tf_name
	self:setNameVisible(nameVisible)
	self._ccbOwner.tf_name:setString(nameValue)
end

--设置小红点显示
function QUIWidgetGemstonesBox:setTips(b)
	self._tips = b
	self:showTipsByState()
end

--设置小红点显示
function QUIWidgetGemstonesBox:showTipsByState(state)
	if state == nil then
		self._ccbOwner.node_tips:setVisible(self._tips)
		return 
	end
	if state == "evolution" then
		self._ccbOwner.node_tips:setVisible(self._breakTips)
		return 
	end
	if state == "strength" then
		self._ccbOwner.node_tips:setVisible(self._strengthTips)
		return 
	end
	if state == "detail" then
		self._ccbOwner.node_tips:setVisible(self._detailTips)
		return 
	end

	if state == "mix" then
		self._ccbOwner.node_tips:setVisible(self._mixTips)
		return 
	end

	if state == "refine" then
		self._ccbOwner.node_tips:setVisible(self._refineTips)
		return 
	end
end

--设置突破小红点显示
function QUIWidgetGemstonesBox:setBreakTips(b)
	self._breakTips = b
end

--设置突破小红点显示
function QUIWidgetGemstonesBox:setStrengthTips(b)
	self._strengthTips = b
end

--设置突破小红点显示
function QUIWidgetGemstonesBox:setDetailTips(b)
	self._detailTips = b
end

function QUIWidgetGemstonesBox:setMixTips(b)
	self._mixTips = b
end

function QUIWidgetGemstonesBox:setRefineTips(b)
	self._refineTips = b
end

--设置强化信息显示
function QUIWidgetGemstonesBox:setStrengthVisible(b)
	if b and (self._state == remote.gemstone.GEMSTONE_NONE or self._state == remote.gemstone.GEMSTONE_WEAR) then
		self._ccbOwner.node_strengthen:setVisible(true)
	else
		self._ccbOwner.node_strengthen:setVisible(false)
	end
end

--设置是否显示状态描述
function QUIWidgetGemstonesBox:setStateDescVisible(b)
	self._ccbOwner.node_state:setVisible(b)
end

--设置是否显示品质信息
function QUIWidgetGemstonesBox:setStateQualityVisible(b)
	self._ccbOwner.node_quality:setVisible(b)
end

--设置icon位置的缩放
function QUIWidgetGemstonesBox:setIconScale(scale)
	self._ccbOwner.node_main:setScale(scale)
end

--显示套装特效
function QUIWidgetGemstonesBox:showSuitEffect(b)
	if b == false and self._suitEffect ~= nil then
		self._suitEffect:removeFromParent()
		self._suitEffect = nil
	elseif b == true and self._suitEffect == nil then
		self._suitEffect = QUIWidget.new("ccb/effects/baoshiguangxiao.ccbi")
		self._ccbOwner.node_icon:addChild(self._suitEffect)
	end
end

--重置
function QUIWidgetGemstonesBox:resetAll()
	self._ccbOwner.tf_name:setString("")
	self:setState(remote.gemstone.GEMSTONE_NONE)
	self._ccbOwner.node_godlevel:setVisible(false)
end

--根据状态显示
function QUIWidgetGemstonesBox:setState(state)
	self._state = state
	self._ccbOwner.node_break:setVisible(false)
	self._ccbOwner.node_quality:setVisible(false)
	self._ccbOwner.node_strengthen:setVisible(false)
	self._ccbOwner.node_refine:setVisible(false)
	self._ccbOwner.node_wear:setVisible(false)
	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_state:setVisible(false)
	self._ccbOwner.node_lock:setVisible(false)
	self._ccbOwner.node_godlevel:setVisible(false)
	self._ccbOwner.node_hero_star:setVisible(false)
	self:setGray(false)
	self:setBreakLevel()
	if state == remote.gemstone.GEMSTONE_NONE or state == remote.gemstone.GEMSTONE_WEAR then
		self._ccbOwner.node_break:setVisible(true)
		self._ccbOwner.node_quality:setVisible(true)
		self._ccbOwner.node_strengthen:setVisible(true)
	elseif state == remote.gemstone.GEMSTONE_LOCK then
		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_break:setVisible(true)
		self._ccbOwner.node_lock:setVisible(true)
	elseif state == remote.gemstone.GEMSTONE_ICON then
		self._ccbOwner.node_break:setVisible(true)
	elseif state == remote.gemstone.GEMSTONE_CAN_WEAR then
		self._ccbOwner.node_wear:setVisible(true)
		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_break:setVisible(true)
	end
end

function QUIWidgetGemstonesBox:getState()
	return self._state
end

function QUIWidgetGemstonesBox:getContentSize()
	return self._ccbOwner.sp_break:getContentSize()
end

function QUIWidgetGemstonesBox:_onTriggerTouch(e)
	self:dispatchEvent({name = QUIWidgetGemstonesBox.EVENT_CLICK, pos = self._pos, itemID = self._itemId})
end


function QUIWidgetGemstonesBox:getIsSelectedForFood()
	return self._isSelected
end

function QUIWidgetGemstonesBox:setSelectedFoodNum( num )
	self._selectedCountForFood = num
end

function QUIWidgetGemstonesBox:getSelectedFoodNum()
	return self._selectedCountForFood
end


function QUIWidgetGemstonesBox:setStarVisible(v)
	self._ccbOwner.node_hero_star:setVisible(v)
end

function QUIWidgetGemstonesBox:setSelectedForFood( boo )
	self._isSelected = boo
	self._ccbOwner.sp_subtract:setVisible(self._isSelected)
end

-- 選擇作為分解對象，全選或全部取消
function QUIWidgetGemstonesBox:onSelectChangeForFood()
	self._isSelected = not self._isSelected
	self._ccbOwner.sp_subtract:setVisible(self._isSelected)
	return self._isSelected
end

return QUIWidgetGemstonesBox