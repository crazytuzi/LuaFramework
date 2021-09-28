-- require "Common.define";
require "net.LogHttp"
require "Common.MtjFunctions";
require "Core.Manager.UISoundManager"
require "Core.Module.Common.Phalanx";
require "Core.Module.Common.UIEffect";

require "Core.Module.Common.CommonPageItem"
require "Core.Net.SimpleSender";
require "Core.Module.Common.Alert";
require "Core.Manager.ConfigManager";
require "Core.Manager.LanguageMgr";
require "Core.Module.Common.CommonFunction";
require "Core.Module.Common.MsgUtils";
require "Core.Manager.Item.ColorDataManager"
require "Core.Module.Common.QualitySetting";

require "Core.Manager.ProtocolManager";
require "Core.Manager.ModuleManager";
require "Core.Manager.PanelManager";
require "Core.Manager.MessageManager";

require "Core.Manager.LoginManager";
require "Core.Sequence.SequenceManager";
require "Core.Trigger.TriggerManager";
require "Core.Manager.Item.TodoManager";
require "Core.Manager.Item.ChatManager";

require "Core.Module.Login.LoginModule";
require "Core.Module.Message.MessageModule";
require "Core.Module.SelectRole.SelectRoleModule";
require "Core.Module.Backpack.BackpackModule";
require "Core.Module.ProductTip.ProductTipModule";
require "Core.Module.Confirm.ConfirmModule";
require "Core.Module.Broadcast.BroadcastModule"
require "Core.Module.Pet.PetModule";
require "Core.Module.MainUI.MainUIModule";
require "Core.Module.Skill.SkillModule";
require "Core.Module.Dialog.DialogModule";
require "Core.Module.Task.TaskModule";
require "Core.Module.Mail.MailModule";
require "Core.Module.OtherInfo.OtherInfoModule";
require "Core.Module.Friend.FriendModule";
require "Core.Module.Guild.GuildModule";
require "Core.Module.GuildWar.GuildWarModule";
require "Core.Module.Rank.RankModule";
require "Core.Module.Ride.RideModule";
require "Core.Module.Compose.ComposeModule";
require "Core.Module.DaysRank.DaysRankModule";
require "Core.Module.DaysTarget.DaysTargetModule";


require "Core.Module.Equip.EquipModule";
require "Core.Module.Wing.WingModule";
require "Core.Module.Map.MapModule";
require "Core.Module.PVP.PVPModule";
require "Core.Module.UIRequest.UIRequestModule";
require "Core.Module.TShop.TShopModule";
require "Core.Module.AutoFight.AutoFightModule"
--require "Core.Module.Trump.TrumpModule"
require "Core.Module.GM.GMModule"
require "Core.Module.Lottery.LotteryModule"
require "Core.Module.NumInput.NumInputModule"
require "Core.Module.AddFriends.AddFriendsModule"
require "Core.Module.Activity.ActivityModule"
require "Core.Module.InstancePanel.InstancePanelModule"

require "Core.Module.LSInstance.LSInstanceModule"
require "Core.Module.XLTInstance.XLTInstanceModule"


require "Core.Module.FightAlert.FightAlertModule"
require "Core.Module.FightSkillName.FightSkillNameModule"
require "Core.Module.ChoosePKType.ChoosePKTypeModule"

require "Core.Module.FBResult.FBResultModule"
require "Core.Module.Chat.ChatModule"

require "Core.Module.Yaoyuan.YaoyuanModule"
require "Core.Module.SelectScene.SelectSceneModule"

require "Core.Module.LingYao.LingYaoModule"
require "Core.Module.XMBoss.XMBossModule"
require "Core.Module.NewTrump.NewTrumpModule"
require "Core.Module.WildBoss.WildBossModule"
require "Core.Module.WorldBoss.WorldBossModule"

require "Core.Module.ZongMenLiLian.ZongMenLiLianModule"
require "Core.Module.Mall.MallModule"
require "Core.Module.Notice.NoticeModule"
require "Core.Module.Sale.SaleModule"

require "Core.Module.Realm.RealmModule"
require "Core.Module.BusyLoading.BusyLoadingModule"
require "Core.Module.SignIn.SignInModule"
require "Core.Module.Guide.GuideModule"


require "Core.Module.ConvenientUse.ConvenientUseModule"

require "Core.Module.FirstRechargeAward.FirstRechargeAwardModule"

require "Core.Module.Promote.PromoteModule"
require "Core.Module.ActivityGifts.ActivityGiftsModule"

require "Core.Module.Arathi.ArathiModule"
require "Core.Module.Countdown.CountdownModule"
require "Core.Module.AppSplitDown.AppSplitDownModule"

