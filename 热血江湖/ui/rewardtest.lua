module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_rewardTest = i3k_class("wnd_rewardTest", ui.wnd_base)

function wnd_rewardTest:ctor()

end

function wnd_rewardTest:configure()
    self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_rewardTest:refresh()
    -- self:setSurveyRightData()
end


local STATUS_UNOPEN_FIRST  = 1
local STATUS_UNOPEN_SECOND = 2
local STATUS_JOININ        = 3
local STATUS_GET_REWARD    = 4
local STATUS_FINISHED      = 5

local rewardStatus =
{
    [STATUS_UNOPEN_FIRST]  = {text = string.format("%d级开启", i3k_db_fengce.baseData.surveyNeedLvl), btnEnable = false, onClick = nil, arg = nil}, -- 等级不足
    [STATUS_UNOPEN_SECOND] = {text = string.format("%d级开启", i3k_db_fengce.baseData.surveyNeedLvl2), btnEnable = false, onClick = nil, arg = nil}, -- 等级不足
    [STATUS_JOININ]        = {text = string.format("参与调查"), btnEnable = true, onClick = "joinSurvey", arg = "_index"}, -- 可以参与调研
    [STATUS_GET_REWARD]    = {text = string.format("领奖"), btnEnable = true, onClick = "takeSurveyReward", arg = nil }, -- 可以领奖
    [STATUS_FINISHED]      = {text = string.format("已完成"), btnEnable = false, onClick = nil, arg = nil}, -- 已经领过奖，下一个等级是否开启未知
}

function wnd_rewardTest:getRewardStatus(index, reward)
    if g_i3k_game_context:GetLevel() < i3k_db_fengce.baseData.surveyNeedLvl then
        return STATUS_UNOPEN_FIRST
    end
    if reward == 0 then
        if g_i3k_db.i3k_db_get_reward_test_first_finish_status(index) then
            return STATUS_GET_REWARD
        else
            return STATUS_JOININ
        end
    end
    if reward == 1 then
        if g_i3k_game_context:GetLevel() < i3k_db_fengce.baseData.surveyNeedLvl2 then
            return STATUS_FINISHED
        end
        if g_i3k_db.i3k_db_get_reward_test_second_finish_status(index) then
            return STATUS_GET_REWARD
        else
            return STATUS_JOININ
        end
    end
    return STATUS_FINISHED
end

function wnd_rewardTest:setSurveyRightData(index, reward)
    self._index = index
    self._reward = reward
    local widget = self._layout
	local item = nil
    if self._index >= i3k_db_fengce.baseData.lastQuestionID and self._reward == 1 then
		item = i3k_db_fengce.survey2
	else
		item = i3k_db_fengce.survey
	end
	widget.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
	widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id,i3k_game_context:IsFemaleRole()))
	widget.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(item.id))
    widget.vars.itemCounts:setText("x"..item.count)
    widget.vars.lockImg:setVisible(item.id > 0)
	widget.vars.btn:setTag(item.id)
	widget.vars.btn:onClick(self, self.checkItemInfo)

    local status = self:getRewardStatus(index, reward)
    widget.vars.takeLabel:setText(rewardStatus[status].text)
    if not rewardStatus[status].btnEnable then
        widget.vars.joinBtn:disableWithChildren()
    end
    if rewardStatus[status].onClick then
        widget.vars.joinBtn:onClick(self, self[rewardStatus[status].onClick], self[rewardStatus[status].arg])
    end
end

function wnd_rewardTest:checkItemInfo(sender)
	local itemId = sender:getTag()
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_rewardTest:joinSurvey(sender, index)
	g_i3k_ui_mgr:OpenUI(eUIID_Survey)
	g_i3k_ui_mgr:RefreshUI(eUIID_Survey, index+1)
end

function wnd_rewardTest:takeSurveyReward(sender)
	local index = sender:getTag()
    local item = nil
    if self._index >= i3k_db_fengce.baseData.lastQuestionID and self._reward == 1 then
		item = i3k_db_fengce.survey2
	else
		item = i3k_db_fengce.survey
	end
	local itemTable = {item}
	local callback = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RewardTest, "surveryRewardCB", widget, itemTable)
	end
	local isEnoughTable = {
		[item.id] = item.count,
	}
	local isenough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isenough then
		i3k_sbean.take_survey_gift(callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end

function wnd_rewardTest:surveryRewardCB(widget, itemTable)
    local widget = self._layout
	widget.vars.takeLabel:setText(string.format("已完成"))
	widget.vars.joinBtn:disableWithChildren()
	g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
	-- self:hideRedPoint(SURVEY_STATE)
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_rewardTest.new();
		wnd:create(layout);
	return wnd;
end
