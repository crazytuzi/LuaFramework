require "Core.Manager.Item.FightingCapacityDataManager";

require "Core.Info.ProductAttrInfo";

ProductInfo = class("ProductInfo");
local insert = table.insert

function ProductInfo:New()
    self = { };
    setmetatable(self, { __index = ProductInfo });
    return self;
end

-- 物品信息
-- {"st":1,"pt":"10100103","id":"1029","am":1,"idx":0,"spId":302002}
function ProductInfo:Init(data)

    self.baseData = data;

    self.st = data.st or 0;
    self.pt = data.pt or 0;
    self.id = data.id or "0";
    self.am = data.am or 1;
    self.idx = data.idx or -1;
    self.spId = data.spId;
    -- self.lev = data.level or 1;
    -- 物品等级不能设置默认值， 如果是空的话， 在GetLevel 函数中会获取配置中的等级
    self.lev = data.level;
    self.fm = data.fm;

    -- 仙兵玄兵 附魔
    self.bind = data.bind or 0;
    self._baseAttr = ProductAttrInfo:New()
    self._baseAttrChange = true;
    -- local config = ProductManager.GetProductById(self.spId)
    self.configData = ProductManager.GetProductById(self.spId);

    self:UpAttribute(0);

    self.kind = self:GetKind();

end




-- 获取 仙兵的 基础属性(包括锻造后的属性)
function ProductInfo:GetWiseEqAllAtt()

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    local att_keys = EquipDataManager.GetWiseEquipAttKeys(my_career, self.kind);
    local basAttList = self:GetPropertyAndDes();

    local lev = 0;
    local att_base_value = 0;

    local res = { };
    local dz_att = nil;

    for key, att_k in pairs(att_keys) do

        att_base_value = self.att_configData[att_k];

        local att = EquipLvDataManager.GetWiseEqAtt(att_k,self.kind) ;
        if att ~= nil then
            -- 属性等级
            lev = att.lev;
            dz_att = EquipDataManager.GetWiseEquip_forging(self.kind, att_k, lev);
            att_base_value = math.floor((att_base_value + dz_att.att_value) *(1 + dz_att.base_attribute_per * 0.01));
        end

        res[att_k] = att_base_value;
    end

    return res;
end

-- 是否已经鉴定 了 仙兵
function ProductInfo:IsHasFairyGroove()
    if self.fm == nil or table.getn(self.fm) <= 0 then
        return false;
    end
    return true;
end

-- 获取仙兵对应的 槽位属性 index [1 6]
-- return nil 表示 没有属性
--[[fm1  --attr_value= [123]
|    --attr_key= [hit]
|    --idx= [1]
|    --max_attr_lev= [50]
]]
function ProductInfo:GetFairyGroove(index)

    if self.fm ~= nil then

        local lv = self:GetLevel();

        for key, value in pairs(self.fm) do
            if tonumber(value.idx) == tonumber(index) and tonumber(value.max_attr_lev) ~= 0 then
                local res = { };
                local fg = EquipDataManager.GetFairyGroove(lv, value.max_attr_lev);

                if fg == nil then
                   Error("获取配置数据出错， 配置表： fairy_groove_value  道具："..self.spId.. " lv "..lv.." max_attr_lev "..value.max_attr_lev);
                end 

                res.att_name = LanguageMgr.Get("attr/" .. value.attr_key);
                res.att_value = value.attr_value;
                res.color = fg.color;
                res.max_attr_lev = value.max_attr_lev;
                res.enchant_cost = fg.enchant_cost;
                res.attr_key = value.attr_key;
                res[res.attr_key] = res.att_value;

                -- 附魔消耗
                return res;
            end
        end
    end
    return nil;
end

-- 仙兵 玄兵 槽位是否有属性
function ProductInfo:IsHasFairyGrooveAtt()
    if self.fm ~= nil then

        for key, value in pairs(self.fm) do
            if value.max_attr_lev > 0 then
                return true;
            end
        end
    end

    return false;
end

