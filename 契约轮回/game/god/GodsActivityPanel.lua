--- Created by Admin.
--- DateTime: 2019/11/12 14:11
GodsActivityPanel = GodsActivityPanel or class("GodsActivityPanel", BasePanel)
local this = GodsActivityPanel

function GodsActivityPanel:ctor()
    self.abName = "god"
    self.assetName = "GodsActivityPanel"
    self.layer = "UI"
    self.use_background = true
    self.events = {}
    self.orderReds = {}
    self.effect = {}
    self.model = GodModel.GetInstance()
end

function GodsActivityPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.jihuo_red then
        self.jihuo_red:destroy()
        self.jihuo_red = nil
    end

    if self.actBtn_red then
        self.actBtn_red:destroy()
        self.actBtn_red = nil
    end
    self:DestroyEffect()
    for i, v in pairs(self.orderReds) do
        v:destroy()
        v = nil
    end
    self.orderReds = {}

    for i, v in pairs(self.itemList) do
        v:destroy()
    end
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil
end

function GodsActivityPanel:Open()
    GodsActivityPanel.super.Open(self)
end

function GodsActivityPanel:OpenCallBack()
end

function GodsActivityPanel:LoadCallBack()
    self.nodes = {
        "bg","close","time","ScrollView/Viewport/Content","item","modelCon",
        "sliderObj/sliderPoint/p_1","sliderObj/sliderPoint/p_2","sliderObj/sliderPoint/p_3",
        "sliderObj/sliderPoint/p_4","sliderObj/sliderPoint/p_5","sliderObj/sliderPoint/p_6",
        "sliderObj/sliderPoint/p_7","sliderObj/sliderPoint/p_8",
        "skillPanel/skill1/skill1Img","skillPanel/skill1/skill1Name",
        "skillPanel/skill2/skill2Img","skillPanel/skill2/skill2Name",

        "jihuoObj","jihuoObj/jihuoTex","jihuoBtn","jihuoBtn/jihuoBtnTex","max","actBtn",
    }
    self:GetChildren(self.nodes)
    self.bigbg = GetImage(self.bg)
    self.skill1Img = GetImage(self.skill1Img)
    self.skill2Img = GetImage(self.skill2Img)
    self.skill1Tex= GetText(self.skill1Name)
    self.skill2Tex = GetText(self.skill2Name)
    self.p_1 = GetImage(self.p_1)
    self.p_2 = GetImage(self.p_2)
    self.p_3 = GetImage(self.p_3)
    self.p_4 = GetImage(self.p_4)
    self.p_5 = GetImage(self.p_5)
    self.p_6 = GetImage(self.p_6)
    self.p_7 = GetImage(self.p_7)
    self.p_8 = GetImage(self.p_8)
    self.jihuoTex = GetText(self.jihuoTex)
    self.jihuoBtnTex = GetText(self.jihuoBtnTex)


    self.jihuo_red = RedDot(self.jihuoBtn, nil, RedDot.RedDotType.Nor)
    self.jihuo_red:SetPosition(54, 16)
    self.jihuo_red:SetRedDotParam(true)

    self.actBtn_red = RedDot(self.actBtn, nil, RedDot.RedDotType.Nor)
    self.actBtn_red:SetPosition(54, 16)
    self.actBtn_red:SetRedDotParam(true)

    for i = 1, 8 do
        self.orderReds[i] = RedDot(self["p_"..i].transform, nil, RedDot.RedDotType.Nor)
        self.orderReds[i]:SetPosition(13, 12)
    end

    local res = "gods_1_bg";
    lua_resMgr:SetImageTexture(self, self.bigbg, "iconasset/icon_big_bg_" .. res, res, false);

    self:AddEvent()
    self:InitPanel()
    self:InitRightPanel()
    MountCtrl:GetInstance():RequestMorphList(enum.TRAIN.TRAIN_GOD)
    OperateController:GetInstance():Request1700006(171100)
end

function GodsActivityPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.close.gameObject, call_back)

    local function call_back(go)
        local arr = string.split(go.name,"_")
        local num = tonumber(arr[2]) - 1
        self:KongClick(num,go)
    end
    for i = 1, 8 do
        AddClickEvent(self["p_"..i].gameObject,call_back)
    end

    local function call_back(go)
        if self.is_act then
            MountCtrl:GetInstance():RequestUpStar(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
        else
            Notify.ShowText("You don't have enough shards")
        end
    end
    AddClickEvent(self.actBtn.gameObject, call_back)

    local function call_back()  --激活按钮
        MountCtrl:GetInstance():RequestUpStar(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
    end
    AddClickEvent(self.jihuoBtn.gameObject,call_back)
-- 数据下发
    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MORPH_ACTIVE_LIST,handler(self,self.HandleActiceList))
    --数据更新
    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MORPH_UPSTAR_DATA,handler(self,self.HandleUpStarData))

    self.events[#self.events + 1] = GlobalEvent:AddListener(OpenHighEvent.UpdateTaskPro, handler(self, self.InitRightPanel))
    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessFetch))
    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO,handler(self,self.HandRightList))
end

--  活动id
function GodsActivityPanel:InitPanel()
    local c = Config.db_yunying[171100].reqs
    local id = String2Table(c)[3]
    local cfg = Config.db_god_morph[id]
    local res = cfg.res
    local ratio = cfg.ratio

    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -2001, y = -116, z = 550}
    cfg.scale = {x = ratio,y = ratio,z = ratio}
    cfg.trans_x = 550
    cfg.trans_y = 550
    cfg.trans_offset = {y=191}
    self.monster = UIModelCommonCamera(self.modelCon, nil, "model_soul_"..res, nil,false)
    self.monster:SetConfig(cfg)

    local key = tostring(id).."@".."9" --写死
    local cfg = Config.db_god_star[key]
    local skillTab = String2Table(cfg.skill_show)
    self.skillid1 = skillTab[1]
    self.skillid2 = skillTab[2]
    local skillCfg1  = Config.db_skill[self.skillid1]
    local skillCfg2  = Config.db_skill[self.skillid2] if not skillCfg1 or not skillCfg2 then
        logError("没有技能配置")
    end
    self.skill1Tex.text = skillCfg1.desc
    self.skill2Tex.text = skillCfg2.desc

    lua_resMgr:SetImageTexture(self, self.skill1Img, "iconasset/icon_skill",skillCfg1.icon,true)
    lua_resMgr:SetImageTexture(self, self.skill2Img, "iconasset/icon_skill",skillCfg2.icon,true)

    self:UpdateGodInfo(id)
    self:ShowTime()
end

function GodsActivityPanel:InitRightPanel()
    local list =  OperateModel:GetInstance():GetRewardConfig(171100)
    self.itemList = self.itemList or {}
    local len = #list
    for i = 1, #list do
        local item = self.itemList[i]
        if not item then
            item = GodsActivityItem(self.item.gameObject, self.Content)
            self.itemList[i] = item
        else
            item:SetVisible(true)
        end
        list[i].index = i
        item:SetData(list[i], self)
    end
    for i = len + 1, #self.itemList do
        local item = self.itemList[i]
        item:SetVisible(false)
    end
end


function GodsActivityPanel:HandleActiceList()
    self.data =  MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD]
    if   self.isFirst  then
        self:InitMenuList()
    end
end

function GodsActivityPanel:InitMenuList()
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


function GodsActivityPanel:HandleUpStarData()
    if self.isJIhuo and self.curCfg.star_client < 0 then
        local function call_back()
            MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_GOD,self.curCfg.id)
        end
        local cfg = Config.db_god_morph[self.curCfg.id]

        Dialog.ShowTwo("Tip", string.format("You activated avatars<color=#%s>%s</color>.Morph now?",ColorUtil.GetColor(cfg.color),cfg.name), "Confirm", call_back, nil, "Cancel", nil, nil)
    end
    self:UpdateGodInfo(self.curCfg.id)
