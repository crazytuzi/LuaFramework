-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_friendsFC = i3k_class("wnd_friendsFC", ui.wnd_base)

local LAYER_MORE = "ui/widgets/hygnt"

function wnd_friendsFC:ctor()
	self._friendData = nil
end

function wnd_friendsFC:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local factionId = g_i3k_game_context:GetFactionSectId()
	local myPos = g_i3k_game_context:GetSectPosition() or 0
	if factionId ~= 0 and  i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
		self.infotb = {
			{name="查看信息",callback=self.check},
			{name="密语",callback=self.private},
			{name="赠花",callback=self.giveFlowers},
			{name="查看日记", callback = self.openFriendsDiary,isMoodDiary = true},
			{name="+关注度+",callback=self.addAtt},
			{name="-关注度-",callback=self.reduceAtt},
			{name="删除",callback=self.delete},
			{name="邀请入帮",callback=self.inviteFaction},
			{name="加黑名单",callback=self.blackFriends},
			{name="切磋",callback=self.challenge},
			{name="示爱", callback = self.useShowLoveItem},			
			{name="拜访家园", callback = self.openHomeLand},
		}
	else
		self.infotb = {
			{name="查看信息",callback=self.check},
			{name="密语",callback=self.private},
			{name="赠花",callback=self.giveFlowers},
			{name="查看日记", callback = self.openFriendsDiary,isMoodDiary = true},
			{name="+关注度+",callback=self.addAtt},
			{name="-关注度-",callback=self.reduceAtt},
			{name="删除",callback=self.delete},
			{name="加黑名单",callback=self.blackFriends},
			{name="切磋",callback=self.challenge},
			{name="示爱", callback = self.useShowLoveItem},			
			{name="拜访家园", callback = self.openHomeLand},
		}
	end
end

function wnd_friendsFC:onShow()

end

function wnd_friendsFC:initScroll(info)
	local jsScroll = self._layout.vars.btn_scroll
	jsScroll:setBounceEnabled(false)
	local homelandStr = self:getPlayerRelationShipTxt(info.overview.id)
	local name = ""
	local temData = {}
	
	for i = 1, #self.infotb do
		local flag = false
		
		if not self.infotb[i].isMoodDiary then
			flag = true
		else
			if info.overview.level >= i3k_db_mood_diary_cfg.openLevel then
				flag = true
			end
		end
		
		if flag then
			table.insert(temData, self.infotb[i])
		end
	end
	
	local children = jsScroll:addChildWithCount(LAYER_MORE, 2, table.nums(temData), true)
	
	for k, v in ipairs(children) do
		local item = children[k].vars
		name = temData[k].name
		
		if name == "拜访家园" then 
			name = homelandStr
		end
		
		item.btnName:setText(name)
		item.btn:onClick(self, temData[k].callback, info)
	end
end

function wnd_friendsFC:openFriendsDiary(sender,info)
	--local newData = info.fov.overview
	i3k_sbean.mood_diary_open_main_page(2, info.overview.id)
end

function wnd_friendsFC:refresh(info)
	self._friendData = info
	local newData = info.fov
	self:initScroll(newData)
end

function wnd_friendsFC:check(sender,info)
	--发协议
	local id = info.overview.id
	i3k_sbean.query_rolefeature(id)
	self:onClose()
end

function wnd_friendsFC:private(sender,info)
	local data = info.overview
	local player = {}
	player.msgType = global_recent
	player.name = data.name
	player.id = data.id
	player.level = data.level
	player.iconId = data.headIcon

	g_i3k_ui_mgr:OpenUI(eUIID_PriviteChat)
	g_i3k_ui_mgr:RefreshUI(eUIID_PriviteChat, player)
	self:onClose()
end

function wnd_friendsFC:giveFlowers(sender, info)
	local data = info.overview
	local player = {id = data.id, iconId = data.headIcon, level = data.level, name = data.name, bwType = data.bwType, headBorder = data.headBorder}
	g_i3k_logic:OpenSendFlowerUI(player)
	self:onCloseUI()
end

function wnd_friendsFC:openHomeLand(sender, info)
	g_i3k_game_context:gotoPlayerHomeLand(info.overview.id)
end

--斗技
function wnd_friendsFC:challenge(sender,info)
	--发协议
--[[	g_i3k_ui_mgr:OpenUI(eUIID_ArenaSetBattle)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaSetBattle, info.overview, enemy.rank, enemy.pets,  self._info.rankNow)--]]
	--g_i3k_ui_mgr:PopupTipMessage("功能暂未开放")
--	self:onClose()
	i3k_sbean.request_role_single_invite_req(info.overview.id)
end

-- 示爱道具
function wnd_friendsFC:useShowLoveItem(sender, info)
	g_i3k_logic:openShowLoveItemUI(info.overview.id)
end

--关注度
function wnd_friendsFC:addAtt(sender,info)
	--发协议
	local id = info.overview.id
	local attenhight = i3k_db_common.friends_about.attention_hight
	local addValue = i3k_db_common.friends_about.attention_add
	local atten = g_i3k_game_context:GetfriendsAttention(id)
	if atten >=attenhight then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(303,info.overview.name))
	else
		i3k_sbean.setFriendsFocus(id,1)
	end
end
function wnd_friendsFC:reduceAtt(sender,info)
	--发协议
	local id = info.overview.id
	local addValue = i3k_db_common.friends_about.attention_add
	local atten = g_i3k_game_context:GetfriendsAttention(id)
	if atten<addValue then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(304,info.overview.name))
	else
		i3k_sbean.setFriendsFocus(id,-1)
	end
end
function wnd_friendsFC:delete(sender,info)
	--发协议
	local function callback(isOK)
		if isOK then
			local id = info.overview.id
			i3k_sbean.deleteFriend(id)
		end
	end
	local msg = "是否删除该好友？"
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
	self:onClose()
end
function wnd_friendsFC:inviteFaction(sender,info) --邀请入帮协议
	i3k_sbean.invite_faction(info.overview.id)
end
function wnd_friendsFC:blackFriends(sender,info) --加入黑名单
	i3k_sbean.addBlackFriend(info.overview.id,true)
	self:onClose()
end

function wnd_friendsFC:getPlayerRelationShipTxt(roleID)
	if g_i3k_game_context:checkIsLover(roleID) then 
		if g_i3k_game_context:IsFemaleRole() then 
			return "丈夫的家园" 
		else 
			return "妻子的家园"
		end
	elseif g_i3k_game_context:CheckIsMaster(roleID)then   
		return "师傅的家园"
	elseif g_i3k_game_context:CheckIsStudent(roleID) then 
		return "徒弟的家园"
	end
	return "拜访家园"
end 

function wnd_friendsFC:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_GetFriendsMoredec)
end

function wnd_create(layout, ...)
	local wnd = wnd_friendsFC.new();
		wnd:create(layout, ...);

	return wnd;
end
