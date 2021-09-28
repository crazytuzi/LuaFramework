local _M = {}
_M.__index = _M
local cjson = require "cjson" 


function _M.GetDemonTowerInfoRequest(id,cb)
    Pomelo.DemonTowerHandler.getDemonTowerInfoRequest(id,function (ex,sjson)
        if not ex then
            local param = sjson:ToData()
            cb(param)
        end
    end)
end


function _M.GetDemonTowerSweepInfoRequest(cb)
    Pomelo.DemonTowerHandler.getDemonTowerSweepInfoRequest(function (ex,json)
        
        if ex == nil then
            local param = json:ToData()
            if(param ~= nil)then
                
                cb(param)
            end
        end
    end)
end


function _M.StartToSweepDemonTowerRequest(cb)
    Pomelo.DemonTowerHandler.startToSweepDemonTowerRequest(function (ex,json)
        
        if ex == nil then
            local param = json:ToData()
            if(param ~= nil)then
                
                cb(param)
            end
        end
    end)
end


function _M.FinishSweepDemonTowerRequest(cb)
    Pomelo.DemonTowerHandler.finishSweepDemonTowerRequest(function (ex,json)
        
        if ex == nil then
            local param = json:ToData()
            if(param ~= nil)then
                
                cb(param)
            end
        end
    end)
end


function _M.StartDemonTowerRequest(id)
    Pomelo.DemonTowerHandler.startDemonTowerRequest(id,function (ex,json)
        
    end)
end

function GlobalHooks.DynamicPushs.OnfightLevelResultPush(ex, json)
  if ex == nil then
    local param = json:ToData()
    if param ~= nil then 
         local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIDemonLevelEnd, -1)
         obj:setData(param)
    end
  end
end

function GlobalHooks.DynamicPushs.OnSceneNamePush(ex, json)
    if ex == nil then
        local param = json:ToData()
        print("GlobalHooks.DynamicPushs.OnSceneNamePush")
        if(param ~= nil and  HudManagerU.Instance ~=nil and HudManagerU.Instance.SmallMap ~= nil)then
            HudManagerU.Instance:SetSmallMapTitle(param.scene_name);
        end
    end
end

function GlobalHooks.DynamicPushs.OnSweepDemonTowerEndPush(ex, json)
    if ex == nil then
        
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIDemonTowerSweep)
    end
end

function _M.InitNetWork()
    Pomelo.BattleHandler.fightLevelResultPush(GlobalHooks.DynamicPushs.OnfightLevelResultPush)
    Pomelo.BattleHandler.sceneNamePush(GlobalHooks.DynamicPushs.OnSceneNamePush)
    Pomelo.DemonTowerHandler.sweepDemonTowerEndPush(GlobalHooks.DynamicPushs.OnSweepDemonTowerEndPush)
end


return _M
