
local p = require "protocoldef.knight.gsp.skill.specialskill.sspecialskills"
function p:process()
	local NuQiSkillManager = require "ui.skill.nuqiskillmanager"
	NuQiSkillManager.InitNuQiSkills(self.skills)
	NuQiSkillManager.InUsesSkills(self.inuseskills)
	NuQiSkillManager.SetPoints(self.exp)

	local NuQiSkillXiuLianDlg = require "ui.skill.nuqiskillxiuliandlg"
	if NuQiSkillXiuLianDlg.getInstanceNotCreate() then
		NuQiSkillXiuLianDlg.getInstanceAndShow():ShowSkill()
		NuQiSkillXiuLianDlg.getInstanceAndShow():RefreshPoints()
	end
end

local p = require "protocoldef.knight.gsp.skill.specialskill.sinuseskills"
function p:process()
	local NuQiSkillManager = require "ui.skill.nuqiskillmanager"
	NuQiSkillManager.InUsesSkills(self.inuseskills)

	local NuQiSkillXiuLianDlg = require "ui.skill.nuqiskillxiuliandlg"
	local NuQiJiinWuShuangDlg = require "ui.skill.nuqijiinwushuangdlg"
	local NuQiJiinNormalDlg = require "ui.skill.nuqijiinnormaldlg"
	if NuQiSkillXiuLianDlg.getInstanceNotCreate() then
		NuQiSkillXiuLianDlg.getInstanceNotCreate():ShowSkill()
	end
	if NuQiJiinWuShuangDlg.getInstanceNotCreate() then
		NuQiJiinWuShuangDlg.getInstanceNotCreate():Refresh()
	end
	if NuQiJiinNormalDlg.getInstanceNotCreate() then
		NuQiJiinNormalDlg.getInstanceNotCreate():Refresh()
	end
end

local p = require "protocoldef.knight.gsp.skill.specialskill.slearnspecialskill"
function p:process()
	print("slearnspecialskill id " .. tostring(self.skillid))
	print("slearnspecialskill pt " .. tostring(self.exp))
	local NuQiSkillManager = require "ui.skill.nuqiskillmanager"
	NuQiSkillManager.LearnSkill(self.skillid)
	NuQiSkillManager.SetPoints(self.exp)

	local NuQiSkillXiuLianDlg = require "ui.skill.nuqiskillxiuliandlg"
	local NuQiHuoDeDlg = require "ui.skill.nuqihuodedlg"
	local NuQiJiinNormalDlg = require "ui.skill.nuqijiinnormaldlg"
	if NuQiSkillXiuLianDlg.getInstanceNotCreate() then
		NuQiSkillXiuLianDlg.getInstanceNotCreate():ShowSkill()
		NuQiSkillXiuLianDlg.getInstanceNotCreate():RefreshPoints()
	end
	if self.skillid ~= 0 then
		NuQiHuoDeDlg.getInstanceAndShow():Refresh(self.skillid)
	end
	if NuQiJiinNormalDlg.getInstanceNotCreate() then
		NuQiJiinNormalDlg.getInstanceNotCreate():Refresh()
	end
end

local p = require "protocoldef.knight.gsp.skill.specialskill.supgradespecialskill"
function p:process()
	local NuQiSkillManager = require "ui.skill.nuqiskillmanager"
	NuQiSkillManager.UpgradeSkill(self.skillid, self.level)

	local NuQiSkillXiuLianDlg = require "ui.skill.nuqiskillxiuliandlg"
	local NuQiJiinWuShuangDlg = require "ui.skill.nuqijiinwushuangdlg"
	local NuQiJiinNormalDlg = require "ui.skill.nuqijiinnormaldlg"
	if NuQiSkillXiuLianDlg.getInstanceNotCreate() then
		NuQiSkillXiuLianDlg.getInstanceNotCreate():ShowSkill()
	end
	if NuQiJiinWuShuangDlg.getInstanceNotCreate() then
		NuQiJiinWuShuangDlg.getInstanceNotCreate():Refresh()
	end
	if NuQiJiinNormalDlg.getInstanceNotCreate() then
		NuQiJiinNormalDlg.getInstanceNotCreate():Refresh()
	end
end

