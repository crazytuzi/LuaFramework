-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------
wnd_equip_temper = i3k_class("wnd_equip_temper",ui.wnd_profile)

local NEEDITEMT1 = "ui/widgets/zbqht2"
local TEMPERPROPT1 = "ui/widgets/zbclt2"
local TEMPERPROPT2 = "ui/widgets/zbclt3"
local SPEED = 5 --属性条渐变速度
local ALL_PROP_INCREASE = 1--属性改变值全部升高
local ALL_PROP_DECREASE = -1--属性改变值全部降低

function wnd_equip_temper:ctor()
	self.partID = 0
	self.selectID = 0
	self.widgets = nil
	self.propWidgets = {} --属性条控件
end

function wnd_equip_temper:configure()
	local widgets = self._layout.vars

	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon

	self:initWearEquipWidget(widgets)

	self.qhRedPoint = widgets.strengRedPoint
	self.starRedPoint = widgets.starRedPoint
	self.inlayRedPoint = widgets.inlayRedPoint
	self.temperRedPoint = widgets.temperRedPoint

	self.increase_lv = widgets.increase_lv

	widgets.starPreviewBtn:onClick(self,function()
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperStarPreview)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperStarPreview, self.partID)
	end)
	widgets.cl_bt:stateToPressed()
	widgets.sx_bt:stateToNormal()
	widgets.xq_bt:stateToNormal()
	widgets.qh_bt:stateToNormal()

	widgets.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17408))
		end)
	widgets.sx_bt:onClick(self,self.sxBtn)
	widgets.xq_bt:onClick(self,self.xqBtn)
	widgets.qh_bt:onClick(self,self.qhBtn)
	widgets.close_btn:onClick(self, self.onCloseBtn)
	widgets.bailianBtn:onClick(self, self.onBaiLianBtn)
	self.new_root = widgets.new_root
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
end

--初始化穿着装备控件
function wnd_equip_temper:initWearEquipWidget(widgets)
	for i=1, eEquipSharpen do
		local equip_btn = "equip"..i
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local is_select = "is_select"..i
		local level_label = "star_level"..i
		local star_icon = "starIcon"..i
		local red_tips = "tips"..i

		self.wear_equip[i]  = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			is_select	= widgets[is_select],
			level_label	= widgets[level_label],
			red_tips	= widgets[red_tips],
			star_icon = widgets[star_icon],
		}
		self.wear_equip[i].equip_btn:onClick(self, self.onSelectEquip, i)
	end
end

function wnd_equip_temper:refresh(partID, equip_id)
	local wEquips = g_i3k_game_context:GetWearEquips()
	if self.partID == 0 then
		if partID then
			self.partID = partID;
			self:selectEquip(partID, equip_id)
		else
			self:defaultSelectEquip(g_i3k_game_context:GetWearEquips())
		end
	else
		self:selectEquip(self.partID, wEquips[self.partID].equip.equip_id)
	end

	if g_i3k_game_context:checkTempPropsAllIncOrDec(partID or self.partID) == ALL_PROP_INCREASE then
		self:onSaveBtn(self, partID or self.partID)
	end

	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	self:updateRedPoint()
	self:updatePartRedPoint()
end

function wnd_equip_temper:updateWearEquipsData(ctype, level, fightpower, wEquips)
	self:updateProfile(ctype, level, fightpower, wEquips)
	self:updateEquipStar(wEquips)
end

function wnd_equip_temper:updateEquipStar(wEquips)
	local wEquips = wEquips or g_i3k_game_context:GetWearEquips()
	for i=1,eEquipSharpen do
		local equip = wEquips[i].equip
		if equip then
			local starCount = g_i3k_game_context:GetEquipTemperTotalStars(i)
			self.wear_equip[i].level_label:setVisible(starCount ~= 0)
			self.wear_equip[i].level_label:setText(starCount)
			self.wear_equip[i].star_icon:setVisible(starCount ~= 0)
			--self:updateWearEquipsLevl(i)
		else
			self.wear_equip[i].star_icon:setVisible(false)
			self.wear_equip[i].level_label:setVisible(false)
			self.wear_equip[i].equip_btn:enable()
		end
	end
