-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_role_return = i3k_class("wnd_role_return", ui.wnd_base)

local LAYER_LYZHT = "ui/widgets/lyzht"
local LAYER_LYZHT2 = "ui/widgets/lyzht2"

local ZHAOHUI = 1
local JIANGLI = 2
local DUIHUAN = 3

function wnd_role_return:ctor()
	self._index = ZHAOHUI -- 表示打开哪个界面
	self._btn = {}
	self._root = {}
end

function wnd_role_return:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.help:onClick(self, self.onHelp)
	widgets.friends_btn:onClick(self, self.onZhaoHui)
	widgets.myself_btn:onClick(self, self.onJiangLi)
	widgets.enemy_btn:onClick(self, self.onDuiHuan)
	self._btn = {zhaoHui = widgets.friends_btn, jiangLi = widgets.myself_btn, duiHuan = widgets.enemy_btn}
	self._root = {zhaoHuiRoot = widgets.zhaoHuiRoot, jiangLiRoot = widgets.jiangLiRoot, duiHuanRoot = widgets.duiHuanRoot}
end

function wnd_role_return:refresh()
	if self._index == ZHAOHUI then
		self:updateBtnType("zhaoHui")
		self:updateRootType("zhaoHuiRoot")
		self:updateZhaoHui()
	elseif self._index == JIANGLI then
		self:onJiangLi()
	else
		self:onDuiHuan()
	end
end

function wnd_role_return:onZhaoHui(sender)
	if self._index ~= ZHAOHUI then
		self._index = ZHAOHUI
		self:updateBtnType("zhaoHui")
		self:updateRootType("zhaoHuiRoot")
		self:updateZhaoHui()
	end
end

function wnd_role_return:onJiangLi(sender)
	if self._index ~= JIANGLI then
		self._index = JIANGLI
		self:updateBtnType("jiangLi")
		self:updateRootType("jiangLiRoot")
		self:updateJiangLi()
	end
end

function wnd_role_return:onDuiHuan(sender)
	if self._index ~= DUIHUAN then
		self._index = DUIHUAN
		self:updateBtnType("duiHuan")
		self:updateRootType("duiHuanRoot")
		self:updateDuiHuan()
	end
end

function wnd_role_return:updateZhaoHui()
	local info, code = g_i3k_game_context:getRoleReturnInfo()
	self._layout.vars.buyScrollRight:removeAllChildren()
	self._layout.vars.zhaoHuanMa:setText(code)
	self._layout.vars.copyBtn:onClick(self, self.copy, code)
	if info.bindRoles then
		for k, v in pairs(info.bindRoles) do
			local _layer = require(LAYER_LYZHT)()
			local widgets = _layer.vars
			widgets.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(v.bindRole.role.headIcon, false))
			widgets.roleHeadBg:setImage(g_i3k_get_head_bg_path(v.bindRole.role.bwType, v.bindRole.role.headBorder))
			widgets.level_label:setText(v.bindRole.role.level)
			widgets.job_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.bindRole.role.type].classImg))
			widgets.name_label:setText(v.bindRole.role.name)
			widgets.chongZhi:setText(v.rewardNum)
			widgets.hongli:setText(v.rewardNum * i3k_db_role_return.common.pay_rate / 10000)
			self._layout.vars.buyScrollRight:addItem(_layer)
		end
	end
	self._layout.vars.buyScrollRight:show()
end

function wnd_role_return:updateJiangLi()
	local info = g_i3k_game_context:getRoleReturnInfo()
	self._layout.vars.text:setText(string.format("被召唤者每提升一级增加%d分", i3k_db_role_return.common.point_evelvl))
	self._layout.vars.buyScrollRight2:removeAllChildren()
	if info.score then
		self._layout.vars.points:setText(info.score)
		for k, v in ipairs(i3k_db_role_return.gift) do
			local _layer = require(LAYER_LYZHT2)()
			local widgets = _layer.vars
			widgets.item_name:setText(v.giftName)
			widgets.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconId))
			widgets.out_icon:hide()
			if v.giftPoint <= info.score then
				widgets.get_btn:show()
				widgets.money_count:hide()
			else
				widgets.get_btn:hide()
				widgets.money_count:show()
				widgets.money_count:setText(string.format("%d积分领取", v.giftPoint))
			end
			if info.takedRewards then
				for i, j in pairs(info.takedRewards) do
					if i == k then
						widgets.out_icon:show()
						widgets.get_btn:hide()
						widgets.money_count:show()
						widgets.money_count:setText(string.format("%d积分领取", v.giftPoint))
					end
				end
			end
			local itemData = {}
			for i, j in ipairs(v.items) do
				table.insert(itemData, {id = j.id, count = j.count})
			end
			self:updateItems(widgets, itemData)
			widgets.out_icon:onClick(self, self.onItem, itemData)
			local function callback(isOk)
				if isOk then
					i3k_sbean.get_score_reward(k, function()
						g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainMoreItems)
						g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainMoreItems, itemData)
						i3k_sbean.sync_regression(function()
							g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleReturn, "updateJiangLi")
						end)
					end)
				end
			end
			widgets.get_btn:onClick(self, function()
				g_i3k_ui_mgr:ShowMessageBox2(string.format("确定消耗%s积分兑换该礼包?", v.giftPoint), callback)
			end)
			self._layout.vars.buyScrollRight2:addItem(_layer)
		end
	end
	self._layout.vars.buyScrollRight2:show()
