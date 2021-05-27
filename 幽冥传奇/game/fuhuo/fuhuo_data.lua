FuHuoData = FuHuoData or BaseClass()

function FuHuoData:__init()
	if FuHuoData.Instance then
		ErrorLog("[FuHuoData] Attemp to create a singleton twice !")
	end
	FuHuoData.Instance = self

	self.close_time = 0
	
end

function FuHuoData:__delete()
	FuHuoData.Instance = nil
end


----------复活倒计时----------
function FuHuoData:SetCloseTime(protocol)
	self.close_time = protocol.close_time + Status.NowTime
end

function FuHuoData:GetCloseTime()
	return self.close_time
end