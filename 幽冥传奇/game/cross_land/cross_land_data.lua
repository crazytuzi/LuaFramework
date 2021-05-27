CrossLandData = CrossLandData or BaseClass()

function CrossLandData:__init()
	if CrossLandData.Instance then
		ErrorLog("[CrossLandData] attempt to create singleton twice!")
		return
	end
	CrossLandData.Instance = self
end

function CrossLandData:__delete()
end

function CrossLandData:GetRewardRemind()
	return 0
end