end

function wnd_role_return:updateDuiHuan()
	self._layout.vars.input_label:setText("")
	self._layout.vars.leftTime:setText("每日可进入：")
	self._layout.vars.times:setText("2次")
	self._layout.vars.detil:setText(i3k_get_string(4120))
	--self._layout.vars.times:setText(i3k_db_NpcDungeon[7].joinCnt - g_i3k_game_context:getNpcDungeonEnterTimes(7))
	self._layout.vars.fubenTitle:setText(i3k_get_string(3129))
	self._layout.vars.dsa:setText(i3k_get_string(3130, i3k_db_role_return.common.disLevel))
	self._layout.vars.go_dungeon:onClick(self, self.goDungeon)
	self._layout.vars.exchange_btn:onClick(self, function()
		local isReturn = g_i3k_game_context:getIsRoleReturn()
		if isReturn > 0 then
			local text = self._layout.vars.input_label:getText()
			if text == "" then
				g_i3k_ui_mgr:PopupTipMessage("输入不能为空")
			else
				if g_i3k_game_context:yqmsr_check(text) then
					local itemData = {}
					for k, v in ipairs(i3k_db_role_return.reward) do
						itemData[v.id] = v.count
					end
					if g_i3k_game_context:IsBagEnough(itemData) then
						i3k_sbean.use_regression_code(text)
					else						
						g_i3k_ui_mgr:PopupTipMessage("背包已满，请先整理背包再领取")
					end
				else
					g_i3k_ui_mgr:PopupTipMessage("请输入正确的数字字母组合")
				end
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4116))
		end
	end)
end

function wnd_role_return:goDungeon()
	g_i3k_game_context:GotoNpc(60008)
end

function wnd_role_return:copy(sender, code)
	i3k_copy_to_clipboard(code)
end

function wnd_role_return:updateItems(widgets, itemData)
	local items = 
	{
		{icon = widgets.daoju1, button = widgets.itemBtn1, bg = widgets.item_bg1, suo = widgets.suo1, count = widgets.count1},
		{icon = widgets.daoju2, button = widgets.itemBtn2, bg = widgets.item_bg2, suo = widgets.suo2, count = widgets.count2},
		{icon = widgets.daoju3, button = widgets.itemBtn3, bg = widgets.item_bg3, suo = widgets.suo3, count = widgets.count3},
		{icon = widgets.daoju4, button = widgets.itemBtn4, bg = widgets.item_bg4, suo = widgets.suo4, count = widgets.count4},
	}
	for k, v in ipairs(itemData) do
		items[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
		items[k].button:onClick(self, self.onItem, v.id)
		items[k].bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		items[k].suo:setVisible(v.id > 0)
		items[k].count:setText(v.count)
	end
end

function wnd_role_return:onItem(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_role_return:updateAllRoot()
	for k, v in pairs(self._root) do
		v:hide()
	end
end

function wnd_role_return:updateRootType(root)
	self:updateAllRoot()
	for k, v in pairs(self._root) do
		if k == root then
			v:show()
		end
	end
end

function wnd_role_return:updateAllBtn()
	for k, v in pairs(self._btn) do
		v:stateToNormal()
	end
end

function wnd_role_return:updateBtnType(btn)
	self:updateAllBtn()
	for k, v in pairs(self._btn) do
		if k == btn then
			v:stateToPressed()
		end
	end
end

function wnd_role_return:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleReturn)
end

function wnd_role_return:onHelp()
	g_i3k_ui_mgr:OpenUI(eUIID_Help)
	g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(4115))
end

function wnd_create(layout, ...)
	local wnd = wnd_role_return.new();
		wnd:create(layout, ...);
	return wnd;
end
