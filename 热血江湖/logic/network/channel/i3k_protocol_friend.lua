------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
-- 好友界面信息同步
function i3k_sbean.syncFriend(isOpenUI, callback)
	local data = i3k_sbean.friend_sync_req.new()
	data.isOpenUI = isOpenUI
	data.callback = callback
	i3k_game_send_str_cmd(data,i3k_sbean.friend_sync_res.getName())
end
-- 好友界面信息同步回应
function i3k_sbean.friend_sync_res.handler(bean,req)
	--self.friends:		map[int32, FriendInfo]
	--self.dayVitTakeTimes:		int32
	--self.vitLvl:		int32
	--self.vitExp:		int32
	--self.personalMsg:		string
	--self.charm:		int32

	local Data = {}
	Data.dayVitTakeTimes = bean.dayVitTakeTimes
	Data.vitLvl = bean.vitLvl
	Data.vitExp = bean.vitExp
	Data.personalMsg = bean.personalMsg
	Data.charm = bean.charm
	g_i3k_game_context:setAutoDelData(1, bean.isClear > 0)
	--同步数据
	g_i3k_game_context:SetFriendsData(bean.friends)
	g_i3k_game_context:setMyselfData(Data)
	--刷新界面
	if req then
		if req.isOpenUI == 1 then
			g_i3k_ui_mgr:OpenUI(eUIID_Friends)
			g_i3k_ui_mgr:RefreshUI(eUIID_Friends)
		elseif req.isOpenUI == 2 then --组队邀请
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_InviteFriends,"onShowFriendsList")
		end
		if req.callback then
			req.callback()
		end
	end
	DCEvent.onEvent("查看好友")
end


-- 获取好友列表
--[[function i3k_sbean.listFriend()
	local data = i3k_sbean.friend_list_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.friend_list_res.getName())
end--]]
-- 获取好友列表的响应
--[[function i3k_sbean.friend_list_res.handler(bean,req)
	--self.friends:		vector[FriendOverview]
	local friends = bean.friends
	local friendsData = g_i3k_game_context:GetFriendsData()
	for k,v in pairs(friends) do
		local findData = g_i3k_game_context:GetFriendsDataByID(v.overview.id)
		if findData == nil then
			table.insert(friendsData,v)
		else
			local keyTab ={}
			for i = #friendsData,1,-1 do
				if v.overview.id == friendsData[i].overview.id then
					keyTab[i] = v
					table.remove(friendsData,i)
				end
			end
			for k1,v1 in pairs(keyTab) do
				table.insert(friendsData,k1,v1)
			end
		end
	end
	g_i3k_game_context:SetFriendsData(friendsData)--刷新本地
	if isOpenUI == 0 then
		i3k_sbean.syncFriend()
	else
		isOpenUI = 0
	end
end--]]

-- 获取最新加我为好友的列表
function i3k_sbean.plusListFriend(noFriend)
	local data = i3k_sbean.friend_pluslist_req.new()
	data.noFriend = noFriend
	i3k_game_send_str_cmd(data,i3k_sbean.friend_pluslist_res.getName())
end

function i3k_sbean.friend_pluslist_res.handler(bean,req)
	--self.nears:		vector[RoleOverview]
	local recentfriends = bean.nears
	local isRecommoned = true
	if recentfriends then
		local count = #recentfriends
		if count>=0 then
			--刷新数据
			local num = 0
			--[[for k,v in pairs(recentfriends) do
				local oldData = g_i3k_game_context:GetRecommendList()
				num = #oldData
				if num == RecommonFriendsNum then
					break;
				end
				local value1 = g_i3k_game_context:GetRecommendDataById(v.id)
				local value2 = g_i3k_game_context:GetFriendsDataByID(v.id)
				if value1 == nil then
					if value2 == nil then
						g_i3k_game_context:addRecommendData(v,1)
					end
				else
					local oldData = g_i3k_game_context:GetRecommendList()
					local keyTab ={}
					for i = #oldData,1,-1 do
						if v.id == oldData[i].id then
							keyTab[i] = v
							v.flag = 1
							table.remove(oldData,i)
						end
					end
					for k1,v1 in pairs(keyTab) do
						table.insert(oldData,k1,v1)
					end
					g_i3k_game_context:SetRecommendList1(oldData)
				end
			end--]]
			g_i3k_game_context:SetRecommendList1(nil)
			for k,v in pairs(recentfriends) do
				g_i3k_game_context:addRecommendData(v,1)
				local oldData = g_i3k_game_context:GetRecommendList()
				num = #oldData
				if num == RecommonFriendsNum then
					break;
				end
			end

			if num < RecommonFriendsNum then
				isRecommoned = false
				i3k_sbean.recommendFriend(not req.noFriend)
			end
		end
	end
	if isRecommoned then
		g_i3k_game_context:redirectToAddFriend(not req.noFriend)
	end
end

-- 获取系统推荐的列表
function i3k_sbean.recommendFriend(isHaveFriend)
	local data = i3k_sbean.friend_recommend_req.new()
	data.isHaveFriend = isHaveFriend
	i3k_game_send_str_cmd(data,i3k_sbean.friend_recommend_res.getName())
end
-- 获取系统推荐的列表的响应
function i3k_sbean.friend_recommend_res.handler(bean,req)
	--self.recommends:		vector[RoleOverview]
	local recommends = bean.recommends
	if recommends then
		local count = #recommends
		if count>0 then
			local roleID = g_i3k_game_context:GetRoleId()
			for k,v in pairs(recommends) do
				local oldData = g_i3k_game_context:GetRecommendList()
				if oldData and #oldData >= RecommonFriendsNum then
					break;
				end
				g_i3k_game_context:addRecommendData(v,0)
				--[[if v.id ~= roleID then
					local value1 = g_i3k_game_context:GetRecommendDataById(v.id)
					local value2 = g_i3k_game_context:GetFriendsDataByID(v.id)
					if value1 == nil then
						if value2 == nil then
--							g_i3k_ui_mgr:PopupTipMessage("推荐成功")
							g_i3k_game_context:addRecommendData(v,0)
						end
					else
						local oldData = g_i3k_game_context:GetRecommendList()
						local keyTab ={}
						for i = #oldData,1,-1 do
							if v.id == oldData[i].id then
								keyTab[i] = v
								v.flag = 0
								table.remove(oldData,i)
							end
						end
						for k1,v1 in pairs(keyTab) do
							table.insert(oldData,k1,v1)
						end
						g_i3k_game_context:SetRecommendList1(oldData)
					end
				end--]]
			end
		else
			local oldData = g_i3k_game_context:GetRecommendList()
			if #oldData == 0 then
				g_i3k_ui_mgr:PopupTipMessage("没有可推荐的好友")
			end
		end
	end
	g_i3k_game_context:redirectToAddFriend(req.isHaveFriend)
