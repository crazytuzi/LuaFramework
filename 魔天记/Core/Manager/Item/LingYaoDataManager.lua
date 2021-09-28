LingYaoDataManager = { };

LingYaoDataManager.elixirCf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ELIXIR); --require "Core.Config.elixir"

LingYaoDataManager.career_list = nil;

local _sortfunc = table.sort 

--[[
elixir:灵药[{spId,am},..]
]]
function LingYaoDataManager.Init(data)

    LingYaoDataManager.hasUse_elixir = { };
    for key, value in pairs(data) do
        LingYaoDataManager.hasUse_elixir[value.spId + 0] = value.am;
    end

    LingYaoDataManager.CheckInit();
end

--[[
获取 已经使用的 丹药数量
]]
function LingYaoDataManager.GetHasUseAm(spId)
    local res = LingYaoDataManager.hasUse_elixir[spId + 0];
    if res == nil then
        res = 0;
    end
    return res;
end

-- 获取所有的属性加成
function LingYaoDataManager.TryAllHasAtt()

    local res = { };
    res['hp_max'] = 0;
    -- 生命值
    res['phy_att'] = 0;
    -- 物理攻击
    -- res['mag_att'] = 0;
    -- 法术攻击
    res['phy_def'] = 0;
    -- 物理防御
    -- res['mag_def'] = 0;
    -- 法术防御

    for key, value in pairs(LingYaoDataManager.hasUse_elixir) do
        local spId = key;
        local am = value;
       
        local obj = LingYaoDataManager.Get_elixirCf(spId);
        res['hp_max'] = res['hp_max'] + obj['hp_max'] * am;
        res['phy_att'] = res['phy_att'] + obj['phy_att'] * am;
        -- res['mag_att'] = res['mag_att'] + obj['mag_att'] * am;
        res['phy_def'] = res['phy_def'] + obj['phy_def'] * am;
        -- res['mag_def'] = res['mag_def'] + obj['mag_def'] * am;

    end
    return res;

end

function LingYaoDataManager.TryGetAttTotal(kind)

    local res = { value = 0; att_name = nil };

    for key, value in pairs(LingYaoDataManager.hasUse_elixir) do
        local spId = key;
        local am = value;

        local obj = LingYaoDataManager.Get_elixirCf(spId);
        if obj.kind == kind then

            if obj.hp_max > 0 then
                res.value = res.value + obj.hp_max * am;
                res.att_name = "hp_max";
            elseif obj.phy_att > 0 then
                res.value = res.value + obj.phy_att * am;
                res.att_name = "phy_att";
            -- elseif obj.mag_att > 0 then
            --     res.value = res.value + obj.mag_att * am;
            --     res.att_name = "mag_att";
            elseif obj.phy_def > 0 then
                res.value = res.value + obj.phy_def * am;
                res.att_name = "phy_def";
            -- elseif obj.mag_def > 0 then
            --     res.value = res.value + obj.mag_def * am;
            --     res.att_name = "mag_def";
            else
                res.att_name = nil;
            end
        end
    end

    if res.att_name == nil then
        local obj_t = LingYaoDataManager.GetObjByKind(kind);
        if obj_t.hp_max > 0 then
            res.att_name = "hp_max";
        elseif obj_t.phy_att > 0 then
            res.att_name = "phy_att";
        -- elseif obj_t.mag_att > 0 then
        --     res.att_name = "mag_att";
        elseif obj_t.phy_def > 0 then
            res.att_name = "phy_def";
        -- elseif obj_t.mag_def > 0 then
        --     res.att_name = "mag_def";
        end
    end


    return res;

end

function LingYaoDataManager.AddHasAm(spId, am)
    local id = spId + 0;
    if LingYaoDataManager.hasUse_elixir[id] == nil then
        LingYaoDataManager.hasUse_elixir[id] = am;
    else
        LingYaoDataManager.hasUse_elixir[id] = LingYaoDataManager.hasUse_elixir[id] + am;
    end

end


function LingYaoDataManager.Get_elixirCf(spid)
    return LingYaoDataManager.elixirCf[spid];
end


function LingYaoDataManager.CheckIsFixMyCareer(spid)
    local obj = LingYaoDataManager.Get_elixirCf(spid);
    local careers = obj.career;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local kind = heroInfo.kind;

    local t_num = table.getn(careers);
    for i = 1, t_num do
        local career = careers[i];
        if career == kind then
            return true;
        end
    end
    return false;
end


function LingYaoDataManager.GetAttById(spid)
    local res = { };
    local obj = LingYaoDataManager.elixirCf[spid];

    if obj.hp_max > 0 then
        res.value = obj.hp_max;
        res.att_name = LanguageMgr.Get("attr/hp_max");
    elseif obj.phy_att > 0 then
        res.value = obj.phy_att;
        res.att_name = LanguageMgr.Get("attr/phy_att");
    -- elseif obj.mag_att > 0 then
    --     res.value = obj.mag_att;
    --     res.att_name = LanguageMgr.Get("attr/mag_att");
    elseif obj.phy_def > 0 then
        res.value = obj.phy_def;
        res.att_name = LanguageMgr.Get("attr/phy_def");
    -- elseif obj.mag_def > 0 then
    --     res.value = obj.mag_def;
    --     res.att_name = LanguageMgr.Get("attr/mag_def");
    end

    return res;

