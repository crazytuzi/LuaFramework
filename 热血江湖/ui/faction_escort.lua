-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_escort = i3k_class("wnd_faction_escort", ui.wnd_base)

local up_icon = {174,175,176}
local rankTable = {[1] = 2718, [2] = 2719, [3] = 2720}
local rankBottom = {[1] = 8574, [2] = 8575, [3] = 8576}
local IMGAEID = 8577

--数据整除
DIVIDE_NUMBER1 = 100
DIVIDE_NUMBER2 = 10

--万分比
local THOU = 10000

local YUNBIAOT = "ui/widgets/yunbiaot"
local YUNBIAOTASK = "ui/widgets/yunbiaot5"

function wnd_faction_escort:ctor()
	
	self._wish_exp_args = 0
	self._wish_money_args = 0

end

function wnd_faction_escort:showTab(index)
	for k,v in ipairs(self.tabs) do
		if k == index then
			v.btn:stateToPressed()
			v.root:show()
		else
			v.btn:stateToNormal()
			v.root:hide()
		end
	end
end

function wnd_faction_escort:onUpdateSkin(showSkinId, notResort)--不重新排序
	self:showTab(3)
	local skinPropScroll = self._layout.vars.skinPropScroll
	local skinScroll = self._layout.vars.skinScroll
	skinScroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	local config = i3k_db_escort_skin
	local skinData = g_i3k_game_context:GetFactionEscortSkin()
	
	local showIndex = function (id)
		local _config = config[id]
		skinPropScroll:removeAllChildren()
		
		if _config.awardType == 0 then
			local _item = require("ui/widgets/yunbiaot4")()
			_item.vars.propertyName:setText(_config.desc)
			skinPropScroll:addItem(_item)
		end
		
		if _config.awardType == 1 then
			local _item = require("ui/widgets/yunbiaot3")()
			_item.vars.propertyName:setText("经验")
			_item.vars.propertyValue:setText("+" .. _config.awardNum / 100 .. "%")
			skinPropScroll:addItem(_item)
		end
		
		local carModule = self._layout.vars.module
		ui_set_hero_model(carModule, _config.moduleId)
		carModule:setRotation(_config.rotate)
		
		self._layout.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(_config.icon))
		
		for k,v in ipairs(skinScroll:getAllChildren()) do
			if v.escort_id == id then
				v.vars.back:setImage(g_i3k_db.i3k_db_get_icon_path(706))
				v.vars.nameBg:setImage(g_i3k_db.i3k_db_get_icon_path(5196))
				v.vars.name:setTextColor("ffe21b1b")
			else
				v.vars.back:setImage(g_i3k_db.i3k_db_get_icon_path(707))
				v.vars.nameBg:setImage(g_i3k_db.i3k_db_get_icon_path(5195))
				v.vars.name:setTextColor("ff924c12")
			end
		end
		
		self._layout.vars.useBtn:setVisible(false)
		self._layout.vars.enableBtn:setVisible(false)
		
		self._layout.vars.propBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(_config.propId))
		self._layout.vars.propIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(_config.propId,i3k_game_context:IsFemaleRole()))
		self._layout.vars.propBtn:onClick(self,function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(_config.propId)
		end)
		
		local ItemName = g_i3k_db.i3k_db_get_common_item_name(_config.propId)
		self._layout.vars.propNum:setText(ItemName .. "X" ..  _config.propNum)
		self._layout.vars.propNum:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCount(_config.propId)>=_config.propNum))
		
		self._layout.vars.enable:onClick(self,function ()
			local count = g_i3k_game_context:GetCommonItemCount(_config.propId)
			if count <  _config.propNum then
				g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
				return
			end
			i3k_sbean.sect_deliver_skin_unlock(id,function ()
				g_i3k_game_context:UseCommonItem(_config.propId,_config.propNum)
				g_i3k_game_context:SetFactionEscortUnlockSkin(id)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"onUpdateSkin",id, true)
			end)
		end)
		
		self._layout.vars.useBtn:onClick(self,function ()
			i3k_sbean.sect_deliver_skin_select(id)
		end)

		if id == skinData.curId then
			self._layout.vars.isUse:setVisible(true)
		else
			self._layout.vars.isUse:setVisible(false)
			if skinData.unlockIds[id] or _config.rule == 0 then
				self._layout.vars.useBtn:setVisible(true)				
			else
				self._layout.vars.enableBtn:setVisible(true)
			end
		end
	end
	
	skinScroll:removeAllChildren()
	self.sort_cfg = notResort and self.sort_cfg or self:getSortedCfg(config,skinData)

	for k,v in ipairs(self.sort_cfg) do
		local _item = require("ui/widgets/yunbiaot2")()
		_item.vars.name:setText(v.name)
		_item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.openIcon))
		_item.escort_id = v.id
		if v.id == skinData.curId then
			_item.vars.isUse:setVisible(true)
		else
			_item.vars.isUse:setVisible(false)
		end
		
		if not skinData.unlockIds[v.id] and config[v.id].rule ~= 0 then
			_item.vars.red:setVisible(g_i3k_game_context:GetCommonItemCount(v.propId) >= v.propNum)
		end
		
		_item.vars.btn:onClick(self,function ()
			showIndex(v.id)
		end)
		
		skinScroll:addItem(_item)
	end
	
	showIndex(showSkinId or 1)
