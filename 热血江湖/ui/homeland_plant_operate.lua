-- zengqingfeng
-- 2018/5/15
--eUIID_HomelandPlantOperate --家园植物操作界面
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
wnd_homeland_plant_operate = i3k_class("homeland_plant_operate", ui.wnd_base)

local textColor = {"ff89e24d", "ffff5e4d"}

function wnd_homeland_plant_operate:ctor()
	self._updateCD = 0
	self._lastState = -1 
	self._countdown_water = 0 
	self._countdown_care = 0 
	self._countdown_steal = 0
	self._countdown_harvest = 0
	self._crop = nil -- 地图上作物的引用
	self.btns = {} -- 按钮UI的引用合集
	self.cfgs = {} -- 按钮的数据合集
	self._time_str = ""
end

function wnd_homeland_plant_operate:configure()
	self._isClose = false
	local widgets = self._layout.vars
	widgets.imgBK:onTouchEvent(self, self.closeButton)
	self.txt_name = widgets.name
	self.txt_time = widgets.time 
	self.txt_value1 = widgets.btnValue1
	self.txt_value2 = widgets.btnValue2
	
	local operateCfgs = {
		["master"] = {
			[1] = {txt = "浇水", func = self.waterCrop},
			[2] = {txt = "护理", func = self.careCrop},
			[3] = {txt = "收获", func = self.harvestCrop},
			[4] = {txt = "铲除", func = self.removeCrop},
		},
		["guests"] = {
			[1] = {txt = "浇水", func = self.waterCrop},
			[2] = {txt = "护理", func = self.careCrop},
			[3] = {txt = "偷菜", func = self.stealCrop},
		}
	}
	
	local btnShowCfgs = {
		["master"] = {
			[g_CROP_STATE_SEED] = {1, 4},
			[g_CROP_STATE_STRONG] = {1, 2, 4},
			[g_CROP_STATE_MATURE] = {3, 4},
		},
		["guests"] = {
			[g_CROP_STATE_SEED] = {1},
			[g_CROP_STATE_STRONG] = {1, 2},
			[g_CROP_STATE_MATURE] = {3},
		}
	}
	
	local str = g_i3k_game_context:isInMyHomeLand() and "master" or "guests"
	self.operateCfg = operateCfgs[str]
	self.btnShowCfg = btnShowCfgs[str]
	
	for index = 1, 3 do 
		table.insert(self.btns, {isShow = false, ui_btn = widgets["btn"..index], ui_txt = widgets["btnName"..index]})
	end 
end

function wnd_homeland_plant_operate:setCrop_safe(crop)
	if crop then 
		self._crop = crop -- 植物的引用，不可修改数据只读
	end 
end 

function wnd_homeland_plant_operate:onShow()
	
end

function wnd_homeland_plant_operate:onHide()
	self._isClose = true 
end 

function wnd_homeland_plant_operate:onCloseUI()
	if not self._isClose then 
		self:getSuper().onCloseUI(self)
	end 
end

function wnd_homeland_plant_operate:onUpdate(dTime)
	--[[if self._lastState == g_CROP_STATE_MATURE then 
		return 
	end --]]
	self._updateCD = self._updateCD - dTime 
	self._countdown_water = self._countdown_water - dTime
	self._countdown_care = self._countdown_care - dTime 
	self._countdown_steal = self._countdown_steal - dTime
	self._countdown_harvest = self._countdown_harvest - dTime
	if self._updateCD < 0 and self._crop then 
		self._updateCD = 0.5 
		self:updateTimeStr()
		if self._lastState ~= self._crop._cropState then 
			self:refresh()
		end
	end
end

function wnd_homeland_plant_operate:onOperate(crop)
	if self._crop._gid == crop._gid then 
		if crop._cropState == g_CROP_STATE_SEED 
		or crop._cropState == g_CROP_STATE_STRONG
		or crop._cropState == g_CROP_STATE_MATURE then 
			self:refresh(crop)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_HomelandPlantOperate)
		end 
	end
end 

function wnd_homeland_plant_operate:refresh(crop)
	self:setCrop_safe(crop)
	self:refreshBtns()
	self:refreshName()

	local plant = self._crop._ground.curPlant
	self._countdown_water = i3k_db.i3k_db_getWaterLeftTime(plant)
	self._countdown_care = i3k_db.i3k_db_getCareLeftTime(plant)
	self._countdown_steal = i3k_db.i3k_db_getStealLeftTime(plant)
	self._countdown_harvest = i3k_db.i3k_db_getHarvestLeftTime(plant)
	self._layout.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_home_land_corp[plant.id].getItemID))
	self._layout.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_home_land_corp[plant.id].getItemID))
	local value2Visible = false
	if self._crop._cropState == g_CROP_STATE_MATURE then 
		self.txt_time:setText("已成熟")
		if g_i3k_game_context:isInMyHomeLand() then 
			self:refreshHarvestTimes()
		else 
			self:refreshStealTimes()
		end
	else 
		if self._crop._cropState == g_CROP_STATE_STRONG then 
			self:refreshCareTimes()
			value2Visible = true 
		end
		self:refreshWaterTimes()
	end 
	self.txt_value2:setVisible(value2Visible)
	self._lastState = self._crop._cropState
