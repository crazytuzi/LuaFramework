--
-- Author: Kumo.Wang
-- 仙品养成升级界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbUpLevel = class("QUIWidgetMagicHerbUpLevel", QUIWidget)

local QListView = import("...views.QListView")
local QActorProp = import("...models.QActorProp")
local QUIWidgetAnimationPlayer = import(".QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIViewController = import("...ui.QUIViewController")

local QUIWidgetMagicHerbEffectBox = import("..widgets.QUIWidgetMagicHerbEffectBox")

function QUIWidgetMagicHerbUpLevel:ctor( options )
    local ccbFile = "ccb/Widget_MagicHerb_UpLevel.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerOne", callback = handler(self, self._onTriggerOne)},
        {ccbCallbackName = "onTriggerFive", callback = handler(self, self._onTriggerFive)},
        {ccbCallbackName = "onTriggerUpTeamLevel", callback = handler(self, self._onTriggerUpTeamLevel)},
    }
    QUIWidgetMagicHerbUpLevel.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.button_five)
    q.setButtonEnableShadow(self._ccbOwner.button_one)

end

function QUIWidgetMagicHerbUpLevel:onEnter()
	self:_init()
end

function QUIWidgetMagicHerbUpLevel:onExit()
end

function QUIWidgetMagicHerbUpLevel:setParentDailog(parentDailog)
	self._parentDailog = parentDailog
end

function QUIWidgetMagicHerbUpLevel:_reset()
	self._ccbOwner.node_info:setVisible(false)
	self._ccbOwner.node_client:setVisible(false)
	self._ccbOwner.node_max:setVisible(false)

	self._ccbOwner.node_client_old:setVisible(true)
	self._ccbOwner.node_client_new:setVisible(true)
	self._ccbOwner.tf_magicHerb_info:setVisible(false)
	self._ccbOwner.tf_level_limit:setVisible(false)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:setVisible(true)
	self._ccbOwner.node_btn:setVisible(true)
	self._ccbOwner.node_icon_for_one:removeAllChildren()
	self._ccbOwner.tf_price_for_one:setVisible(false)
	self._ccbOwner.node_icon_for_five:removeAllChildren()
	self._ccbOwner.tf_price_for_five:setVisible(false)
	self._ccbOwner.btn_one:setVisible(true)
	self._ccbOwner.btn_five:setVisible(true)
	self._ccbOwner.node_limitByTeamLevel:setVisible(false)
	self._ccbOwner.btn_team_upLevel:setVisible(false)
end

function QUIWidgetMagicHerbUpLevel:_init()
	self:_reset()
end

function QUIWidgetMagicHerbUpLevel:setInfo(actorId, pos)
	self:_reset()

	self._actorId = actorId
	self._pos = pos
	self._uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)

	self._curMasterLevel = self._uiHeroModel:getMasterLevelByType(QUIHeroModel.MAGICHERB_UPLEVEL_MASTER)
	local wearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(self._pos)
	if not wearedInfo then return end
	self._sid = wearedInfo.sid
	
	self._ccbOwner.node_info:setVisible(true)

	self._icon = QUIWidgetMagicHerbEffectBox.new()
	self._icon:setInfo(self._sid)
	self._icon:hideName()
	self._ccbOwner.node_icon:addChild(self._icon)



	self:_update()
end

