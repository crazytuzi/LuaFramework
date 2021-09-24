function api_alliance_edit(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    

    -- 军团内部公告，0-100字
    local internalNotice = request.params.internalNotice

    -- 军团宣言，0-100字
    local foreignNotice = request.params.foreignNotice

    -- 加入需要的用户等级
    local joinNeedLv = tonumber(request.params.joinNeedLv)

    -- 加入需要的用户战力
    local joinNeedFc = tonumber(request.params.joinNeedFc)

    -- 成员加入军团方式
    -- 0，自由加入
    -- 1，需要批准
    local joinType = tonumber(request.params.joinType)
    local params = {}
    local uid = request.uid

    if uid == nil or aid == 0 or utfstrlen(internalNotice) > 200 or utfstrlen(foreignNotice) > 200 then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    
    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    if request.params.logo and moduleIsEnabled('alogo') == 1 then
        -- 联盟旗帜（logo）
        local logo = request.params.logo
        if type(logo) == 'table' then
            local status,cost,logo = M_alliance.checkLogo(logo)
            if status ~= 1 then
                response.ret = -102
                return response
            end
            
            local logoCfg = getConfig('allianceflag')
            local changeCost = logoCfg.changeCost

            local acceptRet,code = M_alliance.get{aid=aid,uid=uid}

            if not acceptRet then
                response.ret = code
                return response
            end
            
            if acceptRet.ret == 0 then
                if type (acceptRet.data) == 'table' and type(acceptRet.data.alliance) == 'table' and next(acceptRet.data.alliance) then
                    if acceptRet.data.alliance.logo then
                        local reLogo = acceptRet.data.alliance.logo
                        if type(reLogo) == 'table' then
                            local reLogoCount = #reLogo
                            local matchNum = 0
                            if reLogoCount > 0 then
                                for lk,lv in pairs(logo) do
                                    if reLogo[lk] and tonumber(reLogo[lk]) == tonumber(lv) then
                                        matchNum = matchNum + 1
                                    end
                                end
                                if matchNum == reLogoCount then
                                    changeCost = 0
                                    cost = 0
                                end
                            end
                        end

                        if not reLogo or #reLogo == 0 then
                            changeCost = 0
                        end
                    end
                end
            end
            
            if changeCost+cost > 0 then
                if not mUserinfo.useGem(changeCost+cost) then
                    response.ret = -109 
                    return response
                end
                regActionLogs(uid,1,{action=163,item="",value=changeCost+cost,params={logo=logo}})
            end
            
            params.logo = json.encode(logo)
        end
    elseif request.params.logo then
        response.ret = -324
        return response
    end
    
    local execRet, code = M_alliance.updateSettings{uid=uid,aid=aid,notice=internalNotice,desc=foreignNotice,level_limit=joinNeedLv,fight_limit=joinNeedFc,type=joinType,logo=params.logo}
    
	if not execRet then
        response.ret = code
        return response
    end
    
    -- 如果成功的修改字段后，会有相应的字段返回，
    -- 前台传回的修改信息与原信息无任何变化的情况在这里排除
    if type(execRet.data.alliance_updates) == 'table' and next(execRet.data.alliance_updates) then        
        -- push -------------------------------------------------
        local cmd = 'alliance.update'
        local data = {
            alliance = {
                -- alliance={
                    -- desc=foreignNotice,
                    -- notice=internalNotice,
                    -- level_limit=joinNeedLv,
                    -- fight_limit=joinNeedFc,
                    -- type=joinType,
                -- }
                alliance=execRet.data.alliance_updates
            }
        }

        local mems = M_alliance.getMemberList{uid=uid,aid=aid}
        if mems then
            local mMap = require "lib.map"
            for _,v in pairs( mems.data.members) do
                if execRet.data.alliance_updates.logo then
                    local mapData = mMap:getUserMap(v.uid)
                    if mapData then
                        mMap:update(mapData.id,{alliancelogo=execRet.data.alliance_updates.logo})
                    end
                end
                regSendMsg(v.uid,cmd,data)
            end
        end
        -- push -------------------------------------------------
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end	