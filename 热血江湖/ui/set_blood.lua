-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local LAYER_MESSAGE = "ui/widgets/szjmt"
-------------------------------------------------------
wnd_set_blood = i3k_class("wnd_set_blood", ui.wnd_base)

local TXLEVEl = 3 --美术特效等级暂时为EPP_0,EPP_1,EPP_2 三级，以后可改
--同屏人数屏蔽限制最大最小人数
local MaxPlayerNum = i3k_db_common.filter.maxPlayerNum
local MinPlayerNum = i3k_db_common.filter.minPlayerNum

local BASE_SET_TYPE = 1 --基础设置

function wnd_set_blood:ctor()
	self._is_ok = false
	self._percent = 1
	self._showType = 0 --基础设置，挂机设置，推送设置
end

function wnd_set_blood:configure(...)
	local widgets = self._layout.vars
	local slider = self._layout.vars.slider
	percentWord = self._layout.vars.percentWord
	if slider then
		slider:addEventListener(self.onSlider)
	end

	self._layout.vars.close:onClick(self,self.onCloseUI, function ()
		local bgVol = self.bgVol
		local effVol =  self.effVol
		g_i3k_game_context:GetUserCfg():SetVolume(bgVol,effVol)
	end)

	local isSelect_btn = self._layout.vars.isSelect_btn
	if isSelect_btn then
		isSelect_btn:onTouchEvent(self,self.onSelect)
	end
	local btnHelp = self._layout.vars.btnHelp
	if btnHelp then
		btnHelp:onTouchEvent(self,self.onHelp)
	end

	local btnAnnounce = self._layout.vars.btnAnnounce
	if btnAnnounce then
		btnAnnounce:onTouchEvent(self,self.onAnnounce)
	end

	--音效相关控件
	self.gAudioType_Action	= 1
	self.gAudioType_Effect	= 2
	self.gAudioType_Scene	= 3
	self.gAudioType_BGM		= 4
	self.gAudioType_UI		= 5

	widgets.bg_music_onTouch:onTouchEvent(self,self.bg_music_onTouch)
	widgets.eff_music_onTouch:onTouchEvent(self,self.eff_music_onTouch)
	widgets.bg_music_scrollBar:addEventListener(self.bg_music_scrollBar)--如果监听事件是这个方法则该响应方法中的self是该对象
	widgets.eff_music_scrollBar:addEventListener(self.eff_music_scrollBar)
	self.bgVol = 0
	self.effVol = 0
	self:initMusicStatus()
	self:initTouchOperate()


	--设置可以触摸操作
	widgets.touchOpBtn:onTouchEvent(self,self.onTouchOpBtn)

	widgets.camera_distance:addEventListener(self.onCameraDistance);
	self:initCameraInter()

	-- 基础设置，挂机设置，推送设置
	self._setShowType = {
		{btn = widgets.baseSetting, panel = widgets.baseSetPanel},
		{btn = widgets.autoSetting, panel = widgets.autoSetPanel},
		{btn = widgets.pushServiceBtn, panel = widgets.pushPanel, func = self.initPushServices},
	}
	for i, e in ipairs(self._setShowType) do
		e.btn:onClick(self, self.onChangeType, i)
	end
	self:onChangeType(nil, BASE_SET_TYPE) --默认显示基础设置

	widgets.userCenter:onClick(self,self.onUserCenter)
	-- 头顶信息
	widgets.headInfoBtn:onClick(self,self.onMyselfHeadInfo)
	self:initIsShowMyselfHeadInfo()
	widgets.headInfoBtn2:onClick(self,self.onOthersHeadInfo)
	self:initIsShowOthersHeadInfo()
	--屏蔽特效
	self._effectSet = widgets.effectSet
	widgets.effectSet:addEventListener(self.onSetFilterTXLvl)
	self:initFilterTXLvl()
	-- 自动组队相关设置
	widgets.teamRequestBtn:onClick(self,self.onTeamRequestBtn)
	widgets.teamApplyBtn:onClick(self,self.onTeamApplyBtn)
	self:initTeamMatchInfo()

	widgets.break_death:onClick(self, self.onBreakBtn) --脱离卡死按钮
	widgets.switchChar:onClick(self, self.onSwitCharBtn) --角色切换按钮
	widgets.switchRole:onClick(self, self.onSwitRoleBtn)
	widgets.resetBtn:onClick(self, self.onResetBtn) -- 恢复默认

	--随从补血
	widgets.petRegBtn:onClick(self, self.onPetRegBtn)
	widgets.petRegDescBtn:onClick(self, self.onPetRegDescBtn)
	--屏蔽镖车
	widgets.carBtn:onClick(self, self.onCarBtn)
	widgets.carImg:setVisible(g_i3k_game_context:GetUserCfg():GetIsHideCar())
	self:initUsePetPool()

	--同屏人数
	-- filterNum = widgets.filterNum
	self._playerNum = widgets.playerNum
	widgets.playerNum:addEventListener(self.onSetPlayerNum)
	self:initFilterPlayerNum()

	-- 自动变身设置
	self.autoSuperBtn = widgets.autoSuperBtn
	self.autoSuperImg = widgets.autoSuperImg
	self.autoSuperDesc = widgets.autoSuperDesc
	widgets.autoSuperBtn:onClick(self, self.onAutoSuperBtn)
	widgets.redEnvelopeBtn:onClick(self, self.onBlockRedEnvelopeBtn)
	self:initIsShowRedEnvelope()
	self:initAutoSuperMode()
	self:initFPSLimit()
	widgets.fpsControl:addEventListener(self.onFPSLimitBar);
	--托管范围
	self:initAutoFightRadius()
	widgets.radiusHelp:onClick(self, self.onAutoFightRadiusHelp)
	widgets.fightRadius:addEventListener(self.onAutoFightRadiusBar);
	widgets.superOnHookBtn:onClick(self, self.onSuperOnHook)
	self:initSuperOnHook()

	widgets.openUrlBtn:onClick(self, self.onOpenUrl)
	widgets.powerSaveBtn:onClick(self, self.onPowerSaveBtn)
	widgets.powerSaveHelp:onClick(self, self.onPowerSaveHelp)
	widgets.autoPowerSave:onClick(self, self.onAutoPowerSaveBtn)
	widgets.autoPowerHelp:onClick(self, self.onAutoPowerSaveHelp)
	self:initPowerSaveBtnState()

	widgets.autoSaleEquipBtn:onClick(self, self.onAutoSaleEquipBtn)
	widgets.autoSaleDrugBtn:onClick(self, self.onAutoSaleDrugBtn)
	self:initAutoSaleEquip()
	self:initAutoSaleDrug()
	widgets.autoSaleDrugLabel:setText(i3k_get_string(17142))
	widgets.cameraShakeBtn:onClick(self, self.OnCameraShakeChange)
	self:initCameraShake()

