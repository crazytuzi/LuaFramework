local sblackroles = require "protocoldef.knight.gsp.pingbi.sblackroles"
function sblackroles:process()
	if BanListManager.getInstance() then
		BanListManager.getInstance():RefreshBanList(self.blackroles)
	end
	if FriendsDialog.getInstanceNotCreate() then
		FriendsDialog:getInstance():RefreshRoleList(3)
	end
end

local ssearchblackroleinfo = require "protocoldef.knight.gsp.pingbi.ssearchblackroleinfo"
function ssearchblackroleinfo:process()
	require "ui.searchbanfrienddlg"
	if SearchBanFriendDlg.getInstanceNotCreate() then
		SearchBanFriendDlg.getInstanceNotCreate():Init(self.searchblackrole)
	end
end