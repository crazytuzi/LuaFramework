-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steed_practice = i3k_class("wnd_steed_practice", ui.wnd_base)

local MaxItemNum = 3

function wnd_steed_practice:ctor()
	self._lockAttr = {}
	self._pracNeedItemIsEnough = true
	self._lockNeedItemIsEnough = true
	self._oldPower = 0
	self._newPower = 0
	self._oldPartTable = {}
	self.needValue = {}
	self._exitJudge = false
	
	self._needItem = {}
	self.steedId = nil
	self.enhancePropNum = 0
	self.enhanceLvl = 0
	self.refineCfg = nil
	self._sortRefineCfg = nil
	self.isAllActivation = false
	self.limtiLvl = nil
	self.maxPropNum = 0
	self._info = {};
	self._showReplaceItem = false
	self._steedCfg = nil
end


function wnd_steed_practice:configure()
	local widgets = self._layout.vars
	
	local root = {}
	root.powerLabel = widgets.powerLabel
	root.powerLabel2 = widgets.powerLabel2
	root.practiceBtn = widgets.practiceBtn
	root.saveBtn = widgets.saveBtn
	root.saveBtn:onClick(self, self.saveData)
	root.saveBtn:hide()
		
	widgets.helpBtn:onTouchEvent(self, self.onTips)
	widgets.closeBtn:onClick(self, self.onClose)
	widgets.refineSet:onClick(self, self.openRefineSet)
	widgets.autoRefine:onClick(self, self.openAutoRefine)
	widgets.autoBg:onClick(self, self.closeAutoRefine)
	widgets.autobt2:onClick(self, self.onAutoRefine, i3k_db_steed_common.autoRefine.refineNums[2])
	widgets.autobt1:onClick(self, self.onAutoRefine, i3k_db_steed_common.autoRefine.refineNums[1])
	widgets.auto_close:onClick(self, self.closeAutoRefine)
	widgets.outPriew:onClick(self, self.onOutPrivew)
	
	root.attrLabelTable = {
		{root = widgets.attrRoot1, nameLabel = widgets.nameLabel1, valueLabel = widgets.attrLabel1},
		{root = widgets.attrRoot2, nameLabel = widgets.nameLabel2, valueLabel = widgets.attrLabel2},
		{root = widgets.attrRoot3, nameLabel = widgets.nameLabel3, valueLabel = widgets.attrLabel3},
		{root = widgets.attrRoot4, nameLabel = widgets.nameLabel4, valueLabel = widgets.attrLabel4},
		{root = widgets.attrRoot5, nameLabel = widgets.nameLabel5, valueLabel = widgets.attrLabel5},
	}
	root.attrLabelTableRight = {
		{root = widgets.attrRoot1L, nameLabel = widgets.nameLabel10, valueLabel = widgets.attrLabel10, frame = widgets.frame1},
		{root = widgets.attrRoot2L, nameLabel = widgets.nameLabel11, valueLabel = widgets.attrLabel11, frame = widgets.frame2},
		{root = widgets.attrRoot3L, nameLabel = widgets.nameLabel12, valueLabel = widgets.attrLabel12, frame = widgets.frame3},
		{root = widgets.attrRoot4L, nameLabel = widgets.nameLabel13, valueLabel = widgets.attrLabel13, frame = widgets.frame4},
		{root = widgets.attrRoot5L, nameLabel = widgets.nameLabel14, valueLabel = widgets.attrLabel14, frame = widgets.frame5},
	}
	root.unActivationLbl = {
		[1] = {root = widgets.unActRootL1, desc = widgets.unActLblL1},
		[2] = {root = widgets.unActRootL2, desc = widgets.unActLblL2},
	}

	root.unActivationLblRight = {
		[1] = {root = widgets.unActRootR1, },
		[2] = {root = widgets.unActRootR2, },
	}

	root.activationCost = {
		[1] = {root = widgets.actRoot1, itemBorder = widgets.actBrdImg1, itemImg = widgets.actImg1, ItemBtn = widgets.actItemBtn1, itemNum = widgets.actNum1, actBtn = widgets.actBtn1},
		[2] = {root = widgets.actRoot2, itemBorder = widgets.actBrdImg2, itemImg = widgets.actImg2, ItemBtn = widgets.actItemBtn2, itemNum = widgets.actNum2, actBtn = widgets.actBtn2},
	}

	root.lockBtn = {
		[1] = widgets.lockBtn1,
		[2] = widgets.lockBtn2,
		[3] = widgets.lockBtn3,
		[4] = widgets.lockBtn4,
		[5] = widgets.lockBtn5,
	}

	root.expInfo = {}
	root.expInfo.expLoading = widgets.expLoading
	root.expInfo.expLabel = widgets.expLabel
	root.expInfo.lvlLabel = widgets.pracLvlLabel
	root.expInfo.helpBtn = widgets.helpBtn
	root.expInfo.maxlevel = widgets.maxlevel
	
	self._widgets = root
