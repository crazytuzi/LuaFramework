

InstanceDataManager = { };

-- require "Core.Manager.Item.InstanceDataManager";

--  event for InstanceDataManager
InstanceDataManager.MESSAGE_INSTANCEDATA_CHANGE = "MESSAGE_INSTANCEDATA_CHANGE";
InstanceDataManager.MESSAGE_INSTANCEDATA_BOXINFO_CHANGE = "MESSAGE_INSTANCEDATA_BOXINFO_CHANGE";
InstanceDataManager.MESSAGE_0X0F01_CHANGE = "MESSAGE_0X0F01_CHANGE";

InstanceDataManager.MESSAGE_XLT_CENG_CHANGE = "MESSAGE_XLT_CENG_CHANGE";


InstanceDataManager.cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_INSTANCE);
InstanceDataManager.chapters = nil;
InstanceDataManager.expMapList = nil;
InstanceDataManager.returnHandler = nil;
InstanceDataManager.handTarget = nil;




InstanceDataManager.shiyongQuan = { };



InstanceDataManager.hasGetBoxLog = { };
local _sortfunc = table.sort

InstanceDataManager.hasPassInstanceList = { };
-- 1:主线副本(单人),2:经验副本(单人),3:装备副本（组队）,4:灵石副本（组队）,5:材料副本（组队）,6:竞技场(单人)
InstanceDataManager.InstanceType =
{
    System_instance = 0,
    -- 系统内置副本， http://192.168.0.8:3000/issues/1836
    MainInstance = 1,
    -- 剧情
    ExperienceInstance = 2,
    --
    EquipInstance = 3,
    -- 小炎界
    SpiritStonesInstance = 4,
    -- 海皇宫

    MaterialInstance = 5,
    -- 伏蛟山
    PVPInstance = 6,
    -- 竞技场
    XuLingTaInstance = 7,
    -- 虚灵塔
    -- 虚灵塔 副本
    type_MingZhuRuQing = 15,
    -- 螟族入侵
    type_ZongMenLiLian = 11,
    -- 无尽试练
    type_endlessTry = 12,
    -- 宗门历练
    type_jiuyouwangzuo = 13,
    -- 九幽王座
    -- 新手剧情副本
    type_novice = 14
}


--[[
    通过type判定副本的具体类型
    剧情副本   500140

副本类型：5 对应入场券：伏蛟山入场券 入场券ID：500141
副本类型：3 对应入场券：小炎界入场券 入场券ID：500142
副本类型：4 对应入场券：海皇宫入场券 入场券ID：500143
副本类型：13 对应入场券：九幽王座入场券 入场券ID：500144

副本类型：15 对应入场券：螟族入侵入场券 入场券ID：500145
副本类型：12 对应入场券：无尽试炼入场券 入场券ID：500146
    ]]
InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.MainInstance] = 500140;
InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.EquipInstance] = 500142;
InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.SpiritStonesInstance] = 500143;
InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.MaterialInstance] = 500141;
InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.type_jiuyouwangzuo] = 500144;
InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.type_MingZhuRuQing] = 500145;
InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.type_endlessTry] = 500146;



InstanceDataManager.MapType =
{
    -- 野外
    Field = 1,
    -- 2副本
    Instance = 2,
    -- 3主程
    Main = 3,
    -- 4仙盟领地
    Guild = 4,
    -- 仙盟 boss
    XMBoss = 5,
    -- 宗门理论
    ZongMenLiLian = 6,
    -- 7世界boss
    WorldBoss = 7,
    -- 上古争霸
    ArathiWar = 8,
    -- 新手场景
    Novice = 9,
    -- 仙盟战
    GuildWar = 10,
    -- 无尽试练
    endlessTry = 12,

    VipWildBoss = 13,
    Taboo = 14,-- 禁忌之地
}

InstanceDataManager.kind_0 = 0;
InstanceDataManager.kind_1 = 1; -- 对应 剧情副本  是普通
InstanceDataManager.kind_2 = 2;  -- 对应 剧情副本  是英雄
InstanceDataManager.kind_3 = 3;  -- 对应 剧情副本  是噩梦

InstanceDataManager.__old_xlt_ceng = -1;

