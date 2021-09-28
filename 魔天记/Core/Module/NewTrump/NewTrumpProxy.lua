require "Core.Module.Pattern.Proxy"

NewTrumpProxy = Proxy:New();
function NewTrumpProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EquipTrump, NewTrumpProxy.RspEquipTrump);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RefineTrump, NewTrumpProxy.RspRefineTrump);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EnableMobao, NewTrumpProxy.EnableMobao);
end

function NewTrumpProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EquipTrump, NewTrumpProxy.RspEquipTrump);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RefineTrump, NewTrumpProxy.RspRefineTrump);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EnableMobao, NewTrumpProxy.EnableMobao);
end

function NewTrumpProxy.SendActiveTrump(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.ActiveTrump, {id = id});
end

function NewTrumpProxy.SendEquipTrump(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.EquipTrump, {id = id});
end

function NewTrumpProxy.RspEquipTrump(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
end

function NewTrumpProxy.SendRefineTrump(id, level)	
	SocketClientLua.Get_ins():SendMessage(CmdType.RefineTrump, {id = id, lv = level});
end

function NewTrumpProxy.RspRefineTrump(cmd, data)
	
	if(data and data.errCode == nil) then
		ModuleManager.SendNotification(NewTrumpNotes.SHOW_REFINEEFFECT, data.lv)
		UISoundManager.PlayUISound(UISoundManager.ui_skill_upgrade)		
	end
end

function NewTrumpProxy.EnableMobao(cmd, d)
	if d.errCode then return end
    NewTrumpManager.EnableMobao( d)
end

