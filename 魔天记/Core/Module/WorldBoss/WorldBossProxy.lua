require "Core.Module.Pattern.Proxy"

WorldBossProxy = Proxy:New();
function WorldBossProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WorldBossInfos, WorldBossProxy._WorldBossInfosHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WorldBossHurtRank, WorldBossProxy._WorldBossHurtRankHandler, self);
end

function WorldBossProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WorldBossInfos, WorldBossProxy._WorldBossInfosHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WorldBossHurtRank, WorldBossProxy._WorldBossHurtRankHandler, self);
end

function WorldBossProxy:_WorldBossInfosHandler(cmd, data)
	if data and data.errCode == nil then
		MessageManager.Dispatch(WorldBossNotes, WorldBossNotes.EVENT_BOSSINFOS, data);
	end
end

function WorldBossProxy:_WorldBossHurtRankHandler(cmd, data)
	MessageManager.Dispatch(WorldBossNotes, WorldBossNotes.EVENT_BOSSHURTRANK, data);
end

function WorldBossProxy.RefreshBossInfos()
	SocketClientLua.Get_ins():SendMessage(CmdType.WorldBossInfos, { });
end

function WorldBossProxy.RefreshBossHurtRank(kind)
	local data = { };
	data.kind = kind;
	SocketClientLua.Get_ins():SendMessage(CmdType.WorldBossHurtRank, data);
end
