
knight_gsp = {}

function knight_gsp.SRoleList_Lua_Process(p)
	LogInfo("SRoleList handler enter")
	require "ui.loginqueuedialog"
	require "ui.selectserversdialog"
		
	LoginQueueDlg.DestroyDialog()
	SelectServersDialog.DestroyDialog()
	return true
end

return knight_gsp
