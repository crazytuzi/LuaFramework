-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_spiritTip = i3k_class("wnd_spiritTip", ui.wnd_base)

-------------------------------------------------------

local WIDGET_ROOL = "ui/widgets/gdylsmt1"
local WIDGET_SKILL = "ui/widgets/gdylsmt"

function wnd_spiritTip:ctor()
	self._selectID = 1
end

function wnd_spiritTip:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.scroll1 = widgets.scroll1
	self.scroll2 = widgets.scroll2
	self.tabs = {
		{ btn = widgets.roolTip , ui = widgets.wanfaRoot},
		{ btn = widgets.skillTip , ui = widgets.jinengRoot}
	}

	for i,v in ipairs(self.tabs) do
		v.btn:onClick(
            self,
            function()
                self:onTabBtnClick(i)
            end
        )
	end
	
end

function wnd_spiritTip:onTabBtnClick(index)
	self:showDataByIndex(index)
end

--页签界面控制
function wnd_spiritTip:showDataByIndex(index)
	self._curTabIndex = index
	for i, v in ipairs(self.tabs) do
        if i == index then
        	v.btn:stateToPressed()
        	v.ui:setVisible(true)
        	self:showData(index)
        else
         	v.btn:stateToNormal()
         	v.ui:setVisible(false)
        end
    end
end 

function wnd_spiritTip:showData(index)
	if index == 1 then
		self:showRoolTip()
	end
	if index == 2 then
		self:showSkillTip()
	end
end

function wnd_spiritTip:showRoolTip()
	self.scroll1:removeAllChildren()
	local node = require(WIDGET_ROOL)()
	node.vars.desc:setText(i3k_get_string(18619, 
		i3k_db_catch_spirit_base.dungeon.callTimes,					--每日可进行x次驭灵
		i3k_db_catch_spirit_base.spiritFragment.bagMaxCount,		--最多收集碎片数量上限
		i3k_db_catch_spirit_base.spiritFragment.bagMaxCount,		--奖励最多数量
		i3k_db_catch_spirit_base.spiritFragment.weeklyTimes,		--每周炼化次数
		i3k_db_catch_spirit_base.spiritFragment.exchangeConsume,	--交换消耗碎片个数
		i3k_db_catch_spirit_base.spiritFragment.exchangeDaily		--每日交换次数
		))
	self.scroll1:addItem(node)

	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local textUI = node.vars.desc
		local size = node.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(self.scroll1, width, height, true)
	end, 1)
end

function wnd_spiritTip:showSkillTip()
	
	self.scroll2:removeAllChildren()
	for i,v in ipairs(i3k_db_catch_spirit_base.npc.showSkills) do
		print("2")
		local node = require(WIDGET_SKILL)()
		local skill = i3k_db_skills[v]
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
		node.vars.name:setText(skill.name)
		node.vars.desc:setText(skill.desc)
		self.scroll2:addItem(node)
	end
	local node2 = require(WIDGET_SKILL)()
	local skill2 = i3k_db_skills[i3k_db_catch_spirit_base.npc.godViewSkills]
	node2.vars.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(i3k_db_catch_spirit_base.npc.godViewSkills))
	node2.vars.name:setText(skill2.name)
	node2.vars.desc:setText(skill2.desc)
	self.scroll2:addItem(node2)
	--[[
	for i,v in ipairs(i3k_db_catch_spirit_base.npc.godViewSkills) do
		local node = require(WIDGET_SKILL)()
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
		self.scroll:addItem(node)
	end
	]]
end


function wnd_spiritTip:refresh()
	self:showDataByIndex(1)
end

function wnd_create(layout, ...)
	local wnd = wnd_spiritTip.new()
	wnd:create(layout, ...)
	return wnd;
end
