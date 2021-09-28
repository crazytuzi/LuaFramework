require "Core.Module.Pattern.Proxy"

ActivityGiftsProxy = Proxy:New();




function ActivityGiftsProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLimitBuyInfo, ActivityGiftsProxy.GetLimitBuyInfoCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetRechageAwardLog, ActivityGiftsProxy.GetRechageAwardLogResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RechageAwarChange, ActivityGiftsProxy.RechageAwarChangeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetTotalRechageAward, ActivityGiftsProxy.GetTotalRechageAwardResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetYueKaInfos, ActivityGiftsProxy.GetYueKaInfosResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetYueKaAwards, ActivityGiftsProxy.GetYueKaAwardsResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetChengZhangJiJingInfos, ActivityGiftsProxy.GetChengZhangJiJingInfosResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetChengZhangJiJingAwards, ActivityGiftsProxy.GetChengZhangJiJingAwardsResult);
end

function ActivityGiftsProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLimitBuyInfo, ActivityGiftsProxy.GetLimitBuyInfoCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetRechageAwardLog, ActivityGiftsProxy.GetRechageAwardLogResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RechageAwarChange, ActivityGiftsProxy.RechageAwarChangeResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetTotalRechageAward, ActivityGiftsProxy.GetTotalRechageAwardResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetYueKaInfos, ActivityGiftsProxy.GetYueKaInfosResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetYueKaAwards, ActivityGiftsProxy.GetYueKaAwardsResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetChengZhangJiJingInfos, ActivityGiftsProxy.GetChengZhangJiJingInfosResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetChengZhangJiJingAwards, ActivityGiftsProxy.GetChengZhangJiJingAwardsResult);

end

function ActivityGiftsProxy.SendGetLimitBuyInfo(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.GetLimitBuyInfo, { id = id });
end

function ActivityGiftsProxy.GetLimitBuyInfoCallBack(cmd, data)
    if (data and data.errCode == nil) then
        ActivityGiftsDataManager.SetLimitBuyInfo(data.l)
        ModuleManager.SendNotification(ActivityGiftsNotes.UPDATE_ACTIVITYGIFTSPANEL)
    end
end

function ActivityGiftsProxy.GetTotalRechageAward(id)


    SocketClientLua.Get_ins():SendMessage(CmdType.GetTotalRechageAward, { id = id });

end


function ActivityGiftsProxy.GetTotalRechageAwardResult(cmd, data)


    if (data.errCode == nil) then

        local id = data.id;
        RechargRewardDataManager.SetListHasGetAwardByTypeId(RechargRewardDataManager.TYPE_TOTAL_RECHARGE, id);
         MessageManager.Dispatch(ActivityGiftsNotes,ActivityGiftsNotes.UPDATE_ACTIVITY_GIFT_MSGS);

    end
end

function ActivityGiftsProxy.RechageAwarChangeResult(cmd, data)
    ActivityGiftsProxy.GetRechageAwardLog();
  
end 


function ActivityGiftsProxy.GetRechageAwardLog()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetRechageAwardLog, { });

end

--[[
07 获取累计充值奖励礼包
输入：
输出：
l:[(id:礼包id recharge_reward的kind字段,s：礼包状态（(0：未领取1：已领取2：邮件发送)）)....] 礼包

]]
function ActivityGiftsProxy.GetRechageAwardLogResult(cmd, data)


    if (data.errCode == nil) then

        RechargRewardDataManager.SetRecharge(data.rmb, data.l);

    end
end


----------------------------------------------------------------------------------------------------------------------
ActivityGiftsProxy.MESSAGE_GETYUEKAINFOS_COMPLETE = "MESSAGE_GETYUEKAINFOS_COMPLETE";
ActivityGiftsProxy.MESSAGE_GETYUEKAAWARDS_COMPLETE = "MESSAGE_GETYUEKAAWARDS_COMPLETE";

function ActivityGiftsProxy.GetYueKaInfos()


    SocketClientLua.Get_ins():SendMessage(CmdType.GetYueKaInfos, { });

end


ActivityGiftsProxy._YueKaInfos_neeShowTip = false;
function ActivityGiftsProxy.CheckYueKaInfos(data)

    local s = data.s;
    local f = data.f;
    ActivityGiftsProxy._YueKaInfos_neeShowTip = false;
    if f == 1 then
        ActivityGiftsProxy._YueKaInfos_neeShowTip = false;
    else
        ActivityGiftsProxy._YueKaInfos_neeShowTip = true;
    end

    if s == 0 then
        ActivityGiftsProxy._YueKaInfos_neeShowTip = false;
    else

        if ActivityGiftsProxy._YueKaInfos_neeShowTip then
            ActivityGiftsProxy._YueKaInfos_neeShowTip = true;
        end

    end

    MessageManager.Dispatch(ActivityGiftsNotes,ActivityGiftsNotes.UPDATE_ACTIVITY_GIFT_MSGS);

end

