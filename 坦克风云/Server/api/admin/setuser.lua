function api_admin_setuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local nickname = tostring(request.nickname)
    local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0

    if uid < 1 or type(request.params) ~= 'table' then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')

    local playerCfg = getConfig('player')

    for k,v in pairs(request.params) do
        if k == 'exp' then
            v = tonumber(v) or 0 
            if v > 0 then
                mUserinfo.exp = v
                mUserinfo.updateLevel()
            end
        elseif k == 'level' then
            local iLevel = tonumber(v) or 0 
            local tPlayerExpsCfg = playerCfg.level_exps
            local iLevelXp = tPlayerExpsCfg[iLevel] or 0 

            if iLevelXp >= 0 and iLevel > 0 then
                mUserinfo.level = iLevel
                mUserinfo.exp = iLevelXp
            end
        elseif k == 'honor' then
            v = tonumber(v) or 0
            local tPlayerHonorCfg = playerCfg.honors
            local maxHonnor = tPlayerHonorCfg[#tPlayerHonorCfg]
            local minHonnor = tPlayerHonorCfg[0]

            v = v > maxHonnor and maxHonnor or v
            v = v < minHonnor and minHonnor or v

            mUserinfo.honors = v
        elseif k == 'gems' then
            v = tonumber(v) or 0
            if v > 0 then
                local oldGems = mUserinfo.gems
                mUserinfo.gems = v

		local difnum = v-oldGems
                recordRequest(uid,'gem',{num=difnum})

                regActionLogs(uid,6,{action=602,item="gm",value=num,params={oldGems=oldGems,gems=mUserinfo.gems}})
            end

        elseif k == 'regdate' then
            v = tonumber(v) or 0
            if v > 0 then
                mUserinfo.regdate = v
            end
        elseif k == 'hwid' then
            -- v = tonumber(v) or 0
            -- if tonumber(mUserinfo.hwid) ~= v then
            --     if (not tonumber(mUserinfo.hwid) or tonumber(mUserinfo.hwid) == 0 ) and v == 1 then
            --         local redis = getRedis()
            --         local key = "z"..getZoneId()..".login."..mUserinfo.uid
            --         redis:del(key)    
            --     end

            --     mUserinfo.hwid = v
            -- end
            mUserinfo.hwid = v
            local redis = getRedis()
            local key = "z"..getZoneId()..".login."..mUserinfo.uid
            redis:del(key)
        elseif k == 'vip' then
            v = tonumber(v) or 0 
            -- if v > 0 then
                local tPlayerVipCfg = playerCfg.vipLevel
                local maxVip = tPlayerVipCfg[#tPlayerVipCfg]
                v = v > maxVip and maxVip or v
                mUserinfo.vip = v
            -- end

        elseif k=='rank' then
                
            v = tonumber(v) or 0 
            -- if v > 0 then
                local tPlayerVipCfg = playerCfg.vipLevel
                local rankCfg =getConfig("rankCfg")
                for k,val in pairs(rankCfg.rank) do
                    if val.id==v then
                        mUserinfo.rank = v
                        mUserinfo.rp   = val.point
                    end
                end
               

        else

            mUserinfo[k] = v

        end
    end

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()  
    if uobjs.save() then
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end

    return response

end