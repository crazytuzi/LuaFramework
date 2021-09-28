local HeroSoulConst = require("app.const.HeroSoulConst")

local MoShenConst = require("app.const.MoShenConst")
local Test500Item = require("app.scenes.herosoul.Test500Item")

local Test500Layer = class("Test500Layer", UFCCSModelLayer)

Test500Layer.REPEAT_COUNT = 100

function Test500Layer.create(nGroup, func, ...)
	return Test500Layer.new("ui_layout/herosoul_ReviewLayer.json", Colors.modelColor, nGroup, func, ...)
end

function Test500Layer:ctor(json, param, nGroup, func, ...)
	self._nCurGroup = MoShenConst.GROUP.WEI
	self._tListViewList = {}
	self._tSummonTmplList = {}

	self._bReady = true
	self._nCount = 0
	self._func = func

	self.super.ctor(self, json, param, ...)
end

function Test500Layer:onLayerLoad()
	self:_initView()
	self:_initWidgets()

	self:_initTabs()
end

function Test500Layer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_EXTRACT_SUCC, self._onTerraceSucc, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")

	if not self._tTimer then
		self._tTimer = G_GlobalFunc.addTimer(0.1, function()
			if not self._bReady then
				return
			end
			if self._nCount >= Test500Layer.REPEAT_COUNT then
				self:_removeTimer()
				self:_analyze()
			end

			self._nCount = self._nCount + 1
			self._bReady = false

			if self:_isGoldEnough(HeroSoulConst.EXTRACT_TYPE.FIVE) then
				G_HandlersManager.heroSoulHandler:sendSummonKsoul(HeroSoulConst.SUMMOM_TYPE.FIVE)
			end
		end)
	end
end

function Test500Layer:_removeTimer()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
end

function Test500Layer:onLayerExit()
	self:_removeTimer()
end

function Test500Layer:onLayerUnload()
	
end

function Test500Layer:_initView()
	
end

function Test500Layer:_initWidgets()
	self:registerBtnClickEvent("Button_close", function()
		if self._func then
			self._func()
		end
	end)
end

function Test500Layer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_1", self:getPanelByName("Panel_weiguo"), "Label_weig_check") 
    self._tabs:add("CheckBox_2", self:getPanelByName("Panel_shuguo"), "Label_sg_check") 
    self._tabs:add("CheckBox_3", self:getPanelByName("Panel_wuguo"), "Label_wug_check") 
    self._tabs:add("CheckBox_4", self:getPanelByName("Panel_qunxiong"), "Label_qx_check") 

    self._tabs:checked("CheckBox_"..1)
end

function Test500Layer:_checkedCallBack(szCheckBoxName)
	self:_initListView(self._nCurGroup)
end

function Test500Layer:_uncheckedCallBack()
	
end

function Test500Layer:_prepareData()

end

function Test500Layer:_initListView(nGroup)
	nGroup = 1
	local szPanelName = {
		"Panel_weiguo_list"
	}

	local tListView = self._tListViewList[nGroup]
	if not tListView then
		local panel = self:getPanelByName(szPanelName[nGroup])
		if panel then
			tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        
	        tListView:setCreateCellHandler(function(list, index)
	            return Test500Item.new()
	        end)

	        tListView:setUpdateCellHandler(function(list, index, cell)
	        	local tTmplList = {}
	        	for i=1, 4 do
	        		table.insert(tTmplList, #tTmplList + 1, self._tSummonTmplList[index * 4 + i])
	        	end
	        	cell:updateItem(tTmplList)
	        end)

	        local len = 0
	        tListView:initChildWithDataLength(len)
		end

		self._tListViewList[nGroup] = tListView
	end
end

function Test500Layer:_onTerraceSucc(tData)
	local function sortFunc(tTmpl1, tTmpl2)
		local tSoulTmpl1 = ksoul_info.get(tTmpl1.id)
		local tSoulTmpl2 = ksoul_info.get(tTmpl2.id)
		if tSoulTmpl1.quality ~= tSoulTmpl2.quality then
			return tSoulTmpl1.quality > tSoulTmpl2.quality
		end
		return tSoulTmpl1.id < tSoulTmpl2.id
	end

	self._bReady = true

	for i, v in ipairs(tData.awards) do
		local tAward = v 
		if tAward.type == G_Goods.TYPE_HERO_SOUL then 
			local tSoulTmpl = ksoul_info.get(tAward.value)
			table.insert(self._tSummonTmplList, #self._tSummonTmplList + 1, tSoulTmpl)
		end
	end

	local nGroup = 1

    local len = 0
    if #self._tSummonTmplList % 4 ~= 0 then
    	len = math.floor(#self._tSummonTmplList / 4) + 1
    else
    	len = #self._tSummonTmplList / 4
    end

    table.sort(self._tSummonTmplList, sortFunc)

	self._tListViewList[nGroup]:reloadWithLength(len)
end

function Test500Layer:_isGoldEnough(nType)
	local isEnough = false
	if nType == HeroSoulConst.EXTRACT_TYPE.ONCE then
		isEnough = G_Me.userData.gold >= HeroSoulConst.ONCE_COST
	elseif nType == HeroSoulConst.EXTRACT_TYPE.FIVE then
		isEnough = G_Me.userData.gold >= HeroSoulConst.FIVE_COST
	end

	return isEnough
end

function Test500Layer:_analyze()
	local nHongCount = 0
	local nChengCount = 0
	local nZiCount = 0

	for i=1, #self._tSummonTmplList do
		local tSoulTmpl = self._tSummonTmplList[i]
		if tSoulTmpl.quality == 6 then
			nHongCount = nHongCount + 1
		elseif tSoulTmpl.quality == 5 then
			nChengCount = nChengCount + 1
		elseif tSoulTmpl.quality == 4 then
			nZiCount = nZiCount + 1
		end
	end

	__Log("-- 红色将灵 = %d个, 橙色将灵 = %d个, 紫色将灵 = %d个", nHongCount, nChengCount, nZiCount)
end

return Test500Layer