function InstanceDataManager.OpenFBUI(type)

    --local cf = InstanceDataManager.GetMapCfById(fb_id);
    --local type = cf.type;

    --[[if type == InstanceDataManager.InstanceType.MainInstance then
        -- 剧情副本
        -- 还需要判断是在哪个难度


        ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCEPANEL, { fb_id = cf.id });

    elseif type == InstanceDataManager.InstanceType.type_jiuyouwangzuo then
        ModuleManager.SendNotification(ZongMenLiLianNotes.OPEN_ZONGMENLILIANPANEL);

    else]]if type == InstanceDataManager.InstanceType.PVPInstance then
        PVPProxy.SendGetPVPPlayer();
    else

        local interface_data = 0;
        local interface_id = 0;
        local instance_type = 0;

        if type == InstanceDataManager.InstanceType.EquipInstance then
            interface_data = TeamMatchDataManager.type_2;
            interface_id = ActivityDataManager.interface_id_28;
            instance_type = 3;

        elseif type == InstanceDataManager.InstanceType.SpiritStonesInstance then
            interface_data = TeamMatchDataManager.type_3;
            interface_id = ActivityDataManager.interface_id_27;
            instance_type = 4;
        elseif type == InstanceDataManager.InstanceType.MaterialInstance then
            interface_data = TeamMatchDataManager.type_4;
            interface_id = ActivityDataManager.interface_id_29;
            instance_type = 5;
        elseif type == InstanceDataManager.InstanceType.type_jiuyouwangzuo then
            interface_data = TeamMatchDataManager.type_13;
            interface_id = ActivityDataManager.interface_id_30;
            instance_type = 13;
        elseif type == InstanceDataManager.InstanceType.type_endlessTry then
            interface_data = TeamMatchDataManager.type_12;
            interface_id = ActivityDataManager.interface_id_18;
            instance_type = 12;
        end
        --Warning( interface_id.."__".. interface_data.."__".. instance_type.."__".. InstanceDataManager.kind_0)

        local args = { interface_id = interface_id, interface_data = interface_data, type = instance_type, kind = InstanceDataManager.kind_0 };
        ModuleManager.SendNotification(LSInstanceNotes.OPEN_LSINSTANCEPANEL, args);

    end

   

end

--[[
S <-- 16:13:15.306, 0x0F0C, 13, {"l":[{"rs":[{"flag":0,"index":2},{"flag":0,"index":4},{"flag":1,"index":1},{"flag":0,"index":3}],"t":1,"k":1}]}
]]
function InstanceDataManager.SetHasGetBoxLog(data)

    InstanceDataManager.hasGetBoxLog = data.l;

    MessageManager.Dispatch(InstanceDataManager, InstanceDataManager.MESSAGE_INSTANCEDATA_BOXINFO_CHANGE);

end

function InstanceDataManager.GetHasGetBoxLog(t, k, index)

    for key, value in pairs(InstanceDataManager.hasGetBoxLog) do

        if t == value.t and k == value.k then
            local rs = value.rs;
            for key1, value1 in pairs(rs) do
                if value1.index == index then
                    if value1.flag == 1 then
                        return true;
                    else
                        return false;
                    end
                end
            end
        end
    end

    return false;
end


function InstanceDataManager.GetListByKeys(type, kind)

    local res = { };
    local index = 1;

    for key, value in pairs(InstanceDataManager.cf) do

        local t_type = value.type;
        local t_kind = value.kind;

        if kind ~= nil then
            if t_type == type and kind == t_kind then
                res[index] = value;
                index = index + 1;
            end
        else
            if t_type == type then
                res[index] = value;
                index = index + 1;
            end
        end


    end

    -- 需要通过 id 来 排序
    _sortfunc(res, function(a, b)

        if (a.id < b.id) then
            -- <
            return true
        else
            return false
        end
    end );


    return res;

end

--[[

InstanceDataManager.UpData(function()
{
InstanceDataManager.GetXLTHasPassCen()
}
)


]]

-- :[instId:副本ID,t:次数,s:星级,ut:通关时间]
-- for 0x0105
function InstanceDataManager.UpData(returnHandler, handTarget)

    InstanceDataManager.returnHandler = returnHandler;
    InstanceDataManager.handTarget = handTarget;
    SocketClientLua.Get_ins():SendMessage(CmdType.GetFB_instReds, { });
