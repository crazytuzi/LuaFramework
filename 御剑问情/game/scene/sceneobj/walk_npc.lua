-- 行走NPC
WalkNpc = WalkNpc or BaseClass(Npc)

function WalkNpc:__init(vo)
	self.cur_path_index = 1
	self.forward = true
	self.stack1 = {{x = vo.pos_x, y = vo.pos_y}}
	self.stack2 = {}
	for k,v in ipairs(self.vo.paths) do
		table.insert(self.stack2, v)
	end
	self.bubble_config = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other
	self.bubble_leisure_npc_config = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_leisure_npc_list

	self.same_npc_text_list = {}
	for k,v in ipairs(self.bubble_leisure_npc_config) do
		if v.leisure_npc_id == self.vo.npc_id then						--如果话语属于当前NPC，则加入到当前NPC话语表中
			table.insert(self.same_npc_text_list, v.bubble_leisure_npc_text)
		end
	end
	self.next_update_time = 0
	self.target_pos_x = 0
	self.target_pos_y = 0
end

function WalkNpc:__delete()
	if nil ~= self.bubble_change_timer then
		GlobalTimerQuest:CancelQuest(self.bubble_change_timer)
		self.bubble_change_timer = nil
	end

	if self.animator_handle then
		self.animator_handle:Dispose()
	end
end

function WalkNpc:OnEnterScene()
	SceneObj.OnEnterScene(self)
	self:GetFollowUi()
	self:BubbleControl()
end

function WalkNpc:Update(now_time, elapse_time)
	Npc.Update(self, now_time, elapse_time)
	if Status.NowTime >= self.next_update_time then
		self.next_update_time = Status.NowTime + 0.2
		local root = self.draw_obj:GetRoot()
		if root then
			self:SetRealPos(root.transform.position.x, root.transform.position.z)
		end
	end
end

function WalkNpc:DoWalk()
	if #self.stack2 > 0 and not self.stop then
		local target_pos = self.stack2[1]
		if #self.stack2 > 1 then
			table.insert(self.stack1, 1, target_pos)
			table.remove(self.stack2, 1)
		else
			local temp = self.stack1
			self.stack1 = self.stack2
			self.stack2 = temp
		end
		self:SetDirectionByXY(target_pos.x, target_pos.y)
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		self.target_pos_x, self.target_pos_y = GameMapHelper.LogicToWorld(target_pos.x, target_pos.y)
		self.draw_obj:MoveTo(self.target_pos_x, self.target_pos_y, COMMON_CONSTS.NPC_WALK_SPEED, "WalkNpc")
		self.draw_obj:SetMoveCallback(function (flag)
			if flag == 1 then
				part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
				part:SetTrigger("Action")
			end
		end)
	end
end

function WalkNpc:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		if obj and obj.animator and not self.animator_handle then
			self:DoWalk()
			self.animator_handle = obj.animator:ListenEvent("Action/exit", BindTool.Bind(self.DoWalk, self))
		end
	end
end

function WalkNpc:BubbleControl()
	local exist_time = self.bubble_config[1].exist_time

	if nil ~= self.bubble_change_timer then
		GlobalTimerQuest:CancelQuest(self.bubble_change_timer)
		self.bubble_change_timer = nil
	end

	self.bubble_change_timer = GlobalTimerQuest:AddRunQuest(function()
		local text = self.same_npc_text_list[math.random(1,#self.same_npc_text_list)]	--随机选择话语
		self.follow_ui:ShowBubble()
		self.follow_ui:ChangeBubble(text, exist_time)
		self.follow_ui.bubble:SetActive(true)
	end, 30)
end

function WalkNpc:PlayAction()

end

function WalkNpc:IsWalkNpc()
	return true
end

function WalkNpc:Stop()
	self.draw_obj:StopMove()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	self.stop = true
end

function WalkNpc:Continue()
	self.stop = false
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	self:SetDirectionByXY(GameMapHelper.WorldToLogic(self.target_pos_x, self.target_pos_y))
	part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	self.draw_obj:MoveTo(self.target_pos_x, self.target_pos_y, COMMON_CONSTS.NPC_WALK_SPEED, "WalkNpc")
	self.draw_obj:SetMoveCallback(function (flag)
		if flag == 1 then
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			part:SetTrigger("Action")
		end
	end)
end

function WalkNpc:GetRandomStr()
	return self.same_npc_text_list[math.random(1,#self.same_npc_text_list)]
end