end

function wnd_steed_practice:onShow()
	local limtiLvl = {}
	self.limtiLvl = {}
	for i , v in ipairs(i3k_steed_lvl_propLock) do
		if v.propNum > 3 then
			if not limtiLvl[v.propNum] then
				limtiLvl[v.propNum] = i
				table.insert(self.limtiLvl,{ propNum = v.propNum, lvl = i})
			end
		end
	end
end

function wnd_steed_practice:refresh(steedId, info, power)
	--self._layout.anis.c_xilian.stop()--特效
	local vars = self._layout.vars
	vars.jiantou:hide()
	local practiceTable = i3k_db_steed_cfg[steedId].practiceArg
	self.maxPropNum = #practiceTable
	local refineId = i3k_db_steed_cfg[steedId].refineId
	self.refineCfg = i3k_db_steed_practice[refineId]
	self._sortRefineCfg = i3k_db_steed_sort_practice[refineId]
	self._oldPartTable = info.enhanceAttrs
	self.steedId = steedId
	self._steedCfg = i3k_db_steed_cfg[steedId]
	
	if table.nums(self._needItem) == 0 then
		local steedCfg = self._steedCfg	
		table.insert(self._needItem, {itemId = steedCfg.practiceId1, count = steedCfg.practiceCount1})
		table.insert(self._needItem, {itemId = steedCfg.practiceId2, count = steedCfg.practiceCount2})
	end

	for i,v in pairs(self._widgets.lockBtn) do
		v:setTag(i)
		v:onClick(self, self.lockAttr, steedId)
	end
	self._widgets.practiceBtn:setTag(steedId)
	self._widgets.practiceBtn:onClick(self, self.toPractice)
	vars.btText2:setText(i3k_get_string(18151, i3k_db_steed_common.autoRefine.refineNums[2]))
	vars.btText1:setText(i3k_get_string(18151, i3k_db_steed_common.autoRefine.refineNums[1]))

	self:updateLeftProp(info.enhanceAttrs)
	self:refreshRightProp(info.enhanceAttrs)
	self:setNeedItemData()
	self:setExpData(info)
end

function wnd_steed_practice:showItemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_steed_practice:activationPropIndex(sender, hInfo)
	if g_i3k_game_context:GetCommonItemCanUseCount(hInfo.itemId) < hInfo.count then
		return g_i3k_ui_mgr:PopupTipMessage("道具不足，无法启动")
	elseif hInfo.index - hInfo.currCnt > 1 then
		return g_i3k_ui_mgr:PopupTipMessage("请先启动上一条属性")
	end
	i3k_sbean.horse_enhance_prop_unlock_req_send(hInfo.hid, hInfo.index, hInfo.itemId, hInfo.count)
end

function wnd_steed_practice:getColor(value, cfg) --new
	local ratio = (value - cfg.minValue)/(cfg.maxValue - cfg.minValue)
	if ratio >= 0 and ratio < 0.2 then
		return g_i3k_get_white_color()
	elseif ratio >= 0.2 and ratio < 0.4 then
		return g_i3k_get_green_color()
	elseif ratio >= 0.4 and ratio < 0.6 then
		return g_i3k_get_blue_color()
	elseif ratio >= 0.6 and ratio < 0.8 then
	        return g_i3k_get_purple_color()
	elseif ratio >= 0.8 and ratio < 1 then
		return g_i3k_get_orange_color()
	elseif ratio >= 1 then
		return g_i3k_get_red_color()
	end
	return g_i3k_get_white_color()
end

