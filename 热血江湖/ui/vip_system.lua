-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_vip_system = i3k_class("wnd_vip_system", ui.wnd_base)

local l_nTitle 			= 181
local l_nFullTip 		= 182
local l_nGetTips		= 186
local l_sVipLvl 		= "vip#v%s.png"
local l_pVipDesc 		= "ui/widgets/viptqt"

function wnd_vip_system:ctor()
	self._discountFlag = false
end

local discountImage = {499, 500, 501, 502, 503, 504, 505, 506, 507}

function wnd_vip_system:configure()
	self.rewardWins = {}
	local reward = "reward"
	local showBtn = "showBtn"
	local ricon = "ricon"
	local num = "num"
	local suo = "suo"
	for i=1, 4 do
		local r = {}
		r.reward = self._layout.vars[reward .. i]
		r.showBtn = self._layout.vars[showBtn .. i]
		r.icon = self._layout.vars[ricon.. i]
		r.num = self._layout.vars[num .. i]
		r.suo = self._layout.vars[suo..i]
		table.insert(self.rewardWins, r)
	end

	self.percent = self._layout.vars.percent
	self.percentText = self._layout.vars.percentText
	self.title = self._layout.vars.title
	self.takeReward = self._layout.vars.takeReward
	self.vipLvl = self._layout.vars.vipLvl
	self.wholefuncTitel = self._layout.vars.wholefuncTitel
	self.funcTitel = self._layout.vars.funcTitel
	self.wholegiftTitle = self._layout.vars.wholegiftTitle
	self.giftTitle = self._layout.vars.giftTitle
	self.scroll = self._layout.vars.desc_scroll

	local left = self._layout.vars.left
	local right = self._layout.vars.right
	local channel_pay = self._layout.vars.channel_pay_btn
	left:onClick(self, self.onLeftClick)
	right:onClick(self, self.onRightClick)
	channel_pay:onClick(self, self.onGoChannelPay)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.diamondNum = self._layout.vars.diamondNum
	self.diamondIcon = self._layout.vars.diamondIcon
end

function wnd_vip_system:refresh(payInfo, curLvl)
	self.payInfo = payInfo
	self.curLvl = curLvl or payInfo.vipLvl
	self:setTopInfo(payInfo.vipLvl)
	self:updateCurRewards()
end

function wnd_vip_system:onShow()

end

function wnd_vip_system:onHide()
	
end

function wnd_vip_system:setTopInfo(vipLvl)
	local curPoints = self.payInfo.pointsTotal
	local nextLvlNeedPoints = 1

	if vipLvl + 1 <= i3k_table_length(i3k_db_kungfu_vip) - 1 then
		nextLvlNeedPoints = i3k_db_kungfu_vip[vipLvl + 1].points
	end

	local fullLvl = vipLvl >= i3k_table_length(i3k_db_kungfu_vip) - 1
	if curPoints > nextLvlNeedPoints then
		curPoints = nextLvlNeedPoints
	end

	self.percent:setPercent(curPoints / nextLvlNeedPoints * 100)
	self.percentText:setText(curPoints .. " / " .. nextLvlNeedPoints)

	if not fullLvl then
		self.title:setText(i3k_get_string(l_nTitle, nextLvlNeedPoints - curPoints, vipLvl + 1))
	else
		self.percentText:hide()
		self.title:setText(i3k_get_string(l_nFullTip))
	end

	self.vipLvl:setImage(string.format(l_sVipLvl, vipLvl))
end

function wnd_vip_system:updateVipInfo()
	self:updateCurRewards()
end

function wnd_vip_system:updateCurRewards()
	local vipCfg = i3k_db_kungfu_vip[self.curLvl]
	local reward = {}
	if vipCfg then
		for i,v in ipairs(self.rewardWins) do
			local itemID = vipCfg.gifts[i].itemID
			local itemCount = vipCfg.gifts[i].itemCount
			if itemCount > 0 then
				local itemInfo = g_i3k_db.i3k_db_get_common_item_cfg(itemID)
				if itemInfo then
					local grade = itemInfo.rank
					v.reward:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
					v.icon:setImage(i3k_db_icons[itemInfo.icon].path)
					v.icon:onClick(self, self.showItemTips, itemID)
					local shwoNum = math.abs(itemID) == g_BASE_ITEM_COIN and i3k_get_num_to_show(itemCount) or itemCount
					v.num:setText("x"..shwoNum)
					v.suo:setVisible(itemID > 0)
					v.reward:show()

					if reward[itemID] then
						reward[itemID] = reward[itemID] + itemCount
					else
						reward[itemID] = itemCount
					end
				else
					v.reward:hide()
				end
			else
				v.reward:hide()
			end
		end
		
		self:refreshDiamondCostAndRewardBt(reward)
	else
		self:hideAllRewards()
	end

	self:updateVipDesc(vipCfg)

	self.funcTitel:setText(i3k_get_string(491, self.curLvl))
	self.giftTitle:setText(i3k_get_string(491, self.curLvl))

	self.wholefuncTitel:setVisible(self.curLvl > 0)
	self.wholegiftTitle:setVisible(self.curLvl > 0)
end

