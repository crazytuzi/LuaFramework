-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_moodDiary = i3k_class("wnd_moodDiary", ui.wnd_base)

local LAYER_DIARYITEM = "ui/widgets/xinqingrijit1"
local LAYER_GIFTITEM = "ui/widgets/xinqingrijit2"
local LAYER_HOBBY = "ui/widgets/xinqingrijit3"
local LAYER_PERSONLABEL = "ui/widgets/xinqingrijit4"
local GIFTCOUNT = 7 -- 显示礼物数量

function wnd_moodDiary:ctor()
	self.moodDiary = {}
	self.friendData = {}
	self.opentype = 1
	self.curDecorate = 1
	self.getGifts = {}
	self.giftPage = 1
	self.personalInfo = {}
end

function wnd_moodDiary:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.write_diary:onClick(self, self.onWriteDiary)
	widgets.myFans_btn:onClick(self, self.onFansRank)
	widgets.otherFans_btn:onClick(self, self.onFansRank)
	widgets.gift_btn:onClick(self, self.onSendGift)
	widgets.addFriend_btn:onClick(self, self.onAddFriend)
	--widgets.beauty_btn:onClick(self, self.onBeauty)
	widgets.myShare_btn:onClick(self, self.onShareBtn)
	widgets.constellation_btn:onClick(self, self.onConstellationChoose)
	widgets.hobby_btn:onClick(self, self.onSetHobby)
	widgets.declaration_btn:onClick(self, self.onSetDeclaration)
	widgets.sexhelp_btn:onClick(self, self.onSexHelp)
	widgets.star_btn:onClick(self, self.personLabelHelp)
end

function wnd_moodDiary:refresh(opentype,moodDiary,personInfo)
	self.opentype = opentype
	self.moodDiary = moodDiary
	self.friendData = moodDiary.roleOverview
	self.personalInfo = personInfo
	self._layout.vars.beauty_btn:onClick(self, self.onBeauty)
	if moodDiary.curDecorate ~= 0 then
		self.curDecorate = moodDiary.curDecorate
	end
	self.getGifts = {}
	if moodDiary.receiveGifts then
		for k, v in pairs(moodDiary.receiveGifts) do
			for i, e in ipairs(i3k_db_mood_diary_gift) do
				if e.itemID == k then
					table.insert(self.getGifts, {id = k, count = v, sortID = i})
				end
			end
		end
	end
	table.sort(self.getGifts, function(a, b)
		return a.sortID > b.sortID
	end)
	self:updateData()
	self:setScrollEvent()
end

function wnd_moodDiary:onShowGiftBtn(sender, moodDiary)
	g_i3k_ui_mgr:OpenUI(eUIID_MoodDiaryShowGifts)
	g_i3k_ui_mgr:RefreshUI(eUIID_MoodDiaryShowGifts, moodDiary)
end

function wnd_moodDiary:cancelScroll()
	self._layout.vars.diary_scroll:cancelLoadEvent()
end

function wnd_moodDiary:setScrollEvent()
	self._layout.vars.diary_scroll:setLoadEvent(
	function ()
		i3k_sbean.mood_diary_get_diaries(self.opentype, #self.moodDiary.diaries, self.opentype == 2 and self.friendData.id or nil)
	end
	)
end

function wnd_moodDiary:onSexHelp(sender)
	local widgets = self._layout.vars
	if widgets.sex:isVisible() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17519))
	end
end

function wnd_moodDiary:personLabelHelp(sender)
	local widgets = self._layout.vars
	if widgets.test_result:isVisible() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17519))
	end
end

function wnd_moodDiary:onBeauty(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_MoodDiaryBeauty)
	g_i3k_ui_mgr:RefreshUI(eUIID_MoodDiaryBeauty, self.moodDiary)
end

function wnd_moodDiary:onAddFriend(sender)
	i3k_sbean.addFriend(self.friendData.id)
end

