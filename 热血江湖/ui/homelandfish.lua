-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_homeLandFish = i3k_class("wnd_homeLandFish", ui.wnd_base)

local PERCENT_CONST = 75 -- 设置钓鱼弧度初始百分比，timeer 左侧从75%开始
local MAX_ROTATION	= 90 -- 箭头最大旋转角度 避免最右侧箭头部分看不到
local MIN_ROTATION	= 0 -- 箭头最小旋转角度
local TOTAL_ROTATION = 90 -- 总弧度
local AutoTime = 0 --自动钓鱼等待时间

local FISH_ICON = {[g_THROW_STATE] = 6746, [g_PACK_UP_STATE] = 6747} -- 钓鱼两种ICON
local STEP_ANGLE = i3k_db_home_land_base.fishCfg.stepLong

local QJ_WIDGETS = "ui/widgets/dj1"

function wnd_homeLandFish:ctor()
	self._isAutoFish = false --是否自动钓鱼
	self._startFishState = false -- 开始钓鱼状态
	self._fishTimeSpace = 0 --间隔
	self._shortcutState = 0
	self._isTouch = true -- 是否可以点击
end

function wnd_homeLandFish:configure()
	local widgets = self._layout.vars
	self.wearEquipWidget = {}
	self:initFishEquipWidget(widgets)
	self.tag_root		= widgets.tag_root
	self.target			= widgets.target
	self.tag_desc		= widgets.tag_desc

	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.helpBtn:onClick(self, self.onHelp)

	self.autoFishBtn	= widgets.autoFishBtn
	self.fishBtn 		= widgets.fishBtn
	self.range			= widgets.range	
	self.jiantouview	= widgets.jiantouview

	self.arrow			= widgets.arrow -- 箭头
	self.timersWidgets = {} -- 钓鱼进度条
	for i = 1, 5 do
		self.timersWidgets[i] = widgets["timer"..i]
	end

	self.autoFishBtn:onClick(self, self.onAutoBtn)
	--self.autoFishBtn:hide() --先屏蔽自动钓鱼
	self.fishBtn:onClick(self, self.onFishBtn)

	self.isadd = true
	self:randomFishSlider()

	--快捷更换鱼竿鱼饵
	self.shortcutRoot	= widgets.shortcutRoot
	self.shortcutScroll = widgets.shortcutScroll
	widgets.globalBtn:onClick(self, function()
		self.shortcutRoot:setVisible(false)
		self:resetShortcutState()
	end)
	
end

function wnd_homeLandFish:initFishEquipWidget(widgets)
	for i=1, 2 do
		self.wearEquipWidget[i] = {
			equip_btn	= widgets["equip"..i],
			equip_icon	= widgets["equip_icon"..i],
			grade_icon	= widgets["grade_icon"..i],
			count 		= widgets["count"..i],
			name 		= widgets["name"..i],
		}
		self.wearEquipWidget[i].equip_btn:onClick(self, self.onChangeFishEquip, i) -- i 家园装备类型 武器，鱼饵
	end
end

-- 每次重新钓鱼重新随机
function wnd_homeLandFish:randomFishSlider()
	local barstyles = i3k_db_home_land_base.fishCfg.barstyles
	self.info = {counts = {}, poss ={}}
	local randCnt = math.random(1, #barstyles)
	local cfg = barstyles[randCnt]
	for i, e in ipairs(cfg) do
		table.insert(i % 2 == 0 and self.info.counts or self.info.poss, e)
	end
end

-- 打开界面 挂载鱼竿spr
function wnd_homeLandFish:onShow()
	i3k_sbean.homeland_fish_status_change(1)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:LinkHomeLandFishModel(g_i3k_game_context:GetHomeLandCurEquip(), g_i3k_game_context:GetRoleId())
	end
end

function wnd_homeLandFish:refresh()
	self:loadFishEquipInfo()
	self:loadFishTagetDesc()
	self:loadSliderWidget()
	self:updateFishBtnImage(g_THROW_STATE)
	self:refreshFishAndExpCount()
end

-- refresh and InvokeUIFunction
function wnd_homeLandFish:loadFishEquipInfo()
	local fishCfg = i3k_db_home_land_base.fishCfg
	local wearEquips = g_i3k_game_context:GetHomeLandCurEquip()
	for i, e in ipairs(self.wearEquipWidget) do
		local info = wearEquips[i]
		if info then
			local equipCfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(info.confId)
			e.grade_icon:enableWithChildren()
			e.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipCfg.needItmeID, g_i3k_game_context:IsFemaleRole()))
			e.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipCfg.needItmeID))
			e.count:setText(info.canUseTime .. "/" ..equipCfg.canUseTims)
			e.name:setText(i3k_get_string(5351 + i))
		else
			-- local iconID = i == g_HOMELAND_WEAPON_EQUIP and fishCfg.fishRodIcon or fishCfg.baitIcon
			-- e.equip_icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
			e.count:setText(i3k_get_string(5124))
			e.grade_icon:disableWithChildren()
		end
	end
