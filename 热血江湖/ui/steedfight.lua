-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/steedBase");

-------------------------------------------------------
wnd_steedFight = i3k_class("wnd_steedFight", ui.wnd_steedBase)

local PROP = "ui/widgets/zqqzt"

local CANACTIVE = 5425;
local ACTIVE = 5426;
local Color1 = "ffcdbaff"
local Color2 = "ffd14602"
local OutlineColor1 = "ff573525"
local OutlineColor2 = "fffff070"
local prop1 = 1;
local prop2 = 2;

function wnd_steedFight:ctor()
	self._item = {}
	self._lvl = nil;
	self._exp = nil;
	self._needExp = nil;
	self._upLvlItem = {}
	self._canUse = true
	self._showType = 0
end

function wnd_steedFight:configure()
	-- 重写父类
	ui.wnd_steedBase.configure(self)
	local widgets 		= self._layout.vars;
	self.scroll 		= widgets.scroll
	self.steed_point 	= widgets.steed_point
	self.steedSkinPoint = widgets.steedSkinPoint
	self.fightRedPoint	= widgets.fightRedPoint
	self.enhanceRed		= widgets.enhanceRed
	self.spiritRed		= widgets.spiritRed
	-- self.newSpiritRed   = widgets.newSpiritRed
	self.curLvl			= widgets.curLvl;
	self.expValue		= widgets.expValue;
	self.topText		= widgets.topText;
	self.expBar			= widgets.expBar;
	self.showText		= widgets.showText;
	self.propBtn		= widgets.propBtn;
	self.typeButton		= {widgets.masterBtn, widgets.spiritBtn, widgets.equipBtn}
	self.typeButton[1]:stateToPressed(true)
	for i, e in ipairs(self.typeButton) do
		e:onClick(self, self.onShowTypeChanged, i)
	end
	widgets.upLvlBtn:onClick(self, self.onUpLvlBtn)
	widgets.propBtn:onClick(self, self.onPropBtn);

	self:initItem(widgets)

	self.masterRoot = widgets.masterRoot
	-- self.spiritRoot = widgets.spiritRoot

end

function wnd_steedFight:initItem(widgets)
	for i = 1, 3 do
		self._item[i] = {
			item_bg = widgets["item_bg"..i],
			item_btn = widgets["item_btn"..i],
			item_icon = widgets["item_icon"..i],
			item_value = widgets["item_value"..i],
			item_count = widgets["item_count"..i]
		}
	end
end

function wnd_steedFight:initSpiritStar(widgets)
	local starNodes = {}
	for i = 1, i3k_db_steed_fight_base.rankStarCount do
		starNodes[i] = widgets["starIcon"..i]
	end
	return starNodes
end

function wnd_steedFight:initSpiritSkillWidget(widgets)
	local skillNodes = {}
	for i = 1, 2 do
		skillNodes[i] = {
			skillIcon = widgets["skillIcon"..i],
			skillBtn = widgets["skillBtn"..i],
			skillName = widgets["skillName"..i],
			skillLvl = widgets["skillLvl"..i],
			skillFlicker = widgets["skillFlicker"..i], -- 闪烁
			skillRed = widgets["skillRed"..i],
		}
	end
	return skillNodes
end

function wnd_steedFight:refresh(state)
	local defaultState = STEED_MASTER_STATE -- 默认打开马术精通
	-- if g_i3k_game_context:getIsUnlockSteedSpirit() then -- 达到良驹之灵开启等级默认打开良驹之灵
	-- 	-- defaultState = STEED_SPIRIT_STATE
	-- 	self:changeToSprite()
	-- end
	self:onTypeChanged(state or defaultState)
	self:updateSteedRed() -- @Override
end


function wnd_steedFight:onPropBtn(sender)
	local property = g_i3k_game_context:getSteedFightProperty()
	if next(property) ~= nil then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedFightProp);
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedFightProp, property);
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1268))
	end
end

function wnd_steedFight:updateTypeBtnState()
	for i, e in ipairs(self.typeButton) do
		e:stateToNormal(true)
	end
	self.typeButton[self._showType]:stateToPressed(true)
end

function wnd_steedFight:onShowTypeChanged(sender, showType)
	self:onTypeChanged(showType)
end

function wnd_steedFight:changeToSprite()
	g_i3k_logic:OpenSteedSpriteUI()
end


