--[[
文件名:CacheSlotPref.lua
描述：阵容卡槽最优数据抽象类型
创建人：liaoyuangang
创建时间：2016.12.09
--]]

-- 卡槽最优数据说明
--[[
    服务器返回的卡槽最优数据：
    [0] = {
        "EquipStepUse" = {
            "Pants" = "7f2fa4c9-7c5f-4e76-bac8-9442b807a008",
        },
        "EquipStarInfo" = {
            "Shoes" = {
                1 = "064b229d-4056-45d5-b0c9-6468eab492d4",
            },
        },
        "ZhenJueCanStep" = {
            1 = "99a7639f-afc0-4ac6-8aa7-cb4cb24d027d",
            2 = "a53ad446-65b8-43a0-a5e4-50c55e561140",
        },
        MainHeroTalInfo = {1,2,3} -- 可上阵招式的序号(1,2,3)
    },
    [1] = {
        "ZhenJuePref" = {
            "4" = {
                "ModelId" = 18014302,
                "Id" = "bc8e5cab-4fc6-4c8d-b8dd-f055d4af718c",
            },
            "1" = {
                "ModelId" = 18014302,
                "Id" = "bc8e5cab-4fc6-4c8d-b8dd-f055d4af718c",
            },
            "5" = {
                "ModelId" = 18014302,
                "Id" = "bc8e5cab-4fc6-4c8d-b8dd-f055d4af718c",
            },
            "2" = {
                "ModelId" = 18014302,
                "Id" = "bc8e5cab-4fc6-4c8d-b8dd-f055d4af718c",
            },
            "6" = {
                "ModelId" = 18014302,
                "Id" = "bc8e5cab-4fc6-4c8d-b8dd-f055d4af718c",
            },
            "3" = {
                "ModelId" = 18014302,
                "Id" = "bc8e5cab-4fc6-4c8d-b8dd-f055d4af718c",
            },
        },
        "ZhenYuanPref" = {
            "1" = {
                "ModelId" = 27010202,
                "Id" = "895c3a41-ce8f-4444-86bb-8db1339d5224",
            },
        },

        PetPref = {
            "ModelId" = 23010602,
            "Id" = "942fcf58-d01b-4c20-a8be-a192c0f9afc9",
        },

       	EquipPref = {
			Weapon = {
				Id:123,
				ModelId:123456
			},
			Helmet: = {
				Id:123,
				ModelId:123456
			},
			Clothes = {
				Id:123,
				ModelId:123456
			},
			Necklace = {
				Id:123,
				ModelId:123456
			},
			Pants = {
				Id:123,
				ModelId:123456
			},
			Shoes = {
				Id:123,
				ModelId:123456
			},
			Book = {
				Id:123,
				ModelId:123456
			},
		},

		EquipStepUse = {
			Weapon = {
				09586492-9683-4051-9bbb-d7aaade31520,
				...
			},
		}

		HeroCanStep = true/false      -- 侠客可进阶
        PetCanActiveTal = true/false  -- 外功可参悟  
        TreasureCanStep = true/false  -- 神兵可进阶
        HeroCanReborn = true/false  -- 侠客可转身
    },
    [2] = {
		EquipPref = {...},
		EquipStepUse = {...},
		HeroCanStep = true/false
        PetCanActiveTal = true/false
        TreasureCanStep = true/false
        HeroCanReborn = true/false  -- 侠客可转身
    }
    [3] = {...}
    ...
]]

local CacheSlotPref = class("CacheSlotPref", {})

function CacheSlotPref:ctor()
	-- 装备类型对应的英文名
	self.mEquipTypeNames = {
        [ResourcetypeSub.eWeapon] = "Weapon", -- "武器"
        [ResourcetypeSub.eHelmet] = "Helmet", -- "头盔"
        [ResourcetypeSub.eClothes] = "Clothes", --  "衣服"
        [ResourcetypeSub.eNecklace] = "Necklace", -- "项链"
        [ResourcetypeSub.ePants] = "Pants", -- "裤子"
        [ResourcetypeSub.eShoe] = "Shoes", -- "鞋子"
    }
    -- 神兵类型对应的英文名
    self.mTreasureTypeNames = {
        [ResourcetypeSub.eBook] = "Book", -- "神兵"
    }

    -- 服务器返回卡槽最优数据的原始数据
    self.mSlotPrefData = {}
