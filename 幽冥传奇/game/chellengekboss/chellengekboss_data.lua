ChellengeKBossData = ChellengeKBossData or BaseClass()

function ChellengeKBossData:__init()
	if ChellengeKBossData.Instance then
		ErrorLog("[ChellengeKBossData]:Attempt to create singleton twice!")
	end
	ChellengeKBossData.Instance = self
end

function ChellengeKBossData:__delete()
	ChellengeKBossData.Instance = nil
end

function ChellengeKBossData:IsChellengeKBossOpen()
	return OtherData.Instance:GetOpenServerDays() <=7
end