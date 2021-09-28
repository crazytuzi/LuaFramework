local Util                    = require 'Zeus.Logic.Util'
local XmlUITemplate           = require 'Zeus.UI.hackui.XmlUITemplate'



local SkillMenu               = require "Zeus.UI.Skill.SkillMenu"

local GameUIMelt              = require 'Zeus.UI.XmasterBag.GameUIMelt'

local SceneMapU               = require "Zeus.UI.XmasterMap.SceneMapU"







local GameUIGoodItem          = require 'Zeus.UI.GameUIGoodItem'

local InteractiveMenu         = require 'Zeus.UI.InteractiveMenu'
local Interactive2Menu        = require 'Zeus.UI.Interactive2Menu'
local FuncEntryMenu           = require 'Zeus.UI.FuncEntryMenu'
local MailUI                  = require 'Zeus.UI.XmasterMail.MailUI'
local InMailUI                = require 'Zeus.UI.XmasterMail.InMailUI'
local ChatMainSecond          = require "Zeus.UI.Chat.ChatMainSecond"
local ChatUIFace              = require "Zeus.UI.Chat.ChatUIFace"
local ChatUIAction            = require "Zeus.UI.Chat.ChatUIAction"
local ChatUIGift              = require "Zeus.UI.Chat.ChatUIGift"

local SocialUIMain            = require "Zeus.UI.XmasterSocial.SocialUIMain"
local SocialUIFriend          = require "Zeus.UI.XmasterSocial.SocialUIFriend"
local SocialUIFriendAdd       = require "Zeus.UI.XmasterSocial.SocialUIFriendAdd"
local SocialUIFriendApply     = require "Zeus.UI.XmasterSocial.SocialUIFriendApply"





local NumInputMenu            = require 'Zeus.UI.NumInputMenu'
local RoleRename            = require 'Zeus.UI.XmasterCommon.RoleRename'

local SignAwardUI             = require 'Zeus.UI.XmasterSign.SignUISignAward'
local SignAwardBoxUI             = require 'Zeus.UI.XmasterSign.SignUISignAwardBox'


local ReliveUI                = require "Zeus.UI.XmasterRelive.ReliveUI"
local ReliveTipsUI            = require "Zeus.UI.XmasterRelive.ReliveTipsUI"








local RideUIMain              = require "Zeus.UI.XmasterRide.RideUIMain"
local RideTrain       		  = require "Zeus.UI.XmasterRide.RideUITrain"
local RideSkin                = require "Zeus.UI.XmasterRide.RideUISkin"
local RideEquipList           = require "Zeus.UI.XmasterRide.RideEquipList"











local GameUINPCTalk           = require 'Zeus.UI.GameUINPCTalk'

local GameUIBagMain           = require 'Zeus.UI.XmasterBag.UIBagMain'

local GameUIEquipmentList     = require "Zeus.UI.XmasterActor.UIEquipmentList"
local GameUIRoleAttribute     = require 'Zeus.UI.XmasterActor.UIActorMain'
local GameUIRoleAttributeMain = require "Zeus.UI.XmasterActor.UIPropertyDetail"
local GameUICombatDetail      = require "Zeus.UI.XmasterActor.UICombatDetail"

local GameUIBloodList     = require "Zeus.UI.XmasterBloodSoul.BloodList"






local EventItemDetail         = require "Zeus.UI.XmasterBag.EventItemDetail"
local UpStairsUI              = require 'Zeus.UI.XmasterActor.UIActorBreak'
local AttrExchangeUI   		  = require 'Zeus.UI.XmasterActor.AttrExchangeUI'
local GameUIRealmLook         = require 'Zeus.UI.XmasterActor.UIRealmLook'
local GameUINewItems          = require 'Zeus.UI.GameUINewItems'
local GameUIPreviewItems      = require 'Zeus.UI.GameUIPreviewItems'


local ItemDetailMenu          = require "Zeus.UI.XmasterBag.ItemDetailMenu"
local GameUIQuestDetail       = require 'Zeus.UI.GameUIQuestDetail'
local GameUIQuest             = require 'Zeus.UI.GameUIQuest'
local GameUILevelTarget       = require 'Zeus.UI.XmasterLvTarget.LevelTargetUI'
local GameUIArenaMain         = require "Zeus.UI.XmasterArena.ArenaUIMain"


local GameUIMultiPvpEnd       = require "Zeus.UI.XmasterArena.ArenaUIEnd"

local LeaderboardUI           = require "Zeus.UI.XmasterLeaderboard.LeaderboardUI"






local GameUIConsignmentMain       = require "Zeus.UI.XmasterConsignment.ConsignmentUIMain"
local GameUIConsignmentBuy        = require "Zeus.UI.XmasterConsignment.ConsignmentUIBuy"
local GameUIConsignmentAuction    = require "Zeus.UI.XmasterConsignment.ConsignmentUIAuction"
local GameUIConsignmentSell       = require "Zeus.UI.XmasterConsignment.ConsignmentUISell"
local GameUIConsignmentItemDetail = require "Zeus.UI.XmasterConsignment.ConsignmentUIItemDetail"

local FuncOpen                = require "Zeus.Model.FunctionOpen"
local GameUIFirstPay          = require "Zeus.UI.XmasterSign.FirstPay"
local GameUICarnival         = require "Zeus.UI.XmasterSign.Carnival"

local GameUINumberInput       = require "Zeus.UI.XmasterCommon.NumInputUI"
local TeamUIMain              = require "Zeus.UI.XmasterTeam.TeamUIMain"
local QuestSubmitItem         = require "Zeus.UI.QuestSubmitItemUI"


local function OnUIOpen(eventname, params)
	
	local tag = tonumber(params.tag)
	local cacheLevel = tonumber(params.cacheLevel)
	local param = tostring(params.params)
	GlobalHooks.OpenUI(tag, cacheLevel, param)
end

function GlobalHooks.FindUIs(tag)
	local ret = Util.List2Luatable(MenuMgrU.Instance:FindMenusByTag(tag))
	return ret
end

