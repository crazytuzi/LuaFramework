--5.1
--钛矿丰收周
function api_active_taibumperweek(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid
    local day = request.params.day or 0
    local t = request.params.t or 0
    local l = request.params.l or 0
    local r = request.params.r or 0
    if  uid ==nil then
        response.ret=-102
        return response
    end

 -- 活动名称，幸运转盘
    local acname = 'taibumperweek'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active." .. acname.."."..mUseractive.info[acname].cfg)
    if mUseractive.info[acname].t~=weeTs then
            mUseractive.info[acname].d={}
    end   
    --activity_setopt(uid,'taibumperweek',{pay=100})
    --activity_setopt(uid,'taibumperweek',{l=1})
    --activity_setopt(uid,'taibumperweek',{t=10})
    --activity_setopt(uid,'taibumperweek',{res={r4=1000000}})
    if type(mUseractive.info[acname].d.rd)~='table' then  mUseractive.info[acname].d.rd={} end

    if day~=nil and day~=0 then
        if type(mUseractive.info[acname].pfr)~='table' then  mUseractive.info[acname].pfr={} end
        local flag =false
        local gem=0
        if mUseractive.info[acname].pf~=nil  and next(mUseractive.info[acname].pf) then
            for k,v in pairs(mUseractive.info[acname].pf) do
                gem=gem+v
                local addcount =mUseractive.info[acname].pfr[k] or 0
                if addcount<mUseractive.info[acname].pf[k] then
                    flag=true
                    local resRate=mUseractive.info[acname].pf[k]-addcount
                    local dayarr = k:split('d') 
                    local index =tonumber(dayarr[2])
                    local count=activeCfg.dayres[index]
                    if count==nil then
                        response.ret=-102
                        return response
                    end
                    local addresource={[activeCfg.res]=count*resRate}
                    local ret = mUserinfo.addResource(addresource)
                    if not ret then
                        response.ret=-403
                        return response
                    end
                    mUseractive.info[acname].pfr[k]=(mUseractive.info[acname].pfr[k] or 0) +resRate
                end
                
            end

        end
        if gem>=500000 then
            response.ret=-1987
            return response
        end
        if not flag then
            response.ret=-102
            return response
        end
        
    end

    if t~=nil and t>0 then
        if type(mUseractive.info[acname].d.rd.t)~='table' then  mUseractive.info[acname].d.rd.t={} end
        if mUseractive.info[acname].d.t <activeCfg.task.t[t][1] then
            response.ret=-102
            return response
        end

        local pkey="p"..t
        for k,v in pairs(mUseractive.info[acname].d.rd.t) do
            if v==pkey then
                response.ret=-102
                return response
            end
        end
        local addresource={[activeCfg.res]=activeCfg.task.t[t][2]}
        
        local ret = mUserinfo.addResource(addresource)
        if not ret then
            response.ret=-403
            return response
        end
        table.insert(mUseractive.info[acname].d.rd.t,pkey)
    end

    if l~=nil and l>0 then
        local flag=mUseractive.info[acname].d.rd.l or 0
        if flag==1 then
            response.ret=-102
            return response
        end
        local addresource={[activeCfg.res]=activeCfg.task.l[1][2]}
        
        local ret = mUserinfo.addResource(addresource)
        if not ret then
            response.ret=-403
            return response
        end
        mUseractive.info[acname].d.rd.l=1
    end

    if r~=nil and r>0 then
        if type(mUseractive.info[acname].d.rd.r)~='table' then  mUseractive.info[acname].d.rd.r={} end
        if mUseractive.info[acname].d.r < activeCfg.task.r[r][1] then
            response.ret=-102
            return response
        end

        local pkey="p"..r
        for k,v in pairs(mUseractive.info[acname].d.rd.r) do
            if v==pkey then
                response.ret=-102
                return response
            end
        end
        local addresource={[activeCfg.res]=activeCfg.task.r[r][2]}
        local ret = mUserinfo.addResource(addresource)
        if not ret then
            response.ret=-403
            return response
        end
        table.insert(mUseractive.info[acname].d.rd.r,pkey)
    end
   if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
   end
   return response
end