--[[
天神
jiayong
]]
_G.TianShenController=setmetatable({},{__index=IController});
TianShenController.name = "TianShenController";
TianShenController.ReadyOpen=false;
function TianShenController:Create()
	CControlBase:RegControl(self, false);
    MsgManager:RegisterCallBack(MsgType.SC_BianShenInfo,self,self.OnBianSheninfo);
    MsgManager:RegisterCallBack(MsgType.SC_BianShenOperResult,self,self.OnBianShenOperResult)
end


--返回变身信息
function TianShenController:OnBianSheninfo(msg)
	TianShenModel:SetTianshenListinfo(msg.list);

	self:UpdateState();

	RemindFuncController:ExecRemindFunc(RemindFuncConsts.RFC_TianShenActivity);
	RemindFuncController:ExecRemindFunc(RemindFuncConsts.RFC_TianShenLvUp);
	RemindFuncController:ExecRemindFunc(RemindFuncConsts.RFC_TianShenUpStar);
	RemindFuncController:AutoRemoveFailPreshowById(RemindFuncConsts.RFC_TianShenUpStar);
end
--返回操作变身结果   "1=激活 2=升星 3=升阶 4=换外显 5=换变身/>
function TianShenController:OnBianShenOperResult(msg)

if msg.result==0 then
		
		local vo = TianShenModel:GetTianShenVO(msg.tid);
		vo.oper=msg.oper;
		if msg.oper==1 then   
        self:sendNotification(NotifyConsts.TianShenActiveUpdate,vo);
		elseif msg.oper==2 then
        self:sendNotification(NotifyConsts.TianShenStarUpdate,vo);
		elseif msg.oper==3 then
        self:sendNotification(NotifyConsts.TianShenLevelUpdate,vo);
		elseif msg.oper==4 then

        elseif msg.oper==5 then
	    self:sendNotification(NotifyConsts.TianShenChangeModel,vo);
		end		 
        self:sendNotification(NotifyConsts.TianShenUpdate,vo);
     else
     	print("变身激活失败"..msg.oper,msg.result);
	end
end
--   1 代表激活  
function TianShenController:ReqActiveBianShen(roleid)
	  if roleid and TianShenModel:IsActive(roleid) then 
	  	return 
	  end;
      local msg = ReqBianShenOperMsg:new();
	  msg.oper = 1;    
	  msg.tid=roleid;
	  MsgManager:Send(msg);
end
function TianShenController:TransformUpdate(state,id)

    -- TianShenModel.isTransfor=state	--old
    NewTianshenModel.isTransfor=state
	if not state then
		SkillModel:ClearShortCutList();
		return;
	end

	-- local vo = TianShenModel:GetFightModel();	--old
	local vo = NewTianshenModel:GetTianshenByFightSize(0)
	if not vo then
		local const = t_consts[309];
		local skills = GetCommaTable(const.param);
		SkillModel:SetTransformShortCutList(skills);
		self:sendNotification(NotifyConsts.SkillShortCutRefresh);
		self:sendNotification(NotifyConsts.TainShenUpdate);
		return;
	end
	self:UpdateState(state and 3 or nil );

end

function TianShenController:SendTianshenSkill(bAuto)
   -- local vo=TianShenModel:GetFightModel()
   local vo=NewTianshenModel:GetTianshenByFightSize(0)
   if not vo then return; end
   -- if not TianShenConsts:IsTransform(vo) then return; end	--old
   local energy=t_consts[314];
   if not energy then return end
   local playerenergy=MainPlayerModel.humanDetailInfo.eaTianShenEnergy;
   -- 特殊处理（大摆筵席活动按F键不向服务器请求变身技能）@adder:houxudong date:2016/10/18 12:29:30
   if ActivityController:GetCurrId() == ActivityConsts.Lunch then
   		 FloatManager:AddSkill(StrConfig['skill1014']);
   		return;
   end
   if bAuto then
		-- if playerenergy>=energy.val3 and not TianShenModel.isTransfor then	--old
		if playerenergy>=energy.val3 and not NewTianshenModel.isTransfor and TianShenConsts:IsModelTransform(vo.tianshenID) then
			local msg = ReqCastMagicMsg:new()
			msg.skillID = 5000001;
			msg.targetID=MainPlayerController:GetRoleID();
			MsgManager:Send(msg); 
		end
		return
	end
	
    -- if playerenergy>energy.val3 and not TianShenModel.isTransfor then  return end	--old                     
    if playerenergy>energy.val3 and not NewTianshenModel.isTransfor then  return end                     

    local msg = ReqCastMagicMsg:new()
    msg.skillID = 5000001;
    msg.targetID=MainPlayerController:GetRoleID();
    MsgManager:Send(msg); 
   
end
function TianShenController:SendChangeTianshen(roleid)
	local msg = ReqBianShenOperMsg:new();
	msg.oper = 5;    
	msg.tid=roleid;
	MsgManager:Send(msg);
end
function TianShenController:ReqLevelUp(roleid)