function GlobalHooks.FindUI(tag)
	local ret = Util
	local menu = MenuMgrU.Instance:FindMenuByTag(tag)
	if menu then
		return menu,menu.LuaTable
	end
end

function GlobalHooks.CloseUI(tag)
	local menu = MenuMgrU.Instance:FindMenuByTag(tag)
	if menu then
		menu:Close()
	end
end

function GlobalHooks.OpenCustomUI(xml,cache)
	local ret = GlobalHooks.CreateCustomUI(xml,cache)
	if ret then
		MenuMgrU.Instance:AddMenu(ret.menu)
	end
	return ret
end

function GlobalHooks.OpenUI(tag, cacheLevel, params)
	
	
	local node,lua_obj = GlobalHooks.CreateUI(tag, cacheLevel, params)
	
	if node ~= nil then
		MenuMgrU.Instance:AddMenu(node)
	end
	
	return node,lua_obj
end

function GlobalHooks.OpenUIOnlyOne(tag, cacheLevel, params)
	
	local node, lua_obj = GlobalHooks.FindUI(tag)
	if node then
		node:Close()
	end
	return GlobalHooks.OpenUI(tag, cacheLevel, params)
end

local function CreateFrameNode(tag,xmlPath,defaultTag,showAnime)
	local isShowAnime = showAnime==nil and true or showAnime
	return MenuFrameBase.Create(tag, xmlPath, defaultTag, isShowAnime)
end

local function CreateFrameNodeU(tag,xmlPath,defaultTag)
	return MenuFrameBaseU.Create(tag, xmlPath, defaultTag)
end

