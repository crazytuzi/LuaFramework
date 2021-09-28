-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_knightly_detective_member = i3k_class("wnd_knightly_detective_member", ui.wnd_base)

local clueNode = "ui/widgets/guiyingwangluot1"
local modelNode = "ui/widgets/guiyingwangluot2"
local memberCount = 8

function wnd_knightly_detective_member:ctor()
	self._spyData = nil
	self._memberTable = {}
	self._curMemberId = 0
end

function wnd_knightly_detective_member:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
	self._layout.vars.leaderBtn:onClick(self, self.onExposeBtn)
	self._layout.vars.surveyBtn:onClick(self, self.onSurveyBtn)
	self._layout.vars.chooseBtn:onClick(self, self.onChooseBtn)
	self._layout.vars.storyBtn:onClick(self, self.onStoryBtn)
	self._layout.vars.leftBtn:onClick(self, self.onLeftBtn)
	self._layout.vars.rightBtn:onClick(self, self.onRightBtn)
	self._layout.vars.leaderSurvey:onClick(self, self.onLeaderSurvey)
	for k = 1, memberCount do
		self._layout.vars["modelBtn"..k]:onClick(self, self.onMemberBtn, k)
	end
end

function wnd_knightly_detective_member:refresh()
	self._spyData = g_i3k_game_context:getKnightlyDetectiveData()
	if self._spyData then
		self._memberTable = g_i3k_game_context:getKnightlyDetectiveMember()
		if self._spyData.bossFond == g_DETECTIVE_EXPOSED then
			self:updateBossModel()
		else
			self:updateMemberData()
		end
		self:updateClueScroll()
	end
end

function wnd_knightly_detective_member:updateBossModel()
	self._curMemberId = 0
	self._layout.vars.surveyBtn:hide()
	self._layout.vars.leaderSurvey:show()
	self._layout.vars.leaderBg:show()
	self._layout.vars.leaderScroll:removeAllChildren()
	local monsterId = i3k_db_knightly_detective_ringleader[self._spyData.boss].monsterId
	local node = require(modelNode)()
	ui_set_hero_model(node.vars.model, g_i3k_db.i3k_db_get_monster_modelID(monsterId))
	self._layout.vars.stateText:setText(i3k_db_monsters[monsterId].name)
	self._layout.vars.clueDesc:setText(i3k_get_string(18256))
	self._layout.vars.ralation:setText(i3k_get_string(18187))
	if self._spyData.chasingBoss == g_DETECTIVE_DEAD then
		--已击杀头目
		self._layout.vars.bossText:setText(i3k_get_string(18222))
		node.vars.model:setRotation(i3k_db_knightly_detective_ringleader[self._spyData.boss].angleDead / 180 * math.pi)
		node.vars.model:setColor(0xffffffff)
		self._layout.vars.chooseBtn:disableWithChildren()
		self._layout.vars.chooseText:setText(i3k_get_string(18255))
	else
		self._layout.vars.bossText:setText(i3k_get_string(18192, i3k_db_monsters[monsterId].name))
		node.vars.model:setRotation(i3k_db_knightly_detective_ringleader[self._spyData.boss].angleAlive / 180 * math.pi)
		node.vars.model:setColor(0xffffffff)
		self._layout.vars.chooseText:setText(i3k_get_string(18254))
		if self._spyData.chasingBoss == g_DETECTIVE_CHANSING then
			self._layout.vars.chooseBtn:disableWithChildren()
		else
			self._layout.vars.chooseBtn:enableWithChildren()
		end
	end
	self._layout.vars.leaderScroll:addItem(node)
	for k, v in ipairs(self._memberTable) do
		self._layout.vars["modelBg"..k]:hide()
	end
	self._layout.vars.leaderBg:show()
	self._layout.vars.leaderBg:setImage(g_i3k_db.i3k_db_get_icon_path(9049))
	self:updateSurveyTimes()
end

function wnd_knightly_detective_member:updateClueScroll()
	if not next(self._spyData.finishedMembers) then
		self._layout.vars.noneClueText:show()
		self._layout.vars.noneClueText:setText(i3k_get_string(18190))
	else
		self._layout.vars.noneClueText:hide()
		self._layout.vars.clueScroll:removeAllChildren()
		for k, v in ipairs(self._spyData.finishedMembers) do
			local clueType = i3k_db_knightly_detective_members[v].clueType
			if clueType ~= 0 then
				local node = require(clueNode)()
				node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_knightly_detective_common.clueIcon[clueType]))
				node.vars.bt:onClick(self, self.onClueBtn, clueType)
				self._layout.vars.clueScroll:addItem(node)
			end
		end
	end
