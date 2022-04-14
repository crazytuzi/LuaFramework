---
--- Created by  Administrator
--- DateTime: 2020/7/27 10:59
---
ToemsPanel = ToemsPanel or class("ToemsPanel", BaseItem)
local this = ToemsPanel

function ToemsPanel:ctor(parent_node, parent_panel)
    self.abName = "toems"
    self.assetName = "ToemsPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.model = ToemsModel.GetInstance()
    self.events = {}
    self.labels = {}
    ToemsPanel.super.Load(self)
end

function ToemsPanel:dctor()
    self.model:RemoveTabListener(self.events)
    destroyTab(self.items);
    self.items = nil;
    self:DestroySkills();
    self.skillItems = nil;
    destroyTab(self.equipItems);
    self.equipItems = {}
    self.equips = nil
    destroyTab(self.labels);
    self.labels = nil
    if self.strength_reddot then
        self.strength_reddot:destroy();
    end
    self.strength_reddot = nil;
    if self.bag_reddot then
        self.bag_reddot:destroy();
    end
    self.bag_reddot = nil;
    if self.summon_reddot then
        self.summon_reddot:destroy();
    end
    self.summon_reddot = nil;
end
function ToemsPanel:DestroySkills()
    if self.skillItems then
        for k, v in pairs(self.skillItems) do
            destroy(v);
        end
    end
end

function ToemsPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function ToemsPanel:LoadCallBack()
    self.nodes = {
        "leftObj/ScrollView/Viewport/Content","ToemsItem","ToemsAttrItem","ToemsSkillItem","rightObj/skills",
        "btns/summon/summonText","btns/summon","btns/bag","btns/onekey","btns/jiaBtn","btns/assistNum","btns/strength",
        "middleObj/moncon","rightObj/attrParent","middleObj/nameBg/name",
        "middleObj/equip/equip_3","middleObj/equip/equip_4","middleObj/equip/equip_5","middleObj/equip/equip_2","middleObj/equip/equip_1",

    }
    self:GetChildren(self.nodes)
    self.summonText = GetText(self.summonText)
    self.assistNum = GetText(self.assistNum)
    self.moncon = GetImage(self.moncon)
    self.summon = GetButton(self.summon)
    self.name = GetText(self.name)
    self.strength = GetButton(self.strength)
    self:InitUI()
    self:InitTogs()
    self:AddEvent()
    self.strength_reddot = RedDot(self.strength.transform, nil, RedDot.RedDotType.Nor)
    self.strength_reddot:SetPosition(64, 22);
    --self.strength_reddot:SetRedDotParam(true);

    self.bag_reddot = RedDot(self.bag.transform, nil, RedDot.RedDotType.Nor)
    self.bag_reddot:SetPosition(64, 22);
    --self.bag_reddot:SetRedDotParam(true);

    self.summon_reddot = RedDot(self.summon.transform, nil, RedDot.RedDotType.Nor)
    self.summon_reddot:SetPosition(64, 22);

    ToemsController:GetInstance():RequesToemsListInfo()
end

function ToemsPanel:InitUI()
    self.equips = {};
    for i = 1, 4 do
        --self.labels[i] = GetText(self["label_" .. i]);
        --self.values[i] = GetText(self["value_" .. i]);
        self.equips[i] = GetImage(self["equip_" .. i]);
    end
    self.equips[5] = GetImage(self["equip_" .. 5]);

end

