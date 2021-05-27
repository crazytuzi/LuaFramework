ChangeJobData = ChangeJobData or BaseClass()

function ChangeJobData:__init()
	if ChangeJobData.Instance then
		ErrorLog("[ChangeJobData]:Attempt to create singleton twice!")
	end
	ChangeJobData.Instance = self
	self:InitChangeJobCfg()
end

function ChangeJobData:__delete()
	ChangeJobData.Instance = nil
end

function ChangeJobData:InitChangeJobCfg()
	self.equip_boss_cfg = {}
	for k, v in ipairs(ChangeJobConfig.TaskAchieveId) do
		local temp = {
		index= v,id=k }
	self.equip_boss_cfg[#self.equip_boss_cfg+1] = temp
	end
end

function ChangeJobData:GetChangeJobCfg()
	return self.equip_boss_cfg
end
