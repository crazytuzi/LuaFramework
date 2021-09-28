require "Core.Module.Pattern.Proxy"

SaleProxy = Proxy:New();
local notice = LanguageMgr.Get("Sale/SubSaleMyGroundingPanel/saleGroudingNotice")

function SaleProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetCanBuyList, SaleProxy.SendGetSaleListCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.BuySaleItem, SaleProxy.SendBuySaleItemCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SendSale, SaleProxy.SendSaleItemCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetMySaleData, SaleProxy.GetMySaleDataCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ResetSaleRecord, SaleProxy.ResetSaleRecordCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSaleGold, SaleProxy.GetSaleGoldCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSaleRecord, SaleProxy.SendGetSaleRecordCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ReGrounding, SaleProxy.SendReGroundingCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UnGrounding, SaleProxy.SendUnGroundingCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetRecentPrice, SaleProxy.SendGetRecentPriceCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSaleMoney, SaleProxy.GetSaleMoneyCallBack);
	
end

function SaleProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetCanBuyList, SaleProxy.SendGetSaleListCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.BuySaleItem, SaleProxy.SendBuySaleItemCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SendSale, SaleProxy.SendSaleItemCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetMySaleData, SaleProxy.GetMySaleDataCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ResetSaleRecord, SaleProxy.ResetSaleRecordCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetSaleGold, SaleProxy.GetSaleGoldCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetSaleRecord, SaleProxy.SendGetSaleRecordCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ReGrounding, SaleProxy.SendReGroundingCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UnGrounding, SaleProxy.SendUnGroundingCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetRecentPrice, SaleProxy.SendGetRecentPriceCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetSaleMoney, SaleProxy.GetSaleMoneyCallBack);	
end

function SaleProxy.SendGetSaleList()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetCanBuyList, {t = SaleManager.GetCurSelectType(), k = SaleManager.GetCurSelectKind()});
end

function SaleProxy.SendGetSaleListCallBack(cmd, data)
	if(data and data.errCode == nil) then
		SaleManager.SetSaleData(data.t, data.k, data.l)
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALELIST)
	end
end

function SaleProxy.GetSaleMoneyCallBack(cmd, data)
	if(data and data.errCode == nil) then
		SaleManager.SetSaleMoney(data.sales)
		MessageManager.Dispatch(SaleManager, SaleManager.SALEMONEYCHANGE)
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALEPANEL_SALEMONEYSTATE)
	end
end

function SaleProxy.SendBuySaleItem(spId, num, price)
	SocketClientLua.Get_ins():SendMessage(CmdType.BuySaleItem, {spId = spId, num = num, price = price});
end

function SaleProxy.SendBuySaleItemCallBack(cmd, data)
	if(data and data.errCode == nil) then
		ModuleManager.SendNotification(SaleNotes.CLOSE_SALEBUYITEMPANEL)
		local item = SaleManager.GetSaleDataByPriceAndSpId(data.spId, data.price)
		item.num = data.num
		if(item.num == 0) then
			SaleManager.RemoveSaleDataByPriceAndSpId(data.spId, data.price)
		end
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALELIST)
	else
		ModuleManager.SendNotification(SaleNotes.CLOSE_SALEBUYITEMPANEL)
		SaleProxy.SendGetSaleList()
	end
end

function SaleProxy.SendSaleItem(id, num, price, tt)
	
	if(SaleManager.GetMySaleDataCount() >= SaleManager.GetMaxGroundingCount()) then
		MsgUtils.ShowTips("Sale/SubSaleMyGroundingPanel/saleGroudingNotice")
		return
	end
	local time = 24
	if(tt == 1) then
		time = 24
	elseif tt == 2 then
		time = 48
	elseif tt == 3 then
		time = 72
	end
	
	SocketClientLua.Get_ins():SendMessage(CmdType.SendSale, {id = id, num = num, price = price, tt = time});
	SaleManager.SetCurSelectItem(nil)
end

function SaleProxy.SendSaleItemCallBack(cmd, data)
	if(data and data.errCode == nil) then
		MsgUtils.ShowTips("Sale/SaleProxy/Suc", {name = ProductManager.GetProductById(data.spId).name})
		
		SaleManager.InsertMySaleData(data)
		
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALELISTCOUNT)
	end
end

function SaleProxy.SendGetSaleRecord()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetSaleRecord, {});
end

function SaleProxy.SendGetSaleRecordCallBack(cmd, data)
	if(data and data.errCode == nil) then
		SaleManager.SetSaleRecordData(data)
		ModuleManager.SendNotification(SaleNotes.OPEN_GETXIANYUPANEL)
	end
end

function SaleProxy.SendGetMySaleData()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetMySaleData, {});
end

function SaleProxy.GetMySaleDataCallBack(cmd, data)
	if(data and data.errCode == nil) then
		SaleManager.SetMySaleData(data)
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALEPANEL)
	end
end

function SaleProxy.SendClearRecord()
	SocketClientLua.Get_ins():SendMessage(CmdType.ResetSaleRecord, {});
end

function SaleProxy.ResetSaleRecordCallBack(cmd, data)
	if(data and data.errCode == nil) then
		SaleManager.SetSaleRecord(nil)
		ModuleManager.SendNotification(SaleNotes.UPDATE_GETXIANYUPANEL)
	end
end

function SaleProxy.SendGetXianyu()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetSaleGold, {});
end

function SaleProxy.GetSaleGoldCallBack(cmd, data)
	if(data and data.errCode == nil) then
		SaleManager.SetSaleGold(0)
		SaleManager.SetSaleMoney(0)
		MessageManager.Dispatch(SaleManager, SaleManager.SALEMONEYCHANGE)
		ModuleManager.SendNotification(SaleNotes.UPDATE_GETXIANYUPANEL)
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALEPANEL_SALEMONEYSTATE)		
	end
end

function SaleProxy.SendReGrounding(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.ReGrounding, {id = id});
end

function SaleProxy.SendReGroundingCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local item = SaleManager.GetMyGroudingDataById(data.id)
		item.et = data.et
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALEPANEL)
	end
end

function SaleProxy.SendUnGrounding(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.UnGrounding, {id = id});
end

function SaleProxy.SendUnGroundingCallBack(cmd, data)
	if(data and data.errCode == nil) then
		SaleManager.RemoveMyGroungdingDataById(data.id)
		ModuleManager.SendNotification(SaleNotes.UPDATE_SALEPANEL)
	end
end

function SaleProxy.SendGetRecentPrice(spId)
	SocketClientLua.Get_ins():SendMessage(CmdType.GetRecentPrice, {spId = spId});
end

function SaleProxy.SendGetRecentPriceCallBack(cmd, data)
	if(data and data.errCode == nil) then
		ModuleManager.SendNotification(SaleNotes.UPDATE_RECENTPRICE, data)
	end
end 