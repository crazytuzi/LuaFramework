---
--- Created by  Administrator
--- DateTime: 2020/7/27 15:17
---
ToemsEquipPanel = ToemsEquipPanel or class("ToemsEquipPanel", WindowPanel)
local this = ToemsEquipPanel

function ToemsEquipPanel:ctor(parent_node, parent_panel)
    self.abName = "toems"
    self.assetName = "ToemsEquipPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.mEvents = {}
    self.schedules = {};
    self.panel_type = 3;
    self.model = ToemsModel:GetInstance()
    self.model:SetItemsByQulityAndStar(0, 0)
    --ToemsEquipPanel.super.Load(self)
end

function ToemsEquipPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.mEvents)
    if self.bagEventId then
        RemoveModelListener(self.bagEventId, BagModel:GetInstance());
    end
    self.bagEventId = nil;

    self.selectedStar = 0;
    self.selectedColor = 0;

    self.equips = {};
    destroyTab(self.items);
    self.items = {};

    destroyTab(self.equipItems);
    self.equipItems = {};
    self.model:DelectedEmptyItem();
    if self.scrollView ~= nil then
        self.scrollView:OnDestroy()
    end
    self.scrollView = nil;

    self.equipText = nil;
    self.allBagEquip = nil;
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function ToemsEquipPanel:Open(slot)
    self.defaultSlot = slot;
    --self.allBagEquip = self.model:GetSortBeastBag(self.defaultSlot);
    WindowPanel.Open(self)
end

function ToemsEquipPanel:LoadCallBack()
    self.nodes = {
        "bag/Viewport","beastcon","bag","bag/Viewport/Content",
        "equip/equip_2","equip/equip_4","zhuanhua","equip/equip_5","equip/equip_1","equip/equip_3",
        "jie_drop","star_drop","getequip",
    }
    self:GetChildren(self.nodes)
    self.beastcon = GetImage(self.beastcon)
    self:SetMask();
    self.ScrollView = self.bag:GetComponent('RectTransform')
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("toems_image", "Toems_title_2");
    AddBgMask(self.gameObject, 20, 20, 20, 80);

    --BagController:GetInstance():RequestBagInfo(BagModel.toems);
end



function ToemsEquipPanel:InitUI()
    self.zhuanhua = GetButton(self.zhuanhua);
    self.equips = {};
    self.equipText = {};
    for i = 1, 5 do
        self.equips[i] = GetImage(self["equip_" .. i]);
        local child = GetChild(self.equips[i].transform, "des");
        self.equipText[i] = GetText(child);
    end
    self:InitDropDown();
    self:UpdateAllBagEquip(self.defaultSlot);
    self:HandleBagItems(self.defaultSlot);

    local beastConfig = Config.db_totems[self.model.currentBeastEquip];
    if beastConfig then
        local slotColorTab = String2Table(beastConfig.slot)
        for k, v in pairs(slotColorTab) do
            local key = v[1];
            local value = v[2];
            if self.equipText[key] then
                self.equipText[key].text = "<color=#" .. ToemsModel.FONTCOLOR[value] .. ">" .. tostring(ToemsModel.POS2CHINESE[key]) .. "</color>";
            end
        end
        lua_resMgr:SetImageTexture(self, self.beastcon, "toems_image",beastConfig.id, false);
    end

    self:RefreshEquips();

    local equipdata = self.model.EmbedEquips[self.model.currentBeastEquip] or {};
    if equipdata.summon then
        ShaderManager:GetInstance():SetImageNormal(self.beastcon);
    else
        ShaderManager:GetInstance():SetImageGray(self.beastcon);
    end

end

function ToemsEquipPanel:RefreshEquips()
    destroyTab(self.equipItems);
    self.equipItems = {};
    local resetPoscallback = function(baseiconsettor)
        SetAnchoredPosition(baseiconsettor.transform, -5, 5);
    end
    if self.is_loaded then
        if self.model.EmbedEquips[self.model.currentBeastEquip] then
            local tab = self.model.EmbedEquips[self.model.currentBeastEquip];
            local embedEquips = tab.equips;
            for k, v in pairs(embedEquips) do
                local equipConfig = Config.db_totems_equip[embedEquips[k].id];
                local slot = equipConfig.slot;

                local param = {}
                local operate_param = {}
                GoodsTipController.Instance:SetTakeOffCB(operate_param, handler(self, self.TakeOff), { embedEquips[k] })
                GoodsTipController.Instance:SetStrongCB(operate_param, handler(self, self.Strong), { embedEquips[k] })
                param["cfg"] = Config.db_totems_equip[embedEquips[k].id]
                param["model"] = self.model
                param["p_item"] = embedEquips[k]
                param["can_click"] = true
                param["operate_param"] = operate_param

                local awarditem = GoodsIconSettorTwo(self.equips[slot].transform);
                awarditem:SetIcon(param)
                --awarditem:RemoveUpdateNumEvent();
                if self.equipItems[slot] then
                    self.equipItems[slot]:destroy();
                end
                self.equipItems[slot] = awarditem;
            end
        end
    end
