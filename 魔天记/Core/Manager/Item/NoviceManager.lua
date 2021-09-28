NoviceManager = {}
NoviceManager.dress = {
	[101000] =
	{
		a = 301470;
		b = 301475;
	-- w = 341010;
	};
	[102000] = {
		a = 302400;
		b = 302405;
	-- w = 342010;
	};
	[103000] = {
		a = 303850;
		b = 303855;
	-- w = 343010;
	};
	[104000] = {
		a = 304690;
		b = 304685;
	-- w = 344010;
	};
}

function NoviceManager.Runing()
	return NoviceManager.runing
end
function NoviceManager.A(role)
	if(role and role.info) then
		NoviceManager.runing = true
		local dress = NoviceManager.dress[role.info.kind]
		local skIndex = 1;
		NoviceManager.oldLevel = role.info.level
		NoviceManager.oldPower = PlayerManager.power
		role.info.level = 500;
		PlayerManager.power = 999999
		MessageManager.Dispatch(PlayerManager, PlayerManager.SelfLevelChange)
		if(dress) then
			NoviceManager.oldDress = {}
			for i, v in pairs(dress) do
				NoviceManager.oldDress[i] = role.info.dress[i]
				role.info.dress[i] = v;
				if(i == "a") then
					role:ChangeWeapon()
				elseif(i == "b") then
					role:ChangeBody()
				elseif(i == "w") then
					role:ChangeWing()
				end
			end
		end
		
		local defSkill = role.info:GetSkills()
		if(defSkill) then
			local skills = {};
			NoviceManager.oldSkill = role.info:GetCurrSkillSet()
			for i = 1, 4 do
				skills[i] = defSkill[i];
			end
			role.info:SetCurrSkillSet(skills);
			MessageManager.Dispatch(PlayerManager, PlayerManager.SelfSkillChange)
		end
	end
end

function NoviceManager.B(role)
	NoviceManager.runing = false
	if(role and role.info) then
		role.info.level = NoviceManager.oldLevel;
		NoviceManager.oldLevel = nil;
		PlayerManager.power = NoviceManager.oldPower;
		MessageManager.Dispatch(PlayerManager, PlayerManager.SelfLevelChange)
		if(NoviceManager.oldDress) then
			for i, v in pairs(NoviceManager.oldDress) do
				role.info.dress[i] = v;
				if(i == "a") then
					role:ChangeWeapon()
				elseif(i == "b") then
					role:ChangeBody()
				elseif(i == "w") then
					role:ChangeWing()
				end
			end
			NoviceManager.oldDress = nil;
		end
		
		if(NoviceManager.oldSkill) then
			role.info:SetCurrSkillSet(NoviceManager.oldSkill);
		else
			role.info:SetCurrSkillSet({});
		end
		MessageManager.Dispatch(PlayerManager, PlayerManager.SelfSkillChange)
	end
end 