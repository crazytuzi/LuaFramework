 --
-- desc: 三周年-充值返利
-- user: chenyunhe
--
local function api_active_sznczfl(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'sznczfl',
    }

    function self.before(request)
        local response = self.response    
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if not uid then
            response.ret = -102
            return response
        end

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local weeTs = getWeeTs()
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local flag = false
        -- 可领取的钻石
        if not mUseractive.info[self.aname].gems then
            flag = true
            mUseractive.info[self.aname].gems = 0
        end

        -- 充值次数
        if not mUseractive.info[self.aname].cn then
            flag = true
            mUseractive.info[self.aname].cn = 0
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取返利 
    function self.action_rebate(request)
    	local response = self.response
        local uid= request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive',})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
 
        local gems = mUseractive.info[self.aname].gems or 0
        if gems<=0 then
            response.ret = -102
            return response
        end

        local reward = {userinfo_gems=gems}
        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        mUseractive.info[self.aname].gems = 0
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response        
    end

    return self
end

return api_active_sznczfl
