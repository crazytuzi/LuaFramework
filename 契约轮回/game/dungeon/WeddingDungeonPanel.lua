---
--- Created by  Administrator
--- DateTime: 2019/7/13 11:32
---
WeddingDungeonPanel = WeddingDungeonPanel or class("WeddingDungeonPanel", DungeonMainBasePanel)
local this = WeddingDungeonPanel

function WeddingDungeonPanel:ctor(parent_node, parent_panel)

    self.abName = "dungeon"
    self.assetName = "WeddingDungeonPanel"

    self.model = MarryModel:GetInstance()
    self.events = {}
    self.gevents = {}
    self.rewards = {}
    self.itemicon = {}
    self.isMyWedding = false
end

function WeddingDungeonPanel:dctor()
    GlobalEvent:RemoveTabListener(self.gevents)
    self.model:RemoveTabListener(self.events)
    self:StopSchedule()
    for i, v in pairs(self.rewards) do
        v:destroy()
    end
    self.rewards = {}
    if self.expSchedules then
        GlobalSchedule:Stop(self.expSchedules);
    end

    for i, v in pairs(self.itemicon) do
        v:destroy()
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

function WeddingDungeonPanel:Open( )
    DungeonPersonalBossPanel.super.Open(self)
end

function WeddingDungeonPanel:LoadCallBack()
    self.nodes = {
        "endTime/endTitleTxt","progress/slider","static/foodTex","endTime",
        "static/expTex","hardshow/iconParent",
        "static/xiTex","progress/heat_slader",
        "progress/rewardParent","WeddingDungeonReward",
        "progress/hotTex",
        "hardshow/highBtn/highBtnTex","hardshow/highBtn",
        "hardshow/lowBtn","hardshow/lowBtn/lowBtnTex",
        "invBtn","mgrBtn","progress"
    }
    self:GetChildren(self.nodes)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.foodTex = GetText(self.foodTex)
    self.expTex = GetText(self.expTex)
    self.xiTex = GetText(self.xiTex)
    self.hotTex = GetText(self.hotTex)
    self.slider = GetSlider(self.slider)
    self.heat_slader = GetImage(self.heat_slader)
    self.lowBtnTex = GetText(self.lowBtnTex)
    self.highBtnTex = GetText(self.highBtnTex)
    self.lowBtnImg = GetImage(self.lowBtn)
    self.highBtnImg = GetImage(self.highBtn)
    self.red1 = RedDot(self.lowBtn, nil, RedDot.RedDotType.Nor)
    self.red1:SetPosition(43, 14)


    self.red2 = RedDot(self.highBtn, nil, RedDot.RedDotType.Nor)
    self.red2:SetPosition(43, 14)
    --self:MarryRedPoint()
    self:InitUI()
    self:AddEvent()


    MarryController:GetInstance():RequsetPartyInfo()
    MarryController:GetInstance():RequsetWeddingNotice()
end

function WeddingDungeonPanel:InitUI()
    local lowFire = self.model:GetLowFireId()
    local highFire = self.model:GetHighFireId()
    self:CreateIcon(lowFire)
    self:CreateIcon(highFire)
    self:SetLowBtnState(lowFire)
    self:SetHighBtnState(highFire)
end

