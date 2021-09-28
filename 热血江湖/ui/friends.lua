-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_friends = i3k_class("wnd_friends", ui.wnd_base)

local colorOnline = {ff2fff4c, ffd5ff55}
local colorOffline = {ffc6dae5, ffffffff}

local LAYER_FRUI = "ui/widgets/haoyou"
local LAYER_ERITEM = "ui/widgets/haoyout"

local LAYER_CROSSFRIEND = "ui/widgets/kuafuhaoyou"
local LAYER_CROSSFRIENDITEM = "ui/widgets/kuafuhaoyout"

local LAYER_WUI = "ui/widgets/wo"
local LAYER_WITEM = "ui/widgets/wot"

local LAYER_SUI = "ui/widgets/sudi"
local LAYER_SITEM = "ui/widgets/sudit"

function wnd_friends:ctor()
	self.state = 0
	self.unlockHeads = nil
	self.friendsToBeDelete = {}
	self.matchInfo = {}
	self.dayRefreshTimes = 0
	self.openMatch = 0
	self.applies = {}
	self._crossFriends = nil
	self.headIconUIs = {}
end

function wnd_friends:configure()
	local _layout = self._layout.vars

	self._layout.vars.close_btn:onClick(self,self.onCloseUI, function ()
		self:closeFC()
	end)
	--好友
	local friends_btn = _layout.friends_btn
	friends_btn:onClick(self,self.onFriends)
	--改为跨服好友
	local luckyStar_btn = _layout.makefr_btn
	luckyStar_btn:onClick(self,self.onCrossFriend)

	--我
	local myself_btn = _layout.myself_btn
	myself_btn:onClick(self,self.onMyself)

	--宿敌
	local enemy_btn = _layout.enemy_btn
	enemy_btn:onClick(self,self.onEnemy)

	self._allBtn = {friends_btn = friends_btn,makefr_btn = luckyStar_btn,myself_btn = myself_btn,enemy_btn = enemy_btn}
	self.titleImg = _layout.titleImg--标题图片
	self.uiRoot = _layout.rootNode
end

function wnd_friends:refresh()
	local Data = g_i3k_game_context:getMyselfData()
	if Data then
		self.dayVitTakeTimes = Data.dayVitTakeTimes--体力领取次数
		self.vitLv = Data.vitLvl--体力的受赠等级
		self.personalMsg = Data.personalMsg--个人信息
		self.vitExp = Data.vitExp
	end
	self._layout.vars.lucky_red:setVisible(g_i3k_game_context:GetCrossFriendRed())
	self:updateFriendsData()
end

function wnd_friends:updateRoleName(name)
	self.role_name:setText(name)
end

function wnd_friends:rootShow(layer)
	local nodeWidth = self.uiRoot:getContentSize().width
	local nodeHeight = self.uiRoot:getContentSize().height
	local old_layer = self.uiRoot:getAddChild()
	if old_layer[1] then
		self.uiRoot:removeChild(old_layer[1])
	end
	self.uiRoot:addChild(layer)
	layer.rootVar:setContentSize(nodeWidth, nodeHeight)
end

function wnd_friends:allBtnNormal()
	for k,v in pairs(self._allBtn) do
		v:stateToNormal()
	end
end

function wnd_friends:onCrossFriend(sender)
	local personInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
	if g_i3k_game_context:GetLevel() < i3k_db_mood_diary_cfg.crossFriendLevelLimit then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17513, i3k_db_mood_diary_cfg.crossFriendLevelLimit))
		return
	end
	if personInfo.self.gender == 0 or personInfo.self.constellation == 0 or not next(personInfo.self.testScore) or personInfo.self.signature == "" or not next(personInfo.self.hobbies) and not next(personInfo.self.diyHobbies) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17512))
		return
	end
	i3k_sbean.mood_diary_cross_friend_sync_info()
end

function wnd_friends:setCrossFriendInfo(matchInfo, dayRefreshTimes, openMatch)
	self.matchInfo = {}
	self.matchInfo = matchInfo
	self.dayRefreshTimes = dayRefreshTimes
	self.openMatch = openMatch
end

--刷新匹配信息的函数
function wnd_friends:refreshMatchInfo(refreshInfo)
	if refreshInfo and self.matchInfo then
		if refreshInfo.overview and self.matchInfo.overview then
			if refreshInfo.overview.id == self.matchInfo.overview.id then
				self.matchInfo = nil
			end
		end
	end
end

--跨服好友增加的刷新函数
function wnd_friends:addCrossFriendApply(applies)
	local isInsert = true
	if next(self.applies) then
		for _,v in ipairs(self.applies) do
			if v.overview.id == applies.overview.id then
				isInsert = false
			end
		end
	end
	if isInsert then
		table.insert(self.applies, applies)
	end
end

function wnd_friends:showCrossBank(applies)
	self.state = 2
	self:btnToPressed("makefr_btn")
	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(7701))
	self.applies = applies
	local crossFriends_layer =  require(LAYER_CROSSFRIEND)()
	self:rootShow(crossFriends_layer)
	self._crossFriends = crossFriends_layer
	self._layout.vars.lucky_red:setVisible(false)
	crossFriends_layer.vars.add_friend:onClick(self, self.onMakeCrossFriends)
	crossFriends_layer.vars.friends_apply:onClick(self, self.onCrossFriendsApply)
	crossFriends_layer.vars.help_btn:onClick(self, self.onHelp)
	self:showCrossFriends()
	self:updateCrossFriendsRed()
end

