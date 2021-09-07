RebateRewardManager = RebateRewardManager or BaseClass(BaseManager)

function RebateRewardManager:__init()
	if RebateRewardManager.Instance ~= nil then
		return
	end

	RebateRewardManager.Instance = self
	self.model = RebateRewardModel.New()
    self.OnUpdateRedPoint = EventLib.New()
    self.timer = nil

    self.redPointDic = {}
    self.isInit = false
    EventMgr.Instance:AddListener(event_name.campaign_change,function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.sleepmanager_onresume,function() self:CheckRedPoint() end)
    -- event_name.sleepmanager_onresume
end

function RebateRewardManager:OpenWindow(args)
	self.model:OpenWindow(args)
end

function RebateRewardManager:RequestInitData()
    if self.timer == nil then
        self.timer = LuaTimer.Add(1000,2000,function() self:CheckTimer() end)
    end
end
function RebateRewardManager:OpenMainWindow(args)
	self.model:OpenMainWindow(args)
end

function RebateRewardManager:SetIcon()
	local systemIconId = DataCampaign.data_camp_ico[40].ico_id
    MainUIManager.Instance:DelAtiveIcon3(systemIconId)

    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.RebateReward] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[systemIconId]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    local temdate = CampaignManager.Instance.campaignTree[CampaignEumn.Type.RebateReward]
    local ttdata ={}
    local length = 1
    for k,v in pairs(temdate) do
        ttdata[length] = v
        length = length + 1
    end
    if #ttdata <=2 and (ttdata[1].index == CampaignEumn.RebateReward.RebateRewarded) then
        self.activeIconData.clickCallBack = function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rebatereward_window) end
    else
        self.activeIconData.clickCallBack = function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rebatereward_main_window) end
    end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end


function RebateRewardManager:__delete()
	self.model:DeleteMe()
end


function RebateRewardManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        self.isInit = true
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(341,self:IsNeedShowRedPoint())
    end
end

function RebateRewardManager:CheckTimer()
    if self.isInit == true then
         if self.timer ~= nil then
                LuaTimer.Delete(self.timer)
                self.timer = 0
        end

        self.isInit = false
    end
    self:CheckRedPoint()
end


function RebateRewardManager:IsNeedShowRedPoint()
    local bool = false
    -- local openLevel = self.model:CheckTabShow()
    for k,v in pairs(self.redPointDic) do
        bool = bool or v
    end

    return bool
end

function RebateRewardManager:CheckRedPoint()
    local roledata = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,607)
    if self:IsCheckCampaignAcive() == true then
        local temData = DataCampaign.data_list[607]

        local str = PlayerPrefs.GetString(key)


        if str == "init" then
            self.redPointDic[temData.index] = false
        else
            self.redPointDic[temData.index] = true
        end
    else
        local str = PlayerPrefs.GetString(key)
        if str ~= nil then
            PlayerPrefs.DeleteKey(key)
        end
        local temData = DataCampaign.data_list[607]
        self.redPointDic[temData.index] = false
    end
    self.OnUpdateRedPoint:Fire()
    self:CheckMainUIIconRedPoint()
end


function RebateRewardManager:IsCheckCampaignAcive()
    local active = false
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
     -- local time = DataCampaign.data_list[3].day_time[1]
    local time = DataCampaign.data_list[607].cli_start_time[1]
    beginTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})

    time = DataCampaign.data_list[607].cli_end_time[1]
    endTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})


    if baseTime > beginTime and baseTime <endTime then
          active = true
    end

    return active
end