end

function wnd_equip_temper:setRightView(equip_id, partID)
	local props = g_i3k_game_context:GetEquipTemperProps(partID)
	local isUnlocked = props and next(props) --是否解锁了
	self.propWidgets = {} --清空
	local isMax = self:isAllPropMax(partID)
	if not isUnlocked then
		self:showUnlock(equip_id, partID)
	else
		self:setTopPart(equip_id, partID)
		if isMax then
			self:showMax(equip_id, partID)
		else
			self:showNormal(equip_id, partID)
		end
	end
end

--显示解锁界面
function wnd_equip_temper:showUnlock(equip_id, partID)
	local widgets = self._layout.vars
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local temperPropsStarLimit = equipCfg.temperPropsStarLimit
	widgets.img_max:hide()
	widgets.topBar:hide()
	widgets.saveBtn:hide()
	widgets.qianchuiBtn:hide()
	widgets.unlockBtn:show()
	widgets.img_unlock:show()
	widgets.needItem:show()
	self:setSkill(equip_id)
	self:setNeedItem(g_i3k_db.i3k_db_get_equip_temper_unlock_consume_by_id(equip_id))
	widgets.topContent:removeAllChildren()
	for k, v in ipairs(temperPropsStarLimit) do
		local layout = require(TEMPERPROPT1)()
		layout.vars.des:setText(string.format("第%s条属性%s", k, i3k_get_string(17405, v.min)))
		widgets.topContent:addItem(layout)
	end
	widgets.unlockBtn:onClick(self, self.onUnlockBtnClick, partID)
end

--显示满级界面
function wnd_equip_temper:showMax(equip_id)
	local widgets = self._layout.vars
	widgets.img_max:show()
	widgets.topBar:show()
	widgets.needItem:hide()
	widgets.unlockBtn:hide()
	widgets.img_unlock:hide()
	widgets.saveBtn:hide()
	widgets.qianchuiBtn:hide()
	local equip_id = equip_id or g_i3k_game_context:GetWearEquips()[self.partID].equip.equip_id
	self:setSkill(equip_id)
end

--显示正常界面
function wnd_equip_temper:showNormal(equip_id, partID)
	local widgets = self._layout.vars
	widgets.img_max:hide()
	widgets.topBar:show()
	widgets.img_unlock:hide()
	widgets.unlockBtn:hide()
	local tempProps = g_i3k_game_context:GetTempEquipQianChuiProps()
	widgets.saveBtn:setVisible(tempProps and next(tempProps) and true or false)
	widgets.needItem:show()
	widgets.qianchuiBtn:show()
	self:setSkill(equip_id)
	widgets.qianchuiBtn:onClick(self, self.onQianChuiBtn, partID)
	widgets.saveBtn:onClick(self, self.onSaveBtn, partID)
end

--设置右边上半部分
function wnd_equip_temper:setTopPart(equip_id, partID)
	local props = g_i3k_game_context:GetEquipTemperProps(partID)
	local widgets = self._layout.vars
	widgets.totalStar:setText('x'..g_i3k_game_context:GetEquipTemperTotalStars(partID))
	local consume = i3k_db_equip_temper_base.qianchuiConsume
	self:setNeedItem(consume)
	widgets.topContent:removeAllChildren()
	local propStarThreshold = i3k_db_equip_temper_base.propStarThreshold
	local tempQianChuiProps = g_i3k_game_context:GetTempEquipQianChuiProps()
	for i,v in ipairs(props) do
		local layout = require(TEMPERPROPT2)()
		local prop = i3k_db_prop_id[v.id] --属性的相关信息
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id) --装备的相关信息
		layout.info = {
			curValue = v.value,--当前值
			targetValue = v.value,--目标值
			propID = v.id,
			equipID = equip_id,
			index = i,--下标
		}
		layout.vars.prop_name:setText(prop.desc)
		layout.vars.prop_icon:setImage(g_i3k_db.i3k_db_get_icon_path(prop.icon))
		self:setPropBarProcess(layout, v.value)
		widgets.topContent:addItem(layout)
		self.propWidgets[i] = layout
		if tempQianChuiProps and tempQianChuiProps[i] then --如果本地存有临时的属性 要显示变化
			local change = tempQianChuiProps[i].value - v.value --变话的差值
			local changeTxt = change > 0 and ('+'..change) or change
			changeTxt = change == 0 and '' or changeTxt
			if not layout.vars.max:isVisible() then
				layout.vars.prop_change:show()
				layout.vars.prop_change:setText(changeTxt)
			    layout.vars.prop_change:setTextColor(g_i3k_get_cond_color(change >= 0))
			end
		end
	end
