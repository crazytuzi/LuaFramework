require "Core.Module.Pattern.Proxy"

LotProxy = Proxy:New();
local cdate
local config
LotProxyType = {}
LotProxyType.BuyExp = 2
LotProxyType.BuyMoney = 1
function LotProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LotBuyExp, LotProxy._ChangeLotInfo)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLotInfo, LotProxy._OnGetLotInfo)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LotBuyMoney, LotProxy._ChangeLotMoneyInfo)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLotMoneyInfo, LotProxy._OnGetLotMoneyInfo)
end

function LotProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.LotBuyExp, LotProxy._ChangeLotInfo)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLotInfo, LotProxy._OnGetLotInfo)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.LotBuyMoney, LotProxy._ChangeLotMoneyInfo)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLotMoneyInfo, LotProxy._OnGetLotMoneyInfo)
end

function LotProxy.TryBuy(t)
    local cost = LotProxy.GetSelfCost(t)
    local cmd = t == 1 and CmdType.LotBuyMoney or CmdType.LotBuyExp
    if cost <= 0 then
        SocketClientLua.Get_ins():SendMessage(cmd);
        return
    end
    local buyfunc = function()
	    SocketClientLua.Get_ins():SendMessage(cmd);
    end
    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {			
		msg = LanguageMgr.Get("qiaoyuang/tips", {n = cost}),	
		hander = buyfunc
		});
end
function LotProxy.GetLotInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetLotInfo);
	SocketClientLua.Get_ins():SendMessage(CmdType.GetLotMoneyInfo);
end
function LotProxy._OnGetLotInfo(cmd, data)
	if(data.errCode == nil) then
        LotProxy.data = data
        MessageManager.Dispatch(LotNotes, LotNotes.CHANGE_LOT_INFO, LotProxyType.BuyExp)
    end
end
function LotProxy._ChangeLotInfo(cmd, data)
	if(data.errCode == nil) then
        LotProxy.data = data
        MessageManager.Dispatch(LotNotes, LotNotes.CHANGE_LOT_CHANGE, LotProxyType.BuyExp)
    end
end
function LotProxy._OnGetLotMoneyInfo(cmd, data)
	if(data.errCode == nil) then
        LotProxy.dataMoney = data
        MessageManager.Dispatch(LotNotes, LotNotes.CHANGE_LOT_INFO, LotProxyType.BuyMoney)
    end
end
function LotProxy._ChangeLotMoneyInfo(cmd, data)
	if(data.errCode == nil) then
        LotProxy.dataMoney = data
        MessageManager.Dispatch(LotNotes, LotNotes.CHANGE_LOT_CHANGE, LotProxyType.BuyMoney)
    end
end

function LotProxy.SetLotMoneyInfo(t)
    if not LotProxy.dataMoney then LotProxy.dataMoney = {} end
    if t then LotProxy.dataMoney.t = t end
    MessageManager.Dispatch(LotNotes, LotNotes.CHANGE_LOT_INFO, LotProxyType.BuyMoney)
end
function LotProxy.SetLotInfo(t)
    if not LotProxy.data then LotProxy.data = {} end
    if t then LotProxy.data.t = t end
    MessageManager.Dispatch(LotNotes, LotNotes.CHANGE_LOT_INFO, LotProxyType.BuyExp)
end
function LotProxy.HasMsg(t)
    local d = Util.GetString("LotProxy.HasMsg")
    if not d then return true end
    if not cdate then cdate = os.date("%x") end
    if d ~= cdate then return true end
    if t == nil or t == LotProxyType.BuyMoney then
	    local c = LotProxy.GetSelfCost(t or LotProxyType.BuyMoney)
        --Warning(tostring(c))
        if c == 0 then return true end
    end
    if t == nil or t == LotProxyType.BuyExp then
	    local c = LotProxy.GetSelfCost(t or LotProxyType.BuyExp)
        --Warning(tostring(c))
        if c == 0 then return true end
    end
	return false
end
function LotProxy.SetMsg()
    local cd = os.date("%x")
    Util.SetString("LotProxy.HasMsg", cd)
    cdate = cd
    MessageManager.Dispatch(LotNotes, LotNotes.CHANGE_LOT_INFO)
end
function LotProxy.GetSelfLimitNum(t)
    local d = (t == LotProxyType.BuyMoney and LotProxy.dataMoney or LotProxy.data)
    if not d then return 0 end
    local tt = d.t
    local mt = t == LotProxyType.BuyMoney and VIPManager.GetLotMoneyNum() or VIPManager.GetLotNum()
	return mt - tt
end
function LotProxy.GetSelfCost(t)
    if not config then LotProxy._InitConfig() end
    local d = (t == LotProxyType.BuyMoney and LotProxy.dataMoney or LotProxy.data)
    if not d then return 0 end
    local tt = d.t + 1
    --Warning(tostring(t) .. tostring(tt))
    for k, v in pairs(config) do
        if v.money_type == t and v.time == tt then return v.cost end
    end
	return 0
end
function LotProxy.GetSelfExp(t)
    if t == LotProxyType.BuyMoney and LotProxy.dataMoney then return LotProxy.dataMoney.v end
    if t == LotProxyType.BuyExp and LotProxy.data then return LotProxy.data.exp end
	return 0
end
function LotProxy._InitConfig()
    config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_LOT)
end


