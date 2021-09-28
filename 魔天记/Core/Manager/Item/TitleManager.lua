TitleManager = { }
local titleConfig = nil
local titleData = nil
local titleTypeDes = nil
local currentEquipTitleId = 0
local maxCount = 0
TitleManager.TITLECHANGE = "TITLECHANGE"
require "Core.Info.BaseAttrInfo";
local insert = table.insert
local _sortfunc = table.sort

function TitleManager.Init()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetTitle, TitleManager.GetTitleCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChangeTitle, TitleManager.ChangeTitleCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LostTitle, TitleManager.LostTitleCallBack);

    currentEquipTitleId = 0
    titleConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TITLE)
    titleTypeDes = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TITLE_TYPE)
    maxCount = table.getCount(titleConfig)
    titleData = { }
    for k, v in pairs(titleConfig) do

        local item = { }
        setmetatable(item, { __index = ConfigManager.TransformConfig(v) })
        if (titleData[v["type"]] == nil) then
            titleData[v["type"]] = { }
            titleData[v["type"]].name = titleTypeDes[v["type"]]["type"]
            titleData[v["type"]].datas = { }
        end
        item.state = 0
        item.attr = BaseAttrInfo:New()
        item.attr:Init(item)
        insert(titleData[v["type"]].datas, item)
    end
end

function TitleManager.GetTitleCallBack(cmd, data)
    if (data and data.errCode == nil) then
        local result = { }
        result = TitleManager.SetTitleData(data.titles)
        if (table.getCount(result) > 0) then
            if (TitleManager.GetCurrentEquipTitleId() == 0) then
                for k, v in ipairs(result) do
                    if v.kind == 17 then --vip称号自动穿戴
                        MainUIProxy.SendChangeTitle(v.id)
                        break
                    end
                end
            end

            ModuleManager.SendNotification(MainUINotes.OPEN_TITLENOTICE, { result[1], true })
        end
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Title)
    end
end

function TitleManager.ChangeTitleCallBack(cmd, data)
    if (data and data.errCode == nil) then
        if (data.pi == HeroController.GetInstance().id) then
            TitleManager.SetCurrentEquipTitleId(data.id)
            ModuleManager.SendNotification(MainUINotes.UPDATE_MYROLEPANEL)
        end
        MessageManager.Dispatch(TitleManager, TitleManager.TITLECHANGE, data)
    end

end

function TitleManager.LostTitleCallBack(cmd, data)
    if (data and data.errCode == nil) then
        if (data.pi == HeroController.GetInstance().id) then
            for k, v in pairs(titleData) do
                for k1, v1 in pairs(v.datas) do
                    if (v1.id == data.id) then
                        v1.state = 0
                    end
                end
            end

            if (data.id == currentEquipTitleId) then
                TitleManager.SetCurrentEquipTitleId(0)
            end
            ModuleManager.SendNotification(MainUINotes.UPDATE_MYROLEPANEL)
            ModuleManager.SendNotification(MainUINotes.OPEN_TITLENOTICE, { TitleManager.GetTitleConfigById(data.id), false })
            PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Title)
        end
        MessageManager.Dispatch(TitleManager, TitleManager.TITLECHANGE, { pi = data.pi, id = 0 })

    end
end



function TitleManager.GetCurrentEquipTitleData()
    if (currentEquipTitleId and currentEquipTitleId ~= 0) then
        return TitleManager.GetTitleConfigById(currentEquipTitleId)
    end

    return nil
end

function TitleManager.GetAllTitleCount()
    return maxCount
end

function TitleManager.GetFinishTitleCount()
    local count = 0
    for k, v in pairs(titleData) do
        for k1, v1 in pairs(v.datas) do
            if (v1.state == 1) then
                count = count + 1
            end
        end
    end
    return count
end

function TitleManager.SetCurrentEquipTitleId(id)
    if (id) then
        currentEquipTitleId = id
    end
    -- Warning(tostring(id))
end


function TitleManager.GetCurrentEquipTitleId()
    return currentEquipTitleId
end

function TitleManager.GetTitleConfigById(id)
    return titleConfig[id]
end

function TitleManager.SetTitleData(data)
    local result = { }
    if (data) then
        for k, v in pairs(data) do

            local item = ConfigManager.Clone(TitleManager.GetTitleConfigById(v.id))
            if (item) then
                item.state = 1
                item.limitTime = v.et
                item.attr = BaseAttrInfo:New()
                item.attr:Init(item)
                for k1, v1 in ipairs(titleData[item.type].datas) do
                    if (v1.id == item.id) then
                        if (v1.state == 0) then
                            insert(result, item)
                        end

                        titleData[item.type].datas[k1] = item
                        break
                    end
                end
            else
                Error("找不到称号" .. v.id)
            end
        end
        ModuleManager.SendNotification(MainUINotes.UPDATE_MYROLEPANEL)
    end
    return result
end

function TitleManager.GetTitleData()
    return titleData
end

function TitleManager.GetDataByCondition(onlyShowGet, data)
    local result = { }
    if (onlyShowGet) then
        for k, v in pairs(data) do
            if (v.state == 1) then
                insert(result, ConfigManager.Clone(v))
            end
        end
    else
        result = ConfigManager.Clone(data)
    end

    if (result and table.getCount(result) > 1) then
        _sortfunc(result, function(a, b)
            return((a.state - b.state) * 1000 + b.id - a.id) > 0
        end )
    end
    return result
end

function TitleManager.GetAllGetTitleAttr()
    local item = BaseAttrInfo:New()
    for k, v in pairs(titleData) do
        for k1, v1 in pairs(v.datas) do
            if (v1.state == 1) then
                item:Add(v1.attr)
            end
        end
    end
    return item
end