end

InstanceDataManager.instredsData = nil;

function InstanceDataManager.GetbuyReds(type)

    if InstanceDataManager.instredsData ~= nil then
        local buyReds = InstanceDataManager.instredsData.buyReds;
        for key, value in pairs(buyReds) do
            if value.it == type then
                return value.t;
            end
        end
    end

    return 0;
end



function InstanceDataManager.GetElsenum()

    local elseTime = InstanceDataManager:GetElseTimeByType(InstanceDataManager.InstanceType.MainInstance);
    local buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.MainInstance);
    local elseNum = elseTime + buy_num;

    --  log(" elseTime "..elseTime.." buy_num "..buy_num.. " elseNum "..elseNum);

    return elseNum;
end


--[[
尝试进入主线副本
]]
function InstanceDataManager.TryGotoInstanceFb(fb_id)


    local elseTime = InstanceDataManager.GetElsenum();

    if elseTime > 0 then

        GameSceneManager.GoToFB(fb_id)

    else
        -- self:_OnresetBt();
        InstanceDataManager.TryBuyTineConfirm(InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.MainInstance], fb_id);
    end

end


function InstanceDataManager.TryBuyTineConfirm(spid, fb_id)
    -- 500140
    local procf = ProductManager.GetProductById(spid);
    local t_num = BackpackDataManager.GetProductTotalNumBySpid(spid);


    if t_num > 0 or fb_id == nil then
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("InstancePanel/InstanceFbItem/tip2",{ n = procf.name, m = t_num }),
            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = InstanceDataManager.ResetResluatHandler,
            target = nil,
            data = { hideCheckBox = true, proInfo = procf }
        } );
    else


        local inscf = InstanceDataManager.GetMapCfById(fb_id);

        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("InstancePanel/InstanceFbItem/tip4",{ n = inscf.price }),
            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = InstanceDataManager.ResetByLingshiHandler,
            target = nil,
            data = { hideCheckBox = true, proInfo = procf, fb_id = fb_id }
        } );
    end


end

function InstanceDataManager.ResetByLingshiHandler(data)

    XLTInstanceProxy.XLTReSetTaoZhanTime(data.fb_id)

end 

function InstanceDataManager.ResetResluatHandler(data)

    local proInfo = data.proInfo;
    local spid = proInfo.id;
    local t_num = BackpackDataManager.GetProductTotalNumBySpid(spid);


    if t_num <= 0 then
        -- iii.仙玉不足时，点击“重置次数”按钮，系统提示：仙玉不足！提示文字红色显示
        MsgUtils.ShowTips("InstancePanel/InstanceFbItem/tip3", { n = proInfo.name });
    else
        -- self.checkBoxSelected = data.checkBoxSelected;
        -- InstancePanelProxy.TryResetInstanteTime(self.data.id)

        -- 直接使用道具
        local pro = BackpackDataManager.GetProductBySpid(spid);

        ProductTipProxy.TryUseProduct(pro, 1)

    end


end


--  S <-- 18:00:17.858, 0x0F01, 4, {"instReds":[{"instId":"753001","s":0,"t":0,"ut":-1}]}
function InstanceDataManager.GetFB_instRedsResult(cmd, data)



    if (data.errCode == nil) then

        InstanceDataManager.hasPassInstanceList = { };


        InstanceDataManager.instredsData = data;

        local instReds = data.instReds;
        for key, value in pairs(instReds) do
            -- if value.s > 0 then
            InstanceDataManager.hasPassInstanceList[value.instId + 0] = value;
            --  end
        end


        if InstanceDataManager.returnHandler ~= nil then
            if (InstanceDataManager.handTarget ~= nil) then
                InstanceDataManager.returnHandler(InstanceDataManager.handTarget);
            else
                InstanceDataManager.returnHandler();
            end
        end

        InstanceDataManager.returnHandler = nil;
        InstanceDataManager.handTarget = nil;

        MessageManager.Dispatch(InstanceDataManager, InstanceDataManager.MESSAGE_0X0F01_CHANGE);

        local xlt_ceng = InstanceDataManager.GetXLTHasPassCen();
        InstanceDataManager.TrySetXLTNext(xlt_ceng)

    else
        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end