end

function wnd_set_blood:refresh(isShowBgMusicOn,isShowEffMusicOn)
	self:setBgMusicOn(isShowBgMusicOn)
	self:setEffMusicOn(isShowEffMusicOn)
end

function wnd_set_blood:onShow()
	self._layout.vars.btnHelp:disableWithChildren()
	local percentWord = self._layout.vars.percentWord
	local slider = self._layout.vars.slider
	local btn_icon1 = self._layout.vars.btn_icon
	local btn_icon2 = self._layout.vars.btn_icon2
	local cfg = g_i3k_game_context:GetUserCfg();
	local userCenter = self._layout.vars.userCenter
	if g_i3k_game_handler.ShowUserCenter then
	 	userCenter:setVisible(true)
	else
		userCenter:setVisible(false)
	end
	if percentWord and cfg then
		local isSelect,mark = cfg:GetAutoTakeBloodData()
		self._percent = mark
		local desc = string.format("当血量低于%s%%时自动吃药",mark)
		percentWord:setText(desc)
		slider:setPercent(mark)
		if isSelect == 1 then
			--btn_icon1:hide()
			btn_icon2:show()
			self._is_ok = true
		else
			btn_icon1:show()
			btn_icon2:hide()
			self._is_ok = false
		end
	end

	DCEvent.onEvent("设置按钮")
end

function wnd_set_blood:onHide()

end

-- 初始化
function wnd_set_blood:initUsePetPool()
	local cfg = g_i3k_game_context:GetUserCfg()
	local checkImg = self._layout.vars.petRegImg
	checkImg:setVisible(cfg:getIsPetCanUsePool())
end

function wnd_set_blood:onUserCenter(sender)
	g_i3k_game_handler:ShowUserCenter()
end

function wnd_set_blood:initTouchOperate()
	local cfg = g_i3k_game_context:GetUserCfg()
	local checkImg = self._layout.vars.touchOpImg
	checkImg:setVisible(cfg:GetIsTouchOperate())
end


function wnd_set_blood:initIsShowMyselfHeadInfo()
	local cfg = g_i3k_game_context:GetUserCfg()
	local checkImg = self._layout.vars.headInfoImage
	checkImg:setVisible(not(cfg:GetIsShowMyselfHeadInfo()))
end

function wnd_set_blood:initIsShowOthersHeadInfo()
	local cfg = g_i3k_game_context:GetUserCfg()
	local checkImg = self._layout.vars.headInfoImage2
	checkImg:setVisible(not(cfg:GetIsShowOthersHeadInfo()))
end

function wnd_set_blood:initIsShowRedEnvelope()
	local cfg = g_i3k_game_context:GetUserCfg()
	local checkImg = self._layout.vars.redEnvelopeImg
	checkImg:setVisible((cfg:GetRedEnvelope()))
end

function wnd_set_blood:initFilterTXLvl()
	local cfg = g_i3k_game_context:GetUserCfg()
	local LvlTX = cfg:GetFilterTXLvl()
	local percent = 0
	if LvlTX == EPP_1 then
		percent = 50
	elseif LvlTX == EPP_2 then
		percent = 100
	end
	self._effectSet:setPercent(percent)
	g_i3k_game_context:SetEffectFilter(LvlTX)
end

