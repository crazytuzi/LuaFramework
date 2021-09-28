-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_meridian = i3k_class("wnd_meridian",ui.wnd_base)
local Item = "ui/widgets/jingmait"
local Pulse = "ui/widgets/jingmait2"
local Meridian = "ui/widgets/jingmait3"
local pulseType1 = 1;--成功几率
local pulseType2 = 2;--影响参数
local pulseType3 = 3;--效果加成

local Point1 = 1;--穴位1
local Point2 = 2;--穴位2
local Point3 = 3;--穴位3
local Point4 = 4;--穴位4
local Point5 = 5;--穴位5

function wnd_meridian:ctor()
	self._selectPos = 1 -- 默认选中第一个部位
	self._meridians = nil;
	self._pulse = {};
	self._effectsTime = 0;
	self._isEffects = false;
	self._addEnergy = {};
	self._addNum = {};
	self._anis = {};
	self._isPaly1 = true;
	self._isPaly2 = true;
	self._isPaly3 = true;
	self._isPaly4 = true;
	self._isPaly5 = true;
	self._pulseValue = 0;
	self._isHideValue = false;
	self._isHideValueTime = 0;
	self._buffAdd = {}
	self._gasSea = 0
end

function wnd_meridian:configure(...)
	local widgets		= self._layout.vars
	self.shockBtn		= widgets.shockBtn;
	self.meridian_btn	= widgets.meridian_btn;
	self.xinfa_btn		= widgets.xinfa_btn;
	self.skill_btn		= widgets.skill_btn;
	self.pulseScroll	= widgets.pulseScroll;
	self.meridianScroll	= widgets.meridianScroll;
	self.itemScroll		= widgets.itemScroll;
	self.red_point_1 	= widgets.red_point_1
	self.red_point_2 	= widgets.red_point_2
	self.red_point_3 	= widgets.red_point_3
	self.red_point_4	= widgets.red_point_4
	self.evaluate		= widgets.evaluate;
	self.potentialRed	= widgets.potentialRed;
	self.continuousBtn	= widgets.continuousBtn;
	self.c_cx			= self._layout.anis.c_cx;

	self.meridian_btn:stateToPressed()
	self.xinfa_btn:stateToNormal()
	self.skill_btn:stateToNormal()
	widgets.skill_btn:onClick(self, self.onSkillBtn)
	self.xinfa_btn:onClick(self, self.onXinfaBtn)
	widgets.help_btn:onClick(self,self.onHelp)
	widgets.resetBtn:onClick(self,self.OnReset)
	widgets.potentialBtn:onClick(self,self.onPotentialBtn)
	widgets.continuousBtn:onClick(self,self.onContinuousShockBtn)
	widgets.shockBtn:onClick(self,self.onShockBtn)
	widgets.propertyBtn:onClick(self, self.onPropertyBtn)
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.wujue:onClick(self, self.onWujueBtn)
	widgets.wujue:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_wujue.showLevel)
end

function wnd_meridian:refresh(meridians)
	self:updateData(meridians)
	self:updateMeridianScroll();
	self:updatePulseDtate();
end

function wnd_meridian:updatePulseDtate()
	self:updatePulseScroll()
	self:AcupuncturePoint()
	self:calculatePulse()
	self:PotentiaRed()
	self:setMeridianPotentialScroll()
	self:updateItemScroll();
end

function wnd_meridian:updateData(meridians)
	self.red_point_3:hide();
	local timeNow = i3k_game_get_time()
	self._meridians = meridians;
	self:PotentiaRed()
	g_i3k_game_context:SetIsMeridianRed(timeNow)
	self.red_point_1:setVisible(g_i3k_game_context:isShowXinfaRedPoint())
	self.red_point_2:setVisible(g_i3k_game_context:isShowSkillRedPoint() or g_i3k_game_context:isShowUniqueSkillRedPoint())
	self.red_point_4:setVisible(g_i3k_game_context:isShowWujueRedPoint())
end

