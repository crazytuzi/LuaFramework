-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_addCrossFriends = i3k_class("wnd_addCrossFriends", ui.wnd_base)

--local LAYER_MFITEM = "ui/widgets/jiahaoyout"

function wnd_addCrossFriends:ctor()
	self.crossInfo = {}
end

function wnd_addCrossFriends:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.match_btn:onClick(self, self.onMatchNow)
	self._layout.vars.like_btn:onClick(self, self.onFriendLike)
	self._layout.vars.unlike_btn:onClick(self, self.onFriendUnlike)
end
--{matchInfo = matchInfo, applies = applies, dayRefreshTimes = dayRefreshTimes, openMatch = openMatch}
function wnd_addCrossFriends:refresh(crossInfo)
	self.crossInfo = crossInfo
	self:showBaseBank()
end

function wnd_addCrossFriends:showBaseBank()
	local widgets = self._layout.vars
	if self.crossInfo.openMatch == 0 then
		widgets.crossfr_item:setVisible(false)
		return
	end
	if self.crossInfo.openMatch ~= 0 and (not self.crossInfo.matchInfo or self.crossInfo.matchInfo.overview.id == 0) then
		widgets.crossfr_item:setVisible(false)
		widgets.matchnow_item:setVisible(true)
		--widgets.matchBtn_txt:setText("换一批")
		return
	end
	self:showCrossFriendInfo(self.crossInfo.matchInfo, true)
end

function wnd_addCrossFriends:timeLimitShowBank(refreshInfo)
	local widgets = self._layout.vars
	if refreshInfo and self.crossInfo.matchInfo then
		if refreshInfo.overview and self.crossInfo.matchInfo.overview then
			if refreshInfo.overview.id == self.crossInfo.matchInfo.overview.id then
				widgets.crossfr_item:setVisible(false)
				widgets.matchnow_item:setVisible(true)
			end
		end
	end
	--widgets.matchBtn_txt:setText("换一批")
end

function wnd_addCrossFriends:onFriendLike(sender)
	i3k_sbean.mood_diary_cross_friend_add_cross_friend(self.crossInfo.matchInfo.overview.id)
end

function wnd_addCrossFriends:onFriendUnlike(sender)
	i3k_sbean.mood_diary_cross_friend_ignore_cross_friend(self.crossInfo.matchInfo.overview.id, self.crossInfo.dayRefreshTimes)
end

