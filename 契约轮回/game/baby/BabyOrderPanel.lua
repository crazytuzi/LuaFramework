---
--- Created by  Administrator
--- DateTime: 2019/8/30 10:11
---
BabyOrderPanel = BabyOrderPanel or class("BabyOrderPanel", BaseItem)
local this = BabyOrderPanel

function BabyOrderPanel:ctor(parent_node, parent_panel,index)
    self.abName = "baby"
    self.assetName = "BabyOrderPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.gEvents = {}
    self.skills = {}
    self.textList = {}
    self.typeIndex = 1
    self.index = 1
    self.isFirst = true
    self.isOrderBaby = false
    self.orderCost = {}
    self.defIndex = index
  --  self.curBabyId = 0
    self.model = BabyModel:GetInstance()
    BabyCulturePanel.super.Load(self)
end

function BabyOrderPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gEvents)
    if self.left_menu then
        self.left_menu:destroy()
    end
    self.left_menu = nil

    if self.itemicon then
        self.itemicon:destroy()
    end
    self.itemicon = nil
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil
    for i, v in pairs(self.orderCost) do
        v:destroy()
    end
    self.orderCost = {}

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
        self.schedules = nil;
    end
    for i, v in pairs(self.skills) do
        v:destroy()
    end
    self.skills = {}

    self.textList = nil
    if self.piaoZiSchedule then
        GlobalSchedule:Stop(self.piaoZiSchedule);
    end

    if self.one_red then
        self.one_red:destroy()
        self.one_red = nil
    end

    if self.jihuo_red then
        self.jihuo_red:destroy()
        self.jihuo_red = nil
    end
    if self.type1_red then
        self.type1_red:destroy()
        self.type1_red = nil
    end
    if self.type2_red then
        self.type2_red:destroy()
        self.type2_red = nil
    end

end

function BabyOrderPanel:LoadCallBack()
    self.nodes = {
        "leftObj/LeftMenu","leftObj/togbtns/tog_text_1","leftObj/togbtns/tog_text_2","leftObj/togbtns/tog_btn","midleObj/title/babyName",
        "midleObj/modelCon","rightObj/jiHuoObj/jihuoDes","rightObj/jiHuoObj/jihuoIconParent","rightObj/jiHuoObj/jiHuoBtn","midleObj/huanhIcon",
        "rightObj/orderObj","rightObj/jiHuoObj","rightObj/orderObj/iconParent","rightObj/orderObj/oneBtn","rightObj/orderObj/oneBtn/autoTex",
        "rightObj/orderObj/expSliderBG/expSlider","rightObj/orderObj/expSliderBG/expText","rightObj/orderObj/max_img","rightObj/attrObj/powerObj/power",
        "midleObj/skillObj/desbg","midleObj/skillObj/desbg/des","midleObj/skillObj/skillParent","rightObj/attrObj/title2/title2Tex",
        "rightObj/orderObj/expSliderBG","rightObj/orderObj/expCon","rightObj/orderObj/expCon/TextObj","leftObj/togbtns",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj4",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj2",
        "rightObj/attrObj/baseAttrObj/baseAttr4",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj3",
        "rightObj/attrObj/baseAttrObj/baseAttr3",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj1",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj4/baseAttrUp4",
        "rightObj/attrObj/baseAttrObj/baseAttrtex3","rightObj/attrObj/baseAttrObj/baseAttr2",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj2/baseAttrUp2","rightObj/attrObj/baseAttrObj/baseAttrtex4",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj1/baseAttrUp1",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj3/baseAttrUp3","rightObj/attrObj/baseAttrObj/baseAttr1",
        "rightObj/attrObj/baseAttrObj/baseAttrtex2",
        "rightObj/attrObj/baseAttrObj/baseAttrtex1",
    }
    self:GetChildren(self.nodes)
    self.babyName = GetText(self.babyName)
    self.jihuoDes = GetText(self.jihuoDes)
    self.jiHuoBtnImg = GetImage(self.jiHuoBtn)
    self.autoTex = GetText(self.autoTex)
    self.expSlider = GetImage(self.expSlider)
    self.expText = GetText(self.expText)
    self.power = GetText(self.power)
    self.des = GetText(self.des)
    self.title2Tex = GetText(self.title2Tex)
    self.tog_text_1 = GetText(self.tog_text_1);
    self.tog_text_2 = GetText(self.tog_text_2);
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


    SetVisible(self.max_img,false)
    SetVisible(self.oneBtn,false)
    self:InitUI()
    self:AddEvent()
    BabyController:GetInstance():RequstOrderInfo()

    self.jihuo_red = RedDot(self.jiHuoBtn, nil, RedDot.RedDotType.Nor)
    self.jihuo_red:SetPosition(53, 15)

    self.one_red = RedDot(self.oneBtn, nil, RedDot.RedDotType.Nor)
    self.one_red:SetPosition(53, 15)

    self.type1_red = RedDot(self.togbtns, nil, RedDot.RedDotType.Nor)
    self.type1_red:SetPosition(3, 14)

    self.type2_red = RedDot(self.togbtns, nil, RedDot.RedDotType.Nor)
    self.type2_red:SetPosition(108, 14)