function wnd_steed_practice:updateAttrProp(enhanceAttrs, attrWdg) --new
	for i,v in ipairs(attrWdg) do
		if i <= #enhanceAttrs then
			v.root:show()
			local atrr = enhanceAttrs[i]
			if atrr.id > 0 then
				local attrName = i3k_db_prop_id[atrr.id].desc..": "
				v.nameLabel:setText(attrName)
				local rank = g_i3k_db.i3k_db_can_auto_refhine_quality(atrr.value, self.refineCfg[i][atrr.id])
				local color = g_i3k_get_color_by_rank(rank)
				if rank == g_RANK_VALUE_MAX then
					v.valueLabel:setText(i3k_get_prop_show(atrr.id, atrr.value).."(MAX)")
				else
					v.valueLabel:setText(i3k_get_prop_show(atrr.id, atrr.value))
				end
				v.nameLabel:setTextColor(color)
				v.valueLabel:setTextColor(color)
			else
				v.nameLabel:setText("无")
				v.valueLabel:setText("0")
				v.nameLabel:stateToNormal()
				v.valueLabel:stateToNormal()
			end
		else
			v.root:hide()
		end
	end
end

function wnd_steed_practice:updateActivation(enhanceAttrs, enhanceLvl, force)
	if self.isAllActivation then
		return
	end
	local lockCfg = i3k_steed_lvl_propLock[enhanceLvl]
	if lockCfg.propNum == self.enhancePropNum  and not force then
		return
	end
	self.enhancePropNum = lockCfg.propNum

	local wdg = self._widgets
	
	for i = 1 , #wdg.activationCost do
		local acwdg = wdg.activationCost[i]
		local unAcWdg = wdg.unActivationLbl[i]
		local unAcWdgR = wdg.unActivationLblRight[i]
		if self.maxPropNum > #enhanceAttrs then
			local lvlCfg = self.limtiLvl[i]
			if lvlCfg.propNum > #enhanceAttrs and lockCfg.propNum >= lvlCfg.propNum then
				local actCfg = i3k_db_steed_common.activePropItems[lvlCfg.propNum]
				acwdg.root:show()
				unAcWdg.root:hide()
				--unAcWdgR.root:hide()
				acwdg.itemBorder:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(actCfg.itemId))
				acwdg.itemImg:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(actCfg.itemId,i3k_game_context:IsFemaleRole()))
				acwdg.ItemBtn:onClick(self, self.showItemInfo, actCfg.itemId)
				local haveCnt = g_i3k_game_context:GetCommonItemCanUseCount(actCfg.itemId)
				if actCfg.itemId == g_BASE_ITEM_COIN then
					acwdg.itemNum:setText(actCfg.count)
				else
					acwdg.itemNum:setText(haveCnt.."/"..actCfg.count)
				end
				acwdg.itemNum:setTextColor(g_i3k_get_cond_color(haveCnt>=actCfg.count))
				acwdg.actBtn:onClick(self, self.activationPropIndex, {hid = self.steedId, index = lvlCfg.propNum, itemId = actCfg.itemId, count = actCfg.count, currCnt = #enhanceAttrs})
			elseif lvlCfg.propNum > lockCfg.propNum then
				acwdg.root:hide()
				unAcWdg.root:show()
				unAcWdgR.root:show()
				unAcWdg.desc:setText(string.format("洗练等级%s级开启",lvlCfg.lvl))
			else
				acwdg.root:hide()
				unAcWdg.root:hide()
				unAcWdgR.root:hide()
			end
		else
			acwdg.root:hide()
			unAcWdg.root:hide()
			unAcWdgR.root:hide()
			self.isAllActivation = true
		end
	end
end

function wnd_steed_practice:refreshActivationCost()
	local wdg = self._widgets
	if wdg then
		for i = 1 , #wdg.activationCost do
			local acwdg = wdg.activationCost[i]
			local lvlCfg = self.limtiLvl and self.limtiLvl[i]
			if lvlCfg then
				local actCfg = i3k_db_steed_common.activePropItems[lvlCfg.propNum]
				local haveCnt = g_i3k_game_context:GetCommonItemCanUseCount(actCfg.itemId)
				if actCfg.itemId == g_BASE_ITEM_COIN then
					acwdg.itemNum:setText(actCfg.count)
				else
					acwdg.itemNum:setText(haveCnt.."/"..actCfg.count)
				end
				acwdg.itemNum:setTextColor(g_i3k_get_cond_color(haveCnt>=actCfg.count))
			end
		end
	end
end

function wnd_steed_practice:updateLeftProp(enhanceAttrs)
	local wdg = self._widgets
	self:updateAttrProp(enhanceAttrs, wdg.attrLabelTable)
	self._oldPower = g_i3k_game_context:getSteedPower(enhanceAttrs)
	self._widgets.powerLabel:setText(self._oldPower)
	self:initRightFrame(enhanceAttrs)
end

function wnd_steed_practice:refreshRightProp(curr_enhanceAttrs)
	local propT = {}
	local newattrs = self.needValue.attrs
	for i = 1 , #curr_enhanceAttrs do
		local id = 0
		local value = 0
		if newattrs and newattrs[i] then
			id = newattrs[i].id
			value = newattrs[i].value
		end
		table.insert(propT, {id = id, value = value})
	end
	self:updateRightProp(propT)
end

function wnd_steed_practice:updateRightProp(newEnhanceAttrs)
	local wdg = self._widgets
	self:updateAttrProp(newEnhanceAttrs, wdg.attrLabelTableRight)
	self._newPower = g_i3k_game_context:getSteedPower(newEnhanceAttrs)
	self._widgets.powerLabel2:setText(self._newPower)
	self:refreshRightFrame(newEnhanceAttrs)
end

function wnd_steed_practice:setExpData(info)
	self._info = info;
	local nowExp = info.enhanceExp
	local lvlCfg = i3k_db_steed_lvl[info.id][info.enhanceLvl + 1]
	self.enhanceLvl = info.enhanceLvl
	self:updateActivation(info.enhanceAttrs, info.enhanceLvl)
	if lvlCfg  then
		self._widgets.expInfo.lvlLabel:setText(info.enhanceLvl)
		self._widgets.expInfo.expLabel:setText(nowExp.."/"..lvlCfg.practiceExp)
		self._widgets.expInfo.expLoading:setPercent(nowExp/lvlCfg.practiceExp*100)
	else
		self._widgets.expInfo.lvlLabel:setText(info.enhanceLvl)
		--self._widgets.expInfo.expLabel:setText("已满级")
		self._widgets.expInfo.expLoading:setPercent(100)
		self._widgets.expInfo.maxlevel:show()   --满级ui
		self._widgets.expInfo.expLabel:hide()
	end
end

function wnd_steed_practice:IsEnoughGoods()
	for i,v in ipairs(self._needItem) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.itemId) < v.count then
			return false
		end
	end
	return true
end

function wnd_steed_practice:addCostGoodsItem(goods)
	local item = require("ui/widgets/zqxlt")()
	item.vars.itemBorder:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(goods.itemId))
	item.vars.itemBtn:onClick(self, self.showItemInfo, goods.itemId)
	item.vars.itemImg:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(goods.itemId,i3k_game_context:IsFemaleRole()))
	item.vars.lockImg:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(goods.itemId))
	self:setCostGoodData(item, goods)
	self._layout.vars.costScroll:addItem(item)
