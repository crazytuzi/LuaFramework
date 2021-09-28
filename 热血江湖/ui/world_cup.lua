------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_world_cup = i3k_class("wnd_world_cup",ui.wnd_base)

local T1_WIDGETS = "ui/widgets/shijiebeit1"
local RowitemCount = 4
local TotleCount = 8
local MaxCountryCount = 32
local DefaultImage = 6637
local RankMap = {6623, 6643, 6649}
local CheckColor = "FF003646"
local UnCheckColor = "FF631B00"

function wnd_world_cup:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.xiaozu_btn:onClick(self,self.onXiaozuBtnClick)
	widgets.taotai_btn:onClick(self,self.onTaotaiBtnClick)
	widgets.deadline:setText(string.format(i3k_db_string[1408], i3k_db_world_cup_other.wagerEndDataStr))	
	self:onXiaozuBtnClick()
end

function wnd_world_cup:refresh()
	self:onXiaozuShow()
end

function wnd_world_cup:onXiaozuBtnClick()   --点击小组赛按钮
	local widgets = self._layout.vars
	widgets.xiaozu:setVisible(true)
	widgets.taotai:setVisible(false)
	self:onXiaozuShow()
end

function wnd_world_cup:onTaotaiBtnClick()	--点击淘汰赛按钮
	self:onTaotaiShow()
end

function wnd_world_cup:onXiaozuShow()
	local temp = {} --记录每个组加入多少个国家
	local widgets = self._layout.vars
	local groups = widgets.xiaozu_content:addChildWithCount(T1_WIDGETS, RowitemCount, TotleCount, true)
	for i = 1, #i3k_db_world_cup_team do
		local cfg = i3k_db_world_cup_team[i]
		local widget = groups[cfg.group].vars
		if temp[cfg.group] then
			temp[cfg.group] = temp[cfg.group] + 1
		else
			temp[cfg.group] = 1
			widget.groupName:setText(i3k_db_world_cup_group_name[cfg.group])
		end
		widget['img'..temp[cfg.group]]:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
		widget['name'..temp[cfg.group]]:setText(cfg.name)
		widget['red'..temp[cfg.group]]:setVisible(g_i3k_game_context:getWorldCupCountry(i) and true or false)
		local tempBtn = widget['btn'..temp[cfg.group]]
		tempBtn.countryId = i
		tempBtn:onClick(self,self.onTeamBtnClick)
	end
	widgets.count:setText(g_i3k_game_context:getWorldCupBetCount()..'/'..i3k_db_world_cup_other.wagerCount)
	widgets.xiaozu_btn:stateToPressedAndDisable()
	widgets.taotai_btn:stateToNormal()
	widgets.xiaozu_txt:setTextColor(CheckColor)
	widgets.taotai_txt:setTextColor(UnCheckColor)
end

function wnd_world_cup:onTaotaiShow()
	local widgets = self._layout.vars
	widgets.xiaozu:setVisible(false)
	widgets.taotai:setVisible(true)
	widgets.taotai_count:setText(g_i3k_game_context:getWorldCupBetCount()..'/'..i3k_db_world_cup_other.wagerCount)
	local gamePicture = g_i3k_game_context:getWorldCupPicture()
	for i = 1,MaxCountryCount do
		local tempPos = gamePicture[i]
		local img = widgets['p'..tempPos.record..'_'..tempPos.position]
		local lab = widgets['t'..tempPos.record..'_'..tempPos.position]
		img:setImage(g_i3k_db.i3k_db_get_icon_path(tempPos.countryId == 0 and DefaultImage or i3k_db_world_cup_team[tempPos.countryId].icon ))
		lab:setText(tempPos.countryId == 0 and "" or i3k_db_world_cup_team[tempPos.countryId].name )
		if tempPos.position == 0 then--说明是前四名)
			local rankImg = widgets['g'..tempPos.record..'_'..tempPos.position]
			rankImg:setVisible(tempPos.rank > 0 and tempPos.rank < 4)--如果是1 3名显示皇冠
			rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(RankMap[tempPos.rank]))
		end
	end
	widgets.xiaozu_btn:stateToNormal()
	widgets.taotai_btn:stateToPressedAndDisable()
	widgets.xiaozu_txt:setTextColor(UnCheckColor)
	widgets.taotai_txt:setTextColor(CheckColor)
end

function wnd_world_cup:onTeamBtnClick(sender)
	if not g_i3k_game_context:getWorldCupCountry(sender.countryId) then
		if g_i3k_get_GMTtime(i3k_game_get_time()) > i3k_db_world_cup_other.wagerEndDate then
			g_i3k_ui_mgr:PopupTipMessage(string.format(i3k_db_string[1423]))
			return;
		end
		if g_i3k_game_context:getWorldCupBetCount() < i3k_db_world_cup_other.wagerCount then
			g_i3k_ui_mgr:OpenUI(eUIID_WorldCupYaZhu)
			g_i3k_ui_mgr:RefreshUI(eUIID_WorldCupYaZhu, sender.countryId)
		else
			g_i3k_ui_mgr:PopupTipMessage(string.format(i3k_db_string[1414], i3k_db_world_cup_other.wagerCount))
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_WorldCupResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_WorldCupResult, sender.countryId)
	end
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_world_cup.new()
	wnd:create(layout,...)
	return wnd
end
