-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dine = i3k_class("wnd_faction_dine", ui.wnd_base)

local LAYER_QKCFT = "ui/widgets/qkcft"


function wnd_faction_dine:ctor()
	self._type = 1
end


function wnd_faction_dine:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	local start_btn1 = self._layout.vars.start_btn1 
	start_btn1:onTouchEvent(self,self.onStart)
	local start_btn2 = self._layout.vars.start_btn2 
	start_btn2:onTouchEvent(self,self.onStart1)
	--self.btn1_mark = self._layout.vars.cSelectIcon
	--self.btn1_mark:show()
	--local select1_btn = self._layout.vars.select1_btn 
	--select1_btn:onTouchEvent(self,self.onSelectCommon)
	--self.btn2_mark = self._layout.vars.gSelectIcon
--	self.btn2_mark:hide()
	--local select2_btn = self._layout.vars.select2_btn 
	--select2_btn:onTouchEvent(self,self.onSelectGrand)
	--local cName = self._layout.vars.cName 
	--local gName = self._layout.vars.gName 
--cName:setText(i3k_db_faction_dine[1].name)
	--gName:setText(i3k_db_faction_dine[2].name)
	
	local cType = i3k_db_faction_dine[1].moneyType
	local cMoneyIcon = self._layout.vars.cMoneyIcon 
	cMoneyIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cType,i3k_game_context:IsFemaleRole()))
	local cSuoIcon = self._layout.vars.cSuoIcon 
	if cType > 0 then
		cSuoIcon:show()
	else
		cSuoIcon:hide()
	end
	local cMoneyCount = self._layout.vars.cMoneyCount 
	cMoneyCount:setText(i3k_db_faction_dine[1].moneyCount)
	
	local gType = i3k_db_faction_dine[2].moneyType
	local gMoneyIcon = self._layout.vars.gMoneyIcon 
	gMoneyIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(gType,i3k_game_context:IsFemaleRole()))
	local gSuoIcon = self._layout.vars.gSuoIcon 
	if gType > 0 then
		gSuoIcon:show()
	else
		gSuoIcon:hide()
	end
	
	local gMoneyCount = self._layout.vars.gMoneyCount 
	gMoneyCount:setText(i3k_db_faction_dine[2].moneyCount)
	self.desc_scroll1 = self._layout.vars.desc_scroll1 
	self.desc_scroll2 = self._layout.vars.desc_scroll2 
end

function wnd_faction_dine:onShow()
end

function wnd_faction_dine:updateData()
	self.desc_scroll1:removeAllChildren()
	
	local _layer = require(LAYER_QKCFT)()
	local desc = _layer.vars.desc 
	local count_label = _layer.vars.count_label 
	desc:setText(i3k_get_string(10015))
	count_label:setText(i3k_get_string(10016,i3k_db_faction_dine[1].contributionCount))
	self.desc_scroll1:addItem(_layer)
	local _layer = require(LAYER_QKCFT)()
	local desc = _layer.vars.desc 
	local count_label = _layer.vars.count_label 
	desc:setText(i3k_get_string(10017))
	count_label:setText(i3k_get_string(10058,i3k_db_faction_dine[1].physicalCount))
	self.desc_scroll1:addItem(_layer)
	local _layer = require(LAYER_QKCFT)()
	local desc = _layer.vars.desc 
	local count_label = _layer.vars.count_label 
	desc:setText(i3k_get_string(10047))
	count_label:setText(i3k_get_string(10048,i3k_db_faction_dine[1].startCount))
	self.desc_scroll1:addItem(_layer)
	
	self.desc_scroll2:removeAllChildren()
	local _layer = require(LAYER_QKCFT)()
	local desc = _layer.vars.desc 
	local count_label = _layer.vars.count_label 
	desc:setText(i3k_get_string(10015))
	count_label:setText(i3k_get_string(10016,i3k_db_faction_dine[2].contributionCount))
	self.desc_scroll2:addItem(_layer)
	
	local _layer = require(LAYER_QKCFT)()
	local desc = _layer.vars.desc 
	local count_label = _layer.vars.count_label 
	desc:setText(i3k_get_string(10049))
	count_label:setText(i3k_get_string(10059,i3k_db_faction_dine[2].physicalCount))
	self.desc_scroll2:addItem(_layer)
	local _layer = require(LAYER_QKCFT)()
	local desc = _layer.vars.desc 
	local count_label = _layer.vars.count_label 
	desc:setText(i3k_get_string(10060))
	count_label:setText(i3k_get_string(10061,i3k_db_faction_dine[2].startCount))
	self.desc_scroll2:addItem(_layer)
end

function wnd_faction_dine:refresh()
	self:updateData()
end 

function wnd_faction_dine:onSelectCommon(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		--self.btn1_mark:show()
		--self.btn2_mark:hide()
		self._type = 1
	end
end

function wnd_faction_dine:onSelectGrand(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		--self.btn1_mark:hide()
	--	self.btn2_mark:show()
		self._type = 2
	end
end

function wnd_faction_dine:onStart(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local dine_open = g_i3k_game_context:GetOpenDineData() or {}
		local maxCount = i3k_db_faction_dine[1].startCount
		local moneyCount = i3k_db_faction_dine[1].moneyCount
		local have_count = g_i3k_game_context:GetDiamond(true)
		if have_count < moneyCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10080))
			return 
		end 
		if dine_open[1] and dine_open[1] >= maxCount then
			g_i3k_ui_mgr:PopupTipMessage("开启次数已满")
			return 
		end
		
		
		local data = i3k_sbean.sect_openbanquet_req.new()
			--TODO发送请客吃饭的消息
		data.type = 1
		i3k_game_send_str_cmd(data,i3k_sbean.sect_openbanquet_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDine)
	end
	
end

function wnd_faction_dine:onStart1(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local dine_open = g_i3k_game_context:GetOpenDineData() or {}
		local maxCount = i3k_db_faction_dine[2].startCount
		local moneyCount = i3k_db_faction_dine[2].moneyCount
		local have_count = g_i3k_game_context:GetDiamond(true)
		if have_count < moneyCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10080))
			return 
		end 
		if dine_open[2] and dine_open[2] >= maxCount then
			g_i3k_ui_mgr:PopupTipMessage("开启次数已满")
			return 
		end
		local data = i3k_sbean.sect_openbanquet_req.new()
			--TODO发送请客吃饭的消息
		data.type = 2
		i3k_game_send_str_cmd(data,i3k_sbean.sect_openbanquet_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDine)
	end
end

function wnd_faction_dine:onCancel(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDine)
	end
end

--[[function wnd_faction_dine:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDine)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_dine.new()
	wnd:create(layout, ...)
	return wnd
end

