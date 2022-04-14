---
--- Created by  Administrator
--- DateTime: 2019/8/28 16:53
---
BabyCulturePanel = BabyCulturePanel or class("BabyCulturePanel", BaseItem)
local this = BabyCulturePanel

function BabyCulturePanel:ctor(parent_node, parent_panel)

    self.abName = "baby"
    self.assetName = "BabyCulturePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.gEvent = {}
    self.btnSelects = {}
    self.babyItems = {}
    self.tastItems = {}
    self.textList = {}
    self.isFirst = true
    self.isPlayAni = false
    self.count = 5
    self.isClick = true
  --  self.rightType = -1   --1养育 2任务
    self.curBaby = -1 --1男 2女
    self.model = BabyModel:GetInstance()
    BabyCulturePanel.super.Load(self)
end

function BabyCulturePanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gEvent)

    for i, v in pairs(self.babyItems) do
        v:destroy()
    end
    self.babyItems = {}
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil
    self.btnSelects = nil

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = nil

    if self.orderCost then
        self.orderCost:destroy()
    end
    self.orderCost = nil

    for i, v in pairs(self.tastItems) do
        v:destroy()
    end
    self.tastItems = {}
    self.textList = nil;
    if self.piaoZiSchedule then
        GlobalSchedule:Stop(self.piaoZiSchedule);
    end
    self.piaoZiSchedule = nil

    self:ClearRedPoint()

    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
    
end

function BabyCulturePanel:LoadCallBack()
    self.nodes = {
        "midleObj/btnParent/showIcon","BabyCultureTaskItem","midleObj/btnParent/zanIcon",
        "midleObj/btnParent/rankIcon","leftObj/babyParent","BabyCultureBabyItem","midleObj/btnParent/playIcon",
        "midleObj/wenhao","midleObj/HideTog","midleObj/title/babyName","midleObj/babyState/babyStateImg","midleObj/modelCon",
        "rightObj/taskBtn","rightObj/taskObj/ScrollView/Viewport/Content","rightObj/CulObj/culPanel2","rightObj/culBtn",
        "rightObj/taskObj","rightObj/CulObj","rightObj/CulObj/culPanel1","midleObj/babyState",
        "rightObj/taskBtn/taskBtnSelect","rightObj/culBtn/culBtnSelect","rightObj/CulObj/culPanel1/quliyBtn","rightObj/CulObj/culPanel2/oneBtn",
        "rightObj/CulObj/culPanel2/expSliderBG/expSlider","rightObj/CulObj/culPanel2/expSliderBG/expText","rightObj/CulObj/culPanel2/maxImg",
        "rightObj/CulObj/culPanel2/iconParent","rightObj/CulObj/culPanel2/oneBtn/autoTex",
        "rightObj/CulObj/culPanel1/Slider","rightObj/CulObj/culPanel1/Slider/sliderTex",
        "rightObj/CulObj/culPanel2/powerObj/power","midleObj/hand","rightObj/CulObj/culPanel1/des",
        "rightObj/CulObj/culPanel1/dunIcon","rightObj/CulObj/culPanel1/shopIcon",
        "rightObj/CulObj/culPanel2/expCon","rightObj/CulObj/culPanel2/expCon/TextObj",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj2/baseAttrUp2",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrtex4",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrtex1",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttr3",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrtex3",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj4/baseAttrUp4",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj1/baseAttrUp1",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttr2",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj3/baseAttrUp3",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrtex2",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttr1",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttr4",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj3",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj4",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj1",
        "rightObj/CulObj/culPanel2/attrObj/baseAttrObj/baseAttrUpObj2",
        "midleObj/Noactive","midleObj/btnParent",
    }
    self:GetChildren(self.nodes)
    self:InitUI()
    self:AddEvent()
    self.expSlider = GetImage(self.expSlider)
    self.expText = GetText(self.expText)
    self.autoTex = GetText(self.autoTex)
    self.babyName = GetText(self.babyName)
    self.sliderTex = GetText(self.sliderTex)
    self.Slider = GetSlider(self.Slider)
    self.power = GetText(self.power)
    self.HideTog = GetToggle(self.HideTog)
    self.babyStateImg = GetImage(self.babyStateImg)
    self.des = GetText(self.des)

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

    self.btnSelects[1] = self.culBtnSelect
    self.btnSelects[2] = self.taskBtnSelect
    BabyController:GetInstance():RequstBabyInfo()

    self.play_red = RedDot(self.playIcon, nil, RedDot.RedDotType.Nor)
    self.play_red:SetPosition(30, 23)

    self.one_red = RedDot(self.oneBtn, nil, RedDot.RedDotType.Nor)
    self.one_red:SetPosition(53, 15)

    self.cul_red = RedDot(self.culBtn, nil, RedDot.RedDotType.Nor)
    self.cul_red:SetPosition(53, 16)

    self.task_red = RedDot(self.taskBtn, nil, RedDot.RedDotType.Nor)
    self.task_red:SetPosition(53, 16)

    self.record_red = RedDot(self.zanIcon, nil, RedDot.RedDotType.Nor)
    self.record_red:SetPosition(30, 23)

    self.show_red = RedDot(self.showIcon, nil, RedDot.RedDotType.Nor)
    self.show_red:SetPosition(30, 23)