--提出一个函数来显示跨服好友，同意申请的时候刷新也要用
function wnd_friends:showCrossFriends()
	if self._crossFriends then
		local personInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
		local widgets = self._crossFriends.vars
		widgets.crossfr_scroll:removeAllChildren()
		local crossFriendCnt = 0
		if next(personInfo.friends) then
			widgets.no_friends:setVisible(false)
			for k,v in pairs(personInfo.friends) do
				local Item = require(LAYER_CROSSFRIENDITEM)()
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
				
				--设置人物标签
				for i,e in pairs(v.info.testScore) do
					for _,x in ipairs(i3k_db_mood_diary_constellation_test_result) do
						if x.testResultGroupID == i and x.matchType == v.info.gender and v.info.testScore[i] >= x.countFloor and v.info.testScore[i] <= x.countCelling then
							--local Item = require(LAYER_PERSONLABEL)()
							Item.vars.person_pic:setImage(g_i3k_db.i3k_db_get_icon_path(x.resultForDisplayIcon))
							--widgets.person_scroll:addItem(Item)
						end
					end
				end
				
				--设置在线状态
				if v.online > 0 then --在线
					Item.vars.online_state:setImage(g_i3k_db.i3k_db_get_icon_path(7786))
				else
					Item.vars.online_state:setImage(g_i3k_db.i3k_db_get_icon_path(7787))
				end
			
				--设置好友缘分
				for i,e in ipairs(i3k_db_mood_diary_constellation_fate) do
					if e.constellationID == personInfo.self.constellation and e.constellationIDOther == v.info.constellation then
						Item.vars.percent_label:setText(string.format("%d%%", e.constellationCount))
						Item.vars.percent:setPercent(e.constellationCount)
					end
				end
				Item.vars.send_btn:onClick(self, self.onPriviteChat, v.overview)
				Item.vars.info_btn:onClick(self, self.checkData, v.overview.id)
				Item.vars.delete_btn:onClick(self, self.onCrossFriendsDelete, v.overview.id)
				widgets.crossfr_scroll:addItem(Item)
				crossFriendCnt = crossFriendCnt + 1
			end
		else
			widgets.no_friends:setVisible(true)
			widgets.noFri_label:setText(i3k_get_string(17501))
		end
		widgets.crossFri_cnt:setText(string.format("当前好友数量%d/%d", crossFriendCnt, i3k_db_mood_diary_cfg.crossFriendCountLimit))
	end
end

function wnd_friends:onCrossFriendsDelete(sender, roleID)
	local fun = (function(ok)
		if ok then
			i3k_sbean.mood_diary_cross_friend_cross_friend_delete(roleID)
		end
	end)
	local desc = "是否删除该好友"
	g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
end

function wnd_friends:updateCrossFriendsRed()
	local isShowRedPoint = g_i3k_game_context:GetCrossFriendRed()
	if self.state == 2 then
		if isShowRedPoint then
			self._crossFriends.vars.crossFri_red:show()
		else
			self._crossFriends.vars.crossFri_red:hide()
		end
	end
end

function wnd_friends:onHelp(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Help)
	g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(17520))
end

function wnd_friends:onCrossFriendsApply(sender)
	self._crossFriends.vars.crossFri_red:setVisible(false)
	g_i3k_ui_mgr:OpenUI(eUIID_CrossFriendsApply)
	g_i3k_ui_mgr:RefreshUI(eUIID_CrossFriendsApply, self.applies)
end

function wnd_friends:onMakeCrossFriends(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_AddCrossFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_AddCrossFriends, {matchInfo = self.matchInfo, dayRefreshTimes = self.dayRefreshTimes, openMatch = self.openMatch})
end

function wnd_friends:onPriviteChat(sender, info)
	local player = {}
	player.msgType = global_cross
	player.id = info.id
	player.name = info.name
	player.iconId = info.headIcon
	player.headBorder = info.headBorder
	player.bwType = info.bwType
	g_i3k_ui_mgr:OpenUI(eUIID_PriviteChat)
	g_i3k_ui_mgr:RefreshUI(eUIID_PriviteChat, player)
end

function wnd_friends:checkData(sender, playerId)
	i3k_sbean.query_rolefeature(playerId)
end

function wnd_friends:btnToPressed(btn)
	self:allBtnNormal()--更新按下状态
	self._allBtn[btn]:stateToPressed()
end

function wnd_friends:updateFriendsData()
	local hideAway = g_i3k_game_context:isHideOfflineFri()
	self.state = 1
	self._crossFriends = nil
	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1325))
	self:btnToPressed("friends_btn")
	local friends_layer =  require(LAYER_FRUI)()
	self:rootShow(friends_layer)
	local widgets = friends_layer.vars
	widgets.friAutoDelDesc:setText(i3k_get_string(18205, i3k_db_common.friends_about.fri_auto_del / 24))
	self._friAutoDelMark = widgets.autoDelMark
	self._friAutoDelMark:setVisible(g_i3k_game_context:getAutoDelState(1))
	widgets.autoDel:onClick(self, self.onAutoDel)
	local getBtnText = widgets.GetBtnText
	getBtnText:setText("一键领取")
	local headicon = g_i3k_game_context:GetRoleHeadIconId()
	widgets.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headicon, false))
	local BWType = g_i3k_game_context:GetTransformBWtype()
	local frameId = g_i3k_game_context:GetRoleHeadFrameId()
	widgets.headframe:setImage(g_i3k_get_head_bg_path(BWType, frameId))

	local scroll = widgets.fr_scroll
	self.friendScroll  = scroll
	--体力领取次数
	local getCount = widgets.GetCount
	local level  = widgets.Level
	local getBtn = widgets.GetBtn
	local refresh_btn =  widgets.refresh_btn
	local pagenum = widgets.pageNum
	local friendnum = widgets.friendNum
	local hideBtn = widgets.hideBtn
	self.hideBtn = hideBtn
	self.hideImage = widgets.hideImage
	self.hideLable = widgets.hideLable
	self.selectIcon = widgets.selectIcon
	widgets.addFriendBtn:onClick(self, self.onMakeFriends)
	hideBtn:onClick(self,self.onHideBtn)
	if hideAway then
		widgets.selectIcon:show()
		g_i3k_game_context:setHideOfflineFri(true)
	else
		widgets.selectIcon:hide()
		g_i3k_game_context:setHideOfflineFri(false)
	end
	self.getCount = getCount
	self.getBtn = getBtn
	self.level = level
	self.refresh_btn = refresh_btn
	local loadingBar = widgets.loadingBar
	self.loadingBar = loadingBar
	getBtn:onClick(self,self.doAction)--一键操作
	getBtn:disableWithChildren()
	refresh_btn:onClick(self,self.onRefreshBtnClick)

	self.giveAllVitBtn = widgets.giveAllVitBtn
	self.giveAllVitBtn:onClick(self,self.giveAllVits)--一键操作

	widgets.deleteFriendsBtn:onClick(self, self.deleteFriends)

	self:updateFriendsUI()
	--排序
	g_i3k_game_context:SortFriendsData()
	local FriendOverview = g_i3k_game_context:GetFriendsData()--获取基本数据
