TalismanEumn = TalismanEumn or {}

TalismanEumn.Type = {
    Mask = 1,           -- 面罩
    Ring = 2,           -- 指环
    Cloak = 3,          -- 斗篷
    Blazon = 4,         -- 纹章
}

TalismanEumn.Name = {
    [TalismanEumn.Type.Mask] = TI18N("面具"),
    [TalismanEumn.Type.Ring] = TI18N("指环"),
    [TalismanEumn.Type.Cloak] = TI18N("斗篷"),
    [TalismanEumn.Type.Blazon] = TI18N("纹章"),
}

TalismanEumn.ProtoType = {
    [TalismanEumn.Type.Ring] = 147,
    [TalismanEumn.Type.Mask] = 148,
    [TalismanEumn.Type.Cloak] = 149,
    [TalismanEumn.Type.Blazon] = 150,
}

TalismanEumn.TypeProto = {
    [147] = TalismanEumn.Type.Ring,
    [148] = TalismanEumn.Type.Mask,
    [149] = TalismanEumn.Type.Cloak,
    [150] = TalismanEumn.Type.Blazon,
}

TalismanEumn.FlowerColorName = {
    TI18N("白莲"),
    TI18N("青莲"),
    TI18N("红莲"),
    TI18N("紫莲"),
    TI18N("金莲"),
    TI18N("彩莲"),
}

-- 法宝品质
TalismanEumn.Qualify = {
    [2] = "blue",
    [3] = "purple",
    [4] = "orange",
    [5] = "red",
}

TalismanEumn.QualifyName = {
    TI18N(""),
    TI18N(""),
    TI18N("史诗"),
    TI18N("传说"),
    TI18N("神"),
}

function TalismanEumn.FormatQualifyName(qualify, name)
    if qualify == 3 then
        return string.format("[%s]%s", TI18N("史诗"), name)
    elseif qualify == 4 then
        return string.format("[%s]%s", TI18N("传说"), name)
    elseif qualify == 5 then
        return string.format("[%s]%s", TI18N("神"), name)
    end
    return name
end

-- 解析法宝属性的flag 
-- type == 1 返回序号
-- type == 2 返回星数
-- type == 3 返回 1.人物属性 2.宠物属性
function TalismanEumn.DecodeFlag(flag, type)
    if flag == nil then
        return 0
    elseif type == 1 then
        return math.floor(flag /100) % 100
    elseif type == 2 then
        return flag % 100
    elseif type == 3 then
        return math.floor(flag / 10000)
    end
end