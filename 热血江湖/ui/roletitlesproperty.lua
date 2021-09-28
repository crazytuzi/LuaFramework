module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_roleTitlesProperty = i3k_class("wnd_roleTitlesProperty", ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/zbtipst"

function wnd_roleTitlesProperty:ctor()

end



function wnd_roleTitlesProperty:configure()
	local widgets = self._layout.vars
	local globel_bt = widgets.globel_bt
	globel_bt:onClick(self, self.onClose)
	self.roleTitleName   = widgets.itemName_label
	self.roleTitleIron   = widgets.item_icon
	self.roleTitleIronBg = widgets.item_bg
	self.scroll        = widgets.scroll
	self.itemGrade_lable = widgets.itemGrade_lable
	self.get_label = widgets.get_label
	
end
function wnd_roleTitlesProperty:onShowData(info)
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
			--local hour = math.fmod(math.floor(nowTime/3600), 24)
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
			--local hour = math.fmod(math.floor(nowTime/3600), 24)
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
	self.roleTitleName:setVisible(false)
	self.roleTitleIron:setVisible(true)
	self.roleTitleIronBg:setVisible(true)
	self.roleTitleIronBg:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconbackground))
	self.roleTitleIron:setImage(g_i3k_db.i3k_db_get_icon_path(info.name))
	for i = 1, #info.attribute do
		if info.attribute[i] ~= 0 then
			local _layer = require(LAYER_ZBTIPST)()
			local widget = _layer.vars
			local _t = i3k_db_prop_id[info.attribute[i]]
			local colour1 = _t.textColor
			local colour2 = _t.valuColor
			widget.desc:setText(i3k_db_prop_id[info.attribute[i]].desc.."：")
			--widget.desc:setTextColor(colour1)
			--widget.iron:setImage(g_i3k_db.i3k_db_get_property_icon_path(propertyId[k]))
			widget.value:setText(i3k_get_prop_show(info.attribute[i],info.value[i]))
			--widget.value:setTextColor(colour2)
			self.scroll:addItem(_layer)
		end
	end
	
end

function wnd_roleTitlesProperty:refresh(info)
	self:onShowData(info)
end



function wnd_roleTitlesProperty:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleTitlesProperty)
end

function wnd_create(layout)
	local wnd = wnd_roleTitlesProperty.new();
		wnd:create(layout);

	return wnd;
end
