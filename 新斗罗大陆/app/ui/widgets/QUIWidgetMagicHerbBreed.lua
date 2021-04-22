
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbBreed = class("QUIWidgetMagicHerbBreed", QUIWidget)

local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetItemsBox =  import("..widgets.QUIWidgetItemsBox")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetMagicHerbEffectBox = import("..widgets.QUIWidgetMagicHerbEffectBox")

QUIWidgetMagicHerbBreed.EXPOSURE_ACTION_TYPE = 1	--曝光动画
QUIWidgetMagicHerbBreed.FLOWER_ACTION_TYPE = 2		--花动画
QUIWidgetMagicHerbBreed.PARTICLE_ACTION_TYPE = 3

function QUIWidgetMagicHerbBreed:ctor( options )
    local ccbFile = "ccb/Widget_MagicHerb_Breed.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerBreed", callback = handler(self, self._onTriggerBreed)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
  
    }
    QUIWidgetMagicHerbBreed.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_breed)
    q.setButtonEnableShadow(self._ccbOwner.btn_plus)

    self._costItemId = 1
	self._delayUpdate = false
	self._callback = nil
	self._isAction = false
end

function QUIWidgetMagicHerbBreed:onEnter()
	self:_init()
end

function QUIWidgetMagicHerbBreed:onExit()
	if self._delayHandle ~= nil then
		scheduler.unscheduleGlobal(self._delayHandle)
		self._delayHandle = nil
	end	
	self._callback = nil
end

function QUIWidgetMagicHerbBreed:_reset()
	self._ccbOwner.node_grade_tips:setVisible(false)
end

function QUIWidgetMagicHerbBreed:_init()
	self:_reset()
end

function QUIWidgetMagicHerbBreed:setInfo(actorId, pos)



	self._actorId = actorId
	self._pos = pos
	self._uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local wearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(self._pos)
	if not wearedInfo then return end

	if self._isAction and self._actorId == actorId  and self._pos == pos and self._sid == wearedInfo.sid  then --需要动画不刷新
		return 
	end
	self._callback = nil
	self._isAction = false

	self._ccbOwner.node_action_end:removeAllChildren()

	self._sid = wearedInfo.sid

	self:updateInfo()
	self:updateInitAction()

end

function QUIWidgetMagicHerbBreed:updateData()
	local magicHerbInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	self._breedLv = magicHerbInfo.breedLevel or 0
end

function QUIWidgetMagicHerbBreed:updateInfo()
	local magicHerbInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	local itemConfig = db:getItemByID(magicHerbInfo.itemId)
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbInfo.itemId)

	if not magicHerbInfo or not magicHerbConfig or not itemConfig then return end

	self._breedLv = magicHerbInfo.breedLevel or 0
	self._magicHerbId = magicHerbConfig.id

	if self._icon == nil then
		self._icon = QUIWidgetMagicHerbEffectBox.new()
		self._ccbOwner.node_icon:addChild(self._icon)
	end
	self._icon:setInfo(self._sid)
	self._icon:hideName()

	local name = magicHerbConfig.name
	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]

	local curBreedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._magicHerbId, self._breedLv )
	local nextBreedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._magicHerbId, self._breedLv + 1)
	self._ccbOwner.node_max:setVisible(false)
	self._ccbOwner.node_client:setVisible(false)
	if nextBreedConfig == nil then
		self._ccbOwner.node_max:setVisible(true)
		self._ccbOwner.node_client:setVisible(false)
		fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour + 1]]
		self:setMagicHerbPropInfo("max",curBreedConfig,false,true,name,fontColor)
		return
	end
	self._ccbOwner.node_client:setVisible(true)

	local  isZero = false
	if curBreedConfig == nil then
		isZero = true
		curBreedConfig = nextBreedConfig
	end

	self:setMagicHerbPropInfo("old",curBreedConfig,isZero,false,name,fontColor)
	if nextBreedConfig.breed_level >= remote.magicHerb.BREED_LV_MAX then
		fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour + 1]]
		self:setMagicHerbPropInfo("new",nextBreedConfig,false,true,name,fontColor)
	else
		self:setMagicHerbPropInfo("new",nextBreedConfig,false,false,name,fontColor)
	end


	self:setCostNum(nextBreedConfig)
	self:setCostIcon(nextBreedConfig)
	self:checkRedTips()