end


-- 添加好友
function i3k_sbean.addFriend(playerId, isNull)
	local value = g_i3k_game_context:GetFriendsDataByID(playerId)
	if value then
		g_i3k_ui_mgr:PopupTipMessage("已加为好友")
		return
	end
	if g_i3k_game_context:isBlackFriend(playerId) then
		return g_i3k_ui_mgr:PopupTipMessage("玩家在您的黑名单，不能添加好友")
	end
	local FriendOverview = g_i3k_game_context:GetFriendsData()
	local num = #FriendOverview
	local roleId = g_i3k_game_context:GetRoleId()
	if playerId == roleId then
		g_i3k_ui_mgr:PopupTipMessage("不能加自己为好友")
	elseif num >= i3k_db_common.friends_about.friendMaxCount then
		g_i3k_ui_mgr:PopupTipMessage("好友人数已达上限")
	else
		local data = i3k_sbean.friend_add_req.new()
		data.friendId = playerId
		data.isNull = isNull
		i3k_game_send_str_cmd(data,i3k_sbean.friend_add_res.getName())
	end
end
-- 添加好友回应
function i3k_sbean.friend_add_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
		--加好友成功
		g_i3k_game_context:deleteRecommendData(req.friendId)
		local isSend = true
		local friendsUI = g_i3k_ui_mgr:GetUI(eUIID_Friends)
		if friendsUI then
			if friendsUI.state == 1 then
				isSend = false
				i3k_sbean.syncFriend(1)
			end
		end
		--外部加好友刷新
		if isSend then
			i3k_sbean.syncFriend(0)
		end
		if friendsUI then
			if not req.isNull then
			g_i3k_ui_mgr:OpenUI(eUIID_AddFriends)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_AddFriends,"updateMakefrData")
			end
		end
		g_i3k_ui_mgr:PopupTipMessage("加好友成功")
		DCEvent.onEvent("添加好友")
	elseif ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("好友人数已达上限")
	elseif ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("玩家在您的黑名单，不能添加好友")
	elseif ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("您在对方的黑名单，不能添加好友")
	else
		--加好友失败
		g_i3k_ui_mgr:PopupTipMessage("加好友失败")
	end
end

-- 是否同意添加好友
function i3k_sbean.agreeaddFriend(playerId, isIgnoreFriendInvite)
	--self.friendId:		int32
	local data = i3k_sbean.friend_agreeadd_req.new()
	data.friendId = playerId
	data.isIgnoreFriendInvite = isIgnoreFriendInvite
	i3k_game_send_str_cmd(data,i3k_sbean.friend_agreeadd_res.getName())
end
-- 是否同意添加好友回应
function i3k_sbean.friend_agreeadd_res.handler(bean,req)
	--self.ok:		int32
	g_i3k_game_context:removeInviteItem(req.friendId, g_INVITE_TYPE_FRIEND)
	local ok = bean.ok
	if ok == 2 then 
		--g_i3k_ui_mgr:PopupTipMessage("遮罩成功")
	elseif ok > 0 then
		g_i3k_game_context:deleteRecommendData(req.friendId)
		local isSend = true
		local friendsUI = g_i3k_ui_mgr:GetUI(eUIID_Friends)
		if friendsUI then
			if friendsUI.state == 1 then
				isSend = false
				i3k_sbean.syncFriend(1)
			end
		end
		--外部加好友刷新
		if isSend then
			i3k_sbean.syncFriend(0)
		end
		g_i3k_ui_mgr:PopupTipMessage("同意添加好友成功")
	elseif ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("已经是好友了")
	elseif ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("已经不是好友了")
	elseif ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("好友人数已达上限")
	end
end

-- 通知被加好友回应
function i3k_sbean.friend_add_push.handler(bean)
	--self.friendId:		int32
	--self.friendName:		string
	local playerName = bean.friendName
	local playerId = bean.friendId
	local value = g_i3k_game_context:GetFriendsDataByID(playerId)
	if value == nil then
		--[[local callfunction = function(ok)
			if ok then
				i3k_sbean.agreeaddFriend(playerId)
			end
		end
		local msg = string.format("是否同意%s%s", playerName ,"添加你为好友？")
		g_i3k_ui_mgr:ShowCustomMessageBox2("同意", "拒绝", msg, callfunction)--]]
		if bean.hide then --亲密关系
		g_i3k_logic:OpenReceiveFriendInviteUI(playerId, playerName)
		else
			local acceptfunc = function()
				local ignoreRequestInLoad = g_i3k_game_context:getInviteListSettting(g_INVITE_SET_FRIEND)
				i3k_sbean.agreeaddFriend(playerId, ignoreRequestInLoad and 1 or 0)
			end
			local refusefunc = function()
				if g_i3k_game_context:getInviteListSettting(g_INVITE_SET_FRIEND) then
					i3k_sbean.agreeaddFriend(0, 1)
				end
				g_i3k_game_context:removeInviteItem(playerId, g_INVITE_TYPE_FRIEND)
			end
			local desc = i3k_get_string(1814, playerName)
			local yes_name = i3k_get_string(1815)
			local no_name = i3k_get_string(1816)
			g_i3k_game_context:addInviteItem(g_INVITE_TYPE_FRIEND, bean, acceptfunc, refusefunc, nil, playerId, desc, yes_name, no_name)
		end
	end
end


-- 好友删除
function i3k_sbean.deleteFriend(playerID)
	local data = i3k_sbean.friend_delete_req.new()
	--self.friendId:		int32
	data.friendId = playerID
	i3k_game_send_str_cmd(data,i3k_sbean.friend_delete_res.getName())
