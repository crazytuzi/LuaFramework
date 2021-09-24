-- 宝石系统
local function api_alienweapon_jewel(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    -- 功能等级限制
    function self.checkopen(level)
        local jewelCfg = getConfig("alienjewel")
        if level < jewelCfg.others['unlocklevel'] then
            return false
        end

        return true
    end

    -- 合成宝石 两个相同颜色且等级相同 
    function self.action_compose(request)
        local response = self.response
        local uid =  request.uid
        local jewel =  request.params.j
        local method = request.params.method or 1 --1 不消耗 2 必定成功
        local usep = request.params.usep or 0
        local useg = request.params.useg or 0

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        if not jewel or not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})      
        local mUserinfo = uobjs.getModel('userinfo') 
        local mAweapon = uobjs.getModel('alienweapon')
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local cfg = getConfig('alienjewel')
        local jewelCfg = mAweapon.getjewelCfg(jewel)
        if type(jewelCfg)~= 'table' or not next(jewelCfg) then
            response.ret = -102
            return response
        end

        -- 十级宝石不能融合
        local subj =  string.sub(jewel,1,1)
        if subj == 't' then
            response.ret = -102
            return response
        end
        local usedjewel = mAweapon.usedjewel()
        
        local available = tonumber(mAweapon.jewelinfo1[jewel]) or 0
        if usedjewel[jewel] then
            available = available - usedjewel[jewel]
        end

        if available < jewelCfg.combinenum then
            response.ret = -26004
            return response
        end

        local costGem = 0
        local costprop = 0
        local costjewel = {}

        setRandSeed()
        local rd=rand(1,100)
        -- 合成成功
        local stive = 0
        local crystal = 0
        local reward = {}
        local flag = false
        if method ==2 then   
            local keys = cfg.others.upItem:split('_')
            local mBag = uobjs.getModel('bag')
            local propNums = mBag.getPropNums(keys[2])
    
            if propNums >= jewelCfg.upNum then
                if not mBag.use(keys[2],jewelCfg.upNum) then
                    response.ret = -1995
                    return response    
                end
                costprop = jewelCfg.upNum
            else
                local diff = jewelCfg.upNum-propNums
                if propNums>0 then
                    if not mBag.use(keys[2],propNums) then
                        response.ret = -1995
                        return response  
                    end

                    costprop = propNums
                end

                local pcfg = getConfig('prop.'..keys[2])
                local cgem = diff*pcfg.gemCost

                costGem = cgem
               
                -- 使用钻石购买
                if  not mUserinfo.useGem(cgem) then
                    response.ret = -109
                    return response
                end

            end
            
            rd = 0 -- 使用了升级符 必然成功
        end

        if method ==2 then
            if useg ~= costGem or usep~=costprop then
                response.ret = -102
                return response
            end
        end

        -- 宝石精研
        local bsjy = activity_setopt(uid,'bsjy',{act='rate'})
        if bsjy and bsjy>0 then
            rd = rd - bsjy
        end

        if rd <= jewelCfg.ratio then
            flag =  true
            mAweapon.jewelinfo1[jewel] = mAweapon.jewelinfo1[jewel] - jewelCfg.combinenum

            local  ext,result = mAweapon.addjewel(jewelCfg.combineget,1)
            if ext ~=0 then
                response.ret = ext
                return response
            end

            -- 战资比拼
            zzbpupdate(uid,{t='f14',n=1,id=jewelCfg.combineget})
  
            response.data.combine = result

            costjewel[jewel] = (costjewel[jewel] or 0) + jewelCfg.combinenum
        else
            mAweapon.jewelinfo1[jewel] =  mAweapon.jewelinfo1[jewel] - 1
            stive = math.floor(jewelCfg.stive*cfg.others.failBack)
            --合成失败 返回宝石粉尘
            mAweapon.addstive(stive)
            reward['ajewel_p1'] = stive

            costjewel[jewel] = (costjewel[jewel] or 0) + 1
        end

        if next(costjewel) then
            regKfkLogs(uid,'alienjewel',{
                    addition={
                        {desc="普通合成宝石 消耗",value=costjewel},
                    }
                }
            ) 
        end

	    -- 使用钻石购买
        if costGem >0 then
            regActionLogs(uid, 1, {action = 195, item = "", value = costGem, params = {}})
        end 

        -- 节日花朵
        activity_setopt(uid,'jrhd',{act="tk",id="hc",num=1})

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
            response.data.flag = flag -- true or false
            response.data.reward = formatReward(reward)
            response.data.alienjewel = mAweapon.formjeweldata()
        else
            response.ret = -106
        end

        return response
    end

    -- 一键合成宝石
    -- 两种合成模式 1什么都不消耗（随机概率） 2必定成功（消耗升级符 不够花钻石补充）
    function self.action_easycompose(request)
        local response = self.response
        local uid =  request.uid
        local method = request.params.method or 1 --1 不消耗 2 必定成功
        local selected = request.params.se or {} -- 选中的宝石等级 {1,2,3,4,5,6,7,8,9}
        local usep = request.params.usep or 0 -- 使用的道具
        local useg = request.params.useg or 0 -- 使用到的宝石

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        if  not uid or not next(selected) then
            response.ret = -102
            return response
        end

        for k,v in pairs(selected) do
            if not v or v<=0 then
                response.ret = -102
                return response
            end
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon","bag"})       
        local mUserinfo = uobjs.getModel('userinfo') 
        local mAweapon = uobjs.getModel('alienweapon')
        local mBag = uobjs.getModel('bag')

        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local cfg = getConfig('alienjewel')
        local propCfg = getConfig('prop')
        local usedjewel = mAweapon.usedjewel()

        local stive = 0 -- 最终获得的宝石粉尘
        local crystal = 0 -- 获得的宝石结晶
        local result = {} -- 最终合成结果

        local costGem = 0 -- 一共消耗的钻石
        local usepropsn = 0 -- 消耗的道具
        local combfaild = {} -- 合成失败的
        local combresult = {} -- 合成新的宝石
        local costjewel = {} -- 消耗的宝石
       
        local orgjewelinifo1 = copyTable(mAweapon.jewelinfo1)
        local orgjewelinifo2 = copyTable(mAweapon.jewelinfo2)
        --local c = mAweapon.getJewel2Count()
     
        table.sort(selected)

        local keys = cfg.others.upItem:split('_')   
        local pid = keys[2]
        local propNums = mBag.getPropNums(pid)
        local pcfg = propCfg[pid]
        local loopnum -- 记录递归次数
        local avoidtab = {'j9','j19','j29','j39','j49','j59'}
        local tenflag = false

        -- 宝石精研 增加合成概率
        local bsjy = activity_setopt(uid,'bsjy',{act='rate'})

        local function combine(key)
            if mAweapon.jewelinfo1[key] and mAweapon.jewelinfo1[key]>1 then
                local jewelCfg = cfg.main[key]
                local canuse = mAweapon.jewelinfo1[key]
                if usedjewel[key] then
                    canuse = canuse - usedjewel[key]
                end
                -- 可能合成下一级宝石的个数
                local cancomb = math.floor(canuse/jewelCfg.combinenum)
                if cancomb > 0 then
                    setRandSeed()
                    local rd=rand(1,100)
                    -- method =2 必定合成成功
                    local cgem = 0
                    local cprop = 0
                    if method == 2 then
                        
                        if propNums >= jewelCfg.upNum then
                            propNums = propNums - jewelCfg.upNum
                            cprop =  jewelCfg.upNum    
                        else
                            local diff = jewelCfg.upNum-propNums
                            if propNums>0 then 
                                cprop = propNums
                                propNums  = 0 
                                
                            end
                            cgem = diff*pcfg.gemCost
                            
                        end
                        
                        rd = 0 -- 使用了升级符 必然成功
                    end
                    -- 宝石精研 活动增加成功概率
                    if bsjy and bsjy>0  then
                        rd = rd - bsjy
                    end
                 
                    if rd <= jewelCfg.ratio then
                        mAweapon.jewelinfo1[key] = mAweapon.jewelinfo1[key] - jewelCfg.combinenum
                       
                        local ext,result = mAweapon.addjewel(jewelCfg.combineget,1)
                        if ext~=0 then
                            tenflag = true
                            if method==2 then
                                propNums = propNums + cprop
                            end
                            
                            return false
                        else
                            if method==2 then
                                usepropsn = usepropsn + cprop
                                costGem = costGem + cgem
                            end          
                        end
                        costjewel[key] = (costjewel[key] or 0) + jewelCfg.combinenum
                       
                    else
                        -- 如果10级宝石已满 9级宝石再次合成跳过
                        if tenflag and table.contains(avoidtab,key) then
                            return false
                        end
                        mAweapon.jewelinfo1[key] = mAweapon.jewelinfo1[key] - 1
                        combfaild[key] = (combfaild[key] or 0) + 1
                        stive =stive + math.floor(jewelCfg.stive*cfg.others.failBack)

                        costjewel[key] = (costjewel[key] or 0) + 1
                    end

                    -- 节日花朵
                    activity_setopt(uid,'jrhd',{act="tk",id="hc",num=1})
                    
                    ---防止死循环
                    if loopnum > 1000 then 
                         return false
                    end

                    combine(key) -- 每次合完 再跑一遍 确保宝石都合完
                    loopnum = loopnum + 1
                end
            end 

            return true
        end

        -- 合成逻辑
        for n=0,5 do -- 宝石种类
            local pre = 'j'
            n = n*10
            for _,lv in pairs(selected) do
                local key = pre..(lv+n)
                loopnum = 0
                combine(key)
            end
        end

        -- 一键合成 消耗钻石和道具验证
        if method == 2 then
            if usep ~= usepropsn or useg~=costGem then
                response.ret = -102
                return response
            end
        end

        if usepropsn>0 then
            if not mBag.use(pid,usepropsn) then
                response.ret = -1995
                return response 
            end
        end

        -- 使用钻石购买
        if costGem >0 then
            if not mUserinfo.useGem(costGem) then
                response.ret = -109
                return response
            end

            regActionLogs(uid, 1, {action = 195, item = "", value = costGem, params = {}})
        end 
     
        -- 合成的1-9级宝石
        for k,v in pairs(mAweapon.jewelinfo1) do
            local dif = v-(orgjewelinifo1[k] or 0)
            if dif > 0 then
                combresult[k] = dif

                -- 战资比拼
                zzbpupdate(uid,{t='f14',n=dif,id=k})
            end
        end

        -- 合成的10级宝石
        for k,v in pairs(mAweapon.jewelinfo2) do
            if not orgjewelinifo2[k] then
                combresult[k]=v

                -- 战资比拼
                zzbpupdate(uid,{t='f14',n=1,id='j10'})
            end
        end

        local reward = {}
        if stive > 0 then
            --合成失败 返回宝石粉尘
            mAweapon.addstive(stive)
            reward['ajewel_p1'] = stive
        end

        if next(costjewel) then
            regKfkLogs(uid,'alienjewel',{
                    addition={
                        {desc="一键合成宝石 消耗",value=costjewel},
                    }
                }
            ) 
        end

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave() 
        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'success'
            response.data.reward = formatReward(reward)
           
            response.data.combresult = combresult
            --response.data.combfaild = combfaild
	    response.data.combfaild = {} -- 客户端不显示失败的宝石了,只需要返回的资源
            response.data.alienjewel = mAweapon.formjeweldata()

        else
            response.ret = -106
        end

        return response
    end

    -- 分解宝石 {宝石编号:数量}
    function self.action_resolve(request)
        local response = self.response
        local uid =  request.uid
        local jewel =  request.params.j

        if type(jewel)~='table' or not uid then
            response.ret = -102
            return response
        end

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})       
        local mUserinfo = uobjs.getModel('userinfo') 
        local mAweapon = uobjs.getModel('alienweapon')
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local cfg = getConfig('alienjewel')
        local usedjewel = mAweapon.usedjewel()

        local stive = 0 -- 分解获得的宝石粉尘
        local crystal = 0 -- 分解获得宝石结晶
        local costjewel = {} -- 分解宝石记录
        for k,v in pairs(jewel) do
            local curnum = tonumber(mAweapon.jewelinfo1[k]) or 0
            
            local jewelcfg = mAweapon.getjewelCfg(k)
            local subj = string.sub(k,1,1)
            if subj == 't' then
                if not mAweapon.jewelinfo2[k] then
                    response.ret = -102
                    return response
                end

                if (tonumber(usedjewel[k]) or 0)>0 or v > 1 then
                    response.ret = -26004
                    return response
                end

                costjewel[mAweapon.jewelinfo2[k][1]] =  (costjewel[mAweapon.jewelinfo2[k][1]] or 0)+v

                mAweapon.jewelinfo2[k] = nil
            else
                if not mAweapon.jewelinfo1[k] then
                    response.ret = -102
                    return response
                end
                if mAweapon.jewelinfo1[k] - (tonumber(usedjewel[k]) or 0) < v then
                    response.ret = -26004
                    return response
                end 
                mAweapon.jewelinfo1[k] = mAweapon.jewelinfo1[k] - v

                costjewel[k] =  (costjewel[k] or 0)+v
            end

            stive = stive + jewelcfg.stive*v
            crystal = crystal + jewelcfg.crystal*v
        end

        local reward = {}

        if stive > 0 then
            mAweapon.addstive(stive)
            reward['ajewel_p1'] = stive
        end

        if crystal > 0 then
            mAweapon.addcrystal(crystal)
            reward['ajewel_p2'] = crystal
        end

        if next(costjewel) then
            regKfkLogs(uid,'alienjewel',{
                    addition={
                        {desc="分解宝石 消耗",value=costjewel},
                    }
                }
            ) 
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
            response.data.reward = formatReward(reward)
           
            response.data.alienjewel = mAweapon.formjeweldata()
        else
            response.ret = -106
        end

        return response
    end

    -- 镶嵌宝石或者更换
    function self.action_set(request)
        local response = self.response
        local uid =  request.uid
        local weapon = request.params.w
        local jewel = request.params.j

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})      
        local mUserinfo = uobjs.getModel('userinfo') 
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local mAweapon = uobjs.getModel('alienweapon')
        local ret = mAweapon.setJewel(weapon,jewel)
        if ret==0 then
            -- 更新战斗力

            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave() 
            if uobjs.save() then
                processEventsAfterSave()
                response.ret = 0
                response.msg = 'success'  
                response.data.alienjewel = mAweapon.formjeweldata()
            else
                response.ret = -106
            end

            return response
        else
            response.ret = ret
        end

        return response
    end

    -- 一键装配
    function self.action_easyset(request)
        local response = self.response
        local uid =  request.uid
        local wid = request.params.w

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        if  not uid or not wid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon","bag"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mAweapon = uobjs.getModel('alienweapon')
      

        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end



        if not table.contains(mAweapon.used,wid) then
            response.ret = -102
            return response
        end

        local ret,flag = mAweapon.easyset(wid)
        if ret ~= 0 then
            response.ret = ret
            return response
        end

        if flag then
            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave() 
            if uobjs.save() then
                processEventsAfterSave()
            else
                response.ret = -1989
                return response
            end
        end
      
        response.ret = 0
        response.msg = 'success'           
        response.data.alienjewel = mAweapon.formjeweldata()
     
        return response
    end

    -- 卸下宝石
    function self.action_demount(request)
        local response = self.response
        local uid =  request.uid
        local weapon = request.params.w
        local jewel = request.params.j

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})
        
        local mUserinfo = uobjs.getModel('userinfo') 
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local mAweapon = uobjs.getModel('alienweapon')
        if mAweapon.deJewel(weapon,jewel) then
            -- 更新战斗力

            
            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave() 
            if uobjs.save() then
                processEventsAfterSave()
                response.ret = 0
                response.msg = 'success' 

                response.data.alienjewel = mAweapon.formjeweldata()
            else
                response.ret = -106
            end

            return response
        else
            response.ret = -106
        end

        return response
    end

    -- 一键卸下
    function self.action_easydemount(request)
         local response = self.response
        local uid =  request.uid
        local weapon = request.params.w

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})
        
        local mUserinfo = uobjs.getModel('userinfo') 
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local mAweapon = uobjs.getModel('alienweapon')
        if mAweapon.easydeJewel(weapon) then
            -- 更新战斗力

            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave() 
            if uobjs.save() then
                processEventsAfterSave()
                response.ret = 0
                response.msg = 'success'  

                response.data.alienjewel = mAweapon.formjeweldata()
            else
                response.ret = -106
            end
            return response
        else
            response.ret = -106
        end

        return response
    end

    -- 初始化商店数据
    function self.action_initshop(request)
        local response = self.response
        local uid =  request.uid

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        if not uid then
            response.ret = -102
            return response
        end
     
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})
        
        local mUserinfo = uobjs.getModel('userinfo') 
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end
        local shopCfg = getConfig('alienjewel.shopList')
        local mAweapon = uobjs.getModel('alienweapon')

        local redis =  getRedis()
        local date = getDateByTimeZone(getClientTs(),'%m%d')
        local redkey = "zid."..getZoneId()..'jewel_exchange'..uid..'_'..date


        local exlog = json.decode(redis:get(redkey))
        if type(exlog)~='table'  then
            exlog = {}
        end

        local shop = {}
        for k,v in pairs(shopCfg) do
            shop[k] = exlog[k] and exlog[k] or 0
        end

        response.ret = 0
        response.msg = 'success'
        response.data.shop = shop

        return response
    end

    -- 商店兑换 item列表编号
    function self.action_exchange(request)
        local response = self.response
        local uid =  request.uid
        local item = request.params.item
        local num = request.params.num -- 购买次数
        local ty = request.params.type -- 1 宝石粉尘 2 宝石结晶 3 钻石
        local price = request.params.price

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        if not uid then
            response.ret = -102
            return response
        end
     
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})
        
        local mUserinfo = uobjs.getModel('userinfo') 
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end
        local shopCfg = getConfig('alienjewel.shopList')
        local mAweapon = uobjs.getModel('alienweapon')
        local itemCfg = shopCfg[item]

        if type(itemCfg)~='table' then
            response.ret = -102
            return response
        end

        if itemCfg.costType ~= ty then
            response.ret = -102
            return response
        end

        local redis =  getRedis()
        local date = getDateByTimeZone(getClientTs(),'%m%d')
        local redkey = "zid."..getZoneId()..'jewel_exchange'..uid..'_'..date

        local exlog = json.decode(redis:get(redkey))
        if type(exlog)~='table'  then
            exlog = {}
        end
        local curtimes = exlog[item] or 0

        -- 每天刷新 等于0无限次数 大于零有次数限制
        if itemCfg.limit>0 then
            -- 售卖类型 是否限制次数 
            if curtimes >= itemCfg.limit then
                response.ret = -26006
                return response
            end

            -- 验证可购买的数量
            if num>itemCfg.limit-curtimes then
                response.ret = -121
                return response
            end
        end

        local stive = 0
        local crystal = 0
        local gems = 0
        -- costType 1-粉尘，2-晶体，3-钻石
        if itemCfg.costType==1 then
            stive = itemCfg.price * num
        end

        if itemCfg.costType==2 then
            crystal = itemCfg.price * num
        end

        if itemCfg.costType==3 then
            gems = itemCfg.price * num
        end

        -- 消耗会根据次数有所增加
        if itemCfg.sellType == 2 then
            for i=1,num do
                local times = 0
                local cts = curtimes + i - 1
                if cts >= itemCfg.growLimit then
                    times = itemCfg.growLimit
                else
                    times = cts
                end

                local addv = itemCfg.growRate*times
                if itemCfg.costType==1 then
                    stive = stive+addv
                end

                if itemCfg.costType==2 then
                    crystal = crystal + addv
                end

                if itemCfg.costType==3 then
                    gems = gems + addv
                end    
            end
        end

        local flag = false
        -- 兑换消耗物品
        if stive > 0 then
            if stive ~= price then
                response.ret = -102
                return response
            end
            if not mAweapon.usestive(stive) then
                response.ret = -26007
                return response
            end
            flag = true
        end

        if crystal > 0 then
            if crystal ~= price then
                response.ret = -102
                return response
            end
            if not mAweapon.usecrystal(crystal) then
                response.ret = -26008
                return response
            end
            flag = true
        end 

        if gems > 0 then
            if gems ~= price then
                response.ret = -102
                return response
            end
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            flag =  true
        end

        if not flag then
            response.ret = -102
            return response
        end

        local reward = {}
        for k,v in pairs(itemCfg.serverreward) do
            reward[k] = v * num
        end

        if not takeReward(uid,reward) then
            response.ret = -106
            return response
        end

        exlog[item] = curtimes + num
        redis:set(redkey,json.encode(exlog))
        redis:expire(redkey,86400)

        if gems>0 then
            regActionLogs(uid,1,{action=194,item="",value=gems,params={reward=reward,num=num}})
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'

            response.data.alienjewel = mAweapon.formjeweldata()
            
            response.data.reward = formatReward(reward)
        else
            response.ret = -106
        end

        return response
    end

    -- 宝石数据
    function self.action_initjewel(request)
        local response = self.response
        local uid =  request.uid

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end
       
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})
        
        local mUserinfo = uobjs.getModel('userinfo') 
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local mAweapon = uobjs.getModel('alienweapon')

        response.ret = 0
        response.msg = 'success'
        response.data.alienjewel = mAweapon.formjeweldata()

        return response
    end

    -- 宝石洗练
    function self.action_succinct(request)
        local response = self.response
        local uid =  request.uid
        local jewel = request.params.j --洗练的宝石

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        if not uid or not jewel then
            response.ret = -102
            return response
        end
       
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon","bag"})
        
        local mUserinfo = uobjs.getModel('userinfo') 
        local mBag = uobjs.getModel('bag')
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local mAweapon = uobjs.getModel('alienweapon')
         local cfg = getConfig("alienjewel")
        local skillCfg = cfg.skill
        local jewelcfg = mAweapon.getjewelCfg(jewel)
         
        if type(jewelcfg)~='table' then
            response.ret = -102
            return response
        end

        if jewelcfg.level < 10 then
            response.ret = -102
            return response
        end

        local keys = cfg.others.renewItem:split('_')
        if not mBag.use(keys[2],cfg.others.renewNum) then
            response.ret = -1995
            return response
        end

        local clientTab = mAweapon.succinct(jewel)
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
            response.data.randskills = clientTab
        else
            response.ret = -106
        end   
  
        return response
    end

    -- 保存宝石洗练数据
    function self.action_saveSuccinct(request)
        local response = self.response
        local uid =  request.uid
        local jewel = request.params.j --洗练的宝石
        local sid = request.params.s -- 技能
        local val = request.params.v -- 洗出技能的值

        if moduleIsEnabled("jewelsys") ~= 1  then
            response.ret = -180
            return response
        end

        if not uid or not jewel then
            response.ret = -102
            return response
        end
       
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon","bag"})
        
        local mUserinfo = uobjs.getModel('userinfo') 
        local mBag = uobjs.getModel('bag')
        if not self.checkopen(mUserinfo.level) then
            response.ret = -180
            return response
        end

        local mAweapon = uobjs.getModel('alienweapon')
        if not mAweapon.jewelinfo2[jewel] then
            response.ret = -102
            return response
        end

        -- 验证洗练数值
        local redis = getRedis()
        local redkey = "zid."..getZoneId()..'_succinctVal_'..uid
        local succinctVal = json.decode(redis:get(redkey))
        if type(succinctVal)~='table' then
            response.ret = -102
            return response
        end

        if succinctVal.s~=sid or succinctVal.v~=val then
            response.ret = -102
            return response
        end

        mAweapon.jewelinfo2[jewel][2] = sid
        mAweapon.jewelinfo2[jewel][3] = val

        -- 如果是装配在武器上需要刷新战斗力
        local wid = nil
        for k,v in pairs(mAweapon.jewelused) do
            for _,jw in pairs(v) do
                if jw == jewel then
                    wid = k
                    break
                end
            end
        end

        if wid then
            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave()     
        end
        if uobjs.save() then
            if wid then
                processEventsAfterSave()
            end
            redis:del(redkey)
            response.ret = 0
            response.msg = 'success'
            response.data.alienjewel = mAweapon.formjeweldata()         
        else
            response.ret = -106
        end

        return response

    end

    return self
end

return api_alienweapon_jewel