end

function BabyCulturePanel:ClearRedPoint()
    if self.play_red then
        self.play_red:destroy()
        self.play_red = nil
    end

    if self.one_red then
        self.one_red:destroy()
        self.one_red = nil
    end

    if self.cul_red then
        self.cul_red:destroy()
        self.cul_red = nil
    end

    if self.task_red then
        self.task_red:destroy()
        self.task_red = nil
    end

    if self.record_red then
        self.record_red:destroy()
        self.record_red = nil
    end

    if self.show_red then
        self.show_red:destroy()
        self.show_red = nil
    end


end

function BabyCulturePanel:InitUI()

end

function BabyCulturePanel:AddEvent()
    
    local function call_back()
        self:ClickRightBtn(1)
    end
    AddClickEvent(self.culBtn.gameObject,call_back)
    local function call_back()
        self:ClickRightBtn(2)
    end
    AddClickEvent(self.taskBtn.gameObject,call_back)

    local function call_back() --跳转
        local babyCfg = Config.db_baby[self.curBaby]
        local mallTab = String2Table(babyCfg.mall)
        local mallID = tonumber(mallTab[5])
        local mallCfg = Config.db_mall[mallID]
        local itemTab = String2Table(mallCfg.item)
        local itemId = itemTab[1]
        if  BagModel:GetInstance():GetItemNumByItemID(itemId) <= 0 then
            self:GoShop()
        else
            OpenLink(1300,1,2,self.curBaby)
        end

    end
    AddButtonEvent(self.quliyBtn.gameObject,call_back)

    local function call_back() --一件培养
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Quick Cultivation"
            self.schedules = nil;
            return
        end
        --local info = self.info
        -- local key = tostring(self.curBaby).."@"..tostring(info.level + 1)
        --if not key then
        --    --logError("检查配置，是不是从0级开始")
        --    return
        --end
        --local cfg = Config.db_baby_level[key]
        --local itemTab = String2Table(cfg.cost)
        --self.itemId = itemTab[1][1]
        --self.itemNum = itemTab[1][2]
        local cfg = Config.db_baby[self.curBaby]

        self.itemId = cfg.growitem
        self.itemNum = 1

        if BagModel:GetInstance():GetItemNumByItemID(self.itemId) >= self.itemNum then
            self.schedules = GlobalSchedule:Start(handler(self,self.AutoLevel), 0.2, -1);
            self.autoTex.text = "Stop";
        else
            Notify.ShowText("Not enough upgrade materials")
        end
    end
    AddButtonEvent(self.oneBtn.gameObject,call_back)
    
    local function call_back() --逗宝宝
        if self.isPlayAni == false then
            BabyController:GetInstance():RequstPlay(self.curBaby)
        end

    end
    AddButtonEvent(self.playIcon.gameObject,call_back)

    local function call_back()
      --  Notify.ShowText("暂未开放，敬请期待")
       -- self.count
        if not self.isClick then
            Notify.ShowText(string.format("Please try again after %s sec",self.count))
            return
        end
        CacheManager:GetInstance():SetInt("babyShow"..RoleInfoModel:GetInstance():GetMainRoleId(),os.time())
        self.model:CheckCulRedPoint()
       -- if self.isClick then
        Notify.ShowText("Successfully shared")
            self.isClick = false
            local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
            local text = string.format("My babe is so cute! Come and have a look!-<color=#3ab60e><a href=baby_%s>amuse the babe</a></color>",role_id)
            ChatController.GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD , 0, text)
            local function call_back()
                self.count = self.count - 1
                if self.count <= 0 then
                    self.count = 5
                    self.isClick = true
                    if self.schedule then
                        GlobalSchedule:Stop(self.schedule)
                        self.schedule = nil
                    end
                end
            end
            self.schedule = GlobalSchedule.StartFun(call_back, 1, -1)
       -- end


    end
    AddButtonEvent(self.showIcon.gameObject,call_back)

    local function call_back()
        --Notify.ShowText("暂未开放，敬请期待")
        lua_panelMgr:GetPanelOrCreate(BabyRankPanel):Open()
    end
    AddButtonEvent(self.rankIcon.gameObject,call_back)

    local function call_back()
       -- Notify.ShowText("暂未开放，敬请期待")
        lua_panelMgr:GetPanelOrCreate(BabyRecordPanel):Open()
    end
    AddButtonEvent(self.zanIcon.gameObject,call_back)


    local function call_back()
        self:GoShop()
    end
    AddButtonEvent(self.shopIcon.gameObject,call_back)

    local function call_back()
        OpenLink(1200,5)
    end
    AddButtonEvent(self.dunIcon.gameObject,call_back)





    local call_back = function(target, bool)
        --print2(bool)
        if bool ~= self.model:GetIsHide() then
            BabyController:GetInstance():RequstHide(bool)
        end
    end

    AddValueChange(self.HideTog.gameObject, call_back)

    local function call_back() --问号
        ShowHelpTip(HelpConfig.Baby.Help,true)
    end
    AddButtonEvent(self.wenhao.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyInfo,handler(self,self.BabyInfo))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyUpLevel,handler(self,self.BabyUpLevel))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyPlay,handler(self,self.BabyPlay))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyHide,handler(self,self.BabyHide))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.UpdateRedPoint,handler(self,self.UpdateRedPoint))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyCultureItemClick,handler(self,self.BabyCultureItemClick))

    self.gEvent[#self.gEvent + 1] = GlobalEvent:AddListener(TaskEvent.FinishTask,handler(self,self.FinishTask))

end

function BabyCulturePanel:UpdateRedPoint()
    --self.curBaby
    --self.model.babyCulRedPoints[self.curBaby]
    self.record_red:SetRedDotParam(self.model.isRecordRedPoint)
    self.one_red:SetRedDotParam(self.model.babyCulRedPoints[self.curBaby][1])
    self.cul_red:SetRedDotParam(self.model.babyCulRedPoints[self.curBaby][1])
    self.play_red:SetRedDotParam(self.model.babyCulRedPoints[self.curBaby][2])
    self.task_red:SetRedDotParam(self.model.babyCulRedPoints[self.curBaby][3])

    self.show_red:SetRedDotParam(self.model.babyShowRed)
end

function BabyCulturePanel:FinishTask(id)
    for i, v in pairs(self.tastItems) do
        if id == v.taskId then
            Notify.ShowText("Claimed")
            self:UpdateTaskInfo()
        end
    end
    self.model:CheckCulRedPoint()
end

function BabyCulturePanel:SetHideBox(bool)
    bool = bool and true or false;
    self.HideTog.isOn = bool
end

function BabyCulturePanel:BabyHide()
    self:SetHideBox(self.model:GetIsHide())
end

function BabyCulturePanel:GoShop()
    local babyCfg = Config.db_baby[self.curBaby]
    local mallTab = String2Table(babyCfg.mall)
    local mallID = tonumber(mallTab[5])
    local lv = Config.db_mall[mallID].limit_level
    local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if role_data.level >= lv then
        --OpenLink(180, 1, 2, 1, mallID)
        OpenLink(unpack(mallTab))
    else
        local gender = "Baby Boy"
        if self.curBaby == 2 then
            gender = "Baby Girl"
        end
        Notify.ShowText(string.format("Lv.%s unlocks %s Speed up birth",lv,gender))
    end

end

function BabyCulturePanel:ClickRightBtn(index)
    self:StopShedule()
    if  self.rightType == index then
        return
    end
    self.rightType = index
    for i = 1, #self.btnSelects do
        if i == index then
            SetVisible(self.btnSelects[i],true)
        else
            SetVisible(self.btnSelects[i],false)
        end
    end
    self:SetRightUI()
end

function BabyCulturePanel:SetRightUI()
    if self.rightType == 1 then --培养
        SetVisible(self.CulObj,true)
        SetVisible(self.taskObj,false)
    else --任务
        SetVisible(self.CulObj,false)
        SetVisible(self.taskObj,true)

    end
end

function BabyCulturePanel:GetTaskState(info)
    if not info then
        return 0
    end
    return info.state
end

function BabyCulturePanel:UpdateTaskInfo()
    local babyCfg = Config.db_baby[self.curBaby]
    local taskTab = String2Table(babyCfg.task)[1]
    table.sort(taskTab, function(a,b)
        local info1 =  TaskModel:GetInstance():GetTask(a)
        local info2 =  TaskModel:GetInstance():GetTask(b)
        local state1 = self:GetTaskState(info1)
        local state2 = self:GetTaskState(info2)
        return state1 > state2

    end)
    for i = 1, #taskTab do
        local item = self.tastItems[i]
        if not item then
            item = BabyCultureTaskItem(self.BabyCultureTaskItem.gameObject,self.Content,"UI")
            self.tastItems[i] = item
        end
        item:SetData(taskTab[i])
    end
end




--设置培养信息
function BabyCulturePanel:SetCulInfo()
    local gender =  self.curBaby
   -- logError(gender)
    if self.model:IsBirth(gender) then
        SetVisible(self.culPanel2,true)
        SetVisible(self.culPanel1,false)
        self:UpdateCulInfo()
    else
        SetVisible(self.culPanel2,false)
        SetVisible(self.culPanel1,true)
        self:SetCulPro()
    end
end

--设置出生进度
function BabyCulturePanel:SetCulPro()
    local cfg = Config.db_baby[self.curBaby]
    local curPro = self.model.progress[self.curBaby]
    if not curPro then
        curPro = 0
    end
    self.Slider.value = curPro/cfg.reqs
    self.sliderTex.text = string.format("%s/%s",curPro,cfg.reqs)
end

--更新信息
function BabyCulturePanel:UpdateCulInfo()
    self.info = self.model:GetBabyInfo(self.curBaby)
    if self:IsMax(self.info.level) then
        self.expSlider.fillAmount = 1
        self.expText.text = "max"
    else
        local cfg = Config.db_baby[self.curBaby]
        if  self.info  then
            local exp =  self.info.exp
            local lvKey = tostring(self.curBaby).."@"..tostring(self.info.level + 1)
            local lvCfg = Config.db_baby_level[lvKey]

            self.expSlider.fillAmount = exp/lvCfg.cost
            self.expText.text = string.format("%s/%s",exp,lvCfg.cost)
            --local key = tostring(self.curBaby).."@"..tostring( self.info.level + 1)
            --if not key then
            --    return
            --end
            --local lvCfg = Config.db_baby_level[key]
            --local rewardTab = String2Table(lvCfg.cost)
            --local id = rewardTab[1][1]
            --local num = rewardTab[1][2]
            local cfg = Config.db_baby[self.curBaby]

            local id = cfg.growitem
            local num  = 1
            if not self.orderCost then
                self.orderCost = BabyGoodsItem(self.iconParent)
            end
            self.orderCost:SetData(id,2,num)
        end
    end
    for i, v in pairs(self.babyItems) do
        if v.data.gender == self.curBaby then
            v:UpdateLevel(self.info.level)
        end
    end
    self:UpdateAttr()
    self:SetBabyName()
end


function BabyCulturePanel:BabyCultureItemClick(data)
    self:StopShedule()
    --SetShow
    for i, v in pairs(self.babyItems) do
        if v.data.gender == data.gender then
            self.curBaby = data.gender
            v:SetShow(true)
            self.info = self.model:GetBabyInfo(self.curBaby)
            self:SetBabyUiInfo(data)
            self:UpdateRedPoint()
        else
            v:SetShow(false)
        end
    end
end


function BabyCulturePanel:InitBabyItem()
    local babyCfg = Config.db_baby
    for i = 1, #babyCfg do
        local item = self.babyItems[i]
        if not item then
            item = BabyCultureBabyItem(self.BabyCultureBabyItem.gameObject,self.babyParent,"UI")
            self.babyItems[i] = item
        end
        item:SetData(babyCfg[i])
    end
    self:BabyCultureItemClick(self.babyItems[1].data)
end

function BabyCulturePanel:BabyInfo(data)

    if self.isFirst then
        self:InitBabyItem()
        self:SetHideBox(self.model:GetIsHide())
        self.isFirst = false
    else
       -- self:UpdateCulInfo()
    end

end

function BabyCulturePanel:BabyPlay()
    self.isPlayAni = true
    self:UpdatePlayState()
    self:PlayBabyAni()
end

function BabyCulturePanel:BabyUpLevel()
    self:UpdateCulInfo()
    local exp = Config.db_item[self.itemId]
    self:ShowAddExp("+"..exp.effect);
end

function BabyCulturePanel:PlayBabyAni()
  -- if self.isPlayAni == false then
        SetVisible(self.hand,true)
        local action
        action = cc.ScaleTo(0.3, 1.3)
        action = cc.Sequence(action,cc.ScaleTo(0.3, 0.7))
        action = cc.Sequence(action,cc.ScaleTo(0.3, 1.3))
        action = cc.Sequence(action,cc.ScaleTo(0.3, 1))
        action = cc.Sequence(action, cc.CallFunc(handler(self,self.EndAni)))
        cc.ActionManager:GetInstance():addAction(action, self.hand)
        self.monster.UIModel:AddAnimation({"show","idle"},false,"idle",0)--,"casual"
   -- end

end

function BabyCulturePanel:EndAni()
    self.isPlayAni = false
    SetVisible(self.hand,false)
end


function BabyCulturePanel:UpdatePlayState()
    local  times = self.model:GetPlayBabyTimes(self.curBaby)
   -- local stateTex = "QAQ"
    if times > 0  then
       -- stateTex = "*∩_∩*"
        lua_resMgr:SetImageTexture(self, self.babyStateImg, "baby_image", "baby_xiao", true, nil, false)
    else
        --有红点
        lua_resMgr:SetImageTexture(self, self.babyStateImg, "baby_image", "baby_ku", true, nil, false)
    end

end

function BabyCulturePanel:SetBabyUiInfo(data)
    if not self.model:IsBirth(data.gender) then --没出生
        SetVisible(self.babyState,false)
        SetVisible(self.btnParent,false)
        SetVisible(self.Noactive,true)
    else
        SetVisible(self.babyState,true)
        SetVisible(self.btnParent,true)
        SetVisible(self.Noactive,false)
        self:UpdatePlayState()
    end
    self:SetCulInfo()
    self:SetBabyName()
    self:InitModel(string.format("model_child_%s0001",data.gender))
    self:UpdateTaskInfo()
    self.des.text = HelpConfig.Baby.Help2
    self:ClickRightBtn(self.rightType or 1)
end

function BabyCulturePanel:SetBabyName()
    local info = self.info
    local cfg = Config.db_baby[self.curBaby]
    if not info then
        self.babyName.text = "Lv.0"..cfg.name
    else
        self.babyName.text = "Lv."..info.level..cfg.name
    end


   -- self.babyName.text =
end

function BabyCulturePanel:InitModel(resName)
    if self.monster then
        self.monster:destroy()
    end
    local id = self.model:GetWingShowId()
    local cfg = {}
    cfg.pos = {x = -2000, y = -60, z = 193}
    cfg.scale = {x=200, y=200, z=200}
    cfg.trans_offset = {y=60}
    if id ~= 0 then
        self.monster = UIModelCommonCamera(self.modelCon, nil, resName,id)
    else
        self.monster = UIModelCommonCamera(self.modelCon, nil, resName)
    end

    self.monster:SetConfig(cfg)
end

function BabyCulturePanel:AutoLevel()
    if self:IsMax() then
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto upgrade"
            self.schedules = nil;
            return
        end
    end
    local num = BagModel:GetInstance():GetItemNumByItemID(self.itemId) or 0
    if num >= self.itemNum then
        BabyController:GetInstance():RequstUpLevel(self.curBaby)
    else
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
            self.autoTex.text = "Auto upgrade"
            self.schedules = nil;
            return
        end
    end

end

function BabyCulturePanel:UpdateAttr()
    local info = self.info
    local key = tostring(self.curBaby).."@"..tostring(info.level)
    local nextKey = tostring(self.curBaby).."@"..tostring(info.level + 1)
    local cfg = Config.db_baby_level[key]
    local nextCfg = Config.db_baby_level[nextKey]
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

function BabyCulturePanel:IsMax(level)
    local babyCfg = Config.db_baby[self.curBaby]
    local maxlevel = babyCfg.maxlevel
    local lv =  level or self.info.level

    local NextLvKey = tostring(self.curBaby).."@"..tostring(self.info.level + 1)
    local NextLvCfg = Config.db_baby_level[NextLvKey]

    local key = tostring(self.curBaby).."@"..tostring(self.info.level)
    local cfg =   Config.db_baby_level[key]
    if not NextLvCfg  and self.info.exp >= cfg.exp then
        if self.orderCost then
            self.orderCost:destroy()
        end
        self.orderCost = nil
        SetVisible(self.maxImg,true)
        SetVisible(self.oneBtn,false)
         return true
    end
    SetVisible(self.maxImg,false)
    SetVisible(self.oneBtn,true)
    return false
end


function BabyCulturePanel:ShowAddExp(text1)
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

function BabyCulturePanel:UpdateTextList()
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

function BabyCulturePanel:CreateText()
    return newObject(self.TextObj):GetComponent('Text');
end

function BabyCulturePanel:StopShedule()
    --for i = 1, #self.textList do
    --    destroy(self.textList[i])
    --    table.remove(self.textList, 1)
    --end
    --self:UpdateTextList()
    --if self.piaoZiSchedule then
    --    GlobalSchedule:Stop(self.piaoZiSchedule);
    --end
    --self.piaoZiSchedule = nil
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
        self.autoTex.text = "Quick Cultivation"
    end
    self.schedules = nil
end

