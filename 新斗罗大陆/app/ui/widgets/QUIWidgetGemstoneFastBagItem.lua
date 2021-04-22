local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneFastBagItem = class("QUIWidgetGemstoneFastBagItem", QUIWidget)
local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QActorProp = import("...models.QActorProp")
local QUIViewController = import("...QUIViewController")
 
function QUIWidgetGemstoneFastBagItem:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_kehuishou.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
    }
	QUIWidgetGemstoneFastBagItem.super.ctor(self, ccbFile, callBacks, options)

	if options then
		self._callback = options.callback
	end
	self:setDuplicateVisible(false)
	self:setSuitVisible(false)
	self:setTuijianVisible(false)
	self._ccbOwner.tf_desc:setVisible(true)
end

function QUIWidgetGemstoneFastBagItem:getContentSize()
	local size = self._ccbOwner.normal_banner:getContentSize()
	size.height = size.height + 10
	return size
end

function QUIWidgetGemstoneFastBagItem:setInfo(gemstone)
	self:setDuplicateVisible(false)
	self:setSuitVisible(false)
	self:setTuijianVisible(false)
	self._ccbOwner.tf_cost:setVisible(false)
	self._ccbOwner.sp_cost:setVisible(false)
	self._ccbOwner.tf_count:setString("")
	
	local buttonText = gemstone.buttonText or ""
	if gemstone.callback then
		self._callback = gemstone.callback
		gemstone = gemstone.v
	end
	self._gemstone = gemstone
	self._isFragment = gemstone.isFragment

	local itemConfig = db:getItemByID(gemstone.itemId)
    local name = itemConfig.name
	self._ccbOwner.node_icon:removeAllChildren()
	local totalprop ={}

	if self._isFragment then
		local icon = QUIWidgetGemStonePieceBox.new()
		icon:setGoodsInfo(gemstone.id, ITEM_TYPE.GEMSTONE_PIECE, gemstone.count)
		self._ccbOwner.node_icon:addChild(icon)
		self._ccbOwner.buttonText:setString("合 成")

		local itemInfo = db:getItemCraftByItemId(gemstone.itemId)
        local needCount = itemInfo.component_num_1 or 1
		local desc = gemstone.count.."/"..needCount.."（可合成）"
		name = name.."碎片"
		self._ccbOwner.tf_count:setString(desc)

		local sabcInfo = db:getSABCByQuality(gemstone.gemstone_quality)

		local fontColor = BREAKTHROUGH_COLOR_LIGHT[sabcInfo.color]
		self._ccbOwner.tf_name:setColor(fontColor)
		self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

		self._ccbOwner.tf_type:setString("")
		self._ccbOwner.tf_cost:setVisible(true)
		self._ccbOwner.sp_cost:setVisible(true)
		self._ccbOwner.tf_cost:setString(itemInfo.price)
		if itemInfo.price > remote.user.money then
			self._ccbOwner.tf_cost:setColor(GAME_COLOR_LIGHT.warning)
		else
			self._ccbOwner.tf_cost:setColor(GAME_COLOR_LIGHT.stress)
		end

		local itemProp = db:getGemstoneBreakThroughByLevel(gemstone.itemId, 0) or {}
		totalprop = itemProp
	else
		local icon = QUIWidgetGemstonesBox.new()
		icon:setGemstoneInfo(gemstone)
		self._ccbOwner.node_icon:addChild(icon)
		self._ccbOwner.buttonText:setString("装 备")

	    local level, color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 

    	local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
    	local mixLevel = gemstone.mix_level or 0

    	name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)


	    if level > 0 then
	    	name = name .. "＋".. level
	    end

	    local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
		self._ccbOwner.tf_name:setColor(fontColor)
		self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
		self._ccbOwner.tf_type:setColor(fontColor)
		self._ccbOwner.tf_type = setShadowByFontColor(self._ccbOwner.tf_type, fontColor)


		if mixLevel > 0 then
			self._ccbOwner.tf_type:setString("")
		else
			local desc = string.format("【%s】", remote.gemstone:getTypeDesc(itemConfig.gemstone_type))
			self._ccbOwner.tf_type:setString(desc)
		end
		if gemstone.mix_level and gemstone.mix_level > 0 then
			self._ccbOwner.btn_info:setVisible(true)
		else
			self._ccbOwner.btn_info:setVisible(false)
		end
		totalprop = gemstone.prop
		local mixConfig = db:getGemstoneMixConfigByIdAndLv(gemstone.itemId , gemstone.mix_level or 0) or {}
		local refineConfig = db:getRefineConfigByIdAndLevel(gemstone.itemId , gemstone.refine_level or 0) or {}
		totalprop = self:addProp(mixConfig, totalprop)
		totalprop = self:addProp(refineConfig, totalprop)
		local goldLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
		local skillsProp = remote.gemstone:getGemstoneEvolutionSkillProp(gemstone.itemId,goldLevel)
		if not q.isEmpty(skillsProp) then
			totalprop = self:addProp(skillsProp, totalprop)
		end
	end
	self._ccbOwner.tf_name:setString(name)

	for i=1,4 do
		self._ccbOwner["tf_prop"..i]:setVisible(false)
	end
	self._index = 1



	self._propDesc = remote.gemstone:setPropInfo(totalprop,true,true)
	for i,v in ipairs(self._propDesc or {}) do
		if i > 4 then
			break
		end
		self._ccbOwner["tf_prop"..i]:setString(v.name..":"..v.value)
		self._ccbOwner["tf_prop"..i]:setVisible(true)
	end

	-- if gemstone.prop ~= nil then
	-- 	self:setProp(gemstone.prop.attack_value, "攻击＋%d")
	-- 	self:setProp(gemstone.prop.hp_value, "生命＋%d")
	-- 	self:setProp(gemstone.prop.armor_physical, "物防＋%d")
	-- 	self:setProp(gemstone.prop.armor_magic, "法防＋%d")
	-- end
	if gemstone.position ~= nil and gemstone.position > 0 then
		local charactConfig = db:getCharacterByID(gemstone.actorId)
		local desc = ""
		if charactConfig ~= nil and charactConfig.name ~= nil then
			desc = charactConfig.name.."装备中"
		end
		self._ccbOwner.tf_desc:setString(desc)
		-- self._ccbOwner.node_btn:retain()
		-- self._ccbOwner.node_btn:removeFromParent()
		-- self._ccbOwner.node_wear:addChild(self._ccbOwner.node_btn)
		self:showBtnState(self._ccbOwner.node_wear)
	else
		self._ccbOwner.tf_desc:setString("")
		-- self._ccbOwner.node_btn:retain()
		-- self._ccbOwner.node_btn:removeFromParent()
		-- self._ccbOwner.node_nowear:addChild(self._ccbOwner.node_btn)
		self:showBtnState(self._ccbOwner.node_nowear)
	end

	if buttonText and buttonText ~= "" then
		self._ccbOwner.buttonText:setString(buttonText)
	end