function wnd_vip_system:refreshDiamondCostAndRewardBt(reward)
	local weights = self._layout.vars
	
	if self.curLvl == 0 then
		weights.diamondIcon:hide()
		weights.diamondIcon2:hide()
		weights.diamondIcon3:hide()
		weights.diamondIcon:hide()
		self.takeReward:hide()
		return
	end
	
	self.takeReward:show()
	self.takeReward:onClick(self, self.takeRewardClick, {level = self.curLvl, reward = reward})
	self._discountFlag = self.payInfo.rewards[self.curLvl] and g_i3k_db.i3k_db_check_vipGiftBgDiscount_date()
	weights.diamondIcon:setVisible(not self._discountFlag)
	weights.diamondIcon2:setVisible(self._discountFlag)
	weights.diamondIcon3:setVisible(self._discountFlag)
	
	local cfg = i3k_db_kungfu_vip[self.curLvl]
	
	if self._discountFlag then
		--已经领取老的 不显示diamondIcon
		weights.diamondNum2:setText(cfg.needDiamond)
		weights.diamondNum3:setText(math.ceil(cfg.needDiamond * cfg.vipGiftBgDiscount / 10000))
		local discount = math.ceil(cfg.vipGiftBgDiscount / 1000)
		local iconID = discountImage[discount]
		
		if iconID then
			weights.discountImage:show()
			weights.discountImage:setImage(i3k_db_icons[iconID].path)
		else
			weights.discountImage:hide()
		end
		
		weights.tipsBt:onClick(self, function() g_i3k_logic:OpenVipGiftDistountTips() end)
	else
		weights.diamondNum:setText(cfg.needDiamond)
	end
	
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local newRewards = self.payInfo.newRewards[1]
	
	if vipLvl < self.curLvl or (newRewards ~= nil and newRewards.takedRewards[self.curLvl] ~= nil) then
		self.takeReward:disableWithChildren()
	else		
		self.takeReward:enableWithChildren()
	end
end

function wnd_vip_system:updateVipDesc(vipCfg)
	local descs = string.split(vipCfg.desc, "\n")
	self.scroll:removeAllChildren()
	local width = self.scroll:getContainerSize().width
	self.scroll:setContainerSize(width, 0)
	for i,v in ipairs(descs) do
		local descItem = require(l_pVipDesc)()
		descItem.vars.text:setText(v)
		self.scroll:addItem(descItem)
	end
end

function wnd_vip_system:hideAllRewards()
	for i, v in ipairs(self.rewardWins) do
		v.reward:hide()
	end
end

--[[function wnd_vip_system:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_VipSystem)
end--]]

function wnd_vip_system:onGoChannelPay(sender)
	local payInfo = self.payInfo
	g_i3k_ui_mgr:CloseUI(eUIID_VipSystem)
	g_i3k_ui_mgr:OpenUI(eUIID_ChannelPay)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChannelPay, payInfo)
	--g_i3k_ui_mgr:SetUICloseCallback(eUIID_ChannelPay, function ()
		--i3k_game_set_ignore_next_pause_resume_state(false) --暂不启用
	--end)
end

function wnd_vip_system:takeRewardClick(sender, info)
	local newRewards = self.payInfo.newRewards[1]
	if newRewards ~= nil and newRewards.takedRewards[info.level] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(l_nGetTips))
		return 
	end

	local enough = g_i3k_game_context:IsBagEnough(info.reward)
	if enough then
			local haveDiamond = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
			local cfg = i3k_db_kungfu_vip[info.level]
			local needDiamond = self._discountFlag and math.ceil(cfg.needDiamond * cfg.vipGiftBgDiscount / 10000) or cfg.needDiamond
			
			if haveDiamond >= needDiamond then
				local gifts = {}
				for k,v in pairs(info.reward) do
					table.insert(gifts, {id = k, count = v})
				end
								
				local fun = (function(ok)
					if ok then
						if self._discountFlag and not g_i3k_db.i3k_db_check_vipGiftBgDiscount_date() then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17296))
							self:updateCurRewards()
							return
						end
						
						i3k_sbean.take_vip_reward(info.level, gifts, needDiamond)
					end
				end)
				g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(15199, needDiamond), fun)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15195))
			end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end

function wnd_vip_system:takeRewardHandle(level)
	local newRewards = self.payInfo.newRewards[1]
	newRewards = newRewards == nil and {} or newRewards
	newRewards.takedRewards = newRewards.takedRewards == nil and {} or newRewards.takedRewards
	newRewards.takedRewards[level] = true
	self.payInfo.newRewards[1] = newRewards
	self.takeReward:disableWithChildren()
end

function wnd_vip_system:onLeftClick(sender)
	local curLvl = self.curLvl
	if curLvl > 0 then
		curLvl = curLvl - 1
		self.curLvl = curLvl
		self:updateVipInfo()
	end
end

function wnd_vip_system:onRightClick(sender)
	local curLvl = self.curLvl
	local maxLvl = i3k_table_length(i3k_db_kungfu_vip) - 1
	if curLvl < maxLvl then
		curLvl = curLvl + 1
		self.curLvl = curLvl
		self:updateVipInfo()
	end
end

function wnd_vip_system:showItemTips(sender, itemID)
	if itemID then
		g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_vip_system.new()
	wnd:create(layout, ...)
	return wnd
end