end

--设置一个属性条期望的进度
function wnd_equip_temper:setPropBarProcess(widget, target, isShowEffect)
	local info = widget.info
	local prop_change = target - info.targetValue
	local changeTxt = prop_change > 0 and ('+'..prop_change) or prop_change
	changeTxt = prop_change == 0 and '' or changeTxt
	widget.vars.prop_change:setText(changeTxt)
	widget.vars.prop_change:setTextColor(g_i3k_get_cond_color(prop_change >= 0))
	info.targetValue = target
	local propStarThreshold = i3k_db_equip_temper_base.propStarThreshold
	local curStar = g_i3k_db.i3k_db_get_equip_temper_prop_star(info.propID, info.curValue) --当前属性对应的星数
	local curStarThreshold = propStarThreshold[info.propID][curStar]	--当前星级的属性的区间
	widget.vars.max:setVisible(self:isMaxOfEquipProp(info.equipID, info.index, info.propID, info.curValue))
	widget.vars.prop_bar_text:setText(math.ceil(info.curValue))
	local percent = (info.curValue - curStarThreshold.min)/(curStarThreshold.max - curStarThreshold.min) * 100
	widget.vars.prop_bar:setPercent(percent)
	widget.vars.propStar:setText('x'..curStar)
	if isShowEffect and prop_change ~= 0 then --初始化时不播放特效
		widget.anis.c_shenji:stop()
		widget.vars.prop_change:show()
		widget.anis.c_shenji.play(function()
			widget.vars.prop_change:hide()
			widget.anis.c_shenji:stop()
		end)
	end
end

--千锤成功之后更新属性
function wnd_equip_temper:setQianChuiProps(props)
	self._layout.vars.saveBtn:show()
	local curProps = g_i3k_game_context:GetEquipTemperProps(self.partID)
	for i, v in ipairs(props) do
		local change = v.value - curProps[i].value
		local changeTxt = change > 0 and ('+'..change) or change
		changeTxt = change == 0 and '' or changeTxt
		local prop_change = self.propWidgets[i].vars.prop_change
		local prop_max = self.propWidgets[i].vars.max
		if not prop_max:isVisible() then
			prop_change:setTextColor(g_i3k_get_cond_color(change >= 0))
			prop_change:setVisible(true)
			prop_change:setText(changeTxt)
		end
	end
end


--判断某个装备的某个属性是否达到了最大值
function wnd_equip_temper:isMaxOfEquipProp(equip_id, prop_index, prop_id, prop_value)
	local propStarThreshold = i3k_db_equip_temper_base.propStarThreshold
	local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local maxStar = equip_cfg.temperPropsStarLimit[prop_index].max
	local maxValue = propStarThreshold[prop_id][maxStar].max
	return prop_value == maxValue
end

--判断这个装备的所有属性是否达到了最大值
function wnd_equip_temper:isAllPropMax(partID)
	local wEquips = g_i3k_game_context:GetWearEquips()[partID]
	local equip_id = wEquips.equip.equip_id
	local props = g_i3k_game_context:GetEquipTemperProps(partID)
	if props and next(props) then
		for i, v in ipairs(props) do
			if not self:isMaxOfEquipProp(equip_id, i, v.id, v.value) then
				return false
			end
		end
	else
		return false
	end
	return true
