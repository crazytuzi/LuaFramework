
local DailyPvpMatchLayer = class("DailyPvpMatchLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

DailyPvpMatchLayer.MAX_TIME = 60

function DailyPvpMatchLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self._txtLabel = self:getLabelByName("Label_txt")
    self._timeLabel = self:getLabelByName("Label_time")
    self._time = 0
    self._schedule = nil
    self:attachImageTextForBtn("Button_cancel","Image_cancel")

    self:registerBtnClickEvent("Button_cancel", function()
        self:clickCancel()
    end)
end

function DailyPvpMatchLayer:clickCancel()
    local inTeam = G_Me.dailyPvpData:inTeam()
    if inTeam then
        if G_Me.dailyPvpData:getSelfData().isLeader then
            G_HandlersManager.dailyPvpHandler:sendTeamPVPStopMatch()
        end
    else
        G_HandlersManager.dailyPvpHandler:sendTeamPVPLeave()
    end
end

function DailyPvpMatchLayer.show(...)
    local layer = nil
    if G_Me.dailyPvpData:inTeam() then
        layer = DailyPvpMatchLayer.new("ui_layout/dailypvp_MatchingTeamLayer.json",require("app.setting.Colors").modelColor,...) 
        uf_sceneManager:getCurScene():addChild(layer)
    else
        layer = DailyPvpMatchLayer.new("ui_layout/dailypvp_MatchingLayer.json",require("app.setting.Colors").modelColor,...) 
        uf_sceneManager:getCurScene():addChild(layer)
    end
    return layer
end

function DailyPvpMatchLayer:onLayerEnter()
    -- self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    self._time = 0
    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    end
    self._timeLabel:setText(G_lang:get("LANG_DAILY_TIME",{time=self._time}))

    if G_Me.dailyPvpData:inTeam() then
        self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown, 1)
        if G_Me.dailyPvpData:isLeader() then
            self:getButtonByName("Button_cancel"):setVisible(true)
        else
            self:getButtonByName("Button_cancel"):setVisible(false)

            self:getImageViewByName("Image_bg"):setSize(CCSizeMake(528,463))
            self:getImageViewByName("Image_titleDi"):setPositionXY(0,194)
            self:getPanelByName("Panel_content"):setPositionXY(-216,-204)
        end
        local teamMembers = G_Me.dailyPvpData:getTeamMembers()
        for k , v in pairs(teamMembers) do 
            local times = rawget(v,"sp8") and v.sp8 or 0
            self:getLabelByName("Label_name"..(v.sp3+1)):setText(v.name)
            self:getLabelByName("Label_times"..(v.sp3+1)):setText(times)
            self:getLabelByName("Label_times"..(v.sp3+1)):setColor(times>0 and Colors.lightColors.TIPS_02 or Colors.lightColors.TIPS_01)
        end
    else
        self:getButtonByName("Button_cancel"):setVisible(true)
    end
end

function DailyPvpMatchLayer:updateView()
    local status = G_Me.dailyPvpData:inTeam()
    local txt = status and "LANG_DAILY_MATCH2" or "LANG_DAILY_MATCH1"
    self._txtLabel:setText(G_lang:get(txt))
end

function DailyPvpMatchLayer:_refreshTimeLeft()
    if not G_NetworkManager:isConnected() then
        G_Me.dailyPvpData:resetData()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPSTATUS, nil, false,nil)
        return
    end

    if self._time > DailyPvpMatchLayer.MAX_TIME then
        G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_MATCH_OUT_TIME"))
        self:clickCancel()

        if self._schedule then
            GlobalFunc.removeTimer(self._schedule)
            self._schedule = nil
        end
    end

    self._time = self._time + 1
    self._timeLabel:setText(G_lang:get("LANG_DAILY_TIME",{time=self._time}))
end

function DailyPvpMatchLayer:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
end

return DailyPvpMatchLayer

