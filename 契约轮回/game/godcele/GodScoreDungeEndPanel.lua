-- @Author: lwj
-- @Date:   2019-09-10 19:59:02 
-- @Last Modified time: 2019-09-10 19:59:04

GodScoreDungeEndPanel = GodScoreDungeEndPanel or class("GodScoreDungeEndPanel", BasePanel)
local GodScoreDungeEndPanel = GodScoreDungeEndPanel

function GodScoreDungeEndPanel:ctor()
    self.abName = "sevenDayActive"
    self.assetName = "GodScoreDungeEndPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.cd_num = 5
    self.use_background = true
    self.is_hide_other_panel = true

    self.model = GodCelebrationModel.GetInstance()
end

function GodScoreDungeEndPanel:dctor()

end

function GodScoreDungeEndPanel:Open(data)
    self.data = data
    --dump(data, "<color=#6ce19b>GodScoreDungeEndPanel   GodScoreDungeEndPanel  GodScoreDungeEndPanel  GodScoreDungeEndPanel</color>")
    GodScoreDungeEndPanel.super.Open(self)
end

function GodScoreDungeEndPanel:OpenCallBack()
    AutoFightManager.GetInstance():StopAutoFight()
end

function GodScoreDungeEndPanel:LoadCallBack()
    self.nodes = {
        "autoCloseText", "btns/closeBtn", "win/icon/bg", "win/icon/starCon/star1", "win/icon/starCon/star2", "win/icon/starCon/star3",
        "win/Right/rewa_con", "win", "win/eft_con", "lose", "btns/closeBtn/closeText",
    }
    self:GetChildren(self.nodes)
    self.cd = GetText(self.autoCloseText)
    self.btn_text = GetText(self.closeText)

    self:AddEvent()
    self:InitPanel()
end

function GodScoreDungeEndPanel:AddEvent()
    local function callback()
        if self.is_last_floor or self.data.isClear == false then
            self:CloseFun()
        else
            self:EnterDunge()
        end
    end
    AddButtonEvent(self.closeBtn.gameObject, callback)
end

function GodScoreDungeEndPanel:CloseFun()
    local scene_data = SceneManager:GetInstance():GetSceneInfo()
    if self.model:IsGodScoreScene(scene_data.scene) then
        SceneControler:GetInstance():RequestSceneLeave();
    end
    self:Close()
end

function GodScoreDungeEndPanel:InitPanel()
    --胜利
    self.enter_info = self.model.dunge_enter_info
    local floor = self.enter_info.floor
    local str = ""
    if self.data.isClear then
        self.is_last_floor = floor == 3
        str = self.is_last_floor and ConfigLanguage.GodCele.Close or ConfigLanguage.GodCele.NextFloor
        SetVisible(self.win, true)
        self:LoadEft()
        self:LoadRewa()
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.bg.transform, nil, true, nil, false, 2)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.star1.transform, nil, true, nil, false, 3)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.star2.transform, nil, true, nil, false, 3)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.star3.transform, nil, true, nil, false, 3)
    else
        str = ConfigLanguage.GodCele.Close
        SetVisible(self.lose, true)
    end
    self.btn_text.text = str
    self:StartCountDown()
end

function GodScoreDungeEndPanel:LoadEft()
    self.effect_Win = UIEffect(self.eft_con, 10401, false, self.layer)

    self.effect_Win2 = UIEffect(self.eft_con, 10402, false, self.layer)
    self.effect_Win2:SetConfig({ scale = 1.06, pos = { x = 17, y = 6, z = 0 } })
end

function GodScoreDungeEndPanel:LoadRewa()
    self:DestroyRewards()
    local list = self.data.reward
    local interator = table.pairsByKey(list)
    for item_id, num in interator do
        local param = {}
        local operate_param = {}
        param["item_id"] = item_id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 84, y = 84 }
        param["num"] = num
        local itemIcon = GoodsIconSettorTwo(self.rewa_con)
        itemIcon:SetIcon(param)
        self.rewa_item_list[#self.rewa_item_list + 1] = itemIcon
    end
end
function GodScoreDungeEndPanel:DestroyRewards()
    if self.rewa_item_list then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
    end
    self.rewa_item_list = {}
end

function GodScoreDungeEndPanel:StartCountDown()
    self:StopMySchedule()
    local color = self.data.clear and "fffd8d" or "ffffff"
    self.cd.text = string.format(ConfigLanguage.CoupleDungeon.FewSecLaterColorClose, color, self.cd_num)
    self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
end
function GodScoreDungeEndPanel:BeginningCD()
    if self.cd_num > 1 then
        local color = self.data.clear and "fffd8d" or "ffffff"
        self.cd_num = self.cd_num - 1
        self.cd.text = string.format(ConfigLanguage.CoupleDungeon.FewSecLaterColorClose, color, self.cd_num)
    else
        self:StopMySchedule()
        if self.is_last_floor or self.data.isClear == false then
            self:CloseFun()
        else
            self:EnterDunge()
        end
    end
end
function GodScoreDungeEndPanel:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function GodScoreDungeEndPanel:EnterDunge()
    DungeonCtrl.GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER, nil, nil, true)
    self:Close()
end

function GodScoreDungeEndPanel:CloseCallBack()
    self:StopMySchedule()
    self:DestroyRewards()
    if self.effect_Win ~= nil then
        self.effect_Win:destroy()
    end

    if self.effect_Win2 ~= nil then
        self.effect_Win2:destroy()
    end
end