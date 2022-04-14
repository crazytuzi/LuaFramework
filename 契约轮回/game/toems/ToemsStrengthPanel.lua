---
--- Created by  Administrator
--- DateTime: 2020/7/28 10:29
---
ToemsStrengthPanel = ToemsStrengthPanel or class("ToemsStrengthPanel", WindowPanel)
local this = ToemsStrengthPanel

function ToemsStrengthPanel:ctor(parent_node, parent_panel)
    self.abName = "toems"
    self.assetName = "ToemsStrengthPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.gEvents = {}
    self.panel_type = 2;
    self.model = ToemsModel.GetInstance()
    self.model:DelectedEmptyItem()
    self.model.maxColor = 6;
    self.selectedList = {};
    self.schedules = {};
   -- ToemsStrengthPanel.super.Load(self)
end

function ToemsStrengthPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gEvents)
    self.model.ItemsUid = {}
    self.model = nil;
    self:StopAllSchedules()
    self.selectedList = nil;

    if self.blood then
        self.blood:destroy();
    end

    if self.scrollViewScp ~= nil then
        self.scrollViewScp:OnDestroy()
    end
    self.scrollViewScp = nil;

    self.values = nil;
    self.preSelectItem = nil;

    destroyTab(self.items);
    self.items = nil;
    self.starimgs = nil;
end

function ToemsStrengthPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function ToemsStrengthPanel:LoadCallBack()
    self.nodes = {
        "bag","jie_drop","light","MiddleObj/stars/star_1","ToemsItem","MiddleObj/stars/star_2","leftObj/ScrollView/Viewport/Content",
        "name","attrParent/attr1","attrParent/attr2","wenhao","bag/Viewport/BagContent","strengthbtn",
        "MiddleObj/power/next","MiddleObj/stars/star_3","dark","MiddleObj/power/pre","bag/Viewport","MiddleObj/equipcon",
        "percent","MiddleObj/power/arrow","selectall",

    }
    self:GetChildren(self.nodes)
    self.ScrollView = GetRectTransform(self.bag)

    self:InitUI()
    self:AddEvent()

    self:InitDefaultSelected();
    self:SetTileTextImage("toems_image", "Toems_title_3");
    --self:SetTileTextImage(self.image_ab, "beast_strength_text");
end

function ToemsStrengthPanel:InitDefaultSelected(selectedQuality)
    if self.model:defaultStrengthSelect() == 1 then
        self.selectall.isOn = true;
    else
        self.selectall.isOn = false;
        self.model:SetItemsByLessQuality(self.model.maxColor - self.model:defaultStrengthColor(), selectedQuality or 3);
        if self.scrollViewScp then
            self.scrollViewScp:ForceUpdate();
        end
    end
    self:CalcExp();
end

function ToemsStrengthPanel:InitUI()
    self.starimgs = {};
    for i = 1, 3 do
        self.starimgs[i] = GetImage(self["star_" .. i]);
    end

    self.webBtn = GetButton(self.webBtn);--问号

    self.pre = GetText(self.pre);
    self.next = GetText(self.next);
    self.pre.text = "0";
    self.next.text = "0";
    self.percent = GetText(self.percent);
    self.name = GetText(self.name)
    self.prop_1 = GetText(self.attr1);
    self.prop_2 = GetText(self.attr2);
    self.values = {};
    self.values[1] = self.prop_1;
    self.values[2] = self.prop_2;

    self.light = GetImage(self.light);
    self.light.fillAmount = 0;
    self.dark = GetImage(self.dark);
    --SetSizeDeltaX(self.light.transform, 0);

    self.equipcon = GetImage(self.equipcon);


    self.bagimgs = {};

    self.selectall = GetToggle(self.selectall);

    self:InitTogs();
    self:InitDropDown();

    self:HandleBagItems();

end

--刷新背包
function ToemsStrengthPanel:HandleBagItems()
    self:LoadItems()
end

