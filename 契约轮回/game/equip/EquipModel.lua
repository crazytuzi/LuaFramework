--
-- @Author: chk
-- @Date:   2018-08-29 17:55:56
--

EquipModel = EquipModel or class("EquipModel", BaseModel)

EquipModel.FairyType = {
    Devil = 1,
    Angel = 2,
}

EquipModel.FairyList = {
    [EquipModel.FairyType.Devil] = { 11020143, 11020145 },
    [EquipModel.FairyType.Angel] = { 11020144, 11020146 },
}

function EquipModel:ctor()
    EquipModel.Instance = self
    self:Reset()

    self.equipUpPanelIndex = 1
    self.emoSlot = 1011  --小恶魔部位
    self.notMapCarrerColor = "CE0808FF"

    self.UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    --self:SetOperations()
end

function EquipModel.GetInstance()
    if EquipModel.Instance == nil then
        EquipModel()
    end
    return EquipModel.Instance
end

function EquipModel:ClearData()
    self.outEquipItem = nil
    self.outEquipItemId = nil
end

function EquipModel:Reset()
    self.is_first_return = true

    self.hadRequestEquip = false       --是否请求过身上的装备
    self.equipSlotWeight = {}
    self.operation = {}
    self.operateEquipItem = nil
    self.outEquipItem = nil
    self.outEquipItemId = nil
    self.putOnedEquipList = {}         --身上穿的装备
    self.putOnedEquipDetailList = {}   --身上穿的装备详细信息
    self.sortEquipDetailList = {}      --
    self:SetEquipSlotWeight()
    self.is_checked_fairy = false
    self.is_checked_fairy2 = false
end

--添加穿上的装备
function EquipModel:AddPutOnedEquips(equips)
    --p_item_base
    local str
    for i, v in pairs(equips) do
        Chkprint("装备的id____", v.id)
        local equip = Config.db_equip[v.id]
        v.slot = equip.slot
        if not self.is_first_return then
            if self.putOnedEquipDetailList[equip.slot] then
                --Notify.ShowText("替换成功")
            else
                Notify.ShowText("Equipped")
            end
        end
        self.putOnedEquipList[equip.slot] = v
        self.putOnedEquipDetailList[equip.slot] = v
        GlobalEvent:Brocast(EquipEvent.PutOnEquip, equip.slot, v)
    end

    self:SortPutOnEquip()
end

--添加身上穿的装备的详细信息
function EquipModel:AddPutOnedEquipDetail(equipDetail)
    local equip = Config.db_equip[equipDetail.id]
    self.putOnedEquipDetailList[equip.slot] = equipDetail
end

function EquipModel:DelPutOnEquip(slot)
    self.putOnedEquipList[slot] = nil
    self.putOnedEquipDetailList[slot] = nil
end

function EquipModel:GetEquipBySlot(slot)
    return self.putOnedEquipDetailList[slot]
end

function EquipModel:GetFstSuitEquip()
    local equipDetail = nil
    local equipDetails = self:GetCanSuitEquips()
    for i, v in pairs(equipDetails) do
        equipDetail = v
        break
    end

    return equipDetail
end

--是否穿戴小天使
function EquipModel:GetEquipDevil()
    local equip = self.putOnedEquipDetailList[enum.ITEM_STYPE.ITEM_STYPE_FAIRY]
    if equip and not BagModel:GetInstance():IsExpire(equip.etime) then
        return equip.id
    end
    return nil
end

function EquipModel:GetEquipDevilOrFairy()
    local equip = self.putOnedEquipDetailList[enum.ITEM_STYPE.ITEM_STYPE_FAIRY]
    local equip2 = self.putOnedEquipDetailList[enum.ITEM_STYPE.ITEM_STYPE_FAIRY2]
    if equip and not BagModel:GetInstance():IsExpire(equip.etime) then
        return equip.id
    end
    if equip2 and not BagModel:GetInstance():IsExpire(equip2.etime) then
        return equip2.id
    end

    return nil
end

-- 获取精灵类型，恶魔还是天使
function EquipModel:GetFairyType(item_id)
    for fairy_type, list in pairs(EquipModel.FairyList) do
        for index, id in pairs(list) do
            if item_id == id then
                return fairy_type, index
            end
        end
    end
    return nil
end