end

function wnd_steed_practice:updateMoney()
	--有锁定且锁定消耗元宝时，更新元宝数量 cfg.lockNeedId --最开始默认的消耗id 元宝
	if self._needItem[MaxItemNum] and self._steedCfg.lockNeedId == self._needItem[MaxItemNum].itemId then
		local scroll = self._layout.vars.costScroll
		self:setCostGoodData(scroll:getChildAtIndex(MaxItemNum), self._needItem[MaxItemNum])
	end
end

function wnd_steed_practice:setCostGoodData(item, goods)
	local haveCnt = g_i3k_game_context:GetCommonItemCanUseCount(goods.itemId)
	if goods.itemId == g_BASE_ITEM_COIN then
		item.vars.itemNum:setText(goods.count)
	else
		item.vars.itemNum:setText(haveCnt.."/"..goods.count)
	end
	item.vars.itemNum:setTextColor(g_i3k_get_cond_color(haveCnt>=goods.count))
end

function wnd_steed_practice:setNeedItemData()
	local scroll = self._layout.vars.costScroll
	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)
	for i,v in ipairs(self._needItem) do
		self:addCostGoodsItem(v)
	end
end

function wnd_steed_practice:refreshNeedItemData()
	--物品使用或获得时调用此方法 ，判断锁定替代物品数量是否还够
	--self:setLockItemData(self.steedId);
	--刷新其他消耗品展示
	local cfg = self._steedCfg
	if self._needItem[MaxItemNum] and self._needItem[MaxItemNum].itemId == cfg.lockReplaceId then
		if not self:IsEnoughReplaceGoods() then
			self:setLockItemData()
		end
	end
	
	local scroll = self._layout.vars.costScroll
	for i,v in ipairs(self._needItem) do
		self:setCostGoodData(scroll:getChildAtIndex(i), v)
	end