end 
 
-- 设置按钮信息
function wnd_homeland_plant_operate:refreshBtns()
	self.cfgs = {}
	for index, id in ipairs(self.btnShowCfg[self._crop._cropState]) do 
		table.insert(self.cfgs, self.operateCfg[id])
	end 
	for index, btn in ipairs(self.btns) do 
		btn.isShow = false
	end 
	for index, cfg in ipairs(self.cfgs) do 
		local btn = self.btns[index]
		btn.ui_btn:onClick(self, cfg.func)
		btn.ui_txt:setText(cfg.txt)
		btn.isShow = true
	end 
	self:setBtnsLayout()
end 

function wnd_homeland_plant_operate:refreshName()
	local name = i3k_db.i3k_db_getCropNameByState(self._crop._ground, self._crop._cropState)
	self.txt_name:setText(name)
end 

function wnd_homeland_plant_operate:refreshHarvestTimes()
	local t1, t2 = i3k_db.i3k_db_getHarvestTimes(self._crop._ground)
	self.txt_value1:setText(string.format("次数:%s/%s", t1, t2))
	self:setTextColorByTimes2(self.txt_value1, t1, t2)
end 

function wnd_homeland_plant_operate:refreshStealTimes()
	local str, stealTimes = g_i3k_game_context:GetHomelandStealTimes()
	self.txt_value1:setText(string.format("次数:%s", str))
	self:setTextColorByTimes(self.txt_value1, stealTimes)
end 

function wnd_homeland_plant_operate:refreshWaterTimes()
	local _,waterTimes, waterTimesLimit = i3k_db.i3k_db_checkWaterCropTimesLimit(self._crop._ground, self._crop._cropState)
	self.txt_value1:setText(string.format("次数:%s/%s", waterTimes, waterTimesLimit))
	self:setTextColorByTimes2(self.txt_value1, waterTimes, waterTimesLimit)
end 

function wnd_homeland_plant_operate:refreshCareTimes()
	local t1, t2 = i3k_db.i3k_db_getCareTimes(self._crop._ground)
	self.txt_value2:setText(string.format("次数:%s/%s", t1, t2))
	self:setTextColorByTimes2(self.txt_value2, t1, t2)
end 

function wnd_homeland_plant_operate:setTextColorByTimes(txt, t1)
	local colorIndex = t1 > 0 and 1 or 2
	txt:setTextColor(textColor[colorIndex])
end 

function wnd_homeland_plant_operate:setTextColorByTimes2(txt, t1, t2)
	local colorIndex = t1 < t2 and 1 or 2
	txt:setTextColor(textColor[colorIndex])
end 

function wnd_homeland_plant_operate:setTextColorByTime(txt, time)
	local colorIndex = time > 0 and 2 or 1
	txt:setTextColor(textColor[colorIndex])
end 

function wnd_homeland_plant_operate:refreshWaterAndCareTimes()
	
	if self._crop._cropState == g_CROP_STATE_STRONG then  
		
	end
	self.txt_value1:setText(str)
end 

-- 根据需要显示的按钮数目做布局
function wnd_homeland_plant_operate:setBtnsLayout()
	local dx = 175
	local xo = dx - dx / 2 * #self.cfgs + 25
	if #self.cfgs == 2 then 
		dx = dx + 55
		xo = xo - 80
	end 
	for index, btn in ipairs(self.btns) do 
		if btn.isShow then 
			btn.ui_btn:setPositionX(xo + index * dx)
		end
		btn.ui_btn:setVisible(btn.isShow)
	end
end 

-- 偷菜
function wnd_homeland_plant_operate:stealCrop()
	if self._crop._cropState ~= g_CROP_STATE_MATURE then   
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5059))
	elseif not g_i3k_game_context:checkHomeLandStealTimes() then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5060))
	elseif not g_i3k_db.i3k_db_checkCanStealCrop(self._crop._ground) then -- 偷取冷却时间
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5061))
	elseif not g_i3k_game_context:checkBagCanAddCell(i3k_db_home_land_base.baseCfg.getCropBagItemNeed, true) then -- 背包大小判断
		
	else
		i3k_sbean.homeland_steal(self._crop._typeid, self._crop._groundIndex, self._crop._ground)
		self:onCloseUI()
	end
