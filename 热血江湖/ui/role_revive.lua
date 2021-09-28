-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

local sliderImg = {3767,3767,3768,3769,3770}
-------------------------------------------------------

wnd_role_revive = i3k_class("wnd_role_revive",ui.wnd_base)

function wnd_role_revive:ctor()
	self._reviveTime = 0;
	self._revivetimeLine = 0;
	self._isThunder = false;
end

function wnd_role_revive:configure()
	local widget = self._layout.vars
	self.btn3_text = widget.btn3_text
	self.btn2 = widget.btn2
	
	self.revive3Panel = widget.revive3Panel
	self.LeftTime = widget.LeftTime
	
	self.costpanel = widget.costpanel
	self.costicon = widget.costicon
	self.costtext = widget.costtext
	self.costlockicon = widget.costlockicon
	
	widget.btn1_text:setText("原地复活")
	widget.btn2_text:setText("复活点复活")
	
	widget.btn1:onClick(self, self.onReviveInsitu) -- 原地复活
	widget.btn2:onClick(self, self.onReviviePoint) -- 复活点复活
	widget.btn3:onClick(self, self.onSafeOrLeave)  -- 离开副本，安全区域复活
	widget.cprReviveBtn:onClick(self, self.onCprReviveBtn) --大地图cpr复活

	-- 推荐
	self.recRoot = widget.rec_root
	self.recCont = {widget.rec_cont1,widget.rec_cont2}
	self.recName = {widget.rec_name1,widget.rec_name2}
	self.recDes = {widget.rec_des1,widget.rec_des2}
	self.recTip = widget.rec_tip
	self._is_select = widget.is_select
	self._is_select2 = widget.is_select2
	self.topImage = widget.topImage;
	self.tlImage = widget.tlImage;
	self.recImg = {widget.recommendImg1,widget.recommendImg2}
	self.recSlider = {widget.slider1,widget.slider2}
	self.recSliderBG = {widget.slider1BG,widget.slider2BG}
	self.recSliderDesc = {widget.slider1Desc,widget.slider2Desc}
end

function wnd_role_revive:ThunderText()
	self._is_select:hide();
	self._is_select2:hide();
	self.topImage:hide();
	self.recTip:hide();
	self.tlImage:show();
	self.recName[1]:setText(i3k_get_string(970)) 
	self.recName[2]:setText(i3k_get_string(970)) 
	self.recDes[1]:setText(i3k_get_string(971))
	self.recDes[2]:setText(i3k_get_string(972))
end

function wnd_role_revive:refresh(isThunder)
	self.revive3Panel:setVisible(true)
	self._isThunder = isThunder;
	local cfg = i3k_db_common.rolerevive
	local serverTime = i3k_game_get_time()
	local lastrevive = g_i3k_game_context:GetReviveTickLine()
	if serverTime - lastrevive >= cfg.revivetime then
		self.LeftTime:hide()
		self:changefree(true)
	else
		self._reviveTime = (cfg.revivetime-(serverTime - lastrevive)) *1000;
		self._revivetimeLine = 0;
		self.LeftTime:show()
		self:changefree(false)
	end
	self:updateBtnText()
	self.costpanel:show()
	local cost = g_i3k_game_context:GetReviveCost()
	self.costtext:setText(cost)
	if isThunder then
		self:ThunderText();
	else
		self.tlImage:hide();
		self.topImage:show();
		self.recTip:show();
		self._is_select:show();
		self._is_select2:show();
		local recCfg = g_i3k_get_commend_mission()
		if #recCfg == 0 then 
			self.recRoot:setVisible(false)
		else
			for i=1,2 do
				if recCfg[i] then
					self.recName[i]:setText(i3k_db_want_improve_strongChild[recCfg[i]].name) 
					self.recDes[i]:setText(i3k_db_want_improve_strongChild[recCfg[i]].describe)
					self.recImg[i]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_want_improve_strongChild[recCfg[i]].iconID))
					self:setSliderBar(recCfg[i],i)
				else
					self.recCont[i]:setVisible(false)
				end 
			end
			self.recTip:setText(i3k_get_string(765))
		end
	end
	self:changeBtnPosition()
end

function wnd_role_revive:updateBtnText()
	local mapType = i3k_game_get_map_type()
	if mapType == g_FIELD then
		self.btn3_text:setText("安全区域复活")
	elseif mapType == g_Life or mapType == g_OUT_CAST or mapType == g_BIOGIAPHY_CAREER then
		self.btn3_text:setText("暂时离开")
	elseif mapType == g_BASE_DUNGEON or mapType == g_ACTIVITY or maptype == g_TOWER or mapType == g_FACTION_TEAM_DUNGEON or mapType == g_DEMON_HOLE or mapType == g_MAZE_BATTLE then
		self.btn3_text:setText("放弃离开")
	elseif mapType == g_FACTION_GARRISON then
		self.btn3_text:setText(i3k_get_string(16620))
	elseif mapType == g_PRINCESS_MARRY or mapType == g_MAGIC_MACHINE or mapType == g_GOLD_COAST or mapType == g_CATCH_SPIRIT then
		self.btn3_text:setText("放弃离开")
		self._layout.vars.btn3:disableWithChildren()
	end
end

function wnd_role_revive:onReviveInsitu(sender)
	local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
	local havefree = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
	if have + havefree >= g_i3k_game_context:GetReviveCost() then
		i3k_sbean.role_revive_insitu(1)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(293))
	end
end

function wnd_role_revive:onReviviePoint(sender)
	if i3k_game_get_map_type() ~= g_FACTION_GARRISON then
		i3k_sbean.role_revive_other()
	else
		i3k_sbean.role_sect_zone_revive_safe()
	end 