function wnd_meridian:updateItemScroll()
	if not self:isMax() then
		return
	end
	local item = i3k_db_meridians.common.dashItem;
	self.itemScroll:removeAllChildren()
	for _, e in ipairs(item) do
		if e.id > 0 then
			local node = require(Item)()
			local widget = node.vars
			widget.lock:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(e.id))	--jiasuo
			local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.id))
			widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.id,i3k_game_context:IsFemaleRole()))
			widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.id))
			if e.id == g_BASE_ITEM_DIAMOND or e.id == g_BASE_ITEM_COIN then
				widget.num:setText(e.count)
			else
				widget.num:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.id) .."/".. e.count)
			end
			local color = g_i3k_get_hl_green_color();
			if g_i3k_game_context:GetCommonItemCanUseCount(e.id) < e.count then
				color = g_i3k_get_hl_red_color();
			end
			widget.num:setTextColor(color)
			widget.btn:onClick(self, self.onItemTips, e.id);
			self.itemScroll:addItem(node)
		end
	end
end

function wnd_meridian:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_meridian:updateMeridianScroll()
	self.meridianScroll:removeAllChildren()
	self.meridianScroll:setBounceEnabled(false)
	if self._meridians then
		local meridian = i3k_db_meridians.meridians
		for i, e in ipairs(self._meridians) do
			local isShowMeridian = true
			local geaSea = 0
			local premiseID = meridian[i].premiseID
			if premiseID ~= 0 then
				geaSea = g_i3k_db.i3k_db_get_geasea_from_meridianID(premiseID, self._meridians[premiseID].holes)
				isShowMeridian = geaSea >= meridian[i].showNeedNum
			end
			if isShowMeridian then
				local node = require(Meridian)()
				local widget = node.vars
				widget.borderIcon:setVisible(self._selectPos == i)
				local iconID = self._selectPos == i and meridian[i].icon1 or meridian[i].icon
				local isUnlock = true
				if premiseID ~= 0 and geaSea < meridian[i].unlockNeedNum then
					isUnlock = false
				end
				widget.skill_btn:setTag(i)
				widget.skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
				if not isUnlock then
					widget.skill_icon:disableWithChildren()
				end
				widget.skill_btn:onClick(self, self.onMeridianBtn, {id = i, isUnlock = isUnlock})
				widget.redPoint:hide()
				self.meridianScroll:addItem(node)
			end
		end
	end
end

function wnd_meridian:onMeridianBtn(sender, data)
	local i = data.id
	if not data.isUnlock then
		local cfg = i3k_db_meridians.meridians
		local premiseID = cfg[i].premiseID
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17244, cfg[premiseID].name, cfg[i].unlockNeedNum))
	end
	if i == self._selectPos then
		return
	end
	-- 清除冲穴动画
	for i = 1, 4 do
		self._layout.anis["c_fei"..i].stop()
	end
	self._selectPos = i;
	local meridian = i3k_db_meridians.meridians
	for k, v in ipairs(self.meridianScroll:getAllChildren()) do
		local meridianID = v.vars.skill_btn:getTag()
		local iconID = meridianID == i and meridian[meridianID].icon1 or meridian[meridianID].icon
		local geaSea = 0
		local premiseID = meridian[meridianID].premiseID
		if premiseID ~= 0 then
			geaSea = g_i3k_db.i3k_db_get_geasea_from_meridianID(premiseID, self._meridians[premiseID].holes)
		end
		local isUnlock = true
		if premiseID ~= 0 and geaSea < meridian[meridianID].unlockNeedNum then
			isUnlock = false
		end
		v.vars.borderIcon:setVisible(meridianID == i)
		v.vars.skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
		if not isUnlock then
			v.vars.skill_icon:disableWithChildren()
		end

	end
	self:updatePulseDtate()
end

function wnd_meridian:resetPulse(newHoles)
	if self._selectPos and newHoles then
		self._meridians[self._selectPos].holes = newHoles;
		self:updatePulseDtate()
	end
end

