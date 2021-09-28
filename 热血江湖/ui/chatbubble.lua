
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_chatBubble = i3k_class("wnd_chatBubble",ui.wnd_base)
local l_NormalChatBg = 3419
local l_VipChatBg = 3420
function wnd_chatBubble:ctor()
	self.openState = nil
	self.currId = 0
	self.chatBoxIds = {}
	self.currUsingNode = nil
	self.oldUsingNode = nil
end

function wnd_chatBubble:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	widgets.have_btn:onClick(self, self.onUpdateScroll)
	widgets.all_btn:onClick(self, self.onUpdateScroll)

	self.openState = widgets.all_btn
	self.have_btn = widgets.have_btn
	self.scroll = widgets.scroll
	self.scroll:setBounceEnabled(false)
end

function wnd_chatBubble:refresh(currId, chatBoxIds, openHave)
	self.currId = currId
	self.chatBoxIds = chatBoxIds
	if openHave then
		self.openState = self.have_btn
		self.have_btn:stateToPressed(true)
	else
		self._layout.vars.all_btn:stateToPressed(true)
	end
	self:updateScroll()
end

function wnd_chatBubble:updateScroll()
	local node = nil
	self.currUsingNode = nil
	self.oldUsingNode = nil
	self.scroll:removeAllChildren()
	self:addDefaultBg()
	for k,e in ipairs(i3k_db_chatBubble) do
		node = nil
		if self.openState ~= self.have_btn then
			node = require("ui/widgets/ltqpt")()
			node.vars.useingImg:hide()
			node.vars.useBtn:hide()
			if e.showBuyBtn <= 0 then
				node.vars.activateBtn:hide()
			else
				node.vars.activateBtn:onClick(self, self.activateBox,k)
			end
			if self.chatBoxIds[k] == 0 then
				node.vars.activateBtn:hide()
			end
		elseif self.chatBoxIds[k] and (i3k_game_get_time() < self.chatBoxIds[k] or self.chatBoxIds[k] == 0) then
			node = require("ui/widgets/ltqpt")()
			node.vars.activateBtn:hide()
			node.vars.useingImg:hide()
			node.vars.useBtn:onClick(self, self.activateBox,{id = k, node = node, time = self.chatBoxIds[k]})
			if k == self.currId then
				node.vars.useingImg:show()
				node.vars.useBtn:hide()
				self.oldUsingNode = node
			end
		end
		if node then
			self:showDetail(node.vars, k)
			self.scroll:addItem(node)
		end
	end
end

function wnd_chatBubble:addDefaultBg()
	if self.openState == self.have_btn then
		local node = require("ui/widgets/ltqpt")()
		local vars = node.vars
		vars.activateBtn:hide()
		vars.useingImg:hide()
		vars.useBtn:onClick(self, self.activateBox,{id = 0, node = node, time = 0})
		if 0 == self.currId then
			vars.useingImg:show()
			vars.useBtn:hide()
			self.oldUsingNode = node
		end
		vars.upImg:hide()
		vars.downImg:hide()
		vars.getText:setText("系统赠送")
		vars.timedesc:setText("剩余时间:")
		vars.time:setText("永久")
		local viplvl = g_i3k_game_context:GetVipLevel()
		-- local limitLvl = 0
		-- for k,v in pairs(i3k_db_kungfu_vip) do
		-- 	if v.vipBgIcon == vipChatBg
		-- end
		vars.boxImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_kungfu_vip[viplvl].vipBgIcon))
		vars.desc:setText(i3k_get_string(16852, self:getChangeIconLvl(viplvl)))
		vars.titleName:setText("默认聊天气泡")
		self.scroll:addItem(node)
	end 
end
--判断vip背景开始改变级别
function wnd_chatBubble:getChangeIconLvl(viplvl)
	local curVipBgIcon = i3k_db_kungfu_vip[viplvl].vipBgIcon
	local curLvl = viplvl
	for	k = viplvl, 0, -1 do
		if i3k_db_kungfu_vip[k].vipBgIcon ~= curVipBgIcon then
			return k+1 
		end
	end
	return 0
end

function wnd_chatBubble:showDetail(widgets, id)
	local cfg = i3k_db_chatBubble[id]
	widgets.getText:setText(cfg.getWays)
	
	widgets.boxImg:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))
	widgets.upImg:hide()
	widgets.downImg:hide()
	if cfg.upImg > 0 then
		widgets.upImg:show():setImage(g_i3k_db.i3k_db_get_icon_path(cfg.upImg))
	end
	if cfg.downImg > 0 then
		widgets.downImg:show():setImage(g_i3k_db.i3k_db_get_icon_path(cfg.downImg))
	end
	local time = self.chatBoxIds[id]
	local str = cfg.desc
	local preTimeStr, timestr = "剩余时间:","永久"
	if time and i3k_game_get_time() < time then
		widgets.actTxt:setText("续 费")
		dtime = time - i3k_game_get_time()
		local day = math.modf(dtime/86400)
		local hours = math.modf((dtime%86400)/3600)
		local sec = math.modf(math.modf(dtime%3600)/60)
		timestr = (day == 0 and "" or day.."天") .. (hours == 0 and "" or hours.."时") .. (sec == 0 and "" or sec.."分")
		if timestr == "" then
			timestr = "即将到期"
		end
	elseif time == 0 then
	else
		preTimeStr = "有效时间:"
		widgets.actTxt:setText("购 买")
		if cfg.time > 0 then
			timestr = string.format("%s天",(math.modf(cfg.time/86400)))
		end
	end

	widgets.timedesc:setText(preTimeStr)
	widgets.time:setText(timestr)
	widgets.desc:setText(cfg.desc)
	widgets.titleName:setText(cfg.name)
end

function wnd_chatBubble:onUpdateScroll(sender)
	if self.openState == sender  then
		return
	end
	sender:stateToPressed(true)
	self.openState:stateToNormal(true)
	self.openState = sender
	self:updateScroll()
end

function wnd_chatBubble:activateBox(sender, args)
	if self.openState ~= self.have_btn then
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(i3k_db_chatBubble[args].itemId)
		g_i3k_logic:OpenVipStoreUI(cfg.showType, cfg.isBound, cfg.id)
		self:onCloseUI()
	else
		if i3k_game_get_time() < args.time or args.time == 0 then
			self.currUsingNode = args.node
			i3k_sbean.role_chat_box_changeReq(args.id)
		else
			i3k_sbean.role_chat_box_syncReq(true)
		end
	end
end

function wnd_chatBubble:updateCurrUseingItem(chatBoxId)
	if self.oldUsingNode then
		self.oldUsingNode.vars.useingImg:hide()
		self.oldUsingNode.vars.useBtn:show()
	end
	if self.currUsingNode then
		self.currUsingNode.vars.useingImg:show()
		self.currUsingNode.vars.useBtn:hide()
	end
	self.currId = chatBoxId
	self.oldUsingNode = self.currUsingNode
end

function wnd_create(layout, ...)
	local wnd = wnd_chatBubble.new()
	wnd:create(layout, ...)
	return wnd;
end

