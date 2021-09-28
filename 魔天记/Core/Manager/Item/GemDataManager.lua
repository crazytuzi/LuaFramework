require "Core.Info.ProductInfo";

GemDataManager = { };

GemType = {
    HP = 1;
    PHY_ATK = 2;
    MAG_ATK = 3;
    PHY_DEF = 4;
    MAG_DEF = 5;
    MINGZHONG = 6;
    SHANBI = 7;
    BAOJI = 8;
    RENXING = 9;
    BISHA = 10;
    BLOCK = 11;
}

GemDataManager.gemChg = false;
GemDataManager.data = { };       -- 镶嵌数据

GemDataManager.AllGemCfg = nil;
GemDataManager.allGems = { };    -- 背包宝石数组
GemDataManager.dict = { };       -- 背包宝石索引
GemDataManager.cache = {
    -- 背包宝石分档缓存.
    t1 = { },
    t2 = { },
    t3 = { },
    t4 = { },
    t5 = { },
    t6 = { },
    t7 = { },
    t8 = { },
    t9 = { },
    t10 = { },
    t11 = { },
    t12 = { }
};

GemDataManager.MAX = 12;
GemDataManager.MAX_LEV = 12;

local _sortfunc = table.sort 
local insert = table.insert
 
function GemDataManager.Init(slotData)

    GemDataManager.InitDictAllGemsCfg();

    -- 初始化镶嵌孔数据
    GemDataManager.data = { };
    for i, val in ipairs(slotData) do
        GemDataManager.UpdateSlot(val)
    end

    -- 初始化背包里的宝石数据
    GemDataManager.UpdateBag();
end

function GemDataManager.UpdateSlot(equipSlotData)
    local tmp = string.split(equipSlotData.gems, ",");
    for i, v in ipairs(tmp) do
        tmp[i] = tonumber(v);
    end
    GemDataManager.data[equipSlotData.idx + 1] = tmp;
end

function GemDataManager.Reset()
    GemDataManager.allGems = { };
    GemDataManager.dict = { };
    for i = 1, GemDataManager.MAX do
        GemDataManager.cache["t" .. i] = { };
    end
end

-- 检查背包更新的内容
function GemDataManager.CheckBagChg(data)
    local update = false;
    local cfg;
    if (data.a) then
        for i, val in ipairs(data.a) do
            cfg = ConfigManager.GetProductById(val.spId);
            if (cfg ~= nil and cfg.type == 2) then
                update = true;
                break;
            end
        end
    end

    if not update and data.u then
        for i, val in ipairs(data.u) do
            local tmp = BackpackDataManager.GetProductById(val.id);
            if (tmp) then
                cfg = ConfigManager.GetProductById(tmp.spId);
                if (cfg ~= nil and cfg.type == 2) then
                    update = true;
                    break;
                end
            end
        end
    end
    GemDataManager.gemChg = update;
end

-- 更新宝石数据
function GemDataManager.UpdateBag()
    GemDataManager.Reset();
    local data = BackpackDataManager.GetAllProducts(false);
    for k, v in pairs(data) do
        if v:GetType() == 2 then
            local spId = v.spId;           
            local cv = ProductInfo:New()
            cv:Init({id = v.id, spId = spId, am = v.am});
            local g = GemDataManager.dict[spId];
            if g then
                g.am = g.am + cv.am;
            else
                insert(GemDataManager.allGems, cv);
                GemDataManager.dict[spId] = cv;
            end
        end
    end
    -- 按等级排序
    _sortfunc(GemDataManager.allGems, function(a, b) return a:GetLevel() > b:GetLevel() end);
    -- 填入类型缓存字典
    for i, v in ipairs(GemDataManager.allGems) do
        local k = v:GetKind();
        insert(GemDataManager.cache["t" .. k], v);
    end

    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_GEM_CHG);
end

function GemDataManager.GetSlotData(idx)
    -- if SystemManager.IsOpen(SystemConst.Id.Gem) then
    return GemDataManager.data[idx];
    -- end
    -- return {-1, -1, -1, -1};
end