end
function wnd_faction_escort:getSortedCfg(config, skinData)
	local sort_cfg = {}
	for i, v in ipairs(config) do
		table.insert(sort_cfg, v)
	end
	for i, v in ipairs(sort_cfg) do
		local total = v.id
		local isHave = skinData.unlockIds[v.id]
		local isCanActive = not isHave and v.rule ~= 0 and g_i3k_game_context:GetCommonItemCount(v.propId) >= v.propNum
		local isCur = v.id == skinData.curId
		total = total + (isCanActive and -10000 or 0)
		total = total + (isCur and -1000 or 0)
		total = total + (isHave and -100 or 0)
		v.sortID = total
	end
	table.sort(sort_cfg, function(a,b)
		return a.sortID < b.sortID
	end)
	return sort_cfg
end

function wnd_faction_escort:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.escort_root = self._layout.vars.escort_root 
	self.wish_root = self._layout.vars.wish_root
	self.tabs = {
		{btn=self._layout.vars.escort_btn,root=self._layout.vars.escort_root},
		{btn=self._layout.vars.wish_btn,root=self._layout.vars.wish_root},		
		{btn=self._layout.vars.skin_btn,root=self._layout.vars.skin_root},
	}
	
	self.wish_btn = self._layout.vars.wish_btn 
	self.wish_btn:onClick(self,self.onWish)
	self.escort_btn = self._layout.vars.escort_btn
	self.escort_btn:onClick(self,self.onEscort)
	self:showTab(1)
	
	self._layout.vars.skin_btn:onClick(self,function ()
		self:onUpdateSkin()
	end)
	
	local refresh_btn = self._layout.vars.refresh_btn 
	refresh_btn:onClick(self,self.onRefresh)
	
	
	self.model = self._layout.vars.model 
	
		
		
		
		
		
		
	
	self.wish_rank = self._layout.vars.wish_rank 
	self.user_wish_btn = self._layout.vars.user_wish_btn 
	self.user_wish_btn:onClick(self,self.onUserWish)
	self.save_btn = self._layout.vars.save_btn 
	self.save_btn:hide()
	self.save_btn:onClick(self,self.onSaveWish)
	
	self.money_icon = self._layout.vars.money_icon 
	self.money_suo = self._layout.vars.money_suo 
	self.money_count = self._layout.vars.money_count 
	
	self.old_exp = self._layout.vars.old_exp 
	self.new_exp = self._layout.vars.new_exp 
	self.exp_up_icon = self._layout.vars.exp_up_icon 
	
	self.old_coin = self._layout.vars.old_coin 
	self.new_coin = self._layout.vars.new_coin 
	self.coin_up_icon = self._layout.vars.coin_up_icon 
	
	self.old_blood = self._layout.vars.old_blood 
	self.new_blood = self._layout.vars.new_blood 
	self.blood_up_icon = self._layout.vars.blood_up_icon 
	
	self.wish_rank = self._layout.vars.wish_rank 
	
	self.model = self._layout.vars.model 
	
	self._layout.vars.rob_task_btn:onClick(self,self.onRobEscort) 
	self._layout.vars.luck_draw_btn:onClick(self,self.onLuckDraw)
	
	
	
	self.escort_times = self._layout.vars.escort_times 

	local have_times = g_i3k_game_context:GetFactionEscortRobTimes()

	self.model = self._layout.vars.model 
	self:updateModel(155)
	self.quick_btn = self._layout.vars.quick_btn
	self.quick_btn:onTouchEvent(self, self.onQuickBtnTouch)
	self.quick_num = self._layout.vars.quick_num
	self.quick_desc = self._layout.vars.quick_desc
	self.quick_desc:setText(i3k_get_string(18543))
	self.quick_panel = self._layout.vars.quick_panel
	self.quick_panel:setVisible(false)
	self.quick_img = self._layout.vars.quick_img
	self.quick_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_escort.escort_args.iconID))
