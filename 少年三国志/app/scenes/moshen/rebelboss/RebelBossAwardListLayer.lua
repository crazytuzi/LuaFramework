
local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"


local function contains(idList, nId)
	local isContain = false
	for key, val in pairs(idList) do
		local id = val
		if id == nId then
			isContain = true
		end
	end
	return isContain
end

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local MoShenConst = require("app.const.MoShenConst")

local RebelBossAwardListLayer = class("RebelBossAwardListLayer", UFCCSModelLayer)

function RebelBossAwardListLayer.create(...)
	return RebelBossAwardListLayer.new("ui_layout/moshen_RebelBossAwardListLayer.json", Colors.modelColor, ...)
end

function RebelBossAwardListLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)
    -- 荣誉奖励
	self._tHonorAwardListView = nil
	-- Boss等级奖励
	self._tBossLevelAwardListView = nil 
	-- 军团奖励
	self._tLegionAwardListView = nil

	-- 3种奖励的模板表
	self._tHonorTmplList = nil
	self._tBossLevelTmplList = nil
	self._tLegionTmplList = nil

	self._nCurMode = MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR

    self:_initTabs()
	self:_initWidgets()

	self:_initHonorAwardListView()
	self:_initBossLevelAwardListView()
	self:_initLegionAwardListView()
end

function RebelBossAwardListLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- 进入界面
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_CLAIMED_AWARD_LIST, self._reloadRankList, self)
	-- 领奖成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_CLIAM_AWARD_SUCC, self._onCliamAwardSucc, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
	-- 拉取协议
	G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(self._nCurMode)

	for i=1, 3 do
		-- 红点
		local nMode = i
		if G_Me.moshenData:hasRebelBossAward(nMode) then
			self:showWidgetByName("Image_Tip"..nMode, true)
		else
			self:showWidgetByName("Image_Tip"..nMode, false)
		end
	end

	
end

function RebelBossAwardListLayer:onLayerExit()

end

function RebelBossAwardListLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))
    self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onCloseWindow))

    CommonFunc._updateLabel(self, "Label_LegionClaimTip", {text=""})
end

function RebelBossAwardListLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(2, self, self._onTabChecked, self._onTabUnchecked)
	self._tabs:add("CheckBox_Honor", self:getPanelByName("Panel_Honor"), "Label_Honor")
	self._tabs:add("CheckBox_BossLevel", self:getPanelByName("Panel_BossLevel"), "Label_BossLevel")
	self._tabs:add("CheckBox_Legion", self:getPanelByName("Panel_Legion"), "Label_Legion")

	-- check the "rank" tab in default
	self._tabs:checked("CheckBox_Honor")
end

-- 荣誉奖励列表
function RebelBossAwardListLayer:_initHonorAwardListView()
	self:_initHonorAwardData()

	if not self._tHonorAwardListView then
		local panel = self:getPanelByName("Panel_ListView_Honor")
		self._tHonorAwardListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._tHonorAwardListView:setCreateCellHandler(function(list, index)
			local AwardItem = require("app.scenes.moshen.rebelboss.RebelBossAwardItem")
			return AwardItem.new(MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR)
		end)

		self._tHonorAwardListView:setUpdateCellHandler(function(list, index, cell)
			local tTmpl = self._tHonorTmplList[index + 1]
			cell:updateItem(tTmpl)
		end)
	end

	self._tHonorAwardListView:reloadWithLength(table.nums(self._tHonorTmplList))
end

-- Boss等级奖励列表
function RebelBossAwardListLayer:_initBossLevelAwardListView()
	self:_initBossLevelAwardData()

	if not self._tBossLevelAwardListView then
		local panel = self:getPanelByName("Panel_ListView_BossLevel")
		self._tBossLevelAwardListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._tBossLevelAwardListView:setCreateCellHandler(function(list, index)
			local AwardItem = require("app.scenes.moshen.rebelboss.RebelBossAwardItem")
			return AwardItem.new(MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL)
		end)

		self._tBossLevelAwardListView:setUpdateCellHandler(function(list, index, cell)
			local tTmpl = self._tBossLevelTmplList[index + 1]
			cell:updateItem(tTmpl)
		end)
	end

	self._tBossLevelAwardListView:reloadWithLength(table.nums(self._tBossLevelTmplList))
end

