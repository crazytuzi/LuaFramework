ChildBirthManager = ChildBirthManager or BaseClass(BaseManager)

function ChildBirthManager:__init()
    if ChildBirthManager.Instance ~= nil then
        Debug.Error("不能重复实例化 ChildBirthManager")
        return
    end
    ChildBirthManager.Instance = self
    self.model = ChildBirthModel.New()

    self.onFlowerCountEvent = EventLib.New()
    self.onHundredEvent = EventLib.New()
    self.onMsgEvent = EventLib.New()
    self.onCheckRed = EventLib.New()
    self.onUpdateTower = EventLib.New()

    self.redPointDic = {}

    self:InitHandler()
end

function ChildBirthManager:__delete()
end

function ChildBirthManager:InitHandler()
    self:AddNetHandler(17821, self.on17821)
    self:AddNetHandler(17822, self.on17822)
    self:AddNetHandler(17823, self.on17823)
    self:AddNetHandler(17824, self.on17824)
    self:AddNetHandler(17825, self.on17825)
    self:AddNetHandler(17826, self.on17826)
    self:AddNetHandler(17827, self.on17827)

    self.onCheckRed:AddListener(function() self:CheckMainUI() end)
end

function ChildBirthManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(325)

    -- BaseUtils.dump(CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth], "<color='#00ff00'>ChildBirth</color>")

    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth] == nil then
        if self.activeIconData ~= nil then
            self.activeIconData:DeleteMe()
            self.activeIconData = nil
        end
        return
    end

    if self.activeIconData == nil then
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[325]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        self.activeIconData.clickCallBack = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_birth_window)
        end
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)

    self:CheckRedPoint()
end

function ChildBirthManager:CheckRedPoint()
    self.redPointDic[395] = (((self.model.flowerData or {}).count or 0) >= 63)

    self.onCheckRed:Fire()
end

function ChildBirthManager:CheckMainUI()
    local red = false
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth] ~= nil then
        for k,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth]) do
            if k ~= "count" then
                red = red or (self.redPointDic[v.sub[1].id] == true)
            end
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(325, red)
    end
end

function ChildBirthManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function ChildBirthManager:OpenSubWindow(args)
    self.model:OpenSubWindow(args)
end

function ChildBirthManager:OpenShop(args)
    self.model:OpenShop(args)
end

function ChildBirthManager:send17821()
    Connection.Instance:send(17821, {})
end

function ChildBirthManager:on17821(data)
    self.model.flowerData = self.model.flowerData or {}
    self.model.flowerData.count = data.count

    self.onFlowerCountEvent:Fire(data.count)
    SummerCarnivalManager.Instance:CheckRedPoint()
    self:CheckRedPoint()

end

function ChildBirthManager:send17822()
    Connection.Instance:send(17822, {})
end

function ChildBirthManager:on17822(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ChildBirthManager:send17823(count)
    Connection.Instance:send(17823, {count = count})
end

function ChildBirthManager:on17823(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ChildBirthManager:RequestInitData()
    --self:send17821()
    self:send17824()
    self:send17827()
end

function ChildBirthManager:send17824()
    Connection.Instance:send(17824, {})
end

function ChildBirthManager:on17824(data)
    --BaseUtils.dump(data,"，再抽奖励数据")
    self.model.currentFloor = data.floor
    self.model.rewardCount = data.times
    --self.model.next_times = data.next_times
    self.model.rewardList = data.rewards
    self.onUpdateTower:Fire()
end

function ChildBirthManager:send17825(times)
    Connection.Instance:send(17825, {times = times})
end

function ChildBirthManager:on17825(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>on17825</color>")
    self.onHundredEvent:Fire(data.list)
end

function ChildBirthManager:send17826()
    Connection.Instance:send(17826, {})
end

function ChildBirthManager:on17826(data)
    -- BaseUtils.dump(data, "<color='#ffff00'>on17826</color>")
    self.onMsgEvent:Fire(data.msg)
end

function ChildBirthManager:send17827()
    -- print("<color='#ff0000'>send17827</color>")
    Connection.Instance:send(17827, {})
end

function ChildBirthManager:on17827(data)
    -- BaseUtils.dump(data, "<color='#ff0000'>on17827</color>")
    self.model.history = data.list
end