function wnd_moodDiary:onSendGift(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SendGift)
	g_i3k_ui_mgr:RefreshUI(eUIID_SendGift, self.friendData, self.moodDiary.curDecorate)
end

function wnd_moodDiary:onFansRank(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FansRank)
	g_i3k_ui_mgr:RefreshUI(eUIID_FansRank, self.moodDiary)
end

function wnd_moodDiary:onWriteDiary(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_DiaryContent)
	g_i3k_ui_mgr:RefreshUI(eUIID_DiaryContent,self.moodDiary)
end

function wnd_moodDiary:onShareBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_MoodDiaryShare)
	g_i3k_ui_mgr:RefreshUI(eUIID_MoodDiaryShare, self.moodDiary.curDecorate)
end

function wnd_moodDiary:onConstellationChoose(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SetConstellation)
	g_i3k_ui_mgr:RefreshUI(eUIID_SetConstellation, self.moodDiary.curDecorate)
end

function wnd_moodDiary:onSetHobby(sender)
	local personalInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
	g_i3k_ui_mgr:OpenUI(eUIID_SetHobby)
	g_i3k_ui_mgr:RefreshUI(eUIID_SetHobby, personalInfo, self.moodDiary.curDecorate)
end

function wnd_moodDiary:onSetDeclaration(sender)
	--local personalInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
	g_i3k_ui_mgr:OpenUI(eUIID_WriteDeclaration)
	g_i3k_ui_mgr:RefreshUI(eUIID_WriteDeclaration, self.moodDiary)
end

function wnd_moodDiary:updateData()
	local widgets = self._layout.vars
	local role_name = g_i3k_game_context:GetRoleName()
	local role_type = g_i3k_game_context:GetRoleType()
	local gcfg = g_i3k_db.i3k_db_get_general(role_type)
	local headicon = g_i3k_game_context:GetRoleHeadIconId()
	local BWType = g_i3k_game_context:GetTransformBWtype()
	local frameId = g_i3k_game_context:GetRoleHeadFrameId()
	local level = g_i3k_game_context:GetLevel()

	widgets.beauty_btn:setVisible(true)
	widgets.myFans_btn:setVisible(true)
	widgets.write_diary:setVisible(true)
	widgets.myShare_btn:setVisible(true)
	widgets.gift_btn:setVisible(false)
	widgets.otherFans_btn:setVisible(false)
	widgets.addFriend_btn:setVisible(false)

	if self.opentype == 2 then --1是自己，2是别人
		role_name = self.friendData.name
		role_type = self.friendData.type
		gcfg = g_i3k_db.i3k_db_get_general(role_type)
		headicon = self.friendData.headIcon
		BWType = self.friendData.bwType
		frameId = self.friendData.headBorder
		level = self.friendData.level
		widgets.beauty_btn:setVisible(false)
		widgets.myFans_btn:setVisible(false)
		widgets.write_diary:setVisible(false)
		widgets.myShare_btn:setVisible(false)
		widgets.gift_btn:setVisible(true)
		widgets.otherFans_btn:setVisible(true)
		widgets.addFriend_btn:setVisible(true)
		widgets.show_gift_btn:setVisible(false)
		widgets.constellation_btn:setTouchEnabled(false)
		widgets.hobby_btn:setTouchEnabled(false)
		widgets.declaration_btn:setVisible(false)
		widgets.sexhelp_btn:setTouchEnabled(false)
		widgets.star_btn:setTouchEnabled(false)
	else
		widgets.show_gift_btn:setVisible(true)
		self._layout.vars.show_gift_btn:onClick(self, self.onShowGiftBtn, self.moodDiary)
	end

	widgets.role_name:setText(role_name)
	widgets.zhiye_img:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
	widgets.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headicon, false))
	widgets.headframe:setImage(g_i3k_get_head_bg_path(BWType, frameId))
	widgets.level:setText("Lv." .. level)

	self:showPopularity()
	self:setPersonInfo()
	self:changeDecorateId()--这个方法放在最后
	--self:showReceivedGift()
