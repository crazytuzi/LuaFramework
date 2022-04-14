---
--- Created by  Administrator
--- DateTime: 2019/12/24 14:24
---
MachineArmorUpLvPanel = MachineArmorUpLvPanel or class("MachineArmorUpLvPanel", BaseItem)
local this = MachineArmorUpLvPanel

function MachineArmorUpLvPanel:ctor(parent_node, parent_panel)
    self.abName = "machinearmor"
    self.assetName = "MachineArmorUpLvPanel"
    self.layer = "UI"

    self.model = MachineArmorModel:GetInstance()
    self.attrs = {}
    self.events = {}
    self.modelEvents = {}
    self.itemList ={}
    MachineArmorUpLvPanel.super.Load(self)
end

function MachineArmorUpLvPanel:dctor()
    self.model:RemoveTabListener(self.modelEvents)
    GlobalEvent:RemoveTabListener(self.events)
    if not table.isempty(self.attrs) then
        for i, v in pairs(self.attrs) do
            v:destroy()
        end
        self.attrs = {}
    end
    if not table.isempty(self.itemList) then
        for i, v in pairs(self.itemList) do
            v:destroy()
        end
        self.itemList = {}
    end

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
        self.schedules = nil;
    end

    if self.red then
        self.red:destroy()
        self.red = nil
    end
    if self.red2 then
        self.red2:destroy()
        self.red2 = nil
    end
end

function MachineArmorUpLvPanel:LoadCallBack()
    self.nodes = {
        "attrObj/oneBtn","attrObj/attrParent","attrObj/oneBtn/oneBtnTex","attrObj",
        "attrObj/iconParent","attrObj/lvBtn","attrObj/PowerObj/equipPower","MachineArmorAttrItem",
        "attrObj/expSliderBG/expText","attrObj/expSliderBG/expSlider","attrObj/LvTex","goBtn",
    }
    self:GetChildren(self.nodes)
    self.autoTex = GetText(self.oneBtnTex)
    self.equipPower = GetText(self.equipPower)
    self.expText = GetText(self.expText)
    self.expSlider = GetImage(self.expSlider)
    self.LvTex = GetText(self.LvTex)
    SetAlignType(self.attrObj.transform, bit.bor(AlignType.Right, AlignType.Null))
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.info)
    end

end

function MachineArmorUpLvPanel:InitUI()
    self.currentEnum = MachineArmorModel.lvCost
    self:InitItemList()
end