end

function LingYaoDataManager.GetObjByKind(kind)
    for key, value in pairs(LingYaoDataManager.elixirCf) do

        if value.kind == kind then
            return value;
        end

    end

end

function LingYaoDataManager.CheckInit()

    if LingYaoDataManager.career_list == nil then
        local list = { };

        for key, value in pairs(LingYaoDataManager.elixirCf) do

            local kind = value.kind;
            local career = value.career;

            if list[kind] == nil then
                list[kind] = { career = career, list = { } };
            end
            local t_num = table.getn(list[kind].list);

            t_num = t_num + 1;
            list[kind].list[t_num] = value;
        end

        --------------------  组合数据  ----------------------------
        LingYaoDataManager.career_list = { };

        local t_num = table.getn(list);
        -- 药品 种类
        for i = 1, t_num do

            local obj = list[i];

            _sortfunc(obj.list, function(a, b)
                return a.id < b.id;
            end )

            local careers = obj.career;
            local c_num = table.getn(careers);
            for j = 1, c_num do

                local career = careers[j];

                if LingYaoDataManager.career_list[career] == nil then
                    LingYaoDataManager.career_list[career] = { };
                end
                local c_len = table.getn(LingYaoDataManager.career_list[career]);
                c_len = c_len + 1;
                LingYaoDataManager.career_list[career][c_len] = obj;
            end
        end
        --------------------------------------------

    end
end


function LingYaoDataManager.GetListByCareer(career)

    LingYaoDataManager.CheckInit();

    return LingYaoDataManager.career_list[career];

end

----------------------------------------------------------------------------

--[[

获取 丹药 合成 配置数据

属性丹药        恢复丹药       其他丹药
type=6           type=4      type=4
king=1,2,3,4,5    king=1,2   kind=???


]]

LingYaoDataManager.hcCfList = { };

-- 属性药
 LingYaoDataManager.hcCfList[1] = {
                { type = 6, kind = 1, name = LanguageMgr.Get("Manager/LingYaoDataManager/label1") },
                { type = 6, kind = 2, name = LanguageMgr.Get("Manager/LingYaoDataManager/label2") },
                { type = 6, kind = 3, name = LanguageMgr.Get("Manager/LingYaoDataManager/label3") },
                { type = 6, kind = 4, name = LanguageMgr.Get("Manager/LingYaoDataManager/label4") },
                { type = 6, kind = 5, name = LanguageMgr.Get("Manager/LingYaoDataManager/label5") },
            };


-- 恢复药
LingYaoDataManager.hcCfList[2] = {
    { type = 4, kind = 1, name = LanguageMgr.Get("Manager/LingYaoDataManager/label6") },
    { type = 4, kind = 2, name = LanguageMgr.Get("Manager/LingYaoDataManager/label7") },
};


-- 其他药
LingYaoDataManager.hcCfList[3] = {
    { type = 4, kind = 4, name = LanguageMgr.Get("Manager/LingYaoDataManager/label8") },
    { type = 4, kind = 5, name = LanguageMgr.Get("Manager/LingYaoDataManager/label9") }
};

--[[

 dp  1 属性药      2 恢复药     3 其他药

]]
function LingYaoDataManager.GetHeChengList(dp)

--[[
    if dp == 1 and LingYaoDataManager.hcCfList[1] == nil then

        local me = HeroController:GetInstance();
        local heroInfo = me.info;
        local career = heroInfo.kind;

        if career == 102000 or career == 103000 then

            LingYaoDataManager.hcCfList[1] = {
                { type = 6, kind = 1, name = LanguageMgr.Get("Manager/LingYaoDataManager/label1") },
                { type = 6, kind = 2, name = LanguageMgr.Get("Manager/LingYaoDataManager/label2") },
                -- { type = 6, kind = 3, name = LanguageMgr.Get("Manager/LingYaoDataManager/label3") },
                { type = 6, kind = 4, name = LanguageMgr.Get("Manager/LingYaoDataManager/label4") },
                { type = 6, kind = 5, name = LanguageMgr.Get("Manager/LingYaoDataManager/label5") },
            };

        elseif career == 101000 or career == 104000 then

            LingYaoDataManager.hcCfList[1] = {
                { type = 6, kind = 1, name = LanguageMgr.Get("Manager/LingYaoDataManager/label1") },
                -- { type = 6, kind = 2, name = LanguageMgr.Get("Manager/LingYaoDataManager/label2") },
                { type = 6, kind = 3, name = LanguageMgr.Get("Manager/LingYaoDataManager/label3") },
                { type = 6, kind = 4, name = LanguageMgr.Get("Manager/LingYaoDataManager/label4") },
                { type = 6, kind = 5, name = LanguageMgr.Get("Manager/LingYaoDataManager/label5") },
            };

        end

    end
    ]]
    return LingYaoDataManager.hcCfList[dp];

end

LingYaoDataManager.plist = { };

function LingYaoDataManager.GetProductsList(type, kind)

    local key = type .. "_" .. kind;

    if LingYaoDataManager.plist[key] == nil then
        LingYaoDataManager.plist[key] = ProductManager.GetProductsList(type, kind);
    end
    return LingYaoDataManager.plist[key];
end