end

function BabyOrderPanel:InitUI()

end

function BabyOrderPanel:AddEvent()
    local function call_back()--激活
        if  self.isOrderBaby  then --使用物品
            local gender = self.curBabyCfg.gender
            local babyCfg = Config.db_baby[gender]
            if self.curBabyCfg.id == babyCfg.id   then
                local itemId = babyCfg.item
                local uid = BagModel:GetInstance():GetUidByItemID(itemId)
                if uid then
                    GoodsController:GetInstance():RequestUseGoods(uid, 1)
                else
                    Notify.ShowText("Lack of materials")
                end
            end
            return
        end
        BabyController:GetInstance():RequstActive(self.curBabyCfg.id)
    end
    AddClickEvent(self.jiHuoBtn.gameObject,call_back)
    
    
    local function call_back() --一键培养
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Quick Cultivation"
            self.schedules = nil;
            return
        end
        local id = self.curBabyCfg
        local itemTab = String2Table(self.curBabyCfg.cost)
        self.itemId1 = itemTab[1]
        self.itemId2 = itemTab[2]
        if BagModel:GetInstance():GetItemNumByItemID(self.itemId1) >= 1 or  BagModel:GetInstance():GetItemNumByItemID(self.itemId2) >= 1 then
            self.schedules = GlobalSchedule:Start(handler(self,self.AutoLevel), 0.2, -1);
            self.autoTex.text = "Stop";
        else
            Notify.ShowText("Not enough upgrade materials")
        end

    end

    AddClickEvent(self.oneBtn.gameObject,call_back)
    
    local function call_back() --幻化
        BabyController:GetInstance():RequstFigure(self.curBabyCfg.id)
    end
    AddButtonEvent(self.huanhIcon.gameObject,call_back)


    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyOrderInfo,handler(self,self.BabyOrderInfo))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyUpOrder,handler(self,self.BabyUpOrder))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyFigure,handler(self,self.BabyFigure))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.UpdateRedPoint,handler(self,self.UpdateRedPoint))

    AddClickEvent(self.tog_text_1.gameObject, handler(self, self.HandleTogBtnClick, 1));
    AddClickEvent(self.tog_text_2.gameObject, handler(self, self.HandleTogBtnClick, 2));

    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick), self.gEvents);
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick), self.gEvents);
end

function BabyOrderPanel:UpdateRedPoint()
   local id =  self.curBabyCfg.id
    self.jihuo_red:SetRedDotParam(self.model.babyOrderRedPoints[id][1])
    self.one_red:SetRedDotParam(self.model.babyOrderRedPoints[id][2])
    self.left_menu:UpdateRedPoint()
    local isRed = {}
    for babyId, reds in pairs(self.model.babyOrderRedPoints) do
        local key = tostring(babyId).."@".."0"
        local cfg = Config.db_baby_order[key]
        if not isRed[cfg.type_id] then
            isRed[cfg.type_id] = false
        end
        for i, v in pairs(reds) do
            if v == true then
                isRed[cfg.type_id] = true
            end
        end
    end
    self.type1_red:SetRedDotParam(isRed[1])
    self.type2_red:SetRedDotParam(isRed[2])

