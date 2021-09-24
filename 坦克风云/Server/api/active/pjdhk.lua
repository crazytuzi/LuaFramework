--
-- desc: 配件大回馈
-- user: chenyunhe
--
local function api_active_pjdhk(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'pjdhk',
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
        local flag = false
        -- 消耗体力
        if not mUseractive.info[self.aname].energy then
            flag = true
            mUseractive.info[self.aname].energy = 0
        end
        -- 充值
        if not mUseractive.info[self.aname].gem then
            flag = true
            mUseractive.info[self.aname].gem = 0
        end

        local activeCfg =mUseractive.getActiveConfig(self.aname)
        -- 初始化体力领取奖励记录
        if not mUseractive.info[self.aname].elog then
            mUseractive.info[self.aname].elog = {}
            for k,v in pairs(activeCfg.serverreward.getItem) do
                table.insert(mUseractive.info[self.aname].elog,0)
            end
            flag = true
        end

        -- 初始化商店购买记录
        if not mUseractive.info[self.aname].slog then
            mUseractive.info[self.aname].slog = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].slog,0)
            end
            flag = true
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

    -- 领取消耗体力奖励
    function self.action_ereward(request)
        local response = self.response
        local uid=request.uid
        local item = request.params.item -- 领取的哪个奖励
        if not item then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if mUseractive.info[self.aname].elog[item]==1 then
            response.ret = -1976
            return response
        end

        local activeCfg =mUseractive.getActiveConfig(self.aname)
        local needenergy = 0
        local flag = false
        for k,v in pairs(activeCfg.energyNeed) do
            needenergy = needenergy + v
            if k==item then
                if mUseractive.info[self.aname].energy >= needenergy then
                    flag = true
                end
            end
        end
        if not flag then
            response.ret = -102
            return response
        end

        local rewardCfg = activeCfg.serverreward.getItem[item]
        if not rewardCfg then
            response.ret = -102
            return response
        end

        -- 获取奖励配置
        if not takeReward(uid,rewardCfg) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].elog[item]=1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(rewardCfg)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 大回馈（购买）
    function self.action_buy(request)
        local response = self.response
        local uid=request.uid
        local item = request.params.item -- 购买的哪个
        if not item then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg =mUseractive.getActiveConfig(self.aname)

        -- 判断充值开启限制
        if mUseractive.info[self.aname].gem < activeCfg.rechargeNum then
            response.ret = -102
            return response
        end

        local shopCfg = activeCfg.serverreward.shopList[item]
        if not shopCfg then
            response.ret = -102
            return response
        end

        -- 判断次数
        if mUseractive.info[self.aname].slog[item]>=shopCfg.limit then
            response.ret = -118
            return response
        end
        local gems = shopCfg.price
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        
        if gems>0 then
            regActionLogs(uid,1,{action = 242, item = "", value = gems, params = {num = 1}})
        end

        -- 获取奖励配置
        if not takeReward(uid,shopCfg.serverreward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].slog[item] = mUseractive.info[self.aname].slog[item] + 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(shopCfg.serverreward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response

    end

    return self
end

return api_active_pjdhk
