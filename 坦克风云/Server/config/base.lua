local function returnCfg(clientPlat)
    local commonCfg={
        ----------------------------------------------------
        -- 开启debug模式
        ----------------------------------------------------
        SYSDEBUG = false,

        ----------------------------------------------------
        -- 游戏key
        ----------------------------------------------------
        SECRETKEY = "d73d55ee6b51ffe604e25f7a92235f33",

        ----------------------------------------------------
        -- 客户端C++版本号
        ----------------------------------------------------
        CLIENT_MAIN_VERSION = 1,

        ----------------------------------------------------
        -- 客户端lua脚版本号
        ----------------------------------------------------
        CLIENT_SUB_VERSION = 1,

        GAME_STRONG_VERSION = {
            ["9002002"] = 36,
        },

        GAME_MAX_VERSION=36,

       ----------------------------------------------------
        -- 时区
        ----------------------------------------------------
        TIMEZONE = 8,

        ----------------------------------------------------
        -- 是否执行夏令时与冬令时
        ----------------------------------------------------
        ISDST = false,

        ----------------------------------------------------
        -- application platform
        ----------------------------------------------------
        AppPlatform = clientPlat or 'def',

        ----------------------------------------------------
        -- 大平台 ID
        ----------------------------------------------------
        AppPlatformID = 0,

        ----------------------------------------------------
        -- 当前平台开放的版本
        ----------------------------------------------------
        serverVersion = "version13",

        ----------------------------------------------------
        -- 关闭的服 closeServers = {[1]=true,[2]=true}
        ----------------------------------------------------
        closeServers = nil
    }

    local platCfg={ 
        efun_tw = {          
            AppPlatformID = 1013,
            CLIENT_MAIN_VERSIONS = {
                [10213] = 2,  -- 安卓
                [10313]= 2,  -- 隆中
                [10113] = 4,  -- ios
		[10413] = 100,  -- mrik
		[10613] = 100,  -- om2

            },
            CLIENT_SUB_VERSION = 2,
            serverVersion = "version10",
        },
	ship_3kwan={
	
	        CLIENT_MAIN_VERSIONS = {
                [9001001] = 9,
                [9002001]=50,
            },

            AppPlatformID=9001000,
	},

	["9001001"]={
	   CLIENT_MAIN_VERSION = 9,
	},
        android3kwan = {
            AppPlatformID = 1020,
            CLIENT_MAIN_VERSION = 2,
            CLIENT_SUB_VERSION = 2,
            serverVersion = "version9",
        },

        zsy_ru = {
            AppPlatformID = 1024,
            -- TIMEZONE = 4,
	        TIMEZONE = 3,
            ISDST = true,
            CLIENT_MAIN_VERSIONS = {
                [10224] = 2,  -- 安卓
            },
	        serverVersion = "version7",
        },

        qihoo = {
            AppPlatformID = 1011,
            CLIENT_MAIN_VERSION = 7,
            serverVersion = "version9",
        },
        
        kunlun_na = {
            AppPlatformID = 1026,
            -- TIMEZONE = -8,
            TIMEZONE = -7,
			ISDST = true,
            CLIENT_MAIN_VERSIONS = {
                [10226] = 3,  -- 安卓
            },
            serverVersion = "version7",
        },

        ["1mobile"] = {
            AppPlatformID = 1028,
            -- TIMEZONE = -8,
            TIMEZONE = -7,
            ISDST = true,
            serverVersion = "version7",
        },

        -- 快用
        ["1"] = {
            AppPlatformID = 1009,
            CLIENT_MAIN_VERSION = 3,
            CLIENT_SUB_VERSION = 2, 
            serverVersion = "version10",
        },
        
        -- 南美
        efun_nm = {
            AppPlatformID = 1027,
            TIMEZONE = -3, -- 北京夏季用的
	        -- TIMEZONE = -2, -- 北京冬季用的
            ISDST = true,
	       serverVersion = "version7",
        },
	
        androidsevenga = {
            AppPlatformID = 1018,
    	    CLIENT_MAIN_VERSIONS={
        		[10118]=4, --ios
        		[1018]=5,
    	    },
            CLIENT_SUB_VERSION = 2,
	        CLIENT_SUB_VERSION_IOS = 1,	
            -- TIMEZONE = 1,
            TIMEZONE = 2,
            ISDST = true,
            serverVersion = "version9",
        },
        
        -- 韩国
        zsy_ko = {
            AppPlatformID = 1025,
            TIMEZONE = 9,
            serverVersion = "version7",
        },

        gNet_jp = {
            AppPlatformID = 1029,
            TIMEZONE = 9,
            serverVersion = "version3",
        },

        -- 飞流app
        ["5"] = {
            AppPlatformID = 1016,
    	    CLIENT_MAIN_VERSIONS={
    		  [1016]=6,
    	    },	
            CLIENT_SUB_VERSION = 2,
            serverVersion = "version9", 
        },

        fl_yueyu = {
            AppPlatformID = 1017,
            serverVersion = "version9"
        },

        -- sevenga ios
        ["11"] = {
            AppPlatformID = 1019,
            CLIENT_MAIN_VERSION = 5,
            -- TIMEZONE = 1,
            TIMEZONE = 2,
            ISDST = true,
            serverVersion = "version9",
        },

        qihoo_au = {
            TIMEZONE = 10,
        },

        rayjoy_android = {
            AppPlatformID = 1015,
            serverVersion = "version9",
        },

        efun_dny = {
            AppPlatformID = 1014,
	        CLIENT_MAIN_VERSIONS={
                [10114]=3, --ios
                [10214]=3,
            },	
            serverVersion = "version7",
        },

        -- 阿拉伯
        tank_ar = {
            AppPlatformID = 1031,
            -- TIMEZONE = 2,
            TIMEZONE = 3,
            serverVersion = "version7",
        },
            
        -- 法国
        kunlun_france = {
            AppPlatformID = 1032,
            TIMEZONE = 1,
            ISDST = true,
        },

        -- 土耳其
        tank_turkey = {
            AppPlatformID = 1033,
            -- TIMEZONE = 2,
            TIMEZONE = 3,
        },

        kakao = {
            TIMEZONE = 9,
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
