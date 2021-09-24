local function api_tender_tender(request)
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
        获取补给舰模块数据
    ]]
    function self.action_get(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        response.data.tender = uobjs.getModel("tender").toArray(true)

        uobjs.save()
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --[[
        补给舰升级
    ]]
    function self.action_upgrade(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 配置文件
        local tenderCfg = getConfig("tender")

        -- 人物等级不足
        if mUserinfo.level < tenderCfg.main.unlocklevel then
            response.ret = -301
            return response
        end

        local maxLevel = tenderCfg.main.maxLevel
        local tenderLevel = mTender.getLevel()

        -- 补给舰已达最高等级,不能再升了
        if tenderLevel >=  maxLevel then
            response.ret = -28002
            return response
        end

        local nextLevel = tenderLevel + 1
        local requiredExp = tenderCfg.level[nextLevel].expNeed

        if nextLevel > 1 then
            -- 升级所需的经验值不足
            if not mTender.useExp(requiredExp) then
                response.ret = -28001
                return response
            end
        end

        -- 初始化任务
        if mTender.levelUp() == 1 then
            for k,v in pairs(tenderCfg.main.initialTask) do
                mTender.addTask(v)
                mTender.startTaskCD()
            end
        end

        -- 刷新战力
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        补给舰强化
    ]]
    function self.action_enhance(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        -- 配置文件
        local tenderCfg = getConfig("tender")

        local enhancelvl = mTender.getEnhancelvl()
        local maxEnhanceLvl = tenderCfg.main.maxIntensify

        -- 强化等级已达上限,不能再强化了
        if mTender.getEnhancelvl() >= maxEnhanceLvl then
            response.ret = -28005
            return response
        end

        local nextEnhanceLvl = enhancelvl + 1
        local enhanceCfg = tenderCfg.intensify[nextEnhanceLvl]
        if not enhanceCfg then
            response.ret = -102
            response.err = "enhanceCfg is nil"
            response.nextEnhanceLvl = nextEnhanceLvl
            return response
        end

        local requiredLevel = enhanceCfg.levelNeed
       
        -- 补给舰等级不足,不能强化
        if not requiredLevel or ( mTender.getLevel() < requiredLevel ) then
            response.ret = -28004
            return response
        end

        -- 消耗的材料
        local materialCost = enhanceCfg.cost

        -- 强化消耗的材料
        local ok,id = mTender.useMaterial(materialCost)
        if not ok then
            response.ret = -28006
            response.itemId = id
            return response
        end

        mTender.enhanceLvlUp()
        
        -- 刷新战力
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- function self.after() end

    return self
end

return api_tender_tender