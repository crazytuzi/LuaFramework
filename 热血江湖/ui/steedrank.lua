-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_steedRank = i3k_class("wnd_steedRank", ui.wnd_base)

local f_rankImg = {2718, 2719, 2720}
local breakImage = {5325, 5326, 5327}

function wnd_steedRank:ctor()
	
end

function wnd_steedRank:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.close_left:onClick(self, self.onCloseLeft)
	self.starImgTable = {
		[1] = widgets.star1,
		[2] = widgets.star2,
		[3] = widgets.star3,
		[4] = widgets.star4,
		[5] = widgets.star5,
	}
	
	self.starImgTable2 = {
		[1] = widgets.star6,
		[2] = widgets.star7,
		[3] = widgets.star8,
		[4] = widgets.star9,
		[5] = widgets.star10,
	}
	
	self.attrLabelTable = {
		{root = widgets.attrRoot1, nameLabel = widgets.nameLabel1, valueLabel = widgets.attrLabel1},
		{root = widgets.attrRoot2, nameLabel = widgets.nameLabel2, valueLabel = widgets.attrLabel2},
		{root = widgets.attrRoot3, nameLabel = widgets.nameLabel3, valueLabel = widgets.attrLabel3},
		{root = widgets.attrRoot4, nameLabel = widgets.nameLabel4, valueLabel = widgets.attrLabel4},
		{root = widgets.attrRoot5, nameLabel = widgets.nameLabel5, valueLabel = widgets.attrLabel5},
	}
end

function wnd_steedRank:refresh(info)
	local cfg = {id = info.id, power = info.power, starLv = g_i3k_game_context:getSteedInfoBySteedId(info.id).star}
	self:setSteedInfo(info.id, info.power)
	self:showRank(info)
	self:showSelfRank(info)
	self._layout.vars.get_stronger:onClick(self, self.getStronger, cfg)
end

function wnd_steedRank:setSteedInfo(id, power)
	local cfg = i3k_db_steed_huanhua[i3k_db_steed_cfg[id].huanhuaInitId]
	local mcfg = i3k_db_models[cfg.modelId]
	local starLvl = g_i3k_game_context:getSteedInfoBySteedId(id).star
	self._layout.vars.steed_name:setText(cfg.name)
	self._layout.vars.rankName:setText(cfg.name.."排行榜")
	if mcfg then
		self._layout.vars.model:setSprite(mcfg.path);
		if id == 5 or id == 8 then                                     --对飞剑和龙舟模型大小做特殊处理
			self._layout.vars.model:setSprSize(mcfg.uiscale + 2.5)
		else
			self._layout.vars.model:setSprSize(mcfg.uiscale);
		end
		self._layout.vars.model:playAction("show");
	end
	if cfg.modelRotation ~= 0 then
		self._layout.vars.model:setRotation(cfg.modelRotation)
	end
	self._layout.vars.pracLvlLabel:setText(power)
	
	for i,v in ipairs(self.starImgTable) do
		if i>starLvl then
			v:disable()
		else
			v:enable()
		end
	end
	local breakLevel = g_i3k_game_context:GetSteedBreakInfo(id)
	if breakLevel <= 0 then
		self._layout.vars.breakImage:hide()
		self._layout.vars.starRoot:show()
	else
		self._layout.vars.breakImage:show()
		self._layout.vars.breakImage:setImage(g_i3k_db.i3k_db_get_icon_path(breakImage[breakLevel]))
		self._layout.vars.starRoot:hide()
	end	
end

function wnd_steedRank:showRank(info)
	local scroll = self._layout.vars.rank_scroll
	scroll:removeAllChildren()
	for i, v in ipairs(info.allPlayers) do
		local pht = require("ui/widgets/zqpht")()
		local role = v.role
		if i<=3 then
			pht.vars.rankImg:show()
			pht.vars.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[i]))
			pht.vars.rankLabel:hide()
		else
			pht.vars.rankImg:hide()
			pht.vars.rankLabel:show()
			pht.vars.rankLabel:setText(i..".")
		end
		pht.vars.name:setText(role.name)
		pht.vars.occupation:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[role.type].classImg))
		
		pht.vars.power:setText(v.rankKey)
		local cfg = {power = v.rankKey, horseAtrrs = info.horseInfo[role.id], name = role.name, index = i}
		pht.vars.btn:onClick(self, self.getSteedInfo, cfg)
		scroll:addItem(pht)
	end
end

function wnd_steedRank:getSteedInfo(sender, horseInfo)
	local refineId = i3k_db_steed_cfg[horseInfo.horseAtrrs.id].refineId
	self.refineCfg = i3k_db_steed_practice[refineId]
	self._layout.vars.infoRoot:show()
	self:updateScrollBtnState(horseInfo.index)
	self:showEnhanceAttrs(horseInfo.horseAtrrs.info.enhanceAttrs)
	self:setSelfInfo(horseInfo)
end

function wnd_steedRank:getStronger(sender, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_PromoteSteed)
	g_i3k_ui_mgr:RefreshUI(eUIID_PromoteSteed, cfg)
end

function wnd_steedRank:showSelfRank(info)
	local num = 100
	if info.count > 1 then
		num = tonumber(string.format("%0.2f", (info.count - info.selfRank) * 100 / (info.count - 1)))	
	end
	self._layout.vars.yourRank:setText(num.."%")
end

function wnd_steedRank:showEnhanceAttrs(enhanceAttrs)
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

function wnd_steedRank:setSelfInfo(info)
	local widgets = self._layout.vars
	--local cfg = i3k_db_steed_huanhua[i3k_db_steed_cfg[info.horseAtrrs.id].huanhuaInitId]
	--local mcfg = i3k_db_models[cfg.modelId]
	
	widgets.player_name:setText(info.name)
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
	if info.horseAtrrs.info.breakLvl <= 0 then
		self._layout.vars.breakImage2:hide()
		self._layout.vars.starRoot2:show()
	else
		self._layout.vars.breakImage2:show()
		self._layout.vars.breakImage2:setImage(g_i3k_db.i3k_db_get_icon_path(breakImage[info.horseAtrrs.info.breakLvl]))
		self._layout.vars.starRoot2:hide()
	end
end

function wnd_steedRank:getColor(value, cfg) 
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

function wnd_steedRank:updateScrollBtnState(index)
	local scroll = self._layout.vars.rank_scroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		if index == k then
			v.vars.btn:stateToPressed()
		else
			v.vars.btn:stateToNormal(true)
		end
	end
end

function wnd_steedRank:onCloseLeft(sender)
	self._layout.vars.infoRoot:hide()
end

function wnd_create(layout)
	local wnd = wnd_steedRank.new()
	wnd:create(layout)
	return wnd
end
