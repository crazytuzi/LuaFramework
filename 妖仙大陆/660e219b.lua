local _M = { }
_M.__index = _M

local Util = require 'Zeus.Logic.Util'
local BossFightModel        = require 'Zeus.Model.BossFight'

function _M.GetStrByLeftSecond(seconds)
    if seconds == nil then
        return Util.GetText(TextConfig.Type.ACTIVITY, "ACT_NOServerData")
    elseif seconds == 0 then
        return Util.GetText(TextConfig.Type.ACTIVITY, "ACT_HaveRefsh")
   
    
    else
        local leftSecond = math.floor(seconds/1000 - (os.time() - BossFightModel.getBossInfoTime))
        if leftSecond <= 0 then
            return Util.GetText(TextConfig.Type.ACTIVITY, "ACT_HaveRefsh")
        end

        local leftMin =  math.fmod(math.floor(leftSecond/60), 60)
        local leftHour = math.floor(leftSecond/3600);
        leftSecond = math.fmod(leftSecond, 60)
        
        
        
        return Util.GetText(TextConfig.Type.ACTIVITY, "ACT_WaitRefsh",leftHour>9 and tostring(leftHour) or "0"..tostring(leftHour),
            leftMin>9 and tostring(leftMin) or "0"..tostring(leftMin),
            leftSecond>9 and tostring(leftSecond) or "0"..tostring(leftSecond))
    end
end

local function OpenActivityPanel(funId)
    if funId <= 0 then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ACTIVITY, "ACT_NotOpen"))
        return 
    end
    GlobalHooks.OpenUI(funId, 0)
end

local function OpenActivityChildPanel(funId)
    if string.len(funId) <= 0 then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ACTIVITY, "ACT_NotOpen"))
        return 
    end

    local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIActivityHJBoss)
    if lua_obj then
        lua_obj.SwitchChildMenu(funId)
    end
end

function _M.OnActivityClickGo(dailyData)
    if DataMgr.Instance.TeamData.HasTeam and not DataMgr.Instance.TeamData:IsLeader() and DataMgr.Instance.TeamData.TeamFollow == 1 and tonumber(dailyData.GoForInFollowingState) == 0 then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "followCannotOperateTip"))
        return
    end
    if dailyData.FunType == 3 then  
        EventManager.Fire('Event.Goto', {id = dailyData.FunID})
    elseif dailyData.FunType == 2 then 
        EventManager.Fire('Event.Goto', {id = dailyData.FunID})
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIActivityHJBoss)
    elseif dailyData.FunType == 1 then 
        OpenActivityPanel(tonumber(dailyData.FunID))
    elseif dailyData.FunType == 4 then 
        OpenActivityChildPanel(dailyData.FunID)
    end
end

return _M
