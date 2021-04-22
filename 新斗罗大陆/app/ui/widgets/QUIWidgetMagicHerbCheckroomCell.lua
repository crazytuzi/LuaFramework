--
-- Author: Kumo.Wang
-- 仙品养成穿戴界面Cell
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetMagicHerbCheckroomCell = class("QUIWidgetMagicHerbCheckroomCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMagicHerbBox = import(".QUIWidgetMagicHerbBox")
local QListView = import("...views.QListView")
local QActorProp = import("...models.QActorProp")

function QUIWidgetMagicHerbCheckroomCell:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_Checkroom.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
	}
	QUIWidgetMagicHerbCheckroomCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMagicHerbCheckroomCell:onEnter()
end

function QUIWidgetMagicHerbCheckroomCell:onExit()
end

function QUIWidgetMagicHerbCheckroomCell:_resetAll()
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_type:setVisible(false)
	self._ccbOwner.tf_prop_title_1:setVisible(false)
	self._ccbOwner.tf_prop_value_1:setVisible(false)
	self._ccbOwner.tf_prop_title_2:setVisible(false)
	self._ccbOwner.tf_prop_value_2_1:setVisible(false)
	self._ccbOwner.tf_prop_value_2_2:setVisible(false)
	self._ccbOwner.tf_state:setVisible(false)
	self._ccbOwner.sp_suit:setVisible(false)
	self._ccbOwner.tf_warn:setVisible(false)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:setVisible(true)
	self._ccbOwner.node_btn:setVisible(true)
	self._ccbOwner.sp_tuijian:setVisible(false)
	self._ccbOwner.btn_icon:setVisible(true)
	makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	self._ccbOwner.tf_btn_text:enableOutline()
	self._ccbOwner.btn_wear:setEnabled(true)
	self._ccbOwner.node_lock:setVisible(false)
	self._ccbOwner.btn_lock:setEnabled(false)

	self._clickWearEnable = true
end

