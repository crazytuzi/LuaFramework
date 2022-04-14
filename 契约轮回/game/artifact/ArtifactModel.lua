---
--- Created by  Administrator
--- DateTime: 2020/6/17 14:56
---
ArtifactModel = ArtifactModel or class("ArtifactModel", BaseBagModel)
local ArtifactModel = ArtifactModel

ArtifactModel.money =
{
    [1] = {[1] = Constant.GoldType.artScore1 , [2] = enum.ITEM.ITEM_ELEMENT_1 },
    [2] =  {[1] = Constant.GoldType.artScore2 , [2] = enum.ITEM.ITEM_ELEMENT_2 },
    [3] =  {[1] = Constant.GoldType.artScore3 , [2] = enum.ITEM.ITEM_ELEMENT_3 },
    [4] =  {[1] = Constant.GoldType.artScore4 , [2] = enum.ITEM.ITEM_ELEMENT_4 },
    [5] = {[1] = Constant.GoldType.artScore5 , [2] = enum.ITEM.ITEM_ELEMENT_5 },

}
function ArtifactModel:ctor()
    ArtifactModel.Instance = self
    self:Reset()

end

--- 初始化或重置
function ArtifactModel:Reset()
    self.FoldData = {}
    self.curPanel = 1
    self:InitFoldData()
    self.artielemsInfo = {}
    self.artis = {}
    self.curArtId = 0
    self.curPItem = nil
    self.isOpenUpPanel = false
    self.selectEquip = {}
    self.redPoints = {}
end

function ArtifactModel:GetInstance()
    if ArtifactModel.Instance == nil then
        ArtifactModel()
    end
    return ArtifactModel.Instance
end

function ArtifactModel:InitFoldData()
    local cfg = Config.db_artifact_unlock
    for i, v in pairs(cfg) do
        if not self.FoldData[v.type] then
            self.FoldData[v.type] = {}
        end
        if not self.FoldData[v.type][v.aid] then
            self.FoldData[v.type][v.aid] =  v
        end
    end
end

function ArtifactModel:GetArtifactName(id)
    local cfg = Config.db_artifact_unlock[id]
    if  cfg then
        return cfg.name
    end
    return nil
end

function ArtifactModel:GetTypeName(type)
    local cfg = Config.db_artifact_unlock
    for i, v in pairs(cfg) do
        if v.type == type then
            return v.will_name
        end
    end
    return nil
end

function ArtifactModel:GetArtiInfo(id)
    for i, v in pairs(self.artis) do
        if id == v.id then
            return v
        end
    end
    return nil
end

function ArtifactModel:IsArtiLock(type)
    for i, v in pairs(self.artis) do
        local cfg = Config.db_artifact_unlock[v.id]
        if type == cfg.type then
            return false
        end
    end
    return true
end

function ArtifactModel:DealArtielemInfo(data)
    self.artielemsInfo[data.type] = {}
    for i = 1, #data.elems do
        table.insert(self.artielemsInfo[data.type],data.elems[i])
    end
end

function ArtifactModel:GetArtielemTab(type)
    return self.artielemsInfo[type]
end

function ArtifactModel:GetArtielemInfo(type,id)
    if not self.artielemsInfo[type] then
        return nil
    end
    for i, v in pairs(self.artielemsInfo[type]) do
        if id == v.id then
            return v
        end
    end
    return nil
end

function ArtifactModel:GetArtielemLv(type,id)
    local info = self:GetArtielemInfo(type,id)
    if not info then
        return 0
    end
    return info.level
end




function ArtifactModel:SetUpGradeInfo(data)
    --local tab = self.artielemsInfo[data.arti_type]
    --if not self.artielemsInfo[data.arti_type] then
    --    self.artielemsInfo[data.arti_type] = {}
    --    table.insert(self.artielemsInfo[data.arti_type],{id = data.elem_id,level = 1})
    --end

    local boo = false
    local id = data.elem_id
    for i = 1, #self.artielemsInfo[data.arti_type] do
        if id == self.artielemsInfo[data.arti_type][i].id then
            boo = true
            self.artielemsInfo[data.arti_type][i].level = self.artielemsInfo[data.arti_type][i].level + 1
        end
    end
    if not boo then
        table.insert(self.artielemsInfo[data.arti_type],{id = data.elem_id,level = 1})
    end
end

