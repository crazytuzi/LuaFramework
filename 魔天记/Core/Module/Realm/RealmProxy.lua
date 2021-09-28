require "Core.Module.Pattern.Proxy"

RealmProxy = Proxy:New();
function RealmProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RealmUpgrade, WorldBossProxy._RealmUpgradeHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RealmCompact, WorldBossProxy._RealmCompactHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChooseRealmSkill, WorldBossProxy._ChooseRealmSkillHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChooseTheurgy, WorldBossProxy._ChooseTheurgyHandler, self);
    MessageManager.AddListener(InstanceDataManager, InstanceDataManager.MESSAGE_XLT_CENG_CHANGE, RealmProxy._OnXLTChange)
end

function RealmProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RealmUpgrade, WorldBossProxy._RealmUpgradeHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RealmCompact, WorldBossProxy._RealmCompactHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChooseRealmSkill, WorldBossProxy._ChooseRealmSkillHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChooseTheurgy, WorldBossProxy._ChooseTheurgyHandler, self);
    MessageManager.RemoveListener(InstanceDataManager, InstanceDataManager.MESSAGE_XLT_CENG_CHANGE, RealmProxy._OnXLTChange)
end

function WorldBossProxy:_RealmUpgradeHandler(cmd, data)
	if(data and data.errCode == nil) then
		local _nextHasSkillLevel = math.ceil(RealmManager.GetRealmLevel() / 9) * 9 + 1
		RealmManager.SetRealmLevel(data.rlv);
		
		if(data.rlv >= _nextHasSkillLevel) then
			local rInfo = RealmManager.GetUpgradeInfoByLevel(_nextHasSkillLevel);
			if(rInfo) then
				local hInfo = PlayerManager.hero.info;
				for i, v in pairs(rInfo.realm_skill) do
					if(v > 0) then 
						hInfo:AddSkill(v);
					end
				end
			end 
		end

		UISoundManager.PlayUISound(UISoundManager.ui_realm)
		MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_REALMUPGRADE, data);
		MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_REALMUPGRADE1, data);
	end
end

function WorldBossProxy:_RealmCompactHandler(cmd, data)
	if(data and data.errCode == nil) then
		UISoundManager.PlayUISound(UISoundManager.ui_skill_upgrade)
		MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_REALMCOMPACT, data);
	end
end

function WorldBossProxy:_ChooseRealmSkillHandler(cmd, data)
	if data and data.errCode == nil then
		local layer = data.layer;
		local skid = data.sk;
		if(skid and layer > 0 and layer <= 7) then
			RealmManager.SetRealmSkill(layer, skid, data.idx)
		end
	end
	MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_CHOOSEREALMSKILL, data);
end

function WorldBossProxy:_ChooseTheurgyHandler(cmd, data)
	if data and data.errCode == nil and data.idx then
		RealmManager.SetTheurgy(data.idx)
	end
	MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_CHOOSETHEURGY, data);
end

function RealmProxy.Upgrade()
	return SocketClientLua.Get_ins():SendMessage(CmdType.RealmUpgrade, {});
end

function RealmProxy.Compact()
	SocketClientLua.Get_ins():SendMessage(CmdType.RealmCompact, {});
end

function RealmProxy.ChooseSkill(layer, skillId, idx)
	if(layer and skillId) then
		local data = {};
		data.idx = idx;
		data.layer = layer;
		data.sk = skillId;
		SocketClientLua.Get_ins():SendMessage(CmdType.ChooseRealmSkill, data);
	end
end

function RealmProxy.ChooseTheurgy(id)
	if(id) then
		local data = {};
		data.idx = id;
		SocketClientLua.Get_ins():SendMessage(CmdType.ChooseTheurgy, data);
	end
end

function RealmProxy.GetXLTier()
    return InstanceDataManager.GetXLTHasPassCen()
end

function RealmProxy._OnXLTChange(ceng)
    RealmManager.OnXLTChange(ceng)
end
