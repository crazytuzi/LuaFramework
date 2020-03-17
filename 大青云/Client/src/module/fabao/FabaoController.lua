_G.FabaoController = setmetatable({},{__index=IController});
FabaoController.name = "FabaoController";

function FabaoController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FabaoInfo,self,self.OnFabaoInfo);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoCombineResult,self,self.OnCombineResult);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoCallResult,self,self.OnCallResult);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoDevourResult,self,self.OnDevourResult);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoRebornResult,self,self.OnRebornResult);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoLearnResult,self,self.OnLearnResult);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoCastTargetResult,self,self.OnCastResult);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoLevelup,self,self.OnLevelupResult);
	MsgManager:RegisterCallBack(MsgType.SC_FabaoExpChanged,self,self.OnExpChanged);
end

function FabaoController:OnFabaoInfo(msg)
	for i,vo in ipairs(msg.fabaolist) do
		FabaoModel:AddFabao(vo);
	end
	
	table.sort(FabaoModel.list,function(A,B)
		if A.modelId < B.modelId then
			return true;
		else
			return false;
		end
	end);
	self:sendNotification(NotifyConsts.FabaoListChange);
end

function FabaoController:SendFabaoCombine(id)
	local msg = ReqFabaoCombineMsg:new();
	msg.tid = id;
	MsgManager:Send(msg);
end
function FabaoController:OnCombineResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.FabaoCombineResult);
	else
		
	end
end

function FabaoController:SendChangeName(id,name)
	local msg = ReqFabaoChangeNameMsg:new();
	msg.id = id;
	msg.name = name;
	MsgManager:Send(msg);
end

function FabaoController:SendCallFabao(id,state)
	local msg = ReqFabaoCallMsg:new();
	msg.id = id;
	msg.state = state;
	MsgManager:Send(msg);
end
function FabaoController:OnCallResult(msg)
	if msg.result == 0 then
		if msg.state == 2 then
			self:sendNotification(NotifyConsts.FabaoListChange,FabaoModel:RemoveFabao(msg.id));
		else
			local fabao = FabaoModel:ChangeState(msg.id,msg.state);
			if fabao then
				fabao.callid = msg.callid;
			end
			self:sendNotification(NotifyConsts.FabaoChange,fabao);
		end
	else
		
	end
end

function FabaoController:SendDevourFabao(srcid,dstid)
	local msg = ReqFabaoDevourMsg:new();
	msg.srcid = srcid;
	msg.dstid = dstid;
	MsgManager:Send(msg);
end
function FabaoController:OnDevourResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.FabaoDevourResult);
		self:sendNotification(NotifyConsts.FabaoListChange,FabaoModel:RemoveFabao(msg.dstid));
	else
		
	end
end

function FabaoController:SendRebornFabao(id)
	local msg = ReqFabaoRebornMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end
function FabaoController:OnRebornResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.FabaoRebornResult);
	else
		
	end
end

function FabaoController:SendLearnFabao(id,itemid)
	local msg = ReqFabaoLearnMsg:new();
	msg.id = id;
	msg.skillitem = itemid;
	MsgManager:Send(msg);
end
function FabaoController:OnLearnResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.FabaoLearnResult);
	else
		
	end
end

function FabaoController:SendFabaoSkill(skillId)
	local fabao = FabaoModel:GetFighting();
	if not fabao then
		return;
	end
	
	
	if not skillId then
		skillId = fabao.sskill.modelId;
	end
	if fabao.sskill.modelId ~= skillId then
		return;
	end
	
	--判断是否符合施法条件
	local result,target = self:IsCanUseSkill(skillId);
	if result ~= 0 then
		SkillController:ShowNotice(skillId, result);
		return;
	end
	
	if not target then
		return;
	end
	
	local targetCid = SkillController.targetCid or "0_0";
	local msg = ReqFabaoCastTargetMsg:new();
	msg.fabaoID = fabao.id;
	msg.skillID = skillId;
	msg.targetID = targetCid;
	msg.posX = target.x;
	msg.posY = target.y;
	MsgManager:Send(msg);
end
function FabaoController:OnCastResult(msg)
	if msg.result == 0 then
	else
	
	end
end

function FabaoController:IsCanUseSkill(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return 1
    end
	
	local fabao = FabaoModel:GetFighting();
	if not fabao then
		return;
	end
	
	--检查CD
    if not SkillController:CheckSkillCD(skillId) then
        return 2
    end
	
	local char, charType = SkillController:GetCurrTarget();
	local targetPos = nil
    if char then
        targetPos = char:GetPos();
		return 0,targetPos;
    end
	
	if not targetPos then
		targetPos = GetMousePos();
	end
	
	if targetPos then
		local avatar = LSController:GetLingShou(fabao.callid);
		if not avatar then
			return 0,targetPos;
		end
		
		local pos = avatar:GetPos();
		local length = GetDistanceTwoPoint(pos, targetPos);
		local jump = t_consts[208].val1;
		local dis = jump + skillConfig.min_dis;
		if length>dis then
			dis = jump; 
		else
			if length<=skillConfig.min_dis then
				dis = 0;
			else
				dis = length - skillConfig.min_dis;
			end
		end
		
		dis = math.max(dis,0);
		if dis==0 then
			return 0,targetPos;
		end
		
		local dir = GetDirTwoPoint(targetPos, pos);
		targetPos.x = pos.x - dis * math.sin(dir);
		targetPos.y = pos.y + dis * math.cos(dir);
		targetPos.z = CPlayerMap:GetSceneMap():getSceneHeight(targetPos.x, targetPos.y)
		return 0,targetPos;
	end
	
	return;
end


function FabaoController:OnLevelupResult(msg)
	-- local char, type = CharController:GetCharByCid(msg.id);
	-- if not char or type ~= enEntType.eEntType_LingShou then
		-- return;
	-- end
	
	-- char:PlayerPfx(90004);
	local fabao = FabaoModel:GetFabaoById(msg.id);
	if not fabao then
		return;
	end

	fabao.level = msg.level;
	self:sendNotification(NotifyConsts.FabaoChange);

end

function FabaoController:OnExpChanged(msg)
	local fabao = FabaoModel:GetFabaoById(msg.id);
	if not fabao then
		return;
	end
	
	local add = msg.exp - fabao.exp;
	--if add>0 then
	fabao.exp = msg.exp;
	self:sendNotification(NotifyConsts.FabaoChange);
	FloatManager:AddUserInfo(string.format(StrConfig['fabao13'],add));
	--end

end