function InstanceDataManager.TrySetXLTNext(xlt_ceng, upToSdata)

    if InstanceDataManager.__old_xlt_ceng ~= xlt_ceng then
        InstanceDataManager.__old_xlt_ceng = xlt_ceng;

        if upToSdata then
            local hasPass = InstanceDataManager.GetXLTHasPassInfo();
            if hasPass ~= nil then
                hasPass.s = xlt_ceng;
            end
        end

        MessageManager.Dispatch(InstanceDataManager, InstanceDataManager.MESSAGE_XLT_CENG_CHANGE, InstanceDataManager.__old_xlt_ceng);
    end

end

-- 获取 type 类型 所有已经打过的 副本 的 剩余 次数

function InstanceDataManager:GetElseTimeByType(fb_type)

    local hasUseTime = 0;

    for key, value in pairs(InstanceDataManager.hasPassInstanceList) do

        local instId = value.instId;
        local cf_data = InstanceDataManager.GetMapCfById(instId);
        if cf_data.type == fb_type then

            hasUseTime = hasUseTime + value.t;

        end

    end

    -- 获取 该类型 的 次数 最大 次数

    local typeArr = InstanceDataManager.GetMapsInfoListByType(fb_type);
    local max_num = typeArr[1].number;
    local elseTime = max_num - hasUseTime;

    return elseTime;

end

-- {"instReds":[{"instId":"753001","s":0,"t":0,"ut":-1}]}
-- instReds:[instId:副本ID,t:次数,s:星级,ut:通关时间，rt:重置次数]
function InstanceDataManager.GetHasPassById(instId)
    return InstanceDataManager.hasPassInstanceList[tonumber(instId)];
end

function InstanceDataManager.GetXLTHasPassInfo()
    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
    local firstFb = bfCflist[1];
    local hasPass = InstanceDataManager.GetHasPassById(firstFb.id);
    return hasPass;
end

function InstanceDataManager.SetXLTHasPassInfo(cen)
    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
    local firstFb = bfCflist[1];
    local hasPass = InstanceDataManager.GetHasPassById(firstFb.id);
    hasPass.s = cen;
    return hasPass;
end

-- 获取虚灵塔已经通过层数
function InstanceDataManager.GetXLTHasPassCen()
    local hasPass = InstanceDataManager.GetXLTHasPassInfo();
    if hasPass ~= nil then
        return hasPass.s;
    end
    return 0;
end

 
--[[
获取副本剩余次数
]]
function InstanceDataManager.GetElseTeamNum(instId)
    local data = InstanceDataManager.hasPassInstanceList[tonumber(instId)];
    local cf = InstanceDataManager.GetMapCfById(instId);

    if data ~= nil then
        return cf.number - data.t;
    end

    return cf.number;
end

-- 获取是否玩过 某个副本 
function InstanceDataManager.GetIsPlayedFb(instId)
    local fb = InstanceDataManager.GetHasPassById(instId);
    if fb ~= nil then
        return true;
    end
    return false;
end


function InstanceDataManager.GetMapCfById(instId)
    return InstanceDataManager.cf[tonumber(instId)];
end


-- 只用于剧情副本
function InstanceDataManager.Get_First_pass_reward(instId)

    local cf = InstanceDataManager.GetMapCfById(instId);
    local first_pass_reward = cf.first_pass_reward;

    local my_info = HeroController:GetInstance().info;
    local my_career = tonumber(my_info:GetCareer());


    for key, value in pairs(first_pass_reward) do

        local arr = ConfigSplit(value);
        if my_career == tonumber(arr[1]) then
            return { spId = tonumber(arr[2]), am = tonumber(arr[3]) };
        end
    end


    return nil;
end

function InstanceDataManager.GetInsByMapId(map_id)

    map_id = tonumber(map_id);
    for key, value in pairs(InstanceDataManager.cf) do

        if value.map_id == map_id then
            return value;
        end
    end
    return nil;
end


-- 获取 type 的第一个 数据配置
function InstanceDataManager.GetFirstInsCf(_type)

    for key, value in pairs(InstanceDataManager.cf) do

        if value.type == _type then
            return value;
        end
    end

    return nil;
end