local UI_SWITH_TABLE =
{

[GlobalHooks.UITAG.GameUIRoleAttribute] = function (tag, params)
	return GameUIRoleAttribute.Create(tag),GameUIRoleAttribute
end,

[GlobalHooks.UITAG.GameUICombatDetail] = function (tag, params)
	return GameUICombatDetail.Create(tag),GameUICombatDetail
end,

[GlobalHooks.UITAG.GameUIRoleAttributeMain] = function(tag,params)
    return GameUIRoleAttributeMain.Create(tag),GameUIRoleAttributeMain
end,

[GlobalHooks.UITAG.GameUIRealmLook] = function(tag,params)
    return GameUIRealmLook.Create(tag),GameUIRealmLook
end,





[GlobalHooks.UITAG.GameUIBagMain] = function (tag, params)
	return GameUIBagMain.Create(tag,params),GameUIBagMain
end,


	
	







	


[GlobalHooks.UITAG.GameUIGoodItem] = function (tag, params)
	return GameUIGoodItem.Create(tag),GameUIGoodItem
end,


	


[GlobalHooks.UITAG.GameUISkillMain] = function (tag, params)
	
	
	return SkillMenu.Create(),SkillMenu
end,













[GlobalHooks.UITAG.GameUIBatchSell] = function (tag, params)
	return BatchSellMenu.Create(),BatchSellMenu
end,

[GlobalHooks.UITAG.GameUIInteractive] = function (tag, params)
	return InteractiveMenu.Create(tag,params),InteractiveMenu
end,

[GlobalHooks.UITAG.GameUIInteractive2] = function (tag, params)

	return Interactive2Menu.Create(tag,params),Interactive2Menu
end,

[GlobalHooks.UITAG.GameUIMelt] = function (tag, params)
	
	return GameUIMelt.Create(tag),GameUIMelt
end,

[GlobalHooks.UITAG.GameUINewItems] = function (tag, params)
	return GameUINewItems.Create(tag,params),GameUINewItems
end,

[GlobalHooks.UITAG.GameUIPreviewItems] = function (tag, params)
	return GameUIPreviewItems.Create(tag,params),GameUIPreviewItems
end,





















[GlobalHooks.UITAG.GameUINPCTalk] = function (tag, params)
	return GameUINPCTalk.Create(tag,params),GameUINPCTalk
end,

[GlobalHooks.UITAG.GameUIQuest] = function (tag, params)
	
	return GameUIQuest.Create(tag,params),GameUIQuest
end,

[GlobalHooks.UITAG.GameUILevelTarget] = function (tag, params)
	
	return GameUILevelTarget.Create(tag,params),GameUILevelTarget
end,

[GlobalHooks.UITAG.GameUIQuestDetail] = function (tag, params)
	
	return GameUIQuestDetail.Create(tag,params),GameUIQuestDetail
end,

[GlobalHooks.UITAG.GameUISceneMapU] = function (tag, params)
	
	return SceneMapU.Create(params),SceneMapU
end,









[GlobalHooks.UITAG.GameUINumInput] = function (tag, params)
	return NumInputMenu.Create(tag),NumInputMenu
end,

[GlobalHooks.UITAG.GameUIRoleRename] = function (tag, params)
	return RoleRename.Create(tag),RoleRename
end,





[GlobalHooks.UITAG.GameUIItemDetailMain] = function (tag, params)
	return EventItemDetail.Create(tag),EventItemDetail
end,

[GlobalHooks.UITAG.GameXMDSUIItemDetail] = function (tag, params)
	return ItemDetailMenu.CreateWithMiniXml(tag),ItemDetailMenu
end,

[GlobalHooks.UITAG.GameUINumberInput] = function (tag, params)
	return GameUINumberInput.Create(tag),GameUINumberInput
end,

[GlobalHooks.UITAG.GameUISimpleDetail] = function (tag, params)
	return ItemDetailMenu.CreateWithMiniXml(tag,params),ItemDetailMenu
end,






















	
	



	
	



	
	



	
	





































[GlobalHooks.UITAG.GameUIFuncEntry] = function (tag, params)
	return FuncEntryMenu.Create(tag,params),FuncEntryMenu
end,

[GlobalHooks.UITAG.GameUIChatMainSecond] = function (tag, params)
	
	return ChatMainSecond.Create(tag,params),ChatMainSecond
end,

[GlobalHooks.UITAG.GameUIChatFace] = function (tag, params)
	
	return ChatUIFace.Create(tag,params),ChatUIFace
end,

[GlobalHooks.UITAG.GameUIInMail] = function (tag, params)
	return InMailUI.Create(params),InMailUI
end,

[GlobalHooks.UITAG.GameUIChatAction] = function (tag, params)
	
	return ChatUIAction.Create(tag,params),ChatUIAction
end,

[GlobalHooks.UITAG.GameUIChatGift] = function (tag, params)
	
	return ChatUIGift.Create(tag,params),ChatUIGift
end,

[GlobalHooks.UITAG.GameUISocialMain] = function (tag, params)
	
	return SocialUIMain.Create(tag,params),SocialUIMain
end,

[GlobalHooks.UITAG.GameUISocialFriend] = function (tag, params)
	
	return SocialUIFriend.Create(tag,params),SocialUIFriend
end,

[GlobalHooks.UITAG.GameUISocialFriendAdd] = function (tag, params)
	
	return SocialUIFriendAdd.Create(tag,params),SocialUIFriendAdd
end,

[GlobalHooks.UITAG.GameUISocialFriendApply] = function (tag, params)
	
	return SocialUIFriendApply.Create(tag,params),SocialUIFriendApply
end,

[GlobalHooks.UITAG.GameUIQuestSubmitItem] = function(tag ,params)
    return QuestSubmitItem.Create(tag,params),QuestSubmitItem
end,


























[GlobalHooks.UITAG.GameUIMail] = function (tag, params)
	return MailUI.Create(),MailUI
end,

[GlobalHooks.UITAG.GameUISignAward] = function (tag, params)
	return SignAwardUI.Create(params),SignAwardUI
end,

[GlobalHooks.UITAG.GameUISignAwardBox] = function (tag, params)
	return SignAwardBoxUI.Create(params),SignAwardBoxUI
end,


	



[GlobalHooks.UITAG.GameUIDailyTasks] = function (tag, params)
	local DailyTasks  = require 'Zeus.UI.Activity.DailyTasks'
	return DailyTasks.Create(params),DailyTasks
end,

[GlobalHooks.UITAG.GameUIDailyWelfare] = function (tag, params)
	local DailyWelfare  = require 'Zeus.UI.Activity.DailyWelfare'
	return DailyWelfare.Create(params),DailyWelfare
end,


	



[GlobalHooks.UITAG.GameUIDeadCommon] = function (tag, params)
	return ReliveUI.Create(params) ,ReliveUI
end,

[GlobalHooks.UITAG.GameUIDeadCommonTips] = function (tag, params)
	return ReliveTipsUI.Create(params) ,ReliveTipsUI
end,
























[GlobalHooks.UITAG.GameUIRideMain] = function (tag, params)
	return RideUIMain.Create(tag, params),RideUIMain
end,

[GlobalHooks.UITAG.GameUIRideTrain] = function (tag, params)
	return RideTrain.Create(tag, params),RideTrain
end,

[GlobalHooks.UITAG.GameUIRideSkin] = function (tag, params)
	return RideSkin.Create(tag, params),RideSkin
end,

[GlobalHooks.UITAG.GameUIRideEquipList] = function (tag, params)
	return RideEquipList.Create(tag, params),RideEquipList
end,







[GlobalHooks.UITAG.GameUIFirstPay] = function (tag, params)
	return FirstPay.Create(tag),GameUIFirstPay
end,

[GlobalHooks.UITAG.GameUICarnival] = function (tag, params)
	return Carnival.Create(tag),GameUICarnival
end,
























	









[GlobalHooks.UITAG.GameUIEquipReworkMain] = function (tag, params) 
	return GameUIEquipReworkMain.Create(tag,params),GameUIEquipReworkMain
end,

[GlobalHooks.UITAG.GameUIEquipReworkLeftChoose] = function (tag, params) 
	return GameUIEquipReworkLeftChoose.Create(tag,params),GameUIEquipReworkLeftChoose
end,

[GlobalHooks.UITAG.GameUIEquipReworkRightToggle] = function (tag, params) 
	return GameUIEquipReworkRightToggle.Create(tag,params),GameUIEquipReworkRightToggle
end,

[GlobalHooks.UITAG.GameUIEquipReworkScurbing] = function (tag, params) 
	return GameUIEquipReworkScurbing.Create(tag,params),GameUIEquipReworkScurbing
end,

[GlobalHooks.UITAG.GameUIEquipReworkRefine] = function (tag, params) 
	return GameUIEquipReworkRefine.Create(tag,params),GameUIEquipReworkRefine
end,

[GlobalHooks.UITAG.GameUIEquipReworkMake] = function (tag, params) 
	return GameUIEquipReworkMake.Create(tag,params),GameUIEquipReworkMake
end,

[GlobalHooks.UITAG.GameUIEquipReworkReMake] = function (tag, params) 
	return GameUIEquipReworkReMake.Create(tag,params),GameUIEquipReworkReMake
end,

[GlobalHooks.UITAG.GameUIEquipReworkKaiguang] = function (tag, params) 
	return GameUIEquipReworkKaiguang.Create(tag,params),GameUIEquipReworkKaiguang
end,

[GlobalHooks.UITAG.GameUIMultiPvpFrame] = function (tag, params)
	
	
	
	
	
	
	
	
	
	return GameUIArenaMain.Create(tag,0)
end,









[GlobalHooks.UITAG.GameUIMultiPvpEnd] = function (tag, params)
	return GameUIMultiPvpEnd.Create(tag,params)
end,

[GlobalHooks.UITAG.GameUITeamMain] = function (tag, params)
    return TeamUIMain.Create(tag,params),TeamUIMain

end,

























[GlobalHooks.UITAG.GameUIUpStairs] = function (tag, params)
	return UpStairsUI.Create(tag), UpStairsUI
end,

[GlobalHooks.UITAG.GameUIAttrExchange] = function (tag, params)
	return AttrExchangeUI.Create(tag), AttrExchangeUI
end,









[GlobalHooks.UITAG.GameUILeaderboard] = function (tag, params)
	return LeaderboardUI.Create(params), LeaderboardUI
end,


	


[GlobalHooks.UITAG.GameUIConsignmentMain] = function (tag, params)
	return GameUIConsignmentMain.Create(tag, params), GameUIConsignmentMain
end,

[GlobalHooks.UITAG.GameUIConsignmentSell] = function (tag, params)
	return GameUIConsignmentSell.Create(tag, params), GameUIConsignmentSell
end,

[GlobalHooks.UITAG.GameUIConsignmentBuy] = function (tag, params)
	return GameUIConsignmentBuy.Create(tag), GameUIConsignmentBuy
end,

[GlobalHooks.UITAG.GameUIConsignmentAuction] = function (tag, params)
	return GameUIConsignmentAuction.Create(tag), GameUIConsignmentAuction
end,

[GlobalHooks.UITAG.GameUIConsignmentItemDetail] = function (tag, params)
	return GameUIConsignmentItemDetail.Create(tag,params), GameUIConsignmentItemDetail
end,


	


	



	


[GlobalHooks.UITAG.GameUIRoleEquipmentList] = function (tag, params)
	return GameUIEquipmentList.Create(tag, params), GameUIEquipmentList
end,

[GlobalHooks.UITAG.GameUIBloodList] = function (tag, params)
	return GameUIBloodList.Create(tag, params), GameUIBloodList
end,
}


