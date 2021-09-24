local function api_admin_tender(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },

        tbName = "killrace_season",
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },

            ["action_addMaterial"] = {
                material = {"required","table"},
            },

            ["action_addSupply"] = {
                supply = {"required","table"},
            },
        }
    end

    function self.before(request) 
        -- 开关未开启
        if not switchIsEnabled('tender') then
            self.response.ret = -180
            return self.response
        end
    end

    -- 获取补给舰数据
    function self.action_get(request)
        local response = self.response

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')
        local mUserinfo = uobjs.getModel('userinfo')

        local data = {
            userinfo = {
                nickname = mUserinfo.nickname
            },
            tender = {
                level = mTender.getLevel(),
                enhancelvl = mTender.getEnhancelvl(),
                exp = mTender.exp,
            },
            used = {},
        }

        -- 有使用的补给品
        local supply = mTender.getUsedSupply()
        if supply then
            data.used[1] = supply[1]
            data.used[2] = mTender.getSupplyAttributes(supply)
            data.used[3] = supply[3]
        end

        response.data = data
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 设置补给舰等级，强化等级，经验
    function self.action_set(request)
        local response = self.response

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local tenderCfg = getConfig("tender")

        if request.params.level then
            local level = math.floor(request.params.level)
            local maxLevel = tenderCfg.main.maxLevel
            
            -- 补给舰已达最高等级,不能再升了
            if level >  maxLevel then
                response.ret = -28002
                return response
            end

            if level < 0 then
                response.ret = -102
                response.err = "level invalid"
                return response
            end

            mTender.level = level
        end

        if request.params.enhancelvl then
            local enhancelvl = math.floor(request.params.enhancelvl)
            local maxEnhanceLvl = tenderCfg.main.maxIntensify

            -- 强化等级已达上限,不能再强化了
            if enhancelvl > maxEnhanceLvl then
                response.ret = -28005
                return response
            end

            if enhancelvl < 0 then
                response.ret = -102
                response.err = "enhancelvl invalid"
                return response
            end

            mTender.enhancelvl = enhancelvl
        end

        if request.params.exp then
            local exp = math.floor(request.params.exp)
            if exp < 0 then
                response.ret = -102
                response.err = "exp invalid"
                return response
            end

            mTender.exp = exp
        end

        local data = {
            tender = {
                level = mTender.getLevel(),
                enhancelvl = mTender.getEnhancelvl(),
                exp = mTender.exp,
            }
        }

        mTender.reCalcBuildingStrength()

        if uobjs.save() then
            response.data = data
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 补给品背包
    function self.action_bag(request)
        local response = self.response

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local data = {
            bag = {}
        }

        for k,v in pairs(mTender.bag) do
            table.insert(data.bag,{
                v[1],mTender.getSupplyAttributes(v),v[3],
            })
        end

        data.material = mTender.material

        response.data = data
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 删除使用中的
    function self.action_rmused(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        mTender.used = {}

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 移除补给品
    function self.action_rmsupply(request)
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

        mTender.rmSupply(idx)

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 添加材料
    function self.action_addMaterial(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local tenderCfg = getConfig("tenderSkill")
        local material = request.params.material

        if not next(material) then
            response.ret = 0
            response.msg = 'Success'
            return response
        end

        for k,v in pairs(material) do
            if (v < 0) or (not tenderCfg.item[k]) then
                response.ret = -102
                response.errMaterialId = k
                return response
            end
        end

        mTender.addMaterial(material)

        if uobjs.save() then
            response.data.material = mTender.material
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 减材料
    function self.action_subMaterial(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local tenderCfg = getConfig("tenderSkill")
        local material = request.params.material

        if not next(material) then
            response.ret = 0
            response.msg = 'Success'
            return response
        end

        for k,v in pairs(material) do
            if (v < 0) or (not tenderCfg.item[k]) then
                response.ret = -102
                response.errMaterialId = k
                return response
            end
        end

        if not mTender.useMaterial(material) then
            response.ret = -28006
            return response
        end

        if uobjs.save() then
            response.data.material = mTender.material
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 添加补给品
    function self.action_addSupply(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local supply = request.params.supply
        local tenderCfg = getConfig("tenderSkill")
        local supplyCfg = tenderCfg.compose[supply[1]]

        if not supplyCfg then
            response.ret = -102
            response.errSupplyQuality = supply[1]
            return response
        end

        if #supply[2] < supplyCfg.attNum[1] or #supply[2] > #supplyCfg.attContain then
            response.ret = -102
            response.err = "attributes out of range"
            return response
        end

        local attrNo = 0
        local maxAttrKey = #supplyCfg.attContain
        for k,v in pairs(supply[2]) do
            if v < 1 or v > maxAttrKey then
                response.ret = -102
                response.err = "attributes out of range"
                return response
            end

            attrNo = bit32.bor(attrNo,bit32.lshift(1,v-1))
        end

        supply[2] = attrNo

        local skillPoolCfg = tenderCfg.skillPool[supplyCfg.skillPool]

        if not supply[3] then
            supply[3] = 0
        end

        if supply[3] ~= 0 then
            if not skillPoolCfg or not table.contains(skillPoolCfg[3],supply[3]) then
                response.ret = -102
                response.skillPoolCfg = skillPoolCfg or "nil"
                return response
            end
        end
        
        if not mTender.addSupplyToBag(supply) then
            response.ret = -28016 -- 补给品背包超重,无法操作
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- function self.after() end

    return self
end

return api_admin_tender