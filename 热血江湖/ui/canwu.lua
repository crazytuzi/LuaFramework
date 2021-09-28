module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_canwu = i3k_class("wnd_canwu", ui.wnd_base)

local CANWUT        = "ui/widgets/canwut"
local CANWUT3       = "ui/widgets/canwut3"

function wnd_canwu:ctor()
	self.wudao = {}
	self._poptick = 0
	self._canShow = true
	self.allTime = nil
	self.select = nil
	self.dayBuyTime = 0
	self.skillInfo = {}
	self._nextCfg = nil
end

function wnd_canwu:configure()
	local widgets = self._layout.vars
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self.empowerment_btn   = widgets.empowerment_btn
	self.library_btn   = widgets.library_btn 
	self.penetrate_btn = widgets.penetrate_btn
	self.library_btn:onClick(self,self.libraryBtn)
	self.penetrate_btn:onClick(self,self.penetrateBtn)
	self.empowerment_btn:onClick(self,self.empowermentBtn)
	
	self.scroll1 = widgets.scroll
	self.scroll2 = widgets.scroll2
	self.nextName = widgets.nextName
	self.nowEffect = widgets.nowEffect
	self.nextEffect = widgets.nextEffect
	self.nextMark = {widgets.nextMark1,widgets.nextMark2,widgets.nextMark3}
	self.canwuCount = widgets.canwuCount
	self.canwuLabel = widgets.canwuLabel
	self.CDCount = widgets.CDCount
	self.resetBtn = widgets.resetBtn
	self.CDName = widgets.CDName
	self.lvNow = widgets.lvNow
	self.expPercent =widgets.expPercent
	self.expLabel = widgets.expLabel
	self.tips = widgets.tips
	self.tipsBg = widgets.tipsBg
	self.red_point = widgets.red_point
	self.red_point2 = widgets.red_point2
	self.red_point3 = widgets.red_point3
	self.CDCount:hide()
	self.CDName:hide()
	self.empowerment_btn:stateToNormal()
	self.penetrate_btn:stateToPressed()
	self.library_btn:stateToNormal()
	self.library_btn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_experience_args.args.libraryHideLevel)
	
	self.resetBtn:onClick(self,self.resetBtnData)

	widgets.qiankunBtn:onClick(self,self.qiankunBtn)
	widgets.qiankunBtn:stateToNormal()
	widgets.qiankunBtn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_experience_args.experienceUniverse.showLevel)

	self.maxUI = widgets.maxUI  --参悟满级
	widgets.canwu_btn:onClick(self, self.startWudao)
	widgets.buy_btn:onClick(self, self.onBuyCanwuTimes)
end

function wnd_canwu:refresh()
	self.dayBuyTime = g_i3k_game_context:GetBuyTimes()
	self.skillInfo = g_i3k_game_context:GetGraspSkill()
	self:leftScrollData()    --左边
	self:canwuCountData()	--中间
end

function wnd_canwu:leftScrollData(count)
	local info = g_i3k_game_context:GetWudaoInfo()
	local wudaoData = {}
	local deleteID = 0
	if next(info) then
		for k,v in ipairs(info) do
			table.insert(wudaoData, v)
		end
	end
	self.scroll1:removeAllChildren()
	local all_layer = self.scroll1:addItemAndChild(CANWUT, 2, #wudaoData)
	for k,v in ipairs(wudaoData) do
		local widget = all_layer[k].vars
		widget.name:setText(v.name)
		widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iron))
		--widget.iconBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.iron))
		widget.desc:setText("Lv." .. v.lvl)
		widget.is_select:hide()
		widget.select1_btn:onClick(self,self.setWudaoData,{widget = widget, newInfo = v, nowSelect = v.canwuID, k = k})
		--widget.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(707))
		if count then
			if count == k then
				self.select = v.canwuID
				self:setWudaoInfo(v)
				widget.is_show:show()
				--widget.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(706))
			end
		else
			if k == 1 then
				g_i3k_game_context:recordSelectWudao(k)
				self.select = v.canwuID
				self:setWudaoInfo(v)
				widget.is_show:show()
				--widget.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(706))
			end
		end
	end
	if count then
		self.scroll1:jumpToChildWithIndex(count)
	end
