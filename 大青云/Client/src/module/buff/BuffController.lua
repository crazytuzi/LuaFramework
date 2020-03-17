_G.classlist['BuffController'] = 'BuffController'
_G.BuffController = setmetatable({}, {__index = IController})
BuffController.name = "BuffController"
BuffController.objName = 'BuffController'
function BuffController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_DelBuff, self, self.OnDeleteBuff)
	MsgManager:RegisterCallBack(MsgType.SC_AddBuff, self, self.OnAddBuff)
	MsgManager:RegisterCallBack(MsgType.SC_AddBuffList, self, self.OnAddBuffList)
	-- MsgManager:RegisterCallBack(MsgType.SC_UpdateBuff, self, self.OnUpdateBuff) --这条协议没有使用 --叠加buff使用add多个不同cid的buff实现
	return true
end

function BuffController:OnLineChange()
	-- 换线后服务器会重新接收到server发buff，客户端清空
	BuffModel:Clear();
	BuffTargetModel:Clear();
end

function BuffController:Update(interval)
	BuffModel:UpdateBuffCD( interval );
	BuffTargetModel:UpdateBuffCD( interval );
end

function BuffController:Destroy()
	return true
end

function BuffController:GetBuffList(cid)
	local char, charType = CharController:GetCharByCid(cid)
	if not char then
		return
	end
	if charType ~= enEntType.eEntType_Monster 
		and charType ~= enEntType.eEntType_Player then
		return
	end
	return char:GetBuffInfo()
end

function BuffController:OnAddBuff(buffInfoMsg)
	local cid = buffInfoMsg.target
	local char, charType = CharController:GetCharByCid(cid)
	if not char then
		return
	end
	if charType ~= enEntType.eEntType_Monster 
		and charType ~= enEntType.eEntType_Player then
		return
	end
	BuffController:AddBuff(char, buffInfoMsg)
end

function BuffController:OnAddBuffList(buffInfoListMsg)
	local cid = buffInfoListMsg.target
	local char, charType = CharController:GetCharByCid(cid)
	if not char then
		return
	end
	if charType ~= enEntType.eEntType_Monster 
		and charType ~= enEntType.eEntType_Player then
		return
	end
	local list = buffInfoListMsg.buffList
	for i = 1, #list do
		local buffInfoMsg = list[i]
		BuffController:AddBuff(char, buffInfoMsg)
	end
end

function BuffController:AddBuff(char, buffInfoMsg)
	local buff = Buff:new()
	buff:Init(buffInfoMsg.id, buffInfoMsg.buffid, buffInfoMsg.time, buffInfoMsg.caster)
	local buffInfo = char:GetBuffInfo()
	buffInfo:AddBuff(buff)
	BuffScript:AddBuffEffect(char, buff.buffId)
	--主玩家buff
	if buffInfoMsg.target == MainPlayerModel.mainRoleID then
 		BuffModel:Add(buffInfoMsg.id, buffInfoMsg.buffid, buffInfoMsg.time, buffInfoMsg.caster)
	end
	--当前选中目标buff
	if TargetManager:CheckIsTarget(char) then
		BuffTargetModel:Add(buff)
	end
end

function BuffController:OnDeleteBuff(buffMsg)
	local cid = buffMsg.target
	local id = buffMsg.id
	local char, charType = CharController:GetCharByCid(cid)
	if not char then
		Debug("error :未找到Buff宿主单位" .. id)
		return
	end
	if charType ~= enEntType.eEntType_Monster 
		and charType ~= enEntType.eEntType_Player then
		return
	end
	local buffInfo = char:GetBuffInfo()
	local buff = buffInfo:GetBuff(id)
	if not buff then
		Debug("error :客户端还没有收到buff" .. id)
		return
	end
	BuffScript:DeleteBuffEffect(char, buff.buffId)
	buffInfo:DeleteBuff(id)
	--主玩家buff
	if buffMsg.target == MainPlayerModel.mainRoleID then
		BuffModel:Remove(buffMsg.id);
	end
	--当前选中目标buff
	if TargetManager:CheckIsTarget(char) then
		BuffTargetModel:Remove( buffMsg.id );
	end
end

function BuffController:ClearAllBuffByCid(cid)
	local char, charType = CharController:GetCharByCid(cid)
	if not char then
		Debug("error :未找到Buff宿主单位" .. id)
		return
	end
	if charType ~= enEntType.eEntType_Monster 
		and charType ~= enEntType.eEntType_Player then
		return
	end
	local buffInfo = char:GetBuffInfo()
	for id, buff in pairs(buffInfo.buffList) do
		BuffScript:DeleteBuffEffect(char, buff.buffId)
		buffInfo:DeleteBuff(id)
	end
	if cid == MainPlayerModel.mainRoleID then
		BuffModel:Clear()
	end
	if TargetManager:CheckIsTarget(char) then
		BuffTargetModel:Clear()
	end
end

function BuffController:ClearCrossBuff()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	local buffInfo = selfPlayer:GetBuffInfo()
	if not buffInfo then
		return
	end
	for id, buff in pairs(buffInfo.buffList) do
		local buffId = buff.buffId
		local buffConfig = t_buff[buffId]
		if buffConfig
			and buffConfig.disappear_cross
			and buffConfig.disappear_cross == 1 then
			BuffScript:DeleteBuffEffect(selfPlayer, buffId)
			buffInfo:DeleteBuff(id)
			BuffModel:Remove(id)
		end
	end
end