end

function wnd_homeLandFish:onChangeFishEquip(sender, fishType)
	if self._shortcutState ~= fishType then
		i3k_sbean.homeland_equip_sync(fishType)
	end
end

function wnd_homeLandFish:loadShortcutScroll(fishType)
	self._shortcutState = fishType
	local equipInfo = g_i3k_game_context:GetHomeLandEquip()
	local items = self:itemSort(equipInfo, fishType)
	self:isShowShortcutRoot(#items > 0)
	if #items > 0 then
		self.shortcutScroll:removeAllChildren()
		local all_layer = self.shortcutScroll:addChildWithCount(QJ_WIDGETS, 3, #items)
		for i, e in pairs(all_layer) do
			local info = items[i].info
			local equipCfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(info.confId)
			e.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipCfg.needItmeID, g_i3k_game_context:IsFemaleRole()))
			e.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipCfg.needItmeID))
			e.vars.item_count:setText(info.canUseTime) --可用次数
			e.vars.bt:onClick(self, self.onEquipTips, info)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17421))
	end
end

function wnd_homeLandFish:isShowShortcutRoot(isShow)
	self.shortcutRoot:setVisible(isShow)
end

-- InvokeUIFunction
function wnd_homeLandFish:resetShortcutState()
	self._shortcutState = 0
end

--物品排序
function wnd_homeLandFish:itemSort(items, fishType)
	local tmp = {}
	for k, v in pairs(items) do
		local order = v.confId * 1000000 + v.canUseTime * 1000 + v.id
		local isAdd = false
		local equipCfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(v.confId)
		if equipCfg.equipType == fishType and equipCfg.isCanFish == 1 then
			isAdd = true
		end
		if isAdd then
			table.insert(tmp, {order = order, info = v})
		end		
	end

	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

function wnd_homeLandFish:onEquipTips(sender, info)
	if g_i3k_game_context:GetHomeLandFishTime() ~= 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17422))
	end
	i3k_sbean.homeland_equip_wear(info.id, info, 1)
end


function wnd_homeLandFish:loadFishTagetDesc(textID)
	self.tag_desc:setText(i3k_get_string(textID or 5119))
end

function wnd_homeLandFish:loadSliderWidget(isAgain)
	if not isAgain then
		self.arrow:setRotation(MIN_ROTATION)
	end
	local colorImages = i3k_db_home_land_base.fishCfg.colorImages
	for i = 1, 5 do
		local timerNode = self.timersWidgets[i]
		local nodePercent = self.info.poss[i] / 100 * (100 - PERCENT_CONST)
		timerNode:setPercent(nodePercent + PERCENT_CONST)
		-- local colorType = self.info.counts[i]
		-- if colorImages[colorType] then -- 注释，策划配置无用
		-- 	stateNode:setImage(g_i3k_db.i3k_db_get_icon_path(colorImages[colorType]))
		-- end
	end
end

function wnd_homeLandFish:updateFishBtnImage(state)
	local iconID = FISH_ICON[state]
	self.fishBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(iconID))
end

function wnd_homeLandFish:updateFishBtnState(isDisable)
	if isDisable then
		self.fishBtn:enableWithChildren()
	else
		self.fishBtn:disableWithChildren()
	end
	self._isTouch = isDisable
end

