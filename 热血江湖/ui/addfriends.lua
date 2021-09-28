-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_addFriends = i3k_class("wnd_addFriends", ui.wnd_base)

local LAYER_MFITEM = "ui/widgets/jiahaoyout"

function wnd_addFriends:ctor()
end

function wnd_addFriends:configure()
	self._layout.vars.find_btn:onClick(self, self.find)
	self._layout.vars.sysrecommend:onClick(self, self.recommend)
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_addFriends:refresh()
end

function wnd_addFriends:updateMakefrData()
	local widgets = self._layout.vars
	
	local scroll  = widgets.friend_scroll
	local pagenum = widgets.pageNum
	self.editbox = widgets.editbox
	self.editbox:setPlaceHolder("请输入玩家昵称：")
	local find_btn = widgets.find_btn
	local tuijian = widgets.sysrecommend
	
	find_btn:onClick(self,self.find)
	tuijian:onClick(self,self.recommend)
	
	--获取数据
	--初始化UI控件
	local mfData = g_i3k_game_context:GetRecommendList()
	scroll:removeAllChildren()
	if mfData then
		local num = #mfData
		if num>0 then
			local children = scroll:addChildWithCount(LAYER_MFITEM,2,num)
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

function wnd_addFriends:addFriend(sender,playerId)
	i3k_sbean.addFriend(playerId)
end
function wnd_addFriends:find(sender)
	--搜索
	local content =	self.editbox:getText() 
	if content then
		if content == "" then 
			g_i3k_ui_mgr:PopupTipMessage("输入不能为空")
		else
			g_i3k_game_context:SetRecommendList1(nil)
			i3k_sbean.searchFriend(content)
		end
	end
end	
function wnd_addFriends:recommend(sender)--推荐
	--判断时间间隔，用时间戳判断
	local timeNow = i3k_game_get_time()
	local sendTime = g_i3k_game_context:GetRecommendSendTime()
	if sendTime then
		if timeNow-sendTime>=i3k_db_common.friends_about.cool_time then
			g_i3k_game_context:prepareFriendRecommendList(timeNow, true)
		else
			g_i3k_ui_mgr:PopupTipMessage("刷新冷却时间未到")
		end
	else
		g_i3k_game_context:prepareFriendRecommendList(timeNow, true)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_addFriends.new()
	wnd:create(layout, ...)
	return wnd;
end
