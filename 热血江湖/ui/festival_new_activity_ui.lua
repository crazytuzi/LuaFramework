-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require('ui/base')

-------------------------------------------------------
wnd_newFestivalActive = i3k_class('wnd_newFestivalActive', ui.wnd_base)

local SERVER_TAG = 1
local PERSON_TAG = 2 


function wnd_newFestivalActive:ctor()
    self.new_festival_commit_Info = {
        [SERVER_TAG] = i3k_db_new_festival_commit_server,
        [PERSON_TAG] = i3k_db_new_festival_commit_person
    }
    self.new_festival_get_rewards = {
        [SERVER_TAG] = function() return g_i3k_game_context:GetNewFestivalActiveServerRewards() end,
        [PERSON_TAG] = function() return g_i3k_game_context:GetNewFestivalActivePersonRewards() end
    }
    self.new_festival_get_score = {
        [SERVER_TAG] = function() return g_i3k_game_context:GetNewFestivalActiveServerScore() end,
        [PERSON_TAG] = function() return g_i3k_game_context:GetNewFestivalActivePersonScore() end

    }
end

function wnd_newFestivalActive:configure()
    local widgets = self._layout.vars
    self.Score = {}
    self.Rewards = {}
    
    widgets.team_enter_btn:onClick(self, self.JoinFestivalActivity)
    widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_newFestivalActive:refresh()
    self._layout.vars.activity_day:setText(i3k_get_string(18999))
    self._layout.vars.activity_time:setText(i3k_get_string(19000))
    self._layout.vars.open_time:setText(i3k_get_string(19001,i3k_db_new_festival_info.openTimeStr,i3k_db_new_festival_info.closeTimeStr))
    self._layout.vars.desc1:setText(i3k_get_string(19020))
    self._layout.vars.desc2:setText(i3k_get_string(19021))
    self:UpdateCommitInfo(SERVER_TAG)
    self:UpdateCommitInfo(PERSON_TAG)
end

function wnd_newFestivalActive:UpdateCommitInfo(tag)
    self.Rewards[tag] = self.new_festival_get_rewards[tag]()
    self.Score[tag]  = self.new_festival_get_score[tag]()
    local score = self.Score[tag]
    for k, v in ipairs(self.new_festival_commit_Info[tag]) do
        self._layout.vars['box_btn'..tag.. k]:onClick(self, self.OnGetGiftRewards, {commitValue = v.commitValue, rewards = v.rewards, tag = tag})
        self._layout.vars['text'..tag .. k]:setText(v.commitValue)
        
        local isOpen = self.Rewards[tag][v.commitValue]
        self._layout.vars['box'..tag.. k]:setVisible(not isOpen)
        self._layout.vars['box_used'..tag.. k]:setVisible(isOpen)
        
        if not isOpen and score >= v.commitValue then 
            self._layout.anis['c_bx'..tag..k]:play()
        else
            self._layout.anis['c_bx'..tag..k]:stop()
        end
    end
    
    local length = #self.new_festival_commit_Info[tag] 
    local percent = score  * 100 / self.new_festival_commit_Info[tag][length].commitValue    
    self._layout.vars["score"..tag]:setText(score )
    self._layout.vars["slider"..tag]:setPercent(percent)

end
function wnd_newFestivalActive:CloseRewardsAnimition(index)

end

function wnd_newFestivalActive:JoinFestivalActivity()
    if not g_i3k_db.i3k_db_is_in_new_festival_task() then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19078))
        g_i3k_ui_mgr:CloseUI(eUIID_FestivalActivityUI)
		return
	end
    g_i3k_ui_mgr:OpenUI(eUIID_FestivalTaskCommit)
    g_i3k_ui_mgr:RefreshUI(eUIID_FestivalTaskCommit)
end


function wnd_newFestivalActive:OnGetGiftRewards(sender, data)
	if not g_i3k_db.i3k_db_is_in_new_festival_task() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19078))
        g_i3k_ui_mgr:CloseUI(eUIID_FestivalActivityUI)
		return
	end
    --判断是否可以领取
    if self.Score[data.tag] >= data.commitValue then 
        if self.Rewards[ data.tag][ data.commitValue] then
            return 
        end
        if data.tag == PERSON_TAG then 
            i3k_sbean.festival_activity_role_reward(data.commitValue, data.rewards)
        else
            i3k_sbean.festival_activity_world_reward(data.commitValue, data.rewards)
        end 
    else
        g_i3k_ui_mgr:OpenUI(eUIID_FestivalScoreBoxTips)
        g_i3k_ui_mgr:RefreshUI(eUIID_FestivalScoreBoxTips,data.rewards)
    end
    
end

function wnd_create(layout, ...)
    local wnd = wnd_newFestivalActive.new()
    wnd:create(layout)
    return wnd
end
