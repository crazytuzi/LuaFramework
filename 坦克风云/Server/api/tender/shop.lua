local function api_tender_shop(request)
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

            ["action_exchange"] = {
                itemId = {"required","string"},
                num = {"required", "number", {"min", 1}},
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
        商店兑换
    ]]
    function self.action_exchange(request)
        local response = self.response
        local itemId = request.params.itemId
        local num = math.floor(request.params.num)

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        -- 配置文件
        local itemCfg = getConfig("tender").shopList[itemId]
        if not itemCfg then
            response.ret = -102
            response.err = "itemId invalid"
            return response
        end

        -- 不能批量使用
        if num > 1 and itemCfg.bulkbuy == 0 then
            response.ret = -102
            response.err = "This item cannot be exchanged in bulk."
            return response 
        end

        -- 限购
        if itemCfg.limit > 0 then
            -- 超过当日限购数量,不能再买了
            if ( itemCfg.limit - mTender.getShopItem(itemId) ) < num then
                response.ret = -28015
                response.boughtNum = mTender.getShopItem(itemId)
                return response
            end

            -- 设置已购
            mTender.setShop(itemId,num)
        end

        local expCost = itemCfg.expCost * num

        -- (防刷)判断一下最小经验值不能小于10
        if expCost < 10 then 
            response.err = -120
            return response 
        end

        -- 经验不足
        if not mTender.useExp(expCost) then
            response.ret = -28001
            return response
        end

        local itemGet = {}
        for k,v in pairs(itemCfg.get) do
            itemGet[k] = v * num
        end

        if not takeReward(uid,itemGet) then        
            response.ret = -403 
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

return api_tender_shop