function wnd_set_blood:initTeamMatchInfo()
	local cfg = g_i3k_game_context:GetUserCfg()
	local checkImg = self._layout.vars.teamRequestImg
	checkImg:setVisible(cfg:GetMatchTeamRequestStatus())
	local checkImg = self._layout.vars.teamApplyImg
	checkImg:setVisible(cfg:GetMatchTeamApplyStatus())
end

function wnd_set_blood:initCameraInter()
	local percent = i3k_get_load_cfg():GetCameraInter() * 100
	self._layout.vars.camera_distance:setPercent(percent);
	g_i3k_game_context:setCameraDistance(percent / 100);
end

function wnd_set_blood:initPushServices()
	local scroll = self._layout.vars.pushScroll
	scroll:removeAllChildren()
	local cfg = g_i3k_game_context:GetUserCfg()
	local banServices = cfg:GetBanPushServices()
	local count = #i3k_db_push_service -- - #banServices
	local children = scroll:addItemAndChild(LAYER_MESSAGE, 1, count)
	for i,v in ipairs(children) do
		local name = i3k_db_push_service[i].name
		local daysTable = g_i3k_game_context:getDayTableByInt32(i3k_db_push_service[i].days)
		local dayStr = g_i3k_game_context:getDayString(daysTable)
		local time = i3k_db_push_service[i].times
		local timeStr1 = time[1].h..":"..(time[1].m == 0 and "00:00" or time[1].m..":00")
		local timeStr2 = time[2].h..":"..(time[2].m == 0 and "00:00" or time[2].m..":00")
		v.vars.name:setText(name)
		v.vars.days:setText(dayStr)
		v.vars.time:setText(timeStr1.."~"..timeStr2)
		v.vars.onBtn:onClick(self, self.onPushServiceBtn)
		if g_i3k_game_context:vectorContain(banServices, i) then
			v.vars.onBtn:stateToNormal()
		else
			v.vars.onBtn:stateToPressed()
		end
		v.vars.onBtn:setTag(i)
	end
end

-- 恢复默认，推送消息全部开启
function wnd_set_blood:clearPushServices()
	local cfg = g_i3k_game_context:GetUserCfg()
	local banServices = cfg:GetBanPushServices()
	cfg:SetBanPushServices(nil)
	g_i3k_game_context:getInitNeedBanServices() -- 初始化下cfg中类型冲突的问题
	self:initPushServices()
end

function wnd_set_blood:initAutoBlood()
	local cfg = g_i3k_game_context:GetUserCfg()
	local isSelect,mark = cfg:GetAutoTakeBloodData()
	self._layout.vars.slider:setPercent(mark)
	local desc = string.format("当血量低于%s%%时自动吃药",mark)
	local btn_icon1 = self._layout.vars.btn_icon
	local btn_icon2 = self._layout.vars.btn_icon2
	percentWord:setText(desc)
	if isSelect == 1 then
		--btn_icon1:hide()
		btn_icon2:show()
		self._is_ok = true
	else
		btn_icon1:show()
		btn_icon2:hide()
		self._is_ok = false
	end
end

-- 初始化fps设置
function wnd_set_blood:initFPSLimit()
	local cfg = g_i3k_game_context:GetUserCfg()
	local setValue = cfg:GetFPSLimit()
	g_i3k_game_context:setFPSLimitValue(setValue)
	local mark = self:getFPSLimitPercentByID(setValue)
	-- g_i3k_ui_mgr:PopupTipMessage(setValue.." "..mark)
	self._layout.vars.fpsControl:setPercent(mark)
end

function wnd_set_blood:getFPSLimitPercentByID(value)
	if value < 0 then
		return 100
	end
	local count = 0
	local size = #FPS_LIMIT - 1
	for i, v in ipairs(FPS_LIMIT) do
		if value ~= i then
			count = count + 1
		else
			break
		end
	end
	return count / size * 100
end

--音效相关部分
function wnd_set_blood:initMusicStatus()
	local cfg = g_i3k_game_context:GetUserCfg()
	self.bgVol, self.effVol = cfg:GetVolume()
	local widgets = self._layout.vars
	widgets.bg_music_scrollBar:setPercent(self.bgVol )
	widgets.eff_music_scrollBar:setPercent(self.effVol)

	i3k_set_game_music(self.bgVol, self.effVol)

	local effectMusicOn = self._layout.vars.effect_music_on
	local bgMusicOn = self._layout.vars.bg_music_on
	effectMusicOn:setVisible(self.effVol ~= 0)
	bgMusicOn:setVisible(self.bgVol ~= 0)
end

