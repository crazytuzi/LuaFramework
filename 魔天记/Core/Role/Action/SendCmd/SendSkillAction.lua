require "Core.Role.Action.SkillAction";

SendSkillAction = class("SendSkillAction", SkillAction)
SendSkillAction.CastSkill = "CastSkill"
function SendSkillAction:New(skill)
	self = {};
	setmetatable(self, {__index = SendSkillAction});
	self:Init();
	self.tsk = skill
	self:_InitSkill(skill:GetSeriesSkill());
	
	return self;
end


function SendSkillAction:_OnStartCompleteHandler()
	local controller = self._controller
	if(controller) then
		local rotation = controller.transform.rotation.eulerAngles
		local position = controller.transform.position;
		local data = Convert.PointToServer(position, rotation.y);
		local skill = self._skill;
		local target = self._target;
		
		data.st = self._roleServerType;
		data.sid = controller.id;
		data.skid = skill.id;
		controller:SetEpigoneTarget(target);
		if(target) then
			data.tid = controller.target.id;
			if(target.roleType == ControllerType.PLAYER or target.roleType == ControllerType.HERO) then
				data.tt = 1;
			elseif(target.roleType == ControllerType.MONSTER) then
				data.tt = 2;
			elseif(target.roleType == ControllerType.PUPPET or target.roleType == ControllerType.HEROPUPPET) then
				data.tt = 4;
			elseif(target.roleType == ControllerType.ROBOT) then
				data.tt = 5;
			elseif(target.roleType == ControllerType.HEROGUARD) then
				data.tt = 6;
			elseif(target.roleType == ControllerType.HIRE) then
				data.tt = 7;
			end
		else
			data.tid = "0";
			data.tt = 0;
		end
		
		if(skill.zoomSpeed ~= 0) then
			MainCameraController.GetInstance():Zoom(skill.zoomSpeed, skill.continueTime, skill.stayTime);
		end
		SocketClientLua.Get_ins():SendMessage(CmdType.CastSkill, data);
		
		if(controller == PlayerManager.hero) then
			if(self.tsk.skill_type == 1) then
				SequenceManager.TriggerEvent(SequenceEventType.Guide.NOVICE_OPERATION_ATTACK);
			else
				SequenceManager.TriggerEvent(SequenceEventType.Guide.NOVICE_OPERATION_SKILL);				
				MessageManager.Dispatch(SendSkillAction, SendSkillAction.CastSkill, self.tsk)
			end
		else			
			controller.info.mp = math.max(controller.info.mp - skill.mp_cost, 0);
		end
		
		if(self.tsk:IsSeries()) then
			if(self.tsk:IsSeriesComplete()) then
				self:_StartSkillCool();
				if(controller == PlayerManager.hero) then
					if(self.tsk.skill_type == 1) then
						SequenceManager.TriggerEvent(SequenceEventType.Guide.NOVICE_OPERATION_ATTACK_COMPLETE);					
					end
				end
			else
				self.tsk:Next();
				self.tsk:ResetDelayCooling();
			end
		else
			if(controller == PlayerManager.hero) then
				if(self.tsk.skill_type == 1) then
					SequenceManager.TriggerEvent(SequenceEventType.Guide.NOVICE_OPERATION_ATTACK_COMPLETE);					
				end
			end
			self:_StartSkillCool();
		end
	end
end;

function SendSkillAction:_StartSkillCool()
	local controller = self._controller;
	if(self.tsk:IsCommonCD()) then		
		if(controller and controller.info) then
			controller.info:StartSkillCool(self.tsk.com_cd);			
		end
	else
		--self.tsk:StartCool();
		controller.info:CoolSkill(self.tsk);		
	end
end


function SendSkillAction:_OnStopHandler()
	--    local controller = self._controller;
	--	if (self.tsk:IsSeries()) then
	--		if (not self.tsk:IsSeriesComplete()) then
	--			--self.tsk:CoolSkill(true);
	--            controller.info:CoolSkill(self.tsk,true);
	--		end
	--	end 
	--self:_StartSkillCool();
	self.super._OnStopHandler(self);
end
