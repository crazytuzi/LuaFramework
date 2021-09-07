DailyTaskFbSceneLogic = DailyTaskFbSceneLogic or BaseClass(BaseFbLogic)

function DailyTaskFbSceneLogic:__init()
	self.line_t = {}
	self.kill_spec_monster = false
	self.story = nil
end

function DailyTaskFbSceneLogic:__delete()
	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
end

local next_time = 0
local next_time2 = 0
local monster_list = nil
function DailyTaskFbSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
	if self.talk_time == nil  then return end

	if self.talk_time <= now_time then
		self.talk_time = now_time + self.talk_Interval
		monster_list = Scene.Instance:GetMonsterList()
		local monster_key_t = {}
		for k,v in pairs(monster_list) do
			if v:GetMonsterId() == self.talk_monster then
				table.insert(monster_key_t, k)
			end
		end
		if #monster_key_t > 0 then
			local index = math.random(1, #monster_key_t)
			self.monster = monster_list[monster_key_t[index] or 1]
			if self.monster then
				self.monster:SetBubble(self.talk_dec)
			end
		end
	elseif self.monster and self.talk_time - now_time < (self.talk_Interval - 2) then
		if not self.monster:IsDeleted() then
			self.monster:SetBubble()
		end
		self.monster = nil
	end

	if not self.kill_spec_monster and next_time2 < now_time then
		next_time2 = now_time + 0.5
		if self.branch_fb_type == DailyTaskFbData.FB_TYPE.STATUE
		or self.branch_fb_type == DailyTaskFbData.FB_TYPE.XIXUE
		or self.branch_fb_type == DailyTaskFbData.FB_TYPE.SHENZHU then
			monster_list = Scene.Instance:GetMonsterList()
			local boss = nil
			local monster = nil
			local statue = nil
			for k,v in pairs(monster_list) do
				if v:GetMonsterId() == self.boss_monster then
					boss = v
				else
					monster = v
				end
				if v:GetMonsterId() == self.diaoxiang_monster then
					statue = v
				end
			end
			if self.branch_fb_type == DailyTaskFbData.FB_TYPE.STATUE then
				if statue then
					if not ViewManager.Instance:IsOpen(ViewName.BossSkillWarning) then
						ViewManager.Instance:Open(ViewName.BossSkillWarning, nil, "branch_fb_type", {self.branch_fb_type})
					end
				elseif ViewManager.Instance:IsOpen(ViewName.BossSkillWarning) then
					ViewManager.Instance:Close(ViewName.BossSkillWarning)
					self.kill_spec_monster = true
				end
			elseif self.branch_fb_type == DailyTaskFbData.FB_TYPE.XIXUE or self.branch_fb_type == DailyTaskFbData.FB_TYPE.SHENZHU then
				if boss and monster then
					if not ViewManager.Instance:IsOpen(ViewName.BossSkillWarning) then
						ViewManager.Instance:Open(ViewName.BossSkillWarning, nil, "branch_fb_type", {self.branch_fb_type})
					end
				elseif ViewManager.Instance:IsOpen(ViewName.BossSkillWarning) then
					ViewManager.Instance:Close(ViewName.BossSkillWarning)
					self.kill_spec_monster = true
				end
			end
		end
	end

	if next_time < now_time then
		next_time = now_time + 0.1
		if self.branch_fb_type == DailyTaskFbData.FB_TYPE.SHENZHU then
			monster_list = Scene.Instance:GetMonsterList()
			local boss = nil
			local monster1 = nil
			local monster2 = nil
			for k,v in pairs(monster_list) do
				if v:GetMonsterId() == self.boss_monster then
					boss = v
				elseif monster1 then
					monster2 = v
				else
					monster1 = v
				end
			end
			if boss then
				if monster1 then
					if self.line_t[monster1:GetMonsterId()] == nil then
						self.line_t[monster1:GetMonsterId()] = {need = true, obj = self:CreateSDX(monster1)}
					end
					self.line_t[monster1:GetMonsterId()].need = true
					local line_renderer = self.line_t[monster1:GetMonsterId()].obj:GetLineRenderer()
					if not IsNil(line_renderer) then
						local pos = boss.draw_obj:GetRootPosition()
						line_renderer:SetPosition(1, Vector3(pos.x, pos.y + 4, pos.z))
						pos = monster1.draw_obj:GetRootPosition()
						line_renderer:SetPosition(0, Vector3(pos.x, pos.y + 4.5, pos.z))
					end
				end
				if monster2 then
					if self.line_t[monster2:GetMonsterId()] == nil then
						self.line_t[monster2:GetMonsterId()] = {need = true, obj = self:CreateSDX(monster2)}
					end
					self.line_t[monster2:GetMonsterId()].need = true
					local line_renderer = self.line_t[monster2:GetMonsterId()].obj:GetLineRenderer()
					if not IsNil(line_renderer) then
						local pos = boss.draw_obj:GetRootPosition()
						line_renderer:SetPosition(1, Vector3(pos.x, pos.y + 4, pos.z))
						pos = monster2.draw_obj:GetRootPosition()
						line_renderer:SetPosition(0, Vector3(pos.x, pos.y + 4.5, pos.z))
					end
				end
			end
			for k,v in pairs(self.line_t) do
				if v.need then
					v.need = false
				else
					self:DeleteSDX(v.obj)
					self.line_t[k] = nil
				end
			end
		end
	end
end

function DailyTaskFbSceneLogic:GetIsShowSpecialImage(obj)
	if self.branch_fb_type ~= DailyTaskFbData.FB_TYPE.SCORE then return false end
	local cfg = DailyTaskFbData.Instance:GetFbCfg2(Scene.Instance:GetSceneId())
	if cfg then
		for i= 1, 3 do
			if cfg["monster_" .. i] == obj:GetMonsterId() then
				return true, "uis/images", "df_score_" .. i
			end
		end
	end
	return false
end

function DailyTaskFbSceneLogic:AlwaysShowMonsterName()
	return self.branch_fb_type == DailyTaskFbData.FB_TYPE.SCORE
end


function DailyTaskFbSceneLogic:DeleteSDX(obj)
	local obj_id = obj:GetObjId()
	Scene.Instance:DeleteObj(obj_id, 0)
end

function DailyTaskFbSceneLogic:CreateSDX(monster)
	local effect_vo = GameVoManager.Instance:CreateVo(EffectObjVo)
	effect_vo.obj_id = -1
	effect_vo.name = "Line"
	effect_vo.pos_x = monster.logic_pos.x
	effect_vo.pos_y = monster.logic_pos.y
	effect_vo.res = monster:GetMonsterId() == self.huixie_monster and "shandianxian2" or "shandianxian"
	effect_vo.product_id = PRODUCT_ID_TRIGGER.CLIENT_SHANDIANXIAN_LINE
	return Scene.Instance:CreateEffectObj(effect_vo)
end

function DailyTaskFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.DailyTaskFb)
	DailyTaskFbCtrl.Instance.view:Open()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	local cfg = DailyTaskFbData.Instance:GetFbCfg2(Scene.Instance:GetSceneId())
	if cfg then
		self.talk_time = Status.NowTime + 5
		self.talk_Interval = cfg.talk_time
		self.talk_dec = cfg.talk_desc
		self.talk_monster = cfg.talk_monster
		self.boss_monster = cfg.boss_monster
		self.huixie_monster = cfg.huixie
		self.branch_fb_type = cfg.branch_fb_type
		self.diaoxiang_monster = cfg.diaoxiang_monster
		self.kill_spec_monster = false
	end

	self.story = XinShouStorys.New(Scene.Instance:GetSceneId())
end

function DailyTaskFbSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.DailyTaskFb)
	ViewManager.Instance:Close(ViewName.BossSkillWarning)
	self.talk_time = nil
	self.boss_monster = nil
	self.kill_spec_monster = false
	for k,v in pairs(self.line_t) do
		self:DeleteSDX(v.obj)
		self.line_t[k] = nil
	end
	self.line_t = {}
	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function DailyTaskFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