end

function wnd_moodDiary:setPersonInfo()
	local widgets = self._layout.vars
	local personInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
	widgets.hobbyScroll:removeAllChildren()
	widgets.person_scroll:removeAllChildren()
	widgets.hobbyScroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	widgets.person_scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	--设置星座
	if self.opentype == 2 then --1是自己，2是别人
		widgets.choose_desc:setVisible(false)
		if not self.personalInfo.constellation or self.personalInfo.constellation == 0 then
			widgets.constellation_mine:setVisible(false)
			widgets.constellation_other:setVisible(true)
		else
			widgets.constellation_mine:setVisible(true)
			widgets.constellation_other:setVisible(false)
			widgets.constellation_desc:setText(i3k_db_mood_diary_constellation[self.personalInfo.constellation].constellationName)
			widgets.constellation_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_constellation[self.personalInfo.constellation].constellationIcon))
		end
	else
		self.personalInfo = {}
		self.personalInfo = personInfo.self
		if personInfo.self.constellation == 0 then
			widgets.constellation_mine:setVisible(false)
		else
			widgets.constellation_mine:setVisible(true)
			widgets.choose_desc:setVisible(false)
			widgets.constellation_desc:setText(i3k_db_mood_diary_constellation[personInfo.self.constellation].constellationName)
			widgets.constellation_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_constellation[self.personalInfo.constellation].constellationIcon))
		end
		widgets.constellation_other:setVisible(false)
	end
	--设置爱好
	if next(self.personalInfo.hobbies) or next(self.personalInfo.diyHobbies) then
		widgets.hobby:setVisible(false)
		for k,v in pairs(self.personalInfo.hobbies) do
			local Item = require(LAYER_HOBBY)()
			if v then
				Item.vars.desc:setText(i3k_db_mood_diary_hobby[k].hobbyName)
			end
			widgets.hobbyScroll:addItem(Item)
		end
			
		for k,v in ipairs(self.personalInfo.diyHobbies) do
			local Item = require(LAYER_HOBBY)()
			Item.vars.desc:setText(v)
			widgets.hobbyScroll:addItem(Item)
		end
	else
		widgets.hobby:setVisible(true)
	end
	--设置人物标签
--	for k,v in pairs(self.personalInfo.testScore) do
	if next(self.personalInfo.testScore) then
		widgets.test_result:setVisible(false)
		for i,e in pairs(self.personalInfo.testScore) do
			if e then
				for k,v in ipairs(i3k_db_mood_diary_constellation_test_result) do
					if v.testResultGroupID == i and v.matchType == self.personalInfo.gender and self.personalInfo.testScore[i] >= v.countFloor and self.personalInfo.testScore[i] <= v.countCelling then
						local Item = require(LAYER_PERSONLABEL)()
						Item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.resultForDisplayIcon))
						widgets.person_scroll:addItem(Item)
					end
				end
			end
		end
	else
		widgets.test_result:setVisible(true)
	end
	--设置性别
	if self.personalInfo.gender == 0 or not self.personalInfo.gender then
		widgets.sex:setVisible(true)
		widgets.sex_icon:setVisible(false)
	else
		widgets.sex:setVisible(false)
		--widgets.sex:setText(i3k_db_mood_diary_sex[self.personalInfo.gender].sexName)
		widgets.sex_icon:setVisible(true)
		widgets.sex_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_sex[self.personalInfo.gender].sexIcon))
	end
	--设置好友宣言
	if self.personalInfo.signature == "" then
		widgets.declaration_desc:setText("暂未填写")
	else
		widgets.declaration_desc:setText(self.personalInfo.signature)
	end
end

function wnd_moodDiary:showPopularity()
	local widgets = self._layout.vars
	widgets.contri_value:setText(self.moodDiary.popularity)
end