function ToemsPanel:InitTogs()
    destroyTab(self.items);
    self.items = {};
    SetGameObjectActive(self.us_item, true);
    self.defaultSelectedIndex = 1;
    for i = 1, #self.model.allBeasts, 1 do
        local tab = self.model.allBeasts[i];
        local item = ToemsItem(self.ToemsItem.gameObject, self.Content,"UI",tab);
        self.items[i] = item;
        item:SetScoreText("Score: " .. 0);
        self:CalcScore(item);
        item:SetIcon(tab.res);
        item:SetColor(tab.color)

        --SetParent(item.transform, self.Content.transform);
        --SetLocalPosition(item.transform, 0, 0, 0);
        --SetLocalScale(item.transform, 1, 1, 1);
    end

    local rt = GetRectTransform(self.Content);
    rt.sizeDelta = Vector2(rt.sizeDelta.x, #self.items * 90);
    if #self.items >= self.defaultSelectedIndex then
        self:HandleScrollClick(nil, nil, nil, self.defaultSelectedIndex);--self.items[1]
    end
    if self.defaultSelectedIndex <= 3 then
        SetLocalPositionY(rt, 0);
    else
        SetLocalPositionY(rt, (self.defaultSelectedIndex - 3) * 90);
    end

    SetGameObjectActive(self.us_item, false);
end




function ToemsPanel:AddEvent()
    for k, v in pairs(self.items) do
        AddClickEvent(v.gameObject, handler(self, self.HandleScrollClick, k));
    end

    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.ToemsListInfo, handler(self, self.ToemsListInfo))
    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.EquipLoadInfo, handler(self, self.HandleBeastEquipLoad))
    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.EquipUnloadInfo, handler(self, self.HandleEquipUnload))
    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.SummonInfo, handler(self, self.HandleSummonChange))
    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.UnSummonInfo, handler(self, self.HandleSummonChange))
    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.AddSummonInfo, handler(self, self.HandleMaxSummon))

    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.UpdateRedDot, handler(self, self.UpdateReddot))


    --AddEventListenerInTab(BeastEvent.ADD_MAX_SUMMON, handler(self, self.HandleMaxSummon), self.events);

    AddClickEvent(self.strength.gameObject, handler(self, self.HandleStrength));

    AddClickEvent(self.onekey.gameObject, handler(self, self.HandleOneKey));

    AddClickEvent(self.bag.gameObject, handler(self, self.HandleEquipBag));

    AddClickEvent(self.summon.gameObject, handler(self, self.HandleSummon));

    AddClickEvent(self.jiaBtn.gameObject, handler(self, self.HandleOpenBuyTip));

end



function ToemsPanel:HandleStrength()
    if self.strength.enabled then
        lua_panelMgr:GetPanelOrCreate(ToemsStrengthPanel):Open();
    else
        Notify.ShowText("The gear that has assisted totem can be strengthened");
    end
    self.model.red_dot_list[2] = false;
    self:UpdateReddot();
end

--@一键卸下
function ToemsPanel:HandleOneKey()
    if self.preSelectItem then
        local data = self.preSelectItem.data;
        ToemsController:GetInstance():RequesEquipUnloadInfo(data.id, 0);
    end
end

--@ling autofun
function ToemsPanel:HandleEquipBag(go, x, y)
    local bagui = lua_panelMgr:GetPanel(ToemsEquipPanel);
    if bagui then
        bagui:Close();
    end
    self.model.currentBeastEquip = self.preSelectItem.data.id;

    --local slot = self.model:GetCurrentDefaultSlot();
    lua_panelMgr:GetPanelOrCreate(ToemsEquipPanel):Open(1);
end

function ToemsPanel:HandleOpenBuyTip(go, x, y)
    local tab = Config.db_totems_summon[self.model.max_summon + 1];

    if tab then
        local panel = lua_panelMgr:GetPanel(ToemsBuyTip);
        if panel then
            panel:Close();
        end
        lua_panelMgr:GetPanelOrCreate(ToemsBuyTip):Open(tab);


    else
        Notify.ShowText("Full");
    end


end




function ToemsPanel:HandleSummon(go, x, y)
    if self.summon.interactable then
        local embedEquips = self.model.EmbedEquips[self.preSelectItemIndex];
        if embedEquips then
            if embedEquips.summon then
                ToemsController:GetInstance():RequesUnSummonInfo(self.preSelectItemIndex);
            else
                ToemsController:GetInstance():RequesSummonInfo(self.preSelectItemIndex);
            end
        else
        end
    else

    end
end


