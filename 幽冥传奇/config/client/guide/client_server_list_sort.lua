ClientServerListSortCfg = 
{
	[1] = {
			{"aas","las"},
			{	
				{48,"一大区","",0,true},
				{1500,"二大区","",48,true},
				{1000000,"测试服","测试服",1500,true},
			},
		  },
	  
}

ClientServerListSortCfgFun = {}
function ClientServerListSortCfgFun.GetSortListCfg(spid)
	for _,v in pairs(ClientServerListSortCfg) do
		local spids = v[1]
		for _,v1 in pairs(spids) do
			if v1 == spid then
				return v[2]
			end	
		end	
	end	
	return nil
end	