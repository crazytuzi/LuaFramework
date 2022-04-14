---
--- Created by  Administrator
--- DateTime: 2019/9/6 15:37
---
GodFigurePanel = GodFigurePanel or class("GodFigurePanel", BaseItem)
local this = GodFigurePanel

function GodFigurePanel:ctor(parent_node, parent_panel)
    self.abName = "god"
    self.assetName = "GodFigurePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.isFirst = true
    self.effect = {}
    self.orderReds = {}
    --  self.curBabyId = 0
    self.model = GodModel:GetInstance()
    GodMainPanel.super.Load(self)
end

function GodFigurePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.left_menu then
        self.left_menu:destroy()
    end
    self.left_menu = nil
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil

    for i, v in pairs(self.effect) do
        v:destroy()
    end
    self.effect = {}

    if self.jihuo_red then
        self.jihuo_red:destroy()
        self.jihuo_red = nil
    end

    for i, v in pairs(self.orderReds) do
        v:destroy()
        v = nil
    end
    self.orderReds = {}
end

function GodFigurePanel:LoadCallBack()
    self.nodes = {
        "leftObj/LeftMenu",
        "middleObj/sliderObj/sliderPoint/p_3","middleObj/sliderObj/sliderPoint/p_4","middleObj/sliderObj/sliderPoint/p_6",
        "middleObj/sliderObj/sliderPoint/p_5","middleObj/sliderObj/sliderPoint/p_1","rightObj/attrObj/powerObj/power",
        "middleObj/sliderObj/sliderPoint/p_2","middleObj/sliderObj/sliderPoint/p_8","middleObj/sliderObj/sliderPoint/p_7",
        "rightObj/skillObj/skillPanel/skill2/skill2Name","rightObj/skillObj/skillPanel/skill1/skill1Lv",
        "rightObj/skillObj/skillPanel/skill1/skill1Img","rightObj/skillObj/skillPanel/skill1/skill1Name",
        "rightObj/skillObj/skillPanel/skill2/skill2Img","rightObj/skillObj/skillPanel/skill2/skill2Lv",
        "middleObj/jihuoBtn","middleObj/figureBtn","middleObj/unFigureBtn","middleObj/max","middleObj/jihuoObj","middleObj/jihuoObj/jihuoTex",
        "rightObj/attrObj/baseAttrObj/baseAttrtex3","rightObj/attrObj/baseAttrObj/baseAttrtex1",
        "rightObj/attrObj/baseAttrObj/baseAttr4","rightObj/attrObj/baseAttrObj/baseAttrUpObj1/baseAttrUp1",
        "rightObj/attrObj/baseAttrObj/baseAttr1","rightObj/attrObj/baseAttrObj/baseAttrUpObj5","rightObj/attrObj/baseAttrObj/baseAttrUpObj2",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj4/baseAttrUp4","rightObj/attrObj/baseAttrObj/baseAttrUpObj3",
        "rightObj/attrObj/baseAttrObj/baseAttr5","rightObj/attrObj/baseAttrObj/baseAttr3","rightObj/attrObj/baseAttrObj/baseAttrUpObj5/baseAttrUp5",
        "rightObj/attrObj/baseAttrObj/baseAttrtex4","rightObj/attrObj/baseAttrObj/baseAttrUpObj2/baseAttrUp2","rightObj/attrObj/baseAttrObj/baseAttrtex2",
        "rightObj/attrObj/baseAttrObj/baseAttrUpObj3/baseAttrUp3","rightObj/attrObj/baseAttrObj/baseAttrUpObj4", "rightObj/attrObj/baseAttrObj/baseAttr2",
        "rightObj/attrObj/baseAttrObj/baseAttrtex5","rightObj/attrObj/baseAttrObj/baseAttrUpObj1",
        "middleObj/nameBg/godName","middleObj/modelCon","middleObj/wenhao","middleObj/jihuoBtn/jihuoBtnTex",
    }
    self:GetChildren(self.nodes)
    self.skill2Name = GetText(self.skill2Name)
    self.skill2Lv = GetText(self.skill2Lv)
    self.skill2Img = GetImage(self.skill2Img)

    self.skill1Name = GetText(self.skill1Name)
    self.skill1Lv = GetText(self.skill1Lv)
    self.skill1Img = GetImage(self.skill1Img)
    self.p_1 = GetImage(self.p_1)
    self.p_2 = GetImage(self.p_2)
    self.p_3 = GetImage(self.p_3)
    self.p_4 = GetImage(self.p_4)
    self.p_5 = GetImage(self.p_5)
    self.p_6 = GetImage(self.p_6)
    self.p_7 = GetImage(self.p_7)
    self.p_8 = GetImage(self.p_8)
    self.jihuoTex = GetText(self.jihuoTex)
    self.power = GetText(self.power)
    self.godName = GetText(self.godName)
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
    self.jihuoBtnTex = GetText(self.jihuoBtnTex)

    self.jihuo_red = RedDot(self.jihuoBtn, nil, RedDot.RedDotType.Nor)
    self.jihuo_red:SetPosition(54, 16)
    self.jihuo_red:SetRedDotParam(true)
    for i = 1, 8 do
        self.orderReds[i] = RedDot(self["p_"..i].transform, nil, RedDot.RedDotType.Nor)
        self.orderReds[i]:SetPosition(13, 12)
    end

    self:InitUI()
    self:AddEvent()
    MountCtrl:GetInstance():RequestMorphList(enum.TRAIN.TRAIN_GOD)

   -- dump(self.model.itemsId)