--	local allData = g_i3k_game_context:GetfriendsOtherData()
--	local Data = allData.FriendInfo
	local friendNum = #FriendOverview
	if friendNum<50 then
		widgets.deleteFriendsBtn:setVisible(false)
	else
		widgets.deleteFriendsBtn:setVisible(true)
	end
	local nowtime  = i3k_game_get_time() --当前时间
--获取数据
--初始化Ui控件
	local num = 0
	local hadTimes = 0
	self.friendsToBeDelete = {}
	for k,v in ipairs(FriendOverview) do
		local info = v.fov.overview
		local bwType = info.bwType
		local frameId = info.headBorder
		local eachFriend = v.eachFriend
		local receiveVit = v.receiveVit--接收精力
		local sendVit = v.sendVit--发送精力
		local focusValue = v.focusValue -- 关注度
		local addTime = v.addTime --添加好友时间
		local logintime = v.fov.lastLoginTime
		local personalMsg = v.fov.personalMsg
		local online = v.fov.online
		local fightpower = info.fightPower
		local Item = require(LAYER_ERITEM)()
		local name = Item.vars.name_label
		local state = Item.vars.state
		local tx = Item.vars.tx_img
		local level = Item.vars.level
		local zhiye = Item.vars.zhiye_img
		local isonline = Item.vars.isOnline_img--是否在线
		local iseachfriends = 	Item.vars.iseachfriends_lab
		local attention = Item.vars.attention_label--关注度
		local Iconbg=Item.vars.txb_img
		local btnInfo = {name = info.name, roleID = info.id}
		Item.vars.showLoveBtn:onClick(self, self.onShowLoveBtn, btnInfo)
		Item.vars.showLoveBtn:setVisible(g_i3k_db.i3k_db_get_is_activity_world_open(g_activity_show_world))
		Iconbg:setImage(g_i3k_get_head_bg_path(bwType, frameId))
		local fightPower = Item.vars.fightPower--战力
		local timeOfOffline = (nowtime - logintime)/3600
		if timeOfOffline > i3k_db_common.friends_about.offline_time or focusValue <= i3k_db_common.friends_about.attention_threshold or math.abs(g_i3k_game_context:GetLevel()-info.level)>i3k_db_common.friends_about.level_diffrence then
			table.insert(self.friendsToBeDelete,v)
		end
		if eachFriend == 0 then
			iseachfriends:hide()
		else
			iseachfriends:show()
		end
		if online == 0 then
			isonline:setImage(g_i3k_db.i3k_db_get_icon_path(1319))
			--table.insert(self.friendsToBeDelete,v)
		elseif online == 1 then
			isonline:setImage(g_i3k_db.i3k_db_get_icon_path(1318))
		end
		fightPower:setText("战力:" .. fightpower)
		attention:setText(focusValue)
		name:setText(info.name)
		level:setText(info.level)
		local gcfg = g_i3k_db.i3k_db_get_general(info.type)
		zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
		tx:setImage(g_i3k_db.i3k_db_get_head_icon_path(info.headIcon, false))
		state:setText(personalMsg)

		local more_btn = Item.vars.more_btn
		local sendBtn = Item.vars.sendpower_btn
		local getpower = Item.vars.getpower_btn
		if receiveVit == 0 then
			getpower:disableWithChildren()
		elseif receiveVit == 1 then
			getpower:enableWithChildren()
			getBtn:enableWithChildren()
			hadTimes = 1
		end
		getpower:setTag(info.id)
		sendBtn:setTag(info.id + 100000)
		if sendVit == 1 or sendVit == -1 then
			sendBtn:disableWithChildren()
		elseif sendVit==0 then
			sendBtn:enableWithChildren()
		end
		local arg = {info.id,scroll,eachFriend,hadTimes}
		getpower:onClick(self,self.getPower,arg)
		sendBtn:onClick(self,self.sendPower,arg)
		more_btn:onClick(self,self.getMore,v)
		if hideAway  then
			if  online == 1 then
				scroll:addItem(Item)
			end
		else
			scroll:addItem(Item)
		end
		num = num+1
	end
	if self.scrollPercent then
		scroll:jumpToListPercent(self.scrollPercent)
		self.scrollPercent = nil
	end
	if num == 0 then
		self:showRefreshBtn(true)
		g_i3k_game_context:SetRecommendList1(nil)
		i3k_sbean.plusListFriend(true)
	else
		self:showRefreshBtn(false)
	end
	local friendsAllnum = i3k_db_common.friends_about.friendMaxCount
	friendnum:setText(num .. "/" .. friendsAllnum)
end

