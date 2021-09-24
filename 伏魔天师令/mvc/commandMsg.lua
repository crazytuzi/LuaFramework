CActivityIconCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CActivityIconCommand"
	self.data = VO_data
end)
CActivityIconCommand.TYPE          = "TYPE_CActivityIconCommand"
CActivityIconCommand.REMOVE_LAYOUT = "activity_remove_layout"
CActivityIconCommand.REMOVE_OTHER  = "activity_remove_other"
CActivityIconCommand.HIDE_TASK_GUIDE = "HIDE_TASK_GUIDE"
CActivityIconCommand.EFFECT_REMOVE = "activity_effect_remove"
function CActivityIconCommand.setOtherData(self,_data)
	self.otherData = _data
end
function CActivityIconCommand.getOtheData(self)
	return self.otherData
end

-----------------------------------------------------------------------
--查看其他玩家属性界面打开命令
-----------------------------------------------------------------------
CCharacterPropertyACKCommand = classGc(command, function( self, REQ)
	self.type = "TYPE_CCharacterPropertyACKCommand"
	self.data = REQ
end)
CCharacterPropertyACKCommand.TYPE = "TYPE_CCharacterPropertyACKCommand"

-----------------------------------------------------------------------
--发送REQ请求...REQ是协议的_G.Protocol["REQ"]
CPropertyCommand = classGc(command, function( self, REQ )
    self.type = "TYPE_CPropertyCommand"
    self.data = REQ
end)
CPropertyCommand.TYPE   = "TYPE_CPropertyCommand"
CPropertyCommand.ENERGY = "ENERGY"
CPropertyCommand.MONEY  = "MONEY" --金钱
CPropertyCommand.VIP    = "VIP"
CPropertyCommand.POWERFUL_ALL = "POWERFUL_ALL"
CPropertyCommand.POWERFUL = "POWERFUL"
CPropertyCommand.EXP      = "EXP"
CPropertyCommand.NAME     = "NAME"
CPropertyCommand.LEVELUP  = "LEVELUP"

-----------------------------------------------------------------------
CPlotCommand = classGc(command, function( self, REQ )
    self.type = "TYPE_CPlotCommand"
    self.data = REQ
end)
CPlotCommand.TYPE   = "TYPE_CPlotCommand"
CPlotCommand.START  = "START"
CPlotCommand.FINISH = "FINISH"

-----------------------------------------------------------------------
--通过属性缓存数据改变发送此命令通知主界面人物部分门派名改变的UI
-----------------------------------------------------------------------
CClanIdOrNameUpdateCommand = classGc(command, function( self, REQ )
	self.type = "TYPE_CClanIdOrNameUpdateCommand"
	self.data = REQ
end)
CClanIdOrNameUpdateCommand.TYPE = "TYPE_CClanIdOrNameUpdateCommand"

-----------------------------------------------------------------------
--通过属性缓存数据改变发送此命令通知人物面板属性部分改变的UI
-----------------------------------------------------------------------
CCharacterInfoUpdataCommand = classGc(command, function( self, REQ )
	self.type = "TYPE_CCharacterInfoUpdataCommand"
	self.data = REQ
end)
CCharacterInfoUpdataCommand.TYPE = "TYPE_CCharacterInfoUpdataCommand"

-----------------------------------------------------------------------
--通过背包缓存数据改变发送此命令通知人物面板装备部分改变的UI
-----------------------------------------------------------------------
CCharacterEquipInfoUpdataCommand = classGc(command, function( self, REQ )
	self.type = "TYPE_CCharacterEquipInfoUpdataCommand"
	self.data = REQ
end)
CCharacterEquipInfoUpdataCommand.TYPE = "TYPE_CCharacterEquipInfoUpdataCommand"

-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
CCharacterPartnerAttrCommand = classGc(command, function( self, REQ)
self.type = "TYPE_CCharacterPartnerAttrCommand"
self.data = REQ
end)
CCharacterPartnerAttrCommand.TYPE = "TYPE_CCharacterPartnerAttrCommand"
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
CCharacterPartnerWarCommand = classGc(command, function( self, REQ)
self.type = "TYPE_CCharacterPartnerWarCommand"
self.data = REQ
end)
CCharacterPartnerWarCommand.TYPE = "TYPE_CCharacterPartnerWarCommand"
---------------------------------------------------------------------
ChatMsgCommand = classGc(command, function(self, vo_data)
	self.type = "TYPE_ChatMsgCommand"
	self.data = vo_data
end)
ChatMsgCommand.TYPE = "TYPE_ChatMsgCommand"

---------------------------------------------------------------------
CCopyMapCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CCopyMapCommand"
	self.data = VO_data