-- require "Core.Module.GuildJuYing.GuildJuYingModule"
require "Core.Module.HirePlayer.HirePlayerModule"
require "Core.Module.ProductGet.ProductGetModule"
require "Core.Module.BuffList.BuffListModule"

require "Core.Module.LD.LDModule"
local LotModule = require "Core.Module.Lot.LotModule"
local EndlessTryModule = require "Core.Module.EndlessTry.EndlessTryModule"
local TabooModule = require "Core.Module.Taboo.TabooModule"

local WiseEquipPanelModule = require "Core.Module.WiseEquip.WiseEquipPanelModule"
local RechargeAwardModule = require "Core.Module.RechargeAward.RechargeAwardModule"
local VipTryModule = require "Core.Module.VipTry.VipTryModule"
local ImmortalShopModule = require "Core.Module.ImmortalShop.ImmortalShopModule"
local XinJiRisksModule = require "Core.Module.XinJiRisks.XinJiRisksModule"
local FormationModule = require "Core.Module.Formation.FormationModule"
local NewestNoticeModule = require "Core.Module.NewestNotice.NewestNoticeModule"

local ItemMoveEffectModule = require "Core.Module.ItemMoveEffect.ItemMoveEffectModule"
local XuanBaoModule = require "Core.Module.Xuanbao.XuanBaoModule";
local StarModule = require "Core.Module.Star.StarModule";
local SceneEntityModule = require "Core.Module.SceneEntity.SceneEntityModule";
local FestivalModule = require "Core.Module.Festival.FestivalModule";
local CloudPurchaseModule = require "Core.Module.CloudPurchase.CloudPurchaseModule"
local CashGiftModule = require "Core.Module.CashGift.CashGiftModule"
local YaoShouModule = require "Core.Module.YaoShou.YaoShouModule";

-- local mri = require "MemoryReferenceInfo"
--[[UpdateBeat = event("Update", true);
LateUpdateBeat = event("LateUpdate", true);
CoUpdateBeat = event("CoUpdate", true);
FixedUpdateBeat = event("FixedUpdate", true);
--]]
frameRate = 30
FPSScale = 1;

 