function ToemsPanel:HandleSummonChange(id)
    local embedEquips = self.model.EmbedEquips[self.preSelectItemIndex];

    self:HandleMaxSummon();
    self:RefreshImage();
    if self.items and self.items[self.model.currentBeastEquip] then
        self:CalcScore(self.items[self.model.currentBeastEquip]);
    end
    --self:RefreshEquipProp();
    if embedEquips then
        if embedEquips.summon then
            self.summonText.text = "Recall";
            self.summon.interactable = true;
            ShaderManager:GetInstance():SetImageNormal(self.summonImg);
            self.preSelectItem:SetIsAssist(embedEquips.summon);
            self.preSelectItem:SetGray(not embedEquips.summon)
            return ;
        end
    end
    self:HandleSummonBtnStatus();

end

function ToemsPanel:ToemsListInfo()
    local index = 0;
    for k, v in pairs(self.model.EmbedEquips) do
        if v.summon then
            index = index + 1;
            if self.items[k] then
                self.items[k]:SetIsAssist(true);
                self.items[k]:SetGray(false);
            end
        end
    end
    self:RefreshEquips();

    self:RefreshEquipProp();

    self:HandleMaxSummon();

    --
    self:UpdateReddot();
end

function ToemsPanel:HandleBeastEquipLoad(data)
    local id = data.id;
    local p_item = data.equip;

    --local equipConfig = Config.db_beast_equip[p_item.id];
    --local slot = equipConfig.slot;
    --local resetPoscallback = function(baseiconsettor)
    --    SetAnchoredPosition(baseiconsettor.transform, -5, 5);
    --end
    --local awarditem = GoodsIconSettorTwo(self.equips[slot].transform);
    --awarditem:LoadNow(resetPoscallback);
    --awarditem:UpdateIconClickNotOperate(p_item, 1, nil, ClickGoodsIconEvent.Click.BEAST_SHOW);
    ----local awarditem = AwardItem(self.equips[slot].transform);
    ----awarditem:SetData(p_item.id, 1);
    --if self.equipItems[slot] then
    --    self.equipItems[slot]:destroy();
    --end
    --self.equipItems[slot] = awarditem;
    self:HandleSummonBtnStatus();
    self:RefreshEquips();
    self:RefreshEquipProp();


    self:CalcScore(self.items[data.id])
    --self:RefreshEquips();
end

function ToemsPanel:HandleEquipUnload(data)
    local id = data.id;
    local slot = data.slot;

    self:RefreshEquips();
    self:RefreshEquipProp();
    --if slot == 0 then
    --    if self.preSelectItemIndex == id then
    --        destroyTab(self.equipItems);
    --        self.equipItems = {};
    --    end
    --else
    --    if self.equipItems and self.equipItems[slot] then
    --        self.equipItems[slot]:destroy();
    --        self.equipItems[slot] = nil;
    --    end
    --end
    local embedEquips = self.model.EmbedEquips[id];
    if embedEquips then
        embedEquips.summon = false;
    end
    self:HandleMaxSummon();
    self:HandleSummonBtnStatus();

    self:CalcScore(self.items[data.id])
end


function ToemsPanel:HandleSummonBtnStatus()
    local embedEquips = self.model.EmbedEquips[self.preSelectItemIndex];
    local index = 1;
    if embedEquips then
        local equips = embedEquips.equips;
        for k, v in pairs(equips) do
            index = index + 1;
        end
        if index == 6 then
            self.summonText.text = "Assist";
            self.summon.interactable = true;
            ShaderManager:GetInstance():SetImageNormal(self.summonImg);
        else
            self.summonText.text = "Assist"
            self.summon.interactable = false;
            ShaderManager:GetInstance():SetImageGray(self.summonImg);
        end
        self.preSelectItem:SetIsAssist(embedEquips.summon);
        self.preSelectItem:SetGray(not embedEquips.summon);
    else
        self.summonText.text = "Assist"
        self.summon.interactable = false;
        ShaderManager:GetInstance():SetImageGray(self.summonImg);
        self.preSelectItem:SetIsAssist(false);
        self.preSelectItem:SetGray(true);
    end


end


