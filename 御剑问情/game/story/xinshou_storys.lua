XinShouStorys = XinShouStorys or BaseClass()

function XinShouStorys:__init(scene_id)
	self.story_list = {}

	self:CreateStorys(scene_id)
end

function XinShouStorys:__delete()
	for _, v in pairs(self.story_list) do
		v:DeleteMe()
	end
end

function XinShouStorys:CreateStorys(scene_id)
	local cfg_list = ConfigManager.Instance:GetAutoConfig("story_auto")["normal_scene_story"]
	if nil == cfg_list then
		return
	end

	local step_cfg_list = {}
	local story_view = ViewManager.Instance:GetView(ViewName.StoryView)
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local common_prof = 0				--职业通用

	for _, v in ipairs(cfg_list) do
		if v.scene_id == scene_id and (v.prof == prof or v.prof == common_prof) then
			if nil == self.story_list[v.story_id] then
				step_cfg_list = {}
				self.story_list[v.story_id] = Story.New(step_cfg_list, story_view)
			end

			table.insert(step_cfg_list, v)
		end
	end
end

function XinShouStorys:GetStoryNum()
	local num = 0
	for _, v in pairs(self.story_list) do
		num = num + 1
	end

	return num
end