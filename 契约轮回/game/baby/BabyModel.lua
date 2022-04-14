---
--- Created by  Administrator
--- DateTime: 2019/8/28 14:45
---
BabyModel = BabyModel or class("BabyModel", BaseBagModel)
local BabyModel = BabyModel

BabyModel.slotList = {
    [1] = 4001,
    [2] = 4002,
    [3] = 4003,
    [4] = 4004,
    [5] = 4005,
    [6] = 4006,
}

function BabyModel:ctor()
    BabyModel.Instance = self
    self:Reset()
end

BabyModel.foldName = { [1] = "Great Ambition", [2] = "Great Ambition" }

--- 初始化或重置
function BabyModel:Reset()
    self.isOpenBaby = false
    self.isHide = false --是否隐藏
    self.babies = {}
    self.progress = {} --出生进度
    self.orderBabies = {} --进阶宝宝数据
    self.figure = 0 --显示宝宝的ID
    self.curType = 1
    self.babyCulRedPoints = {}
    self.babyOrderRedPoints = {}
    self.babyToysRedPoints = {}
    self.babyWingRedPoints = {}
    self.babyWingNum = {}
    self.allBaby = {}
    self.allActBaby = {}
    self.wingInfo = {}
    self.wingInfoList = {}
    self.babyShowRed = false

    self.itemIds = {} --红点相关的物品
    self.taskInfo = {}
    self.selectEquip = {}
    self.equipsInfo = {}
    self.recordsInfo = {}
    self.isOpenDecompose = false
    self.openToysType = 1
    self:InitAllBaby()
    self:InitAllActBaby()
    self:InitOrderRedPoint()
    self:InitItemIds()
    self:IniEquipLvRedPoint()
end

function BabyModel:GetInstance()
    if BabyModel.Instance == nil then
        BabyModel()
    end
    return BabyModel.Instance
end

function BabyModel:InitAllBaby()
    local cfg = Config.db_baby_order
    for i, v in pairs(cfg) do
        if v.type_id == 1 then
            if not self.allBaby[v.gender] then
                self.allBaby[v.gender] = {}
            end

            if not self.allBaby[v.gender][v.id] then
                self.allBaby[v.gender][v.id] = {}
            end
        end
    end
end

function BabyModel:InitAllActBaby()
    local cfg = Config.db_baby_order
    for i, v in pairs(cfg) do
        if v.type_id == 2 then
            if not self.allActBaby[v.gender] then
                self.allActBaby[v.gender] = {}
            end

            if not self.allActBaby[v.gender][v.id] then
                self.allActBaby[v.gender][v.id] = {}
            end

            local actTab = String2Table(v.active)
            if not table.isempty(actTab) then
                if not self.itemIds[actTab[1][1]] then
                    self.itemIds[actTab[1][1]] = actTab[1][2]
                end
            end
            local rewardTab = String2Table(v.cost)
            if not table.isempty(rewardTab) then
                if not self.itemIds[rewardTab[1]] then
                    self.itemIds[rewardTab[1]] = 1
                end
                if not self.itemIds[rewardTab[2]] then
                    self.itemIds[rewardTab[2]] = 1
                end
            end
        end
    end
end

function BabyModel:InitItemIds()
    local cfg = Config.db_baby
    for i, v in pairs(cfg) do
        if not self.itemIds[v.item] then
            self.itemIds[v.item] = 1
        end
        if not self.itemIds[v.growitem] then
            self.itemIds[v.growitem] = 1
        end
    end
end

function BabyModel:InitBabyTaskInfo()
    local taskTab = String2Table(Config.db_baby[1].task)[1]
    for i = 1, #taskTab do
        local taskId = taskTab[i]
        --self.taskInfo[taskId] = TaskModel:GetInstance():GetTask(taskId)
        local info = TaskModel:GetInstance():GetTask(taskId)
        if info then
            self.taskInfo[taskId] = info.count
        else
            self.taskInfo[taskId] = -1
        end
    end
end

function BabyModel:IniEquipLvRedPoint()
    for i = 1, #BabyModel.slotList do
        if not self.babyToysRedPoints[BabyModel.slotList[i]] then
            self.babyToysRedPoints[BabyModel.slotList[i]] = false
        end
    end
end

