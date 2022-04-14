---
--- Created by  Administrator
--- DateTime: 2019/9/6 15:35
---
GodMainPanel = GodMainPanel or class("GodMainPanel", BaseItem)
local this = GodMainPanel

function GodMainPanel:ctor(parent_node, parent_panel)
    self.abName = "god"
    self.assetName = "GodMainPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.danItems = {};
    self.danAttrs = {}
    self.isFirst = true
    --  self.curBabyId = 0
    self.model = GodModel:GetInstance()
    GodMainPanel.super.Load(self)
end

function GodMainPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.danItems) do
        v:destroy()
    end
    self.danItems = {}
    for i, v in pairs(self.itemList) do
        v:destroy()
    end
    self.itemList = {}

    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = nil

    if self.one_red then
        self.one_red:destroy()
        self.one_red = nil
    end
end

function GodMainPanel:LoadCallBack()
    self.nodes = {
        "leftObj/nameBg/godName","leftObj/starObj/start_1","leftObj/starObj/start_2","leftObj/starObj/start_3","leftObj/starObj/start_4","leftObj/starObj/start_5",
        "leftObj/skillObj/skill1/skill1Name",
       -- "leftObj/skillObj/skill2/skill2Des",
        "leftObj/skillObj/skill2/Scroll View/Viewport/Content/skill2Des",
        "leftObj/skillObj/skill1/Scroll View/Viewport/Content/skill1Des",
        --"leftObj/skillObj/skill1/skill1Des",
        "leftObj/skillObj/skill2/skill2Img","leftObj/skillObj/skill2/skill2Name",
        "leftObj/skillObj/skill1/skill1Img","rightObj/levelObj/expSliderBG/levelTex","rightObj/levelObj/expSliderBG/expSlider","rightObj/levelObj/expSliderBG/expText",
        "leftObj/hunShiObj/dan_container","rightObj/levelObj/itemContainer","rightObj/levelObj/lvBtn","rightObj/levelObj/oneLvBtn","rightObj/levelObj/oneLvBtn/autoTex",
        "leftObj/modelCon","rightObj/attrObj/powerObj/power","leftObj/wenhao",
        "rightObj/attrObj/baseAttrObj/baseAttrtex1","rightObj/attrObj/baseAttrObj/baseAttrtex2",
        "rightObj/attrObj/baseAttrObj/baseAttrtex3","rightObj/attrObj/baseAttrObj/baseAttrtex4",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj1/baseAttrUp1","rightObj/attrObj/baseAttrObj/baseAttrtex5",
        "rightObj/attrObj/baseAttrObj/baseAttr1","rightObj/attrObj/baseAttrObj/baseAttrUpObj4/baseAttrUp4",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj5/baseAttrUp5","rightObj/attrObj/baseAttrObj/baseAttrUpObj2/baseAttrUp2",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj3/baseAttrUp3","rightObj/attrObj/baseAttrObj/baseAttr2",
        "rightObj/attrObj/baseAttrObj/baseAttr3",
        "rightObj/attrObj/baseAttrObj/baseAttr4","rightObj/attrObj/baseAttrObj/baseAttr5",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj2","rightObj/attrObj/baseAttrObj/baseAttrUpObj5","rightObj/attrObj/baseAttrObj/baseAttrUpObj3",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj4","rightObj/attrObj/baseAttrObj/baseAttrUpObj1",

    }
    self:GetChildren(self.nodes)
    self.godName = GetText(self.godName)
    self.start_1 = GetImage(self.start_1)
    self.start_2 = GetImage(self.start_2)
    self.start_3 = GetImage(self.start_3)
    self.start_4 = GetImage(self.start_4)
    self.start_5 = GetImage(self.start_5)
    self.skill1Name = GetText(self.skill1Name)
    self.skill1Des = GetText(self.skill1Des)
    self.skill1Img = GetImage(self.skill1Img)

    self.skill2Name = GetText(self.skill2Name)
    self.skill2Des = GetText(self.skill2Des)
    self.skill2Img = GetImage(self.skill2Img)

    self.levelTex = GetText(self.levelTex)
    self.expSlider = GetImage(self.expSlider)
    self.expText = GetText(self.expText)

    self.autoTex = GetText(self.autoTex)
    self.power = GetText(self.power)

    self.baseAttr1 = GetText(self.baseAttr1)
    self.baseAttr2 = GetText(self.baseAttr2)
    self.baseAttr3 = GetText(self.baseAttr3)
    self.baseAttr4 = GetText(self.baseAttr4)
    self.baseAttr5 = GetText(self.baseAttr5)
    self.baseAttrtex1 = GetText(self.baseAttrtex1)
    self.baseAttrtex2 = GetText(self.baseAttrtex2)
    self.baseAttrtex3 = GetText(self.baseAttrtex3)
    self.baseAttrtex4 = GetText(self.baseAttrtex4)
    self.baseAttrtex5 = GetText(self.baseAttrtex5)
    self.baseAttrUp1 = GetText(self.baseAttrUp1)
    self.baseAttrUp2 = GetText(self.baseAttrUp2)
    self.baseAttrUp3 = GetText(self.baseAttrUp3)
    self.baseAttrUp4 = GetText(self.baseAttrUp4)
    self.baseAttrUp5 = GetText(self.baseAttrUp5)
    self:InitUI()
    self:AddEvent()

    self.one_red = RedDot(self.oneLvBtn, nil, RedDot.RedDotType.Nor)
    self.one_red:SetPosition(53, 15)
    MountCtrl:GetInstance():RequestTrainInfo(enum.TRAIN.TRAIN_GOD)