local UI_SWITH_SIMPLE_TABLE = {

[GlobalHooks.UITAG.GameUIRoleTitleList] = "Zeus.UI.XmasterTitle.TitleListUI",
[GlobalHooks.UITAG.GameUIRoleGotTitle] = "Zeus.UI.XmasterTitle.GotTitleUI",

[GlobalHooks.UITAG.GameUIFashionMain] = "Zeus.UI.XmasterFashion.FashionMain",
[GlobalHooks.UITAG.GameUIFashionSuit] = "Zeus.UI.XmasterFashion.FashionSuit",




[GlobalHooks.UITAG.GameUIFuben]         =  "Zeus.UI.XmasterFuben.FubenUI",
[GlobalHooks.UITAG.GameUIFubenLimit]         =  "Zeus.UI.XmasterFuben.FubenUILimit",
[GlobalHooks.UITAG.GameUIFubenSecond]   = "Zeus.UI.XmasterFuben.FubenSecondUI",
[GlobalHooks.UITAG.GameUIFubenWaitEnter]= "Zeus.UI.XmasterFuben.FubenWaitEnterUI",
[GlobalHooks.UITAG.GameUIFubenRoll]		= "Zeus.UI.XmasterFuben.FubenRollUI",


[GlobalHooks.UITAG.GameUIResFubenSecondUI]		= "Zeus.UI.XmasterFuben.FubenResSecondUI",
[GlobalHooks.UITAG.GameUIResFubenOverUI]	= "Zeus.UI.XmasterFuben.FubenResOverUI",
[GlobalHooks.UITAG.GameUILimitGift]		= "Zeus.UI.XmasterSign.LimitGift",
[GlobalHooks.UITAG.GameUIFightLimitReward]		= "Zeus.UI.XmasterFuben.LimitFightReward",
[GlobalHooks.UITAG.GameUIHuanJing]		= "Zeus.UI.XmasterHuanJing.HuanjingUI",
[GlobalHooks.UITAG.GameUIMiJing]        =  "Zeus.UI.XmasterMiJing.MiJingUI",
[GlobalHooks.UITAG.GameUIDemonTower]    = "Zeus.UI.XmasterDemonTower.DemonTowerUI",
[GlobalHooks.UITAG.GameUIDemonLevelEnd] = "Zeus.UI.XmasterDemonTower.DemonTowerNewEnd",
[GlobalHooks.UITAG.GameUIDemonTowerSweep]    = "Zeus.UI.XmasterDemonTower.DemonTowerSweepUI",





[GlobalHooks.UITAG.GameUIPKSelectMenu]  = 'Zeus.UI.PK.RolePKSelectMenu',

[GlobalHooks.UITAG.GameUIActivityHJBoss]  =  'Zeus.UI.XmasterActivity.ActivityUIMain',
[GlobalHooks.UITAG.GameUISceneMapUThird]  = 'Zeus.UI.XmasterMap.SceneMapUThird',
[GlobalHooks.UITAG.GameUISceneMapUSecond]  = 'Zeus.UI.XmasterMap.SceneMapUSecond',




[GlobalHooks.UITAG.GameUISetMain] = 'Zeus.UI.XmasterSet.SetUIMain',
[GlobalHooks.UITAG.GameUISetHangup] = 'Zeus.UI.XmasterSet.SetUIHangup',
[GlobalHooks.UITAG.GameUISetSystem] = 'Zeus.UI.XmasterSet.SetUISystem',
[GlobalHooks.UITAG.GameUISetSelect] = 'Zeus.UI.XmasterSet.SetUISelect',


[GlobalHooks.UITAG.GameUIPetRename] = 'Zeus.UI.XmasterPet.PetUIRename',--'Zeus.UI.Pet.GameUIRename',

[GlobalHooks.UITAG.GameUIPetMain] = 'Zeus.UI.XmasterPet.PetUIMain',
[GlobalHooks.UITAG.GameUIPetEvolution] = 'Zeus.UI.XmasterPet.PetUIEvolution', 







[GlobalHooks.UITAG.GameUIItemGetDetail] = 'Zeus.UI.ItemGetDetail',








[GlobalHooks.UITAG.GameUIPetSkillInfo]  = 'Zeus.UI.XmasterPet.PetSkillTip',

[GlobalHooks.UITAG.GameUIShowXmlTips]  = 'Zeus.UI.ShowXmlTips',

[GlobalHooks.UITAG.GameUIPetGetNewPush]  = 'Zeus.UI.XmasterPet.PetUIGetNew',

[GlobalHooks.UITAG.GameUIChatMainSmall]  = 'Zeus.UI.Chat.ChatMainSmall',
[GlobalHooks.UITAG.GameUIChatPersonList]  = 'Zeus.UI.Chat.GameUIChatPersonList',
[GlobalHooks.UITAG.GameUIChatSetting1st]  = 'Zeus.UI.Chat.GameUIChatSetting1st',
[GlobalHooks.UITAG.GameUIChatSetting2nd]  = 'Zeus.UI.Chat.GameUIChatSetting2nd',
[GlobalHooks.UITAG.GameUIChatSetting3rd]  = 'Zeus.UI.Chat.GameUIChatSetting3rd',
[GlobalHooks.UITAG.GameUIChatTabList]  = 'Zeus.UI.Chat.GameUIChatTabList',
[GlobalHooks.UITAG.GameUIChatCommonList]  = 'Zeus.UI.Chat.ChatUICommonList',
[GlobalHooks.UITAG.GameUIChatShowItem]  = 'Zeus.UI.Chat.ChatUIItem',
[GlobalHooks.UITAG.GameUIChatSpeaker]  = 'Zeus.UI.Chat.ChatUISpeaker',
[GlobalHooks.UITAG.GameUIRedPacket]  = 'Zeus.UI.Chat.RedPacketUI',
[GlobalHooks.UITAG.GameUIRedPacketSend]  = 'Zeus.UI.Chat.RedPacketSend',
[GlobalHooks.UITAG.GameUIRedPacketGet]  = 'Zeus.UI.Chat.RedPacketGet',

[GlobalHooks.UITAG.GameUISolo]          = 'Zeus.UI.XmasterSolo.SoloUIMain',

[GlobalHooks.UITAG.GameUISoloRoundOver] = 'Zeus.UI.XmasterSolo.SoloRoundOverUI',
[GlobalHooks.UITAG.GameUISoloBattleOver]= 'Zeus.UI.XmasterSolo.SoloBattleOverUI',
[GlobalHooks.UITAG.GameUISoloRule]       = 'Zeus.UI.XmasterSolo.SoloRule',             
[GlobalHooks.UITAG.GameUISoloGrade]      = 'Zeus.UI.XmasterSolo.SoloGrade',             
[GlobalHooks.UITAG.GameUISoloRecord]     = 'Zeus.UI.XmasterSolo.SoloRecordList',              
[GlobalHooks.UITAG.GameUISoloRewardBox]  = 'Zeus.UI.XmasterSolo.SoloRewardBox',              
[GlobalHooks.UITAG.GameUISoloMatchOk]    = 'Zeus.UI.XmasterSolo.SoloMatchOk',

[GlobalHooks.UITAG.GameUI5V5Main]       = 'Zeus.UI.Xmaster5V5.5V5UIMain',
[GlobalHooks.UITAG.GameUI5V5Record]       = 'Zeus.UI.Xmaster5V5.5V5UIRecordList',
[GlobalHooks.UITAG.GameUI5V5Result]       = 'Zeus.UI.Xmaster5V5.5V5UIResult',
[GlobalHooks.UITAG.GameUI5V5WaitEnter]    = 'Zeus.UI.Xmaster5V5.5V5UIWaitEnter',
[GlobalHooks.UITAG.GameUI5V5Ready]       = 'Zeus.UI.Xmaster5V5.5V5UIReady',

[GlobalHooks.UITAG.GameUIVSPlayer]      ='Zeus.UI.XmasterActor.PageUIPropertyOther',--'Zeus.UI.VS.VSPlayerUI',
[GlobalHooks.UITAG.GameUIVSAttribute]   = 'Zeus.UI.XmasterActor.VSOtherProperty',--'Zeus.UI.VS.VSAttributeUI',
[GlobalHooks.UITAG.GameUIItemUseNow]        = 'Zeus.UI.GameUIItemUseNow',
[GlobalHooks.UITAG.GameUIChangeLine] = 'Zeus.UI.GameUIChangeLine',





















[GlobalHooks.UITAG.GameUIGuildSetJob] = 'Zeus.UI.Guild.SetGuildJob',
[GlobalHooks.UITAG.GameUIApplyGuild] = 'Zeus.UI.XmasterGuild.ApplyGuild',
[GlobalHooks.UITAG.GameUIBuildGuild] = 'Zeus.UI.XmasterGuild.BuildGuild',
[GlobalHooks.UITAG.GameUIGuildMain]  = 'Zeus.UI.XmasterGuild.GuildMain',
[GlobalHooks.UITAG.GameUIGuildSetJob] = 'Zeus.UI.XmasterGuild.SetGuildJob',
[GlobalHooks.UITAG.GameUIGuildFactor] = 'Zeus.UI.XmasterGuild.GuildFactor',
[GlobalHooks.UITAG.GameUIGuildSetNotice] = 'Zeus.UI.XmasterGuild.GuildSetNotice',
[GlobalHooks.UITAG.GameUIGuildHall] = 'Zeus.UI.XmasterGuild.GuildHall',
[GlobalHooks.UITAG.GameUIGuildDonate] = 'Zeus.UI.XmasterGuild.GuildDonate',
[GlobalHooks.UITAG.GameUIGuildUpLv] = 'Zeus.UI.XmasterGuild.GuildUpLv',
[GlobalHooks.UITAG.GameUIGuildSetName] = 'Zeus.UI.XmasterGuild.GuildSetName',
[GlobalHooks.UITAG.GameUIGuildSetQQ] = 'Zeus.UI.XmasterGuild.GuildSetQQ',
[GlobalHooks.UITAG.GameUIGuildDynamic] = 'Zeus.UI.XmasterGuild.GuildDynamic',
[GlobalHooks.UITAG.GameUIGuildWareHouse] = 'Zeus.UI.XmasterGuild.GuildWareHouse',
[GlobalHooks.UITAG.GameUIGuildWareHouseSave] = 'Zeus.UI.XmasterGuild.GuildWareHouseSaveAndGet',
[GlobalHooks.UITAG.GameUIGuildWareHousePrivilege] = 'Zeus.UI.XmasterGuild.GuildWareHousePrivilege',
[GlobalHooks.UITAG.GameUIGuildWareHouseUpLv] = 'Zeus.UI.XmasterGuild.GuildWareHouseUpLv',
[GlobalHooks.UITAG.GameUIGuildWareHouseDynamic] = 'Zeus.UI.XmasterGuild.GuildWareHouseDynamic',

[GlobalHooks.UITAG.GameUIGuildAuction] = 'Zeus.UI.XmasterGuild.GuildAuction',
[GlobalHooks.UITAG.GameUIGuildBoss] = 'Zeus.UI.XmasterGuild.GuildBoss',
[GlobalHooks.UITAG.GameUIGuildBossEnd] = 'Zeus.UI.XmasterGuild.GuildBossEnd',
[GlobalHooks.UITAG.GameUIGuildPray] = 'Zeus.UI.XmasterGuild.GuildPray',
[GlobalHooks.UITAG.GameUIGuildPrayUpLv] = 'Zeus.UI.XmasterGuild.GuildPrayUpLv',
[GlobalHooks.UITAG.GameUIGuildTech] = 'Zeus.UI.XmasterGuild.GuildTech',
[GlobalHooks.UITAG.GameUIGuildTechUpLv] = 'Zeus.UI.XmasterGuild.GuildTechUpLv',
[GlobalHooks.UITAG.GameUIGuildTechBuffUpLv] = 'Zeus.UI.XmasterGuild.GuildTechBuffUpLv',

[GlobalHooks.UITAG.GameUIGuildWarMain] = 'Zeus.UI.XmasterGuildWar.GuildWarMain',
[GlobalHooks.UITAG.GameUIGuildWarApply] = 'Zeus.UI.XmasterGuildWar.GuildWarApply',
[GlobalHooks.UITAG.GameUIGuildWarStatistics] = 'Zeus.UI.XmasterGuildWar.GuildWarStatistics',
[GlobalHooks.UITAG.GameUIGuildWarResult] = 'Zeus.UI.XmasterGuildWar.GuildWarResult',








[GlobalHooks.UITAG.GameUIShop] = 'Zeus.UI.XmasterShop.UIShopMain',
[GlobalHooks.UITAG.GameUIShopScore] = 'Zeus.UI.XmasterShop.IntegralShopUI',


[GlobalHooks.UITAG.GameUIShopFriendSelect] = 'Zeus.UI.XmasterShop.FriendSelectUI',




[GlobalHooks.UITAG.GameUIActivityMain] = 'Zeus.UI.XmasterActivity.ActivityUIMain',
[GlobalHooks.UITAG.GameUIActivityBossDetail] = 'Zeus.UI.XmasterActivity.ActivityUIBossDetail', 
[GlobalHooks.UITAG.GameUIActivityCalendar] = 'Zeus.UI.XmasterActivity.ActivityUIActivityCalendar', 
[GlobalHooks.UITAG.GameUIActivityDetail] = 'Zeus.UI.XmasterActivity.ActivityUIActivityDetail', 

[GlobalHooks.UITAG.GameUIFishItem] = 'Zeus.UI.GameUIFishItem',











[GlobalHooks.UITAG.GameUISocialDaoqunBuild] = 'Zeus.UI.XmasterSocial.SocialUIDaoqunBuild',
[GlobalHooks.UITAG.GameUISocialDaoyouInvite] = 'Zeus.UI.XmasterSocial.SocialUIDaoyouInvite',
[GlobalHooks.UITAG.GameUISocialDaoqun] = 'Zeus.UI.XmasterSocial.SocialUIDaoqun',
[GlobalHooks.UITAG.GameUISocialDaoqunSetName] = 'Zeus.UI.XmasterSocial.SocialUIDaoqunSetName',
[GlobalHooks.UITAG.GameUISocialDaoqunNotice] = 'Zeus.UI.XmasterSocial.SocialUIDaoqunNotice',
[GlobalHooks.UITAG.GameUISocialDaoqunRebate] = 'Zeus.UI.XmasterSocial.SocialUIDaoqunRebate',

[GlobalHooks.UITAG.GameUIStealItem] = 'Zeus.UI.GameUIStealItem',

[GlobalHooks.UITAG.GameUISignXMDS] = 'Zeus.UI.XmasterSign.SignUIMain',
[GlobalHooks.UITAG.GameUIFuncOpen]     = "Zeus.UI.FuncOpenUI",

[GlobalHooks.UITAG.GameUIGetNewSkin]     = "Zeus.UI.XmasterRide.NewSkinUI",
[GlobalHooks.UITAG.GameUINewSkinChoice]     = "Zeus.UI.XmasterRide.NewSkinChoiceUI",





















[GlobalHooks.UITAG.GameUITreasureMainUI] = "Zeus.UI.XmasterDemonTower.DemonTowerUI",









[GlobalHooks.UITAG.GameUITeamApply] = 'Zeus.UI.XmasterTeam.TeamApply',
[GlobalHooks.UITAG.GameUITeamInvite] = 'Zeus.UI.XmasterTeam.TeamInvite',
[GlobalHooks.UITAG.GameUITeamRecruit] = 'Zeus.UI.XmasterTeam.TeamRecruit',
[GlobalHooks.UITAG.GameUITeamTargetSet] = 'Zeus.UI.XmasterTeam.TeamSet',

[GlobalHooks.UITAG.GameUIFirstPay] = 'Zeus.UI.XmasterSign.FirstPay',
[GlobalHooks.UITAG.GameUICarnival] = 'Zeus.UI.XmasterSign.Carnival',







[GlobalHooks.UITAG.GameUIWorldLv]     = "Zeus.UI.XMasterWorship.WorshipMain",




[GlobalHooks.UITAG.GameUIEquipReworkMain]     = "Zeus.UI.XMasterReWork.GameUIRework", 
[GlobalHooks.UITAG.GameUIEquipReworkLeftChoose]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkLeftChoose", 
[GlobalHooks.UITAG.GameUIEquipReworkRightToggle]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkRightToggle", 
[GlobalHooks.UITAG.GameUIEquipReworkScurbing]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkScurbing", 
[GlobalHooks.UITAG.GameUIEquipReworkRefine]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkRefine", 
[GlobalHooks.UITAG.GameUIEquipReworkMake]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkMake", 
[GlobalHooks.UITAG.GameUIEquipReworkReMake]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkReMake", 
[GlobalHooks.UITAG.GameUIEquipReworkKaiguang]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkKaiguang", 
[GlobalHooks.UITAG.GameUIEquipReworkChuancheng]     = "Zeus.UI.XMasterReWork.GameUIEquipReworkChuancheng", 

[GlobalHooks.UITAG.GameUIStrongerMain]     = "Zeus.UI.XmasterStronger.StrongerMain", 
[GlobalHooks.UITAG.GameUIStrongerAchievement]     = "Zeus.UI.XmasterStronger.StrongerAchievement", 

[GlobalHooks.UITAG.GameUITarget]     = "Zeus.UI.XmasterTarget.TargetUI", 
[GlobalHooks.UITAG.GameUITargetSuit]     = "Zeus.UI.XmasterTarget.TargetSuitUI", 

[GlobalHooks.UITAG.GameUIGardenMain]     = "Zeus.UI.XMasterGarden.GardenMain", 
[GlobalHooks.UITAG.GameUIGardenSeeds]     = "Zeus.UI.XMasterGarden.GardenSeeds", 

[GlobalHooks.UITAG.GameUIBloodMain]     = "Zeus.UI.XmasterBloodSoul.BloodSoulMain", 
[GlobalHooks.UITAG.GameUIBloodSuit]     = "Zeus.UI.XmasterBloodSoul.BloodSuit", 
[GlobalHooks.UITAG.GameUIBloodSmelt]     = "Zeus.UI.XmasterBloodSoul.BloodSoulSmelt", 

[GlobalHooks.UITAG.GameUIHotMainUI]     = "Zeus.UI.XmasterHot.HotMain", 
[GlobalHooks.UITAG.GameUIHotContinue]     = "Zeus.UI.XmasterHot.ContinueUI", 
[GlobalHooks.UITAG.GameUIHotRich]     = "Zeus.UI.XmasterHot.RichUI", 
[GlobalHooks.UITAG.GameUIHotSeventarget]     = "Zeus.UI.XmasterHot.SevenTargetUI", 
}
for k,v in pairs(UI_SWITH_SIMPLE_TABLE) do
	local chunk = require(v)
	UI_SWITH_TABLE[k] = function (tag, params)
		return chunk.Create(tag, params), chunk
	end