function wnd_homeLandFish:onFishBtn(sender, isAuto)
	if self._isAutoFish and not isAuto then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5371))
	end
	if not isAuto then
		if g_i3k_game_context:GetBagIsFull() then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17423))
		end

		if not g_i3k_game_context:GetHomeLandCurEquipCanFish() then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5147))
		end
	end
	if g_i3k_game_context:GetHomeLandFishTime() == 0 then
		local hero = i3k_game_get_player_hero()
		if hero then
			local net_log = i3k_get_net_log()
			net_log:Add("zh-homeland_start_fish")
			local heroPos = hero._curPos
			local facePos = i3k_world_pos_to_logic_pos(g_i3k_game_context:GetHomeLandFishPos())
			local angle = i3k_vec3(facePos.x - heroPos.x, 0, facePos.z - heroPos.z)
			i3k_sbean.homeland_start_fish(angle, heroPos, facePos)
		end
		return
	end
	if not self._startFishState then
		self._startFishState = true
		local net_log = i3k_get_net_log()
		net_log:Add("zh-startFishState")
	else
		if g_i3k_game_context:GetHomeLandFishTime() ~= 0 then
			self._startFishState = false
			local curIdx = self:getNowArrowCurIndex()
			if curIdx then
				local net_log = i3k_get_net_log()
				net_log:Add("zh-homeland_finish_fish")
				i3k_sbean.homeland_finish_fish(curIdx, self._isAutoFish)
			else
				local net_log = i3k_get_net_log()
				net_log:Add("zh-not curIdx")
			end
		end
	end
end

-- 提示动画
function wnd_homeLandFish:playTipsAnis(isPlay)
	if isPlay then
		self._layout.anis.c_ts.play()
	else
		self._layout.anis.c_ts.stop()
	end
end

function wnd_homeLandFish:onRetractRod(dTime)
	if g_i3k_game_context:GetHomeLandFishTime() ~= 0 then
		if self._startFishState then
			self:playTipsAnis(false)
			if self.arrow:getRotation() < MAX_ROTATION and self.isadd then
				self.isadd = true
				self.arrow:setRotation(self.arrow:getRotation() + STEP_ANGLE * dTime)
			else
				self.arrow:setRotation(self.arrow:getRotation() - STEP_ANGLE * dTime)
				self.isadd = false
				if self.arrow:getRotation() < MIN_ROTATION then
					self.isadd = true
				end
			end
		end
	end
end

-- 获取箭头停止指向进度条样是idx值
function wnd_homeLandFish:getNowArrowCurIndex()
	local curIndex = nil
	local nowRotation = self.arrow:getRotation()
	local realPercent = nowRotation / TOTAL_ROTATION * 100 -- 转换箭头指向位置所占比例
	for i, e in ipairs(self.info.poss) do
		if realPercent < e then
			curIndex = self.info.counts[i]
			break
		end
	end
	return curIndex
end

-- InvokeUIFunction
function wnd_homeLandFish:finishFish()
	self._startFishState = false
	self:loadFishTagetDesc(5119)
end

function wnd_homeLandFish:onUpdate(dTime)
	self:onRetractRod(dTime)
	if g_i3k_game_context:GetIsInFishArea() then
		self._fishTimeSpace = self._fishTimeSpace + dTime
		if self._fishTimeSpace > 1 then
			local startFishTime = g_i3k_game_context:GetHomeLandFishTime()
			if startFishTime > 0 then 
				if startFishTime - i3k_game_get_time() == 0 then
					self:updateFishBtnImage(g_PACK_UP_STATE)
					self:loadFishTagetDesc(5121)
					self:updateFishBtnState(true)
					self:playTipsAnis(true)
					local hero = i3k_game_get_player_hero()
					if hero then
						local alist = {}
						table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actBiteHook, actloopTimes = 1})
						table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actBiteHook, actloopTimes = 1})
						table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actFishing, actloopTimes = -1})
						hero:PlayActionList(alist, 1)
						local net_log = i3k_get_net_log()
						net_log:Add("zh-actFishing")
					end
					
				end
			end
			self._fishTimeSpace = 0
		end
	end
	if self._isTouch then
		AutoTime = AutoTime + dTime
	end
	if AutoTime > 0.5 then
		AutoTime = 0
		self:autoFish()
	end
end

-- 自动
function wnd_homeLandFish:onAutoBtn(sender)
	if not self._isAutoFish then
		if not self:autoFishCondition() then return end
		local callBack = function (ok)
			if ok then
				self.autoFishBtn:stateToPressed()
				self._isAutoFish = not self._isAutoFish
				g_i3k_ui_mgr:OpenUI(eUIID_HomeLandAutoFishTips)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5372), callBack)
		
	else
		self.autoFishBtn:stateToNormal()
		self._isAutoFish = not self._isAutoFish
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandAutoFishTips)
	end
	
