-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_streng_tips = i3k_class("wnd_streng_tips", ui.wnd_base)

local LAYER_TZJLT = "ui/widgets/tzjlt"


--title,title描边,属性，属性描边
local NOT_FINISH =	{'ffefdabc', 'ff9d714a', 'ff774d2a', 'ffa47848'}
local FINISH = 		{'fffffd6c', 'ffe5691f', 'ffe5691f', 'ff5b7838'}

--标题图标
local Title_Icon = {
	[1] = {finish = 8431, not_finish = 8430 },
	[2] = {finish = 8429 , not_finish = 8428 },
	[3] = {finish = 8427 , not_finish = 8426 },
}
--底板
local FINISH_IMAGE =  8023
local NOT_FINISH_IMAGE = 6204
function wnd_streng_tips:ctor()
	self._type = 0
end

function wnd_streng_tips:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onClose)
	self.title = widgets.title
	self.scroll = widgets.scroll
	self.bottomTips = widgets.bottomTips
end

function wnd_streng_tips:refresh(class)
	self._type = class
	self:updateTitle(self._type)
	local qh_t = g_i3k_db.i3k_db_get_property_reward_count(self._type)
	local titleIcon = Title_Icon[class]
	for k, v in ipairs (i3k_db_common_award_property) do
		if v.type == self._type then
			local _layer = require(LAYER_TZJLT)()
			local widgets = _layer.vars
			local isGet = table.nums(qh_t[v.args])  >= 6
			widgets.icon:setVisible(isGet)
			local opacity = isGet and FINISH_IMAGE or NOT_FINISH_IMAGE
			widgets.bg:setImage( g_i3k_db.i3k_db_get_icon_path(opacity))
			local titleColor = isGet and FINISH[1] or NOT_FINISH[1]
			local titleOutline = isGet and FINISH[2] or NOT_FINISH[2]
			local textColor = isGet and FINISH[3] or NOT_FINISH[3]
			--local textOutline = isGet and FINISH[5] or NOT_FINISH[5]
		
			widgets.title:setText(v.desc)
			widgets.title:setTextColor(titleColor)
			widgets.title:enableOutline(titleOutline)
			
			local titleIconHave = isGet and titleIcon.finish or titleIcon.not_finish
			widgets.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(titleIconHave))
			for i=1,6 do--显示小球图片
				local partCfg = i3k_db_equip_part[i]
				local tmp = string.format("ball%s",i)
				local ball_icon = nil
				if isGet then
					ball_icon = g_i3k_db.i3k_db_get_icon_path(partCfg.allReachIcon)
				else
					ball_icon = qh_t[v.args][i]  and g_i3k_db.i3k_db_get_icon_path(partCfg.reachIcon) or g_i3k_db.i3k_db_get_icon_path(partCfg.notReachIcon)
				end
				widgets[tmp]:setImage(ball_icon)
			end
			for i=1, 3 do
				local proID = string.format("pro%sID",i)
				local proValue = string.format("pro%sValue",i)
				local attribute = string.format("attribute%s",i)
				local value = string.format("value%s",i)
				local propertyIcon = string.format("property%s_icon",i)
				local property = v[proID]
				local propertyValue = v[proValue]
				widgets[attribute]:setVisible(property~=0)
				widgets[value]:setVisible(property~=0)
				if property ~= 0 then
					widgets[attribute]:setText(g_i3k_db.i3k_db_get_attribute_name(property))
					--widgets[attribute]:setTextColor(textColor)
					widgets[value]:setText(propertyValue)
					widgets[value]:setTextColor(textColor)
					--widgets[value]:enableOutline(textOutline)
					widgets[propertyIcon]:setImage(g_i3k_db.i3k_db_get_attribute_icon(property))
				end
			end
			self.scroll:addItem(_layer,true)
		end
	end

	local child = self.scroll:getAllChildren()
	local whereTwo = 0
	for i,v in pairs(child) do
		local icon = child[i].vars.icon
		local isVisible = icon:isVisible()
		if not isVisible and whereTwo==0 then
			whereTwo=i
		end
	end
	if whereTwo ~= 1 then
		self.scroll:jumpToChildWithIndex(whereTwo)
	end
	self:refreshBottomTips()
end

function wnd_streng_tips:refreshBottomTips()
	local level = g_i3k_game_context:GetLevel();
	if level >= 79 then
		self.bottomTips:show()
		self.bottomTips:setText(i3k_get_string(1247))
	else
		self.bottomTips:hide()
	end
end

function wnd_streng_tips:updateTitle(class)
	if class == 1 then
		self.title:setText("升级奖励")
	elseif class == 2 then
		self.title:setText("强化奖励")
	elseif class == 3 then
		self.title:setText("镶嵌奖励")
	end
end

function wnd_streng_tips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_StrengTips)
end

function wnd_create(layout)
	local wnd = wnd_streng_tips.new()
	wnd:create(layout)
	return wnd
end