end


BabyOrderPanel.TogImgPos = {
    [1] = -41,
    [2] = 60,
}

function BabyOrderPanel:HandleLeftSecItemClick(menuId, subId)
    self:StopShedule()
    self:UpdateBabyInfo(subId)
    self:UpdateRedPoint()
end

function BabyOrderPanel:HandleLeftFirstClick(index,isHide)
    self:StopShedule()
    --dump(self.sub_menu)
    if not isHide then  --显示
        self:UpdateBabyInfo(self.sub_menu[index][self.index][1])
        self:UpdateRedPoint()
    end

end

function BabyOrderPanel:UpdateBabyInfo(babyId)
    --local babyCfg = Config.db_baby_order
    local info = self.model:GetOrderInfo(babyId)
    local cfg
    if not info then --
        local key = tostring(babyId).."@".."0"
         cfg = Config.db_baby_order[key]
      --  SetVisible(self.desbg,true)
        SetVisible(self.huanhIcon,false)
        --  return cfg.name
    else
        local key = tostring(info.id).."@"..tostring(info.order)
         cfg = Config.db_baby_order[key]

      --  SetVisible(self.desbg,false)
        SetVisible(self.huanhIcon,self.model:GetShowBaby() ~= cfg.id)
    end
    self.curBabyCfg = cfg
    self.curInfo = info
    self.babyName.text ="T"..cfg.order..cfg.name

    self:InitModel(cfg.res_id)
    self:InitRightInfo(cfg,info)
end

function BabyOrderPanel:InitRightInfo(cfg,info)
    if self.itemicon then
        self.itemicon:destroy()
    end
    self.itemicon = nil
    if cfg.type_id == 2 then --活动
        self.isOrderBaby = false
        if not info then
           local actTab = String2Table(self.curBabyCfg.active)
            if table.isempty(actTab) then
                logError("没有配激活消耗"..self.curBabyCfg.id)
                return
            end
            local itemId = actTab[1][1]
            local num = actTab[1][2]
            self:CreateJhItem(itemId,num)
            SetVisible(self.orderObj,false)
            SetVisible(self.jiHuoObj,true)
            self.jihuoDes.text = ""
            self:UpdateAttr()
            self:UpdateSkills()
            self.title2Tex.text = "Activate Baby"
        else
            self.jihuoDes.text = ""
            self.title2Tex.text = "Advanced Blessing"
            self:UpdateCulInfo()
        end
        SetVisible(self.desbg,false)
    else --进阶
        self.isOrderBaby = true
        if not info then --没有进阶信息
            local gender = cfg.gender
            local babyCfg = Config.db_baby[gender]
            local minId = babyCfg.id
            if cfg.id == minId and cfg.order == 0 then  --出生的宝宝
                local itemId = babyCfg.item
                self:CreateJhItem(itemId)
                SetLocalPosition(self.jihuoDes.transform,27,26)
                self.jihuoDes.text = string.format("%s can be activated when progress bar is filled\nor:",cfg.name)
                self.des.text = string.format("Activate when %s's growth bar is full",cfg.name)
                ShaderManager:GetInstance():SetImageNormal(self.jiHuoBtnImg)
            else
               -- SetLocalPositionY(self.jihuoDes.transform,-11)
                SetLocalPosition(self.jihuoDes.transform,0,26)
                local lastId = cfg.front_id
                local key = tostring(lastId).."@".."0"
                local lastCfg = Config.db_baby_order[key]
                local des = string.format("Activate when training %s to T10",lastCfg.name)
                self.jihuoDes.text = des
                self.des.text = des
                ShaderManager:GetInstance():SetImageGray(self.jiHuoBtnImg)
            end
            SetVisible(self.desbg,true)
            SetVisible(self.orderObj,false)
            SetVisible(self.jiHuoObj,true)
            self:UpdateAttr()
            self:UpdateSkills()
            self.title2Tex.text = "Activate Baby"
        else --有进阶信息
            self.jihuoDes.text = ""
            self:UpdateCulInfo(cfg,info)
            SetVisible(self.desbg,false)
            self.title2Tex.text = "Advanced Blessing"
        end

    end