end

function wnd_steed_practice:lockAttr(sender, id)
	local index = sender:getTag()
	self._widgets.lockBtn[index]:stateToPressed()
	for i,v in ipairs(self._lockAttr) do
		if v==index then
			sender:stateToNormal()
			table.remove(self._lockAttr, i)
			self:setLockItemData()
			return
		end
	end
	local count = #self._lockAttr
	local lockCfg = i3k_steed_lvl_propLock[self.enhanceLvl]
	if count==lockCfg.maxLockNum then
		self._widgets.lockBtn[self._lockAttr[1]]:stateToNormal()
		table.remove(self._lockAttr, 1)
	end
	table.insert(self._lockAttr, index)
	
	self:setLockItemData()
end

function wnd_steed_practice:removeLastLockItem()
	local scroll = self._layout.vars.costScroll
	scroll:removeChild(scroll.child[MaxItemNum].root, true) --cocos元素移除
	table.remove(scroll.child, MaxItemNum) --UIScrollList元素移除
	scroll:update() --更新布局
end

function wnd_steed_practice:setLockItemData()
	local count = #self._lockAttr

	if count == 0 then
		table.remove(self._needItem,3)
		--self:setNeedItemData()
		self:removeLastLockItem()
		return
	end

	local cfg = self._steedCfg
	local newGoods = {itemId = cfg.lockNeedId, count = cfg.lockNeedCount[count]}
	if self:IsEnoughReplaceGoods() then
		newGoods.itemId =  cfg.lockReplaceId
		newGoods.count =  cfg.lockReplceCount[count]
	end
	
	if #self._needItem == MaxItemNum then
		
		if self._needItem[MaxItemNum].itemId ~= newGoods.itemId then
			self._needItem[MaxItemNum] = newGoods
			self:removeLastLockItem()
			self:addCostGoodsItem(newGoods)
			--self:setNeedItemData()
			return
		end
		self._needItem[MaxItemNum] = newGoods
		local node = self._layout.vars.costScroll:getChildAtIndex(MaxItemNum)
		self:setCostGoodData(node, self._needItem[MaxItemNum])
	else
		table.insert(self._needItem, newGoods)
		self:addCostGoodsItem(newGoods)
	end
end

function wnd_steed_practice:IsEnoughReplaceGoods()
	return g_i3k_game_context:GetCommonItemCanUseCount(self._steedCfg.lockReplaceId) >= self._steedCfg.lockReplceCount[#self._lockAttr]
end

function wnd_steed_practice:GetProtocolTag()
	if #self._lockAttr == 0 then
		return 0
	end

	if self:IsEnoughReplaceGoods() then
		return 1
	end

	return 0
end

function wnd_steed_practice:toPractice(sender)
	if self:IsEnoughGoods() then--self._pracNeedItemIsEnough and self._lockNeedItemIsEnough
		local needItems = self._needItem
		local function sendProtocol( )
			local callback = function (items)
				for i,v in pairs(items) do
					g_i3k_game_context:UseCommonItem(v.itemId, v.count,AT_ENHANCE_HORSE)
					--g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice, "refushNeedItemData", sender:getTag())
				end
			end
			i3k_sbean.practice_steed(sender:getTag(), self._lockAttr, needItems, self:GetProtocolTag(), callback)
		end
		if self._exitJudge then
			local desc = i3k_get_string(556)
			local msgbox_callback = function(isOk)
				if isOk then
					sendProtocol()
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(desc, msgbox_callback)
		else
			sendProtocol()	
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(205))
	end
end

--洗练之后属性临时修改
function wnd_steed_practice:addAttrs(steedId, attrs)
	local starSteedAttr = g_i3k_game_context:getSteedStarAttr(steedId)

	self:updateRightProp(attrs)

	self._exitJudge = self._newPower > self._oldPower

	local jiantou = self._layout.vars.jiantou
	jiantou:show()
	if self._newPower == self._oldPower then
		jiantou:hide()
	elseif self._exitJudge then
		jiantou:setImage(g_i3k_db.i3k_db_get_icon_path(174))
	else
		jiantou:setImage(g_i3k_db.i3k_db_get_icon_path(175))
	end
	
	self.needValue = {id = steedId, power = self._newPower, attrs = attrs}
	self._widgets.saveBtn:show()