end
-- 好友删除回应
function i3k_sbean.friend_delete_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
		--刷新界面
		local overview = g_i3k_game_context:GetFrRoleOverviewById(req.friendId)
		--好友列表数据刷新
		g_i3k_game_context:deleteOneFriend(req.friendId)
		--推荐好友数据刷新
		local value =  g_i3k_game_context:GetRecommendDataById(req.friendId)
		if value == nil then
			g_i3k_game_context:addRecommendData(overview,0)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_Friends)
--		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateFriendsData")
		g_i3k_ui_mgr:PopupTipMessage("好友删除成功")

		DCEvent.onEvent("删除好友")
	else
		--加好友失败
		g_i3k_ui_mgr:PopupTipMessage("好友删除失败")
	end
end

-- 好友搜索
function i3k_sbean.searchFriend(playerName)
	local data = i3k_sbean.friend_search_req.new()
	--self.name:		string
	data.name = playerName
	i3k_game_send_str_cmd(data,i3k_sbean.friend_search_res.getName())
end
-- 好友搜索回应
function i3k_sbean.friend_search_res.handler(bean,req)
	--self.overview:		RoleOverview
	local overview = bean.overview
	if overview then
		--刷新界面
		local value = g_i3k_game_context:GetRecommendDataById(overview.id)
		if value == nil then
			g_i3k_game_context:addRecommendData(overview,2)
		end
		g_i3k_ui_mgr:PopupTipMessage("搜索成功")
		g_i3k_ui_mgr:OpenUI(eUIID_AddFriends)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AddFriends,"updateMakefrData")
	else
		--搜索失败
		g_i3k_ui_mgr:PopupTipMessage("不存在该好友")
	end
end

--设置好友关注度
function i3k_sbean.setFriendsFocus(playerID,flag)
	--self.friendId:		int32
	--self.value:		int32
	local data = i3k_sbean.friend_setfocus_req.new()
	data.friendId = playerID
	data.value = flag
	i3k_game_send_str_cmd(data,i3k_sbean.friend_setfocus_res.getName())
end

--好友关注度回应
function i3k_sbean.friend_setfocus_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
		local addValue = i3k_db_common.friends_about.attention_add
		local atten = g_i3k_game_context:GetfriendsAttention(req.friendId)
		local popId = 301
		if req.value == 1 then
			popId = 301
			atten = atten + addValue
		elseif req.value == -1 then
			popId = 302
			atten = atten - addValue
		end
		local overview = g_i3k_game_context:GetFrRoleOverviewById(req.friendId)
		if overview then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(popId,overview.name,atten))
		end
		g_i3k_game_context:SetfriendsAttention(atten,req.friendId)
		g_i3k_ui_mgr:RefreshUI(eUIID_Friends)
--		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateFriendsData")
	else
--		g_i3k_ui_mgr:PopupTipMessage("设置失败")
	end
end


-- 好友送体力
function i3k_sbean.giveVitFriend(playerId)
	--self.friendId:		int32
	local data = i3k_sbean.friend_givevit_req.new()
	data.friendId = playerId
	i3k_game_send_str_cmd(data,i3k_sbean.friend_givevit_res.getName())
end
--好友送体力回应
function i3k_sbean.friend_givevit_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
		--赠送体力成功
		local allData = g_i3k_game_context:GetFriendsData()
		for i,e in ipairs(allData) do
			if e.fov.overview.id == req.friendId then
				e.sendVit = ok
			end
		end
		g_i3k_game_context:SetFriendsData(allData)

		local data = g_i3k_game_context:GetFriendsDataByID(req.friendId)
		if data then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(363,data.fov.overview.name))
		end
		--g_i3k_ui_mgr:RefreshUI(eUIID_Friends)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateUI")
	else
		--赠送体力失败
		if ok == -1 then
			g_i3k_ui_mgr:PopupTipMessage("您今天已经给对方赠送过体力了")
		elseif ok == -2 then
			g_i3k_ui_mgr:PopupTipMessage("已经不是好友")
		elseif ok == -4 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(477))
		else
			g_i3k_ui_mgr:PopupTipMessage("赠送体力失败")
		end
	end
end

-- 好友接收体力
function i3k_sbean.receiveVitFriend(fidTab)
	local data = i3k_sbean.friend_receivevit_req.new()
	data.fids = fidTab
	i3k_game_send_str_cmd(data,i3k_sbean.friend_receivevit_res.getName())
end
--好友接收体力回应
function i3k_sbean.friend_receivevit_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
		--接收体力成功
		g_i3k_ui_mgr:PopupTipMessage("成功领取鸡翅")
		local allData = g_i3k_game_context:GetFriendsData()
		local count = 0
		for k,v in pairs(req.fids) do
			for i,e in ipairs(allData) do
				if e.fov.overview.id == k then
					e.receiveVit = 0
					count = count+1
				end
			end
		end
		g_i3k_game_context:SetFriendsData(allData)
		local myData = g_i3k_game_context:getMyselfData()
		myData.dayVitTakeTimes = myData.dayVitTakeTimes+count
		local ExpaddValue = i3k_db_common.friends_about.getExperence
		myData.vitExp = myData.vitExp + ExpaddValue*count
		local nextdata = g_i3k_db.i3k_db_get_friends_award(myData.vitLvl+1)
		if nextdata then
			if myData.vitExp >= nextdata.awardExp_hight then
				myData.vitLvl = myData.vitLvl+1
				myData.vitExp = myData.vitExp - nextdata.awardExp_hight
			end
		end
		--g_i3k_ui_mgr:RefreshUI(eUIID_Friends)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateUI")
	else
		--接收体力失败
		g_i3k_ui_mgr:PopupTipMessage("领取鸡翅失败")
	end
end

-- 接收一个好友的体力
--[[function i3k_sbean.receivesingleVitFriend(playerID)
	--self.friendId:		int32
	local data = i3k_sbean.friend_receivevitsingle_req.new()
	data.friendId = playerID
	i3k_game_send_str_cmd(data,i3k_sbean.friend_receivevitsingle_res.getName())
end
--接收一个好友的体力回应
function i3k_sbean.friend_receivevitsingle_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
		--接收体力成功
		i3k_sbean.listFriend()
--		i3k_sbean.syncFriend()
		local data = g_i3k_game_context:GetFriendsDataByID(req.friendId)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(364,data.overview.name))
	else
		--接收体力失败
		g_i3k_ui_mgr:PopupTipMessage("接收体力失败")
	end
end--]]

