local function api_amixer_item(request)
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

            ["action_buy"] = {
                item = {"required","string"},
                num = {"required", "number", {"min", 1}},
            },
        }
    end

    function self.before(request)
        if not switchIsEnabled('btMix') then
            self.response.ret = -180
            return self.response
        end
    end

    -- 购买商店物品
    function self.action_buy(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mUmixer = uobjs.getModel('umixer')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local itemId = request.params.item
        local num = request.params.num
        local itemCfg = getConfig("bestMixer").shopList[itemId]

        if not itemCfg then
            response.ret = -102
            return response
        end

        if num > 1 and itemCfg.bulkbuy ~= 1 then
            response.ret = -102
            return response
        end

        if itemCfg.limit > 0 then
            mUmixer.setShop(itemId,num)
            if mUmixer.getPurchases(itemId) > itemCfg.limit then
                response.ret = -8464 -- 已达购买上限,不能购买(兑换商店)
                return response
            end
        end

        if not mUmixer.useCrystal(itemCfg.coinCost * num) then
            response.ret = -8465 -- 金色晶体不足,不能购买(兑换商店)
            return response
        end

        local items = {}
        for k,v in pairs(itemCfg.get) do
            items[k] = v * num
        end

        if not takeReward(uid,items) then
            response.ret =-403
            return response
        end

        if uobjs.save() then
            response.data.bestMixer = {
                umixer = mUmixer.toArray(true)
            }

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end
    
    -- function self.after() end

    return self
end

return api_amixer_item