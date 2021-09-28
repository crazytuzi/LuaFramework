require "Core.Manager.Item.RechargRewardDataManager"
VIPManager = { }
VIPManager.VipChange = "VIPManager.VipChange"
VIPManager.BuySuccess = "BuySuccess"
VIPManager.Try_Vlaue = -1 -- vip 调用等级

ChargeType = { normal = 0, month = 1, day = 2, grow = 3, gack = 5 }

local _chargeConfig = { }
local _chargeByType = { }
local _vipConfig = { }
local _firstChargeRecord = { }
-- 我的 首充状态（(0：没有首充，1：已首充，2：已领取））}
VIPManager.my_fr = 0;
-- 第二次充值状态 (0：没有首充，1：已首充，2：已领取)
VIPManager.my_fr2 = 0;

-- vip每日礼包是否可领{0:可领取 1:已领取}
VIPManager.dailyAward = 1;

-- 获取是否可以领取首充值奖励
function VIPManager.GetFristRechargeCanGetAward()
    local flag = VIPManager.GetFirstStatus();
    return flag == 1 or flag == 3;
end

-- 初始化vip数据data
function VIPManager.Init(data)
    _firstChargeRecord = { }
    _vipConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_VIP)
    _vipCardConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_VIP_CARD)
    _vipCardConfig = ConfigManager.SortForField(_vipCardConfig, 'id')
    table.sort(_vipConfig, function(x, y) return x.lev < y.lev end)
    VIPManager._SetVipData(data)
    local socket = SocketClientLua.Get_ins()
    socket:AddDataPacketListener(CmdType.VipChange, VIPManager._VipChange);
    socket:AddDataPacketListener(CmdType.GetFirstChargeRecord, VIPManager._FirstChargeRecorder);

    VIPManager.InitCharge()
end

function VIPManager._SetVipData(data)
    VIPManager._data = data
    VIPManager._myVipLevel = data.lv
    VIPManager.downTime = GetTime()
    VIPManager._myVipConfig = VIPManager.GetConfigByLevel(VIPManager.GetSelfVIPLevel())

    VIPManager.my_fr = data.fr;
    VIPManager.my_fr2 = data.fr2 or 0;

    VIPManager.dailyAward = data.dg;

    RechargRewardDataManager.SetRMB(data.rmb)

    MessageManager.Dispatch(VIPManager, VIPManager.VipChange, data)

    -- Warning(data.lv .. '----'..VIPManager.GetVIPDownTime() )
    VIPManager.VipTryCheck()
    if data.sy == 1 then
        ModuleManager.SendNotification(VipTryNotes.OPEN_VIP_TRY_PANEL, { s = 0 })
    end
    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.VIP)
end

function VIPManager.VipTryCheck()
    if VIPManager.GetSelfVIPLevel() == VIPManager.Try_Vlaue then
        local dt = VIPManager.GetVIPDownTime()
        if dt > 0 then
            local bd = { s = 1, t = dt }
            ModuleManager.SendNotification(VipTryNotes.USE_VIP_TRY, bd)
            VIPManager.use_vip_try = true
            return bd
        end
    elseif VIPManager.use_vip_try then
        ModuleManager.SendNotification(VipTryNotes.USE_VIP_TRY, { s = 0 })
    end
    return nil
end

function VIPManager.HasVipTips()
    --    local mylev = VIPManager.GetSelfVIPLevel()
    --    local myMon = MoneyDataManager.Get_gold()
    --    for i, v in pairs(VIPManager.GetVipConfigs()) do
    -- 	local f = v.lev <= mylev and v.price <= myMon and not VIPManager.GetMyBuyedGift(v.lev)
    --        if f then return true end
    -- end
    return false
end

function VIPManager.GetFirstStatus()
    -- Warning(VIPManager.my_fr .. '----' .. VIPManager.my_fr2)
    if VIPManager.my_fr < 2 then
        return VIPManager.my_fr;
    else
        return VIPManager.my_fr + VIPManager.my_fr2;
    end
end

VIPManager.MESSAGE_RCHARGE_CHANGE = "MESSAGE_RCHARGE_CHANGE";

function VIPManager._FirstChargeRecorder(cmd, data)
    if (data and data.errCode == nil) then
        VIPManager.SetFirstChargeRecorder(data.rl)
        MallProxy.CallSuccessCallBack(data.rl)

        MessageManager.Dispatch(VIPManager, VIPManager.MESSAGE_RCHARGE_CHANGE);
    end
end

function VIPManager.SetFirstChargeRecorder(data)
    if (data) then
        for k, v in ipairs(data) do
            _firstChargeRecord[v.rid] = v.f
        end
        ModuleManager.SendNotification(MallNotes.UPDATE_MALLPANEL)
    end

end

function VIPManager._VipChange(cmd, data)
    VIPManager._SetVipData(data)
end

-- vip一次性礼包购买 vipLev等级
function VIPManager.Bug(vipLev)
    SocketClientLua.Get_ins():SendMessage(CmdType.VipBuy, { lv = vipLev })
