-- @author 黄耀聪
-- @date 2016年10月14日

NewMoonManager = NewMoonManager or BaseClass(BaseManager)

function NewMoonManager:__init()
    if NewMoonManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    NewMoonManager.Instance = self
    self.model = NewMoonModel.New()

    self.diceUpdateEvent = EventLib.New()
    self.diceMsgEvent = EventLib.New()
    self.diceInfoEvent = EventLib.New()

    self.chargeUpdateEvent = EventLib.New()
    self.onUpdateRedPoint = EventLib.New()

    self:InitHandler()
end

function NewMoonManager:__delete()
end

function NewMoonManager:InitHandler()
    self:AddNetHandler(14087, self.on14087)
    self:AddNetHandler(14088, self.on14088)
    self:AddNetHandler(14089, self.on14089)
    self:AddNetHandler(14090, self.on14090)
    self:AddNetHandler(14091, self.on14091)
    self:AddNetHandler(14092, self.on14092)
    self:AddNetHandler(14093, self.on14093)
    self:AddNetHandler(14094, self.on14094)
end

function NewMoonManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function NewMoonManager:send14087()
    Connection.Instance:send(14087, {})
end

function NewMoonManager:on14087(data)
    -- BaseUtils.dump(data, "on14087")
    self.model.diceData = self.model.diceData or {}

    local diceData = self.model.diceData
    diceData.id = data.id
    diceData.day = data.day
    diceData.roll_times = data.roll_times
    diceData.status = data.status
    diceData.reward = diceData.reward or {}
    for k,_ in pairs(diceData.reward) do
        diceData.reward[k] = nil
    end
    for k,v in pairs(data.reward) do
        diceData.reward[v.reward_id] = v
    end
    diceData.reward_get = diceData.reward_get or {}
    for k,_ in pairs(diceData.reward_get) do
        diceData.reward_get[k] = nil
    end
    for _,v in pairs(data.reward_get) do
        diceData.reward_get[v.reward_id_get] = v
    end
    self:CheckRedPoint()
    SummerGiftManager.Instance:CheckRedPoint()
    self.diceUpdateEvent:Fire()
end

function NewMoonManager:send14088(reward_id)
    Connection.Instance:send(14088, {reward_id = reward_id})
end

function NewMoonManager:on14088(data)
    -- BaseUtils.dump(data, "on14088")
    if data.err_code == 0 then
        NoticeManager.Instance:FloatTipsByString()
    end
end

function NewMoonManager:send14089()
    Connection.Instance:send(14089, {})
end

function NewMoonManager:on14089(data)
    -- BaseUtils.dump(data, "on14089")
    self.diceInfoEvent:Fire(data.err_code == 1, data.val)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NewMoonManager:send14090()
    Connection.Instance:send(14090, {})
end

function NewMoonManager:on14090(data)
    -- BaseUtils.dump(data, "on14090")
    self.model:AddToCircle(data.msg)
    self.diceMsgEvent:Fire(data.msg)
end

function NewMoonManager:RequestInitData()
    self:send14087()
    self:send14091()
    self:send14094()
end

function NewMoonManager:CheckRedPoint()
    local red = false
    if self.model.diceData ~= nil then
        red = (self.model.diceData.status == 1)
        for i,v in ipairs(DataCampLoginRoll.data_reward) do
            local day = v.day
            red = red or (self.model.diceData.roll_times >= day and self.model.diceData.reward_get[i] == nil)
        end
    end
    CampaignManager.Instance.redPointDic[337] = red

    red = false
    if self.model.chargeData ~= nil and self.model.chargeData.reward ~= nil then
        for _,v in ipairs(self.model.chargeData.reward) do
            if v.day_status == 1 then
                red = true
            end
        end
    end
    CampaignManager.Instance.redPointDic[373] = red
    SpringFestivalManager.Instance:SetRed(402, red)

    if MainUIManager.Instance.MainUIIconView ~= nil then
        red = CampaignManager.Instance.redPointDic[337]
        red = red or CampaignManager.Instance.redPointDic[338]
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(315, red)
    end

    self.onUpdateRedPoint:Fire()

    ValentineManager.Instance:CheckRed()
    MayIOUManager.Instance:CheckRed()
end

function NewMoonManager:send14091()
    Connection.Instance:send(14091, {})
end

function NewMoonManager:on14091(data)
    -- BaseUtils.dump(data, "on14091")
    self.model.chargeData = self.model.chargeData or {}

    self.model.chargeData.day_now = data.day_now
    self.model.chargeData.first_time = data.first_time
    self.model.chargeData.reward = self.model.chargeData.reward or {}
    for k,_ in pairs(self.model.chargeData.reward) do
        self.model.chargeData.reward[k] = nil
    end
    for i,v in ipairs(data.reward) do
        self.model.chargeData.reward[v.day_id] = v
    end
    self.chargeUpdateEvent:Fire()
    self:CheckRedPoint()
    SummerGiftManager.Instance:CheckRedPoint()
end

function NewMoonManager:send14092(id)
    Connection.Instance:send(14092, {id = id})
end

function NewMoonManager:on14092(data)
    -- BaseUtils.dump(data, "on14092")
    if data.err_code ~= 1 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
        self.chargeUpdateEvent:Fire()
    end
end

function NewMoonManager:send14093()
    Connection.Instance:send(14093, {})
end

function NewMoonManager:on14093(data)
end

function NewMoonManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(315)

    local base_time = BaseUtils.BASE_TIME

    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewMoon] == nil then
        if self.activeIconData ~= nil then
            self.activeIconData:DeleteMe()
            self.activeIconData = nil
        end
        return
    end

    if self.activeIconData == nil then
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[315]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.new_moon_window, {1, 1}) end
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    self:CheckRedPoint()
end

function NewMoonManager:send14094()
    Connection.Instance:send(14094, {})
end

function NewMoonManager:on14094(data)
    local model = self.model
    for _,v in ipairs(data.pmd_list) do
        model:AddToCircle(v.msg)
    end
end
