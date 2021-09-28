-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_roleDynamicTitle = i3k_class("wnd_roleDynamicTitle",ui.wnd_base)
local LAYER_ZBTIPST = "ui/widgets/chenghaodtt"
function wnd_roleDynamicTitle:ctor()
end

function wnd_roleDynamicTitle:configure(...)
	local widgets			= self._layout.vars
	self.scroll				= widgets.scroll
	self.itemGrade_lable 	= widgets.itemGrade_lable
	self.get_label 			= widgets.get_label
	self.hero_module 		= widgets.hero_module
	self.titleSpr 			= widgets.titleSpr
	widgets.close:onClick(self, self.onCloseUI)	
end

function wnd_roleDynamicTitle:refresh(info)
	self:onShowData(info)
	self:updateModle(info)
end

function wnd_roleDynamicTitle:updateModle(info)
	local cfg = i3k_db_title_base[info.id]
	if cfg and cfg.dynamicSPR then
		local mcfg = i3k_db_models[cfg.dynamicSPR];
		if mcfg then
			self.titleSpr:setSprite(mcfg.path);
			self.titleSpr:setSprSize(mcfg.uiscale);
			self.titleSpr:playAction(i3k_db_common.engine.defaultStandAction);
		end
	end
	ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion())
end

function wnd_roleDynamicTitle:onShowData(info)
	local isHave = g_i3k_game_context:GetAllRoleTitle()
	local endTime = 0
	for k,v in pairs(isHave) do
		if info.id == k then
			endTime = v 
			break
		end
	end
	if info.time > 0 then
		if endTime ~= 0 then
			local serverTime = i3k_game_get_time()
			serverTime = i3k_integer(serverTime)
			local nowTime = endTime - serverTime
			local hour = math.modf(nowTime/(3600*24) * 24)
			local min = math.fmod(math.floor(nowTime/60), 60)
			local sec = math.fmod(nowTime, 60)
			local str
			if hour >= 1 then
				str = string.format("剩余%s小时%s分钟",hour,min)
			elseif hour < 1 then
				str = string.format("剩余%s分钟%s秒", min, sec)
			end
			self.itemGrade_lable:setText("时效:" .. str)
		else
			local nowTime = info.time
			local hour = math.modf(nowTime/(3600*24) * 24)
			local min = math.fmod(math.floor(nowTime/60), 60)
			local sec = math.fmod(nowTime, 60)
			local str
			if hour >= 1 then
				str = string.format("保存%s小时%s分钟",hour,min)
			elseif hour < 1 then
				str = string.format("保存%s分钟%s秒", min, sec)
			end
			self.itemGrade_lable:setText("时效:" .. str)
		end
		local hour = math.modf(info.time/(3600*24) * 24)
		local str = string.format(info.nameDesc, hour)
		self.get_label:setText(str)
	else
		local str = string.format(info.nameDesc)
		self.get_label:setText(str)
		self.itemGrade_lable:setText("时效:长久")
	end
	for i = 1, #info.attribute do
		if info.attribute[i] ~= 0 then 
			local _layer = require(LAYER_ZBTIPST)()
			local widget = _layer.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(info.attribute[i])
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(info.attribute[i]))
			widget.propertyValue:setText(i3k_get_prop_show(info.attribute[i], info.value[i]))
			self.scroll:addItem(_layer)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_roleDynamicTitle.new()
	wnd:create(layout)
	return wnd
end