end



function GodMainPanel:InitUI()
    self.currentEnum = GodModel.lvCost
    self:InitItemList()
end

function GodMainPanel:AddEvent()

    local function call_back()
        ShowHelpTip(HelpConfig.god.Help,true)
    end
    AddClickEvent(self.wenhao.gameObject,call_back)

    local function call_back()--升级
        MountCtrl:GetInstance():RequestTrainUpgrade(enum.TRAIN.TRAIN_GOD,self.currentItem)
    end
    AddClickEvent(self.lvBtn.gameObject,call_back)

    local function call_back()--自动升级
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Quick Cultivation"
            self.schedules = nil;
            return
        end

        if BagModel:GetInstance():GetItemNumByItemID(self.currentItem) >= 1 then
            self.schedules = GlobalSchedule:Start(handler(self,self.AutoLevel), 0.2, -1);
            self.autoTex.text = "Stop";
        else
            Notify.ShowText("Not enough upgrade materials")
        end
    end
    AddClickEvent(self.oneLvBtn.gameObject,call_back)
    local call_back = function(target, x, y)

        for i = 1, #self.itemList, 1 do
            if self.itemList[i].gameObject == target and self.itemList[i]:GetIsSelected() then
                self.itemList[i]:ShowTips();
                break ;
            end
        end

        for i = 1, #self.itemList, 1 do
            self.itemList[i]:SetIsSelected(false);
        end
        if target == self.itemList[1].gameObject then
            self.currentItem = self.currentEnum[1];
            self.itemList[1]:SetIsSelected(true);
        elseif target == self.itemList[2].gameObject then
            self.currentItem = self.currentEnum[2];
            self.itemList[2]:SetIsSelected(true);
        elseif target == self.itemList[3].gameObject then
            self.currentItem = self.currentEnum[3];
            self.itemList[3]:SetIsSelected(true);
        else
            self.currentItem = self.currentEnum[1];
            self.itemList[1]:SetIsSelected(true);
        end
    end

    for i = 1, #self.itemList, 1 do
        AddClickEvent(self.itemList[i].gameObject, call_back);
    end

    local updateNumCallBack = function()
      --  GlobalSchedule.StartFunOnce(handler(self, self.UpdateReddot), 0.1);
        if not self.itemList then
            return ;
        end
        local flag = false
        for k, v in pairs(self.itemList) do
            local awardItem = v;
            local num = BagModel:GetInstance():GetItemNumByItemID(v.db_id);
            awardItem:UpdateNum0(num);
            if num > 0 then
                flag = true;
            end
        end
       -- self:SetBtnState(flag);
    end
    AddEventListenerInTab(BagEvent.UpdateGoods, updateNumCallBack, self.events);

    local function call_back()
        local tipsPanel = lua_panelMgr:GetPanelOrCreate(TipsSkillPanel)
        tipsPanel:Open()
        tipsPanel:SetId(self.skillid1, self.skill1Img.transform)
    end
    AddClickEvent(self.skill1Img.gameObject,call_back)

    local function call_back()
        local tipsPanel = lua_panelMgr:GetPanelOrCreate(TipsSkillPanel)
        tipsPanel:Open()
        tipsPanel:SetId(self.skillid2, self.skill2Img.transform)
    end
    AddClickEvent(self.skill2Img.gameObject,call_back)

     self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MOUNT_INFO_TRAIN_DATA,handler(self,self.HandleGodInfo))
    self.events[#self.events + 1]  = GlobalEvent:AddListener(GodEvent.CheckRedPoint,handler(self,self.CheckRedPoint))
    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MORPH_ACTIVE_LIST,handler(self,self.HandleGodInfo))

