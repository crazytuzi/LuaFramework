-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_statueInfo = i3k_class("wnd_statueInfo", ui.wnd_base)

local EXP_CFG = i3k_db_statueExp_cfg

function wnd_statueInfo:ctor()
	
end

function wnd_statueInfo:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.help_btn:onClick(self, self.onHelp)
end

function wnd_statueInfo:refresh(info, statueType)
	self._info = info
	self._roleID = info.overview.id
	self._statueType = statueType
	self:showModel(info)
	self:showStatueInfo(info)
	self._layout.vars.salute_btn:onClick(self, self.onSalute)
	self._layout.vars.check_btn:onClick(self, self.onCheckInfo)
end

function wnd_statueInfo:showModel(Data)
	local statueData = Data.overview
	local data = {}
	for k,v in pairs(Data.wear.wearEquips) do
		data[k] = v.equip.id
	end
	self:changeModel(statueData.type,statueData.bwType,statueData.gender,Data.wear.face,Data.wear.hair,data,Data.wear.curFashions, Data.wear.showFashionTypes,Data.wear.wearParts, Data.wear.armor, Data.wear.weaponSoulShow, Data.wear.soaringDisplay)
end

function wnd_statueInfo:changeModel(id, bwType, gender, face, hair, equips,fashions,isshow,equipparts,armor, weaponSoulShow, soaringDisplay)
	local modelTable = {}
	modelTable.node = self._layout.vars.hero_module
	modelTable.id = id
	modelTable.bwType = bwType
	modelTable.gender = gender
	modelTable.face = face
	modelTable.hair = hair
	modelTable.equips = equips
	modelTable.fashions = fashions
	modelTable.isshow = isshow
	modelTable.equipparts = equipparts
	modelTable.armor = armor
	modelTable.weaponSoulShow = weaponSoulShow
	modelTable.isEffectFashion = nil
	modelTable.soaringDisplay = soaringDisplay
	self:createModelWithCfg(modelTable)
end

function wnd_statueInfo:showStatueInfo(Data)
	local statueData = Data.overview
	local sectName = Data.relationship.sectName
	local roleID = g_i3k_game_context:GetRoleId()
	local gcfg = g_i3k_db.i3k_db_get_general(statueData.type)
	self._layout.vars.class_icon:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
	self._layout.vars.battle_power:setText(statueData.fightPower)
	self._layout.vars.name:setText(statueData.name)
	self:showMessage(statueData.type, statueData.name)
	if sectName and sectName ~= "" then
		self._layout.vars.sectName:setText("所属帮派："..sectName)
	else
		self._layout.vars.sectName:setText("所属帮派：暂无帮派")
	end
	
	if roleID == statueData.id then
		self._layout.vars.salute_lable:setText("擦拭")
	end
end

function wnd_statueInfo:onCheckInfo()
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleInfo, self._info, nil, nil)
end

function wnd_statueInfo:onSalute()
	local lvl = g_i3k_game_context:GetLevel()
	local selfType = g_i3k_game_context:GetRoleType()
	local exp = 0
	if lvl >= EXP_CFG.limitLvl then
		if selfType == self._info.overview.type then
			exp = math.floor((EXP_CFG.saluteTime / 10000) * (EXP_CFG.sameJopTime / 10000) * i3k_db_exp[lvl].statueExp)
		else
			exp = math.floor((EXP_CFG.saluteTime / 10000) * (EXP_CFG.diffJopTime / 10000) * i3k_db_exp[lvl].statueExp)
		end
		i3k_sbean.statueSalute(self._statueType, self._roleID, exp)
	else
		g_i3k_ui_mgr:PopupTipMessage("等级达到" .. EXP_CFG.limitLvl .. "级开启")
	end
end

function wnd_statueInfo:showMessage(roleType, name)
	local widgets = self._layout.vars
	if self._statueType == 1 then
		local declarationID = i3k_db_statueExp_power_cfg[roleType].declarationID
		widgets.des:setText(i3k_get_string(declarationID, name))
	elseif self._statueType == 2 then
		local declarationIDs = EXP_CFG.declarationIDs
		local declarationID = i3k_engine_get_rnd_u(1, #declarationIDs)
		widgets.des:setText(i3k_get_string(EXP_CFG.declarationIDs[declarationID], name))
	else
		widgets.des:setText("这货既不属于职业排行，也不属于武道会排行")
	end
end

function wnd_statueInfo:onHelp()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17034, EXP_CFG.dayTimes))
end

function wnd_create(layout)
	local wnd = wnd_statueInfo.new()
	wnd:create(layout)
	return wnd
end
