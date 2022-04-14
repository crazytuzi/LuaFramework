---
--- Created by  Administrator
--- DateTime: 2020/7/23 9:38
---
ToemsModel = ToemsModel or class("ToemsModel", BaseBagModel)
local ToemsModel = ToemsModel

ToemsModel.allBeasts = {};
ToemsModel.currentBeastEquip = 0;
ToemsModel.strengthColor = 2;
ToemsModel.maxColor = 6;
ToemsModel.beastItemDatas = {}

function ToemsModel:ctor()
    ToemsModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function ToemsModel:Reset()
    self.red_dot_list = {}
    self.max_summon = 0;
    self.items = {};
    --物品数据,按照顺序存取
    self.beastItemDatas = {}

    self.equipBeasts = {}
    --镶嵌在身上的装备
    --以神兽的id作为key,最长共5个装备
    self.EmbedEquips = {};
    --最大可出战数量
    self.max_summon = 0;

    self.currentBeastEquip = 0;

    self.strengthColor = 2;
    self:InitBeasts()
end

function ToemsModel:GetInstance()
    if ToemsModel.Instance == nil then
        ToemsModel()
    end
    return ToemsModel.Instance
end


function ToemsModel:InitBeasts()
    self.allBeasts = {};
    for k, v in pairs(Config.db_totems) do
        table.insert(self.allBeasts, v);
    end
    table.sort(self.allBeasts, OrderCompareFun);
end


function ToemsModel:GetCurrentDefaultSlot()
    if self.red_dot_list[3] then
        if self.red_dot_list[3][self.currentBeastEquip] then
            for i = 1, 5 do
                if self.red_dot_list[3][self.currentBeastEquip][i] then
                    return i;
                end
            end

        end
    end

    return nil;
end

function ToemsModel:IsFullAssist()
    local summonNum = 0;
    for k, v in pairs(self.EmbedEquips) do
        if v.summon then
            summonNum = summonNum + 1;
        end
    end
    --最大出战了
    if summonNum == self.max_summon then
        return true;
    end
    return false;
end


function ToemsModel:SetItemsByQulityAndStar(qulity, star)
    self.equipBeasts = {}
    local beastItems = {}
    local allbeastItems = BagModel.Instance.bags[BagModel.toems].bagItems
    for i, v in pairs(allbeastItems or {}) do
        if type(v) == "table" then
            local itemCfg = Config.db_item[v.id]
            if itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
                table.insert(beastItems, v)
            end
        end
    end
    if qulity == 0 and star == 0 then
        for i, v in pairs(beastItems) do
            if type(v) == "table" then
                table.insert(self.equipBeasts, v)
            end
        end
    else
        for i, v in pairs(beastItems or {}) do
            if type(v) == "table" then
                local itemCfg = Config.db_item[v.id]
                local equipCfg = Config.db_totems_equip[v.id]
                if qulity == 0 then
                    if equipCfg.star == star then
                        table.insert(self.equipBeasts, v)
                    end
                elseif star == 0 then
                    if itemCfg.color == qulity then
                        table.insert(self.equipBeasts, v)
                    end
                elseif itemCfg.color == qulity and equipCfg.star == star then
                    table.insert(self.equipBeasts, v)
                end
            end
        end
    end

    BagModel.Instance:ArrangeGoods(self.equipBeasts)
end

function ToemsModel:GetBeastBagItems()
    local bag = BagModel:GetInstance():GetBag(BagModel.toems)
    self.items = bag.items;
    return self.items;
end

function ToemsModel:GetItemDataByUid(uid)
    local allEquip = self:GetBeastBagItems();
    for k, v in pairs(allEquip) do
        if v.uid == uid then
            return v;
        end
    end
    return nil;
end

function ToemsModel:GetAllEquips()
    local tab = {};
    for k, v in pairs(self.EmbedEquips) do
        if v.summon then
            local equips = v.equips;
            for k1, v1 in ipairs(equips) do
                table.insert(tab, v1);
                v1.beastID = k;
            end
            --for i = 1, 5 do
            --    if equips[i] then
            --        table.insert(tab , equips[i]);
            --    end
            --end
        end
    end
    return tab;
end

