-- 海域探索扫荡
-- chenyunhe
-- 当剩余探索次数大于等于当前章节中的关卡数时 才可以扫荡
-- 否则需要玩家购买次数

local function api_alienweapon_exraid(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    -- 扫荡
    function self.action_raid(request)
        local response = self.response
        if moduleIsEnabled('awRaid') == 0 then
            response.ret = -180
            return response
        end
        local uid = request.uid
        local useGems = request.params.useGems or false -- 是否花费钻石数
        local weeTs = getWeeTs()
        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "alienweapon"})
        local mAweapon = uobjs.getModel('alienweapon')
        local mUserinfo = uobjs.getModel("userinfo")  

        if type(mAweapon.sinfo.sea.l)~='table' then
            response.ret = -29001
            return response
        end

        local cfg = getConfig("alienWeaponSecretSeaCfg")  
        if type(mAweapon.sinfo.enum) ~= 'table' or mAweapon.sinfo.enum[3] ~= weeTs then
            mAweapon.sinfo.enum ={cfg.freeNum, 0, weeTs} -- {剩余探索次数, 购买的次数,  重置时间戳}
        end
     
        local unlockMaxChap = math.floor(mAweapon.sinfo.unlock/cfg.difficult) 
        -- 最后一关 需要特殊判断  sinfo.unlock等于最大章节后就不会向下增加了 需要根据攻打次数判断是否通关过
        if cfg.maxChapter == mAweapon.sinfo.sea.chap then
            -- 最后章节写死了 24
            if mAweapon.sinfo.psea[1]~=24 or mAweapon.sinfo.psea[2] < 3 then
                response.ret = -29002
                response.msg = 'chap unenable'
                return response
            end
        elseif mAweapon.sinfo.sea.chap > unlockMaxChap then
            response.ret = -29002
            response.msg = 'chap unenable!'
            return response
        end

        if useGems then
            local maxnum = cfg.num[mUserinfo.vip+1] -- vip1开始的购买次数
            if mAweapon.sinfo.enum[2] > maxnum then
                response.ret = -29004
                return response
            end
            mAweapon.sinfo.enum[2] = mAweapon.sinfo.enum[2] + 1 -- 购买次数累计
            local gemCost = cfg.exploreNumCost[ mAweapon.sinfo.enum[2] ]
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end

            mAweapon.sinfo.enum[1] = mAweapon.sinfo.enum[1] + cfg.buyNum -- 购买了加上次数
            -- 日志
            regActionLogs(uid,1,{action=160,item="explorenum",value=gemCost,params={}})
        end

        -- 可探岛屿的数量
        local num = 0
        for k,v in pairs(mAweapon.sinfo.sea.l) do
            if v==0 then
                num = num + 1
            end
        end

        if num == 0 then
            response.ret = -29003
            response.msg = 'no init'
            return response
        end   

        if mAweapon.sinfo.enum[1] >= num then
            mAweapon.sinfo.enum[1] = mAweapon.sinfo.enum[1] - num --扣次数
            for k,v in pairs(mAweapon.sinfo.sea.l) do
                if v == 0 then
                    mAweapon.sinfo.sea.l[k] = 1
                end
            end

            -- 引用过来的注释：发现boss (1 发现未击败，2 发现击败)
            -- 当发现BOSS时(是1),扫荡会跳过BOSS,2是已经被击杀了,所以也不算
            if mAweapon.sinfo.sea.boss == 0 then
                -- 二次授勋海域探索中攻打第7关及以上关卡15次
                uobjs.getModel('hero').refreshCurrentFeat("t14",tonumber(mAweapon.sinfo.sea.chap))
            end

            -- boss是的情况 说明有boss还没打  其他情况改成2  才能领取章节奖励
            local reward = {}
            if mAweapon.sinfo.sea.boss~=1 then
                mAweapon.sinfo.sea.boss = 2

                local rewardcfg = cfg.bossReward[tonumber(mAweapon.sinfo.sea.chap)][tonumber(mAweapon.sinfo.sea.type)]
                reward = getRewardByPool(rewardcfg)
                local normal = cfg.exp.normal[tonumber(mAweapon.sinfo.sea.type)][tonumber(mAweapon.sinfo.sea.chap)]
                reward['aweapon_exp'] = math.floor( cfg.exp.expBoss * normal)
               
            end

            -- 获得经验
            local exp = cfg.exp.normal[mAweapon.sinfo.sea.type][mAweapon.sinfo.sea.chap]
            local getexp = exp*num
            reward['aweapon_exp'] = (reward['aweapon_exp'] or 0) + getexp
            if not takeReward(uid, reward) then
                response.ret = -106
                return response
            end
            response.data.reward = formatReward(reward)

	    --日常任务
            local mDailyTask = uobjs.getModel('dailytask')
            mDailyTask.changeTaskNum1('s1013',num)
            -- 活动：异星任务
            activity_setopt(uid,'alientask',{t='y3',n=num,w=1})
            -- 跨服战资比拼
            zzbpupdate(uid,{t='f11',n=num})

            -- 国庆七天乐
            activity_setopt(uid,'nationalday2018',{act='tk',type='ts',num=num})  

            -- 感恩节拼图
            activity_setopt(uid,'gejpt',{act='tk',type='ts',num=num})
        else
            if not useGems then
                response.ret = -109
                return response
            end
          
        end
    
        if not uobjs.save() then
            response.ret = -106
            return response
        end
       
        response.data.alienweapon = {sinfo = mAweapon.sinfo}
        response.ret = 0
        response.msg = 'success'

        return response
    end
    

    return self
end

return api_alienweapon_exraid