end

--设置锤炼技能
function wnd_equip_temper:setSkill(equip_id)
	local skillids = i3k_db_equip_temper_base.partDetail[self.partID].hammerSkill
	local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local widgets = self._layout.vars
	local activeSkill =	g_i3k_game_context:GetEquipiTemperSkill(self.partID)
	for i = 1,2 do
		if widgets['skill'..i..'_icon'] then
			local skillcfg = i3k_db_equip_temper_skill[skillids[i]]
			local skillID = skillids[i]
			local isActive = activeSkill and activeSkill[skillids[i]]
			local skillLvl = isActive and activeSkill[skillids[i]] or equip_cfg.temperSkillsLevel[i].min
			local skillRed = false
			local canConsume = true
			if not isActive then
				for i, v in ipairs(skillcfg[skillLvl].activeConsume) do
					if canConsume then
						canConsume = g_i3k_game_context:GetCommonItemCanUseCount(v.itemId) >= v.count
					else
						break
					end
				end
				local isStarEnough = g_i3k_game_context:GetEquipTemperTotalStars(self.partID) >= skillcfg[skillLvl].needStar
				skillRed = canConsume and isStarEnough
			else
				local isMax = skillLvl == equip_cfg.temperSkillsLevel[i].max
				if isMax then
					skillRed = false
				else
					for i, v in ipairs(skillcfg[skillLvl + 1].activeConsume) do
						if canConsume then
							canConsume = g_i3k_game_context:GetCommonItemCanUseCount(v.itemId) >= v.count
						else
							break
						end
					end
					local isStarEnough = g_i3k_game_context:GetEquipTemperTotalStars(self.partID) >= skillcfg[skillLvl + 1].needStar
					skillRed = canConsume and isStarEnough
				end
			end

			local isMax = isActive and skillLvl == equip_cfg.temperSkillsLevel[i].max
			widgets['skill'..i..'_icon']:setImage(g_i3k_db.i3k_db_get_icon_path(skillcfg[skillLvl].icon))
			widgets['skill'..i..'_name']:setText(skillcfg[skillLvl].name)
			widgets['skill'..i..'_red']:setVisible(skillRed)
			widgets['isActive'..i]:setImage(g_i3k_db.i3k_db_get_icon_path(isActive and 7253 or 7254))
			widgets['skill'..i..'_btn']:onClick(self, self.onSkillClick, {
				isActive = isActive,
				skillID  = skillids[i],
				partID   = self.partID,
				skillLvl = skillLvl,
				index    = i,
				isMax    = isMax,
				})
		end
	end
end

--保存成功
function wnd_equip_temper:onSaveSuccess()
	self._layout.vars.saveBtn:hide()
	local props = g_i3k_game_context:GetEquipTemperProps(self.partID)
	if props and next(props) then
		for i, v in ipairs(props) do
			self:setPropBarProcess(self.propWidgets[i], props[i].value, true)
		end
		if self:isAllPropMax(self.partID) then
			self:showMax()
		end
	end
	self:updateRedPoint()
	self:updatePartRedPoint()
end

--让属性value动起来
function wnd_equip_temper:updatePropWidgetValue(dTime)
	for i, v in ipairs(self.propWidgets) do
		local info = v.info
		if info.curValue ~= info.targetValue then
			if math.abs(info.curValue - info.targetValue) <= 0.1 then
				info.curValue = info.targetValue
			end
			info.curValue = info.curValue + (info.targetValue - info.curValue)* SPEED * dTime
			local propStarThreshold = i3k_db_equip_temper_base.propStarThreshold
			local curStar, curStarThreshold = g_i3k_db.i3k_db_get_equip_temper_prop_star(info.propID, math.floor(info.curValue)) --当前属性对应的星数 --当前星级的属性的区间
			v.vars.max:setVisible(self:isMaxOfEquipProp(info.equipID, info.index, info.propID, info.curValue))
			v.vars.prop_bar_text:setText(math.ceil(info.curValue))
			local percent = (info.curValue - curStarThreshold.min)/(curStarThreshold.max - curStarThreshold.min) * 100
			v.vars.prop_bar:setPercent(percent)
			v.vars.propStar:setText('x'..curStar)
		end
	end
	self._layout.vars.totalStar:setText('x'..g_i3k_game_context:GetEquipTemperTotalStars(self.partID))
	self:updateEquipStar()
