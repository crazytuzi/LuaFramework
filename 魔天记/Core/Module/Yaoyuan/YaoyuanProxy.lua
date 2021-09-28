require "Core.Module.Pattern.Proxy"

require "Core.Manager.Item.FarmsDataManager"

YaoyuanProxy = Proxy:New();

YaoyuanProxy.MESSAGE_MY_XIANMEN_NUMBER_CHANGE = "MESSAGE_MY_XIANMEN_NUMBER_CHANGE";
YaoyuanProxy.MESSAGE_GET_XIANMEN_INFO_COMPLETE = "MESSAGE_GET_XIANMEN_INFO_COMPLETE";
YaoyuanProxy.MESSAGE_GET_XIANMEN_YAOQING_LIST_COMPLETE = "MESSAGE_GET_XIANMEN_YAOQING_LIST_COMPLETE";
YaoyuanProxy.MESSAGE_GET_DIDUI_XIANMEN_YAOQING_LIST_COMPLETE = "MESSAGE_GET_DIDUI_XIANMEN_YAOQING_LIST_COMPLETE";

YaoyuanProxy.MESSAGE_GET_XIANMEN_LOG_COMPLETE = "MESSAGE_GET_XIANMEN_LOG_COMPLETE";

YaoyuanProxy.MESSAGE_REC_0X140ADATA = "MESSAGE_REC_0X140ADATA";

YaoyuanProxy.MESSAGE_REC_SHOUHU_TJ = "MESSAGE_REC_SHOUHU_TJ";

YaoyuanProxy.MESSAGE_CLEANALLYAOYUANLOG_COMPLETE = "MESSAGE_CLEANALLYAOYUANLOG_COMPLETE";

YaoyuanProxy.MESSAGE_TRYGETYAOYUANJS_TY_TIME_COMPLETE = "MESSAGE_TRYGETYAOYUANJS_TY_TIME_COMPLETE";

YaoyuanProxy.MESSAGE_MY_YAOYUAN_LEVEL_CHANGE = "MESSAGE_MY_YAOYUAN_LEVEL_CHANGE";

YaoyuanProxy.NUMBER_INFO_TYPE_0 = 0; -- 自己
YaoyuanProxy.NUMBER_INFO_TYPE_1 = 1;  -- 自己仙盟的成员
YaoyuanProxy.NUMBER_INFO_TYPE_2 = 2;  -- 敌对仙盟的成员

YaoyuanProxy._0x140AData = { };

YaoyuanProxy.debugNum = 0;
YaoyuanProxy.isDebug = false;

-- 原始数据 
--[[
S <-- 16:49:07.766, 0x1401, 63, {"farms":[
{"st":0,"sp":"","gt":28790,"s":"356050","wt":0,"i":2,"wp":""},
{"st":0,"sp":"","gt":28794,"s":"356053","wt":0,"i":4,"wp":""},
{"st":0,"sp":"","gt":28785,"s":"356059","wt":0,"i":1,"wp":""},
{"st":0,"sp":"","gt":28788,"s":"356055","wt":0,"i":3,"wp":""}],
"pf":{"e":5,"st":1480316780000,"gts":0,"sts":0,"et":1480322780000,"odd":0,"exp":0,"gt":0,"wt":0,"l":1,"gpi":""}}
]]

YaoyuanProxy.debug_baseData = {
    farms =
    {
        { st = 0, sp = "", gt = 28790, s = "356050", wt = 0, i = 2, wp = "" },
        { st = 0, sp = "", gt = 28794, s = "356053", wt = 0, i = 4, wp = "" },
        { st = 0, sp = "", gt = 28785, s = "356059", wt = 0, i = 1, wp = "" },
        { st = 0, sp = "", gt = 28788, s = "356055", wt = 0, i = 3, wp = "" }
    },
    pf = { e = 5, st = 1480316780000, gts = 0, sts = 0, et = 1480322780000, odd = 0, exp = 0, gt = 0, wt = 0, l = 1, gpi = "" }
};

