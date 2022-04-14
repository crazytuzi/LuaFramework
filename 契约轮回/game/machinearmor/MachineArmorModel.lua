---
--- Created by  Administrator
--- DateTime: 2019/12/19 14:55
---
MachineArmorModel = MachineArmorModel or class("MachineArmorModel", BaseBagModel)
local MachineArmorModel = MachineArmorModel

function MachineArmorModel:ctor()
    MachineArmorModel.Instance = self
    self:Reset()
end

MachineArmorModel.lvCost = {57000,57001,57002}


MachineArmorModel.slotList = {7001,7002,7003,7004,7005}
--- 初始化或重置
function MachineArmorModel:Reset()
    self.allMechas = {}
    self:InitAllMechas()
    self.starRedPoints = {}
    self.equipRedPoints = {}
    self.lvRedPoints = {}
    self.isBatterEquip = {}

    self.mechas = {}
    self.usedMecha = -1  --当前出站的机甲
    self.curMecha = -1  --当前选中的机甲Id
    self.isOpenDecompose = false
    self.openEquipType = 1
    self.currentIndex = -1
    self.equipsInfo = {}
    self.slotLocks = {}
    self.selectEquip = {}
    self.redPoints = {}
end

function MachineArmorModel:GetInstance()
    if MachineArmorModel.Instance == nil then
        MachineArmorModel()
    end
    return MachineArmorModel.Instance
end

function MachineArmorModel:InitAllMechas()
    local cfg = Config.db_mecha
    for i, v in pairs(cfg) do
        if v.show ~= 0 then
            if not self.allMechas[v.id] then
                self.allMechas[v.id] = {}
            end
        end
    end
end


--处理服务器返回机甲信息
function MachineArmorModel:DealMechaInfo(data)
    self.usedMecha =  data.use_id
   -- logError(self.usedMecha)
    for i, v in pairs(data.mechas) do
        self.mechas[v.id] = v
    end
   -- self.mechas = data.mechas
end

--通过Id获取机甲信息
function MachineArmorModel:GetMecha(id)
    return self.mechas[id]
    --for i, v in pairs(self.mechas) do
    --    if i == id then
    --        return v
    --    end
    --end
    --return nil
end

function MachineArmorModel:SetMechaInfo(mecha)
    self.mechas[mecha.id] = mecha
end

function MachineArmorModel:IsActive(id)
    local data = self:GetMecha(id)
    if not data then
        return false
    end
    local key = tostring(id).."@"..data.star
    local curCfg  = Config.db_mecha_star[key]
    if curCfg.star_client < 0 then --未激活
        return false
    end
    return true
end

function MachineArmorModel:IsCanClick(index)
    if not self:IsActive(self.curMecha) then
        local des = "Unable to upgrade this mecha - inactive"
        if index == 3 then
            des = "Unable to upgrade this mecha - inactive"
        end
        return des
    end
end

function MachineArmorModel:DealEquipInfo(data)
    --self.equipsInfo
    if not self.equipsInfo[data.id] then
        self.equipsInfo[data.id] = {}
    end
    for i, v in pairs(data.equips) do
        local cfg = Config.db_mecha_equip[v.id]
        local slot = cfg.slot
        self.equipsInfo[data.id][slot] = v
    end

    if not self.slotLocks[data.id] then
        self.slotLocks[data.id] = {}
    end
    if not table.isempty(data.slots) then
        for i, v in pairs(data.slots) do
            self.slotLocks[data.id][i] = v
        end
    end
end

--当前部位是否穿戴
function MachineArmorModel:GetPutOnBySlot(id,slot)
    --equipsInfo
    local tab = self.equipsInfo[id]
    --logError(Table2String(self.equipsInfo))
    if not table.isempty(tab) then
        for i, v in pairs(tab) do
            if slot == i then
                return v
            end
        end
    end
    return nil

end