function wnd_meridian:updatePulseScroll()
	if self._meridians then
		local holes = self._meridians[self._selectPos].holes;
		local tbl = {};
		for k,v in pairs(holes) do
			table.insert(tbl, { id = k, buff = v.buff, energy = v.energy});
		end
		local _cmp = function(d1, d2)
			return d1.id < d2.id;
		end
		table.sort(tbl, _cmp);
		self._pulse = tbl;
		if not self:isMax() then
			return
		end
		self.pulseScroll:removeAllChildren()
		self.pulseScroll:setBounceEnabled(false)
		local children = self.pulseScroll:addChildWithCount(Pulse, 1, 5)
		local PointIds = i3k_db_meridians.meridians[self._selectPos].acupuncturePointIds;
		local point = i3k_db_meridians.acupuncturePoint;
		local pulse = i3k_db_meridians.pulse;
		for i,e in ipairs(tbl) do
			local widget = children[i].vars
			local pro = 0;
			for k,v in ipairs(e.buff) do
				if pulse[v].pulseType ~= 0 then
					if pulse[v].pulseType == pulseType1 or  pulse[v].pulseType == pulseType3 then
						if pulse[v].pulseType == pulseType1 then
							pro = pulse[v].value;
						end
						widget["value"..k]:setText((pulse[v].value / 100).."%")
					else
						widget["value"..k]:hide();
					end
					widget["des"..k]:setText(pulse[v].name)
					widget["bg"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(pulse[v].rankIcon))
					widget["icon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(pulse[v].icon))
					widget["btn"..k]:onClick(self, self.onPulseBtn, pulse[v])
				else
					widget["des"..k]:hide()
					widget["bg"..k]:hide()
					widget["icon"..k]:hide()
					widget["value"..k]:hide();
				end
			end
			widget.des:setText("突破率: "..((point[e.id].probability + pro) /100).."%")
			widget.name:setText(point[e.id].name);
		end
	end
end

function wnd_meridian:onPulseBtn(sender, pulse)
	if not g_i3k_ui_mgr:GetUI(eUIID_MeridianPulse) then
		g_i3k_ui_mgr:OpenUI(eUIID_MeridianPulse)
		g_i3k_ui_mgr:RefreshUI(eUIID_MeridianPulse, pulse)
	end
end

function wnd_meridian:AcupuncturePoint()
	if self._pulse then
		local point = i3k_db_meridians.acupuncturePoint;
		local pulse = i3k_db_meridians.pulse;
		local meridians = i3k_db_meridians.meridians
		local bgIconID = meridians[self._selectPos].bgIconID
		self._layout.vars.bgImage:setImage(g_i3k_db.i3k_db_get_icon_path(bgIconID))
		for i,e in ipairs(self._pulse) do
			self._layout.vars["name"..i]:setText(point[e.id].name);
			self._layout.vars["bar"..i]:setPercent(e.energy / point[e.id].upperLimit * 100)
			self._layout.vars["value"..i]:setText(e.energy)
			self._layout.vars["addValue"..i]:hide();
			self._layout.vars["max"..i]:setVisible(e.energy == point[e.id].upperLimit)
		end
	end
end

function wnd_meridian:onUpdate(dTime)
	if self._isEffects and self._addEnergy then
		self._effectsTime = self._effectsTime + dTime;
		local point = i3k_db_meridians.acupuncturePoint;
		if self._effectsTime > 2.2 then
			self:clsEffects();
		end
		if self._effectsTime > 0 and self._isPaly1 then
			if self._addNum[Point2] then
				self._layout.anis.c_fei1.play();
			end
			if self._addNum[Point1] and self._addNum[Point1] > 0 then
				self._layout.anis.c_cg1.play();
				self._layout.vars.bar1:setPercent(self._pulse[Point1].energy / point[Point1].upperLimit * 100)
				self._layout.vars.value1:setText(self._pulse[Point1].energy)
				if self._pulse[Point1].energy < point[Point1].upperLimit then
					self._layout.vars.addValue1:show():setText("+"..self._addNum[Point1].."( +"..self._buffAdd[Point1]..")")
				else
					self._layout.vars.addValue1:show():setText("+"..0)
				end
			else
				self._layout.anis.c_sb1.play();
			end
			if Point1 == #self._addEnergy then
				self:clsEffects();
			end
			self._isPaly1 = false;
		elseif self._effectsTime > 0.5 and self._isPaly2 then
			if self._addNum[Point3] then
				self._layout.anis.c_fei2.play();
			end
			if self._addNum[Point2] and self._addNum[Point2] > 0 then
				self._layout.anis.c_cg2.play();
				self._layout.vars.bar2:setPercent(self._pulse[Point2].energy / point[Point2].upperLimit * 100)
				self._layout.vars.value2:setText(self._pulse[Point2].energy)
				if self._pulse[Point2].energy < point[Point2].upperLimit then
					self._layout.vars.addValue2:show():setText("+"..self._addNum[Point2].."( +"..self._buffAdd[Point2]..")")
				else
					self._layout.vars.addValue2:show():setText("+"..0)
				end
			else
				self._layout.anis.c_sb2.play();
			end
			if Point2 == #self._addEnergy then
				self:clsEffects();
			end
			self._isPaly2 = false;
		elseif self._effectsTime > 1 and self._isPaly3 then
			if self._addNum[Point4] then
				self._layout.anis.c_fei3.play();
			end
			if self._addNum[Point3] and self._addNum[Point3] > 0 then
				self._layout.anis.c_cg3.play();
				self._layout.vars.bar3:setPercent(self._pulse[Point3].energy / point[Point3].upperLimit * 100)
				self._layout.vars.value3:setText(self._pulse[Point3].energy)
				if self._pulse[Point3].energy < point[Point3].upperLimit then
					self._layout.vars.addValue3:show():setText("+"..self._addNum[Point3].."( +"..self._buffAdd[Point3]..")")
				else
					self._layout.vars.addValue3:show():setText("+"..0)
				end
			else
				self._layout.anis.c_sb3.play();
			end
			if Point3 == #self._addEnergy then
				self:clsEffects();
			end
			self._isPaly3 = false;
		elseif self._effectsTime > 1.5 and self._isPaly4 then
			if self._addNum[Point5] then
				self._layout.anis.c_fei4.play();
			end
			if self._addNum[Point4] and self._addNum[Point4] > 0 then
				self._layout.anis.c_cg4.play();
				self._layout.vars.bar4:setPercent(self._pulse[Point4].energy / point[Point4].upperLimit * 100)
				self._layout.vars.value4:setText(self._pulse[Point4].energy)
				if self._pulse[Point4].energy < point[Point4].upperLimit then
					self._layout.vars.addValue4:show():setText("+"..self._addNum[Point4].."( +"..self._buffAdd[Point4]..")")
				else
					self._layout.vars.addValue4:show():setText("+"..0)
				end
			else
				self._layout.anis.c_sb4.play();
			end
			if Point4 == #self._addEnergy then
				self:clsEffects();
			end
			self._isPaly4 = false;
		elseif self._effectsTime > 2 and self._isPaly5 then
			if self._addNum[Point5] and self._addNum[Point5] > 0 then
				self._layout.anis.c_cg5.play();
				self._layout.vars.bar5:setPercent(self._pulse[Point5].energy / point[Point5].upperLimit * 100)
				self._layout.vars.value5:setText(self._pulse[Point5].energy)
				if self._pulse[Point5].energy < point[Point5].upperLimit then
					self._layout.vars.addValue5:show():setText("+"..self._addNum[Point5].."( +"..self._buffAdd[Point5]..")")
				else
					self._layout.vars.addValue5:show():setText("+"..0)
				end
			else
				self._layout.anis.c_sb5.play();
			end
			if Point4 == #self._addEnergy then
				self:clsEffects();
			end
			self._isPaly5 = false;
		end
	end
	if self._isHideValue then
		self._isHideValueTime = self._isHideValueTime + dTime;
		if self._isHideValueTime > 0.5 then
			for i,e in ipairs(self._addEnergy) do
				self._layout.vars["addValue"..i]:hide();
			end
			self._isHideValueTime = 0
			self._isHideValue = false;
		end
	end
end

function wnd_meridian:clsEffects()
	self._effectsTime = 0;
	self._isEffects = false;
	self._addEnergy = {};
	self._addNum = {};
	self._buffAdd = {}
	for i = 1,5 do
		self._layout.vars["addValue"..i]:hide();
	end
end

function wnd_meridian:HideXian()
	self._isPaly1 = true;
	self._isPaly2 = true;
	self._isPaly3 = true;
	self._isPaly4 = true;
	self._isPaly5 = true;
	for i = 1,5 do
		self._layout.anis["c_sb"..i].stop();
		self._layout.anis["c_cg"..i].stop();
	end
	for i = 1,4 do
		self._layout.anis["c_fei"..i].stop();
	end
end

function wnd_meridian:updatePoint(addEnergy, isMuti)
	if addEnergy then
		local point = i3k_db_meridians.acupuncturePoint;
		self._addEnergy = addEnergy;
		for i,e in ipairs(addEnergy) do
			self._addNum[i] = e.add + e.buffAdd;
			self._buffAdd[i] = e.buffAdd;
			if self._pulse[i].energy < point[i].upperLimit then
				local energy = self._pulse[i].energy + e.add + e.buffAdd;
				self._pulse[i].energy = energy
				if energy > point[i].upperLimit then
					self._pulse[i].energy = point[i].upperLimit
				end
				if self._meridians and self._selectPos then
					local PointIds = i3k_db_meridians.meridians[self._selectPos].acupuncturePointIds;
					self._meridians[self._selectPos].holes[PointIds[i]].energy = self._pulse[i].energy;
				end
			end
		end
		if isMuti then
			self:SetPiontValue();
		else
			self:SetPointMax()
			self._isEffects = true;
		end
	end
end

function wnd_meridian:SetPiontValue()
	local point = i3k_db_meridians.acupuncturePoint;
	self.c_cx.play();
	for i,e in ipairs(self._addEnergy) do
		if self._pulse[i] then
			self._layout.vars["value"..i]:setText(self._pulse[i].energy)
			if self._pulse[i].energy < point[i].upperLimit then
				if self._addNum[i] and self._addNum[i] > 0 then
					self._layout.vars["addValue"..i]:show():setText("+"..self._addNum[i].."( +"..self._buffAdd[i]..")")
					self._layout.anis["c_cg"..i].play();
				else
					self._layout.vars["addValue"..i]:hide();
					self._layout.anis["c_sb"..i].play();
				end
			else
				self._layout.vars["addValue"..i]:show():setText("+"..0)
				self._layout.anis["c_cg"..i].play();
			end
			self._layout.vars["bar"..i]:setPercent(self._pulse[i].energy / point[i].upperLimit * 100)
			self._layout.vars["max"..i]:setVisible(self._pulse[i].energy==point[i].upperLimit) --更新
		end
	end
	self._isHideValue = true;
end

function wnd_meridian:SetPointMax()
	local point = i3k_db_meridians.acupuncturePoint;
	for i,e in ipairs(self._addEnergy) do
		if self._pulse[i] then
			self._layout.vars["max"..i]:setVisible(self._pulse[i].energy==point[i].upperLimit)
		end
	end
end

function wnd_meridian:calculatePulse()
	if self._pulse then
		local point = i3k_db_meridians.acupuncturePoint;
		local pulse = i3k_db_meridians.pulse;
		local pro = {}
		for i,e in ipairs(self._pulse) do
			local pro1 = point[e.id].probability / 10000;
			local pro2 = 1;
			local pro3 = 0;
			for k,v in ipairs(e.buff) do
				if pulse[v].pulseType == pulseType1 then
					pro1 = pro1 + (pulse[v].value / 10000);
				end
				if pulse[v].pulseType == pulseType2 then
					pro2 = pulse[v].value;
				end
				if pulse[v].pulseType == pulseType3 then
					pro3 = pulse[v].value  / 10000;
				end
			end
			table.insert(pro, {pro1 = pro1, pro2 = pro2, pro3 = pro3});
		end
		local k = i3k_db_meridians.common.scoreFactor;
		local A = pro[1].pro1;
		local B = pro[2].pro1 * math.pow(pro[1].pro1, pro[1].pro2)
		local C = pro[3].pro1 * math.pow(pro[1].pro1, pro[1].pro2) * math.pow(pro[2].pro1, pro[2].pro2);
		local D = pro[4].pro1 * math.pow(pro[1].pro1, pro[1].pro2) * math.pow(pro[2].pro1, pro[2].pro2) * math.pow(pro[3].pro1, pro[3].pro2);
		local E = pro[5].pro1 * math.pow(pro[1].pro1, pro[1].pro2) * math.pow(pro[2].pro1, pro[2].pro2) * math.pow(pro[3].pro1, pro[3].pro2) * math.pow(pro[4].pro1, pro[4].pro2);
		local a = A * (pro[1].pro3 + 1);
		local b = B * (pro[2].pro3 + 1);
		local c = C * (pro[3].pro3 + 1);
		local d = D * (pro[4].pro3 + 1);
		local e = E * (pro[5].pro3 + 1);
		self._pulseValue = math.floor((a*b + b*c + c*d + d*e + e*a ) * 100 / k);
		self.evaluate:setText("评分："..self._pulseValue);
	end
end

function wnd_meridian:OnReset(sender)
	if not g_i3k_ui_mgr:GetUI(eUIID_MeridianResetPulse) then
		g_i3k_ui_mgr:OpenUI(eUIID_MeridianResetPulse)
		g_i3k_ui_mgr:RefreshUI(eUIID_MeridianResetPulse, self._selectPos, self._pulseValue)
	end
end

function wnd_meridian:onCloseUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSkillNotice")
	g_i3k_ui_mgr:CloseUI(eUIID_Meridian)
end

function wnd_meridian:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16884))
end

