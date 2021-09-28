-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-----------------飞升界面---------------------------------
local wnd_feisheng = i3k_class("wnd_feisheng", ui.wnd_base)
function wnd_feisheng:ctor()
	
end

function wnd_feisheng:configure()
	self.ui = self._layout.vars
	self.ui.close:onClick(self, self.onCloseUI)
	self.p_page = 1
	self.ui.expItemBtn:onClick(self, self.onExpItemBtnClick)
end

--return #1返回0为正在升级，1为可升级，2为满级
local function wnd_State(exp, nxtLvlExp, lvl)
	local cfg = i3k_db_role_flying
	if exp >= nxtLvlExp then
		if cfg[lvl + 1] then
			return 1
		else
			return 2
		end
	end
	return 0
end

local function setui(self, i)
	local hero = i3k_game_get_player_hero()
	local fs = g_i3k_game_context:getFeishengInfo()
	local cfg = i3k_db_role_flying[self.p_page]
	local tp = cfg["showType"..i]
	local value = cfg["arg"..i]
	local icon = self.ui['ic'..i]
	local m = self.ui['m'..i]
	local button = self.ui['hunyuanjindou_btn']
	local rankImg = self.ui['equip_rank_img']
	local equipImg = self.ui['equip_img']
	local redPoint = self.ui['red_point']
	self.ui['tt'..i]:setText(cfg['title'..i])
	self.ui['bt'..i]:setText(cfg['bottomStr'..i])
	
	icon:setVisible(false)
	m:setVisible(false)
	button:setVisible(false)
	button:onClick(self, self.onsetuiButtonClick)
	if i == 1 then
		rankImg:setVisible(false)
		equipImg:setVisible(false)
	else
		redPoint:setVisible(false)
	end
	if tp == 1 then
		m:setVisible(true)
		ui_set_hero_model(m, hero, g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), false, nil, i3k_db_common.engine.defaultRunAction)
		if hero and hero._soaringDisplay.footEffect ~= 0 then
			local effectId = 0
			if g_i3k_game_context:GetTransformBWtype() == 1 then
				effectId = i3k_db_feet_effect[hero._soaringDisplay.footEffect].justiceUIEffect
			else
				effectId = i3k_db_feet_effect[hero._soaringDisplay.footEffect].evilUIEffect
			end
			self:changeFootEffect(m, effectId)
		end
		m:setRotation(0.5,0,6.12);
	elseif tp == 2 then
		m:setVisible(true)
		local index = g_i3k_game_context:GetRoleType() * 2 + g_i3k_game_context:GetTransformBWtype() - 2
		local weaponId = cfg.weaponId[index]
		local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(weaponId)
		local weaponModel = 0
		if g_i3k_game_context:GetTransformBWtype() == 1 then
			if g_i3k_game_context:IsFemaleRole() then
				weaponModel = equipCfg.skin_ZF_ID
			else
				weaponModel = equipCfg.skin_ZM_ID
			end
		else
			if g_i3k_game_context:IsFemaleRole() then
				weaponModel = equipCfg.skin_XF_ID
			else
				weaponModel = equipCfg.skin_XM_ID
			end
		end
		ui_set_hero_model(m, weaponModel[1])
	elseif tp == 3 then
		local ic = g_i3k_db.i3k_db_get_icon_path(value)
		icon:setVisible(true)
		icon:setImage(ic)
	elseif tp == 4 then
		m:setVisible(true)
		local index = g_i3k_game_context:GetRoleType() * 2 + g_i3k_game_context:GetTransformBWtype() - 2
		local equipId = cfg.weaponId[index]
		ui_set_hero_model(m, hero, g_i3k_game_context:GetWearEquips(), false, false, nil, nil, equipId)
	elseif tp == 5 then
		local ic = g_i3k_db.i3k_db_get_icon_path(value)
		icon:setVisible(true)
		icon:setImage(ic)
		local index = g_i3k_game_context:GetRoleType() * 2 + g_i3k_game_context:GetTransformBWtype() - 2
		local equipId = cfg.weaponId[index]
		rankImg:setVisible(true)
		rankImg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipId))
		equipImg:setVisible(true)
		equipImg:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipId,g_i3k_game_context:IsFemaleRole()))
	elseif tp == 6 then
		local ic = g_i3k_db.i3k_db_get_icon_path(value)
		button:setVisible(true)
		button:setImage(ic)
		local canSharpen = g_i3k_game_context:isFlyingSharpenHaveRedPoint()
		local canTrans = g_i3k_game_context:isFlyingTransHaveRedPoint()
		local flyingLevel = g_i3k_game_context:getFlyingLevel()
		local level_limit = 6
		redPoint:setVisible(flyingLevel >= level_limit and (canSharpen or canTrans))
	end
