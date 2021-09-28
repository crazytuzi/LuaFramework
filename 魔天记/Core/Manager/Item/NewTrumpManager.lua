NewTrumpManager = { }
require "Core.Info.NewTrumpInfo";
local newTrumpConfig = nil
local newTrumpRefineConfig = nil
local newTrumpData = nil
local selectTrump = nil
local selectTrumpRefineLevel = 1
local mainTrump = nil
local _autoConfirm = false
NewTrumpManager.SelfTrumpFollow = "SelfTrumpFollow"
NewTrumpManager.ActiveTrump = "ActiveTrump"
NewTrumpManager.MaxRefineLevel = ConfigManager.GetLevelLimit("magic_refine")
function NewTrumpManager.Init()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CanActiveTrump, NewTrumpManager.CanActiveTrumpCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ActiveTrump, NewTrumpManager.ActiveTrumpCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EquipTrump, NewTrumpManager.EquipTrumpCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RefineTrump, NewTrumpManager.RefineTrumpCallBack);
    _autoConfirm = false
    mainTrump = nil
    selectTrump = nil
    selectTrumpRefineLevel = 1
    newTrumpConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NEW_TRUMP)
    newTrumpRefineConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NEW_TRUMP_REFINE)
end

function NewTrumpManager.CanActiveTrumpCallBack(cmd, data)

    if (data and data.errCode == nil) then        
        for k, v in ipairs(newTrumpData) do
            if (v.id == data.id) then
                v.state = 1                
                ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPNOTICEPANEL, v)
                break
            end
        end
        NewTrumpManager.SortTrump()
        ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPPANEL)
    end
end

function NewTrumpManager.ActiveTrumpCallBack(cmd, data)
    if (data and data.errCode == nil) then
        for k, v in ipairs(newTrumpData) do
            if (v.id == data.id) then
                v.state = 2
                ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPACTIVEPANEL, v)
                ModuleManager.SendNotification(NewTrumpNotes.CLOSE_NEWTRUMPNOTICEPANEL, v)
                PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.NewTrump)
                break
            end
        end
        NewTrumpManager.SortTrump()
        MessageManager.Dispatch(NewTrumpManager, NewTrumpManager.ActiveTrump);
        ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPPANEL)
    end
end

function NewTrumpManager.EquipTrumpCallBack(cmd, data)
    if (data and data.errCode == nil) then
        for k, v in ipairs(newTrumpData) do
            if (v.id == data.id) then
                v.state = 3
                mainTrump = v
                PlayerManager.GetPlayerInfo():SetTrumpSkill(mainTrump:GetTrumpSkillInfo());
            else
                if (v.state == 3) then
                    v.state = 2
                end
            end
        end
        NewTrumpManager.SortTrump()

        ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPPANEL)
        MessageManager.Dispatch(NewTrumpManager, NewTrumpManager.SelfTrumpFollow);
    end
end

function NewTrumpManager.RefineTrumpCallBack(cmd, data)
    if (data and data.errCode == nil) then
        for k, v in ipairs(newTrumpData) do
            if (v.id == data.id) then
                v:SetRefineData(data)
                v:SetRefineState(data.lv, 1)
                PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.NewTrump)
                --                PlayerManager.CalculatePlayerAttribute()
            end
        end
        ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPPANEL)
    end
end

function NewTrumpManager.GetTrumpConfigById(id)
    return newTrumpConfig[id]
end
function NewTrumpManager.GetSkillIdByTrumpId(id)
    return newTrumpConfig[id].act_skill
end

local insert = table.insert

-- 开始的时候初始化自己的数据
function NewTrumpManager.SetSelfTrumpData(data)
    local heroInfo = PlayerManager.GetPlayerInfo();
    newTrumpData = { }
    for k, v in ipairs(data) do
        local config = newTrumpConfig[v]
        if (config) then
            local tempData = { }
            tempData.st = 0
            tempData.id = v
            local temp = NewTrumpInfo:New(v)
            heroInfo:AddTrumpSkill(temp:GetTrumpSkillInfo())
            insert(newTrumpData, temp)
        end
    end
end

function NewTrumpManager.GetAllTrumpData()
    return newTrumpData
end

-- 设置多个法宝数据
function NewTrumpManager.SetAllNewTrumpData(data)
    local heroInfo = PlayerManager.GetPlayerInfo();
    heroInfo:SetTrumpSkill(nil);
    MessageManager.Dispatch(NewTrumpManager, NewTrumpManager.SelfTrumpFollow);
    if (data) then
        for k, v in ipairs(data) do
            for k1, v1 in ipairs(newTrumpData) do
                if (v1.id == v.id) then
                    v1:SetTrumpState(v.st)
                    v1:SetAllRefineData(v.rlv)
                    if (v.st == 3) then
                        mainTrump = v1
                        heroInfo:SetTrumpSkill(v1:GetTrumpSkillInfo());
                        MessageManager.Dispatch(NewTrumpManager, NewTrumpManager.SelfTrumpFollow);
                    end
                end
            end
        end
        NewTrumpManager.SortTrump()
    end