-- 获取宝石列表
function GemDataManager.GetGemList(types, filter)
    local tmp = { };
    local list = { };
    -- 克隆字典数据
    local gems = ConfigManager.Clone(GemDataManager.cache);
    -- 过滤不要的类型
    if filter ~= nil then
        for i, v in ipairs(filter) do
            -- table.remove(gems,i);
            gems["t" .. v] = nil;
        end
    end

    -- 筛选要的类型
    if types ~= nil then
        for i, v in ipairs(types) do
            tmp["t" .. v] = gems["t" .. v];
        end
        gems = tmp;
    end

    for k, gl in pairs(gems) do
        for i, v in ipairs(gl) do
            insert(list, v);
        end
    end
    
    _sortfunc(list, function(a, b) 
        if a:GetLevel() == b:GetLevel() then
            return a:GetKind() < b:GetKind();
        else
            return a:GetLevel() > b:GetLevel();
        end
    end);

    --[[
    -- 按类型顺序重组为数组
    tmp = { };
    for i = 1, GemDataManager.MAX do
        local v = gems["t" .. i];
        if v then
            insert(tmp, v);
        end
    end
    gems = tmp;

    -- 对每个类型数组头位出栈,组档
    local isEnd = false;
    while true do
        isEnd = true
        for i, gs in ipairs(gems) do
            if (table.getn(gs) > 0) then
                local v = gs[1];
                insert(list, v);
                table.remove(gs, 1);
                isEnd = false;
            end
        end
        if isEnd then
            break;
        end
    end
    ]]
    return list;
end

-- 根据类型, 等级获取背包里的宝石
function GemDataManager.GetGemsByTypeAndLev(kind, level)
    local list = GemDataManager.cache["t" .. kind];
    for i, v in ipairs(list) do
        if (v:GetLevel() == level) then
            -- table.insert(tmp, v);
            return v;
        end
    end
    return nil;
end

-- 背包里取宝石
function GemDataManager.GetGemById(spId)
    return GemDataManager.dict[spId];
end

function GemDataManager.GetGemNumById(spId)
    local tmp = GemDataManager.dict[spId];
    return tmp and tmp.am or 0;
end

-- 获取可合成的所有宝石
function GemDataManager.GetAllComposeGems()
    local tmp = { };

    for k, v in pairs(GemDataManager.AllGemCfg) do
        if not tmp[v.kind] then
            tmp[v.kind] = {};
        end

        if v.lev > 1 then
            insert(tmp[v.kind], v);
        end
    end

    for k,v in pairs(tmp) do
        _sortfunc(v, function(a, b) return a.id < b.id end);
    end

    return tmp;
end
-- 获取宝石的属性
function GemDataManager.GetGemAttr(gemId)
    local gemCfg = ConfigManager.GetProductById(gemId);
    local attrCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT_ATTR)[gemId .. "_" .. gemCfg.lev];
    local res = { };
    if (attrCfg) then
        local c = ConfigManager.TransformConfig(attrCfg)
        for att_k, att_v in pairs(c) do
            if att_k ~= "id" and att_k ~= "key" and att_k ~= "level" and att_k ~= "exp" and att_k ~= "money" then
                if att_v > 0 then
                    if res[att_k] == nil then
                        res[att_k] = 0;
                    end
                    res[att_k] = res[att_k] + att_v;
                end
            end
        end
    end
    return res;
end

-- 判断某个宝石能不能升级
function GemDataManager.CanUpgrade(gemId)
    local cfg = ConfigManager.GetProductById(gemId);
    return cfg.lev < GemDataManager.MAX_LEV and GemDataManager.GetGemSubNum(gemId, 2);
end

-- 判断某个宝石能不能合成
function GemDataManager.CanCompose(gemId, num)
    num = num or 1;
    local cfg = ConfigManager.GetProductById(gemId);
    local needGemId = GemDataManager.GetGemsId(cfg.kind, cfg.lev - 1);
    return GemDataManager.GetGemSubNum(needGemId, num * 3);
end

function GemDataManager.GetGemSubNum(gemId, num)
    local cfg = ConfigManager.GetProductById(gemId);
    local count = GemDataManager.GetGemNumById(gemId);
    if count >= num then
        return true;
    else
        if (cfg.lev > 1) then
            local needNum =(num - count) * 3;
            local needGemId = GemDataManager.GetGemsId(cfg.kind, cfg.lev - 1);
            return GemDataManager.GetGemSubNum(needGemId, needNum);
        else
            return false;
        end
    end

