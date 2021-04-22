local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneMix = class("QUIWidgetHeroGemstoneMix", QUIWidget)
local QUIWidgetHeroGemstoneMixInfo = import("..widgets.QUIWidgetHeroGemstoneMixInfo")
local QScrollContain = import("....ui.QScrollContain")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")

local QQuickWay = import("...utils.QQuickWay")


function QUIWidgetHeroGemstoneMix:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_mix.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
	}
	QUIWidgetHeroGemstoneMix.super.ctor(self,ccbFile,callBacks,options)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_reset)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.materials = {}
	if options.callback then
		self._callback = options.callback
	end
	self._costItemBox = nil
	self._ccbOwner.node_btn_rest:setVisible(false)
	self._costItemid = db:getConfigurationValue("GEMSTONE_MIX_ITEM") or 601007
end

function QUIWidgetHeroGemstoneMix:onEnter()
	QUIWidgetHeroGemstoneMix.super.onEnter(self)
	self:initScrollView()
end

function QUIWidgetHeroGemstoneMix:onExit()
	QUIWidgetHeroGemstoneMix.super.onExit(self)
    if self._scrollContain ~= nil then
        self._scrollContain:disappear()
        self._scrollContain = nil
    end

	self._actorId = nil
	self._gemstoneSid = nil
	self._gemstonePos = nil
	self._isAction = false
end


function QUIWidgetHeroGemstoneMix:initScrollView()
    self._scrollContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY , endRate = 0.1})
    self._contentNode = QUIWidgetHeroGemstoneMixInfo.new()
    self._scrollContain:addChild(self._contentNode)

end

function QUIWidgetHeroGemstoneMix:updateInfo()
	if self._actorId and self._gemstoneSid and self._gemstonePos  then
		self:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos)
	end
end

function QUIWidgetHeroGemstoneMix:setInfo(actorId, gemstoneSid, gemstonePos)

	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos

	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._gemstone = gemstone
	local itemId = gemstone.itemId
	local mixLevel = gemstone.mix_level or 0
	local itemConfig = db:getItemByID(itemId)
    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
    local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local curMixConfig,nextMixConfig = remote.gemstone:getGemstoneMixConfigAndNextByIdAndLv(itemId,mixLevel)
	--名称
    local name = itemConfig.name
    name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)
    if level > 0 then
    	name = name .. "＋".. level
    end
    local typeStr = ""
    if mixLevel <= 0 then
    	typeStr = " 【"..remote.gemstone:getTypeDesc(itemConfig.gemstone_type).."】"
    end
	self._ccbOwner.tf_item_name:setString("LV."..gemstone.level.."  "..name..typeStr)
	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)

	if not self._contentNode then
		self:initScrollView()
	end
	self._contentNode:setDetailInfo(actorId, gemstoneSid, gemstonePos)
    local size = self._contentNode:getContentSize()
    self._scrollContain:setContentSize(size.width, size.height)
	self._ccbOwner.sp_max:setVisible(false)

	if nextMixConfig == nil then
		--max
		self._ccbOwner.node_moneyCost:setVisible(false)
		self._ccbOwner.node_itemCost:setVisible(false)
		self._ccbOwner.node_btn_ok:setVisible(false)
		self._ccbOwner.sp_max:setVisible(true)
		return
	end


	if curMixConfig == nil then
		-- self._ccbOwner.node_btn_rest:setVisible(false)
		self._ccbOwner.tf_button_name:setString("品质突破")

	else
		-- self._ccbOwner.node_btn_rest:setVisible(true)
		self._ccbOwner.tf_button_name:setString("融合")
	end
	self._costMoneyNum = nextMixConfig.cost_money
	self._costItemNum = nextMixConfig.cost_num
	self:updateCostInfo()
	self._ccbOwner.node_btn_ok:setVisible(true)

end

function QUIWidgetHeroGemstoneMix:updateCostInfo()
	self._ccbOwner.node_moneyCost:setVisible(true)
	self._ccbOwner.node_itemCost:setVisible(true)

	local haveNum = remote.items:getItemsNumByID(self._costItemid)
	self._ccbOwner.tf_money:setString(self._costMoneyNum)
	
	if remote.user.money >= self._costMoneyNum  then
		self._ccbOwner.tf_money:setColor(COLORS.k)
	else
		self._ccbOwner.tf_money:setColor(COLORS.m)
	end

	self._ccbOwner.tf_progress:setString(haveNum.."/"..self._costItemNum)
	self._ccbOwner.sp_progress:setScaleX(math.min(haveNum / self._costItemNum, 1))

	if self._costItemBox == nil then
		self._costItemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(self._costItemBox)
		self._costItemBox:setGoodsInfo(self._costItemid, ITEM_TYPE.ITEM)
		self._costItemBox:hideSabc()
	end
end

function QUIWidgetHeroGemstoneMix:_onTriggerOk(e)
	app.sound:playSound("common_small")
	if self._callback and self._callback() then return end
	-- if true then
	-- 	remote.gemstone:dispatchEvent({name = remote.gemstone.EVENT_MIX_SUCCESS, gemstone = self._gemstone })
	-- 	return
	-- end
	if self._costMoneyNum > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end

	local haveNum = remote.items:getItemsNumByID(self._costItemid)
	if self._costItemNum > haveNum then
		local needCount = self._costItemNum - haveNum
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._costItemid, needCount)
		return
	end


	remote.gemstone:gemstoneMixRequest(self._costItemNum , self._gemstoneSid, function (data)
			if self:safeCheck() then
				remote.gemstone:dispatchEvent({name = remote.gemstone.EVENT_MIX_SUCCESS, gemstone = self._gemstone })
			end
		end)

end

function QUIWidgetHeroGemstoneMix:_onTriggerPlus(e)
	
	if self._callback and self._callback() then return end

	local dropType = QQuickWay.ITEM_DROP_WAY
	QQuickWay:addQuickWay(dropType,self._costItemid, nil, nil, false)
end

function QUIWidgetHeroGemstoneMix:_onTriggerReset(e)
	app.sound:playSound("common_small")
	if self._callback and self._callback() then return end
	local costNum = db:getConfigurationValue("GEMSTONE_MIX_RETURN") or 50
	if costNum > remote.user.token then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return
	end
end


return QUIWidgetHeroGemstoneMix