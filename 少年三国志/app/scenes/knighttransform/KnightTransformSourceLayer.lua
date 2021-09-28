local KnightTransformSourceItem = require("app.scenes.knighttransform.KnightTransformSourceItem")

local KnightTransformSourceLayer = class("KnightTransformSourceLayer", UFCCSModelLayer)
local KnightConst = require("app.const.KnightConst")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

function KnightTransformSourceLayer.create(...)
	return KnightTransformSourceLayer.new("ui_layout/KnightTransform_SourceLayer.json", nil, ...)
end

function KnightTransformSourceLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)

	self:adapterWithScreen()
	self:adapterWidgetHeight("Panel_list", "Panel_260", "", 0, 30)

	self:_initWidgets()
	
end

function KnightTransformSourceLayer:onLayerEnter()
	self:registerKeypadEvent(true)
	self:_prepareData()
	self:_initListView()
end

function KnightTransformSourceLayer:onLayerExit()
	
end

function KnightTransformSourceLayer:_initWidgets()
	self:getLabelByName("Label_hide"):createStroke(Colors.strokeBrown, 2)

	self:registerBtnClickEvent("Button_return", function()
	--	self:removeFromParentAndCleanup(true)
		self:_onClickReturn()
	end)
end

function KnightTransformSourceLayer:onBackKeyEvent()
    self:_onClickReturn()
    return true
end

function KnightTransformSourceLayer:_onClickReturn()
	self:close()
end

function KnightTransformSourceLayer:checkQuality(tKnightTmpl)
	-- 橙将或者橙升红的红将
	local isQualityValid = tKnightTmpl.diff == KnightConst.KNIGHT_QUALITY_DIFF.BASE_ORANGE
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.RED_KNIGHT_TRANSFORM) then
		isQualityValid = isQualityValid or tKnightTmpl.diff == KnightConst.KNIGHT_QUALITY_DIFF.RED
	end
	return isQualityValid
end

function KnightTransformSourceLayer:_prepareData()
	local tKnightIdList = G_Me.bagData.knightsData:getKnightsIdListCopy()

	if not self._tKnightList then
		self._tKnightList = {}
		for key, val in pairs(tKnightIdList) do
			local nKnightId = val
			local tKnight = G_Me.bagData.knightsData:getKnightByKnightId(nKnightId)
			if tKnight then
				local nBaseId = tKnight["base_id"]
				local tKnightTmpl = knight_info.get(nBaseId)
				
				-- 橙色和橙升红的武将，不是金龙宝宝
				if self:checkQuality(tKnightTmpl) and nBaseId ~= G_GlobalFunc.getGoldDragonId() then
					-- 不是主角
					if nKnightId ~= G_Me.formationData:getMainKnightId() then
						-- 非上阵, 非援军
						if G_Me.formationData:getKnightTeamId(nKnightId) == 0 then
							table.insert(self._tKnightList, #self._tKnightList+1, tKnight)
						--	__Log("--naem = %s, id = %d, base_id = %d", tKnightTmpl.name, tKnight.id, nBaseId)
						end
					end
				end

			end
		end
	end
end

function KnightTransformSourceLayer:_initListView()
	if not self._tListView then
		local panel = self:getPanelByName("Panel_list")
		if panel then
			self._tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        
	        self._tListView:setCreateCellHandler(function(list, index)
	            return KnightTransformSourceItem.new(handler(self, self._onSelectedCallback))
	        end)

	        self._tListView:setUpdateCellHandler(function(list, index, cell)
	            local tKnight = self._tKnightList[index + 1]
	            cell:updateItem(tKnight)
	        end)

	        self._tListView:initChildWithDataLength(table.nums(self._tKnightList), 0.2)
		end
	end
end

-- 完成选择一个武将
function KnightTransformSourceLayer:_onSelectedCallback()
	self:removeFromParentAndCleanup(true)
end

function KnightTransformSourceLayer:_reloadListView()
	
end

return KnightTransformSourceLayer