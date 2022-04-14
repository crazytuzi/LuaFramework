---
--- Created by R2D2.
--- DateTime: 2019/4/4 17:05
---
PetItemView = PetItemView or class("PetItemView", Node)
local this = PetItemView

function PetItemView:ctor(obj, data)
    self.transform = obj.transform
    self.data = data

    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    self.abName = "pet"
    self.imageAb = "pet_image"



    self.pet_equip_model_events = {}
    self.bag_model_events = {}

    self:InitUI()
    self:AddEvent()
    self:RefreshView()
end

function PetItemView:SetCallBack(callback)
    self.CallBack = callback
end

function PetItemView:dctor()
    if (self.redPoint) then
        self.redPoint:destroy()
        self.redPoint = nil
    end

    if(self.epImgList) then
        for _, value in pairs(self.epImgList) do
            value = nil
        end
        self.epImgList = nil
    end

    for _, event_id in pairs(self.role_events) do
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(event_id)
    end
    self.role_events = nil
    GlobalEvent:RemoveTabListener(self.events)
    self.events = nil
    
    PetEquipModel.GetInstance():RemoveTabListener(self.pet_equip_model_events)
    self.pet_equip_model_events = nil

    BagModel.GetInstance():RemoveTabListener(self.bag_model_events)
    self.bag_model_events = nil

    self:StopSchedule()
end

function PetItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Bg", "Icon", "Mask", "Frame", "State", "EP1", "EP2", "EP3", "EP4", "RankText",
                   "NoEvolution", "HadInBag", "CountDown" }
    self:GetChildren(self.nodes)

    self.bgImg = GetImage(self.Bg)
    self.iconImg = GetImage(self.Icon)
    self.maskImg = GetImage(self.Mask)
    self.frameImg = GetImage(self.Frame)
    self.stateImg = GetImage(self.State)
    self.rankTxt = GetText(self.RankText)
    self.rankTxtOutline = self.RankText:GetComponent('Outline')
    self.noEvolutionImg = GetImage(self.NoEvolution)
    self.hadInBagImg = GetImage(self.HadInBag)
    self.countDownText = GetText(self.CountDown)

    self.epImgList = {}
    table.insert(self.epImgList, GetImage(self.EP4))
    table.insert(self.epImgList, GetImage(self.EP3))
    table.insert(self.epImgList, GetImage(self.EP2))
    table.insert(self.epImgList, GetImage(self.EP1))

end

function PetItemView:SetData(data)
    --self.tempData = self.data
    self.data = data
    self:RefreshView()
end

function PetItemView:RefreshView()

    --if(self.tempData) then
    --    self.tempData = nil
    --else
    lua_resMgr:SetImageTexture(self, self.iconImg, self.imageAb, self.data.Config.pic, true)
    lua_resMgr:SetImageTexture(self, self.frameImg, self.imageAb, "Q_Frame_" .. self.data.Config.quality, true)
    lua_resMgr:SetImageTexture(self, self.bgImg, self.imageAb, "Q_Bg_" .. self.data.Config.quality, true)
    --SetVisible(self.frameImg, false)
    --lua_resMgr:SetImageTexture(self,self.bgImg,"common_image","com_icon_bg_" .. self.data.Config.quality,true)
    if (self.data.Config.type == 2) then
        self.rankTxt.text = ConfigLanguage.Pet.ActivityType
    else
        self.rankTxt.text = "T" .. self.data.Config.order_show
    end
    --end

    if (self.data.IsActive) then
        SetOutLineColor(self.rankTxtOutline, 200, 80, 30, 255)
        lua_resMgr:SetImageTexture(self, self.stateImg, self.imageAb, self.data.IsFighting and "Txt_Battle" or "Txt_Assist")
        self:ActiveStyle(self.data.Config.evolution, self.data.Data.extra)

        self:CheckTimeLimit()
    else
        SetOutLineColor(self.rankTxtOutline, 80, 80, 80, 255)
        if self.data.HasInBag then
            SetVisible(self.stateImg, false)
        else
            lua_resMgr:SetImageTexture(self, self.stateImg, self.imageAb, "Txt_Inactive", true)
        end
        self:InactiveStyle(self.data.Config.evolution)

        self.countDownText.text = ""
    end

    --请求宠物装备数据
    PetController.GetInstance():RequestPetEquips(self.data.Config.order)

    self:RefreshPoint()
end

function PetItemView:RefreshState(fightOrder)
    if (self.data.IsActive) then
        self.data.IsFighting = self.data.Config.order == fightOrder
        lua_resMgr:SetImageTexture(self, self.stateImg, self.imageAb, self.data.IsFighting and "Txt_Battle" or "Txt_Assist")
    end