-- 更新玩家心情
function i3k_sbean.updatePlayerMsg(personMsg)
	--self.msg:		string
	local data = i3k_sbean.friend_changemsg_req.new()
	data.msg = personMsg
	i3k_game_send_str_cmd(data,i3k_sbean.friend_changemsg_res.getName())
end
--更新玩家心情回应
function i3k_sbean.friend_changemsg_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
--		g_i3k_ui_mgr:PopupTipMessage("更改成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("更改失败")
	end
end

-- 更改玩家头像
function i3k_sbean.updatePlayerIcon(headId)
	--self.headId:		int16
	local data = i3k_sbean.friend_changehead_req.new()
	data.headId = headId
	i3k_game_send_str_cmd(data,i3k_sbean.friend_changehead_res.getName())
end
--更改玩家头像回应
function i3k_sbean.friend_changehead_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
		i3k_sbean.item_unlock_head()
		local roleId = g_i3k_game_context:GetRoleId()
		g_i3k_game_context:setRoleHeadIconId(req.headId)
		g_i3k_game_context:ChangedRoleHeadIcon(roleId,req.headId)
		g_i3k_ui_mgr:PopupTipMessage("更改头像成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("更改头像失败")
	end
end

--同步玩家已解锁头像框
function i3k_sbean.syncPlayerFrameIcon()
	local data = i3k_sbean.sync_headborder_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sync_headborder_res.getName())
end

function i3k_sbean.sync_headborder_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_ChangeHeadFrame)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChangeHeadFrame, res.ok)
end

--激活玩家头像框
function i3k_sbean.unlockPlayerFrameIcon(borderId, callback, isUseItem)
	local data = i3k_sbean.unlock_headborder_req.new()
	data.borderId = borderId
	data.__callback = callback
	data.isUseItem = isUseItem
	i3k_game_send_str_cmd(data,i3k_sbean.unlock_headborder_res.getName())
end

function i3k_sbean.unlock_headborder_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_UnlockHead)
		if req.isUseItem then
			g_i3k_game_context:UseCommonItem(i3k_db_head_frame[req.borderId].condition_1, i3k_db_head_frame[req.borderId].condition_2, AT_UNLOCK_HEADBORDER)
		end
		if req.__callback then
			req.__callback()
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15563))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15564))
	end
end

-- 保存玩家头像框
function i3k_sbean.savePlayerFrameIcon(borderId, callback)
	local data = i3k_sbean.change_headborder_req.new()
	data.borderId = borderId
	data.__callback = callback
	i3k_game_send_str_cmd(data,i3k_sbean.change_headborder_res.getName())
end

function i3k_sbean.change_headborder_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setRoleHeadFrameId(req.borderId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "updatePlayerHeadFrame")
		if req.__callback then
			req.__callback()
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15565))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15566))
	end
end

-- 获取宿敌列表
function i3k_sbean.getEnemyFriend()
	local data = i3k_sbean.friend_enemy_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.friend_enemy_res.getName())
end
function i3k_sbean.friend_enemy_res.handler(bean,req)
	--self.enemys:		vector[EnemyOverview]
	--self.overview:		RoleOverview
	--self.killTime:		int32
	--self.curMapID:		int32
	--self.curLine:		int32
	local enemys = bean.enemys
	local num = #enemys
	g_i3k_game_context:SetEnemyListData(enemys)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateEnemyData",1)
	if num == 0 then
		g_i3k_ui_mgr:PopupTipMessage("您当前没有宿敌")
	end

	DCEvent.onEvent("查看宿敌")
end
-- 宿敌删除
function i3k_sbean.deleteEnemy(enemyID)
	local data = i3k_sbean.friend_removeenemy_req.new()
	--self.enemyId:		int32
	data.enemyId = enemyID
	i3k_game_send_str_cmd(data,i3k_sbean.friend_removeenemy_res.getName())
end
function i3k_sbean.friend_removeenemy_res.handler(bean,req)
	--self.ok:		int32
	local ok = bean.ok
	if ok > 0 then
--		i3k_sbean.getEnemyFriend()
		g_i3k_game_context:removeEnemy(req.enemyId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateEnemyData",1)
		g_i3k_ui_mgr:PopupTipMessage("宿敌删除成功")
	else
		--宿敌删除失败
		g_i3k_ui_mgr:PopupTipMessage("宿敌删除失败")
	end
end

-- 登陆同步黑名单
function i3k_sbean.role_blacklist.handler(bean)
	g_i3k_game_context:SetBlackListData(bean.blacklist, bean.banList)
end
-- 获取黑名单列表
function i3k_sbean.getBlackFriend()
	local data = i3k_sbean.blacklist_sync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.blacklist_sync_res.getName())
end
function i3k_sbean.blacklist_sync_res.handler(bean,req)
	local enemys = bean.overviews
	local num = table.nums(enemys)
	g_i3k_game_context:SetBlackListData2(bean)
	g_i3k_game_context:setAutoDelData(0, bean.isClear > 0)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateEnemyData",2)
	if num == 0 then
		g_i3k_ui_mgr:PopupTipMessage("当前无玩家在您黑名单")
	end
	DCEvent.onEvent("查看黑名单")
end
-- 黑名单删除
function i3k_sbean.deleteBlackFriend(enemyID)
	local data = i3k_sbean.blacklist_del_req.new()
	data.rid = enemyID
	i3k_game_send_str_cmd(data,i3k_sbean.blacklist_del_res.getName())