end

function wnd_equip_temper:onUpdate(dTime)
	self:updatePropWidgetValue(dTime)
end

function wnd_equip_temper:setNeedItem(data)
	self.needItemData = data or self.needItemData
	local data = data or self.needItemData
	local widgets = self._layout.vars.bottomContent
	widgets:removeAllChildren()
	self.isMaterialEnough = true
	for i, e in ipairs(data) do
		local T1 = require(NEEDITEMT1)()
		local widget = T1.vars
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemId))
		widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemId))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemId, g_i3k_game_context:IsFemaleRole()))
		widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemId))
		widget.item_name:setTextColor(name_colour)
		widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemId))
		if e.itemId == g_BASE_ITEM_DIAMOND or e.itemId == g_BASE_ITEM_COIN then
			widget.item_count:setText(e.itemCount or e.count)
		else
			widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) .."/".. (e.itemCount or e.count))
		end
		if self.isMaterialEnough then
			self.isMaterialEnough = g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= (e.itemCount or e.count)
		end
		widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= (e.itemCount or e.count)))
		widget.bt:onClick(self, self.onItemTips, e.itemId)
		widgets:addItem(T1)
	end
	self:updateRedPoint()
	self:updatePartRedPoint()
end

function wnd_equip_temper:defaultSelectEquip(wEquips)
	local defaultIndex = g_i3k_game_context:GetDefaultTemperSelectEquip()
	--若果本地没有存 就找默认第一个能锤炼的 如果存了 就用存的
	if not g_i3k_db.i3k_db_get_equip_can_temper_by_pos(defaultIndex) then --如果默认的不能锤炼 说明换号了 清空
		defaultIndex = 0
		g_i3k_game_context:ClearTempEquipProps()
		g_i3k_game_context:ResetDefaultTemperSelectEquip()
	end
	local equipIndex = defaultIndex ~= 0 and defaultIndex or g_i3k_logic:GetDefaultCanTemperWeapon()
	if equipIndex then
		g_i3k_game_context:SetDefaultTemperSelectEquip(equipIndex)
		local equip = wEquips[equipIndex].equip
		if equip then
			self.wear_equip[equipIndex].is_select:show()
			self.selectID = equipIndex;
			self.partID = equipIndex;
			self:setRightView(equip.equip_id, equipIndex)
		end
	end
end

