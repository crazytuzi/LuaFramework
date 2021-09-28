FactionDataManager = {
	factions = {
	--[[
	{d_factionname = "XX",
	d_level=10,
	d_factionid=12,
	d_mastername="ouyangjingxu"},
	{d_factionname = "ananaiai",
	d_level=1,
	d_factionid=81,
	d_mastername="zhangtingting"},
	--]]
	}
}

function FactionDataManager.GetFactions()
	return FactionDataManager.factions
end

function FactionDataManager.at(factionid)
	for i = 1, #FactionDataManager.factions do
		if FactionDataManager.factions[i].index == factionid then
			return FactionDataManager.factions[i]
		end
	end
	return false
end

function FactionDataManager.removeMember(memberid)
	if not FactionDataManager.members then
		return false
	end
	for i = 1, #FactionDataManager.members do
		if FactionDataManager.members[i].roleid == memberid then
			table.remove(FactionDataManager.members[i], i)
			return true
		end 
	end
	return false
end

function FactionDataManager.addMember(memberinfo)
	if not FactionDataManager.members then
		FactionDataManager.members = {}
	end
	for i = 1, #FactionDataManager.members do
		if FactionDataManager.members[i].roleid == memberinfo.roleid then
			FactionDataManager.members[i] = memberinfo.roleid
			return
		end 
	end
	table.insert(FactionDataManager.members, memberinfo)
end

function FactionDataManager.GetCurFactionName()
    if not FactionDataManager or not FactionDataManager.members then
        return false, ""
    end
    
    local curRoleID = -1
    if GetDataManager() and GetDataManager():GetMainCharacterID() then
        curRoleID = GetDataManager():GetMainCharacterID()
    end
    
    if curRoleID < 0 then
        return false, ""
    end

    for i = 1, #FactionDataManager.members do
		if FactionDataManager.members[i].roleid == curRoleID then
			local result = FactionDataManager.members[i].factionname
            if result then
                return true, result
            else
                print("____not found factionname")
                return false, ""
            end
		end 
	end
    
    return false, ""
end

return FactionDataManager



