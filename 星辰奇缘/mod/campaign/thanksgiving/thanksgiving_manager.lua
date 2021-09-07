ThanksgivingManager = ThanksgivingManager or BaseClass(BaseManager)

function ThanksgivingManager:__init()
    if ThanksgivingManager.Instance ~= nil then
        Log.Error("不能重复实例化 ThanksgivingManager")
        return
    end
    ThanksgivingManager.Instance = self
    self.model = ThanksgivingModel.New()

    self.cardEvent = EventLib.New()
    self.checkRed = EventLib.New()

    self:InitHandler()
end

function ThanksgivingManager:InitHandler()
    self:AddNetHandler(14047, self.on14047)
    self:AddNetHandler(14048, self.on14048)
    self:AddNetHandler(14049, self.on14049)
end

function ThanksgivingManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(319)
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        return
    end
    local systemIcon = DataCampaign.data_camp_ico[CampaignEumn.Type.Thanksgiving]
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving] == nil then
        return
    end
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[319]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        local count = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving].count
        if count == 1 and CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving][CampaignEumn.ThanksgivingType.Exchange] ~= nil then
            self.model:OpenExchange()
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.thanksgiving)
         end
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)

    self:CheckRed()
end

function ThanksgivingManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function ThanksgivingManager:RequestInitData()
    self.model.cardData = nil
    self.model.receiveNum = 0

    NewMoonManager.Instance:send14091()
    self:send14047()
end

-- 请求活动牌面
function ThanksgivingManager:send14047()
    Connection.Instance:send(14047, {})
end

function ThanksgivingManager:on14047(data)
    local model = self.model

    model.receiveNum = 0
    model.baseIdList = {}
    model.allOpen = true
    model.notOpen = true
    local tab = {}

    for k,v in pairs(data.card_list) do
        if v.flag ~= 0 then
            model.receiveNum = model.receiveNum + 1
            tab[v.flag] = v
        end
        model.allOpen = model.allOpen and (v.flag ~= 0)
        model.notOpen = model.notOpen and (v.flag == 0)
        table.insert(model.baseIdList, v)
    end

    if model.cardData == nil then       -- 登录请求
        model.cardData = model.cardData or {}
        if model.notOpen == true then
            model.cardData.card_list = model.baseIdList
        else
            model.cardData.card_list = tab
        end
        self.cardEvent:Fire(false)
    else
        if #model.cardData.temp_list == 0 and model.notOpen == true then      -- 执行了派牌
            model.cardData.card_list = model.baseIdList
            self.cardEvent:Fire(true)
        elseif #data.card_list == 0 then                                    -- 可认为是0点更新
            model.cardData.card_list = tab
            self.cardEvent:Fire(false)
        else
            model.cardData.card_list = tab
            self.cardEvent:Fire(false)
        end
    end
    model.cardData.temp_list = data.card_list

    self:CheckRed()
end

-- 请求发牌
function ThanksgivingManager:send14048()
    Connection.Instance:send(14048, {})
end

function ThanksgivingManager:on14048(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 请求活动翻牌
function ThanksgivingManager:send14049(order)
    Connection.Instance:send(14049, {order = order})
end

function ThanksgivingManager:on14049(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ThanksgivingManager:CheckRed()
    local model = self.model
    local campaignMgr = CampaignManager.Instance

    campaignMgr.redPointDic[367] = false
    local activity = (AgendaManager.Instance.activitypoint or {}).activity or 0
    if model.receiveNum == 0 then
        if activity >= 30 then
            campaignMgr.redPointDic[367] = true and (campaignMgr.campaignTab[367] ~= nil)
        end
    elseif model.receiveNum == 1 then
        if activity >= 80 then
            campaignMgr.redPointDic[367] = true and (campaignMgr.campaignTab[367] ~= nil)
        end
    end

    self.checkRed:Fire()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(319, campaignMgr.redPointDic[367])
    end
end

