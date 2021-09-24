--
-- 修改活动数据
-- User: luoning
-- Date: 14-11-20
-- Time: 上午11:21
--
function api_admin_modifyactivedata(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local action = request.params.action
    if action == nil then
        return response
    end

    if action == "list" then

        response.data = getConfig("adminActive")
        response.ret = 0
        response.msg = "Success"
    elseif action == "modify" then

        local uid = tonumber(request.uid)
        local aname = request.params.activename
        local value = tonumber(request.params.value) or request.params.value
        local item = request.params.item
        local uobjs = getUserObjs(uid)
        local mUserActive = uobjs.getModel('useractive')
        local tmpValue = json.decode(value)
        if type(tmpValue) == "table" then
            value = tmpValue
        end
        if not uid or not aname or not value or not item or not mUserActive.info[aname] then
            return response
        end

        item = item:split(":")
        local flag = true
        if item[1] then
            if not mUserActive.info[aname][item[1]] then
                mUserActive.info[aname][item[1]] = {}
            end
            if not item[2] then
                mUserActive.info[aname][item[1]] = value
                flag = false
            end
        end
        if flag then
            if item[2] then
                if not mUserActive.info[aname][item[1]][item[2]] then
                    mUserActive.info[aname][item[1]][item[2]] = {}
                end
                if not item[3] then
                    mUserActive.info[aname][item[1]][item[2]] = value
                    flag = false
                end
            end
        end
        if flag then
            if item[3] then
                if not mUserActive.info[aname][item[1]][item[2]][item[3]] then
                    mUserActive.info[aname][item[1]][item[2]][item[3]] = {}
                end
                if not item[4] then
                    mUserActive.info[aname][item[1]][item[2]][item[3]] = value
                end
            end
        end
        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end
    end
    return response
end

