-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
local starPoint	= "ui/widgets/xingyaot1"
local propArg1	= "ui/widgets/xyjmt1"
local propArg2	= "ui/widgets/xyjmt2"
local PointBg	= 4780;
local starX = i3k_db_martial_soul_cfg.starLength
local starY = i3k_db_martial_soul_cfg.starWide

wnd_star_flare = i3k_class("wnd_star_flare",ui.wnd_base)

function wnd_star_flare:ctor()
	self._curStarId = 0
end

function wnd_star_flare:configure()
	local widgets = self._layout.vars
	self.useText	= widgets.useText
	self.lead		= widgets.lead
	self.use		= widgets.use
	self.useText	= widgets.useText
	self.propScroll	= widgets.propScroll
	self.starScroll	= widgets.starScroll
	self.useBtnText	= widgets.useBtnText
	self.powerText	= widgets.powerText
	self.leadBtn	= widgets.leadBtn
	self.useBtn		= widgets.useBtn
	self.lockBtn	= widgets.lockBtn
	self.propText	= widgets.propText
	self.starName	= widgets.starName
	self.starBg		= widgets.starBg
	self.addText	= widgets.additionText;

	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_star_flare:isCanLock(starID)
	local actives = g_i3k_game_context:GetActiveStars()
	if actives then
		local rank = i3k_db_star_soul[starID].rank;
		for k,v in pairs(actives) do
			local rank1 = i3k_db_star_soul[k].rank;
			if rank1 and rank1 == rank then
				return true;
			end
		end
	end
	
	return false;
end

function wnd_star_flare:onLockBtn(sender, starID)
	if self:isCanLock(starID) then
		if not g_i3k_ui_mgr:GetUI(eUIID_StarLock) then
			g_i3k_ui_mgr:OpenUI(eUIID_StarLock)
			g_i3k_ui_mgr:RefreshUI(eUIID_StarLock, starID)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1149))
	end
end

function wnd_star_flare:onLeadBtn(sender, starId)
	local tmp_str = i3k_get_string(1121)
	local fun = (function(ok)
		if ok then
			g_i3k_game_context:SetExpectDish(starId)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "LeadStarDish", starId)
			g_i3k_ui_mgr:CloseUI(eUIID_StarFlare);
		end
	end)
	g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1139), i3k_get_string(1140), tmp_str, fun)
end

function wnd_star_flare:onUseBtn(sender, starId)
	i3k_sbean.SetCurStar(starId)
end

function wnd_star_flare:refresh(starId)
	self:rightData(starId)
	self:leftData(starId)
end

function wnd_star_flare:leftData(starId)
	self.lead:hide()
	self.use:hide()
	if g_i3k_game_context:isHaveStar(starId) then
		self.lockBtn:hide()
		self.use:show()
		self.useBtn:onClick(self, self.onUseBtn, starId)
		if g_i3k_game_context:isUseStar(starId) then
			self.useBtn:disableWithChildren()
			self.useBtnText:setText(i3k_get_string(1028))
		else
			self.useBtn:enableWithChildren()
		end
	else
		self.lead:show()
		self.lockBtn:onClick(self, self.onLockBtn, starId)
	end
	self.leadBtn:onClick(self, self.onLeadBtn, starId)
	
	self.propScroll:removeAllChildren()
	local rankCfg = i3k_db_star_soul[starId]
	if rankCfg then
		local count = g_i3k_game_context:GetActiveStarsCount(starId);
		local addition = i3k_db_martial_soul_cfg.addition[count];
		if count > 1 and count < 4 then
			local nextAdd = i3k_db_martial_soul_cfg.addition[count + 1];
			self.addText:setText(i3k_get_string(1153, count, addition * 100).."\n"..i3k_get_string(1154, count + 1, nextAdd * 100))
		elseif count == 4 then
			self.addText:setText(i3k_get_string(1153, count, addition * 100))
		else
			for i,e in ipairs(i3k_db_martial_soul_cfg.addition) do
				if e > 0 then
					self.addText:setText(i3k_get_string(1154, i, e * 100))
					break;
				end
			end
		end
		local power = math.modf(g_i3k_db.i3k_db_get_battle_power(g_i3k_game_context:GetStarPropData(starId)))
		self.powerText:setText(power)
		self.starName:setText(rankCfg.name)
		local prop = {};
		if rankCfg.bgIcon and rankCfg.bgIcon > 0 then
			self.starBg:show():setImage(g_i3k_db.i3k_db_get_icon_path(rankCfg.bgIcon))
		end
		for _, e in ipairs(rankCfg.propTb) do
			if e.propID ~= 0 then
				table.insert(prop, e);
			end
		end
		local node = require(propArg1)()
		local all_layer = self.propScroll:addItemAndChild(propArg1, 2, #prop)
		for i,e in ipairs(prop) do
			local icon = g_i3k_db.i3k_db_get_property_icon(e.propID)
			all_layer[i].vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			all_layer[i].vars.propertyName:setText(g_i3k_db.i3k_db_get_property_name(e.propID))
			if addition and addition > 0 then
				local value = e.propValue + e.propValue * addition;
				all_layer[i].vars.propertyValue:setText(i3k_get_prop_show(e.propID, value))
			else
				all_layer[i].vars.propertyValue:setText(i3k_get_prop_show(e.propID, e.propValue))
			end
		end	
		self.propText:setText(rankCfg.specialDes);
	end
end

function wnd_star_flare:setCurStarColr(all_layer, starId)
	local star = i3k_db_star_soul[starId]
	if star then
		for i,e in ipairs(star.starDisk) do
			local widget = all_layer[e + 1].vars
			local color = i3k_db_star_soul_colored_color[star.color[i]].iconID;
			widget.point:show():setImage(g_i3k_db.i3k_db_get_icon_path(color))
		end
	end
end

function wnd_star_flare:rightData(starId)
	self.starScroll:removeAllChildren()
	self.starScroll:setBounceEnabled(false)
	local cfg = i3k_db_martial_soul_cfg;
	local all_layer = self.starScroll:addItemAndChild(starPoint, starX, starX*starY)
	for  i=1, starX*starY do
		local widget = all_layer[i].vars
		widget.poinText:hide()
		widget.point:hide()
		widget.pointBg:setImage(g_i3k_db.i3k_db_get_icon_path(PointBg))
	end
	self:setCurStarColr(all_layer, starId);
end

function wnd_create(layout)
	local wnd = wnd_star_flare.new()
	wnd:create(layout)
	return wnd
end
	