--
-- desc: 德国首冲条件礼包
-- user: chenyunhe
--
local function api_active_sctjgift(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'sctjgift',
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
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取充值奖励
    function self.action_reward(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','bag'})
        local mUseractive = uobjs.getModel('useractive')
        local mHero = uobjs.getModel('hero')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local gid = mUseractive.info[self.aname].gid or 0

        if type(mUseractive.info[self.aname].rlog)~='table' then
            mUseractive.info[self.aname].rlog = {}
        end
        
        -- 领取一个 就不能再领了
        if next(mUseractive.info[self.aname].rlog) then
            response.ret = -1976
            return response
        end
        -- 已领取
        if mUseractive.info[self.aname].r == 2 then
            response.ret = -1976
            return response
        end
        -- 未达到领取条件
        if mUseractive.info[self.aname].r ~= 1 then
            response.ret = -102
            return response
        end

        local giftCfg = copyTable(activeCfg.serverreward.gift[gid])
        if type(giftCfg)~= 'table' then
            response.ret = -102
            return response
        end
   
        if not takeReward(uid,giftCfg.gift) then    
            response.ret=-403
            return response
        end

        table.insert(mUseractive.info[self.aname].rlog,gid)
        mUseractive.info[self.aname].r = 2
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(giftCfg.gift)
            response.data.hero =mHero.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
   
    return self
end

return api_active_sctjgift