function ArtifactModel:GetEquipInfo(id,slot)
    local artInfo = self:GetArtiInfo(id)
    if not artInfo then
        return nil
    end
    for i, v in pairs(artInfo.equips) do
        if i == slot then
            return v
        end
    end
    return nil
end

function ArtifactModel:AddEquip(data)
    for i = 1, #self.artis do
        if self.artis[i].id == data.arti_id then
            if not self.artis[i].equips  then
                self.artis[i].equips = {}
            end
            self.artis[i].equips[data.slot_id] = self.curPItem
        end
    end
end

function ArtifactModel:RemoveEquip(data)
    for i = 1, #self.artis do
        if self.artis[i].id == data.arti_id then
            --if not self.artis[i].equips  then
            --    self.artis[i].equips = {}
            --end
            self.artis[i].equips[data.slot_id] =  nil
        end
    end
end

function ArtifactModel:IsPutOnEquipInfo(id)
    local artInfo = self:GetArtiInfo(id)
    if not artInfo then
        return false
    end
    if table.isempty(artInfo.equips)  then
        return false
    end
    return true
end

function ArtifactModel:GetPutOnEquipIds(id)
    local tab = {}
    local artInfo = self:GetArtiInfo(id)
    if not artInfo then
        return nil
    end
    if table.isempty(artInfo.equips) then
        return nil
    end
    for i, v in pairs(artInfo.equips) do
        table.insert(tab,v.id)
    end
    return tab
end

function ArtifactModel:GetPunOnEquip(id,slot)
    local artInfo = self:GetArtiInfo(id)
    if not artInfo then
        return nil
    end
    if table.isempty(artInfo.equips) then
        return nil
    end
    for i, v in pairs(artInfo.equips) do
        if slot == i then
            return v
        end
    end
    return nil
end

function ArtifactModel:SetAriLv(data)
    for i = 1, #self.artis do
        if self.artis[i].id == data.arti_id then
            self.artis[i].reinf_lv = data.reinf_lv
            self.artis[i].reinf_exp = data.reinf_exp
        end
    end
end

function ArtifactModel:SetEquipSelect(uid,select)
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

function ArtifactModel:GetEquipOneSelect(uid)
    for i, v in pairs(self.selectEquip) do
        if uid == v then
            return true
        end
    end
    return false
end

function ArtifactModel:GetEquipId(uid)
    local equips = BagModel:GetInstance().artifactItems
    for i, v in pairs(equips) do
        if v.uid == uid then
            return v.id
        end
    end
    return 0
end

function ArtifactModel:GetEquipByUid(uid)
    local equips = BagModel:GetInstance().artifactItems
    for i, v in pairs(equips) do
        if v.uid == uid then
            return v
        end
    end
    return nil
end

function ArtifactModel:GetAttrCode(artId,index)
    local cfg = Config.db_artifact_enchant[artId.."@"..index]
    return cfg.attr_code
end

function ArtifactModel:SetEnchant(data)
    for i = 1, #self.artis do
        if self.artis[i].id == data.arti_id then
            if not self.artis[i].enchant  then
                self.artis[i].enchant = {}
            end
            for key, value in pairs(data.enchant) do
                --logError(i,v)
                self.artis[i].enchant[key] = value
            end
        end
    end
end

function ArtifactModel:IsLockEnchant(artId,index)
    local cfg = Config.db_artifact_unlock[artId]
    local info = self:GetArtiInfo(artId)
    --1
    local isLock = false
    if index == 1 then
        local lockTab = String2Table(cfg.unlock1)
        if info and table.nums(info.equips) >= lockTab[1][1] then
            local index = 0
            for i, v in pairs(info.equips) do
                local equipCfg = Config.db_equip[v.id]
                if equipCfg.color >= lockTab[1][2] then
                    index = index + 1
                end
            end
            if index == lockTab[1][1]  then
                isLock = true
            end
        end
    else
       -- local lockTab = String2Table(cfg.unlock1)
        local lockTab = String2Table(cfg["unlock"..index])
        local attrCode = lockTab[1][1]
        local attrValue = lockTab[1][2]
       -- local attrCode = self:GetAttrCode(artId,index)
       -- if not info.enchant[attrCode] then
       --     isLock = true
       -- else
            if info.enchant[attrCode] and info.enchant[attrCode] >= attrValue then
                isLock = true
            end
        --end
    end

    return isLock
