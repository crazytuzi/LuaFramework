local function api_amixer_set(request)
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

            ["action_sequip"] = {
                items = {"required","table"},
                coin = {"required","number"},
            },

            ["action_allot"] = {
                item = {"required","string"},
                idx = {"required","number"},
                member = {"required","number"},
            },
        }
    end

    function self.before(request) 
        if not switchIsEnabled('btMix') then
            self.response.ret = -180
            return self.response
        end

        if os.time() < (getWeeTs() + 300) then
            self.response.ret = -8469
            return self.response
        end
        
        -- 成就等级限制
        if getUserObjs(request.uid).getModel('achievement').level < getConfig("bestMixer").main.achieveLevel then
            self.response.ret = -8467
            return self.response
        end
    end

    --[[
        投入超级装备
    ]]
    function self.action_sequip(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mSequip = uobjs.getModel('sequip')
        local mUmixer = uobjs.getModel('umixer') 
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance)

        local cCoin = request.params.coin
        local items = request.params.items
        local itemType = 1

        local mixerCfg = getConfig("bestMixer")

        local totalNum = 0
        local sCoin = 0
        for idx,num in pairs(items) do
            num = math.floor(math.abs(num))

            if not mixerCfg.itemList[idx] or mixerCfg.itemList[idx].type ~= itemType then
                response.ret = -102
                response.cfg = {idx,mixerCfg.itemList[idx]}
                return response
            end

            if num < 1 or not mSequip.consumeEquip(mixerCfg.itemList[idx].item, num) then
                response.ret=-102
                response.err = {idx,mixerCfg.itemList[idx].item, num}
                return response
            end

            if not mAmixer.addSequip(idx,num) then
                response.ret = -121
                return response
            end

            sCoin = sCoin + mixerCfg.itemList[idx].coinBack * num
            totalNum = totalNum + num
        end

        mUmixer.incrSequipNum(totalNum)
        if mUmixer.getSequipNum() > mixerCfg.main.numLimit[itemType] then
            response.ret = -8466 -- 已达投放上限,不能再投了(投放原料)
            return response
        end

        if cCoin ~= sCoin then
            response.ret = -102
            response.sCoin = sCoin
            return response
        end

        mUmixer.addCrystal(sCoin)

        if uobjs.save() then
            if not mAmixer.save() then 
                writeLog({"amixer save failed",request})
            end

            response.data.bestMixer = {
                amixer = {
                    sequip = mAmixer.getSequip()
                },
                umixer = mUmixer.toArray(true)
            }

            response.data.sequip = mSequip.toArray(true)

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 投入海兵方阵
    function self.action_armor(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mArmor = uobjs.getModel('armor')
        local mUmixer = uobjs.getModel('umixer') 
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance)

        local cCoin = request.params.coin
        local items = request.params.items
        local armors = request.params.armors
        local itemType = 2

        local mixerCfg = getConfig("bestMixer")

        local totalNum = 0
        local sCoin = 0
        for idx, armors in pairs(items) do
            if type(armors) ~= "table" then return response end

            local num = #armors

            if (num < 1) or ( not mixerCfg.itemList[idx] ) or (mixerCfg.itemList[idx].type ~= itemType) then
                response.ret = -102
                response.cfg = {idx,mixerCfg.itemList[idx],num}
                return response
            end

            for _,armorId in pairs(armors) do
                -- TODO 方阵等级大于1的不知道能不能投
                if mArmor.getArmorId(armorId) ~= mixerCfg.itemList[idx].item then
                    response.ret = -102
                    response.err = {mArmor.getArmorId(armorId),mixerCfg.itemList[idx].item}
                    return response
                end

                -- 正在使用中的不能投放
                if mArmor.checkUsed(armorId) or ( not mArmor.delArmor(armorId) ) then
                    response.ret = -102
                    response.err = "delArmor failed"
                    return response
                end
            end

            if not mAmixer.addArmor(idx,num) then
                response.ret = -121
                return response
            end

            sCoin = sCoin + mixerCfg.itemList[idx].coinBack * num
            totalNum = totalNum + num
        end

        mUmixer.incrArmorNum(totalNum)
        if mUmixer.getArmorNum() > mixerCfg.main.numLimit[itemType] then
            response.ret = -8466 -- 已达投放上限,不能再投了(投放原料)
            return response
        end

        if cCoin ~= sCoin then
            response.ret = -102
            response.sCoin = sCoin
            return response
        end

        mUmixer.addCrystal(sCoin)

        if uobjs.save() then
            if not mAmixer.save() then 
                writeLog({"amixer save failed",request})
            end

            response.data.bestMixer = {
                amixer = {
                    armor = mAmixer.getArmor()
                },
                umixer = mUmixer.toArray(true)
            }

            response.data.armor = mArmor.toArray(true)

            response.ret = 0
            response.msg = 'Success'
        end 

        return response
    end

    -- 投入配件
    function self.action_accessory(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mAccessory = uobjs.getModel('accessory')
        local mUmixer = uobjs.getModel('umixer') 
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance)

        local cCoin = request.params.coin
        local items = request.params.items
        local itemType = 3

        local mixerCfg = getConfig("bestMixer")

        local totalNum = 0
        local sCoin = 0
        for idx,num in pairs(items) do
            num = math.floor(math.abs(num))

            if not mixerCfg.itemList[idx] or mixerCfg.itemList[idx].type ~= itemType then
                response.ret = -102
                response.cfg = {idx,mixerCfg.itemList[idx]}
                return response
            end

            if num < 1 or not mAccessory.useFragment(mixerCfg.itemList[idx].item, num) then
                response.ret=-102
                response.err = {idx,mixerCfg.itemList[idx].item, num}
                return response
            end

            if not mAmixer.addAccessory(idx,num) then
                response.ret = -121
                return response
            end

            sCoin = sCoin + mixerCfg.itemList[idx].coinBack * num
            totalNum = totalNum + num
        end

        mUmixer.incrAccessoryNum(totalNum)
        if mUmixer.getAccessoryNum() > mixerCfg.main.numLimit[itemType] then
            response.ret = -8466 -- 已达投放上限,不能再投了(投放原料)
            return response
        end

        if cCoin ~= sCoin then
            response.ret = -102
            response.sCoin = sCoin
            return response
        end

        mUmixer.addCrystal(sCoin)

        if uobjs.save() then
            if not mAmixer.save() then 
                writeLog({"amixer save failed",request})
            end

            response.data.bestMixer = {
                amixer = {
                    accessory = mAmixer.getAccessory()
                },
                umixer = mUmixer.toArray(true),
            }
            response.data.accessory = mAccessory.toArray(true)

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 投入异星武器
    function self.action_alienWeapon(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mAweapon = uobjs.getModel("alienweapon")
        local mUmixer = uobjs.getModel('umixer') 
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance)

        local cCoin = request.params.coin
        local items = request.params.items
        local itemType = 4

        local mixerCfg = getConfig("bestMixer")

        local totalNum = 0
        local sCoin = 0
        for idx,num in pairs(items) do
            num = math.floor(math.abs(num))

            if not mixerCfg.itemList[idx] or mixerCfg.itemList[idx].type ~= itemType then
                response.ret = -102
                response.cfg = {idx,mixerCfg.itemList[idx]}
                return response
            end

            if num < 1 or not mAweapon.useFragment(mixerCfg.itemList[idx].item, num) then
                response.ret = -12006
                response.err = {idx,mixerCfg.itemList[idx].item, num}
                return response
            end

            if not mAmixer.addAlienWeapon(idx,num) then
                response.ret = -121
                return response
            end

            sCoin = sCoin + mixerCfg.itemList[idx].coinBack * num
            totalNum = totalNum + num
        end

        mUmixer.incrAlienweaponNum(totalNum)
        if mUmixer.getAlienweaponNum() > mixerCfg.main.numLimit[itemType] then
            response.ret = -8466 -- 已达投放上限,不能再投了(投放原料)
            return response
        end

        if cCoin ~= sCoin then
            response.ret = -102
            response.sCoin = sCoin
            return response
        end

        mUmixer.addCrystal(sCoin)

        if uobjs.save() then
            if not mAmixer.save() then 
                writeLog({"amixer save failed",request})
            end

            response.data.bestMixer = {
                amixer = {
                    alienWeapon = mAmixer.getAlienWeapon()
                },
                umixer = mUmixer.toArray(true)
            }

            response.data.alienweapon = mAweapon.toArray(true)

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end
    
    -- function self.after() end

    return self
end

return api_amixer_set