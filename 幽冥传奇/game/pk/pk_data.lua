PkData = PkData or BaseClass()

function PkData:__init()
	if PkData.Instance then
		ErrorLog("[PkData]:Attempt to create singleton twice!")
	end
	PkData.Instance = self

	self.pk_mode = GameEnum.ATTACK_MODE_PEACE
end

function PkData:__delete()
	PkData.Instance = nil
end

function PkData:SetPKMode(mode)
	if self.pk_mode ~= mode then
		self.pk_mode = mode
		-- GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_PK_MODE_CHANGE, mode)
	end
end

function PkData:GetPKMode(mode)
	return self.pk_mode
end
