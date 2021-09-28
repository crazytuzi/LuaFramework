module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qilingActive = i3k_class("wnd_qilingActive", ui.wnd_base)

function wnd_qilingActive:ctor()
end

function wnd_qilingActive:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.ok:onClick(self, self.onActiveBtn)
end

function wnd_qilingActive:refresh(cfg, cardID)
	self._cfg = cfg
	self._cardID = cardID
	local widgets = self._layout.vars
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imgID))
	widgets.item_name:setText(cfg.name)
	widgets.rateLabel:setText(i3k_get_string(1091, cfg.rate/ 10000 * 100))

	self:updateBtnAndText(cfg, cardID)
	local transAttr = cfg.transAttr
	local foreverAttr = cfg.foreverAttr
	self:setWeaponScroll(transAttr)
	self:setForeverScroll(foreverAttr)
	self:refreshConsume()
end

-- InvokeUIFunction
function wnd_qilingActive:refreshConsume()
	local consumes = self._cfg.consume
	self:setConsumeScroll(consumes)
end


function wnd_qilingActive:updateBtnAndText(cfg, cardID)
	local widgets = self._layout.vars
	local forwardNode = cfg.forward
	local info = g_i3k_game_context:getQilingData()
	local activeNodes = info[cardID].activitePoints
	local forwardActive = forwardNode == 0 or activeNodes[forwardNode] -- g_i3k_game_context:vectorContain(activeNodes, forwardNode)
	widgets.ok:setVisible(forwardActive)
	widgets.descLabel:setVisible(not forwardActive)
end

-- 变身加持属性
function wnd_qilingActive:setWeaponScroll(transAttr)
	local widgets = self._layout.vars
	local scroll = widgets.scroll1
	self:setScrollData(scroll, transAttr)
end

-- 永久属性
function wnd_qilingActive:setForeverScroll(foreverAttr)
	local widgets = self._layout.vars
	local scroll = widgets.scroll2
	self:setScrollData(scroll, foreverAttr)
end

function wnd_qilingActive:setScrollData(scroll, data)
	scroll:removeAllChildren()
	for k, v in ipairs(data) do
		if v.id ~= 0 and v.count ~= 0 then
			local des = require("ui/widgets/qljht2")()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			local icon = g_i3k_db.i3k_db_get_property_icon(v.id)
			des.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			des.vars.desc:setText(_desc)
			des.vars.value:setText(i3k_get_prop_show(v.id, v.count))
			scroll:addItem(des)
		end
	end
end

function wnd_qilingActive:setConsumeScroll(consumes)
	local widgets = self._layout.vars
	local scroll = widgets.consumeScroll
	scroll:removeAllChildren()
	for k, v in ipairs(consumes) do
		local ui = require("ui/widgets/qljht1")()
		ui.vars.bt:onClick(self, self.onConsumeItem, v.id)
		ui.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole()))
		ui.vars.suo:setVisible(v.id > 0)
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		local text = math.abs(v.id) == g_BASE_ITEM_COIN and v.count or canUseCount.."/"..v.count  -- 铜钱只显示数量
		ui.vars.item_count:setText(text)
		ui.vars.item_count:setTextColor(g_i3k_get_cond_color(canUseCount >= v.count))
		scroll:addItem(ui)
	end
end

function wnd_qilingActive:onConsumeItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_qilingActive:checkConsume()
	local consumes = self._cfg.consume
	for k, v in ipairs(consumes) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if canUseCount < v. count then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
			return false
		end
	end
	return true
end


function wnd_qilingActive:onActiveBtn(sender)
	if not self:checkConsume() then
		return
	end

	local qilingID = self._cardID
	local pointID = self._cfg.id
	local consumes = self._cfg.consume
	i3k_sbean.activeQilingPoint(qilingID, pointID, consumes)
end

function wnd_create(layout, ...)
	local wnd = wnd_qilingActive.new();
		wnd:create(layout, ...);
	return wnd;
end