end

function BabyOrderPanel:SetMax(max)
    if max then
        --for i, v in pairs(self.orderCost) do
        --    v:destroy()
        --end
        --self.orderCost = {}
        SetVisible(self.max_img,true)
        SetVisible(self.oneBtn,false)
    else
        SetVisible(self.max_img,false)
        SetVisible(self.oneBtn,true)
    end
end
--更新培养信息
function BabyOrderPanel:UpdateCulInfo()
    local info = self.model:GetOrderInfo(self.curBabyCfg.id)
    local cfg
    if not info then --
        local key = tostring(self.curBabyCfg.id).."@".."0"
        cfg = Config.db_baby_order[key]
        --  return cfg.name
    else
        local key = tostring(info.id).."@"..tostring(info.order)
        cfg = Config.db_baby_order[key]
    end
    self.curBabyCfg = cfg
    self.curInfo = info
    SetVisible(self.orderObj,true)
    SetVisible(self.jiHuoObj,false)
    if self:IsMax() then
        self:SetMax(true)
        self.expText.text = "max"
        self.expSlider.fillAmount = 1
    else
        --local rewardTab = String2Table(cfg.cost)
        --for i = 1, #rewardTab do
        --    local item = self.orderCost[i]
        --    if not item  then
        --        item = BabyGoodsItem(self.iconParent)
        --        self.orderCost[i] = item
        --    end
        --    item:SetData(rewardTab[i],1,1)
        --end
        self:SetMax(false)
        --进度
        local maxExp = cfg.exp
        --if self.isFirst == false then
        --    local exp = Config.db_item[self.showItemId]
        --    self:ShowAddExp("+"..exp.effect);
        --end
       -- self.showItemId
        self.expText.text = string.format("%s/%s",info.exp,maxExp)
        self.expSlider.fillAmount = info.exp/maxExp
    end
    local rewardTab = String2Table(cfg.cost)
    for i = 1, #rewardTab do
        local item = self.orderCost[i]
        if not item  then
            item = BabyGoodsItem(self.iconParent)
            self.orderCost[i] = item
        end
        item:SetData(rewardTab[i],1,1)
    end
    self:UpdateAttr()
    self:UpdateSkills()
    --dump(self.model:GetBabySkills(self.curBabyCfg.id))
    SetVisible(self.huanhIcon,self.model:GetShowBaby() ~= self.curBabyCfg.id)
    self.babyName.text ="Tier"..cfg.order..cfg.name
    self.model:Brocast(BabyEvent.UpdateOrderInfo,self.curBabyCfg.id)
end

function BabyOrderPanel:UpdateSkills()
    local tab = self.model:GetBabySkills(self.curBabyCfg.id)
    for i = 1, #tab do
        local item = self.skills[i]
        if not item then
            item = BabySkillItem(self.skillParent)
            self.skills[i] = item
        end
        item:SetData(tab[i],self.curBabyCfg)

    end
end

function BabyOrderPanel:InitModel(resName)
    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -2000, y = -60, z = 193}
    cfg.scale = {x=200, y=200, z=200}
    cfg.trans_offset = {y=60}
    self.monster = UIModelCommonCamera(self.modelCon, nil, resName)
    self.monster:SetConfig(cfg)
end