function ToemsPanel:UpdateReddot()
    local red_dot_list = self.model.red_dot_list;
    if self.summon_reddot then
        if self.model:GetSummonReddot() then
            self.summon_reddot:SetRedDotParam(true);
        else
            self.summon_reddot:SetRedDotParam(false);
        end
    end
    if self.strength_reddot then
        self.strength_reddot:SetRedDotParam(red_dot_list[2] and self.strength.enabled);
    end

    if self.bag_reddot then
        if self.model:GetCanUpdateReddot(self.model.currentBeastEquip) or self.model:GetCanEquipReddot(self.model.currentBeastEquip) then
            self.bag_reddot:SetRedDotParam(true);
        else
            self.bag_reddot:SetRedDotParam(false);
        end
    end
    if self.items then
        for i = 1, #self.items do
            if self.model:GetSummonReddot(i) or self.model:GetCanUpdateReddot(i) or self.model:GetCanEquipReddot(i) then
                self.items[i]:ShowReddot(true);
            else
                self.items[i]:ShowReddot(false);
            end
        end
    end

end

function ToemsPanel:HandleMaxSummon()
    local index = 0;
    local flag = false;
    for k, v in pairs(self.model.EmbedEquips) do
        if v.summon then
            index = index + 1;
            if self.items[k] then
                self.items[k]:SetIsAssist(true);
            end
            flag = true;
        end
    end
    if flag then
        local img = GetImage(self.strength.gameObject);
        ShaderManager:GetInstance():SetImageNormal(img);
        self.strength.enabled = true;
        self.model.strengthEnable = true;
    else
        local img = GetImage(self.strength.gameObject);
        ShaderManager:GetInstance():SetImageGray(img);
        self.strength.enabled = false;
        self.model.strengthEnable = false;
    end
    self.assistNum.text = "Assist totem: <color=#56BF3E>" .. index .. "/" .. self.model.max_summon .. "</color>";
end



ToemsPanel.preSelectItem = nil;
ToemsPanel.preSelectItemIndex = -1;
--点击ScrollItem事件
function ToemsPanel:HandleScrollClick(go, x, y, k)
    if self.preSelectItemIndex == k then
        return ;
    end
    if self.preSelectItem then
        self.preSelectItem:SetIsSelected(false);
    end
    self.preSelectItemIndex = k;
    self.preSelectItem = self.items[k];
    self.preSelectItem:SetIsSelected(true);
    self:RefreshItem(self.preSelectItem);
    self.model.currentBeastEquip = self.preSelectItem.data.id;
    self:RefreshImage();
    self:UpdateReddot();
end

function ToemsPanel:RefreshImage()
    local data1 = self.preSelectItem.data;

    self.name.text = data1.name
    lua_resMgr:SetImageTexture(self, self.moncon, "toems_image", data1.id, false);
    --local data = self.preSelectItem.data;
    local data = self.model.EmbedEquips[self.preSelectItemIndex];
    if data and data.summon then
        ShaderManager:GetInstance():SetImageNormal(self.moncon);
    else
        ShaderManager:GetInstance():SetImageGray(self.moncon);
    end
end


function ToemsPanel:RefreshItem(item)
    local data = item.data;

    local index = 1;
    --SetGameObjectActive(self.beast_skill_item, true);
    local skill = String2Table(data.skill);
    index = 1;
    self:DestroySkills()
    self.skillItems = {};
    for k, v in pairs(skill) do
        local skillConfig = Config.db_skill[v[1]];
        if skillConfig then
            local bsi = ToemsSkillItem(self.ToemsSkillItem.gameObject,self.skills,"UI")
            local icon = GetImage(GetChild(bsi.transform, "skill_icon"));
            local level = GetText(GetChild(bsi.transform, "skill_level"));
            level.text = "Level" .. tostring(v[2]);
            lua_resMgr:SetImageTexture(self, icon, "iconasset/icon_skill", skillConfig.icon, true);
            SetGameObjectActive(icon, true);
            --SetParent(bsi.transform, self.skills.transform);
            --SetLocalPosition(bsi.transform, 0, 0, 0);
            --SetLocalScale(bsi.transform, 1, 1, 1);
            self.skillItems[index] = bsi.gameObject;
            index = index + 1;
            AddClickEvent(bsi.gameObject, handler(self, self.HandleSkillTip, v[1]));
        end
    end

    self:RefreshEquipProp();
    self:RefreshEquips();
