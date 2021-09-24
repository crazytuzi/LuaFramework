-- 补给舰 补给品相关api

--[[
    补给品作用：
    放大补给舰属性：补给品为补给舰中自产的可使用道具，使用后可在有效时间内放大补给舰所加成的属性；
    每条补给品属性，放大倍数随机；
    获得战斗技能：中级以上的补给品，生产时随机获得一个技能，该技能仅在战斗中生效；
    使用补给品不增加战斗力；

    补给品有重量；不可堆叠；可分解；
]]
local function api_tender_supply(request)
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

            ["action_speedUp"] = {
                idx = {"required","number"},
                cost = {"required","number",{"min",1}},
            },

            ["action_speedUpByItem"] = {
                item = {"required","string"},
            },

            ["action_produce"] = {
                quality = {"required","string"},
            },

            ["action_use"] = {
                idx = {"required","number"},
                quality = {"required","string"},
            },

            ["action_cancel"] = {
                idx = {"required","number"},
            },

            ["action_decompose"] = {
                idx = {"required","number"},
                quality = {"required","string"},
            },

        }
    end

    function self.before(request) 
        -- 开关未开启
        if not switchIsEnabled('tender') then
            self.response.ret = -102
            return self.response
        end
    end

    --[[
        生产补给品
             补给品生产；
             每次仅能生产1个补给品；
             补给品队列最大数量4；
             补给品生产时间：7*24小时；
             可使用钻石加速，直接完成生产；
    ]]
    function self.action_produce(request)
        local response = self.response
        local quality = request.params.quality

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeName = request.params.acName
        if activeName then
            local mUseractive = uobjs.getModel('useractive')
            local activStatus = mUseractive.getActiveStatus(activeName)

            -- 活动检测
            if activStatus ~= 1 then
                response.ret = activStatus
                return response
            end

            local activeCfg = mUseractive.getActiveConfig(activeName)
            if not activeCfg._ModelTenderCompose then
                response.ret = -102
                response.err = "_ModelTenderCompose is nil"
                return response
            end

            if not table.contains(activeCfg._ModelTenderCompose,quality) then
                response.ret = -102
                response.err = "quality invalid"
                return response
            end
        end

        local tenderSkillCfg = getConfig("tenderSkill")
        if not tenderSkillCfg.compose[quality] then
            response.ret = -102
            response.err = "quality invalid"
            return response
        end

        -- 活动配方
        if tenderSkillCfg.compose[quality].composeType >= 11 and not activeName then
            response.ret = -102
            response.err = "activeName is nil"
            return response
        end

        -- 解锁需要的强化阶数，没有则跟建筑一起解锁 || 应客户端要求，取消验证(0级也能生产 ——_——!)
        -- if mTender.getLevel() < 1 then
        --     response.ret = -28011
        --     response.err = "tender is not unlock"
        --     return response
        -- end

        -- 强化等级验证
        if tenderSkillCfg.compose[quality].unlockNeed then
            if mTender.getEnhancelvl() < tenderSkillCfg.compose[quality].unlockNeed then
                response.ret = -28011
                return response
            end
        end

        -- 生产队列已满，不能生产
        if mTender.productionQueueIsFull() then
            response.ret = -28012
            return response
        end

        -- 消耗资源
        -- 注意这里不能做打折活动,取消生产会全额返回资源
        local resourceCost = tenderSkillCfg.compose[quality].cost1
        if not mUserinfo.useResource(resourceCost) then
            response.ret = -107
            return response
        end

        -- 消耗材料
        local materialCost = tenderSkillCfg.compose[quality].cost2
        local ok,id = mTender.useMaterial(materialCost)
        if not ok then
            response.ret = -28006
            response.itemId = id
            return response
        end

        mTender.productionQueueAdd(quality,tenderSkillCfg.compose[quality].lastTime)

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.data.userinfo = mUserinfo.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end
        
        return response
    end

    -- 取消生产
    function self.action_cancel(request)
        local response = self.response
        local idx = request.params.idx

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')
        local mUserinfo = uobjs.getModel('userinfo')

        local ts = getClientTs()
        local tenderSkillCfg = getConfig("tenderSkill")
        local productionInfo = mTender.productionQueueGet(idx)
        if not productionInfo then
            response.ret = -102
            response.err = "not found production info"
            return response
        end

        -- 已生产完成
        if productionInfo[2] and productionInfo[2] < ts then
            response.ret = -102
            response.et = productionInfo[2]
            return response
        end

        local quality = productionInfo[1]
        local rate = tenderSkillCfg.compose[quality].cancelBack
        if rate > 1 then rate = 1 end

        -- 返还资源
        local resourceCost = {}
        for k,v in pairs(tenderSkillCfg.compose[quality].cost1) do
            local n = math.floor(v * rate)
            assert(n <= v,"resource error")

            if n > 0 then
                resourceCost[k] = n
            end
        end

        if next(resourceCost) then
            if not mUserinfo.addResource(resourceCost) then
                response.ret = -1991
                return response
            end
        end

        local materialCost = {}
        for k,v in pairs(tenderSkillCfg.compose[quality].cost2) do
            local n = math.floor(v * rate)
            if n > 0 then
                materialCost[k] = n
            end
        end

        if next(materialCost) then
            if not mTender.addMaterial(materialCost) then
                response.ret = -1998
                return response
            end
        end

        mTender.productionQueueRemove(idx)

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.data.userinfo = mUserinfo.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end
        
        return response
    end 

    --[[
        加速生产补给品
    ]]
    function self.action_speedUp(request)
        local response = self.response
        local idx = request.params.idx
        local clientCost = request.params.cost

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')
        local ts = getClientTs()

        local productionInfo = mTender.productionQueueGet(idx)
        if not productionInfo or not productionInfo[2] then
            response.ret = -102
            response.err = "not found production info"
            return response
        end

        local tenderSkillCfg = getConfig("tenderSkill")
        if not tenderSkillCfg.compose[productionInfo[1]] then
            response.ret = -102
            response.err = "config error"
            return response
        end

        local diffTime = productionInfo[2] - ts
        local gemsCost = 0
        if diffTime > 0 then
            gemsCost = math.ceil(diffTime/tenderSkillCfg.compose[productionInfo[1]].timeWorth)
        end
        
        -- 前后端的钻石消耗数超过2时报错
        if math.abs(gemsCost - clientCost) > 2 then
            response.ret = -102
            response.gemsCost = gemsCost
            return response
        end

        -- 已生产完成，无需加速
        if gemsCost <= 0 then
            response.ret = -28013
            return response
        end

        -- 金币不足
        if not uobjs.getModel('userinfo').useGem(gemsCost) then
            response.ret = -109 
            return response
        end

        -- 补给舰-补给品生产加速
        regActionLogs(uid,1,{action=230,item="",value=gemsCost,params={diffTime=diffTime}})

        mTender.setProductionTime(idx,ts)

        if uobjs.save() then
            processEventsAfterSave()
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        使用道具加速生产补给品
    ]]
    function self.action_speedUpByItem(request)
        local response = self.response
        local idx = request.params.idx
        local item = request.params.item
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local ts = getClientTs()
        local productionInfo = mTender.productionQueueGet(idx)
        if not productionInfo or not productionInfo[2] then
            response.ret = -102
            response.err = "not found production info"
            return response
        end

        local tenderSkillCfg = getConfig("tenderSkill")
        if tenderSkillCfg.item[item] == nil or tenderSkillCfg.item[item].timeDecrease == nil then
            response.ret = -102
            response.err = "config error"
            return response
        end

        -- 已生产完成，无需加速
        if productionInfo[2] <= ts then
            response.ret = -28013
            return response
        end

        local ok,id = mTender.useMaterial({[item]=1})
        if not ok then
            response.ret = -28006
            response.itemId = id
            return response
        end

        local et = productionInfo[2]-tenderSkillCfg.item[item].timeDecrease
        if et < ts then  et = ts end

        mTender.setProductionTime(idx,et)

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        领取补给品
    ]]
    function self.action_collect(request)
        local response = self.response
        local idx = request.params.idx
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local productionInfo = mTender.productionQueueGet(idx)
        if not productionInfo then
            response.ret = -102
            response.err = "not found production info"
            return response
        end

        -- 未生产完成，不能领取补给品
        if not productionInfo[2] or productionInfo[2] > getClientTs() then
            response.ret = -28014
            return response
        end
        
        -- 补给品背包超重,无法操作
        if not mTender.addSupply(productionInfo[1]) then
            response.ret = -28016
            return response
        end

        mTender.productionQueueRemove(idx)

        if uobjs.save() then
            processEventsAfterSave()
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end


    -- 使用补给品
    function self.action_use(request)
        local response = self.response
        local idx = request.params.idx
        local quality = request.params.quality
        
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        -- -28017 补给品不存在，使用失败
        if not mTender.checkSupply(idx,quality) then
            response.ret = -28017
            return response
        end

        mTender.useSupply(idx)

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 补给品分解
    function self.action_decompose(request)
        local response = self.response
        local idx = request.params.idx
        local quality = request.params.quality
        
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        -- -28017 补给品不存在
        if not mTender.checkSupply(idx,quality) then
            response.ret = -28017
            return response
        end

        local tenderSkillCfg = getConfig("tenderSkill")
        local composeCfg = tenderSkillCfg.compose[quality]
        if not mTender.addMaterial(composeCfg.decompose) then
            response.ret = -1998
            return response
        end

        mTender.rmSupply(idx)

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

     -- 批量分解
    function self.action_batchDecompose(request)
        local response = self.response
        local colors = request.params.color
        local colorsFlag = {}
        for k,v in pairs(colors) do
            colorsFlag[v] = true
        end
        
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local tenderSkillCfg = getConfig("tenderSkill")
        local material = {}
        for i=#mTender.bag,1,-1 do
            local supplyColor = tenderSkillCfg.compose[mTender.bag[i][1]].color
            if colorsFlag[supplyColor] then
                for m,n in pairs(tenderSkillCfg.compose[mTender.bag[i][1]].decompose) do
                    material[m] = (material[m] or 0) + n
                end

                mTender.rmSupply(i)
            end
        end

        if not next(material) then
            response.ret = -1998
            return response
        end

        if not mTender.addMaterial(material) then
            response.ret = -1998
            return response
        end

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- function self.after() end

    return self
end

return api_tender_supply