
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_npcDonate = i3k_class("wnd_npcDonate",ui.wnd_base)

function wnd_npcDonate:ctor()
	self._info = nil
	self._inputGoods = nil
	self._outputGoods = nil
end

function wnd_npcDonate:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	self.ui = widgets

	self.requireItem = {}
	for i = 1, 3 do
		self.requireItem[i] = {
			require_icon 		= widgets["require_icon" .. i],
			require_goods_icon 	= widgets["require_goods_icon" .. i],
			require_goods_btn  	= widgets["require_goods_btn" .. i],
			require_goods_count = widgets["require_goods_count" .. i],
		}
	end
	self.getItem = {}
	for i = 1, 1 do
		self.getItem[i] = {
			get_icon 		= widgets["get_icon" .. i],
			get_goods_icon 	= widgets["get_goods_icon" .. i],
			get_goods_btn  	= widgets["get_goods_btn" .. i],
			get_goods_count = widgets["get_goods_count" .. i],
			get_goods_suo 	= widgets["get_goods_suo" .. i],
		}
	end

	self.rewardItem = {}
	for i = 1, 5 do
		self.rewardItem[i] = {
			reward_box 		= widgets["reward_box1" .. i],
			reward_icon 	= widgets["reward_icon1" .. i],
			reward_btn 		= widgets["reward_btn1" .. i],
			reward_get_icon = widgets["reward_get_icon1" .. i],
			value_img 		= widgets["value_img1" .. i],
			reward_txt 		= widgets["reward_txt1" .. i],
		}
	end


end

function wnd_npcDonate:refresh(info)
	self._info = info
	self:updateDonateInfo()
	self:updateProgressData()

	self.ui.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(info.cfg.content)
	end)
	self.ui.actTime:setText(self:getActTimeStr(info.cfg.time))
end

function wnd_npcDonate:updateDonateInfo()
	local info = self._info
	self._inputGoods = info.cfg.inputGoods
	self._outputGoods = info.cfg.outputGoods

	self:updateInputGoods()
	self:updateOutputGoods()
	local haveTimes = info.cfg.daytimes - info.distoryTimes
	if haveTimes > 0 then
		self.ui.donateBtn:enableWithChildren()
		self.ui.donateBtn:onClick(self, self.onDonate)
	else
		self.ui.donateBtn:disableWithChildren()
	end
	self.ui.remainTimes:setText(string.format("剩余%s次", haveTimes))
end

function wnd_npcDonate:updateInputGoods()
	local inputGoods = self._inputGoods
	for i, v in ipairs(self.requireItem) do
		local item = inputGoods[i]
		if item then
			v.require_icon:show()
			v.require_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
			v.require_goods_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id), g_i3k_game_context:IsFemaleRole())
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(item.id)
			local text = (math.abs(item.id) == g_BASE_ITEM_COIN or math.abs(item.id) == g_BASE_ITEM_DIAMOND) and item.count or canUseCount .. "/" .. item.count  -- 铜钱和元宝只显示数量
			v.require_goods_count:setText(text)
			v.require_goods_count:setTextColor(g_i3k_game_context:GetCommonItemCanUseCount(item.id) < item.count and g_i3k_get_red_color() or g_i3k_get_green_color())
			v.require_goods_btn:onClick(self, self.onTips, item.id)
		else
			v.require_icon:hide()
		end
	end
end

function wnd_npcDonate:updateOutputGoods()
	local outputGoods = self._outputGoods
	for i, v in ipairs(self.getItem) do
		local item = outputGoods[i]
		if item then
			v.get_icon:show()
			v.get_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
			v.get_goods_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id), g_i3k_game_context:IsFemaleRole())
			v.get_goods_count:setText("x"..item.count)
			v.get_goods_btn:onClick(self, self.onTips, item.id)
		else
			v.get_icon:hide()
		end
	end
end

function wnd_npcDonate:updateProgressData()
	local gradeReward = self._info.cfg.gradeReward
	local totalTimes = self._info.totalTimes --全服捐赠总次数
	local rewardLog = self._info.rewardTimes --宝箱领取记录

	local percent = 0
	local singlePercent = #gradeReward > 0 and (100 / #gradeReward) or 100

	for i, v in ipairs(self.rewardItem) do
		local gradeData = gradeReward[i]
		if gradeData then
			local times = gradeData.times
			local goods = gradeData.goods
			v.reward_txt:setText(times)
			if totalTimes >= times then
				percent = i * singlePercent
			else
				local lastTimes = 0
				if i > 1 then
					lastTimes = gradeReward[i - 1].times
				end
				local total = times - lastTimes
				local off = totalTimes - lastTimes
				if off > 0 then
					percent = percent + off / total * singlePercent
				end
			end
			--领过奖励
			if rewardLog[times] then
				v.reward_icon:setVisible(false)
				v.reward_get_icon:setVisible(true)
				self._layout.anis["c_fudai" .. i].stop()
				v.reward_btn:onClick(self, function()
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17005))
				end)
			else
				if totalTimes >= times then
					self._layout.anis["c_fudai" .. i].play()
					local data = {grade = i - 1, goods = goods}
					v.reward_btn:onClick(self, self.onGetScheduleReward, data)
				else
					v.reward_btn:onClick(self, function()
						local data = {}
						for _, v in ipairs(goods) do
							table.insert(data, {id = v.id, num = v.count})
						end
						g_i3k_ui_mgr:OpenUI(eUIID_CallBackTips)
						g_i3k_ui_mgr:RefreshUI(eUIID_CallBackTips, data)
					end)
				end
			end
			v.reward_box:show()
		else
			v.reward_box:hide()
		end
	end
	self.ui.progress:setPercent(percent)
end

function wnd_npcDonate:onDonate(sender)
	for _, v in ipairs(self._inputGoods) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			g_i3k_ui_mgr:PopupTipMessage("捐赠所需道具不足")
			return
		end
	end

	local callback = function()
		i3k_sbean.sync_doante_info()
	end

	if self:isBagEnough(self._outputGoods) then
		i3k_sbean.conduct_donate(self._inputGoods, self._outputGoods, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
		return
	end
end

function wnd_npcDonate:onGetScheduleReward(sender, data)
	local goods = data.goods
	local grade = data.grade

	local callback = function()
		i3k_sbean.sync_doante_info()
	end

	if self:isBagEnough(goods) then
		i3k_sbean.receive_award(grade, goods, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
		return
	end
end

function wnd_npcDonate:onTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_npcDonate:isBagEnough(gifts)
	local isEnoughTable = {}
	for _, v in pairs(gifts) do
		isEnoughTable[v.id] = v.count
	end
	return g_i3k_game_context:IsBagEnough(isEnoughTable)
end

function wnd_npcDonate:getActTimeStr(time)
	local cur_Time = i3k_game_get_time()
	local totalDay = g_i3k_get_day(cur_Time)
	local lastDay = g_i3k_get_day(time.endTime)
	local days = lastDay - totalDay

	local havetime = time.endTime - cur_Time
	local min = math.floor(havetime / 60 % 60)
	local hour = math.floor(havetime / 3600 % 24)
	local day = math.floor(havetime / 3600 / 24)

	local str = ""
	if days <= 3 then
		str = string.format("%d天%d时%d分", day, hour, min)
	else
		str = g_i3k_get_ActDateRange(time.startTime, time.endTime)
	end

	return str
end

function wnd_create(layout, ...)
	local wnd = wnd_npcDonate.new()
	wnd:create(layout, ...)
	return wnd;
end

