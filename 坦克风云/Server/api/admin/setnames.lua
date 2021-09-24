--
-- desc: 修改玩家名字、军团名
-- user: chenyunhe
--
local function api_admin_setnames(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }
    -- 修改玩家的名字
    function self.action_reuname(request)
        local response = self.response
        local uid = tonumber(request.uid)
        local nickname = request.params.nickname

        if not uid or not nickname then
            response.ret = -102
            return response
        end

        if string.len(nickname) < 2 or string.len(nickname) > 40 then
            response.ret = -103
            response.msg = 'nickname invalid'
            return response
        end

        if match(nickname) then
            response.ret = -8024
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props"})
        local userinfo = uobjs.getModel('userinfo')

        if userinfo.nickname == nickname then
            response.ret = 0
            response.msg = "success"
            return response
        end


        local ts = getClientTs()
	    -- flag情况下  多匹配几次名字
        if userGetUidByNickname(nickname) > 0 and request.params.flag then
            for i=0,20 do
                local s1 = string.sub(ts+i,-4)
                local s2 = string.sub(uid,-6)
                local tmpName = 'pl' .. s2 .. s1
         
                if userGetUidByNickname(tmpName) <= 0 then
                    nickname = tmpName
                    break
                end 
            end
        end 

        if userGetUidByNickname(nickname) <= 0  then
            userinfo.nickname = nickname

            local renameMap = function(uid, nickname)
                local db = getDbo()
                local result = db:getRow("select id,type,oid from map where type = :type and oid = :oid",{type=6, oid=uid})
                if result then
                    db:update("map", {name=nickname}, "id=" .. result['id'])
                end
            end
            --修改地图名称
            renameMap(uid, nickname)
            --修改军团名称
            if tonumber(userinfo.alliance) > 0 then
                local joinAtData,code = M_alliance.admin{uid=uid,aid=userinfo.alliance,nickname=nickname }
                if type(joinAtData) ~= 'table' or joinAtData['ret'] ~= 0 then
                    return response
                end
            end

            processEventsBeforeSave()

            if uobjs.save() then
                processEventsAfterSave()
                response.ret = 0
                response.msg = "success"
            end
        end

        return response
    end

    -- 修改军团名字
    function self.action_reaname(request)
        local response =  self.response
        local name = tostring(request.params.name) or ''
        local aid = request.aid
        local nameLen = utfstrlen(name)    
        local maxNameLen = getClientPlat() == 'tank_ar' and 24 or 12

        if aid == nil or nameLen < 3 or nameLen > maxNameLen or utfstrlen(foreignNotice) > 200 then
            response.ret = -102
            return response
        end

        if match(name) then
            response.ret = -8024
            return response
        end

        local aData = {} 
        aData.name = name
        aData.aid = aid
        local execRet,code = M_alliance.resetaname(aData)
        
        if not execRet then
            response.ret = code
            return response
        end

        response.ret = 0
        response.msg = 'Success'
        
        return response
    end


    return self
end

return api_admin_setnames
