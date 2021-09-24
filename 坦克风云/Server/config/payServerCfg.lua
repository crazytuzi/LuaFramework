local function returnCfg(clientPlat)
    local commonCfg={
        rayapiUrl = {},
    }

    local platCfg={ 
        ["ship_3kwan"] = {
            rayapiUrl = {
                ["9001"]='http://bigship-3k-sdk.raygame1.com/rsdk-base-server/token/check?',
                ["9002"]='http://bigship-3kios-sdk.raygame1.com/rsdk-base-server/token/check?',
                ["9010"]='http://bigship-yyb-sdk.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_3kwanios"] = {
            rayapiUrl = {
                ["0"]='http://bigship-3kios-sdk.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_android"] = {
            rayapiUrl = {
                ["0"]='http://bigship-android-sdk.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_arab"] = {
            rayapiUrl = {
                ["0"]='http://bigship-ar-sdk.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_efun_tw"] = {
            rayapiUrl = {
                ["0"]='http://bigship001.lunplay.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_ger"] = {
            rayapiUrl = {
                ["0"]='http://bigship-ger-sdk.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_ina"] = {
            rayapiUrl = {
                ["0"]='http://cjzjynsdk.efunen.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_jap"] = {
            rayapiUrl = {
                ["0"]='http://bigship-jp-sdk.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_korea"] = {
            rayapiUrl = {
                ["0"]='http://bigship-kr-in.happyuniverse.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_russia"] = {
            rayapiUrl = {
                ["0"]='http://cjzjrulogin.aseugame.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_dny"] = {
            rayapiUrl = {
                ["0"]='http://cjjdsdk.efunfun.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_yyb"] = {
            rayapiUrl = {
                ["0"]='http://bigship-yyb-sdk.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_us"] = {
            rayapiUrl = {
                ["0"]='http://bigship-na-in.raygame1.com/rsdk-base-server/token/check?',
            }
        },

        ["ship_xinma"] = {
            rayapiUrl = {
                ["0"]='http://bigship-sing-in.gamedreamer.com.tw/rsdk-base-server/token/check?',
            }
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