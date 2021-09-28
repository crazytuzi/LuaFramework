module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_xinhun_main_star_practice = i3k_class("wnd_xinhun_main_star_practice", ui.wnd_base)

local LAYER_XINGHUNZHUXINGT = "ui/widgets/xinghunzhuxingt"
local LAYER_XINGHUNZHUXING2T = "ui/widgets/xinghunzhuxing2t"

function wnd_xinhun_main_star_practice:ctor()
	self._consumes = {}
	self._isSave = true  --洗炼结果是否已保存
	self._propValue = 0

	self._tmpProps = {}
	self._nowProps = {}
end

function wnd_xinhun_main_star_practice:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onMyCloseUI)

	self.scroll1 = widgets.scroll1
	self.scroll2 = widgets.scroll2
	self.scroll3 = widgets.scroll3

	self.save_btn = widgets.saveBtn
	self.practice_btn = widgets.practiceBtn

	self.save_btn:onClick(self, self.onSaveBtn)
	self.practice_btn:onClick(self, self.onPracticeBtn)

	self.desc = widgets.desc
end

function wnd_xinhun_main_star_practice:refresh()
	local roleType = g_i3k_game_context:GetRoleType()
	local cfg = g_i3k_db.i3k_db_get_main_star_up_cfg(roleType, 1)
	if cfg then
		self._propValue = cfg.propValue
		self.desc:setText(i3k_get_string(16987, self._propValue/100))
	end

	self._tmpProps = g_i3k_game_context:GetXinHunMainStarTmpProps()
	self._nowProps = g_i3k_game_context:GetXinHunMainStarProps()

	self:updateLeftScroll()
	self:updateConsumeScroll()
	self:updateRightScroll()
	self:updateSaveBtnState()
end

function wnd_xinhun_main_star_practice:updateLeftScroll()
	self.scroll1:removeAllChildren()
	self.scroll1:stateToNoSlip()
	if self._nowProps and next(self._nowProps) then
		for id, _ in pairs(self._nowProps) do
			local ui = require(LAYER_XINGHUNZHUXINGT)()
			ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(id)))
			ui.vars.desc:setText(g_i3k_db.i3k_db_get_main_star_prop_desc(id))
			ui.vars.wenhao:hide()
			self.scroll1:addItem(ui)
		end
	end
end

function wnd_xinhun_main_star_practice:updateRightScroll()
	self.scroll2:removeAllChildren()
	self.scroll2:stateToNoSlip()
	if self._tmpProps and next(self._tmpProps) then
		for id, _ in pairs(self._tmpProps) do
			local ui = require(LAYER_XINGHUNZHUXINGT)()
			ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(id)))
			ui.vars.desc:setText(g_i3k_db.i3k_db_get_main_star_prop_desc(id))
			ui.vars.wenhao:hide()
			self.scroll2:addItem(ui)
		end
	else
		local randCnt = i3k_db_chuanjiabao.cfg.randCnt
		for i = 1, randCnt do
			local ui = require(LAYER_XINGHUNZHUXINGT)()
			ui.vars.desc:setText("")
			ui.vars.icon:hide()
			self.scroll2:addItem(ui)
		end
	end
end

function wnd_xinhun_main_star_practice:updateConsumeScroll()
	self.scroll3:removeAllChildren()
	self._consumes = i3k_db_chuanjiabao.cfg.praticeConsumes
	for _, v in ipairs(self._consumes) do
		if v.id > 0 and v.count > 0 then
			local ui = require(LAYER_XINGHUNZHUXING2T)()
			ui.vars.tip_btn:onClick(self, self.onConsumeItem, v.id)
			ui.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			ui.vars.suo:setVisible(v.id > 0)
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
			local text = math.abs(v.id) == g_BASE_ITEM_COIN and v.count or canUseCount.."/"..v.count  -- 铜钱只显示数量
			ui.vars.item_count:setText(text)
			ui.vars.item_count:setTextColor(g_i3k_get_cond_color(canUseCount >= v.count))
			self.scroll3:addItem(ui)
		end
	end
end

function wnd_xinhun_main_star_practice:updateSaveBtnState()
	if self._tmpProps and next(self._tmpProps) then
		self._isSave = false
	else
		self._isSave = true
	end
	self.save_btn:setVisible(not self._isSave)
end

function wnd_xinhun_main_star_practice:onSaveBtn(sender)
	if self._tmpProps and next(self._tmpProps) then
		i3k_sbean.request_main_star_save_req(self._tmpProps)
	else
		g_i3k_ui_mgr:PopupTipMessage("请先随机新属性方可保存")
	end
end

function wnd_xinhun_main_star_practice:onPracticeBtn(sender)
	local isEnough = true
	for _, v in ipairs(self._consumes) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if canUseCount < v.count then
			isEnough = false
		end
	end
	if isEnough then
		i3k_sbean.request_main_star_refresh_req(self._consumes)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
	end
end

function wnd_xinhun_main_star_practice:onMyCloseUI(sender)
	if self._isSave then
		g_i3k_ui_mgr:CloseUI(eUIID_XingHunMainStarPractice)
	else
		local desc = i3k_get_string(16986)
		local callback  = function(ok)
			if ok then
				g_i3k_ui_mgr:CloseUI(eUIID_XingHunMainStarPractice)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	end
end

function wnd_xinhun_main_star_practice:onConsumeItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_xinhun_main_star_practice.new();
		wnd:create(layout, ...);
	return wnd;
end
