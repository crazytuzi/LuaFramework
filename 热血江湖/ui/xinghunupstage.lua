module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_xinghun_up_stage = i3k_class("wnd_xinghun_up_stage", ui.wnd_base)

local LAYER_XINGHUNSJT = "ui/widgets/xinghunsjt"

local OKICON = 4688
local NOICON = 4689
function wnd_xinghun_up_stage:ctor()
	self._cfg = {}
	self._curStage = 1
	self._nextStage = 2
end

function wnd_xinghun_up_stage:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)

	self.cond = widgets.cond1
	self.mark = widgets.mark1

	self.effect = widgets.effect
	self.effectTitle = widgets.effectTitle
	self.scroll = widgets.scroll

	self.up_stage_label = widgets.up_stage_label
	self.up_stage_btn = widgets.up_stage_btn
	self.up_stage_btn:onClick(self, self.onUpSatge)

	widgets.leftBtn:onClick(self, self.onLeftBtn)
	widgets.rightBtn:onClick(self, self.onRightBtn)
end

function wnd_xinghun_up_stage:refresh()
	self._curStage = g_i3k_game_context:getHeirloomData().starSpirit.rank  --当前星魂阶数
	self._nextStage = (self._curStage + 1) <= #i3k_db_chuanjiabao.starStage and (self._curStage + 1) or #i3k_db_chuanjiabao.starStage
	self._cfg = g_i3k_db.i3k_db_get_one_star_up_stage_cfg(self._nextStage)
	self:updateUI()
end

function wnd_xinghun_up_stage:updateUI()
	self:updateCondition()
	self:updateEffect()
	self:updateScroll()
	self:updateUpBtnState()
end

function wnd_xinghun_up_stage:updateCondition()
	local level = self._cfg.condition.subStarLevel
	local num =  self._cfg.condition.subStarNum

	local isShow = g_i3k_game_context:xingHunIsCanUpStage()
	if self._nextStage <= self._curStage then
		isShow = true
	end

	if self._nextStage - self._curStage > 1 then
		isShow = false
	end

	local id = isShow and OKICON or NOICON
	self.mark:setImage(g_i3k_db.i3k_db_get_icon_path(id))
	self.cond:setText(i3k_get_string(isShow and 16959 or 16960, level, g_i3k_game_context:GetSubStarCntWithLevel(level),num))
end

function wnd_xinghun_up_stage:updateEffect()
	self.effectTitle:setText(string.format("%s阶效果", self._nextStage))
	self.effect:setText(self._cfg and self._cfg.desc or "")
end

function wnd_xinghun_up_stage:updateScroll()
	self.scroll:removeAllChildren()
	local consumes = self._cfg and self._cfg.consumes or {}
	for _, v in ipairs(consumes) do
		if v.id > 0 and v.count > 0 then
			local ui = require(LAYER_XINGHUNSJT)()
			ui.vars.tip_btn:onClick(self, self.onConsumeItem, v.id)
			ui.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			ui.vars.suo:setVisible(v.id > 0)
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
			local text = math.abs(v.id) == g_BASE_ITEM_COIN and v.count or canUseCount.."/"..v.count  -- 铜钱只显示数量
			ui.vars.item_count:setText(text)
			ui.vars.item_count:setTextColor(canUseCount >= v.count and g_i3k_get_hl_green_color() or g_i3k_get_hl_red_color())
			self.scroll:addItem(ui)
		end
	end
end

function wnd_xinghun_up_stage:updateUpBtnState()
	if self._curStage == #i3k_db_chuanjiabao.starStage or self._nextStage <= self._curStage then
		self.up_stage_label:setText("已进阶")
		self.up_stage_btn:disableWithChildren()
	else
		local conds = self._cfg and self._cfg.condition or {}
		local function checkUpStageCond()
			local canClick = true

			if not g_i3k_game_context:xingHunIsCanUpStage() then
				canClick = false
			end

			if self._nextStage - self._curStage > 1 then
				canClick = false
			end

			return canClick
		end

		self.up_stage_label:setText("进 阶")
		if checkUpStageCond() then
			self.up_stage_btn:enableWithChildren()
		else
			self.up_stage_btn:disableWithChildren()
		end
	end
end

function wnd_xinghun_up_stage:onLeftBtn(sender)
	local stage = self._nextStage - 1
	if stage >= 2 then
		self._nextStage = stage
		self._cfg = g_i3k_db.i3k_db_get_one_star_up_stage_cfg(self._nextStage)
		self:updateUI()
	else
		g_i3k_ui_mgr:PopupTipMessage("已是最小阶")
	end
end

function wnd_xinghun_up_stage:onRightBtn(sender)
	local stage = self._nextStage + 1
	if stage <= #i3k_db_chuanjiabao.starStage then
		self._nextStage = stage
		self._cfg = g_i3k_db.i3k_db_get_one_star_up_stage_cfg(self._nextStage)
		self:updateUI()
	else
		g_i3k_ui_mgr:PopupTipMessage("已是最大阶")
	end
end

--升阶
function wnd_xinghun_up_stage:onUpSatge(sender)
	local isEnough = true
	local consumes = self._cfg and self._cfg.consumes or {}
	for _, v in ipairs(consumes) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if canUseCount < v.count then
			isEnough = false
		end
	end
	if isEnough then
		i3k_sbean.request_star_spirit_uprank_req(self._nextStage, consumes)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
	end
end

function wnd_xinghun_up_stage:onConsumeItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_xinghun_up_stage.new();
		wnd:create(layout, ...);
	return wnd;
end