end
function TianShenController:ReqConsumerBianShen(modelid)
         
       
	  local msg = ReqBianShenOperMsg:new();
	  msg.oper = 3;  	  
	  msg.tid=modelid
	  MsgManager:Send(msg);

end
function TianShenController:ReqConsumerShentu(modelid)
   local msg = ReqBianShenOperMsg:new();
	  msg.oper = 2;    
	  msg.tid=modelid
	  MsgManager:Send(msg);
end
-- function TianShenController:ReqSelectModel()

-- 	local msg = ReqBianShenOperMsg:new();
-- 	  msg.oper = 4;
-- 	  msg.tid=roleid
-- 	  MsgManager:Send(msg);
-- end
function TianShenController:IsOpen()
	return FuncManager:GetFuncIsOpen(FuncConsts.Tianshen);
end

function TianShenController:Update(e)
	if not AutoBattleModel:IsAutoTianShenSkill() then
		return;
	end
	
	if not AutoBattleController:GetAutoHang() then
		return;
	end
	
	-- if TianShenModel.isTransfor then	--old
	if NewTianshenModel.isTransfor then
		return;
	end
	-- self:SendTianshenSkill(true);
end

function TianShenController:UpdateState(state)
	-- old
	--[[local list = TianShenModel:GetBianshenList();
	local info = nil;
	for i = 1,#list do
		if list[i].state>1 then
			info = list[i];
			break;
		end
	end]]
	local info = NewTianshenModel:GetTianshenByFightSize(0);
	self:UpdateFollowAvatar(info);
	self:UpdateSkill(info,state);
end

function TianShenController:UpdateFollowAvatar(info)
	local player = MainPlayerController:GetPlayer();
	if not player then
		return;
	end
	if info then
		-- player:SetTianshenId(info.tid,info.star,info.lv);	--old
		player:SetTianshenId(info:GetCfg().model,info.star,info.lv,info:GetQuality() or 0);
	else
		player:SetTianshenId(0);
	end
end

function TianShenController:UpdateSkill(info,state)
	SkillUtil:SetFrameType(-1);
	SkillUtil:SetPointType(-1);
	SkillUtil:SetAdditiveType(-1);
	SkillUtil:SetAdditiveId(-1);
	self.bIsUsable = false;
	self:SetHangEnabled(self.hangEnabled,info);
	if info then
		state = state or info.state;
		-- SkillUtil:SetFrameType(info.tid);	--old
		SkillUtil:SetFrameType(info.tianshenID);
		SkillUtil:SetPointType(1);
		SkillUtil:SetAdditiveType(SkillConsts.ENUM_ADDITIVE_TYPE.TIANSHEN);
		-- SkillUtil:SetAdditiveId(info.tid);	--old
		SkillUtil:SetAdditiveId(info.tianshenID);
		if state == 3 then
			local config=t_tianshenlv[info.step];
			-- local skills = GetCommaTable(config.skill);	--old
			local skills = info:GetSkill();
			SkillModel:SetTransformShortCutList(skills);
			SkillUtil:SetFrameType(-1);
			SkillUtil:SetPointType(-1);
			AutoBattleController:ChangeWhenTransform();
		end
		self.bIsUsable = true;
	end
	
	SkillModel:ClearTransformHangSkills();
	self:sendNotification(NotifyConsts.SkillShortCutRefresh);
end

function TianShenController:HasFighting()
	-- return TianShenModel:GetFightModel() ~= nil;	--old
	return NewTianshenModel:GetTianshenByFightSize(0) ~= nil;
end

function TianShenController:CreateFollowTianshen(player)
	if not player then	
		return;
	end
	
	local modelId = player:GetTianshenId();
	if not TianShenConsts:IsModelFollow(modelId) then
		self:RemoveFollowTianshen(player);
		return;
	end
	
	local modelCfg = t_bianshenmodel[modelId];
	local name = "Lv."..player.tianshenLv;
	local star = player.tianshenStar;
	local color = player.tianshenColor or 0;
	local playerName = player.playerInfo[enAttrType.eaName];
	playerName = string.format(StrConfig['tianshen0004'],playerName);
	
	local avatar = player.tianshen;
	if not avatar then
		avatar = TianshenAvatar:new();
		local cid = player:GetRoleID();
		avatar.ownerId = cid;
		if MainPlayerController:GetRoleID() == cid then
			avatar.dnotDelete = true
		end
		player.tianshen = avatar;
	end
	avatar:UpdateAvatar(player:GetTianshenId());
	avatar.playerNameWidth = nil;
	avatar.selfNameWidth = nil;
	avatar.selfTitleImg = nil;
	avatar:SetImgName(modelCfg.sen_name..color..'.png');
	avatar.selfStars = nil;
	avatar.selfName = name;
	avatar.playerName = playerName;
	local pfx = avatar.selfStar or 0;
	pfx = 'v_jiaodiguanghuan_'..pfx..'.pfx';
	avatar:StopPfxByName(pfx);
	avatar.selfStar = color;
	pfx = 'v_jiaodiguanghuan_'..color..'.pfx';
	if color~= 0 then
		avatar:SklPlayPfx(pfx,pfx,true);
	end
	avatar.nameHeight = modelCfg['name_height'] or 0;
	avatar.nameColor = tonumber(modelCfg['color']);
	return avatar;