function wnd_moodDiary:showDiaryContent(decorateId)
	local widgets = self._layout.vars
	widgets.diary_scroll:removeAllChildren()
	if #self.moodDiary.diaries > 0 then
		widgets.none_diary:hide()
		for i=1, #self.moodDiary.diaries do
			local Item = require(LAYER_DIARYITEM)()
			Item.vars.delete_btn:setVisible(false)
			Item.vars.showdelete_btn:onClick(self,self.onShowDeleteBtn,Item)
			Item.vars.delete_btn:onClick(self,self.onDeleteDiary,self.moodDiary.diaries[i].time)
			Item.vars.diaryContent:setText(self.moodDiary.diaries[i].msg)
			Item.vars.date:setText(g_i3k_get_YearAndDayAndTime(self.moodDiary.diaries[i].time))
			Item.vars.date:setTextColor(i3k_db_mood_diary_decorate[decorateId].diariesColor)
			Item.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].diariesBottom))
			Item.vars.diaryContent:setTextColor(i3k_db_mood_diary_decorate[decorateId].diariesColor)
			widgets.diary_scroll:addItem(Item)
		end
		--[[if moodDiary then
			widgets.diary_scroll:jumpToChildWithIndex(startNum-3)
		end--]]
	else
		widgets.none_diary:show()
		widgets.none_diary:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].noneDiaryIcon))
		widgets.none_text:setTextColor(i3k_db_mood_diary_decorate[decorateId].noneDiaryTextColor)
	end
end

function wnd_moodDiary:showNextDiary(moodDiary)
	local widgets = self._layout.vars
	local startNum = #self.moodDiary.diaries
	table.insertto(self.moodDiary.diaries,moodDiary)
	if moodDiary then
		--widgets.none_diary:hide()
		for i=1, #moodDiary do
			local Item = require(LAYER_DIARYITEM)()
			Item.vars.delete_btn:setVisible(false)
			Item.vars.showdelete_btn:onClick(self,self.onShowDeleteBtn,Item)
			Item.vars.delete_btn:onClick(self,self.onDeleteDiary,moodDiary[i].time)
			Item.vars.diaryContent:setText(moodDiary[i].msg)
			Item.vars.date:setText(g_i3k_get_YearAndDayAndTime(moodDiary[i].time))
			Item.vars.date:setTextColor(i3k_db_mood_diary_decorate[self.curDecorate].diariesColor)
			Item.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.curDecorate].diariesBottom))
			Item.vars.diaryContent:setTextColor(i3k_db_mood_diary_decorate[self.curDecorate].diariesColor)
			widgets.diary_scroll:addItem(Item)
		end
		g_i3k_coroutine_mgr:StartCoroutine(function()
			g_i3k_coroutine_mgr.WaitForSeconds(0.1)
			widgets.diary_scroll:jumpToChildWithIndex(startNum)
		end
		)
		--local startNum = #self.moodDiary.diaries
	end

end

function wnd_moodDiary:onShowDeleteBtn(sender,Item)
	if self.opentype == 1 then --1是自己，2是别人
		if Item.vars.delete_btn:isVisible() then
			Item.vars.delete_btn:setVisible(false)
		else
			Item.vars.delete_btn:setVisible(true)
		end
	end
end

function wnd_moodDiary:showReceivedGift(decorateId)
	local widgets = self._layout.vars
	widgets.gift_scroll:removeAllChildren()
	widgets.front_btn:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].nextPageIcon))
	widgets.next_btn:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].nextPageIcon))
	for i = 1, GIFTCOUNT do
		local node = require(LAYER_GIFTITEM)()
		node.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].giftBottom))
		local data = self.getGifts[(self.giftPage - 1) * GIFTCOUNT + i]
		if data then
			local rank = g_i3k_db.i3k_db_get_common_item_rank(data.id)
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(data.id, g_i3k_game_context:IsFemaleRole()))
			node.vars.item_icon:onClick(self, self.onItemInfo, data.id)
			node.vars.count:setText(data.count)
			node.vars.count:setTextColor(i3k_db_mood_diary_decorate[decorateId].giftCountColor)
			node.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].giftRankIcon[rank]))
		else
			node.vars.item_icon:hide()
			node.vars.bg:hide()
			node.vars.count:hide()
		end
		widgets.gift_scroll:addItem(node)
	end
	if self.giftPage > 1 then
		widgets.front_btn:onClick(self, self.onFrontBtn)
	end
	if #self.getGifts > self.giftPage * GIFTCOUNT then
		widgets.next_btn:onClick(self, self.onNextBtn)
	end
