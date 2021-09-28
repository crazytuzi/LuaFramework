MarryMeData = MarryMeData or BaseClass()

RA_MARRYME_OPERA_TYPE = {
	RA_MARRYME_REQ_INFO = 0,
}
MarryMeData.Has_Open = false
function MarryMeData:__init()
	if MarryMeData.Instance then
		print_error("[MarryMeData] Attempt to create singleton twice!")
		return
	end
	MarryMeData.Instance = self
	self.info = {
		cur_couple_count = 0,
		couple_list = {},
	}
	self.is_first = true
	RemindManager.Instance:Register(RemindName.MarryMe, BindTool.Bind(self.GetMarryMeRemind, self))
end

function MarryMeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MarryMe)

	MarryMeData.Instance = nil
end

function MarryMeData:SetInfo(protocol)
	self.info.cur_couple_count = protocol.cur_couple_count
	self.info.couple_list = protocol.couple_list
end

function MarryMeData:GetInfo()
	return self.info
end

function MarryMeData:GetIsFirst()
	local state = self.is_first
	self.is_first = false
	return state
end

function MarryMeData:GetMarryMeRemind(is_open)
	if GameVoManager.Instance:GetMainRoleVo().lover_uid > 0 then
		return 0
	end

	local limit_level = 0
	local cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.MARRY_ME)
	if cfg then
		limit_level = cfg.min_level
	end
	return (ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.MARRY_ME) and limit_level <= GameVoManager.Instance:GetMainRoleVo().level) and 1 or 0
end

function MarryMeData:GetNpcInfo(scene_id, npc_id)
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if scene_cfg and scene_cfg.npcs then
		for k,v in pairs(scene_cfg.npcs) do
			if v.id == npc_id then
				return v
			end
		end
	end
end