end

-- 清空管理对象中的数据
function CacheSlotPref:reset()
   self.mSlotPrefData = {}
end

-- 设置卡槽最优数据改变信息
function CacheSlotPref:updatePrefData(prefData)
    for key, item in pairs(prefData) do
        local slotId = tonumber(key)
        -- 0表示卡槽无关数据，如装备升星和锻造，>0表示卡槽数据
        self.mSlotPrefData[slotId] = self.mSlotPrefData[slotId] or {}
        local slotInfo = self.mSlotPrefData[slotId]

        -- 最优装备信息
        if item.EquipPref then
        	slotInfo.EquipPref = item.EquipPref
        end
    
        -- 最优外功信息
        if item.PetPref then
            slotInfo.PetPref = item.PetPref
        end
    
        -- 最优阵诀信息
        if item.ZhenJuePref then
            slotInfo.ZhenJuePref = {}
            for k,v in pairs(item.ZhenJuePref) do
                -- 服务端传回来的k是字符串类型，需要处理成数字
                slotInfo.ZhenJuePref[tonumber(k)] = v
            end
        end

        -- 最优真元信息
        if item.ZhenYuanPref then
            slotInfo.ZhenYuanPref = {}
            for k,v in pairs(item.ZhenYuanPref) do
                slotInfo.ZhenYuanPref[tonumber(k)] = v
            end
        end
    
        -- 人物是否可以进阶
        if item.HeroCanStep ~= nil then
            slotInfo.HeroCanStep = item.HeroCanStep
        end
        if item.HeroCanReborn ~= nil then
            slotInfo.HeroCanReborn = item.HeroCanReborn
        end
        -- 外功是否可以参悟
        if item.PetCanActiveTal ~= nil then
            slotInfo.PetCanActiveTal = item.PetCanActiveTal
        end
        -- 神兵是否可以进阶
        if item.TreasureCanStep ~= nil then
            slotInfo.TreasureCanStep = item.TreasureCanStep
        end
        
        -- 可进阶装备信息(卡槽0中)
        if item.EquipStepUse then
        	slotInfo.EquipStepUse = item.EquipStepUse
        end
    
        -- 可升星装备信息(卡槽0中)
        if item.EquipStarInfo then
            slotInfo.EquipStarInfo = item.EquipStarInfo
        end

        -- 内功是否可以进阶(卡槽0中)
        if item.ZhenJueCanStep ~= nil then
            slotInfo.ZhenJueCanStep = item.ZhenJueCanStep
        end

        -- 有招式可上阵(卡槽0中)
        if item.MainHeroTalInfo then
            slotInfo.MainHeroTalInfo = item.MainHeroTalInfo
        end

        Notification:postNotification(EventsName.eSlotRedDotPrefix .. tostring(slotId))
	end

    -- 计算完成后通知一下关注者
    Notification:postNotification(EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation))
    -- 再通知一下需要刷新加号显示的地方
    Notification:postNotification(EventsName.eSlotEquipNodeAddFlagVisible)
end

--- 获取一键上阵的装备列表
--[[
-- 参数
    slotId：需要获取一键上阵装备的卡槽Id
-- 返回值
    -- todo
 ]]
function CacheSlotPref:getOneKeyReplaceEquip(slotId)
	local slotItem = FormationObj:getSlotInfoBySlotId(slotId)
    if not slotItem or not Utility.isEntityId(slotItem.HeroId) then
        return {}
    end

    local ret = {}
    local currSlotPrefInfo = self.mSlotPrefData[slotId]
    if currSlotPrefInfo then
        ret = currSlotPrefInfo.EquipPref

        -- 返回值里增加外功秘籍
        if (currSlotPrefInfo.PetPref ~= nil) and (currSlotPrefInfo.PetPref.Id ~= nil) then
            ret["Pet"] = currSlotPrefInfo.PetPref
        end
    end

    return ret
