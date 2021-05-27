ChiYouData = ChiYouData or BaseClass()

ChiYouData.CHIYOU_BOSS_NUM = "chiyou_boss_num"

function ChiYouData:__init()
	if ChiYouData.Instance then
		ErrorLog("[ChiYouData] attempt to create singleton twice!")
		return
	end
	ChiYouData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.boss_num = 0
end

function ChiYouData:__delete()
end

function ChiYouData:GetChiyouBossNum(protocol)
	self.boss_num = protocol.chiyou_time

	self:DispatchEvent(ChiYouData.CHIYOU_BOSS_NUM)
end

function ChiYouData:GetChiyouTime()
	return self.boss_num
end

function ChiYouData:RemindChiyouNum()
	local num = BagData.Instance:GetItemNumInBagById(452)

	return num > 0 and 1 or 0
end