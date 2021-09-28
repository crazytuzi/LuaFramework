module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qilingPromote = i3k_class("wnd_qilingPromote", ui.wnd_base)


local condition =   -- TODO 配置？
{
	[1] = {str = 1073, valueName = "needLevel", cond = g_i3k_game_context.checkQilingPromoteLevel , cur = g_i3k_game_context.GetLevel},
	[2] = {str = 1074, valueName = "needPower", cond = g_i3k_game_context.checkQilingPromotePower, cur = g_i3k_game_context.GetRolePower},
	[3] = {str = 1075, valueName = "needStars", cond = g_i3k_game_context.checkQilingPromoteWeapon, cur = g_i3k_game_context.getAllWeaponStars},
	[4] = {str = 17903, valueName = "myActivitePoints", cond = g_i3k_game_context.checkQilingPromoteActivitePoints, cur = g_i3k_game_context.getCurWeaponActivitePoints},
}
local OKICON = 4688
local NOICON = 4689

function wnd_qilingPromote:ctor()
end
function wnd_qilingPromote:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.ok:onClick(self, self.onOkBtn)

end

function wnd_qilingPromote:refresh(id, rank)
	local cfg = i3k_clone(i3k_db_qiling_trans[id][rank])
	cfg.myActivitePoints = #i3k_db_qiling_nodes[id][rank]
	self._id = id
	self._rank = rank
	self._cfg = cfg
	self:setScroll(cfg)

	self:setConsumeScroll()
end


function wnd_qilingPromote:setScroll(cfg)
	local widgets = self._layout.vars
	local scroll = widgets.scroll1
	for k, v in ipairs(condition) do
		local ui = require("ui/widgets/qljh2t")()
		ui.vars.label:setText(string.format(i3k_get_string(v.str, v.cur(g_i3k_game_context, self._id), cfg[v.valueName])))
		local id = v.cond(g_i3k_game_context, cfg, self._id) and OKICON or NOICON
		ui.vars.image:setImage(g_i3k_db.i3k_db_get_icon_path(id))
		scroll:addItem(ui)
	end
end

-- InvokeUIFunction
function wnd_qilingPromote:setConsumeScroll()
	local consumes = self._cfg.consume
	local widgets = self._layout.vars
	local scroll = widgets.scroll2
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

function wnd_qilingPromote:onConsumeItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

-- 检查是否符合进化条件
function wnd_qilingPromote:checkCondition()
	local cfg = self._cfg
	for k, v in ipairs(condition) do
		if not v.cond(g_i3k_game_context, cfg, self._id) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1093))
			return false
		end
	end
	-- 是否所有点全解锁？
	--[[local nodeCfg = i3k_db_qiling_nodes[self._id][self._rank]
	local info = g_i3k_game_context:getQilingData()
	if #nodeCfg > table.nums(info[self._id].activitePoints) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1094))
		return false
	end--]]
	-- 消耗
	local consumes = cfg.consume
	for k, v in ipairs(consumes) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if canUseCount < v.count then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
			return false
		end
	end
	return true
end

function wnd_qilingPromote:onOkBtn(sender)
	if not self:checkCondition() then
		return false
	end
	local qilingID = self._id
	local rank = self._rank + 1
	local consumes = self._cfg.consume
	i3k_sbean.upRankQiling(qilingID, rank, consumes)
end

function wnd_create(layout, ...)
	local wnd = wnd_qilingPromote.new();
		wnd:create(layout, ...);
	return wnd;
end
