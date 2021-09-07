BuyManager = BuyManager or BaseClass(BaseManager)

function BuyManager:__init()
    if BuyManager.Instance ~= nil then
        return
    end

    BuyManager.Instance = self

    self.autoBuyList = {
        ["ChildUpgrade"] = {},   -- 子女进阶
        ["ChildTalent"] = {},    -- 子女训练
        ["ChildEducate"] = {},   -- 子女教育
        ["ChildGemWash"] = {},   -- 子女重置天赋
        ["ChildTalentChange"] = {},  -- 子女天赋更换
        ["EquipStrengthBuy"] = {},       -- 装备强化石购买
        ["EquipStrengthDianhua"] = {},   -- 装备精炼
        ["EquipStrengthPerfect"] = {},   -- 装备锻造
        ["EquipStrengthPerfect2"] = {},   -- 装备锻造，我也不知道为什么要两个锻造
        ["EquipStrengthAdvance"] = {},   -- 装备镶嵌
        ["EquipStrengthTrans"] = {},   -- 装备镶转
        ["EquipStrengthWash"] = {},      -- 装备洗练
        ["FashionUpgrade"] = {},     -- 时装升级
        ["FashionSave"] = {},        -- 时装保存
        ["GodAnimalTrans"] = {},     -- 神兽转换
        ["GodAnimalExchange"] = {},  -- 神兽兑换
        ["PetFeed"] = {},            -- 宠物喂养资质
        ["PetGemWash"] = {},         -- 宠物符石技能洗练
        ["PetSkinActivate"] = {},    -- 宠物皮肤激活
        ["PetStoneWashUpdate"] = {},       -- 宠物符石洗练
        ["PetStoneWashReset"] = {},       -- 宠物符石重置
        ["PetUpgrade"] = {},             -- 宠物进阶
        ["PetWash"] = {},        -- 宠物洗髓
        ["PetWash2"] = {},        -- 宠物洗髓2
        ["RideWear"] = {},       -- 坐骑穿戴
        ["RideWear2"] = {},       -- 坐骑穿戴2
        ["RideSkillUpgrade"] = {},   -- 坐骑技能升级
        ["RideSkillWash"] = {},      -- 坐骑技能洗练
        ["RideUseItem"] = {},        -- 坐骑补充精力
        ["RideWash"] = {},           -- 坐骑洗髓
        ["ShouhuRecruit"] = {},      -- 守护招募
        ["TreasuremapExchange"] = {},-- 宝图兑换
        ["WingUpgrade"] = {},        -- 翅膀升级
        ["WingSkillReset"] = {},     -- 翅膀技能重置
        ["RiceDumpling"] = {},       -- 粽子合成（活动道具消耗）
        ["PetRuneResonanceButton"] = {},       -- 宠物内丹共鸣
        ["PetRuneStudyButton"] = {},           -- 宠物内丹学习
        ["NoticeConfirmCostButton"] = {},      -- 消耗道具确认框
        
    }
end

-- 快捷购买（只能购买，不能做其他操作）
-- array = {
--         [base_id] = {need = 0}
--     }
-- }
function BuyManager:ShowQuickBuy(array)
    local base_ids = {}
    for base_id,v in pairs(array) do
        if base_id < 90000 and v ~= nil and v.need > 0 then
            table.insert(base_ids, {base_id = base_id})
        end
    end

    if self.askCallbackKey ~= nil and self.askCallbackIndex ~= nil and MarketManager.Instance.model.on12416_callback ~= nil and MarketManager.Instance.model.on12416_callback[self.askCallbackKey] ~= nil and MarketManager.Instance.model.on12416_callback[self.askCallbackKey][self.askCallbackIndex] ~= nil then
        MarketManager.Instance.model.on12416_callback[self.askCallbackKey][self.askCallbackIndex] = nil
    end
    self.askCallbackKey,self.askCallbackIndex = MarketManager.Instance:send12416({base_ids = base_ids}, function(priceByBaseid)
        local baseidToPrice = {}
        for _,v in pairs(priceByBaseid) do
            baseidToPrice[v.base_id] = {}
            for key,value in pairs(v) do
                baseidToPrice[v.base_id][key] = value
            end
        end
        if self.buyConfirm == nil then
            self.buyConfirm = BuyConfirm.New()
        end
        self.buyConfirm:Show({baseidToPrice = baseidToPrice, baseidToNeed = array})
    end)
end

-- 判断base_id列表对于某功能是否全部自动购买
function BuyManager:IsAutoBuy(type, list)
    if self.autoBuyList[type] == nil or next(self.autoBuyList[type]) == nil then
        return false
    else
        for _,base_id in pairs(list) do
            if self.autoBuyList[type][base_id] ~= true then
                return false
            end
        end
        return true
    end
end
