-- 
-- @Author: LaoY
-- @Date:   2018-07-17 19:34:31
-- 
AnimationManager = AnimationManager or class("AnimationManager",BaseManager)
local this = AnimationManager

function AnimationManager:ctor()
	AnimationManager.Instance = self
	self:Reset()

	LateUpdateBeat:Add(self.Update,self)
end

function AnimationManager:Reset()
	self.animator_list = {}
end

function AnimationManager.GetInstance()
	if AnimationManager.Instance == nil then
		AnimationManager()
	end
	return AnimationManager.Instance
end

function AnimationManager:AddAnimation(cls,animator,animation_name_list,is_loop,default_action_name,delay_time)
	delay_time = delay_time or 0.02
	-- delay_time = delay_time < 0.02 and 0.02 or delay_time
	self.animator_list[cls] = self.animator_list[cls] or {}
	local action_list = {}
	local action
	local default_action
	if type(animation_name_list) ~= "table" then
		animation_name_list = {animation_name_list}
	end
	for i=1,#animation_name_list do
		local action_name = animation_name_list[i]
		action = {action_name = action_name,action_time = false,index = i,pass_time = 0,delay_time = delay_time}
		if action_name == default_action_name then
			default_action = action
		end
		action_list[i] = action
	end
	if not default_action then
		default_action = action_list[1]
	end
	action_list.default_action = default_action
	action_list.is_play_end = false
	action_list.is_playing_transition = false
	action_list.is_playing = false
	action_list.is_loop = is_loop
	self.animator_list[cls][animator] = action_list

	-- self:Play(cls,animator,action_list[1].index)
end

function AnimationManager:PlayTransition(cls,animator)
	local action_list = self.animator_list[cls][animator]
	local action = action_list.default_action
	if not action then
		return
	end
	-- animator:Play(action.action_name)
	animator:CrossFade(action.action_name,0)
	if cls.PlayCallBack then
		cls:PlayCallBack(action.action_name)
	end
	action_list.is_playing_transition = true
end

function AnimationManager:Play(cls,animator,index)
	local action_list = self.animator_list[cls][animator]
	local action = action_list[index]
	if not action then
		return
	end
	if tostring(animator) == "null" or not animator then
		Yzprint('--LaoY AnimationManager.lua,line 75--',tostring(animator) == "null",cls.__cname,cls.is_dctored)
		self.animator_list[cls][animator] = nil
		return
	end
	local cur_state = animator:GetCurrentAnimatorStateInfo(0)
	if cur_state:IsName(action.action_name) then
		self:SetActionTime(animator,action)
		action.pass_time = cur_state.normalizedTime * action.action_time
	else
		-- animator:Play(action.action_name)
		animator:CrossFade(action.action_name,0)
		if cls.PlayCallBack then
			cls:PlayCallBack(action.action_name)
		end
		self:SetActionTime(animator,action)
		action.pass_time = 0
	end

	-- Yzprint('--LaoY AnimationManager.lua,line 81-- data=',action.action_name,action.action_time)
	-- animator:Play(action.action_name)
	-- action.pass_time = 0

	action_list.cur_action = action
	action_list.is_playing_transition = false
	action_list.is_playing = true
end

function AnimationManager:SetActionTime(animator,action)
	if not animator or not action then
		return
	end
	if not action.action_time then
		-- 这个时间长度会受到speed影响
		-- local cur_state = animator:GetCurrentAnimatorStateInfo(0)
		-- Yzprint('--LaoY AnimationManager.lua,line 97-- data=',action.action_name,cur_state:IsName(action.action_name))
		-- action.action_time = cur_state.length
		-- 这个时间长度不会受到speed影响
		-- local count,ClipInfo = animator:GetCurrentAnimatorClipInfo(0)
		-- action.action_time = ClipInfo[0].clip.length
		local length = GetClipLength(animator,action.action_name)
		if length == 0 then
			local count,ClipInfo = animator:GetCurrentAnimatorClipInfo(0)
			if count > 0 then
				length = ClipInfo[0].clip.length
			end
		end
		action.action_time = length
	end
end

function AnimationManager:RemoveAnimation(cls,animator)
	if cls and animator then
		self.animator_list[cls][animator] = nil
	elseif cls then
		self.animator_list[cls] = nil
	end
end

function AnimationManager:Update(deltaTime)
	for cls,animators in pairs(self.animator_list) do
		for animator,action_list in pairs(animators) do
			if not action_list.is_playing then
				self:Play(cls,animator,action_list[1].index)
				break
			end
			-- cls.gameObject.activeInHierarchy c#单独导出
			if cls.is_replay_in_show == false then
				cls.is_recursion_show = true
			elseif cls and not cls.is_dctored and not IsNil(cls.gameObject) and cls.gameObject.activeInHierarchy ~= cls.is_recursion_show then
				cls.is_recursion_show = not cls.is_recursion_show
				if not cls.is_recursion_show then
					animator.speed = 0
					break
				else
					animator.speed = 1
					action_list.is_play_end = false
					action_list.is_playing_transition = false

					self:Play(cls,animator,action_list[1].index)
					-- local cur_action = action_list.cur_action
					-- if not cur_action then
					-- 	cur_action = action_list.default_action
					-- end
					-- self:Play(cls,animator,cur_action.index)
					break
				end
			end
			if not cls.is_recursion_show then
				break
			end
			if not action_list.is_play_end then
				local action = action_list.cur_action
				action.pass_time = action.pass_time + deltaTime
				if action.pass_time >= action.action_time then
					if action.pass_time >= action.action_time + action.delay_time then
						local index
						if action.index >= #action_list then
							if action_list.is_loop then
								index = 1
							else
								index = action_list.default_action.index
								action_list.is_play_end = true
							end
						else
							index = action.index + 1
						end
						self:Play(cls,animator,index)
					else
						if not action.is_playing_transition then
							self:PlayTransition(cls,animator)
						end
					end
				end
			end
		end
	end
end