-- 变化后数据
--[[
S <-- 16:49:23.216, 0x1401, 65, {"farms":[
{"st":0,"sp":"","gt":28775,"s":"356050","wt":0,"i":2,"wp":""},
{"st":0,"sp":"","gt":28179,"s":"356053","wt":1,"i":4,"wp":"_10100036"},
{"st":0,"sp":"","gt":28770,"s":"356059","wt":0,"i":1,"wp":""},
{"st":0,"sp":"","gt":28773,"s":"356055","wt":0,"i":3,"wp":""}],
"pf":{"e":5,"st":1480316780000,"gts":0,"sts":0,"et":1480322780000,"odd":0,"exp":0,"gt":0,"wt":0,"l":1,"gpi":""}}
]]

YaoyuanProxy.debug_extData = {
    farms =
    {
        { st = 0, sp = "", gt = 28775, s = "356050", wt = 0, i = 2, wp = "" },
        { st = 0, sp = "", gt = 28179, s = "356053", wt = 1, i = 4, wp = "_10100036" },
        { st = 0, sp = "", gt = 28770, s = "356059", wt = 0, i = 1, wp = "" },
        { st = 0, sp = "", gt = 28773, s = "356055", wt = 0, i = 3, wp = "" }
    },
    pf = { e = 5, st = 1480316780000, gts = 0, sts = 0, et = 1480322780000, odd = 0, exp = 0, gt = 0, wt = 0, l = 1, gpi = "" }
};


function YaoyuanProxy:OnRegister()


    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RecAcceptForShouHu, YaoyuanProxy.RecAcceptForShouHuResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.MyYaoYuanLevelChange, YaoyuanProxy.MyYaoYuanUpLvCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.MyYaoYuanDataChange, YaoyuanProxy.MyYaoYuanDataChangeCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetYaoYuanJs_Ty_time, YaoyuanProxy.TryGetYaoYuanJs_Ty_timeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryCleanAllYaoYuanLog, YaoyuanProxy.TryCleanAllYaoYuanLogResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrytouQu, YaoyuanProxy.TrytouQuResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryTouQuAll, YaoyuanProxy.TryTouQuAllResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetXianMenLog, YaoyuanProxy.TryGetXianMenLogResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetDiDuiXianMenNembers, YaoyuanProxy.TryGetDiDuiXianMenNembersResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AcceptForShouHu, YaoyuanProxy.AcceptForShouHuResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryInviteForShouHu, YaoyuanProxy.TryInviteForShouHuResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetMyXianMenNembers, YaoyuanProxy.TryGetXMYaoQingListResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryJiaoShuiAll, YaoyuanProxy.TryJiaoShuiAllResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryYaoYuanJiaoShui, YaoyuanProxy.TryYaoYuanJiaoShuiResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetXianMenNumberInfo, YaoyuanProxy.TryGetXianMenNumberInfoResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetMyXianMenNembers, YaoyuanProxy.TryGetMyXianMenNembersResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryHarvestAll, YaoyuanProxy.TryHarvestAllResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryHarvest, YaoyuanProxy.TryHarvestResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryJoinYaoyuan, YaoyuanProxy.TryJoinYaoyuanResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryZhongzhi, YaoyuanProxy.TryZhongzhiResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.OpenPanelForYaoyuan, YaoyuanProxy.OpenPanelForYaoyuanResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.YijianChengshu, YaoyuanProxy.YijianChengshuResult);



end

function YaoyuanProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RecAcceptForShouHu, YaoyuanProxy.RecAcceptForShouHuResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.MyYaoYuanLevelChange, YaoyuanProxy.MyYaoYuanUpLvCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.MyYaoYuanDataChange, YaoyuanProxy.MyYaoYuanDataChangeCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetYaoYuanJs_Ty_time, YaoyuanProxy.TryGetYaoYuanJs_Ty_timeResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryCleanAllYaoYuanLog, YaoyuanProxy.TryCleanAllYaoYuanLogResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrytouQu, YaoyuanProxy.TrytouQuResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryTouQuAll, YaoyuanProxy.TryTouQuAllResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetXianMenLog, YaoyuanProxy.TryGetXianMenLogResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetDiDuiXianMenNembers, YaoyuanProxy.TryGetDiDuiXianMenNembersResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AcceptForShouHu, YaoyuanProxy.AcceptForShouHuResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryInviteForShouHu, YaoyuanProxy.TryInviteForShouHuResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetMyXianMenNembers, YaoyuanProxy.TryGetXMYaoQingListResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryJiaoShuiAll, YaoyuanProxy.TryJiaoShuiAllResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryYaoYuanJiaoShui, YaoyuanProxy.TryYaoYuanJiaoShuiResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetXianMenNumberInfo, YaoyuanProxy.TryGetXianMenNumberInfoResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetMyXianMenNembers, YaoyuanProxy.TryGetMyXianMenNembersResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryHarvestAll, YaoyuanProxy.TryHarvestAllResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryHarvest, YaoyuanProxy.TryHarvestResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryJoinYaoyuan, YaoyuanProxy.TryJoinYaoyuanResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryZhongzhi, YaoyuanProxy.TryZhongzhiResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.OpenPanelForYaoyuan, YaoyuanProxy.OpenPanelForYaoyuanResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.YijianChengshu, YaoyuanProxy.YijianChengshuResult);
end




function YaoyuanProxy.MyYaoYuanDataChangeCallBack(cmd, data)

    if (data.errCode == nil) then
        YaoyuanProxy.TryOpenYaoYuan();
    end

end
--------------------------------  药园 升级 通知 ---------MyYaoYuanLevelChange------------------
--[[
14 药园等级通知（服务端发出）
输出：
exp:经验
lv：等级 （如果有，就升级）

]]
function YaoyuanProxy.MyYaoYuanUpLvCallBack(cmd, data)

    if (data.errCode == nil) then

        local lv = data.lv;
        if lv ~= nil then
            MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_MY_YAOYUAN_LEVEL_CHANGE, data);
        else

            local mypf = FarmsDataManager.GetMy_pf();
            if mypf ~= nil then

                local dexp = data.exp - mypf.exp;
                FarmsDataManager.SetMyExp(data.exp)

                MsgUtils.ShowTips(nil, nil, nil, dexp .. LanguageMgr.Get("Yaoyuan/YaoyuanProxy/label5"));

                MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_MY_YAOYUAN_LEVEL_CHANGE, data);


            end

        end


    end

end



--------------------------------------------  获取 浇水， 偷药 次数  TryGetYaoYuanJs_Ty_time -----------------------------------------------


function YaoyuanProxy.TryGetYaoYuanJs_Ty_time()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetYaoYuanJs_Ty_time, { });
end


--[[
 S <-- 14:28:06.265, 0x1413, 19, {"sts":1,"wt":0}
]]
function YaoyuanProxy.TryGetYaoYuanJs_Ty_timeResult(cmd, data)

    if (data.errCode == nil) then

        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_TRYGETYAOYUANJS_TY_TIME_COMPLETE, data);
    end
end





-------------------------------------------   清理日志 -------------------------------------------------------------


function YaoyuanProxy.TryCleanAllYaoYuanLog()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryCleanAllYaoYuanLog, { });
end