end

function wnd_faction_escort:onShow()
	
end




function wnd_faction_escort:refresh(data,wishTimes,wishData)
	self._wish_exp_args = wishData.exp
	self._wish_money_args = wishData.money
	self:updateEscortData(data)
	self:updateWishMoney(wishTimes)
	self:refreshEscortData()
end 
function wnd_faction_escort:refreshEscortData()
	local have_tiem = g_i3k_game_context:GetFactionEscortAccTimes()
	local str = string.format("每日运镖次数：%s/%s",i3k_db_escort.escort_args.escort_count - have_tiem,i3k_db_escort.escort_args.escort_count)
	self.escort_times:setText(str)
	local quickCardNum = g_i3k_game_context:GetEscortQuickCard()
	self.quick_num:setText(i3k_get_string(18542, quickCardNum))
end 

function wnd_faction_escort:onRobEscort(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionEscortRobStore)
end 


function wnd_faction_escort:onLuckDraw(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionEscortLuckDraw)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionEscortLuckDraw)
end 

function wnd_faction_escort:onEscort(sender,eventType)
	
	i3k_sbean.sect_escort_data()
end 

function wnd_faction_escort:onWish(sender,eventType)
	
	i3k_sbean.escort_wish_sync()
end 

function wnd_faction_escort:onRefresh(sender)
	local fun = (function(ok)
		if ok then
			i3k_sbean.refresh_escort()
		end
	end)
	local refreshTimes = g_i3k_game_context:GetFactionEscortRefreshTimes()
	if refreshTimes >= g_MAX_REFRESH_TIMES then
		g_i3k_ui_mgr:PopupTipMessage("本日刷新次数已满")
		return 
	end 
	local need_ingot = 0
	if i3k_db_escort.escort_args.refresh_escort[refreshTimes + 1] then
		need_ingot = i3k_db_escort.escort_args.refresh_escort[refreshTimes + 1]
	else
		need_ingot = i3k_db_escort.escort_args.refresh_escort[#i3k_db_escort.escort_args.refresh_escort]
	end
	if need_ingot ~= 0 then
		local have_coin = g_i3k_game_context:GetDiamondCanUse(false)
		local bCoin = g_i3k_game_context:GetDiamond(false)
		local fCoin = g_i3k_game_context:GetDiamond(true)
		if fCoin + bCoin < need_ingot then
			local desc = i3k_get_string(548)
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return 
		else
			local desc = i3k_get_string(15164,need_ingot,g_MAX_REFRESH_TIMES - refreshTimes )
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		end 
		
		
	else
		i3k_sbean.refresh_escort()
	end
end 

function wnd_faction_escort:onSure(sender)
	
	local serverTime = i3k_integer(i3k_game_get_time())
	
	for i=1,#i3k_db_escort.escort_args.ensure_time,2 do 
		if g_i3k_get_day_time(i3k_db_escort.escort_args.ensure_time[i]) < serverTime and 
			serverTime < g_i3k_get_day_time(i3k_db_escort.escort_args.ensure_time[i+1]) then
			local desc = i3k_get_string(547)
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return 
		end
	end
	
	local have_coin = g_i3k_game_context:GetDiamondCanUse(false)
	if have_coin < i3k_db_escort.escort_args.ensure_count then
		local desc = i3k_get_string(546)
		g_i3k_ui_mgr:PopupTipMessage(desc)
		return 
	end 
	
	local fun = (function(ok)
		if ok then
			i3k_sbean.escort_protect()
		end
	end)
	local desc = i3k_get_string(540,i3k_db_escort.escort_args.ensure_count)
	g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
end 

function wnd_faction_escort:updateWishMoney(times)
	local need_money = 0
	if i3k_db_escort.escort_args.wish_ingot[times + 1] then
		need_money = i3k_db_escort.escort_args.wish_ingot[times + 1]
	else
		need_money = i3k_db_escort.escort_args.wish_ingot[#i3k_db_escort.escort_args.wish_ingot]
	end
	self.money_count:setText(need_money)
end 

function wnd_faction_escort:updateEscortData(data)
	self:showTab(1)
	local t = data or {}
	local widget = self._layout.vars	
	widget.taskScoll:removeAllChildren()
	for k,v in ipairs(t) do
		
		local cfg = i3k_db_escort_task[v.id] 
	
		local exp_cfg = g_i3k_db.i3k_db_get_level_cfg(g_i3k_game_context:GetLevel())
		local exp_base = math.modf(cfg.exp/THOU * exp_cfg.escort_exp)
		local coin_base = math.modf(cfg.coin/THOU * exp_cfg.escort_coin)
		
		local car_cfg = i3k_db_escort_car[cfg.car_quality]
		local exp_str = string.format("×%s", exp_base)
		local tmp_str = string.format("×%s", coin_base)	
		local layer = require(YUNBIAOTASK)()
		local wid = layer.vars
		wid.bg:setImage(g_i3k_get_icon_frame_path_by_rank(car_cfg.quality))
		wid.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon_id))
		wid.des:setText(cfg.name)
		wid.des:setTextColor(g_i3k_get_color_by_rank(car_cfg.quality))
		wid.exp:setText(exp_str)
		wid.money:setText(tmp_str)
		wid.go:enableWithChildren()
		wid.go:onClick(self, self.onGoEscort, v.id)
		if v.flag == 1 then
			wid.go:disableWithChildren()
		end
		
		widget.taskScoll:addItem(layer)
	end
	
	local have_tiem = g_i3k_game_context:GetFactionEscortAccTimes()
	local str = string.format("每日运镖次数：%s/%s",i3k_db_escort.escort_args.escort_count - have_tiem,i3k_db_escort.escort_args.escort_count)
	self.escort_times:setText(str)
