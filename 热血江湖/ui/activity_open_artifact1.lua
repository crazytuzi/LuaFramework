-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_actvity_open_aryifact_fromhero = i3k_class("wnd_actvity_open_aryifact_fromhero", ui.wnd_base)

local LAYER_CJB1T1 = "ui/widgets/cjb1t1"
local LAYER_CJB1T2 = "ui/widgets/cjb1t2"

function wnd_actvity_open_aryifact_fromhero:ctor()

end

function wnd_actvity_open_aryifact_fromhero:configure( )
	local widgets = self._layout.vars
	self.coloseBtn = widgets.close
	self.curpurcent = widgets.curpurcent
	self.haveTimes = widgets.haveTimes
	self.model = widgets.modle
	self.tips = widgets.tips
	self.upLvlBtn = widgets.upLvlBtn
	self.upBtn = widgets.upBtn
	--self.showBtn = widgets.showBtn
	self.duigou = widgets.duigou
	self.upLvlBtntxt = widgets.upLvlBtntxt
	
	self.starUpBtn = widgets.starUpBtn
	self.scroll = widgets.scroll
	self.fightPower = widgets.fightPower

	--self.showBtn:onClick(self, self.onShowModle)
	self.coloseBtn:onClick(self, self.onCloseUI)
	self.upBtn:onClick(self, self.onClickupLvlBtn)
	self.starUpBtn:onClick(self, self.onStarUpBtn)
	self:updateModelState()
	self._weaponIcon = {8549, 8550, 8551, 8552, 8553, 8555, 8554,9777}
end

function wnd_actvity_open_aryifact_fromhero:refresh()
	self:updateUpBtnState()
	self:updateArtifactInfo()

	self.scroll:removeAllChildren()  --添加属性前清除scroll内容
	self:setBasePropScroll()
	self:setStrengthPropScroll()
	self:setStarPropScroll()

	self.fightPower:setText(g_i3k_game_context:GetHeirloomFightPower())
	local roleType = g_i3k_game_context:GetRoleType()
	self._layout.vars.weaponIcon:setImage(g_i3k_db.i3k_db_get_icon_path(self._weaponIcon[roleType]))
end

function wnd_actvity_open_aryifact_fromhero:updateHaveTimes(haveTimes, dayWipeTimes)
	local str = "剩余次数"..(haveTimes - dayWipeTimes).."/"..haveTimes.."次"
	if haveTimes == dayWipeTimes then
		str = string.format("剩余次数<c=%s>%s</c>/%s次",g_i3k_get_red_color(),(haveTimes - dayWipeTimes), haveTimes)
	end
	self.haveTimes:setText(str)
end

--强化按钮和星魂按钮的状态
function wnd_actvity_open_aryifact_fromhero:updateUpBtnState()
	local heirloom = g_i3k_game_context:getHeirloomData()
	local lvl = g_i3k_game_context:GetLevel();
	if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
		self.upLvlBtntxt:setText("强化解封")
		self:updateHaveTimes(i3k_db_chuanjiabao.cfg.haveTimes, heirloom.dayWipeTimes);
	else
		self.upLvlBtntxt:setText("精炼强化")
		if lvl >= i3k_db_chuanjiabao_strength.cfg.levelLimit then
			local heirloomStreng = g_i3k_game_context:getHeirloomStrengthData();
			self.tips:hide()
			self.upLvlBtn:enableWithChildren();
			self:updateHaveTimes(i3k_db_chuanjiabao_strength.cfg.dayStrengthTime, heirloomStreng.dayStrengthTime);
		else
			self.haveTimes:hide();
			self.upLvlBtn:disableWithChildren();
		end
	end

	self.starUpBtn:setVisible(lvl >= i3k_db_chuanjiabao.cfg.showLvl)
end