end)
CCopyMapCommand.TYPE = "TYPE_CCopyMapCommand"
CCopyMapCommand.COPYINFO_CLOSE = "COPYINFO_CLOSE"
CCopyMapCommand.HUANGUP_END1 = "HUANGUP_END1"
CCopyMapCommand.HUANGUP_END2 = "HUANGUP_END2"
CCopyMapCommand.HUANGUP_END3 = "HUANGUP_END3"
---------------------------------------------------------------------
CTeamCommand = classGc( command, function( self, VO_data )
	self.type = "TYPE_CTeamCommand"
	self.data = VO_data
end)
CTeamCommand.TYPE = "TYPE_CTeamCommand"
---------------------------------------------------------------------
CErrorBoxCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CErrorBoxCommand"
	self.data = VO_data
end)

CErrorBoxCommand.TYPE = "TYPE_CErrorBoxCommand"
---------------------------------------------------------------------
CFlyItemCommand = classGc(command,function(self, _itemId)
	self.type = "TYPE_CFlyItemCommand"
	self.data = _itemId
end)
CFlyItemCommand.TYPE = "TYPE_CFlyItemCommand"
---------------------------------------------------------------------
CFunctionSignCommand = classGc(command, function(self, vo_data)
	self.type = "TYPE_CFunctionSignCommand"
	self.data = vo_data
end)
CFunctionSignCommand.TYPE = "TYPE_CFunctionSignCommand"
CFunctionSignCommand.SIGN_ADD = "SIGN_ADD"
CFunctionSignCommand.SIGN_DEL = "SIGN_DEL"
---------------------------------------------------------------------
CFunctionOpenCommand = classGc(command, function(self, vo_data)
	self.type = "TYPE_CFunctionOpenCommand"
	self.data = vo_data
end)
CFunctionOpenCommand.TYPE = "TYPE_CFunctionOpenCommand"
CFunctionOpenCommand.UPDATE = "sysOpen_List_update"
CFunctionOpenCommand.TIMES_UPDATE = "sysOpen_Times_update"
CFunctionOpenCommand.LIMIT_ADD    = "LIMIT_ADD"
CFunctionOpenCommand.LIMIT_REMOVE = "LIMIT_REMOVE"
CFunctionOpenCommand.SHOW_EFFECT  = "SHOW_EFFECT"
---------------------------------------------------------------------
CFunctionUpdateCommand = classGc(command, function(self, way)
	self.type = "TYPE_CFunctionUpdateCommand"
	self.data = way
end)
CFunctionUpdateCommand.TYPE = "TYPE_CFunctionUpdateCommand"
CFunctionUpdateCommand.BUFF_TYPE = "BUFF_TYPE_CFunctionUpdateCommand"
---------------------------------------------------------------------
--缓存数据改变由此命令通知需要改变的UI
CProxyUpdataCommand = classGc(command, function( self, REQ )
self.type = "TYPE_CProxyUpdataCommand"
self.data = REQ
print("Command name:",self.type)
end)
CProxyUpdataCommand.TYPE = "TYPE_CProxyUpdataCommand"
---------------------------------------------------------------------
CGotoSceneCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CGotoSceneCommand"
	self.data = VO_data
end)
CGotoSceneCommand.TYPE = "TYPE_CGotoSceneCommand"


----------------------
--新手指引触发 命令
----------------------
CGuideTouchCammand = classGc(command, function(self, VO_data, typeId)
	self.type = "TYPE_CGuideTouchCammand"
	self.data = VO_data
	self.typeId = typeId --触发类型ID
end)
CGuideTouchCammand.TYPE   = "TYPE_CGuideTouchCammand"
CGuideTouchCammand.TASK_RECEIVE  = "GUIDE_TASK_RECEIVE" --接受任务
CGuideTouchCammand.TASK_FINISH   = "GUIDE_TASK_FINISH"  --提交任务
CGuideTouchCammand.GUIDE_FINISH  = "GUIDE_FINISH"
CGuideTouchCammand.LV_UP         = "GUIDE_LV_UP"
CGuideTouchCammand.LOGIN         = "GUIDE_LOGIN"
---------------------------------------------------------------------
CGuideNoticAdd = classGc(command, function(self, VO_data)
	self.type = "TYPE_CGuideNoticAdd"
	self.data = VO_data
end)
CGuideNoticAdd.TYPE = "TYPE_CGuideNoticAdd"
---------------------------------------------------------------------
CGuideNoticDel = classGc(command, function(self, VO_data)
	self.type = "TYPE_CGuideNoticDel"
	self.data = VO_data
end)
CGuideNoticDel.TYPE = "TYPE_CGuideNoticDel"
---------------------------------------------------------------------
CGuideNoticShow = classGc(command, function(self, VO_data)
	self.type = "TYPE_CGuideNoticShow"
	self.data = VO_data
end)
CGuideNoticShow.TYPE = "TYPE_CGuideNoticShow"
---------------------------------------------------------------------
CGuideNoticHide = classGc(command, function(self, VO_data)
	self.type = "TYPE_CGuideNoticHide"
	self.data = VO_data
end)
CGuideNoticHide.TYPE = "TYPE_CGuideNoticHide"

