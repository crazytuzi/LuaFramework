require "Core.Module.Pattern.Proxy"

CashGiftProxy = Proxy:New();

local function GetCashGiftInfoCallBack(cmd, data)
	if(data and data.errCode == nil) then
		CashGiftsManager.SetCashGiftsInfo(data.rs)
		ModuleManager.SendNotification(CashGiftNotes.UPDATE_CASHGIFTSPANEL)
	end	
end

function CashGiftProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetClashGiftsInfo, GetCashGiftInfoCallBack);
end

function CashGiftProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetClashGiftsInfo, GetCashGiftInfoCallBack);	
end

function CashGiftProxy.SendGetClashGiftsInfo()
	--模拟数据
	--GetCashGiftInfoCallBack(123, {rs = {{rid = 14, time = 0}, {rid = 15, time = 1}, {rid = 16, time = 1}}})
	SocketClientLua.Get_ins():SendMessage(CmdType.GetClashGiftsInfo);		
end

