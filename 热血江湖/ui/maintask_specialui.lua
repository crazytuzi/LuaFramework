-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
require("ui/ui_funcs")
-------------------------------------------------------
wnd_mainTask_specialUI = i3k_class("wnd_mainTask_specialUI", ui.wnd_base)

local textcontent = {
{id=1844,text="日常活动可以获得大量经验和道具"},
{id=1841,text="帮派征讨堂任务可以获得帮贡和经验"},
{id=1842,text="装备副本可以获得大量精品装备"},
{id=1843,text="竞技场可以一展雄风"}
}

function wnd_mainTask_specialUI:ctor()

end

function wnd_mainTask_specialUI:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
--	widgets.text:onClick(self,self.ChangeText)
end

function wnd_mainTask_specialUI:onShow()

end

function wnd_mainTask_specialUI:refresh()
	local dialogue = i3k_db_dialogue[819]
	local index = i3k_engine_get_rnd_u(1, #dialogue)
	local content = dialogue[index].txt
	self._layout.vars.text:setText(content)
	local scroll = self._layout.vars.scroll
	scroll:setBounceEnabled(false)
	scroll:setDirection(1)
	local children =  scroll:addChildWithCount("ui/widgets/zhiyin4t",1,4)
	for i=1,4 do
		local widget = children[i].vars
		widget.bgicon:setImage(g_i3k_db.i3k_db_get_icon_path(textcontent[i].id))
		widget.goBtn:setTag(i)
		widget.goBtn:onClick(self,self.commoneFunc)
		widget.msgType:setText(textcontent[i].text)
	end

	local model = self._layout.vars.model
	ui_set_hero_model(model, 323)
end

function wnd_mainTask_specialUI:commoneFunc(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_MainTask_SpecialUI)
	local tag = sender:getTag()
	if tag == 1 then
--		g_i3k_logic:OpenDailyTask(1)
		g_i3k_logic:OpenShiLianUI()
	elseif tag ==2 then
		local sectId = g_i3k_game_context:GetSectId()
		if sectId <= 0 then
			local data = i3k_sbean.sect_list_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.sect_list_res.getName())
			return
		end
		g_i3k_logic:OpenFactionTaskUI()
	elseif tag == 3 then
		g_i3k_logic:OpenDungeonUI(false)
	elseif tag == 4  then
		g_i3k_logic:OpenArenaUI()
	end
end



function wnd_create(layout, ...)
	local wnd = wnd_mainTask_specialUI.new();
		wnd:create(layout, ...);

	return wnd;
end