-- 军团奖励列表
function RebelBossAwardListLayer:_initLegionAwardListView()
	if not self._tLegionAwardListView then
		local panel = self:getPanelByName("Panel_ListView_Legion")
		self._tLegionAwardListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._tLegionAwardListView:setCreateCellHandler(function(list, index)
			local LegionAwardItem = require("app.scenes.moshen.rebelboss.RebelBossAwardItem")
			return LegionAwardItem.new(MoShenConst.REBEL_BOSS_AWARD_MODE.LEGION)
		end)

		self._tLegionAwardListView:setUpdateCellHandler(function(list, index, cell)
			local tTmpl = rebel_boss_corps_info.get(index + 1)
			assert(tTmpl)
			cell:updateItem(tTmpl)
		end)
	end

	self._tLegionAwardListView:reloadWithLength(rebel_boss_corps_info.getLength())
end


function RebelBossAwardListLayer:_onCloseWindow()
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_SHOW_AWARD_TIPS, nil, false, nil)
	self:animationToClose()
end

function RebelBossAwardListLayer:_onTabChecked(szCheckBoxName)
	if szCheckBoxName == "CheckBox_Honor" then
		self._nCurMode = MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR
		self:_switchPage(self._nCurMode)
	elseif szCheckBoxName == "CheckBox_BossLevel" then
		self._nCurMode = MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL
		self:_switchPage(self._nCurMode)
	elseif szCheckBoxName == "CheckBox_Legion" then
		self._nCurMode = MoShenConst.REBEL_BOSS_AWARD_MODE.LEGION
		self:_switchPage(self._nCurMode)
	end
end

function RebelBossAwardListLayer:_switchPage(nMode)
	if self._nCurMode == MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR then
		self:_initHonorAwardListView()
		G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(self._nCurMode)
	elseif self._nCurMode == MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL then
		self:_initBossLevelAwardListView()
		G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(self._nCurMode)
	else
		G_HandlersManager.moshenHandler:sendRebelBossCorpAwardInfo()
	end
end

function RebelBossAwardListLayer:_onTabUnchecked()
	
end

