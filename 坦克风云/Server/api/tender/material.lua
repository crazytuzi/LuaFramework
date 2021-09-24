local function api_tender_material(request)
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

            ["action_decompose"] = {
                items = {"required","table"},
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

    -- 材料分解
    -- 只会获得经验值
    function self.action_decompose(request)
        local response = self.response
        local items = request.params.items

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        -- 配置文件
        local tenderSkillCfg = getConfig("tenderSkill")

        local totalExp = 0
        for itemId,num in pairs(items) do
            if num <= 0 or math.ceil(num) ~= num then
                response.ret = -102
                response.err = "item num invalid"
                response.itemId = itemId
                return response
            end

            local itemCfg = tenderSkillCfg.item[itemId]
            if not itemCfg then
                response.ret = -102
                response.err = "item id invalid"
                response.itemId = itemId
                return response
            end

            -- 该材料不能分解
            if itemCfg.type ~= 1 then
                response.ret = -28003
                return response
            end

            totalExp = totalExp + itemCfg.decompose * num
        end

        totalExp = math.floor(totalExp)
        if totalExp <= 0 then
            response.ret = -102
            response.err = "total exp is 0"
            response.totalExp = totalExp
            return response
        end
        
        -- 分解的材料数量不足
        local ok,id = mTender.useMaterial(items)
        if not ok then
            response.ret = -28006
            response.item = {id,mTender.getMaterialNum(id)}
            return response
        end

        mTender.addExp(totalExp)

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

return api_tender_material