-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chuHanFight = i3k_class("wnd_chuHanFight", ui.wnd_base)

local ROLE_INFO = "ui/widgets/chuhanzhizhengjnt"

--阵营
local CAMP_CHU = 1
local CAMP_HAN = 2

function wnd_chuHanFight:ctor()

end

function wnd_chuHanFight:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_chuHanFight:refresh()
	self:updataScroll()
end

--兵种
function wnd_chuHanFight:updataScroll()
	local widget = self._layout.vars
	widget.scroll:removeAllChildren()
	local cfg = self:mergeCamp()
	local camp = nil
	for	k, v in pairs(cfg) do
		local node =  require(ROLE_INFO)()
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(v.classImg, false))
		node.vars.name:setText(v.name)
		node.vars.desc:setText(v.desc)
		
		local mcfg = i3k_db_missionmode_cfg[v.maleModelID]

		for k, v in ipairs(mcfg.skills) do
			local scfg = i3k_db_skills[v.skillid];
			if scfg then
				node.vars["skillIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(scfg.icon))
				node.vars["skillBtn"..k]:onTouchEvent(self, self.skillDescTips, {skillID = v.skillid, btn = node.vars["skillBtn"..k]})
			end
		end
		local scfg = i3k_db_skills[mcfg.attacks[1]];
		if scfg then
			node.vars["skillIcon"]:setImage(g_i3k_db.i3k_db_get_icon_path(scfg.icon))
			node.vars["skillBtn"]:onTouchEvent(self, self.skillDescTips, {skillID = mcfg.attacks[1], btn = node.vars["skillBtn"]})
		end
		widget.scroll:addItem(node)
	end
	widget.restraintDesc:setText(i3k_get_string(5491))
end

--合并楚汉相同兵种
function wnd_chuHanFight:mergeCamp()
	local data = {}
	local cfg = clone(i3k_db_chess_generals)
	for	k, v in ipairs(cfg) do
		if data[v.arms] then
			if v.camp == CAMP_CHU then
				data[v.arms].name = v.name .. "/" .. data[v.arms].name
			else
				data[v.arms].classImg = v.classImg
				data[v.arms].name = data[v.arms].name .. "/" .. v.name
			end
		else
			data[v.arms] = v
		end
	end
	return data
end


function wnd_chuHanFight:getTournamentSkillsPosition(btn)
	local btnSize = btn:getParent():getContentSize()
	local sectPos = btn:getPosition()
	local btnPos = btn:getParent():getParent():convertToWorldSpace(sectPos)
	
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

--skill_tip
function wnd_chuHanFight:skillDescTips(sender, eventType, data)
	if eventType == ccui.TouchEventType.began then
		local pos = self:getTournamentSkillsPosition(data.btn)
		g_i3k_ui_mgr:OpenUI(eUIID_DescTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_DescTips, i3k_db_skills[data.skillID].name, i3k_db_skills[data.skillID].desc, pos)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_DescTips)
		end
	end
end

-------------------------------------
function wnd_create(layout)
	local wnd = wnd_chuHanFight.new();
		wnd:create(layout);
	return wnd;
end
