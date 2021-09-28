local p = require "protocoldef.knight.gsp.skill.ssendassistskillmaxlevels"

function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.maxlevels = {}
	for k, v in pairs(self.maxlevels) do
		datamanager.maxlevels[k] = v
	end
	local dlg = require "ui.faction.factionxiulian":getInstanceOrNot()
	if dlg then
		dlg:RefreshSkillMaxLevels()
	end
end

local sgetwulinskills = require "protocoldef.knight.gsp.skill.sgetwulinskills"
function sgetwulinskills:process()
	local WLMgr = require "ui.skill.wulinmijimanager".getInstance()
	WLMgr:RefreshDataFromServer(self, nil, nil, nil)
	local WulinmijiDlg = require "ui.skill.wulinmijidlg"
	if WulinmijiDlg.getInstanceNotCreate() ~= nil then
		WulinmijiDlg.getInstance():RefreshLeftView()
		WulinmijiDlg:getInstance():RefreshRightView()
	end
end

local sgetjingjieinfo = require "protocoldef.knight.gsp.skill.sgetjingjieinfo"
function sgetjingjieinfo:process()
	local WLMgr = require "ui.skill.wulinmijimanager".getInstance()
	WLMgr:RefreshDataFromServer(nil, self, nil, nil)
	local WulinmijiDlg = require "ui.skill.wulinmijidlg"
	if WulinmijiDlg.getInstanceNotCreate() ~= nil then
		WulinmijiDlg.getInstance():RefreshLeftView()
		WulinmijiDlg:getInstance():RefreshRightView()
	end
end

local sgetmijiinfo = require "protocoldef.knight.gsp.skill.sgetmijiinfo"
function sgetmijiinfo:process()
	local WLMgr = require "ui.skill.wulinmijimanager".getInstance()
	WLMgr:RefreshDataFromServer(nil, nil, self, nil)
	local WulinmijiDlg = require "ui.skill.wulinmijidlg"
	if WulinmijiDlg.getInstanceNotCreate() ~= nil then
		WulinmijiDlg.getInstance():RefreshLeftView()
	end
	local UpMijiDlg = require "ui.skill.upmijidlg"
	if UpMijiDlg.getInstanceNotCreate() ~= nil then
		UpMijiDlg.getInstance():RefreshView()
	end
end

local sopenmijidlg = require "protocoldef.knight.gsp.skill.sopenmijidlg"
function sopenmijidlg:process()
	local WLMgr = require "ui.skill.wulinmijimanager".getInstance()
	WLMgr:RefreshDataFromServer(nil, nil, nil, self)
	local WulinmijiDlg = require "ui.skill.wulinmijidlg".getInstanceAndShow()
	WulinmijiDlg.getInstance():RefreshLeftView()
	WulinmijiDlg:getInstance():RefreshRightView()
	local UpMijiDlg = require "ui.skill.upmijidlg".getInstanceAndShow()
	UpMijiDlg.getInstance():RefreshView()
end