end

function GemDataManager.InitDictAllGemsCfg()
    GemDataManager.AllGemCfg = { };
    local dict = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT);
    for k, v in pairs(dict) do
        if (v.type == 2) then
            GemDataManager.AllGemCfg[v.id] = v;
        end
    end
end

-- 根据种类,等级获取宝石id
function GemDataManager.GetGemsId(kind, level)

    for k, v in pairs(GemDataManager.AllGemCfg) do
        if (v.kind == kind and v.lev == level) then
            return v.id;
        end
    end
    return 0;
end

function GemDataManager.OnResult(data, attrChg)
    GemDataManager.UpdateSlot(data);
    if (attrChg) then
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Gem)
    end
    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_GEM_SLOT_CHG, data.idx);

    EquipDataManager.Check_Npoint(EquipNotes.classify_4);
end

-- 给计算人物属性提供接口.
function GemDataManager.GetAllAttrs()
    -- 装备的基础属性
    local res = BaseAdvanceAttrInfo:New()
    for i = 1, 8 do
        local eq = EquipDataManager.GetProductByKind(i);
        if eq ~= nil then
            local slotAttr = GemDataManager.GetSlotGemAttr(i);
            res:Add(slotAttr);
        end
    end
    return res
end

-- 获取某个位置的宝石属性.
function GemDataManager.GetSlotGemAttr(idx)
    local attrs = BaseAdvanceAttrInfo:New()
    local slot = GemDataManager.GetSlotData(idx);
    if slot ~= nil then
        for i, val in ipairs(slot) do
            if (val > 0) then
                local tmp = GemDataManager.GetGemAttr(val);
                for k, v in pairs(tmp) do
                    attrs[k] = attrs[k] + v;
                end
            end
        end
    end
    return attrs;
end

function GemDataManager.GetAllGemLevel()
    local lv = 0;
    for i, v in ipairs(GemDataManager.data) do
        for n, m in ipairs(v) do
            if m > 0 then
                local cfg = ConfigManager.GetProductById(m);
                if cfg then
                    lv = lv + cfg.lev;
                end
            end
        end
    end
    return lv;
end


function GemDataManager.HasGemWithType(gemType)
    local a = GemDataManager.cache["t" .. gemType];
    return a and #a > 0 or false;
end

function GemDataManager.GetGemRedPoint()
    --Warning("GemDataManager.GetGemRedPoint");
    local gemTypes = nil;
    for i = 1, 8 do
        if GemDataManager.GetGemRedPointBySlot(i) then
            return true;
        end
    end
    return false;
end

function GemDataManager.GetGemRedPointBySlot(slotId)
    local eq = EquipDataManager.GetProductByKind(slotId);
    if eq then
        local slot = GemDataManager.GetSlotData(slotId);
        local eq = EquipDataManager.GetProductByKind(slotId);
        local gemTypes = {};
        if eq then
            local cfg = ConfigManager.GetProductById(eq.spId);
            gemTypes = cfg.gemtype;
        end

        if #gemTypes > 0 then
            --空的宝石位检查背包里的是否有相应类型的宝石
            local slotNum = VIPManager.GetMyGemSlotNum();
            for n,m in ipairs(slot) do
                if n <= slotNum then
                    --Warning(n .. " -> " .. m)
                    if m > 0 then
                        if GemDataManager.CanUpgrade(m) or GemDataManager.CanImprove(m) then
                            return true;
                        end
                    else
                        for i, v in ipairs(gemTypes) do
                            --Warning("---->type:" .. v .. " " .. tostring(GemDataManager.HasGemWithType(v)));
                            if GemDataManager.HasGemWithType(v) then
                                return true;
                            end
                        end
                    end
                end
            end
        end
        
    end
    return false;
end

--判断身上是否有更高级的宝石.
function GemDataManager.CanImprove(gemId)
    local cfg = ConfigManager.GetProductById(gemId);
    local level = cfg.lev;
    if level < GemDataManager.MAX_LEV then
        for i = level, GemDataManager.MAX_LEV do
            local list = GemDataManager.cache["t" .. cfg.kind];
            for i, v in ipairs(list) do
                if (v:GetLevel() > level) then
                    return true;
                end
            end
        end
    end

    return false;
end