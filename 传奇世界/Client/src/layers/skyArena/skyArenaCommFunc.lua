local skyArenaCommFunc = class("skyArenaCommFunc")

skyArenaCommFunc.limitLevel = 30
-- check level
function skyArenaCommFunc.checkTeamMemLevel()
    for k,v in pairs(G_TEAM_INFO.team_data) do
         if v.roleLevel < skyArenaCommFunc.limitLevel then
            MessageBox( string.format(game.getStrByKey("sky_arena_someonelevelnot30"),v.name))
            return false
         end 
    end
    return true
end

-- check times
function skyArenaCommFunc.checkTeamMemTimes()
    -- get data from server
    return true
end

-- check team
function skyArenaCommFunc.checkTeam()
    if G_TEAM_INFO and G_TEAM_INFO.has_team then
		if G_TEAM_INFO.memCnt and G_TEAM_INFO.memCnt > 3 then
			--TIPS( {str = game.getStrByKey("team_memcount_toomany"), type = 1} )
            MessageBox(game.getStrByKey("team_memcount_toomany"))
			return false
		else
			return true
		end
	else
		--TIPS( {str = game.getStrByKey("need_team"), type = 1} )
        MessageBox(game.getStrByKey("need_team"))
		return false
	end
end

function skyArenaCommFunc.reOrderTableByKey(tab)
    local tmpTab = {}
    for k,_ in pairs(tab) do
        table.insert(tmpTab,k)
    end
    table.sort(tmpTab)
    local resTab = {}
    for _,v in pairs(tmpTab) do
        table.insert(resTab,{v,tab[v]})
    end
    return resTab
end

return skyArenaCommFunc