-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_fashion_spinning = i3k_class("wnd_fashion_spinning",ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/zbtipst"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local LAYER_SZJFT = "ui/widgets/szjft"

local PROP_OPEN_CONDITION = i3k_db_fashion_base_info.prop_open_condition  --第二属性开启条件

function wnd_fashion_spinning:ctor()
	self.fashionId = 0
	self.consumeItems = {}
	self.isCanSpinning = true  --是否可以精纺

	--战力变化
	self._poptick = 0
	self._base = 0
	self._target = 0
	self._showPowerChange = false  --是否显示战力变化
end

function wnd_fashion_spinning:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	
	self.fashionTb = 
	{
		["item_name"]		= widgets.item_name,
		["iten_icon"]		= widgets.item_icon,
		["item_bg"]			= widgets.item_bg,
		["power_value"] 	= widgets.power_value,
	}
	self.prop_scroll = widgets.scroll  			--时装属性
	self.consume_scroll = widgets.scroll2  		--消耗物品
	self.spinningBtn = widgets.modifyAnncBtn  	--精纺按钮
	self.spinningBtn:onClick(self, self.onSpinningBtn)
	self.model = widgets.model  --模型
	self.desc = widgets.desc    --精纺消耗说明
end

function wnd_fashion_spinning:refresh(fashionId)
	self.fashionId = fashionId
	local prop = g_i3k_game_context:GetPropertyByFashionId(fashionId)
	local propertyTb = g_i3k_game_context:ConvertVectorToMap(prop)
	local power = g_i3k_db.i3k_db_get_battle_power(propertyTb,true)
	
	local cfg = g_i3k_db.i3k_db_get_fashion_cfg(fashionId)
	local id = cfg.needItemId  --道具Id

	self.fashionTb.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self.fashionTb.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	self.fashionTb.iten_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, i3k_game_context:IsFemaleRole()))
	self.fashionTb.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	if not self._showPowerChange then
		self.fashionTb.power_value:setText(power)
	end
	
	self:updatePropScroll(prop)
	self:updateConsumeScroll()

	self:updateModel()
end

function wnd_fashion_spinning:updatePropScroll(prop)
	self.prop_scroll:removeAllChildren()
	
	for k, v in ipairs(prop) do
		local des = require(LAYER_ZBTIPST)()
		local _t = i3k_db_prop_id[v.id]
		local _desc = _t.desc
		_desc = _desc..":"
		des.vars.desc:setText(_desc)

		local maxValue = i3k_db_fashion_prop_max[v.id] and i3k_db_fashion_prop_max[v.id].maxValue or 0
		des.vars.max_img:setVisible(not (v.value < maxValue or maxValue == 0))
		
		des.vars.value:setText(i3k_get_prop_show(v.id, v.value))
		self.prop_scroll:addItem(des)
	end
end

function wnd_fashion_spinning:updateConsumeScroll()
	self.isCanSpinning = true
	self.consumeItems = {}
	self.consume_scroll:removeAllChildren()
	local timesNow = g_i3k_game_context:GetFashionSpinningTimes(self.fashionId)
	if timesNow > 0 then
		self.desc:setText(i3k_get_string(15545, PROP_OPEN_CONDITION))
	end
	
	local consumeItems = {}
	for i, v in ipairs(i3k_db_fashion_consume) do
		local cfg_times = v.spinningNum  --精纺次数
		if timesNow < cfg_times then
			consumeItems = v.item
			break
		end
	end

	if timesNow >= i3k_db_fashion_consume[#i3k_db_fashion_consume].spinningNum then
		consumeItems = i3k_db_fashion_consume[#i3k_db_fashion_consume].item
	end

	for _, v in ipairs(consumeItems) do
		if v.itemId ~= 0 and v.needCount ~= 0 then
			local node = require(LAYER_SZJFT)()
			local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.itemId)
			if math.abs(v.itemId) == g_BASE_ITEM_DIAMOND or math.abs(v.itemId) == g_BASE_ITEM_COIN then
				node.vars.item_count:setText(string.format("%d", v.needCount))
			else
				node.vars.item_count:setText(string.format("%d/%d", haveCount, v.needCount))
			end
			node.vars.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= v.needCount))
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemId,i3k_game_context:IsFemaleRole()))
			node.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemId))
			
			node.vars.bt:onClick(self, self.showItemTips, v.itemId)
			node.vars.suo:setVisible(v.itemId > 0)	

			local _t = i3k_sbean.DummyGoods.new()
			_t.id = v.itemId
			_t.count = v.needCount
			table.insert(self.consumeItems, _t)
			
			self:setSpinningState(haveCount,v.needCount)
			self.consume_scroll:addItem(node)
		end
	end
end

function wnd_fashion_spinning:setSpinningState(haveCount,needCount)
	if haveCount < needCount then
		self.isCanSpinning = false
	end
end

function wnd_fashion_spinning:onSpinningBtn()
	if self.isCanSpinning then
		i3k_sbean.fashion_worsted(self.fashionId, self.consumeItems, false)
	else
		g_i3k_ui_mgr:PopupTipMessage("精纺所需物品不足")
	end
end

function wnd_fashion_spinning:updateModel()
	local modelID = 1305
	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	self.model:setSprite(path)
	self.model:setSprSize(uiscale)
	self.model:playAction("stand")
end

function wnd_fashion_spinning:showItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

--播放动画
function wnd_fashion_spinning:playUpdateAnim()
	self._layout.anis.c_shenxin.play()
end

--展示战力的变化
function wnd_fashion_spinning:showPowerChange(oldPower, newPower)
	self._base = oldPower
	self._target = newPower
	self._showPowerChange = true
end

function wnd_fashion_spinning:onUpdate(dTime)
	if self._showPowerChange then
		self._poptick = self._poptick + dTime
		if self._poptick < 1 then
			local text = self._base + math.floor((self._target - self._base)*self._poptick)
			self.fashionTb.power_value:setText(text)
		elseif self._poptick >= 1 and self._poptick < 2 then
			self.fashionTb.power_value:setText(self._target)
		else
			self._poptick = 0
			self._base = 0
			self._target = 0
			self._showPowerChange = false
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_fashion_spinning.new()
	wnd:create(layout)
	return wnd
end