function QUIWidgetMagicHerbCheckroomCell:setInfo(param)
	self:_resetAll()
	-- QPrintTable(param)
	self._isReborn = param.isReborn
	self._rebornType = param.rebornType
	self._magicHerbItemInfo = param.info
	self._actorId = param.actorId
	self._pos = param.pos
	-- self._otherMagicHerbInfoList = param.otherMagicHerbInfoList
	self._callback = param.callback

	if self._rebornType == 1 then
		self._ccbOwner.tf_btn_text:setString("放入分解")
	elseif self._rebornType == 2 then
		self._ccbOwner.tf_btn_text:setString("放入重生")
	else
		self._ccbOwner.tf_btn_text:setString("携 带")
	end

	local icon = QUIWidgetMagicHerbBox.new()
	icon:setInfo(self._magicHerbItemInfo.magicHerbInfo.sid)
	self._ccbOwner.node_icon:addChild(icon)
	icon:hideName()

	local itemConfig = db:getItemByID(self._magicHerbItemInfo.magicHerbInfo.itemId)
	local name =  ""
	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[1]]

	if itemConfig then
		-- QPrintTable(itemConfig)
		name =itemConfig.name
		fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]
	end
	local showBreed = false
	local  breedLevel = self._magicHerbItemInfo.magicHerbInfo.breedLevel or 0
    if breedLevel == remote.magicHerb.BREED_LV_MAX then
    	fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[ itemConfig.colour + 1]]
		showBreed= true
	elseif breedLevel > 0 then
		name = name.."+"..breedLevel
		showBreed= true
    end

	self._ccbOwner.tf_name:setString(name)
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	self._ccbOwner.tf_name:setVisible(true)
	self._ccbOwner.btn_info:setVisible(showBreed)

	local magicHerbConfig = self._magicHerbItemInfo.magicHerbConfig
	if magicHerbConfig then
		-- QPrintTable(magicHerbConfig)
		self._ccbOwner.tf_type:setString("【"..(magicHerbConfig.type_name or "无品").."类】")
		self._ccbOwner.tf_type:setVisible(true)

		if self._actorId then
			local uiHeroModle = remote.herosUtil:getUIHeroByID(self._actorId)
			if not uiHeroModle:checkMagicHerbCanWear(self._pos, magicHerbConfig.attribute_type, magicHerbConfig.type) then
				makeNodeFromNormalToGray(self._ccbOwner.node_btn)
				self._ccbOwner.tf_btn_text:disableOutline()
				self._ccbOwner.btn_wear:setEnabled(false)
				self._clickWearEnable = false
			end
		end
	end

	local basicPropList = {}
	local magicHerbGradeConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(self._magicHerbItemInfo.magicHerbInfo.itemId, self._magicHerbItemInfo.magicHerbInfo.grade or 1)
	local tbl = {}
	if magicHerbGradeConfig then
		-- QPrintTable(magicHerbGradeConfig)
		for key, value in pairs(magicHerbGradeConfig) do
			if QActorProp._field[key] then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				local num = value
				if tbl[key] then
					tbl[key] = {name = name, value = tbl[key].value + num, isPercent = QActorProp._field[key].isPercent}
				else
					tbl[key] = {name = name, value = num, isPercent = QActorProp._field[key].isPercent}
				end
			end
		end
	end
	local magicHerbUpLevelConfig =  remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(self._magicHerbItemInfo.magicHerbInfo.itemId, self._magicHerbItemInfo.magicHerbInfo.level or 1)
	if magicHerbUpLevelConfig then
		-- QPrintTable(magicHerbUpLevelConfig)
		for key, value in pairs(magicHerbUpLevelConfig) do
			if QActorProp._field[key] then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				local num = value
				if tbl[key] then
					tbl[key] = {name = name, value = tbl[key].value + num, isPercent = QActorProp._field[key].isPercent}
				else
					tbl[key] = {name = name, value = num, isPercent = QActorProp._field[key].isPercent}
				end
			end
		end
	end

	local tmpTbl1 = {}
	local tmpTbl2 = {}
	for k, v in pairs(tbl) do
		if k == "armor_physical" or k == "armor_magic" then
			table.insert(tmpTbl1, {name = v.name, value = v.value, isPercent = v.isPercent})
		elseif k == "armor_physical_percent" or k == "armor_magic_percent" then
			table.insert(tmpTbl2, {name = v.name, value = v.value, isPercent = v.isPercent})
		else
			table.insert(basicPropList, {name = v.name, value = v.value, isPercent = v.isPercent})
		end
	end
	if #tmpTbl1 == 2 then
		table.insert(basicPropList, {name = "双防", value = tmpTbl1[1].value, isPercent = tmpTbl1[1].isPercent})
	elseif #tmpTbl1 == 1 then
		table.insert(basicPropList, {name = tmpTbl1[1].name, value = tmpTbl1[1].value, isPercent = tmpTbl1[1].isPercent})
	end
	if #tmpTbl2 == 2 then
		table.insert(basicPropList, {name = "双防", value = tmpTbl2[1].value, isPercent = tmpTbl2[1].isPercent})
	elseif #tmpTbl2 == 1 then
		table.insert(basicPropList, {name = tmpTbl2[1].name, value = tmpTbl2[1].value, isPercent = tmpTbl2[1].isPercent})
	end

	local propStr = ""
	for _, v in ipairs(basicPropList) do
		v.value = q.getFilteredNumberToString(v.value, v.isPercent, 2)		
		propStr = propStr..(v.name.."+"..v.value.."  ")
	end
	self._ccbOwner.tf_prop_title_1:setString("仙品属性：")
	self._ccbOwner.tf_prop_title_1:setVisible(true)
	if propStr ~= "" then
		self._ccbOwner.tf_prop_value_1:setString(propStr)
		self._ccbOwner.tf_prop_value_1:setVisible(true)
	end

	local magicHerbInfo = self._magicHerbItemInfo.magicHerbInfo
	if magicHerbInfo and magicHerbConfig then 
		-- QPrintTable(magicHerbInfo)
		if showBreed then
		    local breedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(magicHerbInfo.itemId, breedLevel)
	    	local propConfig = {}
	    	if breedConfig then
	    		self._ccbOwner.tf_prop_title_2:setString("培育属性：")
				self._ccbOwner.tf_prop_title_2:setVisible(true)
		       	for key, value in pairs(breedConfig or {}) do
		            key = tostring(key)
		            if QActorProp._field[key] then
		                if propConfig[key] then
		                    propConfig[key] = propConfig[key] + value
		                else
		                    propConfig[key] = value
		                end
		            end
		        end
	    	end		
	    	local propDesc = remote.magicHerb:setPropInfo(breedConfig ,true,true,true)
	    	for i,v in ipairs(propDesc) do
	    		local tfNode = self._ccbOwner["tf_prop_value_2_"..i]
				if tfNode then
					-- tfNode = setShadowByFontColor(tfNode, color)
					tfNode:disableOutline()
					tfNode:setColor(COLORS.k)
					if i == 1 then
						tfNode:setString(v.name.."+"..v.value)
					else
						tfNode:setString(v.name.."...")
					end
					tfNode:setVisible(true)
				end
	    	end
	    	self:_autoLayoutRefineProp()
		else
			if magicHerbInfo.attributes then
				self._ccbOwner.tf_prop_title_2:setString("转生属性：")
				self._ccbOwner.tf_prop_title_2:setVisible(true)
				-- local propStr = ""
				local index = 1
				for _, value in ipairs(magicHerbInfo.attributes) do
					local key = value.attribute
					if key and QActorProp._field[key] then
						local tfNode = self._ccbOwner["tf_prop_value_2_"..index]
						if tfNode then
							local name = QActorProp._field[key].uiName or QActorProp._field[key].name
							local num = q.getFilteredNumberToString(value.refineValue, QActorProp._field[key].isPercent, 2)	
							local additional_attributes = remote.magicHerb:getMagicHerbAdditionalAttributes(magicHerbInfo)
							local colorStr = remote.magicHerb:getRefineValueColorAndMax(key, value.refineValue, additional_attributes)
							local color = COLORS[colorStr]
							tfNode:setColor(color)
							tfNode = setShadowByFontColor(tfNode, color)
							tfNode:enableOutline()
							tfNode:setString(name.."+"..num)
							tfNode:setVisible(true)
							index = index + 1
						end
						-- propStr = propStr..(name.."+"..num.."  ")
					end
				end
				self:_autoLayoutRefineProp()
			end
		end



		local state = ""
		if magicHerbInfo.actorId ~= nil and magicHerbInfo.actorId > 0 then
			local charactConfig = QStaticDatabase:sharedDatabase():getCharacterByID(magicHerbInfo.actorId)
			if charactConfig ~= nil and charactConfig.name ~= nil then
				state = charactConfig.name.."装备中"
				self._ccbOwner.tf_state:setString(state)
				self._ccbOwner.tf_state:setVisible(true)
			end

			if magicHerbInfo.actorId == self._actorId then
				makeNodeFromNormalToGray(self._ccbOwner.node_btn)
				self._ccbOwner.tf_btn_text:disableOutline()
				self._ccbOwner.btn_wear:setEnabled(false)
				self._clickWearEnable = false
			end
		else
			self._ccbOwner.sp_suit:setVisible(self._ccbOwner.btn_wear:isEnabled() and not self._isReborn)
		end
		
		self:_updateLock()
	end
