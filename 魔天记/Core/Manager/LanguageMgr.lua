LanguageMgr = { }
LanguageMgr.content = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_LANGUAGE); --require "Core.Config.language";

--[[
需要从字典提取的内容  #字典_id#:取字典id的name
ex. 
#npc_130001# - 柳明
#mon_{id}# 取参数id对应的怪物名称
LanguageMgr.Get("杀了那只#mon_{id}#", {id = 120001}) = "杀了那只赤红妖蚁";
]]

LanguageMgr.ds = {
    npc = ConfigManager.CONFIGNAME_NPC;                 --npc
    mon = ConfigManager.CONFIGNAME_MONSTER;             --怪物
    map = ConfigManager.CONFIGNAME_MAP;                 --地图
    item = ConfigManager.CONFIGNAME_PRODUCT;            --物品
    inst = ConfigManager.CONFIGNAME_INSTANCE;           --副本
    skill = ConfigManager.CONFIGNAME_SKILL;             --技能
    attr = "attr";
};

--[[
读取language配置的文本格式,填充参数返回对应的文本内容
ex.
language.lua 里面有配置
["task/reward/chance"] = "完成次数: {num}/{total}";

local str = LanguageMgr.Get("task/reward/chance", {num = 5, total = 10});
log(str);  --"完成次数: 5/10"
]]

local temp = {}

function LanguageMgr.Get(key, data, color)
    local format = LanguageMgr.content[key] or "";
    if(data == nil and color == nil) then
        if( temp[key] == nil) then
            temp[key] = format
        end
        return temp[key]       
    end

    return LanguageMgr.ApplyFormat(format, data, color);
end

--根据参数的键值填充字符串
function LanguageMgr.ApplyFormat(str, data, color)
    for x in string.gmatch(str, "{%w+%}") do
        local field = string.sub(x, 2, #x -1);
        if data and data[field] then 
            str = string.gsub(str, x, data[field]);
        else
            str = string.gsub(str, x, "nil");
        end
    end
    if color then
        str = LanguageMgr.ApplyDictColor(str);
    end
    return LanguageMgr.GetDictLang(str);
end

--[[
因为前后端顺序不一致, 暂时不用.
--根据参数的顺序填充字符串
function LanguageMgr.ApplyFormatByIdx(str, data, color)
    local i = 1;
    for x in string.gmatch(str, "{%w+%}") do
        local field = tonumber(string.sub(x, 2, #x -1));
        if data[field] then 
            str = string.gsub(str, x, data[field]);
        else
            str = string.gsub(str, x, "nil");
        end
    end
    if color then
        str = LanguageMgr.ApplyDictColor(str);
    end
    return LanguageMgr.GetDictLang(str);
end
]]

function LanguageMgr.GetDictLang(str)
    for x in string.gmatch(str, "#%a+_[%w_]+%#") do
        local field = string.sub(x, 2, #x -1);
        local a = string.find(field, "_");
        local tmp = string.sub(field, 1, a -1);
        local key = string.sub(field, a + 1);
        local dName = LanguageMgr.ds[tmp];
        if dName then
            local rep = nil;
            if dName == "attr" then
                rep = LanguageMgr.Get("attr/"..key);
            elseif dName == ConfigManager.CONFIGNAME_SKILL then
                local skCfg = ConfigManager.GetConfig(dName)[key .. "_1"];
                if (skCfg~=nil) then
                    rep = skCfg.name;
                end
            else
                key = tonumber(key);
                local cfg = ConfigManager.GetConfig(dName)[key];
                if (cfg~=nil) then
                    rep = cfg.name;
                end
            end
            
            if rep then
                str = string.gsub(str, x, rep);
            else 
                str = string.gsub(str, x, "null");
            end
        end
    end
    return str;
end

function LanguageMgr.ApplyDictColor(str)
    for x in string.gmatch(str, "#%a+_[%w_]+%#") do
        local field = string.sub(x, 2, #x -1);
        local a = string.find(field, "_");
        local tmp = string.sub(field, 1, a -1);
        local key = string.sub(field, a + 1);
        local rep = LanguageMgr.ApplyColor({tmp,key}, x);
        if rep ~= nil then
            str = string.gsub(str, x, rep);
        end
    end
    return str
end


function LanguageMgr.ApplyColor(keys, str)
    local key = keys[1];
    if key == "item" then
        local itemId = tonumber(keys[2]);
        local cfg = ConfigManager.GetProductById(itemId);
        if (cfg~=nil) then
            return LanguageMgr.GetColor(cfg.quality, str);
        end
    elseif key == "npc" then
        return LanguageMgr.GetColor(1, str);
    elseif key == "mon" then
        return LanguageMgr.GetColor(6, str);
    end
    return nil;
end

function LanguageMgr.GetColor(color, str)
    str = str or "";
    
    if color == "" then
        return str;
    end

    if color == "d" or color == "r" or color == "g" or color == "y" then
        return "[" .. LanguageMgr.Get("color/" .. color) .. "]" .. str .. "[-]";
    end
    return ColorDataManager.GetColorTextByQuality(color, str);
end