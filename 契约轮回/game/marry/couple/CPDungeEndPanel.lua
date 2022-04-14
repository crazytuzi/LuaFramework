-- @Author: lwj
-- @Date:   2019-08-27 15:38:52 
-- @Last Modified time: 2019-08-27 15:38:56

CPDungeEndPanel = CPDungeEndPanel or class("CPDungeEndPanel", BasePanel)
local CPDungeEndPanel = CPDungeEndPanel

function CPDungeEndPanel:ctor()
    self.abName = "marry"
    self.assetName = "CPDungeEndPanel"
    self.layer = "UI"
    self.cd_num = 5

    self.use_background = true
    self.is_hide_other_panel = true
    self.model = CoupleModel.GetInstance()
end

function CPDungeEndPanel:dctor()

end

function CPDungeEndPanel:Open(data)
    self.data = data
    CPDungeEndPanel.super.Open(self)
end

function CPDungeEndPanel:OpenCallBack()
end

function CPDungeEndPanel:LoadCallBack()
    self.nodes = {
        "lose", "win/icon", "win/eft_con", "win/Right/des", "autoCloseText", "win", "btns/closeBtn", "win/Right/rewa_con",
        "win/icon/starCon/star2", "win/icon/starCon/star1", "win/icon/starCon/star3", "win/icon/bg",
    }
    self:GetChildren(self.nodes)
    self.cd = GetText(self.autoCloseText)
    self.des = GetText(self.des)

    self:AddEvent()
    self:InitPanel()
end

function CPDungeEndPanel:AddEvent()
    local function callback()
        self:CloseFun()
    end
    AddButtonEvent(self.closeBtn.gameObject, callback)
end

function CPDungeEndPanel:CloseFun()
    local scene_data = SceneManager:GetInstance():GetSceneInfo()
    if self.model:IsCoupleScene(scene_data.scene) then
        SceneControler:GetInstance():RequestSceneLeave();
    end
    self:Close()
end

function CPDungeEndPanel:InitPanel()
    --胜利
    if self.data.clear then
        SetVisible(self.win, true)
        self:LoadEft()
        self:LoadRewa()
        local base_score = String2Table(Config.db_dunge_couple.base.val)[1]
        local extra_score = String2Table(Config.db_dunge_couple.extra.val)[1]
        local str = ConfigLanguage.CoupleDungeon.YuanChaYiXian
        local tips = string.format(str, base_score)
        if self:IsChooseSame() then
            str = ConfigLanguage.CoupleDungeon.XinYouLingXi
            local preference = self:GetSexPreference()
            tips = string.format(str, preference, base_score, preference, extra_score)
        end

        self.des.text = tips
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.bg.transform, nil, true, nil, false, 2)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.star1.transform, nil, true, nil, false, 3)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.star2.transform, nil, true, nil, false, 3)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.star3.transform, nil, true, nil, false, 3)
    else
        self.cd_num = 8
        SetVisible(self.lose, true)
    end
    self:StartCountDown()
end

function CPDungeEndPanel:LoadEft()
    self.effect_Win = UIEffect(self.eft_con, 10401, false, self.layer)

    self.effect_Win2 = UIEffect(self.eft_con, 10402, false, self.layer)
    self.effect_Win2:SetConfig({ scale = 1.06, pos = { x = 17, y = 6, z = 0 } })
end

function CPDungeEndPanel:LoadRewa()
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

--是不是选的一样
function CPDungeEndPanel:IsChooseSame()
    local list = self.data.stat
    local is_same = false
    local temp_value = nil
    local same_idx = nil
    for i, v in pairs(list) do
        if not temp_value then
            temp_value = v
        elseif temp_value and temp_value == v then
            is_same = true
            same_idx = v
        end
    end
    return is_same, same_idx
end

--获取答案偏好
function CPDungeEndPanel:GetSexPreference()
    local str = ""
    local is_same, same_idx = self:IsChooseSame()
    if is_same then
        str = "Male"
        if same_idx == 2 then
            str = "Saintess"
        end
    end
    return str
end

function CPDungeEndPanel:DestroyRewards()
    if self.rewa_item_list then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
    end
    self.rewa_item_list = {}
end

function CPDungeEndPanel:StartCountDown()
    self:StopMySchedule()
    local color = self.data.clear and "fffd8d" or "ffffff"
    self.cd.text = string.format(ConfigLanguage.CoupleDungeon.FewSecLaterColorClose, color, self.cd_num)
    self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
end
function CPDungeEndPanel:BeginningCD()
    if self.cd_num > 1 then
        local color = self.data.clear and "fffd8d" or "ffffff"
        self.cd_num = self.cd_num - 1
        self.cd.text = string.format(ConfigLanguage.CoupleDungeon.FewSecLaterColorClose, color, self.cd_num)
    else
        self:StopMySchedule()
        self:CloseFun()
    end
end

function CPDungeEndPanel:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function CPDungeEndPanel:CloseCallBack()
    self:StopMySchedule()
    self:DestroyRewards()
    if self.effect_Win ~= nil then
        self.effect_Win:destroy()
    end

    if self.effect_Win2 ~= nil then
        self.effect_Win2:destroy()
    end
end