end

function QUIWidgetMagicHerbCheckroomCell:_autoLayoutRefineProp()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.tf_prop_value_2_1)
	table.insert(nodes, self._ccbOwner.tf_prop_value_2_2)
	q.autoLayerNode(nodes, "x", 15)
end

function QUIWidgetMagicHerbCheckroomCell:_updateLock()
    self._ccbOwner.btn_lock:setHighlighted(self._magicHerbItemInfo.magicHerbInfo.isLock)
    self._ccbOwner.btn_lock:setVisible(true)
    -- self._ccbOwner.btn_lock:setEnabled(false)
end

function QUIWidgetMagicHerbCheckroomCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetMagicHerbCheckroomCell:_onTriggerWear()
	app.sound:playSound("common_small")

	if not self._clickWearEnable then
		app.tip:floatTip("对应仙品无法携带")
		return
	end

	if self._callback then
		self._callback({magicHerbItemInfo = self._magicHerbItemInfo})
	end
end

function QUIWidgetMagicHerbCheckroomCell:_onTriggerInfo()
	app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMagicHerbAttrInfo"
  		,options = {magicHerbInfo = self._magicHerbItemInfo.magicHerbInfo, subtitle = "属性详情"}}, {isPopCurrentDialog = false})
end


function QUIWidgetMagicHerbCheckroomCell:_onTriggerClick()
	print("QUIWidgetMagicHerbCheckroomCell:_onTriggerClick()")
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuitView", 
        options = {sid = self._magicHerbItemInfo.magicHerbInfo.sid}})
end

return QUIWidgetMagicHerbCheckroomCell