end

--- 获取一键上阵的阵诀列表
--[[
-- 参数
    slotId：需要获取一键上阵装备的卡槽Id
-- 返回值
    -- todo
 ]]
function CacheSlotPref:getOneKeyReplaceZhenjue(slotId)
    local slotItem = FormationObj:getSlotInfoBySlotId(slotId)
    if not slotItem or not Utility.isEntityId(slotItem.HeroId) then
        return {}
    end

    return self.mSlotPrefData[slotId] and self.mSlotPrefData[slotId].ZhenJuePref or {}
end

--- 获取一键上阵的真元列表
--[[
-- 参数
    slotId：需要获取一键上阵装备的卡槽Id
-- 返回值
    -- todo
 ]]
function CacheSlotPref:getOneKeyReplaceZhenyuan(slotId)
    local slotItem = FormationObj:getSlotInfoBySlotId(slotId)
    if not slotItem or not Utility.isEntityId(slotItem.HeroId) then
        return {}
    end

    return self.mSlotPrefData[slotId] and self.mSlotPrefData[slotId].ZhenYuanPref or {}
end

--- 获取是否有更优的装备可以上阵
--[[
-- 参数
    aSlotId： 如果该参数不为nil，则获取该卡槽的更优装备，否则会遍历所有卡槽，直到有最优卡槽为止
-- 返回值：
  	-- todo
 ]]
function CacheSlotPref:havePreferableEquip(aSlotId)
	local slotInfos = FormationObj:getSlotInfos()
	-- 
    local function getSlotPreferableEquip(slotId)
        local slotItem = slotInfos[slotId]
        if not slotItem or not Utility.isEntityId(slotItem.HeroId) then
            return nil
        end

        local tempItem = self.mSlotPrefData[slotId] and self.mSlotPrefData[slotId].EquipPref or {}
        local foundDiff = false
        local ret = {slotId = slotId}

        -- 查找装备
        for type, typeName in pairs(self.mEquipTypeNames) do
            local tempEquip, slotEquip = tempItem[typeName], slotItem[typeName]
            if tempEquip and tempEquip.Id and (not slotEquip or slotEquip.Id ~= tempEquip.Id) then
                ret[type] = tempEquip
                foundDiff = true
            end
        end
        
        -- 查找神兵
        for type, typeName in pairs(self.mTreasureTypeNames) do
            local tempTreasure, slotTreasure = tempItem[typeName], slotItem[typeName]
            if tempTreasure and tempTreasure.Id and (not slotTreasure or slotTreasure.Id ~= tempTreasure.Id) then
                ret[type] = tempTreasure
                foundDiff = true
            end
        end

        -- 查找外功秘籍
        local slotPet = slotItem.Pet
        local tempPet = self.mSlotPrefData[slotId] and self.mSlotPrefData[slotId].PetPref or {}
        if tempPet.Id and (not slotPet or slotPet.Id ~= tempPet.Id) then
            ret[ResourcetypeSub.ePet] = tempPet
            foundDiff = true
        end
        
        return foundDiff and ret or nil
    end

    if aSlotId then
        return getSlotPreferableEquip(aSlotId)
    else
        for slotId = 1, #slotInfos do
            local tempRet = getSlotPreferableEquip(slotId)
            if tempRet then
                return tempRet
            end
        end
    end
end

--- 获取是否有更优的阵诀可以上阵
--[[
-- 参数
    aSlotId： 如果该参数不为nil，则获取该卡槽的更优装备，否则会遍历所有卡槽，直到有最优卡槽为止
-- 返回值：
    -- todo
 ]]