end
-- vip配置
function VIPManager.GetVipConfigs()
    return _vipConfig
end
-- vip卡配置
function VIPManager.GetVipCardConfigs()
    return _vipCardConfig
end
-- vip卡配置
function VIPManager.GetVipCardConfigById(id)
    local cs = VIPManager.GetVipCardConfigs()
    for k, c in pairs(cs) do
        if c.id == id then return c end
    end
end
-- 我的vip特权等级,逻辑用
function VIPManager.GetSelfVIPLevel()
    return VIPManager.GetVIPDownTime() > 0 and VIPManager._myVipLevel or 0
end
-- 我的vip等级
function VIPManager.GetSelfVIPLevel2()
    return VIPManager._myVipLevel
end
-- vip等级转换显示用等级,vip为nil取自己的等级
function VIPManager.GetVIPShowLevel(vip)
    vip = vip or VIPManager._myVipLevel
    return vip == VIPManager.Try_Vlaue and 2 or vip
end
-- 我的vip等级
function VIPManager.HasVIPLev()
    return VIPManager._myVipLevel > 0
end
-- 我的vip等级经验
function VIPManager.GetVIPExp()
    return VIPManager._data and VIPManager._data.exp or 0
end
function VIPManager.GetVIPDownTime()
    return VIPManager._data and(VIPManager._data.rt -(GetTime() - VIPManager.downTime)) or -1
end


function VIPManager.GetSelfTeam_instance_Max_buy_num(ins_type)
    local myvip = VIPManager.GetSelfVIPLevel();

    local vipcf = VIPManager.GetConfigByLevel(myvip);
    -- local team_instance_num = vipcf.team_instance_num;
    local dekaron_num = vipcf.dekaron_num;

    for i, v in pairs(dekaron_num) do
        local arr = ConfigSplit(v);
        if tonumber(arr[1]) == tonumber(ins_type) then
            return tonumber(arr[2]);
        end
    end

    return 0;
end


-- 返回vip等级对应的配置
function VIPManager.GetConfigByLevel(vipLevel)
    for i, v in pairs(_vipConfig) do
        if v.lev == vipLevel then return v end
    end
end
-- 返回我的vip等级对应的配置
function VIPManager.GetSelfConfig()
    return VIPManager._myVipConfig
end

-- vip经验加成
function VIPManager.GetSelfExp_per()
    return VIPManager.GetSelfConfig().exp_per;
end
function VIPManager.GetVipAttrs()
    local baseAttrInfo = BaseAdvanceAttrInfo:New()
    baseAttrInfo:Add(VIPManager.GetSelfConfig())
    -- for k,v in pairs(baseAttrInfo) do Warning(k ..'---'.. tostring(v)) end
    return baseAttrInfo
end

-- 返回我的竞技场次数
function VIPManager.GetArenaNum()
    local vipdata = VIPManager.GetSelfConfig()
    return vipdata.arena_num
end
-- 返回我的每日仙玉炼宝次数
function VIPManager.GetTrumpNum()
    local vipdata = VIPManager.GetSelfConfig()
    return vipdata.trump_lianbao
end
-- 返回我的悬赏购买次数
function VIPManager.GetBountyNum()
    local vipdata = VIPManager.GetSelfConfig()
    return vipdata.bounty_num
end
-- 返回我的虚灵塔扫荡购买次数
function VIPManager.GetSweepNum()
    local vipdata = VIPManager.GetSelfConfig()
    return vipdata.sweep_num
end
-- 返回我的虚灵塔挑战购买次数
--[[function VIPManager.GetDekaronNum()
    local vipdata = VIPManager.GetSelfConfig()
    return vipdata.dekaron_num
end
]]
-- 返回我的剧情副本重置次数
function VIPManager.GetInstanceNum()
    local vipdata = VIPManager.GetSelfConfig()
    return vipdata.instance_num
end
-- 返回最大的vip等级
function VIPManager.GetMaxVipLevel()
    return #_vipConfig
end
-- 返回下个vip等级还要充值多少
function VIPManager.GetNextLevelMoney(level)
    local c1 = VIPManager.GetConfigByLevel(level)
    local c2 = VIPManager.GetConfigByLevel(level - 1)
    return c2 and c1.req_gold - c2.req_gold or c1.req_gold
end
-- 返回我下个vip等级还要充值多少
function VIPManager.GetMyNextLevelMoney()
    local gap = VIPManager.GetConfigByLevel(VIPManager.GetSelfVIPLevel()).req_gold
    return gap - VIPManager._data.rmb
end
-- 返回我是否购买vip等级对应礼包
function VIPManager.GetMyBuyedGift(vipLev)
    -- return VIPManager._data.gifts[vipLev + 1] == 1
    return true
end
-- 返回vip等级对应经验
function VIPManager.GetMyNextExp(vipLev)
    return VIPManager.GetConfigByLevel(vipLev).vip_exp
end
local insert = table.insert