end

function wnd_steed_practice:addActivationProp()
	if self.needValue.attrs then
		table.insert(self.needValue.attrs, {id = 0, value = 0})
	end
end

function wnd_steed_practice:saveData(sender)
	if self._newPower < self._oldPower then
		local desc = i3k_get_string(15447)
		local callback = function (isOk)
			if isOk then
				i3k_sbean.replace_attrs(nil,self._oldPartTable,self.needValue)
			end
		end
		return g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	end
	i3k_sbean.replace_attrs(nil,self._oldPartTable,self.needValue)
end

function wnd_steed_practice:setSavePracticeData(needValue, steedInfo)
	self._exitJudge = false
	self._widgets.saveBtn:hide()
	self._oldPower = needValue.power
	self._info = steedInfo
	self.needValue = {}

	local vars = self._layout.vars
	vars.jiantou:hide()
	self:updateLeftProp(steedInfo.enhanceAttrs)
	self:refreshRightProp(steedInfo.enhanceAttrs)
end

function wnd_steed_practice:onTips(sender, eventType)
	if eventType==ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedPracticeTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedPracticeTips, self._info)
	elseif eventType==ccui.TouchEventType.moved then
		
	else
		--g_i3k_ui_mgr:CloseUI(eUIID_SteedPracticeTips)
	end
end

function wnd_steed_practice:onClose(sender)
	if self._exitJudge then
		local desc = i3k_get_string(271)
		local callback = function (isOk)
			if isOk then
				g_i3k_ui_mgr:CloseUI(eUIID_SteedPractice)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_SteedPractice)
	end
end

function wnd_steed_practice:openRefineSet()
	if not g_i3k_db.i3k_db_can_auto_refhine(self._info.enhanceLvl) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18152, i3k_db_steed_common.autoRefine.refhineNeddLeve))
		return
	end
	
	g_i3k_logic:OpenAutoRefhineSetUI(self.steedId, self._sortRefineCfg)
end

function wnd_steed_practice:openAutoRefine()
	if not g_i3k_db.i3k_db_can_auto_refhine(self._info.enhanceLvl) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18152, i3k_db_steed_common.autoRefine.refhineNeddLeve))
		return
	end
	
	local user_cfg = g_i3k_game_context:GetUserCfg()
	--{[1] = {"01234567", "01234567", "01234567", "01234567", "01234567"},[2] = {"0123456", "01234567", "01234567", "01234567", "01234567"},}
	if not user_cfg or not user_cfg:GetSteedAutoRefine()[self.steedId] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18153))
		return
	end
	
	if not self:IsEnoughGoods() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(205))
		return
	end
	
	if self:isAllLockAndMax() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18166))
		return
	end
	
	local widgets = self._layout.vars
	
	if self._exitJudge then
		local desc = i3k_get_string(556)
		
		local callback = function(isOk)
			if isOk then
				widgets.autoRoot:show()
			end
		end
		
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)			
	elseif self:isHaveNoLockOrangePro() then	
		local desc = i3k_get_string(18154)
		
		local callback2 = function(isOk)
			if isOk then
				widgets.autoRoot:show()
			end
		end
		
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback2)
	else			
		widgets.autoRoot:show()
	end
end

function wnd_steed_practice:initRightFrame(enhanceAttrs)
	local wid = self._widgets.attrLabelTableRight
	
	for _, v in ipairs(wid) do
		v.frame:hide()
	end
	
	self._oldPartTable = enhanceAttrs
end

function wnd_steed_practice:isHaveNoLockOrangePro()
	local atts = self._oldPartTable or {}
	
	for i, v in ipairs(atts) do
		local rank = g_i3k_db.i3k_db_can_auto_refhine_quality(v.value, self.refineCfg[i][v.id])
		
		if rank >= g_RANK_VALUE_ORANGE and self:noLock(i) then
			return true
		end
	end
	
	return false
end

function wnd_steed_practice:noLock(index)
	for _, v in ipairs(self._lockAttr) do
		if v == index then
			return false
		end
	end
	
	return true
end

