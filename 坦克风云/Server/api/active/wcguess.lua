--
-- desc: 球赛竞猜
-- user: chenyunhe
-- 玩家投注 没点确定 则在投注所在的赛程后 需要通过邮件返还(设置cron)
-- 玩家竞猜正确 可以通过cron 和刷新 两种方式结算
-- 注 刷新和cron如果一个执行过了并且做了处理标识 再执行就不会生效(防止重复发)
--
local function api_active_wcguess(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'wcguess',
    }

    function self.before(request)
        local response = self.response    
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if not uid then
            response.ret = -102
            return response
        end

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg =mUseractive.getActiveConfig(self.aname)

        local flag = false
        -- 初始化商店购买记录
        if not mUseractive.info[self.aname].slog then
            mUseractive.info[self.aname].slog = {}
            for k,v in pairs(activeCfg.serverreward.shop) do
                mUseractive.info[self.aname].slog[k] = 0
            end
            flag = true
        end
        
        -- 每个赛程 投注数据
        if not mUseractive.info[self.aname].se then
            mUseractive.info[self.aname].se = {} -- 下注数据
            mUseractive.info[self.aname].r = {}  -- 赛程领取奖励
            mUseractive.info[self.aname].con = {} -- 各赛程确定下注标识 
            mUseractive.info[self.aname].cr = {} -- 每个赛程cronid --用来定时发奖挥或者退回投注
            for k,v in pairs(activeCfg.stage) do
                table.insert(mUseractive.info[self.aname].se,{}) --{队1编号:投注数,...}
                table.insert(mUseractive.info[self.aname].r,0) --赛程奖励领取,或者退回记录
                table.insert(mUseractive.info[self.aname].con,0)
                table.insert(mUseractive.info[self.aname].cr,0)
            end
            flag = true
        end

        -- 猜中的次数
        if not mUseractive.info[self.aname].gt then
            mUseractive.info[self.aname].gt = 0
            flag = true
        end
     
        -- 更新玩家 竞猜正确次数 用来开启可购买的商品
        local f,times = self.binggo(activeCfg,mUseractive.info[self.aname].se,mUseractive.info[self.aname].gt)
        if f then
            flag = true
            mUseractive.info[self.aname].gt = times
        end

        -- 已经结束 未结算的或者退还的 要检测处理下
        local cflag = self.check(uid,activeCfg)
        if cflag then 
            flag=true 
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 兑换球票
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local costgem = request.params.num -- 兑换消耗的钻石
        if not costgem or costgem<=0 then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        local activeCfg =mUseractive.getActiveConfig(self.aname)
        local ts = getClientTs()
        local stagenum = #activeCfg.stage

	-- 下注时间外不能兑换球票
        if ts>activeCfg.time then
            response.ret = -27024
            return response
        end
     

        if not mUserinfo.useGem(costgem) then
            response.ret = -109
            return response
        end

        local piao = costgem * activeCfg.ratio
        if costgem >0 then
            regActionLogs(uid,1,{action = 243, item = "", value = costgem, params = {}})
        end

        if not mBag.add(activeCfg.id,piao) then
            response.ret = -106
            return response
        end

        local reward = {}
        reward['props_'..activeCfg.id] = piao

        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data.bag = mBag.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 商店 如果球票数量不足 玩家可以用钻石补充 
    function self.action_shop(request)
        local response = self.response
        local uid=request.uid
        local item = request.params.item -- 购买的哪个
        local num = request.params.num -- 兑换的个数
        local cost = request.params.cost -- 补充消耗的钻石
        local flag = request.params.f -- 0不用钻石补充 1补充
        if not item or num<=0 then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        local activeCfg =mUseractive.getActiveConfig(self.aname)

        local shopCfg = activeCfg.serverreward.shop[item]
        if not shopCfg then
            response.ret = -102
            return response
        end

        -- 判断购买资格（猜对几次）
        if mUseractive.info[self.aname].gt < shopCfg.con then
            response.ret = -27025
            return response
        end

        local cur = mUseractive.info[self.aname].slog[item] or 0
        -- 判断次数
        if cur >= shopCfg.bn then
            response.ret = -118
            return response
        end

        local canbuy = shopCfg.bn - cur
        if num>canbuy then
            response.ret = -118
            return response
        end

        local propNums = mBag.getPropNums(activeCfg.id)
        local costp = shopCfg.p * num
        local costprop = 0
        if propNums < costp then
            if cost>0 then
                local needp = costp - propNums
                costgem =  needp/activeCfg.ratio
                if cost ~= costgem then
                    response.ret = -102
                    return response
                end

                if not mUserinfo.useGem(costgem) then
                    response.ret = -109
                    return response
                end
                regActionLogs(uid,1,{action = 243, item = "", value = costgem, params = {}}) 

                costprop = propNums
            else
                response.ret = -109
                return response
            end
        else
            costprop = costp
        end

        if costprop>0 then
            if not mBag.use(activeCfg.id,costprop) then
                response.ret = -106
                return response
            end
        end

        local reward = {}
        for k,v in pairs(shopCfg.sr) do
            reward[k] = v * num
        end

        -- 获取奖励配置
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].slog[item] = (mUseractive.info[self.aname].slog[item] or 0) + num
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 投注 
    function self.action_select(request)
        local response = self.response
        local uid=request.uid
        local tid = request.params.tid -- 选择的队
        local p = request.params.p     -- 下注的球票数
        local stage = request.params.stage -- 哪个阶段

        if not tid or p<=0 then
            response.ret = -102
            return response
        end
        
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        local activeCfg =mUseractive.getActiveConfig(self.aname)

        -- 确认了 不能操作
        if mUseractive.info[self.aname].con[stage] == 1 then
            response.ret = -27023
            return response
        end
        -- 最小投注数
        if p<activeCfg.minMoney  then
            response.ret = -27022
            return response
        end

        local stageCfg = activeCfg.stage[stage]
        if type(stageCfg)~='table' then
            response.ret = -102
            return response
        end

        -- 当前的赛程不能投注了
        if ts>activeCfg.time then
            response.ret = -27024
            return response
        end

        local snum = stageCfg[2]
        if not table.contains(activeCfg.winteam[1].t,tid) then
            response.ret = -102
            return response
        end

        local propNums = mBag.getPropNums(activeCfg.id)
        if propNums < p then
            response.ret = -1996
            return response
        end

        -- 已经选了投注队的个数上限  再选其他的 不能投注
        local teams = {}
        for k,v in pairs(mUseractive.info[self.aname].se[stage]) do
            table.insert(teams,k)
        end
        if #teams==snum and not table.contains(teams,tid) then
            response.ret = -102
            return response
        end

        if not mBag.use(activeCfg.id,p) then
            response.ret = -102
            return response
        end

        --TODO
        --[[
         -- mUseractive.info[self.aname].cr[stage]=0
         -- mUseractive.info[self.aname].con[stage]=0
         -- mUseractive.info[self.aname].r[stage]=0
        ]]

        -- 记录cronid 生成了标识 
        if mUseractive.info[self.aname].cr[stage]==0 then
            local et = mUseractive.info[self.aname].et
            local diftime = stageCfg[1] - ts       
            local cronParams = {cmd="active.wcguess.sendmail",uid=uid,params={stage=stage,et=et}}
            --local exc,cronid = setGameCron(cronParams,10)-- 给没点确定的玩家返回下注道具
            local exc,cronid = setGameCron(cronParams,diftime)-- 给没点确定的玩家返回下注道具
            if not exc or not cronid then
                response.ret = -1989
                return response
            else
                mUseractive.info[self.aname].cr[stage] = cronid
            end
        end 

        mUseractive.info[self.aname].se[stage][tid] = (mUseractive.info[self.aname].se[stage][tid] or 0)+p  
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.bag = mBag.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- cron发奖
    function self.action_sendmail(request)
        local response = self.response
        local ts = getClientTs()
        
        if ts > request.params.et then
            response.ret = -102
            return response
        end
        --writeLog('params='..json.encode(request),'wcguess')
    
        local uid=request.uid
        local stage = request.params.stage -- 哪个阶段

        if not stage then
            response.ret = -102
            return response
        end
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        
        -- 校验一下数据
        local activeCfg =mUseractive.getActiveConfig(self.aname)
        local timeCfg = activeCfg.stage[stage]
        -- 判断能否领取
        if type(timeCfg)~='table' then
            response.ret = -102
            return response
        end
        -- 没数据
        if type(mUseractive.info[self.aname].se[stage])~='table' or not next(mUseractive.info[self.aname].se[stage]) then
            response.ret = -102
            return response
        end

        -- 处理过了
        if mUseractive.info[self.aname].r[stage]==1 then
            response.ret = -1976
            return response
        end
        
        -- 没确认
        if mUseractive.info[self.aname].con[stage] ~=1 then
            -- 返还
            local returnp = 0
            for k,v in pairs(mUseractive.info[self.aname].se[stage]) do
                local nu = tonumber(v)
                if nu>0 then
                    returnp = returnp + nu
                end
            end

            if returnp>0 then
                local reward = {}
                reward['props_'..activeCfg.id] = returnp
                --reward={h={props_p588=2,props_p230=1,props_p4917=2,props_p881=100},q={p={{p588=2,index=1},{p230=1,index=2},{p4917=2,index=3},{p881=100,index=4}}}},
                local content = {h=reward,q=formatReward(reward)}
                -- 给玩家发邮件
                local ret = MAIL:mailSent(uid,0,uid,mUserinfo.nickname,'','世界杯竞猜','世界杯竞猜返还',1,0,10,content)
            end
            mUseractive.info[self.aname].se[stage] = {}
            mUseractive.info[self.aname].r[stage] = 1
        else
            -- 统计押注成功的球队
            local gr = nil -- 结果
            local winteam = activeCfg.winteam[stage].r
            if type(winteam)~='table' or not next(winteam) then
                response.ret = -102
                return response
            end

            
            for w,wid in pairs(winteam) do
                local tname = activeCfg.serverreward.guess[wid].name
                if not gr then
                    gr = tname
                else
                    gr = gr..','..tname
                end
            end
             
            local gr1 = ''
            local returnp = 0
            for k,v in pairs(mUseractive.info[self.aname].se[stage]) do
                if table.contains(winteam,k) then
                    local times = activeCfg.serverreward.guess[k].odds[stage]
                    local tname =activeCfg.serverreward.guess[k].name
                    if gr1=='' then
                        gr1 = tname
                    else
                        gr1 = gr1..','..tname
                    end
                   
                    returnp = returnp + math.floor(v*times)
                end
            end
            gr = gr..'_'..gr1
            local reward = {}
            local content = {}
            local isreward = 1
            reward['props_'..activeCfg.id] = returnp
            if returnp>0 then
                content = {h=reward,q=formatReward(reward)}
                isreward= 0
            end
            -- 此处发邮件
            local ret = MAIL:mailSent(uid,0,uid,mUserinfo.nickname,'',gr,gr,1,0,11,content)
            if ret and  isreward==1  then
                local eid = ret.eid
                MAIL:mailReward(uid,eid)
            end
            mUseractive.info[self.aname].r[stage] = 1 
        end
        
        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 刷新检查结算（
    -- 万一sendmail 定时没跑 或者 在定时脚本之后才把 配置上传更新完  
    -- 没给玩家发奖励或者退回投注
    --）MAIL:mailSent(uid,0,uid,'','',title,content,1,0,2,item)
    function self.check(uid,cfg)
        local flag = false
        local stages = {}
        local ts = getClientTs()
        for k,v in pairs(cfg.stage) do
            if ts>v[1] then
                table.insert(stages,k)
            end
        end
        
        if not next(stages) then
            return false
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 校验一下数据
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        for k,v in pairs(stages) do
            local gid = v
            -- 没发奖励
            if mUseractive.info[self.aname].r[gid]==0 then
                if type(mUseractive.info[self.aname].se[gid])=='table' and next(mUseractive.info[self.aname].se[gid]) then
                    -- 没确认
                    if mUseractive.info[self.aname].con[gid] ~=1 then
                        -- 返回
                        local returnp = 0
                        for sk,sv in pairs(mUseractive.info[self.aname].se[gid]) do
                            local nu = tonumber(sv)
                            if nu>0 then
                                returnp = returnp + nu
                            end
                        end

                        if returnp>0 then
                            local reward = {}
                            reward['props_'..activeCfg.id] = returnp
                            --reward={h={props_p588=2,props_p230=1,props_p4917=2,props_p881=100},q={p={{p588=2,index=1},{p230=1,index=2},{p4917=2,index=3},{p881=100,index=4}}}},
                            local content = {h=reward,q=formatReward(reward)}
                            -- 给玩家发邮件
                            local ret = MAIL:mailSent(uid,0,uid,mUserinfo.nickname,'','世界杯竞猜','世界杯竞猜返还',1,0,10,content)
                            --MAIL:mailSent(uid,0,uid,'','',title,content,1,0,2,item)
                        end
                        mUseractive.info[self.aname].se[gid] = {}
                        mUseractive.info[self.aname].r[gid] = 1
                    else
                        -- 统计押注成功的球队
                        local gr = nil -- 结果
                        local winteam = activeCfg.winteam[gid].r
                        if type(winteam)=='table' and next(winteam) then
                            for w,wid in pairs(winteam) do
                                local tname = activeCfg.serverreward.guess[wid].name
                                if not gr then
                                    gr = tname
                                else
                                    gr = gr..','..tname
                                end
                            end
                           
                            local gr1 = ''
                            local returnp = 0
                            for sk,sv in pairs(mUseractive.info[self.aname].se[gid]) do
                                if table.contains(winteam,sk) then
                                    local times = activeCfg.serverreward.guess[sk].odds[gid]
                                    local tname =activeCfg.serverreward.guess[sk].name
                                    if gr1=='' then
                                        gr1 = tname
                                    else
                                        gr1 = gr1..','..tname
                                    end
                                    returnp = returnp + math.floor(sv*times)
                                end
                            end

                            gr = gr..'_'..gr1
                            local reward = {}
                            local content = {}
                            local isreward = 1--没奖励的 直接给设置成已领取
                            reward['props_'..activeCfg.id] = returnp
                            if returnp>0 then
                                content = {h=reward,q=formatReward(reward)}
                                isreward = 0
                            end

                            -- 此处发邮件
                            local ret = MAIL:mailSent(uid,0,uid,mUserinfo.nickname,'',gr,gr,1,0,11,content)
                            if ret and  isreward==1  then
                                local eid = ret.eid
                                MAIL:mailReward(uid,eid)
                            end
                            mUseractive.info[self.aname].r[gid] = 1
                        end
                    end
                end 
                flag = true
            end   
        end      
        
        return flag
    end

    -- 取消投注
    function self.action_cancel(request)
        local response = self.response
        local uid=request.uid
        local tid = request.params.tid -- 选择的队
        local stage = request.params.stage -- 哪个阶段

        if not tid then
            response.ret = -102
            return response
        end
        
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        local activeCfg =mUseractive.getActiveConfig(self.aname)
        local stageCfg = activeCfg.stage[stage]
        if type(stageCfg)~='table' then
            response.ret = -102
            return response
        end
        -- 确认了 不能取消
        if mUseractive.info[self.aname].con[stage] == 1 then
            response.ret = -27023
            return response
        end

        -- 时间不在该赛程范围内,不能取消
        if ts>activeCfg.time then
            response.ret = -27024
            return response
        end

        -- 已经选了投注队的个数 再选其他的 不能投注
        local teams = {}
        for k,v in pairs(mUseractive.info[self.aname].se[stage]) do
            table.insert(teams,k)
        end
    
        if not table.contains(teams,tid) then
            response.ret = -102
            return response
        end
        
        local returnp = mUseractive.info[self.aname].se[stage][tid] or 0
        if not mBag.add(activeCfg.id,returnp) then
            response.ret = -102
            return response
        end
        local reward = {}
        reward['props_'..activeCfg.id] = returnp
        mUseractive.info[self.aname].se[stage][tid] = nil
        
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.bag = mBag.toArray(true)
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 竞猜正确的次数 用来开启可购买的商品
    function self.binggo(cfg,guess,gt)
        if type(guess)~='table' or not next(guess) then
            return false,0
        end

        local times = 0
        local ts = getClientTs()
        for k,v in pairs(cfg.stage) do
            if ts>=v[2] then
                local winteam = cfg.winteam[k].r
                for g,gv in pairs(guess[k]) do
                    if table.contains(winteam,g) then
                        times = times + 1
                    end
                end
            end
        end

        if times>gt then
            return true,times
        end

        return false,gt
    end

    -- 下注确定 不确定的话 不能计算有效下注数据 且要返回
    function self.action_confirm(request)
        local response = self.response
        local uid=request.uid
        local stage = request.params.stage -- 哪个阶段
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        local activeCfg =mUseractive.getActiveConfig(self.aname)       
        -- 时间不在赛程范围内  不能确定
        if ts>activeCfg.time then
            response.ret = -27024
            return response
        end
        -- 没下注
        if not mUseractive.info[self.aname].se[stage] then
            response.ret = -102
            return response
        end
        -- 确认过了
        if mUseractive.info[self.aname].con[stage] == 1 then
            response.ret = -27023
            return response
        end

        mUseractive.info[self.aname].con[stage] = 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end
    return self
end

return api_active_wcguess