end



function ToemsEquipPanel:PutOnEquip(param)
    ToemsController:GetInstance():RequesEquipLoadInfo(self.model.currentBeastEquip, param[1].uid)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function ToemsEquipPanel:TakeOff(param)
    local equipCfg = Config.db_totems_equip[param[1].id]
    ToemsController:GetInstance():RequesEquipUnloadInfo(self.model.currentBeastEquip, equipCfg.slot)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function ToemsEquipPanel:Strong(param)
    local isSummon = false;
    if self.model.EmbedEquips[self.model.currentBeastEquip] then
        isSummon = self.model.EmbedEquips[self.model.currentBeastEquip].summon;
    end
    if self.model.strengthEnable and isSummon then
        lua_panelMgr:GetPanelOrCreate(ToemsStrengthPanel):Open(param[1].uid);
    else
        Notify.ShowText("The gear that has assisted totem can be strengthened");
    end
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end


ToemsEquipPanel.selectedColor = 0;
function ToemsEquipPanel:UpdateAllBagEquip(slot)
    if self.selectedColor == 0 and self.selectedStar == 0 then
        if slot then
            self.allBagEquip = self:GetSortBeastBag(slot);
        else
            self.allBagEquip = self:GetSortBeastBag2();
        end

    else
        self.model:SetItemsByQulityAndStar(self.selectedColor, self.selectedStar or 0);
        self.allBagEquip = self.model.equipBeasts;
    end

    if self.scrollView then
        self.scrollView:ForceUpdate();
    end
    --if self.scrollView then
    --    self.scrollView:scrollChange();
    --end
end



function ToemsEquipPanel:InitDropDown()
    --品质筛选
    self.jie_drop = GetDropDown(self.jie_drop);
    self.jie_drop.options:Clear();

    local od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "All quality";
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "Pink";
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "Red";
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "Orange";
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "Purple";
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "Blue";
    self.jie_drop.options:Add(od);
    --od = UnityEngine.UI.Dropdown.OptionData();
    --od.text = "绿色";
    --self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "White";
    self.jie_drop.options:Add(od);

    --星级筛选
    self.star_drop = GetDropDown(self.star_drop);
    self.star_drop.options:Clear();

    local od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "All stars";
    self.star_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "1-Star Gear";
    self.star_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "2-Star Gear";
    self.star_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "3-Star Gear";
    self.star_drop.options:Add(od);
end

