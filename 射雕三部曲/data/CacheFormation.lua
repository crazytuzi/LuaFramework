--[[
文件名:CacheFormation.lua
描述：阵容数据抽象类型，可以实例化玩家自己的阵容数据，也可以实例化其他玩家阵容的数据，并提供相关的辅助函数
创建人：liaoyuangang
创建时间：2016.04.27
--]]

-- 阵容数据说明
--[[
-- 服务器返回的队伍卡槽数据为：
    {
        {
            "SlotId"      = 1
            "HeroId"      = "2ffb0214-b369-4488-b43c-8ddb3041921f"
            "ModelId" = 12010001
            "RebornLvModelId" = 161000
            "FAP"         = 87977
            "Property" = {
                "AP"         = 9271
                "AP1"        = 760
                "AP2"        = 7591
                "APAdd"      = 10
                "APR1"       = 0
                "APR2"       = 2200
                "BCP"        = 0
                "BCPR"       = 0
                "BLO"        = 0
                "BOG"        = 0
                "CP"         = 0
                "CPR"        = 0
                "CRI"        = 0
                "CRId"       = 0
                "DAMADD"     = 0
                "DAMADDR"    = 0
                "DAMCUT"     = 0
                "DAMCUTR"    = 0
                "DEF"        = 270
                "DEF1"       = 252
                "DEF2"       = 252
                "DEFAdd"     = 3
                "DEFR1"      = 0
                "DEFR2"      = 600
                "DOD"        = 0
                "FAP"        = 87977
                "FSP"        = 100
                "HIT"        = 10000
                "HP"         = 5707
                "HP1"        = 5318
                "HP2"        = 5318
                "HPAdd"      = 70
                "HPR1"       = 0
                "HPR2"       = 600
                "PVPDAMADDR" = 0
                "PVPDAMCUTR" = 0
                "RP"         = 50
                "TEN"        = 0
                "TEND"       = 0
            }
            "Weapon" = {
                "EquipModelId" = 13010760
                "GemId"        = "00000000-0000-0000-0000-000000000000"
                "GemModelID"   = 0
                "Id"           = "97083a47-96fd-4a75-9167-3969f97915fa"
                "Lv"           = 134
                "Step"         = 3
            }
            "Clothes" = {
            }
            "Helmet" = {
            }
            "Necklace" = {
            }
            "Shoes" = {
            }
            "Pants" = {
            }
            Book" = {
            }
            "Zhenjue" = {
                1 = *MAX NESTING*
                2 = *MAX NESTING*
                3 = *MAX NESTING*
                4 = *MAX NESTING*
                5 = *MAX NESTING*
                6 = *MAX NESTING*
            }
            "WeaponImprint" = {
                "Lv" = 0, --宝石等级
                "ModelId" = 30013111, --模型id
                "Id" = "af945377-d0f7-44f5-a3fb-ab6216388390", --实例id
                "AttrIdStr" = "1", -- 随机属性id
                "TotalExp" = 0, -- 强化获得的总经验
                "IsCombat" = false -- 是否上阵
            }
            "ClothesImprint" = {
            }
            "HelmetImprint" = {
            }
            "NecklaceImprint" = {
            }
            "ShoesImprint" = {
            }
            "PantsImprint" = {
            }
        }
        ....
    },
-- 服务器返回的江湖后援团卡槽数据为：
    {
        {  -- 已上阵江湖后援团卡槽信息
            "SlotId"      = 1
            "HeroId"      = "2f797e7b-7a52-473c-ba16-1518b051cdc8"
            "HeroModelId" = 12011013
            "RebornStep"  = 0
            "Step"        = 0
        },
        { -- 已开启，但还未上阵江湖后援团卡槽信息
            "SlotId"      = 2
            "HeroId"      = "00000000-0000-0000-0000-000000000000"
            "HeroModelId" = 0
            "RebornStep"  = 0
            "Step"        = 0
        }
        ...
    }
-- 服务器返回的布阵信息为：
    {
        "Formation1" = 4
        "Formation2" = 6
        "Formation3" = 5
        "Formation4" = 2
        "Formation5" = 1
        "Formation6" = 3
    }
-- 服务器返回的宠物布阵信息为：
    PetFormationInfo
    {
        FormationStr = "4,5,6,1,2,3"
    }
--]]

-- “返回羁绊信息说明”
--[[
-- 返回羁绊信息列表中每个条目的格式为
    {
        prName: 羁绊的名称
        prIntro: 羁绊详情介绍,该字段可以直接用于显示（如：与犬夜叉、杀生丸同时上阵，攻击+1000,防御+1000）
        havePr: 是否已达成羁绊
        memberList: 该羁绊的成员列表
        {
            [ModelId] = {
                resourcetypeSub: 资源类型
                palyerHave: 玩家是否拥有
            }
        }
    }
]]

-- 卡槽数据变化的权重枚举，主要用户查找玩家当前操作的是哪个卡槽
-- 权重由高到低为：上阵人物(7)、上阵装备(6)、下阵装备(5)、上阵内功心法(4)、下阵内功心法(3)、上阵外功秘籍(2)、战力变化(1)
local SlotChangeWeight = {
    eHeroCombat = 8,    -- 上阵人物
    eEquipCombat = 7,   -- 上阵装备
    eEquipUncombat = 6, -- 卸下装备
    eZhenjueCombat = 5, -- 上阵内功心法
    eZhenjueUncombat = 4, -- 下阵内功心法
    ePetCombat = 3, -- 上阵外功秘籍
    ePetUnCombat = 2, -- 下阵外功秘籍
    eFAPChange = 1, -- 战力变化
}


local CacheFormation = class("CacheFormation", {})

--[[
-- 参数
    isMyself: 是否是玩家自己的阵容信息, 默认为false
]]
function CacheFormation:ctor(isMyself)
    -- 是否是玩家自己的阵容信息
    self.mIsMyself = isMyself
    -- 其他玩家基本信息
    self.mOtherPlayerInfo = {}
    -- 阵容卡槽个数（包括江湖后援团入口位置）
    self.mMaxSlotCount = 7
    -- 可上阵江湖后援团的最大个数
    self.mMaxMateCount = 10
    -- Vip开启卡槽的起始Index
    self.mVipMateStartIndex = 9
    -- Vip开启卡槽的数量
    self.VipMateMaxCount = 2
    -- 纠正卡槽个数，具体个数已配置文件为准
    self:initSlotCount()

    -- 清空管理对象中的数据
	self:reset()

    -- 阵容数据中装备名字段名列表
    self.mEquipTypeNameList = {
        [ResourcetypeSub.eHelmet] = "Helmet",
        [ResourcetypeSub.eWeapon] = "Weapon",
        [ResourcetypeSub.eNecklace] = "Necklace",
        [ResourcetypeSub.eClothes] = "Clothes",
        [ResourcetypeSub.ePants] = "Pants",
        [ResourcetypeSub.eShoe] = "Shoes",
        [ResourcetypeSub.eBook] = "Book",
    }
    -- 宝石部位类型列表
    self.mImprintTypeList = {
        ResourcetypeSub.eHelmet,
        ResourcetypeSub.eWeapon,
        ResourcetypeSub.eNecklace,
        ResourcetypeSub.eClothes,
        ResourcetypeSub.ePants,
        ResourcetypeSub.eShoe,
    }
end

-- 初始化卡槽个数
function CacheFormation:initSlotCount()
    require("Config.AttrtreeSlotRelation")
    require("Config.VipSlotRelation")

    -- 计算Vip开启江湖后援团卡槽的最大个数
    self.VipMateMaxCount = 0
    for index, item in pairs(VipSlotRelation.items or {}) do
        self.mVipMateStartIndex = math.min(self.mVipMateStartIndex, index)
        self.VipMateMaxCount = self.VipMateMaxCount + 1
    end

    -- 计算点星开启江湖后援团的最大个数
    local tempCount = 0
    local mateStarIndexIncr = 20
    for index, item in pairs(AttrtreeSlotRelation.items or {}) do
        if index > mateStarIndexIncr then
            tempCount = tempCount + 1
        end
    end

    -- 江湖后援团的最大个数
    self.mMaxMateCount = tempCount + self.VipMateMaxCount
end

-- 清空管理对象中的数据
function CacheFormation:reset()
    self.mSlotInfo = {}
    self.mMateInfo = {}
    self.mEmbattleInfo = {}
    self.mPetFormationInfo = {}

    self:resetAssistCache()
end

----------------------------------------------------------------------------------------------------
-- 私有接口：整理缓存信息

-- 重置辅助缓存
function CacheFormation:resetAssistCache()
    self.mSlotHeros = {count = 0}       -- 卡槽人物信息
    self.mMateHeros = {count = 0}       -- 江湖后援团人物信息

    self.mEquips = {count = 0}          -- 上阵装备信息
    self.mTreasures = {count = 0}       -- 上阵神兵信息
    self.mZhenjues = {count = 0}        -- 上阵新妖灵信息
    self.mZhenyuans = {count = 0}       -- 上阵真元信息
    self.mPets = {count = 0}            -- 上阵的外功秘籍信息
    self.mImprints = {}                 -- 上阵的外功秘籍信息

    self.mHeroModels = {}               -- 上阵人物的模型Id列表，包含江湖后援团 {[modelId] = 1 or 2} -- 2表示江湖后援团

    -- 上阵人物的羁绊成员信息, 格式为：
    --[[ 
        {
            [slotId] = {
                {
                    memberList = {{modelId1, ...}, {modelId1, ...}, ...},  -- 该卡槽的羁绊成员列表  
                    lackList = {{modelId1, ...}, {modelId1, ...}, ... },  -- 达成该卡槽羁绊还缺少的成员模型Id列表
                }
            }
            ...
        }
    ]]
    self.mSlotPrMemberInfo = {} 

    -- 格式为
    --[[
        {
            [slotId] = {
                [modelId] = {}
            }
        }
    ]]  
    self.mSlotEquipList = {} 
end

