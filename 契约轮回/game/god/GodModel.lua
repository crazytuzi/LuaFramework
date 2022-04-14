---
--- Created by  Administrator
--- DateTime: 2019/9/6 15:17
---
GodModel = GodModel or class("GodModel", BaseBagModel)
local GodModel = GodModel

GodModel.defaultID = 60000
GodModel.lvCost = {56000,56001,56002}
GodModel.GroupName = {[4] = "Sacred servant",[5] = "Guardian Demon",[6] = "Legend avatar",[7] = "Ancient avatar"}
GodModel.ButtonName ={[4] = "got_btn1",[5] = "got_btn2",[6] = "got_btn3",[7] = "got_btn4"}
GodModel.rightState = false
GodModel.needNum = 1


GodModel.slotList =
{
    [1] = 5002,
    [2] = 5005,
    [3] = 5008,
    [4] = 5001,
    [5] = 5003,
    [6] = 5006,
    [7] = 5009,
    [8] = 5004,
    [9] = 5007,
    [10] = 5010,
}
function GodModel:ctor()
    GodModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function GodModel:Reset()
    self.FoldData = {}
    self.itemsId = {}
    self:InitFoldData()
    self:InitItems()
    self.godRedPoints = {}
    self.starRedPoints = {}
    self.needNum = 1
    self.rightState = false
    self.isOpenDecompose = false
    self.openEquipType = 1
    self.equipsInfo = {}
    self.selectEquip = {}
    self.equipRedPoints = {}
    self.slotLocks = {}
end

function GodModel:GetInstance()
    if GodModel.Instance == nil then
        GodModel()
    end
    return GodModel.Instance
end

function GodModel:InitFoldData()
    local cfg = Config.db_god_morph
    for i, v in pairs(cfg) do
        if v.color ~= 0 then
            if not self.FoldData[v.color] then
                self.FoldData[v.color] = {}
            end
            if not self.FoldData[v.color][v.id] then
                self.FoldData[v.color][v.id] = {}
            end
        end
    end
end

function GodModel:InitItems()
    local cfg = Config.db_god_star
    for i, v in pairs(cfg) do
        local costTab = String2Table(v.cost)
        if not table.isempty(costTab) then
            local id = costTab[1]
            if not self.itemsId[id] then
                self.itemsId[id] = {}
            end
        end
    end
    local cfg2 = Config.db_god_train
    for i, v in pairs(cfg2) do
        if not self.itemsId[i] then
            self.itemsId[i] = {}
        end
    end

    for i = 1, #GodModel.lvCost do
        if not self.itemsId[GodModel.lvCost[i]] then
            self.itemsId[GodModel.lvCost[i]] = {}
        end
    end

end

function GodModel:IniEquipLvRedPoint()
    for i = 1, #GodModel.slotList do
        if not self.equipRedPoints[GodModel.slotList[i]] then
            self.equipRedPoints[GodModel.slotList[i]] = false
        end
    end
end

function GodModel:GetGodName(id)
    local cfg = Config.db_god_morph[id]
    if not cfg then
        logError("不存在ID"..id)
        return
    end
    return cfg.name
end

function GodModel:IsGodActive(godId)
    local info =  MountModel:GetInstance():GetMorphDataByType(enum.TRAIN.TRAIN_GOD,godId)
    if not info then
        return nil
    end
    local key = tostring(godId).."@"..info.star
    local curCfg = Config.db_god_star[key]
    if curCfg.star_client < 0 then
        return nil
    end
    return info
end