end

function wnd_canwu:canwuCountData()
	local args = g_i3k_db.i3k_db_experience_args
	local nowTimes = g_i3k_game_context:GetCanwuTimes()
	local str = nowTimes .. "/" .. (args.canwuCorrelation.canwuTimes + self.dayBuyTime)
	self.canwuCount:setText(str)
	self.red_point:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks()) --红点逻辑
	self.red_point2:setVisible(g_i3k_game_context:qiankunRedPoints()) --红点逻辑
	self.red_point3:setVisible(g_i3k_game_context:isShowCunWnRed())
	if nowTimes >= args.canwuCorrelation.canwuTimes + self.dayBuyTime then
		self.resetBtn:hide();
	end
	local skillLvl = self.skillInfo[11] or 0
	self._layout.vars.skill_icon:setImage(i3k_db_icons[i3k_db_faction_skill[11][skillLvl].icon].path)
	self._layout.vars.canwu_level:setText(skillLvl)
	self._layout.vars.canwu_rate:setText(string.format("%s%%", i3k_db_faction_skill[11][skillLvl].canwuRate/100))
end

function wnd_canwu:setCanwuData()
	self.scroll2:removeAllChildren()
	self.wudao = {}

	local canwuCfg = self._nextCfg
	self.scroll2:setVisible(canwuCfg ~= nil)
	self.maxUI:setVisible(not canwuCfg)
	if canwuCfg then
		for _, v in ipairs(canwuCfg.consumeItem) do
			local node = require(CANWUT3)()
			self:setItemData(node, v.id, v.count)
		end
	end
end

function wnd_canwu:setCanwuExpAdd()
	local widgets = self._layout.vars
	local skillLvl = self.skillInfo[11] or 0
	local addExpRate = i3k_db_faction_skill[11][skillLvl].canwuRate/10000
	local canwuCfg = self._nextCfg
	widgets.canwu_base:setVisible(canwuCfg ~= nil)
	widgets.canwu_add:setVisible(canwuCfg ~= nil)
	widgets.canwu_base_text:setVisible(canwuCfg ~= nil)
	widgets.canwu_add_text:setVisible(canwuCfg ~= nil)
	if canwuCfg then
		widgets.canwu_base:setText(canwuCfg.addExp)
		widgets.canwu_add:setText(math.floor(canwuCfg.addExp * addExpRate))
	end
end

function wnd_canwu:setItemData(node, id, count)
	local curCount = g_i3k_game_context:GetCommonItemCanUseCount(id)
	local color = count <= curCount and g_COLOR_VALUE_GREEN or g_COLOR_VALUE_RED
	node.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
	node.vars.item_btn:onClick(self, self.onItemTips, id)
	if math.abs(id) == g_BASE_ITEM_DIAMOND or math.abs(id) == g_BASE_ITEM_COIN then
		node.vars.item_count:setText(count)
	else
		node.vars.item_count:setText(curCount.."/"..count)
	end
	node.vars.item_count:setTextColor(color)
	node.vars.suo:setVisible(id > 0)
	table.insert(self.wudao, {id = id, count = count})
	self.scroll2:addItem(node)
end

function wnd_canwu:addCanwuCount(times)
	self.dayBuyTime = self.dayBuyTime + 1
	self:canwuCountData()
end

