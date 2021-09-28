
local _M = { }
_M.__index = _M

local cjson = require "cjson"
local helper = require "Zeus.Logic.Helper"

_M.FuncsInfo = {
    
}
_M.OpenList = {
    
}

local nameList = {
    [GlobalHooks.UITAG.GameUIMail] = 'Mail',
    [GlobalHooks.UITAG.GameUIChatMainSecond] = 'Chat',
    [GlobalHooks.UITAG.GameUIBagStore] = 'Warehouse',
    [GlobalHooks.UITAG.GameUISceneMapU] = 'Map',
    [GlobalHooks.UITAG.GameUISignXMDS] = 'Activity',
    
    
    [GlobalHooks.UITAG.GameUIRoleMain] = 'Bag',
    [GlobalHooks.UITAG.GameUIMoneyShow] = 'Currency',
    [GlobalHooks.UITAG.GameUIRoleAttribute] = 'Character',
    
    
    [GlobalHooks.UITAG.GameUIActivityHJBoss] = 'DailyPlay',
    [GlobalHooks.UITAG.GameUIFuben] = 'FB',
    [GlobalHooks.UITAG.GameUISkillMain] = 'Skill',
    [GlobalHooks.UITAG.GameUIRideMain] = 'Ride',
    [GlobalHooks.UITAG.GameUITeamMain] = 'Team',
    [GlobalHooks.UITAG.GameUIMelt] = 'Smelting',
    [GlobalHooks.UITAG.GameUIExchangeMain] = 'Change',
    [GlobalHooks.UITAG.GameUIApplyGuild] = 'Guild',
    
    [GlobalHooks.UITAG.GameUIEquipSuit] = 'suit',
    [GlobalHooks.UITAG.GameUIPetMain] = 'Pet',
    [GlobalHooks.UITAG.GameUIBloodMain] = 'BloodLineage',
    
    
    
    
    
    
    [GlobalHooks.UITAG.GameUIUpStairs] = 'Up',
    
    [GlobalHooks.UITAG.GameUIShop] = 'Mall',
    [GlobalHooks.UITAG.GameUIActivityMain] = 'XMDSActivity',
    [GlobalHooks.UITAG.GameUILeaderboard] = 'Rank',
    
    [GlobalHooks.UITAG.GameUISocialMain] = 'Social',
    [GlobalHooks.UITAG.GameUISocialDaoqun] = 'Ally',
    [GlobalHooks.UITAG.GameUISetMain] = 'SysSetting',
    [GlobalHooks.UITAG.GameUIMultiPvpFrame] = 'JJC',
    [GlobalHooks.UITAG.GameUIConsignmentMain] = 'Consignment',
    [GlobalHooks.UITAG.GameUISolo] = 'Solo',
    
    

    
    [GlobalHooks.UITAG.GameUIFirstPay] = 'FirstCharge',
    

    
    
    
    
    
    

    
    [GlobalHooks.UITAG.GameUIWorldLv] = 'WorldExp',
    

    [GlobalHooks.UITAG.GameUIEquipReworkMain] = 'Reworking',
    [GlobalHooks.UITAG.GameUIEquipReworkScurbing] = 'Reborn',
    [GlobalHooks.UITAG.GameUIEquipReworkRefine] = 'ReworkRefine',
    [GlobalHooks.UITAG.GameUIEquipReworkReMake] = 'Rebuild',
    [GlobalHooks.UITAG.GameUIEquipReworkMake] = 'Make',
    [GlobalHooks.UITAG.GameUIEquipReworkKaiguang] = 'Refine',
    [GlobalHooks.UITAG.GameUIEquipReworkChuancheng] = 'Inherit',
    [GlobalHooks.UITAG.GameUIHuanJing] = 'Dreamland',
    [GlobalHooks.UITAG.GameUI5V5Main] = '5v5',
}

local function RequestPlayedFunction(funcName, cb)
    
    Pomelo.FunctionOpenHandler.setFunctionPlayedRequest(funcName, function(ex, sjson)
        if ex == nil then
            if cb ~= nil then
                cb()
            end
        end
    end , XmdsNetManage.PackExtData.New(false, false))
end

function _M.SetPlayedFunctionByName(funcName)
    local func = _M.FuncsInfo[funcName]
    if func ~= nil and func.Type == 6 and func.playFlag == 0 then
        RequestPlayedFunction(funcName, function()
            func.playFlag = 1
            EventManager.Fire('Event.FunctionOpen.WaitToPlay', { name = funcName, waitToPlay = false })
        end )
    end
