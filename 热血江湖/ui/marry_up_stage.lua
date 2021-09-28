-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------

wnd_marry_up_stage = i3k_class("wnd_marry_up_stage",ui.wnd_base)

local COLORTAB = {"ffb66a4d", "ffeb6a32", "fff15960"}

function wnd_marry_up_stage:ctor()
	self._selectGrade = nil
end

function wnd_marry_up_stage:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.upStageBtn:onClick(self, self.onUpStage)
end

function wnd_marry_up_stage:refresh()
	self:updateUI()
end

function wnd_marry_up_stage:updateUI()
	local widgets = self._layout.vars
	for i = 2, 3 do
		widgets["btn"..i]:onClick(self, self.onSelectBtn, i)
		widgets["costNum"..i]:setText("x"..i3k_db_marry_grade[i].upStageCost)
	end
end

function wnd_marry_up_stage:onSelectBtn(sender, grade)
	self._selectGrade = grade

	for i = 2, 3 do
		self._layout.anis["c_hl"..i]:stop()
	end
	self._layout.anis["c_hl"..grade]:play()
end

function wnd_marry_up_stage:onUpStage(sender)
	local grade = self._selectGrade
	if not grade then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17898))
	end

	local costDiamond = i3k_db_marry_grade[grade].upStageCost
	local canUseDiamond = g_i3k_game_context:GetDiamondCanUse(true)
	if canUseDiamond < costDiamond then
		return g_i3k_ui_mgr:PopupTipMessage("升级所需元宝不足")
	end

	local name = i3k_db_marry_grade[grade].marryGradeName
	local desc = i3k_get_string(17899, name)
	local fun = function(ok)
		if ok then
			i3k_sbean.marriage_upgrade(grade, costDiamond)
		end
	end

	g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
end

function wnd_create(layout)
	local wnd = wnd_marry_up_stage.new()
		wnd:create(layout)
	return wnd
end