end

function NewTrumpManager.SetNewTrumpRefineData(data)
    if (data) then
        for k, v in pairs(newTrumpData) do
            if (v.id == data.id) then
                v:SetRefineData(data)
            end
        end
    end

end

function NewTrumpManager.SetNewTrumpState(id, state)
    for k, v in pairs(newTrumpData) do
        if (v.id == id) then
            v:SetTrumpState(state)
        end
    end
end 

function NewTrumpManager.GetNewTrumpRefineConfigByIdAndLev(id, lev)
    local index = id .. "_" .. lev
    return newTrumpRefineConfig[index]
end

function NewTrumpManager.GetCurrentSelectTrump()
    return selectTrump
end

function NewTrumpManager.SetCurrentSelectTrump(v)
    selectTrump = v
    selectTrumpRefineLevel = 1
    SequenceManager.TriggerEvent(SequenceEventType.Guide.TRUMP_CHANGE, v);
end

function NewTrumpManager.GetSelectRefineLevel()
    return selectTrumpRefineLevel
end

function NewTrumpManager.SetSelectRefineLevel(v)
    selectTrumpRefineLevel = v
end 

function NewTrumpManager.GetAllAttrs()
    local attr = BaseAttrInfo:New()
    for k, v in ipairs(newTrumpData) do
        if (v.state > NewTrumpInfo.State.CanActive) then
            attr:Add(v:GetAllAttr())
        end
    end
    return attr
end

function NewTrumpManager.CheckRefine(data, level)
    local isLastLevelActive = data:GetLastLevelIsActive(level)
   
    if (not isLastLevelActive) then
        MsgUtils.ShowTips("NewTrumpManger/lastLevelNotActive")
        return false
    end
    local refineData = data:GetRefineDataByLevel(level)
    if (MoneyDataManager.Get_money() < refineData.reqMoney) then
        MsgUtils.ShowTips("common/lingshibuzu")
        return false
    end

    -- if (BackpackDataManager.GetProductTotalNumBySpid(refineData.condition[1].itemId) < refineData.condition[1].itemCount) then
    --        ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
    --         {id = refineData.condition[1].itemId, msg= NewTrumpNotes.CLOSE_NEWTRUMPPANEL,updateNote = NewTrumpNotes.UPDATE_NEWTRUMPPANEL })

    --     MsgUtils.ShowTips("NewTrumpManger/refineProductNotEnough")
    --     return false
    -- end
    return true
end

function NewTrumpManager.IsTrumpHadRefine()
    for k, v in pairs(newTrumpData) do
        if (v:IsTrumpHadRefine()) then
            return true
        end
    end
    return false
end

function NewTrumpManager.IsTrumpDress()
    for k, v in pairs(newTrumpData) do
        if (v.state == NewTrumpInfo.State.HadDress) then
            return true
        end
    end
    return false
end
-- 主界面法宝/炼制红点是否显示
function NewTrumpManager.CanTrumpMsg()
    return NewTrumpManager.CanTrumpShowTip() or NewTrumpManager.CanTrumpRefineShowTip()
end
-- 界面法宝红点是否显示
function NewTrumpManager.CanTrumpShowTip()
    for k, v in pairs(newTrumpData) do
        if (v.state == NewTrumpInfo.State.HadDress) then
            return false
        end
    end

    for k, v in pairs(newTrumpData) do
        if (v.state == NewTrumpInfo.State.HadActive) then
            return true
        end
    end
    return false
end

-- 界面炼制红点是否显示
function NewTrumpManager.CanTrumpRefineShowTip()
    if(not SystemManager.IsOpen(SystemConst.Id.NewTrumpRefine)) then
        return false
    end
    for k, v in pairs(newTrumpData) do
        if (v:CanTrumpRefine()) then
            return true
        end
    end
    return false
end

local weight =
{
    [0] = 100,
    [1] = 10000,
    [2] = 1000,
    [3] = 100000,
}

local sortTrump = function(a, b)
    local p = 0
    p = weight[a.state] - weight[b.state] + b.id - a.id
    return p > 0
end
local _sortfunc = table.sort 

function NewTrumpManager.SortTrump()
    _sortfunc(newTrumpData, sortTrump)