end


function GlobalHooks.CheckRindingIsOpenByName(funcName,isShowTips)
    local fInfo = GlobalHooks.DB.Find('OpenLv', funcName)
    if fInfo then
         local lv = fInfo.OpenLv
         local myLv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL, 0)
         if myLv >= lv then
             return true
         end
         if isShowTips then
             local tips = fInfo.Tips
             if (not string.empty(tips)) then
                 GameAlertManager.Instance:ShowNotify(tips)
             end
         end
         return false
    else
        return true
    end
end


function GlobalHooks.CheckFuncIsOpenByName(funcName, isShowTips)
    funcName = nameList[funcName]
    local fInfo = GlobalHooks.DB.Find('OpenLv', funcName)
    if fInfo then
        local lv = fInfo.OpenLv
        local myLv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL, 0)
        
        if myLv >= lv then
            return true
        end
        if isShowTips then
            local tips = fInfo.Tips
            if (not string.empty(tips)) then
                GameAlertManager.Instance:ShowNotify(tips)
            end
        end
        return false
    else
        return false
    end
end

function _M.SetPlayedFunctionByTag(UITag)
    local funName = nameList[UITag]
    if funName ~= nil then
        

        
    end
    return true
end

function GlobalHooks.CheckFuncWaitToPlay(funcName)
    
    local func = _M.FuncsInfo[funcName]
    if func ~= nil and func.Type == 6 and func.openFlag == 1 and func.playFlag == 0 then
        
        return true
    end
    return false
end

function GlobalHooks.CheckFuncOpenByName(funcName, isShowTips)
    local func = _M.FuncsInfo[funcName]
    if func ~= nil then
        local isOpen = func.openFlag ~= 0
        if not isOpen and isShowTips then
            local tips = func.Tips
            if tips == '' then
                tips = Util.GetText(TextConfig.Type.ITEM, "notopenlevel")
            end
            GameAlertManager.Instance:ShowNotify(tips)
        end
        return isOpen
    end
    return true
end

function GlobalHooks.CheckFuncOpenByTag(UITag, isShowTips)
    local funName = nameList[UITag]
    if funName ~= nil then
        return GlobalHooks.CheckFuncOpenByName(funName, isShowTips)
    end

    return true
end

local function CheckIdleState()
    
    
    if GameSceneMgr.Instance.BattleRun.BattleClient == nil then
        return false
    end
    if not GameSceneMgr.Instance.BattleRun.BattleClient:LoadOk() then
        return false
    end

    
    local mapTypeStr = GlobalHooks.DB.GetGlobalConfig("OpenLv.Animation.SceneID")
    local mapType = string.split(mapTypeStr, ',')
    local sceneIdle = false
    for i = 1, #mapType do
        if DataMgr.Instance.UserData.SceneType == mapType[i] then
            mapType = true
            break
        end
    end
    if not mapType then
        return false
    end

    
    if MenuMgrU.Instance:GetTopMenu() ~= nil then
        return false
    end

    
    if DataMgr.Instance.UserData:IsSeekState() then
        return false
    end

    return true
end

local function InitOneFuncIcon(id, openFlag, funcDetail)
    local fOpen = openFlag == 1
    local fType = funcDetail.Type
    local fIcon = funcDetail.Icon
    local fComp = funcDetail.Comp
    if fType == 1 then
        
        local ui = HudManagerU.Instance:GetHudUI("MainHud")
        MenuBaseU.SetVisibleUENode(ui, fComp, fOpen)
    elseif fType == 2 then
        
        local ui = HudManagerU.Instance:GetHudUI("FuncEntry")
        
        
    elseif fType == 3 then
        
        
        
        
    elseif fType == 5 then
        
        local ui = HudManagerU.Instance:GetHudUI("Interactive")
        MenuBaseU.SetVisibleUENode(ui, fComp, fOpen)
    else
        

    end
end

