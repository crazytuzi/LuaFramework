--
-- 购买精英关卡次数
--
function api_schallenge_buyeite(request)

    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid = request.uid
    local action = request.params.action
    if not uid then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled("sec")==0 then
        response.ret = -9000
        return response
    end 

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "schallenge"})
    local schallenge = uobjs.getModel('schallenge')

    local ret = 0
    if action == 1 then
        ret = schallenge.buyEiteCount()
    end

    if ret ~= 0 then
        response.ret = ret
        return response
    end

    if uobjs.save() then 
        response.data.schallenge = schallenge.getChallengeMaxSid()
    end

    return response
end