-- 获取当前穿戴另外一种精灵的最高级uid
function EquipModel:GetOtherFairyTypeUid()
    local item_id = self:GetEquipDevil()
    local fairy_type = self:GetFairyType(item_id)
    for _fairy_type, list in pairs(EquipModel.FairyList) do
        if _fairy_type ~= fairy_type then
            for i = #list, 1, -1 do
                local id = list[i]
                local uid = BagModel:GetInstance():GetUidByItemID(id);
                if uid then
                    return uid, i
                end
            end
        end
    end
    return nil
end

-- 获取当前穿戴同种精灵的最高级uid
function EquipModel:GetSameFairyTypeMaxUid()
    local item_id = self:GetEquipDevil()
    local fairy_type, index = self:GetFairyType(item_id)
    for _fairy_type, list in pairs(EquipModel.FairyList) do
        if _fairy_type ~= fairy_type then
            for i = #list, index, 1 do
                local id = list[i]
                local uid = BagModel:GetInstance():GetUidByItemID(id);
                if uid then
                    return uid, i
                end
            end
        end
    end
    return nil
end

--[[
  	@author LaoY
  	@des	获取背包的精灵UID
  	@param1 compare_level bool 选填 是否对比各种精灵的等级； 
			true  选取最高级的精灵，如果恶魔和天使同等级，优先选择恶魔
			false 优先选择最高级的恶魔
  --]]
function EquipModel:GetBagFairUid(compare_level)
    local devil_index = 0
    local angel_index = 0
    local devil_uid = nil
    local angel_uid = nil
    for i = 1, #EquipModel.FairyList do
        local fairy_list = EquipModel.FairyList[i]
        for i = #list, 1, -1 do
            local id = list[i]
            local uid = BagModel:GetInstance():GetUidByItemID(id);
            if not compare_level then
                return uid
            else
                if i == EquipModel.FairyType.Devil then
                    devil_index = i
                    devil_uid = uid
                    break
                else
                    if devil_uid and devil_index >= i then
                        return devil_uid
                    end
                    return uid
                end
            end
        end
    end
    return nil
end

function EquipModel:GetEquipIsOn(id)
    local on = false
    for i, v in pairs(self.putOnedEquipDetailList) do
        local equipCfg = Config.db_equip[v.id]
        if equipCfg.id == id then
            on = true
            break
        end
    end

    return on
end

function EquipModel:GetFstMountEquip()
    local equipDetail = nil
    local equipDetails = self:GetCanMountStoneEquips()
    for i, v in pairs(equipDetails) do
        equipDetail = v
        break
    end

    return equipDetail
end

function EquipModel:GetEquipSetSlots(equipSetIdx)
    local equips = {}
    local equipSetTbl = String2Table(Config.db_equip_set[equipSetIdx].slot)
    for i=1, #equipSetTbl do
        local slot = equipSetTbl[i]
        local pitem = self:GetEquipBySlot(slot)
        if pitem then
            equips[#equips+1] = pitem
        end
    end
    return equips
end


--根据部位，获取装备是否可强化
function EquipModel:GetEquipCanStrongBySlot(slot)
    local equipSetTbl = String2Table(Config.db_equip_set[1].slot)
    if table.containValue(equipSetTbl, slot) then
        return true
    end

    return false
end


--获取可以强化的装备
function EquipModel:GetCanStrongEquips()
    return self:GetEquipSetSlots(1)
end

--获取可以铸造的装备
function EquipModel:GetCanCastEquips()
    return self:GetEquipSetSlots(4)
end

--获取可以洗练的装备
function EquipModel:GetCanRefineEquips()
    return self:GetEquipSetSlots(5)
end

--根据部位，获取装备是否可镶嵌
function EquipModel:GetEquipCanStoneBySlot(slot)
    local equipSetTbl = String2Table(Config.db_equip_set[2].slot)
    if table.containValue(equipSetTbl, slot) then
        return true
    end

    return false
end


--获取可以镶嵌宝石/晶石的装备
function EquipModel:GetCanMountStoneEquips()
    return self:GetEquipSetSlots(2)
end

--获取可以做套装的装备
function EquipModel:GetCanSuitEquips()
    return self:GetEquipSetSlots(3)
end

function EquipModel:GetEquipDifTime(send_time, server_time)

    local difTime = send_time - server_time

    if difTime <= 0 then
        return ConfigLanguage.Mix.Expired
    end

    if difTime < 59 then
        return ConfigLanguage.Mix.Just
    end

    local timeTab = TimeManager:GetLastTimeData(server_time, send_time)

    if timeTab then

        local day, hour, minute, sec = "", "", "", ""

        if (timeTab.day) then
            day = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    timeTab.day) .. ConfigLanguage.Mix.Day
        end

        if (timeTab.hour) then
            hour = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    timeTab.hour) .. ConfigLanguage.Mix.Hour
        end

        if (timeTab.min) then
            minute = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    timeTab.min) .. ConfigLanguage.Mix.Minute
        end

        if (timeTab.sec) then
            sec = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    timeTab.sec) .. ConfigLanguage.Mix.Sec
        end

        return day .. hour .. minute .. sec
    end


    --local difDay = TimeManager.Instance:GetDifDay(send_time, server_time)
    --local difTime = server_time - send_time
    --difTime = math.abs(difTime)
    --return self:SplicingDifTime(difDay, difTime)
