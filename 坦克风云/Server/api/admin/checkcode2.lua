--查询扫矿验证
function api_admin_checkcode2(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local startTime = request.params.starttime or 0
    local endTime = request.params.endtime or 0
    local nickname = request.params.nickname
    local uid = request.params.uid
    local ip = request.params.ip

    local self = {}
    function self.search()
        local db = getDbo()
        local wherecase = " scoutdata>=" .. startTime .. " and scoutdata<=" .. endTime
        if nickname then
            uid =userGetUidByNickname(nickname)
        end 
        if uid and uid ~= 0 then
            wherecase = wherecase .. " and uid=" .. uid
        end
        if ip then
            wherecase = wherecase .. " and ip='" .. ip .. "'"
        end

        local result = db:getAllRows("select * from scoutlog where " .. wherecase)
        if type(result) ~= 'table' then result = {} end

        for k, v in pairs (result) do
            local uobjs = getUserObjs(tonumber(v.uid))
            local mUserinfo = uobjs.getModel('userinfo')
            result[k].nickname = mUserinfo.nickname
            result[k].vip = mUserinfo.vip
            result[k].level = mUserinfo.level
            result[k].hwid = mUserinfo.hwid
        end

        return result
    end

    local cfg = getConfig('player.checkcode2')

    response.data.cfg = cfg
    response.data.result = self.search()
    response.msg = 'Success'
    response.ret = 0

    return response
end
