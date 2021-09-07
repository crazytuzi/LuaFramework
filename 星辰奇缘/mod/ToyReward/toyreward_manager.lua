ToyRewardManager = ToyRewardManager or BaseClass(BaseManager)

function ToyRewardManager:__init()
	if ToyRewardManager.Instance ~= nil then
		Log.Error("不可重复实例化")
	end

    ToyRewardManager.Instance = self
    self.model = ToyRewardModel.New()
end


function ToyRewardManager:__delete()
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
    end

    self:RemoveHandlers()
end


function ToyRewardManager:OpenWindow()
	if self.model ~= nil then
		self.model:OpenWindow()
    end
end


function ToyRewardManager:SetIcon()

    local systemIconId = DataCampaign.data_camp_ico[33].ico_id
    MainUIManager.Instance:DelAtiveIcon3(systemIconId)

    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.ToyReward] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[systemIconId]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.toyreward_window) end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end