function BabyModel:InitOrderRedPoint()
    self.babyOrderRedPoints = {}
    for i = 1, 2 do
        for id, v in pairs(self.allBaby[i]) do
            self.babyOrderRedPoints[id] = {}
            self.babyOrderRedPoints[id][1] = false
            self.babyOrderRedPoints[id][2] = false
        end
        for id, v in pairs(self.allActBaby[i]) do
            self.babyOrderRedPoints[id] = {}
            self.babyOrderRedPoints[id][1] = false
            self.babyOrderRedPoints[id][2] = false
        end
    end
end

function BabyModel:GetBabyInfo(gender)
    for i, v in pairs(self.babies) do
        if gender == v.gender then
            return v
        end
    end
    return nil
end

function BabyModel:GetIsHide()
    return self.isHide
end

function BabyModel:GetPlayBabyTimes(gender)
    for i, v in pairs(self.babies) do
        if gender == v.gender then
            return v.play
        end
    end
    return 0
end


--是否出生
function BabyModel:IsBirth(gender)
    if not self.progress[gender] then
        return false
    end
    local cfg = Config.db_baby[gender]
    if cfg then
        local req = cfg.reqs
        if self.progress[gender] >= req then
            return true
        end
    end
    return false
end

--获取出生进度
function BabyModel:GetBirthPro(gender)
    local pro = 0
    if not self.progress[gender] then
        return pro
    end
    return self.progress[gender]
end

--通过ID获取进阶信息
function BabyModel:GetOrderInfo(id)
    -- self.orderBabies
    for i, v in pairs(self.orderBabies) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function BabyModel:GetShowBaby()
    return self.figure
end

--通过ID获取子女名字
function BabyModel:GetBabyName(id)
    local info = self:GetOrderInfo(id)
    if not info then
        --
        local key = tostring(id) .. "@" .. "0"
        local cfg = Config.db_baby_order[key]
        return cfg.name
    end
    local key = tostring(info.id) .. "@" .. tostring(info.order)
    return Config.db_baby_order[key].name
end

function BabyModel:GetBabyInfoAndCfg(id)
    local info = self:GetOrderInfo(id)
    local cfg
    if not info then
        --
        local key = tostring(id) .. "@" .. "0"
        cfg = Config.db_baby_order[key]
        --  return cfg.name
    else
        local key = tostring(info.id) .. "@" .. tostring(info.order)
        cfg = Config.db_baby_order[key]
    end
    return cfg, info
end

function BabyModel:GetBabySkills(id)
    local tab = {}
    for key, v in pairs(Config.db_baby_order) do
        local arr = string.split(key, "@")
        local skillTab = String2Table(v.skill)
        if tonumber(arr[1]) == id and #skillTab > 0 then
            table.insert(tab, v)
        end
    end
    table.sort(tab, function(a, b)
        return a.skill < b.skill
    end)
    return tab
end

function BabyModel:GetGender()

end

function BabyModel:GetSelectId(type, gender)
    local gender
    local babyId
    --local tab = self.allBaby
    --if type == 2 then
    --    tab = self.allActBaby
    --end
    for id, v in table.pairsByKey(self.babyOrderRedPoints) do
        local cfg, info = self:GetBabyInfoAndCfg(id)
        if not info then
            if type == cfg.type_id then
                if cfg.type_id == 1 then
                    --进阶
                    if cfg.order == 0 and cfg.front_id == 0 then
                        local babyCfg = Config.db_baby[cfg.gender]
                        local itemID = babyCfg.item
                        local num = BagModel:GetInstance():GetItemNumByItemID(itemID)
                        if num >= 1 then
                            return cfg.gender, cfg.id
                        end
                    end
                else
                    --活动的
                    local itemTab = String2Table(cfg.active)
                    local itemId = itemTab[1][1]
                    local itemIdNub = itemTab[1][2]
                    local num = BagModel:GetInstance():GetItemNumByItemID(itemId)
                    if num >= itemIdNub then
                        return cfg.gender, cfg.id
                    end
                end
            end
        else
            local nextKey = tostring(cfg.id) .. "@" .. tostring(cfg.order + 1)
            local nextCfg = Config.db_baby_order[nextKey]
            if type == cfg.type_id and nextCfg then
                if info.exp < cfg.exp then
                    gender = cfg.gender
                    babyId = id
                    return gender, babyId
                end
            end
        end

    end

    return 0, 0
