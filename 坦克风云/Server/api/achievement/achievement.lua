local function api_achievement_achievement(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },

            ["action_reward"] = {
                aid = {"required","string"},
                atype = {"required","number"},
            },

            ["action_cup"] = {
                aid = {"required","string"},
                action = {"required","number"},
            },

        }
    end

    function self.before(request) 
        -- 开关未开启
        if not switchIsEnabled('avt') then
            self.response.ret = -9000
            return self.response
        end
    end

    --[[
        获取数据
    ]]
    function self.action_get(request)
        local response = self.response
        local uid = request.uid

        local uobjs = getUserObjs(uid)
        local mAchievement = uobjs.getModel("achievement")
        local allInfo = getAllAchievement()

        response.data.achievement = mAchievement.toArray()
        response.data.achievementAll = allInfo or {}

        response.data.ranking = 0

        local list = getAchievementRankingList()
        for k,v in pairs(list) do
            local mid = tonumber(v[2])
            if mid == uid then
                response.data.ranking = k
            end
        end

        response.ret = 0
        response.msg = 'Success'

        return response
    end

    --[[
        领取奖励
        atype:类型 1是个人成就，2是全服成就
        aid:成就id
    ]]
    function self.action_reward(request)
        local response = self.response
        local uid = request.uid
        local atype = request.params.atype
        local aid = request.params.aid

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        local mAchievement = uobjs.getModel("achievement")
        local ts = getClientTs()

        if not aid or not atype then
            response.ret = -102
            return response
        end

        local achievementlog = {}
        local addInfo = {}
        local achievementCfg = getConfig("achievement")
        if atype == 1 then
            local hasRewardNum,rewardNum = 0,0
            local num = mAchievement.uinfo[aid] or 0
            if achievementCfg.person[aid] then
                local cfg = achievementCfg.person[aid]
                if achievementCfg.unlock and achievementCfg.unlock[cfg.type] and mAchievement.level < achievementCfg.unlock[cfg.type] then
                    response.ret = -1981
                    return response
                end

                if not mAchievement.reward.p then
                    mAchievement.reward.p = {}
                end
                if not mAchievement.reward.p[aid] then
                    mAchievement.reward.p[aid] = {}
                end

                local allInfo = getAllAchievement(aid)
                for k,v in pairs(cfg.needNum) do
                    if not mAchievement.reward.p[aid][k] then
                        mAchievement.reward.p[aid][k] = 0
                    end
                    if mAchievement.reward.p[aid][k] > 0 then
                        hasRewardNum = hasRewardNum + 1
                    elseif num >= v then
                        local reward = cfg.serverReward[k]
                        if not takeReward(uid,reward) then        
                            response.ret = -403 
                            return response
                        end

                        mAchievement.reward.p[aid][k] = ts
                        rewardNum = rewardNum + 1
                        local level = cfg.addLevel[k] or 0
                        mAchievement.level = (mAchievement.level or 0) + level
                        addInfo[tostring(k)] = 1

                        if k == #cfg.needNum then
                            local rank = 0
                            if allInfo and allInfo[k] then
                                rank = allInfo[k]
                            end
                            if rank and rank < achievementCfg.rank then
                                if not mAchievement.info.rank then
                                    mAchievement.info.rank = {}
                                end
                                mAchievement.info.rank[aid] = {rank + 1,getZoneId()}
                                achievementlog = {aid=aid,rank=rank+1,zid=getZoneId(),uid=uid,name=mUserinfo.nickname,ts=ts}
                            end
                        end
                    end
                end

                if hasRewardNum >= #cfg.needNum then
                    response.ret = -1976
                    return response
                end
            end

            if rewardNum <= 0 then
                response.ret = -1981
                return response
            end

        elseif atype == 2 then
            local hasRewardNum,rewardTotal,rewardNum,index = 0,0,0,{}
            local allInfo = getAllAchievement(aid)
            if achievementCfg.all[aid] then
                local cfg = achievementCfg.all[aid]
                if achievementCfg.unlock and achievementCfg.unlock[cfg.type] and mAchievement.level < achievementCfg.unlock[cfg.type] then
                    response.ret = -1981
                    return response
                end

                if not mAchievement.reward.a then
                    mAchievement.reward.a = {}
                end
                if not mAchievement.reward.a[aid] then
                    mAchievement.reward.a[aid] = {}
                end

                for k,v in pairs(cfg.num) do
                    local num = 0
                    if allInfo and allInfo[k] then
                        num = allInfo[k]
                    end
                    if not mAchievement.reward.a[aid][k] then
                        mAchievement.reward.a[aid][k] = {}
                    end
                    local rewardCfg = cfg.serverReward[k] or {}
                    local levelCfg = cfg.addLevel[k] or {}
                    for kk,vv in pairs(v) do
                        rewardTotal = rewardTotal + 1
                        if not mAchievement.reward.a[aid][k][kk] then
                            mAchievement.reward.a[aid][k][kk] = 0
                        end
                        if mAchievement.reward.a[aid][k][kk] > 0 then
                            hasRewardNum = hasRewardNum + 1
                        elseif num >= vv then
                            local reward = rewardCfg[kk] or {}
                            if not takeReward(uid,reward) then        
                                response.ret = -403 
                                return response
                            end

                            mAchievement.reward.a[aid][k][kk] = ts
                            rewardNum = rewardNum + 1
                            local level = levelCfg[kk] or 0
                            mAchievement.level = (mAchievement.level or 0) + level
                            index = {k,kk}
                        end
                    end
                end

                if hasRewardNum >= rewardTotal then
                    response.ret = -1976
                    return response
                end
            end

            if rewardNum <= 0 then
                response.ret = -1981
                return response
            end

            if next(index) then
                if not mAchievement.info.cup then
                    mAchievement.info.cup = {}
                end
                if not mAchievement.info.cup.a then
                    mAchievement.info.cup.a = {}
                end
                if not mAchievement.info.cup.a[aid] then
                    mAchievement.info.cup.a[aid] = index
                end
            end
        end

        -- 计算
        mAchievement.countAchievement()

        if next(addInfo) then
            local db = getDbo()
            db.conn:setautocommit(false)

            if uobjs.save() and setAllAchievement(aid,addInfo) and db.conn:commit() then
                local allInfo = getAllAchievement()
                response.data.achievementAll = allInfo or {}
                response.data.achievement = mAchievement.toArray()
                response.ret = 0
                response.msg = 'Success'

                if next(achievementlog) then
                    writeLog(achievementlog,'achievementlog')
                end
            end

            db.conn:setautocommit(true)
        else
            if uobjs.save() then
                response.data.achievement = mAchievement.toArray()
                response.ret = 0
                response.msg = 'Success'
            end
        end

        return response
    end

    
    --[[
        选择奖杯:
        action:类型 1模块 2各模块里面全服成就
        aid:成就id
        stype:1个人,2全服(type==1时)
        index:全服成就类别索引(type==2时)
    ]]
    function self.action_cup(request)
        local response = self.response
        local uid = request.uid
        local action = request.params.action
        local aid = request.params.aid
        local stype = request.params.stype
        local index = request.params.index

        local uobjs = getUserObjs(uid)
        local mAchievement = uobjs.getModel("achievement")
        local ts = getClientTs()

        if not action or not aid then
            response.ret = -102
            return response
        end

        if not mAchievement.info.cup then
            mAchievement.info.cup = {}
        end

        if action == 1 then
            if not mAchievement.info.cup.t then
                mAchievement.info.cup.t = {}
            end

            local achievementCfg = getConfig("achievement")
            if stype == 1 and achievementCfg.person[aid] then
                local cfg = achievementCfg.person[aid]
                if cfg and cfg.type then
                    mAchievement.info.cup.t[cfg.type] = {stype,aid}
                end
            elseif stype == 2 and achievementCfg.all[aid] then
                local cfg = achievementCfg.all[aid]
                if cfg and cfg.type then
                    mAchievement.info.cup.t[cfg.type] = {stype,aid}
                end
            else
                response.ret = -102
                return response 
            end

        elseif action == 2 then
            local achievementCfg = getConfig("achievement")
            if not index or not achievementCfg.all[aid] then
                response.ret = -102
                return response
            end

            if index[1] and index[2] and achievementCfg.all[aid].num[index[1]] and achievementCfg.all[aid].num[index[1]][index[2]] then
            else
                response.ret = -102
                return response
            end

            if mAchievement.reward.a and mAchievement.reward.a[aid] and mAchievement.reward.a[aid][index[1]] and mAchievement.reward.a[aid][index[1]][index[2]] then
            else
                response.ret = -1981
                return response
            end

            if not mAchievement.info.cup.a then
                mAchievement.info.cup.a = {}
            end
            mAchievement.info.cup.a[aid] = index
        end

        if uobjs.save() then
            response.data.achievement = mAchievement.toArray()
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 点赞
    function self.action_like(request)
        local response = self.response
        local uid = request.uid

        local likeUid = request.params.likeUid
        local uobjs = getUserObjs(likeUid)
        local mAchievement = uobjs.getModel("achievement")

        if not mAchievement.hasLiked(likeUid,uid) then
            mAchievement.like()
            if not mAchievement.setLikedRecord(uid,likeUid,1) then
                response.ret = 0
                response.msg = 'Success'
                return response
            end
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        end
        
        return response
    end

    -- 取消点赞
    function self.action_unlike(request)
        local response = self.response
        local uid = request.uid

        local likeUid = request.params.likeUid
        local uobjs = getUserObjs(likeUid)
        local mAchievement = uobjs.getModel("achievement")

        if mAchievement.hasLiked(likeUid,uid) then
            mAchievement.unlike()
            if mAchievement.setLikedRecord(uid,likeUid,0) and uobjs.save() then
                response.ret = 0
                response.msg = 'Success'
            end
        end

        return response
    end

    -- 获取排行榜
    function self.action_rankingList(request)
        local response = self.response
        local uid = request.uid
        local list = getAchievementRankingList()
        local achvids = {}

        for k,v in pairs(list) do
            local mid = v[2]
            if mid and mid > 0 then
                v[1] = getUserObjs(mid,true).getModel('achievement').getLiked()
                table.insert(achvids,mid)
            end
        end

        local myliked = {}
        if next(achvids) then
            local achvidStr = table.concat(achvids,',')
            local sql = string.format("select achvid from user_like_achievement where uid = %d and achvid in (%s)",uid,achvidStr)            
            for k,v in pairs(getDbo():getAllRows(sql)) do
                table.insert(myliked,tonumber(v.achvid))
            end
        end

        response.data = {
            list = list,
            myliked = myliked
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_hasLiked(request)
        local response = self.response
        local likeUid = request.params.likeUid
        local uid = request.uid
        
        local mAchievement = getUserObjs(likeUid,true).getModel("achievement") 
        response.data.hasLiked = mAchievement.hasLiked(likeUid,uid) and true or false
        response.data.liked = mAchievement.getLiked()

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    return self
end

return api_achievement_achievement