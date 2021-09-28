-- FileName:CountryWarCheerController.lua
-- Author:FQQ
-- Data:2015-12-01
-- Purpose:国战助威控制器

module("CountryWarCheerController", package.seeall)


require "script/ui/countryWar/cheer/CountryWarCheerService"
require "script/ui/countryWar/cheer/CountryWarCheerData"


--助威某个人
function supportOneUser( pPid, pServerId, pCallback )
    --判断当前是否处在助威阶段
    local curStage = CountryWarMainData.getCurStage()
    if(curStage ~=CountryWarDef.SUPPORT)then
        --助威时间已过
        AnimationTip.showTip(GetLocalizeStringBy("fqq_034"))
        return
    end
    local requestCallback = function ( pData )
        if pData.ret == "expired" then
            --助威时间已过
            AnimationTip.showTip(GetLocalizeStringBy("fqq_034"))
            return
        end
        --1.增加助威人的人气
        CountryWarCheerData.addPlayerFans(pPid,pServerId, 1)
        local mySupportCallback = function ( ... )
            if pCallback then
                pCallback()
            end
        end
        --拉取我的助威信息
        getMySupport(mySupportCallback)
    end
    CountryWarCheerService.supportOneUser(pPid, pServerId, requestCallback)
end

--助威势力
function supportOneCountry( pCountryId, pCallback )
    --判断当前是否处在助威阶段
    local curStage = CountryWarMainData.getCurStage()
    if(curStage ~=CountryWarDef.SUPPORT)then
        --助威时间已过
        AnimationTip.showTip(GetLocalizeStringBy("fqq_034"))
        return
    end
    local requestCallback = function ( pRecData )
        --没有人参赛时
        if pRecData.ret == "noone" then
            AnimationTip.showTip(GetLocalizeStringBy("fqq_040"))
            return
        end
        --1.修改助威势力
        CountryWarCheerData.setSide(pCountryId)
        if pCallback then
            pCallback()
        end
    end
    CountryWarCheerService.supportOneCountry(pCountryId, requestCallback)
end

--我助威的玩家信息
function getMySupport( pCallback )
    local requestCallback = function ( pRecData )
        --1.修改助威势力
        CountryWarCheerData.setMySupportUserInfo(pRecData.user)
        if pCallback then
            pCallback()
        end
    end
    CountryWarCheerService.getMySupport(requestCallback)
end