function wnd_equip_temper:onSelectEquip(sender, partID)
	local wEquip = g_i3k_game_context:GetWearEquips()[partID].equip
	if not wEquip then
		return
	end
	local equip_id = wEquip.equip_id
	if self.selectID == partID then
		return
	end
	if g_i3k_db.i3k_db_get_equip_can_temper(equip_id) then
		local tempQianChuiProps = g_i3k_game_context:GetTempEquipQianChuiProps() --临时的千锤属性
		if tempQianChuiProps and next(tempQianChuiProps) then
			g_i3k_ui_mgr:ShowCustomMessageBox2("保留","不保留","是否保留千锤的结果？",function(bValue)
				if bValue then
					local wEquips = g_i3k_game_context:GetWearEquips()
					local equip_id = wEquips[self.selectID].equip.equip_id
					local guid = wEquips[self.selectID].equip.equip_guid
					if g_i3k_game_context:checkTempPropsAllIncOrDec(self.selectID) == ALL_PROP_DECREASE then
						g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17407),function(bValue)
							if bValue then
								i3k_sbean.equip_hammer_save(equip_id, guid, self.selectID)
							else
								g_i3k_game_context:ClearTempEquipProps()--清掉临时数据
							end
							g_i3k_game_context:SetDefaultTemperSelectEquip(partID)--设置默认选中的装备位 如果短线重连需要恢复到这个位置
							self.selectID = partID
							self.partID = partID
							self:refresh()
						end)
					else
						i3k_sbean.equip_hammer_save(equip_id, guid, self.selectID)
					end
				else
					g_i3k_game_context:ClearTempEquipProps()--清掉临时数据
					g_i3k_game_context:SetDefaultTemperSelectEquip(partID)--设置默认选中的装备位 如果短线重连需要恢复到这个位置
					self.selectID = partID
					self.partID = partID
					self:refresh()
				end
			end)
		else
			for i=1, #self.wear_equip do
				self.wear_equip[i].is_select:setVisible(i == partID)
			end
			g_i3k_game_context:SetDefaultTemperSelectEquip(partID)--设置默认选中的装备位 如果短线重连需要恢复到这个位置
			self.selectID = partID
			self.partID = partID
			self:refresh()
		end
	else
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
		if equip_cfg.temperSkillsLevel then
			g_i3k_ui_mgr:PopupTipMessage("该部位暂未开放锤炼")
		else
			g_i3k_ui_mgr:PopupTipMessage("该装备不能锤炼")
		end
	end
end

function wnd_equip_temper:updateRedPoint()
	self.qhRedPoint:setVisible(g_i3k_game_context:qhRedPoint())
	self.starRedPoint:setVisible(g_i3k_game_context:starRedPoint())
	local test = g_i3k_game_context:isHaveInlayRedPoint()
	self.inlayRedPoint:setVisible(g_i3k_game_context:isHaveInlayRedPoint())
	self.temperRedPoint:setVisible(g_i3k_game_context:temperRedPoint())
end

function wnd_equip_temper:updatePartRedPoint()
	local wEquips = g_i3k_game_context:GetWearEquips()
	for i=1, eEquipSharpen do
		if wEquips[i] then
			self.wear_equip[i].red_tips:hide()
			if wEquips[i].equip then
				if g_i3k_game_context:SingleEquipTemperRed(i) then
					self.wear_equip[i].red_tips:show()
				end
			end
		end
	end
end

function wnd_equip_temper:RemoveRightUI()
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
end

function wnd_equip_temper:selectEquip(partID, equip_id)
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == partID)
	end
	self.selectID = partID
	self:setRightView(equip_id, partID)
end

--------------Btn Click--------------------------------
function wnd_equip_temper:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_equip_temper:onQianChuiBtn(sender, partID)
	if self.isMaterialEnough then
		local wEquips = g_i3k_game_context:GetWearEquips()
		local equip_id = wEquips[partID].equip.equip_id
		local guid = wEquips[partID].equip.equip_guid
		i3k_sbean.equip_hammer(equip_id, guid, partID)
	else
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法千锤")
	end
end

function wnd_equip_temper:onSaveBtn(sender, partID)
	local wEquips = g_i3k_game_context:GetWearEquips()
	local equip_id = wEquips[partID].equip.equip_id
	local guid = wEquips[partID].equip.equip_guid
	if g_i3k_game_context:checkTempPropsAllIncOrDec(partID) == ALL_PROP_DECREASE then
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17407),function(bValue)
			if bValue then
				i3k_sbean.equip_hammer_save(equip_id, guid, partID)
			end
		end)
	else
		i3k_sbean.equip_hammer_save(equip_id, guid, partID)
	end
end

function wnd_equip_temper:onSkillClick(sender, info)
	if info.isActive then
		if not info.isMax then
			g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperSkillUp)
			g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperSkillUp, info)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperSkillDes)
			g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperSkillDes, info)
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperSkillActive)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperSkillActive ,info)
	end