end


function GlobalHooks.ReloadUI(tagOrPath)
	local function Reload(tag, path)
		if not path then
			print("can not reload menu tag ", tag)
			return
		end
		
		package.loaded[path] = nil
		local chunk = require(path)
		UI_SWITH_TABLE[tag] = function (tag, params)
			return chunk.Create(tag, params), chunk
		end
	end
	MenuMgrU.Instance:ClearAllCacheUI(100)
	local tag, path = nil, nil
	if type(tagOrPath) == "number" then
		tag = tagOrPath
		path = UI_SWITH_SIMPLE_TABLE[tag]
		Reload(tag, path)
	elseif type(tagOrPath) == "string" then
		for k,v in pairs(UI_SWITH_SIMPLE_TABLE) do
			if v == tagOrPath then
				Reload(k, v)
			end
		end
	end
end

function GlobalHooks.CreateCustomUI(xml,cache)
	
	local menu = MenuMgrU.Instance:GetCacheUIByXml(xml)
	local ret
	if not menu then
		ret = XmlUITemplate.Create(xml)
		ret.menu.LuaTable = ret
	else
		ret = menu.LuaTable
	end
	if cache then
		
		if ret.menu.CacheLevel == 0 then
			ret.menu.CacheLevel = (cache and 0) or -1
		end
	end
	print('create_custom_ui',xml)
	
	return ret