end
function i3k_sbean.blacklist_del_res.handler(bean,req)
	local ok = bean.ok
	if ok > 0 then
		g_i3k_game_context:delBlackFriend(req.rid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateEnemyData",2)
		g_i3k_ui_mgr:PopupTipMessage("黑名单删除成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("黑名单删除失败")
	end
end

-- 黑名单添加
function i3k_sbean.addBlackFriend(enemyID,refresh)
	if g_i3k_game_context:isBlackFriend(enemyID) then
		return g_i3k_ui_mgr:PopupTipMessage("玩家已在您的黑名单")
	end
	local callfunction = function(ok)
		if ok then
			local data = i3k_sbean.blacklist_add_req.new()
			data.rid = enemyID
			data.refresh = refresh
			i3k_game_send_str_cmd(data,i3k_sbean.blacklist_add_res.getName())
		end
	end
	local friend = g_i3k_game_context:GetFriendsDataByID(enemyID)
	if friend then
		local name = ""
		if friend.overview then
			name = friend.overview.name
		elseif friend.fov and friend.fov.overview then
			name = friend.fov.overview.name
		end
		local msg = string.format("%s%s",name,"是您的好友，确定加入黑名单？")
		g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, callfunction)
		return nil;
	end

	local data = i3k_sbean.blacklist_add_req.new()
	data.rid = enemyID
	data.refresh = refresh
	i3k_game_send_str_cmd(data,i3k_sbean.blacklist_add_res.getName())
end
function i3k_sbean.blacklist_add_res.handler(bean,req)
	local ok = bean.ok
	if ok > 0 then
		g_i3k_game_context:addBlackFriend(req.rid)
		if req.refresh == true then
			g_i3k_game_context:deleteOneFriend(req.rid)
			g_i3k_ui_mgr:RefreshUI(eUIID_Friends)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateEnemyData",2)
		end
		g_i3k_ui_mgr:PopupTipMessage("黑名单添加成功")
		g_i3k_game_context:deleteOneFriend(req.rid)
	elseif ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1366, i3k_db_common.friends_about.blacklistMaxNum))
	else
		g_i3k_ui_mgr:PopupTipMessage("黑名单添加失败")
	end
end

--黑名单禁止互动
function i3k_sbean.blacklist_ban_interAct(id)
	local bean = i3k_sbean.blacklist_ban_req.new()
	bean.rid = id
	i3k_game_send_str_cmd(bean, "blacklist_ban_res")
end
function i3k_sbean.blacklist_ban_res.handler(res, req)
	if res.ok > 0 then
		local data = g_i3k_game_context:GetBlackListData2()
		for i, v in ipairs(data) do
			if v.id == req.rid then
				v.isBanInterAct = true
			end
		end
		g_i3k_game_context:AddBanList(req.rid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateEnemyData",2)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17732))
	else
		g_i3k_ui_mgr:PopupTipMessage("禁止失败")
	end
end
--获取赠送魅力值记录
function i3k_sbean.get_flowerlog(refresh)
	local data = i3k_sbean.get_flowerlog_req.new()
	data.refresh = refresh
	i3k_game_send_str_cmd(data, "get_flowerlog_res")
end

function i3k_sbean.get_flowerlog_res.handler(bean, req)
	local giveFlower = bean.giveFlower
	local acceptFlower = bean.acceptFlower
	g_i3k_game_context:SetCharmData(bean.giveFlower, bean.acceptFlower, req.refresh)
end

-- 获取查看的接收玫瑰列表
function i3k_sbean.get_acceptlist(rid, info)
	local data = i3k_sbean.get_acceptlist_req.new()
	data.rid = rid
	data.info = info
	i3k_game_send_str_cmd(data, "get_acceptlist_res")
end

function i3k_sbean.get_acceptlist_res.handler(bean, req)
	g_i3k_ui_mgr:OpenUI(eUIID_FriendsCharm)
	g_i3k_ui_mgr:RefreshUI(eUIID_FriendsCharm, req.info, bean.result)
end

-- 一键送体力
function i3k_sbean.giveVitToAllFriend(friends)
	local data = i3k_sbean.friend_giveallvits_req.new()
	data.friends = friends
	i3k_game_send_str_cmd(data)--, "friend_giveallvits_res", friends)
end

function i3k_sbean.friend_giveallvits_res.handler(bean, req)
	local ok = bean.ok
	if ok > 0 then
		--赠送体力成功
		req = req or {}
		local friends = req.friends or {}
		local allData = g_i3k_game_context:GetFriendsData()
		for k , friendId in pairs(friends or {}) do
			for i,e in ipairs(allData) do
				if e.fov.overview.id == friendId then
					e.sendVit = 1
				end
			end
		end
		g_i3k_game_context:SetFriendsData(allData)
		g_i3k_ui_mgr:PopupTipMessage("一键赠送体力成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateUI",100000)
	elseif ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("您今天已经给对方赠送过体力了")
	elseif ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("已经不是好友，请稍后重试")
	elseif ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("好友已满")
	elseif ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("不是互为好友")
	else
		g_i3k_ui_mgr:PopupTipMessage("一键发送体力失败~")
	end
end

--幸运星
function i3k_sbean.lucklystar_sync_req_send(openType)
	local bean = i3k_sbean.lucklystar_sync_req.new()
	bean.openType = openType
	i3k_game_send_str_cmd(bean,"lucklystar_sync_res")
end

function i3k_sbean.lucklystar_sync_res.handler(res, req)
	g_i3k_game_context:SetLuckyStarData(res.info)
	
	if req.openType == 1 then --好友
		g_i3k_ui_mgr:OpenUI(eUIID_LuckyStarGift)
		g_i3k_ui_mgr:RefreshUI(eUIID_LuckyStarGift)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"updateLuckyStarData")
	else
		g_i3k_ui_mgr:OpenUI(eUIID_LuckyStar)
		g_i3k_ui_mgr:RefreshUI(eUIID_LuckyStar)
	end
end

function i3k_sbean.lucklystar_gift_req_send(roleId, name)
	local bean = i3k_sbean.lucklystar_gift_req.new()
	bean.roleId = roleId
	bean.name = name
	i3k_game_send_str_cmd(bean,"lucklystar_gift_res")
end

function i3k_sbean.lucklystar_gift_res.handler(res, req)
	if res.ok > 0 then
		if req.name then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3054, req.name))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3042))
		end
		g_i3k_game_context:subtractGiveGiftTimes()
		--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3042))
		local tmp_items = {}
		local items = g_i3k_game_context:GetLuckyStarDB()
		if items then
			for i=1,3 do
				if items[i].itemID ~= 0 then
					count = items[i].count
					if g_i3k_game_context:GetCurrentRoleType() == req.ctype then
						count = count * 2
					end
					local t = {id = items[i].itemID,count = items[i].count * res.ok}
					table.insert(tmp_items,t)
				end
			end

			g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
		end
	elseif res.ok == -1 then
		--g_i3k_ui_mgr:PopupTipMessage("等级不足")
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3044))
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3045))
	elseif res.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3043,i3k_db_luckyStar.cfg.limitLvl))
	elseif res.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3046))
	elseif res.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3047))
	end
end

