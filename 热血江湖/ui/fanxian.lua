-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
local FANXIAN_WIDGET = "ui/widgets/czflt"
wnd_fanxian = i3k_class("wnd_fanxian",ui.wnd_base)
function wnd_fanxian:ctor()
	self.pets = {}
	self.allitem = {}
end

function wnd_fanxian:configure()
	self.expression = self._layout.vars.expression
	self.desc = self._layout.vars.desc
	self.pet_scroll = self._layout.vars.pet_scroll
	self.ok = self._layout.vars.ok
	self.btnName = self._layout.vars.btnName
	self.viptext = self._layout.vars.viptext
	self.diamondtext = self._layout.vars.diamondtext
	self.vipnumber = self._layout.vars.vipnumber
	self.diamondnumber = self._layout.vars.diamondnumber
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end


function wnd_fanxian:refresh(result)
	self.pets = {}
	self.allitem = {}
	local chongzhi = 0
	local diamond = 0
	local vipvalue = 0
	if result ~= 0 then
		chongzhi = result * 0.1
		diamond = result * 2
		vipvalue = result
		local viplv = self:getviplvl(result)
		table.insert(self.allitem,{id = -1,count = diamond})
		table.insert(self.allitem,{id = 1001,count = vipvalue})
		self:updatapets(viplv)
	end
	self.expression:setText(string.format("感谢您参与“热血江湖”内测，您可以领取以下返还奖励，祝您游戏愉快~",chongzhi,"USD"))
	self.desc:setText("您可以领取以下奖励（该奖励只可领取一次）")
	self.viptext:setText("贵宾特权点数:")
	self.vipnumber:setText(vipvalue)
	self.diamondtext:setText("元宝数量:")
	self.diamondnumber:setText(diamond)
	self.btnName:setText("领取")
	self.ok:onClick(self,self.get_gift)
	self:updatascroll()
end

function wnd_fanxian:updatapets(viplv)
	for k , v in ipairs(i3k_db_kungfu_vip[viplv].vipFanXian) do
		table.insert(self.pets, {id = v.id, count = v.count})
		table.insert(self.allitem, {id = v.id, count = v.count})
	end
end

function wnd_fanxian:updatascroll()
	self.pet_scroll:removeAllChildren()
	for i,e in pairs(self.pets) do
		local _layer = require(FANXIAN_WIDGET)()
		local widget = _layer.vars
		local id = e.id
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
		widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.bt:onClick(self,self.clickitem,id)
		self.pet_scroll:addItem(_layer)
	end
end

function wnd_fanxian:getviplvl(result)
	local viplv = -1
	for i , j in ipairs(i3k_db_kungfu_vip) do
		if result < j.points then
			viplv = i - 1
			break
		end
	end
	if viplv == -1 then
		viplv = 15
	end
	return viplv
end

function wnd_fanxian:update(addtion)
	if addtion ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainMoreItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainMoreItems,self.allitem)
	else
		g_i3k_ui_mgr:PopupTipMessage("您没有奖励可领取")
	end
	self.btnName:setText("已领取")
	self.ok:disableWithChildren()
end

function wnd_fanxian:get_gift()
	local t = {}
	for i , j in ipairs(self.pets) do
		t[j.id]=j.count
	end
	local is_enough = g_i3k_game_context:IsBagEnough(t)
	if is_enough then
		i3k_sbean.take_reward()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end

function wnd_fanxian:clickitem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layer,...)
	local wnd = wnd_fanxian.new()
	wnd:create(layer,...)
	return wnd
end