function MachineArmorModel:GetSlotLock(id,slot)
    local isLock = false
    local tab = self.slotLocks[id]
    for i, v in pairs(tab) do
        if slot == i then
            if v == 1 then
                return true
            end
        end
    end
    return false
end

function MachineArmorModel:isSlotLock(id,slot)
    local cfg = Config.db_mecha_equip_open[tostring(id).."@"..slot]
    if cfg then
        local openTab = String2Table(cfg.open)
        if table.isempty(openTab) then
            return false
        end
        if openTab[1] == "star" then
            local  mecha = self:GetMecha(id)
            if  mecha  then
                --local key = id.."@"..  mecha.star
                --local starCfg = Config.db_mecha_star[key]
                if mecha.star >= openTab[2] then
                    return false
                end
            end

        end
    end
    return true
end


--装备是否最大等级
function MachineArmorModel:IsMaxUpLv(pItem)
    local upLevel = pItem.extra
    local equipCfg = Config.db_mecha_equip[pItem.id]
    local slot = equipCfg.slot
    local upKey = slot.."@"..upLevel + 1
    local cfg = Config.db_mecha_equip_level[upKey]
    if not cfg then
        return true
    end
    return false
end

function MachineArmorModel:GetMinSlot(id)
    for i = 1, #MachineArmorModel.slotList do
        local slot = MachineArmorModel.slotList[i]
        if self:GetPutOnBySlot(id,slot) then
            return slot
        end
    end
    return 0
end

function MachineArmorModel:SetEquipSelect(uid,select)
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


function MachineArmorModel:GetEquipId(uid)
    local equips = BagModel:GetInstance().mechaItems
    for i, v in pairs(equips) do
        if v.uid == uid then
            return v.id
        end
    end
    return 0
end

function MachineArmorModel:GetEquipOneSelect(uid)
    for i, v in pairs(self.selectEquip) do
        if uid == v then
            return true
        end
    end
    return false
end

--是否是专属装备 返回机甲ID
function MachineArmorModel:isOwnerEquip(equip)
    local cfg = Config.db_mecha_equip[equip]
    if cfg then
        local mecha_id = cfg.mecha_id
        if mecha_id ~= 0 then
            return true,mecha_id
        end
    end
    return false
end

function MachineArmorModel:GetMechaCfg(id)
    local cfg = Config.db_mecha
    for i, v in pairs(cfg) do
        if id == v.id then
            return v
        end
    end
    return nil
end

