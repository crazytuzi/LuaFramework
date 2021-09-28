-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_escort_path = i3k_class("wnd_faction_escort_path", ui.wnd_base)

local XZLXT = "ui/widgets/xzlxt"

--数据整除
local DIVIDE_NUMBER1 = 100
local DIVIDE_NUMBER2 = 10
--万分比
local THOU = 10000
--奖励计算公式 奖励 = 基础奖励 *(1 + 帮派祝福系数 + 运镖黄金时间系数)


function wnd_faction_escort_path:ctor()
	self._path_root = {}
	self._task_id = 0
	self._path_id = 0
	
	self._wish_exp_args = 0
	self._wish_money_args = 0
	
	self._select_bg = nil 
	self._select_icon = nil 
	self._auton_icon_id = 0
end

function wnd_faction_escort_path:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local continue_btn = self._layout.vars.continue_btn 
	
	for i=1,3 do
		local tmp_icon = string.format("path_icon%s",i)
		local path_icon = self._layout.vars[tmp_icon]
		
		local tmp_name = string.format("path_name%s",i)
		local path_name = self._layout.vars[tmp_name]
		
		local tmp_desc = string.format("path_desc%s",i)
		local path_desc = self._layout.vars[tmp_desc]
		
		local tmp_btn = string.format("path_btn%s",i)
		local path_btn = self._layout.vars[tmp_btn]
		
		self._path_root = {path_icon = path_icon,path_name = path_name,path_desc = path_desc,path_btn = path_btn} 
	end
	
	self.path_scroll = self._layout.vars.path_scroll 
	
	self.start_btn = self._layout.vars.start_btn 
	self.start_btn:onClick(self,self.onStartEscort)
	
	self.base_award = self._layout.vars.base_award 
	self.exp_count = self._layout.vars.exp_count 
	self.money_count = self._layout.vars.money_count 
	
	self.wish_time = self._layout.vars.wish_time 
	self.wish_exp = self._layout.vars.wish_exp 
	self.wish_money = self._layout.vars.wish_money 
	
	self.sure_btn = self._layout.vars.sure_btn 
	self.sure_btn:onClick(self,self.onSure)
	
	self.vit_count = self._layout.vars.vit_count 
	self.vit_count:setText("×"..i3k_db_escort.escort_args.vit_count)
	
	self.have_vit = self._layout.vars.have_vit 
	self.quick_btn = self._layout.vars.quick_btn
	self.quick_btn:onClick(self, self.onQuickBtnClick)
	self.quick_num = self._layout.vars.quick_num
	self.quick_num:setText(string.format("x%d", i3k_db_escort.escort_args.need_card_num))
	self.quick_img = self._layout.vars.quick_img
	self.quick_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_escort.escort_args.iconID))
end

function wnd_faction_escort_path:onShow()
	
end

function wnd_faction_escort_path:updateUserVit(count,maxCount)
	self.have_vit:setText(string.format("%s/%s",count,maxCount))
end 

function wnd_faction_escort_path:onSure(sender)
	
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
	--local desc = i3k_get_string(540,i3k_db_escort.escort_args.ensure_count)
	--g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	
	local have_coin = g_i3k_game_context:GetDiamondCanUse(false)
		local bCoin = g_i3k_game_context:GetDiamond(false)
		local fCoin = g_i3k_game_context:GetDiamond(true)
		if fCoin + bCoin < i3k_db_escort.escort_args.ensure_count then
			local desc = i3k_get_string(546)
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return 
		else
			if bCoin >= i3k_db_escort.escort_args.ensure_count then
				local desc = string.format("确定消耗<c=green>%s</c>绑定元宝投保镖车？",i3k_db_escort.escort_args.ensure_count)
				g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			else
				if bCoin ~= 0 then
					local lastValue = i3k_db_escort.escort_args.ensure_count - bCoin
					local desc = string.format("确定消耗<c=green>%s</c>绑定元宝和<c=green>%s</c>元宝投保镖车？",bCoin,lastValue)
					g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
				else
					local desc = string.format("确定消耗<c=green>%s</c>元宝投保镖车？",i3k_db_escort.escort_args.ensure_count)
					g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
				end 
			end
		end 
end 

function wnd_faction_escort_path:refresh(id,wish_exp,wish_money)
	self._task_id = id
	self._wish_exp_args = wish_exp
	self._wish_money_args = wish_money
	self:updatePathData(i3k_db_escort_path)
	self:updateData()
	self:updateUserVit(g_i3k_game_context:GetVit(),g_i3k_game_context:GetVitMax())
end 