--[[

 S <-- 16:54:42.058, 0x1411, 18, {"items":[{"am":1,"spId":355000}],"farms":{"st":1,"gt":0,"s":"3560
]]
function YaoyuanProxy.TryCleanAllYaoYuanLogResult(cmd, data)

    if (data.errCode == nil) then

        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_CLEANALLYAOYUANLOG_COMPLETE);
    end
end

-------------------------------------------   TrytouQu -------------------------------------------------------------
function YaoyuanProxy.TrytouQu(id, idx)


    SocketClientLua.Get_ins():SendMessage(CmdType.TrytouQu, { id = id, idx = idx });

end


--[[

 S <-- 16:54:42.058, 0x1411, 18, {"items":[{"am":1,"spId":355000}],"farms":{"st":1,"gt":0,"s":"3560
]]
function YaoyuanProxy.TrytouQuResult(cmd, data)

    if (data.errCode == nil) then


        local t_num = table.getn(data.items);

        if t_num > 0 then
            BroadcastListManager.Get_ins():Crean();

            for i = 1, t_num do
                local obj = data.items[i];
                local spId = obj.spId;
                local am = obj.am;
                local cf = ProductManager.GetProductById(spId);
                BroadcastListManager.Get_ins():AddMsg(LanguageMgr.Get("Yaoyuan/YaoyuanProxy/label1", { a = am, n = cf.name }), 50);
            end

            BroadcastListManager.Get_ins():Start();

        else
            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("Yaoyuan/YaoyuanProxy/label6"));
        end

        -- 需要重新 拉 数据
        YaoyuanProxy.TryGetXianMenNumberInfo(YaoYuanPanel.curr_info.pid, YaoyuanProxy.NUMBER_INFO_TYPE_2, YaoYuanPanel.curr_info);

        YaoyuanProxy.TryGetYaoYuanJs_Ty_time()

    end
end

------------------------------------    TryTouQuAll  一键偷取             -----------------------------------------------------

function YaoyuanProxy.TryTouQuAll(id)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryTouQuAll, { id = id });

end


--[[


]]
function YaoyuanProxy.TryTouQuAllResult(cmd, data)

    if (data.errCode == nil) then


        local t_num = table.getn(data.items);

        if t_num > 0 then
            BroadcastListManager.Get_ins():Crean();

            for i = 1, t_num do
                local obj = data.items[i];
                local spId = obj.spId;
                local am = obj.am;
                local cf = ProductManager.GetProductById(spId);


                BroadcastListManager.Get_ins():AddMsg(LanguageMgr.Get("Yaoyuan/YaoyuanProxy/label1", { a = am, n = cf.name }), 50);
            end

            BroadcastListManager.Get_ins():Start();

        else

            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("Yaoyuan/YaoyuanProxy/label6"));
        end



        -- 需要重新 拉 数据
        YaoyuanProxy.TryGetXianMenNumberInfo(YaoYuanPanel.curr_info.pid, YaoyuanProxy.NUMBER_INFO_TYPE_2, YaoYuanPanel.curr_info);

        YaoyuanProxy.TryGetYaoYuanJs_Ty_time()

    end
end

------------------------------------------- 获取 药园 记录   ----------------------------------------------------

function YaoyuanProxy.TryGetXianMenLog()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetXianMenLog, { });

end


--[[


]]
function YaoyuanProxy.TryGetXianMenLogResult(cmd, data)

    if (data.errCode == nil) then
        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_LOG_COMPLETE, data);

    end
end


----------------------------------------- 获取敌方列表信息 ---------------------------------------------------------------------------------------------

function YaoyuanProxy.TryGetDiDuiXianMenNembers()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetDiDuiXianMenNembers, { });

end


--[[
0E 获取设置过的敌对帮会成员列表（随机18个）
输出：
st：玩家的偷取次数
tm:  [{pid:player_id玩家ID，n：玩家昵称，l:等级，c:career职业，st：被偷取次数},..]


]]
function YaoyuanProxy.TryGetDiDuiXianMenNembersResult(cmd, data)

    if (data.errCode == nil) then
        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_DIDUI_XIANMEN_YAOQING_LIST_COMPLETE, data);

    end
end


--------------------------------------------------------------------------------------------------------------------------------------

--[[
S <-- 17:49:49.265, 0x140C, 0, {"name":"\u5211\u5E38\u575A","pf":{"e":0,"st":1470190475000,"gts":0,"sts":0,"odd":300000,"gt":1470314952691,"wt":0,"l":1},"f":1,"id":"20100002"}

0C 对方是否接受邀请守护回复消息（服务端发出）
输出：
id：玩家ID
name：玩家呢陈
f:0:拒绝1:同意
pf:（wt:浇水次数，gts：守护次数,gt：守护时间,sts:偷药次数，st：最近一次偷药时间，odd:额外增加的守护概率）（同意才有）


]]

function YaoyuanProxy.RecAcceptForShouHuResult(cmd, data)

    if (data.errCode == nil) then
        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_SHOUHU_TJ, data);

    end
end

--------------------------------------------------------------------------------------------------------------------------------------------------

function YaoyuanProxy.AcceptForShouHu(id, f)


    SocketClientLua.Get_ins():SendMessage(CmdType.AcceptForShouHu, { id = id, f = f });

end


