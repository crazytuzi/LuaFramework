--init_frame.lua

-- config part
							  require("UF.config")

-- tools part
uf_notifyLayer				= require(__UUZU_FRAME__..".ui.NotifyLayer").new()
UFCCSSceneMonitor 			= require(__UUZU_FRAME__..".tools.SceneMonitor")
 							  require(__UUZU_FRAME__..".tools.DebugHelper")


uf_funcCallHelper			= require(__UUZU_FRAME__..".tools.FuncCallHelper").new()
  							  require(__UUZU_FRAME__..".tools.ResourceHelper")
  							  require(__UUZU_FRAME__..".tools.UIHelper")

-- event part
uf_eventManager 			= require(__UUZU_FRAME__..".event.EventManager").new()
uf_keypadHandler			= require(__UUZU_FRAME__..".event.KeypadHandler").new()


UFCCSUIHooker			  	= require(__UUZU_FRAME__..".ui."..__UF_UI_CCS_..".CCSUIHooker")
if __USE_COCOSBUILDER_ == 1 then
-- ui part
 	UFCCBBaseScene 				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".CCBBaseScene")
 	UFCCBMessageBox				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".CCBMessageBox")
 	UFCCBModelLayer				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".CCBModelLayerBase")
 	UFCCBNormalLayer			= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".CCBNormalLayerBase")
end
if __USE_COCOSTUDIO_ == 1 then
	UFCCSBaseScene				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCS_..".CCSUISceneBase")
	UFCCSModelLayer				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCS_..".CCSModelLayerBase")
	UFCCSNormalLayer			= require(__UUZU_FRAME__..".ui."..__UF_UI_CCS_..".CCSNormalLayerBase")
	UFCCSMessageBox				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCS_..".CCSMessageBox")
end


-- net part
 uf_messageDispatcher 		= require(__UUZU_FRAME__..".net.MessageDispatcher").new()
 uf_netManager 				= require(__UUZU_FRAME__..".net.NetManager").new()
 uf_messageSender 			= require(__UUZU_FRAME__..".net.MessageSender").new()
 uf_downloadManager			= require(__UUZU_FRAME__..".net.DownloadManager").new()
 --g_pbcProtobuf 				= require(__UUZU_FRAME__..".net.pbc.protobuf")
 uf_pbcParser 				= require(__UUZU_FRAME__..".net.pbc.parser")

-- component part
  							  require(__UUZU_FRAME__..".ui.component.ComponentExtend")
 UFComponentBase 			= require(__UUZU_FRAME__..".ui.component.ComponentBase")

if __USE_COCOSBUILDER_ == 1 then
-- control part
 	UFCCBEditbox				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".control.CCBEditbox")
 	UFCCBTableView				= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".control.CCBTableView")
 	UFCCBTableViewCellEx		= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".control.CCBTableViewCellEx")
 	UFCCBTableViewCellUF		= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".control.CCBTableViewCellUF")
	UFCCBTableEventHandler		= require(__UUZU_FRAME__..".ui."..__UF_UI_CCB_..".control.CCBTableEventHandler")
end

-- lib part
 --uf_libComSdk 				= require(__UUZU_FRAME__..".libs.LibComSdk").new()

 uf_sceneManager			= require(__UUZU_FRAME__..".SceneManager").new()

ExitHelper:getInstance():addExitExcute(function (  )
	uf_notifyLayer = nil
	uf_funcCallHelper = nil
	uf_eventManager = nil
	uf_messageSender = nil
	uf_messageDispatcher = nil
	uf_netManager = nil 
	uf_downloadManager = nil

	--uf_libComSdk = nil
	uf_sceneManager = nil
end)