end

function checkBoundary(self)
	if self.p_page == 1 then
		self.ui.lb:setVisible(false)
	end
	if self.p_page == #i3k_db_role_flying then
		self.ui.rb:setVisible(false)
	end
end

function updateBoth(self)
	local cfg = i3k_db_role_flying[self.p_page]
	
	checkBoundary(self)
	setui(self, 1)
	setui(self, 2)
	
	if cfg.text3 then
		self.ui.txt3:setText(cfg.text3)
	else
		self.ui.txt3:setText("")
	end
	
	self.ui.prop:removeAllChildren()
	for i, v in ipairs(i3k_db_role_flying[self.p_page].property) do
		if v.id ~= 0 then
			local wg = require("ui/widgets/feishengcgt")()
			local prevVal = i3k_db_role_flying[self.p_page - 1] and i3k_db_role_flying[self.p_page - 1].property[i].value or 0
			
			wg.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
			wg.vars.name:setText(g_i3k_db.i3k_db_get_property_name(v.id))
			wg.vars.value:setText(i3k_get_prop_show(v.id, v.value - prevVal))
			self.ui.prop:addItem(wg)
		end
	end
end

function wnd_feisheng:refresh()
	local fs = g_i3k_game_context:getFeishengInfo()
	local lvl = fs._level
	local cfg = i3k_db_role_flying
	local max = not cfg[lvl + 1]
	local ugdNedExp
	if max then
		ugdNedExp = fs._exp
	else
		ugdNedExp = cfg[lvl + 1].upgradeNeedExp
	end
	local msg = max and tostring(fs._exp) or string.format("%s/%s", fs._exp, ugdNedExp)

	self.ui.expbar:setPercent(100 * fs._exp / ugdNedExp)
	self.ui.level:setText(i3k_get_string(1770, lvl))
	self.ui.exp:setText(msg)
	self.ui.desc:setText(i3k_get_string(1762, fs._cfg.maxExp))

	self.p_page = lvl
	
	self.ui.upgrade:onClick(self, function()
		local state = wnd_State(fs._exp, ugdNedExp, lvl)
		if fs._upgraing then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1763))
		elseif state == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1764))
		elseif state == 2 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1765))
		else
			g_i3k_ui_mgr:OpenAndRefresh(eUIID_FeiShengUpgrade)
		end
	end)
	self.ui.ugdTxt:setText(max and i3k_get_string(1768) or i3k_get_string(1769))
	self.ui.lb:onClick(self, function()
		self.p_page = self.p_page - 1
		updateBoth(self)
		if self.p_page == #cfg - 1 then
			self.ui.rb:setVisible(true)
		end
	end)
	
	self.ui.rb:onClick(self, function()
		self.p_page = self.p_page + 1
		updateBoth(self)
		if self.p_page == 2 then
			self.ui.lb:setVisible(true)
		end
	end)

	updateBoth(self)
end

function wnd_feisheng:onExpItemBtnClick(sender)
	local diff = self:getExpDiff()
	local itemID = i3k_db_feisheng_misc.expItemList[1]
	if diff < i3k_db_new_item[itemID].args1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1792))
	else
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingExpItem)
	end
end
function wnd_feisheng:getExpDiff()
	local currentExp = g_i3k_game_context:getFlyingExp()
	local maxExp = g_i3k_game_context:getFlyingMaxExp()
	return maxExp - currentExp
end
function wnd_feisheng:updateFlyingExp(items)
	local exp = g_i3k_game_context:getFlyingExp()
	for k, v in pairs(items) do
		exp = exp + i3k_db_new_item[math.abs(k)].args1 * v
	end
	g_i3k_game_context:setFlyingExp(exp)
	g_i3k_ui_mgr:RefreshUI(eUIID_FeiSheng)
end
function wnd_feisheng:onsetuiButtonClick(sender)
	local level_limit = 6
	if g_i3k_game_context:isFinishFlyingTask(level_limit) then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingEquipSharpen)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1809))
	end
end
function wnd_create(layout)
	local wnd = wnd_feisheng.new()
	wnd:create(layout)
	return wnd
end







	
	

	
	


	
	







		










	


	






	
	
	






	
	
	













	










	
	





	
	
		
	
	