--[[

0B 是否同意接受守护
输入：
id：玩家id
f:0:拒绝1:同意
输出：
f:0:拒绝1:同意
pf:（wt:浇水次数，gts：守护次数,gt：守护时间,sts:偷药次数，st：最近一次偷药时间，odd:额外增加的守护概率）（同意才有）


]]
function YaoyuanProxy.AcceptForShouHuResult(cmd, data)

    if (data.errCode == nil) then


        YaoyuanProxy._0x140AData[data.id] = nil;
        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_0X140ADATA);
    end
end




------------------------------------------------------------------------------------------------------------------------





function YaoyuanProxy.Get0x140AData()

    local res = { };
    local res_index = 1;
    for key, value in pairs(YaoyuanProxy._0x140AData) do
        res[res_index] = value;
        res_index = res_index + 1;
    end

    return res;

end


function YaoyuanProxy.CleanAll0x140AData()
    YaoyuanProxy._0x140AData = { };
    MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_0X140ADATA);
end


-----------------------------------------------------------------------------------------------------------------

function YaoyuanProxy.TryInviteForShouHu(id)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryInviteForShouHu, { id = id });

end


--[[


]]
function YaoyuanProxy.TryInviteForShouHuResult(cmd, data)

    if (data.errCode == nil) then

        MsgUtils.ShowTips("Yaoyuan/YaoyuanProxy/label2", { n = data.n });
    end
end


-------------------------------------------------------------------------------------------------------------------------------------------

function YaoyuanProxy.TryGetXMYaoQingList()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetMyXianMenNembers, { o = 0 });

end


--[[
S <-- 14:58:52.871, 0x140D, 47, {"tm":[
{"n":"\u4EFB\u4EA6\u6DB5","pid":"20100341","wts":0,"c":0,"l":99},{"n":"\u9C81\u82F1\u6770","pid":"20100280","wts":0,"c":101000,"l":48}]}

 S <-- 18:00:10.017, 0x140D, 34, {"tm":[
 {"e":4,"gts":0,"n":"\u9F99\u9704\u751F","pid":"20100293","wts":0,"c":101000,"l":67}]}

]]
function YaoyuanProxy.TryGetXMYaoQingListResult(cmd, data)

    if (data.errCode == nil) then

        local tm = data.tm;

        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_YAOQING_LIST_COMPLETE, tm);

    end
end


-----------------------------------------   一键浇水    TryJiaoShuiAll     ----------------------------------------------------


--[[
10 一键浇水
输出：
id:对方玩家ID
输出：
farms:{[i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数...]}
items:[(spid,num)....]

]]
function YaoyuanProxy.TryJiaoShuiAll(id, hander, hander_tg)

    YaoyuanProxy.jiaoshuiHD = hander;
    YaoyuanProxy.jiaoshuiHDTg = hander_tg;


    SocketClientLua.Get_ins():SendMessage(CmdType.TryJiaoShuiAll, { id = id .. "" });

end


--[[
10 一键浇水
输出：
id:对方玩家ID
输出：
farms:{[i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数...]}
items:[(spid,num)....]

]]
function YaoyuanProxy.TryJiaoShuiAllResult(cmd, data)

    if (data.errCode == nil) then

        local items = data.items;


        BroadcastListManager.Get_ins():Crean();
        BroadcastListManager.Get_ins():AddMsg(LanguageMgr.Get("Yaoyuan/YaoyuanProxy/label3"), 50);

        local t_num = table.getn(items);


        for i = 1, t_num do
            local obj = items[i];
            local spId = obj.spId;
            local am = obj.am;
            local cf = ProductManager.GetProductById(spId);

            BroadcastListManager.Get_ins():AddMsg(LanguageMgr.Get("Yaoyuan/YaoyuanProxy/label4", { a = am, n = cf.name }), 50);
        end

        BroadcastListManager.Get_ins():Start();



        if YaoyuanProxy.jiaoshuiHD ~= nil then
            YaoyuanProxy.jiaoshuiHD(YaoyuanProxy.jiaoshuiHDTg, data);
        end

        YaoyuanProxy.TryGetYaoYuanJs_Ty_time()

    end
end






-------------------------------------------------------------------------------------------------

