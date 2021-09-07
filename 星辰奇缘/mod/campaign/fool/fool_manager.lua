-- @author 黄耀聪
-- @date 2017年3月17日

FoolManager = FoolManager or BaseClass(BaseManager)

function FoolManager:__init()
    if FoolManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    FoolManager.Instance = self

    self.model = FoolModel.New()

    self:InitHandler()
end

function FoolManager:__delete()
end

function FoolManager:InitHandler()
end

function FoolManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function FoolManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(325)
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        return
    end
    local systemIcon = DataCampaign.data_camp_ico[CampaignEumn.Type.Fool]
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Fool] == nil then
        return
    end
    if self.activeIconData == nil then
        self.activeIconData = AtiveIconData.New()
    end
    local iconData = DataSystem.data_daily_icon[325]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        local count = 0
        for k,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.Fool]) do
            if k ~= "count" then
                count = count + 1
            end
        end
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.foolwindow)
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end