end


function ToemsPanel:HandleSkillTip(go, x, y, id)
    local tipsPanel = lua_panelMgr:GetPanelOrCreate(TipsSkillPanel)
    tipsPanel:Open();
    tipsPanel:SetId(id, self.skills)
end


function ToemsPanel:RefreshEquips()
    destroyTab(self.equipItems);
    self.equipItems = {};
    local resetPoscallback = function(baseiconsettor)
        SetAnchoredPosition(baseiconsettor.transform, -5, 5);
    end
    if self.is_loaded then
        if self.model.EmbedEquips[self.preSelectItemIndex] then
            local tab = self.model.EmbedEquips[self.preSelectItemIndex];
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
                --param["out_call_back"] = callback
                param["operate_param"] = operate_param

                local awarditem = GoodsIconSettorTwo(self.equips[slot].transform);
                awarditem:SetIcon(param)

                --awarditem:LoadNow(resetPoscallback);
                --awarditem:UpdateIconClickNotOperate(embedEquips[k], 0, nil, ClickGoodsIconEvent.Click.BEAST_SHOW);
                --local awarditem = AwardItem(self.equips[slot].transform);
                --awarditem:SetData(embedEquips[k].id, 1);
                if self.equipItems[slot] then
                    self.equipItems[slot]:destroy();
                end
                self.equipItems[slot] = awarditem;
            end
        end
    end
end


function ToemsPanel:TakeOff(param)
    local equipCfg = Config.db_totems_equip[param[1].id]
    ToemsController:GetInstance():RequesEquipUnloadInfo(self.model.currentBeastEquip, equipCfg.slot)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function ToemsPanel:Strong(param)
    if self.strength.enabled then
        lua_panelMgr:GetPanelOrCreate(ToemsStrengthPanel):Open(param[1].uid);
    else
        Notify.ShowText("The gear that has assisted totem can be strengthened");
    end
end


function ToemsPanel:RefreshEquipProp()
    if not self.preSelectItem then
        return ;
    end
    local data = self.preSelectItem.data;
    local embedEquips = self.model.EmbedEquips[self.preSelectItemIndex];
    local propTab = {};
    if embedEquips then
        local equips = embedEquips.equips;
        local index = 1;
        local eventSlot = {};
        for i = 1, 5, 1 do
            if equips[i] then
                index = index + 1
                local p_item = equips[i];
                local equipConfig = Config.db_totems_equip[p_item.id];
                if equipConfig then
                    local prop = String2Table(equipConfig.base);
                    eventSlot[equipConfig.slot] = true;
                    for j = 1, #prop, 1 do
                        local tab = prop[j];
                        local k = tab[1];
                        local v = tab[2];
                        if not propTab[k] then
                            propTab[k] = 0;
                        end
                        propTab[k] = propTab[k] + v;
                    end
                    local strengthConfig = Config.db_totems_reinforce[i .. "@" .. p_item.extra];
                    if strengthConfig then
                        prop = String2Table(strengthConfig.base);
                        for j = 1, #prop, 1 do
                            local tab = prop[j];
                            local k = tab[1];
                            local v = tab[2];
                            if not propTab[k] then
                                propTab[k] = 0;
                            end
                            propTab[k] = propTab[k] + v;
                        end
                    end
                end

            end
        end

        for i = 1, 5, 1 do
            if eventSlot[i] then
                RemoveClickEvent(self.equips[i].gameObject);
            else
                AddClickEvent(self.equips[i].gameObject, handler(self, self.HandleEquipSort, i));
            end
        end

        if embedEquips.summon then
            self.summonText.text = "Recall"
            self.summon.interactable = true;
            ShaderManager:GetInstance():SetImageNormal(self.summonImg);
        else
            if index == 6 then
                self.summonText.text = "Assist"
                self.summon.interactable = true;
                ShaderManager:GetInstance():SetImageNormal(self.summonImg);
            else
                self.summonText.text = "Assist"
                self.summon.interactable = false;
                ShaderManager:GetInstance():SetImageGray(self.summonImg);
            end
        end
    else
        self:AddEquipSlotEvent();
        self.summonText.text ="Assist";
        self.summon.interactable = false;
        ShaderManager:GetInstance():SetImageGray(self.summonImg);
    end
    --62EA43
    local index = 1;
    local base = String2Table(data.attr);
    for k, v in pairs(base) do
        local key = v[1];
        local value = v[2];
        local suffix = "";
        propTab[key] = propTab[key] or 0;
        if propTab[key] ~= 0 then
            suffix = "<color=#62EA43>+" .. tonumber(propTab[key]) .. "</color>";--"+" .. tonumber(propTab[key])
        end

        --index = index + 1
        local item = self.labels[index]
        if not item then
            item = ToemsAttrItem(self.ToemsAttrItem.gameObject,self.attrParent,"UI")
            self.labels[index] = item

        else
            item:SetVisible(true)
        end
        item:SetData(key,value, suffix)

        for i = table.nums(base) + 1,#self.labels do
            local buyItem = self.labels[i]
            buyItem:SetVisible(false)
        end

        --self.labels[index].text = PROP_ENUM[key].label .. ":";
        --if v[1] >= 13 then
        --    self.values[index].text = math.ceil(tonumber(value) / 100) .. suffix .. "%";
        --else
        --    self.values[index].text = tostring(value) .. suffix;
        --end
        --
        --SetGameObjectActive(self.values[index].gameObject, true);

        index = index + 1;
    end
