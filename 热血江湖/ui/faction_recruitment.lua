-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base")

-------------------------------------------------------
wnd_faction_recruitment = i3k_class("wnd_faction_recruitment", ui.wnd_base)

function wnd_faction_recruitment:ctor()
	self.curNumber = 0
	self.maxNumber = 0
	self.sectId = 0
	self.needLevel = 0
end

function wnd_faction_recruitment:configure()
	
end

function wnd_faction_recruitment:refresh(info, sectId, name, desc)
	self.curNumber = info.memberNum
	self.maxNumber = i3k_db_faction_uplvl[info.level].count
	self.sectId = sectId
	self.needLevel = info.enterLvl
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)
	widget.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[info.icon].iconid))
	widget.faction_name:setText(name)
	widget.faction_chief:setText(info.leader)
	widget.faction_level:setText(info.level)
	widget.faction_number:setText(string.format("%s/%s", info.memberNum, self.maxNumber))
	widget.faction_active:setText(info.vit)
	widget.faction_needLvl:setText(info.enterLvl)
	widget.desc:setText(desc)
	widget.joinBtn:onClick(self, self.onJoin)
end

function wnd_faction_recruitment:onJoin(sender)
	local level = g_i3k_game_context:GetLevel()
	local factionId = g_i3k_game_context:GetSectId()
	if factionId ~= 0 and factionId ~= -1 then
		g_i3k_ui_mgr:PopupTipMessage("已经加入帮派")
	elseif self.curNumber >= self.maxNumber then
		g_i3k_ui_mgr:PopupTipMessage("成员数量已达上限")
	elseif level < self.needLevel then
		g_i3k_ui_mgr:PopupTipMessage("等级不满足要求")
	else
		local data = i3k_sbean.sect_apply_req.new()
		data.sectId = self.sectId
		i3k_game_send_str_cmd(data, i3k_sbean.sect_apply_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_FactionRecruitment)
	end
end

function wnd_create(layout)
	local wnd = wnd_faction_recruitment.new();
	wnd:create(layout);
	return wnd;
end
