-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_exchangeFame = i3k_class("wnd_exchangeFame",ui.wnd_add_sub)

local BREAKCFG = i3k_db_server_limit.breakSealCfg
local ITEMINFO = i3k_db_server_limit.breakSealCfg.iteminfo

function wnd_exchangeFame:configure()
	local widget = self._layout.vars

	self.ok = widget.ok
	self.ok:onClick(self, self.getFame)
	self.cancel = widget.cancel
	self.cancel:onClick(self, self.onCloseUI)
	
	self.add_btn = widget.jia
	self.sub_btn = widget.jian  
	self.max_btn = widget.max
	self.current_num = 1	
	self._count_label = widget.use_count 
	self._count_label:setText("1")
	self._max_str = nil 
	self._min_str = nil 
	self._fun = nil
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)	
end

function wnd_exchangeFame:refresh(info)
	self.id = info.id
	self.npcId = info.NpcId
	self:updateFun()
	self:setBaseInfo(info)
end

function wnd_exchangeFame:getFame(sender)
	i3k_sbean.breakSeal_donate(self.id, self.current_num, self.npcId)
	self:onCloseUI()
end

function wnd_exchangeFame:setNumCount(count)
	self._count_label:setText(count)
end

function wnd_exchangeFame:updateFun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ExchangeFame,"setNumCount",self.current_num)
	end
end

function wnd_exchangeFame:setBaseInfo(info)
	local widgets = self._layout.vars
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.id, g_i3k_game_context:IsFemaleRole()))
	widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.id))
	widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(info.id))
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(info.id)))
	widgets.item_desc:setText("通过捐赠，您今日还可获得" .. info.dayLeftFame .. "点武林声望")
	widgets.item_point:setText("可提供".. info.itemPoint .. "点武林声望")
	local totalCount = g_i3k_game_context:GetCommonItemCanUseCount(info.id)
	local canUseCount = math.ceil(info.dayLeftFame/info.itemPoint)
	local minCount = math.min(totalCount, canUseCount)
	self.current_add_num = minCount
end

function wnd_create(layout)
	local wnd =wnd_exchangeFame.new()
	wnd:create(layout)
	return wnd
end
