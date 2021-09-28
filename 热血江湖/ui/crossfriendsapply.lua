-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_CrossFriendsApply = i3k_class("wnd_CrossFriendsApply", ui.wnd_base)

local LAYER_CROSSAPPLY = "ui/widgets/kuafuhaoyousqt"

function wnd_CrossFriendsApply:ctor()
	self.friendApply = {}
end

function wnd_CrossFriendsApply:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end


function wnd_CrossFriendsApply:refresh(applies)
	self.friendApply = applies
	self:showCrossFriendApply(applies)
end

--同意或者忽略好友协议回来的刷新函数
function wnd_CrossFriendsApply:refreshApplyList(roleID)
	for k,v in ipairs(self.friendApply) do
		if v.overview.id == roleID then
			table.remove(self.friendApply, k)
		end
	end
	self:showCrossFriendApply(self.friendApply)
end

--好友申请别人的刷新函数
function wnd_CrossFriendsApply:refreshApplyListOther(friendApply)
	table.insert(self.friendApply, friendApply)
	self:showCrossFriendApply(self.friendApply)
end

function wnd_CrossFriendsApply:showCrossFriendApply(applies)
	local widgets = self._layout.vars
	widgets.crossfr_scroll:removeAllChildren()
	if next(applies) then
		widgets.noFr_label:setVisible(false)
		for k,v in ipairs(applies) do
			local Item = require(LAYER_CROSSAPPLY)()
			local personInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
			--头像部分
			local headicon = v.overview.headIcon
			local BWType = v.overview.bwType
			local frameId = v.overview.headBorder
			Item.vars.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headicon, false))
			Item.vars.headframe:setImage(g_i3k_get_head_bg_path(BWType, frameId))
			--性别
			Item.vars.zhiye_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_sex[v.info.gender].sexIcon))
	
			Item.vars.name_label:setText(v.overview.name)
			Item.vars.constellation:setText(i3k_db_mood_diary_constellation[v.info.constellation].constellationName)
			Item.vars.constellation_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_constellation[v.info.constellation].constellationIcon))
			
			--爱好
			local hobbyIndex = 1
		
			if next(v.info.hobbies) then
				for i,e in pairs(v.info.hobbies) do
					if e then
						Item.vars["hobby"..hobbyIndex]:setText(i3k_db_mood_diary_hobby[i].hobbyName)
						hobbyIndex = hobbyIndex + 1
					end
				end
			end
		
			if next(v.info.diyHobbies) then
				for i,e in ipairs(v.info.diyHobbies) do
					Item.vars["hobby"..hobbyIndex]:setText(e)
					hobbyIndex = hobbyIndex + 1
				end
			end
			
			if hobbyIndex <= 4 then
				for i = hobbyIndex, 4 do
					Item.vars["hobby_item"..i]:setVisible(false)
				end
			end
			
			--设置好友宣言
			Item.vars.declaration_desc:setText(v.info.signature)
			
			for i,e in pairs(v.info.testScore) do
				for _,x in ipairs(i3k_db_mood_diary_constellation_test_result) do
					if x.testResultGroupID == i and x.matchType == v.info.gender and v.info.testScore[i] >= x.countFloor and v.info.testScore[i] <= x.countCelling then
						--local Item = require(LAYER_PERSONLABEL)()
						Item.vars.person_pic:setImage(g_i3k_db.i3k_db_get_icon_path(x.resultForDisplayIcon))
						--widgets.person_scroll:addItem(Item)
					end
				end
			end
		
			--设置好友缘分
			for i,e in ipairs(i3k_db_mood_diary_constellation_fate) do
				if e.constellationID == personInfo.self.constellation and e.constellationIDOther == v.info.constellation then
					Item.vars.percent_label:setText(string.format("%d%%", e.constellationCount))
					Item.vars.percent:setPercent(e.constellationCount)
				end
			end
			Item.vars.agree_btn:onClick(self, self.onAgree, {friendInfo = v, index = k})
			Item.vars.disagree_btn:onClick(self, self.onDisagree, {friendInfo = v, index = k})
			widgets.crossfr_scroll:addItem(Item)
		end
	else
		widgets.noFr_label:setVisible(true)
		g_i3k_game_context:SetCrossFriendRed(false)
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CROSS_FRIEND)
	end
end

function wnd_CrossFriendsApply:onAgree(sender, roleInfo)
	i3k_sbean.mood_diary_cross_friend_cross_friend_apply_reply(1, roleInfo.friendInfo, roleInfo.index)
end

function wnd_CrossFriendsApply:onDisagree(sender, roleInfo)
	i3k_sbean.mood_diary_cross_friend_cross_friend_apply_reply(0, roleInfo.friendInfo, roleInfo.index)
end

function wnd_create(layout, ...)
	local wnd = wnd_CrossFriendsApply.new()
	wnd:create(layout, ...)
	return wnd;
end
