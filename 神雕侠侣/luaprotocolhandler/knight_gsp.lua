local sanswerroleteamstate = require "protocoldef.knight.gsp.sanswerroleteamstate"
function sanswerroleteamstate:process()
	LogInfo("enter sanswerroleteamstate process")
	require "ui.contactroledlg"
	ContactRoleDialog.RefreshRoleTeamState(self.roleid,self.teamstate)
	require "ui.friendchatdialog".RefreshRoleTeamState(self.roleid,self.teamstate)
end
local ssendqueueinfo = require "protocoldef.knight.gsp.ssendqueueinfo"
function ssendqueueinfo:process() 
	require "ui.loginwaitingdialog"
	LogInfo("enter ssendqueueinfo process")
  --CLoginWaitingDialog:OnExit()
    LoginWaitingDialog.DestroyDialog();
	local dlg = require "ui.loginqueuedialog"
	dlg.getInstance():RefreshInfo(self.order, self.queuelength,self.minutes)
end


local ssendservermultiexp = require "protocoldef.knight.gsp.ssendservermultiexp"
function ssendservermultiexp:process()
    LogInfo("____ssendservermultiexp:process: expcount: " .. self.addvalue)
	require "ui.richexptipdlg"

    if self.addvalue == 0 then
        g_bCurInRichExpState = false
        RichExpTipDlg.DestroyDialog()
        
    elseif self.addvalue == 2 then
        g_bCurInRichExpState = true
        RichExpTipDlg.getInstanceAndShow()
    end
end

local sgacdkickoutmsg1 = require "protocoldef.knight.gsp.sgacdkickoutmsg1"
function sgacdkickoutmsg1:process()
	LogInfo("sgacdkickoutmsg1 process")
	if GetGameUIManager() then
		GetGameUIManager():AddMessageTip(self.msg, false)
	end	
end

local p = require "protocoldef.knight.gsp.srecommendsnames"
function p:process()
	if require "ui.createroledialog":getInstanceOrNot() then
        --141316	这个名字已经有人用过了，请重新取名。
        GetGameUIManager():AddMessageTip(
        knight.gsp.message.GetCMessageTipTableInstance():getRecorder(141316).msg,false)
    end
end

p = require "protocoldef.knight.gsp.sgivenamebyqiantong"
function p:process()
	local dlg = require "ui.createroledialog":getInstanceOrNot()
	if dlg then
        --141316	这个名字已经有人用过了，请重新取名。
        dlg:GiveNameByQianTong(self.rolename);
    end
end
local p = require "protocoldef.knight.gsp.schangerolenamedata"
function p:process()
	require("ui.namechangeconfirmdlg"):getInstanceAndShow():process(self.modifycount,self.itemkey)
end

local p = require "protocoldef.knight.gsp.soldnamelist"
function p:process()

end

local p = require "protocoldef.knight.gsp.steamvote"
function p:process()
	local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", self.parms[1])
	strbuilder:Set("parameter2", self.parms[2])
    local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145773))
    strbuilder:delete()

    local function ClickYes(self, args)
        GetMessageManager():CloseCurrentShowMessageBox()
        local req = require"protocoldef.knight.gsp.cteamvoteagree".Create()
        req.result = 0
        LuaProtocolManager.getInstance():send(req)
    end

    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            GetMessageManager():CloseCurrentShowMessageBox()
        end
        local req = require"protocoldef.knight.gsp.cteamvoteagree".Create()
        req.result = 1
        LuaProtocolManager.getInstance():send(req)
    end

    GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,10000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
end

local p = require "protocoldef.knight.gsp.ssyssettings"
function p:process()
    local record=knight.gsp.SystemSetting.GetCGameconfigTableInstance():getRecorder(6)
    if self.syssettings[6] ~= nil then
        GetGameConfigManager():SetConfigValue(record.key, self.syssettings[6])
        GetGameConfigManager():ApplyConfig()
        GetGameConfigManager():SaveConfig()
    end
end

local p = require "protocoldef.knight.gsp.sserveridresponse"
function p:process()
    -- Set ServerID to android.lua
    local LuaAndroid = require "android"
    LuaAndroid.serverid = self.serverid

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ysuc" then
        require "luaj"
        local tempTable = {}
        tempTable[1] = tostring(GetDataManager():GetMainCharacterID())
        tempTable[2] = GetDataManager():GetMainCharacterName()
        tempTable[3] = tostring(GetDataManager():GetMainCharacterLevel())
        tempTable[4] = tostring(self.serverid)
        tempTable[5] = GetLoginManager():GetSelectArea() .. "-" .. GetLoginManager():GetSelectServer()
        luaj.callStaticMethod("com.wanmei.mini.condor.uc.UcPlatform", "submitExtendDataWhenLogined", tempTable, nil)
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "kuwo" then
        require "luaj"
        local param = {}
        param[1] = tostring(self.serverid)
        luaj.callStaticMethod("com.wanmei.mini.condor.kuwo.PlatformKuwo", "setServerId", param, "(I)V")
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lngz" then
        require "luaj"
        local param = {}
        param[1] = tostring(self.serverid)
        luaj.callStaticMethod("com.wanmei.mini.condor.longzhong.PlatformLongZhong", "setserverid", param, "(Ljava/lang/String;)V")
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        require "luaj"
        local param = {}
        param[1] = tostring(GetDataManager():GetMainCharacterID())
        param[2] = tostring(self.serverid)
        luaj.callStaticMethod("com.wanmei.mini.condor.efun.PlatformEFun", "ShowFlowButton", param, nil)
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "thlm" then
        require "luaj"
        local param = {}
        param[1] = tostring(self.serverid)
        param[2] = tostring(GetDataManager():GetMainCharacterID())
        luaj.callStaticMethod("pet.saga.hero.th.PlatformLemon", "showFlow", param, nil)
    elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "this" then
        SDXL.ChannelManager:CommonInterface(1,self.serverid)
    end

end

local p = require "protocoldef.knight.gsp.scorssformsrc2des"
function p:process()
	LogInfo("scorssformsrc2des process")
	require "ui.crossserver.crossservermanager"
	CrossServerManager.getInstance():Init(self.ticket, self.crossip, self.crossport, self.account)

				GetNetConnection():send(knight.gsp.CReturnToLogin())

end