function YaoyuanProxy.TryYaoYuanJiaoShui(id, index, hander, hander_tg)

    YaoyuanProxy.jiaoshuiHD = hander;
    YaoyuanProxy.jiaoshuiHDTg = hander_tg;


    SocketClientLua.Get_ins():SendMessage(CmdType.TryYaoYuanJiaoShui, { id = id .. "", index = index });

end


--[[
05 浇水
输入：
id:对方玩家ID
index：下标
输出：
farm:i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数
items:[(spid,num)....]

]]
function YaoyuanProxy.TryYaoYuanJiaoShuiResult(cmd, data)

    if (data.errCode == nil) then

        if YaoyuanProxy.jiaoshuiHD ~= nil then
            YaoyuanProxy.jiaoshuiHD(YaoyuanProxy.jiaoshuiHDTg, data);
        end

        YaoyuanProxy.TryGetYaoYuanJs_Ty_time()

    end
end


----------------------------------------------------------------------------------------------------------------


function YaoyuanProxy.TryGetXianMenNumberInfo(pid, type, j_info)
    YaoyuanProxy.getNumberInfo_type = type;
    YaoyuanProxy.getNumberInfo = j_info;

    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetXianMenNumberInfo, { id = pid .. "" });
end


--[[
04 获取玩家药园信息
输入：
id:对方玩家ID
输出：
farms:[i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数](为空，表示对方还没有开启药园)
]]

function YaoyuanProxy.TryGetXianMenNumberInfoResult(cmd, data)

    if (data.errCode == nil) then

        data.type = YaoyuanProxy.getNumberInfo_type;
        data.hinfo = YaoyuanProxy.getNumberInfo;

        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_INFO_COMPLETE, data);


    end
end

----------------------------------------------------------------------------------


function YaoyuanProxy.TryGetMyXianMenNembers()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetMyXianMenNembers, { o = 1 });

end


--[[
S <-- 14:58:52.871, 0x140D, 47, {"tm":[{"n":"\u4EFB\u4EA6\u6DB5","pid":"20100341","wts":0,"c":0,"l":99},{"n":"\u9C81\u82F1\u6770","pid":"20100280","wts":0,"c":101000,"l":48}]}
]]
function YaoyuanProxy.TryGetMyXianMenNembersResult(cmd, data)

    if (data.errCode == nil) then

        local tm = data.tm;

        MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_MY_XIANMEN_NUMBER_CHANGE, tm);

    end
end


-----------------------------------------------------------------------------------


function YaoyuanProxy.TryHarvestAll()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryHarvestAll, { });

end




-- S <-- 20:37:04.255, 0x1406, 15, {"farm":{"st":0,"gt":0,"s":"","wt":0,"i":3},"items":[{"am":10,"spId":355001}]}
--[[
输入：
输出：
farms:[i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数](为空，表示没有成熟的药田，不能收获)
items:[(spid,num)....]
]]
function YaoyuanProxy.TryHarvestAllResult(cmd, data)

    if (data.errCode == nil) then

        -- 收获成功
        local farms = data.farms;

        table.sort(farms, function(a, b) return a.i < b.i end);

        local idxs = { };
        local t_num = table.getn(farms);

        if t_num > 0 then
            for i = 1, t_num do
                idxs[i] = farms[i].i;
            end

            FarmsControll.ins.plantHarvestEffCtr:PlayMc(idxs, YaoyuanProxy.plantHarvestEffCtrComplete);

        else
            MsgUtils.ShowTips("Yaoyuan/YaoyuanProxy/label11");

        end

    end
end

--------------------------------------------------------------------



function YaoyuanProxy.TryHarvest(index)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryHarvest, { index = index });


end

-- S <-- 20:37:04.255, 0x1406, 15, {"farm":{"st":0,"gt":0,"s":"","wt":0,"i":3},"items":[{"am":10,"spId":355001}]}
function YaoyuanProxy.TryHarvestResult(cmd, data)

    if (data.errCode == nil) then

        -- 收获成功
        local farm = data.farm;
        local i = farm.i;

        local items = data.items;

        local cf = ProductManager.GetProductById(items[1].spId)

        MsgUtils.ShowTips("Yaoyuan/YaoyuanProxy/label4", { a = items[1].am, n = cf.name });
        FarmsControll.ins.plantHarvestEffCtr:PlayMc( { i }, YaoyuanProxy.plantHarvestEffCtrComplete);

    end
