-- dofile entry for lua function registering to c++

----------/////////////////////////////////////
require "protocoldef.protocols"
----------/////////////////////////////////////

----------/////////////////////////////////////
--manager
require "ui.showhide"
require "manager.protocolhandlermanager"
require "manager.luaprotocolmanager"
require "manager.beanconfigmanager"
require "manager.notifymanager"
require "manager.npcservicemanager"

require "ui.luauimanager"
require "ui.team.formationmanager"

require "utils.log"
require "utils.bit"
require "utils.soundenable"

----------/////////////////////////////////////
require "mainticker"
require "globalfunctionsforcpp"
----------/////////////////////////////////////
--ui dialog
--take note,since the nested relation is very complex about xiake lua files, now keep them in this file temporarily
require "ui.logindialog"
require "ui.selectserversdialog"
require "ui.maincontrol"
require "ui.workshop.workshoplabel"
require "ui.xiake.xiake_jiuguan"
require "ui.xiake.mainframe"
require "ui.xiake.xiake_manager"
require "ui.xiake.myxiake_xiake"
require "utils.reload_util"
require "ui.xiake.protocols_xiake"
require "ui.xiake.jinhua_xiake"
require "ui.xiake.qiyu_xiake"
require "ui.xiake.buzhen"
require "ui.battle.zhenfa"
require "ui.battle.zhenfatip"
require "ui.pet.petlabel"
require "ui.checktipswnd"
require "ui.loginqueuedialog"
require "ui.contactservicedialog"
require "ui.task.taskdialog"
require "ui.task.tasktracingdialog"
require "ui.luanewroleguide"
require "ui.clearbuttondlg"
require "ui.activity.activityentrance"
require "ui.activity.activitydlg"
require "ui.activity.activitymanager"
require "ui.richexptipdlg"
require "ui.characterinfo.characterpropertymini"
require "ui.team.teamdialog"
require "ui.vip.vipdialog"
require "ui.chatinsimpleshow"
require "ui.xiake.self_chuangong"
require "ui.xiake.xiake_chuangong"
require "ui.chargedialog"
require "ui.securitylocksettingdlg"
require "ui.skill.skilllable"

--has been used in cpp, need to require in this
require "ui.shop.shopdlg"
require "ui.wujueling.wujuelingcarddlg"
require "ui.rank.rankinglist"
require "ui.vip.vipdialog"

----------/////////////////////////////////////
require "ui.useitemhandler"

require "ui.wujueling.wujuelingcheck"

require "framework.battle"
require "framework.weiboshare"

require "ui.skill.nuqiskilloperatedlg"
require "ui.pet.battlepetsummondlg"
require "ui.battle.luabattleuimanager"

--has been used in cpp, need to require in this
require "ui.advansettingdlg"

require "manager.npcservicemanager"
require "ui.waringbuttondlg"
require "ui.battleautofightdlg"
require "ui.battleautodlg"
require "ui.pet.petoperatedlg"
require "framework.banlistmanager"
require "ui.task.specialgotonpc"

function Entry_Init()
--	SDXL.GetSDXLLogger():setLoggingLevel(SDXL.Insane)
	if Config.MOBILE_ANDROID == 0 then 
		SetFps(40)
	end
	LogInfo("dofile enter init")
--	pcall(require "debug.debugger")

	GetGameApplication():RegisterTickerHandler(LuaMainTick)

	ProtocolHandlerManager.RegisterProtocolScriptHandler()

	--lua protocols
	SDXL.GetProtocolLuaFunManager():RegisterLuaProtocolHandler(LuaProtocolManager.Dispatch)
	RegisterLuaProtocols()


	BeanConfigManager.getInstance():Initialize("/config/autoconfig/", "/config/autobinconfig/")

	--[[
	local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.cmainmissioninfo")

	t = tt:getRecorder(100101)
	for k,v in pairs(t.PostMissionList) do
		print("xml -- "..k .. v)
	end
	--]]
end

Entry_Init()

--GetGameApplication():SetReadXmlFromBinary(false)
SDXL.ChannelManager:RemoveRCPFiles(30)

function OnAuthError()
	LoginQueueDlg.DestroyDialog()
end
----------end/////////////////////////////////
