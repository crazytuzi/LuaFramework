ExtremeVipData = ExtremeVipData or BaseClass()

function ExtremeVipData:__init()
	if ExtremeVipData.Instance ~= nil then
		ErrorLog("[ExtremeVipData] Attemp to create a singleton twice !")
	end
	ExtremeVipData.Instance = self
	self.is_submit = false  --默认是没有提交过
end

function ExtremeVipData:__delete()
	ExtremeVipData.Instance = nil
end

function ExtremeVipData:GetIsSubmit()
	return self.is_submit
end	

function ExtremeVipData:SetIsSubmit(v)
	self.is_submit = v
	GlobalEventSystem:Fire(ExtremeVipEvent.VIP_QQ_INFO_SUBMIT)
end	

function ExtremeVipData:GetSvipSpidInfo()
	return ClientExtremeVipCfg[AgentAdapter:GetSpid()]
end

function ExtremeVipData:IsExtremeVipIconShow()
	local audit_version = IS_AUDIT_VERSION
	local hide_spid = ClientExtremeVipCfg[AgentAdapter:GetSpid()]
	return not self.is_submit and audit_version == false and nil ~= hide_spid and not ClientSuperVipCfg[AgentAdapter:GetSpid()]
end

function ExtremeVipData:IsSuperVipIconShow()
	return not self.is_submit and ClientSuperVipCfg[AgentAdapter:GetSpid()]
end