function wnd_faction_escort_path:updateData()
	local cfg = i3k_db_escort_task[self._task_id]
	
	local exp_cfg = g_i3k_db.i3k_db_get_level_cfg(g_i3k_game_context:GetLevel())
	local exp_base = math.modf(cfg.exp/THOU * exp_cfg.escort_exp)
	local coin_base = math.modf(cfg.coin/THOU * exp_cfg.escort_coin)
	local serverTime = i3k_integer(i3k_game_get_time())
	local doubel_args = 0
	for i=1,#i3k_db_escort.escort_args.double_time,2 do 
		if g_i3k_get_day_time(i3k_db_escort.escort_args.double_time[i]) < serverTime and 
			serverTime < g_i3k_get_day_time(i3k_db_escort.escort_args.double_time[i+1]) then
			doubel_args = i3k_db_escort.escort_args.double_award_args /10000
		end
	end
	local wish_exp = exp_base * ( (self._wish_exp_args/DIVIDE_NUMBER2)/DIVIDE_NUMBER1 + doubel_args + 1)
	local wish_coin = coin_base * ((self._wish_money_args/DIVIDE_NUMBER2)/DIVIDE_NUMBER1 + doubel_args + 1)
	wish_exp = math.modf(wish_exp)
	wish_coin = math.modf(wish_coin)
	self.base_award:setText(cfg.name)
	local car_cfg = i3k_db_escort_car[cfg.car_quality]
	self.base_award:setTextColor(g_i3k_get_color_by_rank(car_cfg.quality))
	local tmp_str = string.format("%s(%s)",exp_base,wish_exp)
	self.exp_count:setText(tmp_str)
	local tmp_str = string.format("%s(%s)",coin_base,wish_coin)
	self.money_count:setText(tmp_str)
	
	
	local tmp_str = doubel_args*100
	tmp_str = string.format("+%s%%",tmp_str)
	self.wish_time:setText(tmp_str)
	local tmp_str = math.modf(self._wish_exp_args/DIVIDE_NUMBER2)
	tmp_str = string.format("+%s%%",tmp_str)
	self.wish_exp:setText(tmp_str)
	local tmp_str = math.modf(self._wish_money_args/DIVIDE_NUMBER2)
	tmp_str = string.format("+%s%%",tmp_str)
	self.wish_money:setText(tmp_str)
end 

function wnd_faction_escort_path:updatePathData(dara)
	self.path_scroll:removeAllChildren()
	for k,v in ipairs(dara) do
		local _layer = require(XZLXT)()
		local path_icon = _layer.vars.path_icon 
		local path_pos = _layer.vars.path_pos 
		local path_name = _layer.vars.path_name 
		local path_btn = _layer.vars.path_btn 
		local select_bg = _layer.vars.select_bg 
		select_bg:hide()
		
		path_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon_id))
		path_name:setText(v.path_name)
		
		local start_name = i3k_db_dungeon_base[v.start_id].name
		local end_name = i3k_db_dungeon_base[v.end_id].name
		
		local temp_str = string.format("%s至%s",start_name,end_name)
		path_pos:setText(temp_str)
		if self._path_id == 0 then
			self._path_id = v.id
			path_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.select_icon_id))
			self._select_icon = path_icon
			self._auton_icon_id = v.icon_id
		end
		local tmp = {id = v.id,select_bg = select_bg,path_icon = path_icon,auto_icon = v.icon_id,select_icon = v.select_icon_id}
		path_btn:onClick(self,self.onSelectPath,tmp)
		
		self.path_scroll:addItem(_layer)
	end
	
end 

function wnd_faction_escort_path:onSelectPath(sender,tmp)
	if self._select_bg then
		self._select_bg:hide()
	end
	self._select_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self._auton_icon_id))
	self._select_icon = tmp.path_icon
	self._select_icon:setImage(g_i3k_db.i3k_db_get_icon_path(tmp.select_icon))
	self._auton_icon_id = tmp.auto_icon
	self._select_bg = tmp.select_bg
	self._select_bg:show()
	self._path_id = tmp.id
end 

function wnd_faction_escort_path:onStartEscort(sender)
	if self._path_id == 0 then
		g_i3k_ui_mgr:PopupTipMessage("请选择运镖路线")
		return 
	end
	
	local coutn = i3k_db_escort.escort_args.escort_count
	
	local have_count = g_i3k_game_context:GetFactionEscortAccTimes()
	
	if have_count >= coutn then
		local tmp_str = i3k_get_string(543)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end
	
	
	local need_vit = i3k_db_escort.escort_args.vit_count
	
	local have_count = g_i3k_game_context:GetVit()
	if have_count < need_vit then
		g_i3k_logic:GotoOpenBuyVitUI()
		return 
	end
	
	local taskId = g_i3k_game_context:GetEscortRobState()
	if taskId ~= 0 then
		local tmp_str = i3k_get_string(553)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end 
	
	local function func()
		i3k_sbean.escort_begin(self._path_id, self._task_id)
	end
	g_i3k_game_context:CheckMulHorse(func)
end 

function wnd_faction_escort_path:onQuickBtnClick(sender)
	local cardNum = g_i3k_game_context:GetEscortQuickCard()
	local function fun(isOk)
		if isOk then
			i3k_sbean.escort_quick_finish(self._task_id)
		end
	end
	if cardNum >= i3k_db_escort.escort_args.need_card_num then
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18544, cardNum, i3k_db_escort.escort_args.need_card_num, i3k_db_escort.escort_args.get_card_num),fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18545))
	end
end
--[[function wnd_faction_escort_path:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionEscortPath)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_escort_path.new();
		wnd:create(layout, ...);

	return wnd;
end