end

function wnd_knightly_detective_member:onClueBtn(sender, clueType)
	g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveClue)
	g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveClue, i3k_db_knightly_detective_ringleader[self._spyData.boss].description[clueType].detail)
end

function wnd_knightly_detective_member:updateMemberData()
	self._layout.vars.surveyBtn:show()
	self._layout.vars.leaderSurvey:hide()
	self._layout.vars.leaderText:setText(i3k_get_string(18258))
	self._layout.vars.leaderBg:hide()
	for k, v in ipairs(self._memberTable) do
		self._layout.vars["modelBg"..k]:show()
		self._layout.vars["modelBg"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(9048))
		self._layout.vars["modelScroll"..k]:removeAllChildren()
		local node = require(modelNode)()
		local monsterId = i3k_db_knightly_detective_members[self._memberTable[k]].monsterId
		ui_set_hero_model(node.vars.model, g_i3k_db.i3k_db_get_monster_modelID(monsterId))
		if table.indexof(self._spyData.finishedMembers, self._memberTable[k]) then
			--已击杀
			node.vars.model:setRotation(i3k_db_knightly_detective_members[self._memberTable[k]].angleDead / 180 * math.pi)
			node.vars.model:setColor(0xffffffff)
		elseif table.indexof(self._spyData.surveyMembers, self._memberTable[k]) then
			--已调查
			node.vars.model:setRotation(i3k_db_knightly_detective_members[self._memberTable[k]].angleDead / 180 * math.pi)
			node.vars.model:setColor(0xffffffff)
		elseif self._spyData.curChasingMember == self._memberTable[k] then
			--正在追踪
			node.vars.model:setRotation(i3k_db_knightly_detective_members[self._memberTable[k]].angleAlive / 180 * math.pi)
			node.vars.model:setColor(0xffffffff)
		else
			node.vars.model:setRotation(i3k_db_knightly_detective_members[self._memberTable[k]].angleAlive / 180 * math.pi)
			node.vars.model:setColor(0xff354a90)
		end
		self._layout.vars["modelScroll"..k]:addItem(node)
	end
	self._curMemberId = self._memberTable[1]
	self:setMemberDetail()
end

function wnd_knightly_detective_member:onMemberBtn(sender, index)
	if index ~= 1 and self._spyData.bossFond ~= g_DETECTIVE_EXPOSED then
		self:turnAroundModels(index)
		self:updateMemberData()
		--self:testShowMemberInfo()
	end
	--self:setMemberDetail()
end

function wnd_knightly_detective_member:onLeftBtn(sender)
	self:onMemberBtn(nil, memberCount)
end

function wnd_knightly_detective_member:onRightBtn(sender)
	self:onMemberBtn(nil, 2)
end

function wnd_knightly_detective_member:turnAroundModels(index)
	local newMembers = {}
	for k = index, index + memberCount - 1 do
		if k > memberCount then
			table.insert(newMembers, self._memberTable[k - memberCount])
		else
			table.insert(newMembers, self._memberTable[k])
		end
	end
	self._memberTable = newMembers
end

function wnd_knightly_detective_member:setMemberDetail()
	self._layout.vars.ralation:setText(i3k_get_string(18187))
	if table.indexof(self._spyData.finishedMembers, self._curMemberId) then
		--已击杀
		local monsterId = i3k_db_knightly_detective_members[self._curMemberId].monsterId
		self._layout.vars.stateText:setText(i3k_db_monsters[monsterId].name)
		--self._layout.vars.clueDesc:setText(i3k_db_knightly_detective_members[self._curMemberId].clueDescription)
		self._layout.vars.chooseBtn:disableWithChildren()
		self._layout.vars.chooseText:setText(i3k_get_string(18255))
		if i3k_db_knightly_detective_members[self._curMemberId].clueType == 0 then
			self._layout.vars.clueDesc:setText(i3k_db_knightly_detective_members[self._curMemberId].clueDescription)
		else
			self._layout.vars.clueDesc:setText(i3k_get_string(18268))
		end
		--self._layout.vars.surveyBtn:disableWithChildren()
	elseif table.indexof(self._spyData.surveyMembers, self._curMemberId) then
		--已调查
		local monsterId = i3k_db_knightly_detective_members[self._curMemberId].monsterId
		self._layout.vars.stateText:setText(i3k_db_monsters[monsterId].name)
		self._layout.vars.clueDesc:setText(i3k_db_knightly_detective_members[self._curMemberId].clueDescription)
		self._layout.vars.chooseBtn:enableWithChildren()
		self._layout.vars.chooseText:setText(i3k_get_string(18254))
		--self._layout.vars.surveyBtn:disableWithChildren()
	elseif self._spyData.curChasingMember == self._curMemberId then
		--正在追踪
		self._layout.vars.stateText:setText(i3k_get_string(18199))
		self._layout.vars.clueDesc:setText(i3k_get_string(18190))
		self._layout.vars.chooseBtn:disableWithChildren()
		self._layout.vars.chooseText:setText(i3k_get_string(18254))
		--self._layout.vars.surveyBtn:disableWithChildren()
	else
		--未揭露
		self._layout.vars.stateText:setText(i3k_get_string(18199))
		self._layout.vars.clueDesc:setText(i3k_get_string(18188))
		self._layout.vars.chooseBtn:enableWithChildren()
		self._layout.vars.chooseText:setText(i3k_get_string(18254))
		--self._layout.vars.surveyBtn:enableWithChildren()
	end
	if self._spyData.bossFond == g_DETECTIVE_NOT_EXPOSE and self._spyData.findingBossCnt >= 1 then
		self._layout.vars.bossText:setText(i3k_get_string(18221))
		self._layout.vars.chooseBtn:disableWithChildren()
		self._layout.vars.leaderBtn:disableWithChildren()
	else
		self._layout.vars.bossText:setText(i3k_get_string(18191))
	end
	self:updateSurveyTimes()