end 

function wnd_faction_escort:updateModel(id)
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self.model:setSprite(path)
	self.model:setSprSize(uiscale)
	self.model:playAction("stand")
end 

function wnd_faction_escort:onGoEscort(sender,id)
	local nowtime  = i3k_game_get_time()
	double_time_start = {}
	double_time_end = {}
	for i,v in ipairs(i3k_db_escort.escort_args.double_time) do
		if i % 2 == 1 then
			table.insert(double_time_start,v)
		else
			table.insert(double_time_end,v)
		end
	end
	local inTime = false
	for i,v in ipairs(double_time_start) do
		if nowtime >= g_i3k_get_day_time(v) and nowtime < g_i3k_get_day_time(double_time_end[i]) then
			inTime = true
			break
		end
	end
	if not inTime then
		g_i3k_ui_mgr:OpenUI(eUIID_YunbiaoTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_YunbiaoTips,function()
			self:onGoEscort2(id)
		end)
	else
		self:onGoEscort2(id)
	end
end
function wnd_faction_escort:onGoEscort2(id)
	local taskId = g_i3k_game_context:GetEscortRobState()
	if taskId ~= 0 then
		local tmp_str = i3k_get_string(553)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end 
	local taskId = g_i3k_game_context:GetFactionEscortTaskId()
	if taskId ~= 0 then
		local desc = i3k_get_string(563)
		g_i3k_ui_mgr:PopupTipMessage(desc)
		return 
	end 
	local coutn = i3k_db_escort.escort_args.escort_count
	
	local have_count = g_i3k_game_context:GetFactionEscortAccTimes()
	
	if have_count >= coutn then
		local tmp_str = i3k_get_string(543)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end
	g_i3k_ui_mgr:OpenUI(eUIID_FactionEscortPath)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionEscortPath,id,self._wish_exp_args,self._wish_money_args)
