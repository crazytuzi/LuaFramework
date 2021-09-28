require("app.cfg.knight_transform_info")
local MoShenConst = require("app.const.MoShenConst")
local KnightTransformTargetItem = require("app.scenes.knighttransform.KnightTransformTargetItem")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local KnightTransformTargetLayer = class("KnightTransformTargetLayer", UFCCSModelLayer)

function KnightTransformTargetLayer.create(nSourceKnightId, ...)
	return KnightTransformTargetLayer.new("ui_layout/KnightTransform_TargetLayer.json", nil, nSourceKnightId, ...)
end

function KnightTransformTargetLayer:ctor(json, param, nSourceKnightId, ...)
	self.super.ctor(self, json, param, ...)

	self._nSourceKnightId = nSourceKnightId
	local nSourceKnightBaseId = G_Me.bagData.knightsData:getBaseIdByKnightId(self._nSourceKnightId)
	local tSourceKnightTmpl = knight_info.get(nSourceKnightBaseId)
	local nSourceKnightGroup = tSourceKnightTmpl.group
	self.nSourceKnightAdvanceCode = tSourceKnightTmpl.advance_code

	self._nCurGroup = nSourceKnightGroup or MoShenConst.GROUP.WEI 
	self._nSourceGroup = self._nCurGroup
	self._tListViewList = {}
	self._tKnightList = {}

	self:adapterWithScreen()
	self:adapterWidgetHeight("Panel_Wei", "Panel_181", "", 0, 0)
	self:adapterWidgetHeight("Panel_Shu", "Panel_181", "", 0, 0)
	self:adapterWidgetHeight("Panel_Wu", "Panel_181", "", 0, 0)
	self:adapterWidgetHeight("Panel_Qun", "Panel_181", "", 0, 0)

	self:adapterWidgetHeight("Panel_Wei_list", "Panel_181", "", 20, 30)
	self:adapterWidgetHeight("Panel_Shu_list", "Panel_181", "", 20, 30)
	self:adapterWidgetHeight("Panel_Wu_list", "Panel_181", "", 20, 30)
	self:adapterWidgetHeight("Panel_Qun_list", "Panel_181", "", 20, 30)


end

function KnightTransformTargetLayer:onLayerEnter()
	self:registerKeypadEvent(true)
	self:_initTabs()
--	self:_enabledCheckBox()
	self:_initWidgets()
end

function KnightTransformTargetLayer:onLayerExit()
	
end

function KnightTransformTargetLayer:onBackKeyEvent()
    self:_onClickReturn()
    return true
end

function KnightTransformTargetLayer:_onClickReturn()
	self:close()
end

function KnightTransformTargetLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_1", self:getPanelByName("Panel_Wei"), "Label_Wei") 
    self._tabs:add("CheckBox_2", self:getPanelByName("Panel_Shu"), "Label_Shu") 
    self._tabs:add("CheckBox_3", self:getPanelByName("Panel_Wu"), "Label_Wu") 
    self._tabs:add("CheckBox_4", self:getPanelByName("Panel_Qun"), "Label_Qun") 

    self._tabs:checked("CheckBox_" .. self._nCurGroup)
end

function KnightTransformTargetLayer:_checkedCallBack(szCheckBoxName)
	if szCheckBoxName == "CheckBox_1" then
		self._nCurGroup = MoShenConst.GROUP.WEI
	elseif szCheckBoxName == "CheckBox_2" then
		self._nCurGroup = MoShenConst.GROUP.SHU
	elseif szCheckBoxName == "CheckBox_3" then
		self._nCurGroup = MoShenConst.GROUP.WU
	elseif szCheckBoxName == "CheckBox_4" then
		self._nCurGroup = MoShenConst.GROUP.QUN
	end

	if self._nCurGroup ~= self._nSourceGroup then
		if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CROSS_GROUP_KNIGHT_TRANSFORM) then
			self._nCurGroup = self._nSourceGroup
			self._tabs:checked("CheckBox_" .. self._nCurGroup)
			return
		end
	end

	self:_initListView(self._nCurGroup)
end

function KnightTransformTargetLayer:_uncheckedCallBack()
	
end

function KnightTransformTargetLayer:_enabledCheckBox()
	for i=1, 4 do
		local nGroup = i
		self:getCheckBoxByName("CheckBox_"..nGroup):setTouchEnabled(nGroup == self._nCurGroup)
	end
end

function KnightTransformTargetLayer:_initWidgets()
	self:getLabelByName("Label_SelectTips"):createStroke(Colors.strokeBrown, 2)

	self:registerBtnClickEvent("Button_return", function()
		self:_onClickReturn()
	end)
end

function KnightTransformTargetLayer:_initListView(nGroup)
	nGroup = nGroup or 1
	local szPanelName = {
		"Panel_Wei_list", "Panel_Shu_list", "Panel_Wu_list", "Panel_Qun_list",
	}

	local tList = self._tKnightList[nGroup]
	if not tList then
		tList = {}
		for i=1, knight_transform_info.getLength() do
			local tTransformTmpl = knight_transform_info.indexOf(i)

			-- 升阶码相同，就是同名武将，转了等于没转，所以要排除出去
			if tTransformTmpl and tTransformTmpl.group == self._nCurGroup 
				and tTransformTmpl.advanced_code ~= self.nSourceKnightAdvanceCode 
				and tTransformTmpl.group_id == self:_getSourceKnightGroupId() then
				table.insert(tList, #tList+1, tTransformTmpl)
			end
		end
		self._tKnightList[nGroup] = tList
	end

	local tListView = self._tListViewList[nGroup]
	if not tListView then
		local panel = self:getPanelByName(szPanelName[nGroup])
		if panel then
			tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        
	        tListView:setCreateCellHandler(function(list, index)
	            return KnightTransformTargetItem.new(self._nSourceKnightId, handler(self, self._selectedCallback))
	        end)

	        tListView:setUpdateCellHandler(function(list, index, cell)
	        	local tList = self._tKnightList[self._nCurGroup]
	        	if tList then
	        		local tTransformTmpl = tList[index+1]
	        		if tTransformTmpl then
						cell:updateItem(tTransformTmpl)
					end
	        	end
	        end)

	        tListView:initChildWithDataLength(table.nums(self._tKnightList[self._nCurGroup]), 0.2)
		end

		self._tListViewList[nGroup] = tListView
	end
end

function KnightTransformTargetLayer:_selectedCallback()
	self:removeFromParentAndCleanup(true)
end

function KnightTransformTargetLayer:_getSourceKnightGroupId()
	local nGroupId = 0
	for i=1, knight_transform_info.getLength() do
		local tTransformTmpl = knight_transform_info.indexOf(i)
		if tTransformTmpl and self.nSourceKnightAdvanceCode == tTransformTmpl.advanced_code then
			nGroupId = tTransformTmpl.group_id
		end
	end

	assert(nGroupId ~= 0)

	return nGroupId
end


return KnightTransformTargetLayer