function ToemsModel:DelectedEmptyItem()
    table.removebyvalue(self.equipBeasts, 0, true)
    table.removebyvalue(self.equipBeasts, nil, true)
    table.removebyvalue(self.beastItemDatas, nil, true)
    table.removebyvalue(self.beastItemDatas, 0, true)

    BagModel.Instance:DeleteEmptyItems(BagModel.toems)
end

function ToemsModel:CheckCanEquip(uid)
    local beastItem = self:GetItemDataByUid(uid);
    if not beastItem then
        return "Can't find the item, please select again";
    end
    local beast = Config.db_totems[self.currentBeastEquip];
    if not beast then
        return "Totem data is abnormal, please try again";
    end
    local beastEquipItem = Config.db_totems_equip[beastItem.id];
    if not beastEquipItem then
        return "Cannot find equipment configuration";
    end

    local itemConfig = Config.db_item[beastItem.id];
    if not itemConfig then
        return "Item configuration not found";
    end
    local beastSlot = String2Table(beast.slot);
    local needColor = 8;
    for k, v in pairs(beastSlot) do
        local key = v[1];
        local value = v[2];
        if key == beastEquipItem.slot then
            needColor = value;
        end
    end
    if itemConfig.color < needColor then
        return beast.name .. "Need to gear" .. "<color=#" .. self.FONTCOLOR[needColor] .. ">" .. enumName.COLOR[needColor] .. tostring(ToemsModel.POS2CHINESE[beastEquipItem.slot]) .. "</color>"
    end
end

function ToemsModel:GetConfig(item_id)
    return Config.db_totems_equip[item_id]
end
function ToemsModel:GetEquipCanPutOn(equipId)
    return true
end
function ToemsModel:GetEquipScoreInCfg(equipId)
    local score = 0
    local equip = Config.db_totems_equip[equipId]
    local equipBaseTbl = String2Table(equip.base)
    for i, v in pairs(equipBaseTbl) do
        score = score + v[2] * Config.db_totems_equip_score[v[1]].ratio
    end

    return math.floor(score)
end

function ToemsModel:GetPutOn(equip_cfg_id)
    local equip = nil
    local equipCfg = Config.db_totems_equip[equip_cfg_id]
    if equipCfg == nil then
        return nil
    else

        local equipsTbl = self.EmbedEquips[self.currentBeastEquip] or {}
        local equips = equipsTbl.equips or {}
        for i, v in pairs(equips) do
            local _beastEquipCfg = Config.db_totems_equip[v.id]
            if _beastEquipCfg.slot == equipCfg.slot then
                -- v.id ~= equip_cfg_id and
                equip = v
                break
            end
        end
    end

    return equip
end

function ToemsModel:GetItemByUid(uid)
    local beastDatas = BagModel.Instance:GetBag(BagModel.toems)
    beastDatas = beastDatas or {}
    if table.isempty(beastDatas) then
        return nil
    end
    return beastDatas.items[uid]
end

function ToemsModel:defaultStrengthColor(color)
    if color then
        CacheManager:GetInstance():SetInt("ToemsModel.DefaultStrengthColor", color);
    else
        color = CacheManager:GetInstance():GetInt("ToemsModel.DefaultStrengthColor", self.strengthColor);
    end
    return color;
end
function ToemsModel:defaultStrengthSelect(value)
    if value then
        value = value == 1 and 1 or 0;
        CacheManager:GetInstance():SetInt("ToemsModel.defaultStrengthSelect", value);
    else
        value = CacheManager:GetInstance():GetInt("ToemsModel.defaultStrengthSelect", 1);
    end
    return value;
end

function ToemsModel:SetItemsByLessQuality(quality, selectedQuality)
    selectedQuality = selectedQuality or quality;
    selectedQuality = selectedQuality > quality and quality or selectedQuality;
    self.beastItemDatas = {}
    local beastItems = BagModel.Instance.bags[BagModel.toems].bagItems

    for i, v in pairs(beastItems) do
        local itemCfg = Config.db_item[v.id]
        if itemCfg.color <= quality then
            table.insert(self.beastItemDatas, v)
        end
        if itemCfg.color <= selectedQuality then
            self:SetItemSelect(v.uid, true)
        else
            self:SetItemSelect(v.uid, false)
        end
    end

    BagModel.Instance:ArrangeGoods(self.beastItemDatas)
