local HeroSoulChartItem = class("HeroSoulChartItem", function()
	return CCSItemCellBase:create("ui_layout/herosoul_ChartItem.json")
end)

require("app.cfg.ksoul_group_info")
local EffectNode = require("app.common.effects.EffectNode")
local AttributesConst = require("app.const.AttributesConst")
local HeroSoulConst = require("app.const.HeroSoulConst")
local HeroSoulIconItem = require("app.scenes.herosoul.HeroSoulIconItem")
local HeroSoulInfoLayer = require("app.scenes.herosoul.HeroSoulInfoLayer")

-- 1~5个将灵图标时，分别的间距
local SOUL_ICON_GAPS = {0, 155, 140, 125, 110}

function HeroSoulChartItem:ctor(fnBegin, fnEnd)
	self._iconList = {}

	-- 激活后效果相关
	self._fnBegin = fnBegin
	self._fnEnd = fnEnd
	self._tEffect = nil

	-- 创建图标控件
	self:_createIcons()

	self:enableLabelStroke("Label_ChartTitle", Colors.strokeBrown, 1)
	self:registerBtnClickEvent("Button_Activate", handler(self, self._onClickActivate))
end

function HeroSoulChartItem:update(chartId)
	self._chartId = chartId
	local chartInfo = ksoul_group_info.get(chartId)

	-- 阵图名
	local chartIndex = G_Me.heroSoulData:getChartIndexById(chartId)
	local chartNo 	 = G_lang:get("LANG_HERO_SOUL_CHART_GROUP", {num = chartIndex})
	local chartName  = chartInfo.group_name
--	self:showTextWithLabel("Label_ChartTitle", chartNo .. " " .. chartName)
	self:showTextWithLabel("Label_ChartTitle", ""..chartName)

	local isActivated = G_Me.heroSoulData:isChartActivated(chartId)
	local canActivate = G_Me.heroSoulData:canActivateChart(chartId)

	-- 将灵图标
	self:_updateIcons(chartInfo)

	-- 阵图属性
	self:_updateAttrs(chartInfo)

	-- 激活状态
	self:_updateActivateState(chartId)

	-- 按钮特效
	self:_updateBtnEffect(self:getButtonByName("Button_Activate"), not isActivated and canActivate)
end