function wnd_friends:deleteFriends(sender)
	if #self.friendsToBeDelete < 1 then
		g_i3k_ui_mgr:PopupTipMessage("没有符合条件的好友")
	else
		g_i3k_ui_mgr:OpenUI(eUIID_Delete_Friend)
		g_i3k_ui_mgr:RefreshUI(eUIID_Delete_Friend,self.friendsToBeDelete)
	end
end

function wnd_friends:updateCharm()
	local old_layer = self.uiRoot:getAddChild()
	if old_layer[1].vars.charm_value then
		old_layer[1].vars.charm_value:setText(g_i3k_game_context:GetCharm())
	end
end

function wnd_friends:updateMyselfData(unlockHeads)
	self._crossFriends = nil
	self.unlockHeads = unlockHeads
	self.state = 3
	self:btnToPressed("myself_btn")
	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1327))
	local myself_layer =  require(LAYER_WUI)()
	self:rootShow(myself_layer)
	local widgets = myself_layer.vars

	widgets.charm_value:setText(g_i3k_game_context:GetCharm())
	widgets.check_btn:onClick(self, self.checkBtn)
	widgets.callBtn:onClick(self, self.onRoleReturn)
	widgets.lucky_star:onClick(self, self.luckyStar)
	widgets.change_frame_btn:onClick(self, self.onChangeFrame)
	--心情日记按钮显隐
	if g_i3k_game_context:GetLevel() < i3k_db_mood_diary_cfg.openLevel then
		widgets.moodDiary_btn:setVisible(false)
	end
	widgets.moodDiary_btn:onClick(self, self.onMoodDiary, 1)
	widgets.constellation_test:onClick(self, self.onConstellationTip)

	local scroll = widgets.wo_scroll
	scroll:setDirection(1)
	self.changeIcon_btn = widgets.changeIcon_btn
	self.changeIcon_btn:onClick(self,self.saveIcon)
	local txd_img = widgets.txd_img
	self.txd_img = txd_img
	self.tx_img = widgets.tx_img
	local myId = widgets.myId
	local IDNum = widgets.IDNum
	local Mystate = widgets.Mystate
	local stateContent = widgets.stateContent
	local changestate = widgets.changestate_btn
	changestate:onClick(self,self.changePersonState,self.personalMsg)
	self.role_name = widgets.role_name
	self:updateRoleName(g_i3k_game_context:GetRoleName())
	local modifyNameBtn = widgets.modifyNameBtn
	modifyNameBtn:onClick(self,self.modifyName)
	--数据
	local data = self.personalMsg
	stateContent:setText(data)
	IDNum:setText(g_i3k_game_context:GetRoleId())

	local headicon = g_i3k_game_context:GetRoleHeadIconId()
	self.tx_img:setImage(g_i3k_db.i3k_db_get_head_icon_path(headicon, false))

	self:updatePlayerHeadFrame()

	--获取数据
	local imgdata = g_i3k_db.i3k_db_get_friends_icon()
	--数据处理
	local Rolegender = g_i3k_game_context:GetRoleGender()
	local loginHeadIcon = g_i3k_game_context:GetloginHeadIcon()
	local newtable1 = {}
	for k,v in pairs(imgdata) do
		if v.gender == Rolegender then
			if v.typeID == 1 then
				if loginHeadIcon == v.ID then
					table.insert(newtable1,v)
				end
			else
				table.insert(newtable1,v)
			end
		end
	end
	for i, v in ipairs(newtable1) do
		local total = v.ID
		total = total + (self:isPersonHeadIconCanActive(v) and -100000 or 0)
		total = total + (v.ID == headicon and -10000 or 0)
		total = total + (self:isPersonHeadIconCanSelect(v) and -1000 or 0)
		v.sortID = total
		end
	table.sort(newtable1,function(a,b)
		return a.sortID < b.sortID
		end)
	self.headIconUIs = {}
	--初始化UI
	for k,v in ipairs(newtable1) do
		local Item = require(LAYER_WITEM)()
		local widgets = Item.vars
		local button = widgets.bt
		local count = widgets.item_count
		local tx = widgets.item_icon
		local bg1 = widgets.bg1
		local bg2 = widgets.bg2
		button:setTag(v.ID)
		button:onClick(self,self.chooseIcon,v)
		tx:setImage(g_i3k_db.i3k_db_get_head_icon_path(v.ID, false))
		local typeValue = v.typeID
		local content = ""
		local level = g_i3k_game_context:GetLevel()
		local viplevel = g_i3k_game_context:GetVipLevel()
		if typeValue == 1 then
			content="默认"
		elseif typeValue == 2 then
			if level < v.needItemId then
				tx:disable()
				content=string.format("%s级解锁",v.needItemId)
			else
				content="可选择"
			end
		elseif typeValue ==3 then
			
			if viplevel < v.needItemId then
				tx:disable()
				content=string.format("贵族%s解锁",v.needItemId)
			else
				content="可选择"
			end
		elseif typeValue == 5 then
			local id = v.ID
			if unlockHeads and unlockHeads[id] then
				content = "可选择"
			else
				tx:disable()
				if g_i3k_game_context:GetCommonItemCanUseCount(v.needItemId) >= v.needItemCount then
					content = "可启动"
					Item.vars.red:show()
				else
				content = "道具解锁"
				end
			end
		end
		if v.ID ~= headicon then
			bg1:hide()
			bg2:show()
		else
			bg1:show()
			bg2:hide()
			content = "已 选"
			self.changeIcon_btn:disableWithChildren()
		end
		count:setText(content)
		scroll:addItem(Item)
		self.headIconUIs[v.ID] = Item
	end
end
--激活头像成功
function wnd_friends:updateActiveHeadIcon(id)
	self.unlockHeads[id] = true
	if self.headIconUIs[id] then
		self.headIconUIs[id].vars.red:hide()
		self.headIconUIs[id].vars.item_count:setText("可选择")
		self.headIconUIs[id].vars.item_icon:enable()
	end
