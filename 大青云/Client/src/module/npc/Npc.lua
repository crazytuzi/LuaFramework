_G.classlist['Npc'] = 'Npc'
_G.Npc = {}
Npc.objName = 'Npc'
local metaNpc = {__index = Npc}

local axis = _Vector3.new(0,0,1)
function Npc:NewNpc(npcId, cid, x, y, faceto, show, offsetZ, isNoLoader)
	local cfgNpc = t_npc[npcId]
	if not cfgNpc then
		Error("don't exist this npc  npcId" .. npcId)
		return
	end
	local npc = {}
	setmetatable(npc, metaNpc)
	npc.npcId = npcId
	npc.cid = cid
	npc.x = x
	npc.y = y
	npc.offsetZ = offsetZ or 0
	npc.__type = "npc"
	npc.PatrolController = nil--巡逻管理器
	npc.isShowHeadBoard = true
	npc.leisureTime = GetCurTime() + 10000
	npc.randomLeisureTime = math.random(1, 10) * 1000
	npc.questState = nil
	npc.questState = QuestController:GetNpcQuestState(npcId)
	npc.markAvatar = nil;
	npc.oldQuestState = -1;
	if show then
		npc.faceto = faceto
		npc.avatar = NpcAvatar:NewNpcAvatar(npcId, cid)
		if not isNoLoader then
			npc.avatar.avatarLoader:beginRecord(true)
		end
		npc.avatar:InitAvatar()
		if not isNoLoader then
			npc.avatar.avatarLoader:endRecord()
		end
		if cfgNpc.is_image then
			npc.avatar.objMesh.transform:mulScalingLeft(1, -1, 1)
			npc.avatar.objMesh.transform:mulRotationLeft(axis, math.pi)
		end
	end

	return npc
end

function Npc:GetNpcId()
	return self.npcId
end

function Npc:GetCid()
	return self.cid
end

--获取NPC对象的配表
function Npc:GetCfg()
	if not t_npc[self.npcId] then
		Debug("cannot find npc in table.NpcId:"..self.npcId);
		return;
	end
	return t_npc[self.npcId];
end

function Npc:GetPos()
	if self.avatar then
		return self.avatar:GetPos()
	else
		return {x = self.x, y = self.y, z = 0}
	end
end

function Npc:GetDir()
	if self.avatar then
		return self.avatar:GetDirValue()
	else
		return self.faceto
	end
end

function Npc:GetAvatar()
	return self.avatar
end

local pos = _Vector3.new()
local name2d = _Vector2.new()
local title2d = _Vector2.new()
local pos2d = _Vector2.new()
local icon2d = _Vector2.new()
local npcFont = _Font.new("SIMHEI", 11, 0, 1, true)
local npcFont1 = _Font.new("SIMHEI", 11, 0, 1, true)
function Npc:Update(dwInterval)
	self:DrawNameBoard()
	self:Leisure()
	if self.PatrolController then
		self.PatrolController:UpdatePatrol()
	end
end

