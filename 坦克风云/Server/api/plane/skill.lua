-- 技能相关接口
local function api_plane_skill()
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid = { "required" },
            },
            ["action_addbyr5"] = {
                count = { "required", "number" },
            },
            ["action_addbygold"] = {
                count = { "required", "number" },
            },
            ["action_used"] = {
                action = { "required", "number" },
                line = { "required", "number" },
                pos = { "required", "number" },
                sid = { "required", "string" },
            },
            ["action_resolve"] = {
                sid = { "string" },
                clist = { "table" },
            },
            ["action_upgrade"] = {
                slist = { "required", "table" },
                useGems = { "boolean" },
            },

        }
    end
    
    function self.before(request) 
        
    end

    -- 水晶抽取
    function self.action_addbyr5(request)
        if moduleIsEnabled('plane') == 0 then
            response.ret = -17000
            return response
        end

        local response = self.response
        local uid = request.uid
        local cnt = math.floor(request.params.count)
        local weeTs = getWeeTs()
        local ts = getClientTs()
        local planeGetCfg = getConfig('planeGetCfg')

        local uobjs = getUserObjs(uid)
        local mPlane = uobjs.getModel('plane')
        local mUserinfo = uobjs.getModel('userinfo')
        
        -- 消耗水晶
        if not mPlane.info.r5 or mPlane.info.r5[1] < weeTs then
            mPlane.info.r5 = { ts , 0 }
        end
        
        local needres = 0 -- planeGetCfg.r5Cost *cnt
        local next_cnt = mPlane.info.r5[2] + 1
        for i = next_cnt, (next_cnt + cnt - 1) do
            local idx = i
            if i > #planeGetCfg.r5Cost then
                idx = #planeGetCfg.r5Cost
            end
            
            --print(i, table.length(planeGetCfg.r5Cost), idx, needres)
            needres = needres + planeGetCfg.r5Cost[idx]
        end

        mPlane.info.r5[1] = ts
        mPlane.info.r5[2] = mPlane.info.r5[2] + cnt
        
        if not mUserinfo.useResource({ gold = needres }) then
            response.ret = -9101
            return response
        end
        -- 发奖
        local reward = self.rewardbypool(1, cnt,planeGetCfg)
        if not takeReward(uid, reward) then
            response.ret = -403
            return response
        end
        --平稳降落
        activity_setopt(uid,'safeend',{act='m1',num=cnt})

        local logparams = {r=reward,hr={}}
        --和谐版
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('funcs','plane',cnt)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data.planeRwd = hClientReward
            logparams.hr = hReward
        end  

        regEventBeforeSave(uid, 'e1')
        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()

            -- 系统功能抽奖记录
            setSysLotteryLog(uid,1,"plane.skill",cnt,logparams) 

            response.data.reward = formatReward(reward)
            response.data.plane = {}
            response.data.plane.info = mPlane.info
            response.ret = 0
            response.msg = 'Success'
        end
        
        return response
    end
    
    -- 钻石抽取
    function self.action_addbygold(request)
        if moduleIsEnabled('plane') == 0 then
            response.ret = -17000
            return response
        end

        local response = self.response
        local uid = request.uid
        local cnt = math.floor(request.params.count)
        local weeTs = getWeeTs()
        local ts = getClientTs()
        local planeGetCfg = getConfig('planeGetCfg')

        local uobjs = getUserObjs(uid)
        local mPlane = uobjs.getModel('plane')
        local mUserinfo = uobjs.getModel('userinfo')

        local poolType = 2 --金币奖池
        
        --消耗金币
        if not mPlane.info.gold then
            mPlane.info.gold = { 0, 0 }
        end
        
        if cnt == 1 then
            if not mPlane.info.gfirst then
                poolType = 3 --金币首抽奖池 
                mPlane.info.gfirst = 1
            elseif mPlane.info.gold[1] < weeTs then
                poolType = 1 --水晶奖池
            end
        end

        -- 新的一天刷新
        if mPlane.info.gold[1] < weeTs then
            mPlane.info.gold = { weeTs, 0 }
        end
        
        local gemCost, mostgemscnt = 0, 0
        local next_cnt = mPlane.info.gold[2] + 1
        for i = next_cnt, (next_cnt + cnt - 1) do
            local idx = i
            if i > #planeGetCfg.goldCost then
                idx = #planeGetCfg.goldCost
                mostgemscnt = mostgemscnt + 1
            end
            
            -- print(i, idx,  table.length(planeGetCfg.goldCost))
            gemCost = gemCost + planeGetCfg.goldCost[idx]
        end

        mPlane.info.gold[1] = ts
        mPlane.info.gold[2] = mPlane.info.gold[2] + cnt

        if not mUserinfo.useGem(gemCost) then
            response.ret = -9102
            return response
        end
        
        --发奖
        local reward = self.rewardbypool(poolType, cnt,planeGetCfg)
        if not takeReward(uid, reward) then
            response.ret = -403
            return response
        end
        --平稳降落
        activity_setopt(uid,'safeend',{act='m1',num=cnt})
        local logparams = {r=reward,hr={}}
        --和谐版
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('funcs','plane',cnt)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data.planeRwd = hClientReward
            logparams.hr = hReward
        end  
        
        if gemCost > 0 then
            regActionLogs(uid, 1, { action = 212, item = mostgemscnt, value = gemCost, params = reward })
        end

        regEventBeforeSave(uid, 'e1')
        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()
             -- 系统功能抽奖记录
            setSysLotteryLog(uid,2,"plane.skill",cnt,logparams) 
            response.data.reward = formatReward(reward)
            response.data.plane = {}
            response.data.plane.info = mPlane.info
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end
    
    -- 根据不同奖池发装备
    function self.rewardbypool(nType, cnt, planeGetCfg)
        local pool = nil

        if nType == 1 then
            pool = planeGetCfg.r5Pool
        elseif nType == 2 then
            pool = planeGetCfg.goldPool
        elseif nType == 3 then
            pool = planeGetCfg.goldPoolFirst
        end
        
        local ret = {}
        for i = 1, cnt do
            local result = getRewardByPool(pool)
            for k, v in pairs(result) do
                ret[k] = (ret[k] or 0) + v
            end
        end
        
        return ret
    end


    -- 装上和卸下技能
    function self.action_used(request)
        local response = self.response
        local uid = request.uid
        local action=tonumber(request.params.action)        --1装配 2卸下
        local line= tonumber(request.params.line)           --第几个飞机
        local pos = tonumber(request.params.pos)            --技能位置
        local sid= request.params.sid                       --技能id，有是装上，无则是卸下
        if uid==nil or action==nil or sid==nil or line==nil or pos==nil then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero","plane"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mPlane = uobjs.getModel('plane')
        local skillCfg=getConfig('planeCfg.skillCfg.'..sid)
        local oldfc = mUserinfo.fc

        if not mPlane.plane[line] or not next(mPlane.plane[line]) then
            response.ret = -102
            return response
        end
        if not skillCfg then
            response.ret = -102
            return response
        end

        local stype
        local skillType=skillCfg.skillType
        if skillType<3 then
            stype=2
        else
            stype=1
        end
        local sIdx=stype+1

        -- 装上技能
        if action==1 then
            if not mPlane.skillPosIsUnlock(line,sIdx,pos) then
                response.ret=-12111 --技能槽未解锁，技能装配失败
                return response
            end

            local canUsed,ret=mPlane.checkCanUse(sid,line,pos)
            if canUsed==false then
                response.ret=ret
                return response
            end
            if not next(mPlane.plane[line][sIdx]) then
                if stype==1 then
                    mPlane.plane[line][sIdx]={0}
                elseif stype==2 then
                    mPlane.plane[line][sIdx]={0,0,0,0}
                end
            end
            local usedSkill=mPlane.plane[line][sIdx][pos]
            if not usedSkill then
                response.ret=-102
                return response
            end
            if usedSkill~=0 and usedSkill==sid then
                response.ret=-12106
                return response
            end

            local usableNum=mPlane.getUsableNum(sid)
            if usableNum and usableNum>0 then
                usableNum=usableNum-1
                if usableNum>0 then
                    mPlane.sinfo[sid]=usableNum
                else
                    mPlane.sinfo[sid]=nil
                end
                if usedSkill and usedSkill~=0 then
                    local cfg = getConfig('planeGrowCfg.grow.'..usedSkill)
                    if not cfg then
                        response.ret=-102
                        return response
                    end
                    if not mPlane.sinfo[usedSkill] then
                        mPlane.sinfo[usedSkill]=1
                    else
                        mPlane.sinfo[usedSkill]=mPlane.sinfo[usedSkill]+1
                    end
                end
                mPlane.plane[line][sIdx][pos]=sid
            else
                response.ret=-12103
                return response
            end
        else
            if not mPlane.plane[line][sIdx] or not mPlane.plane[line][sIdx][pos] then
                response.ret = -102
                return response
            end
            local usedSid=mPlane.plane[line][sIdx][pos]
            if usedSid==0 or usedSid~=sid then
                response.ret = -102
                return response
            end
            if mPlane.sinfo[usedSid] and mPlane.sinfo[usedSid]>0 then
                mPlane.sinfo[usedSid]=mPlane.sinfo[usedSid]+1
            else
                mPlane.sinfo[usedSid]=1
            end
            mPlane.plane[line][sIdx][pos]=0
        end
        regEventBeforeSave(uid,'e1')    
        processEventsBeforeSave()
        if uobjs.save()  then 
            processEventsAfterSave()
            response.data.plane={}
            response.data.plane.sinfo =mPlane.sinfo
            response.ret = 0
            response.data.oldfc =oldfc
            response.data.newfc=mUserinfo.fc      
            response.msg = 'Success'
        end
        return response
    end

    -- 单个分解和批量分解
    function self.action_resolve(request)
        local response = self.response
        local uid = request.uid
        if uid == nil then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "plane"})
        local mPlane = uobjs.getModel('plane')
        local mUserinfo = uobjs.getModel('userinfo')

        -----------main
        local sid = request.params.sid
        local clist = request.params.clist
        local ret, code = nil, nil
        local cnt = 1
        if sid then -- 分解一个
            if mPlane.getUsableNum(sid) < cnt then
                code = -12103
            else
                ret, code = mPlane.resolveSkill(sid, cnt)
            end
        elseif clist then -- 一键分解
            ret, code,cnt = mPlane.resolveAll(clist)
        end

        if not ret then
            response.ret = code or -1
            return response
        end

        --分解道具格式化
        local award = {}
        for k, v in pairs( code ) do
            award["props_" .. k] = v
        end

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save() then 
            processEventsAfterSave()
            response.data.reward = formatReward( award )
            response.data.plane = {}
            response.data.plane.sinfo = mPlane.sinfo
            response.ret = 0        
            response.msg = 'Success'
        end

        return response
    end

    -- 技能融合(进阶)
    function self.action_upgrade(request)
        local response = self.response
        local uid = request.uid
        if uid == nil then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "plane", "bag"})
        local mPlane = uobjs.getModel('plane')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        -----------main
        local slist = request.params.slist
        local useGems = request.params.useGems

        local ret, code = self.upgradebyid(uid,slist,useGems,mPlane,mBag,mUserinfo)

        if not ret then
            response.ret = code
            return response
        end

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save() then 
            processEventsAfterSave()
            response.data.reward = formatReward( code )
            response.data.plane = {}
            response.data.plane.sinfo = mPlane.sinfo
            response.ret = 0        
            response.msg = 'Success'
        end

        return response
    end

    --根据给定技能融合(进阶)
    function self.upgradebyid(uid,slist,useGems,mPlane,mBag,mUserinfo)
        local cfg = getConfig('planeGrowCfg.grow')
        local color = nil
        local getnum = 0
        local itemlog = {} --消耗日志
        --消耗技能
        for sid, num in pairs(slist) do
            if mPlane.getUsableNum(sid) < num then
                return false, -12103
            end

            if not cfg[sid] then return false end

            -- 升级过的技能无法进阶
            if cfg[sid].lv and cfg[sid].lv > 0 then
                return false,-12107
            end
            --此技能是否能融合
            if cfg[sid].isCompose and cfg[sid].isCompose==1 then
            else
                return false,-12107
            end

            if not color then 
                color = cfg[sid].color
            elseif color and color ~= cfg[sid].color then --品阶不同
                return false, -12109
            end
            if not mPlane.consumeSkill(sid, num) then 
                return false, -12103
            end
            getnum = getnum + num
            itemlog[sid] = (itemlog[sid] or 0) + num
        end

        if not color then
            return false, -102
        end 

        local cfg = getConfig('planeGetCfg')
        if color > cfg.upgrade.maxupcolor then --最大品阶
            return false, -12108
        end
        if getnum % cfg.upgrade.planeNum ~= 0 then return false,-12103 end --整数倍
        getnum = getnum / cfg.upgrade.planeNum

        --消耗道具
        local consume = copyTab( cfg.upgrade.prop[color] )
        local gemCost = 0
        local propCfg = getConfig('prop')
        for k, v in pairs(consume) do
            consume[k] = v * getnum

            --金币补充
            local haditem = mBag.getPropNums(k)
            local costcnt = consume[k]
	     -- 战机商店  
            activity_setopt(uid,'zjsd',{type='jy',id=k,num=costcnt})

            if costcnt > haditem then
                gemCost = gemCost + propCfg[k].gemCost * ( costcnt - haditem) --不够金币补
                costcnt = haditem --扣掉所以物品
            end

            if costcnt>0 and not mBag.use(k, costcnt) then
                return false, -1996
            end

            itemlog[k] = (itemlog[k] or 0) + costcnt
        end

        -- 消耗金币
        if gemCost > 0 and (not useGems or not mUserinfo.useGem(gemCost) ) then
            return false, -9102
        end

        if gemCost > 0 then
            regActionLogs(uid,1,{action=214,item="",value=gemCost,params=itemlog })
        end

        local actskillflag = self.checkactive(slist,cfg.upgrade.planeNum)

        return mPlane.addRandSkill(color+1, getnum,actskillflag)
    end

    -- 检测合成消耗的技能是否都是主动技能
    function self.checkactive(slist,num)
        local n = 0
        local stable = {3,4}
        for sid,sv in pairs(slist) do
            local skillcfg = getConfig('planeCfg.skillCfg.'..sid)
            if skillcfg and table.contains(stable,skillcfg.skillType) then
                n = n + sv
            end
        end

        return n==num
    end

    function self.after(response)  

    end

    return self
end

return api_plane_skill