function wnd_steedFight:onTypeChanged(showType)
	if self._showType ~= showType then
		if showType == STEED_EQUIP_STATE then --骑战装备未开启
			return g_i3k_logic:OpenSteedEquipUI()
		end
		if showType == STEED_MASTER_STATE then
			self._showType = STEED_MASTER_STATE
			self:loadSteedMasterInfo()
		elseif showType == STEED_SPIRIT_STATE then
			if g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.spiritOpenLvl then
				self._showType = STEED_SPIRIT_STATE
				-- self:loadSteedSpiritInfo() -- TODO
				self:changeToSprite()
				return;
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1279, i3k_db_steed_fight_base.spiritOpenLvl))
			end
		end
		-- 如果关闭了ui，那么下面的方法也就找不到了，会崩溃
		self:updateWidgetRoot()
		self:updateTypeBtnState()
		self:UpdateSteedRed()
	end
end

function wnd_steedFight:updateWidgetRoot()
	self.masterRoot:setVisible(self._showType == STEED_MASTER_STATE)
	-- self.spiritRoot:setVisible(self._showType == STEED_SPIRIT_STATE)
end

function  wnd_steedFight:loadSteedMasterInfo()
	self:updateExp()
	self:updateScroll()
	self:updateItem()
end

function wnd_steedFight:updateExp()
	self.topText:setText(i3k_get_string(1265))
	self._lvl = g_i3k_game_context:getSteedFightLevel()
	self._exp = g_i3k_game_context:getSteedFightExp()
	if self._lvl > 0 then
		self.curLvl:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_steed_fight_up_prop[self._lvl].iconBg))
	else
		self.curLvl:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_steed_fight_base.iconNumBg))
	end
	if not g_i3k_game_context:fightSteedIsMaxLvl() then
		self._needExp = i3k_db_steed_fight_up_prop[self._lvl + 1].needExp;
		self.expValue:setText(self._exp.."/"..self._needExp)
		self.expBar:setPercent(self._exp / self._needExp * 100)
	else
		self._needExp = i3k_db_steed_fight_up_prop[self._lvl].needExp;
		self.showText:setText(i3k_get_string(948))
		self.expValue:setText(i3k_get_string(948))
		self.expBar:setPercent(self._needExp / self._needExp * 100)
	end
end

function wnd_steedFight:isShowFree(lvl, isCanUp)
	local child = self.scroll:getChildAtIndex(lvl);
	if child and child.vars then 
		child.vars.number:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_steed_fight_up_prop[lvl].iconBg))
		for i = 1 ,3 do
			if isCanUp then
				self.scroll:jumpToChildWithIndex(lvl);
				child.vars["btn"..i]:enable()
			end
			local isUnLock = g_i3k_game_context:isUnLocksByIndex(lvl, i)
			local bgIcon = isUnLock and ACTIVE or CANACTIVE
			local outlineColor = isUnLock and OutlineColor2 or OutlineColor1
			local color = isUnLock and Color2 or Color1
			self:chageTextColor(i, child.vars, color, outlineColor)
			child.vars["bg"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(bgIcon))
			child.vars["free"..i]:setVisible(not g_i3k_game_context:isHavaUnLocks(lvl))
		end
		self:fightSteedRed()
	end
end

function wnd_steedFight:updateItem()
	if self._showType == STEED_MASTER_STATE then
		if not g_i3k_game_context:fightSteedIsMaxLvl() then
			self._upLvlItem = i3k_db_steed_fight_up_prop[self._lvl + 1].upLvlItem;
		else
			self._upLvlItem = i3k_db_steed_fight_up_prop[self._lvl].upLvlItem;
		end

		for i,e in ipairs(self._upLvlItem) do
			local count = g_i3k_game_context:GetCommonItemCount(e)
			local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(e)
			local tmp_cfg = g_i3k_db.i3k_db_get_common_item_cfg(e)
			local itemId = count > 0 and e or -e
			self._item[i].item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e))
			self._item[i].item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e,i3k_game_context:IsFemaleRole()))
			self._item[i].item_value:setText("x"..itemCount)
			self._item[i].item_count:setText("+"..tmp_cfg.args1)
			self._item[i].item_btn:onTouchEvent(self, self.onUseItem, {itemid = itemId, count = itemCount})--长按按钮
		end
	end
end

function wnd_steedFight:setCanUse(canUse)
	self._canUse = canUse
end