function ToemsEquipPanel:AddEvent()
    for k, v in pairs(self.equips) do
        AddClickEvent(v.gameObject, handler(self, self.HandleEquipSort, k));
    end

    self.bagEventId = AddEventListenerInTab(BagEvent.LoadItemByBagId, handler(self, self.HandleBagItems), self.events, BagModel:GetInstance());

    AddClickEvent(self.zhuanhua.gameObject, handler(self, self.HandleZhuanhua));
    AddClickEvent(self.getequip.gameObject, handler(self, self.HandleGetEquip));

    AddValueChange(self.jie_drop.gameObject, handler(self, self.HandleJieSelected));
    AddValueChange(self.star_drop.gameObject, handler(self, self.HandleStarSelected));

    self.mEvents[#self.mEvents + 1] = self.model:AddListener(ToemsEvent.ToemsListInfo, handler(self, self.ToemsListInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(ToemsEvent.EquipLoadInfo, handler(self, self.EquipLoadInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(ToemsEvent.EquipUnloadInfo, handler(self, self.HandleEquipUnload))

    --AddEventListenerInTab(ToemsEvent.ToemsListInfo, handler(self, self.ToemsListInfo), self.events);
    --
    --AddEventListenerInTab(ToemsEvent.EquipLoadInfo, handler(self, self.EquipLoadInfo), self.events);
    --AddEventListenerInTab(ToemsEvent.EquipUnloadInfo, handler(self, self.HandleEquipUnload), self.events);

end

function ToemsEquipPanel:HandleEquipUnload(data)
    local id = data.id;
    local slot = data.slot;
    if slot == 0 then
        destroyTab(self.equipItems);
        self.equipItems = {};
    else
        if self.equipItems and self.equipItems[slot] then
            self.equipItems[slot]:destroy();
            self.equipItems[slot] = nil;
        end
    end
    self:UpdateAllBagEquip();
    --self:HandleBagItems();
end

function ToemsEquipPanel:EquipLoadInfo(data)
    local id = data.id;
    local p_item = data.equip;
    local resetPoscallback = function(baseiconsettor)
        SetAnchoredPosition(baseiconsettor.transform, -5, 5);
    end
    local equipConfig = Config.db_totems_equip[p_item.id];
    local slot = equipConfig.slot;

    local param = {}
    local operate_param = {}
    GoodsTipController.Instance:SetTakeOffCB(operate_param, handler(self, self.TakeOff), { p_item })
    param["cfg"] = Config.db_totems_equip[p_item.id]
    param["model"] = self.model
    param["p_item"] = p_item
    param["can_click"] = true
    param["operate_param"] = operate_param

    local awarditem = GoodsIconSettorTwo(self.equips[slot].transform);
    awarditem:SetIcon(param)
    --awarditem:RemoveUpdateNumEvent();
    if self.equipItems[slot] then
        self.equipItems[slot]:destroy();
    end
    self.equipItems[slot] = awarditem;
    --self:HandleBagItems();
    self:UpdateAllBagEquip();

    --self.allBagEquip = self.model:GetSortBeastBag(self.defaultSlot);
end


function ToemsEquipPanel:ToemsListInfo()
    self:RefreshEquips();
end


function ToemsEquipPanel:HandleJieSelected(go, value)
    if value == 0 then
        self.selectedColor = value;
    else
        self.selectedColor = 8 - value;
    end
    if self.selectedColor == 2 then
        self.selectedColor = 1;
    end
    self.model:SetItemsByQulityAndStar(self.selectedColor, self.selectedStar or 0);
    self:ForceRefreshByTogChange();
end

function ToemsEquipPanel:HandleStarSelected(go, value)
    --print2(value);
    self.selectedStar = value;

    self.model:SetItemsByQulityAndStar(self.selectedColor or 0, self.selectedStar or 0)
    self:ForceRefreshByTogChange();
end

function ToemsEquipPanel:ForceRefreshByTogChange()
    self.allBagEquip = self.model.equipBeasts;
    self.model:Brocast(BagEvent.LoadItemByBagId, BagModel.toems)

    if self.scrollView then
        self.scrollView:ForceUpdate();
    end
end






function ToemsEquipPanel:HandleGetEquip(go, x, y)
    --Notify.ShowText(ConfigLanguage.Language.BeastEquipTip2);
end

function ToemsEquipPanel:HandleZhuanhua(go, x, y)
    --Notify.ShowText("转化");
    --OpenLink(170, 1, 1, true)
    -- OpenLink(170, 1, 2, 106, nil, 1, true)
    local opLv = Config.db_equip_combine_sec_type[108].open_level
    if RoleInfoModel:GetInstance():GetMainRoleLevel() >= opLv then
        local cfg = Config.db_item[301062]
        local compose = cfg.compose
        OpenLink(unpack(String2Table(compose)))
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    end
end


--k是位置,不同位置不同筛选
function ToemsEquipPanel:HandleEquipSort(go, x, y, k)
    if self.defaultSlot == k then
        return ;
    end
    self.defaultSlot = k;
    --初始化背包
    self:UpdateAllBagEquip(self.defaultSlot);
    --self:HandleBagItems(self.defaultSlot);
    --self:HandleBagItems(k);
end

--刷新背包
function ToemsEquipPanel:HandleBagItems(slot)
    self:CreateItems()
end

function ToemsEquipPanel:CreateItems(cellCount)
    local param = {}
    local cellSize = { width = 76, height = 76 }
    param["scrollViewTra"] = self.ScrollView
    param["cellParent"] = self.Content
    param["cellSize"] = cellSize
    param["cellClass"] = ToemsBagItemSettor
    param["begPos"] = Vector2(5, -5)
    param["spanX"] = 5
    param["spanY"] = 5
    param["createCellCB"] = handler(self, self.UpdateCellCB)
    param["updateCellCB"] = handler(self, self.UpdateCellCB)
    param["totalColumn"] = 4;
    param["cellCount"] = Config.db_bag[BagModel.toems].cap
    if self.scrollView then
        self.scrollView:OnDestroy();
    end
    self.scrollView = nil;
    self.scrollView = ScrollViewUtil.CreateItems(param)
end

function ToemsEquipPanel:UpdateCellCB(itemCLS)
    if self.allBagEquip ~= nil then
        --print2(itemCLS.__item_index);
        local itemBase = self.allBagEquip[itemCLS.__item_index]
        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            --配置表存该物品
            if configItem ~= nil then
                local param = {}
                --type,uid,id,num,bag,bind,outTime
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = itemBase.bind
                param["stencil_id"] = self.StencilId;
                param["cellSize"] = { x = 80, y = 80 };
                param["outTime"] = itemBase.etime
                param["get_item_cb"] = handler(self, self.GetItemDataByUid)
                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end
        else
            local param = {}
            param["bag"] = BagModel.beast
            param["get_item_cb"] = handler(self, self.GetItemDataByUid)
            param["model"] = self.model
            param["stencil_id"] = self.StencilId;
            param["cellSize"] = { x = 80, y = 80 };
            itemCLS:InitItem(param)
        end
    else
        local param = {}

        param["bag"] = BagModel.beast
        param["model"] = self.model
        param["stencil_id"] = self.StencilId;
        param["get_item_cb"] = handler(self, self.GetItemDataByUid)
        param["cellSize"] = { x = 80, y = 80 };
        itemCLS:InitItem(param)
    end
end

function ToemsEquipPanel:GetItemDataByIndex(index)
    return self.model.equipBeasts[index]
end

function ToemsEquipPanel:GetItemDataByUid(uid)
    return self.model:GetItemDataByUid(uid);
end



function ToemsEquipPanel:GetSortBeastBag(slot)
    slot = slot or 0;
    local allItems = self.model:GetBeastBagItems();
    local itemArr = {};
    for k, v in pairs(allItems) do
        local equipConfig1 = Config.db_totems_equip[v.id];
        if equipConfig1.slot ~= 0 then
            table.insert(itemArr, v);
        end
    end
    table.sort(itemArr, function(p_item1, p_item2)
        local itemConfig1 = Config.db_item[p_item1.id];
        local itemConfig2 = Config.db_item[p_item2.id];

        local equipConfig1 = Config.db_totems_equip[p_item1.id];
        local equipConfig2 = Config.db_totems_equip[p_item2.id];

        if equipConfig1.slot == slot and equipConfig2.slot ~= slot then
            return true;
        elseif equipConfig2.slot == slot and equipConfig1.slot ~= slot then
            return false;
        else
            --相同卡槽或者卡槽不同,但是都不等于目标卡槽
            if equipConfig1.slot == equipConfig2.slot then
                if itemConfig1.color == itemConfig2.color then
                    if equipConfig1.star == equipConfig2.star then
                        if p_item1.extra == p_item2.extra then
                            return p_item1.uid > p_item2.uid;
                        else
                            return p_item1.extra > p_item2.extra;
                        end
                    else
                        return equipConfig1.star > equipConfig2.star;
                    end
                else
                    return itemConfig1.color > itemConfig2.color;
                end
            else
                return equipConfig2.slot > equipConfig1.slot;
            end
        end
    end);
    return itemArr;
end

function ToemsEquipPanel:GetSortBeastBag2(slot)
    slot = slot or 0;
    local allItems = self.model:GetBeastBagItems();
    local itemArr = {};
    for k, v in pairs(allItems) do
        local equipConfig1 = Config.db_totems_equip[v.id];
        if equipConfig1.slot ~= 0 then
            table.insert(itemArr, v);
        end
    end
    table.sort(itemArr, function(p_item1, p_item2)
        local itemConfig1 = Config.db_item[p_item1.id];
        local itemConfig2 = Config.db_item[p_item2.id];

        local equipConfig1 = Config.db_totems_equip[p_item1.id];
        local equipConfig2 = Config.db_totems_equip[p_item2.id];

        if equipConfig1.slot == slot and equipConfig2.slot ~= slot then
            return true;
        elseif equipConfig2.slot == slot and equipConfig1.slot ~= slot then
            return false;
        else
            --相同卡槽或者卡槽不同,但是都不等于目标卡槽
            if itemConfig1.color == itemConfig2.color then
                if equipConfig1.star == equipConfig2.star then
                    if equipConfig1.slot == equipConfig2.slot then
                        if p_item1.extra == p_item2.extra then
                            return p_item1.score > p_item2.score;
                        else
                            return p_item1.extra > p_item2.extra;
                        end
                    else
                        return equipConfig2.slot > equipConfig1.slot;
                    end

                else
                    return equipConfig1.star > equipConfig2.star;
                end
            else
                return itemConfig1.color > itemConfig2.color;
            end


        end
    end);
    return itemArr;
end

function ToemsEquipPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end