function wnd_meridian:onPotentialBtn(sender)
	if self._meridians and self._selectPos then
		g_i3k_ui_mgr:OpenUI(eUIID_MeridianPotential)
		g_i3k_ui_mgr:RefreshUI(eUIID_MeridianPotential, self._selectPos, self._meridians[self._selectPos])
	end
end

function wnd_meridian:onPropertyBtn(sender)
	if self._meridians and self._selectPos then
		g_i3k_ui_mgr:OpenUI(eUIID_MeridianProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_MeridianProperty)
	end
end

function wnd_meridian:isCanUpLvl(nextCfg, gasSea)
	if not nextCfg then
		return false
	end

	local itemEnough = true
	for i,v in ipairs(nextCfg.needItem) do
		if v.id > 0 and g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			itemEnough = false
			break
		end
	end
	return itemEnough and gasSea >= nextCfg.gasSea
end

function wnd_meridian:PotentiaRed()
	local meridansCfg = i3k_db_meridians.meridians[self._selectPos]
	local potential = g_i3k_game_context:getMeridianPotential()

	local gasSea = 0
	local holes = self._meridians[self._selectPos].holes
	local acupIds = meridansCfg.acupuncturePointIds
	for k,v in ipairs(acupIds) do
		if k == #acupIds then
			gasSea = gasSea + holes[v].energy*holes[acupIds[1]].energy
		else
			gasSea = gasSea + holes[v].energy*holes[acupIds[k + 1]].energy
		end
	end
	gasSea = math.floor( math.sqrt(gasSea) *i3k_db_meridians.common.areasFactor)
	self._gasSea = gasSea
	local isShow = false
	local potCfg = i3k_db_meridians.potentia
	for i,potId in ipairs(meridansCfg.potentialIds) do
		local lvl = potential[potId] or 0
		if self:isCanUpLvl(potCfg[potId][lvl+1],gasSea) then
			isShow = true
			break
		end
	end
	self.potentialRed:setVisible(isShow)