end

--心情日记
function wnd_friends:onMoodDiary(sender,openType)
	i3k_sbean.mood_diary_open_main_page(openType)
end

--心愿测试
function wnd_friends:onConstellationTip(sender)
	local personInfo = g_i3k_game_context:GetSelfMooddiaryPersonInfo()
	if g_i3k_game_context:GetLevel() < i3k_db_mood_diary_cfg.constellationTestOpenLevel then
		g_i3k_ui_mgr:PopupTipMessage(string.format("需要达到%d级才能进行星愿测试", i3k_db_mood_diary_cfg.constellationTestOpenLevel))
		return
	end
	if personInfo.self.gender > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ConstellationTest)
		g_i3k_ui_mgr:RefreshUI(eUIID_ConstellationTest, personInfo.self.gender, i3k_db_mood_diary_sex[personInfo.self.gender].questionGroup)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SetSex)
		g_i3k_ui_mgr:RefreshUI(eUIID_SetSex)
	end
end

--刷新头像框
function wnd_friends:updatePlayerHeadFrame()
	local BWType = g_i3k_game_context:GetTransformBWtype()
	local frameId = g_i3k_game_context:GetRoleHeadFrameId()
	self.txd_img:setImage(g_i3k_get_head_bg_path(BWType, frameId))
end

function wnd_friends:modifyName(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ModifyName)
	g_i3k_ui_mgr:RefreshUI(eUIID_ModifyName)
end
-- mtye 1 宿敌 2 黑名单
function wnd_friends:updateEnemyData(mtype)
	self._crossFriends = nil
	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1328))
	self:btnToPressed("enemy_btn")
	local enemy_layer =  require(LAYER_SUI)()
	self:rootShow(enemy_layer)
	local widgets = enemy_layer.vars
	local scroll = widgets.sudi_scroll
	local enemyBtn = widgets.sudi
	local blackBtn = widgets.heimingdan
	widgets.autoDelDesc:setText(i3k_get_string(18204, i3k_db_common.friends_about.blackList_auto_del / 24))
	enemyBtn:onClick(self,self.onEnemy2,blackBtn)
	blackBtn:onClick(self,self.onBlack,enemyBtn)
	self._blackListAutoDelMark = widgets.autoDelMark
	widgets.autoDel:onClick(self, self.blackListAutoDel)
	local enemyData = nil
	if mtype == 1 then
		enemyData = g_i3k_game_context:GetEnemyListData()
		widgets.desc:setText("没有任何宿敌")
		self.state = 4
		enemyBtn:stateToPressed(true)
		widgets.blackListAutoDel:setVisible(false)
	else
		enemyData = g_i3k_game_context:GetBlackListData2()
		widgets.desc:setText("黑名单没有玩家")
		self.state = 5
		blackBtn:stateToPressed(true)
		widgets.blackListAutoDel:setVisible(true)
		self:setAutoDelMark(0)
	end
	--获取数据
	--初始化UI控件
	if enemyData then
		local num = #enemyData
		if num == 0 then
			widgets.msd:show()
		else
			if self.state == 4 then
				enemyData = g_i3k_game_context:sortByTime()
			end
			widgets.msd:hide()
		end
		for k,v in ipairs(enemyData) do
			local Item = require(LAYER_SITEM)()
			local name = Item.vars.name_label
			local state = Item.vars.state--是否在线
			local deadTime = Item.vars.deadTime--死亡时间
			local tx = Item.vars.tx_img
			local level = Item.vars.level
			local zhiye = Item.vars.career
			local fightpower = Item.vars.fightpower--战力
			local showPosbtn = Item.vars.showPosbtn
			local delete_btn = Item.vars.delete_btn
			local overView = nil
			if self.state == 4 then
				local killTime = v.killTime
				local curLine = v.curLine
				local curMapID = v.curMapID
				local timeText = self:calculateTime(killTime,1)
				deadTime:setText(timeText)
				showPosbtn:setTag(curLine)
				showPosbtn:onClick(self,self.showEnemyPosition,curMapID)
				if curMapID == 0 then
					state:setImage(g_i3k_db.i3k_db_get_icon_path(1319))
				else
					state:setImage(g_i3k_db.i3k_db_get_icon_path(1318))
				end
				overView = v.overview
				delete_btn:onClick(self,self.deleteEnemy,overView.id)
			else
				overView = v
				local timeText = self:calculateTime(v.addtime,2)
				deadTime:setText(timeText)
				Item.vars.btn_text:setText(i3k_get_string(17734))
				showPosbtn:setTag(v.id)
				showPosbtn:onClick(self, self.onClickForbidInterAct, v.name)
				delete_btn:onClick(self,self.deleteBlack,overView.id)
				showPosbtn:SetIsableWithChildren(not v.isBanInterAct)
			end
			local tLvl = overView.tLvl
			local gender = overView.gender
			local gcfg = g_i3k_db.i3k_db_get_general(overView.type)
			zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
			name:setText(overView.name)
			tx:setImage(g_i3k_db.i3k_db_get_head_icon_path(overView.headIcon, false))
			Item.vars.txb_img:setImage(g_i3k_get_head_bg_path(overView.bwType, overView.headBorder))
			level:setText(overView.level)
			fightpower:setText("战力:" .. overView.fightPower)
			scroll:addItem(Item)
		end
	else
		widgets.msd:show()
	end
end

function wnd_friends:calculateTime(time,mtype)
	local timeText = ""
	local nowTime  = i3k_game_get_time()
	local nowTimeDays = g_i3k_get_day(nowTime)
	local deadTimeDays = g_i3k_get_day(time)
	local value = nowTimeDays-deadTimeDays
	if value == 0 then
		timeText="今天"
	elseif value == 1 then
		timeText="昨天"
	elseif value == 2 then
		timeText="三天前"
	else
		timeText="很久以前"
	end
	local str = ""
	if mtype == 1 then
		str = "死亡时间"
	else
		str = "加入时间"
	end
	timeText = string.format(str..":%s",timeText)
	return timeText