end

function GodMainPanel:CheckRedPoint()
    self.one_red:SetRedDotParam(self.model.godRedPoints[2])
end

function GodMainPanel:HandleGodInfo(train)
   -- MountModel:GetInstance.visionData
    self.data = MountModel:GetInstance().visionData[enum.TRAIN.TRAIN_GOD]
    self.orderPdData =  MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD]
    self.morphData =  MountModel:GetInstance().pb_morph_data[enum.TRAIN.TRAIN_GOD]
    self:UpdateSlider()
    self:UpdateAttr()
    if  self.isFirst then
        self.isFirst = false
        self:SetModelInfo()
        self:UpdateItems()
        self:InitDan()
    end
    self:RefreshItemNum()
    self:RefreshDanNum()
end

function GodMainPanel:InitItemList()
    self.itemList = {};
    local item = AwardItem(self.itemContainer.transform);
    self.itemList[1] = item;

    item = AwardItem(self.itemContainer.transform);
    self.itemList[2] = item;

    item = AwardItem(self.itemContainer.transform);
    self.itemList[3] = item;
end


function GodMainPanel:UpdateItems()
    --itemTab = itemTab or self.WING_ENUM;
    local tab = GodModel.lvCost
    local item = self.itemList[1];
    item:SetData(tab[1], 0);
    local num = BagModel:GetInstance():GetItemNumByItemID(tab[1]);
    item:UpdateNum0(num);
    item:SetIsSelected(false);
    item = self.itemList[2];
    item:SetData(tab[2], 0);
    local num1 = BagModel:GetInstance():GetItemNumByItemID(tab[2]);
    item:UpdateNum0(num1);
    item:SetIsSelected(false);
    item = self.itemList[3];
    item:SetData(tab[3], 0);
    local num2 = BagModel:GetInstance():GetItemNumByItemID(tab[3]);
    item:UpdateNum0(num2);
    item:SetIsSelected(false);

    if num > 0 then
        self.itemList[1]:SetIsSelected(true);
        self.currentItem = tab[1]
    elseif num1 > 0 then
        self.itemList[2]:SetIsSelected(true);
        self.currentItem = tab[2]
    elseif num2 > 0 then
        self.itemList[3]:SetIsSelected(true);
        self.currentItem = tab[3]
    else
        self.currentItem = tab[1]
        self.itemList[1]:SetIsSelected(true);
    end
    --if num > 0 or num1 > 0 or num2 > 0 then
    --    self:SetBtnState(true);
    --else
    --    self:SetBtnState(false);
    --end
end
function GodMainPanel:RefreshItemNum()
    local tab = GodModel.lvCost
    local num = BagModel:GetInstance():GetItemNumByItemID(tab[1]);
    if self.itemList[1] then
        self.itemList[1]:UpdateNum0(num);
    end
    local num2 = BagModel:GetInstance():GetItemNumByItemID(tab[2]);
    if self.itemList[2] then
        self.itemList[2]:UpdateNum0(num2);
    end
    local num3 = BagModel:GetInstance():GetItemNumByItemID(tab[3]);
    if self.itemList[3] then
        self.itemList[3]:UpdateNum0(num3);
    end

    --if num > 0 or num2 > 0 or num3 > 0 then
    --    self.upgradeBtn_red:SetRedDotParam(true)
    --else
    --    self.upgradeBtn_red:SetRedDotParam(false)
    --end
end


function GodMainPanel:UpdateSlider()
    self.levelTex.text = "Lv"..self.data.level
    if self:IsMaxLv(self.data.level) then
        self.expSlider.fillAmount = 1
        self.expText.text = "max"
        return
    end
    local cfg = Config.db_god[self.data.level]
    self.expSlider.fillAmount = self.data.exp/cfg.exp
    self.expText.text = string.format("%s/%s",self.data.exp,cfg.exp)