function WeddingDungeonPanel:AddEvent()
    local call_back = function()
        if self.invBtn and self.mgrBtn and self.progress then
            SetGameObjectActive(self.invBtn.gameObject,false)
            SetGameObjectActive(self.mgrBtn.gameObject,false)
            SetGameObjectActive(self.progress,false)
        end
        SetGameObjectActive(self.endTime.gameObject , false);
    end

    self.gevents[#self.gevents + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        if self.invBtn and self.mgrBtn and self.progress then
            if self.isMyWedding then
                SetGameObjectActive(self.invBtn.gameObject,true)
            else
                SetGameObjectActive(self.invBtn.gameObject,false)
            end

            SetGameObjectActive(self.mgrBtn.gameObject,true)
            SetGameObjectActive(self.progress.gameObject,true)
        end
        SetGameObjectActive(self.endTime.gameObject , true);
    end

    self.gevents[#self.gevents + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);




    local function call_back()
       -- local lowFire = self.model:GetLowFireId()
      --  local highFire = self.model:GetHighFireId()
        if self.lowState == 0 then --购买
            lua_panelMgr:GetPanelOrCreate(WeddingShopPanel):Open(60004)
            return
        end
        local uid = BagModel:GetInstance():GetUidByItemID(self.model:GetLowFireId())
        GoodsController:GetInstance():RequestUseGoods(uid,1)

    end
    AddButtonEvent(self.lowBtn.gameObject,call_back)

    local function call_back()
        if self.highState == 0 then --购买
            lua_panelMgr:GetPanelOrCreate(WeddingShopPanel):Open(60003)
            return
        end
        local uid = BagModel:GetInstance():GetUidByItemID(self.model:GetHighFireId())
        GoodsController:GetInstance():RequestUseGoods(uid,1)
    end
    AddButtonEvent(self.highBtn.gameObject,call_back)
    
    local function call_back()  --宾客邀请
        lua_panelMgr:GetPanelOrCreate(WeddingInvitationPanel):Open()
    end
    AddButtonEvent(self.invBtn.gameObject,call_back)

    local function call_back()  --商店
        lua_panelMgr:GetPanelOrCreate(WeddingShopPanel):Open()
    end
    AddButtonEvent(self.mgrBtn.gameObject,call_back)


    local function call_back(id)
       -- self:UdpateGoods()
        
        local lowFire = self.model:GetLowFireId()
        local highFire = self.model:GetHighFireId()
        if id == lowFire or id == highFire then
            self:CreateIcon(lowFire)
            self:SetLowBtnState(lowFire)
            self:CreateIcon(highFire)
            self:SetHighBtnState(highFire)
        end
    end
    self.gevents[#self.gevents + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function call_back(id)
        --local lowFire = self.model:GetLowFireId()
        --local highFire = self.model:GetHighFireId()
        --if id == lowFire or id == highFire then
        --    local TopTransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Top)
        --    UIEffect(TopTransform, 30005)
        --end
    end
    self.gevents[#self.gevents + 1] = GlobalEvent:AddListener(GoodsEvent.UseItemSuccess, call_back)



    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.PartyInfo,handler(self,self.PartyInfo))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.PartyHot,handler(self,self.PartyHot))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.PartyFetch,handler(self,self.PartyFetch))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.PartyExp,handler(self,self.PartyExp))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.WeddingNotice,handler(self,self.WeddingNotice))


end

function WeddingDungeonPanel:WeddingNotice(data)
    local info = data.wedding
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    for i, v in pairs(info.couple) do
        if v.id == role.id then  --自己的婚礼
            SetVisible(self.invBtn,true)
            self.isMyWedding = true
            return
        end
    end
    self.isMyWedding = false
    SetVisible(self.invBtn,false)
end

function WeddingDungeonPanel:PartyInfo(data)
    self.data = data
    local endTime = self.data.etime
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), endTime)
    if timeTab then
        self:StopSchedule()
        self.Schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
        self:StartCountDown();
    end

    self:RequestExp();
    if self.expSchedules then
        GlobalSchedule:Stop(self.expSchedules);
    end
    self.expSchedules = GlobalSchedule.StartFun(handler(self, self.RequestExp), 10, -1);
    self:CreateReward()
    self:UpdateInfo()
    self:SetHot(self.data.hot)

    --local lowFire = self.model:GetLowFireId()
    --local highFire = self.model:GetHighFireId()
    --self:CreateIcon(lowFire)
    --self:CreateIcon(highFire)
    --self:SetLowBtnState(lowFire)
    --self:SetHighBtnState(highFire)
end

function WeddingDungeonPanel:PartyExp(data)
    --print2("经验返回")
    --print2(data)
    --dump(data)
    --print2(data.exp)
    local exp = GetShowNumber(tonumber(data.exp))
    self.expTex.text = string.format("EXP earned: <color=#5BD022>%s</color>",exp)
end

function WeddingDungeonPanel:RequestExp()
    print2("请求经验信息")
    MarryController:GetInstance():RequsetPartyExp()
end

