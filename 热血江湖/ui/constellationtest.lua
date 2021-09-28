-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_constellationTest = i3k_class("wnd_constellationTest", ui.wnd_base)

local LAYER_TESTITEM = "ui/widgets/xinyuxingyuant"

function wnd_constellationTest:ctor()
	self.answer = {}
	self.selectedTest = 0
	self.questionNum = 1
	self.questionType = 0
	self.sex = 0
end

function wnd_constellationTest:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.start_test:onClick(self, self.onStartTest)
end

function wnd_constellationTest:refresh(sex, questionType)
	self.sex = sex
	ui_set_hero_model(self._layout.vars.model, 2076)
	self:showTests()
	--self.questionType = questionType
end

function wnd_constellationTest:showQuestions(questionType)
	local widgets = self._layout.vars
	local questionNo = 0
	for k,v in ipairs(i3k_db_mood_diary_constellation_test) do
		if v.questionGroup == questionType and v.questionID == self.questionNum then
			questionNo = k
		end
	end
	widgets.question_content:setText(i3k_db_mood_diary_constellation_test[questionNo].questionDes)
	widgets.question_index:setText(string.format("%d/10", self.questionNum))
	widgets.questionA:setText(i3k_db_mood_diary_constellation_test[questionNo].questionAnsA)
	widgets.questionB:setText(i3k_db_mood_diary_constellation_test[questionNo].questionAnsB)
	widgets.questionC:setText(i3k_db_mood_diary_constellation_test[questionNo].questionAnsC)
	widgets.questionA_btn:onClick(self, self.onChooseAns, {ans = 1, questionType = questionType})
	widgets.questionB_btn:onClick(self, self.onChooseAns, {ans = 2, questionType = questionType})
	widgets.questionC_btn:onClick(self, self.onChooseAns, {ans = 3, questionType = questionType})
end

function wnd_constellationTest:showTests()
	local widgets = self._layout.vars
	local personInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
	widgets.test_scroll:removeAllChildren()
	widgets.test_scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	for k,v in ipairs(i3k_db_mood_diary_sex[self.sex].questionGroup) do
		local Item = require(LAYER_TESTITEM)()
		if personInfo.self.testScore[i3k_db_mood_diary_sex[self.sex].questionGroup[k]] then
			Item.vars.unfinished:setVisible(false)
			Item.vars.finished:setVisible(true)
		else
			Item.vars.unfinished:setVisible(true)
			Item.vars.finished:setVisible(false)
		end
		Item.vars.choose_btn:onClick(self, self.onChooseTest, {selectTest = k, index = i3k_db_mood_diary_sex[self.sex].questionGroup[k], score = personInfo.self.testScore[i3k_db_mood_diary_sex[self.sex].questionGroup[k]]})
		Item.vars.test_name:setText(i3k_db_mood_diary_constellation_test_name[i3k_db_mood_diary_sex[self.sex].questionGroup[k]].testName)
		widgets.test_scroll:addItem(Item)
	end
	for i = 1, 3 do
		local node = require(LAYER_TESTITEM)()
		node.vars.test_name:setText("敬请期待")
		node.vars.choose_btn:onClick(self, self.onComingSoon)
		node.vars.unfinished:setVisible(false)
		node.vars.finished:setVisible(false)
		widgets.test_scroll:addItem(node)
	end
end

function wnd_constellationTest:onComingSoon(sender)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17515))
end

function wnd_constellationTest:onChooseTest(sender, testItem)
	if testItem.score then	--显示结果
		local role_name = g_i3k_game_context:GetRoleName()
		g_i3k_ui_mgr:OpenUI(eUIID_ConstellationTestResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_ConstellationTestResult, testItem.score, self.sex, testItem.index, role_name)
	else
		if self.selectedTest == testItem.selectTest then	--开始已经选了一个题库了，再点击取消
			for i,v in ipairs(self._layout.vars.test_scroll:getAllChildren()) do
				if i == self.selectedTest then
					v.vars.frame:setVisible(false)
				end
			end
			self.selectedTest = 0
			self.questionType = 0
		else
			for i,v in ipairs(self._layout.vars.test_scroll:getAllChildren()) do
				if i == self.selectedTest then
					v.vars.frame:setVisible(false)
				end
				if i == testItem.selectTest then
					v.vars.frame:setVisible(true)
				end
			end
			self.selectedTest = testItem.selectTest
			self.questionType = testItem.index
		end
		
	end
	
end

function wnd_constellationTest:onStartTest(sender)
	local widgets = self._layout.vars
	if self.questionType == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17514))
	else
		local fun = (function(ok)
			if ok then
				self:showQuestions(self.questionType)
				widgets.test_bank:setVisible(false)
				widgets.question_desc:setVisible(true)
			end
		end)
		local desc = i3k_get_string(17485)
		g_i3k_ui_mgr:ShowConstellationBox("确定", "取消", desc, fun)
	end
end

function wnd_constellationTest:onChooseAns(sender, ansArg)
	if self.questionNum == 10 then
		table.insert(self.answer, ansArg.ans)
		--跳转测试结果
		i3k_sbean.mood_diary_constellation_test(self.answer, self.sex, ansArg.questionType)
	else
		self.questionNum = self.questionNum + 1
		table.insert(self.answer, ansArg.ans)
		self:showQuestions(ansArg.questionType)
	end
end

function wnd_constellationTest:onCloseUI(sender)
	local widgets = self._layout.vars
	if widgets.question_desc:isVisible() then
		local fun = (function(ok)
			if ok then
				g_i3k_ui_mgr:CloseUI(eUIID_ConstellationTest)
			end
		end)
		local desc = "是否退出答题"
		g_i3k_ui_mgr:ShowConstellationBox("确定", "取消", desc, fun)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_ConstellationTest)
	end
end

function wnd_create(layout)
	local wnd = wnd_constellationTest.new()
	wnd:create(layout)
	return wnd
end
