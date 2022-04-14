TimeBossEnterPanel = TimeBossEnterPanel or class("TimeBossEnterPanel",BasePanel)
local TimeBossEnterPanel = TimeBossEnterPanel

function TimeBossEnterPanel:ctor()
	self.abName = "guild_house"
	self.assetName = "TimBossEnterPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.cd_time = 10

	--self.model = 2222222222222end:GetInstance()
end

function TimeBossEnterPanel:dctor()
end

function TimeBossEnterPanel:Open( )
	TimeBossEnterPanel.super.Open(self)
end

function TimeBossEnterPanel:LoadCallBack()
    self.nodes = {
        "des", "btn_close", "btn_enter",
    }
    self:GetChildren(self.nodes)

    self.des_txt = GetText(self.des)
    self:AddEvent()
end

function TimeBossEnterPanel:AddEvent()
    local function call_back(target, x, y)
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(CrossPanel):Open()
        self:Close()
    end
    AddClickEvent(self.btn_enter.gameObject, call_back)
end

function TimeBossEnterPanel:OpenCallBack()
    self:UpdateView()
end

function TimeBossEnterPanel:UpdateView()
    self.des_txt.text = HelpConfig.Dungeon.timeboss_enter
    self:InitCD()
end

function TimeBossEnterPanel:InitCD()
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
        lua_panelMgr:GetPanelOrCreate(CrossPanel):Open()
        self:Close()
    end
    self.CDT:StartSechudle(self.cd_time+ os.time(), call_back)
end

function TimeBossEnterPanel:CloseCallBack()
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
end