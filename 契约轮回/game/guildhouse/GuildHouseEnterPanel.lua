GuildHouseEnterPanel = GuildHouseEnterPanel or class("GuildHouseEnterPanel", BasePanel)
local GuildHouseEnterPanel = GuildHouseEnterPanel

function GuildHouseEnterPanel:ctor()
    self.abName = "guild_house"
    self.assetName = "GuildHouseEnterPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.cd_time = 10

    --self.model = 2222222222222end:GetInstance()
end

function GuildHouseEnterPanel:dctor()
end

function GuildHouseEnterPanel:Open()
    GuildHouseEnterPanel.super.Open(self)
end

function GuildHouseEnterPanel:LoadCallBack()
    self.nodes = {
        "des", "btn_close", "btn_enter",
    }
    self:GetChildren(self.nodes)

    self.des_txt = GetText(self.des)
    self:AddEvent()
end

function GuildHouseEnterPanel:AddEvent()
    local function call_back(target, x, y)
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject, call_back)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(FactionEvent.Faction_EnterGuildHouseEvent)
        self:Close()
    end
    AddClickEvent(self.btn_enter.gameObject, call_back)
end

function GuildHouseEnterPanel:OpenCallBack()
    self:UpdateView()
end

function GuildHouseEnterPanel:UpdateView()
    self.des_txt.text = HelpConfig.GuildHouse.EnterTips
    self:InitCD()
end

function GuildHouseEnterPanel:InitCD()
    if self.CDT then
        return
    end
    local param = {}
    param.formatText = "Join now （%d sec）"
    param.nodes = { "cancel_text", }
    self.CDT = CountDownText(self.btn_enter, param)
    local function call_back()
        self.CDT:StopSchedule()
        SetVisible(self.CDT, false)
        GlobalEvent:Brocast(FactionEvent.Faction_EnterGuildHouseEvent)
        self:Close()
    end
    self.CDT:StartSechudle(self.cd_time+ os.time(), call_back)
end

function GuildHouseEnterPanel:CloseCallBack()
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
end