function MachineArmorUpLvPanel:AddEvent()
    local function call_back() --升级
        if BagModel:GetInstance():GetItemNumByItemID(self.currentItem) <= 0 then
            Notify.ShowText("Not enough upgrade materials")
            return
        end
        MachineArmorController:GetInstance():RequstUpGradeInfo(self.info.id,self.currentItem)
    end
    AddClickEvent(self.lvBtn.gameObject,call_back)


    local function call_back()--自动升级
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Quick improvement"
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
    AddClickEvent(self.oneBtn.gameObject,call_back)

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




    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaUpGradeInfo,handler(self,self.MechaUpGradeInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(MachineArmorEvent.CheckRedPoint,handler(self,self.CheckRedPoint))
    
end

function MachineArmorUpLvPanel:SetData(data)
    self.info = data
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:UpdateLvUpInfo()
    self:CheckRedPoint()
end

function MachineArmorUpLvPanel:CheckRedPoint()
    if not self.red then
        self.red = RedDot(self.lvBtn.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(58, 18)
    end
    if not self.red2 then
        self.red2 = RedDot(self.oneBtn.transform, nil, RedDot.RedDotType.Nor)
        self.red2:SetPosition(58, 18)
    end
    self.red:SetRedDotParam(self.model.lvRedPoints[self.info.id])
    self.red2:SetRedDotParam(self.model.lvRedPoints[self.info.id])

end

function MachineArmorUpLvPanel:MechaUpGradeInfo(data)
    if data.mecha.id == self.info.id then
        self:UpdateLvUpInfo()
    end
end

function MachineArmorUpLvPanel:InitItemList()
    local item = AwardItem(self.iconParent.transform);
    self.itemList[1] = item;

    item = AwardItem(self.iconParent.transform);
    self.itemList[2] = item;

    item = AwardItem(self.iconParent.transform);
    self.itemList[3] = item;
    self:UpdateItems()
end

function MachineArmorUpLvPanel:UpdateItems()
    --itemTab = itemTab or self.WING_ENUM;
    local tab = MachineArmorModel.lvCost
    local item = self.itemList[1] or AwardItem(self.iconParent.transform)
    item:SetData(tab[1], 0);
    local num = BagModel:GetInstance():GetItemNumByItemID(tab[1]);
    item:UpdateNum0(num);
    item:SetIsSelected(false);
    item = self.itemList[2] or AwardItem(self.iconParent.transform)
    item:SetData(tab[2], 0);
    local num1 = BagModel:GetInstance():GetItemNumByItemID(tab[2]);
    item:UpdateNum0(num1);
    item:SetIsSelected(false);
    item = self.itemList[3] or AwardItem(self.iconParent.transform)
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
end

function MachineArmorUpLvPanel:RefreshItemNum()
    local tab = MachineArmorModel.lvCost
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
end

function MachineArmorUpLvPanel:UpdateLvUpInfo()
    self.serInfo = self.model:GetMecha(self.info.id)
    self:RefreshItemNum()
    self:UpdateAttr()
    self:UpdateSlider()
end

function MachineArmorUpLvPanel:UpdateAttr()
    local level = self.serInfo.level
    if level <= 0  then
        level = 1
    end
    local key = self.serInfo.id.."@"..self.serInfo.level
    local nextKey = self.serInfo.id.."@"..self.serInfo.level+1
    local cfg  = Config.db_mecha_upgrade[key]
    -- local nextKey = tostring(self.curBabyCfg.id).."@"..tostring(self.curBabyCfg.order+1)
    local nextCfg = Config.db_mecha_upgrade[nextKey]
    local baseTab =String2Table(cfg.attrs)
    local nextTab = {}
    if nextCfg then
        nextTab = String2Table(nextCfg.attrs)
    end
    for i = 1, #baseTab do
        local buyItem =  self.attrs[i]
        if  not buyItem then
            buyItem = MachineArmorAttrItem(self.MachineArmorAttrItem.gameObject,self.attrParent,"UI")
            self.attrs[i] = buyItem
        else
            buyItem:SetVisible(true)
        end
        buyItem:SetData(baseTab[i],nextTab[i] or {},nextCfg == nil)
    end
    for i = #baseTab + 1,#self.attrs do
        local buyItem = self.attrs[i]
        buyItem:SetVisible(false)
    end
    local attriList = baseTab
    local power2,tab2 = GetPowerByConfigList(attriList,{})
    local power,tab = GetPowerByConfigList(attriList,tab2)
    -- logError(power,self.fPower,power + self.fPower)
    self.equipPower.text = power
end

function MachineArmorUpLvPanel:UpdateSlider()
    self.LvTex.text = "LV."..self.serInfo.level
    if self:IsMaxLv(self.serInfo.level) then
        self.expSlider.fillAmount = 1
        self.expText.text = "max"
        return
    end
    local key = self.serInfo.id.."@"..self.serInfo.level
    local cfg = Config.db_mecha_upgrade[key]
    self.expSlider.fillAmount = self.serInfo.exp/cfg.exp
    self.expText.text = string.format("%s/%s",self.serInfo.exp,cfg.exp)
end

function MachineArmorUpLvPanel:AutoLevel()
    if self:IsMaxLv(self.serInfo.level) then
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto upgrade"
            self.schedules = nil;
            return
        end
    end
    local num = BagModel:GetInstance():GetItemNumByItemID(self.currentItem) or 0
    if num >= 1 then
        MachineArmorController:GetInstance():RequstUpGradeInfo(self.info.id,self.currentItem)
    else
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto improvement"
            self.schedules = nil;
            return
        end
    end
end

function MachineArmorUpLvPanel:IsMaxLv(lv)
    local key = self.serInfo.id.."@"..self.serInfo.level
    local nextKey = self.serInfo.id.."@"..self.serInfo.level+1
    local cfg = Config.db_mecha_upgrade[key]
    local nextCfg = Config.db_mecha_upgrade[nextKey]
    if not nextCfg and self.serInfo.exp >= cfg.exp then
        return true
    end
    return false
end