end

function ArtifactModel:GetItemNumByItemID(itemID)
    local bagItems = BagModel.GetInstance().artifactItems
    local num = 0
    for i, v in pairs(bagItems) do
        if v ~= 0 and v.id == itemID then
            num = num + v.num
        end
    end
    return num
end

function ArtifactModel:GetItemByUid(uid)
    local items = BagModel.GetInstance().artifactItems
    local  item = nil
    for i, v in pairs(items) do
        if v ~= 0 and v.uid == uid then
            item = v
            break
        end
    end
    return item
end

function ArtifactModel:IsCanEquipByArtId(id,itemID,score)
    local cfg = Config.db_item[itemID]
    if not cfg then
        return false
    end
    local equipCfg = Config.db_equip[itemID]
    if not equipCfg then
        return false
    end
    if id == cfg.stype then
        local slot  = equipCfg.slot
        local equipInfo = self:GetEquipInfo(id,slot)
        if not equipInfo then
            return true
        else
            if score >  equipInfo.score then
                return true
            end
        end
    end
    return false
end

function ArtifactModel:GetLockLv(type)
    local cfg = Config.db_artifact_unlock
    for i, v in pairs(cfg) do
        if v.type == type then
            local tab = String2Table(v.unlock)
            return tab[1][2]
        end
    end
    return nil
end

function ArtifactModel:GetCode(index)
    
end


function ArtifactModel:GetMaxEnchant(id,index,info)
   -- local info = self:GetArtiInfo(id)
    local lv = 0
    if info  then
        lv = info.reinf_lv
    end
    local cfg = Config.db_artifact_reinf[id.."@"..lv]
    local enchantLimt = cfg.enchant  --万分比
    local eCfg = Config.db_artifact_enchant[id.."@"..index]
    return eCfg.attr_max * (enchantLimt/10000)
end

function ArtifactModel:GetMaxEnchant2(id,index)
    local info = self:GetArtiInfo(id)
    local lv = 0
    if info  then
        lv = info.reinf_lv
    end
    local cfg = Config.db_artifact_reinf[id.."@"..lv]
    local enchantLimt = cfg.enchant  --万分比
    local eCfg = Config.db_artifact_enchant[id.."@"..index]
    return eCfg.attr_max * (enchantLimt/10000)
end

function ArtifactModel:GetBaseAttr(id,index)
    local eCfg = Config.db_artifact_enchant[id.."@"..index]
    return eCfg.attr_max
end


function ArtifactModel:IsMaxEnchant(id)
    local info = self:GetArtiInfo(id)
    if not info then
        return false
    end
    if table.nums(info.enchant) <= 0 then
        return false
    end
    local index = 0
    for i = 1, 4 do
       local code =  self:GetAttrCode(id,i)
        if info.enchant[code] and info.enchant[code] >= self:GetMaxEnchant(id,i,info) then
            index = index + 1
        end
    end
    return table.nums(info.enchant) == index
    --for code, value in pairs(info.enchant) do
    --    for i = 1, 4 do
    --        local eCfg = Config.db_artifact_enchant[id.."@"..i]
    --
    --    end
    --end
end