end

function BabyModel:IsLvMax(babyInfo)
    local lv = babyInfo.level
    local NextLvKey = tostring(babyInfo.gender) .. "@" .. tostring(babyInfo.level + 1)
    local NextLvCfg = Config.db_baby_level[NextLvKey]
    local key = tostring(babyInfo.gender) .. "@" .. tostring(babyInfo.level)
    local cfg = Config.db_baby_level[key]
    if not NextLvCfg and self.info.exp >= cfg.exp then
        return true
    end
    return false
end

function BabyModel:IsOrderMax(orderCfg, info)
    local key = tostring(orderCfg.id) .. "@" .. tostring(orderCfg.order + 1)
    local cfg = Config.db_baby_order[key]
    if (orderCfg.next_id > 0 and info.exp >= orderCfg.exp) or (not cfg and orderCfg.next_id <= 0) then
        return true
    end
    return false

end

function BabyModel:CheckCulRedPoint()
    local id = RoleInfoModel:GetInstance():GetMainRoleId() or "00"
    local time = CacheManager:GetInstance():GetInt("babyShow" .. id, 0)
    local last_zero_time
    if time ~= 0 then
        --有缓存
        last_zero_time = TimeManager:GetZeroTime(time)
    else
        last_zero_time = os.time()
    end
    local cur_time = os.time()
    local cur_zero_time = TimeManager:GetZeroTime(cur_time)

    if cur_zero_time == last_zero_time then
        self.babyShowRed = false
    else
        self.babyShowRed = true
    end

    self.babyCulRedPoints = {} --养育红点
    self.isRecordRedPoint = false
    for gender, v in pairs(self.allBaby) do
        self.babyCulRedPoints[gender] = {}
        self.babyCulRedPoints[gender][1] = false  --培养
        self.babyCulRedPoints[gender][2] = false  --逗宝宝
        self.babyCulRedPoints[gender][3] = false   --任务
        local babyInfo = self:GetBabyInfo(gender)
        --培养
        if babyInfo and self:IsLvMax(babyInfo) == false then
            local itemID = Config.db_baby[gender].growitem
            local num = BagModel:GetInstance():GetItemNumByItemID(itemID)
            if num > 0 then
                --有培养道具
                self.babyCulRedPoints[gender][1] = true  --一键培养
            end
        end
        --逗宝宝
        if babyInfo then
            local playTimes = babyInfo.play
            local playRewardCount = Config.db_baby[gender].play_count --有奖励次数
            if playTimes < playRewardCount then
                self.babyCulRedPoints[gender][2] = true
            end
        end
        --任务
        local isTaskRed = false
        local taskTab = String2Table(Config.db_baby[gender].task)[1]
        for i = 1, #taskTab do
            local taskId = taskTab[i]
            local info = TaskModel:GetInstance():GetTask(taskId)
            if info then
                if info.state == enum.TASK_STATE.TASK_STATE_FINISH then
                    isTaskRed = true
                end
            end
        end
        self.babyCulRedPoints[gender][3] = isTaskRed
    end

    for i, v in pairs(self.recordsInfo) do
        if v.state == 0 then
            self.isRecordRedPoint = true
        end
    end

    local tab = Config.db_baby_wing_morph

    for i, v in pairs(tab) do
        local k, n = self:GetWingByID(i)
        local idx = i .. "@" .. n
        local c = Config.db_baby_wing_star[idx]
        local cost = String2Table(c.cost)
        local num = BagModel:GetInstance():GetItemNumByItemID(cost[1]) or 0
        local nedNum = cost[2]

        if n < 5 and num >= nedNum then
            self.babyWingRedPoints[i] = true
        else
            self.babyWingRedPoints[i] = false
        end
        self.babyWingNum[i] = num
    end

    self:CheckOrderRedPoint()
    self:CheckToysRedPoint()
    self:UpdateRedPoint()
    -- self:UpdateRedPoint()
    -- dump(self.babyCulRedPoints)
end