-- 对应槽位是否已经开启
function ProductInfo:IsOpenFairyGroove(index)
    local q = self:GetQuality();
    local cf = EquipDataManager.GetFairy_groove_pos(index);
    local quality_req = cf.quality_req;
    return q >= quality_req;
end

function ProductInfo:IsFitMyCareer()
    local career = tonumber(self:Get_career());
    local my_info = HeroController:GetInstance().info;
    local my_career = tonumber(my_info:GetCareer());
    if my_career == career or career == 0 then
        return true;
    end
    return false;
end


function ProductInfo.TryAddAtt(obj, key, addObj)

    if addObj[key] ~= nil then

        if obj[key] == nil then
            obj[key] = 0;
        end

        obj[key] = obj[key] + addObj[key];
    end


end

-- 更新 属性配置表数据 ， st_lv 强化等级
function ProductInfo:UpAttribute(st_lv)
    self.att_configData = self:GetLevelAttData(st_lv);
    self.st_lv = st_lv;

    local ty = self:GetType();

    if ProductManager.type_1 == ty then
        -- 装备只读基础属性
        self.att_configData = self:GetLevelAttData(0);
    end
    self._baseAttr:Init(self.att_configData);
    self._baseAttrChange = true;
end

function ProductInfo:UpStoneAttribute()

    local lv = self:GetBaseConfig()["lev"];
    local att_key = self.spId .. "_" .. lv;
    self.att_configData = self:GetLevelAttData(lv);
    self._baseAttr:Init(self.att_configData);
    self._baseAttrChange = true;
end

function ProductInfo:Get_st_lv(v)

    if self.st_lv == nil then
        self.st_lv = 0;
    end

    return self.st_lv;

end

function ProductInfo:SetLevel(v)
    self.baseData.lev = v;
    self:Init(self.baseData);
end

function ProductInfo:GetLevelAttData(level)


    local att_config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT_ATTR);
    local att_key = self.spId .. "_" .. level;

    return att_config[att_key];

end

function ProductInfo:Clone()
    local res = ProductInfo:New();
    self.baseData.fm = self.fm;
    res:Init(self.baseData);
    return res;
end

function ProductInfo:GetIdx()
    return self.idx
end

function ProductInfo:IsBind()

    if self.bind == 1 then
        return true;
    end
    return false;
end

function ProductInfo:GetId()
    return self.id;
end

function ProductInfo:GetSt()
    return self.st;
end

function ProductInfo:GetStar()

    local star = self.baseData.star;
    if star == nil then
        star = 0;
    end
    return star;
end

function ProductInfo:GetSpId()
    return self.spId;
end

-- 获取物品数量
function ProductInfo:GetAm()
    return self.am;
end

function ProductInfo:GetQuality()

    if self.baseData ~= nil then
        local quality = self.baseData.quality;
        if quality ~= nil then
            return quality;
        end
    end

    return self:GetBaseConfig().quality;
end


function ProductInfo:GetType()
    return self:GetBaseConfig()["type"];
end

function ProductInfo:GetKind()
    return self:GetBaseConfig()["kind"];
end

function ProductInfo:GetCF_CD()
    return self:GetBaseConfig()["cd"];
end

function ProductInfo:Getbind_type()
    return self:GetBaseConfig()["bind_type"];
end

function ProductInfo:GetPrice()
    return self:GetBaseConfig()["price"];
end
function ProductInfo:GetFunPara()
    return self:GetBaseConfig()["fun_para"];
end


function ProductInfo:GetReq_lev()
    return self:GetBaseConfig()["req_lev"];
end

function ProductInfo:GetKindName()
    local kind = self:GetKind();
    local t = self:GetType()
    return ProductManager.GetProductKindName(kind, t)
end

function ProductInfo.GetPTypeName(type)
    return ProductManager.GetPTypeName(type)
end

function ProductInfo:GetTypeName()

    local type = self:GetType();

    return ProductInfo.GetPTypeName(type);

end