end


function QUIWidgetMagicHerbBreed:updateInitAction()
	print("breedLv" ..self._breedLv)
	for i=1,4 do
		self._ccbOwner["node_fly_"..i]:setVisible(i <= self._breedLv)
		local pNode = self._ccbOwner["node_flower_"..i]
		local fcaAnimation = self:getActionNode(pNode,QUIWidgetMagicHerbBreed.FLOWER_ACTION_TYPE)
		if i <= self._breedLv then
			fcaAnimation:playAnimation("animation2", true)
		else
			fcaAnimation:playAnimation("animation", true)
		end
	end

	if self._breedLv >= remote.magicHerb.BREED_LV_MAX then
		self:updateBg(2)
	else
		self:updateBg(1)
	end

end

function QUIWidgetMagicHerbBreed:getActionNode(node,aniType)
	node:removeAllChildren()
	print("QUIWidgetMagicHerbBreed:getActionNode")
	local resAni = QResPath("magic_breed_ani")[aniType]
    local fcaAnimation = QUIWidgetFcaAnimation.new(resAni, "res")
    node:addChild(fcaAnimation)
     return fcaAnimation
end

function QUIWidgetMagicHerbBreed:breedSucceedCallBack()
	if self._delayHandle ~= nil then
		scheduler.unscheduleGlobal(self._delayHandle)
		self._delayHandle = nil
	end
	self._callback = function()
		if self._ccbView then
			self._isAction = false
			self:setInfo(self._actorId, self._pos)
		end
		remote.magicHerb:dispatchEvent({name = remote.magicHerb.EVENT_REFRESH_MAGIC_HERB_BREED_SUCCESS, sid = magicHerbSid, isBreed = true})
	end

	self:updateData()
	self:playActionByIndex(self._callback)
end


function QUIWidgetMagicHerbBreed:updateBg(type_)
	local spBg = QSpriteFrameByPath(QResPath("magic_breed_Bg")[type_]) 
	self._ccbOwner.sp_bg:setDisplayFrame(spBg)
end

function QUIWidgetMagicHerbBreed:playActionByIndex(callback)

	if self._breedLv < remote.magicHerb.BREED_LV_MAX then
		local pNode = self._ccbOwner["node_flower_"..self._breedLv]
		local fcaAnimation = self:getActionNode(pNode,QUIWidgetMagicHerbBreed.FLOWER_ACTION_TYPE)
		fcaAnimation:playAnimation("animation1", false)
		fcaAnimation:setEndCallback(function( )
				fcaAnimation:playAnimation("animation2", true)
	            self._ccbOwner["node_fly_"..self._breedLv]:setVisible(true)
				if callback then
					callback()
				end

	        end)
	else
		local pNode = self._ccbOwner.node_action_end
		local fcaAnimation = self:getActionNode(pNode,QUIWidgetMagicHerbBreed.EXPOSURE_ACTION_TYPE)
		fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
			if callback then
				callback()
			end
			end)
	end

end

function QUIWidgetMagicHerbBreed:setCostNum(nextBreedConfig)
	if nextBreedConfig then
		local inheritCount = remote.items:getItemsNumByID(nextBreedConfig.breed_item)
		local maxBreedCount = nextBreedConfig.breed_num or 10
		self._ccbOwner.tf_progress:setString(inheritCount.."/"..maxBreedCount)
		self._ccbOwner.sp_progress:setScaleX(math.min(inheritCount / maxBreedCount, 1))
	else
		self._ccbOwner.tf_progress:setString("已到顶级")
		self._ccbOwner.sp_progress:setScaleX(1)
	end
end

