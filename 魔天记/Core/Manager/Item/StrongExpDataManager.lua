StrongExpDataManager = { };
StrongExpDataManager.cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STRONG_EXP);

StrongExpDataManager.equipment_strong = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_EQUIPMENT_STRONG);
StrongExpDataManager.equipment_strong_ratio = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_EQUIPMENT_STRONG_RATIO);

StrongExpDataManager.content = nil;

StrongExpDataManager.FuLingMaxLv = 500; -- 附灵等级最大等级 

function StrongExpDataManager.Init()

    StrongExpDataManager.content = { };

    for key, value in pairs(StrongExpDataManager.cf) do

        local vk = value.kind .. "_" .. value.lev;
        StrongExpDataManager.content[vk] = value;
    end

    StrongExpDataManager.equipment_strongDec = { };
    for key, value in pairs(StrongExpDataManager.equipment_strong) do

        local key = value.career .. "_" .. value.level;
        StrongExpDataManager.equipment_strongDec[key] = value;
    end


    StrongExpDataManager.equipment_strong_ratioDec = { };
    for key, value in pairs(StrongExpDataManager.equipment_strong_ratio) do

        local key = value.quality .. "_" .. value.kind;
        StrongExpDataManager.equipment_strong_ratioDec[key] = value;
    end

end

-- 获取 附灵属性 值
--[[
强化属性
]]
function StrongExpDataManager.GetExtStrongAtt(info, slv)

    if StrongExpDataManager.content == nil then
        StrongExpDataManager.Init();
    end

    local att = { };


    local career = info:Get_career();

    local key1 = career .. "_" .. slv;
    local key2 = info:GetQuality() .. "_" .. info:GetKind();

    local st_data = StrongExpDataManager.equipment_strongDec[key1];
    local st_ra_data = StrongExpDataManager.equipment_strong_ratioDec[key2];

    local attkeys = BaseAttrInfo.GetAttKeys();
    local attkeys_num = table.getn(attkeys);

    for k = 1, attkeys_num do
        StrongExpDataManager.SetAtt(att, attkeys[k], st_data, st_ra_data);
    end

    return att;


end




function StrongExpDataManager.SetAtt(att, key, st_data, st_ra_data)

    if st_data == nil or st_ra_data == nil then
        att[key] = 0;
    else
        att[key] =(st_data[key] * st_ra_data[key]) * 0.001;
    end

    local intV = math.floor(att[key]);
    --[[
   -- local pv = intV + 0.5;
   local pv = intV ;

    if att[key] >= pv then
        att[key] = intV + 1;
    else
        att[key] = intV;
    end
    ]]

    att[key] = intV;
end


function StrongExpDataManager.GetExp(kind, lev)

    if StrongExpDataManager.content == nil then
        StrongExpDataManager.Init();
    end

    local vk = kind .. "_" .. lev;
    --   log(vk);
    local obj = StrongExpDataManager.content[vk];
    return obj.exp;
end

-- 获取 比 max_xep 大， 并且最贴近 的 一个对象
--[[
['key'] = 1,	--唯一标示
		['kind'] = 1,	--部位
		['lev'] = 0,	--强化等级
		['exp'] = 12	--累加经验
]]

--[[
function StrongExpDataManager.GetBagerExp(kind, curr_lv, max_exp)

    if StrongExpDataManager.content == nil then
        StrongExpDataManager.Init();
    end


    local ct = StrongExpDataManager.content;
    local need_exp = 0;

    for i = curr_lv, 100 do
        local vk = kind .. "_" .. i;
        local obj = ct[vk];
        local t_exp = need_exp;
        need_exp = need_exp + obj.exp;
        if need_exp >= max_exp then
            obj.elseExp = max_exp - t_exp;
            return obj;
        end
    end
    return nil;
end
]]