end

function EquipModel:SplicingDifTime(difDay, difTime)
    if difDay <= 0 then
        if difTime < 59 then
            return ConfigLanguage.Mix.Just
        elseif difTime >= 60 and difTime < 3600 then
            return string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    math.floor(difTime / 60)) .. ConfigLanguage.Mix.Minute .. string.format("<color=#%s>%s</color>",
                    ColorUtil.GetColor(ColorUtil.ColorType.Green), math.floor(difTime % 60))
        else
            local hour = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    math.floor(difTime / 3600)) .. ConfigLanguage.Mix.Hour
            local minute = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    math.floor((difTime % 3600) / 60)) .. ConfigLanguage.Mix.Minute
            local sec = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                    math.floor((difTime % 60))) .. ConfigLanguage.Mix.Sec

            return hour .. minute .. sec
        end
    else
        local day = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green), difDay)
        local hour = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                math.floor(difTime / 3600)) .. ConfigLanguage.Mix.Hour
        local minute = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                math.floor((difTime % 3600) / 60)) .. ConfigLanguage.Mix.Minute
        local sec = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
                math.floor((difTime % 60))) .. ConfigLanguage.Mix.Sec

        return day .. hour .. minute .. sec
    end
end

--根据(配置表中的id)获取身上对应的装备
function EquipModel:GetPutonEquipMap(equipId)
    local equip = Config.db_equip[equipId]
    return self.putOnedEquipDetailList[equip.slot]
end

function EquipModel:GetEquipWakeCfg(career, equipWake)
    --local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    local wakeKey = career .. "@" .. equipWake
    local wakeCfg = Config.db_wake[wakeKey]

    return wakeCfg
end

function EquipModel:GetMapWakeCfg(career)
    local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    local wakeKey = career .. "@" .. roleData.wake
    local wakeCfg = Config.db_wake[wakeKey]

    return wakeCfg
end

--觉醒是否足够
function EquipModel:GetMapCrntCareer(careerNum, equipId)
    local map = false
    local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    local equipCfg = Config.db_equip[equipId]

    if roleData.wake >= equipCfg.wake then
        local wakeCfg = self:GetMapWakeCfg(careerNum)
        if type(wakeCfg) == "table" then
            map = true
        end
    end

    return map
end

function EquipModel:GetAttrTypeInfo(attr, attrValue)
    local attrCfg = Config.db_attr_type[attr]
    if attrCfg ~= nil and attrCfg.type == 1 then
        return "+" .. attrValue
    end

    return "+" .. (attrValue / 10000) * 100 .. "%"
end

--不带+号
function EquipModel:GetAttrTypeInfo2(attr, attrValue)
    local attrCfg = Config.db_attr_type[attr]
    if attrCfg ~= nil and attrCfg.type == 1 then
        return attrValue
    end

    return (attrValue / 10000) * 100 .. "%"
end


--获取该装备是否符合当前职业
function EquipModel:GetEquipIsMapCareer(equipId)
    local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    local equipConfig = Config.db_equip[equipId]
    if not equipConfig then
        return false
    end
    local careers = string.split(equipConfig.career, ",")
    local map = false
    for i, v in pairs(careers) do
        if tonumber(v) == 0 then
            map = true
            break
        elseif tonumber(v) == roleData.career then
            map = true
            break
        end
    end

    return map
end

local function get_attr_value(rare, attr_id)
    for _, v in pairs(rare) do
        if v[1] == attr_id then
            return v[2]
        end
    end
end