-- 刷新阵容辅助缓存，主要用于数据获取时效率优化
function CacheFormation:refreshAssistCache()
    -- 重置辅助缓存
    self:resetAssistCache()

    -- 整理一个卡槽的装备信息
    local function dealOneSlotEquip(slotInfo)
        local equipList = self.mSlotEquipList[slotInfo.SlotId]
        for _, typeName in pairs(self.mEquipTypeNameList) do
            local tempEquip = slotInfo[typeName]
            if tempEquip and Utility.isEntityId(tempEquip.Id) then
                local tempItem = {
                    Id = tempEquip.Id,
                    ModelId = tempEquip.ModelId,
                    slotId = slotInfo.SlotId,
                }
                equipList[tempEquip.ModelId] = tempItem

                -- 统计上阵装备和神兵
                if Utility.isEquip(Utility.getTypeByModelId(tempEquip.ModelId)) then
                    self.mEquips.count = self.mEquips.count + 1
                    self.mEquips[tempEquip.Id] = tempItem
                else
                    self.mTreasures.count = self.mTreasures.count + 1
                    self.mTreasures[tempEquip.Id] = tempItem
                end
            end
        end
    end 

    -- 整理一个卡槽的内功心法信息
    local function dealOneSlotZhenjue(slotInfo)
        for _, zhenjue in pairs(slotInfo.Zhenjue or {}) do
            if Utility.isEntityId(zhenjue.Id) then
                self.mZhenjues.count = self.mZhenjues.count + 1
                self.mZhenjues[zhenjue.Id] = {
                    Id = zhenjue.Id,
                    ModelId = zhenjue.ModelId,
                    slotId = slotInfo.SlotId,
                }
            end
        end
    end

    -- 整理一个卡槽的真元信息
    local function dealOneSlotZhenyuan(slotInfo)
        for _, zhenyuan in pairs(slotInfo.ZhenYuan or {}) do
            if Utility.isEntityId(zhenyuan.Id) then
                self.mZhenyuans.count = self.mZhenyuans.count + 1
                self.mZhenyuans[zhenyuan.Id] = {
                    Id = zhenyuan.Id,
                    ModelId = zhenyuan.ModelId,
                    slotId = slotInfo.SlotId,
                }
            end
        end
    end

    -- 整理一个卡槽的外功秘籍信息
    local function dealOneSlotPet(slotInfo)
        local petId = (type(slotInfo.Pet) == "table") and slotInfo.Pet.Id or slotInfo.Pet
        if Utility.isEntityId(petId) then
            self.mPets.count = (self.mPets.count or 0) + 1
            self.mPets[petId] = {
                Id = petId, 
                ModelId = slotInfo.Pet.ModelId,
                slotId = slotInfo.SlotId
            }
        end
    end

    -- 整理一个卡槽羁绊成员信息
    local function dealOneSlotPrMemberInfo(slotInfo)
        self.mSlotPrMemberInfo[slotInfo.SlotId] = {}

        local relations = HeroPrRelation.items[slotInfo.ModelId]
        if not relations then
            return 
        end

        local slotPrInfo = self.mSlotPrMemberInfo[slotInfo.SlotId]
        for index, relation in pairs(relations) do
            -- 单个羁绊字符串
            local prModelItem = PrModel.items[relation.PRModelId]
            local prModelIdsList = ConfigFunc:getPrMember(prModelItem)

            local tempItem = {memberList = {}, lackList = {}}
            slotPrInfo[index] = tempItem

            for _, prModelIds in ipairs(prModelIdsList) do
                local haveMember = false
                if Utility.isHero(prModelItem.typeID) then
                    if self.mHeroModels[prModelIds[1]] then
                        haveMember = true
                    end
                else 
                    local slotEquips = self.mSlotEquipList[slotInfo.SlotId]
                    for _, prModelId in pairs(prModelIds) do
                        if slotEquips and slotEquips[prModelId] then
                            haveMember = true
                            break
                        end
                    end
                end

                table.insert(tempItem.memberList, prModelIds) 
                if not haveMember then
                    table.insert(tempItem.lackList, prModelIds) 
                end
            end
        end
    end

    -- 整理一个卡槽宝石信息
    local function dealOneSlotImprint(slotInfo)
        self.mImprints[slotInfo.SlotId] = {}
        for _, slotType in pairs(self.mImprintTypeList) do
            local imprintItem = slotInfo[Utility.getImprintTypeString(slotType)]
            if imprintItem and next(imprintItem) then
                imprintItem.slotType = slotType
                table.insert(self.mImprints[slotInfo.SlotId], imprintItem)
            end
        end
    end

    -- 整理上阵卡槽中信息
    for index, slotInfo in pairs(self.mSlotInfo or {}) do
        self.mSlotEquipList[index] = {}

        -- 如果是其它玩家的整容信息
        if slotInfo.Hero then
            slotInfo.HeroId = slotInfo.Hero.Id or slotInfo.HeroId
            slotInfo.ModelId = slotInfo.Hero.ModelId or slotInfo.ModelId
        end

        if Utility.isEntityId(slotInfo.HeroId) then
            -- 统计上阵卡槽人物信息
            self.mSlotHeros.count = self.mSlotHeros.count  + 1
            self.mSlotHeros[slotInfo.HeroId] = {
                Id = slotInfo.HeroId, 
                HeroModelId = slotInfo.ModelId,
                slotId = slotInfo.SlotId
            }
            self.mHeroModels[slotInfo.ModelId] = 1

            -- 整理一个卡槽的装备/内功心法/外功秘籍信息
            dealOneSlotEquip(slotInfo)
            dealOneSlotZhenjue(slotInfo)
            dealOneSlotZhenyuan(slotInfo)
            dealOneSlotPet(slotInfo)
        end
        -- 整理宝石
        dealOneSlotImprint(slotInfo)
    end

    -- 统计江湖后援团信息
    local tempInfo = self.mMateInfo or {}
    self.mMateInfo = {}
    for index, mateInfo in pairs(tempInfo) do
        if Utility.isEntityId(mateInfo.HeroId) then
            self.mMateHeros.count = self.mMateHeros.count + 1
            self.mMateHeros[mateInfo.HeroId] = {
                Id = mateInfo.HeroId, 
                ModelId = mateInfo.ModelId,
                slotId = mateInfo.SlotId
            }
            self.mHeroModels[mateInfo.ModelId] = 2
        end
        self.mMateInfo[mateInfo.SlotId] = mateInfo
    end

    -- 整理一个卡槽羁绊成员信息, 必须把其它信息整理完了才能进行
    for index, slotInfo in pairs(self.mSlotInfo or {}) do
        if Utility.isEntityId(slotInfo.HeroId) then
            dealOneSlotPrMemberInfo(slotInfo)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- 对外接口：设置/更新阵容相关的数据

-- 设置阵容信息（卡槽信息、江湖后援团信息、布阵信息）
function CacheFormation:setFormation(slotInfos, mateInfos, embattleInfo, petFormationInfo)
    self.mSlotInfo = slotInfos or {}
    self.mMateInfo = mateInfos or {}
    self.mEmbattleInfo = embattleInfo or {}
    self:updatePetFormationInfo(petFormationInfo)

    -- 刷新阵容辅助缓存，主要用于数据获取时效率优化
    self:refreshAssistCache()
end

-- 设置其他玩家基本属性,其他玩家整容数据对象需要调用该接口
function CacheFormation:setOtherPlayerInfo(otherPlayerInfo)
    self.mOtherPlayerInfo = otherPlayerInfo or {}
end

-- 修改阵容中部分卡槽的信息
function CacheFormation:updateSlotInfos(slotInfos)
    -- 保存旧数据
    local oldSlotInfo = clone(self.mSlotInfo)

    -- 获取旧阵容的经脉共鸣等级
    local oldRebornLvs = Utility.getActiveRebornLv()

    -- 判断卡槽变化
    local slotDiffInfos = self:getSlotDiff(self.mSlotInfo, slotInfos)
	for _, slotItem in pairs(slotInfos or {}) do
        if slotItem.SlotId then
            self.mSlotInfo[slotItem.SlotId] = slotItem

            if self.mIsMyself and (slotItem.SlotId == 1) then -- 修改主角的模型Id
                HeroObj:modifyMainHeroModelId(slotItem.ModelId)
            end
        end
    end
    -- 通知卡槽属性变化
    Notification:postNotification(EventsName.eSlotAttrChanged)

	-- 刷新阵容辅助缓存，主要用于数据获取时效率优化
    self:refreshAssistCache()

    -- 新阵容的经脉共鸣等级
    local newRebornLvs = Utility.getActiveRebornLv()
    print(string.format("经脉共鸣等级变化:  %d -> %d ", oldRebornLvs, newRebornLvs))

    -- 判断是否允许弹出动画
    if (self:isCanShowAttrChangeAction() == false) then
        return
    end

    -- 显示卡槽属性变化
    local function endFunc()
        self:showSlotAttrChange(slotDiffInfos)
    end
    -- 显示合体技和培养共鸣的激活提示（两者不会同时出现，因为分别对应人物和装备）
    local oldMasterLvs = ConfigFunc:getMasterLv(oldSlotInfo) or {}
    local newMasterLvs = ConfigFunc:getMasterLv(slotInfos) or {}
    
    local ret1 = self:showJointActiveTips(oldSlotInfo, slotInfos, function ()
            self:showRebornMasterTips(oldRebornLvs, newRebornLvs, endFunc)
        end)
    local ret2 = self:showEquipMasterTips(oldMasterLvs, newMasterLvs, endFunc)
    -- 如果合体技没有触发弹窗, 则判断经脉共鸣的弹窗
    local ret3
    if ret1 == nil then
        ret3 = self:showRebornMasterTips(oldRebornLvs, newRebornLvs, endFunc)
    end

    if (ret1 == nil) and (ret2 == nil) and (ret3 == nil) then
        -- 如果返回值为ni，说明不会弹出激活框
        endFunc()
    end
end

-- 设置江湖后援团卡槽信息
function CacheFormation:updateMateInfos(mateInfos)
    local diffMateInfo = {}  -- 每个条目为： {heroModelId = 0, isCombat = false}
    for _, newItem in pairs(mateInfos) do
        local oldItem = nil 
        for _, item in pairs(self.mMateInfo or {}) do
            if item.SlotId == newItem.SlotId then
                oldItem = item
                break
            end
        end
        if oldItem and oldItem.ModelId ~= newItem.ModelId then
            local tempItem = {}
            if Utility.isEntityId(newItem.HeroId) then
                tempItem.heroModelId = newItem.ModelId
                tempItem.isCombat = true
            else
                tempItem.heroModelId = oldItem.ModelId
                tempItem.isCombat = false
            end
            table.insert(diffMateInfo, tempItem)
        end
    end

	self.mMateInfo = mateInfos
	-- 刷新阵容辅助缓存，主要用于数据获取时效率优化
    self:refreshAssistCache()

    -- 显示因为江湖后援团变化引起的羁绊属性变化
    for _, item in pairs(diffMateInfo) do
        if item.isCombat then
            self:showPrChangeByHero(item.heroModelId, true)
        end
    end
end

-- 设置布阵信息
function CacheFormation:updateEmbattleInfo(embattleInfo)
    self.mEmbattleInfo = embattleInfo or {}
end

-- 设置宠物布阵信息
function CacheFormation:updatePetFormationInfo(petFormationInfo)
    self.mPetFormationInfo = petFormationInfo or {}
end

----------------------------------------------------------------------------------------------------

-- 是否可以弹出属性变化的动画
function CacheFormation:isCanShowAttrChangeAction()
    if (self.isEnableShowAttrChangeAction ~= nil) and (self.isEnableShowAttrChangeAction == false) then
        return false
    end
    return true
end

-- 允许/停止弹出属性变化的动画
function CacheFormation:enableShowAttrChangeAction(flag)
    self.isEnableShowAttrChangeAction = flag
end

----------------------------------------------------------------------------------------------------