function Npc:DrawNameBoard()
	if ToolsController.hideUI then return; end
	if not CPlayerControl.showName then
		return
	end
	if not self.isShowHeadBoard then return end
	if not self.avatar then return end
	if not self.avatar.objNode then return end
	if not self.avatar.objMesh then return end
	local pos2d = self:GetNamePos()
	if RenderConfig.batch == true then _rd.batchId = 1 end
	local npcId = self.npcId
	local cfgNpc = t_npc[npcId]
	local npcName = cfgNpc.name
	local name_image = cfgNpc.name_image
	local cfg = CUICardConfig[999]
    --title
    pos2d.x, pos2d.y = pos2d.x, pos2d.y + 25
    if cfgNpc.title and cfgNpc.title ~= "" then
    	local npcTitle = "<" .. cfgNpc.title .. ">"
	    title2d.x, title2d.y = pos2d.x, pos2d.y
	    npcFont.edgeColor = cfg.npc_title_edgecolor
	    npcFont.textColor = cfg.npc_title_textcolor
	    npcFont:drawText(title2d.x, title2d.y,
	        title2d.x, title2d.y, npcTitle, _Font.hCenter + _Font.vTop)
	    pos2d.x, pos2d.y = pos2d.x, pos2d.y - 20
	end
    --name
    if npcName and npcName ~= "" and cfgNpc.showname == 0 then
		if _G.isDebug then
			npcName = npcName .. self.avatar:GetStatInfo();
		end
    	name2d.x, name2d.y = pos2d.x, pos2d.y
		npcFont1.edgeColor = cfg.npc_name_edgecolor
	    npcFont1.textColor = cfg.npc_name_textcolor
	    npcFont1:drawText(name2d.x, name2d.y,
	        name2d.x, name2d.y, npcName, _Font.hCenter + _Font.vTop)
	    pos2d.x, pos2d.y = pos2d.x, pos2d.y - 20
	end

	local nameImage = nil
    if name_image and name_image ~= "" then
    	name2d.x, name2d.y = pos2d.x, pos2d.y + 20
    	nameImage = CResStation:GetImage(name_image)
		nameImage:drawImage(name2d.x - nameImage.w / 2, name2d.y - nameImage.h, name2d.x + nameImage.w / 2, name2d.y)
		pos2d.x, pos2d.y = pos2d.x, pos2d.y + 20 - nameImage.h
	end

	--[[
	if self.questState or NpcController.currDungeonNpcId ~= 0 then
		local icon = NpcConsts:GetNpcHeadQuestIcon(self.questState)
		if NpcController.currDungeonNpcId == self:GetNpcId() then
			icon = NpcConsts:GetNpcHeadQuestIcon(QuestConsts.State_CanAccept)
		end
		if icon then
			if nameImage then
				icon2d.x =  pos2d.x
				icon2d.y = pos2d.y
			else
				icon2d.x =  pos2d.x
				icon2d.y = pos2d.y + 20
			end
			local frontIcon = CResStation:GetImage(icon)
			frontIcon:drawImage(icon2d.x - frontIcon.w / 2, icon2d.y - frontIcon.h, icon2d.x + frontIcon.w / 2, icon2d.y)
		end
	end
	]]

	if self.questState then
		--如果任务状态改变了
		if self.questState ~= self.oldQuestState then
			self:UpdateQuestHeadModel();
			self.oldQuestState = self.questState;
		end
	else
		self:RemoveQuestHeadModel();
		self.oldQuestState = -1;
	end
	if NpcController.currDungeonNpcId ~= 0 then
		if NpcController.currDungeonNpcId == self:GetNpcId() then
			self.questState = QuestConsts.State_CanAccept;
			if self.questState ~= self.oldQuestState then
				self:UpdateQuestHeadModel();
				self.oldQuestState = self.questState;
			end
		else
			self:RemoveQuestHeadModel();
			self.oldQuestState = -1;
		end
	end

	if RenderConfig.batch == true then _rd.batchId = 0 end
end

-- 显示头顶任务标识
function Npc:UpdateQuestHeadModel()
	local look = nil;
	local exclamationMarkID = 90200017;
	local grayMarkID = 90200019;
	local questionMarkID = 90200018;
	if self.questState == QuestConsts.State_CanAccept then
		look = t_model[exclamationMarkID];
	elseif self.questState == QuestConsts.State_Going then
		look = t_model[grayMarkID];
	elseif self.questState == QuestConsts.State_CanFinish then
		look = t_model[questionMarkID];
	end
	if not look then return; end
	self:RemoveQuestHeadModel();
	if not self.markAvatar then
		self.markAvatar = CAvatar:new();
	end
	local avatar = self.markAvatar;
	avatar.skl = look.skl;
	avatar.skn = look.skn;
	avatar.san_idle = look.san_idle;
	avatar.name = avatar.skn;
	avatar:ChangeSkl(avatar.skl);
	avatar:SetPart(avatar.skn,avatar.skn);
	local npcId = self.npcId
	local cfgNpc = t_npc[npcId]
	local mePos = self:GetPos()
	local mat = _Matrix3D.new();
	mat:identity();
	mat:mulTranslationLeft(0,0,(cfgNpc.height or 1) - 23);
	avatar.objMesh.transform = mat;
	self:GetAvatar().objMesh:addSubMesh(avatar.objMesh);
	avatar:ExecAction(avatar.san_idle,true,nil,true);
end

function Npc:RemoveQuestHeadModel()
	if not self.markAvatar then return; end
	local avatar = self.markAvatar;
	self:GetAvatar().objMesh:delSubMesh(avatar.objMesh);
	avatar.skl = nil;
	avatar.skn = nil;
	avatar.san_idle = nil;
	avatar.name = nil;
	avatar:Destroy();
	self.markAvatar = nil;
end

-- 开始巡逻
function Npc:SetPatrol(patrolData, patrolIndex, patrolEndFunc)
	if not self.PatrolController then
		self.PatrolController = PatrolController:New(self, patrolData, self.npcId)
	end
	
	self.PatrolController:SetRun(patrolIndex,nil,patrolEndFunc)