function wnd_steedFight:onUseItem(sender, eventType, data)
	if not g_i3k_game_context:fightSteedIsMaxLvl()then
		self.needId = data.itemid
		local itemid = data.itemid
		if eventType == ccui.TouchEventType.began then
			if data.count == 0 then
				g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
				return
			end
			self:onUpLevelPet()
			self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
				while true do
					g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
					if g_i3k_game_context:GetCommonItemCanUseCount(itemid) <=0 then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1239))
						return false
					end
					if self._canUse then
						self:onUpLevelPet()
						self._canUse = false
					end
				end
			end)
		elseif eventType == ccui.TouchEventType.ended then
			g_i3k_coroutine_mgr:StopCoroutine(self.co)
		elseif eventType==ccui.TouchEventType.canceled then
			g_i3k_coroutine_mgr:StopCoroutine(self.co)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1280))
	end
end

function wnd_steedFight:onUpLevelPet()
	if not g_i3k_game_context:fightSteedIsMaxLvl()then
		local itemid = self.needId
		if g_i3k_game_context:GetCommonItemCanUseCount(itemid) <= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1239))
			return false
		end
		local total_exp = g_i3k_db.i3k_db_get_common_item_cfg(itemid).args1
		local up_lvl = self._lvl
		local is_ok2 = false
		local need_exp = 0
		local uplvl_cfg = self._needExp;
		while uplvl_cfg do
			need_exp = uplvl_cfg + need_exp
			if need_exp > self._exp + total_exp then
				need_exp = need_exp - uplvl_cfg
				break
			else
				if not g_i3k_game_context:fightSteedIsMaxLvl() then
					up_lvl = up_lvl + 1
					uplvl_cfg = i3k_db_steed_fight_up_prop[up_lvl+1].needExp
					if up_lvl == #i3k_db_steed_fight_up_prop then
						is_ok2 = true
						break
					end
				end	
			end
		end
		local last_exp = self._exp + total_exp - need_exp
		if is_ok2 then
			local new_uplvl_cfg = i3k_db_steed_fight_up_prop[up_lvl+1].needExp
			if last_exp > new_uplvl_cfg then
				last_exp = new_uplvl_cfg -1
			end
		end
		local temp_count = 1
		local temp = {}
		temp[itemid] = temp_count
		local isUpLvl = false;
		if up_lvl ~= self._lvl and not g_i3k_game_context:fightSteedIsMaxLvl() then
			isUpLvl = true
		end
		i3k_sbean.horse_master_addexp(temp, up_lvl, last_exp, isUpLvl)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1280))
	end
end

function wnd_steedFight:onUpLvlBtn(sender)
	local itemExp = 0
	local last_exp = 0
	local temp = {}
	local isCanUp = false;
	if not g_i3k_game_context:fightSteedIsMaxLvl()then
		if self._needExp > self._exp then
			local left_exp = self._needExp - self._exp;
			for i,e in ipairs(self._upLvlItem) do
				local item_cfg = g_i3k_db.i3k_db_get_common_item_cfg(e).args1
				local num = math.ceil((left_exp - last_exp) / item_cfg);
				local count = g_i3k_game_context:GetCommonItemCanUseCount(e)
				local itemCount = g_i3k_game_context:GetCommonItemCount(e)
				local itemId = itemCount > 0 and e or -e
				if count >= num and not g_i3k_game_context:fightSteedIsMaxLvl() then
					itemExp = num * item_cfg;
					last_exp = last_exp + itemExp;
					temp[itemId] = num;
					isCanUp = true;
					break;
				else
					itemExp = count * item_cfg;
					if count ~= 0 then
						temp[itemId] = count;
					end
					last_exp = last_exp + itemExp;
				end
			end
			if next(temp) ~= nil then
				if isCanUp then
					if last_exp >= left_exp then
						last_exp = last_exp - left_exp;
					end
					i3k_sbean.horse_master_addexp(temp, self._lvl + 1, last_exp, isCanUp)
				else
					last_exp = last_exp + self._exp
					i3k_sbean.horse_master_addexp(temp, self._lvl, last_exp, isCanUp)
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1239))
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1280))
	end
end

function wnd_steedFight:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1264))
end