function wnd_set_blood:bg_music_onTouch(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local bgMusicOn = self._layout.vars.bg_music_on
		if bgMusicOn:isVisible() == false then
			bgMusicOn:setVisible(true)
			if self.bgVol ~= 0 then
				g_i3k_mmengine:SetVolume(self.gAudioType_BGM, (self.bgVol / 100) * gAudio_BGMFalloff);
				local slider = self._layout.vars.bg_music_scrollBar
				slider:setPercent(self.bgVol)
			else
				self.bgVol = 20
				g_i3k_mmengine:SetVolume(self.gAudioType_BGM, (self.bgVol / 100) * gAudio_BGMFalloff);
				local slider = self._layout.vars.bg_music_scrollBar
				slider:setPercent(self.bgVol)
			end
		else
			bgMusicOn:setVisible(false)
			g_i3k_mmengine:SetVolume(self.gAudioType_BGM, 0)
			local slider = self._layout.vars.bg_music_scrollBar
			slider:setPercent(0)
			self.bgVol = 0
		end
		self:saveMusicToUserCfg()
	end
end

function wnd_set_blood:eff_music_onTouch(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local effectMusicOn = self._layout.vars.effect_music_on
		if effectMusicOn:isVisible() == false then
			effectMusicOn:setVisible(true)
			if self.effVol ~= 0 then
				g_i3k_mmengine:SetVolume(self.gAudioType_Action, (self.effVol / 100) * gAudio_ActionFalloff);
				g_i3k_mmengine:SetVolume(self.gAudioType_Effect, (self.effVol / 100) * gAudio_EffectFalloff);
				g_i3k_mmengine:SetVolume(self.gAudioType_UI, (self.effVol / 100) * gAudio_UIFalloff);

				local slider = self._layout.vars.eff_music_scrollBar
				slider:setPercent(self.effVol)
			else
				self.effVol = 20;

				g_i3k_mmengine:SetVolume(self.gAudioType_Action, (self.effVol / 100) * gAudio_ActionFalloff);
				g_i3k_mmengine:SetVolume(self.gAudioType_Effect, (self.effVol / 100) * gAudio_EffectFalloff);
				g_i3k_mmengine:SetVolume(self.gAudioType_UI, (self.effVol / 100) * gAudio_UIFalloff);

				local slider = self._layout.vars.eff_music_scrollBar
				slider:setPercent(self.effVol)
			end
		else
			effectMusicOn:setVisible(false)
			g_i3k_mmengine:SetVolume(self.gAudioType_Action, 0)
			g_i3k_mmengine:SetVolume(self.gAudioType_Effect, 0)
			g_i3k_mmengine:SetVolume(self.gAudioType_UI, 0)
			local slider = self._layout.vars.eff_music_scrollBar
			slider:setPercent(0)
			self.effVol = 0
		end
		self:saveMusicToUserCfg()
	end
end

function wnd_set_blood:eff_music_scrollBar()
	local percent = self:getPercent()
	if percent then -- 一定会出现nil的情况
		g_i3k_game_context:setBloodEffMusicOn(percent)
	end
end

function wnd_set_blood:bg_music_scrollBar()
	local percent = self:getPercent()
	if percent then
		g_i3k_game_context:setBloodBgMusicOn(percent)
	end
end

function wnd_set_blood:setEffMusicOn(percent)
	if percent == nil then
		return
	end

	g_i3k_mmengine:SetVolume(self.gAudioType_Action, (self.effVol / 100) * gAudio_ActionFalloff);
	g_i3k_mmengine:SetVolume(self.gAudioType_Effect, (self.effVol / 100) * gAudio_EffectFalloff);
	g_i3k_mmengine:SetVolume(self.gAudioType_UI, (self.effVol / 100) * gAudio_UIFalloff);

	local effectMusicOn = self._layout.vars.effect_music_on
	self.effVol = percent
	self:saveMusicToUserCfg()
	if percent ~= 0 then
		effectMusicOn:setVisible(true)
	else
		effectMusicOn:setVisible(false)
	end
end
function wnd_set_blood:setBgMusicOn(percent)
	if percent == nil then
		return
	end
	g_i3k_mmengine:SetVolume(gAudioType_BGM, (percent / 100) * gAudio_BGMFalloff);

	local bgMusicOn = self._layout.vars.bg_music_on
	self.bgVol = percent
	self:saveMusicToUserCfg()
	if percent ~= 0 then
		bgMusicOn:setVisible(true)
	else
		bgMusicOn:setVisible(false)
	end
end


function wnd_set_blood:saveMusicToUserCfg()
	local bgVol = self.bgVol
	local effVol =  self.effVol
	g_i3k_game_context:GetUserCfg():SetVolume(bgVol,effVol)
end
---------------------------------

function wnd_set_blood:onSlider()
	local percent = self:getPercent()
	--local percentWord = self._layout.vars.percentWord
	local per = 1
	--local percent = slider:getPercent()
	if percent%10 <5 then --四舍五入
		local xx = math.floor(percent/10)
		self:setPercent(xx*10)
		per = xx*10
	else
		self:setPercent(math.ceil(percent/10)*10)
		per = math.ceil(percent/10)*10
	end
	if per == 0 then
		per = 1
	end
	local desc = string.format("当血量低于%s%%时自动吃药",per)
	percentWord:setText(desc)
	self._percent = per
	--i3k_log("self._percent="..self._percent)
	per =self._percent
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		local isSelect,mark = cfg:GetAutoTakeBloodData()
		if isSelect == 1 then
			cfg:SetAutoTakeBloodData(1,self._percent)
		else
			cfg:SetAutoTakeBloodData(0,self._percent)
		end
	end
end

-- 触摸操作
function wnd_set_blood:onTouchOpBtn(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local checkImg = self._layout.vars.touchOpImg
		local cfg = g_i3k_game_context:GetUserCfg()
		if checkImg:isVisible() then
			checkImg:setVisible(false)
			g_i3k_game_handler:EnableObjHitTest(true, false)
			cfg:SetIsTouchOperate(false)
		else
			checkImg:setVisible(true)
			g_i3k_game_handler:EnableObjHitTest(true, true)
			cfg:SetIsTouchOperate(true)
		end
	end
end

function wnd_set_blood:onCameraDistance()
	local percent = self:getPercent();
	if percent then

		g_i3k_game_context:setCameraDistance(percent / 100);
	end
end

function wnd_set_blood:onFPSLimitBar()
	local percent = self:getPercent()
	local p = 1 / (#FPS_LIMIT - 1) * 100
	percent = percent == 0 and percent or math.ceil(percent / p) * p
	self:setPercent(percent)
	local num = math.ceil(percent / p) + 1
	local value = g_i3k_game_context:getFPSLimitValue()
	if num ~= value then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "refresFPSLimitBar", num)
	end
end

function wnd_set_blood:refresFPSLimitBar(num)
	g_i3k_game_context:setFPSLimitValue(num)
	-- TODO set fps limit and write user_cfg
	if FPS_LIMIT[num] then
		i3k_fps_limit(FPS_LIMIT[num])
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetFPSLimit(num)
end

-- 挂机范围相关
function wnd_set_blood:onAutoFightRadiusHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1821))
end

function wnd_set_blood:initAutoFightRadius()
	local cfg = g_i3k_game_context:GetUserCfg()
	local value = cfg:GetAutoFightRadius()
	g_i3k_game_context:setAutoFightRadius(value)
	local mark = self:getAutoFightRadiusByID(value)
	self._layout.vars.fightRadius:setPercent(mark)
end

function wnd_set_blood:getAutoFightRadiusByID(value)
	local count = 0
	local autoFightRadius = i3k_db_common.autoFight.autoFightRadius;
	local size = #autoFightRadius - 1
	for i, _ in ipairs(autoFightRadius) do
		if value ~= i then
			count = count + 1
		else
			break
		end
	end
	return count / size * 100
end

function wnd_set_blood:onAutoFightRadiusBar()
	local autoFightRadius = #i3k_db_common.autoFight.autoFightRadius;
	local percent = self:getPercent()
	local num = 0;
	if percent < 1 / autoFightRadius * 100 then
		percent = 0
		num = 1;
	elseif percent >= 1 / autoFightRadius * 100 and percent < 2 / autoFightRadius * 100 then
		percent = 50
		num = 2;
	elseif percent >= 2 / autoFightRadius * 100 and percent <= 100 then
		percent = 100
		num = 3;
	end
	self:setPercent(percent)
	local value = g_i3k_game_context:getAutoFightRadius()
	if num ~= value then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "AutoFightRadiusBar", num)
	end