end

function wnd_moodDiary:onDeleteDiary(sender,date)
	local function callback(isOK)
		if isOK then
			i3k_sbean.mood_diary_delete(date)
		end
	end
	local msg = i3k_get_string(17187)
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

function wnd_moodDiary:changeDecorateId(decorateId)
	if decorateId then
		self.curDecorate = decorateId
	end
	self:changeDecorate(self.curDecorate)
end

function wnd_moodDiary:changeDecorate(decorateId)
	local widgets = self._layout.vars
	widgets.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].backGroundIcon))
	widgets.gift_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].giftBtnIcon))
	widgets.myFans_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].fansBtn))
	widgets.otherFans_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].fansBtn))
	widgets.addFriend_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].addFriendsBtn))
	widgets.write_diary:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].writeBtn))
	widgets.beauty_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].beautyBtn))
	widgets.myShare_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].shareBtn))
	widgets.close_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].closeBtn))
	widgets.contri_value:setTextColor(i3k_db_mood_diary_decorate[decorateId].popularityColor)
	widgets.role_name:setTextColor(i3k_db_mood_diary_decorate[decorateId].nameColor)
	widgets.level:setTextColor(i3k_db_mood_diary_decorate[decorateId].levelColor)
	widgets.show_gift_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].showGiftBtnIcon))
	widgets.choose_desc:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].constellationTextBg))
	widgets.constellationArrows:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].constellationArrows))
	widgets.constellationIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].constellationIcon))
	widgets.luckychanceSex:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].luckychanceSex))
	widgets.luckychanceHobby:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].luckychanceHobby))
	widgets.luckychanceWish:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].luckychanceWish))
	widgets.declaration:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].luckychanceDeclaration))
	widgets.declarationBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].declarationBg))
	widgets.constellation_desc:setTextColor(i3k_db_mood_diary_decorate[decorateId].constellationTextColor)
	widgets.constellation_other:setTextColor(i3k_db_mood_diary_decorate[decorateId].notWriteTextColor)
	widgets.sex:setTextColor(i3k_db_mood_diary_decorate[decorateId].notWriteTextColor)
	widgets.hobby:setTextColor(i3k_db_mood_diary_decorate[decorateId].notWriteTextColor)
	widgets.test_result:setTextColor(i3k_db_mood_diary_decorate[decorateId].notWriteTextColor)
	if self.personalInfo.signature == "" then
		widgets.declaration_desc:setTextColor(i3k_db_mood_diary_decorate[decorateId].notWriteTextColor)
	else
		widgets.declaration_desc:setTextColor(i3k_db_mood_diary_decorate[decorateId].constellationTextColor)
	end
	self:showReceivedGift(decorateId)
	self:showDiaryContent(decorateId)
end

function wnd_moodDiary:onFrontBtn(sender)
	if self.giftPage > 1 then
		self.giftPage = self.giftPage - 1
		self:showReceivedGift(self.curDecorate)
	end
end

function wnd_moodDiary:onNextBtn(sender)
	if #self.getGifts > self.giftPage * GIFTCOUNT then
		self.giftPage = self.giftPage + 1
		self:showReceivedGift(self.curDecorate)
	end
end

function wnd_moodDiary:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_moodDiary.new()
	wnd:create(layout)
	return wnd
end
