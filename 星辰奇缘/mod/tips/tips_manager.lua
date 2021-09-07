-- -------------------------------------
-- Tips管理
-- hosr
-- -------------------------------------
TipsManager = TipsManager or BaseClass(BaseManager)

function TipsManager:__init()
    if TipsManager.Instance then
        return
    end
    TipsManager.Instance = self
    self.model = TipsModel.New()
    self.updateCall = nil
end

function TipsManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
    end
    self.model = nil
end

function TipsManager:Clear()
    if self.model ~= nil then
        self.model:Clear()
    end
end

function TipsManager:FixedUpdate()
    if self.updateCall == nil then
         return
    end
    self.updateCall()
end

function TipsManager:ShowItem(info)
    self.model:ShowItem(info)
end

function TipsManager:ShowEquip(info)
    self.model:ShowEquip(info)
end

function TipsManager:ShowSkill(info, special)
    self.model:ShowSkill(info, special)
end

function TipsManager:ShowText(info)
    self.model:ShowText(info)
end

function TipsManager:ShowPetEquip(info)
    self.model:ShowPetEquip(info)
end

function TipsManager:ShowPlayer(info)
    self.model:ShowPlayer(info)
end

function TipsManager:ShowButton(info)
    self.model:ShowButton(info)
end

function TipsManager:ShowGuide(info)
    self.model:ShowGuide(info)
end

function TipsManager:HideGuide()
    self.model:HideGuide()
end

function TipsManager:ShowWing(info)
    self.model:ShowWing(info)
end

function TipsManager:ShowFruit(info)
    self.model:ShowFruit(info)
end

function TipsManager:ShowFruitNew(info)
    self.model:ShowFruitNew(info)
end

function TipsManager:ShowRandomFruit(info)
    self.model:ShowRandomFruit(info)
end

function TipsManager:ShowTeamUp(info)
    self.model:ShowTeamUp(info)
end

function TipsManager:ShowTitle(info)
    self.model:ShowTitle(info)
end

function TipsManager:ShowRideSkill(info)
    self.model:ShowRideSkill(info)
end

function TipsManager:ShowRideEquip(info)
    self.model:ShowRideEquip(info)
end

function TipsManager:ShowTextBtn(info)
    self.model:ShowTextBtn(info)
end

function TipsManager:ShowChildTelnet(info)
    self.model:ShowChildTelnet(info)
end

function TipsManager:ShowAllItemTips(info)
    --BaseUtils.dump(info,"info")
    if info.itemData == nil then
        return
    end
    if info.itemData.type == BackpackEumn.ItemType.talismanring
        or info.itemData.type == BackpackEumn.ItemType.talismanmask
        or info.itemData.type == BackpackEumn.ItemType.talismancloak
        or info.itemData.type == BackpackEumn.ItemType.talismanbadge then
        TipsManager.Instance:ShowTalisman(info)
    elseif info.itemData.type == BackpackEumn.ItemType.petattrgem or info.itemData.type == BackpackEumn.ItemType.petskillgem then
        TipsManager.Instance:ShowPetEquip(info)
    elseif info.itemData.type == BackpackEumn.ItemType.childattreqm or info.itemData.type == BackpackEumn.ItemType.childskilleqm then
        TipsManager.Instance:ShowPetEquip(info)
    elseif info.itemData.func == TI18N("变身") then
        local isRandom = false
        local isNewFruit = false
        for i,v in ipairs(info.itemData.effect) do
            if v.effect_type == 52 then
                isNewFruit = true
                break
            end

            if v.effect_type == 20 then
                isRandom = true
                break
            end
        end
        if isNewFruit then
            TipsManager.Instance:ShowFruitNew(info)
        elseif isRandom then
            TipsManager.Instance:ShowRandomFruit(info)
        else
            TipsManager.Instance:ShowFruit(info)
        end
    elseif info.itemData.type == BackpackEumn.ItemType.suitselectgift then
        --背包中的时装选择 走这里~(仅背包)   ItemData.New/DataItem
        self.model:OpenSelectSuitPanel({baseid =(info.itemData.base_id or info.itemData.id), isshow = not info.extra.inbag, type = 1})
    elseif info.itemData.type == BackpackEumn.ItemType.wingselectgift then
        --背包中的翅膀选择 走这里~(仅背包)
        self.model:OpenSelectSuitPanel({baseid =info.itemData.base_id, isshow = not info.extra.inbag, type = 2})
    else
        if BackpackManager.Instance:IsEquip(info.itemData.type) then
            TipsManager.Instance:ShowEquip(info)
        else
            TipsManager.Instance:ShowItem(info)
        end
    end
end

function TipsManager:ShowTalisman(info)
    self.model:ShowTalisman(info)
end

function TipsManager:ShowTalismanAttr(info)
    self.model:ShowTalismanAttr(info)
end

function TipsManager:ShowRules(info)
    self.model:ShowRules(info)
end

function TipsManager:ShowRuneTips(info)
    self.model:ShowRuneTips(info)
end