end

function wnd_set_blood:AutoFightRadiusBar(num)
	g_i3k_game_context:setAutoFightRadius(num)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetAutoFightRadius(num)
end

function wnd_set_blood:onSuperOnHook(sender)
	local mapType = i3k_game_get_map_type()
	if mapType == g_FIELD and not g_i3k_game_context:GetIsSpringWorld() then
		if g_i3k_game_context:getRoleSpecialCardsEndTime(MONTH_CARD) < i3k_game_get_time() then
			local needActivity = i3k_db_common.autoFight.superOnHookNeedActivity
			if g_i3k_game_context:GetScheduleActivity() < needActivity then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1828, needActivity))
				return
			end
		end
		local valid = g_i3k_game_context:GetSuperOnHookValid()
		local setValid = not valid
		g_i3k_game_context:SetSuperOnHookValid(setValid)
		g_i3k_game_context:SetAutoFight(setValid)
		local hero = i3k_game_get_player_hero()
		if setValid then
			g_i3k_game_context:SetSuperOnHookPos(hero:GetCurPos())
			g_i3k_logic:OpenBattleUI()
		else
			self:initSuperOnHook()
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(setValid and 1823 or 1824))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1822))
	end
end
function wnd_set_blood:initSuperOnHook()
	local valid = g_i3k_game_context:GetSuperOnHookValid()
	self._layout.vars.superOnHookLabel:setText(i3k_get_string(valid and 1826 or 1825))
end