end

function wnd_meridian:isCanUse(item)
	local count = 0
	local items = {}
	if item then
		for _,e in ipairs(item) do
			local UseCount = g_i3k_game_context:GetCommonItemCanUseCount(e.id)
			if e.id > 0 then
				count = count + 1;
				if UseCount >= e.count then
					table.insert(items, e);
				end
			end
		end
		if count == #items then
			self._items = items;
			return true;
		end
	end
	return false;
end

function wnd_meridian:isMax()
	local point = i3k_db_meridians.acupuncturePoint;
	local count = 0;
	for i,e in ipairs(self._pulse) do
		if self._pulse[i].energy >= point[i].upperLimit then
			count = count + 1;
		end
	end
	if count == #self._pulse then
		return false;
	end
	return true;
end

function wnd_meridian:onContinuousShockBtn(sender)
	local item = i3k_db_meridians.common.continuousItem;
	if (not self._isHideValue) and (not self._isEffects) then
		if self:isCanUse(item) then
			if self:isMax() then
				i3k_sbean.dashHole(self._selectPos, self._items, 1);
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16887));
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16888));
		end
	end
end

function wnd_meridian:onShockBtn(sender)
	local item = i3k_db_meridians.common.dashItem;
	if (not self._isHideValue) and (not self._isEffects) then
		if self:isCanUse(item) then
			if self:isMax() then
				self:HideXian()
				i3k_sbean.dashHole(self._selectPos, self._items, 0);
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16887));
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16888));
		end
	end