end
--设置出售项是否选中
function ToemsModel:SetItemSelect(uid, select)
    local hasUid = false
    for i, v in pairs(self.ItemsUid) do
        if v == uid then
            hasUid = true
            break
        end
    end

    if select then
        if not hasUid then
            table.insert(self.ItemsUid, uid)
            --self:Brocast(BagEvent.SetSellMoney)
        end
    else
        if hasUid then
            table.removebyvalue(self.ItemsUid, uid)
            --self:Brocast(BagEvent.SetSellMoney)
        end
    end
end

--删除选中的uid
function ToemsModel:DelSelectItemByUid(uid)
    for i, v in pairs(self.ItemsUid) do
        if uid == v then
            table.removebyvalue(self.ItemsUid, v)
            break
        end
    end
end

function ToemsModel:GetItemSelect(uid)
    local select = false
    for i, v in pairs(self.ItemsUid) do
        if v == uid then
            select = true
        end
    end

    return select
end
function ToemsModel:GetBeastIDByItemUid(uid)
    for k, v in pairs(self.EmbedEquips) do
        local equips = v.equips;
        for k1, v1 in ipairs(equips) do
            if v1.uid == uid then
                return k;
            end
        end
    end
    return nil;
end

function ToemsModel:IsMainReddot()
    if self.red_dot_list[2] then
        return true;
    end

    --for k, v in pairs(self.red_dot_list[2]) do
    --    if v then
    --        return true;
    --    end
    --end
    for k, v in pairs(self.red_dot_list[1]) do
        if v then
            return true;
        end
        --for k1, v1 in pairs(v) do
        --    if v1 then
        --        return true;
        --    end
        --end
    end
    for k, v in pairs(self.red_dot_list[3]) do
        for k1, v1 in pairs(v) do
            if v1 then
                return true;
            end
        end
    end

    for k, v in pairs(self.red_dot_list[4]) do

        if self:GetCanEquipReddot(k) then
            return true;
        end
        --local canUpdate = 0;
        --
        --for k1, v1 in pairs(v) do
        --    if v1 then
        --        canUpdate = canUpdate + 1;
        --    end
        --end
        --if canUpdate >= 1 then
        --    return true;
        --end
    end

    return false;
end

function ToemsModel:GetCanEquipReddot(id)
    id = id or self.currentBeastEquip;
    --local flag = true;
    local is5equip = false;
    if self.EmbedEquips[id] then
        local equips = self.EmbedEquips[id].equips;
        if table.nums(equips) == 5 then
            return false;
        end
        local index = 0;
        for i = 1, 5 do
            if self.red_dot_list[4][id][i] or self:IsPosHasEquip(id, i) then
                index = index + 1;
            end
        end
        if index >= 5 then
            return true;
        end
    else
        local index = 0;
        for i = 1, 5 do
            if self.red_dot_list[4][id][i] then
                index = index + 1;
            end
        end
        if index >= 5 then
            return true;
        end
    end

    return false;
end

function ToemsModel:IsPosHasEquip(beastID, pos)
    if self.EmbedEquips[beastID] then
        local equips = self.EmbedEquips[beastID].equips;
        if equips and equips[pos] then
            return true
        end
    end
    return false;
end

function ToemsModel:GetSummonReddot(id)
    id = id or self.currentBeastEquip;
    if self.red_dot_list and self.red_dot_list[1] and self.red_dot_list[1][id] then
        return true;
    end
    return false;
end

function ToemsModel:GetCanUpdateReddot(id)
    id = id or self.currentBeastEquip;
    local flag = false;
    for k, v in pairs(self.red_dot_list[3][id]) do
        if v then
            return true;
        end
    end
    return false;
end


function ToemsModel:UpdateReddot()
    self.red_dot_list = {};
    self.red_dot_list[1] = {};
    if not self:IsFullAssist() then
        self:UpdateAssistReddot();
    end
    self.red_dot_list[3] = {};
    self.red_dot_list[4] = {};
    self:UpdateBetterEquip();

    local isMainReddot = self:IsMainReddot();

    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "totems", isMainReddot )--主菜单
    self:Brocast(ToemsEvent.UpdateRedDot);

