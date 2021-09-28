local m = require "protocoldef.knight.gsp.move.sreqaroundroles"

function m:process()
	require "ui.arounddialog"
	LogInfo("sreqaroundroles process")
	AroundDialog.refreshAroundRoles(self.roles)	
end