--传家宝信息展示
function wnd_actvity_open_aryifact_fromhero:updateArtifactInfo()
	local nextvalue = nil
	local heirloom = g_i3k_game_context:getHeirloomData()
	self.curpurcent:setText("当前完美度："..heirloom.perfectDegree)

	for i = #i3k_db_chuanjiabao.props , 1 , -1 do
		if heirloom.perfectDegree >= i3k_db_chuanjiabao.props[i].wanmeidu then
			if i3k_db_chuanjiabao.props[i+1] then
				nextvalue = i3k_db_chuanjiabao.props[i+1].wanmeidu
			end
			break
		end
	end
	if nextvalue then
		if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
			self.tips:setText(string.format("达到%d%s", nextvalue, "完美提升属性"))
		else
			local lvl = g_i3k_game_context:GetLevel();
			if lvl < i3k_db_chuanjiabao_strength.cfg.levelLimit then
				self.tips:show();
				self.tips:setText(i3k_get_string(15462, i3k_db_chuanjiabao_strength.cfg.levelLimit));
			end
		end
	else
		self.haveTimes:hide()
	end

	--[[if heirloom.display == 1 then
		self.duigou:show()
		self.showBtn:stateToPressed()
	else
		self.duigou:hide()
		self.showBtn:stateToNormal()
	end--]]
end

--基础属性
function wnd_actvity_open_aryifact_fromhero:setBasePropScroll()
	local baseProp = g_i3k_game_context:getHeirloomProps()

	local isMax = true
	local heirloom = g_i3k_game_context:getHeirloomData()
	for i = #i3k_db_chuanjiabao.props, 1, -1 do
		if heirloom.perfectDegree >= i3k_db_chuanjiabao.props[i].wanmeidu then
			if i3k_db_chuanjiabao.props[i + 1] then
				isMax = false
			end
			break
		end
	end

	if next(baseProp) then
		local header = require(LAYER_CJB1T1)()
		header.vars.name:setText("基础属性")
		self.scroll:addItem(header)

		local prop = self:sortProp(baseProp)
		for _, e in ipairs(prop) do
			local des = require(LAYER_CJB1T2)()
			local _t = i3k_db_prop_id[e]
			des.vars.propertyName:setText(_t.desc)
			des.vars.propertyValue:setText(i3k_get_prop_show(e, baseProp[e]))
			des.vars.propIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(e)))
			des.vars.max:setVisible(isMax)
			self.scroll:addItem(des)
		end
	end
end

--强化属性
function wnd_actvity_open_aryifact_fromhero:setStrengthPropScroll()
	local strengthProp = g_i3k_game_context:getHeirloomStrengthProps()
	local Strength = g_i3k_game_context:getHeirloomStrengthData()

	local strengthData = nil
	local isMax = false
	local propIsMax = {[ePropID_maxHP] = false, [ePropID_defN] = false, [ePropID_atkN] = false}
	if Strength.layer > #i3k_db_chuanjiabao_strength.strength then
		isMax = true
	end
	if isMax then
		strengthData = i3k_db_chuanjiabao_strength.strength[Strength.layer - 1]
	else
		strengthData = i3k_db_chuanjiabao_strength.strength[Strength.layer]
	end
	if (Strength and Strength.layer == 5) then
		if Strength.StrengthPro[ePropID_maxHP] and Strength.StrengthPro[ePropID_maxHP] >= strengthData.pro3 then
			propIsMax[ePropID_maxHP] = true
		end
		if Strength.StrengthPro[ePropID_defN] and Strength.StrengthPro[ePropID_defN] >= strengthData.pro2 then
			propIsMax[ePropID_defN] = true
		end 
		if Strength.StrengthPro[ePropID_atkN] and Strength.StrengthPro[ePropID_atkN] >= strengthData.pro1 then
			propIsMax[ePropID_atkN] = true
		end
	end

	if next(strengthProp) then
		local header = require(LAYER_CJB1T1)()
		header.vars.name:setText("强化属性")
		self.scroll:addItem(header)

		local prop = self:sortProp(strengthProp)
		for _, e in ipairs(prop) do
			local des = require(LAYER_CJB1T2)()
			local _t = i3k_db_prop_id[e]
			des.vars.propertyName:setText(_t.desc)
			des.vars.propertyValue:setText(i3k_get_prop_show(e, strengthProp[e]))
			des.vars.propIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(e)))
			if isMax then
				des.vars.max:setVisible(true)
			else
				des.vars.max:setVisible(propIsMax[e])
			end
			self.scroll:addItem(des)
		end
	end
end