function wnd_addCrossFriends:showCrossFriendInfo(matchInfo, isFisrtOpen, isMatchNow)
	local widgets = self._layout.vars
	self.crossInfo.openMatch = 1
	if matchInfo then
		if not isFisrtOpen then
			if not isMatchNow then	--立即匹配不消耗次数
				self.crossInfo.dayRefreshTimes = self.crossInfo.dayRefreshTimes + 1
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "setCrossFriendInfo", matchInfo, self.crossInfo.dayRefreshTimes, self.crossInfo.openMatch)
		end
		self.crossInfo.matchInfo = {}
		self.crossInfo.matchInfo = matchInfo
		--widgets.matchBtn_txt:setText("换一批")
		widgets.matchnow_item:setVisible(false)
		widgets.matchnow_label:setVisible(false)
		widgets.crossfr_item:setVisible(true)
		widgets.match_cnt:setText(string.format("匹配次数：%d/%d", self.crossInfo.dayRefreshTimes, i3k_db_mood_diary_cfg.crossFriendDayRefreshTime))
		local personInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
		--头像部分
		local headicon = matchInfo.overview.headIcon
		local BWType = matchInfo.overview.bwType
		local frameId = matchInfo.overview.headBorder
		widgets.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headicon, false))
		widgets.headframe:setImage(g_i3k_get_head_bg_path(BWType, frameId))
		--性别
		widgets.zhiye_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_sex[matchInfo.info.gender].sexIcon))
	
		widgets.name_label:setText(matchInfo.overview.name)
		widgets.constellation:setText(i3k_db_mood_diary_constellation[matchInfo.info.constellation].constellationName)
		widgets.constellation_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_constellation[matchInfo.info.constellation].constellationIcon))
	
		--爱好
		local hobbyIndex = 1
		
		if next(matchInfo.info.hobbies) then
			for k,v in pairs(matchInfo.info.hobbies) do
				if v then
					widgets["hobby"..hobbyIndex]:setText(i3k_db_mood_diary_hobby[k].hobbyName)
					hobbyIndex = hobbyIndex + 1
				end
			end
		end
		
		if next(matchInfo.info.diyHobbies) then
			for k,v in ipairs(matchInfo.info.diyHobbies) do
				widgets["hobby"..hobbyIndex]:setText(v)
				hobbyIndex = hobbyIndex + 1
			end
		end
		
		if hobbyIndex <= 4 then
			for i = hobbyIndex, 4 do
				widgets["hobby_item"..i]:setVisible(false)
			end
		end
		
		
		--设置好友宣言
		widgets.declaration_desc:setText(matchInfo.info.signature)
		
		for i,e in pairs(matchInfo.info.testScore) do
			for _,x in ipairs(i3k_db_mood_diary_constellation_test_result) do
				if x.testResultGroupID == i and x.matchType == matchInfo.info.gender and matchInfo.info.testScore[i] >= x.countFloor and matchInfo.info.testScore[i] <= x.countCelling then
					--local Item = require(LAYER_PERSONLABEL)()
					widgets.person_pic:setImage(g_i3k_db.i3k_db_get_icon_path(x.resultForDisplayIcon))
					--widgets.person_scroll:addItem(Item)
				end
			end
		end
		
		--设置好友缘分
		for k,v in ipairs(i3k_db_mood_diary_constellation_fate) do
			if v.constellationID == personInfo.self.constellation and v.constellationIDOther == matchInfo.info.constellation then
				widgets.percent_label:setText(string.format("%d%%", v.constellationCount))
				widgets.percent:setPercent(v.constellationCount)
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("没有可匹配的玩家")
		widgets.crossfr_item:setVisible(false)
		widgets.matchnow_item:setVisible(true)
		--widgets.matchBtn_txt:setText("换一批")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "setCrossFriendInfo", matchInfo, self.crossInfo.dayRefreshTimes, self.crossInfo.openMatch)
	end
end

--喜欢或者忽略好友的刷新函数
function wnd_addCrossFriends:likeOrDisLikeRefresh()
	local widgets = self._layout.vars
	if self.crossInfo.dayRefreshTimes >= i3k_db_mood_diary_cfg.crossFriendDayRefreshTime then
		g_i3k_ui_mgr:PopupTipMessage("今日匹配次数已用完")
		widgets.crossfr_item:setVisible(false)
		widgets.matchnow_item:setVisible(true)
		widgets.matchnow_label:setVisible(false)
		--widgets.matchBtn_txt:setText("换一批")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "setCrossFriendInfo", nil, self.crossInfo.dayRefreshTimes, self.crossInfo.openMatch)
	else
		i3k_sbean.mood_diary_cross_friend_refresh_cross_friend()
	end
end

function wnd_addCrossFriends:onMatchNow(sender)
	local widgets = self._layout.vars
	if self.crossInfo.openMatch ~= 0 then
		--不是第一次进来，换一批
		if self.crossInfo.dayRefreshTimes >= i3k_db_mood_diary_cfg.crossFriendDayRefreshTime then
			g_i3k_ui_mgr:PopupTipMessage("今日匹配次数已用完")
		else
			i3k_sbean.mood_diary_cross_friend_refresh_cross_friend()
		end
	else
		--第一次进来，立即匹配逻辑
		i3k_sbean.mood_diary_cross_friend_match_now()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_addCrossFriends.new()
	wnd:create(layout, ...)
	return wnd;
end
