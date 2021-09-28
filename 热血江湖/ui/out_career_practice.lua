-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_out_career_practice = i3k_class("wnd_out_career_practice", ui.wnd_base)


function wnd_out_career_practice:ctor()
	self._careerId = 0
	self._state = 0
	self._countdown = 0
	self._lastUnlock = 0
end

function wnd_out_career_practice:configure()
	self._layout.vars.goBtn:onClick(self,self.onGoBtn)
	self._layout.vars.close:onClick(self,self.onCloseUI)
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
	self._layout.vars.rewardBtn:onClick(self, self.onRewardBtn)
end

function wnd_out_career_practice:refresh(careerId)
	self._careerId = careerId
	self._state, self._countdown = g_i3k_game_context:isCanTransformBack(self._careerId)
	self._layout.vars.title:setText("拳师历练")
	self._layout.vars.desc:setText(i3k_get_string(18500))
	self:updateTaskIcons()
	self:updateBtnState()
	self:updateBoxState()
	self:updateAnimate()
end

function wnd_out_career_practice:updateTaskIcons()
	local info = g_i3k_game_context:getBiographyCareerInfo()
	local taskId = info[self._careerId].taskId
	for k, v in ipairs(i3k_db_biography_career_common.icons) do
		self._layout.vars["icon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		if self._state == g_BIOGIAPHY_STATE_UNFINISH and v.task > taskId then
			self._layout.vars["icon"..k]:disable()
		else
			self._lastUnlock = k
		end
	end
	if self._state ~= g_BIOGIAPHY_STATE_UNFINISH then
		self._lastUnlock = 6
	end
end

function wnd_out_career_practice:updateBtnState()
	if self._state == g_BIOGIAPHY_STATE_WITHINTIME then
		self._layout.vars.goBtn:enableWithChildren()
		self._layout.vars.goBtnText:setText("反悔")
		self._layout.vars.countdown:show()
		self:updateRemaintime()
	elseif self._state == g_BIOGIAPHY_STATE_OVERDUE then
		self._layout.vars.goBtn:disableWithChildren()
		self._layout.vars.goBtnText:setText("反悔")
		self._layout.vars.countdown:show()
		self._layout.vars.countdown:setText(i3k_get_string(18514))
	elseif self._state == g_BIOGIAPHY_STATE_CONFESSED then
		self._layout.vars.goBtn:disableWithChildren()
		self._layout.vars.goBtnText:setText("反悔")
		self._layout.vars.countdown:show()
		self._layout.vars.countdown:setText(i3k_get_string(18515))
	elseif self._state == g_BIOGIAPHY_STATE_UNFINISH then
		self._layout.vars.goBtn:enableWithChildren()
		self._layout.vars.goBtnText:setText("前往历练")
		self._layout.vars.countdown:hide()
	elseif self._state == g_BIOGIAPHY_STATE_FINISH then
		self._layout.vars.goBtn:enableWithChildren()
		self._layout.vars.goBtnText:setText(i3k_get_string(18507))
		self._layout.vars.countdown:hide()
	end
end

function wnd_out_career_practice:updateRemaintime()
	if self._countdown > 86400 then
		local remainTime = math.ceil(self._countdown / 86400) 
		self._layout.vars.countdown:setText(i3k_get_string(18511, remainTime))
	elseif self._countdown > 3600 then
		local remainTime = math.ceil(self._countdown / 3600) 
		self._layout.vars.countdown:setText(i3k_get_string(18512, remainTime))
	else
		local remainTime = math.ceil(self._countdown / 60)
		self._layout.vars.countdown:setText(i3k_get_string(18513, remainTime))
	end
end

function wnd_out_career_practice:onGoBtn(sender)
	if self._state == g_BIOGIAPHY_STATE_WITHINTIME then
		self:onRegret()
	elseif self._state == g_BIOGIAPHY_STATE_OVERDUE then
		--
	elseif self._state == g_BIOGIAPHY_STATE_CONFESSED then
		--
	elseif self._state == g_BIOGIAPHY_STATE_UNFINISH then
		self:onEnterBiography()
	elseif self._state == g_BIOGIAPHY_STATE_FINISH then
		self:onTransform()
	end
end

function wnd_out_career_practice:onRegret()
	local log = g_i3k_game_context:getBiographyCareerLog()
	local _cfg = i3k_db_zhuanzhi[log.classType]
	local trfLvl = g_i3k_game_context:GetTransformLvl()
	local oldProfessionName = _cfg[trfLvl][log.bwType].name
	self._titleName = string.format("%s-%s-%s", i3k_db_generals[log.classType].name, i3k_get_transfer_type_desc(log.bwType), oldProfessionName)
	g_i3k_ui_mgr:OpenUI(eUIID_ChangeProfession)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChangeProfession, 0, self._titleName, log.bwType, log.classType, g_BIOGRAPHY_TRANSFORM_REGRET)