end 

function wnd_faction_escort:onUserWish(sender)
	
	local times = g_i3k_game_context:GetFactionEscortTimes()
	if times >= g_MAX_REFRESH_TIMES then
		g_i3k_ui_mgr:PopupTipMessage("本日刷新次数已满")
		return
	end 
	local need_money = 0
	if i3k_db_escort.escort_args.wish_ingot[times + 1] then
		need_money = i3k_db_escort.escort_args.wish_ingot[times + 1]
	else
		need_money = i3k_db_escort.escort_args.wish_ingot[#i3k_db_escort.escort_args.wish_ingot]
	end

	local have_money = g_i3k_game_context:GetDiamondCanUse(false)
	if have_money < need_money then
		local desc = i3k_get_string(549)
		g_i3k_ui_mgr:PopupTipMessage(desc)
		return
	end
	local fun = (function(ok)
		if ok then
			i3k_sbean.escort_wish()
		end
	end)
	local tmp = g_MAX_REFRESH_TIMES - times
	local desc = i3k_get_string(15163,need_money,g_MAX_REFRESH_TIMES - times )
	g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	--self.save_btn:show()
end 

function wnd_faction_escort:updateSaveBtn(btnType)
	self.save_btn:setVisible(btnType)
end 

function wnd_faction_escort:onSaveWish(sender)
	i3k_sbean.escort_wish_save()
end 

function wnd_faction_escort:updateWishData(data)
	self:showTab(2)
	self._wish_exp_args = data.exp
	self._wish_money_args = data.money
	local tmp_str = string.format("+%s%%", math.modf(data.exp/DIVIDE_NUMBER2))
	self.old_exp:setText(tmp_str)
	local tmp_str = string.format("+%s%%",math.modf(data.money/DIVIDE_NUMBER2))
	self.old_coin:setText(tmp_str)
	local tmp_str = string.format("+%s%%",math.modf(data.hp/DIVIDE_NUMBER2))
	self.old_blood:setText(tmp_str)
	local tmp1 = math.modf(data.expTo/DIVIDE_NUMBER2)/DIVIDE_NUMBER1
	local tmp2 = math.modf(data.exp/DIVIDE_NUMBER2)/DIVIDE_NUMBER1
	
	local tmp3 = math.modf(data.moneyTo/DIVIDE_NUMBER2)/DIVIDE_NUMBER1
	local tmp4 = math.modf(data.money/DIVIDE_NUMBER2)/DIVIDE_NUMBER1
	
	local tmp5 = math.modf(data.hpTo/DIVIDE_NUMBER2)/DIVIDE_NUMBER1
	local tmp6 = math.modf(data.hp/DIVIDE_NUMBER2)/DIVIDE_NUMBER1
	self:updateSaveBtn(tmp1 > tmp2 or tmp3 > tmp4  or tmp5 > tmp6  )
	self.new_exp:setVisible(data.expTo ~= 0)
	local tmp_str = string.format("+%s%%", math.modf(data.expTo/DIVIDE_NUMBER2))
	self.new_exp:setText(tmp_str)
	self.exp_up_icon:setVisible(data.expTo ~= 0)
	self.exp_up_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self:getUpIcon(math.modf(data.expTo/DIVIDE_NUMBER2)/DIVIDE_NUMBER1,math.modf(data.exp/DIVIDE_NUMBER2)/DIVIDE_NUMBER1)))
	
	self.new_coin:setVisible(data.moneyTo ~= 0)
	local tmp_str = string.format("+%s%%", math.modf(data.moneyTo/DIVIDE_NUMBER2))
	self.new_coin:setText(tmp_str)
	self.coin_up_icon:setVisible(data.moneyTo ~= 0)
	self.coin_up_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self:getUpIcon(math.modf(data.moneyTo/DIVIDE_NUMBER2)/DIVIDE_NUMBER1,math.modf(data.money/DIVIDE_NUMBER2)/DIVIDE_NUMBER1)))	
	self.new_blood:setVisible(data.hpTo ~= 0)
	local tmp_str = string.format("+%s%%", math.modf(data.hpTo/DIVIDE_NUMBER2))
	self.new_blood:setText(tmp_str)
	self.blood_up_icon:setVisible(data.hpTo ~= 0)
	self.blood_up_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self:getUpIcon(math.modf(data.hpTo/DIVIDE_NUMBER2)/DIVIDE_NUMBER1,math.modf(data.hp/DIVIDE_NUMBER2)/DIVIDE_NUMBER1)))
	