end


local CheckUITable = {

CrossServer = {
[GlobalHooks.UITAG.GameUISignXMDS] = true,
[GlobalHooks.UITAG.GameUIActivityHJBoss] = true,
[GlobalHooks.UITAG.GameUIActivityMain] = true,
[GlobalHooks.UITAG.GameUIShop] = true,
[GlobalHooks.UITAG.GameUIFuben] = true,
[GlobalHooks.UITAG.GameUIFubenRoll] = true,
[GlobalHooks.UITAG.GameUISolo] = true,
[GlobalHooks.UITAG.GameUIMultiPvpFrame] = true,


},
}

function GlobalHooks.CheckUICanOpen(tag)
	
	if not GlobalHooks.CheckFuncOpenByTag(tag, true) then
		return false
	end
	
	
	if DataMgr.Instance.UserData.SceneType == PublicConst.SceneType.CrossServer:ToInt() then 
		if CheckUITable.CrossServer[tag] then
			local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PUBLICCFG, "crossServerCheck")
			GameAlertManager.Instance:ShowNotify(tips)
			return false
		end
	end
	
	return true
end

function GlobalHooks.CreateUI(tag, cacheLevel, params)
	
	
	
	if not GlobalHooks.CheckUICanOpen(tag) then
		return nil,nil
	end
	
	
	if(not FuncOpen.SetPlayedFunctionByTag(tag)) then
	    return nil,nil
    end

	local node
	params = tostring(params or "")
	cacheLevel = cacheLevel or 0
	if cacheLevel >= 0 then 
		node = MenuMgrU.Instance:GetCacheUIByTag(tag)
		if node ~= nil then
			node.ExtParam = params
			return node,node.LuaTable
		end
	end
	
	local func = UI_SWITH_TABLE[tag]
	if func then
		local ret, requireTab = func(tag, params)
		if type(ret) == 'table' and ret.menu then
			node = ret.menu
			node.LuaTable = ret
		else
			node = ret
		end
		if requireTab ~= nil and type(requireTab) == 'table' then 
			node.RequireTable = requireTab
		end
	end
	
	
	if node ~= nil then
		node.Tag = tag
		node.ExtParam = params
		node.CacheLevel = cacheLevel
        
		return node,node.LuaTable
	else
		return nil,nil
	end
