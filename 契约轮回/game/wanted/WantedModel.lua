-- @Author: lwj
-- @Date:   2019-04-28 11:48:49
-- @Last Modified time: 2019-10-18 17:01:07

WantedModel = WantedModel or class("WantedModel", BaseModel)
local WantedModel = WantedModel

function WantedModel:ctor()
    WantedModel.Instance = self
    self:Reset()
end

function WantedModel:Reset()
    self.is_open_ui = true
    self.info = {}
    self.btn_mode = 1       --1：未完成     2:已完成   3：以领奖
    self.is_hide_icon_after_finish = true       --是否在完成任务之后隐藏主界面图标
    self.is_showing_rd=false            --是否正在显示主界面红点
    self.is_show_once = true
end

function WantedModel.GetInstance()
    if WantedModel.Instance == nil then
        WantedModel()
    end
    return WantedModel.Instance
end

function WantedModel:SetInfo(data)
    self.info = data
end

function WantedModel:GetInfo()
    return self.info
end

function WantedModel:IsCanFetch()
    return self.info.state == 2
end
