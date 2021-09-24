--
-- 指挥官徽章
-- chenyunhe
--

local function api_badge_badge(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
        aname = 'badgechallenge'--活动名字
    }

    local badgeCfg = {}
    function self.before(request)
        local response = self.response
        local uid=request.uid
    
        if not uid then
            response.ret = -102
            return response
        end

        if moduleIsEnabled("badge") ~= 1 then
            response.ret = -180
            return response
        end
        
        badgeCfg = getConfig("badge")
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'badge'})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.level<badgeCfg.main.unlocklevel then
            response.ret = -301
            return response
        end
    end

    -- 初始化
    function self.action_init(request)
        local response = self.response
        local uid = request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'badge'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        response.data.badge = mBadge.toArray()
        response.ret = 0
        response.msg = 'success'   

        return response
    end

    -- 升级
    function self.action_upgrade(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id -- 徽章id(服务器生成的)
        local level=request.params.level or 1
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        if mBadge.info[id]==nil or level<=0 then
            response.ret =-102
            return response
        end

        local cid = mBadge.info[id][1]-- 配置id
        local lvl = mBadge.info[id][2] -- 当前等级
        local br = mBadge.info[id][3] -- 突破次数
        local itemcfg = badgeCfg.itemList[cid]
        if type(itemcfg)~='table' then
            response.ret=-120
            return response
        end

        local quality = itemcfg.quality
        local maxlvl  = itemcfg.maxLevel
        if lvl+level>maxlvl then
            response.ret=-30011
            return response
        end

        local curmaxlevel = itemcfg.maxLevel
        if br < itemcfg.btNum then
            curmaxlevel = itemcfg.btLevel[br+1]
        end

        -- 判断是否需要先突破
        if lvl + level>curmaxlevel then
            response.ret = -30012
            return response
        end 

        local talexp=0
        for i=1,level do
            local needexp = badgeCfg.expCost[quality][lvl+i]
            if mBadge.exp < needexp then
                response.ret = -30013
                return response
            end
            talexp = talexp+needexp
            mBadge.exp=mBadge.exp-needexp
        end
        
        mBadge.info[id][2]=lvl+level
        regKfkLogs(uid,'badge',{
                    addition={
                        {desc="升级徽章id",value=id},
                        {desc="升级信息",value={olvl=lvl,nlvl=mBadge.info[id][2]}},
                        {desc="升级徽章消耗的经验",value=talexp},
                    }
                }
        )

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.badge = mBadge.toArray()
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    -- 突破
    function self.action_break(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        local cid = mBadge.info[id][1]
        local lvl = mBadge.info[id][2]
        local br = mBadge.info[id][3]
        local itemcfg = badgeCfg.itemList[cid]
        if type(itemcfg)~='table' then
            response.ret=-120
            return response
        end

        -- 突破条件判断
        if br>=itemcfg.btNum then
            response.ret = -121
            return response
        end

        if lvl~=itemcfg.btLevel[br+1] then
            response.ret = - 30014
            return response
        end

        if type(itemcfg.btCost[br+1])~='table' then
            response.ret = -102
            return response
        end

        for k,v in pairs(itemcfg.btCost[br+1]) do
            -- 碎片
            if badgeCfg.fragmentList[k] then
                if not mBadge.useFragment(k,v) then
                    response.ret = -30015
                    return response
                end
            else
                -- 突破材料
                if not mBadge.useMaterial(k,v) then
                    response.ret = -30016
                    return response
                end
            end
        end

        mBadge.info[id][3] = mBadge.info[id][3] + 1
        regKfkLogs(uid,'badge',{
                addition={
                    {desc="突破徽章id",value=id},
                    {desc="突破信息",value={olvl=br,nlvl=mBadge.info[id][3]}},
                    {desc="突破消耗的经验",value=itemcfg.btCost[br+1]},
                }
            }
        )

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.badge = mBadge.toArray()
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    -- 装配
    function self.action_set(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        if not mBadge.info[id] then
            response.ret = -102
            return response
        end
        local cid = mBadge.info[id][1]
        local itemcfg = badgeCfg.itemList[cid]
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end

        local part = itemcfg.part
        mBadge.used[part] = id
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.badge = mBadge.toArray()
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    -- 卸下
    function self.action_unset(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        if not mBadge.info[id] then
            response.ret = -102
            return response
        end
        local cid = mBadge.info[id][1]
        local itemcfg = badgeCfg.itemList[cid]
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end

        local part = itemcfg.part
        mBadge.used[part] = 0
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.badge = mBadge.toArray()
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    -- 徽章分解
    function self.action_decompose(request)
        local response = self.response
        local uid = request.uid
        local ids = request.params.ids

        if type(ids)~='table' then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        local exp = 0 -- 返还经验
        local fragment1 = {} -- 合成碎片
        local fragment2 = {} -- 突破碎片
        local material = {} -- 突破材料
        for k,v in pairs(ids) do
            if not mBadge.info[v] then
                response.ret = -102
                return response
            end

            local cid = mBadge.info[v][1] 
            local lvl = mBadge.info[v][2]
            local itemcfg = badgeCfg.itemList[cid]
            if type(itemcfg)~='table' then
                response.ret = -102
                return response
            end

            if table.contains(mBadge.used,v) then
               mBadge.used[itemcfg.part] = 0
            end

            -- 经验
            local quality = itemcfg.quality
            for i=1,lvl do
                exp = exp + badgeCfg.expCost[quality][i]
            end

            -- 突破 消耗的碎片、突破材料
            local br = mBadge.info[v][3]
            if br>0 then
                for i=1,br do
                    for bk,bv in pairs(itemcfg.btCost[i]) do
                        if badgeCfg.fragmentList[bk] then
                            fragment2[bk] = (fragment2[bk] or 0) + bv
                        else
                            material[bk] = (material[bk] or 0) + bv
                        end
                    end
                end
            end
            -- 合成消耗的碎片数量
            local fr = itemcfg.fragment
            fragment1[fr] = (fragment1[fr] or 0) + badgeCfg.fragmentList[fr].needNum

            mBadge.info[v] = nil
        end

        local reward = {}
        exp = math.floor(exp*badgeCfg.main.decomposeRate[2]) -- 此处是否需要取配置
        if exp>0 then
            mBadge.addExp(exp)
            reward['badge_exp'] = exp
        end

        if next(fragment1) then
            for k,v in pairs(fragment1) do
                local cfn = math.floor(v*badgeCfg.main.decomposeRate[1])

                mBadge.addFragment(k,cfn)
                reward['badge_'..k] = (reward['badge_'..k] or 0) + cfn
            end
        end

        if next(fragment2) then
            for k,v in pairs(fragment2) do
                local bfn = math.floor(v*badgeCfg.main.decomposeRate[3])
                mBadge.addFragment(k,bfn)  
                reward['badge_'..k] = (reward['badge_'..k] or 0) + bfn
            end
        end

        if next(material) then
            for k,v in pairs(material) do
                local mn = math.floor(v*badgeCfg.main.decomposeRate[4])
                mBadge.addMaterial(k,mn)
                reward['badge_'..k] = mn
            end
        end

        regKfkLogs(uid,'badge',{
                addition={
                    {desc="分解徽章",value=ids},
                    {desc="分解获得",value=reward},
                }
            }
        )

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.badge = mBadge.toArray()
            response.data.reward = formatReward(reward)
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    -- 合成徽章
    function self.action_compose(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id -- 碎片id
        local n = request.params.n or 0 -- 合成徽章的数量

        if n<=0 or not id then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        if not mBadge.fragment[id] then
            response.ret = -102
            return response
        end

        local itemcfg = badgeCfg.fragmentList[id]
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end

        local cur =  mBadge.getInfoCount()
        local addn = 0
        if (cur+n)>badgeCfg.main.storageLimit then
            local left = badgeCfg.main.storageLimit - cur
            if left>0 then
                addn = n>left and left or n
            end
        else
            addn = n
        end

        if addn<=0 then
            response.ret = -30010
            return response
        end
    
        local cid = itemcfg.metal
        local cost = addn*itemcfg.needNum
        if not mBadge.useFragment(id,cost) then
            response.ret = -30015
            return response
        end

        if not mBadge.add(cid,addn) then
            response.ret = -30010
            return response
        end

        regKfkLogs(uid,'badge',{
                addition={
                    {desc="碎片合成徽章",value={fid=id,n=addn,cost=cost}},
                }
            }
        )

        local reward = {['badge_'..cid]=addn}
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.badge = mBadge.toArray()
            response.data.reward = formatReward(reward)
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end 
        
        return response
    end

    -- 碎片分解
    function self.action_defragment(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id -- 碎片id
        local n = request.params.n or 0 -- 分解的数量

        if n<=0 or not id then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')

        if not mBadge.fragment[id] then
            response.ret = -102
            return response
        end

        local itemcfg = badgeCfg.fragmentList[id]
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end

        if not mBadge.useFragment(id,n) then
            response.ret = -30015
            return response
        end

        local exp = n*itemcfg.decompose
        if not mBadge.addExp(exp) then
            response.ret = -106
            return response
        end

        local reward = {badge_exp=exp}

        regKfkLogs(uid,'badge',{
                addition={
                    {desc="分解徽章碎片",value={fid=id,n=n,exp=exp}},
                }
            }
        )

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.badge = mBadge.toArray()
            response.data.reward = formatReward(reward)
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    -- 获取副本数据
    function self.action_challenge(request)
        local response = self.response
        local weeTs = getWeeTs()
        response.ret = 0
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"badge","useractive"})
        local mUseractive = uobjs.getModel('useractive')
        local mBadge = uobjs.getModel('badge') -- bind的时候会初始化活动数据

        -- 活动副本数据
        local activStatus = mUseractive.getActiveStatus(self.aname)
        -- 活动检测
        if activStatus == 1 then
            response.data.schallenge = copyTable(mUseractive.info[self.aname].challenge) or {}
        end

        uobjs.save()
        response.data.challenge = mBadge.challenge
        response.msg = 'success'
        return response
    end

    -- 购买副本挑战次数
    function self.action_buy(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"badge","useractive","userinfo"})
        local mUseractive = uobjs.getModel('useractive')
        local mBadge = uobjs.getModel('badge')
        local mUserinfo = uobjs.getModel('userinfo')
       
        local vip = mUserinfo.vip
        local cfg = getConfig("badge.main")

        if mBadge.challenge.buy >= cfg.VIPBuy[vip] then
            response.ret = -30018
            return response
        end

        mBadge.challenge.buy = mBadge.challenge.buy + 1
        mBadge.challenge.n = mBadge.challenge.n + cfg.buyGet
        local gems = cfg.buyPrice[mBadge.challenge.buy]
        if not gems or gems<=0 then
            response.ret = -109
            return response
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        mBadge.buytimes = mBadge.buytimes + 1

        regActionLogs(uid,1,{action = 269, item = "", value = gems, params = {vip=vip,cur=mBadge.challenge.buy,num=1}})
        if not uobjs.save() then
            response.ret = -106
            return response
        end

        response.data.badge = mBadge.toArray()
        response.ret = 0        
        response.msg = 'Success'

        return response 
    end

    -- 副本战斗  单次战斗不会自动修复船  扫荡会传自动修复参数
    function self.action_battle(request)
        local response = self.response
        local cid = request.params.cid -- 大章节id
        local fleetInfo = {}
        local num = 0
        local hero   =request.params.hero  
        for m,n in pairs(request.params.fleetinfo) do
            if next(n) then
                n[1] = 'a' .. n[1]
                num = num + n[2]
            end
            fleetInfo[m] = n
        end

        if num <= 0 then
            response.ret = -1
            response.cmd = request.cmd
            response.ts = os.time()
            response.msg = 'troops num is empty'
            return response
        end

        -- 攻防双方id
        local attackerId = request.uid
        local defenderId = request.params.defender
        local equip = request.params.equip


        if not defenderId then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(attackerId)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge","hero"})
        local mBadge = uobjs.getModel('badge')
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')
        local mBag = uobjs.getModel('bag')    
        local mHero      = uobjs.getModel('hero')
        local mSequip = uobjs.getModel('sequip')

        if not mBadge.checkopen(cid) then
            response.ret = -102
            return response
        end

        if not mBadge.checktimes(1) then
            response.ret = -30019
            return response
        end

        -- 关卡是否解锁
        if not mBadge.checkUnlock(cid,defenderId) then
            response.ret = -6001
            response.msg = "challenge not unlock"
            return response
        end

        --check hero
        if type(hero)=='table' and next(hero) then
            hero = mHero.checkFleetHeroStats(hero)
            if hero==false then
                response.ret=-11016 
                return response
            end
        end

        -- check equip
        if equip and not mSequip.checkFleetEquipStats(equip)  then
            response.ret=-8650 
            return response        
        end

        --兵力检测
        if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
            response.ret = -5006
            return response
        end

        local ret,report,win = mBadge.battle(cid,defenderId,fleetInfo,hero,nil,equip)    
        if win == 1 then  
            if not mBadge.usetimes(1) then
                response.ret = -30019
                return response
            end
        end      

        
        if not report or ret~=0 then
            response.ret = -30020
            response.msg = "battle error"
            return response
        end
       
        processEventsBeforeSave()
        if uobjs.save() then        
            response.data.troops = mTroop.toArray(true)
            response.data.bag = mBag.toArray(true)
            response.data.report = report
            response.data.badge = mBadge.toArray()
            
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -501
            response.msg = "save failed"
        end

        return response
    end

    -- 扫荡
    function self.action_raid(request)
        local response = self.response
        local cid = request.params.cid -- 大章节id
        local fleetInfo = {}
        local num = 0
        local hero   =request.params.hero  
        for m,n in pairs(request.params.fleetinfo) do
            if next(n) then
                n[1] = 'a' .. n[1]
                num = num + n[2]
            end
            fleetInfo[m] = n
        end

        if num <= 0 then
            response.ret = -1
            response.cmd = request.cmd
            response.ts = os.time()
            response.msg = 'troops num is empty'
            return response
        end

        -- 攻防双方id
        local attackerId = request.uid
        local defenderId = request.params.defender
        local raidnum = tonumber( request.params.num ) or 0 -- 扫荡次数
        local equip = request.params.equip
        local repair = request.params.repair -- 修复类型

        if not defenderId or raidnum<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(attackerId)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge","hero"})
        local mBadge = uobjs.getModel('badge')
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')
        local mBag = uobjs.getModel('bag')    
        local mHero      = uobjs.getModel('hero')
        local mSequip = uobjs.getModel('sequip')

        if not mBadge.checktimes(1) then
            response.ret = -30019
            return response
        end

        if not mBadge.checkopen(cid) then
            response.ret = -102
            return response
        end

        -- 关卡是否解锁
        if not mBadge.checkUnlock(cid,defenderId) then
            response.ret = -6001
            response.msg = "challenge not unlock"
            return response
        end

        -- 是否能扫荡
        if not mBadge.checkraid(cid,defenderId) then
            response.ret = -30021
            return response
        end

        --check hero
        if type(hero)=='table' and next(hero) then
            hero = mHero.checkFleetHeroStats(hero)
            if hero==false then
                response.ret=-11016 
                return response
            end
        end

        -- check equip
        if equip and not mSequip.checkFleetEquipStats(equip)  then
            response.ret=-8650 
            return response        
        end

        --兵力检测
        if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
            response.ret = -5006
            return response
        end

        local raidcnt = 0
        local reports = {}
        response.data.overflag = 0 -- 默认值 0   -1 攻击次数不足  -2 兵力不足
        -- 扫荡次数
        for i=1, raidnum do 
            --兵力检测
            if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
                response.data.overflag = -2
                break
            end

            if not mBadge.usetimes(1) then
                response.data.overflag = -1
                break
            end

            local ret,report,win,attach = mBadge.battle(cid,defenderId,fleetInfo,hero,repair,equip)  
            if not report then
                response.ret = -30020
                response.msg = "battle error"
                return response
            end
        
            local tmp_report = {r=report.r,attach=attach}
            table.insert(reports, tmp_report)
            if win == 1 then
                 raidcnt = raidcnt + 1
            end
        end
        
        processEventsBeforeSave()
        if uobjs.save() then 
            processEventsAfterSave()       
            response.data.troops = mTroop.toArray(true)
            response.data.bag = mBag.toArray(true)
            response.data.report = reports
            response.data.badge = mBadge.toArray()
            response.data.repair = repair
            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -501
            response.msg = "save failed"
        end

        return response
    end

    -- 活动副本战斗
    function self.action_sbattle(request)
        local response = self.response
        local fleetInfo = {}
        local num = 0
        local hero   =request.params.hero  
        for m,n in pairs(request.params.fleetinfo) do
            if next(n) then
                n[1] = 'a' .. n[1]
                num = num + n[2]
            end
            fleetInfo[m] = n
        end

        if num <= 0 then
            response.ret = -1
            response.cmd = request.cmd
            response.ts = os.time()
            response.msg = 'troops num is empty'
            return response
        end

        -- 攻防双方id
        local attackerId = request.uid
        local defenderId = request.params.defender -- 关卡下标
        local equip = request.params.equip


        if not defenderId or defenderId<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(attackerId)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge","hero","useractive"})
        local mBadge = uobjs.getModel('badge')
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')
        local mBag = uobjs.getModel('bag')    
        local mHero      = uobjs.getModel('hero')
        local mSequip = uobjs.getModel('sequip')
        local mUseractive = uobjs.getModel('useractive')

        -- 活动副本数据
        local activStatus = mUseractive.getActiveStatus(self.aname)
        -- 活动检测
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if not mUseractive.info[self.aname].challenge[defenderId] then
            response.ret = -102
            return response
        end

        if defenderId>1 then
            if mUseractive.info[self.aname].challenge[defenderId-1] == 0 then
                response.ret = -6001
                response.msg = "challenge not unlock"
                return response
            end
        end

        if not mBadge.checktimes(1) then
            response.ret = -30019
            return response
        end

        --check hero
        if type(hero)=='table' and next(hero) then
            hero = mHero.checkFleetHeroStats(hero)
            if hero==false then
                response.ret=-11016 
                return response
            end
        end

        -- check equip
        if equip and not mSequip.checkFleetEquipStats(equip)  then
            response.ret=-8650 
            return response        
        end

        --兵力检测
        if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
            response.ret = -5006
            return response
        end

        local ret,report,win = mBadge.sbattle(defenderId,fleetInfo,hero,nil,equip)    
        if win == 1 then  
            if not mBadge.usetimes(1) then
                response.ret = -30019
                return response
            end
            mUseractive.info[self.aname].challenge[defenderId] = (mUseractive.info[self.aname].challenge[defenderId] or 0) + 1
        end      

        if not report or ret~=0 then
            response.ret = -30020
            response.msg = "battle error"
            return response
        end
       
        processEventsBeforeSave()
        if uobjs.save() then        
            response.data.troops = mTroop.toArray(true)
            response.data.bag = mBag.toArray(true)
            response.data.report = report
            response.data.badge = mBadge.toArray()
            response.data.schallenge = mUseractive.info[self.aname].challenge
            
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -501
            response.msg = "save failed"
        end

        return response
    end

     -- 活动副本扫荡
    function self.action_sraid(request)
        local response = self.response
        local fleetInfo = {}
        local num = 0
        local hero   =request.params.hero  
        for m,n in pairs(request.params.fleetinfo) do
            if next(n) then
                n[1] = 'a' .. n[1]
                num = num + n[2]
            end
            fleetInfo[m] = n
        end

        if num <= 0 then
            response.ret = -1
            response.cmd = request.cmd
            response.ts = os.time()
            response.msg = 'troops num is empty'
            return response
        end

        -- 攻防双方id
        local attackerId = request.uid
        local defenderId = request.params.defender
        local raidnum = tonumber( request.params.num ) or 0 -- 扫荡次数
        local equip = request.params.equip
        local repair = request.params.repair -- 修复类型

        if not defenderId or raidnum<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(attackerId)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge","hero"})
        local mBadge = uobjs.getModel('badge')
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')
        local mBag = uobjs.getModel('bag')    
        local mHero      = uobjs.getModel('hero')
        local mSequip = uobjs.getModel('sequip')
        local mUseractive = uobjs.getModel('useractive')

        -- 活动副本数据
        local activStatus = mUseractive.getActiveStatus(self.aname)
        -- 活动检测
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if not mUseractive.info[self.aname].challenge[defenderId] then
            response.ret = -102
            return response
        end

        if not mBadge.checktimes(1) then
            response.ret = -30019
            return response
        end

        if mBadge.challenge.n < raidnum then
            response.ret = -102
            return response
        end

        -- 能否扫荡
        if mUseractive.info[self.aname].challenge[defenderId]<badgeCfg.main.fastLimit then
            response.ret = -30021
            return response
        end

        --check hero
        if type(hero)=='table' and next(hero) then
            hero = mHero.checkFleetHeroStats(hero)
            if hero==false then
                response.ret=-11016 
                return response
            end
        end

        -- check equip
        if equip and not mSequip.checkFleetEquipStats(equip)  then
            response.ret=-8650 
            return response        
        end

        --兵力检测
        if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
            response.ret = -5006
            return response
        end

        local raidcnt = 0
        local reports = {}
        response.data.overflag = 0 -- 默认值 0   -1 攻击次数不足  -2 兵力不足
        -- 扫荡次数
        for i=1, raidnum do 
            --兵力检测
            if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
                response.data.overflag = -2
                break
            end

            if not mBadge.usetimes(1) then
                response.data.overflag = -1
                break
            end

            local ret,report,win,attach = mBadge.sbattle(defenderId,fleetInfo,hero,repair,equip)  
            if not report then
                response.ret = -30020
                response.msg = "battle error"
                return response
            end
        
            local tmp_report = {r=report.r,attach=attach}
            table.insert(reports, tmp_report)
            if win == 1 then
                 raidcnt = raidcnt + 1
                 mUseractive.info[self.aname].challenge[defenderId] = (mUseractive.info[self.aname].challenge[defenderId] or 0) + 1
            end
        end

        processEventsBeforeSave()
        if uobjs.save() then 
            processEventsAfterSave()       
            response.data.troops = mTroop.toArray(true)
            response.data.bag = mBag.toArray(true)
            response.data.report = reports
            response.data.badge = mBadge.toArray()
            response.data.repair = repair
            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -501
            response.msg = "save failed"
        end

        return response
    end

    --使用经验道具将经验增加到经验池
    function self.action_useexpro(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id -- id
        local n = request.params.n or 0 -- 数量

        if n<=0 or not id then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","badge"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')
        local flag,exp = mBadge.useExpPro(id,n)
        if not flag then
            response.ret = -102
            return response
        end

        local reward = {badge_exp=exp}
        regKfkLogs(uid,'badge',{
                addition={
                    {desc="使用徽章经验道具",value={id=id,n=n}},
                }
            }
        )

        if uobjs.save()  then 
            response.data.badge = mBadge.toArray()
            response.data.reward = formatReward(reward)
            response.ret = 0        
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end
    
    return self
end

return api_badge_badge