end

local withoutMessageMapType = {
	[g_Life] = true,
	[g_OUT_CAST] = true,
	[g_FACTION_GARRISON] = true,
	[g_SPIRIT_BOSS] = true,
	[g_FIVE_ELEMENTS] = true,
	[g_SPY_STORY]	= true,
	[g_BIOGIAPHY_CAREER] = true,
}
local withMessageMapType = {
	[g_BASE_DUNGEON] = true,
	[g_ACTIVITY] = true,
	[g_TOWER] = true,
	[g_FACTION_TEAM_DUNGEON] = true,
	[g_RIGHTHEART] = true,
	[g_ANNUNCIATE] = true,
	[g_DEMON_HOLE] = true,
	[g_DEFEND_TOWER] = true,
	[g_ILLUSORY_DUNGEON] = true,
	[g_DOOR_XIULIAN] = true,
	[g_MAZE_BATTLE] = true,
	[g_AT_ANY_MOMENT_DUNGEON] = true,
	[g_LONGEVITY_PAVILION]	  = true,
	[g_SPY_STORY]			  = true, 
}
function wnd_role_revive:onSafeOrLeave(sender)
	local mapType = i3k_game_get_map_type()
	if mapType == g_FIELD then
		if g_i3k_game_context:GetSuperOnHookValid() then
			g_i3k_game_context:SetSuperOnHookValid(false)
		end
		i3k_sbean.role_revive_safe()
	elseif withoutMessageMapType[mapType] then
		i3k_sbean.mapcopy_leave()
	elseif withMessageMapType[mapType] then
		local fun = (function(ok)
			if ok then
				i3k_sbean.mapcopy_leave()
			end
		end)
		g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(66), fun)
	end
end

function wnd_role_revive:changefree(flag)
	if flag then
		self.btn2:enableWithChildren()
	else
		self.btn2:disableWithChildren()
	end
end

function wnd_role_revive:onUpdate(dTime)
	self._revivetimeLine = self._revivetimeLine + dTime*1000;
	if self._reviveTime >0 then
		local tm = i3k_integer((self._reviveTime - self._revivetimeLine) / 1000);
		if tm > 0 then
			if tm > 10 then
				self:updateTimeElapse(tm, "ffffffff");
			else
				self:updateTimeElapse(tm, "ffff0000");
			end
		else
			self:changefree(true)
			self:enableTimeElapse(false);
			if g_i3k_game_context:GetSuperOnHookValid() then
				i3k_sbean.role_revive_other()
			end
		end	
	end
end

function wnd_role_revive:enableTimeElapse(value)
	if value then
		self.LeftTime:show()
	else
		self.LeftTime:hide()
	end
end

function wnd_role_revive:updateTimeElapse(time, color)
	local formatTime = function(time)
		local tm = time;

		local h = i3k_integer(tm / (60 * 60));
		tm = tm - h * 60 * 60;

		local m = i3k_integer(tm / 60);
		tm = tm - m * 60;

		local s = tm;
		return string.format("%02d:%02d:%02d", h, m, s);
	end

	self.LeftTime:setText(formatTime(time));
	self.LeftTime:setTextColor(color);
end

function wnd_role_revive:changeBtnPosition()
	if i3k_game_get_map_type() == g_FIELD then
		local line = g_i3k_game_context:GetCurrentLine()
		if line ~= g_WORLD_KILL_LINE then
			local cprReviveTime = g_i3k_game_context:getCprReviveTimes()
			self._layout.vars.cprLeftTimes:setText(i3k_get_string(18086, i3k_db_common.rolerevive.cprReviveTimes - cprReviveTime))
			if cprReviveTime >= i3k_db_common.rolerevive.cprReviveTimes then
				self._layout.vars.cprReviveBtn:disableWithChildren()
			end
			return
		end
	end
	self._layout.vars.cprRoot:hide()
	local pos1 = self._layout.vars.btnRoot1:getPosition()
	local pos3 = self._layout.vars.btn3:getPosition()
	self._layout.vars.revivePosRoot:setPosition({x = (pos1.x + pos3.x)/2, y = pos1.y})
end
function wnd_role_revive:onCprReviveBtn(sender)
	if g_i3k_game_context:GetSuperOnHookValid() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1827))
	end
		local cprReviveTime = g_i3k_game_context:getCprReviveTimes()
	if cprReviveTime < i3k_db_common.rolerevive.cprReviveTimes then
		for _, v in ipairs(i3k_db_common.rolerevive.cprReviveFile) do
			if i3k_db_video_data[v].condition == g_i3k_game_context:GetRoleGender() then
				local path = "video/"..i3k_db_video_data[v].fileName
				i3k_game_on_video_play_start(path)
				break
			end
		end
		end
	end

function wnd_role_revive:setSliderBar(id,i)
	local percent = g_i3k_game_context:GetWantImproveProgress(id)
	local sliderDesc = self.recSliderDesc[i]
	local slider = self.recSlider[i]
	local sliderBG = self.recSliderBG[i]
	if percent then
		slider:setPercent(percent * 100)
		local info = g_i3k_db.i3k_db_get_StrengthenSelf_Slider_Info(percent * 100)
		if info then
			sliderDesc:setText(info.judgeText)
			sliderDesc:setTextColor(info.color)
			slider:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconID))
		end
	else
		slider:setVisible(false)
		sliderBG:setVisible(false)
		sliderDesc:setVisible(false)
	end
end
function wnd_create(layout)
	local wnd = wnd_role_revive.new()
		wnd:create(layout)
	return wnd
end