end

function YaoyuanProxy.plantHarvestEffCtrComplete()

    YaoyuanProxy.TryOpenYaoYuan();
end



----------------------------------------------------

function YaoyuanProxy.TryOpenYaoYuan()


    SocketClientLua.Get_ins():SendMessage(CmdType.TryJoinYaoyuan, { });

end

--[[


 S <-- 16:23:43.438, 0x1401, 74, {"farms":[{"st":0,"sp":"","gt":28796,"s":"356056","wt":0,"i":2,"wp":""},{"st":0,"sp":"","gt":28799,"s":"356053","wt":0,"i":4,"wp":""},{"st":0,"sp":"","gt":28789,"s":"356050","wt":0,"i":1,"wp":""},{"st":0,"sp":"","gt":28793,"s":"356059","wt":0,"i":3,"wp":""}],"pf":{"e":3,"st":1480315232000,"gts":0,"sts":0,"et":1480321232000,"odd":0,"exp":200,"gt":0,"wt":4,"l":1,"gpi":""}}
 S <-- 16:23:51.655, 0x1401, 76, {"farms":[{"st":0,"sp":"","gt":28788,"s":"356056","wt":0,"i":2,"wp":""},{"st":0,"sp":"","gt":28791,"s":"356053","wt":0,"i":4,"wp":""},{"st":0,"sp":"","gt":28781,"s":"356050","wt":0,"i":1,"wp":""},{"st":0,"sp":"","gt":28185,"s":"356059","wt":1,"i":3,"wp":"_10100028"}],"pf":{"e":3,"st":1480315232000,"gts":0,"sts":0,"et":1480321232000,"odd":0,"exp":200,"gt":0,"wt":4,"l":1,"gpi":""}}
]]


function YaoyuanProxy.TryJoinYaoyuanResult(cmd, data)

    if (data.errCode == nil) then


        if YaoyuanProxy.isDebug then
            -- 测试改变数据

            FarmsDataManager.InitData(YaoyuanProxy.debug_baseData);

            YaoyuanProxy.debugNum = 200;
            FixedUpdateBeat:Remove(YaoyuanProxy.TestTryHarvest, YaoyuanProxy);
            UpdateBeat:Add(YaoyuanProxy.TestTryHarvest, YaoyuanProxy);


        end


        FarmsDataManager.InitData(data);

    end
end

function YaoyuanProxy.TestTryHarvest()

    if YaoyuanProxy.debugNum > 0 then

        YaoyuanProxy.debugNum = YaoyuanProxy.debugNum - 1;

        if YaoyuanProxy.debugNum == 0 then
            FarmsDataManager.InitData(YaoyuanProxy.debug_extData);
            FixedUpdateBeat:Remove(YaoyuanProxy.TestTryHarvest, YaoyuanProxy);
        end

    end

end


--[[
03 播种
输入：
idxs：{[下标]...}
ids:{[物品ID]...}
输出：
farms:{[i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数]...}


]]
function YaoyuanProxy.TryZhongzhi(list)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryZhongzhi, list);

end

function YaoyuanProxy.TryZhongzhiResult(cmd, data)

    if (data.errCode == nil) then
        YaoyuanProxy.TryOpenYaoYuan();

        MsgUtils.ShowTips("Yaoyuan/YaoyuanProxy/label10");
    end
end


----------------------------------------------------
function YaoyuanProxy.OpenPanelForYaoyuan(id)


    SocketClientLua.Get_ins():SendMessage(CmdType.OpenPanelForYaoyuan, { index = id });

end

function YaoyuanProxy.OpenPanelForYaoyuanResult(cmd, data)

    if (data.errCode == nil) then
        YaoyuanProxy.TryOpenYaoYuan();
    end
end


function YaoyuanProxy.YijianChengshu(id)


    SocketClientLua.Get_ins():SendMessage(CmdType.YijianChengshu, { index = id });

end

function YaoyuanProxy.YijianChengshuResult(cmd, data)

    if (data.errCode == nil) then
        YaoyuanProxy.TryOpenYaoYuan();
    end
end