end

function TianShenController:RemoveFollowTianshen(player)
	if not player then	
		return;
	end
	
	if player.tianshen then 
		player.tianshen:ExitMap();
		player.tianshen = nil;
	end
	
end

function TianShenController:PlaySkill(player,skillId,targetCid, targetPos)
	if not player or not player.tianshen then
		return;
	end
	
	-- skillId = 5101001;
	local cfg = t_skill[skillId]
    if not cfg or cfg.oper_type ~= SKILL_OPER_TYPE.TIANSHEN then
        return
    end
	
	local dir = player:GetDirValue();
	player.tianshen:SetDirValue(dir);
	player.tianshen:PlaySkill(skillId, targetCid, targetPos);
	return true;
end

function TianShenController:ResetFollowTianshenPos(player, isForce)
	if not player then return end
	local tianshen = player.tianshen;
	if not tianshen then return end
	
	local pos = player:GetPos();
	if isForce or not tianshen.curPos then 
		tianshen:StopMove();
	
		tianshen.curPos = _Vector3.new();
		
		local dir = player:GetDirValue();
		tianshen.curPos.x = pos.x - tianshen.followdis * math.sin(tianshen.followangel + dir);
		tianshen.curPos.y = pos.y + tianshen.followdis * math.cos(tianshen.followangel + dir);
		tianshen.curPos.z = pos.z;
		
		tianshen:SetDirValue(dir);
		tianshen:SetPos(tianshen.curPos);
	end
	
	player = nil;
end

function TianShenController:UpdateFollowTianshenPos(player)
	if not player then return end
	local tianshen = player.tianshen;
	if not tianshen then return end

	tianshen.mwDiff = tianshen.mwDiff or _Vector3.new();
	tianshen.targetPos = tianshen.targetPos or _Vector3.new();
	local pos = player:GetPos();
	tianshen.targetPos.x = pos.x;
	tianshen.targetPos.y = pos.y;
	if tianshen.followangel ~= 0 then
		local fDirValue = player:GetDirValue();
		fDirValue = fDirValue + tianshen.followangel;
		tianshen.targetPos.x = pos.x - tianshen.followdis * math.sin(fDirValue);
		tianshen.targetPos.y = pos.y + tianshen.followdis * math.cos(fDirValue);
	end
	tianshen.targetPos.z = pos.z;
	local speed = player:GetSpeed() or 40;
	tianshen.mwDiff = _Vector3.sub( pos, tianshen.curPos, tianshen.mwDiff );
	local dis = tianshen.mwDiff:magnitude();
	tianshen.mwDiff = _Vector3.sub( tianshen.targetPos, tianshen.curPos, tianshen.mwDiff );

	if dis > tianshen.followdis then
		tianshen.mwDiff = tianshen.mwDiff:normalize():mul(dis - tianshen.followdis + 0.01);
		tianshen.curPos = tianshen.curPos:add( tianshen.mwDiff );
		tianshen:MoveTo(tianshen.curPos,function() end, speed, nil, true);
		tianshen:ExecMoveAction();
	else
		tianshen:StopMoveAction();
	end
	
	player = nil;
end

function TianShenController:OnKeyDown(keyCode)
	-- local tianshen = TianShenModel:GetFightModel();	--old
	local tianshen = NewTianshenModel:GetTianshenByFightSize(0);
	if not tianshen then
		return;
	end
	
	-- local skills = tianshen.attachedSkills;	--old
	local skills = tianshen.attachedSkills;
	for i,skill in ipairs(skills) do
		if keyCode == TianShenConsts.SkillKey[i] then
			SkillController:PlayCastSkill(skill.skillId,false,true);
			return true;
		end
	end
	
end

TianShenController.hangEnabled = true;
function TianShenController:SetHangEnabled(enabled,tianshen)
	-- local tianshen = tianshen or TianShenModel:GetFightModel();	--old
	local tianshen = tianshen or NewTianshenModel:GetTianshenByFightSize(0);
	self.hangEnabled = enabled;
	if not tianshen then
		local deletes = SkillModel:DeleteSkillByType(SkillConsts.ShowType_Tianshen);
		for i,skill in pairs(deletes) do
			AutoBattleController:OnSkillRemoveResult( skill.skillId );
		end
		return;
	end
	
	if enabled then
		for i=1,#tianshen.attachedSkills do
			local skill = tianshen.attachedSkills[i];
			SkillModel:AddSkill(skill);
			AutoBattleController:OnSkillAddResult(skill.skillId);
		end
	else
		local deletes = SkillModel:DeleteSkillByType(SkillConsts.ShowType_Tianshen);
		for i,skill in pairs(deletes) do
			AutoBattleController:OnSkillRemoveResult( skill.skillId );
		end
	end
end