end

function NewTrumpManager.SetAutoConfirm(v)
    _autoConfirm = v
end

function NewTrumpManager.GetAutoConfirm(v)
    return  _autoConfirm 
end



local mbConfig
local currentSelect
local mbData = {}
-- local mbData = {{id=310301},{id=310302},{id=310303},{id=310304},{id=310305}}
--local mbData = {{id=310303}}
function NewTrumpManager.GetMobaoAllAttrs()
    local baseAttrInfo = BaseAdvanceAttrInfo:New()
    local lev = PlayerManager.GetPlayerLevel()  
    for i = #mbData, 1, -1 do 
        local c = NewTrumpManager.GetMobaoConfig(mbData[i].id)
        baseAttrInfo:Add(c)
        if c.effect_type == 5 then            
            local add = NewTrumpManager.GetMobaoEffectAdd(c, lev)-- Warning(tostring(add))
            baseAttrInfo.hp_max = baseAttrInfo.hp_max + add
        end
    end
--    for k,v in pairs(baseAttrInfo) do Warning(k ..'---'.. tostring(v)) end
    return baseAttrInfo
end
function NewTrumpManager.GetMobaoPower()
    local p = 0
    for i = #mbData, 1, -1 do 
        local c = NewTrumpManager.GetMobaoConfig(mbData[i].id)
        if (c) then
            p = p + c.fighting_capacity
        end
        --Warning(tostring(c) .. '-----' .. p)
    end
    return p
end
function NewTrumpManager.GetMobaoAttrs(config)
    local baseAttrInfo = BaseAttrInfo:New()
    baseAttrInfo:Add(config)
    return baseAttrInfo
end
function NewTrumpManager.SetMobaoData(d)
    if not d then return end
    mbData = d
end
function NewTrumpManager.EnableMobao(d)
    for i = #mbData, 1, -1 do 
        if mbData[i].id == d.id then return end
    end
    table.insert( mbData, d)
    ModuleManager.SendNotification(NewTrumpNotes.OPEN_MOBAO_NOTICE, NewTrumpManager.GetMobaoConfig(d.id))
    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Mobao)
end
function NewTrumpManager.GetMobaoConfigs()
    if not mbConfig then mbConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MOBAO) end
    return mbConfig
end
function NewTrumpManager.GetMobaoConfig(id)
    local cs = NewTrumpManager.GetMobaoConfigs()
    for k,v in pairs(cs) do
    --Warning(k .. '======' .. tostring(v.id) .. '-' .. id)
        if v.id == id then return v end
    end
    return nil
	--return NewTrumpManager.GetMobaoConfigs()[id]
end
function NewTrumpManager.IsMobaoEnable(id)
    for i = #mbData, 1, -1 do if mbData[i].id == id then return true end end
    return false
end
function NewTrumpManager.SetCurrentMobao(data)
    currentSelect = data
end
function NewTrumpManager.GetCurrentMobao()
    if not currentSelect then
       --if #mbData > 0 then currentSelect = NewTrumpManager.GetMobaoConfig(mbData[#mbData].id)
       --else
           local cs = NewTrumpManager.GetMobaoConfigs()
           cs = ConfigManager.SortForField(cs, 'id')
           currentSelect = cs[1]
       --end
    end
    return currentSelect
end

local mbeConfig
function NewTrumpManager.GetMobaoEffectConfigs()
    if not mbeConfig then mbeConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MOBAO_EFFECT) end
    return mbeConfig
end
function NewTrumpManager.GetMobaoEffectHealAdd(lev)
    local c = NewTrumpManager.GetMobaoEffectConfigs()[lev]
    return c and c.heal_add or 0
end
function NewTrumpManager.GetMobaoEffectHpAdd(lev)
    local c = NewTrumpManager.GetMobaoEffectConfigs()[lev]
    return c and c.hp_add or 0
end
function NewTrumpManager.GetMobaoEffectDes(d)
    local des = d.effect_des
    local lev = PlayerManager.GetPlayerLevel()  
    local add = NewTrumpManager.GetMobaoEffectAdd(d, lev)
    if add and add > 0 then des = LanguageMgr.ApplyFormat(des, { s = add }) end
    return des
end
function NewTrumpManager.GetMobaoEffectAdd(d, lev)
    local add = 0
    if d.effect_type == 3 then --3:使用药品额外生命恢复
        add = NewTrumpManager.GetMobaoEffectHealAdd(lev)
    elseif d.effect_type == 5 then --5:永久提升移速、生命上限
        add = NewTrumpManager.GetMobaoEffectHpAdd(lev)
    end
    return add
end