end



function GodFigurePanel:InitUI()

end

function GodFigurePanel:AddEvent()
    local function call_back()
        ShowHelpTip(HelpConfig.god.Help2,true)
    end
    AddClickEvent(self.wenhao.gameObject,call_back)



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

    local function call_back()  --幻化
         MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
    end
    AddClickEvent(self.figureBtn.gameObject,call_back)

    local function call_back()  --取消幻化幻化
        MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_GOD,GodModel.defaultID)
    end
    AddClickEvent(self.unFigureBtn.gameObject,call_back)

    local function call_back(go)
        local arr = string.split(go.name,"_")
        local num = tonumber(arr[2]) - 1
       -- local curStar = self.curCfg.star
        --local index = (curStar%9) + 1
        self:KongClick(num,go)
    end
    for i = 1, 8 do
        AddClickEvent(self["p_"..i].gameObject,call_back)
    end
    
    local function call_back()  --激活按钮
        --if self.isJIhuo then
        --    local function call_back()
        --        MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
        --    end
        --    local cfg = Config.db_god_morph[self.curCfg.id]
        --
        --    Dialog.ShowTwo("提示", string.format("你激活了神灵<color=#%s>%s</color>，是否立刻幻化",ColorUtil.GetColor(cfg.color),cfg.name), "确定", call_back, nil, "取消", nil, nil)
        --end
        MountCtrl:GetInstance():RequestUpStar(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
    end
    AddClickEvent(self.jihuoBtn.gameObject,call_back)

    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MORPH_ACTIVE_LIST,handler(self,self.HandleActiceList))
    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MORPH_UPSTAR_DATA,handler(self,self.HandleUpStarData))
    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MOUNT_CHANGE_FIGURE,handler(self,self.HandleChangeFigure))
    self.events[#self.events + 1]  = GlobalEvent:AddListener(GodEvent.CheckRedPoint,handler(self,self.CheckRedPoint))

    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick), self.events);
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick), self.events);
end

function GodFigurePanel:CheckRedPoint()
    self.left_menu:UpdateRedPoint()
    --if self.model. then
    --
    --end
    --local index = (self.curCfg.star % 9)
end

function GodFigurePanel:KongClick(index,go)
    if self.isLight[index] == true then
        MountCtrl:GetInstance():RequestUpStar(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
        return
    else
      --  logError("123")
    end
    
   local starIndex =  math.floor(self.curCfg.star / 9) * 9 + index
    local tipsPanel = lua_panelMgr:GetPanelOrCreate(GodOrderTips)
    tipsPanel:Open()
    tipsPanel:SetData(self.curCfg.id,starIndex, go.transform,self.curCfg.star)
  --  logError(starIndex.."starIndex")
end


function GodFigurePanel:HandleLeftSecItemClick(menuId, subId)
    self:UpdateGodInfo(subId)
end

function GodFigurePanel:HandleLeftFirstClick(index,isHide)
    if not isHide then  --显示
       self:UpdateGodInfo(self.sub_menu[index+3][1][1])
    end
end

function GodFigurePanel:HandleActiceList()
    self.data =  MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD]
    if   self.isFirst  then
        self:InitMenuList()
    end
end

function GodFigurePanel:HandleUpStarData()
    if self.isJIhuo and self.curCfg.star_client < 0 then
        local function call_back()
            MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
        end
        local cfg = Config.db_god_morph[self.curCfg.id]

        Dialog.ShowTwo("Tip", string.format("You activated avatars<color=#%s>%s</color>.Morph now?",ColorUtil.GetColor(cfg.color),cfg.name), "Confirm", call_back, nil, "Cancel", nil, nil)
    end
    self:UpdateGodInfo(self.curCfg.id)
end

