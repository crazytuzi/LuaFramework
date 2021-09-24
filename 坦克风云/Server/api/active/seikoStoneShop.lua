-- 精工石限时商店
local function api_active_seikoStoneShop()
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {}
        },
        aname = 'seikoStoneShop',
    }
    -- 兑换
    function self.action_exchange(request)
        local response = self.response
        local uid = request.uid
        local itemid = request.params.itemid

        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mBag = uobjs.getModel('bag')
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.level<22 then
            response.ret = -301
            return response
        end

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local iteminfo = activeCfg['props'][itemid]
        -- 判断当前兑换配置数据
        if  type(iteminfo)~='table' then
            response.ret = -102
            return response
        end

        if type(mUseractive.info[self.aname].items) ~= 'table' then
            mUseractive.info[self.aname].items = {}
        end

        local curTimes = mUseractive.info[self.aname].items[itemid] or 0
        -- 兑换次数上限
        if curTimes>=iteminfo[6] then
            response.ret = -1987
            return response
        end

        -- 扣除道具
        if  not mBag.use(activeCfg.buyitem,iteminfo[3]) then
            response.ret = -107
            return response
        end

        mUseractive.info[self.aname].items[itemid] = curTimes + 1
        mUseractive.info[self.aname].t=ts
        local reward = iteminfo[2]
        if not takeReward(uid,reward) then
            return response
        end

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data.bag = mBag.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    return self
end

return api_active_seikoStoneShop