end

function wnd_equip_temper:sxBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.starUpLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(126, i3k_db_common.functionOpen.starUpLvl))
		return
	end
	self:RemoveRightUI()
	g_i3k_ui_mgr:CloseUI(eUIID_EquipTemper)
	g_i3k_logic:OpenEquipStarUpUI()
end
function wnd_equip_temper:xqBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.inlayLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(127, i3k_db_common.functionOpen.inlayLvl))
		return
	end
	self:RemoveRightUI()
	g_i3k_ui_mgr:CloseUI(eUIID_EquipTemper)
	g_i3k_logic:OpenEquipGemInlayUI()
end

function wnd_equip_temper:qhBtn(sender)
	self:RemoveRightUI()
	g_i3k_ui_mgr:CloseUI(eUIID_EquipTemper)
	g_i3k_logic:OpenStrengEquipUI()
end

function wnd_equip_temper:onCloseBtn(sender)
	local tempQianChuiProps = g_i3k_game_context:GetTempEquipQianChuiProps() --临时的千锤属性
	local partID = self.partID
	if tempQianChuiProps and next(tempQianChuiProps) then
		g_i3k_ui_mgr:ShowCustomMessageBox2("保留","不保留","是否保留千锤的结果？",function(bValue)
			if bValue then
				local wEquips = g_i3k_game_context:GetWearEquips()
				local equip_id = wEquips[partID].equip.equip_id
				local guid = wEquips[partID].equip.equip_guid
				if g_i3k_game_context:checkTempPropsAllIncOrDec(partID) == ALL_PROP_DECREASE then
					g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17407), function(bValue)
						if bValue then
							i3k_sbean.equip_hammer_save(equip_id, guid, partID, true)
						end
					end)
				else
					i3k_sbean.equip_hammer_save(equip_id, guid, partID, true)
				end
			else
				g_i3k_game_context:ClearTempEquipProps()
				self:onCloseUI()
			end
		end)
	else
		self:onCloseUI()
	end
	g_i3k_game_context:ResetDefaultTemperSelectEquip()
end

function wnd_equip_temper:onBaiLianBtn(sender)
	local tempQianChuiProps = g_i3k_game_context:GetTempEquipQianChuiProps() --临时的千锤属性
	local partID = self.partID
	if tempQianChuiProps and next(tempQianChuiProps) then
		g_i3k_ui_mgr:ShowCustomMessageBox2("保留","不保留","是否保留千锤的结果？",function(bValue)
			if bValue then
				local wEquips = g_i3k_game_context:GetWearEquips()
				local equip_id = wEquips[partID].equip.equip_id
				local guid = wEquips[partID].equip.equip_guid
				if g_i3k_game_context:checkTempPropsAllIncOrDec(partID) == ALL_PROP_DECREASE then
					g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17407), function(bValue)
						if bValue then
							i3k_sbean.equip_hammer_save(equip_id, guid, partID)
						else
							g_i3k_game_context:ClearTempEquipProps()
						end
						g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperWash)
						g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperWash, self.partID)
						self:refresh()
					end)
				else
					i3k_sbean.equip_hammer_save(equip_id, guid, partID)
					g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperWash)
					g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperWash, self.partID)
					self:refresh()
				end
			else
				g_i3k_game_context:ClearTempEquipProps()
				self:refresh()
				g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperWash)
				g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperWash, self.partID)
			end
		end)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTemperWash)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperWash, self.partID)
	end
end

function wnd_equip_temper:onUnlockBtnClick(sender, partID)
	if self.isMaterialEnough then
		local wEquips = g_i3k_game_context:GetWearEquips()
		local equip_id = wEquips[partID].equip.equip_id
		local guid = wEquips[partID].equip.equip_guid
		i3k_sbean.equip_smelting_unlock(equip_id, guid, partID)
	else
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法解锁")
	end
end
---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_equip_temper.new()
	wnd:create(layout)
	return wnd
end