function CacheSlotPref:havePreferableZhenjue(aSlotId)
    local slotInfos = FormationObj:getSlotInfos()
    -- 
    local function getSlotPreferableZhenjue(slotId)
        local slotItem = slotInfos[slotId]
        if not slotItem or not Utility.isEntityId(slotItem.HeroId) then
            return nil
        end

        local tempItem = self.mSlotPrefData[slotId] and self.mSlotPrefData[slotId].ZhenJuePref or {}
        local foundDiff = false
        local ret = {slotId = slotId}
        for index, tempZhenjue in pairs(tempItem) do
            local slotZhenjue = slotItem.Zhenjue[index]
            if tempZhenjue and tempZhenjue.Id and (not slotZhenjue or slotZhenjue.Id ~= tempZhenjue.Id) then
                ret[index] = tempZhenjue
                foundDiff = true
            end
        end
        
        return foundDiff and ret or nil
    end

    if aSlotId then
        return getSlotPreferableZhenjue(aSlotId)
    else
        for slotId = 1, #slotInfos do
            local tempRet = getSlotPreferableZhenjue(slotId)
            if tempRet then
                return tempRet
            end
        end
    end
end

--- 获取是否有更优的真元可以上阵
--[[
-- 参数
    aSlotId： 如果该参数不为nil，则获取该卡槽的更优装备，否则会遍历所有卡槽，直到有最优卡槽为止
-- 返回值：
    -- todo
 ]]
function CacheSlotPref:havePreferableZhenyuan(aSlotId)
    local slotInfos = FormationObj:getSlotInfos()
    -- 
    local function getSlotPreferableZhenyuan(slotId)
        local slotItem = slotInfos[slotId]
        if not slotItem or not Utility.isEntityId(slotItem.HeroId) then
            return nil
        end

        local tempItem = self.mSlotPrefData[slotId] and self.mSlotPrefData[slotId].ZhenYuanPref or {}
        local foundDiff = false
        local ret = {slotId = slotId}
        for index, tempZhenyuan in pairs(tempItem) do
            local slotZhenyuan = slotItem.ZhenYuan[index]
            if tempZhenyuan and tempZhenyuan.Id and (not slotZhenyuan or slotZhenyuan.Id ~= tempZhenyuan.Id) then
                ret[index] = tempZhenyuan
                foundDiff = true
            end
        end
        
        return foundDiff and ret or nil
    end

    if aSlotId then
        return getSlotPreferableZhenyuan(aSlotId)
    else
        for slotId = 1, #slotInfos do
            local tempRet = getSlotPreferableZhenyuan(slotId)
            if tempRet then
                return tempRet
            end
        end
    end
end

--- 返回卡槽ID可上阵的列表
function CacheSlotPref:haveMainHeroTal(aSlotId)
    if not aSlotId or aSlotId == 1 then
        local talInfo = self.mSlotPrefData[0] and self.mSlotPrefData[0].MainHeroTalInfo or {}
        return #talInfo > 0 and talInfo or nil
    end
end

--- 返回装备锻造列表
function CacheSlotPref:haveSlotEquipCanStep()
    -- 装备进阶模块还未开启
    if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eEquipStepUp) then
        return {}
    end
    -- EquipStepUse如有，只会有一条数据（卡槽0中）
    return self.mSlotPrefData[0] and self.mSlotPrefData[0].EquipStepUse or {}
end

--- 返回装备升星列表
function CacheSlotPref:haveSlotEquipCanStar()
    -- 装备进阶模块还未开启
    if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eEquipStarUp) then
        return {}
    end
    -- EquipStarInfo如有，只会有一条数据（卡槽0中）
    return self.mSlotPrefData[0] and self.mSlotPrefData[0].EquipStarInfo or {}
end

