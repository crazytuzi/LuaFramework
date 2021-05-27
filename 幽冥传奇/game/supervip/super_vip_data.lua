SuperVipData = SuperVipData or BaseClass()

function SuperVipData:__init()
	if SuperVipData.Instance ~= nil then
		ErrorLog("[SuperVipData] Attemp to create a singleton twice !")
	end
	SuperVipData.Instance = self

end

function SuperVipData:__delete()
	SuperVipData.Instance = nil
end

function SuperVipData:GetSvipSpidInfo()
	return ClientSuperVipCfg[AgentAdapter:GetSpid()]
end
