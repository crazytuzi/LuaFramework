local m = require "protocoldef.knight.gsp.friends.scampinfo"

function m:process()
	require "ui.camp.campcheckdialog"
	LogInsane("scampinfo process")
	CampCheckDialog.getInstanceAndShow()
	CampCheckDialog.ChooseCamp(self.recommend)
end


local m = require "protocoldef.knight.gsp.friends.sjioncamp"
function m:process()
	LogInsane("sjioncamp process")
  
  local p = require "protocoldef.knight.gsp.faction.copenfaction":new()
  require "manager.luaprotocolmanager".getInstance():send(p)

	require "ui.showhide"
	require "ui.faction.factiondatamanager".campid = self.camptype
	if self.roleid == GetDataManager():GetMainCharacterID() then
		if self.camptype == 1 then
			GetGameUIManager():AddUIEffect(CEGUI.System:getSingleton():getGUISheet(), MHSD_UTILS.get_effectpath(10387), false)	
		elseif self.camptype == 2 then
			GetGameUIManager():AddUIEffect(CEGUI.System:getSingleton():getGUISheet(), MHSD_UTILS.get_effectpath(10388), false)	
		end
		GetMainCharacter():SetCamp(self.camptype)
		ShowHide.EnterLeavePVPArea()
	else
		local camp = GetMainCharacter():GetCamp()
		local character = GetScene():FindCharacterByID(self.roleid)
		character:SetCamp(self.camptype)
		if camp ~= 1 and camp ~= 2 then
			character:SetNameColour(0xff33ffff) 			--yellow
		else
			if GetMainCharacter():IsInPVPArea() then
				if character:GetCamp() == camp then
					character:SetNameColour(0xff33ff33) 	--green
				elseif character:GetCamp() ~= 1 and character:GetCamp() ~= 2 then
					character:SetNameColour(0xff33ffff) 	--yellow
				else
					character:SetNameColour(0xff3333ff) 	--red
				end
			else
				if character:GetCamp() == camp then
					character:SetNameColour(0xff33ff33) 	--green
				else
					character:SetNameColour(0xff33ffff) 	--yellow
				end

			end
		end
	end	
end


local m = require "protocoldef.knight.gsp.friends.schangecampnotify"
function m:process()
	LogInsane("schangecampnotify process")
    
    local p = require "protocoldef.knight.gsp.faction.copenfaction":new()
    require "manager.luaprotocolmanager".getInstance():send(p)

	require "ui.camp.campcheckdialog"
	require "utils.stringbuilder"
	local strbuilder = StringBuilder:new()
	strbuilder:SetNum("parameter1", self.changetimes)
	strbuilder:SetNum("parameter2", self.needyuanbao)
	strbuilder:SetNum("parameter3", self.subhonour)
	local str = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145036))
	strbuilder:delete()
	GetMessageManager():AddConfirmBox(eConfirmNormal,str,CampCheckDialog.HandleChangeCamp, self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end

local m = require "protocoldef.knight.gsp.friends.ssetinvitepeople"
function m:process()
	print("ssetinvitepeople process")
	require "ui.yaoqing.friendyaoqingdlg"
	if FriendYaoQingDlg.getInstanceNotCreate() then
		FriendYaoQingDlg.getInstanceNotCreate():setYaoQingRen(self.inviteid)
	end
end

local m = require "protocoldef.knight.gsp.friends.sgaininvitereward"
function m:process()
	print("sgaininvitereward process")
	require "ui.yaoqing.friendyaoqingdlg"
	if FriendYaoQingDlg.getInstanceNotCreate() then
		FriendYaoQingDlg.getInstanceNotCreate():rmCell(self.rewardid)
	end
end

local m = require "protocoldef.knight.gsp.friends.sinvitemainview"
function m:process()
	print("sinvitemainview process")
	require "ui.yaoqing.friendyaoqingdlg"
	if FriendYaoQingDlg.getInstanceNotCreate() == nil then
		FriendYaoQingDlg.getInstanceAndShow():setInfo(self.invitemeroleid, self.invitepeopleinfos, self.inviterewardinfo, self.invitelvrewardinfo)
	end
end

local ssearchfriend = require "protocoldef.knight.gsp.friends.ssearchfriend"
function ssearchfriend:process()
	LogInfo("ssearchfriend process")
	require "ui.searchfrienddlg"
	if SearchFriendDlg.getInstanceNotCreate() then
		SearchFriendDlg.getInstanceNotCreate():Init(self.friendinfobean)
	end

end

local ssearchenemy = require "protocoldef.knight.gsp.friends.ssearchenemy"
function ssearchenemy:process()

	LogInfo("Receive SSearchEnemy For Debug Enter")
	
	require "ui.friendsdialog".GlobalSetEnemyList(self.enemyinfobean)

	LogInfo("Receive SSearchEnemy For Debug End")

end