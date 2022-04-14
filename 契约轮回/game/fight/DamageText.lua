-- 
-- @Author: LaoY
-- @Date:   2018-08-06 20:51:19
-- 

DamageText = DamageText or class("DamageText",BaseWidget)
DamageText.__cache_count = 30

local damaget_count_text = 0

function DamageText:ctor(parent_node,builtin_layer,damage)
	if damage then
		self.parent_node = LayerManager:GetInstance():GetDamageLayerByFont(DamageText.GetFontName(damage))
	else
		self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneDamageText)
	end
	self.abName = "system"
	self.assetName = "EmptyLabel"
	self.builtin_layer = LayerManager.BuiltinLayer.Default

	DamageText.super.Load(self)
	damaget_count_text = damaget_count_text + 1
end

function DamageText:dctor()
	self:StopAction()
	self:StopTime()
	damaget_count_text = math.max(0,damaget_count_text - 1)
end

function DamageText:LoadCallBack()
	self.text = self.transform:GetComponent('Text')
	self:AddEvent()
end

 function DamageText:__reset(parent_node,builtin_layer,damage)
	self:SetVisible(false)
	self:SetVisible(true)
	damaget_count_text = damaget_count_text + 1
	if damage then
	 	self.parent_node = LayerManager:GetInstance():GetDamageLayerByFont(DamageText.GetFontName(damage))
	 end
 	DamageText.super.__reset(self)
 end

 function DamageText:__clear()
 	self:SetVisible(false)
 	self:SetPosition(0,0)
 	self:StopTime()
 	self:StopAction()
 	damaget_count_text = math.max(0,damaget_count_text - 1)
 	DamageText.super.__clear(self)
 end

 function DamageText.GetFontName(damage)
 	local damage_type
 	if damage.unit == enum.ATTACK_UNIT.ATTACK_UNIT_PET then
		damage_type = damage.type + damage.unit * 1000
	else
		damage_type = damage.type
	end
	local art_config = DamageConfig.MainRoleArtFontConfig[damage_type]
	return art_config and art_config.name or "blood"
 end

function DamageText:AddEvent()
end

function DamageText:SetData(atkid,damage,delay_time,coord)
	if damaget_count_text > 30 then
		self:destroy()
		return
	end
	self.delay_time = delay_time or 0
	self.damage = damage
	self.attack = SceneManager:GetInstance():GetObject(atkid)
	self.object = SceneManager:GetInstance():GetObject(self.damage.uid)
	-- Yzprint('--LaoY DamageText.lua,line 31-- data=',self.damage.uid,self.object,damage)
	if self.damage.unit == enum.ATTACK_UNIT.ATTACK_UNIT_PET then
		self.damage_type = self.damage.type + self.damage.unit * 1000
	else
		self.damage_type = self.damage.type
	end
	self.damage_type = DamageConfig.TestDamageType or self.damage_type
	if (not self.attack and not coord) or not self.object then
		self:destroy()
		return
	end
	self.start_coord = coord or (self.attack and self.attack:GetPosition())
	if not self.start_coord then
		self:destroy()
		return
	end
	self.be_hit_is_main_role = self.object.__cname == "MainRole"
	local position = self.object:GetPosition()
	self.position = {x = position.x,y = position.y , z = position.z * 1.1}
	local str = ""
	local abName
	self.action = nil
	local cf = DamageConfig.GetActionConfig(self.damage_type,self.be_hit_is_main_role)
	if not cf then
		self:destroy()
		return
	end
	local offset_x = cf.offset_x or 0
	local offset_y = cf.offset_y or 0
	if not self.be_hit_is_main_role then
		local art_config = DamageConfig.ArtFontConfig[self.damage_type]
		if art_config then
			str = string.format("%s%s",art_config.key,self.damage.value)
			-- logWarn(self.object.object_info.uid,"受到伤害")
			abName = art_config.name
			if self.object.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
				self.position.y = position.y + self.object:GetBodyHeight() * 0.5
			else
				self.position.y = position.y + self.object:GetBodyHeight()
			end
		end
	elseif self.be_hit_is_main_role then
		local art_config = DamageConfig.MainRoleArtFontConfig[self.damage_type]
		if art_config then
			str = string.format("%s%s",art_config.key,self.damage.value)
			-- logWarn(self.object.object_info.uid,"受到伤害")
			abName = art_config.name
			self.position.y = position.y + self.object:GetBodyHeight()
		end
	else
		str = tostring(self.damage.value)
	end
	self.text.text = str
	self.position.z = LayerManager:GetInstance():GetSceneDamageTextDepth(self.position.y)
	-- Yzprint('--LaoY DamageText.lua,line 49-- data=',self.position.z)
	self.position.x = self.position.x + offset_x
	self.position.y = self.position.y + offset_y
	SetLocalPosition(self.transform, self.position.x, self.position.y, self.position.z)

	if abName and self.font_abName ~= abName then
		local function callback(obj)
			if self.is_dctored or self.__is_clear then
				return
			end
			self.font_abName = abName
			self.text.font = obj
			self:LoadFontCallBack()
		end
		lua_resMgr:SetTextFont(self,self.text,abName,nil,callback)
	else
		self:LoadFontCallBack()
	end
	self:StartDestoryTime()