-- 返回 配置对应礼包格式{ProductInfo...}
function VIPManager.GetGift(config)
    local gs = { }
    for i, ss in pairs(config.vip_gift) do
        local s = string.split(ss, '_')
        local productInfo = ProductInfo:New()
        productInfo:Init( { spId = tonumber(s[1]), am = tonumber(s[2]) })
        insert(gs, productInfo)
    end
    return gs
end
-- 返回 配置对应特权
function VIPManager.GetPrivilege(config)
    local gs = { }
    local s = LanguageMgr.Get("Mall/vip/Privilege1")
    if string.len(s) > 0 then insert(gs, s .. config.arena_num) end
    s = LanguageMgr.Get("Mall/vip/Privilege2")
    if string.len(s) > 0 then insert(gs, s .. config.trump_lianbao) end
    s = LanguageMgr.Get("Mall/vip/Privilege3")
    if string.len(s) > 0 then insert(gs, s .. config.bounty_num) end
    s = LanguageMgr.Get("Mall/vip/Privilege4")
    if string.len(s) > 0 then insert(gs, s .. config.sweep_num) end
    s = LanguageMgr.Get("Mall/vip/Privilege5")
    -- if string.len(s) > 0 then insert(gs, s .. config.dekaron_num) end
    -- s = LanguageMgr.Get("Mall/vip/Privilege6")
    if string.len(s) > 0 then insert(gs, s .. config.instance_num) end
    return gs
end
-- 返回 vip等级对应的标识名
function VIPManager.GetLevFlg(lev)
    local c1 = VIPManager.GetConfigByLevel(lev)
    return c1.vip_des
end

function VIPManager.CanGetDailyAward()
    return VIPManager.GetSelfVIPLevel() > 0 and VIPManager.dailyAward <= 0;
end

function VIPManager.OnNewDailyAward()
    _firstChargeRecord[13] = 0
    -- 神器刷新
    VIPManager.dailyAward = 0;
end

--------------------------------充值------------------
-- 初始化充值
function VIPManager.InitCharge()
    _chargeConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CHARGEP)
    _chargeByType = { }
    local _chargeRectIdConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CHARGEREFECTID)
    SDKHelper.instance:InitCharge(_chargeRectIdConfig)
    SDKHelper.instance:SetSdkPayCallBack(VIPManager.PaySuccess, VIPManager.PayFaild);
    for k, v in ipairs(_chargeConfig) do
        v = ConfigManager.Clone(v)
        if (_chargeByType[v.type] == nil) then
            _chargeByType[v.type] = { }
        end

        insert(_chargeByType[v.type], v)
    end

end
local json = require "cjson"
function VIPManager.PaySuccess(data)
    if (data) then
        local josonData = json.decode(data)
        if (josonData and josonData.rid ~= -1) then
            MallProxy.SendChargeSuccess(josonData.orderId, josonData.token, josonData.rid)
        end
    end
end

function VIPManager.PayFaild(data)
    if (data) then
        MsgUtils.ShowTips(nil, nil, nil, nil, data)
    end
end

-- 返回所有充值配置
function VIPManager.GetChargeConfigs(t)
    return _chargeByType[t]
end

function VIPManager.GetChargeConfigById(id)
    return _chargeConfig[id]
end
-- 返回是否首充
function VIPManager.GetChargeFirst(id)
    local f = _firstChargeRecord[id]
    return f and f < 1
end
-- 返回是否推荐
function VIPManager.GetChargeRecommend(id)
    return VIPManager.GetChargeFirst(id) or id == 13
end
-- 返回是否推荐
function VIPManager.SendCharge(id, successCallBack)
    if (GameConfig.instance.useSdk) then
        MallProxy.SendCharge(id, successCallBack)
    else
        GMProxy.SendGmCmd("pay " .. id, function()
            if (successCallBack) then
                successCallBack(id)
            end
        end );
    end
    -- todo
end


function VIPManager.GetVipIconByVip(vip)

    if vip == nil then
        vip = 0;
    end
    vip = tonumber(vip);


    if vip > 0 and vip <= 5 then
        return "vipBlue";
    elseif vip > 5 and vip <= 8 then
        return "vipViolet";
    elseif vip > 8 and vip <= 11 then
        return "vipRed";
    elseif vip > 11 then
        return "vipGold";

    end

    return "";
end


function VIPManager.GetLotNum()
    -- 求缘次数
    return VIPManager.GetSelfConfig().time_qiu
end
function VIPManager.GetLotMoneyNum()
    -- 求缘铜钱次数
    return VIPManager.GetSelfConfig().number_qiu or 0
end

function VIPManager.CanFreePayToDoTask()
    return VIPManager.GetSelfConfig().fly_free
end

function VIPManager.GetMyGemSlotNum()
    return VIPManager.GetSelfConfig().gem_num;
end

function VIPManager.GetGemSlotNum(vip)
    local cfg = VIPManager.GetConfigByLevel(vip);
    return cfg.gem_num;
end

function VIPManager.GetStrongPer()
    local cfg = VIPManager.GetSelfConfig()
    return cfg.strong_per;
end