-- 创建将灵图标
function HeroSoulChartItem:_createIcons()
	local parent = self:getPanelByName("Panel_Icons")
	for i = 1, HeroSoulConst.MAX_SOUL_PER_CHART do
		local item = HeroSoulIconItem.new()
		item:setVisible(false)
		parent:addChild(item)

		self._iconList[#self._iconList + 1] = item
	end
end

-- 刷新将灵图标
function HeroSoulChartItem:_updateIcons(chartInfo)
	local isActivated = G_Me.heroSoulData:isChartActivated(self._chartId)

	-- 该阵图所需要的将灵Id
	local soulIds = {}
	for i = 1, HeroSoulConst.MAX_SOUL_PER_CHART do
		local soulId = chartInfo["ksoul_id" .. i]
		if soulId > 0 then
			soulIds[#soulIds + 1] = soulId
		end
	end

	-- 设置将灵图标
	local soulNum = #soulIds
	local unitGap  = SOUL_ICON_GAPS[soulNum]
	local totalGap = unitGap * (soulNum - 1)
	local leftX = -totalGap / 2
	for i = 1, soulNum do
		-- create soul item
		local soulId = soulIds[i]
		local hasSoul = G_Me.heroSoulData:getSoulNum(soulId) > 0
		local item = self._iconList[i]
		item:setVisible(true)
		item:update(soulId, isActivated or hasSoul, true)

		-- set position
		item:setPositionX(leftX + unitGap * (i - 1))

		-- set click callback
		item:setClickFunc(self, function()
			HeroSoulInfoLayer.show(soulId)
		end)
	end

	-- 没用到的图标隐藏
	for i = soulNum + 1, HeroSoulConst.MAX_SOUL_PER_CHART do
		self._iconList[i]:setVisible(false)
	end
end

-- 刷新阵图属性
function HeroSoulChartItem:_updateAttrs(chartInfo)
	for i = 1, HeroSoulConst.MAX_ATTR_PER_CHART do
		local attrLabel = self:getLabelByName("Label_Attr_" .. i)
		local attrValueLabel = self:getLabelByName("Label_AttrValue_" .. i)
		local attrType = chartInfo["attribute_type" .. i]

		-- show or hide the labels
		attrLabel:setVisible(attrType > 0)
		attrValueLabel:setVisible(attrType > 0)

		-- set attributes
		if attrType > 0 then
			local prefix = (attrType >= AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_ATK_UP_TO_WEI and
		                	attrType <= AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_DEF_UP_TO_QUN)
					   		and G_lang:get("LANG_KNIGHT") or G_lang:get("LANG_HERO_SOUL_ALL_MEMBERS")
			local attrNameStr 	= prefix .. G_lang.getGrowthTypeName(attrType)
			local attrValue 	= chartInfo["attribute_value" .. i]
			local attrValueStr 	= G_lang.getGrowthValue(attrType, attrValue)

			attrLabel:setText(attrNameStr)
			attrValueLabel:setText("+" .. attrValueStr)
		end
	end
end

-- 刷新激活状态
function HeroSoulChartItem:_updateActivateState(chartId)
	local activateBtn = self:getButtonByName("Button_Activate")
	local activateTag = self:getImageViewByName("Image_Activated")

	-- 是否已激活
	local isActivated = G_Me.heroSoulData:isChartActivated(chartId)
	activateBtn:setVisible(not isActivated)
	activateTag:setVisible(isActivated)

	-- 若未激活， 是否可激活
	if not isActivated then
		local canActivate = G_Me.heroSoulData:canActivateChart(chartId)
		activateBtn:setTouchEnabled(canActivate)
		self:getImageViewByName("Image_Activate"):showAsGray(not canActivate)
	end
end

function HeroSoulChartItem:_updateBtnEffect(tParent, bNeeded)
	assert(tParent)
	if bNeeded then
		if not self._tEffect then
			self._tEffect = EffectNode.new("effect_around2") 
			tParent:addNode(self._tEffect)
			self._tEffect:play()
			self._tEffect:setScale(1.4)
		end
		self._tEffect:setVisible(true)
	else
		if self._tEffect then
			self._tEffect:setVisible(false)
		end
	end
end

function HeroSoulChartItem:_onClickActivate()
	if G_Me.heroSoulData:getOnActivating() then
		return
	end

	G_HandlersManager.heroSoulHandler:sendActivateChart(self._chartId)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_ACTIVATE_CHART, self._onRcvActivateChart, self)
end

function HeroSoulChartItem:_onRcvActivateChart(tData)
	if tData.ret == NetMsg_ERROR.RET_OK then
		local chartId = tData.id
		if self._chartId == chartId then
			if self._fnBegin then
				self._fnBegin(self._chartId)
			end

			self:_updateActivateState(chartId)
			local imgActivated = self:getImageViewByName("Image_Activated")
			imgActivated:setScale(5.0)
		    local scaleAction1 = CCScaleTo:create(0.3,1)
		    local actBackOut = CCEaseBackOut:create(scaleAction1)
		    local actDelayTime = CCDelayTime:create(0.2)
		    local actCallback = CCCallFunc:create(function()
		    	if self._fnEnd then
	                self:_fnEnd(self._chartId)
		    	end
		    end)	

		    local tArray = CCArray:create()
		    tArray:addObject(actBackOut)
		    tArray:addObject(actDelayTime)
		    tArray:addObject(actCallback)

		    imgActivated:runAction(CCSequence:create(tArray))	
		end
	end
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_HERO_SOUL_ACTIVATE_CHART)
end

return HeroSoulChartItem