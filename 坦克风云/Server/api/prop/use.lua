function api_prop_use(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local pid = request.params.pid
    local isUseGem = request.params.useGem
    local count    =(request.params.count) or 1
    count  =math.abs(count)
    if uid == nil or pid == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    pid = 'p' .. pid

    -- 使用道具之前先刷一下资源,资源加成道具从此时生效          
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","alien","techs", "troops", "props","bag","skills","buildings","dailytask","task","hero","plane"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mProp = uobjs.getModel('props')
    local mBag = uobjs.getModel('bag')
    local mHero = uobjs.getModel('hero')
    local mAlien = uobjs.getModel('alien')
    local mUerexpedition= uobjs.getModel('userexpedition')
    local mUserarena= uobjs.getModel('userarena')
    local mEquip= uobjs.getModel('equip')
    local mPicstore = uobjs.getModel('picstore')
    local mAccessory = uobjs.getModel('accessory')
    local mAweapon = uobjs.getModel('alienweapon')
    local mPlane = uobjs.getModel('plane')


    --返回客户端坦克的信息
    local getTroopsFlag = false
    --返回英雄信息
    local getHeroFlag   = false
    --返回道具
    local getPropsFlag  = false
    --返回用户信息   
    local getUserFlag   = false
    -- 返回异星科技
    local getmAlienFlag = false
    -- 返回将领装备
    local getSequipFlag = false
    local getBuildFlag = false
    local getTechFlag = false
    -- 获得头像 头像框 挂件 聊天气泡
    local getupicFlag = false

    -- 返回异星武器
    local getAweaponFlag = false


    -- 装甲
    local getArmorFlag   =false
    --返回配件
    local getAccessoryFlag = false
    -- 返回宝石
    local getJewelFlag = false
    -- 返回领地
    local getTerritoryFlag = false
    --返回飞机
    local getPlaneFlag = false
    -- 刷新生产队列
    mProp.update()
    mProp.updateUsePropCd()

    local iCurrNums = mBag.getPropNums(pid)
    local nums = count
    -- 使用数量不能为0以下
    if nums<1 then
        response.ret=-102
        return response
    end

    local propCfg = getConfig('prop')
    local cfg = propCfg[pid]

    if (isUseGem or 0) > 0 and cfg.isSell ~= 1 then
        response.ret=-102
        return response
    end

    if not mProp.checkPropCanUse(pid) then
        response.ret = -1995
        return response
    end
    -- 检测该道具是否能使用多个
    if nums>1 then
        if  cfg.useType==nil or cfg.useType==0 then
            response.ret = -2020
            return response
        end
    end

    if cfg.rolelevel then
        if mUserinfo.level < cfg.rolelevel then            
            return response
        end
    end

    -- 宝石直接使用
    if iCurrNums < 1 or nums > iCurrNums then
        if isUseGem == 1 and mUserinfo.useGem(cfg.gemCost*nums) then
            local mDailyTask = uobjs.getModel('dailytask')
            --新的日常任务检测
            mDailyTask.changeNewTaskNum('s405',1)  
            nums = 0
            regActionLogs(uid,1,{action=27,item=pid,value=cfg.gemCost,params={useNum=nums}})
        else
            response.ret = -1996
           return response
        end
        getUserFlag=true
    end
    
    -- CD时间序列
    if cfg.useDurationTime then
         -- 和平旗
        if cfg.buffid == 'p14' then
            local map = require "lib.map"
            map:setProtectTime(mProp.uid,cfg.useDurationTime*count)
        end
        
        local bSlotInfo = {} 
        bSlotInfo.st = getClientTs()

        bSlotInfo.et = bSlotInfo.st + cfg.useDurationTime*count        

        -- 急速生产，队列分布到其它四种资源上去
        local useSlotRet = true
        if type(cfg.buffid) == "table" then   
            for _,buff4Pid in ipairs(cfg.buffid) do
                if useSlotRet then
                    bSlotInfo.id = buff4Pid
                    useSlotRet = mProp.usePropSlot(propCfg[buff4Pid].buffid,bSlotInfo)
                end
            end
        elseif useSlotRet then
            bSlotInfo.id = cfg.buffid
            useSlotRet = mProp.usePropSlot(cfg.buffid,bSlotInfo)            
        end 

        -- 队列使用失败
        if not useSlotRet then
            response.ret = -1997
            return response
        end
        getPropsFlag=true
    end

    -- 增加道具
    if cfg.useGetProp then
        for k,v in pairs(cfg.useGetProp) do
            if not mBag.add(v[1],v[2]*count) then
                response.ret = -1998
                return response
            end
        end
    end

    -- 增加资源
    if cfg.useGetResource then 
        local setresource = {}
        for k,v in pairs(cfg.useGetResource) do
            setresource[k] = (setresource[k] or 0) + v*count
        end

        if not mUserinfo.addResource(setresource) then
            response.ret = -1991
            return response
        end
        local vippoint =  (setresource.vippoint) or 0
        if vippoint>0 then
            mUserinfo.vip=mUserinfo.updateVipLevel()
        end
           
        getUserFlag=true
    end

    -- 需要消耗其它道具
    -- 不能批量使用
    if cfg.useConsume then 
        local tmpGems = 0
        for _,v in ipairs(cfg.useConsume) do
            local hasN = mBag.getPropNums(v[1])
            if hasN < v[2] then
                -- 道具不足时，是否使用金币补充
                if request.params.ug ~= 1 then
                    response.ret = -1982
                    return response
                end

                local buyNum = v[2] - hasN
                local cost = propCfg[v[1]].gemCost * buyNum
                tmpGems = tmpGems + cost

                if cost > 0 then
                    regActionLogs(uid,1,{action=27,item=v[1],value=cost,params={useNum=buyNum}})
                end
            else
                hasN = v[2]
            end

            if hasN > 0 and not mBag.use(v[1],hasN) then
                response.ret = -1982
                return response
            end
        end

        if tmpGems > 0 and not mUserinfo.useGem(tmpGems) then
            response.ret = -1982
            return response
        end
        getUserFlag=true
    end

    local poolReward,rDetail={}
    if cfg.useGetPool then
        -- 遇到以下key时 poolReward可直接添加  宝石特殊处理
        local containstab = {"troops","userinfo","hero","aweapon","armor","accessory","props","plane","tender","alien","badge"}
        for i=1,count do 
            local Reward = getRewardByPool(cfg.useGetPool)
            local ret 
            local tmprDetail
            ret,tmprDetail = takeReward(uid,Reward)
            --ret,rDetail = takeReward(uid,Reward) 原来的

            if not ret then
                if cfg.aDropMaxNum then
                    response.ret = -6009
                else
                    response.ret = -1989
                end

                return response
            end

            local armorflag=false
            for k,v in pairs(Reward) do
                local reward = k:split('_') 
                if type(reward) == 'table' then
                    if table.contains(containstab,reward[1]) then
                        poolReward[k]=(poolReward[k] or 0) +v
                    end
                    if reward[1] == 'troops' then
                        getTroopsFlag = true
                    elseif reward[1] == 'userinfo' then
                        getUserFlag=true

                    elseif reward[1] == 'hero' then    
                        getHeroFlag=true
                    elseif reward[1] == 'aweapon' then
                        getAweaponFlag=true
                    elseif reward[1] == 'armor' then
                        getArmorFlag = true
                        armorflag=true
                    elseif reward[1]=='accessory' then
                        getAccessoryFlag = true
                    elseif reward[1]=='ajewel' then
                        getJewelFlag = true
                    elseif reward[1]=='plane' then
                        getPlaneFlag = true
		    elseif reward[1]=='alien' then
                        getmAlienFlag = true
                    end
                end
            end

            if armorflag then
                if type(rDetail)~='table' then
                    rDetail={}
                    rDetail.armor={info={}}
                end

                for k,v in pairs(tmprDetail['armor']['info']) do
                    rDetail['armor']['info'][k]=v
                end
            end
            -- 如果加10级的宝石 
            if getJewelFlag then
                for k,v in pairs(tmprDetail) do
                     poolReward[k] = (poolReward[k] or 0) + v
                end
            end
        end

    end


    -- 带幸运的奖池
    if cfg.protectReward then
        mUserinfo.flags.proplucky = mUserinfo.flags.proplucky or 0
        local rwd = {}
        
        -- 随机特殊奖励
        local function rndProtectRwd(pool, isSpecial)
            local Reward,hitKeys = getRewardByPool(pool)
            
            for k,v in pairs(Reward) do
                -- 非命中特殊池
                if 'specialPool' ~= k then
                    rwd[k]=(rwd[k] or 0) +v
                    poolReward[k]=(poolReward[k] or 0) +v
                    local reward = k:split('_') 
                    if type(reward) == 'table' then
                        if reward[1] == 'troops' then
                            getTroopsFlag = true
                        elseif reward[1] == 'userinfo' then
                            getUserFlag=true

                        elseif reward[1] == 'hero' then    
                            getHeroFlag=true
                        elseif reward[1] == 'aweapon' then
                            getAweaponFlag=true
                        end
                    end
                    
                    -- 非特殊池，增加幸运值，否则清空
                    if not isSpecial then
                        local addLucky = cfg.luckyPoint[hitKeys[1]]
                        mUserinfo.flags.proplucky = mUserinfo.flags.proplucky + addLucky
                    else
                        mUserinfo.flags.proplucky = 0
                    end
                -- 命中特殊池
                else
                    rndProtectRwd(cfg.specialPool, true)
                end
            end
        end
        
        -- 进行循环随机奖励
        for _=1,count do
            -- 如果幸运值够，则直接随特殊池
            if mUserinfo.flags.proplucky >= cfg.maxlicky[1] then
                rndProtectRwd(cfg.specialPool, true)
            else
                rndProtectRwd(cfg.protectReward, false)
            end
        end
        
        -- 发放奖励
        local ret
        ret,rDetail = takeReward(uid,rwd)
        if not ret then
            if cfg.aDropMaxNum then
                response.ret = -6009
            else
                response.ret = -1989
            end

            return response
        end
    end

    -- 使用道具送部队
    if cfg.useGetTroops then
        local mTroops = uobjs.getModel('troops') 
        for k,v in pairs(cfg.useGetTroops) do
            if not mTroops.incrTanks(k,v*count) then
                response.ret = -1998
                return response
            end
        end

        getTroopsFlag = true
    end

     -- 使用道具送配件
    if cfg.useGetAccessory then
        response.data.accReward={}
        response.data.accReward.info={}
        local mAccessory = uobjs.getModel('accessory')
        for i=1,count do
            for k,v in pairs(cfg.useGetAccessory) do
                local ret,aid=mAccessory.addAccessory({k,0,0})
                if not  ret then
                    response.ret = -6009
                    return response
                end
                response.data.accReward.info[aid] ={k,0,0}
            end
        end
       
        
    end

     -- 使用道具送碎片
    if cfg.useGetFragment then
        response.data.accReward={}
        response.data.accReward.fragment={}
        local mAccessory = uobjs.getModel('accessory')
        for k,v in pairs(cfg.useGetFragment) do
            if not mAccessory.addFragment(k,v*count) then
                response.ret = -6009
                return response
            end
            response.data.accReward.fragment[k] = (response.data.accReward.fragment[k] or 0 ) + v*count  
        end

    end

    -- 使用道具送配件材料
    if cfg.useGetAccessoryProp then
        response.data.accReward={}
        response.data.accReward.props={}
        local mAccessory = uobjs.getModel('accessory')
        for k,v in pairs(cfg.useGetAccessoryProp) do
            if not mAccessory.addProp(k,v*count) then
                response.ret = -1998
                return response
            end
            response.data.accReward.props[k] = (response.data.accReward.props[k] or 0) + v*count
        end   
         
    end
    --使用道具加英雄或者英魂
    if cfg.useGetHero then
        for i=1,count do
            for k,v in pairs(cfg.useGetHero) do
                if not mHero.addHeroResource(k,v) then
                    response.ret = -1998
                    return response
                end
             end
         end
        getHeroFlag=true
    end
    -- 使用道具添加异星科技的材料

    if cfg.useGetAlienRes then
        for k,v in pairs(cfg.useGetAlienRes) do
            if not mAlien.addMineProp(k,v*count) then
                response.ret = -1998
                return response
            end
         end
    
        getmAlienFlag=true

    end

    -- 使用道具送装甲
    if cfg.useGetArmor then
        getArmorFlag=true
        response.data.amreward={}
        local reward={}
        
        for k,v in pairs (cfg.useGetArmor) do
            reward["armor_"..k]=(reward["armor_"..k] or 0) +v*count
        end

        local ret,retw=takeReward(uid,reward)
        if not ret  then
            response.ret=-9050
            return response
        end
        if type(retw)=="table" and next(retw) then
            response.data.amreward =retw.armor.info
        end
    end

    --使用获得头像
    if cfg.useGetPic then
        if cfg.useGetPic.durationTime then
            --此处需要判断 如果已经有两个此类头像或挂件或头像框或聊天气泡
            --两个在使用时  替换掉结束时间短的 同类的结束时间累加

            local bSlotInfo = {}
            bSlotInfo.id = pid
            bSlotInfo.pid=cfg.useGetPic.pid
            bSlotInfo.ty=string.sub(cfg.useGetPic.pid,1,1)
            local re,inf=mProp.tyInUse(bSlotInfo.ty)
            if #re>=2 and not table.contains(re,bSlotInfo.id) then
                if inf[1]['et']>inf[2]['et'] then
                    mProp.clearUsePropCd(inf[2]['id'])
                else
                    mProp.clearUsePropCd(inf[1]['id'])
                end
                -- response.ret=-2017--超过使用上限
                -- return response
            end

            local inuse=mProp.getInUseBypid(cfg.useGetPic.pid)
            if inuse['et']<=getClientTs()  then 
                bSlotInfo.st = getClientTs()
                bSlotInfo.et = bSlotInfo.st + cfg.useGetPic.durationTime
            else

                bSlotInfo.st = inuse['st']
                bSlotInfo.et = inuse['et'] + cfg.useGetPic.durationTime
            end
            
            mProp.usePropSlot(pid,bSlotInfo)
            local cronParams = {cmd="user.checkpic",params={uid=uid}}
            setGameCron(cronParams, cfg.useGetPic.durationTime)
        else
            mPicstore.addpic(cfg.useGetPic.pid)
        end
        getupicFlag=true

        getUserFlag = true
    end

    --使用获得基地皮肤外观
    local updateMap = false
    if cfg.useGetBaseskin then
        if cfg.useGetBaseskin.id and cfg.useGetBaseskin.durationTime then
            local skinst ,skinet = nil, nil
            local nowtime = getClientTs()
            if type(mUserinfo.flags.skin) == 'table' and 
                mUserinfo.flags.skin[1] == cfg.useGetBaseskin.id and 
                (mUserinfo.flags.skin[2] <= nowtime and nowtime < mUserinfo.flags.skin[3]) then
                -- 结束时间延长
                skinst = mUserinfo.flags.skin[2]
                skinet = mUserinfo.flags.skin[3] + cfg.useGetBaseskin.durationTime
            else
                -- 重新设置时间
                skinst = nowtime
                skinet = nowtime + cfg.useGetBaseskin.durationTime
            end
            -- {外观id, 开始时间, 结束时间}
            mUserinfo.flags.skin={cfg.useGetBaseskin.id, skinst, skinet}
            updateMap = true
            getUserFlag = true
        else
            response.ret = -2000
            return response
        end

    end

    if cfg.useGetHeroPoint then
        local addexp = cfg.useGetHeroPoint*count
        if not mHero.changeExp(addexp) then
            return response
        end
        getHeroFlag = true
    end

    --p409道具查看玩家位置
    if pid == 'p409' then

        local nickname = request.params.nickname
        if not nickname  then
            return response
        end

        if string.len(nickname) < 2 or string.len(nickname) > 40 then
            response.ret = -103
            response.msg = 'nickname invalid'
            return response
        end

        if match(nickname) then
            response.ret = -8024
            return response
        end

        local getLocationByName = function(nickname)
            local db = getDbo()
            local result = db:getRow("select x, y from map where type = 6 and name = :name", {name=nickname})
            if not result then
                return false
            end
            return result
        end

        --保存到缓存
        local saveLocation2Redis = function (nickname, mapx, mapy)
            -- body
            local redis = getRedis()
            local key = "z"..getZoneId()..".radarSearch." .. uid
            local radarData =  redis:get(key)

            radarData = radarData and json.decode(radarData) or {}

            if not radarData[nickname] then radarData[nickname] = {} end

            radarData[nickname].x = mapx
            radarData[nickname].y = mapy

            redis:set(key, json.encode(radarData))

        end

        local location = getLocationByName(nickname)
        if not location then
            response.ret = -315
            return response
        end
        --存到缓存
        print(nickname, location.x, location.y)
        saveLocation2Redis(nickname,  location.x, location.y)

        local mailTitle = "14=" .. nickname
        location.nickname = nickname
        local mail_type = 1
	    location.type = 14
        local mail = json.encode(location)
        local isRead = 0
        --mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead)
        MAIL:mailSent(uid,1,uid,'',mUserinfo.nickname, mailTitle, mail, mail_type, isRead)
        response.data.location = location
    end

     -- 使用道具增加将领装备
    if cfg.useGetEquipRes then
        local addreward={}

        for k,v in pairs (cfg.useGetEquipRes) do
            addreward[k]=(addreward[k] or 0)+v*count
            poolReward["equip_"..k]=(poolReward["equip_"..k] or 0)+v*count
        end

        for k,v in pairs (addreward) do
            if not mEquip.addResource(k,v) then
                response.ret = -1998
                return response
            end
        end
        
    end

     -- 使用道具增加竞技勋章
    if cfg.useGetUserarenaRes then
        local addreward={}
        for k,v in pairs (cfg.useGetUserarenaRes) do
            poolReward["userarena_"..k]=(poolReward["userarena_"..k] or 0)+v*count
            if k=='p' then
                addreward['point']=(addreward['point'] or 0)+v*count
            else
                addreward[k]=(addreward[k] or 0)+v*count
            end
        end
      
        for k,v in pairs (addreward) do
            if not mUserarena.addResource(k,v) then
                response.ret = -1998
                return response
            end
        end 
    end

     -- 使用道具增加远征积分
    if cfg.useGetExpeditionRes then
        local addreward={}
        for k,v in pairs (cfg.useGetExpeditionRes) do
            poolReward["userexpedition_"..k]=(poolReward["userexpedition_"..k] or 0)+v*count
            if k=='p' then
                addreward['point']=(addreward['point'] or 0)+v*count
            else
                addreward[k]=(addreward[k] or 0)+v*count
            end
        end

        for k,v in pairs (addreward) do
            if not mUerexpedition.addResource(k,v) then
                response.ret = -1998
                return response
            end
        end
       
    end

    -- 获取指定道具
    if cfg.useGetSelectProp then
        local selectid = request.params.select
        local selectnum = tonumber(request.params.selectnum) or 0
        local award = {}
        local rkey = nil
        for k, v in pairs( cfg.useGetSelectProp ) do
            local ugsp = v[1]:split('_')
            if next(v) and ugsp[2]==selectid and v[2] == selectnum then
                award[v[1]] = v[2] * count
                rkey = v[1]
                break
            end
        end 

        local ret
        ret,rDetail = takeReward(uid,award)
        if not next(award) or not ret then
            response.ret = -403
            return response
        end

        if string.find(rkey, "hero") then
            getHeroFlag = true
        elseif string.find(rkey, "prop" ) then
            getPropsFlag = true
        elseif string.find(rkey, "sequip") then
            getSequipFlag = true
        elseif string.find(rkey, "userinfo") then
            getUserFlag = true
        elseif string.find(rkey, "troops") then
            getTroopsFlag = true
        elseif string.find(rkey, "aweapon") then
            getAweaponFlag = true
        elseif string.find(rkey,"ajewel") then
            getJewelFlag = true
        end

        if getJewelFlag then
           poolReward = rDetail
        else
            poolReward = award
        end

       
    end

    -- 加速道具
    if cfg.useTimeDecrease then
        local discInter = math.floor(cfg.useTimeDecrease * count)

        if cfg.speedType == 'build' then
            local bid = 'b' .. request.params.bid

            local mBuildings = uobjs.getModel('buildings')
            if not mBuildings.speedupTime(bid, discInter) then
                response.ret =-19990
                return response
            end
            getBuildFlag = true
        elseif cfg.speedType == 'troops' then
            local bid = 'b' .. request.params.bid
            local slotid = request.params.slotid

            local mTroops = uobjs.getModel('troops')
            if not mTroops.speedupTime(slotid, bid, discInter) then
                response.ret =-19991
                return response
            end
            getTroopsFlag = true
        elseif cfg.speedType == 'tech' then
            local slotid = request.params.slotid

            local mTech = uobjs.getModel('techs')
            if not mTech.speedupTime(slotid, discInter) then
                response.ret =-19992
                return response
            end
            getTechFlag = true
        elseif cfg.speedType == 'territory' then -- 军团领地建筑加速     
            if mUserinfo.alliance == 0 then
                response.ret = -102
                return response
            end
            local bid = 'b' .. request.params.bid
            local lt = tonumber(request.params.lt) or 0 --客户端传过来的剩余时间
            local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
            if mAterritory then
                -- 领地维护不能建造 或者升级
                if mAterritory.maintenance() then
                    response.ret = -8411
                    return response
                end

                local code = mAterritory.buildSpeedUp(bid,discInter,lt)
                if code == 0 then
                    regEventAfterSave(uid,'e10',{aid=mUserinfo.alliance})
                else
                    writeLog('领地建筑加速失败1:uid'..uid..'bid='..bid..'aid='..mUserinfo.alliance,"territory")
                    response.data.territory=mAterritory.formatedata()
                    response.ret = code
                    return response
                end
            else
                writeLog('领地建筑加速失败2:uid'..uid..'bid='..bid..'aid='..mUserinfo.alliance,"territory")
                response.ret = -8403
                return response
            end
            getTerritoryFlag = true
        elseif cfg.speedType == 6 then -- 领海战舰队加速
            local uobjs = getUserObjs(uid)
            local mTroops = uobjs.getModel('troops')
            local cronId = "c" .. request.params.slotid

            local fleetInfo = mTroops.getFleetByCron(cronId)
            if not fleetInfo then
                response.ret = -102
                return response
            end

            local ret
            if fleetInfo.bs then
                ret = mTroops.seaWarFleetBackSpeedUp(cronId,cfg.useTimeDecrease)
            else
                ret = mTroops.seaWarFleetAttackSpeedUp(cronId,cfg.useTimeDecrease)
            end

            if not ret then
                response.ret = -5001
                return response
            end

            response.data.troops = mTroops.toArray(true)
        end
    end

    -- 使用得到指定奖励
    if cfg.useGetAward then
        local award = copyTab(cfg.useGetAward)
        if count > 1 then
            for k, v in pairs(award) do
               award[k] = v * count
            end
        end
        
        if not next(award) then
            response.ret = -403
            return response
        end

        local tkflag,tkresult = takeReward(uid, award)
        if not tkflag then
            response.ret = -403
            return response
        end

        local rkey = nil
        for rkey, _ in pairs(award) do
            if string.find(rkey, "hero") then
                getHeroFlag = true
            elseif string.find(rkey, "prop" ) then
                getPropsFlag = true
            elseif string.find(rkey, "sequip") then
                getSequipFlag = true
            elseif string.find(rkey, "userinfo") then
                getUserFlag = true
            elseif string.find(rkey, "troops") then
                getTroopsFlag = true
            elseif string.find(rkey, "aweapon") then
                getAweaponFlag = true
            elseif string.find(rkey, "ajewel") then
                getJewelFlag = true
            end
        end

        if getJewelFlag then
            poolReward = tkresult
        else
            poolReward = award
        end

       
    end

    -- 一键合成
    if cfg.composeGetProp then
        -- 判断使用的宝箱碎末数量
        if count%cfg.composeGetProp[1]~=0 then
            response.ret = -102
            return response
        end

        local comnum = count/cfg.composeGetProp[1]
        if not takeReward(uid,{[cfg.composeGetProp[2][1]] = comnum}) then
            response.ret = -102
            return response
        end
    end
    

    -- 获得活动道具（不进背包那种的 活动期间使用获得 其他时间段获得正常道具或者物品）
    if cfg.useGetActive then
        local actreward = activity_setopt(uid,cfg.useGetActive[1],{act='useprop',pid=pid,num=count})
        -- 活动期间
        if type(actreward) == 'table' and next(actreward) then
            response.data.actreward = {}
            response.data.actreward[cfg.useGetActive[1]] = actreward
            response.data.actreward.num = count
        else
            local actreward = {}        
            -- 非活动期间
            for k,v in pairs(cfg.useGetActive[3]) do
                poolReward[v[1]] = v[2]
            end

            if not takeReward(uid,poolReward) then
                response.ret = -102
                return response
            end
        end  

    end

    if cfg.useGetTender then
        local mTender = uobjs.getModel('tender')
        for k,v in pairs(cfg.useGetTender) do
            if not mTender.addResource(k,v) then
                response.ret = -1989
                return response
            end
        end
    end

    -- 超级装备
    if cfg.useGetSuperEquip then
        local mSequip = uobjs.getModel("sequip")
        for k,v in pairs(cfg.useGetSuperEquip) do
            if not mSequip.addEquip(k,v) then
                response.ret = -1989
                return response
            end
        end
        getSequipFlag = true
    end

    if isUseGem ~= 1 and not mBag.use(pid,nums) then
        response.ret = -1989
        return response
    end

    local mTask = uobjs.getModel('task')
    mTask.check()

    if getTroopsFlag then
        local mTroops = uobjs.getModel('troops')
        response.data.troops = mTroops.toArray(true)
    end
    if getHeroFlag then
        response.data.hero = mHero.toArray(true)
    end
    
    if getPropsFlag then
        response.data.props = mProp.toArray(true)
    end
    if getmAlienFlag then
        response.data.alien = mAlien.toArray(true)
    end
    if getSequipFlag then
        local mSequip = uobjs.getModel("sequip")
        response.data.sequip = mSequip.toArray(true)
    end
    if getBuildFlag then
        local mBuildings = uobjs.getModel("buildings")
        response.data.buildings = mBuildings.toArray(true)
    end
    if getTechFlag then
        local mTech = uobjs.getModel("techs")
        response.data.techs = mTech.toArray(true)
    end
    if getAweaponFlag then
        response.data.alienweapon = mAweapon.toArray(true)
    end

    if  getAccessoryFlag then
        response.data.accessory = mAccessory.toArray(true)
    end

    if getJewelFlag then    
        response.data.alienjewel = mAweapon.formjeweldata()
    end
    if getPlaneFlag then    
        response.data.plane = mPlane.toArray(true)
    end
    
    processEventsBeforeSave()

    if uobjs.save() then   
        response.data.bag = mBag.toArray(true)
        if poolReward then
            response.data.reward = formatReward(poolReward)
        end

        if rDetail and type(rDetail)=='table' then
            if type(rDetail.accessory)=='table' then
                 response.data.accReward = rDetail.accessory
            end
           
            if type(rDetail.armor) == 'table' and rDetail.armor.info then
                response.data.amreward = rDetail.armor.info
            end
        end

        processEventsAfterSave()

        if getUserFlag then
            response.data.userinfo = mUserinfo.toArray(true)
            
        end

        if getupicFlag then
            response.data.picstore2=mProp.getAllp()--这里是有时效的
            response.data.picstore=mPicstore.toArray(true)--这里是永久的
        end

        if getTerritoryFlag then
            local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,true)
            response.data.territory=mAterritory.formatedata()
        end
        
        if updateMap == true then
            local mMap = require "lib.map"
            mMap:refreshBaseSkin(uid)
        end

        response.ret = 0	    
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	
