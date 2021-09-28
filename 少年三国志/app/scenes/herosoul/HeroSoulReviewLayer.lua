local MoShenConst = require("app.const.MoShenConst")
local HeroSoulReviewItem = require("app.scenes.herosoul.HeroSoulReviewItem")

local HeroSoulReviewLayer = class("HeroSoulReviewLayer", UFCCSModelLayer)

function HeroSoulReviewLayer.create(nGroup, ...)
	return HeroSoulReviewLayer.new("ui_layout/herosoul_ReviewLayer.json", Colors.modelColor, nGroup, ...)
end

function HeroSoulReviewLayer:ctor(json, param, nGroup, ...)
	self._nCurGroup = nGroup or MoShenConst.GROUP.WEI
	self._tListViewList = {}
	self._tSummonTmplList = {}
	self._isDataReady = false

	self.super.ctor(self, json, param, ...)
end

function HeroSoulReviewLayer:onLayerLoad()
	self:_initView()
	self:_initWidgets()
end

function HeroSoulReviewLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	self:_initTabs()

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function HeroSoulReviewLayer:onLayerExit()
	
end

function HeroSoulReviewLayer:onLayerUnload()
	
end

function HeroSoulReviewLayer:_initView()
	
end

function HeroSoulReviewLayer:_initWidgets()
	self:registerBtnClickEvent("Button_close", function()
		self:animationToClose()
	end)
end

function HeroSoulReviewLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_1", self:getPanelByName("Panel_weiguo"), "Label_weig_check") 
    self._tabs:add("CheckBox_2", self:getPanelByName("Panel_shuguo"), "Label_sg_check") 
    self._tabs:add("CheckBox_3", self:getPanelByName("Panel_wuguo"), "Label_wug_check") 
    self._tabs:add("CheckBox_4", self:getPanelByName("Panel_qunxiong"), "Label_qx_check") 

    self._tabs:checked("CheckBox_"..self._nCurGroup)
end

function HeroSoulReviewLayer:_checkedCallBack(szCheckBoxName)
	for i=1, 4 do
		if szCheckBoxName == "CheckBox_"..i then
			self._nCurGroup = i
		end
	end
	self:_prepareData()
	self:_initListView(self._nCurGroup)
end

function HeroSoulReviewLayer:_uncheckedCallBack()
	
end

function HeroSoulReviewLayer:_prepareData()
	if self._isDataReady then
		return
	end
	self._isDataReady = true

	for i=1, ksoul_summon_info.getLength() do
		local tSommonTmpl = ksoul_summon_info.indexOf(i)
		local tSoulTmpl = ksoul_info.get(tSommonTmpl.ksoul_id)
		for k=1, 4 do
			if not self._tSummonTmplList[k] then
				self._tSummonTmplList[k] = {}
			end
			if tSoulTmpl.ksoul_camp == k then
				table.insert(self._tSummonTmplList[k], #self._tSummonTmplList[k] + 1, tSommonTmpl)
			end
		end
	end

	local function sortFunc(tTmpl1, tTmpl2)
		local tSoulTmpl1 = ksoul_info.get(tTmpl1.ksoul_id)
		local tSoulTmpl2 = ksoul_info.get(tTmpl2.ksoul_id)
		if tSoulTmpl1.quality ~= tSoulTmpl2.quality then
			return tSoulTmpl1.quality > tSoulTmpl2.quality
		end
		return tSoulTmpl1.id < tSoulTmpl2.id
	end

	for i=1, 4 do
		table.sort(self._tSummonTmplList[i], sortFunc)
	end
end

function HeroSoulReviewLayer:_initListView(nGroup)
	nGroup = nGroup or 1
	local szPanelName = {
		"Panel_weiguo_list", "Panel_shuguo_list", "Panel_wuguo_list", "Panel_qunxiong_list",
	}

	local tListView = self._tListViewList[nGroup]
	if not tListView then
		local panel = self:getPanelByName(szPanelName[nGroup])
		if panel then
			tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        
	        tListView:setCreateCellHandler(function(list, index)
	            return HeroSoulReviewItem.new()
	        end)

	        tListView:setUpdateCellHandler(function(list, index, cell)
	        	local tTmplList = {}
	        	for i=1, 4 do
	        		table.insert(tTmplList, #tTmplList + 1, self._tSummonTmplList[nGroup][index * 4 + i])
	        	end
	        	cell:updateItem(tTmplList)
	        end)

	        local len = 0
	        if #self._tSummonTmplList[nGroup] % 4 ~= 0 then
	        	len = math.floor(#self._tSummonTmplList[nGroup] / 4) + 1
	        else
	        	len = #self._tSummonTmplList[nGroup] / 4
	        end
	        tListView:initChildWithDataLength(len)
		end

		self._tListViewList[nGroup] = tListView
	end
end



return HeroSoulReviewLayer