function i3k_sbean.lucklystar_push.handler(bean)
	--g_i3k_game_context:SetLuckyStarData({dayRecvTimes = 1, dayRewardTimes = 0, lastGiftTimes = 2})
	--and g_i3k_logic:IsRootUIBattle()
	g_i3k_game_context:setLuckyStarState(1)
	if i3k_game_get_map_type() == g_FIELD  and g_i3k_game_context:GetWorldMapID() ~= i3k_db_spring.common.mapId then
		g_i3k_ui_mgr:OpenUI(eUIID_LuckyStarTip)
	end
end

function i3k_sbean.recv_lucnlystar_by_role.handler(bean)
	local name = bean.name
	if name then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3055, name))
	end
	--g_i3k_game_context:SetLuckyStarData({dayRecvTimes = 1, dayRewardTimes = 0, lastGiftTimes = 1})--and g_i3k_logic:IsRootUIBattle()
	g_i3k_game_context:setLuckyStarState(1)
	if  i3k_game_get_map_type() == g_FIELD  and g_i3k_game_context:GetWorldMapID() ~= i3k_db_spring.common.mapId then
		g_i3k_ui_mgr:OpenUI(eUIID_LuckyStarTip)
	end
end
-- 一键删除好友
function i3k_sbean.deleteFriends(friendIds)
	local data = i3k_sbean.friend_onekey_delete_req.new()
	data.friendIds = friendIds
	i3k_game_send_str_cmd(data,i3k_sbean.friend_onekey_delete_res.getName())
end
function i3k_sbean.friend_onekey_delete_res.handler(bean,req)
	local ok = bean.ok
	if ok > 0 then
		for k,v in ipairs(req.friendIds) do
			local overview = g_i3k_game_context:GetFrRoleOverviewById(v)
			--好友列表数据刷新
			g_i3k_game_context:deleteOneFriend(v)
			--推荐好友数据刷新
			local value =  g_i3k_game_context:GetRecommendDataById(v)
			if not value then
				g_i3k_game_context:addRecommendData(overview,0)
			end
			--g_i3k_ui_mgr:PopupTipMessage("delete succeed")
		end
		g_i3k_ui_mgr:PopupTipMessage("好友删除成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Delete_Friend,"updateFriendData")
		g_i3k_ui_mgr:RefreshUI(eUIID_Friends)
	else
		g_i3k_ui_mgr:PopupTipMessage("好友删除失败")
	end
end

function i3k_sbean.mood_diary_open_main_page(opentype, rid, callback)
	local data = i3k_sbean.mood_diary_open_main_page_req.new()
	data.type = opentype
	data.rid = rid
	data.callback = callback
	i3k_game_send_str_cmd(data,i3k_sbean.mood_diary_open_main_page_res.getName())
end

function i3k_sbean.mood_diary_open_main_page_res.handler(bean,req)
	local ok = bean.ok
	if ok > 0 then
		if req.type == 1 then
			g_i3k_game_context:setMoodDiaryDecorate(bean.moodDiary.actDecorates)
		end
		if req then
			g_i3k_ui_mgr:OpenUI(eUIID_MoodDiary)
			g_i3k_ui_mgr:RefreshUI(eUIID_MoodDiary,req.type,bean.moodDiary, bean.personalInfo)
		end
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17190))
	end
end

function i3k_sbean.mood_diary_wirte_diary(diaryContent)
	local data = i3k_sbean.mood_diary_wirte_diary_req.new()
	data.msg = diaryContent
	i3k_game_send_str_cmd(data,i3k_sbean.mood_diary_wirte_diary_res.getName())
end

function i3k_sbean.mood_diary_wirte_diary_res.handler(bean,req)
	local ok = bean.ok
	if ok > 0 then
		i3k_sbean.mood_diary_open_main_page(1)
		g_i3k_ui_mgr:CloseUI(eUIID_DiaryContent)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17183))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17191))
	end
end

function i3k_sbean.mood_diary_delete(time)
	local data = i3k_sbean.mood_diary_delete_req.new()
	data.time = time
	i3k_game_send_str_cmd(data,i3k_sbean.mood_diary_delete_res.getName())
end

function i3k_sbean.mood_diary_delete_res.handler(bean,req)
	local ok = bean.ok
	if ok > 0 then
		i3k_sbean.mood_diary_open_main_page(1)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17184))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17192))
	end
end


function i3k_sbean.mood_diary_get_diaries(opentype,startNum,rid)
	local data = i3k_sbean.mood_diary_get_diaries_req.new()
	--self.type:		int32	
	--self.rid:		int32	
	--self.startNum:		int32	
	data.type = opentype
	data.rid = rid
	data.startNum = startNum
	i3k_game_send_str_cmd(data,i3k_sbean.mood_diary_get_diaries_res.getName())
end

function i3k_sbean.mood_diary_get_diaries_res.handler(bean,req)
	local ok = bean.ok
	if ok > 0 then
		if #bean.diaries>=1 then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "showNextDiary", bean.diaries)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "cancelScroll")
		end
		
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "cancelScroll")
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "setScrollEvent")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17193))
	end
end

function i3k_sbean.mood_diary_send_popularity_item(itemCnt,itemID,rid)
	local data = i3k_sbean.mood_diary_send_popularity_item_req.new()
	--self.rid:		int32	
	--self.itemID:		int32	
	--self.itemCnt:		int32	
	data.itemCnt = itemCnt
	data.rid = rid
	data.itemID = itemID
	i3k_game_send_str_cmd(data,i3k_sbean.mood_diary_send_popularity_item_res.getName())
end

function i3k_sbean.mood_diary_send_popularity_item_res.handler(bean, req)
	local ok = bean.ok
	if ok > 0 then
		g_i3k_game_context:UseBagItem(req.itemID, req.itemCnt,AT_MOODDIARY_GIFT_SEND)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SendGift, "showGift")
		local popTips = true
		for _, v in ipairs(i3k_db_mood_diary_cfg.showAnimateItemId) do
			if math.abs(req.itemID) == v then
				popTips = false
				break
			end
		end
		if i3k_db_new_item[req.itemID].args1 * req.itemCnt >= i3k_db_mood_diary_cfg.showAnimateCondition then
			popTips = false
		end
		if popTips then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17194))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17195))
	end
end