end

function wnd_meridian:onSkillBtn(sender)
	self:onCloseUI()
	g_i3k_logic:OpenSkillLyUI()
end

function wnd_meridian:onXinfaBtn(sender)
	local openLvl = i3k_db_common.functionOpen.xinfaOpenLvl
	if g_i3k_game_context:GetLevel() < openLvl or g_i3k_game_context:GetTransformLvl() < 2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(712,openLvl))
		return
	end
	self:onCloseUI()
	g_i3k_logic:OpenXinfaUI()
end

function wnd_meridian:onWujueBtn(sender)
	g_i3k_logic:OpenWujueUI()
end

function wnd_meridian:setMeridianPotentialScroll()
	if not self:isMax() then
		self._layout.vars.potentialBtn:hide()
		self._layout.vars.propertyRoot:hide()
		self._layout.vars.maxRoot:show()
		self._layout.vars.maxVerse:setText(i3k_db_meridians.meridians[self._selectPos].verse)
		self._layout.vars.propertyScroll:removeAllChildren()
		local rankIcon = i3k_db_meridians.common.rankIcon
		local potCfg = i3k_db_meridians.potentia
		local potential = g_i3k_game_context:getMeridianPotential()
		for i, v in ipairs(i3k_db_meridians.meridians[self._selectPos].potentialIds) do
			local node = require("ui/widgets/jingmaimaxt")()
			self._layout.vars.propertyScroll:addItem(node)
		end
		self:updatePotentialScroll()
	else
		self._layout.vars.potentialBtn:show()
		self._layout.vars.propertyRoot:show()
		self._layout.vars.maxRoot:hide()
	end