function BabyModel:CheckOrderRedPoint()
    for id, v in pairs(self.babyOrderRedPoints) do
        local cfg, info = self:GetBabyInfoAndCfg(id)
        self.babyOrderRedPoints[id][1] = false
        self.babyOrderRedPoints[id][2] = false
        if not info then
            if cfg.type_id == 1 then
                --进阶

                if cfg.order == 0 and cfg.front_id == 0 then
                    local babyCfg = Config.db_baby[cfg.gender]
                    local itemID = babyCfg.item
                    local num = BagModel:GetInstance():GetItemNumByItemID(itemID)
                    if num >= 1 then
                        self.babyOrderRedPoints[id][1] = true
                    end
                end
            else
                --活动的
                --   self.babyOrderRedPoints[id][1] = false
                local itemTab = String2Table(cfg.active)
                local itemId = itemTab[1][1]
                local itemIdNub = itemTab[1][2]
                local num = BagModel:GetInstance():GetItemNumByItemID(itemId)
                if num >= itemIdNub then
                    self.babyOrderRedPoints[id][1] = true
                end
            end
        else

            if not self:IsOrderMax(cfg, info) then
                local itemTab = String2Table(cfg.cost)
                local itemId1 = itemTab[1]
                local itemId2 = itemTab[2]
                --  logError(BagModel:GetInstance():GetItemNumByItemID(itemId1),BagModel:GetInstance():GetItemNumByItemID(itemId2))
                if BagModel:GetInstance():GetItemNumByItemID(itemId1) >= 1 or BagModel:GetInstance():GetItemNumByItemID(itemId2) >= 1 then
                    self.babyOrderRedPoints[id][2] = true
                end
            end
        end
    end
    --   dump(self.babyOrderRedPoints)
    --self:UpdateRedPoint()
end

function BabyModel:CheckToysRedPoint()
    -- self.babyToysRedPoints = {} --强化
    self.isPutOn = false
    if not table.isempty(self.equipsInfo) then
        for slot, v in pairs(self.equipsInfo) do
            self.babyToysRedPoints[slot] = false
            local id = v.id
            local upLevel = v.extra
            local cfg = Config.db_baby_equip_level[slot .. "@" .. upLevel]
            if cfg then
                local cost = String2Table(cfg.cost)
                --local money = cost[1][1]
                local num = cost[1][2]
                local myMoney = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
                if myMoney >= num then
                    self.babyToysRedPoints[slot] = true
                    --self.babyToysRedPoints[1] = true
                    --break
                end
            end

        end
    end

    --for i = 1, #self.slotList do
    --    local slot = self.slotList[i]
    --    local equip = self:GetPutOnBySlot(slot)
    --    if not equip then --没穿戴
    --
    --    end
    --end

    -- dump(self.babyToysRedPoints)

end

function BabyModel:UpdateRedPoint()
    local isRed = false
    --培养界面红点
    for gender, reds in pairs(self.babyCulRedPoints) do
        for i, v in pairs(reds) do
            if v == true then
                isRed = true
                break
            end
        end
    end
    local isRed2 = false
    --进阶界面
    for id, reds in pairs(self.babyOrderRedPoints) do
        for i, v in pairs(reds) do
            if v == true then
                isRed2 = true
                break
            end
        end
    end
    local isRed3 = false

    for i, v in pairs(self.babyToysRedPoints) do
        if v == true then
            isRed3 = true
            break
        end
    end

    local isRed4 = false
    for i, v in pairs(self.babyWingRedPoints) do
        if v == true then
            isRed4 = true
            break
        end
    end
    local is_show = false
    if self:IsBirth(1) or self:IsBirth(2) then
        is_show = isRed or isRed2 or isRed3 or isRed4 or self.babyShowRed
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 68, isRed4)
    else
        self.babyShowRed = false
        is_show = isRed or isRed2
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "baby", is_show or self.isRecordRedPoint)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 46, isRed)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 47, isRed2)

    self:Brocast(BabyEvent.UpdateRedPoint)
end

function BabyModel:DealEquipsInfo(equips)
    for i, v in pairs(equips) do
        -- if not self.model.orderBabies[v.id] then
        local cfg = Config.db_baby_equip[v.id]
        local slot = cfg.slot
        self.equipsInfo[slot] = v
        --  end
    end
end


--当前部位是否穿戴
function BabyModel:GetPutOnBySlot(slot)
    --equipsInfo
    for i, v in pairs(self.equipsInfo) do
        if slot == i then
            return v
        end
    end
    return nil
