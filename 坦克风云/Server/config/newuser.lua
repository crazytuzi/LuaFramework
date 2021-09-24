local function returnCfg(clientPlat)
    local commonCfg={ 
        awardBy7Day = {
            {userinfo_honors=50,props_p19=1,props_p47=1,props_p31=1,props_p2=1,},
            {userinfo_honors=60,props_p19=2,props_p47=2,props_p20=3,troops_a10002=5,},
            {userinfo_honors=70,userinfo_gems=100,props_p47=2,props_p19=5,troops_a10012=5,},
            {userinfo_honors=80,props_p19=5,props_p47=2,props_p12=1,troops_a10022=5,},
            {userinfo_honors=90,props_p19=5,props_p47=2,props_p18=1,troops_a10032=5,},
            {userinfo_honors=100,props_p19=5,props_p47=3,props_p13=2,troops_a10003=5,},
            {props_p20=3,props_p5=1,props_p45=1,props_p17=1,troops_a10035=10,},
        },

		armor_awardBy7Day = {						
		{	userinfo_honors=50,	props_p19=1,	props_p47=1,	props_p31=1,	props_p2=1,	},
		{	userinfo_honors=60,	props_p4517=1,	props_p47=2,	props_p20=3,	troops_a10002=5,	},
		{	userinfo_honors=70,	userinfo_gems=100,	props_p47=2,	props_p4515=1,	troops_a10012=5,	},
		{	userinfo_honors=80,	props_p19=5,	props_p47=2,	props_p12=1,	troops_a10022=5,	},
		{	userinfo_honors=90,	props_p4516=1,	props_p47=2,	props_p18=1,	troops_a10032=5,	},
		{	userinfo_honors=100,	props_p19=5,	props_p47=3,	props_p13=2,	troops_a10003=5,	},
		{	props_p20=3,	props_p5=1,	props_p45=1,	props_p4520=1,	troops_a10035=10,	},

		}

	}						

	-- 装甲矩阵配置
	if moduleIsEnabled('armor') == 0 then
		commonCfg.armor_awardBy7Day = nil
	else
		commonCfg.awardBy7Day = commonCfg.armor_awardBy7Day
	end

    local platCfg=nil

    if clientPlat ~= 'def' then         
        if platCfg and type(platCfg[clientPlat]) == 'table' then
            for k,v in pairs(platCfg[clientPlat]) do
                commonCfg[k] = v
            end
        end
    end
    
    return commonCfg 
end

return returnCfg