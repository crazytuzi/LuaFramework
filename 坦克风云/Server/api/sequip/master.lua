--
-- 超级装备大师
-- chenyunhe
--

local function api_sequip_master(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.before(request)
        local response = self.response
        if moduleIsEnabled('smaster') == 0 then
            response.ret = -180
            return response
        end

        if not request.uid or request.uid<=0 then
            response.ret = -102
            return response
        end
    end

    -- 装备还原 装备大师是不能还原的（代码保留）
    function self.action_reset(request)
        local response = self.response
        local uid =  request.uid
        local eid = request.params.eid -- 可能是超级装备id 也可能是装备大师id 需要做区分判断

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mSequip = uobjs.getModel('sequip')

        local restoreLevel = getConfig('sequipMaster.main.restoreLevel')  
        if restoreLevel>mUserinfo.level then
            response.ret = -180
            return response
        end


        if not mSequip.sequip[eid] then
            response.ret = -102
            return response
        end

        if not mSequip.checkFleetEquipStats(eid) then
            response.ret = -27007
            return response
        end


        local  costgem = mSequip.resetCost(eid)
        if not costgem then
            response.ret = -102
            return response
        end

        local flag,reward = mSequip.reset(eid)  
        if not flag then
            response.ret = reward
            return response
        end
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        if not mUserinfo.useGem(costgem) then
            response.ret = -109
            return response
        end

        if costgem > 0 then
            regActionLogs(uid,1,{action = 218, item = "", value = costgem, params = {}})
        end

        -- 刷新最强装备
        mSequip.updateMaxStrongEquip()

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()  
        if uobjs.save() then
            processEventsAfterSave()
            response.data.sequip = mSequip.toArray(true)
            response.data.reward = formatReward(reward)
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
            return response
        end

        return response
    end
    
    -- 洗练 基础 精英 高级 (洗出属性  临时保存，玩家决定是否执行保存操作)
    function self.action_succinct(request)
        local response = self.response
        local uid = request.uid
        local mid = request.params.mid -- 精炼装备大师id
        local xtype = 'x'..request.params.x -- 精炼类型  x1:基础 x2：精英

        if not mid or not table.contains({'x1','x2'},xtype) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mSequip = uobjs.getModel('sequip')
        if mSequip.checkmasterout(mid) then
            response.ret = -27007
            return response
        end

        -- 当天次数限制
        local weeTs = getWeeTs()
        if mSequip.xtimes.t~=weeTs then
            mSequip.xtimes.x1 = 0
            mSequip.xtimes.x2 = 0
            mSequip.xtimes.x3 = 0
            mSequip.xtimes.t = weeTs
        end

        local daylimit = getConfig('sequipMaster.main.limit')
        if mSequip.xtimes[xtype] >= daylimit[request.params.x] then
            response.ret = -27017
            return response
        end

        local ret,r,costgems = mSequip.succinctValue(mid,xtype)
        if ret ~= 0 then
            response.ret = ret
            return response
        end

	if costgems>0 then
            regActionLogs(uid,1,{action = 220, item = "", value = costgems, params = {}})
        end

        if not uobjs.save() then
            response.ret = -106
            return response
        end

        response.ret = 0
        response.msg = 'success'
        response.data.att = r
        response.data.xtimes = mSequip.xtimes
        return response 
    end

    -- 对洗练值 保存
    function self.action_upsuccinct(request)
        local response = self.response
        local uid = request.uid
        local mid = request.params.mid

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mSequip = uobjs.getModel('sequip')

        local kafkaLog = {
            {desc="装备大师洗练保存前",value=mSequip.smaster[mid][3]},
        }

        local ret = mSequip.upsuccinct(mid)
        if not ret then
            response.ret = -27008
            return response
        end

        table.insert(kafkaLog,{desc="装备大师洗练保存后",value=mSequip.smaster[mid][3]})
        
        regKfkLogs(uid,'action',{
                addition=kafkaLog
            }
        ) 


        -- 刷新最强装备
        mSequip.updateMaxStrongEquip()

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()  
        if uobjs.save() then
            processEventsAfterSave()
            response.data.sequip = mSequip.toArray(true)
           
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
            return response
        end

        return response
    end

    -- 自动洗练 
    -- upatt={0,0,0,0,0,0,0} 0未选中 1选中
    -- upatt每个位置对应指定属性 前端定好的 
    -- 对应属性： 强度 hp,dmg,accuracy,evade,crit,anticrit
    function self.action_autox(request)
        local upatt = {'strength','hp','dmg','accuracy','evade','crit','anticrit'}
        local response = self.response
        local uid = request.uid
        local mid = request.params.mid -- 精炼装备大师id
        local xtype = 'x'..request.params.x -- 精炼类型  x1:基础 x2：精英 x3：高级
        local idx = request.params.index or 1 -- 次数

        local se = request.params.se or {} -- 选择保存条件
        if #se~=7 then
            response.ret = -102
            return response
        end
        -- 格式化保存条件
        local items = {}
        for k,v in pairs(se) do
            if v==1 then
                table.insert(items,upatt[k])
            end
        end

        if not next(items) then
            response.ret = -27009
            return response
        end

        if not mid or not table.contains({'x1','x2'},xtype) or not next(items) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mSequip = uobjs.getModel('sequip')
        --检测装备大师是否被派出
        if mSequip.checkmasterout(mid) then
            response.ret = -27007
            return response
        end

        -- 当天次数限制
        local weeTs = getWeeTs()
        if mSequip.xtimes.t~=weeTs then
            mSequip.xtimes.x1 = 0
            mSequip.xtimes.x2 = 0
            mSequip.xtimes.x3 = 0
            mSequip.xtimes.t = weeTs
        end

        -- 每日上限次数
        local main = getConfig('sequipMaster.main')
        local num = main.autoLimit[idx]
    
        if not num then
            response.ret = -102
            return response
        end

        local curtimes = (mSequip.xtimes[xtype] or 0) + num
        if curtimes > main.limit[request.params.x] then
            response.ret = -27017
            return response
        end
    
        -- 检测本次洗出的属性是否满足设定的保存条件
        local selectd = #items
        local function checksave(items,xatt,selectd)
            local xn = 0
            for k,v in pairs(items) do
                if v=='strength' then
                    local curstren = mSequip.getStrength(mSequip.smaster[mid][3])
                    local newstren = mSequip.getStrength(xatt)
                    if newstren>curstren then
                        xn = xn + 1
                    end   
                else
                    if xatt[v]>(mSequip.smaster[mid][3][v] or 0) then
                        xn = xn + 1
                    end
                end        
            end
            if xn>0 and xn==selectd then
                return true
            end

            return false
        end

        -- 客户端需要的格式
        local function formatt(satt)
            local rep = {}
            -- 固定顺序不能打乱 会用到下标
            local autoAtt = {'hp','dmg','accuracy','evade','crit','anticrit'}
            for k,v in pairs(autoAtt) do
                rep[k] = satt[v] or 0
            end

            return rep
        end

        local kafkaLog = {
            {desc="装备大师洗练保存前",value=mSequip.smaster[mid][3]},
        }

        local n = 0 
        local costgems = 0
        local report = {}
        for i=1,num do
            local oridata = copyTable(mSequip.smaster[mid][3])
            local tmp = {}
            local ret,r,gem = mSequip.succinctValue(mid,xtype)
            
            costgems = costgems + (gem or 0)
            -- 这个跳出 可能是洗练属性值已经最大 
            if ret == -27016 then
                break
            end
            -- 可能消耗物品不足  程序不会继续向下执行
            if ret ~= 0 then
                response.ret = ret
                return response
            end
        
            tmp[1] = formatt(oridata)
            tmp[2] = formatt(r)
            tmp[3] = 0
            if checksave(items,r,selectd) then
                local upret = mSequip.upsuccinct(mid)
                if not upret then
                    response.ret = -106
                    return response
                end
                tmp[3] = 1
            end 
            n = n + 1
          
            table.insert(report,tmp) 
        end
       
        mSequip.smaster[mid][4] = {0,{}}
        
        if n == 0 then
            response.ret = -27016
            return response
        end

        if costgems>0 then
            regActionLogs(uid,1,{action = 220, item = "", value = costgems, params = {}})
        end

        table.insert(kafkaLog,{desc="装备大师洗练保存后",value=mSequip.smaster[mid][3]})
        regKfkLogs(uid,'action',{
                addition=kafkaLog
            }
        ) 

        -- 刷新最强装备
        mSequip.updateMaxStrongEquip()
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()  
       
        if uobjs.save() then
            processEventsAfterSave()
            response.data.n = n -- 成功洗练次数
            response.data.smaster = mSequip.smaster
            response.data.xtimes = mSequip.xtimes
            response.data.report = report
           
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
            return response
        end
        
        return response
    end

    -- 装配超级装备
    function self.action_set(request)
        local response = self.response
        local uid = request.uid
        local eid = request.params.eid -- 装配的超级武器
        local mid = request.params.mid -- 装备大师id
        local p = request.params.p --装配位置
        if not eid or not mid or not table.contains({1,2,3},p) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mSequip = uobjs.getModel('sequip')
        if mSequip.getValidEquip(eid) <= 0 then
            response.ret = -1996
            return response
        end
        -- 检测装备大师是否被派出
        if mSequip.checkmasterout(mid) then
            response.ret = -27007
            return response
        end

        if not mSequip.setMsequip(mid,eid,p) then
            response.ret = -102
            return response
        end


        -- 刷新最强装备
        mSequip.updateMaxStrongEquip()

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()  
        if uobjs.save() then
            processEventsAfterSave()
            response.data.sequip = mSequip.toArray(true)
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
            return response
        end

        return response
    end

    -- 卸下装备大师上的装备（消耗道具）
    function self.action_unset(request)
        local response = self.response
        local uid = request.uid
        local mid = request.params.mid
        local p = request.params.p

        if not mid or not table.contains({1,2,3},p) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mSequip = uobjs.getModel('sequip')
        local eid = mSequip.smaster[mid][2][p] or false
        if not eid or eid ==0 then
            response.ret = -102
            return response
        end

        -- 检测装备大师是否已派出
        if mSequip.checkmasterout(mid) then
            response.ret = -27007
            return response
        end

        if not mSequip.unsetMsequip(mid,p) then
            response.ret = -102
            return response
        end

        -- 刷新最强装备
        mSequip.updateMaxStrongEquip()
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()  
        if uobjs.save() then
            processEventsAfterSave()
            response.data.sequip = mSequip.toArray(true)
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
            return response
        end

        return response
    end

    -- 商店兑换
    function self.action_exchange(request)
        local response = self.response
        local uid = request.uid
        local item = request.params.i -- 兑换的是哪个商品
        local num = request.params.num or 1
        local weeTs = getWeeTs() 
        if not item then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mSequip = uobjs.getModel('sequip')

        local shopLevel = getConfig('sequipMaster.main.shopLevel')  
        if shopLevel>mUserinfo.level then
            response.ret = -180
            return response
        end

        local shopcfg = getConfig('sequipMaster.shopList')
        local itemCfg = shopcfg[item]
        -- 判断是否能批量购买
        if itemCfg.bulkbuy==0 and num >1 then
            response.ret = -102
            return response
        end

        -- 每天  costType>0的要重置
        local resetflag = false
        if mSequip.sshop.t ~= weeTs then
            mSequip.sshop.t = weeTs
            resetflag = true
        end
        for k,v in pairs(shopcfg) do
            if v.costType>0 and resetflag then
                mSequip.sshop[k] = 0
            end
        end

        local cost = copyTable(itemCfg.cost)
        -- 限购次数不循环（固定的）
        if itemCfg.costType == 0 then
            local buyn = mSequip.sshop[item] or 0
            if buyn+num > itemCfg.limit then
                response.ret = -1978
                return response
            end

            local cur = buyn + num
            cost = copyTable(itemCfg.cost[cur])
        elseif itemCfg.costType > 0 then
            -- 需要重置购买次数限制
            local cur = mSequip.sshop[item] or 0
            if cur+num > itemCfg.limit then
                response.ret = -1978
                return response
            end    
        else
            response.ret = -102
            return response
        end

        if type(cost)~='table' then
            response.ret = -102
            return response
        end

        -- 暂时消耗支持资源和道具 如果后期有其他的 需要再加类型检测
        for k,v in pairs(cost) do
            local cinfo = k:split('_')
            if cinfo[1] == 'userinfo' then
                local resource = {}
                resource[cinfo[2]] = v*num
                if not mUserinfo.useResource(resource) then
                    response.ret = -107
                    return response
                end
            elseif cinfo[1] == 'props' then
                 local mBag = uobjs.getModel('bag')
                 if not mBag.use(cinfo[2],v*num) then
                    response.ret = -1996
                    return response
                 end
            else
                -- 新类型 需要处理
                response.ret = -1
                return response
            end
        end

        if itemCfg.gemCost>0 then
            local gemCost = itemCfg.gemCost * num
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end

            if gemCost>0 then
                regActionLogs(uid,1,{action = 217, item = "", value = gemCost, params = {}})
            end
        end

        local reward = {}
        for k,v in pairs(itemCfg.serverreward) do
            reward[k] = v*num
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mSequip.sshop[item] = (mSequip.sshop[item] or 0) + num 
        if not uobjs.save() then
            response.ret = -106
            return response
        end

        response.ret = 0
        response.msg = 'success'
        response.data.sshop = mSequip.sshop
        response.data.smaster = mSequip.smaster

        return response
    end

    return self
end

return api_sequip_master