end
-----------------------------------------------------------------------end

function Npc:GetActionIdByName(actionName)
	local npc_id = self.npcId
	local cfgNpc = t_npc[npc_id]
	if not cfgNpc then
		Error("don't exist this npc npcId" .. npcId)
		return
	end

	local model = t_model[cfgNpc.look]
	if not model then
		Error("don't exist this npc model" .. cfgNpc.look)
		return
	end
	
	local actStr = model["san_" .. actionName]
	if not actStr or actStr == '' then
		FPrint('npc使用的剧情动作id为空'..actionName)
		return ""
	end
	
	local actionTable = GetPoundTable(actStr)
	
	return actionTable[1]
end

function Npc:DialogAction()
	local actionName = self:GetActionIdByName("dialog")
	if actionName and actionName ~= "" then
		self.avatar:DoAction(actionName, false)
	end
	-- self:DialogSound()--移到NPC对话框播放，判断npc任务状态，优先播任务对话
end

function Npc:DialogSound()
	local npc_id = self.npcId
	local cfgNpc = t_npc[npc_id]
	if not cfgNpc then
		Error("don't exist this npc npcId" .. npcId)
		return
	end
	if not cfgNpc.sz_talk then
		return
	end
	SoundManager:PlaySfx(cfgNpc.sz_talk,true)
end

function Npc:StoryAction(actId, isLoop)
	local actionName = self:GetActionIdByName(actId)
	if actionName and actionName ~= "" then
		self.avatar:DoAction(actionName, isLoop)
	end
end

local ret2d = _Vector2.new()
function Npc:GetNamePos()
	if not self.avatar then
		return
	end
	local npcId = self.npcId
	local cfgNpc = t_npc[npcId]
	local cfg = CUICardConfig[999]

    local mePos = self:GetPos()
    pos.x = 0
    pos.y = 0
    pos.z = cfgNpc.height or 1

    pos.x = mePos.x + pos.x
    pos.y = mePos.y + pos.y
    pos.z = mePos.z + pos.z
    _rd:projectPoint( pos.x, pos.y, pos.z, ret2d)
	return ret2d
end

function Npc:IsLeisureState()
	return true
end

function Npc:Leisure()
	local nowTime = GetCurTime()
	if not self:IsLeisureState() then
		self.leisureTime = nowTime
		self:StopLeisureAction()
	else
		if self.leisureTime and nowTime - self.leisureTime > _G.NPC_XIUXIAN_GAP + self.randomLeisureTime then
			self:DoLeisureAction()
			self.leisureTime = nowTime
		end
	end
end

function Npc:DoLeisureAction()
	local actionName = self:GetActionIdByName("leisure")
	if actionName and actionName ~= "" then
		local actionTable = GetPoundTable(actionName)
		local actionFile = actionTable[math.random(1, #actionTable)]
		self.actionFile = actionFile
		self.avatar:DoAction(actionFile, false)
	end
end

function Npc:StopLeisureAction()
	--local actionName = self:GetActionIdByName("leisure")
	if self.actionFile and self.actionFile ~= "" then
		if self.avatar then
			self.avatar:DoStopAction(self.actionFile, false)
		end
	end
end

function Npc:IsHide()
	return self.isHide
end

-- isHide 隐藏掉自己 显示自己 
function Npc:HideSelf(isHide)
	self.isHide = isHide;
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	if not avatar.objNode then
		return
	end
	if not avatar.objNode.entity then
		return
	end
	if isHide then
		self.isShowHeadBoard = false
		avatar.objNode.visible = false
	else
		self.isShowHeadBoard = true
		avatar.objNode.visible = true
	end
end

--剧情中显示自己 isHide=false 但是不显示
function Npc:ShowSelfByStory()
	self.isHide = false;
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	if not avatar.objNode then
		return
	end
	if not avatar.objNode.entity then
		return
	end
	self.isShowHeadBoard = false
	avatar.objNode.visible = false
end

function Npc:destroy()
	if self.PatrolController then
		self.PatrolController:destroy()
		self.PatrolController = nil--巡逻管理器
	end
	self:RemoveQuestHeadModel();
	self.oldQuestState = -1;
	if self.avatar then
		self.avatar = nil
	end

end

function Npc:DeleteSelf()
	if not self.avatar then
		return
	end
	self.avatar:ExitMap()
	self:destroy()
	self = nil
end