end

function DamageText:StartDestoryTime()
	self:StopTime()
	local function step()
		self:destroy()
	end
	self.time_id = GlobalSchedule:Start(step,3.0)
end

function DamageText:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function DamageText:LoadFontCallBack()
	self:StartAction()
end

function DamageText:StartAction()
	self:StopAction()
	local config = DamageConfig.GetActionConfig(self.damage_type,self.be_hit_is_main_role)
	if not config then
		self:destroy()
		return
	end
	local action = cc.DelayTime(self.delay_time)
	--渐入
	local fadein_action
	SetAlpha(self.text,1)
	local start_scale = 1.0
	if config.start_scale then
		if type(config.start_scale) == "table" then
			start_scale = config.start_scale[1]
		else
			start_scale = config.start_scale
		end
	end
	SetLocalScale(self.transform, start_scale,start_scale,start_scale)
	if config.fadein_time then
		SetAlpha(self.text,0)
		fadein_action = cc.FadeIn(config.fadein_time,self.text)
		if not config.fadein_type or config.fadein_type == 1 then
			action  = self:ComboAction(action,fadein_action)
		end
	end

	--移动前缩放
	local move_front_scale_action
	if config.move_front_scale_time then
		if type(config.move_front_scale) == "table" and not table.isempty(config.move_front_scale) then
			if #config.move_front_scale == 1 then
				move_front_scale_action = cc.ScaleTo(config.move_front_scale_time,config.move_front_scale[1])
			else
				local pre_time = config.move_front_scale_time/(#config.move_front_scale-1)
				move_front_scale_action = self:ComboAction(move_front_scale_action,cc.ScaleTo(0,config.move_front_scale[1]))
				for i=2,#config.move_front_scale do
					local scale_action = cc.ScaleTo(pre_time,config.move_front_scale[i])
					move_front_scale_action = self:ComboAction(move_front_scale_action,scale_action)
				end
			end
		elseif type(config.move_front_scale) == "number" then
			move_front_scale_action = cc.ScaleTo(config.move_front_scale_time,config.move_front_scale)
		end
		if fadein_action and config.fadein_type == 2 then
			move_front_scale_action = cc.Spawn(fadein_action,move_front_scale_action)
		end
		action  = self:ComboAction(action,move_front_scale_action)
	end

	-- 第一段移动，包括移动缩放等
	local move_end_pos = self.position
	local moveAction
	local angle_dif = GetAngleByPosition(self.start_coord,self.object:GetPosition())
	local angle_config = DamageConfig.GetDir(angle_dif,self.damage_type,self.be_hit_is_main_role)
	if config.move_length then
		local angle = angle_config[1]
		angle = angle + DamageConfig.GetOffsetAngle(self.damage_type,self.be_hit_is_main_role)
		local vec = GetVectorByAngle(angle)
		move_end_pos = {x = self.position.x + vec.x * config.move_length,y = self.position.y + vec.y * config.move_length,z = move_end_pos.z}
		moveAction = cc.MoveTo(config.move_time,move_end_pos.x,move_end_pos.y,move_end_pos.z)

		if fadein_action and config.fadein_type == 3 then
			moveAction = cc.Spawn(fadein_action,moveAction)
		end

		if config.move_scale then
			local move_scale_action
			if type(config.move_scale) == "table" and not table.isempty(config.move_scale) then
				if #config.move_scale == 1 then
					move_scale_action = cc.ScaleTo(config.move_time,config.move_scale[1])
				else
					local pre_time = config.move_time/(#config.move_scale-1)
					move_scale_action = self:ComboAction(move_scale_action,cc.ScaleTo(0,config.move_scale[1]))
					for i=2,#config.move_scale do
						local scale_action = cc.ScaleTo(pre_time,config.move_scale[i])
						move_scale_action = self:ComboAction(move_scale_action,scale_action)
					end
				end
			elseif type(config.move_scale) == "number" then
				move_scale_action = cc.ScaleTo(config.move_time,config.move_scale)
			end
			if move_scale_action then
				moveAction = cc.Spawn(moveAction,move_scale_action)				
			end
		end

		moveAction = DamageConfig.GetEaseActionType(moveAction,config.move_ease_type,config.move_ease_rate)

		action  = self:ComboAction(action,moveAction)
	end

	-- 第一段移动后得缩放
	local move_after_scale_action
	if config.move_after_scale_time then
		if type(config.move_after_scale) == "table" and not table.isempty(config.move_after_scale) then
			if #config.move_after_scale == 1 then
				move_after_scale_action = cc.ScaleTo(config.move_after_scale_time,config.move_after_scale[1])
			else
				local pre_time = config.move_after_scale_time/(#config.move_after_scale-1)
				move_after_scale_action = self:ComboAction(move_after_scale_action,cc.ScaleTo(0,config.move_after_scale[1]))
				for i=2,#config.move_after_scale do
					local scale_action = cc.ScaleTo(pre_time,config.move_after_scale[i])
					move_after_scale_action = self:ComboAction(move_after_scale_action,scale_action)
				end
			end
		elseif type(config.move_after_scale) == "number" then
			move_after_scale_action = cc.ScaleTo(config.move_after_scale_time,config.move_after_scale)
		end
		action  = self:ComboAction(action,move_after_scale_action)
	end

	-- 移动后停留
	if config.move_delay_time then
		action  = self:ComboAction(action,cc.DelayTime(config.move_delay_time))
	end

	-- 第二段移动，包括缩放
	local fly_action
	if config.fly_length then
		local angle = angle_config[2] or 0
		local vec = GetVectorByAngle(angle)
		local fly_pos = {x = move_end_pos.x,y=move_end_pos.y+config.fly_length ,z = move_end_pos.z}
		local fly_pos = {x = move_end_pos.x + vec.x * config.fly_length,y = move_end_pos.y + vec.y * config.fly_length,z = move_end_pos.z}
		fly_action = cc.MoveTo(config.fly_time,fly_pos.x,fly_pos.y,fly_pos.z)
		
		local fly_delay_action
		if config.fly_delay_time then
			fly_delay_action = cc.DelayTime(config.fly_delay_time)
		end

		-- 缩放
		if config.fly_scale then
			local fly_scale_action
			if type(config.fly_scale) == "table" and not table.isempty(config.fly_scale) then
				if #config.fly_scale == 1 then
					fly_scale_action = cc.ScaleTo(config.fly_time,config.fly_scale[1])
				else
					local pre_time = config.fly_time/(#config.fly_scale-1)
					fly_scale_action = self:ComboAction(fly_scale_action,cc.ScaleTo(0,config.fly_scale[1]))
					for i=2,#config.fly_scale do
						local scale_action = cc.ScaleTo(pre_time,config.fly_scale[i])
						fly_scale_action = self:ComboAction(fly_scale_action,scale_action)
					end
				end
			elseif type(config.fly_scale) == "number" then
				fly_scale_action = cc.ScaleTo(config.fly_time,config.fly_scale)
			end
			if fly_scale_action then
				fly_action = cc.Spawn(fly_action,fly_scale_action)
			end
		end

		-- 渐出
		local fadeout_action
		if config.fadeout_time then
			fadeout_action = cc.FadeOut(config.fadeout_time,self.text)
		end
		if not config.fadeout_type or config.fadeout_type== 1 then
			fly_action = self:ComboAction(fly_action,fly_delay_action)
			fly_action = self:ComboAction(fly_action,fadeout_action)
		elseif config.fadeout_type== 2 then
			fly_action = cc.Spawn(fadeout_action,fly_action)
			fly_action = self:ComboAction(fly_action,fly_delay_action)
		elseif config.fadeout_type== 3 then
			fly_action = self:ComboAction(fly_action,cc.Spawn(fly_delay_action,fadeout_action))
		end

		fly_action = DamageConfig.GetEaseActionType(fly_action,config.fly_ease_type,config.fly_ease_rate)
		action  = self:ComboAction(action,fly_action)
	end

	if action then
		local function end_call_back()
			self:destroy()
		end
		local call_action = cc.CallFunc(end_call_back)
		action  = self:ComboAction(action,call_action)
		cc.ActionManager:GetInstance():addAction(action,self.transform)
	else
		self:destroy()
	end
end

function DamageText:ComboAction(action1,action2)
	if action1 and action2 then
		return cc.Sequence(action1,action2)
	elseif not action1 then
		return action2
	elseif not action2 then
		return action1
	end
end

function DamageText:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end