function GodFigurePanel:HandleChangeFigure()
    self.figureId =  MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD].used_id
    SetVisible(self.unFigureBtn,true)
    SetVisible(self.figureBtn,false)

    if self.figureId == GodModel.defaultID then --取消幻化
        SetVisible(self.figureBtn,true)
        SetVisible(self.unFigureBtn,false)
    else
        SetVisible(self.figureBtn,false)
        SetVisible(self.unFigureBtn,true)
    end
end

function GodFigurePanel:InitMenuList()
    dump(self.model.FoldData)
    if self.left_menu then
        self.left_menu:destroy()
    end
    self.left_menu = nil
    self.left_menu = GodFoldMenu(self.LeftMenu, nil, self, GodMenuItem, GodMenuSubItem)
    self.left_menu:SetStickXAxis(8.5)
    self.menu = {}
    self.sub_menu = {}
    local tab =  self.model.FoldData

    for i, gods in table.pairsByKey(tab) do
        local groupID = i
        local list = {}
        for k, v in  table.pairsByKey(gods) do
            local tab1 = {k,self.model:GetGodName(k)}
            table.insert(list,tab1)
        end
        self.sub_menu[i] = list
        local tab = {groupID,GodModel.GroupName[groupID]}
        table.insert(self.menu,tab)
    end

    self.left_menu:SetData(self.menu,self.sub_menu,1,2,2)
    self.left_menu:SetDefaultSelected(1, 1)
end

function GodFigurePanel:UpdateGodInfo(godId)
    self.info =  MountModel:GetInstance():GetMorphDataByType(enum.TRAIN.TRAIN_GOD,godId)
    self.figureId =  MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD].used_id
    self.fPower = 0

    if not self.info  then --没激活
        local key = tostring(godId).."@".."0"
        self.curCfg = Config.db_god_star[key]
        --self.curCfg =
        SetVisible(self.figureBtn,false)
        SetVisible(self.unFigureBtn,false)
        self.jihuoBtnTex.text = "Activate"

    else
        local key = tostring(godId).."@"..self.info.star
        self.curCfg = Config.db_god_star[key]
        if self.curCfg.star_client < 0 then
            SetVisible(self.figureBtn,false)
            SetVisible(self.unFigureBtn,false)
            self.jihuoBtnTex.text = "Activate"
        else
            if self.figureId == godId then
                if self.figureId == GodModel.defaultID then
                    SetVisible(self.unFigureBtn,false)
                else
                    SetVisible(self.unFigureBtn,true)
                end
                SetVisible(self.figureBtn,false)
            else
                SetVisible(self.unFigureBtn,false)
                SetVisible(self.figureBtn,true)
            end
            self.jihuoBtnTex.text = "Star up"
            local attrTab = String2Table(self.curCfg.power)
            self.fPower = GetPowerByConfigList(attrTab,{})
        end

    end
    self:InitSkillInfo()
    self:UpdateOrderInfo()
    self:InitModel()
end

function GodFigurePanel:InitSkillInfo()
    local key = tostring(self.curCfg.id).."@".."9" --写死
    local cfg = Config.db_god_star[key]
    local skillTab = String2Table(cfg.skill_show)
    self.skillid1 = skillTab[1]
    self.skillid2 = skillTab[2]
    local skillCfg1  = Config.db_skill[self.skillid1]
    local skillCfg2  = Config.db_skill[self.skillid2] if not skillCfg1 or not skillCfg2 then
        logError("没有技能配置")
    end
    self.skill1Name.text = skillCfg1.name
    self.skill2Name.text = skillCfg2.name

    lua_resMgr:SetImageTexture(self, self.skill1Img, "iconasset/icon_skill",skillCfg1.icon,true)
    lua_resMgr:SetImageTexture(self, self.skill2Img, "iconasset/icon_skill",skillCfg2.icon,true)
end




