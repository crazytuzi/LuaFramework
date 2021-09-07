-- @author 黄耀聪
-- @date 2016年6月13日

MergeServerManager = MergeServerManager or BaseClass(BaseManager)

function MergeServerManager:__init()
    if MergeServerManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    MergeServerManager.Instance = self
	self.model = MergeServerModel.New()

	self.onUpdateRed = EventLib.New()
    self:InitHandler()
end

function MergeServerManager:__delete()
end

function MergeServerManager:InitHandler()
    EventMgr.Instance:AddListener(event_name.campaign_change, function() self:CheckRedPoint() end)
end

function MergeServerManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function MergeServerManager:SetIcon()
    local systemIcon = DataCampaign.data_camp_ico[7]
    MainUIManager.Instance:DelAtiveIcon3(306)

    local base_time = BaseUtils.BASE_TIME
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.MergeServer ] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[306]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.merge_server) end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    self:CheckRedPoint()
end

function MergeServerManager:CheckRedPoint()
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.MergeServer] == nil then
        return
    end

    local bool = false
    for k,main in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.MergeServer]) do
        if k ~= "count" then
            for i,proto in pairs(main.sub) do
                if DataCampaign.data_list[proto.id].index ~= CampaignEumn.MergeServerType.Endear and DataCampaign.data_list[proto.id].index ~= CampaignEumn.MergeServerType.Gift then
                    CampaignManager.Instance.redPointDic[proto.id] = (proto.status == CampaignEumn.Status.Finish)
                    bool = bool or CampaignManager.Instance.redPointDic[proto.id]
                end
            end
        end
    end

    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(306, bool)
    end

    self.onUpdateRed:Fire()
end

