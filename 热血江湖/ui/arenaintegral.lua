-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arenaIntegral = i3k_class("wnd_arenaIntegral", ui.wnd_base)

local f_rewardTable = {}
local f_integralImgY = {418, 419, 420, 421, 422, 423, 424, 425, 426, 427}
local f_integralImgG = {428, 429, 430, 431, 432, 433, 434, 435, 436, 437}

local db = g_i3k_db

function wnd_arenaIntegral:ctor()
	self._arenaCoinRewardTable = {}
end

function wnd_arenaIntegral:configure()
	self._layout.vars.scroll:setDirection(2)
	self._layout.vars.close:onClick(self, self.onClose)
end

function wnd_arenaIntegral:onShow()
	
end

function wnd_arenaIntegral:refresh(score, takenScores)
	self._layout.vars.curIntegral:setText("当前积分:"..score)
	self:setData(score, takenScores)
end

function wnd_arenaIntegral:setData(score, takenScores)
	local rewardTable = {}
	f_rewardTable = {}
	for _, v in pairs(i3k_db_score_reward) do
		table.insert(f_rewardTable, v)
		local isTaken = false
		for _,t in pairs(takenScores) do
			if t==v.minScore then
				isTaken = true
				break
			end
		end
		if not isTaken then
			table.insert(rewardTable, v)
		end
	end
	
	local sortFun = function (a, b)
		return a.minScore < b.minScore
	end
	table.sort(rewardTable, sortFun)
	table.sort(f_rewardTable, sortFun)
	
	local hasTakenTable = {}
	for i,v in pairs(takenScores) do
		local hasTakenReward = i3k_db_score_reward[v]
		table.insert(hasTakenTable, hasTakenReward)
	end
	table.sort(hasTakenTable, sortFun)
	
	for i,v in pairs(hasTakenTable) do
		local integralBar = require("ui/widgets/jfjlt")()
		--integralBar.vars.needScore:setText(v.minScore)
		local item1
		local item2
		local item3
		local rewardItemTable = {v.bindMoney, v.arenaPoint, v.bindDiamond, v.itemId1}
		for j,t in ipairs(rewardItemTable) do
			if t~= 0 then
				if item1 then
					if item2 then
						if j==3 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item3.count = t
							break
						elseif j==2 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							item3.count = t
							break
						else
							item3 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item3.count = v.itemCount1
							break
						end
					else
						if j==3 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item2.count = t
						elseif j==2 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							item2.count = t
						else
							item2 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item2.count = v.itemCount1
						end
					end
				else
					if j==1 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(2)
						item1.count = t
					elseif j==2 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(4)
						item1.count = t
					elseif j==3 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(1)
						item1.count = t
					else
						item1 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
						item1.count = v.itemCount1
					end
				end
			end
		end
		integralBar.vars.item1:hide()
		integralBar.vars.item2:hide()
		integralBar.vars.item3:hide()
		if item1 then
			integralBar.vars.item1:show()
			integralBar.vars.itemIcon1:setImage(i3k_db_icons[item1.icon].path)
			integralBar.vars.itemCount1:setText("x"..item1.count)
			local isLock = g_i3k_common_item_has_binding_icon(item1.id)
			if isLock then
				integralBar.vars.lock1:show()
			else
				integralBar.vars.lock1:hide()
			end
			integralBar.vars.item1:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item1.id))
		end
		if item2 then
			integralBar.vars.item2:show()
			integralBar.vars.itemIcon2:setImage(i3k_db_icons[item2.icon].path)
			integralBar.vars.itemCount2:setText("x"..item2.count)
			local isLock = g_i3k_common_item_has_binding_icon(item2.id)
			if isLock then
				integralBar.vars.lock2:show()
			else
				integralBar.vars.lock2:hide()
			end
			integralBar.vars.item2:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item2.id))
		end
		if item3 then
			integralBar.vars.item3:show()
			integralBar.vars.itemIcon3:setImage(i3k_db_icons[item3.icon].path)
			integralBar.vars.itemCount3:setText("x"..item3.count)
			local isLock = g_i3k_common_item_has_binding_icon(item3.id)
			if isLock then
				integralBar.vars.lock3:show()
			else
				integralBar.vars.lock3:hide()
			end
			integralBar.vars.item3:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item3.id))
		end
		
		integralBar.vars.takeBtn:hide()
		integralBar.vars.hadTaken:show()
		integralBar.vars.okLabel:setText("已领取")
		integralBar.vars.hadTaken:setTouchEnabled(false)
		local index
		for j,t in ipairs(f_rewardTable) do
			if v.minScore==t.minScore then
				index = j
				break
			end
		end
		integralBar.vars.jfImg:setImage(i3k_db_icons[f_integralImgG[index]].path)
		integralBar.vars.rewardRoot:setOpacityWithChildren(250*0.6)
		self._layout.vars.scroll:addItem(integralBar)
	end
	
	
	for i,v in pairs(rewardTable) do
		local integralBar = require("ui/widgets/jfjlt")()
		--integralBar.vars.needScore:setText(v.minScore)
		local item1
		local item2
		local item3
		local rewardItemTable = {v.bindMoney, v.arenaPoint, v.bindDiamond, v.itemId1}
		for j,t in ipairs(rewardItemTable) do
			if t~= 0 then
				if item1 then
					if item2 then
						if j==3 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item3.count = t
							break
						elseif j==2 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							self._arenaCoinRewardTable[v.minScore] = t
							item3.count = t
							break
						else
							item3 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item3.count = v.itemCount1
							break
						end
					else
						if j==3 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item2.count = t
						elseif j==2 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							self._arenaCoinRewardTable[v.minScore] = t
							item2.count = t
						else
							item2 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item2.count = v.itemCount1
						end
					end
				else
					if j==1 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(2)
						item1.count = t
					elseif j==2 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(4)
						self._arenaCoinRewardTable[v.minScore] = t
						item1.count = t
					elseif j==3 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(1)
						item1.count = t
					else
						item1 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
						item1.count = v.itemCount1
					end
				end
			end
		end
		integralBar.vars.item1:hide()
		integralBar.vars.item2:hide()
		integralBar.vars.item3:hide()
		local isEnoughTable = {}
		if item1 then
			integralBar.vars.item1:show()
			integralBar.vars.itemIcon1:setImage(i3k_db_icons[item1.icon].path)
			integralBar.vars.itemCount1:setText("x"..item1.count)
			local isLock = g_i3k_common_item_has_binding_icon(item1.id)
			if isLock then
				integralBar.vars.lock1:show()
			else
				integralBar.vars.lock1:hide()
			end
			integralBar.vars.item1:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item1.id))
			isEnoughTable[item1.id] = item1.count
		end
		if item2 then
			integralBar.vars.item2:show()
			integralBar.vars.itemIcon2:setImage(i3k_db_icons[item2.icon].path)
			integralBar.vars.itemCount2:setText("x"..item2.count)
			local isLock = g_i3k_common_item_has_binding_icon(item2.id)
			if isLock then
				integralBar.vars.lock2:show()
			else
				integralBar.vars.lock2:hide()
			end
			integralBar.vars.item2:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item2.id))
			isEnoughTable[item2.id] = item2.count
		end
		if item3 then
			integralBar.vars.item3:show()
			integralBar.vars.itemIcon3:setImage(i3k_db_icons[item3.icon].path)
			integralBar.vars.itemCount3:setText("x"..item3.count)
			local isLock = g_i3k_common_item_has_binding_icon(item3.id)
			if isLock then
				integralBar.vars.lock3:show()
			else
				integralBar.vars.lock3:hide()
			end
			integralBar.vars.item3:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item3.id))
			isEnoughTable[item3.id] = item3.count
		end
		
		local index
		for j,t in ipairs(f_rewardTable) do
			if v.minScore==t.minScore then
				index = j
				break
			end
		end
		integralBar.vars.jfImg:setImage(i3k_db_icons[f_integralImgY[index]].path)
		
		
		local needValue = {isEnoughTable = isEnoughTable, myScore = score, takenScores = takenScores}
		
		if score>=v.minScore then
			integralBar.vars.takeBtn:show()
			integralBar.vars.takeBtn:setTag(v.minScore+1000)
			integralBar.vars.takeBtn:onClick(self, self.takeAnnex, needValue)
			integralBar.vars.darkImg:hide()
			integralBar.vars.hadTaken:hide()
			--integralBar.vars.okLabel:hide()
		else
			integralBar.vars.takeBtn:hide()
			integralBar.vars.hadTaken:show()
			integralBar.vars.okLabel:setText("未达成")
			integralBar.rootVar:disableWithChildren()
			integralBar.vars.leftImg:hide()
			integralBar.vars.rightImg:hide()
		end
		if rewardTable[i+1] then
			if score>=v.minScore and score<rewardTable[i+1].minScore then
				integralBar.vars.rightImg:hide()
			end
		end
		self._layout.vars.scroll:addItem(integralBar)
	end
	
	local children = self._layout.vars.scroll:getAllChildren()
	children[1].vars.leftImg:hide()
	children[1].vars.leftdt:hide()
	children[#children].vars.rightImg:hide()
	children[#children].vars.rightdt:hide()
	if rewardTable then
		self._layout.vars.scroll:jumpToChildWithIndex(#hasTakenTable+1)
	end
end

function wnd_arenaIntegral:takeAnnex(sender, needValue)
	local score = sender:getTag()-1000
	local isEnough = g_i3k_game_context:IsBagEnough(needValue.isEnoughTable)
	if isEnough then
		local take = i3k_sbean.arena_takescore_req.new()
		take.arenaCoin = self._arenaCoinRewardTable[score]
		take.score = score
		take.minScore = score
		take.myScore = needValue.myScore
		take.takenScores = needValue.takenScores
		take.callback = function ()
			local totalRewards = {}
			for i,v in pairs(needValue.isEnoughTable) do
				local tmpReward = {id = i, count = v}
				table.insert(totalRewards, tmpReward)
			end
			g_i3k_ui_mgr:ShowGainItemInfo(totalRewards)
		end
		i3k_game_send_str_cmd(take, "arena_takescore_res")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end

function wnd_arenaIntegral:reload(score, myScore, takenScores)
	self._layout.vars.scroll:removeAllChildren()
	
	table.insert(takenScores, score)
	local rewardTable = {}
	for i,v in pairs(i3k_db_score_reward) do
		table.insert(rewardTable, v)
	end
	table.sort(rewardTable, function (a, b)
			return a.minScore<b.minScore
		end)
		
	local removeTable = {}
	for i,v in pairs(rewardTable) do
		for j,k in pairs(takenScores) do
			if v.minScore==k then
				table.insert(removeTable, i)
			end
		end
	end
	table.sort(removeTable, function (a, b)
		return a>b
	end)
	for i,v in pairs(removeTable) do
		table.remove(rewardTable, v)
	end
	
	------------------更新已经领取了的奖励
	local hasTakenTable = {}
	for i,v in pairs(takenScores) do
		local hasTakenReward = i3k_db_score_reward[v]
		table.insert(hasTakenTable, hasTakenReward)
	end
	table.sort(hasTakenTable, function (a, b)
			return a.minScore<b.minScore
		end)
	
	for i,v in pairs(hasTakenTable) do
		local integralBar = require("ui/widgets/jfjlt")()
		--integralBar.vars.needScore:setText(v.minScore)
		local item1
		local item2
		local item3
		local rewardItemTable = {v.bindMoney, v.arenaPoint, v.bindDiamond, v.itemId1}
		for j,t in ipairs(rewardItemTable) do
			if t~= 0 then
				if item1 then
					if item2 then
						if j==3 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item3.count = t
							break
						elseif j==2 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							item3.count = t
							break
						else
							item3 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item3.count = v.itemCount1
							break
						end
					else
						if j==3 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item2.count = t
						elseif j==2 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							item2.count = t
						else
							item2 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item2.count = v.itemCount1
						end
					end
				else
					if j==1 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(2)
						item1.count = t
					elseif j==2 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(4)
						item1.count = t
					elseif j==3 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(1)
						item1.count = t
					else
						item1 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
						item1.count = v.itemCount1
					end
				end
			end
		end
		integralBar.vars.item1:hide()
		integralBar.vars.item2:hide()
		integralBar.vars.item3:hide()
		if item1 then
			integralBar.vars.item1:show()
			integralBar.vars.itemIcon1:setImage(i3k_db_icons[item1.icon].path)
			integralBar.vars.itemCount1:setText("x"..item1.count)
			local isLock = g_i3k_common_item_has_binding_icon(item1.id)
			if isLock then
				integralBar.vars.lock1:show()
			else
				integralBar.vars.lock1:hide()
			end
			integralBar.vars.item1:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item1.id))
		end
		if item2 then
			integralBar.vars.item2:show()
			integralBar.vars.itemIcon2:setImage(i3k_db_icons[item2.icon].path)
			integralBar.vars.itemCount2:setText("x"..item2.count)
			local isLock = g_i3k_common_item_has_binding_icon(item2.id)
			if isLock then
				integralBar.vars.lock2:show()
			else
				integralBar.vars.lock2:hide()
			end
			integralBar.vars.item2:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item2.id))
		end
		if item3 then
			integralBar.vars.item3:show()
			integralBar.vars.itemIcon3:setImage(i3k_db_icons[item3.icon].path)
			integralBar.vars.itemCount3:setText("x"..item3.count)
			local isLock = g_i3k_common_item_has_binding_icon(item3.id)
			if isLock then
				integralBar.vars.lock3:show()
			else
				integralBar.vars.lock3:hide()
			end
			integralBar.vars.item3:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item3.id))
		end
		
		integralBar.vars.takeBtn:hide()
		integralBar.vars.hadTaken:show()
		integralBar.vars.okLabel:setText("已领取")
		integralBar.vars.hadTaken:setTouchEnabled(false)
		local index
		for j,t in ipairs(f_rewardTable) do
			if v.minScore==t.minScore then
				index = j
				break
			end
		end
		integralBar.vars.jfImg:setImage(i3k_db_icons[f_integralImgG[index]].path)
		integralBar.vars.rewardRoot:setOpacityWithChildren(250*0.6)
		self._layout.vars.scroll:addItem(integralBar)
	end
	
	------------------------------未领取和未达成领取了的奖励
	local hasNoTaken = false
	for i,v in pairs(rewardTable) do
		local integralBar = require("ui/widgets/jfjlt")()
		--integralBar.vars.needScore:setText(v.minScore)
		local item1
		local item2
		local item3
		local rewardItemTable = {v.bindMoney, v.arenaPoint, v.bindDiamond, v.itemId1}
		for j,t in ipairs(rewardItemTable) do
			if t~= 0 then
				if item1 then
					if item2 then
						if j==3 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item3.count = t
							break
						elseif j==2 then
							item3 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							item3.count = t
							break
						else
							item3 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item3.count = v.itemCount1
							break
						end
					else
						if j==3 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(1)
							item2.count = t
						elseif j==2 then
							item2 = g_i3k_db.i3k_db_get_base_item_cfg(4)
							item2.count = t
						else
							item2 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
							item2.count = v.itemCount1
						end
					end
				else
					if j==1 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(2)
						item1.count = t
					elseif j==2 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(4)
						item1.count = t
					elseif j==3 then
						item1 = g_i3k_db.i3k_db_get_base_item_cfg(1)
						item1.count = t
					else
						item1 = db.i3k_db_get_base_item_cfg(t) or db.i3k_db_get_other_item_cfg(t) or db.i3k_db_get_gem_item_cfg(t) or db.i3k_db_get_book_item_cfg(t) or db.i3k_db_get_equip_item_cfg(t)
						item1.count = v.itemCount1
					end
				end
			end
		end
		integralBar.vars.item1:hide()
		integralBar.vars.item2:hide()
		integralBar.vars.item3:hide()
		
		local isEnoughTable = {}
		if item1 then
			integralBar.vars.item1:show()
			integralBar.vars.itemIcon1:setImage(i3k_db_icons[item1.icon].path)
			integralBar.vars.itemCount1:setText("x"..item1.count)
			isEnoughTable[item1.id] = item1.count
			local isLock = g_i3k_common_item_has_binding_icon(item1.id)
			if isLock then
				integralBar.vars.lock1:show()
			else
				integralBar.vars.lock1:hide()
			end
			integralBar.vars.item1:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item1.id))
			
		end
		if item2 then
			integralBar.vars.item2:show()
			integralBar.vars.itemIcon2:setImage(i3k_db_icons[item2.icon].path)
			integralBar.vars.itemCount2:setText("x"..item2.count)
			isEnoughTable[item2.id] = item2.count
			local isLock = g_i3k_common_item_has_binding_icon(item2.id)
			if isLock then
				integralBar.vars.lock2:show()
			else
				integralBar.vars.lock2:hide()
			end
			integralBar.vars.item2:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item2.id))
		end
		if item3 then
			integralBar.vars.item3:show()
			integralBar.vars.itemIcon3:setImage(i3k_db_icons[item3.icon].path)
			integralBar.vars.itemCount3:setText("x"..item3.count)
			isEnoughTable[item3.id] = item3.count
			local isLock = g_i3k_common_item_has_binding_icon(item3.id)
			if isLock then
				integralBar.vars.lock3:show()
			else
				integralBar.vars.lock3:hide()
			end
			integralBar.vars.item3:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(item3.id))
		end
		
		local needValue = {isEnoughTable = isEnoughTable, myScore = myScore, takenScores = takenScores}
		local index
		for j,t in ipairs(f_rewardTable) do
			if v.minScore==t.minScore then
				index = j
				break
			end
		end
		integralBar.vars.jfImg:setImage(i3k_db_icons[f_integralImgY[index]].path)
		
		if myScore>=v.minScore then
			integralBar.vars.takeBtn:show()
			integralBar.vars.takeBtn:setTag(v.minScore+1000)
			integralBar.vars.takeBtn:onClick(self, self.takeAnnex, needValue)
			integralBar.vars.hadTaken:hide()
			integralBar.vars.darkImg:hide()
			hasNoTaken = true
		else
			integralBar.vars.takeBtn:hide()
			integralBar.vars.hadTaken:show()
			integralBar.vars.okLabel:setText("未达成")
			integralBar.rootVar:disableWithChildren()
			integralBar.vars.leftImg:hide()
			integralBar.vars.rightImg:hide()
		end
		
		
		if rewardTable[i+1] then
			if myScore>=v.minScore and myScore<rewardTable[i+1].minScore then
				integralBar.vars.rightImg:hide()
			end
		end
		self._layout.vars.scroll:addItem(integralBar)
	end
	g_i3k_game_context:setArenaInteralRed(hasNoTaken)--判断竞技场积分红点是否显示
	
	local children = self._layout.vars.scroll:getAllChildren()
	children[1].vars.leftImg:hide()
	children[1].vars.leftdt:hide()
	children[#children].vars.rightdt:hide()
	children[#children].vars.rightImg:hide()
	if rewardTable then
		self._layout.vars.scroll:jumpToChildWithIndex(#hasTakenTable+1)
	end
end

function wnd_arenaIntegral:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaIntegral)
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaIntegral.new();
		wnd:create(layout, ...);

	return wnd;
end