local function InitOpenList(funcs)
    
    if #_M.OpenList == 0 and #funcs > 0 then
        
        AddUpdateEvent("Event.UI.FunctionOpen.Update", function(deltatime)
            
            if #_M.OpenList == 0 then
                
                RemoveUpdateEvent("Event.UI.FunctionOpen.Update", true)
                return
            end
            if CheckIdleState() then
                local openFunc = _M.OpenList[#_M.OpenList]
                local node, luaObj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIFuncOpen, -1)
                luaObj.SetData(luaObj, openFunc, function()
                    
                    InitOneFuncIcon(openFunc.ID, 1, openFunc)
                    
                    _M.FuncsInfo[openFunc.Fun].openFlag = 1
                    
                    _M.OpenList[#_M.OpenList] = nil
                end )
                MenuMgrU.Instance:AddMsgBox(node)
            end
        end )
    end

    for i = #funcs, 1, -1 do
        local fun = funcs[i]
        local fName = fun.funcName
        local fOpen = fun.openFlag
        local fPlay = fun.playFlag
        local fInfo = GlobalHooks.DB.Find('OpenLv', fName)
        if fInfo ~= nil then
            if fOpen == 1 and _M.FuncsInfo[fName].openFlag == 0 then
                
                _M.FuncsInfo[fName].openFlag = 1
                if fInfo.Type == 6 then
                    
                    _M.FuncsInfo[fName].openFlag = 1
                    local waitToPlay =(fOpen == 1 and fPlay == 0) and true or false
                    EventManager.Fire('Event.FunctionOpen.WaitToPlay', { name = fName, waitToPlay = waitToPlay })
                else
                    _M.OpenList[#_M.OpenList + 1] = fInfo
                end
                if fName == "Wings" then
                    
                    DramaHelper.PlayActorEffect("/res/effect/50000_state/vfx_50201_level.assetbundles")
                elseif fName == "Riding" then 
                    
                elseif fName == "FirstPay" and DramaUIManage.Instance:IsGuideHandActive() == false then 
                    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFirstPay, -1, 1)
                end
            end
        end
    end
end

local function InitFuncsIcon(funcs)
    
    _M.FuncsInfo = { }
    for i = 1, #funcs do
        local fName = funcs[i].funcName
        local func = GlobalHooks.DB.Find('OpenLv', fName)
        if func ~= nil then
            _M.FuncsInfo[fName] = func
            _M.FuncsInfo[fName].openFlag = funcs[i].openFlag
            _M.FuncsInfo[fName].playFlag = funcs[i].playFlag
            InitOneFuncIcon(funcs[i].id, funcs[i].openFlag, func)
            
            if func.Type == 6 then
                
                local waitToPlay =(funcs[i].openFlag == 1 and funcs[i].playFlag == 0) and true or false
                
                EventManager.Fire('Event.FunctionOpen.WaitToPlay', { name = fName, waitToPlay = waitToPlay })
            end
        end
    end
end

function GlobalHooks.DynamicPushs.OnFunctionOpenListPush(ex, json)
    
    

    if ex == nil then
        local param = json:ToData()
        local funcs = param.s2c_list
        
        
        
        
        InitOpenList(funcs)
        
    end
end

function _M.ReceiveFunctionAwardRequest(id, cb)
    Pomelo.FunctionOpenHandler.receiveFunctionAwardRequest(id, function(ex, sjson)
        if ex == nil then
            if cb ~= nil then
                cb(id)
            end
        end
    end , XmdsNetManage.PackExtData.New(false, false))
end

function GlobalHooks.DynamicPushs.OnFunctionAwardListPush(ex, json)
    if ex == nil then
        local param = json:ToData()
        local funcs = param.guideIds == nil and {} or param.guideIds
        EventManager.Fire('Event.TeamQuestHud.TargetPrizePush', funcs)
        
    end
end







local function InitFunctionList()
    
    local Player = require "Zeus.Model.Player"
    local player = Player.GetBindPlayeProto()
    if player ~= nil then
        local funcs = player.functionList
        if funcs ~= nil then
            InitFuncsIcon(funcs)
        end
    end
end

function _M.initial()
    
    EventManager.Subscribe("Event.Scene.FirstInitFinish", InitFunctionList)
end

function _M.fin(relogin)
    if relogin then
        RemoveUpdateEvent("Event.UI.FunctionOpen.Update", true)
    end
end

function _M.InitNetWork()
    
    
    Pomelo.GameSocket.functionOpenListPush(GlobalHooks.DynamicPushs.OnFunctionOpenListPush)

     Pomelo.GameSocket.functionAwardListPush(GlobalHooks.DynamicPushs.OnFunctionAwardListPush)
end

return _M