function BabyOrderPanel:HandleTogBtnClick(go, x, y, index)
    local posX
    self:StopShedule()
    if 1 == index then
        posX = -41
        SetColor(self.tog_text_1, 0x99, 0x48, 0x29, 255);
        SetColor(self.tog_text_2, 0xEB, 0xD3, 0x9A, 255);
        self:InitOrderBaby()
    else
        posX = 60
        SetColor(self.tog_text_1, 0xEB, 0xD3, 0x9A, 255);--EBD39A
        SetColor(self.tog_text_2, 0x99, 0x48, 0x29, 255);
        if table.isempty(self.model.allActBaby) then
            Notify.ShowText("Event pets are unavailable")
            return
        end
        self:InitActBaby()
    end
    self.typeIndex = index
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.tog_btn.transform)
    local value_action = cc.MoveTo(0.1, posX, -1, 0)
    cc.ActionManager:GetInstance():addAction(value_action, self.tog_btn.transform)
    --self.currentSelectedMountID = 1;
   -- MountInfoPanel.navTab = index;
    --初始化
   -- self:InitTog();
end

function BabyOrderPanel:InitOrderBaby()
    self:InitMenuList(self.model.allBaby,1)
end

function BabyOrderPanel:InitActBaby()
    self:InitMenuList(self.model.allActBaby,2)
end


function BabyOrderPanel:InitMenuList(list,type)
    self.model.curType = type
    if self.left_menu then
        self.left_menu:destroy()
    end
    self.left_menu = nil
    self.left_menu = BabyFoldMenu(self.LeftMenu, nil, self, BabyMenuItem, BabyMenuSubItem)
    self.left_menu:SetStickXAxis(8.5)
    --self.model.allBaby
    self.menu = {}
    self.sub_menu = {}
    local allBaby = list
    for i = 1, 2 do
        local baby = allBaby[i]
        local list = {}
        for k, v in table.pairsByKey(baby) do
            local tab1 = {k,self.model:GetBabyName(k)}
            table.insert(list,tab1)
        end
       -- BabyModel.foldName
        self.sub_menu[i] = list
        local tab = {i,BabyModel.foldName[i]}
        table.insert(self.menu,tab)
    end
    self.left_menu:SetData(self.menu,self.sub_menu,1,2,2)

    if self.defIndex then
        self.left_menu:SetDefaultSelected(self.defIndex, 1)
    else
        local  gender,id = self.model:GetSelectId(type)
        if gender == 0 and id == 0 then
            self.index = 1
            self.left_menu:SetDefaultSelected(1, 1)
        else
            self.index = 1
            for i = 1, #self.sub_menu[gender] do
                if self.sub_menu[gender][i][1] == id then
                    self.index = i
                    break
                end
            end
            self.left_menu:SetDefaultSelected(gender, self.index)
        end

    end


    
    --self.left_menu:SetDefaultSelected(1, 1)  --先写死默认
end


function BabyOrderPanel:BabyOrderInfo(data)
   -- dump(self.model.orderBabies)

    if self.isFirst then
        self:HandleTogBtnClick(nil,1,1,1)
        self.isFirst = false
    else
        self:UpdateCulInfo(self.curBabyCfg,self.model:GetOrderInfo(self.curBabyCfg.id))
    end
    -- self:InitMenuList()
end




function BabyOrderPanel:AutoLevel()
    if self:IsMax() then
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto upgrade"
            self.schedules = nil;
            return
        end
    end
    local num1 = BagModel:GetInstance():GetItemNumByItemID(self.itemId1) or 0
    local num2 = BagModel:GetInstance():GetItemNumByItemID(self.itemId2) or 0
    if num1 > 0  then
        self.showItemId = self.itemId1
        BabyController:GetInstance():RequstUpOrder(self.curBabyCfg.id,self.itemId1)
    elseif num2 > 0 then
        self.showItemId = self.itemId2
        BabyController:GetInstance():RequstUpOrder(self.curBabyCfg.id,self.itemId2)
    else
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto upgrade"
            self.schedules = nil;
            return
        end
    end
end

function BabyOrderPanel:BabyUpOrder()
    local exp = Config.db_item[self.showItemId]
    self:ShowAddExp("+"..exp.effect);
end

--幻化信息
function BabyOrderPanel:BabyFigure()

