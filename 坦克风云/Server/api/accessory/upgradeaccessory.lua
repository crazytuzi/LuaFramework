-- 配件强化
function  api_accessory_upgradeaccessory(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid

    local t = tostring(request.params.type) or ''
    local p = tostring(request.params.ptype) or ''
    local aid =request.params.aid
    local use =math.abs(tonumber(request.params.use) or 0)
    if uid == nil  then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('ec') == 0 then
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
    
    -- stats ---------------------------------------
    -- 强化次数
    regStats('accessory_daily',{item= 'upgradeNum.' .. (access[1] or ''),num=1})
    --强化人数
    if getWeeTs() ~= getWeeTs(mAccessory.upgrade_at) then
        regStats('accessory_daily',{item= 'upgradeUser.' .. (access[1] or ''),num=1})
    end
    -- stats ---------------------------------------

   	if  not next(access) then
    	response.ret = -9005
	    return response
    end
    -- access 1配件id   2  强化等级  3精炼等级

    local accessid = access[1]
    local level = access[2]
    if(level+1>mUserinfo.level)then
        response.ret = -9006
        return response
    end

    local kafkaLog = {
        {desc="配件强化前",value={accessid,level,access[3]}},
    }

    local version  =getVersionCfg()
    local upgradeMaxLv =tonumber(version.roleMaxLevel)
    if(level+1>upgradeMaxLv)then
        response.ret = -9021
        return response
    end

    level=level+1
    local accessconfig = getConfig("accessory.aCfg."..accessid)
    if not next(accessconfig) then
        response.ret =-9002  
        return response
    end
    --配件位置
    local part = tonumber(accessconfig['part'])
    --配件品质
    local quality = accessconfig['quality']

    local upgradeResource='upgradeResource'
    upgradeResource=upgradeResource..quality

    local resource =  getConfig("accessory."..upgradeResource)

    if type(resource[part][level]) ~='table' then
        response.ret =-9007  
        return response
    end
    local useResource = resource[part][level]
    local upgradeProbability ='upgradeProbability'
    upgradeProbability=upgradeProbability..quality
    local upgradeProbabilityconfig =  getConfig("accessory."..upgradeProbability)

    if upgradeProbabilityconfig[level] ==nil then
        response.ret =-9008  
        return response
    end
    local rate = upgradeProbabilityconfig[level]
    --元旦献礼活动
    local addRate =activity_setopt(uid,'yuandanxianli',{rate=rate,type="rate"})
    if addRate~=nil and addRate>0  then
        rate = rate + addRate
        if rate > 100 then
            rate = 100
        end
    end

    -------------------- start vip新特权 增加强化配件概率
    if moduleIsEnabled('vea')== 1 and mUserinfo.vip>0 then
        local vipForEquipStrengthenRate = getConfig('player.vipForEquipStrengthenRate')
        if type(vipForEquipStrengthenRate)=='table' then
            rate =rate+math.ceil(rate*vipForEquipStrengthenRate[mUserinfo.vip+1])
            if rate>100 then
                rate=100
            end
        end             
    end
    --------------------- end

    if rate~=100 and use>0 then

        local prate =getConfig("accessory.amuletProbality")

        local pcount=mAccessory.getPropCount('p6')
        if pcount < use then
            response.ret =-9009  
            return response
        end
        local addrate = use*prate
        rate=rate+addrate
        if rate> 100+prate then
                local  delcount=math.floor((rate-100)/prate)
                use =use-delcount
        end
        local ret=mAccessory.useProp('p6',use)
       
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

    -- 中秋赏月活动埋点
    activity_setopt(uid, 'midautumn', {action='au'})
    -- 国庆活动埋点
    activity_setopt(uid, 'nationalDay', {action='au'})
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='au'})

    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='au',n=1})
    -- 点亮铁塔
    activity_setopt(uid,'lighttower',{act='au',num=1}) 
    -- 愚人节大作战-进行X次配件强化
    activity_setopt(uid,'foolday2018',{act='task',tp='au',num=1},true)

    -- 国庆七天乐
    activity_setopt(uid,'nationalday2018',{act='tk',type='au',num=1})
    -- 感恩节拼图
    activity_setopt(uid,'gejpt',{act='tk',type='au',num=1})

    -- 随机种子
    setRandSeed()
    response.data.accessory={}
    local randnum = rand(1,100)
    if rate< randnum then
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
        if not ret then
            response.ret = -403
            return response
        end
        if uobjs.save() then
            processEventsAfterSave()
            response.data.xitu=mUserinfo.gold
            response.data.accessory.props={}
            response.data.accessory.props=mAccessory.props 
            response.data.xitu=mUserinfo.gold
            response.ret = 0        
            response.msg = 'Success'
            return response
        else

            response.ret = -1
            response.msg = "save failed"
            return response
        end
       else 
        local ret = false

        if aid~=nil then
            local rest,info=mAccessory.updateInFoAccessoryLevel(aid,level,0)
            ret=rest
            response.data.accessory.info={}
            response.data.accessory.info[aid]=info
            
            table.insert(kafkaLog,{desc="后(id,强化,改造)",value={info[1],info[2],info[3]}})
        else
            local rest,info=mAccessory.updateUsedAccessoryLevel(t,p,level,0)
            ret=rest
            response.data.accessory.used={}
            response.data.accessory.used[t]={}
            response.data.accessory.used[t][p]=info

            table.insert(kafkaLog,{desc="后(id,强化,改造)",value={info[1],info[2],info[3]}})
        end

        table.insert(kafkaLog,{desc="品质",value=quality})
  
        -- kafkaLog
        regKfkLogs(uid,'accessory',{
                addition=kafkaLog
            }
        ) 

        -- 设置钢铁之心 之配件强化的等级
        activity_setopt(uid,'heartOfIron',{alevel=level})

        -- 猎杀潜航
        activity_setopt(uid,'silentHunter',{action='at',num=1,type=t})

        --德国七日狂欢 
        activity_setopt(uid,'sevendays',{act='accup',v=mAccessory.info,n=mAccessory.used})
        if ret then
            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave()
             mAccessory.upgrade_at=getClientTs()
            if uobjs.save() then 
                processEventsAfterSave()
                response.data.accessory.props={}
                response.data.accessory.props=mAccessory.props
                response.data.xitu=mUserinfo.gold
                response.ret = 0        
                response.msg = 'Success'
                return response
            else

                response.ret = -1
                response.msg = "save failed"
            end
            else 
                response.ret=-1   
                return response
        end 
        
    end


end