function MachineArmorModel:CheckRedPoint()
   -- self.redPoints
    self.redPoints[1] = false --升阶红点
    self.redPoints[2] = false  --升級紅點
    self.redPoints[3] = false   --装备升級红点
    self.redPoints[4] = false
    -----升阶红点
    for id, v in pairs(self.allMechas) do
        self.starRedPoints[id] = false
        self.lvRedPoints[id] = false
        local info = self:GetMecha(id)
        if not info then  --沒激活
            local key = tostring(id).."@".."0"
            local curCfg = Config.db_mecha_star[key]
            local costTab = String2Table(curCfg.cost)
            local costid = costTab[1]
            local needNub = costTab[2]
            local num = BagModel:GetInstance():GetItemNumByItemID(costid);
            if num >= needNub then
                self.redPoints[1] = true
                self.starRedPoints[id] = true
            end
        else
            local key = tostring(id).."@"..info.star
            local curCfg = Config.db_mecha_star[key]
            if not self:IsOrderMax(curCfg) then
                local costTab = String2Table(curCfg.cost)
                if table.isempty(costTab) then
                    self.redPoints[1] = true
                    self.starRedPoints[id] = true
                else
                    local costId = costTab[1]
                    local needNub = costTab[2]
                    local num = BagModel:GetInstance():GetItemNumByItemID(costId);
                    if num >= needNub then
                        self.redPoints[1] = true
                        self.starRedPoints[id] = true
                    end
                end
            end
            ---------------升级
            if curCfg.star_client >= 0 then --出生后
                local wash_num = 0  --经验值
                for i = 1, #MachineArmorModel.lvCost do
                    local itemId = MachineArmorModel.lvCost[i]
                    local itemCfg = Config.db_item[itemId]
                    local effect = itemCfg and itemCfg.effect or 0
                    local num = BagModel:GetInstance():GetItemNumByItemID(itemId)
                    wash_num = (num * effect) + wash_num
                end
                local level = info.level
                local exp = info.exp
                local lvCfg = Config.db_mecha_upgrade[level]
                if lvCfg and wash_num >= lvCfg.exp - exp then
                    self.lvRedPoints[id] = true
                    self.redPoints[2] = true
                end

                ------裝備升級
                if not table.isempty(self.equipsInfo[id]) then
                    self.equipRedPoints[id] = {}
                    for slot, v in pairs(self.equipsInfo[id]) do
                        self.equipRedPoints[id][slot] = false
                        -- local id = v.id
                        local upLevel = v.extra
                        local cfg = Config.db_mecha_equip_level[slot.."@"..upLevel]
                        if  cfg then
                            local cost = String2Table(cfg.cost)
                            --local money = cost[1][1]
                            local num = cost[1][2]
                            local myMoney =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.mechaScore) or 0
                            if myMoney >= num then
                                self.equipRedPoints[id][slot] = true
                                self.redPoints[3] = true
                            end
                        end
                    end
                end
                --logError(self.redPoints[3])
                self.isBatterEquip[id] = false
                for i, slot in pairs(MachineArmorModel.slotList) do
                    local equipTab = self:GetEquipInBag(slot)
                    if not table.isempty(equipTab) then
                        local equip = self:GetPutOnBySlot(id,slot)
                        if not self:isSlotLock(id,slot) then
                            if not equip  then --没穿戴
                                for i, v in pairs(equipTab) do
                                    local itemId = v.id
                                    local cfg = Config.db_mecha_equip[itemId]
                                    --if cfg.mecha_id ~= 0 and id == cfg.mecha_id  then --专属机甲
                                    --    self.isBatterEquip[id]= true
                                    --end
                                    if cfg.mecha_id ~= 0 then
                                        if id == cfg.mecha_id  then
                                            self.isBatterEquip[id]= true
                                        end
                                    else
                                        self.isBatterEquip[id]= true
                                    end
                                end
                                self.redPoints[4] = true
                            else
                                local color = Config.db_item[equip.id].color
                                for i, v in pairs(equipTab) do
                                    local itemId = v.id
                                    if Config.db_item[itemId].color > color  then
                                        self.isBatterEquip[id]= true
                                        self.redPoints[4] = true
                                    end
                                end
                            end
                        end
                    end
                end

            end
        end
    end


    --------装备
    --equipsInfo



    local isRed = false
    for i, v in pairs(self.redPoints) do
        if v == true then
            isRed = true
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "machinearmor", isRed)
    GlobalEvent:Brocast(MachineArmorEvent.CheckRedPoint)

    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,69, self.redPoints[1])
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,70, self.redPoints[2])
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,71, self.redPoints[3] or self.redPoints[4])
    ----------------------

end


function MachineArmorModel:IsOrderMax(curCfg)
    local nextKey = tostring(curCfg.id.."@"..tostring(curCfg.star + 1))
    if not Config.db_mecha_star[nextKey] then
        return true
    end
    return false
end

function MachineArmorModel:GetEquipInBag(slot)
    local tab = {}
    local equips = BagModel:GetInstance().mechaItems
    for i, v in pairs(equips) do
        local id = v.id
        local cfg = Config.db_mecha_equip[id]
        if cfg then
            if slot == cfg.slot then
                table.insert(tab,v)
            end
        end
    end
    return tab
end

--ID拿数量
function MachineArmorModel:GetEquipNum(id)
    local equips = BagModel:GetInstance().mechaItems
    local num = 0
    for i, v in pairs(equips) do
        if id == v.id then
            num = num + v.num
        end
    end
    return num
end