function wnd_canwu:startWudao(sender)
	local nowTimes = g_i3k_game_context:GetCanwuTimes()
	local start_time = g_i3k_game_context:GetLastCanwuTime()
	local serverTime = i3k_integer(i3k_game_get_time())
	if nowTimes >= i3k_db_experience_args.canwuCorrelation.canwuTimes + self.dayBuyTime then
		g_i3k_ui_mgr:PopupTipMessage("次数不足")
	elseif i3k_db_experience_args.canwuCorrelation.canwuNeedTimes > serverTime - start_time then
		g_i3k_ui_mgr:PopupTipMessage("冷却时间未到")
	else
		local curLvl = g_i3k_game_context:GetLevel()
		if curLvl < self._openLvl then
			return g_i3k_ui_mgr:PopupTipMessage(string.format("等级到达%s方可参悟", self._openLvl))
		end

		local isEnough = true
		for _, v in ipairs(self.wudao) do
			if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
				isEnough = false
				break
			end
		end
		if isEnough then
			local wudaoId = g_i3k_game_context:GetSelectWudao()
			i3k_sbean.goto_grasp_impl(wudaoId, self.wudao)
		else
			g_i3k_ui_mgr:PopupTipMessage("参悟道具不足")
		end
	end
end

function wnd_canwu:onBuyCanwuTimes(sender)
	local vipLevel = g_i3k_game_context:GetVipLevel()
	if self.dayBuyTime >= i3k_db_kungfu_vip[vipLevel].buyCanwu then
		g_i3k_ui_mgr:PopupTipMessage("购买次数已达上限")
	else
		local needDiamond = 0
		if i3k_db_common.canwu.canwuBuy[self.dayBuyTime + 1] then
			needDiamond = i3k_db_common.canwu.canwuBuy[self.dayBuyTime + 1]
		else
			needDiamond = i3k_db_common.canwu.canwuBuy[#i3k_db_common.canwu.canwuBuy]
		end
		if g_i3k_game_context:GetCommonItemCanUseCount(1) < needDiamond then
			g_i3k_ui_mgr:PopupTipMessage("元宝不足")
		else
			local callback = function (isOk)
				if isOk then
					i3k_sbean.grasp_time_buy(self.dayBuyTime + 1, needDiamond)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17010, needDiamond, i3k_db_kungfu_vip[vipLevel].buyCanwu - self.dayBuyTime), callback)
		end
	end
end

function wnd_canwu:resetBtnData(sender)    -- 重置是否可以参悟
	local maxTimes = g_i3k_game_context:GetCanwuTimes()
	if maxTimes >= i3k_db_experience_args.canwuCorrelation.canwuTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(464))
		return
	end
	local desc = string.format(i3k_get_string(465,i3k_db_experience_args.canwuCorrelation.needMoney))
	local canUseMoney = g_i3k_game_context:GetDiamondCanUse(false)
	local callback = function (isOk)
		if isOk then
			if canUseMoney >= i3k_db_experience_args.canwuCorrelation.needMoney then
				i3k_sbean.goto_grasp_reset(i3k_db_experience_args.canwuCorrelation.needMoney)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(466))
			end
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end

function wnd_canwu:setWudaoData(sender, data)
	self:setCellIsSelectHide()
	data.widget.is_show:show()
	--data.widget.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(706))
	self.select = data.nowSelect
	g_i3k_game_context:recordSelectWudao(data.k)
	self:setWudaoInfo(data.newInfo)
end

