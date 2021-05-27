TemplesData = TemplesData or BaseClass()

function TemplesData:__init()
	if TemplesData.Instance then
		ErrorLog("[TemplesData] attempt to create singleton twice!")
		return
	end
	TemplesData.Instance = self
	self.info = {}
end

function TemplesData:__delete()
end

function TemplesData:GetRewardRemind()
	return 0
end

function TemplesData:SetData(data)
	self.info = data
end

function TemplesData:GetBuyTimes()
	return self.info.buy_times
end

--function TemplesData:Get(count)
--	--CrossHallofGodCfg
--	self.count = count
--end
--
--function TemplesData:GetetLeftCount(count)
--	--CrossHallofGodCfg
--	self.count = count
--end