-- 获取阵容数据的变化值
--[[
-- 返回值的格式为
    {
        currSlotId = nil, 
        [slotId] = {
            slotWeight = 0, -- 改卡槽数据变化的权重值
            FAP = 0, -- 
            Hero = {
                oldHeroId = nil, -- 
                oldHeroModelId = nil, --
                HeroId = nil, -- 
                ModelId = nil, --
            },
            Equip = {
                Weapon = {
                    oldId = nil,
                    oldEquipModelId = nil
                    Id = nil,
                    EquipModelId = nil
                },
                ...

                Book = {
                    oldId = nil,
                    oldTreasureModelId = nil
                    Id = nil,
                    TreasureModelId = nil
                },
            },
            Zhenjue = {
                [1] = {
                    oldId = nil
                    Id = nil
                }
                ...
            },
            Pet = {
                oldId = nil
                Id = nil
            },
            Property = {
                AP = 0,
                HP = 0,
                DEF = 0,
            },
        }
    }
]]
function CacheFormation:getSlotDiff(oldSlotInfos, newSlotInfos)
    local ret = {}
    if not oldSlotInfos or not next(oldSlotInfos) then
        return
    end

    -- 比较一个卡槽
    local function compareOneSlot(oldSlot, newSlot, slotId)
        if not newSlot or not Utility.isEntityId(newSlot.HeroId) then
            return
        end
        local tempItem = {slotWeight = 0}
        ret[slotId] = tempItem

        -- 计算战力差值
        tempItem.FAP = newSlot.FAP - (oldSlot and oldSlot.FAP or 0)
        if tempItem.FAP ~= 0 then
            tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.eFAPChange
        end

        -- 计算属性变化值
        tempItem.Property = {}
        for key, value in pairs(newSlot.Property) do
            local function getOnePropertyValue(key, property)
                local tempValue = 0
                if not property then
                    return tempValue
                end

                tempValue = property[key] or 0
                if (tempValue < 0) then
                    tempValue = 0
                end

                return tempValue
            end

            local oldValue = getOnePropertyValue(key, oldSlot and oldSlot.Property or {})
            local newValue = getOnePropertyValue(key, newSlot.Property)
            tempItem.Property[key] = newValue - oldValue
        end

        -- 比较上阵人物
        if not oldSlot or oldSlot.HeroId ~= newSlot.HeroId then
            tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.eHeroCombat

            local tempHero = {}
            tempItem.Hero = tempHero

            tempHero.HeroId = newSlot.HeroId
            tempHero.oldHeroId = oldSlot.HeroId
            if not oldSlot or oldSlot.ModelId ~= newSlot.ModelId then
                tempHero.ModelId = newSlot.ModelId
                tempHero.oldModelId = oldSlot.ModelId
            end
        end

        -- 比较装备
        for restypeSub, typeName in pairs(self.mEquipTypeNameList) do
            local oldEquip, newEquip = oldSlot and oldSlot[typeName] or {}, newSlot[typeName] or {}
            if oldEquip.Id ~= newEquip.Id then -- 上阵装备修改
                tempItem.Equip = tempItem.Equip or {}
                local tempEquip = {}
                tempItem.Equip[typeName] = tempEquip
                tempEquip.oldId = oldEquip.Id
                tempEquip.Id = newEquip.Id

                if Utility.isEntityId(newEquip.Id) then  -- 上阵
                    tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.eEquipCombat
                else
                    tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.eEquipUncombat
                end

                if Utility.isTreasure(restypeSub) then
                    if oldEquip.TreasureModelId ~= newEquip.TreasureModelId then
                        tempEquip.TreasureModelId = newEquip.TreasureModelId
                        tempEquip.oldTreasureModelId = oldEquip.TreasureModelId
                    end
                else
                    if oldEquip.EquipModelId ~= newEquip.EquipModelId then
                        tempEquip.EquipModelId = newEquip.EquipModelId
                        tempEquip.oldEquipModelId = oldEquip.EquipModelId
                    end
                end
            end
        end
        -- 比较内功心法
        for index = 1, 6 do
            local oldZhenjue = oldSlot and oldSlot.Zhenjue and oldSlot.Zhenjue[index] or {}
            local newZhenjue = newSlot.Zhenjue and newSlot.Zhenjue[index] or {}
            if oldZhenjue.Id ~= newZhenjue.Id then
                if Utility.isEntityId(newZhenjue.Id) then  -- 上阵
                    tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.eZhenjueCombat
                else
                    tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.eZhenjueUncombat
                end

                local tempZhenjue = {}
                tempItem.Zhenjue = tempItem.Zhenjue or {}
                tempItem.Zhenjue[index] = tempZhenjue

                tempZhenjue.oldId = oldZhenjue.Id
                tempZhenjue.Id = newZhenjue.Id
            end
        end

        -- 比较外功秘籍
        local isOldHavePet, isNewHavePet = false, false
        if oldSlot and oldSlot.Pet and next(oldSlot.Pet) ~= nil and Utility.isEntityId(oldSlot.Pet.Id) then
            isOldHavePet = true
        end
        if newSlot and oldSlot.Pet and next(newSlot.Pet) ~= nil and Utility.isEntityId(newSlot.Pet.Id) then
            isNewHavePet = true
        end
        if (isNewHavePet and isOldHavePet and oldSlot.Pet.Id ~= newSlot.Pet.Id) or (not isOldHavePet and isNewHavePet)
            or (isOldHavePet and not isNewHavePet) then
            if isNewHavePet then
                tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.ePetCombat
            else
                tempItem.slotWeight = tempItem.slotWeight + SlotChangeWeight.ePetUnCombat
            end

            tempItem.Pet = {}
            tempItem.Pet.Id = isNewHavePet and newSlot.Pet.Id or EMPTY_ENTITY_ID
            tempItem.Pet.oldId = isOldHavePet and oldSlot.Pet.Id or EMPTY_ENTITY_ID
        end
    end

    for _, newSlot in pairs(newSlotInfos) do
        compareOneSlot(oldSlotInfos[newSlot.SlotId], newSlot, newSlot.SlotId)
    end

    local currSlotId 
    for slotId, changeItem in pairs(ret) do
        if not currSlotId or ret[currSlotId].slotWeight < changeItem.slotWeight then
            currSlotId = slotId
        end
    end
    -- 计算得到当前操作的卡槽
    ret.currSlotId = currSlotId

    return ret
end

-- 显示卡槽的合体技变化
function CacheFormation:showJointActiveTips(oldSlotInfos, newSlotInfos, callback)
    if not oldSlotInfos or not next(oldSlotInfos) then
        return
    end

    -- 找出发生变化的卡槽人物
    local changeHeroModelId = nil
    local changeHeroIllusion = nil
    for _, newSlot in pairs(newSlotInfos) do
        local oldSlot = oldSlotInfos[newSlot.SlotId]
        local oldHeroModelId, newHeroModelId = 0, (newSlot.ModelId or 0)
        if (oldSlot ~= nil) then
            oldHeroModelId = oldSlot.ModelId or 0
        end
        if (oldHeroModelId ~= newHeroModelId) then
            changeHeroModelId = newHeroModelId
            changeHeroIllusion = HeroObj:getHero(newSlot.HeroId).IllusionModelId
            break
        end
    end
    if (changeHeroModelId == nil) then
        return
    end

    -- 判断该人是否有合体技
    local heroModel = IllusionModel.items[changeHeroIllusion] or HeroModel.items[changeHeroModelId]
    if (heroModel == nil) or (heroModel.jointID == nil) or (heroModel.jointID == 0) then
        return
    end
    
    -- 判断该合体技是否激活
    if (self:isHeroJointActive(heroModel.jointID) == false) then
        return
    end

    -- 弹出激活对话框
    local newLayer = require("team.ActiveJointLayer").new({jointId = heroModel.jointID, callback = callback})
    LayerManager.getMainScene():addChild(newLayer, Enums.ZOrderType.eNewbieGuide + 1)
    return true
end

-- 显示卡槽的培养共鸣变化
function CacheFormation:showEquipMasterTips(oldMasterLvs, newMasterLvs, callback)
    local changeType, changeStepLv, changeStarLv = nil, nil, nil
    for k,v in pairs(newMasterLvs) do
        local oldItem = oldMasterLvs[k] or {}
        local oldStepLv, oldStarLv = oldItem.StepLv or 0, oldItem.StarLv or 0
        
        local newStepLv, newStarLv = v.StepLv or 0, v.StarLv or 0
        if (newStepLv ~= oldStepLv) or (newStarLv ~= oldStarLv) then
            changeType = k
            changeStepLv = (newStepLv ~= oldStepLv) and newStepLv or 0
            changeStarLv = (newStarLv ~= oldStarLv) and newStarLv or 0
            break
        end
    end
    if (changeType == nil) or ((changeStepLv == 0) and (changeStarLv == 0)) then
        return
    end

    -- 弹出激活对话框
    local newLayer = require("team.ActiveEquipMasterLayer").new({equipType = changeType, activeStepLv = changeStepLv, activeStarLv = changeStarLv, callback = callback})
    LayerManager.getMainScene():addChild(newLayer, Enums.ZOrderType.eNewbieGuide + 1)
    return true
end

-- 显示卡槽的经脉共鸣变化
function CacheFormation:showRebornMasterTips(oldRebornLvs, newRebornLvs, callback)
    if newRebornLvs == oldRebornLvs then
        return
    end

    -- 弹出激活对话框
    local newLayer = require("hero.ActiveRebornMasterLayer").new({
            rebornLv = newRebornLvs,
            callback = callback
        })
    LayerManager.getMainScene():addChild(newLayer, Enums.ZOrderType.eNewbieGuide + 1)
    return true
end