end

function wnd_friends:onFriends(sender)
	--备用
--	self:btnToPressed("friends_btn")
--	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1325))
	if self.state ~= 1 then
--		i3k_sbean.listFriend()
		i3k_sbean.syncFriend(1)
--		self:updateFriendsData()
	end
end

function wnd_friends:luckyStar(sender)
	if self.state == 3 then
		if g_i3k_game_context:GetLevel() >= i3k_db_luckyStar.cfg.limitLvl  then
			i3k_sbean.lucklystar_sync_req_send(1)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16870,i3k_db_luckyStar.cfg.limitLvl))
		end
	end
end

function wnd_friends:onMakeFriends(sender)
--	self:btnToPressed("makefr_btn")
--	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1326))
	--if self.state ~= 2 then
		i3k_sbean.plusListFriend()
	--end
end

function wnd_friends:onMyself(sender)
--	self:btnToPressed("myself_btn")
--	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1327))
	i3k_sbean.item_unlock_head()
--	self:updateMyselfData()
end

function wnd_friends:onEnemy(sender)
--	self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1328))
--	self:btnToPressed("enemy_btn")
	if self.state ~= 4 then
		i3k_sbean.getEnemyFriend()
	end
end
function wnd_friends:onEnemy2(sender,blackBtn)
	if self.state ~= 4 then
		i3k_sbean.getEnemyFriend()
	end
	sender:stateToPressed(true)
	blackBtn:stateToNormal(true)
end
function wnd_friends:onBlack(sender,enemyBtn)
	if self.state ~= 5 then
		i3k_sbean.getBlackFriend()
	end
	sender:stateToPressed(true)
	enemyBtn:stateToNormal(true)
end

function wnd_friends:deleteEnemy(sender,id)
	--发协议
	local function callback(isOK)
		if isOK then
			i3k_sbean.deleteEnemy(id)
		end
	end
	local msg = "是否删除该宿敌？"
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end
function wnd_friends:deleteBlack(sender,id)
	--发协议
	local function callback(isOK)
		if isOK then
			i3k_sbean.deleteBlackFriend(id)
		end
	end
	local msg = "是否移除黑名单？"
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end
function wnd_friends:showEnemyPosition(sender,mapId)
	local msg = ""
	if mapId == 0 then
		msg = i3k_get_string(579)
	else
		local mapName = ""
		local curLine = sender:getTag()
		if i3k_db_field_map[mapId] then
			mapName = i3k_db_field_map[mapId].desc
			msg = curLine ~= g_WORLD_KILL_LINE and i3k_get_string(578,curLine,mapName) or i3k_get_string(858, mapName)
		else
			msg = i3k_get_string(580)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox1(msg)
end

function wnd_friends:onClickForbidInterAct(sender, name)
	local id = sender:getTag()
	local msg = i3k_get_string(17731, name)
	local func = function(isOk)
		if isOk then
			i3k_sbean.blacklist_ban_interAct(id)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(msg, func)
end
function wnd_friends:changePersonState(sender,content)
	g_i3k_ui_mgr:OpenUI(eUIID_ChangePersonState)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChangePersonState,content)
end

function wnd_friends:changePersonalMsg(content)
	if self.personalMsg == content then
--		g_i3k_ui_mgr:PopupTipMessage("个人资讯未发生变化")
		return
	end
	self.personalMsg = content--本地缓存
	i3k_sbean.updatePlayerMsg(content)--同步服务器
	self:updateMyselfData()
end

function wnd_friends:checkBtn(sender)
	i3k_sbean.get_flowerlog()
end

--改头像
function wnd_friends:chooseIcon(sender,v)
	local unlockHeads = self.unlockHeads
	self.iconId = sender:getTag()
	local typeValue = v.typeID
	if typeValue == 2 then
		local level = g_i3k_game_context:GetLevel()
		if level < v.needItemId then
			local content=string.format("%s级解锁",v.needItemId)
			g_i3k_ui_mgr:PopupTipMessage(content)
			self.iconId = nil
			self.changeIcon_btn:disableWithChildren()
			return
		end
	elseif typeValue ==3 then
		local viplevel = g_i3k_game_context:GetVipLevel()
		if viplevel < v.needItemId then
			local content=string.format("贵族%s解锁",v.needItemId)
			g_i3k_ui_mgr:PopupTipMessage(content)
			self.iconId = nil
			self.changeIcon_btn:disableWithChildren()
			return
		end
	elseif typeValue == 5 then
		local id = v.ID
		if not (unlockHeads and unlockHeads[id]) then
			g_i3k_ui_mgr:OpenUI(eUIID_UnlockHead)
			g_i3k_ui_mgr:RefreshUI(eUIID_UnlockHead,id)
			return
		end
	elseif self.iconId == g_i3k_game_context:GetRoleHeadIconId() then
		self.iconId = nil
		self.changeIcon_btn:disableWithChildren()
		return
	end
	self.changeIcon_btn:enableWithChildren()
	self.tx_img:setImage(g_i3k_db.i3k_db_get_head_icon_path(self.iconId , false))
--[[	self:updateMyselfData()--]]
end

function wnd_friends:saveIcon(sender)
	if self.iconId == nil then
		g_i3k_ui_mgr:PopupTipMessage("请选择头像")
		return
	end
	local callback = function(isOk)
		if isOk then
			if self.iconId ~= nil then
				i3k_sbean.updatePlayerIcon(self.iconId)
			end
		end
	end
	local msg = "确定更改头像？"
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

