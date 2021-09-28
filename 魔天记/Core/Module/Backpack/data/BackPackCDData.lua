BackPackCDData = { };
BackPackCDData.MESSAGE_PRODUCTS_CD_CHANGE = "MESSAGE_PRODUCTS_CD_CHANGE";

BackPackCDData.item_cds = { };
BackPackCDData.battleground_config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_CONFIG); --require "Core.Config.battleground_config";

-- 0x0106
-- [{t:物品type,k：物品kind,rt:ms}] 物品使用cd
function BackPackCDData.Init(data)

    local t_num = table.getn(data);
    local sys_time = GetTimeMillisecond();


    for i = 1, t_num do
        data[i].cd_sysTime = data[i].rt + sys_time;
        local key = data[i].t .. "_" .. data[i].k;
        BackPackCDData.item_cds[key] = data[i];
    end

end

function BackPackCDData.CheckUseProduct(spid)

    local obj = ProductManager.GetProductById(spid);
    local cd = obj.cd;

    if cd > 0 then

        local sys_time = GetTimeMillisecond();
        local key = obj.type .. "_" .. obj.kind;

        cd = BackPackCDData.CheckExtCd(cd, spid);

        BackPackCDData.item_cds[key] = { spid = tonumber(spid), t = obj.type, k = obj.kind, rt = cd, cd_sysTime = cd + sys_time };

        MessageManager.Dispatch(BackPackCDData, BackPackCDData.MESSAGE_PRODUCTS_CD_CHANGE);

    end


end


function BackPackCDData.CleanCd(spid)

    for key, value in pairs(BackPackCDData.item_cds) do
        local spid_ = value.spid;
        if spid_ == tonumber(spid) then
            BackPackCDData.item_cds[key] = nil;
            return;
        end
    end
end

-- 重设置 cd
function BackPackCDData.TryCleanExtCd(curr_map_id, old_map_id)

    local mapCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP);

    local curr_map_info = mapCfg[curr_map_id];
    local old_map_info = mapCfg[old_map_id];

    if curr_map_info == nil  or old_map_info == nil then
      return ;
    end


    if curr_map_info.type ~= InstanceDataManager.MapType.ArathiWar and old_map_info.type == InstanceDataManager.MapType.ArathiWar then

        -- 可以清理 对应的 cd
        local bt_cf = BackPackCDData.battleground_config[1];
        local hp_potion_item = bt_cf.hp_potion_item;
        local t_num = table.getn(hp_potion_item);
        for i = 1, t_num do
         BackPackCDData.CleanCd(hp_potion_item[i])
        end
    end

end

function BackPackCDData.CheckSpidIn(hp_potion_item, spid)

    local t_num = table.getn(hp_potion_item);
    for i = 1, t_num do
        local sp = tonumber(hp_potion_item[i]);

        if tonumber(spid) == sp then
            return true;
        end
    end

    return false;
end

function BackPackCDData.CheckExtCd(cd, spid)
    local map = GameSceneManager.map
    if (map and map.info and map.info.type == InstanceDataManager.MapType.ArathiWar) then

        local bt_cf = BackPackCDData.battleground_config[1];
        local hp_potion_item = bt_cf.hp_potion_item;

        local b = BackPackCDData.CheckSpidIn(hp_potion_item, spid);

        if b then
            cd = cd * bt_cf.hp_potion_CD;
        end

    end

    return cd;
end

function BackPackCDData.GetCDByTK(type, kind)

    if BackPackCDData.item_cds == nil then
        return -1;
    end

    local key = type .. "_" .. kind;

    local robj = BackPackCDData.item_cds[key];

    if robj ~= nil then
        local sys_time = GetTimeMillisecond();

        local cd_sysTime = robj.cd_sysTime;
        local rt = cd_sysTime - sys_time;

        if rt > 0 then
            -- 需要显示 倒计时
            local rt_sec = rt;

            return rt_sec;
        else
            -- 倒计时已经结束
            BackPackCDData.item_cds[key] = nil;
        end

    end

    return 0;

end

function BackPackCDData.GetCD(info)

    local type = info:GetType();
    local kind = info:GetKind();

    return BackPackCDData.GetCDByTK(type, kind);

end