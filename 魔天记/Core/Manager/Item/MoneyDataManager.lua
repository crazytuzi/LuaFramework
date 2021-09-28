require "net/SocketClientLua"
require "net/CmdType"

MoneyDataManager = { };
MoneyDataManager.hasListen = false;

MoneyDataManager.EVENT_MONEY_CHANGE = "EVENT_MONEY_CHANGE";--金币
MoneyDataManager.EVENT_ZHENQI_CHANGE = "EVENT_ZHENQI_CHANGE";--真气
MoneyDataManager.EVENT_XIUWEI_CHANGE = "EVENT_XIUWEI_CHANGE";--修为
MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE = "EVENT_GUILD_SKILLPOINT_CHANGE";--仙盟技能点


-- "money":{"gold":456,"money":123,"bgold":789}
function MoneyDataManager.Init(data)

    MoneyDataManager.SetData(data);
    if MoneyDataManager.hasListen == false then
        MoneyDataManager.StartListener();
        MoneyDataManager.hasListen = true;
    end

end

function MoneyDataManager.SetData(data)

    -- 灵石
    if data.money ~= nil then
        MoneyDataManager.money = data.money;
    end

    -- 仙玉
    if data.gold ~= nil then
        MoneyDataManager.gold = data.gold;
    end

    -- 绑定仙玉
    if data.bgold ~= nil then
        MoneyDataManager.bgold = data.bgold;
    end

    MessageManager.Dispatch(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE);
end

function MoneyDataManager.StartListener()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Money_Change, MoneyDataManager.MoneyChange);
end

function MoneyDataManager.MoneyChange(cmd, data)
    MoneyDataManager.SetData(data);
end 

function MoneyDataManager.Get_money()
    return MoneyDataManager.money or 0;
end

function MoneyDataManager.Set_money(v)
    MoneyDataManager.money = v;
end

function MoneyDataManager.Get_gold()
    return MoneyDataManager.gold or 0;
end

function MoneyDataManager.Set_gold(v)
    MoneyDataManager.gold = v;
end

function MoneyDataManager.Get_bgold()
    return MoneyDataManager.bgold or 0;
end

function MoneyDataManager.Set_bgold(v)
    MoneyDataManager.bgold = v;
end

local xianyubuzu = LanguageMgr.Get("common/xianyubuzu")
-- 显示仙玉不足
function MoneyDataManager.ShowGoldNotEnoughTip()
    MsgUtils.ShowTips("common/xianyubuzu");
end

local bangdingxianyubuzu = LanguageMgr.Get("common/bangdingxianyubuzu")

-- 显示绑定仙玉不足
function MoneyDataManager.ShowBGoldNotEnoughTip()
    MsgUtils.ShowTips("common/bangdingxianyubuzu");
end

local lingshibuzu = LanguageMgr.Get("common/lingshibuzu")
-- 显示灵石不足
function MoneyDataManager.ShowMoneyNotEnoughTip()
    MsgUtils.ShowTips("common/lingshibuzu");
end