---------------------------------------------------------------------
CKeyBoardCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CKeyBoardCommand"
	self.data = VO_data
end)
CKeyBoardCommand.TYPE = "TYPE_CKeyBoardCommand"
---------------------------------------------------------------------
CKeyBoardSkillCDCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CKeyBoardSkillCDCommand"
	self.data = VO_data
end)
CKeyBoardSkillCDCommand.TYPE = "TYPE_CKeyBoardSkillCDCommand"
---------------------------------------------------------------------
CLogsCommand = classGc( command, function( self, VO_data )
	self.type = "TYPE_CLogsCommand"
	self.data = VO_data
end)
CLogsCommand.TYPE = "TYPE_CLogsCommand"
---------------------------------------------------------------------
--跑马灯消息命令
CMarqueeCommand = classGc( command, function( self, VO_data )
	self.type = "TYPE_CMarqueeCommand"
	self.data = VO_data
end)
CMarqueeCommand.TYPE = "TYPE_CMarqueeCommand"
---------------------------------------------------------------------
--语音命令
CVoiceCommand = classGc( command, function( self, VO_data )
	self.type = "TYPE_CVoiceCommand"
	self.data = VO_data
end)
CVoiceCommand.TYPE = "TYPE_CVoiceCommand"
CVoiceCommand.RECORD_SUCCESS = "RECORD_SUCCESS"
CVoiceCommand.PLAY_FINISH = "PLAY_FINISH"
---------------------------------------------------------------------
CNetworkCommand = classGc(command, function(self, VO_data)
    self.type = "TYPE_CNetworkCommand"     --getType
    self.data = VO_data               --getData
end)
CNetworkCommand.TYPE = "TYPE_CNetworkCommand"
CNetworkCommand.ACT_DISCONNECT = "ACT_DISCONNECT"
---------------------------------------------------------------------
--更新npc图标
CNpcUpdateCommand = classGc( command, function( self, VO_data )
    self.type = "TYPE_CNpcUpdateCommand"
    self.data = VO_data
end)
CNpcUpdateCommand.TYPE      = "TYPE_CNpcUpdateCommand"
CNpcUpdateCommand.UPDATE    = "UPDATE"
CNpcUpdateCommand.ADD       = "ADD"
CNpcUpdateCommand.DELETE    = "DELETE"
CNpcUpdateCommand.MAIN_TASK = "MAIN_TASK"
---------------------------------------------------------------------
CMainUiCommand = classGc( command, function( self, VO_data )
   self.type = "TYPE_CMainUiCommand"
   self.data = VO_data
end)
CMainUiCommand.TYPE               = "TYPE_CMainUiCommand"
CMainUiCommand.ICON_ADD           = "ICON_ADD"
CMainUiCommand.ICON_DEL           = "ICON_DEL"
CMainUiCommand.ICON_TEAM_INVITE   = "icon_team_invite"
CMainUiCommand.SUBVIEW_ADD        = "subView_add"
CMainUiCommand.SUBVIEW_FINISH     = "subView_finish"
CMainUiCommand.MOPTYPE            = "MOPTYPE"
---------------------------------------------------------------------
--进入界面初始化战力值命令
-----------------------------------------------------------------------
CPowerfulCreateCommand = classGc(command, function( self, REQ )
	self.type = "TYPE_CPowerfulCreateCommand"
	self.data = REQ
end)
CPowerfulCreateCommand.TYPE = "TYPE_CPowerfulCreateCommand"

------------------------------------------
--缓存数据改变由此命令通知需要改变的UI
CSkillDataUpdateCommand = classGc(command, function(self, msgId)
	self.type = "TYPE_CSkillDataUpdateCommand"
	self.data = msgId
end)
CSkillDataUpdateCommand.TYPE = "TYPE_CSkillDataUpdateCommand"
CSkillDataUpdateCommand.TYPE_UPDATE = "TYPE_UPDATE"
CSkillDataUpdateCommand.TYPE_EQUIP  = "TYPE_EQUIP"
CSkillDataUpdateCommand.TYPE_PARTNER = "TYPE_PARTNER"

---------------------------------------
CTaskDialogUpdateCommand = classGc( command, function(self, vo_data)
    self.type = "TYPE_CTaskDialogUpdateCommand"
    self.data = vo_data
end)
CTaskDialogUpdateCommand.TYPE = "TYPE_CTaskDialogUpdateCommand"
CTaskDialogUpdateCommand.GOTO_SHOPPING  = "goto_shopping"           --去商城
CTaskDialogUpdateCommand.GOTO_HOUSE     = "goto_house"              --去客栈
CTaskDialogUpdateCommand.GOTO_TASK      = "goto_task"               --去任务