end

function GodsActivityPanel:UpdateGodInfo(godId)
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
   -- self:InitSkillInfo()
    self:UpdateOrderInfo()
   -- self:InitModel()
end

function GodsActivityPanel:UpdateOrderInfo()
    self.isLight = {}
    --self:UpdateAttr()
    self:DestroyEffect()
    self.isJIhuo = false
    if self:IsMaxOrder() then
        SetVisible(self.max,true)
        SetVisible(self.actBtn,false)
        SetVisible(self.jihuoBtn,false)
        SetVisible(self.jihuoObj,false)
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
    self.model.needNum = itemTab[2]
    if table.isempty(itemTab) then
        self.isLight[index] = true
        SetVisible(self.jihuoBtn,true)
       -- SetVisible(self.jihuoObj,false)
        SetVisible(self.actBtn,false)
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
        SetVisible(self.jihuoBtn,false)
        SetVisible(self.actBtn,true)
      --  SetVisible(self.jihuoObj,true)
    end
    local count = BagModel:GetInstance():GetItemNumByItemID(itemTab[1]);
    self.is_act = count >= self.model.needNum
    self.jihuoTex.text = string.format("Activate: %s",count)
    self.actBtn_red:SetRedDotParam(self.is_act)
    self.model:UpdateMainIcon()
end

function GodsActivityPanel:KongClick(index,go)
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



function GodsActivityPanel:IsMaxOrder()
    local nextKey = tostring(self.curCfg.id).."@"..tostring(self.curCfg.star + 1)
    if not Config.db_god_star[nextKey] then --最大星数
        return true
    end
    return false

end

function GodsActivityPanel:LoadEffect(index)
    if (not self.effect[index]) then
        self.effect[index] = UIEffect(self["p_"..index].transform, 30014, false, self.layer)
        self.effect[index]:SetConfig({ is_loop = true })
    else
        self.effect[index]:SetLoop(true)
        SetVisible(self.effect[index], true)
    end
end
function GodsActivityPanel:DestroyEffect(index)
    for i, v in pairs(self.effect) do
        v:destroy()
    end
    self.effect = {}
end

function GodsActivityPanel:HandRightList(data)
    if data.id == 171100 then
        self.rightData = data.tasks
        local tab = data.tasks
        table.sort(tab, function (a, b)
            if a.state == b.state then
                return  a.id < b.id
            else
                return  a.state < b.state
            end
        end)

        for i = 1, #tab do
            self.itemList[i]:UpdateView(tab[i])
        end

        -- 用于刷新左边界面
        local itemTab = String2Table(self.curCfg.cost)
        local count = BagModel:GetInstance():GetItemNumByItemID(itemTab[1]);
        self.is_act = count >= self.model.needNum
        self.jihuoTex.text = string.format("Activate: %s",count)
        self.actBtn_red:SetRedDotParam(self.is_act)
        self.model:UpdateMainIcon()
    end
end

function GodsActivityPanel:HandleSuccessFetch(data)
    if data.act_id  == 171100 then
        -- 重新刷新界面 排序
        self:HandleUpStarData()
        OperateController:GetInstance():Request1700006(171100)
    end
end


function GodsActivityPanel:ShowTime()
    local act_info = OperateModel.GetInstance():GetAct(171100)
    if not self.countdown_item then
        local param = {}
        param["duration"] = 0.3
        param["isChineseType"] =  true
        param["isShowDay"] = true
        param["isShowHour"] = true
        self.countdown_item = CountDownText(self.time, param)
        local function end_func()
            self:Close()
        end
        self.countdown_item:StartSechudle(act_info.act_etime, end_func)
    end
end

function GodsActivityPanel:CloseCallBack()
    if self.countdown_item then
        self.countdown_item:destroy()
        self.countdown_item = nil
    end
end