end

function GodMainPanel:InitDan()
    destroyTab(self.danItems)
    local cfg = Config.db_god_train
    for i, v in table.pairsByKey(cfg) do
        local itemId = i;
        local awardItem = AwardItem(self.dan_container);
        awardItem:SetData(itemId, 0);
        local num = BagModel:GetInstance():GetItemNumByItemID(itemId);
        if num > 0 then
            awardItem:ShowCanUse(num);
        end
        local click_call = function(go, x, y)
            if awardItem.iscanusenum then
                MountCtrl:GetInstance():RequestTrainAttr(awardItem.db_id, enum.TRAIN.TRAIN_GOD);
            else
                awardItem:ShowTips();
            end
        end
        self.danItems[i] = awardItem;
        AddClickEvent(awardItem.gameObject, click_call);

        if self.data.train[itemId] then
            awardItem:SetNumText(self.data.train[itemId]);
        end
    end
end

function GodMainPanel:RefreshDanNum()
    for i, v in pairs(self.danItems) do
        local num = BagModel:GetInstance():GetItemNumByItemID(i);
        if num > 0 then
            v:ShowCanUse(num);
        else
            v:HideCanUse()
        end
        if self.data.train[i] then
            v:SetNumText(self.data.train[i]);
        end
    end
end



function GodMainPanel:SetModelInfo()
    local id = self.orderPdData.used_id
    local cfg = Config.db_god_morph[id]
    if cfg then
        self.godName.text = cfg.name
        self:InitModel(cfg.res,cfg.ratio)
    end
    local curMorphData =  MountModel:GetInstance():GetMorphDataByType(enum.TRAIN.TRAIN_GOD,id)
    if not curMorphData then
        MountCtrl:GetInstance():RequestMorphList(enum.TRAIN.TRAIN_GOD)
        return
    end
    local starKey = tostring(id).."@"..tostring(curMorphData.star)
    local starCfg = Config.db_god_star[starKey]
    local star = starCfg.star_client

    --if self.monster then
    --    self.monster:destroy()
    --end
    --local cfg = {}
    --cfg.pos = {x = -2000, y = -16, z = 193}
    --self.monster = UIModelCommonCamera(self.modelCon, nil, resName)
    --self.monster:SetConfig(cfg)

    self:SetStars(star)
    self:InitSkill()
end


function GodMainPanel:InitModel(resName,ratio)
    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -1997, y = -93, z = 550}
    cfg.scale = {x = ratio,y = ratio,z = ratio}
    cfg.trans_offset = {x=-126, y=180}
    self.monster = UIModelCommonCamera(self.modelCon, nil, "model_soul_"..resName)
    self.monster:SetConfig(cfg)
end



function GodMainPanel:SetStars(star)
    for i = 1, 5 do
        if star >= i then
            --self["start_"..i]
            lua_resMgr:SetImageTexture(self, self["start_"..i], "uicomponent_image", "lightstar", true, nil, false)
        else
            lua_resMgr:SetImageTexture(self, self["start_"..i], "uicomponent_image", "darkstar", true, nil, false)
        end
    end
end

function GodMainPanel:InitSkill()
    local  id = self.orderPdData.used_id
    local cfg
    --if id == GodModel.defaultID then  --初始id
    --    cfg = Config.db_god_star[tostring(id).."@".."0"]
    --else
        cfg = Config.db_god_star[tostring(id).."@".."9"]
    --end
    local skillTab = String2Table(cfg.skill_show)
    self.skillid1 = skillTab[1]
    self.skillid2 = skillTab[2]
    local skillCfg1  = Config.db_skill[skillTab[1]]
    local skillCfg2  = Config.db_skill[skillTab[2]]
    if not skillCfg1 or not skillCfg2 then
        logError("没有技能配置")
    end
    self.skill1Name.text = skillCfg1.name
    self.skill2Name.text = skillCfg2.name
    self.skill1Des.text = skillCfg1.desc
    self.skill2Des.text = skillCfg2.desc
    lua_resMgr:SetImageTexture(self, self.skill1Img, "iconasset/icon_skill",skillCfg1.icon,true)
    lua_resMgr:SetImageTexture(self, self.skill2Img, "iconasset/icon_skill",skillCfg2.icon,true)
end