function WeddingDungeonPanel:StartCountDown()
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.data.etime)
    local timestr = ""
    if timeTab then
        timeTab.min = timeTab.min or 0;
        timeTab.hour = timeTab.hour or 0;
        --if timeTab.hour then
        --    timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
        --end
        if timeTab.min then
            timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
        end
        if timeTab.sec then
            timestr = timestr .. string.format("%02d", timeTab.sec);
        end
        self.endTitleTxt.text = timestr
    else
        self:StopSchedule()
        Notify.ShowText("The wedding is over")
    end
end

function WeddingDungeonPanel:StopSchedule()
    if self.Schedule then
        GlobalSchedule:Stop(self.Schedule);
    end
end

function WeddingDungeonPanel:UpdateInfo()
    self.cachefood = self.data.food
    local exp = GetShowNumber(tonumber(self.data.exp))
    self.expTex.text = string.format("EXP earned: <color=#5BD022>%s</color>",exp)
    self.foodTex.text = string.format("Taste Delicacy: <color=#5BD022>%s/%s</color>",self.data.food,self.model:GetFoodLimit())
    self.xiTex.text = string.format("Falling Joy: <color=#5BD022>%s</color>","Not refreshed")
    if self.data.refresh == true then
        self.xiTex.text = string.format("Falling Joy: <color=#5BD022>%s</color>","Refreshed")
    end
end

function WeddingDungeonPanel:CreateReward()
    local cfg = table.pairsByKey(Config.db_marriage_hot)
    for i, v in cfg do
        local item =  self.rewards[i]
        if not item then
            item = WeddingDungeonReward(self.WeddingDungeonReward.gameObject,self.rewardParent,"UI")
            self.rewards[i] = item
        end
        item:SetData(v)
    end

end
--热度更新
function WeddingDungeonPanel:PartyHot(data)
    self:SetHot(data.hot)
end

function WeddingDungeonPanel:SetHot(hot)
    local curHot = hot
    local maxHot = self.model:GetHotLimit()
    self.hotTex.text = curHot
    self.heat_slader.fillAmount = curHot / maxHot
    self.slider.value = curHot / maxHot
    for i, v in pairs(self.rewards) do
        v:SetState()
    end
end

function WeddingDungeonPanel:PartyFetch(data)
    --self:SetRewardPro(data.fetch)
    print2("领取奖励")
    for i, v in pairs(self.rewards) do
        v:SetState()
    end
end

function WeddingDungeonPanel:CreateIcon(id)
    if self.itemicon[id] then
        self.itemicon[id]:destroy()
        self.itemicon[id] = nil
    end

    
    if self.itemicon[id] == nil then
        self.itemicon[id] = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = id
    param["num"] = BagModel:GetInstance():GetItemNumByItemID(id)
    param["bind"] = 1
    param["can_click"] = true
    param["show_num"] = true
    self.itemicon[id]:SetIcon(param)
end

function WeddingDungeonPanel:SetLowBtnState(id)
    local num =BagModel:GetInstance():GetItemNumByItemID(id)
    if num > 0 then
        self.lowState = 1
        self.lowBtnTex.text = "Use"
        self.red1:SetRedDotParam(true)
        lua_resMgr:SetImageTexture(self, self.lowBtnImg, "common_image", "btn_yellow_3", true, nil, false)
    else
        self.lowState = 0
        self.lowBtnTex.text = "Buy"
        self.red1:SetRedDotParam(false)
        lua_resMgr:SetImageTexture(self, self.lowBtnImg, "common_image", "btn_blue_3", true, nil, false)
    end

end



function WeddingDungeonPanel:SetHighBtnState(id)
    local num = BagModel:GetInstance():GetItemNumByItemID(id)
    if num > 0 then
        self.highState = 1
        self.highBtnTex.text = "Use"
        self.red2:SetRedDotParam(true)
        lua_resMgr:SetImageTexture(self, self.highBtnImg, "common_image", "btn_yellow_3", true, nil, false)
    else
        self.highState = 0
        self.highBtnTex.text = "Buy"
        self.red2:SetRedDotParam(false)
        lua_resMgr:SetImageTexture(self, self.highBtnImg, "common_image", "btn_blue_3", true, nil, false)
    end

end

