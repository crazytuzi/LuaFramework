--desc:粽子作战活动
--user:chenyunhe

local function api_active_zongzizuozhan(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'zongzizuozhan',
    }
    --  兑换粽子
    function self.action_exchange(request)
        local response = self.response
        local uid = request.uid

        local item = tonumber(request.params.item) or 1  -- 兑换项
        local num =tonumber(request.params.num) or 0 --兑换个数
        local ts = getClientTs()
        local weeTs = getWeeTs()

        if  not table.contains({1,2},item) or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
 
        if type(mUseractive.info[self.aname].m)~='table' then
        	response.ret=-102
        	return response
        end
       
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ex=activeCfg.exchange[item]
      
        -- 判断兑换条件
        for k,v in pairs(ex.n) do
        	if mUseractive.info[self.aname].m[v[1]]<v[2]*num then
        		response.ret=-1981
        		return response
        	else
        		mUseractive.info[self.aname].m[v[1]]=mUseractive.info[self.aname].m[v[1]]-v[2]*num
        	end
        end

        mUseractive.info[self.aname]['item'..item]=(mUseractive.info[self.aname]['item'..item] or 0)+num

        local reward={}
        reward[ex['serverreward']]=num
	    if not takeReward(uid, reward) then
	        return response
	    end        

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

return api_active_zongzizuozhan