local NYSnowman = Kin.NYSnowman

function NYSnowman:Detail(szKeyName)
	Ui:OpenWindow("NewInformationPanel",szKeyName)
end

function NYSnowman:OnEnterMap(nTemplateID)
	if nTemplateID ~= Kin.Def.nKinMapTemplateId then
		return
	end
	if Activity:__IsActInProcessByType("NYSnowmanAct") then
		self:ShowEffect()
	end
end

function NYSnowman:ShowEffect()
	Ui:OpenWindow("SnowballEffectPanel")
end

function NYSnowman:OnLeaveMap(nTemplateID)
	if nTemplateID ~= Kin.Def.nKinMapTemplateId then
		return
	end
	Ui:CloseWindow("SnowballEffectPanel")
end