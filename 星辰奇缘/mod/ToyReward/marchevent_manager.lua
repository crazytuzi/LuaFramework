MarchEventManager = MarchEventManager or BaseClass(BaseManager)

function MarchEventManager:__init()
	if MarchEventManager.Instance ~= nil then
		return
	end

	MarchEventManager.Instance = self
	self.model = MarchEventModel.New()

	self.redPointDic = {}
	self.onUpdateRedPoint = EventLib.New()
	self.redPointCheck = function() self:CheckRedPoint() end
    EventMgr.Instance:AddListener(event_name.role_asset_change,self.redPointCheck)
    EventMgr.Instance:AddListener(event_name.get_campaign_reward_success,self.redPointCheck)
    OpenBetaManager.Instance.onTurnTime:AddListener(self.redPointCheck)
end


function MarchEventManager:CheckRedPoint()
	-- 检查抽奖的红点
	local data = CampaignManager.Instance.campaignTab[742]
	local isGetReward = nil
	if data ~= nil then
        isGetReward = data.status
    end

    if isGetReward == 1 then
       self.redPointDic[1] = true
    else
    	self.redPointDic[1] = false
    end

    self.redPointDic[3] = CampaignRedPointManager.Instance:IsCheckToyReward()

	self:CheckTabRedPoint()
    self:CheckMainUIIconRedPoint()
	self.onUpdateRedPoint:Fire()
end

function MarchEventManager:CheckTabRedPoint()
	if self.model ~= nil then
		if self.model.marchWin ~= nil then
		    self.model.marchWin:CheckRedPoint()
		end
	end
end

function MarchEventManager:CheckMainUIIconRedPoint()
	if MainUIManager.Instance.MainUIIconView ~= nil then
		MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(DataCampaign.data_camp_ico[33].ico_id,self:IsNeedShowRedPoint())
	end
end


function MarchEventManager:IsNeedShowRedPoint()
	local bool = false
	local openLevel = self.model:CheckTabShow()
	for k,v in pairs(self.redPointDic) do
         bool = bool or (v == true and openLevel[k] ~= false)
    end

    return bool
end


function MarchEventManager:OpenWindow(args)
	self:CheckRedPoint()
	self.model:OpenWindow(args)
end


function MarchEventManager:SetIcon()

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
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marchevent_window) end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    self:CheckRedPoint()
end

function MarchEventManager:__delete()
	self.model:DeleteMe()
end


function MarchEventManager:CalculateTime()
    local isStart = false
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
     -- local time = DataCampaign.data_list[3].day_time[1]
    local time = DataCampTurn.data_turnplate[3].day_time[1]
    beginTime = tonumber(os.time{year = y, month = m, day = d, hour = time[1], min = time[2], sec = time[3]})
    endTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})


    if baseTime <= endTime and baseTime >= beginTime then
        isStart = true
    end

    return isStart

end
