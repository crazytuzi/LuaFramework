NewYearManager = NewYearManager or BaseClass(BaseManager)

NewYearManager.SYSTEM_ID = 334
NewYearManager.LUCKEY_CHEST_ID = 565

function NewYearManager:__init()
    if NewYearManager.Instance ~= nil then
        Log.Error("不能重复实例化")
        return
    end

    NewYearManager.Instance = self
    self.model = NewYearModel.New()

    self.redPointEvent = EventLib.New()

    self.redPointEvent:AddListener(function() self:ShowMainUIRed() end)
end

function NewYearManager:__delete()
end

function NewYearManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function NewYearManager:OpenExchange()
    self.model:OpenExchange()
end

function NewYearManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(NewYearManager.SYSTEM_ID)

    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear] == nil then
        return
    end

    local iconData = DataSystem.data_daily_icon[NewYearManager.SYSTEM_ID]
    if self.activeIconData == nil then
        self.activeIconData = AtiveIconData.New()
    end
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        local count = (CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear] or {}).count or 0
        if count == 1 and CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear][CampaignEumn.NewYearType.Exchange] ~= nil then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.newyear_exchange)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.newyearwindow, { 1, 1 })
        end
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)

    self:CheckRedPoint()
    self:ShowMainUIRed()
end

function NewYearManager:CheckRedPoint()
    self.redPointDic = self.redPointDic or {}
    local tab = {}
    for k,v in pairs(self.redPointDic) do
        if v ~= nil then table.insert(tab, k) end
    end
    for _,v in pairs(tab) do
        self.redPointDic[v] = nil
    end
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear] ~= nil then
        for k,main in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear]) do
            if k ~= "count" then
                for _,v in pairs(main.sub) do
                    if v ~= nil and v.status == CampaignEumn.Status.Finish then
                        self.redPointDic[v.id] = true
                    else
                        self.redPointDic[v.id] = false
                    end
                end
            end
        end
    end
    self.redPointEvent:Fire()
end

function NewYearManager:CheckLuckeyChestRedPoint()
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear] ~= nil then
        local count = BackpackManager.Instance:GetItemCount(LuckeyChestWindow.ItemId)
        self.redPointDic[NewYearManager.LUCKEY_CHEST_ID] = count > 0
        self.redPointEvent:Fire()
    end
end

function NewYearManager:ShowMainUIRed()
    local red = false
    for _,v in pairs(self.redPointDic or {}) do
        red = red or (v == true)
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(NewYearManager.SYSTEM_ID, red)
    end
end

