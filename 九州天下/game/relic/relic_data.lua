RelicData = RelicData or BaseClass()

function RelicData:__init()
	if RelicData.Instance then
		print_error("[RelicData] Attempt to create singleton twice!")
		return
	end
	RelicData.Instance = self

	self.info = {}
end

function RelicData:__delete()
	RelicData.Instance = nil
end

function RelicData:IsRelicScene(scene_id)
	return scene_id == 1600
end

function RelicData:SetXingzuoYijiInfo(protocol)
	self.info = protocol
end

function RelicData:GetXingzuoYijiInfo()
	return self.info
end