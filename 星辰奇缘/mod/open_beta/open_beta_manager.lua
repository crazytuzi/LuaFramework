-- @author 黄耀聪
-- @date 2016年8月8日
-- 公测活动

TurnState = TurnState or {}

TurnState.State = {
    NoBegin = 0,
    Active = 1,
    Ended = 2,
}

OpenBetaManager = OpenBetaManager or BaseClass(BaseManager)

function OpenBetaManager:__init()
    if OpenBetaManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    OpenBetaManager.Instance = self
    self.model = OpenBetaModel.New()

    self.onTickTime = EventLib.New()
    self.onCheckRed = EventLib.New()
    self.onTurnResult = EventLib.New()
    self.onTurnTime = EventLib.New()
    self.onUnFrozen = EventLib.New()
	self.onShowItem = EventLib.New()


    self.turnState = {}

    self.redPointDic = {}
    self.hasOpen = {}

    self:InitHandler()
end

function OpenBetaManager:__delete()
end

function OpenBetaManager:InitHandler()
    self:AddNetHandler(14038, self.on14038)
    self:AddNetHandler(14039, self.on14039)
    self:AddNetHandler(14040, self.on14040)
    self:AddNetHandler(14041, self.on14041)

    self.onCheckRed:AddListener(function() self:CheckMainUIRed() end)
    EventMgr.Instance:AddListener(event_name.campaign_change, function() self:CheckRed() end)
end

function OpenBetaManager:OpenWindow(args)
    if CampaignManager.Instance.campaignTab[309] ~= nil or CampaignManager.Instance.campaignTab[310] ~= nil or CampaignManager.Instance.campaignTab[311] ~= nil then
        self.model:OpenWindow(args)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动未开启"))
    end
end

function OpenBetaManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(309)

    -- BaseUtils.dump(CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenBeta], "<color='#00ff00'>CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenBeta]</color>")
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenBeta] == nil then
        return
    end

    if self.activeIconData == nil then self.activeIconData = AtiveIconData.New() end
    local iconData = DataSystem.data_daily_icon[309]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.openbetawindow) end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)

    self:CheckRed()
end

-- 转盘活动，信息
function OpenBetaManager:send14038(type)
  -- print("发送14038")
    Connection.Instance:send(14038, {type = type})
end

function OpenBetaManager:on14038(data)
    --BaseUtils.dump(data, "接收14038")
    local model = self.model
    model.turnplateList = {}
    for _,v in ipairs(data.list) do
        model.turnplateList[v.type] = v
    end
    self.onTurnTime:Fire()
end

-- 转盘活动，转
function OpenBetaManager:send14039(type)
  -- print("发送14039")
    Connection.Instance:send(14039, {type = type})
end

function OpenBetaManager:on14039(data)
    --BaseUtils.dump(data, "接收14039")
    if data.flag == 1 then
        self.onTurnResult:Fire(data.type, data.id)
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
        self.onTurnResult:Fire(data.type, 0)
    end
end

-- 转盘活动，停
function OpenBetaManager:send14040(type)
    Connection.Instance:send(14040, {})
end

function OpenBetaManager:on14040(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.onUnFrozen:Fire(data)
	-- self:ShowGift(data.item_id)
end

function OpenBetaManager:InitData()
    self:send14038()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 3 * 1000, function() self:DoCheckOpen() end)
    end
end

function OpenBetaManager:DoCheckOpen()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))
    local beginTime = nil
    local endTime = nil
    for type,v in pairs(DataCampTurn.data_turnplate) do
        for _,time in ipairs(v.day_time) do
            beginTime = tonumber(os.time{year = y, month = m, day = d, hour = time[1], min = time[2], sec = time[3]})
            endTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})
            if baseTime < beginTime then
                self.turnState[type] = TurnState.State.NoBegin
            elseif baseTime > endTime then
                self.turnState[type] = TurnState.State.Ended
                self.hasOpen[3] = false
            else
                self.turnState[type] = TurnState.State.Active
                break
            end
        end
    end

    local red = self.redPointDic[3]
    self.redPointDic[3] = (((CampaignManager.Instance.campaignTab[311] ~= nil)) and (self.turnState[1] == TurnState.State.Active)) and (self.hasOpen[3] ~= true)
    self.onCheckRed:Fire()
end

function OpenBetaManager:CheckMainUIRed()
    local red = false
    for _,v in pairs(self.redPointDic) do
        red = red or (v == true)
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(309, red)
    end
end

function OpenBetaManager:CheckRed()
    self.redPointDic[1] = (CampaignManager.Instance.campaignTab[309] ~= nil and CampaignManager.Instance.campaignTab[309].status == CampaignEumn.Status.Finish)

    self.onCheckRed:Fire()
end

-- 转盘活动批量转
function OpenBetaManager:send14041(type, num)
  -- print("发送14041")
    Connection.Instance:send(14041, {type = type, num = num})
end

function OpenBetaManager:on14041(data)

    local model = self.model
    model.rewardTenList = {}
    for k,v in ipairs(data.ids) do
        model.rewardTenList[k] = v.id
    end

    --BaseUtils.dump(data, "接收14041")
    if data.flag == 1 then
        self.onTurnResult:Fire(data.type, data.id)
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
        self.onTurnResult:Fire(data.type, 0)
    end
end

function OpenBetaManager:ShowGift(list)
	if #list > 0 then
		if self.giftPreview == nil then
			self.giftPreview = GiftPreview.New(TipsManager.Instance.model.tipsCanvas)
		end
		local tab = {}
		for i,v in ipairs(list) do
			table.insert(tab, {v.item_id, v.num})
		end
		self.giftPreview:Show({text = TI18N("恭喜！获得了以下道具{face_1,18}"), autoMain = true, reward = tab, height = 120, width = 100, column = 5})
	end
end
