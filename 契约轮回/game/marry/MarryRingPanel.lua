---
--- Created by  Administrator
--- DateTime: 2019/6/17 16:16
---
MarryRingPanel = MarryRingPanel or class("MarryRingPanel", BaseItem)
local this = MarryRingPanel

function MarryRingPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryRingPanel"
    self.layer = LayerManager.LayerNameList.UI
    self.events = {}
    self.model = MarryModel:GetInstance()
    self.schedules = {}
    MarryRingPanel.super.Load(self)

    self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarryRingPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.schedules[1] then
        GlobalSchedule:Stop(self.schedules[1]);
    end
    self.schedules = nil

    if self.itemicon then
        self.itemicon:destroy()
    end
    if self.red1 then
        self.red1:destroy()
        self.red1 = nil
    end
    if self.red2 then
        self.red2:destroy()
        self.red2 = nil
    end
end

function MarryRingPanel:LoadCallBack()
    self.nodes = {
        "autoBtn","autoBtn/autoTex","levelBtn","ringParent","attrObj/attr4",
        "baseAttrObj/baseAttr1","baseAttrObj/baseAttr4","wenhaoBtn",
        "baseAttrObj/baseAttr2","cailiaoParent","slider",
        "sliderTex","baseAttrObj/baseAttr3","attrObj/attr3","attrObj/attr1",
        "powerObj /power","attrObj/attr2","ringLevelbg/ringLevel",
        "flowerObj/flower1","flowerObj/flower2","flowerObj/flower3","flowerObj/flower4","flowerObj/flower5",
        "flowerObj/flower6","flowerObj/flower7","flowerObj/flower8","flowerObj/flower9","flowerObj/flower10",
        "baseAttrObj/baseAttrtex1", "baseAttrObj/baseAttrtex2", "baseAttrObj/baseAttrtex3", "baseAttrObj/baseAttrtex4", "baseAttrObj/baseAttrtex5",
        "baseAttrObj/baseAttrUpObj4","baseAttrObj/baseAttrUpObj1","baseAttrObj/baseAttrUpObj3","baseAttrObj/baseAttrUpObj2",
        "attrObj/attrtex3","attrObj/attrtex2","attrObj/attrtex4","attrObj/attrtex1","jiacheng",
        "heatSliderObj/heatSlider",
       -- "attrObj/attrtex3","attrObj/attrtex4","attrObj/attrtex1","attrObj/attrtex2",
        "baseAttrObj/baseAttrUpObj2/baseAttrUp2","baseAttrObj/baseAttrUpObj3/baseAttrUp3","baseAttrObj/baseAttrUpObj4/baseAttrUp4","baseAttrObj/baseAttrUpObj1/baseAttrUp1",



    }
    self:GetChildren(self.nodes)
    self.heatSlider = GetImage(self.heatSlider)
    self.power = GetText(self.power)
    self.sliderTex = GetText(self.sliderTex)
    self.attr1 = GetText(self.attr1)
    self.attr2 = GetText(self.attr2)
    self.attr3 = GetText(self.attr3)
    self.attr4 = GetText(self.attr4)
    self.attrtex1 = GetText(self.attrtex1)
    self.attrtex2 = GetText(self.attrtex2)
    self.attrtex3 = GetText(self.attrtex3)
    self.attrtex4 = GetText(self.attrtex4)
    self.baseAttr1 = GetText(self.baseAttr1)
    self.baseAttr2 = GetText(self.baseAttr2)
    self.baseAttr3 = GetText(self.baseAttr3)
    self.baseAttr4 = GetText(self.baseAttr4)
    self.baseAttrtex1 = GetText(self.baseAttrtex1)
    self.baseAttrtex2 = GetText(self.baseAttrtex2)
    self.baseAttrtex3 = GetText(self.baseAttrtex3)
    self.baseAttrtex4 = GetText(self.baseAttrtex4)

    self.baseAttrUp1 = GetText(self.baseAttrUp1)
    self.baseAttrUp2 = GetText(self.baseAttrUp2)
    self.baseAttrUp3 = GetText(self.baseAttrUp3)
    self.baseAttrUp4 = GetText(self.baseAttrUp4)


    self.slider = GetSlider(self.slider)
    self.ringLevel = GetText(self.ringLevel)
    self.autoTex = GetText(self.autoTex)
    self.jiachengImg = GetImage(self.jiacheng)
    self:InitUI()
    self:AddEvent()
    MarryController:GetInstance():RequsetRingInfo()

    self.red1 = RedDot(self.levelBtn, nil, RedDot.RedDotType.Nor)
    self.red1:SetPosition(70, 20)


    self.red2 = RedDot(self.autoBtn, nil, RedDot.RedDotType.Nor)
    self.red2:SetPosition(70, 20)
    self:MarryRedPoint()
end

function MarryRingPanel:InitUI()

end

function MarryRingPanel:AddEvent()

    local function call_back()

        --local itemID = self.model:GetUpRingMat()
        --local matNum = BagModel:GetInstance():GetItemNumByItemID(itemID);
        --print2(matNum)
        MarryController:GetInstance():RequsetRingUpgradeInfo()
    end
    AddClickEvent(self.levelBtn.gameObject,call_back)

    local function call_back() --自动升级
        if self.schedules[1] then
            GlobalSchedule:Stop(self.schedules[1]);
            self.autoTex.text = "Auto upgrade"
            self.schedules[1] = nil;
            return
        end
        local grade = self.data.ring.grade --阶数
        local level = self.data.ring.level --级数
        local cfg = self.model:GetRingCfg(grade,level)
        if  cfg.exp == 0 then
            Notify.ShowText("Max level reached")
            return
        end
        if BagModel:GetInstance():GetItemNumByItemID(self.model:GetUpRingMat()) ~= 0 then
            self.schedules[1] = GlobalSchedule:Start(handler(self,self.AutoLevel), 0.1, -1);
            self.autoTex.text = "Stop";
        else
            Notify.ShowText("Not enough upgrade materials")
        end


    end
    AddClickEvent(self.autoBtn.gameObject,call_back)

    local function call_back()
        ShowHelpTip(HelpConfig.MARRY.RING)
    end
    AddButtonEvent(self.wenhaoBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarryRedPoint,handler(self,self.MarryRedPoint))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.RingInfo,handler(self,self.RingInfo))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.RingUpgradeInfo,handler(self,self.RingUpgradeInfo))