--改变装饰
function i3k_sbean.mood_diary_change_decorate(id)
	local data = i3k_sbean.mood_diary_change_decorate_req.new()
	data.decorateID = id
	i3k_game_send_str_cmd(data, "mood_diary_change_decorates_res")
end

function i3k_sbean.mood_diary_change_decorates_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17196))
		local callback = function ()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "onBeauty")
		end
		i3k_sbean.mood_diary_open_main_page(1, g_i3k_game_context:GetRoleId(), callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17197))
	end
end

--激活装饰
function i3k_sbean.mood_diary_activite_decorate(id)
	local data = i3k_sbean.mood_diary_activite_decorate_req.new()
	data.decorateID = id
	i3k_game_send_str_cmd(data, "mood_diary_activite_decorate_res")
end

function i3k_sbean.mood_diary_activite_decorate_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17198))
		g_i3k_game_context:addMoodDiaryDecorate(req.decorateID)
		g_i3k_game_context:UseCommonItem(i3k_db_mood_diary_decorate[req.decorateID].unlockItemId, 1, AT_DIARY_DECORATE_ACTIVE)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiaryBeauty, "updateAllBeauty")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17199))
	end
end

--日记分享
function i3k_sbean.mood_diary_share(shareType)
	local data = i3k_sbean.mood_diary_share_req.new()
	data.shareType = shareType
	data.serverName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	i3k_game_send_str_cmd(data, "mood_diary_share_res")
end

function i3k_sbean.mood_diary_share_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17200))
		if req.shareType == global_world then
			g_i3k_game_context:UseCommonItem(65656, 1, AT_USE_CHAT_ITEM)
		else
			g_i3k_game_context:UseCommonItem(66167, 1, AT_USE_CHAT_ITEM)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17201))
	end
end

--获取自己的人气值
function i3k_sbean.mood_diary_get_self_popularity(callback)
	local data = i3k_sbean.mood_diary_get_self_popularity_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "mood_diary_get_self_popularity_res")
end

function i3k_sbean.mood_diary_get_self_popularity_res.handler(res, req)
	g_i3k_game_context:setPopularity(res.popularity)
	if req.callback then
		req.callback()
	end
end

--星座设置
function i3k_sbean.mood_diary_choose_constellation(constellationID)
	local data = i3k_sbean.personal_info_constellation_req.new()
	data.constellation = constellationID
	i3k_game_send_str_cmd(data, "personal_info_constellation_res")
end

function i3k_sbean.personal_info_constellation_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetSelfMooddiaryPersonConstellationInfo(req.constellation)
		g_i3k_ui_mgr:CloseUI(eUIID_SetConstellation)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "setPersonInfo")
	else
		g_i3k_ui_mgr:PopupTipMessage("星座设置失败")
	end
end

--爱好设置
function i3k_sbean.mood_diary_set_hobby(hobbies, diyHobbies)
	local data = i3k_sbean.personal_info_hobbies_req.new()
	data.hobbies = hobbies
	data.diyHobbies = diyHobbies
	i3k_game_send_str_cmd(data, "personal_info_hobbies_res")
end

function i3k_sbean.personal_info_hobbies_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetSelfMooddiaryPersonHobbiesInfo(req.hobbies)
		g_i3k_game_context:SetSelfMooddiaryPersonDiyHobbiesInfo(req.diyHobbies)
		g_i3k_ui_mgr:CloseUI(eUIID_SetHobby)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "setPersonInfo")
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17511))
	elseif res.ok == -404 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17507))
	end
end

--星语星愿答题
function i3k_sbean.mood_diary_constellation_test(answer, sex, groupID)
	local data = i3k_sbean.personal_info_answer_req.new()
	data.anwsers = answer
	data.groupID = groupID
	data.sex = sex
	i3k_game_send_str_cmd(data, "personal_info_answer_res")
end

function i3k_sbean.personal_info_answer_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetSelfMooddiaryPersonTestScoreInfo(res.ok, req.groupID)
		local role_name = g_i3k_game_context:GetRoleName()
		g_i3k_ui_mgr:OpenUI(eUIID_ConstellationTestResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_ConstellationTestResult, res.ok, req.sex, req.groupID, role_name)
	else
		g_i3k_ui_mgr:PopupTipMessage("答题失败")
	end
	g_i3k_ui_mgr:CloseUI(eUIID_ConstellationTest)
end

--性别设置
function i3k_sbean.mood_diary_set_sex(sex)
	local data = i3k_sbean.personal_info_gender_req.new()
	data.gender = sex
	i3k_game_send_str_cmd(data, "personal_info_gender_res")
end

function i3k_sbean.personal_info_gender_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetSelfMooddiaryPersonSexInfo(req.gender)
		g_i3k_ui_mgr:OpenUI(eUIID_ConstellationTest)
		g_i3k_ui_mgr:RefreshUI(eUIID_ConstellationTest, req.gender, i3k_db_mood_diary_sex[req.gender].questionGroup)
		g_i3k_ui_mgr:CloseUI(eUIID_SetSex)
	else
		g_i3k_ui_mgr:PopupTipMessage("性别设置失败")
	end
end

--星语星愿测试结果分享
function i3k_sbean.mood_diary_constellation_test_share(shareType, groupID)
	local data = i3k_sbean.personal_info_share_req.new()
	data.type = shareType
	data.groupID = groupID
	data.serverName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	i3k_game_send_str_cmd(data, "personal_info_share_res")
end

function i3k_sbean.personal_info_share_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17200))
		if req.shareType == 1 then
			g_i3k_game_context:UseCommonItem(65656, 1, AT_USE_CHAT_ITEM)
		else
			g_i3k_game_context:UseCommonItem(66167, 1, AT_USE_CHAT_ITEM)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17201))
	end
end

--好友宣言
function i3k_sbean.mood_diary_write_declaration(declaration)
	local data = i3k_sbean.personal_info_signature_req.new()
	data.signature = declaration
	i3k_game_send_str_cmd(data, "personal_info_signature_res")
end

function i3k_sbean.personal_info_signature_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetSelfMooddiaryPersonDeclarationInfo(req.signature)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "setPersonInfo")
	elseif res.ok == -404 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17509))
	end
end

--跨服好友，立即匹配
function i3k_sbean.mood_diary_cross_friend_match_now()
	local data = i3k_sbean.cross_friend_match_req.new()
	i3k_game_send_str_cmd(data, "cross_friend_match_res")