function QUIWidgetMagicHerbUpLevel:_update()
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	if not magicHerbItemInfo then return end
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
	if not magicHerbConfig then return end
	local maigcHerbItemConfig = db:getItemByID(magicHerbItemInfo.itemId)
	if not maigcHerbItemConfig then return end

	local breedLv = magicHerbItemInfo.breedLevel or 0
	local itemId = magicHerbItemInfo.itemId
	local aptitude = remote.magicHerb:getAptitudeByIdAndBreedLv(itemId,breedLv)
	local nextLevel = magicHerbItemInfo.level + 1

	local teamMaxLevel = remote.user.level * 2
	local configMaxLevel = magicHerbConfig.devour_level
	self._maxLevel = teamMaxLevel > configMaxLevel and configMaxLevel or teamMaxLevel
	local level = magicHerbItemInfo.level or 1
	self._ccbOwner.tf_level_limit:setString("等级："..level.."/"..self._maxLevel)
	self._ccbOwner.tf_level_limit:setVisible(true)
	self._differentLevel = self._maxLevel - level
	if self._differentLevel >= 5 then
		self._ccbOwner.tf_btn_five:setString("升5级")
	else
		self._ccbOwner.tf_btn_five:setString("升"..self._differentLevel.."级")
	end

	self._ccbOwner.node_max:setVisible(false)
	self._ccbOwner.node_client:setVisible(false)

	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour]]
	local addStr = ""
	if breedLv > 0 then
		addStr= "+"..breedLv
	end

	if aptitude == APTITUDE.SS then
		fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour + 1]]
		addStr = ""
	end

	self._ccbOwner.tf_magicHerb_info:setColor(fontColor)
	self._ccbOwner.tf_magicHerb_info = setShadowByFontColor(self._ccbOwner.tf_magicHerb_info, fontColor)
	self._ccbOwner.tf_magicHerb_info:setVisible(true)
	self._ccbOwner.tf_magicHerb_info:setString(magicHerbConfig.name..addStr.."【"..magicHerbConfig.type_name.."类】")


	self._curEnchantConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel( itemId, magicHerbItemInfo.level )
	self._nextEnchantConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel( itemId , nextLevel )
	if magicHerbItemInfo.level == configMaxLevel or self._nextEnchantConfig == nil then
		self:setMagicHerbPropInfo("max",self._curEnchantConfig ,breedLv,itemId,aptitude)
		self._ccbOwner.node_max:setVisible(true)
		return
	end
	self._ccbOwner.node_client:setVisible(true)

	self:setMagicHerbPropInfo("old",self._curEnchantConfig ,breedLv,itemId,aptitude)
	self:setMagicHerbPropInfo("new",self._nextEnchantConfig ,breedLv,itemId,aptitude)
	if teamMaxLevel == magicHerbItemInfo.level then
		self._ccbOwner.node_limitByTeamLevel:setVisible(true)
		self._ccbOwner.node_btn:setVisible(false)

		self._ccbOwner.btn_team_upLevel:setVisible(true)
	else
		self._ccbOwner.node_limitByTeamLevel:setVisible(false)
		self._ccbOwner.node_btn:setVisible(true)

		local tbl = string.split(self._nextEnchantConfig.consum, "^")
		self._itemId, self._price = tonumber(tbl[1]), tonumber(tbl[2])
		local num = remote.items:getItemsNumByID(self._itemId)

		local itemConfig = db:getItemByID(self._itemId)
		if itemConfig.icon_1 then
			local icon1 = CCSprite:create(itemConfig.icon_1)
			local icon2 = CCSprite:create(itemConfig.icon_1)
			self._ccbOwner.node_icon_for_one:addChild(icon1)
			self._ccbOwner.node_icon_for_five:addChild(icon2)
		end

		self._ccbOwner.tf_price_for_one:setString(self._price)
		self._ccbOwner.tf_price_for_one:setVisible(true)
		local fiveLevelCount = self:getFiveLevelConsume(magicHerbConfig.id, magicHerbItemInfo.level)
		self._ccbOwner.tf_price_for_five:setString(fiveLevelCount)
		self._ccbOwner.tf_price_for_five:setVisible(true)
	end

	
	if self._icon then
		self._icon:setInfo(self._sid)
		self._icon:hideName()
	end
end