end


local CacheDefaultLv = {

[GlobalHooks.UITAG.GameUIStrengthenMain] = -1,

[GlobalHooks.UITAG.GameUIMultiPvpFrame] = -1,
[GlobalHooks.UITAG.GameUIBagMain] = 100,
[GlobalHooks.UITAG.GameUISimpleDetail] = -1,
[GlobalHooks.UITAG.GameUIItemDetailMain] = -1,
[GlobalHooks.UITAG.GameUINumInput] = -1,
[GlobalHooks.UITAG.GameUIRoleRename] = -1,
[GlobalHooks.UITAG.GameUIInteractive] = -1,
[GlobalHooks.UITAG.GameUISceneMapUSecond] = -1,
[GlobalHooks.UITAG.GameUIFuncOpen] = -1,



[GlobalHooks.UITAG.GameXMDSUIItemDetail] = -1,
[GlobalHooks.UITAG.GameUIRoleAttribute] = 100,
[GlobalHooks.UITAG.GameUIEquipReworkMain] = -1, 
[GlobalHooks.UITAG.GameUIActivityHJBoss] = -1, 
[GlobalHooks.UITAG.GameUIHuanJing] = -1, 
[GlobalHooks.UITAG.GameUISignXMDS] = -1, 
}

local function InitUICache(eventname, params)
	MenuMgrU.Instance:UICacheInit(CacheDefaultLv)