function ToemsStrengthPanel:LoadItems()
    self.model:SetItemsByLessQuality(self.model.maxColor - self.jie_drop.value)

    local param = {}
    local cellSize = { width = 74, height = 74 }
    param["scrollViewTra"] = self.ScrollView
    param["cellParent"] = self.BagContent
    param["cellSize"] = cellSize
    param["cellClass"] = ToemsBagItemSettor
    param["begPos"] = Vector2(5, -5)
    param["spanX"] = 2
    param["spanY"] = 5
    param["createCellCB"] = handler(self, self.CreateCellCB)
    param["updateCellCB"] = handler(self, self.UpdateCellCB)
    param["totalColumn"] = 9;
    param["cellCount"] = Config.db_bag[BagModel.toems].cap
    self.scrollViewScp = ScrollViewUtil.CreateItems(param)
end

function ToemsStrengthPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function ToemsStrengthPanel:UpdateCellCB(itemCLS)
    if self.model.beastItemDatas ~= nil then
        local itemBase = self.model.beastItemDatas[itemCLS.__item_index]
        if itemBase ~= nil then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then
                --配置表存该物品
                local param = {}
                --type,uid,id,num,bag,bind,outTime
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = itemBase.bind
                param["cellSize"] = { x = 80, y = 80 };
                param["itemBase"] = itemBase;
                param["outTime"] = itemBase.etime
                param["multy_select"] = true
                param["model"] = self.model
                param["get_item_cb"] = handler(self, self.GetItemDataByIndex)
                param["selectItemCB"] = handler(self, self.SelectItemCB)
                param["get_item_select_cb"] = handler(self, self.GetItemSelect)

                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
                --itemCLS:SelectItem(itemBase.bag, self:GetItemSelect(itemBase.uid))
            end
        else
            local param = {}
            param["bag"] = BagModel.toems
            param["multy_select"] = true
            param["get_item_cb"] = handler(self, self.GetItemDataByIndex)
            param["selectItemCB"] = handler(self, self.SelectItemCB)
            param["get_item_select_cb"] = handler(self, self.GetItemSelect)
            param["model"] = self.model;
            param["cellSize"] = { x = 80, y = 80 };
            itemCLS:InitItem(param)
        end

    end
end

function ToemsStrengthPanel:DelItemCB(uid)
    self.model:DelSelectItemByUid(uid)
end

function ToemsStrengthPanel:GetItemDataByIndex(idx)
    return self.model.beastItemDatas[idx]
end
function ToemsStrengthPanel:GetItemDataByUid(uid)
    return self.model:GetItemDataByUid(uid);
end

function ToemsStrengthPanel:SelectItemCB(uid, is_select)
    self.model:SetItemSelect(uid, is_select)
end

function ToemsStrengthPanel:GetItemSelect(uid)
    local select = self.model:GetItemSelect(uid)
    return select ~= nil and select == true or false
end






function ToemsStrengthPanel:InitDropDown()
    self.jie_drop = GetDropDown(self.jie_drop);

    self.jie_drop.options:Clear();
    local od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.Red) .. ">red </color>and below";
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.Orange) .. ">orange </color>and below";
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "<color=#D63BFF>purple </color>and below";--" .. ColorUtil.GetColor(ColorUtil.ColorType.Purple) .. "
    self.jie_drop.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.Blue) .. ">blue </color>and below";
    self.jie_drop.options:Add(od);
    --od = UnityEngine.UI.Dropdown.OptionData();
    --od.text = "<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.Green) .. ">绿色</color>及以下";
    --self.jie_drop.options:Add(od);

    self.jie_drop.value = ToemsModel:GetInstance():defaultStrengthColor();

    AddValueChange(self.jie_drop.gameObject, handler(self, self.HandleColorSelected));
end

