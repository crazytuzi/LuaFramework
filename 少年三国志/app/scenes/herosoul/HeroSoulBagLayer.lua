local HeroSoulBagLayer = class("HeroSoulBagLayer", UFCCSNormalLayer)

require("app.cfg.ksoul_info")
local BagConst = require("app.const.BagConst")
local HeroSoulBagItem = require("app.scenes.herosoul.HeroSoulBagItem")
local HeroSoulBatchDecompose = require("app.scenes.herosoul.HeroSoulBatchDecompose")

function HeroSoulBagLayer.create()
	return HeroSoulBagLayer.new("ui_layout/herosoul_BagLayer.json", nil)
end

function HeroSoulBagLayer:ctor(jsonFile, fun)
	self._soulIds  		= nil	-- 排过序的将灵ID
	self._needlessIds	= nil	-- 建议分解的将灵ID数组
	self._needlessIdMap	= nil 	-- 建议分解的将灵ID - true 映射表
	self._listView 		= nil
	self._soulPoint		= G_Me.userData.hero_soul_point -- 当前的灵玉数

	self:_prepareData()
	self.super.ctor(self, jsonFile, fun)
end

function HeroSoulBagLayer:onLayerLoad()
	self:showTextWithLabel("Label_SoulPoint_Num", tostring(self._soulPoint))

	-- label strokes
	self:enableLabelStroke("Label_SoulPoint", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SoulPoint_Num", Colors.strokeBrown, 1)

	-- register button click events
	self:registerBtnClickEvent("Button_BatchDecompose", handler(self, self._onClickBatch))
	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickBack))
end

function HeroSoulBagLayer:onLayerEnter()
    -- add event listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_DECOMPOSE, self._onRcvDecompose, self)
end

function HeroSoulBagLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function HeroSoulBagLayer:adapterLayer()
	self:adapterWidgetHeight("Panel_ListView", "Panel_Top", "Panel_Bottom", 0, 0)
    self:adapterWidgetHeight("Panel_Content", "Panel_Top", "Panel_Bottom", -20, -100)

    self:_initListView()
    if #self._soulIds == 0 then
    	self:_hasNoSoul()
    end
end

function HeroSoulBagLayer:_prepareData()
	self._soulIds = {}
	self._needlessIds = {}
	self._needlessIdMap = {}
	local soulList = G_Me.heroSoulData:getSoulList()

	-- save the ids to the array
	for k, v in pairs(soulList) do
		self._soulIds[#self._soulIds + 1] = k

		if G_Me.heroSoulData:isActivatedAllCharts(k) then
			self._needlessIdMap[k] = true
		end
	end

	-- sort
	local sortFunc = function(a, b)
		-- 建议分解的排前面
		local notNeedA = self._needlessIdMap[a] or false
		local notNeedB = self._needlessIdMap[b] or false
		if notNeedA ~= notNeedB then
			return notNeedA
		end

		-- 品质高的排前面
		local qualityA = ksoul_info.get(a).quality
		local qualityB = ksoul_info.get(b).quality
		if qualityA ~= qualityB then
			return qualityA > qualityB
		end

		-- 数量多的排前面
		if soulList[a] ~= soulList[b] then
			return soulList[a] > soulList[b]
		end

		-- 默认按照id排序
		return a < b
	end

	table.sort(self._soulIds, sortFunc)

	-- needless array
	for i, v in ipairs(self._soulIds) do
		if self._needlessIdMap[v] and ksoul_info.get(v).quality < BagConst.QUALITY_TYPE.RED then
			self._needlessIds[#self._needlessIds + 1] = {id = v, num = G_Me.heroSoulData:getSoulNum(v)}
		end
	end
end

function HeroSoulBagLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")

		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self._listView:setClippingType(1)

		self._listView:setCreateCellHandler(function(list, index)
			return HeroSoulBagItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			local soulId = self._soulIds[index + 1]
			local needless = self._needlessIdMap[soulId] or false
			cell:update(soulId, needless)
		end)
	end

	self._listView:setSpaceBorder(0, 20)
	self._listView:reloadWithLength(#self._soulIds)
end

function HeroSoulBagLayer:_onRcvDecompose(newSoulPoint)
	local getSoulPoint = newSoulPoint - self._soulPoint
	G_MovingTip:showMovingTip(G_lang:get("LANG_HERO_SOUL_DECOMPOSE_SUCCESS", {num = getSoulPoint}))

	-- refresh list
	self:_prepareData()
	self._listView:reloadWithLength(#self._soulIds)

	-- refresh soul point
	self._soulPoint = newSoulPoint
	self:showTextWithLabel("Label_SoulPoint_Num", tostring(newSoulPoint))

	if #self._soulIds == 0 then
		self:_hasNoSoul()
	end
end

function HeroSoulBagLayer:_onClickBatch()
	if #self._needlessIds > 0 then
		HeroSoulBatchDecompose.show(self._needlessIds)
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_HERO_SOUL_DECOMPOSE_NO_SOUL"))
	end
end

function HeroSoulBagLayer:_onClickBack()
	uf_sceneManager:getCurScene():goBack()
end

function HeroSoulBagLayer:_hasNoSoul()
    local rootWidget = self:getPanelByName("Panel_Content")
    if not self._noSoulLayer then
    	self._noSoulLayer = require("app.scenes.common.EmptyLayer").createWithPanel(require("app.const.EmptyLayerConst").HERO_SOUL, rootWidget)
    else
    	self._noSoulLayer:setVisible(true)
    end
end

return HeroSoulBagLayer