end 

-- 浇水
function wnd_homeland_plant_operate:waterCrop()
	if g_i3k_game_context:homelandCheckCanWater(self._crop._ground, self._crop._cropState, true) then 
		i3k_sbean.homeland_water(self._crop._typeid, self._crop._groundIndex)
		self:onCloseUI()
	end
end 

-- 护理
function wnd_homeland_plant_operate:careCrop()
	if g_i3k_game_context:homelandCheckCanCare(self._crop._ground, self._crop._cropState, true) then  
		i3k_sbean.homeland_nurse(self._crop._typeid, self._crop._groundIndex, self._crop._ground.curPlant.nurseTimes + 1)
		self:onCloseUI()
	end 
end 

-- 收获
function wnd_homeland_plant_operate:harvestCrop()
	if self._crop._cropState ~= g_CROP_STATE_MATURE then  
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5062))
	elseif g_i3k_db.i3k_db_checkHarvestFinished(self._crop._ground) then -- 判断可以收取的数量
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5063))
	elseif not g_i3k_db.i3k_db_checkCanHarvestCrop(self._crop._ground) then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5064))
	elseif not g_i3k_game_context:checkBagCanAddCell(i3k_db_home_land_base.baseCfg.getCropBagItemNeed, true) then -- 背包大小判断
		
	else
		local petId = 0
		for _, v in pairs(i3k_db_arder_pet) do
			local channel = i3k_game_get_channel_name()
			if (v.canUseChannel[1] == tonumber(channel)) or (v.canUseChannel[1] == 0)  then
				if v.isAddition == 3 then
					local wizardData = g_i3k_game_context:GetOfflineWizardData()
					local wizardEndTime = wizardData.wizardEndTimes[v.id] or 0
					if wizardEndTime == -1 or wizardEndTime > i3k_game_get_time() then
						if g_i3k_game_context:GetExtraHarvestTimes(v.id) < v.arg2 then
							petId = v.id
							break
						end
					end
				end
			end
		end
		i3k_sbean.homeland_harvest(self._crop._typeid, self._crop._groundIndex, self._crop._ground, petId)
		self:onCloseUI()
	end
end 

-- 铲除
function wnd_homeland_plant_operate:removeCrop()
	if self._crop._cropState ~= g_CROP_STATE_SEED 
	and self._crop._cropState ~= g_CROP_STATE_STRONG 
	and self._crop._cropState ~= g_CROP_STATE_MATURE then  
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5065))
	else 
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5066), function(flag)
			if flag then 
				i3k_sbean.homeland_remove_plant(self._crop._typeid, self._crop._groundIndex)
				self:onCloseUI()
			end 
		end)
	end 
end 

function wnd_homeland_plant_operate:updateTimeStr()
	if self._crop._cropState == g_CROP_STATE_MATURE then 
		if g_i3k_game_context:isInMyHomeLand() then 
			if self._countdown_harvest > 0 and not i3k_db.i3k_db_checkHarvestFinished(self._crop._ground) then 
				self.txt_value1:setText(i3k_get_time_show_text(self._countdown_harvest))
				self:setTextColorByTime(self.txt_value1, self._countdown_harvest)
			else 
				self:refreshHarvestTimes()
			end
		else 
			if self._countdown_steal > 0 and g_i3k_game_context:checkHomeLandStealTimes() then 
				self.txt_value1:setText(i3k_get_time_show_text(self._countdown_steal))
				self:setTextColorByTime(self.txt_value1, self._countdown_steal)
			else 
				self:refreshStealTimes()
			end
		end 	
	else
		if self._crop._cropState == g_CROP_STATE_STRONG then 
			if self._countdown_care > 0 and not i3k_db.i3k_db_checkCareFinished(self._crop._ground) then 
				self.txt_value2:setText(i3k_get_time_show_text(self._countdown_care))
				self:setTextColorByTime(self.txt_value2, self._countdown_care)
			else 
				self:refreshCareTimes()
			end
		end
		
		if self._countdown_water > 0 and not i3k_db.i3k_db_checkWaterCropTimesLimit(self._crop._ground, self._crop._cropState) then 
			self.txt_value1:setText(i3k_get_time_show_text(self._countdown_water))
			self:setTextColorByTime(self.txt_value1, self._countdown_water)
		else 
			self:refreshWaterTimes()
		end
		self.txt_time:setText(i3k_get_time_show_text(self._crop._countdown))
	end 
end 

function wnd_homeland_plant_operate:closeButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:onCloseUI()
	end
end

function wnd_create(layout,...)
	local wnd = wnd_homeland_plant_operate.new()
	wnd:create(layout,...)
	return wnd
end