end






local SwitchMenuList = {

{
key = {
GlobalHooks.UITAG.GameUIItemDetailMain,
GlobalHooks.UITAG.GameUIEquipSuit
},
enter = function (list)
	local menu1 = list[GlobalHooks.UITAG.GameUIItemDetailMain]
	local menu2 = list[GlobalHooks.UITAG.GameUIEquipSuit]
	if menu1.LifeIndex > menu2.LifeIndex then
		menu2:Close()
	else
		menu1:Close()
	end
end,
},
{
key = {
GlobalHooks.UITAG.GameUIItemDetailMain,
GlobalHooks.UITAG.GameUIRoleAttribute
},
enter = function (list)
	local menu1 = list[GlobalHooks.UITAG.GameUIItemDetailMain]
	local menu2 = list[GlobalHooks.UITAG.GameUIRoleAttribute]
	if menu2.LifeIndex > menu1.LifeIndex then
		menu1:Close()
	end
end,
},
{
key = {
GlobalHooks.UITAG.GameUIMelt,
GlobalHooks.UITAG.GameUIBagStore
},
enter = function (list)
	local menu1 = list[GlobalHooks.UITAG.GameUIMelt]
	local menu2 = list[GlobalHooks.UITAG.GameUIBagStore]
	if menu2.LifeIndex > menu1.LifeIndex then
		menu1:Close()
	else
		menu2:Close()
	end
end,
},
{
key = {
GlobalHooks.UITAG.GameUIItemDetailMain,
GlobalHooks.UITAG.GameUIBagStore
},
enter = function (list)
	local menu1 = list[GlobalHooks.UITAG.GameUIItemDetailMain]
	local menu2 = list[GlobalHooks.UITAG.GameUIBagStore]
	if menu2.LifeIndex > menu1.LifeIndex then
		menu1:Close()
	end
end,
},
{
key = {
GlobalHooks.UITAG.GameUIItemDetailMain,
GlobalHooks.UITAG.GameUIMelt
},
enter = function (list)
	local menu1 = list[GlobalHooks.UITAG.GameUIItemDetailMain]
	local menu2 = list[GlobalHooks.UITAG.GameUIMelt]
	if menu2.LifeIndex > menu1.LifeIndex then
		menu1:Close()
	end
end,
},
{
key = {
GlobalHooks.UITAG.GameUIUpStairs,
GlobalHooks.UITAG.GameUIEquipSuit
},
enter = function (list)
	local menu1 = list[GlobalHooks.UITAG.GameUIUpStairs]
	local menu2 = list[GlobalHooks.UITAG.GameUIEquipSuit]
	if menu2.LifeIndex > menu1.LifeIndex then
		menu1:Close()
	end
end,
},
{
key = {
GlobalHooks.UITAG.GameUIItemDetailMain,
GlobalHooks.UITAG.GameUIUpStairs
},
enter = function (list)
	local menu1 = list[GlobalHooks.UITAG.GameUIUpStairs]
	local menu2 = list[GlobalHooks.UITAG.GameUIItemDetailMain]
	if menu2.LifeIndex > menu1.LifeIndex then
		menu1:Close()
	end
end,
},
}


local function OnMenuListChange(array)

	local menu_pair = {}
	local len = array.Length
	for i = 0, len - 1 do
		menu_pair[array[i].Tag] = array[i]
	end
	
	local function Check(t)
		local count = 0
		local key_table = t or {}
		for _,v in ipairs(key_table) do
			local len = array.Length
			for i = 0, len - 1 do
				if v == array[i].Tag then
					count = count + 1
					break
				end
			end
		end
		return (count == #key_table and #key_table ~= 0)
	end
	
	
	for i=#GlobalHooks.SwitchingMenu,1,-1 do
		local v = GlobalHooks.SwitchingMenu[i]
		local item = SwitchMenuList[v]
		if item.leave then
			local ret = Check(item.key)
			local ret_out = Check(item.outkey)
			if not ret then
				item.leave(menu_pair)
				print('leave -----------------',v)
				
				table.remove(GlobalHooks.SwitchingMenu,i)
			end
		end
	end
	
	
	for i=1,#SwitchMenuList do
		local do_it = true
		for _,v in ipairs(GlobalHooks.SwitchingMenu) do
			if v == i then
				do_it = false
				break
			end
		end
		if do_it then
			local item = SwitchMenuList[i]
			if item.enter then
				local ret = Check(item.key)
				local ret_out = Check(item.outkey)
				if ret and not ret_out and item.enter(menu_pair) then
					print('enter -----------------',i)
					table.insert(GlobalHooks.SwitchingMenu,i)
				end
			end
		end
	end
	
end


local function initial()
	print("OpenUI.initial")
	EventManager.Subscribe("Event.OpenUI.Open", OnUIOpen)
	
	InitUICache()
	MenuMgrU.Instance.OnMenuListChange = OnMenuListChange
	
	GlobalHooks.SwitchingMenu = GlobalHooks.SwitchingMenu or {}
end
 

return {initial = initial}
