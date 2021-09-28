-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_survey = i3k_class("wnd_survey", ui.wnd_base)

function wnd_survey:ctor()
	self._answerTable = {}
end

function wnd_survey:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.closeBtn2:onClick(self, self.onCloseUI)
	self._layout.vars.surveyRoot:show()
	self._layout.vars.finishRoot:hide()
end

function wnd_survey:onShow()

end
--UIScrollList:addItemAndChild(nodePath, length, totalCount)
function wnd_survey:refresh(index)
	local itemId = nil
	local itemCount = nil
	if index > i3k_db_fengce.baseData.lastQuestionID then
		itemId = i3k_db_fengce.surveyReward2.id
		itemCount = i3k_db_fengce.surveyReward2.count
	else
		itemId = i3k_db_fengce.surveyReward.id
		itemCount = i3k_db_fengce.surveyReward.count
	end
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
	self._layout.vars.countLabel:setText("x"..itemCount)
	self._layout.vars.lock:setVisible(g_i3k_db.g_i3k_common_item_has_binding_icon(itemId))
	self._answerTable = {}
	local scroll = self._layout.vars.scroll
	scroll:setBounceEnabled(false)
	scroll:removeAllChildren(true)
	local askCfg = i3k_db_fengce_survey[index]
	--题目
	local children = scroll:addItemAndChild("ui/widgets/yjdyt1")
	local node = children[1]
	node.vars.title:setText(string.format("%d.%s", askCfg.index, askCfg.text))
	--各种答案
	local answerTable = {}
	for i,v in ipairs(askCfg.answerTable) do
		if v~="" then
			table.insert(answerTable, v)
		end
	end
	local children = scroll:addItemAndChild("ui/widgets/yjdyt2", 2, #answerTable)
	for i,v in ipairs(children) do
		v.vars.text:setText(answerTable[i])
		v.vars.btn:setTag(i)
		v.vars.btn:onClick(self, self.selectAnswer, index)
		v.vars.selectImg:hide()
	end
	self._layout.vars.confirmBtn:disableWithChildren()--onClick(self, self.onConfirm)
end

function wnd_survey:selectAnswer(sender, index)
	local askCfg = i3k_db_fengce_survey[index]
	local questionType = askCfg.questionType
	local children = self._layout.vars.scroll:getAllChildren()
	local tag = sender:getTag()

	if questionType==1 then
		self._answerTable = {[tag] = true}
		for i,v in ipairs(children) do
			if v.vars.selectImg then
				v.vars.selectImg:setVisible(v.vars.btn:getTag()==tag)
			end
		end
	else
		for i,v in ipairs(children) do
			if v.vars.selectImg and v.vars.btn:getTag()==tag then
				local isShow = v.vars.selectImg:isVisible()
				v.vars.selectImg:setVisible(not isShow)
				if isShow then
					self._answerTable[tag] = nil
				else
					self._answerTable[tag] = true
				end
			end
		end
	end
	local x = self._answerTable
	local count = 0
	for i,v in pairs(self._answerTable) do
		count = count + 1
	end
	if count>0 then
		self._layout.vars.confirmBtn:enableWithChildren()
		self._layout.vars.confirmBtn:setTag(index)
		self._layout.vars.confirmBtn:onClick(self, self.onConfirm, self._answerTable)
	else
		self._layout.vars.confirmBtn:disableWithChildren()
	end
end

function wnd_survey:onConfirm(sender, answerTable)
	local index = sender:getTag()
	local itemCount = nil
	if index > i3k_db_fengce.baseData.lastQuestionID then
		itemCount = i3k_db_fengce.surveyReward2.count
	else
		itemCount = i3k_db_fengce.surveyReward.count
	end
	local callback = function ()
		g_i3k_ui_mgr:OpenUI(eUIID_AddDiamond)
		g_i3k_ui_mgr:RefreshUI(eUIID_AddDiamond, itemCount)
		if g_i3k_db.i3k_db_get_reward_test_first_finish_status(index) or
			g_i3k_db.i3k_db_get_reward_test_second_finish_status(index)
		 then
			self._layout.vars.surveyRoot:hide()
 			self._layout.vars.finishRoot:show()
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_Survey, index + 1)
		end
		local reward = index > 10 and 1 or 0
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RewardTest, "setSurveyRightData", index, reward)
	end
	i3k_sbean.answer_question(index, answerTable, callback)
end

--[[function wnd_survey:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Survey)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_survey.new()
	wnd:create(layout, ...)
	return wnd;
end
