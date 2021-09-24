--  洗练

function api_accessory_succinct(request)
    local response = {
        ret=-1,
        msg='error',
        data = {accessory={}},
    }

    local uid = request.uid
    local count = tonumber(request.params.count) or 1
    -- method 1 普通  2  高级   3  大师 
    local method = tonumber(request.params.method) or 1
    local p      = request.params.p
    local tank   = request.params.tank
    local value  = request.params.value  or {}
    if moduleIsEnabled('succinct') == 0 or moduleIsEnabled('alien')==0    then
        response.ret = -9034
        return response
    end
    local version  =getVersionCfg()
    if version.unlockAccParts<8 then
        -- 英雄洗练未开启
        response.ret=-9034
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    --local mProp = uobjs.getModel('props')
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag  = uobjs.getModel('bag')
    local accessory=mAccessory.used[tank][p]
    local aid =accessory[1]
    --   攻击  生命  击破   防护
    local info =accessory[4] or {0,0,0,0}
    if not next(info) then
        info={0,0,0,0}
    end

    local aCfg = getConfig("accessory.aCfg."..aid)
    local part = tonumber(aCfg['part'])
    local quality=aCfg.quality
    if aCfg.quality<3 then
        response.ret=-9035
        return response
    end
    local weets = getWeeTs()
    local report={}
    local succinctcfg=getConfig("succinctCfg")

    -- 每日金币洗练次数限制
    if mAccessory.lt < weets then
            mAccessory.lt = weets
            mAccessory.gt=0--大师
            mAccessory.com=0--普通
            mAccessory.hig=0--高级
    end

    if moduleIsEnabled('harmonyversion')==1 then
       if method==1 then
           if mAccessory.com>=succinctcfg.limit[1] then
              response.ret=-1993
              return response
            end        
       end

       if method==2 then
           if mAccessory.hig>=succinctcfg.limit[2] then
              response.ret=-1993
              return response
           end        
       end

       if method==3 then
           if mAccessory.gt>=succinctcfg.limit[3] then
              response.ret=-1993
              return response
           end        
       end
    end 

    local addexp=succinctcfg.add_exp[method]
    local resource=succinctcfg.price[part][method]
    local rate=succinctcfg.addLvValue[method]
    local attLifeLimit=rate[1]
    local arpArmorLimit=rate[2]
    local gems=0
    local valueCount=0
    for vk,val in pairs(value) do
        if val >0 then
            valueCount=valueCount+1
        end
    end
    setRandSeed()
    function getPoint(info)
        -- body
        local rpoint=0
        for k,v in pairs(info) do
            if k>2 then
                rpoint=rpoint+v*20
            else
                rpoint=rpoint+v*800
            end
        end

        return rpoint
    end
    mAccessory.sinfo={}
    for i=1,count do
        local old =copyTab(info)
        local new={}
        for k,v in pairs(info) do
            local level=mAccessory.m_level
            if k>2 then
               local under=tonumber(string.format("%.1f",v*arpArmorLimit[1]))
               local up=v+arpArmorLimit[2]
               local point =rand(under*1000,up*1000)/1000
               point=tonumber(string.format("%.1f",point))
               local maxpoint=succinctcfg.arpArmorLimit[level]
               if quality==3 then
                    maxpoint=succinctcfg.arpArmorLimit[level]/2
               end
               if (point>maxpoint) then
                    point=maxpoint
               end
               new[k]=point
            else
               local under=tonumber(string.format("%.3f",v*attLifeLimit[1]))
               local up=v+attLifeLimit[2]
               local point =rand(under*1000,up*1000)/1000
               point=tonumber(string.format("%.3f",point))
               local maxpoint=succinctcfg.attLifeLimit[level]
               if quality==3 then
                    maxpoint=succinctcfg.attLifeLimit[level]/2
               end
               if (point>maxpoint) then
                    point=maxpoint
               end
               new[k]=point
            end

        end
        
        local tmp={old,new,0}
        -- 看限制条件必须上升才能替换
        local flag={}
        for bk,bv in pairs(value) do
            if bv==1 then
                if bk==1 then
                    
                    local oldpoint=getPoint(old)
                    local newpoint=getPoint(new)
                    
                    if newpoint>oldpoint then
                        table.insert(flag,2)
                    else
                        if newpoint==oldpoint then
                           table.insert(flag,1)
                        else
                            table.insert(flag,0)
                        end
                           
                    end
                    
                else
                    
                    if new[bk-1]>old[bk-1] then
                        table.insert(flag,2)
                    else
                        if new[bk-1] == old[bk-1] then
                            table.insert(flag,1)
                        else
                            table.insert(flag,0)
                        end
                    end
                    
                end
                
            end
        end
        local use=true 
        for uk,uv in pairs(flag) do
            if uv==0 or (valueCount<=1 and uv<=1) then
                use=false
            end
        end

        if use  and  count >1 then
            info=new
            accessory[4]=new
            mAccessory.used[tank][p]=accessory
            tmp[3]=1
            --  精炼
            regKfkLogs(uid,'accessory',{
                        sub_type='succ',
                        addition={
                            old=old,
                            new=accessory,
                            value=value,
                        }
                    }
                    )
        else
            -- 一次精炼的要记录一下值
            local tmp=copyTab(accessory)
            tmp[4]=new
            mAccessory.sinfo={[tank]={[p]=tmp}} 
        end
        table.insert(report,tmp)
        
        -- 扣资源
        if resource.u==nil and resource.p==nil and resource.e==nil  then
            return response
        end

        local useres=true
        --  专家免费
        if mAccessory.succ_at<weets and count==1 and  method==2 then
            useres=false
            mAccessory.succ_at=getClientTs()
        end
        local resrate=1

        for lk,lv in pairs(succinctcfg.privilege[method]) do
           if mAccessory.m_level>=lk then
                resrate=lv
           end
        end

        if useres ==true then
            if resource.u~=nil then
               local u=copyTab(resource.u)
                if resrate<1 then
                    for rk,rv in pairs(u) do
                        u[rk]=math.ceil(rv*resrate)
                    end
                end
                local u1 = {}--钻石
                local u2 = {}--其他的资源
                for uk,uv in pairs(u) do
                    if uk=='gems' then
                        u1[uk] = (u1[uk] or 0) + uv
                    else
                        u2[uk] = (u2[uk] or 0) + uv
                    end
                end

                if next(u2) then
                    if not mUserinfo.useResource(u2) then
                        response.ret =-107
                        return response
                    end
                end
               
                if u1.gems~=nil and u1.gems>0 then
                    if not mUserinfo.useGem(u1.gems) then
                        response.ret = -109
                        return response
                    end
                    gems=gems+u1.gems
                end
            end

            
            if resource.e~=nil then
                local e=copyTab(resource.e)
                if resrate<1 then
                    for ek,ev in pairs(e) do
                        e[ek]=math.ceil(ev*resrate)
                    end
                end
                if not mAccessory.useProps(e) then
                    response.ret=-9033
                    return response
                end
            end
        end
        
        mAccessory.addexp(addexp,succinctcfg.engineerExp,succinctcfg.engineerLvLimit)

    end

    local oldfc = mUserinfo.fc
    processEventsBeforeSave()
    regEventBeforeSave(uid,'e1')
    if gems>0 then
        regActionLogs(uid,1,{action=67,item="",value=gems,params={request}})
    end
    -- 记录每日金币洗练的次数
    if moduleIsEnabled('harmonyversion')==1 then
       if method==3 then
          mAccessory.gt=mAccessory.gt+count
       end
       if method==2 then
          mAccessory.hig=mAccessory.hig+count
       end 

       if method==1 then
           mAccessory.com=mAccessory.com+count
       end       
    end
    if uobjs.save() then 
            processEventsAfterSave()
            -- 统计
            local statskey="z."..getZoneId().."succinct."..method.."ts"..weets
            local redis = getRedis()
            redis:incrby(statskey,count)
            redis:expire(statskey,30*24*3600)
            response.data.report = report
            response.data.accessory.used = {}
            response.data.accessory.m_level=mAccessory.m_level
            response.data.accessory.m_exp=mAccessory.m_exp
            response.data.accessory.used = {}
            response.data.accessory.used = mAccessory.used
            response.data.accessory.com = mAccessory.com
            response.data.accessory.hig = mAccessory.hig
            response.data.accessory.lt = mAccessory.lt
            response.data.accessory.gt = mAccessory.gt
            response.data.accessory.succ_at = mAccessory.succ_at
            response.data.userinfo = mUserinfo.toArray(true)
            response.data.oldfc =oldfc
            response.data.newfc=mUserinfo.fc
            response.ret = 0        
            response.msg = 'Success'
    end
    return response
end
