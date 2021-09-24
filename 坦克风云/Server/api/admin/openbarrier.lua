--
-- 打开所有关卡
-- User: luoning
-- Date: 14-9-3
-- Time: 下午8:28
--
function api_admin_openbarrier(request)

    local response = {
            ret=-1,
            msg='error',
            data = {},
    }

    local uid = request.uid
    if uid == nil then
        return response
    end
    local defenderId = 0
    if request.params then
        defenderId= request.params.fid
    end
    -- local challengeCfg = getConfig('arenaNpcCfg')
    -- if not defenderId then
    --     local jishu = 0
    --     for _,_ in pairs(challengeCfg) do
    --         jishu = jishu + 1
    --     end
    --     defenderId = jishu
    -- end

    -- if not challengeCfg['s'..defenderId] then
    --     return response
    -- end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "challenge", "schallenge"})
    local challenge = uobjs.getModel('challenge')
    local schallenge = uobjs.getModel('schallenge')
    local self = {}
    --普通关卡设置
    function self.setChallenge()
        local challengeCfg = getConfig('challenge')
        if not challengeCfg then
            return false, response
        end

        local allBarr = 0
        for k, v in pairs(challengeCfg) do 
            allBarr = allBarr + 1
        end 
        if not defenderId or defenderId > allBarr then
            defenderId =  allBarr  
        end

        local challengeInfo = {}
        for i=1, defenderId do
            challengeInfo['s'..i] = {s=3}
        end
        challenge.info = challengeInfo

        return true
    end

    --精英关卡
    function self.setEiteChallenge( )
        local challengeCfg = getConfig('schallenge.challenge')
        if not challengeCfg then
            return false, response
        end

        local allBarr = 0
        for k, v in pairs(challengeCfg) do 
            allBarr = allBarr + 1
        end         
        if not defenderId or defenderId > allBarr then
            defenderId =  allBarr  
        end
        
        local challengeInfo = {}
        for i=1, defenderId do
            challengeInfo['s'..i] = {s=3}
        end
        schallenge.info = challengeInfo

        return true        
    end

    local action = request.params.action
    local ret = false
    if action and action==1 then
       ret = self.setEiteChallenge()
    else
       ret = self.setChallenge()
    end

    if not ret then
        return response
    end
    if uobjs.save() then
        response.msg = 'Success'
        response.ret = 0
    end
    return response
end

