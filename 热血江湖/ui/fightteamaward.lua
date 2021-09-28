-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamAward = i3k_class("wnd_fightTeamAward", ui.wnd_base)

function wnd_fightTeamAward:ctor()
	self.gameReward = i3k_db_fightTeam_tournament_reward
	self.personReward = i3k_db_fightTeam_honor_reward
end

function wnd_fightTeamAward:configure(...)
	self.ui = self._layout.vars
	g_i3k_ui_mgr:CloseUI(eUIID_FightTeamGameReport)
	self.ui.tab1:onClick(self,self.showGameReward)
	self.ui.tab2:onClick(self,self.showPersonReward)
	self.ui.myTeam:setVisible(g_i3k_game_context:isShowMyTeamBtn())
	self.ui.myTeam:onClick(self,function ()
		g_i3k_ui_mgr:OpenUI(eUIID_FightTeamInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamInfo,nil,true)
	end)
end

function wnd_fightTeamAward:refresh()
	self:showGameReward()
end

local function getItem()
	local item = require("ui/widgets/wudaohuijlt")()
	return item
end

local function hideItem(_item, index)
	for i = index,6,1 do
		if _item.vars["itemRoot" .. i] then
			_item.vars["itemRoot" .. i]:setVisible(false)
		end
	end
end

local function setAward(item,index,id,count)
	item["item_bg" .. index]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	item["item_icon" .. index]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	item["item_count" .. index]:setText("X" .. count)
	if id < 0 then
		item["lock" .. index]:setVisible(true)
	end
	item["item_btn" .. index]:onTouchEvent(nil,function (hoster,sender,eventType)
		if eventType == 2 then
			g_i3k_ui_mgr:ShowCommonItemInfo(id)
		end
	end)
end

function wnd_fightTeamAward:showGameReward()
	self.ui.tab1:stateToPressed()
	self.ui.tab2:stateToNormal()

	self.ui.scroll:removeAllChildren()
	
	local result = g_i3k_game_context:getFightTeamResult()
	for k,v in ipairs(self.gameReward) do
		local _item = getItem()
		self.ui.scroll:addItem(_item)
		_item.vars.titlePerson:setVisible(false)
		if v.icon ~= 0 then
			_item.vars.titleText:setVisible(false)
			_item.vars.titleGame:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		else
			_item.vars.titleGame:setVisible(false)
			_item.vars.titleText:setText(v.stageDesc)
		end
		--队长奖励
		local index = 1
		local award = {}
		for k1,v1 in ipairs(v.leaderReward) do
			if v1.id ~= 0 then
				setAward(_item.vars,index,v1.id,v1.count)
				_item.vars["leader" .. index]:setVisible(true)
				index = index + 1
				if g_i3k_game_context:getIsFightTeamLeader() then
					table.insert(award,v1)
				end
			end
		end
		--队员奖励
		for k1,v1 in ipairs(v.memberReward) do
			if v1.id ~= 0 then
				setAward(_item.vars,index,v1.id,v1.count)
				index = index + 1
				table.insert(award,v1)
			end
		end
		
		if result.teamResult and result.teamResult > 0 then
			if v.id == result.teamResult then
				_item.vars.getBtn:setVisible(true)
				_item.vars.getBtn:onClick(nil,function ()
					if g_i3k_game_context:IsBagEnough(g_i3k_db.i3k_db_cfg_items_to_BagEnougMap2(award)) then
					i3k_sbean.request_tournament_take_teamreward_req(function ()
						g_i3k_ui_mgr:ShowGainItemInfo(award)
						g_i3k_game_context:getTeamReward()
						if g_i3k_ui_mgr:GetUI(eUIID_FightTeamAward) then
							_item.vars.getBtn:disableWithChildren()
						end
					end)
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
					end
				end)
				if result.teamReward == 1 then
					_item.vars.getBtn:disableWithChildren()
				end
			end
		end
		
		hideItem(_item,index)
	end
end

function wnd_fightTeamAward:showPersonReward()
	self.ui.tab2:stateToPressed()
	self.ui.tab1:stateToNormal()
	self.ui.scroll:removeAllChildren()
	
	local result = g_i3k_game_context:getFightTeamResult()
	local getIndexId = function ()
		--结束
		if g_i3k_game_context:getScheduleStage() == #(g_i3k_game_context:getFightTeamSchedule()) then
			--参赛
			if  g_i3k_game_context:getFightTeamHonor() > 0 then
				if result.roleRank == 0 then
					return -1
				end
				for k,v in ipairs(self.personReward) do
					if v.id >= result.roleRank then
						return v.id
					end
				end
			end
		end
		return 0
	end
	for k,v in ipairs(self.personReward) do
		local _item = getItem()
		self.ui.scroll:addItem(_item)
		_item.vars.titleGame:setVisible(false)
		if v.icon ~= 0 then
			_item.vars.titleText:setVisible(false)
			_item.vars.titlePerson:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		else
			_item.vars.titlePerson:setVisible(false)
			_item.vars.titleText:setText(v.rankDesc)
		end
		--个人奖励
		local index = 1
		local award = {}
		for k1,v1 in ipairs(v.honorReward) do
			if v1.id ~= 0 then
				setAward(_item.vars,index,v1.id,v1.count)
				table.insert(award,v1)
				index = index + 1
			end
		end
		
		if v.id == getIndexId() then
			_item.vars.getBtn:setVisible(true)
			_item.vars.getBtn:onClick(nil,function ()
				if g_i3k_game_context:IsBagEnough(g_i3k_db.i3k_db_cfg_items_to_BagEnougMap2(award)) then
				i3k_sbean.request_tournament_take_rolereward_req(function ()
					g_i3k_ui_mgr:ShowGainItemInfo(award)
					g_i3k_game_context:getRoleReward()
					if g_i3k_ui_mgr:GetUI(eUIID_FightTeamAward) then
						_item.vars.getBtn:disableWithChildren()
					end
				end)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
				end
			end)
			if result.roleReward == 1 then
				_item.vars.getBtn:disableWithChildren()
			end
		end
		
		hideItem(_item,index)
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_fightTeamAward.new();
	wnd:create(layout, ...);
	return wnd;
end
