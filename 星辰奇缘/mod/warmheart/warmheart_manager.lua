--2017/6/12
--zyh
--父亲节活动
WarmHeartManager = WarmHeartManager or BaseClass(BaseManager)

function WarmHeartManager:__init()
	if WarmHeartManager.Instance ~= nil then
		return
	end

	WarmHeartManager.Instance = self
	self.model = WarmHeartModel.New()
    self.OnUpdateRedPoint = EventLib.New()
    self.timer = nil

    self.redPointDic = {}
    self.isInit = false
    self.totalCampaignId = 42
    self.campaignGroup = nil
    -- EventMgr.Instance:AddListener(event_name.campaign_change,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.sleepmanager_onresume,function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.role_asset_change,function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.campaign_change,function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.quest_update,function() self:CheckRedPoint() end)
    -- event_name.sleepmanager_onresume
end

function WarmHeartManager:OpenWindow(args)
	self.model:OpenWindow(args)
end

function WarmHeartManager:RequestInitData()
    -- if self.timer == nil then
    --     self.timer = LuaTimer.Add(1000,2000,function() self:CheckTimer() end)
    -- end
end
function WarmHeartManager:OpenMainWindow(args)
	self.model:OpenMainWindow(args)
end

function WarmHeartManager:SetIcon()
	local systemIconId = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
    MainUIManager.Instance:DelAtiveIcon3(systemIconId)
    -- print("==================================================================================================================================================================================")
    -- BaseUtils.dump(CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart],"活动数据")
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[systemIconId]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    local temdate = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart]
    local ttdata ={}
    local length = 1
    for k,v in pairs(temdate) do
        ttdata[length] = v
        length = length + 1
    end
    -- if #ttdata <=2 and (ttdata[1].index == CampaignEumn.RebateReward.RebateRewarded) then
    --     self.activeIconData.clickCallBack = function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rebatereward_window) end
    -- else
    --     self.activeIconData.clickCallBack = function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rebatereward_main_window) end
    -- end
    self.activeIconData.clickCallBack = function()
        local count = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart].count
        -- for k,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart]) do
        --     if k ~= "count" then
        --         count = count + 1
        --     end
        -- end
        if count == 1 then
            if CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart][CampaignEumn.WarmHeart.CoinActive] ~= nil then
                local datalist = {}
                local lev = RoleManager.Instance.RoleData.lev
                for i,v in pairs(ShopManager.Instance.model.datalist[2][19]) do
                    table.insert(datalist, v)
                end
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("暖心兑换"), extString = "{assets_2,90041}可在父亲节活动中获得"})
            elseif CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart][CampaignEumn.WarmHeart.QuestKing] ~= nil then
                QuestKingManager.Instance.model.campId = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart][CampaignEumn.WarmHeart.QuestKing].sub[1].id
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.quest_king_progress)
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warmheart_main_window)
            end
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warmheart_main_window)
        end
   end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end


function WarmHeartManager:__delete()
	self.model:DeleteMe()
end


function WarmHeartManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        self.isInit = true
        local icon_id = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(icon_id,self:IsNeedShowRedPoint())
    end
end

-- function WarmHeartManager:CheckTimer()
--     if self.isInit == true then
--          if self.timer ~= nil then
--                 LuaTimer.Delete(self.timer)
--                 self.timer = 0
--         end

--         self.isInit = false
--     end
--     self:CheckRedPoint()
-- end


function WarmHeartManager:IsNeedShowRedPoint()
    local bool = false
    -- local openLevel = self.model:CheckTabShow()
    for k,v in pairs(self.redPointDic) do
        bool = bool or v
    end

    return bool
end

function WarmHeartManager:CheckRedPoint()
    local temData = DataCampaign.data_list[645]
    if self:IsCheckRedPointFirstPanel() == true then
        self.redPointDic[temData.index] = true
    else
        self.redPointDic[temData.index] = false
    end

    self.redPointDic[DataCampaign.data_list[657].index] = QuestKingManager.Instance:CheckRed()
    self.OnUpdateRedPoint:Fire()
    self:CheckMainUIIconRedPoint()
end


function WarmHeartManager:IsCheckCampaignAcive()
    -- local active = false
    -- local baseTime = BaseUtils.BASE_TIME
    -- local y = tonumber(os.date("%Y", baseTime))
    -- local m = tonumber(os.date("%m", baseTime))
    -- local d = tonumber(os.date("%d", baseTime))

    -- local beginTime = nil
    -- local endTime = nil
    --  -- local time = DataCampaign.data_list[3].day_time[1]
    -- local time = DataCampaign.data_list[607].cli_start_time[1]
    -- beginTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})

    -- time = DataCampaign.data_list[607].cli_end_time[1]
    -- endTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})


    -- if baseTime > beginTime and baseTime <endTime then
    --       active = true
    -- end

    -- return active
end


function WarmHeartManager:IsCheckRedPointFirstPanel()
    local t = false
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart] ~= nil then

        self.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart][CampaignEumn.WarmHeart.WarmHeart]
        if self.campaignGroup ~= nil then
            for i,v in ipairs(self.campaignGroup.sub) do
                local id = v.id
                local protoData = CampaignManager.Instance.campaignTab[id]
                if protoData.status == CampaignEumn.Status.Finish then
                    t = true
                end
            end
        end
    end

    return t
end