end

function PetItemView:CheckTimeLimit()
    local endTime = self.data.Data.etime
    if (endTime == 0) then
        self.countDownText.text = ""
        return
    end

    local serverTime = TimeManager.Instance:GetServerTime()
    if (endTime <= serverTime) then
        self.countDownText.text = ConfigLanguage.Pet.Overdue
        SetColor(self.countDownText, 255, 0, 0)
        return
    end

    self:StopSchedule()
    self:StartCountDown()
    SetColor(self.countDownText, 0, 255, 100)

    self.scheduleId = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
end

function PetItemView:StopSchedule()
    if self.scheduleId then
        GlobalSchedule:Stop(self.scheduleId)
        self.scheduleId = nil
    end
end

function PetItemView:StartCountDown()

    local serverTime = TimeManager.Instance:GetServerTime()
    local endTime = self.data.Data.etime
    local timeTab = TimeManager:GetLastTimeData(serverTime, endTime)
    local hourStr = ""
    local minStr = ""
    local secStr = ""

    if timeTab then
        hourStr = string.format("%02d", timeTab.hour or 0)
        minStr = string.format("%02d", timeTab.min or 0)
        secStr = string.format("%02d", timeTab.sec or 0)
        self.countDownText.text = string.format("%s:%s:%s", hourStr, minStr, secStr)
    else
        self:StopSchedule()
        self:CheckTimeLimit()
    end
end

function PetItemView:ActiveStyle(count, point)
    self.maskImg.enabled = false
    --self.stateImg.enabled = true
    self:SetEvolutionPoint(count, point)
    ShaderManager.GetInstance():SetImageNormal(self.iconImg)
end

function PetItemView:InactiveStyle(count)
    self.maskImg.enabled = true
    --self.stateImg.enabled = false
    --self.rankTxt.text = ""
    self:SetEvolutionPoint(count, 0)
    ShaderManager.GetInstance():SetImageGray(self.iconImg)
end

function PetItemView:RefreshPoint()

    local show = false
    local isOverdue = self.data:CheckOverdue()
    if (not self.data.IsActive or isOverdue) then
        show = PetModel:GetInstance():HasBagPet(self.data.Config.order)
        self.hadInBagImg.enabled = show
    else
        local hasBetter = PetModel:GetInstance():HasBetter(self.data.Config.order, self.data.Data.score)
        local _, hasTrain, hasCross = PetModel:GetInstance():HasTrainOrCross(self.data)
        local hasEvolution = PetModel:GetInstance():HasEvolution(self.data)
        local is_can_stren = PetEquipModel.GetInstance():CheckStrenOrUporderReddotByTargetPet(self.data.Config.order)
        local is_can_puton = PetEquipModel.GetInstance():CheckCanPutonReddotByTarget(self.data.Config.quality)
        show = hasBetter or hasTrain or hasCross or hasEvolution or is_can_stren or is_can_puton

        self.hadInBagImg.enabled = false
    end
    self:SetRedPoint(show)
end

function PetItemView:SetRedPoint(isShow)
    if self.redPoint == nil then
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(64, 34)
    end

    self.redPoint:SetRedDotParam(isShow)
end

function PetItemView:SetEvolutionPoint(count, point)

    self.noEvolutionImg.enabled = count == 0

    for i, v in ipairs(self.epImgList) do
        if (i <= point) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Little");
        elseif (i <= count) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Little_Gray");
        else
            v.enabled = false
        end
    end
end

function PetItemView:AddEvent()
    self.role_events = self.role_events or {}
    self.events = self.events or {}
    self.pet_equip_model_events =  self.pet_equip_model_events or{}

    local function call_back()
        if (self.CallBack) then
            self.CallBack(self)
        end
    end
    AddClickEvent(self.Bg.gameObject, call_back)

    local function call_back( )
        self:RefreshPoint()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
    self.role_events[#self.role_events + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("money", call_back)
    self.role_events[#self.role_events + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("PetEquipExp", call_back)

    local function call_back(pet_id,equips)
        if pet_id ~=  self.data.Config.order then
            return
        end
        --logError("PetItemView宠物装备可强化红点检查，pet_id"..pet_id)
        self:RefreshPoint()
    end
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = PetEquipModel.GetInstance():AddListener(PetEquipEvent.HandlePetEquips, call_back)

    local function call_back(bag_id)
        --宠物装备背包发生变化时刷新下红点
        if bag_id ~= BagModel.PetEquip then
            return
        end
       
        self:RefreshPoint()
    end
    self.bag_model_events[#self.bag_model_events + 1] = BagModel.GetInstance():AddListener(BagEvent.LoadItemByBagId,call_back )
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.AddItems,call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems,call_back)

end