-- @Author: lwj
-- @Date:   2019-02-16 15:44:04
-- @Last Modified time: 2019-02-16 15:44:06

CandyEnterPanel = CandyEnterPanel or class("CandyEnterPanel", BasePanel)
local CandyEnterPanel = CandyEnterPanel

function CandyEnterPanel:ctor()
    self.abName = "candy"
    self.assetName = "CandyEnterPanel"
    self.layer = "Bottom"

    self.use_background = true
    --self.click_bg_close = true
    self.is_show_open_action = true
    self.cd_time = 10
    self.model = CandyModel.GetInstance()
end

function CandyEnterPanel:dctor()

end

function CandyEnterPanel:Open()
    CandyEnterPanel.super.Open(self)
end

function CandyEnterPanel:LoadCallBack()
    self.nodes = {
        "btn_close", "btn_enter", "des",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
    self:InitPanel()
end

function CandyEnterPanel:AddEvent()
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.btn_close.gameObject, call_back)

    AddButtonEvent(self.btn_enter.gameObject, handler(self, self.ClickFun))
end

function CandyEnterPanel:ClickFun()
    if (not ActivityModel.GetInstance():GetActivity(10121)) and (not ActivityModel.GetInstance():GetActivity(10122)) then
        Notify.ShowText("Event locked, please wait~")
        return
    end
    local curSceneId = SceneManager.GetInstance():GetSceneId()
    if self.model.cur_scene_id ~= curSceneId then
        SceneControler:GetInstance():RequestSceneChange(self.model.cur_scene_id, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, self.model.cur_act_id);
    end
    self:Close()
end

function CandyEnterPanel:OpenCallBack()
    self.model:GetActvityTimeTbl()
end

function CandyEnterPanel:InitPanel()
    --SceneManager:GetInstance():AttackCreepByTypeId(10121)
    self.des.text = HelpConfig.Candy.GameDescriton
    self:InitCD()
end

function CandyEnterPanel:InitCD()
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
        self:ClickFun()
    end
    self.CDT:StartSechudle(self.cd_time + os.time(), call_back)
end

function CandyEnterPanel:CloseCallBack()
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
    if self.change_end_event_id then
        GlobalEvent:RemoveListener(self.change_end_event_id)
        self.change_end_event_id = nil
    end
end