function wnd_set_blood:onSelect(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local slider = self._layout.vars.slider
		self._percent = slider:getPercent()
		local btn_icon1 = self._layout.vars.btn_icon
		local btn_icon2 = self._layout.vars.btn_icon2
		if self._is_ok then
			self._is_ok = false
			local cfg = g_i3k_game_context:GetUserCfg()
			if cfg then
				cfg:SetAutoTakeBloodData(0,self._percent)
			end
			btn_icon1:show()
			btn_icon2:hide()
		else
			self._is_ok = true
			i3k_log("..................self._percent="..self._percent)
			local cfg = g_i3k_game_context:GetUserCfg()
			if cfg then
				cfg:SetAutoTakeBloodData(1,self._percent)
			end
			--btn_icon1:hide()
			btn_icon2:show()
		end
	end
end

function wnd_set_blood:onChangeType(sender, showType)
	if self._showType ~= showType then
		self._showType = showType
		for i, e in ipairs(self._setShowType) do
			local press = showType == i
			e.panel:setVisible(press)
			e.btn[press and "stateToPressed" or "stateToNormal"](e.btn, true)
			if press and e.func then
				e.func(self)
end
end
	end
end



--设置头顶信息
function wnd_set_blood:onHeadIconInfo(sender)
	local widgets = self._layout.vars
	if widgets.headInfoImage:isVisible() then
		widgets.headInfoImage:hide()
		--TODO
		g_i3k_game_context:SetEntitySectVisible(false)
	else
		widgets.headInfoImage:show()
		--TODO
		g_i3k_game_context:SetEntitySectVisible(true)
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		cfg:SetIsShowHeadInfo(widgets.headInfoImage:isVisible())
	end
end

--设置称号显隐
function wnd_set_blood:onMyselfHeadInfo(sender)
	local widgets = self._layout.vars
	if widgets.headInfoImage:isVisible() then
		widgets.headInfoImage:hide()
		--TODO
		g_i3k_game_context:SetMyselfTitleVisible(true)
	else
		widgets.headInfoImage:show()
		--TODO
		g_i3k_game_context:SetMyselfTitleVisible(false)
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		cfg:SetIsShowMyselfHeadInfo(not (widgets.headInfoImage:isVisible()))
	end
end

function wnd_set_blood:onOthersHeadInfo(sender)
	local widgets = self._layout.vars
	if widgets.headInfoImage2:isVisible() then
		widgets.headInfoImage2:hide()
		--TODO
		g_i3k_game_context:SetOtherOnesTitleVisible(true)
	else
		widgets.headInfoImage2:show()
		--TODO
		g_i3k_game_context:SetOtherOnesTitleVisible(false)
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		cfg:SetIsShowOthersHeadInfo(not (widgets.headInfoImage2:isVisible()))
	end
end

function wnd_set_blood:onBlockRedEnvelopeBtn(sender)
	local widgets = self._layout.vars
	local cfg = g_i3k_game_context:GetUserCfg()
	if widgets.redEnvelopeImg:isVisible() then
		cfg:SetRedEnvelope(false)
		widgets.redEnvelopeImg:hide()
	else
		widgets.redEnvelopeImg:show()
		cfg:SetRedEnvelope(true)
	end
end


-- 设置特效显示等级
function wnd_set_blood:onSetFilterTXLvl()
	local percent = self:getPercent()
	local lvl = 0
	local setPercent = 0
	if percent < 1 / TXLEVEl * 100 then
		setPercent = 0
		lvl = EPP_0
	elseif percent >= 1 / TXLEVEl * 100 and percent < 2 / TXLEVEl * 100 then
		setPercent = 50
		lvl = EPP_1
	elseif percent >= 2 / TXLEVEl * 100 and percent <= 100 then
		setPercent = 100
		lvl = EPP_2
	end
	self:setPercent(setPercent)
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		cfg:SetFilterTXLvl(lvl)
	end
	g_i3k_game_context:SetEffectFilter(lvl)
end

-- 自动组队相关
function wnd_set_blood:onTeamRequestBtn()
	local widgets = self._layout.vars
	if widgets.teamRequestImg:isVisible() then
		widgets.teamRequestImg:hide()
	else
		widgets.teamRequestImg:show()
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		cfg:SetMatchTeamRequestStatus(widgets.teamRequestImg:isVisible())
	end
end

function wnd_set_blood:onTeamApplyBtn()
	local widgets = self._layout.vars
	if widgets.teamApplyImg:isVisible() then
		widgets.teamApplyImg:hide()
	else
		widgets.teamApplyImg:show()
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		cfg:SetMatchTeamApplyStatus(widgets.teamApplyImg:isVisible())
	end
end

function wnd_set_blood:onBreakBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end

	local needTime = (g_i3k_game_context:GetLeaveWrongPosTime() - i3k_game_get_time())
	if i3k_game_get_time() >  g_i3k_game_context:GetLeaveWrongPosTime() then
		local hero = i3k_game_get_player_hero()
		hero:ClearFindwayStatus()
		local data = i3k_sbean.wrongpos_leave_req.new()
		i3k_game_send_str_cmd(data, "wrongpos_leave_res")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(305, math.modf(needTime)))
	end
end

function wnd_set_blood:onSwitCharBtn(sender)
	g_i3k_game_context:clearItemCheckList()
	g_i3k_game_context:EscortCarMoveSync()
	g_i3k_game_context:stopRoleNameInvalidRemind()
	i3k_sbean.role_logout()
end

function wnd_set_blood:onSwitRoleBtn(sender)
	g_i3k_game_context:clearItemCheckList()
	g_i3k_game_handler:ReturnInitView(true)
end

