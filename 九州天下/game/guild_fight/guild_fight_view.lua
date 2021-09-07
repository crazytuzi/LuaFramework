require("game/guild_fight/guild_fight_reward_view")
require("game/guild_fight/guild_fight_track_info_view")

GuildFightView = GuildFightView or BaseClass(BaseView)

function GuildFightView:__init()
    self.ui_config = {"uis/views/guildfight","GuildFightTaskView"}
    self.view_layer = UiLayer.MainUI

    self.reward_panel_is_open = true
    self.track_info_panel_is_open = false
    self.mainui_state = true
    self.is_safe_area_adapter = true
end

function GuildFightView:__delete()
    self.reward_panel_is_open = true
    self.track_info_panel_is_open = false
end

function GuildFightView:LoadCallBack()
    self.reward_panel = self:FindObj("RewardPanel")
    self.reward_view = GuildFightRewardView.New(self.reward_panel)

    self.track_info_panel = self:FindObj("TrackAndMapInfo")
    self.track_info_view = GuildFightTrackInfoView.New(self.track_info_panel)

    self.block = self:FindObj("Block")

    self.show_track_info = self:FindVariable("ShowTrackInfo")

    self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
        BindTool.Bind(self.SwitchButtonState, self))

    self:Flush()
end

function GuildFightView:ReleaseCallBack()
    if self.reward_view then
        self.reward_view:DeleteMe()
        self.reward_view = nil
    end
    if self.track_info_view then
        self.track_info_view:DeleteMe()
        self.track_info_view = nil
    end

    if self.show_or_hide_other_button then
        GlobalEventSystem:UnBind(self.show_or_hide_other_button)
        self.show_or_hide_other_button = nil
    end
    self.reward_panel = nil
    self.track_info_panel = nil
    self.block = nil
    self.show_track_info = nil
end

function GuildFightView:CloseCallBack()
    self.reward_panel_is_open = false
end

function GuildFightView:CloseMainView()
    self:Close()
end

function GuildFightView:OnFlush(param_t)
    self.block:SetActive(true)
    self.show_track_info:SetValue(false)
    self.reward_panel:SetActive(false)

    if self.reward_panel_is_open and self.reward_view then
        self.reward_panel:SetActive(true)
        --self.reward_view:Flush()
    elseif self.track_info_panel_is_open and self.track_info_view then
        self.block:SetActive(false)
        if self.mainui_state then
            self.show_track_info:SetValue(true)
        end
        self.track_info_view:Flush()
    end
    for k,v in pairs(param_t) do
        if k == "goldboxpos" then
            if self.track_info_view then
                self.track_info_view:FindBoxPos()
            end
        elseif k == "flush_reward_view" then
            if self.reward_view then
                self.reward_view:Flush()
            end
        end
    end
end

function GuildFightView:OpenTrackInfoView()
    self.reward_panel_is_open = false
    self.track_info_panel_is_open = true
    self:Open()
    self:Flush()
end

function GuildFightView:OnClose()
    self:Close()
end

function GuildFightView:OpenRewardView()
    self.reward_panel_is_open = true
    self.track_info_panel_is_open = false
    if not self:IsLoaded() then
        self:Open()
    else
        self:Flush()
    end
end

function GuildFightView:SwitchButtonState(state)
    self.mainui_state = state
    self.show_track_info:SetValue(state)
    if self.reward_panel_is_open then
        self.show_track_info:SetValue(false)
    end
end