-- 新 的 做发 
--[[
my_lv  当前我的等级
kind 装备类型
curr_slv 当前装备强化等级
curr_exp 当前装备拥有经验
add_exp  可以添加的经验

]]
function StrongExpDataManager.GetBagerExp(my_lv, kind, curr_slv, curr_exp, add_exp)

    -- log("                          ");
    -- log("英雄等级: " .. my_lv .. " 武器kind: " .. kind .. " 当前装备强化等级: " .. curr_slv .. " 当前强化经验: " .. curr_exp .. " 添加强化经验: " .. add_exp);

    if StrongExpDataManager.content == nil then
        StrongExpDataManager.Init();
    end

    local res = { };
    res.upLvInfos = { };
    res.curr_slv = curr_slv;

    local tml = StrongExpDataManager.FuLingMaxLv-1;
    if curr_slv == tml then
        res.canUpLv = false;
        res.canNotType = 1;
        -- 已经是最高等级，不需要升级
    end

    local ct = StrongExpDataManager.content;
    local need_exp = 0;

    --[[
--exp= [36]  --升级到当前等级累加经验
--lev= [1]  强化等级
--key= [2]
--kind= [1]  --1:武器,2:项链,3:戒指,4:护手,5:帽子,6:衣服,7:裤子,8:鞋子


['lev'] = 0,['exp'] = 12	 --升级到当前等级累加经验
['lev'] = 1,['exp'] = 36	 --升级到当前等级累加经验
['lev'] = 2,['exp'] = 72	 --升级到当前等级累加经验
['lev'] = 3,['exp'] = 120	 --升级到当前等级累加经验
['lev'] = 4,['exp'] = 180	 --升级到当前等级累加经验
['lev'] = 5,['exp'] = 252	 --升级到当前等级累加经验

    ]]

    local upLvInfos = { };
    local upLvInfosIndex = 1;

    local vk = "";
    local obj = nil;
    local p_exp = 0;

    local elseBaseExp = curr_exp;
    local elseExp = add_exp;
    res.canUpLv = true;


    ------------------  设置当前等级 和 当前 经验  ------------------------------
    res.curr_slv = curr_slv;
    res.curr_exp = curr_exp;
    vk = kind .. "_" .. curr_slv;

    obj = ct[vk];
    res.curr_parenExp = obj.exp;




    --  my_lv 强化等级 只能 升级到 角色 本身等级
     local maxLv = my_lv-1;
   -- local maxLv = 98;
    -- 现在改成不受角色等级限制 http://192.168.0.8:3000/issues/1983

    local hasUp = false;

    for i = curr_slv, maxLv do
        vk = kind .. "_" .. i;
        obj = ct[vk];
        local needExp = obj.exp;
        local dlv = i - curr_slv;

        local totalElseExp = elseBaseExp + elseExp;

        if totalElseExp >= needExp and elseExp > 0 then
            -- 到达升级要求  -- 首先 先 减掉 elseBaseExp

            dlv =(i + 1) - curr_slv;

            local extExp = needExp - elseBaseExp;
            local parenExp = needExp;
            local upToLv = i + 1;

            if upToLv > my_lv then
                upToLv = my_lv;
                dlv = my_lv - curr_slv;
            end

            --  baseExp (+ extExp) / parenExp   upToLv 可以升级到的等级 dlv 目标等级跟当前等级的差值 canUpTo  是否符合升级要求

            upLvInfos[upLvInfosIndex] = { baseExp = elseBaseExp, extExp = extExp, parenExp = parenExp, upToLv = upToLv, dlv = dlv, canUpTo = true };

            -- 减去额外经验
            elseExp = elseExp - extExp;
            -- 基础经验已经用完了
            elseBaseExp = 0;


            -- elseExp 剩余经验 upToLv 升级到目标等级  parenExp 分母经验
            upLvInfosIndex = upLvInfosIndex + 1;

            hasUp = true;

        else

            -- 未能达到升级要求
            local parenExp = needExp;
            local upToLv = i;
            dlv = i - curr_slv;

            if elseBaseExp ~= 0 or elseExp ~= 0 then

                upLvInfos[upLvInfosIndex] = { baseExp = elseBaseExp, extExp = elseExp, parenExp = parenExp, upToLv = upToLv, dlv = dlv, canUpTo = false };

            else
                -- 经验满但不能升级
                if hasUp then
                    elseExp = parenExp;
                    upLvInfos[upLvInfosIndex] = { baseExp = elseBaseExp, extExp = elseExp, parenExp = parenExp, upToLv = upToLv, dlv = dlv, canUpTo = false };

                end

            end

            -- elseExp 剩余经验 upToLv 升级到目标等级  parenExp 分母经验
            local t_num = table.getn(upLvInfos);
            res.upLvInfos = upLvInfos;

            if t_num <= 0 then
                res.canUpLv = false;
                res.canNotType = 2;
            end

            return res;
        end

    end

    -- 到这一步， 那说明 因为教师等级限制， 不能继续强化了

    res.upLvInfos = upLvInfos;

    local t_num = table.getn(res.upLvInfos);
    if t_num < 1 then
        res.canUpLv = false;
    end

    -- PrintTable(res)

    return res;


end



-- 获取所有强化属性累加
function StrongExpDataManager.GetAllQiangHuaAtt()

    local res = { };

    local attkeys = BaseAttrInfo.GetAttKeys();
    local attkeys_num = table.getn(attkeys);

    for i = 1, 8 do

        local eq = EquipDataManager.GetProductByKind(i);
        if eq ~= nil then
            local spId = eq.spId;
            local productcf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT_ATTR);
            local eqlv = EquipLvDataManager.getItem(i);
            local slv = eqlv.slv;
            if slv ~= nil and slv > 0 then

                local att = StrongExpDataManager.GetExtStrongAtt(eq, slv);

                for k = 1, attkeys_num do
                    ProductInfo.TryAddAtt(res, attkeys[k], att);
                end

            end

        end

    end


    return res;

end