end

function QUIWidgetGemstoneFastBagItem:showBtnState(parentNode)
	if parentNode == nil then return end
	self._ccbOwner.node_btn:retain()
	self._ccbOwner.node_btn:removeFromParent()
	parentNode:addChild(self._ccbOwner.node_btn)
	self._ccbOwner.node_btn:release()
end

function QUIWidgetGemstoneFastBagItem:addProp(prop1, prop2)
	local propInfo = {}
	for name,filed in pairs(QActorProp._field) do
		if prop1[name] ~= nil or prop2[name] ~= nil then
			local num = (prop1[name] or 0) + (prop2[name] or 0)
			if num  > 0 then
				if propInfo[name] == nil then
					propInfo[name] = num
				else
					propInfo[name] = propInfo[name] +num
				end
			end

		end
	end
	return propInfo
end 

function QUIWidgetGemstoneFastBagItem:setSuitInfo(suitDesc)
	self._ccbOwner.tf_desc:setString(suitDesc)
end

function QUIWidgetGemstoneFastBagItem:setDuplicateVisible(b)
	self._ccbOwner.sp_duplicate:setVisible(b)
	if b then
		-- self._ccbOwner.node_btn:retain()
		-- self._ccbOwner.node_btn:removeFromParent()
		-- self._ccbOwner.node_wear:addChild(self._ccbOwner.node_btn)
		self:showBtnState(self._ccbOwner.node_wear)
	end
end

function QUIWidgetGemstoneFastBagItem:setSuitVisible(b)
	self._ccbOwner.tf_active_suit:setVisible(b)
	if b then
		-- self._ccbOwner.node_btn:retain()
		-- self._ccbOwner.node_btn:removeFromParent()
		-- self._ccbOwner.node_wear:addChild(self._ccbOwner.node_btn)
		self:showBtnState(self._ccbOwner.node_wear)
	end
end

function QUIWidgetGemstoneFastBagItem:setTuijianVisible(b)
	self._ccbOwner.sp_tuijian:setVisible(b)
end

function QUIWidgetGemstoneFastBagItem:_onTriggerInfo()
	app.sound:playSound("common_small")
	if q.isEmpty(self._propDesc) then
		return
	end
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparAttrInfo"
  		,options = {propDesc = self._propDesc , subtitle = "属性详情"}}, {isPopCurrentDialog = false})
end

function QUIWidgetGemstoneFastBagItem:setProp(prop,value)
	if prop ~= nil and prop > 0 then
		self._ccbOwner["tf_prop"..self._index]:setString(string.format(value, prop))
		self._ccbOwner["tf_prop"..self._index]:setVisible(true)
		self._index = self._index + 1
	end
end

function QUIWidgetGemstoneFastBagItem:_onTriggerWear(e)
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	if self._callback then
		self._callback(self._gemstone)
	end
end

return QUIWidgetGemstoneFastBagItem