end 

function wnd_faction_escort:getUpIcon(new_value,old_value)
	if new_value > old_value then
		return up_icon[1]
	elseif new_value < old_value then
		return up_icon[2]
	else
		return up_icon[3]
	end
end 


function wnd_faction_escort:updateRank(data)
	self.wish_rank:removeAllChildren()
	for k,v in ipairs(data) do
		local _layer = require("ui/widgets/yunbiaozft")()  
		local wid = _layer.vars
		local rankImg = wid.rankImg 
		local rankLabel = wid.rankLabel 
		local name = wid.name 
		local postion = wid.postion
		local times = wid.times 
		local bottom = wid.bottom
		name:setText(v.name)
		times:setText(v.wishTimes)
		
		if v.job == eFactionOwner then
			postion:setText("帮主")
		elseif v.job == eFactionSencondOwner then
			postion:setText("副帮主")
		elseif v.job == eFactionElder then
			postion:setText("长老")
		elseif v.job == eFactionElite then
			postion:setText("精英")
		elseif v.job == eFactionPeple then
			postion:setText("成员")
		end
		rankLabel:hide()
		rankImg:show()
		if k == 1 then
			rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(rankTable[1]))
			bottom:setImage(g_i3k_db.i3k_db_get_icon_path(rankBottom[1]))
		elseif k == 2 then
			rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(rankTable[2]))
			bottom:setImage(g_i3k_db.i3k_db_get_icon_path(rankBottom[2]))
		elseif k == 3 then
			rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(rankTable[3]))
			bottom:setImage(g_i3k_db.i3k_db_get_icon_path(rankBottom[3]))
		else
			rankLabel:setText(k)
			rankLabel:show()
			rankImg:hide()
			bottom:setImage(g_i3k_db.i3k_db_get_icon_path(IMGAEID))
		end

		self.wish_rank:addItem(_layer)
	end
	self._layout.vars.noWish:setVisible(#data == 0)
end 

function wnd_faction_escort:onQuickBtnTouch(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self.quick_panel:setVisible(true)
	elseif eventType ~= ccui.TouchEventType.moved then
		self.quick_panel:setVisible(false)
	end
end
function wnd_create(layout, ...)
	local wnd = wnd_faction_escort.new();
		wnd:create(layout, ...);

	return wnd;
end