end

function MarryRingPanel:MarryRedPoint()
    self.red1:SetRedDotParam(self.model.redPoints[2])
    self.red2:SetRedDotParam(self.model.redPoints[2])
end

function MarryRingPanel:AutoLevel()
    if BagModel:GetInstance():GetItemNumByItemID(self.model:GetUpRingMat()) ~= 0 and self.model:GetRingCfg(self.grade,self.level).exp ~= 0 then
        MarryController:GetInstance():RequsetRingUpgradeInfo()
    else
        --GlobalSchedule:Stop(self.schedules[1])
        --self.schedules = nil;
        --self.autoText.text = "自动升级";
        if self.schedules[1] then
            GlobalSchedule:Stop(self.schedules[1]);
            self.autoTex.text = "Auto upgrade"
            self.schedules[1] = nil;
            return
        end
    end
end

function MarryRingPanel:UpdateRingInfo(data)
    self.grade = data.ring.grade --阶数
    self.level = data.ring.level --级数
    local curExp = data.ring.exp
    local cfg = self.model:GetRingCfg(self.grade,self.level)
    local maxExp = cfg.exp
    if maxExp == 0 then
        self.sliderTex.text = "Max Lvl"
        self.slider.value = 1
    else
        self.sliderTex.text = curExp.."/"..maxExp
        self.slider.value = curExp/maxExp
    end
    local itemID = self.model:GetUpRingMat()
    local matNum = BagModel:GetInstance():GetItemNumByItemID(itemID);
    local param = {}
    param["item_id"] = itemID
    param["num"] = matNum or 0
    param["model"] = self.model
    param["can_click"] = true
    param["show_num"] = true
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.cailiaoParent)
    end
    self.itemicon:SetIcon(param)
    self.ringLevel.text = string.format("T%s Lv.%s Ring",self.grade,self.level)
    for i = 1, 10 do
        if i <= self.level then
            SetVisible(self["flower"..i],true)
        else
            SetVisible(self["flower"..i],false)
        end
    end
    self.heatSlider.fillAmount = (self.level-1)/10
    if self.heatSlider.fillAmount == 0.2 then
        self.heatSlider.fillAmount = 0.15
    elseif self.heatSlider.fillAmount == 0.3 then
        self.heatSlider.fillAmount = 0.25
    elseif self.heatSlider.fillAmount == 0.7 then
        self.heatSlider.fillAmount = 0.75
    elseif self.heatSlider.fillAmount == 0.8 then
        self.heatSlider.fillAmount = 0.85
    end
    self:UpdateAttr(cfg)
end

function MarryRingPanel:UpdateAttr(cfg)
    local  id = cfg.ring
    local equipCfg = Config.db_equip[id]

    local nextCfg = nil
    if cfg.exp ~= 0 then --最大级
        nextCfg = Config.db_equip[id + 1]
    end
    if not equipCfg then
        return
    end
    if self.role.marry == 0 then --没结婚
        lua_resMgr:SetImageTexture(self, self.jiachengImg, "marry_image", "marry_shixiao", true, nil, false)

    else
        lua_resMgr:SetImageTexture(self, self.jiachengImg, "marry_image", "marry_jiacheng", true, nil, false)
    end
    local baseTab =String2Table(equipCfg.base)
    local marryTab = String2Table(equipCfg.rare4)
    local nextTab
    local marryNextTab
    if nextCfg then
        nextTab = String2Table(nextCfg.base)
        marryNextTab = String2Table(nextCfg.rare4)
    end
    --dump(baseTab)
    --基础属性
    for i = 1, #baseTab do
        local attrId = baseTab[i][1]
        local attrNum = baseTab[i][2]
        if nextCfg == nil then
            self["baseAttrUp"..i].text = "max"
        else
            local nextNux = nextTab[i][2]
            self["baseAttrUp"..i].text = nextNux - attrNum
        end
        local attrName = enumName.ATTR[attrId]
        self["baseAttrtex"..i].text = attrName
        self["baseAttr"..i].text = attrNum
    end

    --结婚属性
    for i = 1, #marryTab do
        local attrId = marryTab[i][1]
        local attrNum = marryTab[i][2]
        local attrName = enumName.ATTR[attrId]
        self["attrtex"..i].text = attrName
        if nextCfg == nil then
            self["attr"..i].text = string.format("%s%s +<color=#00eb2c>%s</color>",attrNum/100,"%","max")
        else
            local nextNux = marryNextTab[i][2]
            self["attr"..i].text = string.format("%s%s +<color=#00eb2c>%s%s</color>",attrNum/100,"%",(nextNux - attrNum)/100,"%")
        end
    end

     local  ring = EquipModel:GetInstance():GetEquipBySlot(enum.ITEM_STYPE.ITEM_STYPE_LOCK)
    if ring then
        self.power.text = ring.equip.power
    end
end


function MarryRingPanel:RingInfo(data)
    self.data = data
    self:UpdateRingInfo(data)
   -- Config.db_marriage_ring
end
function MarryRingPanel:RingUpgradeInfo(data)
    print2("返回升级")
    self.data = data
    self:UpdateRingInfo(data)
end