end

function BabyOrderPanel:CreateJhItem(id,itemNum)
    local num = BagModel:GetInstance():GetItemNumByItemID(id);
    local param = {}
    param["item_id"] = id
    local color = "00FF1A"
    if num < (itemNum or 1) then
        color = "FF1200"
    end
    param["num"] = string.format("<color=#%s>%s/%s</color>",color,num,itemNum or 1)
    param["model"] = BagModel
    param["can_click"] = true
    param["show_num"] = true
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.jihuoIconParent)
    end
    self.itemicon:SetIcon(param)
    if num < (itemNum or 1) then
        self.itemicon:SetIconGray()
    else
        self.itemicon:SetIconNormal()
    end


end


function BabyOrderPanel:UpdateAttr()
    local cfg = self.curBabyCfg
    local nextKey = tostring(self.curBabyCfg.id).."@"..tostring(self.curBabyCfg.order+1)
    local nextCfg = Config.db_baby_order[nextKey]
    local baseTab =String2Table(cfg.attr)
    for i = 1, 4 do
        if #baseTab >= i  then
            local attrId = baseTab[i][1]
            local attrNum = baseTab[i][2]
            if nextCfg == nil then
                self["baseAttrUp"..i].text = "max"
            else
                local nextTab = String2Table(nextCfg.attr)
                local nextNux = nextTab[i][2]
                self["baseAttrUp"..i].text = nextNux - attrNum
            end
            local attrName = enumName.ATTR[attrId]
            self["baseAttrtex"..i].text = attrName
            self["baseAttr"..i].text = attrNum
            SetVisible(self["baseAttrUpObj"..i],true)
        else
            self["baseAttrUp"..i].text = ""
            self["baseAttrtex"..i].text = ""
            self["baseAttr"..i].text = ""
            SetVisible(self["baseAttrUpObj"..i],false)
        end
    end
    local attriList = baseTab
    self.power.text = GetPowerByConfigList(attriList)

end


function BabyOrderPanel:IsMax()
    local key = tostring(self.curBabyCfg.id).."@"..tostring(self.curBabyCfg.order+1)
    local cfg = Config.db_baby_order[key]
    if (self.curBabyCfg.next_id > 0 and self.curInfo.exp >= self.curBabyCfg.exp) or (not cfg and self.curBabyCfg.next_id <= 0 ) then
        return true
    end
    return false

end

function BabyOrderPanel:ShowAddExp(text1)
    local textObj = self:CreateText();
    textObj.transform:SetParent(self.expCon.transform);
    textObj.gameObject:SetActive(true);
    SetLocalPosition(textObj.transform, 0, 0, 0);
    SetLocalScale(textObj.transform, 1, 1, 1);
    SetLocalRotation(textObj.transform, 0, 0, 0);
    textObj.text = tostring(text1);
    self.textList[#self.textList + 1] = textObj;

    if not self.piaoZiSchedule then
        self.piaoZiSchedule = GlobalSchedule:Start(handler(self, self.UpdateTextList), 0.033, -1);
    end
    
end

function BabyOrderPanel:UpdateTextList()
    local removeIndex = 0;
    for i = 1, #self.textList, 1 do
        local text = self.textList[i];
        local color = text.color;
        local pos = text.transform.localPosition;

        color.a = color.a - 0.1;
        pos.y = pos.y + 1;
        text.color = color;
        text.transform.localPosition = pos;
        if color.a < 0 then
            removeIndex = i;
        end
    end
    for i = 1, removeIndex, 1 do
        destroy(self.textList[1]);
        table.remove(self.textList, 1)
    end
    if #self.textList == 0 then
        GlobalSchedule:Stop(self.piaoZiSchedule);
        self.piaoZiSchedule = nil;
    end
end

function BabyOrderPanel:CreateText()
    return newObject(self.TextObj):GetComponent('Text');
end

function BabyOrderPanel:StopShedule()
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
        self.autoTex.text = "Quick Cultivation"
    end
    self.schedules = nil
end


