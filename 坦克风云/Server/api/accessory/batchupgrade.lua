-- 配件批量强化

function api_accessory_batchupgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    local t = tostring(request.params.type) or ''
    local p = tostring(request.params.ptype) or ''
    local aid =request.params.aid
    local use =request.params.use or {}
    local count=tonumber(request.params.count) or 1
    if uid == nil  then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('accessoryMUp') == 0 then
        response.ret = -9000
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')
    local mDailyTask = uobjs.getModel('dailytask')
    local acname = "accessoryEvolution"
    local activStatus = mUseractive.getActiveStatus(acname)

    local access = {}
    if aid~=nil then
        local accessid,info =mAccessory.getAccessoryId(aid)
        access=info
    else
        access=mAccessory.getUsedAccessory(t,p)
    end
    if  not next(access) then
        response.ret = -9005
        return response
    end

    local accessid = access[1]
    local level = access[2]
    local version  =getVersionCfg()
    local upgradeMaxLv =tonumber(version.roleMaxLevel)
    local accessconfig = getConfig("accessory.aCfg."..accessid)
    if not next(accessconfig) then
        response.ret =-9002  
        return response
    end
    local kafkaLog = {
        {desc="配件强化前",value={accessid,level,access[3]}},
    }
    --配件位置
    local part = tonumber(accessconfig['part'])
    --配件品质
    local quality = accessconfig['quality']

    local upgradeResource='upgradeResource'
    upgradeResource=upgradeResource..quality
    local resource =  getConfig("accessory."..upgradeResource)
    local upgradeProbability ='upgradeProbability'
    upgradeProbability=upgradeProbability..quality
    local upgradeProbabilityconfig =  getConfig("accessory."..upgradeProbability)
     -- 随机种子
    setRandSeed()
    -- 批量强化

    -------------------- start vip新特权 增加强化配件概率
    local viprate=0
    if moduleIsEnabled('vea')== 1 and mUserinfo.vip>0 then
        local vipForEquipStrengthenRate = getConfig('player.vipForEquipStrengthenRate')
        if type(vipForEquipStrengthenRate)=='table' then
            viprate=vipForEquipStrengthenRate[mUserinfo.vip+1]
        end             
    end
    --------------------- end
    local report={}
    for i=1,count do
        if level+1>mUserinfo.level then
            break
        end
        if  level+1>upgradeMaxLv then
            break
        end
        level=level+1
        if type(resource[part][level]) ~='table' then
            break
        end
        if upgradeProbabilityconfig[level] ==nil then
            break
        end
        local useResource = resource[part][level]

        local rate = upgradeProbabilityconfig[level]
        --元旦献礼活动
        local addRate =activity_setopt(uid,'yuandanxianli',{rate=rate,type="rate"})
        
        if addRate~=nil and addRate>0  then
            rate = rate + addRate
            if rate > 100 then
                rate = 100
            end
        end
       
       
        if viprate>0 then
            rate=rate+math.ceil(rate*viprate)
            if rate>100 then
                rate=100
            end
        end
        --  增加合成概率
        if use[i]~=nil and use[i] >0 and   rate<100 then
            local prate =getConfig("accessory.amuletProbality")
            local pcount=mAccessory.getPropCount('p6')
            if pcount < use[i] then
                response.ret =-9009  
                return response
            end
            local addrate = use[i]*prate
            rate=rate+addrate
            if rate> 100+prate then
                    local  delcount=math.floor((rate-100)/prate)
                    use[i] =use[i]-delcount
            end
            local ret=mAccessory.useProp('p6',use[i])
            if not ret then
                 response.ret =-9009  
                return response
            end 
        end
        local ret =mUserinfo.useResource(useResource)
        if not ret then
            response.ret =-107
            return response
        end

        --新的日常任务检测
        mDailyTask.changeNewTaskNum('s105',1)
        mDailyTask.changeTaskNum1("s1005")

        -- 春节攀升计划活动
        activity_setopt(uid,'chunjiepansheng',{action='au'})
        -- 国庆活动埋点
        activity_setopt(uid, 'nationalDay', {action='au'})
        --中秋赏月
        activity_setopt(uid,'midautumn',{action="au"})
        -- 悬赏任务
        activity_setopt(uid,'xuanshangtask',{t='',e='au',n=1}) 
        -- 愚人节大作战-进行X次配件强化
        activity_setopt(uid,'foolday2018',{act='task',tp='au',num=1},true)

        -- 国庆七天乐
        activity_setopt(uid,'nationalday2018',{act='tk',type='au',num=1})
        -- 感恩节拼图
        activity_setopt(uid,'gejpt',{act='tk',type='au',num=1})

        -- 随机种子
        setRandSeed()
        local randnum = rand(1,100)
        -- 失败了
        local tmp={}
        table.insert(tmp,useResource)
        table.insert(tmp,use[i] or 0)
        if rate< randnum then
            table.insert(tmp,1,0)
            local upgradeFailReturnResource =getConfig("accessory.upgradeFailReturnResource")
            local addResource ={}  
            for key,val in pairs(useResource) do
                 local userupgradeFailReturnResource= upgradeFailReturnResource  
                 if activStatus == 1 then
                     local activeCfg = getActiveCfg(uid, acname)
                     userupgradeFailReturnResource =userupgradeFailReturnResource+(activeCfg.serverreward.value or 0)
                 end
                 addResource[key]=math.floor(val*userupgradeFailReturnResource)
            end 
            local ret=mUserinfo.addResource(addResource)
            table.insert(tmp,addResource)
            if not ret then
                response.ret = -403
                return response
            end
            level=level-1
        else
            table.insert(tmp,1,1)
            local ret = false
            if aid~=nil then
                local rest,info=mAccessory.updateInFoAccessoryLevel(aid,level,0)
                ret=rest
                table.insert(kafkaLog,{desc="后(id,强化,改造)",value={info[1],info[2],info[3]}})
            else
                local rest,info=mAccessory.updateUsedAccessoryLevel(t,p,level,0)
                ret=rest
                table.insert(kafkaLog,{desc="后(id,强化,改造)",value={info[1],info[2],info[3]}})
            end

            table.insert(kafkaLog,{desc="品质",value=quality})
      
            -- kafkaLog
            regKfkLogs(uid,'action',{
                    addition=kafkaLog
                }
            ) 
            -- 设置钢铁之心 之配件强化的等级
            activity_setopt(uid,'heartOfIron',{alevel=level})
            -- 猎杀潜航
            activity_setopt(uid,'silentHunter',{action='at',num=1,type=t})            
            if not ret then
                return response
            end
        end
        table.insert(report,tmp)
    end
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()
        response.data.accessory = mAccessory.toArray(true)
        response.data.report = report
        response.data.xitu=mUserinfo.gold        
        response.ret = 0        
        response.msg = 'Success'
       
    end
    
    return response
end