function GodModel:CheckRedPoint()
    local data = MountModel:GetInstance().visionData[enum.TRAIN.TRAIN_GOD]
    self.godRedPoints[1] = false --神灵培养丹
    self.godRedPoints[2] = false --神灵升级丹
    self.godRedPoints[3] = false --升阶
    self.godRedPoints[4] = false --装备
    --self.godRedPoints[1] = {}
    --self.godRedPoints[2] = {}
    local cfg1 = Config.db_god_train
    for itemId, v in pairs(cfg1) do
       -- itemId
        local num = BagModel:GetInstance():GetItemNumByItemID(itemId)
        if num > 0 then
            self.godRedPoints[1] = true
            break
        end
    end
   -- if self.godRedPoints[1]  == false then  --条件满足升级丹够升到下一级有红点
        local wash_num = 0  --经验值
        for i = 1, #GodModel.lvCost do
            local itemId = GodModel.lvCost[i]
            local itemCfg = Config.db_item[itemId]
            local effect = itemCfg and itemCfg.effect or 0
            local num = BagModel:GetInstance():GetItemNumByItemID(itemId)
            wash_num = (num * effect) + wash_num
            --if num > 0 then
            --    self.godRedPoints[1] = true
            --    break
            --end
   --     end
        if data then
            local level = data.level
            local exp = data.exp
            local lvCfg = Config.db_god[level]
            if lvCfg and wash_num >= lvCfg.exp - exp then
                self.godRedPoints[2] = true
            end
        end
    end

    for i, ids in pairs(self.FoldData) do
        self.starRedPoints[i] = {}
        for godId, v in pairs(ids) do
            self.starRedPoints[i][godId] = false
            local info = MountModel:GetInstance():GetMorphDataByType(enum.TRAIN.TRAIN_GOD,godId)
            if not info  then --没激活
                local key = tostring(godId).."@".."0"
                local curCfg = Config.db_god_star[key]
                local costTab = String2Table(curCfg.cost)
                local id = costTab[1]
                local needNub = costTab[2]
                local num = BagModel:GetInstance():GetItemNumByItemID(id);
                if num >= needNub then
                    self.godRedPoints[3] = true
                    self.starRedPoints[i][godId] = true
                end
               -- break
            else
                local key = tostring(godId).."@"..info.star
                local curCfg = Config.db_god_star[key]
                if not self:IsOrderMax(curCfg) then
                    local costTab = String2Table(curCfg.cost)
                    if table.isempty(costTab) then
                        self.godRedPoints[3] = true
                        self.starRedPoints[i][godId] = true
                    else
                        local id = costTab[1]
                        local needNub = costTab[2]
                        local num = BagModel:GetInstance():GetItemNumByItemID(id);
                        if num >= needNub then
                            self.godRedPoints[3] = true
                            self.starRedPoints[i][godId] = true
                        end
                       -- break
                    end
                end
            end
        end
    end

    if  not table.isempty(self.equipsInfo) then
        for slot, v in pairs(self.equipsInfo) do
            self.equipRedPoints[slot] = false
            local id = v.id
            local upLevel = v.extra
            local cfg = Config.db_god_equip_level[slot.."@"..upLevel]
            if  cfg then
                local cost = String2Table(cfg.cost)
                --local money = cost[1][1]
                local num = cost[1][2]
                local myMoney =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore)
                if myMoney >= num then
                    self.equipRedPoints[slot] = true
                end
            end
        end
    end
    self:CheckIsBatterEquip()
    if self.isBatterEquip  then
        self.godRedPoints[4] = true
    else
        for i, v in pairs(self.equipRedPoints) do
            if v == true then
                self.godRedPoints[4] = true
                break
            end
        end
    end

    --for i, v in pairs(self.equipRedPoints) do
    --    if v == true then
    --        self.godRedPoints[4] = true
    --        break
    --    end
    --end
    
    


    local isRed = false
    for i, v in pairs(self.godRedPoints) do
        if v == true then
            isRed = true
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "god", isRed)
    GlobalEvent:Brocast(GodEvent.CheckRedPoint)
    if self.godRedPoints[1]== true or self.godRedPoints[2] == true then
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,50,true)
    else
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,50,false)
    end
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,51,self.godRedPoints[3])
    
end

function GodModel:CheckIsBatterEquip()
    self.isBatterEquip = false
    for i = 1, #self.slotList do
        local slot = self.slotList[i]
        local equipTab = self:GetEquipInBag(slot)
        if not table.isempty(equipTab) then
            local equip = self:GetPutOnBySlot(slot)
            if not self:GetSlotLock(slot) then
                if not equip  then --没穿戴
                    self.isBatterEquip = true
                else
                    local color = Config.db_item[equip.id].color
                    for i, v in pairs(equipTab) do
                        local id = v.id
                        if Config.db_item[id].color > color  then
                            self.isBatterEquip = true
                            break
                        end
                    end
                end
            end
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,65,self.isBatterEquip)
end



