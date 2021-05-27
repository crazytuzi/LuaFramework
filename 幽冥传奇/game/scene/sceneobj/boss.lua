
Boss = Boss or BaseClass(Monster)

function Boss:__init(boss_vo)
	self.vo = boss_vo

	-- Todo:boss配置表
	local boss_info = Config.Monster[boss_vo.monster_id] 
	if not boss_info then
		Log("Can't find boss config, boss id:", boss_vo.monster_id)
		self.res_id = 1
	else
		self.res_id = boss_info.res
	end
end

function Boss:__delete()

end

function Boss:OnClick()

end