function Main(blDegug)

    LoginManager.Init();
    ModuleManager.AddAdditionModule(ConfirmModule);
    ModuleManager.AddAdditionModule(NoticeModule);
	ModuleManager.AddAdditionModule(AppSplitDownModule);
	AppSplitDownProxy.InitStatic()
    if GameConfig.instance.autoLogin then 
	    local o = UserConfig.GetInstance();
	    local userName = o:GetValue("username");
	    local password = o:GetValue("password");
	    LoginHttp.SetIsLoginCallBack(false)
        coroutine.start(LoginHttp.TryLogin, userName, password)
    else
        ModuleManager.GotoModule(LoginModule);
    end

    ModuleManager.AddAdditionModule(MainUIModule);
    ModuleManager.AddAdditionModule(MessageModule);
    ModuleManager.AddAdditionModule(SelectRoleModule);
    ModuleManager.AddAdditionModule(BackpackModule);
    ModuleManager.AddAdditionModule(ProductTipModule);
    ModuleManager.AddAdditionModule(BroadcastModule);
    ModuleManager.AddAdditionModule(SkillModule);
    ModuleManager.AddAdditionModule(PetModule);
    ModuleManager.AddAdditionModule(DialogModule);
    ModuleManager.AddAdditionModule(TaskModule);
    ModuleManager.AddAdditionModule(MailModule);
    ModuleManager.AddAdditionModule(OtherInfoModule);
    ModuleManager.AddAdditionModule(FriendModule);
    ModuleManager.AddAdditionModule(GuildModule);
    ModuleManager.AddAdditionModule(GuildWarModule);

    ModuleManager.AddAdditionModule(RankModule);
    ModuleManager.AddAdditionModule(ComposeModule);
    ModuleManager.AddAdditionModule(DaysRankModule);
    ModuleManager.AddAdditionModule(DaysTargetModule);
    ModuleManager.AddAdditionModule(XuanBaoModule);


    ModuleManager.AddAdditionModule(RideModule);
    ModuleManager.AddAdditionModule(EquipModule);

    ModuleManager.AddAdditionModule(WingModule)
    ModuleManager.AddAdditionModule(MapModule)
    ModuleManager.AddAdditionModule(PVPModule);

    ModuleManager.AddAdditionModule(UIRequestModule);
    -- tangping
    ModuleManager.AddAdditionModule(TShopModule);

    ModuleManager.AddAdditionModule(AutoFightModule);
    --ModuleManager.AddAdditionModule(TrumpModule);
    ModuleManager.AddAdditionModule(GMModule);

    ModuleManager.AddAdditionModule(LotteryModule);
    ModuleManager.AddAdditionModule(NumInputModule);

    ModuleManager.AddAdditionModule(AddFriendsModule);

    ModuleManager.AddAdditionModule(ActivityModule);
    ModuleManager.AddAdditionModule(InstancePanelModule);

    ModuleManager.AddAdditionModule(FightAlertModule);
    ModuleManager.AddAdditionModule(FightSkillNameModule);
    ModuleManager.AddAdditionModule(ChoosePKTypeModule);

    ModuleManager.AddAdditionModule(LSInstanceModule);
    ModuleManager.AddAdditionModule(FBResultModule);
    ModuleManager.AddAdditionModule(ChatModule);


    ModuleManager.AddAdditionModule(XLTInstanceModule);

    ModuleManager.AddAdditionModule(YaoyuanModule);
    ModuleManager.AddAdditionModule(SelectSceneModule);

    ModuleManager.AddAdditionModule(LingYaoModule);

    ModuleManager.AddAdditionModule(XMBossModule);
    ModuleManager.AddAdditionModule(NewTrumpModule);

    ModuleManager.AddAdditionModule(WildBossModule);

    ModuleManager.AddAdditionModule(ZongMenLiLianModule);
    ModuleManager.AddAdditionModule(MallModule);
    ModuleManager.AddAdditionModule(WorldBossModule);
    ModuleManager.AddAdditionModule(SaleModule);
    ModuleManager.AddAdditionModule(RealmModule);

    ModuleManager.AddAdditionModule(BusyLoadingModule);
    ModuleManager.AddAdditionModule(SignInModule);
    ModuleManager.AddAdditionModule(ConvenientUseModule);
    ModuleManager.AddAdditionModule(GuideModule);

    ModuleManager.AddAdditionModule(FirstRechargeAwardModule);

    ModuleManager.AddAdditionModule(PromoteModule);

    ModuleManager.AddAdditionModule(ActivityGiftsModule);

    ModuleManager.AddAdditionModule(ArathiModule);
    ModuleManager.AddAdditionModule(CountdownModule);

	
    -- ModuleManager.AddAdditionModule(GuildJuYingModule);
    ModuleManager.AddAdditionModule(HirePlayerModule);

    ModuleManager.AddAdditionModule(LDModule);
    ModuleManager.AddAdditionModule(ProductGetModule);
    ModuleManager.AddAdditionModule(BuffListModule);
    ModuleManager.AddAdditionModule(LotModule);
    ModuleManager.AddAdditionModule(EndlessTryModule);
    ModuleManager.AddAdditionModule(TabooModule);

    ModuleManager.AddAdditionModule(WiseEquipPanelModule);
    ModuleManager.AddAdditionModule(RechargeAwardModule);
    ModuleManager.AddAdditionModule(VipTryModule);
    ModuleManager.AddAdditionModule(ImmortalShopModule);

    ModuleManager.AddAdditionModule(XinJiRisksModule);
    ModuleManager.AddAdditionModule(FormationModule);
    ModuleManager.AddAdditionModule(NewestNoticeModule);
    
	ModuleManager.AddAdditionModule(ItemMoveEffectModule);
	ModuleManager.AddAdditionModule(StarModule);
	ModuleManager.AddAdditionModule(SceneEntityModule);
	ModuleManager.AddAdditionModule(FestivalModule);
	ModuleManager.AddAdditionModule(CloudPurchaseModule);
	ModuleManager.AddAdditionModule(CashGiftModule);
    ModuleManager.AddAdditionModule(YaoShouModule);
    

	
    SequenceManager.Init();
    TriggerManager.Init();
    ChatManager.InitVoice()

	
    -- UnityEngine.QualitySettings.SetQualityLevel(3, true);
    Application.runInBackground = true
end

-- 更新相机参数
function UpdateCameraConfig()
    if not MainCameraController.GetInstance():CanApplyParam() then return end
    UpdateCameraConfiging()
end
function UpdateCameraConfiging()
    local gameConfig = GameConfig.instance
    cameraAngle = gameConfig.cameraAngle;
    cameraLensRotation = gameConfig.cameraLensRotation;
    cameraDistance = gameConfig.cameraDistance;
    cameraOffsetY = gameConfig.cameraOffsetY;
end
UpdateCameraConfiging()

function Update(deltatime, unscaledDeltaTime)
    -- FPSScale =(FPSScale +(deltatime /(1.0 / frameRate))) / 2;
    -- local t = UnityEngine.Time.realtimeSinceStartup;
    Time:SetDeltaTime(deltatime, unscaledDeltaTime)
    UpdateBeat();
    -- if(UnityEngine.Time.realtimeSinceStartup - t > 0.1) then
    --    logTrace("Main.Update,time=" .. UnityEngine.Time.realtimeSinceStartup)
    -- end
