FunGuideFbLogic = FunGuideFbLogic or BaseClass(BaseGuideFbLogic)

function FunGuideFbLogic:__init()
	self.story_name = self:GetStoryName()
end

function FunGuideFbLogic:__delete()

end

-- 进入场景
function FunGuideFbLogic:Enter(old_scene_type, new_scene_type)
	BaseGuideFbLogic.Enter(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function FunGuideFbLogic:Out(old_scene_type, new_scene_type)
	BaseGuideFbLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function FunGuideFbLogic:Update(now_time, elapse_time)
	BaseGuideFbLogic.Update(self, now_time, elapse_time)
	--假副本设置血量少于百分之10加满血
	if GameVoManager.Instance then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local hp = main_role_vo.hp
		if hp / main_role_vo.max_hp <= 0.1 then
			Scene.Instance:GetMainRole():SetAttr("hp", main_role_vo.max_hp)
		end
	end
end

function FunGuideFbLogic:GetStoryName()
	local scene_id = Scene.Instance:GetSceneId()

	if 2010 == scene_id then return "xinshouboss_fb" end
	if 161 == scene_id then return "husong_guide" end
	if 166 == scene_id then return "rob_boss_guide" end
	if 165 == scene_id then return "be_robed_boss_guide" end
	if 164 == scene_id then return "shuijing_guide" end
	if 2020 == scene_id then return "fenghuangcheng_fb" end
	if 3050 == scene_id then return "hanguguan_fb" end
	if 3100 == scene_id then return "kanqi_fb" end
	if 3101 == scene_id then return "banzhuan_fb" end
	if 9030 == scene_id then return "bossyindao_fb" end
	return ""
end