function QUIWidgetMagicHerbBreed:setMagicHerbPropInfo(typeStr , config , isZero , isMax , nameStr , fontColor)

	local propDesc =remote.magicHerb:setPropInfo(config ,true,true,true)	
	--	"tf_state_"..typeStr
	--	"node_richText_"..typeStr
	if isZero or isMax  then
		self._ccbOwner["tf_state_"..typeStr]:setString(nameStr)
	else
		self._ccbOwner["tf_state_"..typeStr]:setString(nameStr.."+"..config.breed_level)
	end
	self._ccbOwner["tf_state_"..typeStr]:setColor(fontColor)
	self._ccbOwner["tf_state_"..typeStr] = setShadowByFontColor(self._ccbOwner["tf_state_"..typeStr], fontColor)

	self._ccbOwner["node_richText_"..typeStr]:removeAllChildren()
	for i,prop in ipairs(propDesc) do
		--prop.name
		--prop.value
		local value = prop.value 
		if isZero then
			value = 0
		end

		local tfNode = self:createPropTextNode(prop.name , value , typeStr == "new")
		self._ccbOwner["node_richText_"..typeStr]:addChild(tfNode)
		tfNode:setPositionY((1.5 - i) * 40)
	end

end

function QUIWidgetMagicHerbBreed:checkRedTips()
	self._ccbOwner.node_grade_tips:setVisible(remote.magicHerb:isBreedUpRedTipsBySid(self._sid))
end

function QUIWidgetMagicHerbBreed:setCostIcon(nextBreedConfig)
	--消耗展示
	self._ccbOwner.node_item:removeAllChildren()
	local itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.node_item:addChild(itemBox)
	itemBox:setGoodsInfo(nextBreedConfig.breed_item, ITEM_TYPE.ITEM)
	itemBox:hideSabc()
end


function QUIWidgetMagicHerbBreed:_onTriggerPlus(e)
	if self._isAction then
		return
	end

	local nextBreedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._magicHerbId, self._breedLv + 1)
	if nextBreedConfig then
		local dropType = QQuickWay.ITEM_DROP_WAY
		QQuickWay:addQuickWay(dropType,nextBreedConfig.breed_item, nil, nil, false)
	end
end




function QUIWidgetMagicHerbBreed:_onTriggerBreed(e)

	if self._isAction then
		return
	end

	local nextBreedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._magicHerbId, self._breedLv + 1)
	if nextBreedConfig == nil then
		app.tip:floatTip("已经到顶级")
		return
	end

	local curCount = remote.items:getItemsNumByID(nextBreedConfig.breed_item)
	if curCount >= nextBreedConfig.breed_num then
		remote.magicHerb:magicHerbBreedRequest(self._sid,function()
			self._isAction = true

			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbBreedSuccess",
				options = {sid = self._sid, callback = function ()
					if self._ccbView then
						if self._delayHandle ~= nil then
                			scheduler.unscheduleGlobal(self._delayHandle)
                			self._delayHandle = nil
            			end
						 self._delayHandle = scheduler.performWithDelayGlobal(handler(self, self.breedSucceedCallBack), 0.2)
					end
				end}},{isPopCurrentDialog = false})
			end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, nextBreedConfig.breed_item)
	end
end

function QUIWidgetMagicHerbBreed:createPropTextNode(name,value,isGreen)
	local tfNode = CCNode:create()

    local tfName = CCLabelTTF:create(name, global.font_default, 20)
    tfName:setAnchorPoint(ccp(0, 0.5))
    tfName:setColor(COLORS.j)
    tfName:setPositionX(0)
	tfNode:addChild(tfName)
    local tfValue = CCLabelTTF:create("+"..value, global.font_default, 20)
    tfValue:setAnchorPoint(ccp(0, 0.5))
    tfValue:setColor(isGreen and COLORS.l or COLORS.j)
    tfValue:setPositionX(tfName:getContentSize().width + 5)
	tfNode:addChild(tfValue)
	return tfNode
end

return QUIWidgetMagicHerbBreed