end

function LateUpdate()
    -- local t = UnityEngine.Time.realtimeSinceStartup;
    -- UpdateCameraConfig()
    LateUpdateBeat()
    CoUpdateBeat()
    -- if(UnityEngine.Time.realtimeSinceStartup - t > 0.1) then
    -- end
end

function FixedUpdate(fixedTime)
    -- local t = UnityEngine.Time.realtimeSinceStartup;
    FPSScale = fixedTime /(1 / frameRate);
    Time:SetFixedDelta(fixedTime)
    FixedUpdateBeat()
    -- if(UnityEngine.Time.realtimeSinceStartup - t > 0.1) then
    --    logTrace("Main.FixedUpdate,time=" .. UnityEngine.Time.realtimeSinceStartup)
    -- end
end

function OnLevelWasLoaded(level)
    Time.timeSinceLevelLoad = 0
end

-- 重启游戏
function ReStartGame()
    SocketClientLua.Get_ins():Close()
    Engine.instance:ReStartGame()
end
-- 重启游戏前清理,由c#调用
function DisposeGame()
    PlayerManager.SubmitExtraData(5)
    PlayerManager.DisposeHero()
    PanelManager.DisposeAll()
    UIUtil.RemoveAllChildren(Scene.instance.uiHurtNumParent)
    UIUtil.RemoveAllChildren(Scene.instance.uiNameParent)
    UIUtil.RemoveAllChildren(Scene.instance.uiDropParent)
    if (GameSceneManager.map) then
        GameSceneManager.map:Dispose();
        GameSceneManager.map = nil;
    end
    Application.LoadLevel("Loading");
end

function PrintGloal()
    -- collectgarbage("collect")
    -- mri.m_cMethods.DumpMemorySnapshot("./", "AllMemoryRef", - 1)
    -- 打印当前 Lua 虚拟机中某一个对象的所有相关引用。
    -- strSavePath - 快照保存路径，不包括文件名。
    -- strExtraFileName - 添加额外的信息到文件名，可以为 "" 或者 nil。
    -- nMaxRescords - 最多打印多少条记录，-1 打印所有记录。
    -- strObjectName - 对象显示名称。
    -- cObject - 对象实例。
    -- MemoryReferenceInfo.m_cMethods.DumpMemorySnapshotSingleObject(strSavePath, strExtraFileName, nMaxRescords, strObjectName, cObject)
    -- collectgarbage("collect")
    -- mri.m_cMethods.DumpMemorySnapshotSingleObject("./", "SingleObjRef", - 1, "_G", _G)
    -- 比较两份内存快照结果文件，打印文件 strResultFilePathAfter 相对于 strResultFilePathBefore 中新增的内容。
    -- strSavePath - 快照保存路径，不包括文件名。
    -- strExtraFileName - 添加额外的信息到文件名，可以为 "" 或者 nil。
    -- nMaxRescords - 最多打印多少条记录，-1 打印所有记录。
    -- strResultFilePathBefore - 第一个内存快照文件。
    -- strResultFilePathAfter - 第二个用于比较的内存快照文件。
    -- MemoryReferenceInfo.m_cMethods.DumpMemorySnapshotComparedFile(strSavePath, strExtraFileName, nMaxRescords, strResultFilePathBefore, strResultFilePathAfter)
    -- mri.m_cMethods.DumpMemorySnapshotComparedFile("./", "Compared", -1, "./LuaMemRefInfo-All-[20170505-002343]-[AllMemoryRef].txt", "./LuaMemRefInfo-All-[20170505-002346]-[AllMemoryRef].txt")
    mri.m_cMethods.DumpMemorySnapshotComparedFile("./", "Compared", -1, "./LuaMemRefInfo-All-[20170508-173558]-[AllMemoryRef].txt", "./LuaMemRefInfo-All-[20170508-173519]-[AllMemoryRef].txt")
    -- 按照关键字过滤一个内存快照文件然后输出到另一个文件.
    -- strFilePath - 需要被过滤输出的内存快照文件。
    -- strFilter - 过滤关键字
    -- bIncludeFilter - 包含关键字(true)还是排除关键字(false)来输出内容。
    -- bOutputFile - 输出到文件(true)还是 console 控制台(false)。
    -- MemoryReferenceInfo.m_cBases.OutputFilteredResult(strFilePath, strFilter, bIncludeFilter, bOutputFile)
    -- mri.m_cBases.OutputFilteredResult("./LuaMemRefInfo-All-[20170505-002343]-[AllMemoryRef].txt", "print", true, true)
    print("Dump memory information ok!")
end