---------------------------------------
CTaskEffectsCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CTaskEffectsCommand"
	self.data = VO_data
end)
CTaskEffectsCommand.TYPE = "TYPE_CTaskEffectsCommand"

---------------------------------------
--缓存数据改变由此命令通知需要改变的UI
CTaskDataUpdataCommand = classGc( command, function( self, VO_data )
	self.type 	= "TYPE_CTaskDataUpdateCommand"
	self.data   = VO_data
end)
CTaskDataUpdataCommand.TYPE = "TYPE_CTaskDataUpdateCommand"
---------------------------------------------------------------------
CTaskMainCommand = classGc( command, function( self, VO_data )
	self.type 	= "TYPE_CTaskMainCommand"
	self.data   = VO_data
end)
CTaskMainCommand.TYPE = "TYPE_CTaskMainCommand"
---------------------------------------------------------------------
--强化面板发给各个子页面
EquipmentsViewCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_EquipmentsViewCommand"
	self.data = VO_data
end)
EquipmentsViewCommand.TYPE = "TYPE_EquipmentsViewCommand"
---------------------------------------------------------------------
--人物面板 发给各个子页面
CRoleViewCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CRoleViewCommand"
	self.data = VO_data
end)
CRoleViewCommand.TYPE = "TYPE_CRoleViewCommand"

---------------------------------------------------------------------
--游戏开场动画
CGameStartCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CGameStartCommand"
	self.data = VO_data
end)
CGameStartCommand.TYPE = "TYPE_CGameStartCommand"
---------------------------------------------------------------------
--更好装备穿上命令
CBetterEquipCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CBetterEquipCommand"
	self.data = VO_data
end)
CBetterEquipCommand.TYPE = "TYPE_CBetterEquipCommand"

---------------------------------------------------------------------
--展示关闭人物面板
CRolePanelCloseCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CRolePanelCloseCommand"
	self.data = VO_data
end)
CRolePanelCloseCommand.TYPE = "TYPE_CRolePanelCloseCommand"
---------------------------------------------------------------------
--用于湛卢坊主界面的装备更新
EquipGoodChangeCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_EquipGoodChangeCommand"
	self.data = VO_data
end)
EquipGoodChangeCommand.TYPE  = "TYPE_EquipGoodChangeCommand"
EquipGoodChangeCommand.EQUIP = "TYPE_EQUIPVIEWCHANGE"
EquipGoodChangeCommand.DELEFFECT = "TYPE_EQUIPVIEWDELEFFECT"
---------------------------------------------------------------------
--用于宝石镶嵌tips的按钮传输
EquipGemInsertCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_EquipGemInsertCommand"
	self.data = VO_data
end)
EquipGemInsertCommand.TYPE    = "TYPE_EquipGemInsertCommand"
EquipGemInsertCommand.UPGRADE = "TYPE_EQUIPGEM_UPGRADE" --升级
EquipGemInsertCommand.CHAIXIE = "TYPE_EQUIPGEM_CHAIXIE" --拆卸
EquipGemInsertCommand.INSERT  = "TYPE_EQUIPGEM_INSERT"  --镶嵌
---------------------------------------------------------------------
---------------------------------------------------------------------
--通用关闭界面命令
BagOpenHCCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_BagOpenHCCommand"
	self.data = VO_data
end)
BagOpenHCCommand.TYPE = "TYPE_BagOpenHCCommand"
---------------------------------------------------------------------
--充值界面
RechargeViewCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_RechargeViewCommand"
	self.data = VO_data
end)
RechargeViewCommand.TYPE = "TYPE_RechargeViewCommand"
---------------------------------------------------------------------
--PK邀请
PKInviteCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_PKInviteCommand"
	self.data = VO_data
end)
PKInviteCommand.TYPE = "TYPE_PKInviteCommand"
PKInviteCommand.ADD  = "ADD"
PKInviteCommand.DEL  = "DEL"
---------------------------------------------------------------------
---------------------------------------------------------------------
--通用关闭界面命令
CloseWindowCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CloseWindowCommand"
	self.data = VO_data
end)
---------------------------------------------------------------------
--神兵界面 发给各个子页面
CArtifactCommand = classGc(command, function(self, VO_data)
	self.type = "TYPE_CArtifactCommand"
	self.data = VO_data
end)
CArtifactCommand.TYPE = "TYPE_CArtifactCommand"
---------------------------------------------------------------------
CloseWindowCommand.TYPE = "TYPE_CloseWindowCommand"