require "Core.Module.Pattern.Proxy"

WingProxy = Proxy:New();
function WingProxy:OnRegister()
	WingProxy._selectId = 0
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UpdateWing, WingProxy.UpdateWingCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UseWing, WingProxy.UseWingCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CancleWing, WingProxy.CancleWingCallBack);
	
	
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ActiveWing, WingProxy.ActiveWingCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RenewWing, WingProxy.RenewWingCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WingTimeEnd, WingProxy.WingTimeEndCallBack);
	
	
end

function WingProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UpdateWing, WingProxy.UpdateWingCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UseWing, WingProxy.UseWingCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.CancleWing, WingProxy.CancleWingCallBack);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ActiveWing, WingProxy.ActiveWingCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RenewWing, WingProxy.RenewWingCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WingTimeEnd, WingProxy.WingTimeEndCallBack);
	
end

function WingProxy.UpdateWingCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local curWing = WingManager.GetCurrentWingData()
		local updateAll = curWing.id ~= data.id	
		local updateLevel = curWing.lev ~= data.level
	 
		WingManager.UpdateWing(data)
		UISoundManager.PlayUISound(UISoundManager.ui_skill_upgrade)
		 
		if(updateAll) then
			ModuleManager.SendNotification(WingNotes.UPDATE_WINGPANEL)			
		else
			if(updateLevel) then
				ModuleManager.SendNotification(WingNotes.UPDATE_SUBWINGPANEL_LEVEL)	
			else
				ModuleManager.SendNotification(WingNotes.UPDATE_SUBWINGPANEL_EXP)				
			end
		end
		
		ModuleManager.SendNotification(WingNotes.SHOW_WINGUPDATELEVELLABEL, data.crit_exp)	
	 
		GuideManager.OptSetStatus(GuideManager.Id.GuideWingUpgrade);
	end
end

function WingProxy.SendActiveWing(id)
	id = id or WingProxy._selectId
	SocketClientLua.Get_ins():SendMessage(CmdType.ActiveWing, {id = id});
end

function WingProxy.ActiveWingCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local wing = WingManager.GetFashionById(data.id)
		WingManager.SetWingTime(data.id, data.t)
		if(wing and wing.rank == 1) then
			WingProxy.SendUseWing(data.id)
		end
		
		ModuleManager.SendNotification(WingNotes.UPDATE_WINGPREVIEWPANEL, data.id)	
		ModuleManager.SendNotification(WingNotes.SHOW_WINGACTIVEEFFECT)	
		
		ModuleManager.SendNotification(WingNotes.OPEN_WINGACTIVEPANEL, data)
		
	end
end

--续费
function WingProxy.RenewWing(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.RenewWing, {id = id});
end

function WingProxy.RenewWingCallBack(cmd, data)
	if(data and data.errCode == nil) then
		WingManager.SetWingTime(data.id, data.t)
		ModuleManager.SendNotification(WingNotes.UPDATE_WINGPREVIEWPANEL, data.id)
		ModuleManager.SendNotification(WingNotes.SHOW_WINGACTIVEEFFECT)			
	end
end

function WingProxy.WingTimeEndCallBack(cmd, data)
	
	if(data and data.errCode == nil) then
		WingManager.SetWingState(data.id, 1)
		local curDressData = WingManager.GetCurDressWingData()
		if(curDressData and curDressData.id == data.id) then
			WingManager.SetUseWing(0)
		end
		ModuleManager.SendNotification(WingNotes.UPDATE_WINGPREVIEWPANEL, data.id)
	end
end

function WingProxy.UseWingCallBack(cmd, data)
	
	if(data and data.errCode == nil) then
		WingManager.SetUseWing(data.wid)
		ModuleManager.SendNotification(WingNotes.UPDATE_WINGPANEL)
	end
end
function WingProxy.CancleWingCallBack(cmd, data)
	if(data and data.errCode == nil) then
		WingManager.SetUseWing(0)
		ModuleManager.SendNotification(WingNotes.UPDATE_WINGPANEL)
	end
end

function WingProxy.SendUpdateWing()
	SocketClientLua.Get_ins():SendMessage(CmdType.UpdateWing, {});
end

function WingProxy.SendUseWing(id)
	local id = id or WingProxy._selectId
	if(id ~= 0) then
		SocketClientLua.Get_ins():SendMessage(CmdType.UseWing, {wid = id});
	end
end

function WingProxy.SendCancleWing()
	SocketClientLua.Get_ins():SendMessage(CmdType.CancleWing, {});
end

function WingProxy.SetCurSelectWingId(id)
	WingProxy._selectId = id
end


--这个是界面选择的数据 不是实际穿着的翅膀数据
function WingProxy.GetCurSelectWingData()
	return WingManager.GetFashionDataById(WingProxy._selectId)
end 