--  第一出需要 请求  ActivityGiftsProxy.GetYueKaInfos()
function ActivityGiftsProxy.GetYueKaInfos_neeShowTip()
    return ActivityGiftsProxy._YueKaInfos_neeShowTip;
end

--[[
l：[{rid,s : int 剩余次数 0：无,f : int 1:表示已领取 0： 表示未领取},..]
]]
function ActivityGiftsProxy.GetYueKaInfosResult(cmd, data)


    if (data.errCode == nil) then

        local hasSetYueKa = false;

        local t_num = table.getn(data.l);
        for i = 1, t_num do
            local obj = data.l[i];

            if obj.rid == 1 then
                hasSetYueKa = true;
                ActivityGiftsProxy.CheckYueKaInfos(obj)
                MessageManager.Dispatch(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETYUEKAINFOS_COMPLETE, obj);
            end
        end

        if not hasSetYueKa then
            local obj = { rid = 1, s = 0, f = 0 };
            ActivityGiftsProxy.CheckYueKaInfos(obj)
            MessageManager.Dispatch(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETYUEKAINFOS_COMPLETE, obj);
        end

    end
end

------ recharge.lua 的 id
function ActivityGiftsProxy.GetYueKaAwards(id)

    SocketClientLua.Get_ins():SendMessage(CmdType.GetYueKaAwards, { rid = tonumber(id) });

end

--[[
03 月卡领取奖励剩余次数
输入：
输出：
s : int 剩余次数 0：无
]]
function ActivityGiftsProxy.GetYueKaAwardsResult(cmd, data)


    if (data.errCode == nil) then
        MessageManager.Dispatch(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETYUEKAAWARDS_COMPLETE, data);
    end
end

---------------------------------------------------------------------------------------------------------------------------

ActivityGiftsProxy.MESSAGE_GETCHENGZHANGJIJINGINFOS_COMPLETE = "MESSAGE_GETCHENGZHANGJIJINGINFOS_COMPLETE";


function ActivityGiftsProxy.GetChengZhangJiJingInfos()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetChengZhangJiJingInfos, { });

end


ActivityGiftsProxy.ChengZhangJiJing_needTip = false;

function ActivityGiftsProxy.CheckChengZhangJiJingInfos(list)
    local list_num = table.getn(list);
    ActivityGiftsProxy.ChengZhangJiJing_needTip = false;

    for i = 1, list_num do
        local data = list[i];
        if data.f == 1 then
            ActivityGiftsProxy.ChengZhangJiJing_needTip = true;
            return;
        end

    end

end

--  第一出需要 请求  ActivityGiftsProxy.GetChengZhangJiJingInfos()
-- 游戏初始化的时候 回调用
function ActivityGiftsProxy.GetChengZhangJiJing_needTip()
    return ActivityGiftsProxy.ChengZhangJiJing_needTip;
end

--[[
08 玩家是否购买成长基金
输入：
输出：
l:[(id(配表id) :Int,f：Int 领取状态（(0：不可领取 1：可领取但未领取 2：已领取)]
s : Int 0 ：表示未购买 1 ：已购买
buy_lv : Int  已经购买的时候用到，购买时的角色的等级


]]
ActivityGiftsProxy._0x1a08Data = nil;
function ActivityGiftsProxy.GetChengZhangJiJingInfosResult(cmd, data)

    if (data.errCode == nil) then

        ActivityGiftsProxy._0x1a08Data = data;


        ActivityGiftsProxy.CheckChengZhangJiJingInfos(data.l);
        MessageManager.Dispatch(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETCHENGZHANGJIJINGINFOS_COMPLETE, data.l);
        MessageManager.Dispatch(ActivityGiftsNotes,ActivityGiftsNotes.UPDATE_ACTIVITY_GIFT_MSGS);
    end
end


function ActivityGiftsProxy.CheckHasGetAllChengZhangJiJin(list)
    local t_num = table.getn(list);
    if t_num == 0 then
        return false;
    end

    for k, v in ipairs(list) do
        if v.f ~= 2 then
            return false;
        end
    end

    return true;
end


function ActivityGiftsProxy.GetChengZhangJiJingAwards(id)

    SocketClientLua.Get_ins():SendMessage(CmdType.GetChengZhangJiJingAwards, { id = id });

end



--[[
08 玩家是否购买成长基金
输入：
输出：
l:[(id(配表id) :Int,f：Int 领取状态（(0：不可领取 1：可领取但未领取 2：已领取)]

]]
function ActivityGiftsProxy.GetChengZhangJiJingAwardsResult(cmd, data)


    if (data.errCode == nil) then
        ActivityGiftsProxy.GetChengZhangJiJingInfos();
    end
end

function ActivityGiftsProxy.HasTips()
	return ActivityGiftsProxy.GetYueKaInfos_neeShowTip()
        or ActivityGiftsProxy.GetChengZhangJiJing_needTip()
        or RechargRewardDataManager.GetIsHasAwardToGet(RechargRewardDataManager.TYPE_TOTAL_RECHARGE)
end