-- 判断某卡槽上的是否有内功可以进阶
--[[
-- 参数
    slotId: 上阵卡槽Id，如果该参数是0，则只要任意一个卡槽可以进阶就返回true
]]
function CacheSlotPref:slotZhenjueCanStep(slotId)
    if (slotId == nil) or (slotId == 0) then
        local zhenStepList = self.mSlotPrefData[0] and self.mSlotPrefData[0].ZhenJueCanStep or {}
        return ((zhenStepList ~= nil) and (#zhenStepList > 0))
    end

    -- 读取当前卡槽里的所有内功
    local slotItem = FormationObj:getSlotInfoBySlotId(slotId)
    if not slotItem or not Utility.isEntityId(slotItem.HeroId) then
        return false
    end

    for _, zhenjue in pairs(slotItem.Zhenjue or {}) do
        if (self:itemZhenjueCanStep(zhenjue.Id) == true) then
            return true
        end
    end
    return false
end

-- 判断某个内功是否可以进阶
--[[
-- 参数
    zhenjueId: 内功心法的Id
]]
function CacheSlotPref:itemZhenjueCanStep(zhenjueId)
    if not Utility.isEntityId(zhenjueId) then
        return false
    end

    local zhenStepList = self.mSlotPrefData[0] and self.mSlotPrefData[0].ZhenJueCanStep or {}
    if (zhenStepList == nil) and (#zhenStepList == 0) then
        return false
    end

    for _,v in ipairs(zhenStepList) do
        if (zhenjueId == v) then
            return true
        end
    end
    return false
end

--- 判断某卡槽上的物件是否需要小红点, 内部使用
--[[
-- 参数
     moduleId: 开启模块ID
     fieldName: 判断字段名
     slotId：上阵卡槽Id
-- 返回值：
     如果卡槽满足条件，则返回对应的卡槽Id，否则返回 false
 ]]
function CacheSlotPref:slotModuleRedDot(moduleId, fieldName, slotId)
    local slotInfos = FormationObj:getSlotInfos()
    if not ModuleInfoObj:modulePlayerIsOpen(moduleId) or not slotInfos then
        return false
    end

    if slotId then
        local tempInfo = self.mSlotPrefData[slotId] or {}
        return tempInfo[fieldName] and slotId or false
    else
        local openSlotCount = FormationObj:getSlotOpenCount()
        for slotId = 1, openSlotCount do
            local tempInfo = self.mSlotPrefData[slotId] or {}
            if tempInfo[fieldName] then
                return slotId
            end
        end
    end

    return false
end

--- 判断某卡槽上的人物是否可以进阶
--[[
-- 参数
     slotId：上阵卡槽Id
-- 返回值：
     如果卡槽满足进阶标识的条件，则返回对应的卡槽Id，否则返回 false
 ]]
function CacheSlotPref:slotHeroCanStep(slotId)
    return self:slotModuleRedDot(ModuleSub.eHeroStepUp, "HeroCanStep", slotId)
end

-- 判断某卡槽上的人物是否可以转身
--[[
-- 参数
    slotId: 上阵卡槽Id
]]
function CacheSlotPref:slotHeroCanReborn(slotId)
    return self:slotModuleRedDot(ModuleSub.eReborn, "HeroCanReborn", slotId)
end

--- 判断某卡槽上的外功是否可以参悟
--[[
-- 参数
     slotId：上阵卡槽Id
-- 返回值：
     如果卡槽满足参悟标识的条件，则返回对应的卡槽Id，否则返回 false
 ]]
function CacheSlotPref:slotPetCanActiveTal(slotId)
    return self:slotModuleRedDot(ModuleSub.ePetActiveTal, "PetCanActiveTal", slotId)
end

--- 判断某卡槽上的神兵是否可以进阶
--[[
-- 参数
     slotId：上阵卡槽Id
-- 返回值：
     如果卡槽满足进阶标识的条件，则返回对应的卡槽Id，否则返回 false
 ]]
function CacheSlotPref:slotTreasureCanStep(slotId)
    return self:slotModuleRedDot(ModuleSub.eTreasureStepUp, "TreasureCanStep", slotId)
end

-- 删除所有的一键上阵装备信息(避免出现小红点刷新不及时)
function CacheSlotPref:deleteSlotEquipPref()
    for _,v in pairs(self.mSlotPrefData) do
        v.EquipPref = {}
        v.PetPref = {}
    end
    -- 计算完成后通知一下关注者
    Notification:postNotification(EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation))
end

return CacheSlotPref