end

function ToemsPanel:AddEquipSlotEvent()
    for i = 1, #self.equips, 1 do
        RemoveClickEvent(self.equips[i].gameObject);
        AddClickEvent(self.equips[i].gameObject, handler(self, self.HandleEquipSort, i));
    end
end

function ToemsPanel:HandleEquipSort(go, x, y, i)
    local panel = lua_panelMgr:GetPanel(ToemsEquipPanel);
    if panel then
        panel:Close();
    end
    lua_panelMgr:GetPanelOrCreate(ToemsEquipPanel):Open(i);
end

function ToemsPanel:CalcScore(item)
    if item and item.data then
        local beastID = item.data.id;
        local score = item.data.score or 0;
        local beastData = self.model.EmbedEquips[beastID];
        if beastData then
            if beastData.summon then
                item:SetIsAssist(true);
                item:SetGray(false);
            else
                item:SetIsAssist(false);
                item:SetGray(true);
            end

            local propTab = {};
            if beastData.equips then
                local equips = beastData.equips;
                local index = 1;
                for i = 1, 5, 1 do
                    if equips[i] then
                        score = score + equips[i].score;
                        index = index + 1
                        local p_item = equips[i];
                        local equipConfig = Config.db_totems_equip[p_item.id];
                        local strengthConfig = Config.db_totems_reinforce[i .. "@" .. (equips[i].extra or 0)];
                        if strengthConfig then
                            local prop = String2Table(strengthConfig.base);
                            for j = 1, #prop, 1 do
                                local tab = prop[j];
                                local k = tab[1];
                                local v = tab[2];
                                if not propTab[k] then
                                    propTab[k] = 0;
                                end
                                propTab[k] = propTab[k] + v;
                            end
                        end
                    end
                end
                for k, v in pairs(propTab) do
                    local tab3 = Config.db_totems_equip_score[k];
                    if tab3 then
                        score = score + v * tonumber(tab3.ratio);
                    else
                        print2("k = " .. k);
                    end
                end
                if index > 5 then
                    self.defaultSelectedIndex = beastID;
                end
            end
            if beastData.summon then
                item:SetScoreText("Score: " .. math.ceil(score));
            else
                item:SetScoreText("<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.GrayWhite) .. ">" .. "Score: " .. score .. "</color>");
            end

        else
            item:SetIsAssist(false);
            item:SetScoreText("<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.GrayWhite) .. ">" .. "Score: " .. score .. "</color>");
            item:SetGray(true);
        end
    end
end