-- 显示卡槽属性变化
function CacheFormation:showSlotAttrChange(slotDiffInfos)
    local currSlotId = slotDiffInfos and slotDiffInfos.currSlotId
    local changeInfo = currSlotId and slotDiffInfos[currSlotId]
    if not changeInfo then
        return
    end
    --local showAttrNames = {"AP", "HP", "DEF"}
    local showAttrNames = {"STR", "CON", "INTE", "AP", "DEF", "HP", "HIT", "DOD", "CRI", "TEN", "BOG", "BLO", "CRID", "TEND"}

    -- 如果只有战力变化，说明玩家当前在操作某一卡槽，要么是公共模块操作引起的所有多个卡槽属性变化，这种情况需要叠加显示
    if changeInfo.slotWeight == SlotChangeWeight.eFAPChange then
        -- 所有改变卡槽战力变化的总和
        local FAPSum = 0
        -- 属性变化的总和
        local propertySum = {}
        for key, changeItem in pairs(slotDiffInfos) do
            if key ~= "currSlotId" then
                FAPSum = FAPSum + changeItem.FAP
                for _, attrName in ipairs(showAttrNames) do
                    local tempValue = changeItem.Property[attrName]
                    if tempValue then
                        propertySum[attrName] = (propertySum[attrName] or 0) + tempValue
                    end
                end
            end
        end
        -- 显示变化的属性
        if FAPSum ~= 0 then
            local tempItem = {}
            local valueColor = FAPSum > 0 and Enums.Color.eGreen or Enums.Color.eRed
            tempItem.Name = TR("战力")
            tempItem.Value = FAPSum
            tempItem.Color = valueColor
            tempItem.HintBgImg = "c_41.png"
            tempItem.HintStr = string.format("%+d", FAPSum)
            FlashHintObj:addHintInfo(tempItem)
        end
        -- 攻击、防御、血量
        for index, value in ipairs(showAttrNames) do
            local tempValue = propertySum[value]
            if tempValue and tempValue ~= 0 then
                local tempItem = {}
                local valueColor = tempValue > 0 and Enums.Color.eGreen or Enums.Color.eRed
                tempItem.Name = ConfigFunc:getViewNameByFightName(value)
                tempItem.Value = tempValue
                tempItem.Color = valueColor
                tempItem.HintStr = string.format("%s: %+d", tempItem.Name, tempValue)
                FlashHintObj:addHintInfo(tempItem)
            end
        end
    else
        -- 战力
        if changeInfo.FAP ~= 0 then
            local tempItem = {}
            local valueColor = changeInfo.FAP > 0 and Enums.Color.eGreen or Enums.Color.eRed
            tempItem.Name = TR("战力")
            tempItem.Value = changeInfo.FAP
            tempItem.Color = valueColor
            tempItem.HintBgImg = "c_41.png"
            tempItem.HintStr = string.format("%+d", changeInfo.FAP)
            FlashHintObj:addHintInfo(tempItem)
        end
        -- 攻击、防御、血量
        for index, value in ipairs(showAttrNames) do
            local tempValue = changeInfo.Property[value]
            if tempValue and tempValue ~= 0 then
                local tempItem = {}
                local valueColor = tempValue > 0 and Enums.Color.eGreen or Enums.Color.eRed
                tempItem.Name = ConfigFunc:getViewNameByFightName(value)
                tempItem.Value = tempValue
                tempItem.Color = valueColor
                tempItem.HintStr = string.format("%s: %+d", tempItem.Name, tempValue)
                FlashHintObj:addHintInfo(tempItem)
            end
        end
        -- 判断人物改变引起的羁绊变化
        if changeInfo.Hero then
            if changeInfo.Hero.ModelId then
                self:showPrChangeByHero(changeInfo.Hero.ModelId, true)
            end
        end

        -- 判断装备变化引起的羁绊变化
        if changeInfo.Equip then
            local changeGroupList = {}
            for restypeSub, typeName in pairs(self.mEquipTypeNameList) do
                local tempEquip = changeInfo.Equip[typeName]
                if tempEquip and tempEquip.Id then
                    -- 如果是下阵，则里面的内容由 Id 变成 oldId
                    local equipInfo = Utility.isTreasure(restypeSub) and TreasureObj:getTreasure(tempEquip.Id) or EquipObj:getEquip(tempEquip.Id)
                    if equipInfo then
                        -- 判断装备引起的缘分变化
                        self:showPrChangeByEquip(equipInfo.ModelId, true, currSlotId)
                        
                        -- 判断装备套装的变化，避免同时上阵多件装备就重复报多次激活
                        local retItem = self:showEquipGroupChange(equipInfo.ModelId, currSlotId)
                        if (retItem ~= nil) and (retItem.groupName ~= nil) and (changeGroupList[retItem.groupName] == nil) then
                            changeGroupList[retItem.groupName] = retItem
                        end
                    end
                end
            end
            for _,v in pairs(changeGroupList) do
                local tempItem = {}
                tempItem.Color = Enums.Color.eGreen
                tempItem.HintStr = TR("%s[%s]%s套装的%s%d件%s效果已激活", 
                    Enums.Color.eGoldH, v.groupName, Enums.Color.eGreenH, 
                    Enums.Color.eGoldH, v.groupNum, Enums.Color.eGreenH
                )
                FlashHintObj:addHintInfo(tempItem)
            end
        end

        -- 判断外功改变引起的羁绊变化
        if changeInfo.Pet then
            local petInfo = PetObj:getPet(changeInfo.Pet.Id)
            if petInfo then
                self:showPrChangeByEquip(petInfo.ModelId, true, currSlotId)
            end
        end

        -- 判断内改变引起的羁绊变化
        if changeInfo.Zhenjue then
            for _,zj in pairs(changeInfo.Zhenjue) do
                local zhenjueInfo = ZhenjueObj:getZhenjue(zj.Id)
                if zhenjueInfo then
                    self:showPrChangeByEquip(zhenjueInfo.ModelId, true, currSlotId)
                end
            end
        end
    end
end

-- 显示因为上阵人物变化引起的羁绊变化
function CacheFormation:showPrChangeByHero(heroModelId, isCombat)
    for _, slotInfo in pairs(self.mSlotInfo) do
        local prInfoList, prCount = self:getSlotPrInfo(slotInfo.SlotId)
        if prCount > 0 then
            local heroName = HeroModel.items[slotInfo.ModelId].name
            for _, prInfo in pairs(prInfoList) do
                if prInfo.havePr and prInfo.memberList[heroModelId] then
                    local tempItem = {}
                    tempItem.Color = Enums.Color.eGreen
                    if isCombat then
                        tempItem.HintStr = TR("%s%s%s的%s[%s]%s已激活", 
                            Enums.Color.eGoldH, heroName, Enums.Color.eGreenH, 
                            Enums.Color.eGoldH, prInfo.prName, Enums.Color.eGreenH
                        )
                    end
                    FlashHintObj:addHintInfo(tempItem)
                end
            end
        end
    end
end

-- 显示因为上阵装备变化引起的羁绊变化
function CacheFormation:showPrChangeByEquip(equipModelId, isCombat, slotId)
    local prInfoList, prCount = self:getSlotPrInfo(slotId)
    if prCount == 0 then
        return
    end
    local slotInfo = self.mSlotInfo[slotId]
    local heroName = HeroModel.items[slotInfo.ModelId].name
    for _, prInfo in pairs(prInfoList) do
        if prInfo.havePr and prInfo.memberList[equipModelId] then
            local tempItem = {}
            tempItem.Color = Enums.Color.eGreen
            if isCombat then
                tempItem.HintStr = TR("%s%s%s的%s[%s]%s已激活", 
                    Enums.Color.eGoldH, heroName, Enums.Color.eGreenH, 
                    Enums.Color.eGoldH, prInfo.prName, Enums.Color.eGreenH
                )
            end
            FlashHintObj:addHintInfo(tempItem)
        end
    end
end

-- 显示因为上阵装备变化引起的套装效果变化
function CacheFormation:showEquipGroupChange(equipModelId, slotId)
    local function readGroupId(tmpModelId)
        local tmpBaseInfo = EquipModel.items[tmpModelId] or {}
        return tmpBaseInfo.equipGroupID or 0
    end

    -- 读取当前的套装ID
    local currGroupId = readGroupId(equipModelId)
    if (currGroupId == 0) then
        return
    end

    -- 读取当前卡槽里和新装备的套装ID一样的数量
    local nCount = 0
    local slotInfo = self.mSlotInfo[slotId] or {}
    for _, typeName in pairs({"Weapon", "Helmet", "Clothes", "Necklace", "Pants", "Shoes"}) do
        local equipItem = slotInfo[typeName] or {}
        local tmpGroupId = readGroupId(equipItem.ModelId or 0)
        if (tmpGroupId == currGroupId) then
            nCount = nCount + 1
        end
    end
    if (nCount <= 1) then
        return
    end
    
    -- 读取配置
    local tmpConfigs = EquipGroupActiveRelation.items[currGroupId]
    local groupConfigs = {}
    for _,v in pairs(tmpConfigs) do
        table.insert(groupConfigs, v)
    end
    table.sort(groupConfigs, function (a, b)
            return a.needNum > b.needNum
        end)

    -- 读取最小的套装需求数量
    local minNum = 0
    for _,v in ipairs(groupConfigs) do
        if (nCount >= v.needNum) then
            minNum = v.needNum
            break
        end
    end

    -- 读取套装名
    local nameArray = string.splitBySep(EquipModel.items[equipModelId].name, "·")
    local tempItem = {}
    tempItem.groupName = nameArray[1]
    tempItem.groupNum = minNum
    return tempItem
end

----------------------------------------------------------------------------------------------------
-- 获取羁绊相关的信息