end

function i3k_sbean.cross_friend_match_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AddCrossFriends, "showCrossFriendInfo", res.matchInfo, false, true)
	else
		g_i3k_ui_mgr:PopupTipMessage("跨服好友匹配失败")
	end
end

--跨服好友，同步信息
function i3k_sbean.mood_diary_cross_friend_sync_info()
	local data = i3k_sbean.cross_friend_sync_req.new()
	i3k_game_send_str_cmd(data, "cross_friend_sync_res")
end

function i3k_sbean.cross_friend_sync_res.handler(res, req)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "setCrossFriendInfo", res.matchInfo, res.dayRefreshTimes, res.openMatch)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "showCrossBank", res.applies)
end

--跨服好友，换一批
function i3k_sbean.mood_diary_cross_friend_refresh_cross_friend()
	local data = i3k_sbean.cross_friend_refresh_req.new()
	i3k_game_send_str_cmd(data, "cross_friend_refresh_res")
end

function i3k_sbean.cross_friend_refresh_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AddCrossFriends, "showCrossFriendInfo", res.matchInfo)
	else
		g_i3k_ui_mgr:PopupTipMessage("跨服好友匹配失败")
	end
end

--跨服好友，添加好友
function i3k_sbean.mood_diary_cross_friend_add_cross_friend(roleID)
	local data = i3k_sbean.cross_friend_like_req.new()
	data.roleID = roleID
	i3k_game_send_str_cmd(data, "cross_friend_like_res")
end

function i3k_sbean.cross_friend_like_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("跨服好友申请成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AddCrossFriends, "likeOrDisLikeRefresh")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17517))
	end
end

--跨服好友，忽略好友
function i3k_sbean.mood_diary_cross_friend_ignore_cross_friend(roleID, refreshTime)
	local data = i3k_sbean.cross_friend_dislike_req.new()
	data.roleID = roleID
	data.refreshTime = refreshTime
	i3k_game_send_str_cmd(data, "cross_friend_dislike_res")
end

function i3k_sbean.cross_friend_dislike_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AddCrossFriends, "likeOrDisLikeRefresh")
	else
		g_i3k_ui_mgr:PopupTipMessage("跨服好友忽略失败")
	end
end

--跨服好友，好友申请处理
function i3k_sbean.mood_diary_cross_friend_cross_friend_apply_reply(accept, roleInfo, index)
	local data = i3k_sbean.cross_friend_reply_req.new()
	data.roleID = roleInfo.overview.id
	data.accept = accept
	data.index = index
	data.roleInfo = roleInfo
	i3k_game_send_str_cmd(data, "cross_friend_reply_res")
end

function i3k_sbean.cross_friend_reply_res.handler(res, req)
	if res.ok > 0 then
		if req.accept == 1 then
			g_i3k_ui_mgr:PopupTipMessage("添加成功")
			--g_i3k_game_context:AddCrossFriendInfo(req.roleInfo)
			--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "showCrossFriends")
		else
			g_i3k_ui_mgr:PopupTipMessage("拒绝成功")
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CrossFriendsApply, "refreshApplyList", req.roleID)
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17522))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17516))
	end
end

--跨服好友，删除好友
function i3k_sbean.mood_diary_cross_friend_cross_friend_delete(roleID)
	local data = i3k_sbean.cross_friend_delete_req.new()
	data.roleID = roleID
	i3k_game_send_str_cmd(data, "cross_friend_delete_res")
end

function i3k_sbean.cross_friend_delete_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("删除成功")
		g_i3k_game_context:DeleteCrossFriendInfo(req.roleID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "showCrossFriends")
		if not g_i3k_game_context:GetFriendsDataByID(req.roleID) then
			local function fun(player)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_PriviteChat, "specialOperate", nil, req.roleID)
			end
			g_i3k_game_context:SetRecentChatData(req.roleID, 1, fun)
		end
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_PriviteChat, "refresh")
	else
		g_i3k_ui_mgr:PopupTipMessage("删除失败")
	end
end

--跨服好友 好友申请通知
function i3k_sbean.cross_friend_apply.handler(res)
	g_i3k_game_context:SetCrossFriendRed(true)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "updateCrossFriendsRed")
	local notices = {[1] = g_NOTICE_TYPE_CAN_REWARD_FRIEND}
	g_i3k_game_context:SetNotices(notices)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CrossFriendsApply, "refreshApplyListOther", res.apply)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "addCrossFriendApply", res.apply)
end

--跨服好友 更新跨服好友信息
function i3k_sbean.cross_friend_update.handler(res)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CrossFriendsApply, "refreshApplyList", res.roleID)
	if res.info then
		g_i3k_game_context:AddCrossFriendInfo(res.info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "refreshMatchInfo", res.info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "showCrossFriends")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AddCrossFriends, "timeLimitShowBank", res.info)
	else
		g_i3k_game_context:DeleteCrossFriendInfo(res.roleID)
		if not g_i3k_game_context:GetFriendsDataByID(res.roleID) then
			local function fun(player)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_PriviteChat, "specialOperate")
			end
			g_i3k_game_context:SetRecentChatData(res.roleID, 1, fun)
		end
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "showCrossFriends")
end
function i3k_sbean.setAutoDel(tp)
	local data = i3k_sbean.set_clear_friend_req.new()
	data.type = tp
	if g_i3k_game_context:getAutoDelState(tp) then
		data.clear = 0
	else
		data.clear = 1
	end
	--g_i3k_ui_mgr:PopupTipMessage(type(tp)..tp.." | "..type(data.clear)..data.clear)
	i3k_game_send_str_cmd(data, "set_clear_friend_res")
end
function i3k_sbean.set_clear_friend_res.handler(res, req)
	if res.ok > 0 then
		local autoDel = g_i3k_game_context:getAutoDelState(req.type)
		g_i3k_game_context:setAutoDelData(req.type, not autoDel)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "setAutoDelMark", req.type)
		if req.type == 0 and not autoDel then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18208, i3k_db_common.friends_about.blackList_auto_del / 24))
		elseif req.type == 1 then
			i3k_sbean.syncFriend(3, function() 
				g_i3k_ui_mgr:RefreshUI(eUIID_Friends) 
			end)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("设置失败:"..res.ok)
	end
end