function EquipModel:GetEquipScore(equipId)
    local equipcfg = Config.db_equip[equipId]
    local base = String2Table(equipcfg.base)
    local other = String2Table(equipcfg.attr)
    local rare1 = String2Table(equipcfg.rare1)
    local rare2 = String2Table(equipcfg.rare2)
    local rare3 = String2Table(equipcfg.rare3)
    local basescore = 0
    for i=1, #base do
        local attr = base[i]
        local attr_id = attr[1]
        local attr_value = attr[2]
        local coef = (Config.db_attr_type[attr_id] and Config.db_attr_type[attr_id].coef or 0)
        basescore = basescore + coef * attr_value
    end
    
    local function get_score(attr_id)
        local scorecfg = Config.db_equip_score[attr_id]
        local QualityList = String2Table(scorecfg.quality_ratio)
        local ratio = scorecfg.ratio
        local color = Config.db_item[equipId].color
        local attr_balue = (get_attr_value(rare1, attr_id) or get_attr_value(rare2, attr_id) or get_attr_value(rare3,attr_id) or 0)
        local ratio2 = 0
        for _, v in pairs(QualityList) do
            if v[1] == color then
                ratio2 = v[2]
                break
            end
        end
        return math.ceil(basescore * attr_balue * ratio/10000)
            + math.ceil(basescore * attr_balue * ratio2)
    end
    local score = 0
    for _, v in pairs(other) do
        score = score + get_score(v)
    end
    return math.ceil(basescore + score)
end

function EquipModel:GetBeastEquipScore(equipId)
    local equipcfg = Config.db_beast_equip[equipId]
    local base = String2Table(equipcfg.base)
    local other = String2Table(equipcfg.attr)
    local rare1 = String2Table(equipcfg.rare1)
    local rare2 = String2Table(equipcfg.rare2)
    local basescore = 0
    for i=1, #base do
        local attr = base[i]
        local attr_id = attr[1]
        local attr_value = attr[2]
        local coef = (Config.db_beast_equip_score[attr_id] and Config.db_beast_equip_score[attr_id].ratio or 0)
        basescore = basescore + coef * attr_value
    end
    for _, attr_id in pairs(other) do
        local attr_value = (get_attr_value(rare1, attr_id) or get_attr_value(rare2, attr_id) or 0)
        local coef = (Config.db_beast_equip_score[attr_id] and Config.db_beast_equip_score[attr_id].ratio or 0)
        basescore = basescore + coef * attr_value
    end
    return math.ceil(basescore)
end

function EquipModel:GetTosmsEquipScore(equipId)
    local equipcfg = Config.db_totems_equip[equipId]
    local base = String2Table(equipcfg.base)
    local other = String2Table(equipcfg.attr)
    local rare1 = String2Table(equipcfg.rare1)
    local rare2 = String2Table(equipcfg.rare2)
    local basescore = 0
    for i=1, #base do
        local attr = base[i]
        local attr_id = attr[1]
        local attr_value = attr[2]
        local coef = (Config.db_totems_equip_score[attr_id] and Config.db_totems_equip_score[attr_id].ratio or 0)
        basescore = basescore + coef * attr_value
    end
    for _, attr_id in pairs(other) do
        local attr_value = (get_attr_value(rare1, attr_id) or get_attr_value(rare2, attr_id) or 0)
        local coef = (Config.db_totems_equip_score[attr_id] and Config.db_totems_equip_score[attr_id].ratio or 0)
        basescore = basescore + coef * attr_value
    end
    return math.ceil(basescore)
end


function EquipModel:GetEquipDetailScore(equip)
    local score = 0
    if not table.isempty(equip.base) then
        for i, v in pairs(equip.base) do
            local aa = Config.db_equip_score[i]
            score = score + v * Config.db_equip_score[i].ratio
        end
    end

    if not table.isempty(equip.rare1) then
        for i, v in pairs(equip.rare1) do
            score = score + v * Config.db_equip_score[i].ratio
        end
    end

    if not table.isempty(equip.rare2) then
        for i, v in pairs(equip.rare2) do
            score = score + v * Config.db_equip_score[i].ratio
        end
    end

    if not table.isempty(equip.rare3) then
        for i, v in pairs(equip.rare3) do
            score = score + v * Config.db_equip_score[i].ratio
        end
    end

    return score
end