end

function wnd_knightly_detective_member:updateSurveyTimes()
	if next(self._spyData.surveyMembers) then
		self._layout.vars.surveyText:setText(i3k_db_knightly_detective_common.surveyTimes - #self._spyData.surveyMembers)
	else
		self._layout.vars.surveyText:setText(i3k_db_knightly_detective_common.surveyTimes)
	end
	self._layout.vars.receiveText:setText(i3k_db_knightly_detective_common.receiveTimes - self._spyData.chasingCnt)
	if self._spyData.bossFond == g_DETECTIVE_EXPOSED then
		self._layout.vars.leaderBtn:hide()
		if self._spyData.chasingBoss ~= g_DETECTIVE_NOT_FIND then
			self._layout.vars.receiveText:setText(i3k_db_knightly_detective_common.receiveTimes - self._spyData.chasingCnt + 1)
			self._layout.vars.chooseBtn:disableWithChildren()
		else
			self._layout.vars.chooseBtn:enableWithChildren()
		end
	else
		self._layout.vars.leaderBtn:show()
		if self._spyData.chasingCnt >= i3k_db_knightly_detective_common.receiveTimes then
			self._layout.vars.chooseBtn:disableWithChildren()
		else
			self._layout.vars.chooseBtn:enableWithChildren()
		end
	end
end

function wnd_knightly_detective_member:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18252, i3k_db_knightly_detective_common.surveyTimes, i3k_db_knightly_detective_common.receiveTimes))
end

function wnd_knightly_detective_member:onExposeBtn(sender)
	if self._spyData.bossFond ~= g_DETECTIVE_EXPOSED then
		g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveLeader)
		g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveLeader)
	end
end

function wnd_knightly_detective_member:onSurveyBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveSurvey)
	g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveSurvey, self._curMemberId)
end

function wnd_knightly_detective_member:onStoryBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveTips)
end

function wnd_knightly_detective_member:onLeaderSurvey(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveSurvey)
	g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveSurvey, 0)
end

--选择追击
function wnd_knightly_detective_member:onChooseBtn(sender)
	if self._spyData.bossFond == g_DETECTIVE_EXPOSED then
		if self._spyData.chasingBoss == g_DETECTIVE_NOT_FIND then
			i3k_sbean.spy_chasing_boss(self._spyData.boss)
		end
	else
		if table.indexof(self._spyData.finishedMembers, self._curMemberId) or self._spyData.curChasingMember ~= 0 then
			--g_i3k_ui_mgr:PopupTipMessage("dead or chasing")
		else
			local memberId = self._curMemberId
			local callback = function (isOk)
				if isOk then
					i3k_sbean.spy_chasing(memberId)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18198), callback)
		end
	end
end

function wnd_knightly_detective_member:changeMemberData()
	self._spyData = g_i3k_game_context:getKnightlyDetectiveData()
	--self:setMemberDetail()
	self:updateMemberData()
end

--测试用方法
function wnd_knightly_detective_member:testShowMemberInfo()
	g_i3k_ui_mgr:PopupTipMessage(string.format("member %s clueType %s", self._curMemberId, i3k_db_knightly_detective_members[self._curMemberId].clueType))
end

function wnd_create(layout)
	local wnd = wnd_knightly_detective_member.new()
	wnd:create(layout)
	return wnd
end
