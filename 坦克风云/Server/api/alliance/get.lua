function api_alliance_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aid = tonumber(request.params.aid) or 0
    local updated_at = tonumber(request.params.updated_at) or 0

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","buildings"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuilding = uobjs.getModel('buildings')

    -- 军团未解锁
    if (tonumber(mUserinfo.alliance or 0)) > 0 and not mBuilding.allianceIsUnlock() then
        response.ret = -113 
        return response
    end
   
    local allianceWarCfg
    if moduleIsEnabled('alliancewarnew') ~= 0 then
        allianceWarCfg = getConfig('allianceWar2Cfg') 
    else
        allianceWarCfg = getConfig('allianceWarCfg') 
    end

    local date  = getWeeTs()
    local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
    local acceptRet,code = M_alliance.get{aid=aid,uid=uid,ents=(date+ents),date=date,point=getConfig('areaWarCfg.slaveRaising')}
 
    if not acceptRet then
        response.ret = code
        return response
    end
     
    -- local bLevel = mBuilding.getLevel('b7')
    -- if tonumber(acceptRet.data.alliance.level) ~= bLevel then
    --     mBuilding.b7[2] = tonumber(acceptRet.data.alliance.level)
    -- end

    if acceptRet.ret == 0 then
        if type (acceptRet.data) ~= 'table' or type (acceptRet.data.alliance) ~= 'table' or not (next(acceptRet.data.alliance)) then
             if mUserinfo.alliance > 0 then
                mUserinfo.alliance = 0
                mUserinfo.alliancename = ''
                if mUserinfo.mapx ~= -1 and mUserinfo.mapy ~= -1 then
                    -- 更新地图中的联盟字段
                    local mMap = require "lib.map"
                    local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
                    local updateData = {}
                    
                    updateData.alliance = ''

                    if moduleIsEnabled('alogo') == 1 then
                        updateData.alliancelogo = {}
                    end
                    
                    mMap:update(mid,updateData)  
                end
                uobjs.save()
            end
        else
            --if mUserinfo.alliance ~= tonumber(acceptRet.data.alliance.aid) or mUserinfo.alliancename ~= acceptRet.data.alliance.name then
                if acceptRet.data.alliance.aid then
                    mUserinfo.alliance = tonumber(acceptRet.data.alliance.aid)
                end
                if acceptRet.data.alliance.name then
                    mUserinfo.alliancename = acceptRet.data.alliance.name
                end
                if mUserinfo.mapx ~= -1 and mUserinfo.mapy ~= -1 then
                    -- 更新地图中的联盟字段
                    local mMap = require "lib.map"
                    local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
                    local updateData = {}
                    
                    updateData.alliance = acceptRet.data.alliance.name
                    
                    if moduleIsEnabled('alogo') == 1 then
                        updateData.alliancelogo = acceptRet.data.alliance.logo or {}
                    end
                    
                    mMap:update(mid,updateData)  
                end
                uobjs.save()
            --end
        end
    end

    local applyInfo = arrayGet(acceptRet.data,"apply")
    if type(applyInfo) == 'table' then
        response.alliancewar = {apply=applyInfo}
        local mAllianceWar = require "model.alliancewar"
        if applyInfo.positionId then
            response.alliancewar.apply.opents = mAllianceWar:getWarOpenTs(tonumber(applyInfo.positionId))
        end
        if applyInfo.ownid then
            if allianceWarCfg.resourceAddition[tonumber(applyInfo.ownid)] then
                response.alliancewar.apply.resaddition = allianceWarCfg.resourceAddition[tonumber(applyInfo.ownid)]
            end
            
        end
    end

    if mUserinfo.alliance > 0 then
        local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
        if not mTerritory.isEmpty() then
            response.data.territory = mTerritory.formatedata()
            local mAtmember = uobjs.getModel('atmember')
            if mUserinfo.alliance ~= mAtmember.aid then
                writeLog('玩家军团改变了aid='..mUserinfo.alliance..'uid='..mUserinfo.uid..'领地数据aid='..mAtmember.aid,'territory')
                mAtmember.resetMember()
                mAtmember.aid = mUserinfo.alliance
                uobjs.save()
            end
        end
    end

    if updated_at < (tonumber(acceptRet.data.alliance.updated_at) or 1) then
        response.data.alliance = acceptRet.data
    end

    -- 军团长每日聊天中发送招贤纳士次数
    response.data.recruit = mUserinfo.recruit(1,mUserinfo.alliance)

    response.ret = 0
    response.msg = 'Success'
    return response
end	