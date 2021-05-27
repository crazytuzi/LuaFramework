
FightData = FightData or BaseClass()

function FightData:__init()
	if FightData.Instance then
		ErrorLog("[FightData]:Attempt to create singleton twice!")
	end
	FightData.Instance = self

end

function FightData:__delete()
	FightData.Instance = nil
end