end

--自动钓鱼开启条件
function wnd_homeLandFish:autoFishCondition()
	local scheduleInfo = g_i3k_game_context:GetScheduleInfo()
	local active = scheduleInfo.activity	
	local autoActive = i3k_db_home_land_base.fishCfg.autoFishNeedActive
	if autoActive > active then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5373, autoActive))
		return false
	end
	if g_i3k_game_context:GetBagIsFull() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17423))
		return false
	end

	if not g_i3k_game_context:GetHomeLandCurEquipCanFish() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5147))
		return false
	end
	return true
end
-- 帮助
function wnd_homeLandFish:onHelp(sender)
	local dbCfg = i3k_db_home_land_base.fishCfg
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(5122, dbCfg.canFishTimes, dbCfg.maxMasteryTimes))
end

function wnd_homeLandFish:refreshFishAndExpCount()
	local weights = self._layout.vars
	local dbCfg = i3k_db_home_land_base.fishCfg
	local fishTimes = g_i3k_game_context:getHomeLandFishCount()
	local masteryTimes = g_i3k_game_context:getHomeLandFishExpCount()
	weights.jiang1:setText(i3k_get_string(5350, fishTimes, dbCfg.canFishTimes))
	weights.jiang2:setText(i3k_get_string(5351, math.min(masteryTimes, dbCfg.maxMasteryTimes), dbCfg.maxMasteryTimes))
end

function wnd_homeLandFish:onHide()
	--关闭自动钓鱼
	if self._isAutoFish then
		self:onAutoBtn()
	end
	g_i3k_game_context:SetHomeLandFishTime(0)
	i3k_sbean.homeland_fish_status_change(0)
	g_i3k_logic:ShowFishBattleUI(true)
	-- 关闭界面时销毁挂载钓鱼装备spr
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UnloadHomeLandFishModel()
	end
end

--自动钓鱼
function wnd_homeLandFish:autoFish()
	if not self._isTouch then return end
	if not self._isAutoFish then return end
	if g_i3k_game_context:GetBagIsFull() then
		self:onAutoBtn()
		return g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17423))
		end, 0.05)
	end

	if not g_i3k_game_context:GetHomeLandCurEquipCanFish() then
		return self:autoEquip()
	end
	if  self._startFishState then
		self:randomRotation()
	end	
	self:onFishBtn(nil, true)
end
--自动补充装备
function wnd_homeLandFish:autoEquip()
	local fishPole = false -- 鱼竿
	local fishBait = false -- 鱼饵
	local  curEquip = g_i3k_game_context:GetHomeLandCurEquip()
	local equipInfo = g_i3k_game_context:GetHomeLandEquip()
	for k, v in pairs(curEquip) do
		local cfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(v.confId)
		if k == g_HOMELAND_WEAPON_EQUIP then
			if cfg.isCanFish == 1 then
				fishPole = true
			end
		elseif k == g_HOMELAND_WEAPON_BAIT then
			fishBait = true
		end
	end
	local itemsFishPole = self:itemSort(equipInfo, g_HOMELAND_WEAPON_EQUIP)
	local itemsFishBait = self:itemSort(equipInfo, g_HOMELAND_WEAPON_BAIT)
	local callback = {
			--ok = function() self._isTouch = false  end,
			fail = function() self:onAutoBtn()
				g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5147))
				end, 0.05)
			end
		} 
	if not fishPole and #itemsFishPole > 0 then
		return i3k_sbean.homeland_equip_wear(itemsFishPole[1].info.id, itemsFishPole[1].info, 1, callback)
	end
	if not fishBait and #itemsFishBait > 0 then
		return i3k_sbean.homeland_equip_wear(itemsFishBait[1].info.id, itemsFishBait[1].info, 1, callback)
	end
	self:onAutoBtn()
	return g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5147))
	end, 0.05)
end

--随机旋转角度
function wnd_homeLandFish:randomRotation()
	if g_i3k_game_context:GetHomeLandFishTime() ~= 0 then
		if self._startFishState then
			local rotation = math.random(MIN_ROTATION, TOTAL_ROTATION)
			self.arrow:setRotation(rotation)
			--g_i3k_game_context:SetHomeLandFishTime(0)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_homeLandFish.new()
	wnd:create(layout)
	return wnd
end