function ProductInfo:GetName()
    --[[    if self:GetType() == 1 and self:GetQuality() > 5 then
        return  LanguageMgr.Get("ProductInfo/type_sq_1",{n=self.configData["name"]});

    end
    ]]
    return self:GetBaseConfig()["name"];
end

function ProductInfo:GetDesc()
    return self:GetBaseConfig()["desc"];
end


function ProductInfo:GetLevel()
    if self.lev == nil then
        self.lev = self:GetBaseConfig()["lev"];
    end
    return self.lev;
end

function ProductInfo:GetIcon_id()
    return self:GetBaseConfig()["icon_id"];
end

function ProductInfo:GetCareer()
    return self:GetBaseConfig()["career"];
end

function ProductInfo:GetExp_value()
    return self:GetBaseConfig()["exp_value"];
end


function ProductInfo:Get_career()
    local career = self:GetBaseConfig()["career"];
    return career;
end

function ProductInfo:GetCareerName()
    local career = self:GetBaseConfig()["career"];
    if career == nil or career == 0 then
        return LanguageMgr.Get("ProductInfo/none");
    end
    return ConfigManager.GetCareerByKind(career).career;
end

function ProductInfo:GetIdx()
    return self.idx;
end

-- ------------------ attribute
function ProductInfo:getAttValue(key)

    if self.att_configData ~= nil then
        local v = self.att_configData[key];

        if v == nil then
            return 0;
        end

        return v;
    end
    return 0;
end

function ProductInfo:GetAttLevel()

    return self:getAttValue("level");
end


function ProductInfo:GetBlock()
    return self:getAttValue("block");
end

function ProductInfo:GetBlock_Name()
    return LanguageMgr.Get("attr/block");
end


function ProductInfo:GetFatal()
    return self:getAttValue("fatal");
end

function ProductInfo:GetFatal_Name()
    return LanguageMgr.Get("attr/fatal");
end

function ProductInfo:GetTough()
    return self:getAttValue("tough");
end

function ProductInfo:GetTough_Name()
    return LanguageMgr.Get("attr/tough");
end

function ProductInfo:GetCrit()
    return self:getAttValue("crit");
end

function ProductInfo:GetCrit_Name()
    return LanguageMgr.Get("attr/crit");
end

function ProductInfo:GetEva()
    return self:getAttValue("eva");
end

function ProductInfo:GetEva_Name()
    return LanguageMgr.Get("attr/eva");
end

function ProductInfo:GetHit()
    return self:getAttValue("hit");
end

function ProductInfo:GetHit_Name()
    return LanguageMgr.Get("attr/hit");
end

function ProductInfo:GetMag_def()
    return self:getAttValue("mag_def");
end

function ProductInfo:GetMag_def_Name()
    return LanguageMgr.Get("attr/mag_def");
end

function ProductInfo:GetPhy_def()
    return self:getAttValue("phy_def");
end

function ProductInfo:GetPhy_def_Name()
    return LanguageMgr.Get("attr/phy_def");
end

function ProductInfo:GetMag_att()
    return self:getAttValue("mag_att");
end

function ProductInfo:GetMag_att_Name()
    return LanguageMgr.Get("attr/mag_att");
end


function ProductInfo:GetPhy_att()
    return self:getAttValue("phy_att");
end

function ProductInfo:GetPhy_att_Name()
    return LanguageMgr.Get("attr/phy_att");
end

function ProductInfo:GetMp_max()
    return self:getAttValue("mp_max");
end

function ProductInfo:GetMp_max_Name()
    return LanguageMgr.Get("attr/mp_max");
end

function ProductInfo:GetHp_max()
    return self:getAttValue("hp_max");
end


function ProductInfo:GetHp_max_Name()
    return LanguageMgr.Get("attr/hp_max");
end

-- 获取 物品的战力
function ProductInfo:GetFight()

    -- 只要 _baseAttr 发生改变的时候才会重新计算
    if not self._baseAttrChange and self.currFight ~= nil then

        return self.currFight;
    end

    self._baseAttrChange = false;

    self.currFight = CalculatePower(self._baseAttr);

    return self.currFight;