function EquipModel:SetEquipSlotWeight()
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_WEAPON] = 1
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_DEPUTY] = 2
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_HELMET] = 3
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_CLOTH] = 4
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_PANTS] = 5
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_GLOVE] = 6
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_SHOES] = 7
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_NECK] = 8
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_RING1] = 9
    self.equipSlotWeight[enum.ITEM_STYPE.ITEM_STYPE_RING2] = 10
end

function EquipModel:SortPutOnEquip()
    self.sortEquipDetailList = {}
    for i, v in pairs(self.putOnedEquipDetailList) do
        table.insert(self.sortEquipDetailList, v)
    end

    local function callBack(equip1, equip2)
        if equip1 ~= nil and equip2 ~= nil then
            local equip1Config = Config.db_equip[equip1.id]
            local equip2Config = Config.db_equip[equip2.id]

            if self.equipSlotWeight[equip1Config.slot] ~= nil and self.equipSlotWeight[equip2Config.slot] ~= nil then
                return self.equipSlotWeight[equip1Config.slot] < self.equipSlotWeight[equip2Config.slot]
            end
        end
    end

    table.sort(self.sortEquipDetailList, callBack)
end

function EquipModel:TranslateAttr(attr_map)
    local attrs = {}
    for attr_name, v in pairs(attr_map) do
        local index = GetAttrMapIndexByKey(attr_name)
        if v ~= 0 and type(v) ~= "table" then
            attrs[index] = v
        end
    end

    return attrs
end

--格式化属性
--param:string
--return:k,v对应的属性
function EquipModel:FormatAttr(attr_str)
    local attr = String2Table(attr_str)
    local result = {}
    for k, v in pairs(attr) do
        if type(v) == "table" then
            result[v[1]] = v[2]
        else
            result[k] = v
        end
    end
    return result
end

function EquipModel:UpdateEquipDetail(equip)
    local equipConfig = Config.db_equip[equip.id]
    if equipConfig ~= nil then
        self.putOnedEquipDetailList[equipConfig.slot] = equip
        self:SortPutOnEquip()
        GlobalEvent:Brocast(EquipEvent.UpdateEquipDetail, equip)
    else
        Chkprint("chk EquipModel UpdateEquipDetail 57_ 没有装备id为" .. equip.id .. "的配置表")
    end
end





--套装相关


--判断该装备是否可打造套装
--equipDetail  服务器发的p_item
--suitLv 套装等级
function EquipModel:GetCanBuildSuit(equipDetail, suitLv)
    return EquipSuitModel.Instance:GetCanBuildSuit(equipDetail, suitLv)
end

--获取该装备激活的套装等级
-- equip_item 服务器发的p_item
function EquipModel:GetShowSuitLvByEquip(equip_item)
    return EquipSuitModel.Instance:GetShowSuitLvByEquip(equip_item)
end

--获取激活套装的数量
--slot 部位
--order 阶位
--suitLv 套装等级
function EquipModel:GetActiveSuitCount(slot, order, suitLv)
    return EquipSuitModel.Instance:GetActiveSuitCount(slot, order, suitLv)
end

--获取套装配置信息
--slot 部位
--order 阶位
--suitLv 套装等级
function EquipModel:GetSuitConfig(slot, order, suitLv)
    return EquipSuitModel.Instance:GetSuitConfig(slot, order, suitLv)
end

--获取套装数量
--slot 部位
--order 阶位
--suitLv 套装等级
function EquipModel:GetSuitCount(slot, order, suitLv)
    return EquipSuitModel.Instance:GetSuitCount(slot, order, suitLv)
end

--获取套装是否激活
-- slot 部位
--suitLv 套装等级
function EquipModel:GetActiveByEquip(slot, suitLv)
    return EquipSuitModel.Instance:GetActiveByEquip(slot, suitLv)
end

--获取套装等级(类别)名字
-- suitLv 套装等级(类别)
function EquipModel:GetSuitLvName(suitLv)
    return EquipSuitModel.Instance:GetSuitLvName(suitLv)
end

--是否匹配职业
function EquipModel:GetMatchSex(item_id)
    local match = false
    local iconTbl = LuaString2Table("{" .. Config.db_item[item_id].icon .. "}")
    if type(iconTbl) == "table" then
        local roleData = RoleInfoModel.Instance:GetMainRoleData()
        for i, v in pairs(iconTbl) do
            if i == roleData.gender then
                match = true
                break
            end
        end

        return match
    else
        return true
    end
end







