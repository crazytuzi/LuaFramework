CombineSelectEquipPanel = CombineSelectEquipPanel or class("CombineSelectEquipPanel", BasePanel)
local CombineSelectEquipPanel = CombineSelectEquipPanel

function CombineSelectEquipPanel:ctor()
    self.abName = "combine"
    self.assetName = "CombineSelectEquipPanel"
    self.layer = "UI"

    self.height = 0
    self.use_background = true
    self.click_bg_close = true
    self.item_list = {}
    --self.change_scene_close = true
    self.model = CombineModel.GetInstance()
end

function CombineSelectEquipPanel:CloseSelectPanel()
    self:Close()
end

function CombineSelectEquipPanel:dctor()
end

function CombineSelectEquipPanel:Open()
    BasePanel.Open(self)
end

function CombineSelectEquipPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/Content",
        "closebtn",
        "needText",
    }
    self:GetChildren(self.nodes)
    self.needText = self.needText:GetComponent("Text")
    self:AddEvent()
end

function CombineSelectEquipPanel:AddEvent()
    local function call_back(target, x, y)
        BasePanel.Close(self)
    end
    AddClickEvent(self.closebtn.gameObject, call_back)

    function selectequipitemclick_call_back(ItemId)
        BasePanel.Close(self)
    end
    self.selectequipitemclick_event_id = GlobalEvent:AddListener(CombineEvent.SelectEquipItemClick, selectequipitemclick_call_back)
end

function CombineSelectEquipPanel:OpenCallBack()
    self:UpdateView()
end

function CombineSelectEquipPanel:UpdateView()
    local stairsName = ""
    local starsName = ""
    local bag_type = self.model.curBagType
    if bag_type == 101 or bag_type == 110 then
        --只有背包和宠物装备才有
        stairsName = CombineStair_List[self.model.cur_Stairs]
    elseif bag_type ~= 108 and bag_type ~= 109 and bag_type ~= 106 then
        --器灵除外
        starsName = CombineStars_List[self.model.cur_Stars] or ""
    end
    local colorsName = CombineColor_List[self.model.cur_Colors]
    local stairsAfter = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep), stairsName)
    local starsAfter = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep), starsName)
    local colorsAfter = string.format("<color=#%s>%s</color>", self.model:CheckTypeNameColor(colorsName), colorsName)
    local finalText = stairsAfter .. starsAfter .. colorsAfter
    self.needText.text = finalText
    local combinebase = Config.db_equip_combine[self.item_id]

    --获取可以加入的材料列表
    local item_uids = {}
    if self.model.curBagType == 101 then
        item_uids = CombineController:GetInstance():GetAllCombineEquips(String2Table(combinebase.other_cost))
    elseif self.model.curBagType == 104 then
        local list = BeastModel:GetInstance():GetAllEqipBaseTbl(String2Table(combinebase.other_cost))
        local finalCount = #list
        if #list > 20 then
            finalCount = 20
        end
        for i = 1, finalCount do
            item_uids[#item_uids + 1] = list[i]
        end
    elseif self.model.curBagType == 106 then
        local list = String2Table(combinebase.other_cost)
        local count = 1
        for _, itemId in pairs(list) do
            local equips = BagModel:GetInstance().babyItems
            for _, v in pairs(equips) do
                if itemId == v.id then
                    if not self.model:IsUidUsed(v.uid) then
                        item_uids[#item_uids + 1] = v
                        if count == 20 then
                            break
                        end
                        count = count + 1
                    end
                end
            end
        end
    elseif self.model.curBagType == 108 then
        local list = String2Table(combinebase.other_cost)
        local count = 1
        for _, itemId in pairs(list) do
            local equips = BagModel:GetInstance().godItems
            for _, v in pairs(equips) do
                if itemId == v.id then
                    if not self.model:IsUidUsed(v.uid) then
                        item_uids[#item_uids + 1] = v
                        if count == 20 then
                            break
                        end
                        count = count + 1
                    end
                end
            end
        end
    elseif self.model.curBagType == 109 then
        local list = String2Table(combinebase.other_cost)
        local count = 1
        for _, itemId in pairs(list) do
            local equips = BagModel:GetInstance().mechaItems
            for _, v in pairs(equips) do
                if itemId == v.id then
                    if not self.model:IsUidUsed(v.uid) then
                        item_uids[#item_uids + 1] = v
                        if count == 20 then
                            break
                        end
                        count = count + 1
                    end
                end
            end
        end
    elseif self.model.curBagType == 110 then
        --从宠物装备背包中筛选
        local list = String2Table(combinebase.other_cost)
        local count = 1
        for _, itemId in pairs(list) do
            local equips = BagModel:GetInstance().bags[BagModel.PetEquip].bagItems
            for _, v in pairs(equips) do
                if itemId == v.id and v.misc.stren_lv == 0 then  --强化过的就过滤掉了
                    if not self.model:IsUidUsed(v.uid) then
                        item_uids[#item_uids + 1] = v
                        if count == 20 then
                            break
                        end
                        count = count + 1
                    end
                end
            end
        end
    elseif self.model.curBagType == BagModel.artifact then
        --从宠物装备背包中筛选
        local list = String2Table(combinebase.other_cost)
        local count = 1
        for _, itemId in pairs(list) do
            local equips = BagModel:GetInstance().artifactItems
            for _, v in pairs(equips) do
                if itemId == v.id then  --强化过的就过滤掉了
                    if not self.model:IsUidUsed(v.uid) then
                        item_uids[#item_uids + 1] = v
                        if count == 20 then
                            break
                        end
                        count = count + 1
                    end
                end
            end
        end
    elseif self.model.curBagType == BagModel.toems then
        --从宠物装备背包中筛选
        local list = String2Table(combinebase.other_cost)
        local count = 1
        for _, itemId in pairs(list) do
            local equips = BagModel:GetInstance().bags[BagModel.toems].bagItems
            for _, v in pairs(equips) do
                if itemId == v.id then  --强化过的就过滤掉了
                    if not self.model:IsUidUsed(v.uid) then
                        item_uids[#item_uids + 1] = v
                        if count == 20 then
                            break
                        end
                        count = count + 1
                    end
                end
            end
        end
    end
    for _, p_item_b in pairs(item_uids) do
        local p_item_base = nil
        if self.model.curBagType == 101 then
            p_item_base = BagModel:GetInstance():GetBagItemByUid(p_item_b.uid)
        elseif self.model.curBagType == 104 or self.model.curBagType == 108 or self.model.curBagType == 109 or self.model.curBagType == 106 or self.model.curBagType == 110 or 
        self.model.curBagType == BagModel.artifact or self.model.curBagType == BagModel.toems  then
            p_item_base = p_item_b
        end
        local item = CombineSelectEquipItem(self.Content)
        item:SetData(p_item_base)
        self.item_list[#self.item_list + 1] = item
        self.height = self.height + item:GetHeight()
    end
    self:Relayout()
end

function CombineSelectEquipPanel:CloseCallBack()
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
    if self.selectequipitemclick_event_id then
        GlobalEvent:RemoveListener(self.selectequipitemclick_event_id)
        self.selectequipitemclick_event_id = nil
    end
end

function CombineSelectEquipPanel:Relayout()
    self.Content.sizeDelta = Vector2(self.Content.sizeDelta.x, self.height)
end

function CombineSelectEquipPanel:SetItemId(ItemId)
    self.item_id = ItemId
end