function wnd_set_blood:onHelp(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if i3k_game_is_dev_mode() then
			g_i3k_ui_mgr:OpenUI(eUIID_GodEye);
		end
	end
end

function wnd_set_blood:onAnnounce(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenUI(eUIID_OtherTest);
	end
end

function wnd_set_blood:onOpenUrl(sender)
	i3k_open_url("https://sojump.com/jq/9852229.aspx")
end

-- 恢复默认
function wnd_set_blood:onResetBtn(sender)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:resetUserCfg()
	self:initTouchOperate()
--	self:initIsShowHeadInfo()
	self:initIsShowMyselfHeadInfo()
	self:initIsShowOthersHeadInfo()
	self:initIsShowRedEnvelope()
	self:initFilterTXLvl()
	self:initTeamMatchInfo()
	self:initMusicStatus()
	self:initCameraInter()
	self:initAutoBlood()
	self:clearPushServices()
	self:initFilterPlayerNum()
	self:initAutoSuperMode()
	self:initAutoSaleEquip()
	self:initAutoSaleDrug()
	self:initAutoFightRadius()
end

function wnd_set_blood:onPetRegBtn(sender)
	local cfg = g_i3k_game_context:GetUserCfg()
	local canUse =(not cfg:getIsPetCanUsePool()) == true and 1 or 0
	i3k_sbean.syncPetCanUsePool(canUse)
	g_i3k_game_context:setUsercfgUsePetPool(not cfg:getIsPetCanUsePool())
end

function wnd_set_blood:setPetRegImgStatus(isVisible)
	self._layout.vars.petRegImg:setVisible(isVisible)
end

function wnd_set_blood:onPetRegDescBtn(sender)
	local msg = i3k_get_string(615)
	g_i3k_ui_mgr:ShowMessageBox1(msg)
end

function wnd_set_blood:onCarBtn(sender)
	local img = self._layout.vars.carImg
	local isShow = img:isVisible()
	img:setVisible(not isShow)
	g_i3k_game_context:SetEscortIsHide(not isShow)
end

function wnd_set_blood:onPushServiceBtn(sender)
	local tag = sender:getTag()
	local scroll = self._layout.vars.pushScroll
	local item = scroll:getChildAtIndex(tag)
	local isPressed = item.vars.onBtn:isStatePressed()
	if isPressed then
		item.vars.onBtn:stateToNormal()
		self:addBanPushService(tag)
	else
		item.vars.onBtn:stateToPressed()
		self:removeBanPushService(tag)
	end
end

function wnd_set_blood:addBanPushService(id)
	local cfg = g_i3k_game_context:GetUserCfg()
	local banServices = cfg:GetBanPushServices()
	if not g_i3k_game_context:vectorContain(banServices, id) then
		table.insert(banServices, id)
	end
	cfg:SetBanPushServices(banServices)
	self:initPushServices()
	local data = g_i3k_game_context:getPushServiceData()
    g_i3k_game_handler:SetPushServiceData(data)
end

function wnd_set_blood:removeBanPushService(id)
	local cfg = g_i3k_game_context:GetUserCfg()
	local banServices = cfg:GetBanPushServices()
	for i,v in ipairs(banServices) do
		if v == id then
			table.remove(banServices, i)
		end
	end
	banServices = g_i3k_game_context:getCheckPushServices(banServices, id)
	cfg:SetBanPushServices(banServices)
	self:initPushServices()
	local data = g_i3k_game_context:getPushServiceData()
    g_i3k_game_handler:SetPushServiceData(data)
end

function wnd_set_blood:setFilterNumText(num)
	self._layout.vars.filterNum:setText(num)
end

function wnd_set_blood:initFilterPlayerNum()
	local cfg = g_i3k_game_context:GetUserCfg()
	local playerNum = cfg:GetFilterPlayerNum()
	local percent = (playerNum - MinPlayerNum + 1) / (MaxPlayerNum - MinPlayerNum  + 1)* 100
	self._playerNum:setPercent(percent)
	-- filterNum:setText(playerNum)
	self._layout.vars.filterNum:setText(playerNum)
end

function wnd_set_blood:onSetPlayerNum()
	local percent = self:getPercent()
	local p = 1 / (MaxPlayerNum - MinPlayerNum + 1) * 100
	percent = percent == 0 and p or math.ceil(percent / p) * p
	self:setPercent(percent)
	local cfg = g_i3k_game_context:GetUserCfg()
	local num = math.ceil(percent / p) - 1
	if num == 0 then
		num = MinPlayerNum
	elseif num >= MaxPlayerNum - MinPlayerNum + 1 then
		num = MaxPlayerNum
	else
		num = MinPlayerNum + num
	end
	if cfg then
		cfg:SetFilterPlayerNum(num)
	end
	-- filterNum:setText(num)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetBlood, "setFilterNumText", num)
end

function wnd_set_blood:initAutoSuperMode()
	local autoSuperLvl = g_i3k_db.i3k_db_get_auto_super_vip_lvl()
	local cfg = g_i3k_game_context:GetUserCfg()
	self.autoSuperImg:setVisible(cfg:GetIsAutoSuperMode())
	self.autoSuperDesc:setText(i3k_get_string(904, autoSuperLvl))
	local vipLvl = g_i3k_game_context:GetVipLevel()
	if vipLvl < autoSuperLvl then
		self.autoSuperBtn:disableWithChildren()
		self.autoSuperImg:disableWithChildren()
	end
end

function wnd_set_blood:onAutoSuperBtn(sender)
	if self.autoSuperImg:isVisible() then
		self.autoSuperImg:hide()
	else
		self.autoSuperImg:show()
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg then
		cfg:SetIsAutoSuperMode(self.autoSuperImg:isVisible())
	end
end

-----------------------------------------------------
-- 自动售卖绿色蓝色品质装备
function wnd_set_blood:initAutoSaleEquip()
	local img = self._layout.vars.autoSaleEquipImg
	local cfg = g_i3k_game_context:GetUserCfg()
	img:setVisible(cfg:GetAutoSaleEquip())
end

function wnd_set_blood:onAutoSaleEquipBtn(sender)
	local img = self._layout.vars.autoSaleEquipImg
	local cfg = g_i3k_game_context:GetUserCfg()
	img:setVisible(not img:isVisible())
	cfg:SetAutoSaleEquip(img:isVisible())
	i3k_sbean.syncAutoSaleEquip(img:isVisible())
end

-- 自动售卖蓝绿品质药品
function wnd_set_blood:initAutoSaleDrug()
	local img = self._layout.vars.autoSaleDrugImg
	local cfg = g_i3k_game_context:GetUserCfg()
	img:setVisible(cfg:GetAutoSaleDrug())
end

function wnd_set_blood:onAutoSaleDrugBtn(sender)
	local img = self._layout.vars.autoSaleDrugImg
	local cfg = g_i3k_game_context:GetUserCfg()
	img:setVisible(not img:isVisible())
	cfg:SetAutoSaleDrug(img:isVisible())
	i3k_sbean.syncAutoSaleDrug(img:isVisible())
end

----------------省电模式---------------------------
-- 初始化显示省电模式当前状态
function wnd_set_blood:initPowerSaveBtnState()
	local widgets = self._layout.vars
	local powerSaveImg = widgets.powerSaveImg
	local autoPowerSaveImg = widgets.autoPowerSaveImg
	local cfg = g_i3k_game_context:GetUserCfg()
	local isOnPowerSave = #cfg:GetPowerSave() > 0
	local isOnAutoPowerSave = cfg:GetAutoPowerSave()
	powerSaveImg:setVisible(isOnPowerSave)
	autoPowerSaveImg:setVisible(isOnAutoPowerSave)
end
-- 省电模式开关
function wnd_set_blood:onPowerSaveBtn(sender)
	local widgets = self._layout.vars
	local powerSaveImg = widgets.powerSaveImg
	local cfg = g_i3k_game_context:GetUserCfg()
	local isOnPowerSave = #cfg:GetPowerSave() > 0
	powerSaveImg:setVisible(not isOnPowerSave)
	g_i3k_download_mgr:setPowerSaveMode(not isOnPowerSave)
end
-- 省电模式帮助
function wnd_set_blood:onPowerSaveHelp(sender)
	g_i3k_ui_mgr:ShowMessageBox1("开启省电模式会使萤幕变暗，帧率下调，点击萤幕可立即退出省电模式")
end
-- 自动开启省电模式按钮
function wnd_set_blood:onAutoPowerSaveBtn(sender)
	local widgets = self._layout.vars
	local autoPowerSaveImg = widgets.autoPowerSaveImg
	local cfg = g_i3k_game_context:GetUserCfg()
	local isOnAutoPowerSave = cfg:GetAutoPowerSave()
	autoPowerSaveImg:setVisible(not isOnAutoPowerSave)
	cfg:SetAutoPowerSave(not isOnAutoPowerSave)
end
-- 自动开启省电模式帮助
function wnd_set_blood:onAutoPowerSaveHelp(sender)
	g_i3k_ui_mgr:ShowMessageBox1("开启自动省电模式，无操作10分钟后会自动进入省电模式")
end

-- 其余的代码在i3k_download_mgr中写。因为此处要调用的是一个全局的方法。
-- 并且还有一个timer，如果有时间的话可以单出抽象出来一个类。

---------------省电模式end-----------------------

function wnd_set_blood:initCameraShake()
	local widgets = self._layout.vars
	local cfg = g_i3k_game_context:GetUserCfg()
	local shake = cfg:GetCameraShake()
	widgets.cameraShakeImg:setVisible(not shake)
end
function wnd_set_blood:OnCameraShakeChange(sender)
	local widgets = self._layout.vars
	local cfg = g_i3k_game_context:GetUserCfg()
	local shake = cfg:GetCameraShake()
	cfg:SetCameraShake(not shake)
	g_i3k_game_context:SetCameraShake(not shake)
	self:initCameraShake()
end
function wnd_set_blood:onUpdateAnnouncement(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_UpdateAnnouncement)
	g_i3k_ui_mgr:RefreshUI(eUIID_UpdateAnnouncement)
end
function wnd_create(layout,...)
	local wnd = wnd_set_blood.new()
	wnd:create(layout,...)
	return wnd
end
