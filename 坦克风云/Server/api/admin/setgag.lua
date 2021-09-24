function api_admin_setgag(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid) or 0
    local mtype = tonumber(request.params.type)


    if uid>1000000 then 
         local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "blacklist"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBlackList = uobjs.getModel('blacklist')
        --禁言用户
        if mtype==2 then 
            
            local hour = tonumber(request.params.hour)
            local ts = getClientTs()
            ts=ts+hour*3600
            mBlackList.limitUser(ts, mUserinfo.nickname)
        end
        
        --解除禁言
        if mtype==1 then
            mBlackList.removeLimit()
        end
        
        --得到用户禁言时间
        if mtype==3 then
            local ts =mBlackList.getBlackTime()
            if ts==false then
                ts=0
            end
            response.ret = 0        
            response.msg = 'Success'
            response.data.ts=ts
            return response
        end
        
        if uobjs.save() then 
            response.ret = 0        
            response.msg = 'Success'
        end

    end    
   
    
    --原来的gameconfig复制出来的model
    if mtype==4 then


        require 'model.customconfig'
        local mCoutomconfig = model_customconfig()
        local count = tonumber(request.params.count) or 10
        local hour = tonumber(request.params.hour) or 10
        local lvl = tonumber(request.params.level) or 10
        local ret=mCoutomconfig.createBlacklistCfg(count,hour,lvl)
        if ret then
            response.ret = 0        
            response.msg = 'Success'
        end

    end 

    if mtype==5 then


        require 'model.customconfig'
        local mCoutomconfig = model_customconfig()
        local count = tonumber(request.params.count) or 10
        local hour = tonumber(request.params.hour) or 10
        local config = mCoutomconfig.getCustomConfig('blacklist')

        response.data.config=config
        response.ret = 0        
        response.msg = 'Success'
        

    end

    if mtype == 6 then

        local db = getDbo()
        local result = db:getAllRows("select * from blacklist where et > :id order by st desc",{id=getClientTs()})

        response.data.list = result
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