end

function ProductInfo:GetAttTotal()

    local ownAtts = self:GetBaseAttr():GetAttr();
    local total = 0;

    for k, v in pairs(ownAtts) do
        total = total + v.property;
    end
    return total;

end

--  GetPropertyAndDes
-- 例子 key = hp_max, des = "生命值",property = 100,sign = "%"
function ProductInfo.GetSampleBaseAtt(cf)
    local res = ProductAttrInfo:New();
    res:Init(cf);
    return res:GetPropertyAndDes();
end

function ProductInfo:GetPropertyAndDes()

    if self._baseAttr ~= nil then
        return self._baseAttr:GetPropertyAndDes();
    end

    return { };
end

function ProductInfo:GetBaseAttr()
    return self._baseAttr
end

function ProductInfo:GetBaseConfig()
    if self.configData == nil then
        Error("self.configData == nul spid " .. self.spId);
    end
    return self.configData
end

function ProductInfo:GetIsEquip()
    return self:GetType() == ProductManager.type_1
end


function ProductInfo.IsInExcepts(spId, excepts)

    for key, value in pairs(excepts) do
        if tonumber(value) == tonumber(spId) then
            return true;
        end
    end

    return false;
end

function ProductInfo.AddToList(list, spId, am)

    if list[spId] == nil then
        list[spId] = am;
    else
        list[spId] = list[spId] + am;
    end

end

function ProductInfo.FindInKey(att_keys, key)
    local t_num = table.getn(att_keys);

    for i = 1, t_num do
        if att_keys[i] == key then
            return true;
        end
    end

    return false;
end

function ProductInfo.GetAttByCareer(propertyValues, kind, career)

    if kind == EquipDataManager.KIND_XIANBING or kind == EquipDataManager.KIND_XUANBING then
        local att_keys = EquipDataManager.GetWiseEquipAttKeys(career, kind);

        local t_num = table.getn(propertyValues);
        local res = {};
        for i = 1, t_num do
            local obj = propertyValues[i];
            local b = ProductInfo.FindInKey(att_keys, obj.key);
            if b then
             insert(res, obj);
            end
        end
        return res;
    end
    return propertyValues;
end

-- l1,l2  这样的格式 { spId = 0, am = 0 } -- overlay
-- excepts 除外数据
function ProductInfo.GetProducts(l1, l2, excepts, returnList_max_num, sortFun)

    local res = { };

    for key, value in pairs(l1) do
        local b = ProductInfo.IsInExcepts(value.spId, excepts);
        if not b then
            ProductInfo.AddToList(res, value.spId, value.am);
        end
    end

    for key, value in pairs(l2) do
        local b = ProductInfo.IsInExcepts(value.spId, excepts);
        if not b then
            ProductInfo.AddToList(res, value.spId, value.am);
        end
    end

    local res_list = { };
    local index = 1;
    for spid, am in pairs(res) do
        res_list[index] = ProductManager.GetProductInfoById(spid, am);
        index = index + 1;
    end

    local t_num = table.getn(res_list);
    if t_num > 1 then
        table.sort(res_list, sortFun);
    end

    if t_num > returnList_max_num then

        local res_list1 = { };
        for i = 1, returnList_max_num do
            res_list1[i] = res_list[i];
        end

        return res_list1;
    end


    return res_list;
end

-- l1,l2  这样的格式 {'506030_5','506030_10',,,,}
function ProductInfo.GetProductInfos(rs)
    local t = {}
    for i = 1, #rs do
        local pd = ProductInfo:New()
        local r = string.split(rs[i], '_')
        pd:Init( { spId = tonumber(r[1]), am = tonumber(r[2]) })
        table.insert(t, pd)
    end
    return t
end

-- 这样的格式 '506030_5'
function ProductInfo.GetProductInfo(rs)
    local pd = ProductInfo:New()
    local r = string.split(rs, '_')
    pd:Init( { spId = tonumber(r[1]), am = tonumber(r[2]) })
    return pd
end