function GodModel:IsOrderMax(curCfg)
    local nextKey = tostring(curCfg.id.."@"..tostring(curCfg.star + 1))
    if not Config.db_god_star[nextKey] then
        return true
    end
    return false
end

--                                       神灵解封       --
function GodModel:GetDataById(id)
    local list =  OperateModel:GetInstance():GetRewardConfig(171100)
    for i = 1, #list do
        if list[i].id == id then
            return list[i]
        end
    end
end

function GodModel:UpdateGodsData(data)
    self.godsData = data
    self:UpdateMainIcon()
end

function GodModel:UpdateMainIcon()
    if self.godsData then
        self.rightState = false
        local is_red = false
        local tab= self.godsData.tasks
        for i = 1, #tab do
            if tab[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                is_red = true
                self.rightState = false
                break
            end
        end
        if is_red == false then
            local count = BagModel:GetInstance():GetItemNumByItemID(55403);
            is_red = count >= self.needNum
        end
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "godtarget", is_red)
    end
end

function GodModel:DealEquipsInfo(data)
    for i, v in pairs(data.equips) do
        local cfg = Config.db_god_equip[v.id]
        local slot = cfg.slot
        self.equipsInfo[slot] = v
    end

    if not table.isempty(data.slots) then
        for i, v in pairs(data.slots) do
            self.slotLocks[i] = v
        end
    end
end

function GodModel:GetSlotLock(slot)
    local isLock = false
    for i, v in pairs(self.slotLocks) do
        if slot == i then
            if v == 1 then
                return true
            end
        end
    end
    return false
end

function GodModel:GetPutOnBySlot(slot)
    for i, v in pairs(self.equipsInfo) do
        if slot == i then
            return v
        end
    end
    return nil
end

function GodModel:IsMaxUpLv(pItem)
    local upLevel = pItem.extra
    local equipCfg = Config.db_god_equip[pItem.id]
    local slot = equipCfg.slot
    local upKey = slot.."@"..upLevel + 1
    local cfg = Config.db_god_equip_level[upKey]
    if not cfg then
        return true
    end
    return false
end

function GodModel:GetMinSlot()
    for i = 1, #GodModel.slotList do
        local slot = GodModel.slotList[i]
        if self:GetPutOnBySlot(slot) then
            return slot
        end
    end
    return 0
end


function GodModel:GetEquipSelect(uid,color)
    --local tab = {}
    local equips = BagModel:GetInstance().godItems
    for i, v in pairs(equips) do
        if v.uid == uid then
            local cfg = Config.db_item[v.id]
            if cfg.color <= color then
                return true
            end
        end
    end
    return false
end

function GodModel:SetEquipSelect(uid,select)
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

function GodModel:GetEquipOneSelect(uid)
    for i, v in pairs(self.selectEquip) do
        if uid == v then
            return true
        end
    end
    return false
end



function GodModel:GetEquipId(uid)
    local equips = BagModel:GetInstance().godItems
    for i, v in pairs(equips) do
        if v.uid == uid then
            return v.id
        end
    end
    return 0
end

function GodModel:GetAllPower()
    local power = 0
    for i, v in pairs(self.equipsInfo) do
        power = power + v.equip.power
    end
    return power
end
function GodModel:GetEquipInBag(slot)
    local tab = {}
    local equips = BagModel:GetInstance().godItems
    for i, v in pairs(equips) do
        local id = v.id
        local cfg = Config.db_god_equip[id]
        if cfg then
            if slot == cfg.slot then
                table.insert(tab,v)
            end
        end
    end
    return tab
end

function GodModel:GetEquipNum(id)
    local equips = BagModel:GetInstance().godItems
    local num = 0
    for i, v in pairs(equips) do
        if id == v.id then
            num = num + v.num
        end
    end
    return num
end
