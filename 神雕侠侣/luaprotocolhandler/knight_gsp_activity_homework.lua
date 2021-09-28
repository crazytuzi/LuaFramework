local shomeworkstates = require "protocoldef.knight.gsp.activity.homework.shomeworkstates"
function shomeworkstates:process()
	local HomeworkDlg = require 'ui.homework.homeworkdlg'
	HomeworkDlg.getInstanceAndShow():refreshInfo(self.canreward, self.states)
end

local shomeworkavg = require "protocoldef.knight.gsp.activity.homework.shomeworkavg"
function shomeworkavg:process()
	local WorkbookDlg = require 'ui.homework.workbookdlg'
	WorkbookDlg.getInstanceAndShow():refreshInfo(self.homeworks, self.avgscore)
end

local shomeworkavgrewardstate = require "protocoldef.knight.gsp.activity.homework.shomeworkavgrewardstate"
function shomeworkavgrewardstate:process()
	local WorkbookDlg = require 'ui.homework.workbookdlg'
	WorkbookDlg.getInstanceAndShow():refreshBonusBtn(self.get)
end