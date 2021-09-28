local Util = require "Zeus.Logic.Util"
local Player = require"Zeus.Model.Player"
local ItemAPI = require "Zeus.Model.Item"
local AutoBuyPotion = require "Zeus.Logic.AutoBuyPotion"

local inited = false
local autoBuyPotion = false

local AutoSetting = {}

function AutoSetting.saveSetting()
    local settingData = DataMgr.Instance.AutoSettingData
    local data = {
        hpPercent = settingData.hpPercent,
        mpPercent = 0,
        hpItemCode = settingData.hpItemCode,
        mpItemCode = settingData.mpItemCode,
        pkSet = (settingData.autoFlee and 1) or 0,
        autoBuyHpItem = settingData.autoBuyHpItem and 1 or 0,
        autoBuyMpItem = settingData.autoBuyMpItem and 1 or 0,
        autoBuyMpItem = 0,
        fieldMaphook = settingData.isAutoFightMapModeInWild and 1 or 0,
        areaMaphook = settingData.isAutoFightMapModeInOther and 1 or 0,
        meltQcolor = {},
    }
    for i=0,5 do
        if settingData:IskMeltQuality(i) then
            table.insert(data.meltQcolor, i)
        end
    end

    if autoBuyPotion then
        autoBuyPotion:updateData()
    end
    
    Pomelo.HookSetHandler.changeHookSetRequest(data, function(ex, sjson)
        if ex then return end

    end)
end

function AutoSetting.loadData()
    inited = true
    local hookData = Player.GetBindPlayerData().hookSetData;
    
    if hookData then
        local settingData = DataMgr.Instance.AutoSettingData
        settingData.hpPercent = hookData.hpPercent
        settingData.mpPercent = hookData.mpPercent
        settingData.hpItemCode = hookData.hpItemCode
        settingData.mpItemCode = hookData.mpItemCode
        settingData.autoBuyHpItem = hookData.autoBuyHpItem == 1
        settingData.autoBuyMpItem = hookData.autoBuyMpItem == 1
        settingData.autoFlee = hookData.pkSet == 1
        settingData.autoFightBack = hookData.pkSet == 0
        settingData.isAutoFightMapModeInWild = hookData.fieldMaphook == 1
        settingData.isAutoFightMapModeInOther = hookData.areaMaphook == 1
        for i=0,5 do
            settingData:SetMeltQuality(i, false)
        end
        for _,v in ipairs(hookData.meltQcolor or {}) do
            settingData:SetMeltQuality(v, true)
        end

        if not autoBuyPotion then
            autoBuyPotion = AutoBuyPotion.New(settingData, "Event.EatEmptyHp", "Event.EatEmptyMp")
        end
    end
end

function AutoSetting.initial()
    if autoBuyPotion then
        autoBuyPotion:subscribeEvents()
    end
end

function AutoSetting.fin(relogin)
    if relogin then
        
        inited = false

        if autoBuyPotion then
            autoBuyPotion:destroy()
            autoBuyPotion = false
        end
    end

end

function AutoSetting.InitNetWork()
    if not inited then
        
        AutoSetting.loadData()
    end
end

return AutoSetting