-- 根据副本类型获取 副本集合 , 有通过  level 的排序
function InstanceDataManager.GetMapsInfoListByType(_type)

    local res = { };
    local index = 1;

    for key, value in pairs(InstanceDataManager.cf) do

        if value.type == _type then
            res[index] = value;
            index = index + 1;
        end
    end

    _sortfunc(res, function(a, b)
        return a.level < b.level;
    end );

    return res;

end

-- 对于 主线副本的
function InstanceDataManager.get_chapter(chapter_id)

    local res = { };
    local chapter_name = "";


    for key, value in pairs(InstanceDataManager.cf) do

        if value.type == InstanceDataManager.InstanceType.MainInstance then
            -- type==1 表示 是 主线副本

            if value.chapter_id == chapter_id then

                local ownership = value.ownership + 0;
                local tp = value.kind + 0;

                if res[ownership] == nil then
                    res[ownership] = { };
                    chapter_name = value.chapter_name;
                end

                res[ownership][tp] = value
            end

        end

    end

    res["chapter_name"] = chapter_name;

    return res;
end

function InstanceDataManager.get_chapters()

    if InstanceDataManager.chapters == nil then
        InstanceDataManager.chapters = { }
        InstanceDataManager.chapters[1] = InstanceDataManager.get_chapter(101);
        InstanceDataManager.chapters[2] = InstanceDataManager.get_chapter(102);
        InstanceDataManager.chapters[3] = InstanceDataManager.get_chapter(103);
        InstanceDataManager.chapters[4] = InstanceDataManager.get_chapter(104);
    end

    return InstanceDataManager.chapters;
end


function InstanceDataManager.CheckPass(open_map_condition, min_s)
    -- 没有的话认为是没有前置副本的
    if (open_map_condition == nil or open_map_condition == "") then
        return true
    end

    local arr = string.split(open_map_condition, ",");
    local len = table.getn(arr);
    if len == 1 then
        if (arr[1] + 0) == 0 then
            return true;
        end

        local hasPass1 = InstanceDataManager.hasPassInstanceList[(arr[1] + 0)];
        if hasPass1 ~= nil then
            if hasPass1.s > min_s then
                return true;
            end
        end
    else

        -- len == 2
        local hasPass1 = InstanceDataManager.hasPassInstanceList[(arr[1] + 0)];
        local hasPass2 = InstanceDataManager.hasPassInstanceList[(arr[2] + 0)];

        if hasPass1 ~= nil and hasPass2 ~= nil then
            if hasPass1.s > min_s and hasPass2.s > min_s then
                return true;
            end
        end

    end

end

--[[  检测 章节 chapter_index(1 2 3 4 ) 是否已经或者可以开启
 判断 方法 是  在获取配置表中的 chapter_index 章节 的 第一个副本 的  简单难度  的 open_map_condition  是否 == 0
  或者 对应 上一个 副本  是否已经通过
]]
function InstanceDataManager.CheckChapterCanPlay(chapter_index)

    local chapters = InstanceDataManager.get_chapters();

    local chapter = chapters[chapter_index];
    local maps = chapter[1];
    local map = maps[1];
    -- 简单难度


    return InstanceDataManager.CheckPass(map.open_map_condition, 0);


end

-- 获取 这张地图是否可以开启
function InstanceDataManager.CheckMapCanPlay(map, bigstar)
    --[[
2、前置副本为通关时，系统提示：前置副本通关后，才能进入当前副本！
3、对应的副本任务未接取时，系统提示：接取主线任务-任务名称，才能进入当前副本！
]]

    -- 前置副本 是否通关
    local qianzhi_fb_can = InstanceDataManager.CheckPass(map.open_map_condition, bigstar);


    --  other_condition  对应的副本任务未接取时
    local other_condition = map.other_condition;
    local other_condition_can = true;
    if other_condition ~= 0 then
        other_condition_can = TaskManager.TaskIsAccess(other_condition);
    end

    local res = { };
    res.can = true;
    res.msg = "";

    if not other_condition_can then
        local taskcf = TaskManager.GetConfigById(other_condition);
        res.msg = LanguageMgr.Get("Manager/InstanceDataManager/tip1", { n = taskcf.name });
        res.can = false;
    end

    if not qianzhi_fb_can then
        res.msg = LanguageMgr.Get("Manager/InstanceDataManager/tip2");
        res.can = false;
    end


    return res;


