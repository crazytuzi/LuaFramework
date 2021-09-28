-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
----------此UI已废弃-----------------
wnd_checkSteedInfo = i3k_class("wnd_checkSteedInfo", ui.wnd_base)

function wnd_checkSteedInfo:ctor()
	
end

function wnd_checkSteedInfo:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	
	self.starImgTable2 = {
		[1] = widgets.star1,
		[2] = widgets.star2,
		[3] = widgets.star3,
		[4] = widgets.star4,
		[5] = widgets.star5,
	}
	
	self.attrLabelTable = {
		{root = widgets.attrRoot1, nameLabel = widgets.nameLabel1, valueLabel = widgets.attrLabel1},
		{root = widgets.attrRoot2, nameLabel = widgets.nameLabel2, valueLabel = widgets.attrLabel2},
		{root = widgets.attrRoot3, nameLabel = widgets.nameLabel3, valueLabel = widgets.attrLabel3},
		{root = widgets.attrRoot4, nameLabel = widgets.nameLabel4, valueLabel = widgets.attrLabel4},
		{root = widgets.attrRoot5, nameLabel = widgets.nameLabel5, valueLabel = widgets.attrLabel5},
	}
end

function wnd_checkSteedInfo:refresh(horseInfo)
	local refineId = i3k_db_steed_cfg[horseInfo.horseAtrrs.id].refineId
	self.refineCfg = i3k_db_steed_practice[refineId]
	self:showEnhanceAttrs(horseInfo.horseAtrrs.info.enhanceAttrs)
	self:setSelfInfo(horseInfo)
end

function wnd_checkSteedInfo:showEnhanceAttrs(enhanceAttrs)
	for i,v in ipairs(self.attrLabelTable) do
		if i <= #enhanceAttrs then
			v.root:show()
			local atrr = enhanceAttrs[i]
			if atrr.id > 0 then
				local attrName = i3k_db_prop_id[atrr.id].desc..": "
				v.nameLabel:setText(attrName)
				local color = self:getColor(atrr.value, self.refineCfg[i][atrr.id])
				if color == g_i3k_get_red_color() then
					v.valueLabel:setText(i3k_get_prop_show(atrr.id, atrr.value).."(MAX)")
				else
					v.valueLabel:setText(i3k_get_prop_show(atrr.id, atrr.value))
				end
				v.nameLabel:setTextColor(color)
				v.valueLabel:setTextColor(color)
			else
				v.nameLabel:setText("无")
				v.valueLabel:setText("0")
				v.nameLabel:stateToNormal()
				v.valueLabel:stateToNormal()
			end
		else
			v.root:hide()
		end
	end
end

function wnd_checkSteedInfo:setSelfInfo(info)
	local widgets = self._layout.vars
	local cfg = i3k_db_steed_huanhua[i3k_db_steed_cfg[info.horseAtrrs.id].huanhuaInitId]
	local mcfg = i3k_db_models[cfg.modelId]
	
	widgets.horse_name:setText(cfg.name)
	--[[if mcfg then
		widgets.horse_module:setSprite(mcfg.path);
		if info.horseAtrrs.id == 5 or info.horseAtrrs.id == 8 then        --对飞剑和龙舟模型大小做特殊处理
			widgets.horse_module:setSprSize(mcfg.uiscale + 2.5)
		else
			widgets.horse_module:setSprSize(mcfg.uiscale)
		end
		widgets.horse_module:playAction("show");
	end
	if cfg.modelRotation ~= 0 then
		widgets.horse_module:setRotation(cfg.modelRotation)
	end]]
	widgets.pracLvlLabel2:setText(info.power)
	
	for i,v in ipairs(self.starImgTable2) do
		if i > info.horseAtrrs.star then
			v:disable()
		else
			v:enable()
		end
	end
end

function wnd_checkSteedInfo:getColor(value, cfg) 
	local ratio = (value - cfg.minValue)/(cfg.maxValue - cfg.minValue)
	if ratio >= 0 and ratio < 0.2 then
		return g_i3k_get_white_color()
	elseif ratio >= 0.2 and ratio < 0.4 then
		return g_i3k_get_green_color()
	elseif ratio >= 0.4 and ratio < 0.6 then
		return g_i3k_get_blue_color()
	elseif ratio >= 0.6 and ratio < 0.8 then
	        return g_i3k_get_purple_color()
	elseif ratio >= 0.8 and ratio < 1 then
		return g_i3k_get_orange_color()
	elseif ratio >= 1 then
		return g_i3k_get_red_color()
	end
	return g_i3k_get_white_color()
end

--function wnd_checkSteedInfo:onHide()
--	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "showSteedRank")
--end

function wnd_create(layout)
	local wnd = wnd_checkSteedInfo.new()
	wnd:create(layout)
	return wnd
end
