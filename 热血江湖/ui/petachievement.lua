module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_petAchievement = i3k_class("wnd_petAchievement", ui.wnd_base)
local SCCJT        = "ui/widgets/sccjt"


function wnd_petAchievement:ctor()
	self._id = 1
	self.needItem = {}
end



function wnd_petAchievement:configure()
	local widgets = self._layout.vars
	self.close = widgets.close
	self.scroll = widgets.scroll
	self.close:onClick(self, self.onClose)
	for i=1, 4 do
		local item = "item"..i
		local item_showBg = "item_showBg"..i
		local item_btn = "item_btn"..i
		self.needItem[i] = {
			item	    = widgets[item],
			item_showBg	= widgets[item_showBg],
			item_btn	= widgets[item_btn],
		}
	end
end
function wnd_petAchievement:upDateScroll()
	for i=1, 4 do
		self.needItem[i].item_btn:onClick(self, self.seleteBtn, i)
	end
end

function wnd_petAchievement:seleteBtn(sender, btnType)
	self:onShowData(btnType)
end

function wnd_petAchievement:onShowData(btnType)
	for i=1, 4 do
		self.needItem[i].item:setImage(g_i3k_db.i3k_db_get_icon_path(707))
		--self.needItem[i].item_showBg:setVisible(false)
	end
	self.needItem[btnType].item:setImage(g_i3k_db.i3k_db_get_icon_path(706))
	--self.needItem[btnType].item_showBg:setVisible(true)
	self._id = btnType
	self.scroll:removeAllChildren()
	local tab = {}
	for k,v in ipairs(i3k_db_mercenaryAchievement) do
		if btnType == v.type then
			table.insert(tab, v)
		end
	end
	local propertyId = {}
	local propertyCount = {}
	for k,v in ipairs(tab) do
		local _layer = require(SCCJT)()
		local widget = _layer.vars
		
		widget.attribute1:setText(i3k_db_prop_id[v.attr1].desc)
		widget.value1:setText(i3k_get_prop_show(v.attr1,v.value1))
		widget.property_icon1:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.attr1))
		widget.item_bg2:setVisible(false)
		if v.attr2 ~= 0 then
			widget.item_bg2:setVisible(true)
			widget.attribute2:setText(i3k_db_prop_id[v.attr2].desc)
			widget.value2:setText(i3k_get_prop_show(v.attr2,v.value2))
			widget.property_icon2:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.attr2))
		end
		
		widget.icon:setVisible(false)
		local count = g_i3k_game_context:GetPetAchievementData(v.type, v.args1)
		if count >= v.mercenarycount then
			widget.title:setText(v.desc)
			
			widget.icon:setVisible(true)
		else
			local str = "(" .. count .. "/" .. v.mercenarycount ..")"
			widget.title:setText(v.desc .. str)
		end
		widget.title:setTextColor(g_i3k_get_cond_color(count >= v.mercenarycount))
		self.scroll:addItem(_layer)
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
end

function wnd_petAchievement:refresh()
	self:onShowData(self._id)
	self:upDateScroll()
	
end



function wnd_petAchievement:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_PetAchievement)
end

function wnd_create(layout)
	local wnd = wnd_petAchievement.new();
		wnd:create(layout);

	return wnd;
end