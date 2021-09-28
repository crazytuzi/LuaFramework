
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_baguaExtract = i3k_class("wnd_baguaExtract",ui.wnd_base)

local LAYER_BAGUACUIQUT = "ui/widgets/baguacuiqut"

function wnd_baguaExtract:ctor()
	self._affix = nil
	self._equipID = nil
	self._getTb = {}
	self._costTb = {}
end

function wnd_baguaExtract:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)

	widgets.desc:setText("萃取的含义")
	widgets.tips:setText("萃取成功后原八卦会被分解")

	self.getScroll = widgets.getScroll
	self.costScroll = widgets.costScroll

	widgets.extractBtn:onClick(self, self.onExtractBtn)
end

function wnd_baguaExtract:refresh(equipID)
	self._equipID = equipID
	self._affix = nil

	local additionProp = g_i3k_game_context:GetBagDiagrams()[equipID].additionProp
	self._affix = g_i3k_db.i3k_db_get_bagua_extractID(additionProp)

	self:updateGetScroll()
	self:updateCostScroll()
end

function wnd_baguaExtract:updateGetScroll()
	self.getScroll:removeAllChildren()
	local getTb = {}  --萃取获得
	if self._affix and i3k_db_bagua_affix[self._affix] then
		table.insert(getTb, {id = i3k_db_bagua_affix[self._affix].extractItemID, count = 1})
	end
	--可萃取八卦品质必然橙色
	table.insert(getTb, {id = g_BASE_ITEM_BAGUA_ENERGY, count = i3k_db_bagua_cfg.baguaEnergy[#i3k_db_bagua_cfg.baguaEnergy]})

	self._getTb = getTb

	for _, v in ipairs(getTb) do
		local ui = require(LAYER_BAGUACUIQUT)()
		ui.vars.btn:onClick(self, self.showItemInfo, v.id)
		ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		ui.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
		ui.vars.suo:setVisible(v.id > 0)
		self.getScroll:addItem(ui)
	end
end

function wnd_baguaExtract:updateCostScroll()
	self.costScroll:removeAllChildren()
	local costTb = i3k_db_bagua_cfg.extractCost  --萃取消耗

	self._costTb = costTb

	for _, v in ipairs(costTb) do
		local ui = require(LAYER_BAGUACUIQUT)()
		ui.vars.btn:onClick(self, self.showItemInfo, v.id)
		ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		ui.vars.suo:setVisible(v.id > 0)
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		local text = math.abs(v.id) == g_BASE_ITEM_COIN and v.count or canUseCount.."/"..v.count  -- 铜钱只显示数量
		ui.vars.name:setText(text)
		ui.vars.name:setTextColor(canUseCount >= v.count and g_i3k_get_green_color() or g_i3k_get_red_color())
		self.costScroll:addItem(ui)
	end
end

function wnd_baguaExtract:onExtractBtn(sender)
	for _, v in ipairs(self._costTb) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			return g_i3k_ui_mgr:PopupTipMessage("萃取所需道具不足")
		end
	end
	i3k_sbean.request_eightdiagram_extraction_req(self._equipID, self._costTb, self._getTb)
end

function wnd_baguaExtract:showItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_baguaExtract.new()
	wnd:create(layout, ...)
	return wnd;
end

