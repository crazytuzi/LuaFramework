FunGuideFbLogic = FunGuideFbLogic or BaseClass(BaseGuideFbLogic)

function FunGuideFbLogic:__init()
	self.story_name = self:GetStoryName()
end

function FunGuideFbLogic:__delete()

end

function FunGuideFbLogic:GetStoryName()
	local scene_id = Scene.Instance:GetSceneId()

	if 160 == scene_id then return "gongchengzhan_guide" end
	if 161 == scene_id then return "husong_guide" end
	if 166 == scene_id then return "rob_boss_guide" end
	if 165 == scene_id then return "be_robed_boss_guide" end
	if 164 == scene_id then return "shuijing_guide" end
	if 169 == scene_id then return "field_boss" end
	if 171 == scene_id then return "taoyuan_cg" end

	return ""
end