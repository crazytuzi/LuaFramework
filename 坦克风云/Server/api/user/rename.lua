function api_user_rename(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local URL = require "lib.url"
    local uid = tonumber(request.uid)     
    local nickname = request.params.nickname
    local pic = tonumber(request.params.pic)
    local useprop = request.params.usep or false
    -- useprop = 1dd 
    if not uid or not nickname or not pic then
        response.ret = -102
        return response
    end
    
    if string.len(nickname) < 2 or string.len(nickname) > 40 then
        response.ret = -103  
        response.msg = 'nickname invalid'
        return response
    end
    
    if match(nickname) then
        -- response.ret = -134
        return response
    end

    if  userGetUidByNickname(nickname) <= 0  then 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props"})
        local userinfo = uobjs.getModel('userinfo')

        if type(userinfo.flags) ~= 'table' then
            userinfo.flags = {}
        end
        local cfg = getConfig('prop.p3308')
        local gems = cfg.gemCost
        local cfgcdtime = cfg.useCDTime
        local cdtime = userinfo.flags.cdtime or 0
        local now = os.time()
        if not string.find(userinfo.nickname,'@') then
            if cdtime ~= 0 then
                if (now-cdtime) < cfgcdtime then
                    response.ret = -3038
                    return response
                end
                if not useprop then
                    response.ret = -102
                    return response
                end
            end
        end
           -- 使用改名卡
        if useprop then
            local mBag = uobjs.getModel('bag')
            if not mBag.use('p3308',1) then
                if moduleIsEnabled('rename') == 0 then
                    response.ret = -1996
                    return response
                else
                    if not userinfo.useGem(gems) then
                        response.ret = -109
                        return response
                    end
                    if gems>0 then
                        request.params.nickname = URL:url_escape(request.params.nickname)
                        regActionLogs(uid,1,{action=233,item="",value=gems,params={}})
                    end
                end
            else
               response.data.bag = mBag.toArray(true)
            end
        end
      
        local level = userinfo.level
        local vip = userinfo.vip
        local oldname = userinfo.nickname
        local aid = userinfo.alliance
        userinfo.nickname = nickname        
        userinfo.pic = pic
        if userinfo.flags.isnamed == 1 then
           userinfo.flags.cdtime = os.time()
        end
        userinfo.flags.isnamed=1
        regEventAfterSave(uid,'e8',{})
        local params = {
                    uid = tonumber(uid),
                    vip = tonumber(vip),
                    level = tonumber(level),
                    oldname = oldname,
                    newname = nickname,
                    update_at = os.time(),
            }
    
        local db = getDbo()
        local ret = db:insert('namelog',params)
        if ret then 
            -- 修改军团玩家名字
            if aid>0 then
                local Ret, code = M_alliance.editname{oldname=oldname,newname=nickname,aid=aid,uid=uid}
                if not Ret then
                    response.ret = code
                    return response
                end
            end
        end

        activity_setopt(uid,'gerrecall',{act='rename',nickname=nickname})

        processEventsBeforeSave()

        if uobjs.save() then           

            -- 北美登陆日志
            if getClientPlat() == "kunlun_na" or getClientPlat() == "1mobile" or getClientPlat() == "kunlun_france" then                
                local log = {request.rplatid,uid,request.client_ip,getClientTs(),request.pname}
                writeKunLunNALog(request.appid,3,log)
            end

            processEventsAfterSave()      
            response.ret = 0
            response.msg = "success"
        end
    

        -- response.ret = -134
    end
    
    return response
end