--[[
-- 参数
    prInfos: 羁绊配置列表，其中每项为 PrModel.lua 中的每项
    equipModelIds: 用于判断玩家是否拥有某类型装备的装备模型列表
    notPrColor: 达成羁绊显示的颜色, 默认为绿色
    notPrColor: 没有达成羁绊的颜色，默认为灰色
-- 返回值，
    第一个值，参考文头处的 “返回羁绊信息说明”
    第二个值，达成羁绊的个数
]]
function CacheFormation:getPrInfoList(prInfos, equipModelIds, prColor, notPrColor, heroId)
    prColor = prColor or Enums.Color.ePrColorH
    if type(prColor) == "table" then
        prColor = string.c3bToStr(prColor)
    end
    notPrColor = notPrColor or Enums.Color.eNotPrColorH
    if type(notPrColor) == "table" then
        notPrColor = string.c3bToStr(notPrColor)
    end

    -- 判断转生大师带来的加成 addby-xyh
    local rebornAP, rebornHP, rebronDEF = "", "", ""
    local rebornAPNum1, rebornHPNum1, rebronDEFNum1 = 0, 0, 0
    local rebornAPNum2, rebornHPNum2, rebronDEFNum2 = 0, 0, 0
    if heroId and HeroObj:getHero(heroId) then
        local heroInfo = HeroObj:getHero(heroId) or nil
        local rebornId = heroInfo and heroInfo.RebornId
        local rebornMasterLv = Utility.getActiveRebornLv()

        -- 判断炼神大师带来的羁绊加成
        local rebornLvItem = clone(RebornLvActiveModel.items)
        local natureList, heroNatureList = {}, {}
        if rebornMasterLv and rebornMasterLv > 0 then
            for _, v in pairs(rebornLvItem) do
                if rebornMasterLv >= v.rebornNum then
                    table.insert(natureList, v)
                end
            end
            if #natureList > 0 then
                table.sort(natureList, function(a, b) return a.rebornNum < b.rebornNum end)
                for i, v in ipairs(natureList) do
                    if v.PRType == "APR" then
                        rebornAPNum1 = rebornAPNum1 + v.PRRatio * 100
                    end
                    if v.PRType == "HPR" then
                        rebornHPNum1 = rebornHPNum1 + v.PRRatio * 100
                    end
                    if v.PRType == "DEFR" then
                        rebronDEFNum1 = rebronDEFNum1 + v.PRRatio * 100
                    end
                end
            end
        end

        -- 判断自身炼神带来的羁绊加成
        local ownRebornLvItem = clone(RebornLvModel.items)
        if rebornId and rebornId > 0 then
            for _, v in pairs(ownRebornLvItem) do
                if (HeroModel.items[heroInfo.ModelId].rebornClassID == v.classID)
                    and ownRebornLvItem[rebornId].rebornNum >= v.rebornNum and v.PRRatio ~= 0 then
                    table.insert(heroNatureList, v)
                end
            end

            if #heroNatureList > 0 then
                table.sort(heroNatureList, function(a, b) return a.rebornNum < b.rebornNum end)
                for i,v in ipairs(heroNatureList) do
                    if v.PRType == "APR" then
                        rebornAPNum2 = rebornAPNum2 + v.PRRatio * 100
                    end
                    if v.PRType == "HPR" then
                        rebornHPNum2 = rebornHPNum2 + v.PRRatio * 100
                    end
                    if v.PRType == "DEFR" then
                        rebronDEFNum2 = rebronDEFNum2 + v.PRRatio * 100
                    end
                end
            end
        end
    end

    -- 保留一位小数四舍五入
    local function mathRound(value)
        local valueItem = (value * 10)
        if valueItem % 1 >= 0.5 then
            valueItem = math.ceil(valueItem)
        else
            valueItem = math.floor(valueItem)
        end

        return valueItem * 0.1
    end

    local ret = {}  
    local prCount = 0
    for _, prItem in ipairs(prInfos) do
        local prInfoItem = {memberList = {}}
        table.insert(ret, prInfoItem)

        prInfoItem.havePr = true
        prInfoItem.prName = prItem.name

        local prType = prItem.typeID
        local prMember = ConfigFunc:getPrMember(prItem)

        -- 创建羁绊属性text
        rebornAP = (rebornAPNum1 + rebornAPNum2 > 0) and string.format("(+%s%%)",mathRound(((rebornAPNum1 + rebornAPNum2) * prItem.APR / 10000))) or ""
        rebornHP = (rebornHPNum1 + rebornHPNum2 > 0) and string.format("(+%s%%)", mathRound(((rebornHPNum1 + rebornHPNum2) * prItem.HPR / 10000))) or ""
        rebronDEF = (rebronDEFNum1 + rebronDEFNum2 > 0) and string.format("(+%s%%)", mathRound(((rebronDEFNum1 + rebronDEFNum2) * prItem.DEFR / 10000))) or ""

        -- 整理该羁绊属性加成信息
        local tempList = {}
        if prItem.APR and prItem.APR > 0 then
            table.insert(tempList, string.format("%s%+d%%%s", FightattrName[Fightattr.eAPR], prItem.APR / 100, rebornAP))
        end
        if prItem.HPR and prItem.HPR > 0 then
            table.insert(tempList, string.format("%s%+d%%%s", FightattrName[Fightattr.eHPR], prItem.HPR / 100, rebornHP))
        end
        if prItem.DEFR and prItem.DEFR > 0 then
            table.insert(tempList, string.format("%s%+d%%%s", FightattrName[Fightattr.eDEFR], prItem.DEFR / 100, rebronDEF))
        end
        local attrAddStr = table.concat(tempList, ",")
        local prFormatStr = ""

        -- 整理 羁绊详情的格式化字符串
        local ownModelIdList = {}
        if Utility.isHero(prType) then -- 人物
            ownModelIdList = self.mHeroModels
            prFormatStr = TR("与%s同时上阵") 
        else  -- 装备和神兵
            ownModelIdList = equipModelIds
            prFormatStr = TR("装备%s")
        end

        -- 解析该羁绊的成员信息
        local function foundModelId(prModelIdList)
            for _, modelId in pairs(prModelIdList) do
                if ownModelIdList[modelId] then
                    return true, modelId
                end
            end

            local selModelId = prModelIdList[1]
            if #prModelIdList > 1 and Utility.isEquip(prType) then
                for _, modelId in pairs(prModelIdList) do
                    local selModel = EquipModel.items[selModelId]
                    local tempModel = EquipModel.items[modelId]
                    if tempModel.quality < selModel.quality then
                        selModelId = modelId
                    end
                end
            end

            return false, selModelId
        end
        local ownNameList, lackNameList = {}, {}
        for _, item in pairs(prMember) do
            local haveOne, modelId = foundModelId(item)
            local tempName = Utility.getGoodsName(prType, modelId)
            if haveOne then
                table.insert(ownNameList, tempName)
                prInfoItem.memberList[modelId] = {modelId = modelId, resourcetypeSub = prType, palyerHave = haveOne}
            elseif modelId > 0 then
                prInfoItem.havePr = false
                table.insert(lackNameList, tempName)
                prInfoItem.memberList[modelId] = {modelId = modelId, resourcetypeSub = prType, palyerHave = haveOne}
            end
        end

        -- 整理该羁绊的描述信息
        if prInfoItem.havePr then
            prCount = prCount + 1
            local ownStr = table.concat(ownNameList, ",")
            local tempStr = string.format("%s%s%s", Enums.Color.eNormalGreenH, ownStr, prColor)
            prInfoItem.prIntro = string.format(prFormatStr, tempStr) .. "," .. attrAddStr
        else
            local ownStr = table.concat(ownNameList, ",")
            local lackStr = table.concat(lackNameList, ",")
            local tempStr = ""
            if ownStr ~= "" then
                tempStr = tempStr .. string.format("%s%s%s", Enums.Color.eNormalGreenH, ownStr, prColor)
            end
            if lackStr ~= "" then
                if tempStr ~= "" then
                    tempStr = tempStr .. ","
                end
                tempStr = tempStr .. string.format("%s%s%s", notPrColor, lackStr, prColor)
            end
            prInfoItem.prIntro = string.format(prFormatStr, tempStr) .. "," .. attrAddStr
        end
    end

    -- 删除低级神兵的信息
    local maxQualityTru, maxQualityEquip, maxQualityPet = 18, 25, 15 -- 标记目前的最高阶羁绊
    local maxQualityEquips = {[ResourcetypeSub.eWeapon] = maxQualityEquip, 
        [ResourcetypeSub.eHelmet] = maxQualityEquip, 
        [ResourcetypeSub.eClothes] = maxQualityEquip, 
        [ResourcetypeSub.eNecklace] = maxQualityEquip, 
        [ResourcetypeSub.ePants] = maxQualityEquip, 
        [ResourcetypeSub.eShoe] = maxQualityEquip}
    local isDelTru = false
    local isPetTru = false
    local isDelEquips = {}
    for i=#ret,1,-1 do
        local menKey = next(ret[i].memberList)
        local menInfo = ret[i].memberList[menKey]
        if menInfo.resourcetypeSub == ResourcetypeSub.eBook then
            local treasureQuality = TreasureModel.items[menKey].quality
            if ret[i].havePr and treasureQuality == maxQualityTru then
                -- 标记最高阶的羁绊已激活
                isDelTru = true
            elseif isDelTru then
                -- 删除其它低阶的羁绊
                table.remove(ret, i)
            end
        elseif menInfo.resourcetypeSub == ResourcetypeSub.eWeapon or menInfo.resourcetypeSub == ResourcetypeSub.eHelmet or 
            menInfo.resourcetypeSub == ResourcetypeSub.eClothes or menInfo.resourcetypeSub == ResourcetypeSub.eNecklace or 
            menInfo.resourcetypeSub == ResourcetypeSub.ePants or menInfo.resourcetypeSub == ResourcetypeSub.eShoe then
            --
            local equipQuality = EquipModel.items[menKey].quality
            if ret[i].havePr and equipQuality == maxQualityEquips[menInfo.resourcetypeSub] then
                -- 标记最高阶的羁绊已激活
                isDelEquips[menInfo.resourcetypeSub] = true
            elseif isDelEquips[menInfo.resourcetypeSub] then
                -- 删除其它低阶的羁绊
                table.remove(ret, i)
            end
        elseif menInfo.resourcetypeSub == ResourcetypeSub.ePet then
            local petQuality = PetModel.items[menKey].quality
            if ret[i].havePr and petQuality == maxQualityPet then
                -- 标记最高阶的羁绊已激活
                isPetTru = true
            elseif isPetTru then
                -- 删除其它低阶的羁绊
                table.remove(ret, i)
            end
        end
    end
    return ret, prCount
end

-- 根据人物实例Id获取羁绊信息
--[[
-- 参数
    heroId: 人物的实例Id
    prColor: 达成羁绊显示的颜色, 默认为绿色
    notPrColor: 没有达成羁绊的颜色，默认为灰色
-- 返回值
    第一个值，参考文头处的 “返回羁绊信息说明”
    第二个值，达成羁绊的个数
]]
function CacheFormation:getHeroPrInfo(heroId, prColor, notPrColor)
    local heroInfo = self:getSlotHeroInfo(heroId)
    local prInfoList = ConfigFunc:getHeroPrInfos(heroInfo.ModelId)
    local rerornMasterHeroId = nil

    local equipModels = {}
    local prPetInfo = nil
    if self.mSlotHeros[heroId] then  -- 阵容卡槽人物
        local slotId = self.mSlotHeros[heroId].slotId
        equipModels = self.mSlotEquipList[slotId]
        rerornMasterHeroId = heroId
        -- 添加外功羁绊
        local petInfo = self:getSlotPet(slotId)
        if petInfo then
            equipModels[petInfo.ModelId] = true
            prPetInfo = PetObj:getPet(petInfo.Id)
        end
        -- 添加内功羁绊
        local zhenjueInfo = self:getSlotZhenjue(slotId)
        for _,v in ipairs(zhenjueInfo or {}) do
            if v.ModelId then
                equipModels[v.ModelId] = true
            end
        end
    else -- 未上阵人物 或 江湖后援团
        -- 装备
        local tempLiset = EquipObj:getEquipListAsModelId()
        for key, _ in pairs(tempLiset) do
            equipModels[key] = true
        end
        -- 神兵
        tempLiset = TreasureObj:getTreasureListAsModelId()
        for key, _ in pairs(tempLiset) do
            equipModels[key] = true
        end
        -- 外功
        tempLiset = PetObj:getPetListAsModelId()
        for key, _ in pairs(tempLiset) do
            equipModels[key] = true
        end
        -- 内功
        tempLiset = ZhenjueObj:getZhenjueListAsModelId()
        for key, _ in pairs(tempLiset) do
            equipModels[key] = true
        end
    end

    -- 找到外功的位置
    local prListPetInfoList = {}
    for i,v in ipairs(prInfoList) do
        if v.typeID == ResourcetypeSub.ePet then
            table.insert(prListPetInfoList, v)
            -- 如未上阵人物，则设置基础属性
            if not prPetInfo then
                prPetInfo = {ModelId = tonumber(v.member)}
            end
        end
    end
    -- 外功参悟等级
    local heroPrInfo = PetHeroPrRelation.items[heroInfo.ModelId]
    if heroPrInfo and next(prListPetInfoList) then
        for _, prListPetInfo in pairs(prListPetInfoList) do
            -- 直接获取第一条羁绊属性
            local heroPetPrList = heroPrInfo[tonumber(prListPetInfo.member)]
            local maxIndex = 0
            -- 如是可激活的外功，则判断是否有参悟等级
            if heroPetPrList[maxIndex].petModelId == prPetInfo.ModelId then
                local petStep = (prPetInfo.TotalNum or 0) - (prPetInfo.CanUseTalNum or 0)
                -- 查找当前应该使用的参悟羁绊等级
                for k,v in pairs(heroPetPrList) do
                    if petStep >= k and maxIndex < k then
                        maxIndex = k
                    end
                end
            end
            prListPetInfo.APR = heroPetPrList[maxIndex].APR
            prListPetInfo.HPR = heroPetPrList[maxIndex].HPR
            prListPetInfo.DEFR = heroPetPrList[maxIndex].DEFR
        end
    end
    return self:getPrInfoList(prInfoList, equipModels, prColor, notPrColor, rerornMasterHeroId)