--星魂属性
function wnd_actvity_open_aryifact_fromhero:setStarPropScroll()
	local starProp = g_i3k_game_context:getXingHunProps()

	if next(starProp) then
		--不显示主星属性
		local cfg = g_i3k_db.i3k_db_get_main_star_up_cfg(g_i3k_game_context:GetRoleType(), g_i3k_game_context:getHeirloomData().starSpirit.mainStarLvl)
		for _, v in ipairs(cfg and cfg.propIds or {}) do
			if starProp[v] then
				starProp[v] = nil
			end
		end

		local header = require(LAYER_CJB1T1)()
		header.vars.name:setText("星魂属性")
		self.scroll:addItem(header)

		local prop = self:sortProp(starProp)
		for _, e in ipairs(prop) do
			local des = require(LAYER_CJB1T2)()
			local _t = i3k_db_prop_id[e]
			des.vars.propertyName:setText(_t.desc)
			des.vars.propertyValue:setText(i3k_get_prop_show(e, starProp[e]))
			des.vars.propIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(e)))
			des.vars.max:setVisible(false)
			self.scroll:addItem(des)
		end
	end
end

-- 参数为Key value形式，返回一个排序好的key数组
function wnd_actvity_open_aryifact_fromhero:sortProp(prop)
	local temp = {}
	for k, v in pairs(prop) do
		table.insert(temp, k)
	end
	table.sort(temp)
	return temp
end

--[[function wnd_actvity_open_aryifact_fromhero:onShowModle(sender)
	if sender:isStatePressed() then
		self.duigou:hide()
		sender:stateToNormal()
		i3k_sbean.setHeirloomdisplay(0)
	else
		self.duigou:show()
		sender:stateToPressed()
		i3k_sbean.setHeirloomdisplay(1)
	end
end--]]

function wnd_actvity_open_aryifact_fromhero:updateModelState()
	local cfg = i3k_db_seven_keep_activity[3]
	local roleType = g_i3k_game_context:GetRoleType()
	local showId = cfg.rewardShow[roleType]
	if cfg.rewardType == 1 then
		ui_set_hero_model(self.model, showId)
		local path = i3k_db_models[showId].path
		local uiscale = i3k_db_models[showId].uiscale
		self.model:setSprite(path)
		self.model:setSprSize(uiscale)
	else
		g_i3k_game_context:SetTestFashionData(showId)
		ui_set_hero_model(self.model, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips())
	end
	for k,v in pairs(cfg.effectList) do
		self.model:pushActionList(v, 1)
	end
	self.model:pushActionList("stand", -1)
	self.model:playActionList()
	if cfg.modelRotation ~= 0 then
		self.model:setRotation(cfg.modelRotation)
	else
		self.model:setRotation(math.pi/2,-0.2)
	end
end

function wnd_actvity_open_aryifact_fromhero:onClickupLvlBtn()
	local heirloom = g_i3k_game_context:getHeirloomData()
	local lvl = g_i3k_game_context:GetLevel();
	if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
		g_i3k_ui_mgr:OpenUI(eUIID_OpenArtufact)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OpenArtufact,"setType",2)
	else
		if lvl >= i3k_db_chuanjiabao_strength.cfg.levelLimit then
			g_i3k_ui_mgr:OpenUI(eUIID_OpenArtufact)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_OpenArtufact,"setType",2)
		else
			g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15462, i3k_db_chuanjiabao_strength.cfg.levelLimit));
		end
	end
end

function wnd_actvity_open_aryifact_fromhero:onStarUpBtn()
	local lvl = g_i3k_game_context:GetLevel()
	local transLvl = g_i3k_game_context:GetTransformLvl()
	if lvl >= i3k_db_chuanjiabao.cfg.openLvl then
		if transLvl >= i3k_db_chuanjiabao.cfg.needTransformLvl then
			g_i3k_ui_mgr:OpenUI(eUIID_XingHun)
			g_i3k_ui_mgr:RefreshUI(eUIID_XingHun)
		else
			g_i3k_ui_mgr:PopupTipMessage(string.format("神器星魂功能%s转开启", i3k_db_chuanjiabao.cfg.needTransformLvl))
		end
	else 
		g_i3k_ui_mgr:PopupTipMessage(string.format("神器星魂功能将于%s级开启", i3k_db_chuanjiabao.cfg.openLvl))
	end
end

function wnd_create(layout)
	local wnd = wnd_actvity_open_aryifact_fromhero.new()
	wnd:create(layout)
	return wnd
end