--修改头像边框
function wnd_friends:onChangeFrame(sender)
	if g_i3k_game_context:GetTransformBWtype() ~= 0 then
		i3k_sbean.syncPlayerFrameIcon()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15570))
	end
end

function wnd_friends:isBagEnough()
	local id = i3k_db_common.friends_about.checken_ID
	local count = g_i3k_game_context:GetBagItemCount(id)
	local t = {}
	t[id] = count
	local isEnough = g_i3k_game_context:IsBagEnough(t)
	return isEnough
end

----一键收体力
function wnd_friends:doAction(sender)
	local data = g_i3k_db.i3k_db_get_friends_award(self.vitLv)
	if self.dayVitTakeTimes >= data.get_times then
		return g_i3k_ui_mgr:PopupTipMessage("领取次数已达上限")
	end
	local item = {}
	local id = i3k_db_common.friends_about.checken_ID
	local vitTab ={}
	local count = 0
	local FriendOverview = g_i3k_game_context:GetFriendsData()
	for k,v in ipairs(FriendOverview) do
		if FriendOverview[k].receiveVit == 1 then
			count= count+1
			local curTimes = self.dayVitTakeTimes+count
			if curTimes <= data.get_times then
				item[id] = count
				local isEnough = g_i3k_game_context:IsBagEnough(item)
				if isEnough then
						local id = FriendOverview[k].fov.overview.id
						vitTab[id] = true
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
					break;
				end
			else
				break

			end
		end
	end
	if count == 0 then
		g_i3k_ui_mgr:PopupTipMessage("无人赠送鸡翅，领取失败")
	else
		self.sender = nil
		self.vitTab = vitTab
		i3k_sbean.receiveVitFriend(vitTab)
	end
end

----一键送体力
function wnd_friends:giveAllVits(sender)
	local item = {}
	local id = i3k_db_common.friends_about.checken_ID
	local vitTab ={}
	local FriendOverview = g_i3k_game_context:GetFriendsData()
	for k,v in ipairs(FriendOverview) do
		if v.eachFriend == 1 and v.sendVit == 0 then
			local id = v.fov.overview.id
			vitTab[id] = id
		end
	end
	self.sender = nil
	self.vitTab = vitTab
	if table.nums(vitTab) > 0 then
		i3k_sbean.giveVitToAllFriend(vitTab)
	else
		g_i3k_ui_mgr:PopupTipMessage("当前没有可赠送体力的好友")
	end
end

----隐藏离线好友
function wnd_friends:onHideBtn(sender)
	g_i3k_game_context:setHideOfflineFri(not g_i3k_game_context:isHideOfflineFri())
	self:updateFriendsData()
end

function wnd_friends:getPower(sender,arg)
	local data = g_i3k_db.i3k_db_get_friends_award(self.vitLv)
	if self.dayVitTakeTimes >= data.get_times then
		return g_i3k_ui_mgr:PopupTipMessage("领取次数已达上限")
	end
	if arg[4] == 0 then
		return g_i3k_ui_mgr:PopupTipMessage("无人赠送鸡翅，领取失败")
	end
	local isEnough = self:isBagEnough()
	if isEnough then
		local playerId = arg[1]
		local vitTab ={}
		vitTab[playerId] = true
		local scroll = arg[2]
		if scroll then
			self.scrollPercent = scroll:getListPercent()
		end
		self.sender = sender
		i3k_sbean.receiveVitFriend(vitTab)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end

function wnd_friends:sendPower(sender,arg)
	local iseachfriends = arg[3];
	if iseachfriends == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(477))
	else
		local playerId = arg[1]
		if playerId then
			local scroll = arg[2]
			if scroll then
				self.scrollPercent = scroll:getListPercent()
			end
			self.sender = sender
			i3k_sbean.giveVitFriend(playerId)
		end
	end
end

function wnd_friends:getMore(sender,info)
	g_i3k_ui_mgr:OpenUI(eUIID_GetFriendsMoredec)
	g_i3k_ui_mgr:RefreshUI(eUIID_GetFriendsMoredec,info)
end

function wnd_friends:closeFC()
	g_i3k_ui_mgr:CloseUI(eUIID_GetFriendsMoredec)
end
--[[
通过self.sender 判断
self.sender不为空的情况为一个个的点击发送或收取，只改相应的按钮状态即可
为空则为一键收取
]]
function wnd_friends:updateUI(minus)
	minus = minus or 0
	if self.sender then
		self.sender:disableWithChildren()
	else
		if self.friendScroll then
			local widgets = self.friendScroll:getAllChildren()
			for i,item in ipairs(widgets) do
				local btn = nil
				if minus ~= 0 then
					btn = item.vars.sendpower_btn
				else
					btn = item.vars.getpower_btn
				end
				local tag = btn:getTag() - minus
				for  id ,_ in pairs(self.vitTab or {}) do
					if tonumber(tag) == id then
						btn:disableWithChildren()
						break
					end
				end
			end
		end
	end
	self:updateFriendsUI()
end

function wnd_friends:updateFriendsUI()
	local Data = g_i3k_game_context:getMyselfData()
	if Data then
		self.dayVitTakeTimes = Data.dayVitTakeTimes--体力领取次数
		self.vitLv = Data.vitLvl--体力的受赠等级
		self.personalMsg = Data.personalMsg--个人信息
		self.vitExp = Data.vitExp
	end
	local data = g_i3k_db.i3k_db_get_friends_award(self.vitLv)
	self.getCount:setText(self.dayVitTakeTimes .. "/" .. data.get_times)

	local nextdata = g_i3k_db.i3k_db_get_friends_award(self.vitLv+1)
	self.level:setText(self.vitLv .. "级")
	local VitPercent = 0
	if nextdata then
		VitPercent = self.vitExp/nextdata.awardExp_hight*100
	else
		VitPercent = 100
	end
	self.loadingBar:setPercent(VitPercent)
	local FriendOverview = g_i3k_game_context:GetFriendsData()--获取基本数据
	self.getBtn:disableWithChildren()
	for k,v in ipairs(FriendOverview) do
		if v.receiveVit == 1 then
			if self.getBtn then
				self.getBtn:enableWithChildren()
			end
			break
		end
	end
