--desc:德国老玩家回归活动
--user:chenyunhe
local function api_active_userreturn(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'userreturn',
    }
    
    function self.action_getreward(request)
        local response = self.response
        local uid = request.uid
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 判断是否领取过
        if mUseractive.info[self.aname].v==1 then
            response.ret = -1976
            return response
        end

        if mUseractive.info[self.aname].c~=1 then
        	response.ret=-1981
        	return response
        end

        local reward = activeCfg['serverreward']
        local awards = {}
        for i=1,#reward do
            awards[reward[i][1]]=(awards[reward[i][1]] or 0)+reward[i][2]
        end
       
        if not takeReward(uid,awards) then
            return response
        end

        mUseractive.info[self.aname].v=1
        mUseractive.info[self.aname].flag=1 --后期查询标识 php 用的是flag查的
        mUseractive.info[self.aname].userreturnflag=1 --后期查询标识 以后如果只查询uid 就用这个标识查
        mUseractive.info[self.aname].rt=ts  --领取时间记录
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    return self
end

return api_active_userreturn