function GodMainPanel:UpdateAttr()
    local cfg  = Config.db_god[self.data.level]
   -- local nextKey = tostring(self.curBabyCfg.id).."@"..tostring(self.curBabyCfg.order+1)
    local nextCfg = Config.db_god[self.data.level + 1]
    local baseTab =String2Table(cfg.attrs)

    local attriList = baseTab
    local addAttrNum = 0
   -- dump(self.data.train)
    self.danAttrs = {}
    if not table.isempty(self.data.train) then
        for id, v in pairs(self.data.train) do
            local traCfg = Config.db_god_train[id]
            if traCfg then
                local arrTab = String2Table(traCfg.attrs)
                local power2,tab2 = GetPowerByConfigList(arrTab,{})
                local power,tab = GetPowerByConfigList(attriList,tab2) - GetPowerByConfigList(attriList,{})
                local PP = power2 + power
                addAttrNum  = addAttrNum + PP * v
                for i, attrs in pairs(arrTab) do
                    local arrtId = attrs[1]
                    local attrValue = attrs[2]
                    if not self.danAttrs[arrtId] then
                        self.danAttrs[arrtId] = attrValue * v
                    else
                        self.danAttrs[arrtId] = self.danAttrs[arrtId] + attrValue * v
                    end
                    --for j = 1, #attrs do
                    --
                    --end
                end
            end
        end
    end
    dump(self.danAttrs)
    local power,tab = GetPowerByConfigList(attriList,{})
    self.power.text = power + addAttrNum



    for i = 1, 5 do
        if #baseTab >= i  then
            local attrId = baseTab[i][1]
            local attrNum = baseTab[i][2]
            SetVisible(self["baseAttrUpObj"..i],true)
            if nextCfg == nil then
                self["baseAttrUp"..i].text = "max"
            else
                local nextTab = String2Table(nextCfg.attrs)
                local nextNux = nextTab[i][2]
                self["baseAttrUp"..i].text = nextNux - attrNum
                SetVisible(self["baseAttrUpObj"..i],nextNux - attrNum ~= 0)
            end
            local attrName = enumName.ATTR[attrId]
            local curNum = attrNum
            if self.danAttrs[attrId] then
                attrNum = attrNum + self.danAttrs[attrId]
            end
            local pNum = 0
            if BASE_CAL_TAB[attrId] then
                for i, v in pairs(BASE_CAL_TAB[attrId]) do
                    if self.danAttrs[v] then
                        pNum =   curNum * (self.danAttrs[v] / 10000)
                        attrNum = attrNum + pNum
                    end
                end
            end

            self["baseAttrtex"..i].text = attrName
            self["baseAttr"..i].text = math.ceil(attrNum)

           -- self.danAttrs[attrId]

        else
            self["baseAttrUp"..i].text = ""
            self["baseAttrtex"..i].text = ""
            self["baseAttr"..i].text = ""
            SetVisible(self["baseAttrUpObj"..i],false)
        end
    end
    --local attriList = baseTab
    --local addAttrNum = 0
    --if not table.isempty(self.data.train) then
    --    for id, v in pairs(self.data.train) do
    --        local traCfg = Config.db_god_train[id]
    --        if traCfg then
    --            local power1,tab1 = GetPowerByConfigList(attriList,{})
    --            local arrTab = String2Table(traCfg.attrs)
    --            local power,tab = GetPowerByConfigList(arrTab,tab1)
    --            addAttrNum  = addAttrNum + power * v
    --        end
    --    end
    --end
    --local power,tab = GetPowerByConfigList(attriList,{})
    --self.power.text = power + addAttrNum

end



function GodMainPanel:IsMaxLv(lv)
    local cfg = Config.db_god[lv]
    local nextCfg = Config.db_god[lv + 1]
    if not nextCfg and self.data.exp >= cfg.exp then
        return true
    end
    return false
end

function GodMainPanel:AutoLevel()
    if self:IsMaxLv(self.data.level) then
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto upgrade"
            self.schedules = nil;
            return
        end
    end
    local num = BagModel:GetInstance():GetItemNumByItemID(self.currentItem) or 0
    if num >= 1 then
        MountCtrl:GetInstance():RequestTrainUpgrade(enum.TRAIN.TRAIN_GOD,self.currentItem)
    else
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto upgrade"
            self.schedules = nil;
            return
        end
    end
end
