--
--后台程序改名
-- User: luoning
-- Date: 14-8-13
-- Time: 上午10:44
--
function api_admin_rename(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

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