end

function BabyModel:GetMinSlot()
    for i = 1, #BabyModel.slotList do
        local slot = BabyModel.slotList[i]
        if self:GetPutOnBySlot(slot) then
            return slot
        end
    end
    return 0
end

--玩具是否最大等级
function BabyModel:IsMaxUpLv(pItem)
    local upLevel = pItem.extra
    local equipCfg = Config.db_baby_equip[pItem.id]
    local slot = equipCfg.slot
    local upKey = slot .. "@" .. upLevel + 1
    local cfg = Config.db_baby_equip_level[upKey]
    if not cfg then
        return true
    end
    return false
end

function BabyModel:GetAllPower()
    local power = 0
    for i, v in pairs(self.equipsInfo) do
        power = power + v.equip.power
    end
    return power
end

function BabyModel:GetEquipSelect(uid, color)
    --local tab = {}
    local equips = BagModel:GetInstance().babyItems
    for i, v in pairs(equips) do
        --local cfg = Config.db_item[v.id]
        --if cfg.color == color and v.uid  then
        --    table.insert(tab,v)
        --end
        if v.uid == uid then
            local cfg = Config.db_item[v.id]
            if cfg.color <= color then
                return true
            end
        end
    end
    return false
end

function BabyModel:SetEquipSelect(uid, select)
    -- self.selectEquip
    local hasUid = false
    for i, v in pairs(self.selectEquip) do
        if v == uid then
            hasUid = true
            break
        end
    end
    if select then
        if not hasUid then
            table.insert(self.selectEquip, uid)
            -- self:Brocast(BagEvent.SetSellMoney)
        end
    else
        if hasUid then
            table.removebyvalue(self.selectEquip, uid)
            -- self:Brocast(BagEvent.SetSellMoney)
        end
    end
end

function BabyModel:GetEquipId(uid)
    local equips = BagModel:GetInstance().babyItems
    for i, v in pairs(equips) do
        if v.uid == uid then
            return v.id
        end
    end
    return 0
end

function BabyModel:GetEquipInBag(slot)
    local tab = {}
    local equips = BagModel:GetInstance().babyItems
    for i, v in pairs(equips) do
        local id = v.id
        local cfg = Config.db_baby_equip[id]
        if cfg then
            if slot == cfg.slot then
                table.insert(tab, v)
            end
        end
    end
    return tab
end

function BabyModel:CheckIsBatterEquip()
    if self:IsBirth(1) or self:IsBirth(2) then
        self.isBatterEquip = false
        for i = 1, #self.slotList do
            local slot = self.slotList[i]
            local equipTab = self:GetEquipInBag(slot)
            if not table.isempty(equipTab) then
                local equip = self:GetPutOnBySlot(slot)
                if not equip then
                    --没穿戴
                    self.isBatterEquip = true
                else
                    local color = Config.db_item[equip.id].color
                    for i, v in pairs(equipTab) do
                        local id = v.id
                        if Config.db_item[id].color > color then
                            self.isBatterEquip = true
                            break
                        end
                    end
                end
            end
        end
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 61, self.isBatterEquip)
    end
end


-- 宝宝翅膀幻化

function BabyModel:SetWingInfo(info)
    if self.wingInfo then
        self.wingInfo = nil
        self.wingInfo = {}
    end

    self.wingInfo.show_id = info.show_id

    for k, v in pairs(info.ids) do
        self.wingInfoList[k] = v
    end
end

function BabyModel:GetWingIsShowByid(id)
    if self.wingInfo then
        return self.wingInfo.show_id == id
    end
end

function BabyModel:GetWingShowId()
    return self.wingInfo.show_id
end

function BabyModel:GetWingByID(id)
    if self.wingInfo then
        for i, v in pairs(self.wingInfoList) do
            if i == id then
                return true, v
            end
        end
        return false, 0
    end
end

function BabyModel:GetNeedNum(id)
    for i, v in pairs(self.babyWingNum) do
        if i == id then
            return v
        end
    end
end

function BabyModel:GetEquipNum(id)
    local equips = BagModel:GetInstance().babyItems
    local num = 0
    for i, v in pairs(equips) do
        if id == v.id then
            num = num + v.num
        end
    end
    return num
end