ToemsStrengthPanel.autoSet = false;
--选择颜色1,橙色及以下2,紫色,3,蓝,4绿5白
function ToemsStrengthPanel:HandleColorSelected(go, value)
    --self:SetAllSelected(false);
    --if go == self.selectall.gameObject then
    --    return;
    --end
    --if go then
    self.autoSet = true;
    --self.selectall.isOn = true;
    self.autoSet = false;
    --end

    local color = self.model.maxColor - value;
    local defalutColor = self.selectall.isOn and 100 or 3;
    ToemsModel:GetInstance():defaultStrengthColor(value);
    self.model:SetItemsByLessQuality(color, defalutColor)
    self.model:Brocast(BagEvent.LoadItemByBagId, BagModel.toems);
    self:CalcExp();
    if self.scrollViewScp then
        self.scrollViewScp:ForceUpdate();
    end
end


--计算所有选中的材料总共能加多少经验,顺便看看能升多少级
function ToemsStrengthPanel:CalcExp()
    self.addedExp = 0;
    for k, v in pairs(self.model.ItemsUid) do
        local item = self.model:GetItemByUid(v);
        if item then
            local equipConfig = Config.db_totems_equip[item.id];
            if equipConfig then
                self.addedExp = self.addedExp + equipConfig.exp;

                if item.extra and item.extra >= 1 then
                    local slot = equipConfig.slot;
                    local total = 0;
                    for i = 1, item.extra do
                        local reinConfig = Config.db_totems_reinforce[slot .. "@" .. item.extra];
                        if reinConfig then
                            total = reinConfig.total;
                        end
                    end
                    self.addedExp = self.addedExp + total;
                end
            end
        end
    end
    --local str = self.percent.text;
    --if not string.isNilOrEmpty(str) and string.find(str , "%%s") then
    --    self.percent.text = string.format(str , self.addedExp);
    --end
    if self.preSelectItem then
        local data = self.preSelectItem.data;
        local equipConfig = Config.db_totems_equip[data.id];
        if data.equip.stren_lv == 0 then
            data.equip.stren_lv = 1;
        end
        local currentEquipConfig = Config.db_totems_reinforce[equipConfig.slot .. "@" .. data.equip.stren_lv];
        self.percent.text = data.equip.stren_phase .. "<color=#ffff00>+" .. self.addedExp .. "</color>/" .. currentEquipConfig.exp;

        self.light.fillAmount = (data.equip.stren_phase / currentEquipConfig.exp);

        local addedExp = self.addedExp + data.equip.stren_phase;
        local nextLevel = data.equip.stren_lv
        for i = nextLevel, 500 do
            local equipConfig = Config.db_totems_reinforce[equipConfig.slot .. "@" .. i];
            if equipConfig.exp <= addedExp then
                addedExp = addedExp - equipConfig.exp;
                nextLevel = i + 1;
            end
        end
        local flag = true;
        if nextLevel >= 500 then
            nextLevel = 500;
            if data.equip.stren_lv == 500 then
                flag = false;
            end

        end
        if nextLevel == data.equip.stren_lv and nextLevel < 500 then
            nextLevel = data.equip.stren_lv + 1;
        end
        self.next.text = "+" .. nextLevel;
        self.pre.text = "+" .. data.equip.stren_lv;

        SetGameObjectActive(self.next , flag);
        SetGameObjectActive(self.pre , flag);
        SetGameObjectActive(self.arrow , flag);
        local nextEquipConfig = nil;
        if flag then
            nextEquipConfig = Config.db_totems_reinforce[equipConfig.slot .. "@" .. (nextLevel)];
        end


        local basePropTab = String2Table(currentEquipConfig.base);

        local index = 1;
        local nextBasePropTab = nil
        if nextEquipConfig then
            nextBasePropTab = String2Table(nextEquipConfig.base);
        end
        for k, v in pairs(basePropTab) do
            local text = PROP_ENUM[v[1]].label .. "+";
            if v[1] >= 13 then
                self.values[index].text = text .. GetPreciseDecimal(tonumber(v[2]) / 100, 2) .. "%";
            else
                self.values[index].text = text .. tostring(v[2]);
            end
            if nextBasePropTab then
                local nv = nextBasePropTab[k];
                if nv then
                    if v[1] >= 13 then
                        self.values[index].text = self.values[index].text .. "<color=#399E10>→" .. GetPreciseDecimal(tonumber(nv[2]) / 100, 2) .. "%</color>";-- - v[2]
                    else
                        self.values[index].text = self.values[index].text .. "<color=#399E10>→" .. tostring(nv[2]) .. "</color>";-- - v[2]
                    end
                end
            end

            index = index + 1;
        end
    end