function RebelBossAwardListLayer:_initHonorAwardData()
	local function sortFunc(tTmpl1, tTmpl2)
		if tTmpl1._nState ~= tTmpl2._nState then
			return tTmpl1._nState < tTmpl2._nState
		else
			return tTmpl1.id < tTmpl2.id
		end
	end

	if not self._tHonorTmplList then
		self._tHonorTmplList = {}
		local tRoleTmpl = role_info.get(G_Me.userData.level)
		for i=1, rebel_boss_exploit_info.getLength() do
			local tTmpl = rebel_boss_exploit_info.indexOf(i)
			if tTmpl.boss_exploit_type == tRoleTmpl.boss_exploit_type then
				table.insert(self._tHonorTmplList, #self._tHonorTmplList + 1, tTmpl)
			end
		end

		local tClimedAwardIdList = G_Me.moshenData:getClaimedAwardList(self._nCurMode)
		for i=1, #self._tHonorTmplList do
			local tTmpl = self._tHonorTmplList[i]
			local isContain = contains(tClimedAwardIdList, tTmpl.id)
			if isContain then
				tTmpl._nState = MoShenConst.AWARD_STATE.CLAIMED 
			else
				tTmpl._nState = MoShenConst.AWARD_STATE.UNFINISH 
			end
		end
		table.sort(self._tHonorTmplList, sortFunc)
	end

	--[[
	    AWARD_STATE = {
        CAN_CLAIM = 1,  -- 可领取
        UNFINISH = 2,   -- 未完成
        CLAIMED = 3,    -- 已领取
    }
	]]
end

function RebelBossAwardListLayer:_initBossLevelAwardData()
	local function sortFunc(tTmpl1, tTmpl2)
		if tTmpl1._nState ~= tTmpl2._nState then
			return tTmpl1._nState < tTmpl2._nState
		else
			return tTmpl1.id < tTmpl2.id
		end
	end

	if not self._tBossLevelTmplList then
		self._tBossLevelTmplList = {}

		for i=1, rebel_boss_reward_info.getLength() do
			local tTmpl = rebel_boss_reward_info.indexOf(i)
			table.insert(self._tBossLevelTmplList, #self._tBossLevelTmplList + 1, tTmpl)
		end

		local tClimedAwardIdList = G_Me.moshenData:getClaimedAwardList(self._nCurMode)
		for i=1, #self._tBossLevelTmplList do
			local tTmpl = self._tBossLevelTmplList[i]
			local isContain = contains(tClimedAwardIdList, tTmpl.id)
			if isContain then
				tTmpl._nState = MoShenConst.AWARD_STATE.CLAIMED 
			else
				tTmpl._nState = MoShenConst.AWARD_STATE.UNFINISH 
			end
		end
		table.sort(self._tBossLevelTmplList, sortFunc)
	end
end

function RebelBossAwardListLayer:_reloadRankList(nMode)
	if nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR then
		self._tHonorTmplList = nil
		self:_initHonorAwardData()
		local len = table.nums(self._tHonorTmplList)
		self._tHonorAwardListView:reloadWithLength(len)
	elseif nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL then
		self._tBossLevelTmplList = nil
		self:_initBossLevelAwardData()
		local len = table.nums(self._tBossLevelTmplList)
		self._tBossLevelAwardListView:reloadWithLength(len)
	elseif nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.LEGION then
		self:_initLegionAwardListView()
		self._tLegionAwardListView:reloadWithLength(rebel_boss_corps_info.getLength())
		self:_updateMyLegionInfo()
	end

	-- 红点
	if G_Me.moshenData:hasRebelBossAward(nMode) then
		self:showWidgetByName("Image_Tip"..nMode, true)
	else
		self:showWidgetByName("Image_Tip"..nMode, false)
	end
end

-- 自己的阵营信息
function RebelBossAwardListLayer:_updateMyLegionInfo()
	local szMyLegion = G_lang:get("LANG_REBEL_BOSS_MY_LEGION")
	local szLegionRank = G_lang:get("LANG_REBEL_BOSS_LEGION_RANK")
	local szLegionHonor = G_lang:get("LANG_REBEL_BOSS_LEGION_HONOR")
	local szMyLegionName = G_lang:get("LANG_REBEL_BOSS_WAITING_FOR_YOU")
	local nLegionRank = 0
	local nLegionHonor = 0

	if G_Me.legionData:hasCorp() then
		local tMyLegionRankInfo = G_Me.moshenData:getMyLegionRankInfo()
		if tMyLegionRankInfo and table.nums(tMyLegionRankInfo) ~= 0 then
			szMyLegionName = tMyLegionRankInfo._szLegionName
			nLegionRank = tMyLegionRankInfo._nRank
			nLegionHonor = tMyLegionRankInfo._nHonor
		end
	end

	CommonFunc._updateLabel(self, "Label_MyLegion", {text=szMyLegion})
	CommonFunc._updateLabel(self, "Label_MyLegionName", {text=szMyLegionName})

	CommonFunc._updateLabel(self, "Label_MyLegionRank", {text=szLegionRank})
	CommonFunc._updateLabel(self, "Label_MyLegionRankValue", {text=(nLegionRank == 0) and G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK_1") or nLegionRank})

	CommonFunc._updateLabel(self, "Label_MyLegionHonor", {text=szLegionHonor})
	CommonFunc._updateLabel(self, "Label_MyLegionHonorValue", {text=nLegionHonor})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_MyLegion'),
        self:getLabelByName('Label_MyLegionName'),
    }, "L")
    self:getLabelByName('Label_MyLegion'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_MyLegionName'):setPositionXY(alignFunc(2))  

   	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_MyLegionRank'),
        self:getLabelByName('Label_MyLegionRankValue'),
    }, "L")
    self:getLabelByName('Label_MyLegionRank'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_MyLegionRankValue'):setPositionXY(alignFunc(2))  

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_MyLegionHonor'),
        self:getLabelByName('Label_MyLegionHonorValue'),
    }, "R")
    self:getLabelByName('Label_MyLegionHonor'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_MyLegionHonorValue'):setPositionXY(alignFunc(2))  

    -- 军团奖励20：00后可领取的tip
    CommonFunc._updateLabel(self, "Label_LegionClaimTip", {text=G_lang:get("LANG_REBEL_BOSS_CAN_CLAIM_LEGION_AWARD"), stroke=Colors.strokeBrown})

    -- 更新主界面自己的军团排行
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MY_LEGION_RANK, nil, false, nLegionRank)
end

function RebelBossAwardListLayer:_onCliamAwardSucc(data)
	-- 重新刷新界面
	if self._nCurMode == MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR or self._nCurMode == MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL then
		G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(self._nCurMode)
	else
		G_HandlersManager.moshenHandler:sendRebelBossCorpAwardInfo()
	end
	-- 飞物品
	local tDropList = {}
	for i, val in ipairs(data.awards) do
		local tAward = val
    	local tDrop = {}
    	tDrop.type = tAward.type
    	tDrop.value = tAward.value
    	tDrop.size = tAward.size
    	table.insert(tDropList, tDrop)
	end
	local tGoodsPopWindowsLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(tDropList, function() end)
    self:addChild(tGoodsPopWindowsLayer)

    for i=1, 3 do
		-- 红点
		local nMode = i
		if G_Me.moshenData:hasRebelBossAward(nMode) then
			self:showWidgetByName("Image_Tip"..nMode, true)
		else
			self:showWidgetByName("Image_Tip"..nMode, false)
		end
	end
end


return RebelBossAwardListLayer