function QUIWidgetMagicHerbUpLevel:setMagicHerbPropInfo(typeStr , lvConfig , breedLv , itemId , aptitude)
	self._ccbOwner["tf_prop_"..typeStr.."_1"]:setVisible(false)
	self._ccbOwner["tf_prop_"..typeStr.."_2"]:setVisible(false)
	self._ccbOwner["tf_prop_"..typeStr.."_3"]:setVisible(false)
	self._ccbOwner["tf_level_"..typeStr]:setString(lvConfig.level.."级效果")
	local curBreed = breedLv > 0 and breedLv or 1

	local enhanceExtraConfig = db:getMagicHerbEnhanceExtraConfigByBreedLvAndId( lvConfig.level , curBreed)
	local maxShowNum = 3

	local descTbl = {}
	local propDesc = remote.magicHerb:setPropInfo(lvConfig ,true,true,true)	

	local str ="无"
	local curKey = ""
	for i,prop in ipairs(propDesc or {}) do
		str = prop.name.."+"..prop.value
		curKey = prop.key
	end
	self._ccbOwner["tf_prop_"..typeStr.."_1"]:setString(str)

	if enhanceExtraConfig ~= nil and aptitude >= APTITUDE.S then
		self._ccbOwner["tf_prop_"..typeStr.."_1"]:setPositionY(10)
		local col = COLORS.j
		local col2 = COLORS.j
		str = "S+"..curBreed.."额外提升"
		if aptitude == APTITUDE.SS then
			str = "SS 额外提升"
		end
		if typeStr == "new" then
			col = COLORS.l
		end
		if breedLv < curBreed then
			col = COLORS.n
			col2 = COLORS.n
			str = str.."(未激活)"
		end

		self._ccbOwner["tf_prop_"..typeStr.."_2"]:setString(str)
		self._ccbOwner["tf_prop_"..typeStr.."_2"]:setColor(col2)
		self._ccbOwner["tf_prop_"..typeStr.."_2"]:setPositionY(-20)
		propDesc = remote.magicHerb:setPropInfo(enhanceExtraConfig ,true,true,true)	
		str ="无"
		print(curKey)
		for i,prop in ipairs(propDesc or {}) do

			if prop.key == curKey then
				str = prop.name.."+"..prop.value
			end
		end
		self._ccbOwner["tf_prop_"..typeStr.."_3"]:setString(str)
		self._ccbOwner["tf_prop_"..typeStr.."_3"]:setColor(col)
		self._ccbOwner["tf_prop_"..typeStr.."_3"]:setPositionY(-50)
	else
		self._ccbOwner["tf_prop_"..typeStr.."_1"]:setPositionY(-20)
		maxShowNum = 1
	end

	for i=1,maxShowNum do
		self._ccbOwner["tf_prop_"..typeStr.."_"..i]:setVisible(true)
	end


end



function QUIWidgetMagicHerbUpLevel:_onTriggerOne()
	app.sound:playSound("common_small")
	local num = remote.items:getItemsNumByID(self._itemId)
	if num >= self._price then
		local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
		self._startUpLevel = magicHerbItemInfo.level or 1
		self._oldMasterLevel = self._curMasterLevel
		print("self._oldMasterLevel (1)= ", self._oldMasterLevel)
		remote.magicHerb:magicHerbEnhanceRequest(self._sid, 1, function()
				if self._ccbView then
					if self._curMasterLevel > self._oldMasterLevel then
						print("self._parentDailog:enableTouchSwallowTop()")
						self._parentDailog:enableTouchSwallowTop()
					end

					self:_showTipsEffect()
					-- self:_update()
				end
			end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
		-- app.tip:floatTip("道具不足")
	end
end

function QUIWidgetMagicHerbUpLevel:_onTriggerFive()
	app.sound:playSound("common_small")
	local num = remote.items:getItemsNumByID(self._itemId)
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	local fiveLevelCount = self:getFiveLevelConsume(magicHerbItemInfo.itemId ,magicHerbItemInfo.level)
	if num >= fiveLevelCount then
		self._startUpLevel = magicHerbItemInfo.level or 1
		self._oldMasterLevel = self._curMasterLevel
		remote.magicHerb:magicHerbEnhanceRequest(self._sid, 5, function()
				if self._ccbView then
					if self._curMasterLevel > self._oldMasterLevel then
						print("self._parentDailog:enableTouchSwallowTop()")
						self._parentDailog:enableTouchSwallowTop()
					end
					self:_showTipsEffect()
					-- self:_update()
				end
			end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
		-- app.tip:floatTip("道具不足")
	end
end

function QUIWidgetMagicHerbUpLevel:_onTriggerUpTeamLevel()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {isQuickWay = true}})
end

function QUIWidgetMagicHerbUpLevel:_getPropWithLevelUp()
	if not self._startUpLevel then return end
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	local nowLevel = magicHerbItemInfo.level
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)

	
	local tbl1 = {}
	local tbl2 = {}
	local enchantConfig1 = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel( magicHerbConfig.id, self._startUpLevel )
	for key, value in pairs(enchantConfig1) do
		if QActorProp._field[key] then
			if tbl1[key] then
				tbl1[key] = tbl1[key] + tonumber(value)
			else
				tbl1[key] = tonumber(value)
			end
		end
	end
	local enchantConfig2 = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel( magicHerbConfig.id, nowLevel )
	for key, value in pairs(enchantConfig2) do
		if QActorProp._field[key] then
			if tbl2[key] then
				tbl2[key] = tbl2[key] + tonumber(value)
			else
				tbl2[key] = tonumber(value) - (tbl1[key] or 0)
			end
		end
	end
				
	self._showPropList = self:_getPropListByEnchantConfig(tbl2)
end