end

-- 根据人物模型Id获取羁绊信息
--[[
-- 参数
    heroModelId: 人物的模型Id
    prColor: 达成羁绊显示的颜色, 默认为绿色
    notPrColor: 没有达成羁绊的颜色，默认为灰色
-- 返回值
    第一个值，参考文头处的 “返回羁绊信息说明”
    第二个值，达成羁绊的个数
]]
function CacheFormation:getHeroPrInfoByModelId(heroModelId)
    local prInfoList = ConfigFunc:getHeroPrInfos(heroModelId)

    local equipModels = {}
    -- 装备
    local tempLiset = EquipObj:getEquipListAsModelId()
    for key, _ in pairs(tempLiset) do
        equipModels[key] = true
    end
    -- 神兵
    tempLiset = TreasureObj:getTreasureListAsModelId()
    for key, _ in pairs(tempLiset) do
        equipModels[key] = true
    end
    -- 外功
    tempLiset = PetObj:getPetListAsModelId()
    for key, _ in pairs(tempLiset) do
        equipModels[key] = true
    end
    -- 内功
    tempLiset = ZhenjueObj:getZhenjueListAsModelId()
    for key, _ in pairs(tempLiset) do
        equipModels[key] = true
    end

    -- 找到外功所在位置
    local prListPetInfo = nil
    for i,v in ipairs(prInfoList) do
        if v.typeID == ResourcetypeSub.ePet then
            prListPetInfo = v
            break
        end
    end
    -- 外功参悟等级
    local heroPrInfo = PetHeroPrRelation.items[heroModelId]
    if heroPrInfo and prListPetInfo then
        -- 直接获取第一条羁绊属性
        local heroPetPrAttrs = table.values(heroPrInfo)[1][0]
        -- 设置基础外功属性
        prListPetInfo.APR = heroPetPrAttrs.APR
        prListPetInfo.HPR = heroPetPrAttrs.HPR
        prListPetInfo.DEFR = heroPetPrAttrs.DEFR
    end

    return self:getPrInfoList(prInfoList, equipModels)
end

-- 获取某阵容卡槽的羁绊信息
--[[
-- 参数
    slotId: 阵容卡槽Id
    isMateSlot: 是否是江湖后援团卡槽, 默认为false
    prColor: 达成羁绊显示的颜色, 默认为绿色
    notPrColor: 没有达成羁绊的颜色，默认为灰色
-- 返回值
    第一个值，参考文头处的 “返回羁绊信息说明”
    第二个值，达成羁绊的个数
]]
function CacheFormation:getSlotPrInfo(slotId, isMateSlot)
    if isMateSlot then
        local slotInfo = self.mMateInfo[slotId]
        if slotInfo and Utility.isEntityId(slotInfo.HeroId) then
            return self:getHeroPrInfo(slotInfo.HeroId)
        end
    else
        local slotInfo = self.mSlotInfo[slotId]
        if slotInfo and Utility.isEntityId(slotInfo.HeroId) then
            return self:getHeroPrInfo(slotInfo.HeroId)
        end
    end
    return {}, 0
end

--读取某个物品(人物、装备、神兵)上阵后可形成的羁绊效果
--[[
-- 参数:
    modelId: 物品模型Id
    resourceType: 资源类型
    combatSlotId: 用于上阵的卡槽Id，如果不传入该参数，则表示是否与任意一个卡槽有羁绊关系
    isMateSlot: 是否是用于江湖后援团卡槽
-- 返回值: 参考 Enums.RelationStatus 枚举定义
--]]
function CacheFormation:getRelationStatus(modelId, resourceType, combatSlotId, isMateSlot)
    if (modelId == nil) or (modelId <= 0) then
        return Enums.RelationStatus.eNone
    end

    local oldHeroModelId = nil  -- 卡槽上原来人物的模型Id
    -- 判断是否有相同人物已上阵
    if Utility.isHero(resourceType) then
        if self.mHeroModels[modelId] then
            return Enums.RelationStatus.eSame
        end
        if combatSlotId then
            local tempInfo = isMateSlot and self.mMateInfo[combatSlotId] or self.mSlotInfo[combatSlotId]
            oldHeroModelId = tempInfo and tempInfo.ModelId
        end
    elseif Utility.isTreasure(resourceType) then
        -- 判断神兵是否已上阵
        for _,value in pairs(self.mTreasures) do
            if type(value) == "table" and value.ModelId == modelId then
                return Enums.RelationStatus.eSame
            end
        end
    elseif Utility.isPet(resourceType) then
        -- 判断外功是否已上阵
        for _,value in pairs(self.mPets) do
            if type(value) == "table" and value.ModelId == modelId then
                return Enums.RelationStatus.eSame
            end
        end
    elseif Utility.isZhenjue(resourceType) then
        -- 判断内功是否已上阵
        for _,value in pairs(self.mZhenjues) do
            if type(value) == "table" and value.ModelId == modelId then
                return Enums.RelationStatus.eSame
            end
        end
    elseif Utility.isZhenyuan(resourceType) then
        -- 判断真元是否已上阵
        for _,value in pairs(self.mZhenyuans) do
            if type(value) == "table" and value.ModelId == modelId then
                return Enums.RelationStatus.eSame
            end
        end
    end

    -- 判断人物的可激活的羁绊状态
    local function getOneRelationStatus(slotId)
        local tempStatus = Enums.RelationStatus.eNone
        local prMembers = self.mSlotPrMemberInfo[slotId]
        for _, item in pairs(prMembers) do
            -- 检查原来的模型Id是否在羁绊成员列表中
            local oldInMemberList = false
            if oldHeroModelId and oldHeroModelId > 0 then
                for _, memberItem in pairs(item.memberList) do
                    if table.indexof(memberItem, oldHeroModelId) then
                        oldInMemberList = true
                        break
                    end
                end
            end

            for _, lackItem in pairs(item.lackList) do
                if table.indexof(lackItem, modelId) then
                    tempStatus = not oldInMemberList and (#item.lackList == 1) and Enums.RelationStatus.eTriggerPr or Enums.RelationStatus.eIsMember
                    break
                end
            end

            -- 如果可以激活条目，则不用再计算后面的条目了
            if tempStatus == Enums.RelationStatus.eTriggerPr then
                break
            end
        end
        return tempStatus
    end

    local retStatus = Enums.RelationStatus.eNone
    if Utility.isHero(resourceType) then
        for index, slotInfo in pairs(self.mSlotInfo or {}) do
            -- 如果是人物
            if (isMateSlot or not isMateSlot and combatSlotId ~= slotInfo.SlotId) and Utility.isEntityId(slotInfo.HeroId) then
                local tempStatus = getOneRelationStatus(slotInfo.SlotId)
                retStatus = math.max(retStatus, tempStatus)
                -- 如果可以激活条目，则不用再计算后面的条目了
                if retStatus == Enums.RelationStatus.eTriggerPr then
                    break
                end
            end
        end
    else  -- 装备或神兵的情况
        if combatSlotId then
            local slotInfo = self.mSlotInfo[combatSlotId]
            if Utility.isEntityId(slotInfo.HeroId) then
                retStatus = getOneRelationStatus(slotInfo.SlotId)
            end
        else
            for index, slotInfo in pairs(self.mSlotInfo or {}) do
                if Utility.isEntityId(slotInfo.HeroId) then
                    local tempStatus = getOneRelationStatus(slotInfo.SlotId)
                    retStatus = math.max(retStatus, tempStatus)
                    -- 如果可以激活条目，则不用再计算后面的条目了
                    if retStatus == Enums.RelationStatus.eTriggerPr then
                        break
                    end
                end
            end
        end
    end

    return retStatus
end

----------------------------------------------------------------------------------------------------
-- 判断卡槽是否开启，卡槽、侠客、装备、神兵、外功秘籍、内功心法等属性是否为空

--- 判断卡槽是否开启
--[[
-- 参数
    slotIndex: 卡槽Id（1、2、3....）
    isMateIndex: 是否是江湖后援团卡槽，默认为false
 ]]
function CacheFormation:slotIsOpen(slotIndex, isMateIndex)
    local playerInfo = self:getThisPlayerInfo()
    if isMateIndex and self:mateSlotIsVipOpen(slotIndex) then -- 需要VIP等级开启的江湖后援团卡槽
        local playerVip = playerInfo.Vip or 0
        local tempItem = VipSlotRelation.items[slotIndex]
        return tempItem and (playerVip >= tempItem.LV) or false
    else
        local starId = playerInfo.StarId or 0
        local needStar = self:getSlotOpenStar(slotIndex, isMateIndex)
        return starId >= needStar
    end
end

-- 判断人物卡槽是否为空
--[[
-- 参数
    slotIndex: 卡槽Id（1、2、3....）
 ]]
function CacheFormation:slotIsEmpty(slotIndex)
    local slotInfo = self.mSlotInfo[slotIndex]
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
        return true
    end
    return false
end

-- 判断卡槽上的装备是否为空
--[[
    slotId: 卡槽Id
    equipType: 装备类型在EnumsConfig.lua中有定义
]]
function CacheFormation:slotEquipIsEmpty(slotId, equipType)
    local slotInfo = self.mSlotInfo[slotId]
    -- 该卡槽还没有上阵人物，则说明也没有装备
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
        return true
    end
    -- 判断该卡槽是否有装备
    local equipTypeName = self.mEquipTypeNameList[equipType]
    local equipInfo = slotInfo[equipTypeName]
    if not equipInfo or not Utility.isEntityId(equipInfo.Id) then
        return true
    end

    return false
end

-- 判断内功心法卡槽是否开启
function CacheFormation:slotZhenjueIsOpen(slotId, zhenjueSlotIndex)
    local maxCount = self:getSlotZhenjueMaxCount(slotId)
    return maxCount >= zhenjueSlotIndex
end

-- 判断卡槽上内功心法是否为空
function CacheFormation:slotZhenjueIsEmpty(slotId, zhenjueSlotIndex)
    local slotInfo = self.mSlotInfo[slotId]
    -- 该卡槽还没有上阵人物，则说明也没有装备
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
        return true
    end
    local zhenjueInfo = slotInfo.Zhenjue[zhenjueSlotIndex]
    if not zhenjueInfo or not Utility.isEntityId(zhenjueInfo.Id) then
        return true
    end

    return false
end

-- 判断外功秘籍卡槽是否为空
function CacheFormation:slotPetIsEmpty(slotId)
    local slotInfo = self.mSlotInfo[slotId]
    -- 该卡槽还没有上阵人物，则说明也没有装备
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
        return true
    end
    local petInfo = slotInfo.Pet
    if not petInfo or not Utility.isEntityId(type(petInfo) == "table" and petInfo.Id or petInfo) then
        return true
    end

    return false
end

-- 判断江湖后援团卡槽是否是Vip等级开启的卡槽
function CacheFormation:mateSlotIsVipOpen(mateSlotId)
    local beginIndex = self.mVipMateStartIndex
    local endIndex = self.mVipMateStartIndex + self.VipMateMaxCount

    return mateSlotId >= beginIndex and mateSlotId < endIndex 
end

----------------------------------------------------------------------------------------------------
-- 获取卡槽、侠客、装备、神兵、外功秘籍、内功心法等信息

--- 获取卡槽的装备
--[[
-- 参数
    slotId: 卡槽Id
    equipType: 装备类型, 在EnumsConfig.lua中有定义, 如果传入的值不是武器、头盔、衣服、项链、兵书、坐骑，那么表示需要获取所有上阵装备
-- 返回值
    单个装备信息为：
    {
        slotId: 所在的卡槽Id
        Id: 装备实例Id
        modelId: 装备模型Id
    }
    如果 slotId 或 equipType 为nil，则会返回一个装备信息的列表
        {
            [Id] = { 装备信息}
            ...
        }

    如果 slotId 和 equipType 都为有效值，则直接返回一个装备的信息
]]
function CacheFormation:getSlotEquip(slotId, equipType)
    -- 获取一个装备卡槽的信息
    local function dealOneType(slotInfo, slotId, typeName)
        local object = slotInfo[typeName]
        if object and Utility.isEntityId(object.Id) then
            if self.mIsMyself then
                return {
                    slotId = slotId,
                    Id = object.Id,
                    modelId = object.ModelId or object.ModelId,
                }
            else
                return object
            end
        end
    end 

    local ret = {}
    if slotId then
        local slotInfo = self.mSlotInfo[slotId] or {}
        if equipType and self.mEquipTypeNameList[equipType] then
            local tempEquip = dealOneType(slotInfo, slotId, self.mEquipTypeNameList[equipType])
            return tempEquip
        else
            for _, typeName in pairs(self.mEquipTypeNameList) do
                local tempEquip = dealOneType(slotInfo, slotId, typeName)
                if tempEquip then
                    ret[tempEquip.Id] = tempEquip
                end
            end
        end
    else
        for index, slotInfo in ipairs(self.mSlotInfo) do
            if equipType and self.mEquipTypeNameList[equipType] then
                local tempEquip = dealOneType(slotInfo, index, self.mEquipTypeNameList[equipType])
                if tempEquip then
                    ret[tempEquip.Id] = tempEquip
                end
            else
                for _, typeName in pairs(self.mEquipTypeNameList) do
                    local tempEquip = dealOneType(slotInfo, index, typeName)
                    if tempEquip then
                        ret[tempEquip.Id] = tempEquip
                    end
                end
            end
        end
    end
    return ret
end

--- 获取卡槽的内功心法
--[[
-- 参数
    slotId: 卡槽Id
    zhenjueSlotId: 内功心法卡槽Id
-- 返回值
    单个装备信息为：
    {
        Id: 内功心法实例Id
        modelId: 内功心法模型Id
    }
    如果 zhenjueSlotId 为nil，则会返回一个内功心法信息的列表
        {
            { 内功心法信息}
            ...
        }

    如果 slotId 和 zhenjueSlotId 都为有效值，则直接返回一个内功心法的信息
]]
function CacheFormation:getSlotZhenjue(slotId, zhenjueSlotId)
    local slotInfo = self.mSlotInfo[slotId] 
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) or not slotInfo.Zhenjue then
        return {}
    end

    if zhenjueSlotId then
        -- 为了保持数据统一，尽量通过实体Id从Cache列表里读取相关信息，不是自己的话才直接从阵容里读取
        local tempZhenjueItem = slotInfo.Zhenjue[zhenjueSlotId]
        return self:isMyself() and ZhenjueObj:getZhenjue(tempZhenjueItem.Id) or tempZhenjueItem
    else
        return slotInfo.Zhenjue
    end
