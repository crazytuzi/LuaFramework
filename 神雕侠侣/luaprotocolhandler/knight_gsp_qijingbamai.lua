local sqijinginfo = require "protocoldef.knight.gsp.qijingbamai.sqijinginfo"
function sqijinginfo:process()
	local dlg = require "ui.skill.qijingbamaidlg".getInstanceNotCreate()
	if dlg ~= nil then
		dlg:ServerRefresh(self)
	end
end