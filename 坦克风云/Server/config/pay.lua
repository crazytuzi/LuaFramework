local function returnCfg(clientPlat)
    local commonCfg={
        50,268,910,1950,3420,8400,
    }

    local platCfg={ 
        qihoo = {
            88,
        },

        efun_tw = {
            120,300,600,1800,3000,6000,
        },

        zsy_ru={
            50,275,625,1650,2890,5800,
        },

        androidsevenga={
            145,370,670,1970,3370,6980,
        },

        ["1mobile"] = {
            60,300,600,1200,3000,6000,
        },

        android3kwan = {
            40,258,448,948,3420,8400,
        },

        efun_dny = {
            60,360,600,1320,3680,6200,
        },

        ["1"] = {
            50,160,460,960,3420,8400,
        },

        fl_yueyu={
            50,160,460,960,3420,8400,
        },

        ["5"] = {
            50,160,460,960,3420,8400,
        },

        ["rayjoy_android"] = {
            50,160,460,960,3420,8400,
        },

        ["11"] = {
            145,370,670,1970,3370,6980,
        },

        efun_nm = {
            60,300,600,1200,3000,6000,
        },

        kunlun_na = {
            60,300,600,1200,3000,6000,
        },

        gNet_jp = {
            60,190,550,1150,4100,10120
        },

        zsy_ko = {
            30,150,300,1650,2520,4200,
        },

        tank_ar = {
            50,275,600,1250,3250,7000,
        },

        kunlun_france={
            60,300,600,1200,3000,6000,
        },

    	tank_turkey ={
    	    100,170,335,1000,1675,3345, -- ios
    	    -- 100,170,335,1675,3345,6455,-- android
    	},

        --kakao
        ["kakao"]= {
            30,150,300,1650,2520,4200,
        },

    }

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