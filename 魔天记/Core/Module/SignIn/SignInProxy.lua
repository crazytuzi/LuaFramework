require "Core.Module.Pattern.Proxy"

SignInProxy = Proxy:New();
function SignInProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Sign, SignInProxy.SendSignCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ReSign, SignInProxy.SendReSignCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSignData, SignInProxy.SendGetSignDataCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetInLineInfo, SignInProxy.TryGetInLineInfoResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetInLineAward, SignInProxy.TryGetInLineAwardResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetRevertAward, SignInProxy._RspRevertAwardInfo);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SignInRevertAward, SignInProxy._RspRevertAward);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLogin7AwardInfos, SignInProxy.GetLogin7AwardInfosResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLogin7Award, SignInProxy.GetLogin7AwardResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetChongJiInfos, SignInProxy.GetChongJiInfosResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetChongJiAwards, SignInProxy.GetChongJiAwardsResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetVipDailyAward, SignInProxy._RspGetVipDailyAward);

end

function SignInProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Sign, SignInProxy.SendSignCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ReSign, SignInProxy.SendReSignCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetSignData, SignInProxy.SendGetSignDataCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetInLineInfo, SignInProxy.TryGetInLineInfoResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetInLineAward, SignInProxy.TryGetInLineAwardResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetRevertAward, SignInProxy._RspRevertAwardInfo);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SignInRevertAward, SignInProxy._RspRevertAward);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLogin7AwardInfos, SignInProxy.GetLogin7AwardInfosResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetChongJiInfos, SignInProxy.GetChongJiInfosResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetChongJiAwards, SignInProxy.GetChongJiAwardsResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetVipDailyAward, SignInProxy._RspGetVipDailyAward);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLogin7Award, SignInProxy.GetLogin7AwardResult);



end

function SignInProxy.SendSignCallBack(cmd, data)
    if (data and data.errCode == nil) then
        local temp = SignInManager.GetDailySignInData()
        temp.f = 1
        temp.n = data.n
        SignInManager.SetDailySignInData(temp)
        ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP)
        ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANEL)
    end
end


function SignInProxy.SendReSignCallBack(cmd, data)
    if (data and data.errCode == nil) then
        local temp = SignInManager.GetDailySignInData()
        temp.n = data.n
        temp.bn = data.bn
        SignInManager.SetDailySignInData(temp)
        ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANEL)
    end
end

function SignInProxy.SendGetSignDataCallBack(cmd, data)
    if (data and data.errCode == nil) then
        SignInManager.SetDailySignInData(data)
        ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP)
        ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANEL)
    end
end

function SignInProxy.SendSign()
    SocketClientLua.Get_ins():SendMessage(CmdType.Sign, { });
end

function SignInProxy.SendReSign()
    local resignConfig = SignInManager.GetReSignSpendConfig(SignInManager.GetReSignCount() + 1)
    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL,
    {
        msg = LanguageMgr.Get("SignIn/SubSignInDailyPanel/resignNotice",{ num = resignConfig.price, name = SpecialProductDes[resignConfig.item] }),
        hander = function() SocketClientLua.Get_ins():SendMessage(CmdType.ReSign, { }) end
    } )

end

function SignInProxy.SendGetSignData()
    SocketClientLua.Get_ins():SendMessage(CmdType.GetSignData, { });
end

-------------------------------------------------- SubInLine -------------------------------------------------------------------

-- 40 获取在线时间领取奖励信息
function SignInProxy.TryGetInLineInfo()
    SubInLineItem.CanGetAward = false;

    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetInLineInfo, { });


    -- 测试
    --   OnlineRewardManager.SetServerInfo(29*60,2);
end

--[[
40 获取在线时间领取奖励信息
输出：
ot:在线时间（秒）
id:在线领取记录(下标)
]]
function SignInProxy.TryGetInLineInfoResult(cmd, data)


    if (data.errCode == nil) then
        OnlineRewardManager.SetServerInfo(math.floor(data.ot * 0.001), tonumber(data.id));
        ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP);
    end

end

--    41 获取奖励（领取之后，上线时间清0）
function SignInProxy.TryGetInLineAward(id)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetInLineAward, { id = tonumber(id) });

end

--[[
41 获取奖励（领取之后，上线时间清0）
输入：
id：下标
输出：
l：[{spId,am},...]

]]
function SignInProxy.TryGetInLineAwardResult(cmd, data)

    if (data.errCode == nil) then
        -- SignInProxy.TryGetInLineInfo();
        local res = { };
        res.id = data.id;
        res.ot = data.ot;
        SignInProxy.TryGetInLineInfoResult(nil, res)
    end

end


---------------------------------------------------[离线奖励]--------------------------------------------------------------

function SignInProxy.ReqRevertAwardInfo()

    SocketClientLua.Get_ins():SendMessage(CmdType.TryGetRevertAward, nil);
end


function SignInProxy._RspRevertAwardInfo(cmd, data)

    if (data == nil or data.errCode ~= nil) then
        return;
    end

    SignInProxy.tmpRevertList = data.l;
    -- 设置红点标识.
    SignInProxy.CheckRevertAward();

    SignInProxy.UpdateRevertData();
    MessageManager.Dispatch(SignInNotes, SignInNotes.ENV_REVERTAWARD_RSP, SignInProxy.tmpRevertList);
end 

function SignInProxy.ReqRevertAward(id, type)

    local t = type == SubSignInRevertAwardItem.Type.Gold and 2 or 1;
    SocketClientLua.Get_ins():SendMessage(CmdType.SignInRevertAward, { id = id, t = t });