end

function InstanceDataManager.ChcekMapLeveCanPlay(map)
    return InstanceDataManager.CheckPass(map.open_map_condition, 0);
end

-- --  S <-- 18:00:17.858, 0x0F01, 4, {"instReds":[{"instId":"753001","s":0,"t":0,"ut":-1}]}
function InstanceDataManager.GetTotalStarNumByKey(type, kind)

    local star_num = 0;

    for key, value in pairs(InstanceDataManager.hasPassInstanceList) do

        local id = value.instId;
        local obj = InstanceDataManager.GetMapCfById(id)

        if obj ~= nil and obj.type == type and obj.kind == kind then
            star_num = star_num + value.s;
        end
    end
    return star_num;
end

-- 获取 类型副本 已经 参与过次数总和
function InstanceDataManager.GetTotalTNumByKey(type, kind)

    local t_num = 0;

    for key, value in pairs(InstanceDataManager.hasPassInstanceList) do

        local id = value.instId;
        local obj = InstanceDataManager.GetMapCfById(id)

        if obj ~= nil and obj.type == type and obj.kind == kind then
            t_num = t_num + value.t;

        end
    end

    return t_num;
end

-- 获取花仙玉购买的次数
function InstanceDataManager.GetTotalTNumBuy(type)

    local t_num = 0;
    for key, value in pairs(InstanceDataManager.hasPassInstanceList) do

        local id = value.instId;
        local obj = InstanceDataManager.GetMapCfById(id)

        if obj ~= nil and obj.type == type then
            t_num = t_num + value.dt;
        end
    end
    return t_num;
end

-- 获取 使用 入场券次数 和 仙玉 购买的次数 总和
function InstanceDataManager.GetTotalTAndDtNumBuy(type)
    local buy_num = InstanceDataManager.GetbuyReds(type);
    local buy1_num = InstanceDataManager.GetTotalTNumBuy(type);

    return buy_num + buy1_num;
end 

-- 获取 一张地图 的 3个难度  的 星集合
function InstanceDataManager.GetTotalStarNum(maps)

    local star_num = 0;
    for i = 1, 3 do
        local map = maps[i];

        if map ~= nil then
            local hasPass = InstanceDataManager.hasPassInstanceList[map.id];
            if hasPass ~= nil then
                -- 有通过记录，
                star_num = star_num + hasPass.s;
            end
        end
    end
    return star_num;

end

--[[
 初始话  经验副本 数据
]]
function InstanceDataManager:InitMapList()

    local expMapList = { };
    local index = 1;

    for key, value in pairs(InstanceDataManager.cf) do
        if value.type == 2 then
            expMapList[index] = value;
            index = index + 1;
        end
    end

    -- 需要进行 排序
    _sortfunc(expMapList, function(a, b)
        return a.level < b.level;
    end );

    InstanceDataManager.expMapList = expMapList;
end


function InstanceDataManager:GetExpMapList()

    if InstanceDataManager.expMapList == nil then
        InstanceDataManager:InitMapList();
    end

    return InstanceDataManager.expMapList;

end


--[[
 地图类型是否 是副本类型
]]
function InstanceDataManager.IsInInstance(map_type)

    map_type = map_type or GameSceneManager.map.info.type;

    if map_type == InstanceDataManager.MapType.Field or
        map_type == InstanceDataManager.MapType.Main or
        map_type == InstanceDataManager.MapType.Guild then

        return false;
    end
    return true;
end

-- 获取虚灵塔有首次 奖励的数据
function InstanceDataManager:GetXLTFirstAwardArr()

    local res = { };
    local res_index = 1;

    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
    local len = table.getn(bfCflist);
    for i = 1, len do
        local first_pass_reward = bfCflist[i].first_pass_reward;
        local f_len = table.getn(first_pass_reward);
        if f_len == 0 or(f_len == 1 and first_pass_reward[1] == "") then
            -- 没有物品， 跳过
        else
            res[res_index] = bfCflist[i];
            res[res_index].ceng = i;
            res_index = res_index + 1;
        end
    end
    return res;

end