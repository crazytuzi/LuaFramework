--lua main entry
require "ui.logindialog"


function main()
    local dlg = LoginDialog.getInstance()
	dlg:SetVisible(true)
end

main()