end

function wnd_friends:onShowLoveBtn(sender, info)
	-- 检查是否在当天的活动时间内
	local checkTime = g_i3k_db.i3k_db_get_is_activity_world_open(g_activity_show_world)
	if not checkTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17245))
		return
	end

	local checkDate = g_i3k_db.i3k_db_get_is_activity_world_open(g_activity_show_world)
	if not checkDate then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17246)) -- 不在日期范围内
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_ShowLove)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShowLove, info)
end

-- 老玩家召回
function wnd_friends:onRoleReturn(sender)
	i3k_sbean.sync_regression(function()
		g_i3k_ui_mgr:OpenUI(eUIID_RoleReturn)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleReturn)
	end)
end

--[[function wnd_friends:onClose(sender)
	self:closeFC()
	g_i3k_ui_mgr:CloseUI(eUIID_Friends)
end--]]

----排序相关
function wnd_friends:isPersonHeadIconCanActive(cfg)
	if self.unlockHeads and self.unlockHeads[cfg.ID] then
			return false
		end
		if cfg.typeID == 5 and g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemId) >= cfg.needItemCount then
			return true
		end
	return false
end
function wnd_friends:isPersonHeadIconCanSelect(cfg)
	local level = g_i3k_game_context:GetLevel()
	local viplevel = g_i3k_game_context:GetVipLevel()
	if self.unlockHeads and self.unlockHeads[cfg.ID] then
		return true
	end
	if cfg.typeID == 1 then--默认头像
		return true
	elseif cfg.typeID == 2 then--等级解锁
		return level >= cfg.needItemId
	elseif cfg.typeID == 3 then--vip解锁头像
		return viplevel >= cfg.needItemId
	end
	return false
end
----------end
function wnd_friends:updateRecommendList()
	local old_layer = self.uiRoot:getAddChild()
	local scroll  = old_layer[1].vars.fr_scroll
	local timeNow = i3k_game_get_time()
	local LAYER_MFITEM = "ui/widgets/jiahaoyout2"
	--获取数据
	--初始化UI控件
	local mfData = g_i3k_game_context:GetRecommendList()
	scroll:removeAllChildren()
	if mfData then
		local num = #mfData
		if num>0 then
			local rowNum = 1
			local children = scroll:addChildWithCount(LAYER_MFITEM,rowNum,num)
			for i,v in ipairs(mfData) do
				local widgets = children[i].vars
				local name = widgets.name_label
				local state = widgets.isfriend
				local txb =	widgets.txb_img
				local tx = widgets.tx_img
				local level = widgets.level
				local career = widgets.career
				local addfriend = widgets.apply_btn
				local fightPower = widgets.fightpower--战力
				local ismyfriend = widgets.duihao
				ismyfriend:hide()
				fightPower:setText("战力:" .. v.fightPower)
				addfriend:onClick(self,self.addFriend,v.id)
				local gcfg = g_i3k_db.i3k_db_get_general(v.type)
				career:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
				name:setText(v.name)
				tx:setImage(g_i3k_db.i3k_db_get_head_icon_path(v.headIcon, false))
				txb:setImage(g_i3k_get_head_bg_path(v.bwType, v.headBorder))
				level:setText(v.level)	
				if v.flag == 0 then
					state:setText("由系统推荐")
				elseif v.flag == 1 then
					state:setText("已加我为好友")
				elseif v.flag == 2 then
					local value2 = g_i3k_game_context:GetFriendsDataByID(v.id)
					if value2 then
						state:hide()
						addfriend:hide()
						ismyfriend:show()
					end
					state:setText("由搜索获得")
				end
			end
		end
	end	
end
function wnd_friends:addFriend(sender,playerId)
	i3k_sbean.addFriend(playerId, true)
end
function wnd_friends:onRefreshBtnClick(sender)
	--判断时间间隔，用时间戳判断
	local timeNow = i3k_game_get_time()
	local sendTime = g_i3k_game_context:GetRecommendSendTime()
	if sendTime then
		if timeNow-sendTime>=i3k_db_common.friends_about.cool_time then
			g_i3k_game_context:prepareFriendRecommendList(timeNow, false)
		else
			g_i3k_ui_mgr:PopupTipMessage("刷新冷却时间未到")
		end
	else
		g_i3k_game_context:prepareFriendRecommendList(timeNow, false)
	end
end
function wnd_friends:showRefreshBtn(isNull)
	self.refresh_btn:setVisible(isNull)
	self.getBtn:setVisible(not isNull)
	self.giveAllVitBtn:setVisible(not isNull)
	self.hideBtn:setVisible(not isNull)
	self.hideImage:setVisible(not isNull)
	self.hideLable:setVisible(not isNull)
	if isNull then
		self.selectIcon:setVisible(false)
		g_i3k_game_context:setHideOfflineFri(false)
	end
end
function wnd_friends:onAutoDel(sender)
	i3k_sbean.setAutoDel(1)
end
function wnd_friends:setAutoDelMark(tp)
	if tp == 0 then
		local autoDel = g_i3k_game_context:getAutoDelState(tp)
		self._blackListAutoDelMark:setVisible(autoDel)
	end
end
function wnd_friends:blackListAutoDel(sender)
	i3k_sbean.setAutoDel(0)
end
function wnd_create(layout)
	local wnd = wnd_friends.new()
		wnd:create(layout)
	return wnd
end