function ArtifactModel:CheckRedPoint()
    self.redPoints[1] = false --元素升级
    self.redPoints[2] = false
    self.redPoints[3] = false
    self.redPoints[4] = false
    self.typeRedPoints = {}
    self.equipRedPoints = {}
    self.upRedPoints = {}
    self.flRedPoints = {}
    --元素
    for type, ids in pairs(self.FoldData) do
        self.typeRedPoints[type] = {}
        self.equipRedPoints[type] = {}
        self.upRedPoints[type] = {}
        self.flRedPoints[type] = {}

        for i = 1, 5 do
            self.typeRedPoints[type][i] = false
            local  info = self:GetArtielemInfo(type,i)
            local key = type.."@"..i.."@"..1
            if info then
                key =  type.."@"..i.."@"..info.level + 1
            end
            local cfg = Config.db_artifact_element[key]
            if cfg then
                local costTab = String2Table(cfg.cost)
                if  table.isempty(costTab) then
                    self.typeRedPoints[type][i] = true
                    self.redPoints[1] = true
                else
                    local id = costTab[1][1]
                    local num = costTab[1][2]
                    local mNum = BagModel:GetInstance():GetItemNumByItemID(id) or 0
                    if mNum >= num then
                        self.typeRedPoints[type][i] = true
                        self.redPoints[1] = true
                    end
                end
            end
        end

        for artId, v in pairs(ids) do
            self.equipRedPoints[type][artId] = {}
            self.upRedPoints[type][artId] = false
            self.flRedPoints[type][artId] = false
            local artInfo = self:GetArtiInfo(artId)
            local lock = self:IsLockEnchant(artId,1)
            if lock and not self:IsMaxEnchant(artId) then
                local cfg = Config.db_artifact_enchant[artId.."@"..1]
                local constTab = String2Table(cfg.cost)
                local  id = constTab[1][1]
                local num  = constTab[1][2]
                local mNum = self:GetItemNumByItemID(id) or 0
                if mNum >= num  then
                    self.flRedPoints[type][artId] = true
                    self.redPoints[4] = true
                end
            end


            local equips = BagModel:GetInstance().artifactItems
            for i = 1, 3 do
                self.equipRedPoints[type][artId][i] = false
                local equip = self:GetPunOnEquip(artId,i)
                if artInfo ~= nil then
                    if not equip then
                        for _, item  in pairs(equips) do
                            local equipCfg = Config.db_equip[item.id]
                            local itemCfg = Config.db_item[item.id]
                            if equipCfg then
                                if equipCfg.slot == i and itemCfg.stype == artId then
                                    self.redPoints[2] = true
                                    self.equipRedPoints[type][artId][i] = true
                                    -- break
                                end
                            end
                        end
                    else
                        for _, item  in pairs(equips) do
                            local equipCfg = Config.db_equip[item.id]
                            local itemCfg = Config.db_item[item.id]
                            if equipCfg then
                                if equipCfg.slot == i and item.score > equip.score and itemCfg.stype == artId then
                                    self.redPoints[2] = true
                                    self.equipRedPoints[type][artId][i] = true
                                    --  break
                                end
                            end
                        end
                    end
                end

            end

            for _, eItem in pairs(equips) do
                --local cfg = Config.db_equip[eItem.id]
                local cfg = Config.db_artifact_reinf
                if artInfo ~= nil  then
                    local cfg = Config.db_artifact_reinf[artId.."@"..artInfo.reinf_lv + 1]
                    if cfg  then
                        local itemCfg = Config.db_item[eItem.id]
                        if (itemCfg.stype == artId and itemCfg.color < 5) or
                                (not string.isempty(itemCfg.effect) and itemCfg.type ~= enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP) then
                            self.upRedPoints[type][artId] = true
                            self.redPoints[3] = true
                            -- break
                        end
                    end
                end

            end
        end
    end
    --装备


    local isRed = false
    for i, v in pairs(self.redPoints) do
        if v == true then
            isRed = true
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "artifact", isRed)
    self:Brocast(ArtifactEvent.UpdateRedPoint)

end


ArtifactModel.desTab=
{
    artielem = "Will",
    equip = "Equip",
    upGrade = "Enhance",
    enchant = "Enchanting",
    selectTex = "Please select the elements to upgrade",
    unLock = "Locked",
    jie = "Tier",
    arrtText = "Divine attributes",
}



ArtifactModel.Help =
[[
    1. Upgrade the five elements of the will to a certain level to unlock the corresponding divine. The unlocked divine can be strengthened and worn with equipment
    2. After wearing three pieces of orange and above quality divine, the divine can unlock the first attribute of the corresponding enchantment, and the following three attributes can only be unlocked after the enchantment has reached a certain number of times.
    3. The upper limit of the initial enchanting attachment of the artifact is 100%, and the upper limit of the enchanting attachment can be unlocked by strengthening the divine
    Corresponding divine enhancement to level 150 can make the upper limit of the corresponding enchantment attribute break to 120%
    Corresponding divine strengthened to 200 can make the upper limit of the corresponding enchantment attribute break to 140%
    Corresponding divine enhancement to level 250 can make the upper limit of the corresponding enchantment attribute break to 160%
    Corresponding divine strengthened to level 300 can make the upper limit of the corresponding enchantment attribute break to 180%
    Corresponding artifact enhancement to level 350 can make the upper limit of the corresponding spirit attribute break to 200%
    Breaking the upper limit does not mean that the attribute can be directly raised to this value, and everyone needs to be enchanted after the breakthrough."
]]