function wnd_steedFight:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_steedFight:UpdateSteedRed()
	self.steed_point:setVisible(g_i3k_game_context:canBetterSteed() or g_i3k_game_context:canAddBook())
	self.fightRedPoint:setVisible(g_i3k_game_context:getIsShowSteedFightRed())
	self.enhanceRed:setVisible(g_i3k_game_context:canfightSteedRed())
	self.spiritRed:setVisible(g_i3k_game_context:getIsShowSteedSpiritRed())
	-- self.newSpiritRed:setVisible(g_i3k_game_context:canUnlockNewSpirit())
	local widgets = self._layout.vars
	widgets.equipRed:setVisible(g_i3k_game_context:getSteedEquipRed())
	widgets.suitRed:setVisible(g_i3k_game_context:getSteedEquipSuitRed())
	widgets.stoveRed:setVisible(g_i3k_game_context:getSteedEquipStoveRed())
end

function wnd_steedFight:fightSteedRed()
	for i, e in ipairs(i3k_db_steed_fight_up_prop) do
		local child = self.scroll:getChildAtIndex(i);
		if child and child.vars then 
			for k,v in ipairs(e.propTb) do
				child.vars["red"..k]:setVisible(g_i3k_game_context:isShowRedByIndex(i, k))
			end
		end
	end
	self:UpdateSteedRed()
end

function wnd_steedFight:updateScroll()
	self.scroll:removeAllChildren()
	for i, e in ipairs(i3k_db_steed_fight_up_prop) do
		local node = require(PROP)()
		local widget = node.vars
		for k,v in ipairs(e.propTb) do
			widget["btn"..k]:onClick(self, self.onBtn, {lvl = i, index = k})
			widget["prop"..k]:setVisible(v[prop1].propID > 0);
			widget["value"..k]:setVisible(v[prop1].propID > 0);
			if v[prop1].propID > 0 then
				widget["prop"..k]:setText(g_i3k_db.i3k_db_get_property_name(v[prop1].propID))
				widget["value"..k]:setText("+"..i3k_get_prop_show(v[prop1].propID, v[prop1].propValue))
			end
			widget["text"..k]:setVisible(v[prop2].propID > 0)
			widget["count"..k]:setVisible(v[prop2].propID > 0)
			if v[prop2].propID > 0 then
				widget["text"..k]:setText(g_i3k_db.i3k_db_get_property_name(v[prop2].propID))
				widget["count"..k]:setText("+"..i3k_get_prop_show(v[prop2].propID, v[prop2].propValue))
			end
			widget["red"..k]:setVisible(g_i3k_game_context:isShowRedByIndex(i, k))
			if i <= self._lvl then
				widget["btn"..k]:enable()
				local isUnLock = g_i3k_game_context:isUnLocksByIndex(i, k)
				local bgIcon = isUnLock and ACTIVE or CANACTIVE
				local outlineColor = isUnLock and OutlineColor2 or OutlineColor1
				local color = isUnLock and Color2 or Color1
				self:chageTextColor(k, widget, color, outlineColor)
				widget["bg"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(bgIcon))
			else
				widget["btn"..k]:disable()
			end
			widget.number:setImage(g_i3k_db.i3k_db_get_icon_path(i <= self._lvl and e.iconBg or e.icon))
			widget["free"..k]:setVisible(i <= self._lvl and not g_i3k_game_context:isHavaUnLocks(i))
		end
		self.scroll:addItem(node)
	end
	self.scroll:jumpToChildWithIndex(self._lvl);
end

function wnd_steedFight:chageTextColor(k, widget, Color, OutlineColor)
	widget["prop"..k]:stateToNormal(Color, OutlineColor);
	widget["value"..k]:stateToNormal(Color, OutlineColor);
	widget["text"..k]:stateToNormal(Color, OutlineColor);
	widget["count"..k]:stateToNormal(Color, OutlineColor);
end

function wnd_steedFight:onBtn(sender, arg)
	if arg.lvl <= self._lvl  then
		local masters = g_i3k_game_context:getSteedFightMasters(arg.lvl)
		if next(masters) == nil then
			local tmp_str = i3k_get_string(1259)
			local fun = (function(ok)
				if ok then
					i3k_sbean.horse_master_unlock(arg.lvl, arg.index)
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1139), i3k_get_string(1140), tmp_str, fun)
		else
			if masters and masters.unLocks and masters.unLocks[arg.index] then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1281))
			else
				g_i3k_ui_mgr:OpenUI(eUIID_SteedFightPropUnlock);
				g_i3k_ui_mgr:RefreshUI(eUIID_SteedFightPropUnlock, arg.lvl, arg.index);
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1282))
	end
end


function wnd_create(layout)
	local wnd = wnd_steedFight.new();
		wnd:create(layout);
	return wnd;
end