function wnd_canwu:setWudaoInfo(info)
	local alllvl = g_i3k_game_context:GetCanLevelWuInfo()
	local nexInfo = g_i3k_game_context:GetNextWudaoLevel(info.canwuID, info.lvl)
	if next(alllvl) ~= nil then 
		if nexInfo then
			for k,v in pairs(alllvl) do
				if k == info.canwuID then
					self.expLabel:setText(v.exp .. "/" .. nexInfo.exp)
					self.expPercent:setPercent(v.exp/nexInfo.exp * 100)
					self._layout.vars.canwu_btn:show()
				end
			end
		else
			self.expLabel:setText(i3k_get_string(948));
			self.expPercent:setPercent(100)
			self._layout.vars.canwu_btn:hide()
		end
	else
		if nexInfo then
			self.expLabel:setText(0 .. "/" .. nexInfo.exp)
			self.expPercent:setPercent(0/nexInfo.exp * 100)
			self._layout.vars.canwu_btn:show()
		end
	end

	self._openLvl = i3k_db_experience_canwu[info.canwuID][info.lvl].openLvl
	self._nextCfg = i3k_db_experience_canwu[info.canwuID][info.lvl + 1]
	
	self:setCanwuData()
	self:setCanwuExpAdd()

	self.lvNow:setText(i3k_get_string(467,info.lvl));
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(info.iron))
	self._layout.vars.desc:setText(info.name)
	if nexInfo ~= nil then
		self.nowEffect:setText(info.promoteDesc)
		self.nextEffect:show()
		self.nextEffect:setText(nexInfo.promoteDesc)
		for _,mark in pairs(self.nextMark) do
			mark:show();
		end
	else
		self.nowEffect:setText(info.promoteDesc)
		self.nextName:hide()
		self.nextEffect:hide()
		for _,mark in pairs(self.nextMark) do
			mark:hide();
		end
	end
end

function wnd_canwu:onUpdate(dTime)--
	local args = g_i3k_db.i3k_db_experience_args
	local allTime = args.canwuCorrelation.canwuNeedTimes
	local start_time = g_i3k_game_context:GetLastCanwuTime()
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	local isCanCanwu = g_i3k_game_context:GetIsCanCanwu()
	local f,m
	if isCanCanwu == false then
		local maxTimes = g_i3k_game_context:GetCanwuTimes()
		if maxTimes >= args.canwuCorrelation.canwuTimes then
			self.CDCount:hide()
			self.CDName:hide()
			self.resetBtn:hide()
			self.canwuCount:show()
			self.canwuLabel:show()
			return
		end
		self.resetBtn:show()
		self.CDCount:show()
		self.CDName:show()
		self.canwuCount:hide()
		self.canwuLabel:hide()
		local have_time = start_time + allTime - serverTime
		f = math.modf(have_time % 3600 / 60)
		m = math.modf(have_time % 3600 % 60)
		if have_time <= 0 or (m  == 0 and f == 0) then
			self.CDCount:hide()
			self.CDName:hide()
			g_i3k_game_context:SetIsCanCanwu(true)
		else
			if string.len(f) == 1 then
				f = string.format("0%s",f)
			end
			if string.len(m) == 1 then
				m = string.format("0%s",m)
			end
			local tmp_str = string.format("%s:%s",f,m)
			self.CDCount:setText(tmp_str)
		end
	else
		self.CDCount:hide()
		self.CDName:hide()
		self.resetBtn:hide()
		self.canwuCount:show()
		self.canwuLabel:show()
	end
end

function wnd_canwu:setCellIsSelectHide()
	for i, e in pairs(self.scroll1:getAllChildren()) do
		if e.vars.is_show then
			e.vars.is_show:hide()
		end
	end
end

function wnd_canwu:empowermentBtn(sender,data)
	i3k_sbean.goto_expcoin_sync()   --历练协议
end

function wnd_canwu:libraryBtn()
	if g_i3k_game_context:GetLevel() < i3k_db_experience_args.args.libraryShowLevel then
		local str = string.format("等级达到%s时藏书开启", i3k_db_experience_args.args.libraryShowLevel)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end
	i3k_sbean.goto_rarebook_sync()   --藏书协议
end

function wnd_canwu:qiankunBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_experience_args.experienceUniverse.openLevel then
		local str = string.format("等级达到%s时乾坤开启", i3k_db_experience_args.experienceUniverse.openLevel)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Qiankun)
	g_i3k_ui_mgr:RefreshUI(eUIID_Qiankun)
	g_i3k_ui_mgr:CloseUI(eUIID_CanWu)
end

function wnd_canwu:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_canwu.new();
		wnd:create(layout);
	return wnd;
end