end


--物品改变需要更新
function ToemsModel:UpdateStengthReddot(item)
    self.red_dot_list[2] = false;
    local defaultColor = self.maxColor - self:defaultStrengthColor();
    local num = 0;
    local allbeastItems = self:GetBeastBagItems();
    for k, v in pairs(allbeastItems) do
        local itemConfig = Config.db_item[v.id];
        if itemConfig then
            if itemConfig.color <= defaultColor then
                --and self:CalcItemExp(v) > 10
                --self.red_dot_list[2] = true;
                num = num + 1;
            end
        end
    end
    if num >= 10 then
        self.red_dot_list[2] = true;
    end
    --end
end


--可助战红点
function ToemsModel:UpdateAssistReddot()
    self.red_dot_list[1] = {};

    --k是神兽ID,V
    for k, v in pairs(self.allBeasts) do
        local beast = self.EmbedEquips[k] or {};
        local equips = beast.equips or {};
        local allEquip = true;
        for i = 1, 5 do
            if not equips[i] then
                allEquip = false;
            end
        end

        if not beast.summon and allEquip then
            self.red_dot_list[1][k] = true;
        end
    end

end


function ToemsModel:UpdateBetterEquip()
    --k是神兽ID,V
    for k, v in pairs(self.allBeasts) do
        local beast = self.EmbedEquips[k] or {};
        local equips = beast.equips or {};
        self.red_dot_list[3][k] = {};
        self.red_dot_list[4][k] = {};
        if not self:IsFullAssist() then
            for i = 1, 5 do
                local equip = equips[i];
                if equip then
                    --有更好的装备
                    if self:IsBetterEquip(equip) then
                        self.red_dot_list[3][k][i] = true;
                    end
                    --self.red_dot_list[4][k][i] = true;
                else
                    --有可穿的装备
                    if self:IsSlotBetterEquip(k, i) then
                        self.red_dot_list[4][k][i] = true;
                    end
                end
            end
        end
    end
end

function ToemsModel:IsBetterEquip(item)
    local itemConfig = Config.db_totems_equip[item.id];
    if not itemConfig then
        return false;
    end
    local allbeastItems = self:GetBeastBagItems();
    for k, v in pairs(allbeastItems) do
        local itemConfig1 = Config.db_beast_equip[v.id];
        --if itemConfig1 and itemConfig1.score > itemConfig.score then
        --    return true;
        --end
        if itemConfig1 and itemConfig1.slot == itemConfig.slot and v.score > item.score then
            return true;
        end
    end
    return false;
end

function ToemsModel:IsSlotBetterEquip(beastID, slot)
    local needColor = 8;
    local beastConfig = Config.db_totems[beastID];
    if beastConfig then
        local slotColorTab = String2Table(beastConfig.slot)
        for k, v in pairs(slotColorTab) do
            if v[1] == slot then
                needColor = v[2];
            end
        end
    end
    local allbeastItems = self:GetBeastBagItems();
    for k, v in pairs(allbeastItems) do
        local equipConfig = Config.db_totems_equip[v.id];
        local itemConfig = Config.db_item[v.id];
        if equipConfig and equipConfig.slot == slot and itemConfig and itemConfig.color >= needColor then
            return true;
        end
    end
end



ToemsModel.help=
[[
    Anyhow write
]]

ToemsModel.text =
{
    tips = "Notice",
    Ok = "Yes",
    center = "Cancle",
    des = "You will sell a precious alien equipment, confirm the sale?"
}


ToemsModel.ItemsUid = {}
ToemsModel.POS2CHINESE = {
    [1] = "Burning Heart",
    [2] = "Rock Heart",
    [3] = "Wave Heart",
    [4] = "Purple Heart",
    [5] = "Jasper Heart",
}

ToemsModel.FONTCOLOR = {
    [1] = "dbdbdb", --dbdbdb--666666
    [2] = "98e42b",
    [3] = "4B8DD2", --72f4f9
    [4] = "914eec",
    [5] = "f38034",
    [6] = "f34343",
    [7] = "e705af",

}