end

function SignInProxy._RspRevertAward(cmd, data)

    if (data == nil or data.errCode ~= nil) then
        return;
    end

    local cfg = nil;
    for i, v in ipairs(SignInProxy.tmpRevertList) do
        cfg = SignInManager.GetRevertCfgById(v.id);
        if cfg.activity_id == data.id then
            v.am = data.am;
            v.am1 = data.am1;
            break;
        end
    end

    SignInProxy.CheckRevertAward();

    SignInProxy.UpdateRevertData();
    MessageManager.Dispatch(SignInNotes, SignInNotes.ENV_REVERTAWARD_RSP, SignInProxy.tmpRevertList);
end

function SignInProxy.CheckRevertAward()
    local flg = false
    for i, v in ipairs(SignInProxy.tmpRevertList) do
        if v.am > v.am1 then
            flg = true;
            break;
        end
    end
    -- Warning(tostring(flg) ..  '___' .. tostring(SignInManager.canRevertAward))
    if flg ~= SignInManager.canRevertAward then SignInManager.SetCanRevertAward(flg) end
end
local _sortfunc = table.sort 

function SignInProxy.UpdateRevertData()
    for i, v in ipairs(SignInProxy.tmpRevertList) do
        local cfg = SignInManager.GetRevertCfgById(v.id);
        v.sortIdx = cfg.sort;
        v.isOver = v.am1 == v.am;
    end
    _sortfunc(SignInProxy.tmpRevertList, SignInProxy.SortRevertList);
end

function SignInProxy.SortRevertList(a, b)
    if a.isOver == b.isOver then
        return a.sortIdx < b.sortIdx;
    elseif a.isOver then
        return false;
    else
        return true;
    end
end


---------------------------------------------------SubLogin7Reward-------------------------------------------------------------------------

--[[
04 获取7日领取信息
输入：
输出：
t:累计登陆次数
f:[{id}] 奖励领取标示


]]
function SignInProxy.GetLogin7AwardInfos()

    SubInLineItem.CanGetAward = false;

    SocketClientLua.Get_ins():SendMessage(CmdType.GetLogin7AwardInfos, { });


end


function SignInProxy.GetLogin7AwardInfosResult(cmd, data)


    if (data.errCode == nil) then

        -- 模拟测试

        -- data.t = 6;
        -- data.r={{id=1},{id=2},{id=3},{id=4},{id=5},{id=6},{id=7},{id=8},{id=9},{id=10},{id=11},{id=12}};
        -- data.r={{id=1},{id=2},{id=3},{id=4},{id=5}};

        Login7RewardManager.SetData(data.t, data.r);
        ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP);

    end
end



function SignInProxy.GetLogin7Award(idx)

    SubInLineItem.CanGetAward = false;

    SocketClientLua.Get_ins():SendMessage(CmdType.GetLogin7Award, { idx = idx });


end


function SignInProxy.GetLogin7AwardResult(cmd, data)


    if (data.errCode == nil) then
        SignInProxy.GetLogin7AwardInfos();
    end

    GuideManager.OptSetStatus(GuideManager.Id.GuideSevenDaySign);

end


--------------------------------------------------------- 升级礼包 -------------------------------------------------------------------------------------

function SignInProxy.GetChongJiInfos()



    SocketClientLua.Get_ins():SendMessage(CmdType.GetChongJiInfos, { });


end


SignInProxy.MESSAGE_GETCHONGJIINFOS_SUCCESS = "MESSAGE_GETCHONGJIINFOS_SUCCESS";


function SignInProxy.GetInfo(list, id)
    local list_num = table.getn(list);

    for i = 1, list_num do
        if list[i].id == id then
            return list[i];
        end
    end

    return nil;
end

SignInProxy.cangetChongJiAward = false;

--[[
0A 玩家所有的冲级礼包
输入：
输出：
l:[(id(配表id) :Int,f：Int 领取状态（(0：不可领取 1：可领取但未领取 2：已领取)]

]]
function SignInProxy.GetChongJiInfosResult(cmd, data)


    if (data.errCode == nil) then

        local list = data.l;


        local list_num = table.getn(list);
        SignInProxy.cangetChongJiAward = false
        for i = 1, list_num do

            if list[i].f == 1 then
                SignInProxy.cangetChongJiAward = true;
            end
        end

        MessageManager.Dispatch(SignInProxy, SignInProxy.MESSAGE_GETCHONGJIINFOS_SUCCESS, data.l);
    end
end

function SignInProxy.GetcangetChongJiAwards()
    return SignInProxy.cangetChongJiAward;
end

function SignInProxy.GetChongJiAwards(id)

    SocketClientLua.Get_ins():SendMessage(CmdType.GetChongJiAwards, { id = id });


end


function SignInProxy.GetChongJiAwardsResult(cmd, data)


    if (data.errCode == nil) then
        SignInProxy.GetChongJiInfos()
    end
end


-------------------------------------------------------------------------------------------------------------


function SignInProxy.ReqGetVipDailyAward()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetVipDailyAward, nil);
    -- SignInProxy._RspGetVipDailyAward(nil, {});
end

function SignInProxy._RspGetVipDailyAward(cmd, data)

    if (data == nil or data.errCode ~= nil) then
        return;
    end

    VIPManager.dailyAward = 1;
    MessageManager.Dispatch(SignInNotes, SignInNotes.ENV_VIP_DAILY_AWARD_RSP);
    ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP);
end