function QUIWidgetMagicHerbUpLevel:_showTipsEffect()
	self:_getPropWithLevelUp()
    if #self._showPropList > 0 then
    	if self._effectShow ~= nil then
            self._effectShow:disappear()
            self._effectShow = nil
        end
        local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
        self._effectShow = QUIWidgetAnimationPlayer.new()
        self:getParent():addChild(self._effectShow)
        self._effectShow:setPosition(100, -200)
        self._effectShow:playAnimation(ccbFile, function(ccbOwner)
		        ccbOwner.node_green:setVisible(true)
		        ccbOwner.node_red:setVisible(false)
		        ccbOwner.tf_title1:setString("升级成功")
		        for i=1, 4 do
		            ccbOwner["node_"..i]:setVisible(false)
		        end
		        local index = 1
		        for _, value in ipairs(self._showPropList) do
		            local node = ccbOwner["node_"..index]
		            local tf = ccbOwner["tf_name"..index]
		            if node and tf then
		                tf:setString(value.name.."：+ "..value.value)
		                node:setVisible(true)
		                index = index + 1
		            end
		        end
		        end, function()
		            if self._effectShow ~= nil then
		                self._effectShow:disappear()
		                self._effectShow = nil
		            end
	            self:_showMasterLevelUp()
	        end)    
    end
end

function QUIWidgetMagicHerbUpLevel:_showMasterLevelUp()
	if self._oldMasterLevel and self._curMasterLevel > self._oldMasterLevel then
		local _oldMasterLevel = self._oldMasterLevel
		self._oldMasterLevel = nil

		print("self._parentDailog:disableTouchSwallowTop()")
		self._parentDailog:disableTouchSwallowTop()
		-- app.master:createMasterLayer()
		-- app.master:upGradeMagicHerbMaster(_oldMasterLevel, self._curMasterLevel, QUIHeroModel.MAGICHERB_UPLEVEL_MASTER, self._actorId)
		-- app.master:cleanMasterLayer()
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	end
end


function QUIWidgetMagicHerbUpLevel:createPropTextNode(name,value,isGray)
	local tfNode = CCNode:create()
	local width = 0
    local tfName = CCLabelTTF:create(name, global.font_default, 22)
    tfName:setAnchorPoint(ccp(0, 0.5))
    tfName:setColor(isGray and COLORS.n or COLORS.j)
    tfName:setPositionX(0)
	tfNode:addChild(tfName)
	width = tfName:getContentSize().width + width

	if value ~= nil then
		width = 5 + width
	    local tfValue = CCLabelTTF:create(value, global.font_default, 22)
	    tfValue:setAnchorPoint(ccp(0, 0.5))
	    tfValue:setColor(COLORS.l )
	    tfValue:setPositionX(width)
		tfNode:addChild(tfValue)
		width = tfValue:getContentSize().width + width
	end

	return tfNode , width
end


function QUIWidgetMagicHerbUpLevel:getFiveLevelConsume(magicHerbId, magicHerbLevel)
	local startLevel = magicHerbLevel + 1
	local count = 0
	for i = startLevel, startLevel + 4, 1 do
		if i <= self._maxLevel then
			local enchantConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(magicHerbId, i)
			local tbl = string.split(enchantConfig.consum, "^")
			count = count + tonumber(tbl[2])
		end
	end

	return count
end

function QUIWidgetMagicHerbUpLevel:_getPropListByEnchantConfig( config )
	local tbl = {}
	if config then
		local tmpTbl1 = {}
		local tmpTbl2 = {}
		for key, value in pairs(config) do
			if QActorProp._field[key] then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				value = q.getFilteredNumberToString(value, QActorProp._field[key].isPercent, 2)		
				if key == "armor_physical" or key == "armor_magic" then
					table.insert(tmpTbl1, {name = name, value = value})
				elseif key == "armor_physical_percent" or key == "armor_magic_percent" then
					table.insert(tmpTbl2, {name = name, value = value})
				else
					table.insert(tbl, {name = name, value = value})
				end
				
			end
		end
		if #tmpTbl1 == 2 then
			table.insert(tbl, {name = "双防", value = tmpTbl1[1].value})
		elseif #tmpTbl1 == 1 then
			table.insert(tbl, {name = tmpTbl1[1].name, value = tmpTbl1[1].value})
		end
		if #tmpTbl2 == 2 then
			table.insert(tbl, {name = "双防", value = tmpTbl2[1].value})
		elseif #tmpTbl2 == 1 then
			table.insert(tbl, {name = tmpTbl2[1].name, value = tmpTbl2[1].value})
		end
	end
	
	return tbl
end

return QUIWidgetMagicHerbUpLevel