end

function wnd_out_career_practice:onEnterBiography()
	local roleLevel	= g_i3k_game_context:GetLevel()
	local transformLvl = g_i3k_game_context:GetTransformLvl()
	local data = i3k_db_wzClassLand[self._careerId]
	local needChangeLevel = data.needChangeLevel
	local needRoleLevel = data.needRoleLevel
	if roleLevel < needRoleLevel or transformLvl < needChangeLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18504, needRoleLevel, needChangeLevel))
	else
		local careerId = self._careerId
		local func = function ()
			if g_i3k_game_context:IsInRoom() then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
				return
			end
			g_i3k_game_context:ClearFindWayStatus()
			i3k_sbean.biography_class_map_start(careerId)
		end
		g_i3k_game_context:CheckMulHorse(func)
	end
end

function wnd_out_career_practice:onTransform()
	g_i3k_ui_mgr:OpenUI(eUIID_TransferPreview)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransferPreview, true, self._careerId)
end

function wnd_out_career_practice:onRewardBtn(sender)
	if self._state == g_BIOGIAPHY_STATE_UNFINISH then
		local gift = {}
		local rewards = i3k_db_wzClassLand[self._careerId].rewards
		for i, v in ipairs(rewards) do
			gift[i] = {ItemID = v.rewordBox, count = v.rewordCountBox}
		end 
		g_i3k_ui_mgr:OpenUI(eUIID_RewardTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_RewardTips, gift, -1)
	else
		local info = g_i3k_game_context:getBiographyCareerInfo()
		if info[self._careerId].boxReward == 0 then
			i3k_sbean.biography_class_receive_box_reward(self._careerId)
		end
	end
end

function wnd_out_career_practice:updateBoxState()
	self._state, self._countdown = g_i3k_game_context:isCanTransformBack(self._careerId)
	local info = g_i3k_game_context:getBiographyCareerInfo()
	if info[self._careerId].boxReward == 0 then
		if self._state ~= g_BIOGIAPHY_STATE_UNFINISH then
			self._layout.vars.icon6:enableWithChildren()
			self._layout.vars.effect:show()
		else
			self._layout.vars.icon6:disableWithChildren()
			self._layout.vars.effect:hide()
		end
		self._layout.vars.rewardBtn:enableWithChildren()
		self._layout.vars.rewardIcon:hide()
	else
		self._layout.vars.rewardBtn:disableWithChildren()
		self._layout.vars.icon6:enableWithChildren()
		self._layout.vars.rewardIcon:show()
		self._layout.vars.effect:hide()
	end
end

function wnd_out_career_practice:updateAnimate()
	local user_cfg = g_i3k_game_context:GetUserCfg()
	local progress = user_cfg:GetBiographyTaskProgress()
	local roleId = g_i3k_game_context:GetRoleId()
	if progress[roleId] and progress[roleId][self._careerId] and progress[roleId][self._careerId] >= self._lastUnlock then
		
	else
		if self._lastUnlock > 0 then
			local pos = self._layout.vars["icon"..self._lastUnlock]:getParent():convertToWorldSpace(self._layout.vars["icon"..self._lastUnlock]:getPosition())
			local parent = self._layout.vars.animate:getParent()
			self._layout.vars.animate:setPosition(parent:convertToNodeSpace(cc.p(pos.x, pos.y)))
			self._layout.anis.c_saoguang1.play()
		end
		user_cfg:SetBiographyTaskProgress(roleId, self._careerId, self._lastUnlock)
	end
end

function wnd_out_career_practice:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18516))
end

function wnd_create(layout)
	local wnd = wnd_out_career_practice.new()
	wnd:create(layout)
	return wnd
end
