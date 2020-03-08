local tbTimerTrigger  =
{ 
    [1] = {szType = "Day", Time = "10:00", Trigger = "RefreshFlowerState"},
    [2] = {szType = "Day", Time = "16:00", Trigger = "RefreshFlowerState"},
}
local tbIllType = {
{
    {"\n\n似乎有些营养不良 ", "施肥", {4}, "Plant2"},
    {"\n\n似乎有些透不过气 ", "松土", {3}, "Plant7"},
},
{
    {"\n\n叶子出现一些孔洞 ", "除虫", {1}, "Plant3"},
    {"\n\n叶子变得干枯萎靡 ", "加水", {4}, "Plant1"},
},
}
------------------------------------ArborDayCureAct------------------------------------
if not MODULE_GAMESERVER then
    Activity.ArborDayCureAct = Activity.ArborDayCureAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("ArborDayCure") or Activity.ArborDayCureAct
tbAct.tbTimerTrigger  = tbTimerTrigger
tbAct.GROUP           = 69
tbAct.DATA_VERSION    = 1
tbAct.LOVER           = 2
tbAct.SCORE           = 3
tbAct.SEX_INACT       = 4
tbAct.CURE_IDX        = 5
tbAct.CURE_TIMES      = 6
tbAct.FLOWER_STATE_B  = 7
tbAct.FLOWER_STATE_E  = 30
tbAct.szScriptDataKey = "ArborDayCureAct"

tbAct.tbRankAward = {
                    {1,     {{"item", 10533, 1},{"item", 6533, 1},{"item", 10779, 1},{"item", 9597, 1}}},
                    {5,     {{"item", 6533, 1},{"item", 10779, 1},{"item", 9597, 1}}},
                    {10,    {{"item", 6533, 1},{"item", 10776, 1},{"item", 9597, 1}}},
                    {20,    {{"item", 6533, 1},{"item", 10776, 1}}},
                    {50,    {{"item", 6534, 1}}},
                    }

-- 第三个参数是索要触发的事件索引，在ArborDayCure中的tbNpcInfo中配置的 事件
tbAct.tbIllType = tbIllType

------------------------------------FathersDayAct------------------------------------
if not MODULE_GAMESERVER then
    Activity.FathersDay = Activity.FathersDay or {}
end
local tbFathersDayAct = MODULE_GAMESERVER and Activity:GetClass("FathersDay") or Activity.FathersDay
tbFathersDayAct.tbTimerTrigger = tbTimerTrigger
tbFathersDayAct.MAP_TID = 1624
tbFathersDayAct.GROUP           = 74
tbFathersDayAct.DATA_VERSION    = 1
tbFathersDayAct.LOVER           = 2
tbFathersDayAct.SCORE           = 3
tbFathersDayAct.SEX_INACT       = 4
tbFathersDayAct.CURE_IDX        = 5
tbFathersDayAct.CURE_TIMES      = 6
tbFathersDayAct.FLOWER_STATE_B  = 7
tbFathersDayAct.FLOWER_STATE_E  = 30
tbFathersDayAct.tbIllType       = tbIllType
if MODULE_GAMESERVER then
    return
end
-----------------------------------------Common End-------------------------------------------------------------------

local function GetRefreshDesc(nEndTime)
    local nRefresh = string.match(tbTimerTrigger[1].Time, "(%d+):(%d+)")
    local nCurHour = Lib:GetLocalDayHour()
    local nTomorrow = true
    for _, tbInfo in ipairs(tbTimerTrigger) do
        local szHour = string.match(tbInfo.Time, "(%d+):(%d+)")
        local nHour = tonumber(szHour)
        if nHour > nCurHour then
            nRefresh = nHour
            nTomorrow = false
            break
        end
    end
    if nTomorrow and nEndTime and Lib:GetLocalDay() == Lib:GetLocalDay(nEndTime) then
        return "下次不再刷新"
    end
    local szDesc = string.format("[92D2FF]下次刷新时间[-]:%d点", tonumber(nRefresh))
    return szDesc
end

------------------------------------ArborDayCureAct------------------------------------
function tbAct:GetRefreshDesc()
    local nEndTime = Activity.tbActivityData.ArborDayCureAct and Activity.tbActivityData.ArborDayCureAct.nEndTime
    local szDesc   = GetRefreshDesc(nEndTime)
    return szDesc
end

function tbAct:OnCureOk(tbIllType)
    Ui:CloseWindow("GrowFlowersPanel")
    UiNotify.OnNotify(UiNotify.emNOTIFY_ARBOR_CURE_OK, tbIllType);
end

function tbAct:OnLeaveHouseMap()
    Ui:CloseWindow("GrowFlowersPanel")
end

------------------------------------FathersDayAct------------------------------------
function tbFathersDayAct:OnSyncState()
    self:OnMapLoaded(self.MAP_TID)
end

function tbFathersDayAct:GetRefreshDesc()
    local nEndTime = Activity.tbActivityData.FathersDay and Activity.tbActivityData.FathersDay.nEndTime
    local szDesc   = GetRefreshDesc(nEndTime)
    return szDesc
end

function tbFathersDayAct:OnMapLoaded(nMapTID)
    if self.MAP_TID == nMapTID then
        Ui:OpenWindow("HomeScreenFuben", "ArborDayCureAct")
        Timer:Register(5, function ()
            local szDesc = self:GetRefreshDesc()
            Fuben:SetTargetInfo(szDesc)
        end)
    end
end

function tbFathersDayAct:OnLeaveMap(nMapTID)
    if self.MAP_TID and self.MAP_TID == nMapTID then
        Ui:CloseWindow("HomeScreenFuben")
        Ui:CloseWindow("GrowFlowersPanel")
    end
end