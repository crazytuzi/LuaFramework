local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"


local RankItem = require("app.scenes.moshen.rebelboss.RebelBossReportItem")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local RebelBossReportLayer = class("RebelBossReportLayer", UFCCSModelLayer)

function RebelBossReportLayer.create(...)
	return RebelBossReportLayer.new("ui_layout/moshen_RebelBossReportLayer.json", Colors.modelColor, ...)
end

function RebelBossReportLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)

	self._tListView = nil

	self:_initWidgets()
end

function RebelBossReportLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	-- 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_BOSS_REPORT, self._reloadRankList, self)

	-- 拉取数据
	G_HandlersManager.moshenHandler:sendGetRebelBossReport()

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function RebelBossReportLayer:onLayerExit( ... )
	if self._tCountDownTimer then
		G_GlobalFunc.removeTimer(self._tCountDownTimer)
		self._tCountDownTimer = nil
	end
end


function RebelBossReportLayer:_initWidgets()
	self:_initListView()

	-- 逃离时间
	local tInitInfo = G_Me.moshenData:getInitializeInfo()
	assert(tInitInfo)
	if tInitInfo then
		local nDay, nHour, nMinute, nSecond = G_ServerTime:getLeftTimeParts(tInitInfo._nEndTime)
		local szLeftTime = ""
		if nHour ~= 0 then
			szLeftTime = G_lang:get("LANG_REBEL_BOSS_LEFT_TIME_FORMAT1", {hour=nHour, minute=nMinute, second=nSecond})
		else
			szLeftTime = G_lang:get("LANG_REBEL_BOSS_LEFT_TIME_FORMAT2", {minute=nMinute, second=nSecond})
		end
		CommonFunc._updateLabel(self, "Label_TimeValue", {text=szLeftTime})
		CommonFunc._updateLabel(self, "Label_TimeEnd", {text=G_lang:get("LANG_REBEL_BOSS_ACTIVITY_CLOSE")})


		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_TimeValue'),
            self:getLabelByName('Label_TimeEnd'),
        }, "C")
        self:getLabelByName('Label_TimeValue'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_TimeEnd'):setPositionXY(alignFunc(2))    
	end

	self:registerBtnClickEvent("Button_Close_TopRight", function()
    	self:animationToClose()
    end)

    -- 活动结束倒计时
    if not self._tCountDownTimer then
        self._tCountDownTimer = G_GlobalFunc.addTimer(1, function(dt)
  			local nDay, nHour, nMinute, nSecond = G_ServerTime:getLeftTimeParts(tInitInfo._nEndTime)
			local szLeftTime = ""
			if nHour ~= 0 then
				szLeftTime = G_lang:get("LANG_REBEL_BOSS_LEFT_TIME_FORMAT1", {hour=nHour, minute=nMinute, second=nSecond})
			else
				szLeftTime = G_lang:get("LANG_REBEL_BOSS_LEFT_TIME_FORMAT2", {minute=nMinute, second=nSecond})
			end
			CommonFunc._updateLabel(self, "Label_TimeValue", {text=szLeftTime})
			CommonFunc._updateLabel(self, "Label_TimeEnd", {text=G_lang:get("LANG_REBEL_BOSS_ACTIVITY_CLOSE")})


			local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	            self:getLabelByName('Label_TimeValue'),
	            self:getLabelByName('Label_TimeEnd'),
	        }, "C")
	        self:getLabelByName('Label_TimeValue'):setPositionXY(alignFunc(1))
	        self:getLabelByName('Label_TimeEnd'):setPositionXY(alignFunc(2))  

            if nLeftTime == 0 then
                -- 活动结束 
                if self._tCountDownTimer then
                    G_GlobalFunc.removeTimer(self._tCountDownTimer)
                    self._tCountDownTimer = nil
                end
            end
        end)
    end

end

function RebelBossReportLayer:_initListView()
	if not self._tListView then
		local panel = self:getPanelByName("Panel_ListView_Report")
		self._tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		
		self._tListView:setCreateCellHandler(function(list, index)
			return RankItem.new()
		end)

		self._tListView:setUpdateCellHandler(function(list, index, cell)
			local tReportList = G_Me.moshenData:getBossReportList()
			assert(tReportList)

			local tReport = tReportList[index + 1]
			cell:updateContent(tReport)
		end)

		local nCellNum = table.nums(G_Me.moshenData:getBossReportList())
		self._tListView:initChildWithDataLength(nCellNum)
		self._tListView:scrollToShowCell(nCellNum-1, 0)

	end
end


function RebelBossReportLayer:_reloadRankList()
	local tReportList = G_Me.moshenData:getBossReportList()
	assert(tReportList)
	local len = table.nums(tReportList)
	self._tListView:setVisible(true)
	self._tListView:reloadWithLength(len, len)
	self._tListView:scrollToShowCell(len-1, 0)
end

return RebelBossReportLayer