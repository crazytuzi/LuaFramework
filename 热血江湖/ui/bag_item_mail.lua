-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--信件道具ui
-------------------------------------------------------

wnd_bag_item_mail = i3k_class("wnd_bag_item_mail",ui.wnd_base)

function wnd_bag_item_mail:ctor()
	
end

function wnd_bag_item_mail:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.closeBtn
    self.getTask = widgets.getTask
	
	self.Scroll = widgets.Scroll
	self.name = widgets.ItemName
	self.getTask:onClick(self, self.getTaskButton)
	self.closeBtn:onClick(self, self.closeButton)
	
end

function wnd_bag_item_mail:refresh(id)
	self.id = id
	self.name:setText(g_i3k_db.i3k_db_get_common_item_name(self.id))
	self:setScrollData(id)
	local MailItemTab = g_i3k_db.i3k_db_get_other_item_cfg(id)
	if MailItemTab.args2 ==0 then --新需求 当参2为0时，视为普通信件（无接取任务按钮）
		self.getTask:setVisible(false)
	else
		self:isShowBtn(id)
	end
	
end

function wnd_bag_item_mail:setScrollData(id)
	local MailItemTab = g_i3k_db.i3k_db_get_other_item_cfg(id)
	local text ="道具表参数1出错"
	if i3k_db_dialogue[MailItemTab.args1]~=nil then
		text = i3k_db_dialogue[MailItemTab.args1][1].txt
	end
	local annText = require("ui/widgets/xint")()
	annText.vars.text:setText(text)
	self.Scroll:addItem(annText)
end


function wnd_bag_item_mail:isShowBtn(id)
	self.getTask:setVisible(g_i3k_game_context:isMainItemGetSubLineTask(id))
	self.getTask:setTouchEnabled(g_i3k_game_context:isMainItemGetSubLineTask(id))
end

function wnd_bag_item_mail:getTaskButton(sender)
	--点击接取按钮
	i3k_sbean.bag_useitemletter(self.id)
end

function wnd_bag_item_mail:setData(id )
	--刷新任务及背包
	local MailItemTab = g_i3k_db.i3k_db_get_other_item_cfg(id)
	if MailItemTab.args4 ==0 then
		g_i3k_game_context:SetUseItemData(id, 1,nil,AT_USE_ITEM_LETTER)--回调成功后消耗道具
	end	
	g_i3k_game_context:checkSubLineTaskIsLock(5,MailItemTab.args2)	
	g_i3k_ui_mgr:CloseUI(eUIID_ItemMailUI)	
end

function wnd_bag_item_mail:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ItemMailUI)
end

function wnd_create(layout)
	local wnd = wnd_bag_item_mail.new()
		wnd:create(layout)
	return wnd
end
