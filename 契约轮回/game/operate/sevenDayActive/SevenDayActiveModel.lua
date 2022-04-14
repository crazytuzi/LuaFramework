---
--- Created by  Administrator
--- DateTime: 2019/4/12 14:34
---
SevenDayActiveModel = SevenDayActiveModel or class("SevenDayActiveModel", BaseBagModel)
local SevenDayActiveModel = SevenDayActiveModel

function SevenDayActiveModel:ctor()
    SevenDayActiveModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function SevenDayActiveModel:Reset()
    --self.shopList = {}
    self.redPoints = {}
    self.petRedPoints = {}
    self.mergeRedPoints = {}
    self.isFirstOpen_rank = true
    self.isFirstOpen_buy = true
end

function SevenDayActiveModel:GetInstance()
    if SevenDayActiveModel.Instance == nil then
        SevenDayActiveModel()
    end
    return SevenDayActiveModel.Instance
end

function SevenDayActiveModel:GetRushBuyShopList(actId)
    local cfg = Config.db_mall
    local tab = {}
    local index = 0
    for i, v in pairs(cfg) do
        if v.activity == actId then
            index = index + 1
            local tab1 = {}
            tab1["id"] = v.id
            tab1["order"] = v.order

            tab1["times"] = 0
            tab[index] = tab1
            --tab[v.id] = v
           -- table.insert(tab,v)
        end
    end
    
    table.sort(tab, function(a,b)
         return a.order < b.order
    end)

    return tab
end

--function SevenDayActiveModel:GetRushBuyShopList()
--    return self.shopList
--end

function SevenDayActiveModel:GetRankTypeStr(eventid,rankId)
    --local str = ""
    local roledata = RoleInfoModel.GetInstance():GetMainRoleData()
   -- dump(Roledata)
    if eventid == 1 then -- 等级
        return roledata.level
    elseif eventid == 17 then --坐骑或者副手
        if rankId == 110502 then --坐骑
            return MountModel:GetInstance().layer.."Stage"..MountModel:GetInstance().level.."Star"
        else
            return MountModel:GetInstance().offhand_layer.."Stage"..MountModel:GetInstance().offhand_level.."Star"
        end
    elseif eventid == 0 then  --魔法卡
        return 0
    elseif eventid == 16 then -- 充值
        return 0 --还没写
    elseif eventid == 12  then --战力
        return roledata.power
    end
    return 0
end

function SevenDayActiveModel:GetLastRankID()
    
end
--升级攻略
function SevenDayActiveModel:GetLevelRecTab(rankId)
    local cfg = Config.db_rank_active
    local tab = {}
    for i, v in pairs(cfg) do
        if v.id == rankId then
            table.insert(tab,v)
        end
    end
    table.sort(tab, function(a,b)
           return a.sort < b.sort
    end)
    return tab
end

function SevenDayActiveModel:SwitchState(state)

    local num = 0
    if state == 1 then
        num = 1
    elseif state == 2 then
        num = 3
    else
        num = 2
    end
    return num
end
--通过ID得到坐骑阶数
function SevenDayActiveModel:GetMountNumByID(id)
    local Cfg = Config.db_mount
    for i, v in pairs(Cfg) do
        if v.id == id then
            return v
        end
    end
    return nil
end

--通过ID得到副手阶数
function SevenDayActiveModel:GetOffhandNumByID(id)
    local Cfg = Config.db_offhand
    for i, v in pairs(Cfg) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function SevenDayActiveModel:GetActType(actId)
    local cfg = OperateModel:GetInstance():GetConfig(actId)
    if not cfg then
        return
    end
    return cfg.type
end

function SevenDayActiveModel:UpdateRedPoint()
    for i, v in pairs(self.redPoints) do
        OperateModel:GetInstance():UpdateIconReddot(i,v)
    end
    self:Brocast(SevenDayActiveEvent.RedPointInfo)
end



