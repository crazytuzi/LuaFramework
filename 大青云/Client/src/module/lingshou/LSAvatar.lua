_G.LSAvatar = {}
setmetatable(LSAvatar, {__index = CAvatar})
local metaLSAvatar = {__index = LSAvatar}

function LSAvatar:New(lsId, cid, nType)
	local avatar = CAvatar:new()
	avatar.avtName = "lsavatar"
	avatar.cid = cid
	avatar.lsId = lsId
	avatar.nType = nType
	avatar.bIsAttack = false;
	setmetatable(avatar, metaLSAvatar)
	return avatar
end

function LSAvatar:InitAvatar()
	local look = self:GetModel()
	
	if not look then
		Error("don't exist this lingshou lookid", self.lsId)
		return
	end

	local sklFile = look.skl_scene
	local sknFile = look.skn_scene
	local defAnima = look.follow_idle
	local moveAction = look.san_move
	
	local meshResource = Assets:GetNpcMesh(sknFile)
	if not meshResource or meshResource == "" then
		Error("Get lingshou Mesh Error", sknFile, lookId)
		return
	end

	local sklResource = Assets:GetNpcSkl(sklFile)
	if not sklResource or sklResource == "" then
		Error("Get lingshou Skl Error", sklFile, lookId)
		return
	end

	self:SetPart("Body", meshResource)
	self:ChangeSkl(sklResource)
	
	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if defAnimaResource or defAnimaResource == "" then
		self:SetIdleAction(defAnimaResource, true)
	end

	local moveActionResource = Assets:GetNpcAnima(moveAction)
	if moveActionResource and moveActionResource ~= "" then
		self:SetMoveAction(moveActionResource)
	end

	local scale = look.model_scale
	self:SetCfgScale(scale)
	self.pickFlag = enPickFlag.EPF_Null
	if look.model_hight and look.model_hight ~= 0 then
		self.airHeight = look.model_hight
	end
	
	self:SetAttackAction(false);
end

function LSAvatar:GetModel()
	local nType = self.nType
	if nType == 0 then
		local lsId = self.lsId
		if not lsId or lsId == 0 then
			return
		end
		local ui_id = nil
		if t_wuhun[lsId] then 
			ui_id = t_wuhun[lsId].ui_id 
		elseif t_wuhunachieve[lsId] then 
			ui_id = t_wuhunachieve[lsId].ui_id 
		end
		if not ui_id then
			return
		end
		local uiCfg = t_lingshouui[ui_id]
		if not uiCfg then
			return
		end
		if not uiCfg.model then
			return
		end
		return t_lingshoumodel[uiCfg.model]
	elseif nType == 2 then
	
		local lsId = self.lsId
		if not lsId or lsId == 0 then
			return
		end
		local slConfig = t_fabao[lsId]
		if not slConfig then
			return
		end
		local modelId = slConfig.model
		return t_shenlingmodel[modelId]
	end
end

function LSAvatar:EnterMap(x, y, faceto)
    local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, 0),
		faceto
	)
	self.objNode.dwType = enEntType.eEntType_LingShou
end

function LSAvatar:OnEnterScene(objNode)
   objNode.dwType = enEntType.eEntType_LingShou
end

function LSAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end

function LSAvatar:GetAtkAction()
	local look = self:GetModel()
	return look.san_act
end

function LSAvatar:GetActByIndex(index)
	local look = self:GetModel()
	return look["san_act" .. index]
end

function LSAvatar:GetLeisureAction()
	if self.bIsAttack then
		return
	end
	local look = self:GetModel()
	return look.san_idle
end

function LSAvatar:PlaySkill(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
    	print("Error:", "lingshou not exist this skill ", skillId)
        return
    end
    local actionFile = nil
    -- if skillConfig.showtype == SkillConsts.ShowType_ShenLingPassive then
    -- 	actionFile = self:GetActByIndex(skillConfig.skill_action)
    -- else
	    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
	    if skill_action then
	        actionFile = skill_action.animation
	    else
	    	actionFile = self:GetAtkAction()
	    end
	-- end
	if not actionFile or actionFile == "" then
		print("Error:", "lingshou not atk action ", skillId, self.lsId)
		return
	end
    self:PlaySkillAction(actionFile, false)
end

function LSAvatar:DoAction(animaID, isLoop, callBack)
	local szFile = Assets:GetNpcAnima(animaID)
	if szFile then
		self:ExecAction(szFile, isLoop, callBack)
	end
end

function LSAvatar:DoStopAction(animaID)
	 local szFile = Assets:GetNpcAnima(animaID)
	if szFile then
		self:StopAction(szFile)
	end
end

function LSAvatar:DoExtendAnima(event)
	if not event then
		return;
	end;

	if string.find(event, "Scale") then
		local script = 'local ' .. event..' return Scale'
		local param = assert(loadstring(script))()
		self:setShapeInfo(param)
	end
end

function LSAvatar:IsLingshou()
	local nType = self.nType
	if nType == 0 then
		return true
	end
	return false
end

function LSAvatar:SetAttackAction(bIsAttack)
	self.bIsAttack = bIsAttack;
	local look = self:GetModel();
    if self.bIsAttack then
		self.dwIdleAnimaID = look.san_battle;
		self.dwMoveAnimaID = look.san_battle;
	else
		self.dwIdleAnimaID = look.follow_idle;
		self.dwMoveAnimaID = look.san_move;
	end
	self:StartDefAction();
end

function LSAvatar:StartDefAction()
	self:SetIdleAction(self.dwIdleAnimaID, true)
	self:SetMoveAction(self.dwMoveAnimaID)
end

function LSAvatar:ExecMoveAction()
    self:ExecAction(self.szMoveAction, true)
end

function LSAvatar:StopMoveAction()
	self:StopAction(self.szMoveAction);
	self:ExecIdleAction();
end