function wnd_steed_practice:refreshRightFrame(atts)
	--洗出目标属性
	local cfg = g_i3k_db.i3k_db_auto_refhine_user_cfg(self.steedId)
	local wid = self._widgets.attrLabelTableRight
	local flag2 = false
	
	for i, v in ipairs(atts) do
		local att = atts[i] --洗脸后第N条属性
		local index = self:getCfgIndexById(i, att.id) --初始的时候id为0
		local value = cfg[i] and cfg[i][index] or 0 
		local noLock = self:noLock(i)
		--if index ~= 0 then
			--local s = g_i3k_db.i3k_db_can_auto_refhine_quality(att.value, self.refineCfg[i][att.id])
			--i3k_log("lht" .. "di" .. i .. "tiaoshuxing" .. "cfgshi" .. value .. "shijishi" .. s)
		--end		
		if value ~= 0 and noLock and g_i3k_db.i3k_db_can_auto_refhine_quality(att.value, self.refineCfg[i][att.id]) >= value then
			flag2 = true
			wid[i].frame:show()
		else
			wid[i].frame:hide()
		end
	end
	
	return flag2
end

function wnd_steed_practice:canAutoRefine(atts)
	local flag2 = self:refreshRightFrame(atts) or self:isAllLockAndMax()
	
	if flag2 then
		g_i3k_game_context:stopDoWork()
		return
	end
	
	local user_cfg = g_i3k_game_context:GetUserCfg()
	
	local fun = function ()
		if self:isAllLockAndMax() or not self:IsEnoughGoods() then --防止多做一次 
			g_i3k_game_context:stopDoWork()
		else
			g_i3k_game_context:doWork()
		end
	end
	
	local refinePowercfg = user_cfg:GetSteedAutoRefinePowerSave()
	
	if self._newPower > self._oldPower then --战力提升
		if refinePowercfg[1] == 1 then
			i3k_sbean.replace_attrs(fun, self._oldPartTable, self.needValue)
		else
			g_i3k_game_context:stopDoWork()
		end
		
		return
	end
	
	local flag = false
	
	for _, v in ipairs(self._lockAttr) do --锁属性提升
		if self._oldPartTable[v].value < atts[v].value then
			flag = true
			break
		end	
	end
	
	if flag and refinePowercfg[2] == 1 then
		i3k_sbean.replace_attrs(fun, self._oldPartTable, self.needValue)
		return	
	end
	
	if not self:IsEnoughGoods() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(205))
		g_i3k_game_context:stopDoWork()
		return false
	end
end

function wnd_steed_practice:onHide()
	g_i3k_game_context:stopDoWork()
end

function wnd_steed_practice:getCfgIndexById(index, id)
	local atts = self._sortRefineCfg[index]
	
	for i, v in ipairs(atts) do
		if v.propId == id then
			return i
		end
	end
	
	return 0
end

function wnd_steed_practice:closeAutoRefine()
	self._layout.vars.autoRoot:hide()
end

function wnd_steed_practice:onAutoRefine(sender, times)
	local fun = function()	
		local callback = function (items)
			for i,v in pairs(items) do
				g_i3k_game_context:UseCommonItem(v.itemId, v.count, AT_ENHANCE_HORSE)
			end
		end
		
		i3k_sbean.practice_steed(self.steedId, self._lockAttr, self._needItem, self:GetProtocolTag(), callback)
	end
	
	g_i3k_game_context:autoDoWork(times, i3k_db_steed_common.autoRefine.sendInterval, g_AUTO_STEED_REFINE, i3k_get_string(18162), fun)
	g_i3k_game_context:doWork()
	self._layout.vars.autoRoot:hide()
end

function wnd_steed_practice:isAllLockAndMax()
	local oldPro = self._oldPartTable or {}
	
	for i, v in ipairs(oldPro) do
		if self:noLock(i) or g_i3k_db.i3k_db_can_auto_refhine_quality(v.value, self.refineCfg[i][v.id]) < g_RANK_VALUE_MAX then
			return false
		end
	end
		
	return true
end

function wnd_steed_practice:onOutPrivew()
	local proSet = g_i3k_db.i3k_db_auto_refhine_user_cfg(self.steedId)
	g_i3k_logic:OpenAutoRefhineSetPreviewUI(self._sortRefineCfg, proSet)
end

function wnd_create(layout, ...)
	local wnd = wnd_steed_practice.new()
	wnd:create(layout, ...)
	return wnd;
end