end


function ToemsStrengthPanel:InitTogs()
    destroyTab(self.items);
    self.items = {};
    --SetGameObjectActive(self.us_item, true);
    local allEquips = ToemsModel:GetInstance():GetAllEquips();

    local selectedIndex = 1;
    local minStrenLevel = 100;
    for i = 1, #allEquips, 1 do
        local tab = allEquips[i];
        local item = ToemsItem(self.ToemsItem.gameObject,self.Content,"UI", tab);
        self.items[i] = item;
        --item:SetScoreText("强化等级 : " .. tab.equip.stren_lv)
        item:SetScoreText("");
        item:SetIsAssist(false);
        --SetParent(item.transform, self.Content.transform);
        --SetLocalPosition(item.transform, 0, 0, 0);
        --SetLocalScale(item.transform, 1, 1, 1);

        if self.data then
            if tab.uid == self.data then
                selectedIndex = i;
            end
        elseif tab.extra < minStrenLevel then
            minStrenLevel = tab.extra;
            selectedIndex = i;
        end
    end

    local rt = GetRectTransform(self.Content);
    SetSizeDeltaY(rt, #self.items * 92)
    if selectedIndex <= 3 then
        SetLocalPositionY(rt, 0);
    else
        SetLocalPositionY(rt, (selectedIndex - 3) * 92);
    end

    if #self.items > 0 then
        self:HandleScrollClick(nil, nil, nil, self.items[selectedIndex]);
    end

    --SetGameObjectActive(self.us_item, false);
end


ToemsStrengthPanel.preSelectItem = nil;
--点击ScrollItem事件
function ToemsStrengthPanel:HandleScrollClick(go, x, y, v)
    if self.preSelectItem then
        self.preSelectItem:SetIsSelected(false);
    end
    self.preSelectItem = v;
    v:SetIsSelected(true);
    self:RefreshItem(v);
    self:CalcExp();

    if v and v.data then
        local item = Config.db_totems_equip[v.data.id];

        local itemConfig = Config.db_item[v.data.id];
        local colorStr = "ffffff";
        if itemConfig.color > 1 then
            colorStr = ColorUtil.GetColor(itemConfig.color)
        end
        self.name.text = "<color=#" .. colorStr .. ">" .. tostring(itemConfig.name) .. "</color>";--BeastModel.FONTCOLOR[itemConfig.color]

        self:SetStarNum(item.star)
    else
        self:SetStarNum(0);
    end
end

function ToemsStrengthPanel:RefreshItem(item)
    local data = item.data;
    local equipConfig = Config.db_totems_equip[data.id];
    if data.equip.stren_lv == 0 then
        data.equip.stren_lv = 1;
    end
    local currentEquipConfig = Config.db_totems_reinforce[equipConfig.slot .. "@" .. data.equip.stren_lv];
    if not currentEquipConfig then
        self.percent.text = "";
        self.pre.text = "+" .. data.equip.stren_lv;
        self.next.text = "+" .. data.equip.stren_lv;
        self.light.fillAmount = 0;
        for k, v in pairs(self.values) do
            v.text = "";
        end
        return ;
    end
    self:CalcExp();

    local itemConfig = Config.db_item[data.id];

    if itemConfig then
        if self.preIcon ~= itemConfig.icon then
            GoodIconUtil.GetInstance():CreateIcon(self, self.equipcon, itemConfig.icon, true)
            --lua_resMgr:SetImageTexture(self, self.equipcon, "iconasset/icon_beast", itemConfig.icon, false, nil, false);
            self.preIcon = itemConfig.icon;
        end
       -- lua_resMgr:SetImageTexture(self, self.equipbg, self.image_ab, "color_" .. itemConfig.color, false, nil, false);
    end
end


function ToemsStrengthPanel:SetStarNum(num)
    for i = 1, 3 do
        SetGameObjectActive(self.starimgs[i] , false);
    end
    for i = 1, num do
        SetGameObjectActive(self.starimgs[i] , true);
    end
end



function ToemsStrengthPanel:AddEvent()
    AddClickEvent(self.wenhao.gameObject, handler(self, self.HandleHelp));
    AddValueChange(self.selectall.gameObject, handler(self, self.HandleSelectAll));
    AddClickEvent(self.strengthbtn.gameObject, handler(self, self.HandleStrength));

    for k, v in pairs(self.items) do
        AddClickEvent(v.gameObject, handler(self, self.HandleScrollClick, v))
    end

    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.EquipReinforceInfo, handler(self, self.HandleStrengthResult))
    --AddEventListenerInTab(ToemsEvent.EquipReinforceInfo, handler(self, self.HandleStrengthResult), self.events);
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(BagEvent.ClickItem, handler(self, self.CalcExp))
    --AddEventListenerInTab(BagEvent.ClickItem, handler(self, self.CalcExp), self.events);