end

--- 获取卡槽的真元
--[[
-- 参数
    slotId: 卡槽Id
    zhenyuanSlotId: 真元卡槽Id
-- 返回值
    单个装备信息为：
    {
        Id: 真元实例Id
        modelId: 真元模型Id
    }
    如果 zhenyuanSlotId 为nil，则会返回一个真元信息的列表
        {
            { }
            ...
        }

    如果 slotId 和 zhenyuanSlotId 都为有效值，则直接返回一个内功心法的信息
]]
function CacheFormation:getSlotZhenyuan(slotId, zhenyuanSlotId)
    local slotInfo = self.mSlotInfo[slotId] 
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) or not slotInfo.ZhenYuan then
        return {}
    end

    if zhenyuanSlotId then
        -- 为了保持数据统一，尽量通过实体Id从Cache列表里读取相关信息，不是自己的话才直接从阵容里读取
        local tempZhenyuanItem = slotInfo.ZhenYuan[zhenyuanSlotId] or {}
        return self:isMyself() and ZhenyuanObj:getZhenyuan(tempZhenyuanItem.Id) or tempZhenyuanItem
    else
        return slotInfo.ZhenYuan
    end
end

--- 获取卡槽的外功秘籍
--[[
-- 参数
    slotId: 卡槽Id(0:出战外功秘籍； 1-6: 阵容卡槽外功秘籍)
-- 返回值
    {
        Id: 外功秘籍实例Id
        FAP: 如果是出战外功秘籍，会返回战力
        slotId: 卡槽Id(0:出战外功秘籍； 1-6: 阵容卡槽外功秘籍)
    }
]]
function CacheFormation:getSlotPet(slotId)
    for _, item in pairs(self.mPets) do
        if type(item) == "table" and item.slotId == slotId then
            return item
        end
    end
end

--- 获取卡槽的宝石
--[[
-- 参数
    slotId: 卡槽Id
    imprintType: 宝石卡槽Id
-- 返回值
    单个装备信息为：
    {
        Id: 宝石实例Id
        modelId: 宝石模型Id
    }
    如果 imprintType 为nil，则会返回一个宝石信息的列表
        {
            { 宝石信息}
            ...
        }

    如果 slotId 和 imprintType 都为有效值，则直接返回一个宝石的信息
]]
function CacheFormation:getSlotImprint(slotId, imprintType)
    local slotInfo = self.mSlotInfo[slotId]
    if not slotInfo then
        return {}
    end

    if imprintType then
        -- 为了保持数据统一，尽量通过实体Id从Cache列表里读取相关信息，不是自己的话才直接从阵容里读取
        local tempImprintItem = slotInfo[Utility.getImprintTypeString(imprintType)] or {}
        return self:isMyself() and ImprintObj:getImprint(tempImprintItem.Id) or tempImprintItem
    else
        return clone(self.mImprints[slotId])
    end
end

--- 获取所有卡槽的宝石
--[[
返回值
    {
        [slotId] = {
            {
                "Lv" = 0, --宝石等级
                "ModelId" = 30013111, --模型id
                "Id" = "af945377-d0f7-44f5-a3fb-ab6216388390", --实例id
                "AttrIdStr" = "1", -- 随机属性id
                "TotalExp" = 0, -- 强化获得的总经验
                "IsCombat" = false -- 是否上阵
                "LvUpAttrStr" = "201|100,202|100" -- 随机属性
                "slotType" = 1301,  -- 所属部位
            }
            ....
        }
        ...
    }
]]
function CacheFormation:getCombtImprint()
    return clone(self.mImprints)
end
----------------------------------------------------------------------------------------------------
-- 判断指定的人物/装备/外功秘籍/内功心法是否已经上阵

--- 判断人物是否已经上阵
--[[
-- 参数
    heroId: 人物实例Id
-- 返回值：
    第一个值，人物已上阵为True，否则为False；
    第二个值，人物已上阵,并且处于江湖后援团卡槽True，否则为False；
    第三个值，如果人物已上阵，表示所在的卡槽Id，如果是上阵在江湖后援团中，则是江湖后援团的卡槽Id
 ]]
function CacheFormation:heroInFormation(heroId)
    local slotHero = self.mSlotHeros[heroId]
    if slotHero then
        return true, false, slotHero.slotId
    end
    local mateHero = self.mMateHeros[heroId]
    if mateHero then
        return true, true, mateHero.slotId
    end

    return false, false
end

--- 判断装备（包含神兵）是否已上阵
--[[
-- 参数：
    entity: 装备实例Id 或实例对象
-- 返回值:
    第一个值，装备已上阵为true，否则为False
    第二个值，如果装备已上阵为上阵的卡槽Id，否则为nil
 ]]
function CacheFormation:equipInFormation(entity)
    local tempId = type(entity) == "table" and entity.Id or entity
    local ret = self.mEquips[tempId] or self.mTreasures[tempId]
    if ret then
        return true, ret.slotId
    end
    return false, nil
end

--- 判断宝石已上阵
--[[
-- 参数：
    entity: 装备实例Id 或实例对象
-- 返回值:
    第一个值，装备已上阵为true，否则为False
    第二个值，如果装备已上阵为上阵的卡槽Id，否则为nil
 ]]
function CacheFormation:imprintInFormation(entity)
    local tempId = type(entity) == "table" and entity.Id or entity
    for slotId, slotImprintList in pairs(self.mImprints) do
        for _, imprintItem in pairs(slotImprintList) do
            if imprintItem.Id == tempId then
                return true, slotId
            end
        end
    end
    
    return false, nil
end

--- 判断内功心法是否已上阵
--[[
-- 参数：
    entity: 内功心法实例Id 或实例对象
-- 返回值:
    第一个值，内功心法已上阵为true，否则为False
    第二个值，如果内功心法已上阵为上阵的卡槽Id，否则为nil
]]
function CacheFormation:zhenjueInFormation(entity)
    local tempId = type(entity) == "table" and entity.Id or entity
    local ret = self.mZhenjues[tempId]
    if ret then
        return true, ret.slotId
    end
    return false, nil
end

--- 判断真元是否已上阵
--[[
-- 参数：
    entity: 真元实例Id 或实例对象
-- 返回值:
    第一个值，真元已上阵为true，否则为False
    第二个值，如果真元已上阵为上阵的卡槽Id，否则为nil
]]
function CacheFormation:zhenyuanInFormation(entity)
    local tempId = type(entity) == "table" and entity.Id or entity
    local ret = self.mZhenyuans[tempId]
    if ret then
        return true, ret.slotId
    end
    return false, nil
end

--- 判断外功秘籍是否已上阵
--[[
-- 参数：
    entity: 外功秘籍实例Id 或实例对象
-- 返回值:
    第一个值，外功秘籍已上阵为true，否则为False
    第二个值，如果外功秘籍已上阵为上阵的卡槽Id，否则为nil，卡槽Id 为0 表示出战外功秘籍，1-6表示阵容卡槽外功秘籍
]]
function CacheFormation:petInFormation(entity)
    local tempId = type(entity) == "table" and entity.Id or entity
    local ret = self.mPets[tempId]
    if ret then
        return true, ret.slotId
    end
    return false, nil
end