function GodFigurePanel:UpdateOrderInfo()
    self.isLight = {}
    self:UpdateAttr()
    self:DestroyEffect()
    self.isJIhuo = false
    if self:IsMaxOrder() then
        SetVisible(self.max,true)
        SetVisible(self.jihuoObj,false)
        SetVisible(self.jihuoBtn,false)
        for i = 1, 8 do
            lua_resMgr:SetImageTexture(self, self["p_"..i], "god_image","god_star2",true)
            self.orderReds[i]:SetRedDotParam(false)
            self:LoadEffect(i)
        end
        return
    end
    SetVisible(self.max,false)
    local index = (self.curCfg.star % 9)
    --local nextStar = self.curCfg.star + 1
    local itemTab = String2Table(self.curCfg.cost)
    if table.isempty(itemTab) then
        self.isLight[index] = true
        SetVisible(self.jihuoBtn,true)
        SetVisible(self.jihuoObj,false)
        self.isJIhuo = true
        for i = 1, 8 do
          lua_resMgr:SetImageTexture(self, self["p_"..i], "god_image","god_star2",true)
            self.orderReds[i]:SetRedDotParam(false)
            self:LoadEffect(i)
        end
    else
        local id = itemTab[1]
        local needNub = itemTab[2]
        local num = BagModel:GetInstance():GetItemNumByItemID(id);
        if num>= needNub then
            self.isLight[index] = true
            lua_resMgr:SetImageTexture(self, self["p_"..index + 1], "god_image","god_star1",true)
            self.orderReds[index+1]:SetRedDotParam(true)
         --   self:HideEffect(index + 1)
        else
            lua_resMgr:SetImageTexture(self, self["p_"..index + 1], "god_image","god_star",true)
            self.orderReds[index+1]:SetRedDotParam(false)
         --   self:HideEffect(index + 1)
        end
        for i = 1, 8 do
            if i < index + 1  then
                lua_resMgr:SetImageTexture(self, self["p_"..i], "god_image","god_star2",true)
                self.orderReds[i]:SetRedDotParam(false)
                self:LoadEffect(i)
            elseif i > index + 1 then
                lua_resMgr:SetImageTexture(self, self["p_"..i], "god_image","god_star",true)
                self.orderReds[i]:SetRedDotParam(false)
              --  self:HideEffect(index + 1)
            end
        end
        self.jihuoTex.text = string.format("%s/%s",index,8)
        SetVisible(self.jihuoBtn,false)
        SetVisible(self.jihuoObj,true)
    end
end

function GodFigurePanel:UpdateAttr()
    local cfg  = self.curCfg
     local nextKey = tostring(self.curCfg.id).."@"..tostring(self.curCfg.star+1)
    local nextCfg = Config.db_god_star[nextKey]
    local baseTab =String2Table(cfg.attrs)
    for i = 1, 5 do
        if #baseTab >= i  then
            local attrId = baseTab[i][1]
            local attrNum = baseTab[i][2]

            if nextCfg == nil then
                self["baseAttrUp"..i].text = "max"
            else
                local nextTab = String2Table(nextCfg.attrs)
                local nextNux = nextTab[i][2]
                self["baseAttrUp"..i].text = nextNux - attrNum
                if attrId > 1000 then
                    self["baseAttrUp"..i].text = ((nextNux - attrNum)/100).."%"
                else
                   -- self["baseAttr"..i].text = attrNum
                    self["baseAttrUp"..i].text = nextNux - attrNum
                end
                if nextNux - attrNum == 0 then
                    SetVisible(self["baseAttrUpObj"..i],false)
                else
                    SetVisible(self["baseAttrUpObj"..i],true)
                end

            end
            local attrName = enumName.ATTR[attrId]
            if attrId > 1000 then
                self["baseAttr"..i].text = (attrNum / 100) .. "%";
            else
                self["baseAttr"..i].text = attrNum 
            end
            self["baseAttrtex"..i].text = attrName


        else
            self["baseAttrUp"..i].text = ""
            self["baseAttrtex"..i].text = ""
            self["baseAttr"..i].text = ""
            SetVisible(self["baseAttrUpObj"..i],false)
        end
    end
    local attriList = baseTab
    local power2,tab2 = GetPowerByConfigList(attriList,{})
    local power,tab = GetPowerByConfigList(attriList,tab2)
   -- logError(power,self.fPower,power + self.fPower)
    self.power.text = power + self.fPower

end

function GodFigurePanel:InitModel()
    local cfg = Config.db_god_morph[self.curCfg.id]
    local res = cfg.res
    local ratio = cfg.ratio
    if res == self.curRes then
        return
    end
    self.curRes = res
    self.godName.text = cfg.name
   -- self.curResName

    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -2001, y = -80, z = 550}
    cfg.scale = {x = ratio,y = ratio,z = ratio}
    cfg.trans_x = 830
    cfg.trans_x = 830
    cfg.trans_offset = {y=121}
    self.monster = UIModelCommonCamera(self.modelCon, nil, "model_soul_"..self.curRes)
    self.monster:SetConfig(cfg)
end


function GodFigurePanel:IsMaxOrder()
    local nextKey = tostring(self.curCfg.id).."@"..tostring(self.curCfg.star + 1)
    if not Config.db_god_star[nextKey] then --最大星数
        return true
    end
    return false

end

function GodFigurePanel:LoadEffect(index)
    if (not self.effect[index]) then
        self.effect[index] = UIEffect(self["p_"..index].transform, 30014, false, self.layer)
        self.effect[index]:SetConfig({ is_loop = true })
    else
        self.effect[index]:SetLoop(true)
        SetVisible(self.effect[index], true)
    end
end

function GodFigurePanel:DestroyEffect(index)
    for i, v in pairs(self.effect) do
        v:destroy()
    end
    self.effect = {}
end