end





function ToemsStrengthPanel:HandleStrengthResult(data)
    local id = data.id;
    local p_item = data.equip;
    local beastData = ToemsModel:GetInstance().EmbedEquips[id];

    for k, v in pairs(self.items) do
        if v.data.uid == p_item.uid then
            --v:SetScoreText("强化等级 : " .. p_item.equip.stren_lv);
            v.data = p_item;
        end
    end

    self:RefreshItem(self.preSelectItem);
    self.selectedList = {};
    self:CalcExp();
    if self.preSelectItem then
        self.preSelectItem:Refresh();
    end
    self.model:DelectedEmptyItem();

    --self:InitDefaultSelected(0);
    --self.model:SetItemsByLessQuality(self.model.maxColor - self.model:defaultStrengthColor(), 0);
    self.model:SetItemsByLessQuality(self.model.maxColor - self.model:defaultStrengthColor(), 0);

    --self:SetItemsByLessQuality();
    --GlobalEvent:Brocast(GoodsEvent.SelectItem, BagModel.beast, self.selectall.isOn);
    if self.scrollViewScp then
        self.scrollViewScp:ForceUpdate();
    end
    GlobalEvent:Brocast(GoodsEvent.SelectItem, BagModel.toems, false);
end


function ToemsStrengthPanel:HandleHelp(go, x, y)
    ShowHelpTip(self.model.help , true);
end

--选择全部
function ToemsStrengthPanel:HandleSelectAll(go, bool)
    --print2(bool);
    bool = toBool(bool);

    --if self.autoSet then
    --    return;
    --end
    --
    --if bool then
    --    self:HandleColorSelected(nil, self.jie_drop.value);
    --else
    --    self:SetAllSelected(false);
    --end
    local value = bool and 1 or 0;
    self.model.ItemsUid = {};
    self.model:defaultStrengthSelect(value);
    if bool then
        self:SetItemsByLessQuality();
        self.model:Brocast(BagEvent.LoadItemByBagId, BagModel.toems);
    end
    GlobalEvent:Brocast(GoodsEvent.SelectItem, BagModel.toems, bool);
    self:CalcExp();
end

function ToemsStrengthPanel:HandleStrength(go, x, y)
    if #self.model.ItemsUid > 0 then
        local beastID = self.model:GetBeastIDByItemUid(self.preSelectItem.data.uid);
        if beastID then
            ToemsController:GetInstance():RequesEquipReinforceInfo(beastID, self.preSelectItem.data.uid, self.model.ItemsUid, false);
        else
            Notify.ShowText("Wrong totem");
        end

    else

        Notify.ShowText("No selected");
    end

end

function ToemsStrengthPanel:SetItemsByLessQuality()
    local color = self.model.maxColor - ToemsModel:GetInstance():defaultStrengthColor()
    self.model:SetItemsByLessQuality(color);
end
function ToemsStrengthPanel:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
end