--- 判断神兵是否已上阵
--[[
-- 参数：
    entity: 外功秘籍实例Id 或实例对象
-- 返回值:
    第一个值，外功秘籍已上阵为true，否则为False
    第二个值，如果外功秘籍已上阵为上阵的卡槽Id，否则为nil，卡槽Id 为0 表示出战外功秘籍，1-6表示阵容卡槽外功秘籍
]]
function CacheFormation:treasureInFormation(entity)
    local tempId = type(entity) == "table" and entity.Id or entity
    local ret = self.mTreasures[tempId]
    if ret then
        return true, ret.slotId
    end
    return false, nil
end

----------------------------------------------------------------------------------------------------

-- 获取拥有该阵容的玩家的玩家信息
function CacheFormation:getThisPlayerInfo()
    return self.mIsMyself and PlayerAttrObj:getPlayerInfo() or self.mOtherPlayerInfo
end

-- 获取阵容最大的卡槽数
function CacheFormation:getMaxSlotCount()
    return self.mMaxSlotCount
end

-- 获取阵容最大的江湖后援团数
function CacheFormation:getMaxMateCount()
    return self.mMaxMateCount
end

-- 获取Vip开启卡槽的起始Id
function CacheFormation:getVipMateStartIndex()
    return self.mVipMateStartIndex
end

-- 获取Vip开启卡槽的数量
function CacheFormation:getVipMateMaxCount()
    return self.VipMateMaxCount
end

----------------------------------------------------------------------------------------------------
-- 辅助接口

-- 判断是非是玩家自己的阵容信息 
function CacheFormation:isMyself()
    return self.mIsMyself
end

-- 获取阵容卡槽信息
function CacheFormation:getSlotInfos()
    return self.mSlotInfo
end

-- 获取某个卡槽的阵容信息
function CacheFormation:getSlotInfoBySlotId(slotId)
    return self.mSlotInfo[slotId or 1]
end

-- 获取上阵模块卡槽人物需要排除的人物模型Id列比啊
function CacheFormation:getExcludeHeroModelIds(slotId, isMateSlot)
    local oldModelId
    if isMateSlot then
        oldModelId = self.mMateInfo[slotId] and self.mMateInfo[slotId].ModelId
    else
        oldModelId = self.mSlotInfo[slotId] and self.mSlotInfo[slotId].ModelId
    end

    local ret = {}
    for key, value in pairs(self.mHeroModels) do
        if key ~= oldModelId then
            table.insert(ret, key)
        end
    end
    return ret
end

-- 获取江湖后援团卡槽信息
function CacheFormation:getMateSlotInfo(slotId)
    return self.mMateInfo[slotId]
end

-- 判断人物是否和阵容中的人物同名
function CacheFormation:haveSameHero(heroModelId)
    return self.mHeroModels[heroModelId]
end

-- 获取阵容的布阵信息
function CacheFormation:getEmbattleInfo()
    return self.mEmbattleInfo
end

-- 获取宠物的布阵信息
function CacheFormation:getPetFormationInfo()
    return self.mPetFormationInfo
end

-- 获取卡槽的人物相信信息
function CacheFormation:getSlotHeroInfo(heroId)
    if self.mIsMyself then
        return HeroObj:getHero(heroId)
    end

    if self.mSlotHeros[heroId] then
        local slotId = self.mSlotHeros[heroId].slotId 
        return self.mSlotInfo[slotId].Hero
    elseif self.mMateHeros[heroId] then
        local slotId = self.mMateHeros[heroId].slotId
        return self.mMateHeros[slotId]
    end
end

-- 获取江湖后援团信息
function CacheFormation:getMateInfo()
    local tempHeroInfo = {}
    for i,v in pairs(self.mMateHeros) do
        if type(v) ~= "number" then
            table.insert(tempHeroInfo, v)
        end
    end
    return tempHeroInfo
end
----------------------------------------------------------------------------------------------------

---查找当前玩家的英雄是否能更换为背包中更好的英雄
--[[
-- 参数：
    heroModelID 查找的目标英雄的
-- 返回值：
    true 有可以更换更好的的英雄 false没有可以更换的英雄
]]
function CacheFormation:haveBetterHero(heroModelID)
    -- 如果不是玩家自己则不提供该函数
    if not self.mIsMyself then
        return 
    end

    -- 获取目标英雄的详细信息
    local heroInfo = HeroModel.items[heroModelID]
    if not heroInfo or heroInfo.specialType == Enums.HeroType.eMainHero then -- 如果是主角，则不能更换
        return false
    end
    local oldColorLv = Utility.getQualityColorLv(heroInfo.quality)
    if oldColorLv >= 5 then -- 橙色的就不用提示更换了
        return false
    end

    -- 如果该人物本身可以激活羁绊或缘份，不用替换
    local tempStatus = self:getRelationStatus(heroModelID, ResourcetypeSub.eHero)
    if tempStatus == Enums.RelationStatus.eIsMember or tempStatus == Enums.RelationStatus.eTriggerPr then
        return false
    end

    -- 如果是橙色以下品质的人物，需要判断是否有更好的品质的可以上阵
    return HeroObj:haveHero({
        notInFormation = true,
        minColorLv = oldColorLv + 1,
        excludeModelIds = table.keys(self.mHeroModels)
    })
end

-- 获取内功心法卡槽能上阵的内功心法类型Id
function CacheFormation:getZhenjueSlotType(zhenjueSlotIndex)
    local tempList = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 3,
        [5] = 2,
        [6] = 1,
    }
    return tempList[zhenjueSlotIndex or 1]
end

-- 获取卡槽可以上阵的内功心法最大个数
function CacheFormation:getSlotZhenjueMaxCount(slotId)
    local slotInfo = self.mSlotInfo[slotId]
    -- 该卡槽还没有上阵人物，
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
        return 0
    end

    local slotHero = self.mIsMyself and HeroObj:getHero(slotInfo.HeroId) or slotInfo.Hero
    local heroModel = HeroModel.items[slotHero.ModelId]
    return heroModel.zhenjueSlotMax
end

--- 获取卡槽开启需要点星的次数
--[[
-- 参数
    slotIndex: 卡槽Id（1、2、3....）
    isMateIndex: 是否是江湖后援团卡槽，默认为false
 ]]
function CacheFormation:getSlotOpenStar(slotIndex, isMateIndex)
    local tempItem 
    if isMateIndex then
        if slotIndex < self.mVipMateStartIndex or slotIndex >= (self.mVipMateStartIndex + self.VipMateMaxCount) then
            tempItem = AttrtreeSlotRelation.items[slotIndex + 20]
        end
    else
        tempItem = AttrtreeSlotRelation.items[slotIndex + 10]
    end

    if tempItem then
        return tempItem.needAttrTreeID
    end
    return 0
end

--- 获取玩家阵容卡槽开启的数量（不能获取江湖后援团开启的个数）
function CacheFormation:getSlotOpenCount()
    local playerInfo = self:getThisPlayerInfo()
    local starId = playerInfo.StarId or 0
    local openCount = 0
    for slotIndex = 1, self.mMaxSlotCount - 1 do
        local tempItem = AttrtreeSlotRelation.items[slotIndex + 10]
        if tempItem.needAttrTreeID > starId then
            break
        end
        openCount = slotIndex
    end
    return openCount
end

-- 获取阵容卡槽的属性
--[[
-- 参数
    slotId：阵容的卡槽Id
]]
function CacheFormation:getSlotAttrInfo(slotId)
    local slotInfo = self.mSlotInfo[slotId]
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
        return {}
    end

    local ret = {}
    for key, value in pairs(slotInfo.Property) do
        local tempItem = {}
        ret[key] = tempItem
        
        if key == "FAP" then -- 战力
            tempItem.name = key
            tempItem.viewName = TR("战力")
            tempItem.value = value
            tempItem.viewValue = tostring(value)
        elseif key == "FSP" then
            tempItem.name = key
            tempItem.viewName = TR("先手")
            tempItem.value = value
            tempItem.viewValue = tostring(value)
        else
            local attrType = ConfigFunc:getFightAttrEnumByName(key)
            tempItem.attrType = attrType
            tempItem.name = key
            tempItem.viewName = ConfigFunc:getViewNameByFightName(key)
            tempItem.value = value
            tempItem.viewValue = Utility.getAttrViewStr(attrType, value, false)
        end
    end

    -- 等级
    local tempHero = slotInfo.Hero or HeroObj:getHero(slotInfo.HeroId)
    local tempItem = {}
    ret["Lv"] = tempItem
    tempItem.name = "Lv"
    tempItem.viewName = TR("等级")
    tempItem.value = tempHero.Lv
    tempItem.viewValue = (slotId == 1) and tostring(tempHero.Lv) or string.format("%d/%d", tempHero.Lv, PlayerAttrObj:getPlayerAttrByName("Lv"))

    local tempItem = {}
    ret.quality = tempItem
    tempItem.name = "quality"
    tempItem.viewName = TR("资质")
    tempItem.value = HeroModel.items[slotInfo.ModelId].quality
    tempItem.viewValue = tostring(HeroModel.items[slotInfo.ModelId].quality)

    return ret
end

-- 根据属性名称获取阵容卡槽的属性
--[[
    slotId：阵容的卡槽Id
    attrName: 属性名称，取值见 “阵容数据说明” 中的 Property 
]]
function CacheFormation:getSlotAttrByName(slotId, attrName)
    local slotInfo = self.mSlotInfo[slotId]
    if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
        return 0
    end

    return slotInfo.Property[attrName]
end

-- 判断某个合体技是否激活
function CacheFormation:isHeroJointActive(jointId)
    if (jointId == nil) then
        return false
    end

    local jointModel = HeroJointModel.items[jointId]
    if (jointModel == nil) or (jointModel.ID == nil) then
        return false
    end

    -- 判断是否同时上阵（副将ID是0表示主角，永远是已上阵状态）
    local isMainActive, isAidActive = false, (jointModel.aidHeroID == 0)
    for _,v in pairs(self.mSlotInfo) do
        if (v.ModelId ~= nil) then
            local isIllusion = false
            local tmpHeroInfo = (self.mIsMyself == true) and HeroObj:getHero(v.HeroId) or v.Hero
            if (tmpHeroInfo ~= nil) and (tmpHeroInfo.IllusionModelId > 0) and (tmpHeroInfo.IllusionModelId == jointModel.mainHeroID) then
                isMainActive = true
            elseif (tmpHeroInfo ~= nil) and (tmpHeroInfo.IllusionModelId > 0) and (tmpHeroInfo.IllusionModelId == jointModel.aidHeroID) then
                isAidActive = true
            elseif (tmpHeroInfo ~= nil) and (v.ModelId == jointModel.mainHeroID) and tmpHeroInfo.IllusionModelId == 0 then
                isMainActive = true
            elseif (tmpHeroInfo ~= nil) and (v.ModelId == jointModel.aidHeroID) and tmpHeroInfo.IllusionModelId == 0 then
                isAidActive = true
            end
        end
    end
    return (isMainActive == true) and (isAidActive == true) 
end

return CacheFormation