end

function wnd_meridian:updatePotentialScroll()
	if not self:isMax() then
		local rankIcon = i3k_db_meridians.common.rankIcon
		local potCfg = i3k_db_meridians.potentia
		local potential = g_i3k_game_context:getMeridianPotential()
		local children = self._layout.vars.propertyScroll:getAllChildren()
		for i, v in ipairs(i3k_db_meridians.meridians[self._selectPos].potentialIds) do
			local node = children[i]
			local lvl = potential[v] or 0
			local cfg = potCfg[v][lvl]
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
			node.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(rankIcon[cfg.rank]))
			node.vars.name:setText(cfg.name)
			if lvl == 0 then
				node.vars.lvl:setText(lvl + 1)
				local ncfg = potCfg[v][lvl + 1]
				node.vars.desc:setText(ncfg.desc)
				node.vars.uplvlBtn:hide()
				node.vars.unlockBtn:show()
				node.vars.unlockBtn:onClick(self, self.onUnlockPotential, v)
				if ncfg.combatValue > 0 then
					node.vars.specialIcon:hide()
					node.vars.power:setText(ncfg.combatValue)
				else
					node.vars.power:hide()
				end
			else
				node.vars.lvl:setText(lvl)
				node.vars.desc:setText(cfg.desc)
				node.vars.unlockBtn:hide()
				if cfg.combatValue > 0 then
					node.vars.specialIcon:hide()
					node.vars.power:setText(cfg.combatValue)
				else
					node.vars.power:hide()
				end
				if not potCfg[v][lvl+1] then
					node.vars.uplvlBtn:hide()
					node.vars.maxIcon:show()
				else
					node.vars.uplvlBtn:show()
					node.vars.uplvlBtn:onClick(self, self.onUnlockPotential, v)
				end
			end
			node.vars.uplvlRed:setVisible(self:isCanUpLvl(potCfg[v][lvl+1], self._gasSea))
			node.vars.unlockRed:setVisible(self:isCanUpLvl(potCfg[v][lvl+1], self._gasSea))
		end
	end
end

function wnd_meridian:onUnlockPotential(sender, id)
	local currlvl = g_i3k_game_context:getMeridianPotentialLvl(id)
	if not i3k_db_meridians.potentia[id][currlvl + 1] then
		return g_i3k_ui_mgr:PopupTipMessage("您已经达到最高级")
	end
	g_i3k_ui_mgr:OpenUI(eUIID_MeridianPotentialUp)
	g_i3k_ui_mgr:RefreshUI(eUIID_MeridianPotentialUp, self._selectPos, id, self._gasSea)
end

function wnd_create(layout)
	local wnd = wnd_meridian.new()
	wnd:create(layout)
	return wnd
end
