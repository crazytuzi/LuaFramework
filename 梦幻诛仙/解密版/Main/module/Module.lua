local Module = {}
Module.moduleId = require("Main.Module.ModuleId")
Module.notifyId = require("Main.Module.NotifyId")
Module.network = require("netio.Network")
Module.moduleMgr = require("Main.module.ModuleMgr").Instance()
require("textres")
require("consts.constant")
gmodule = Module
Module.moduleMgr:RegisterModule(ModuleId.LOGIN, "Main.Login.LoginModule")
Module.moduleMgr:RegisterModule(ModuleId.ITEM, "Main.Item.ItemModule")
Module.moduleMgr:RegisterModule(ModuleId.MAP, "Main.Map.MapModule")
Module.moduleMgr:RegisterModule(ModuleId.FIGHT, "Main.Fight.FightModule")
Module.moduleMgr:RegisterModule(ModuleId.HERO, "Main.Hero.HeroModule")
Module.moduleMgr:RegisterModule(ModuleId.PUBROLE, "Main.Pubrole.PubroleModule")
Module.moduleMgr:RegisterModule(ModuleId.MAINUI, "Main.MainUI.MainUIModule")
Module.moduleMgr:RegisterModule(ModuleId.FRIEND, "Main.friend.FriendModule")
Module.moduleMgr:RegisterModule(ModuleId.CHAT, "Main.Chat.ChatModule")
Module.moduleMgr:RegisterModule(ModuleId.CHATREDGIFT, "Main.ChatRedGift.ChatRedGiftModule")
Module.moduleMgr:RegisterModule(ModuleId.Question, "Main.Question.QuestionModule")
Module.moduleMgr:RegisterModule(ModuleId.EVERY_NIGHT_QUESTION, "Main.Question.EveryNightQuestionModule")
Module.moduleMgr:RegisterModule(ModuleId.EQUIP, "Main.Equip.EquipModule")
Module.moduleMgr:RegisterModule(ModuleId.TEAM, "Main.Team.TeamModule")
Module.moduleMgr:RegisterModule(ModuleId.NPC, "Main.npc.NPCModule")
Module.moduleMgr:RegisterModule(ModuleId.TASK, "Main.task.TaskModule")
Module.moduleMgr:RegisterModule(ModuleId.PET, "Main.Pet.PetModule")
Module.moduleMgr:RegisterModule(ModuleId.WABAO, "Main.Wabao.WabaoModule")
Module.moduleMgr:RegisterModule(ModuleId.ACTIVITY, "Main.activity.ActivityModule")
Module.moduleMgr:RegisterModule(ModuleId.NPC_STORE, "Main.Shop.NpcShop.NpcShopModule")
Module.moduleMgr:RegisterModule(ModuleId.ANNOUNCEMENT, "Main.Announcement.AnnouncementModule")
Module.moduleMgr:RegisterModule(ModuleId.GIVE, "Main.Give.GiveModule")
Module.moduleMgr:RegisterModule(ModuleId.BUFF, "Main.Buff.BuffModule")
Module.moduleMgr:RegisterModule(ModuleId.FORMATION, "Main.Formation.FormationModule")
Module.moduleMgr:RegisterModule(ModuleId.SKILL, "Main.Skill.SkillModule")
Module.moduleMgr:RegisterModule(ModuleId.ONHOOK, "Main.OnHook.OnHookModule")
Module.moduleMgr:RegisterModule(ModuleId.SERVER, "Main.Server.ServerModule")
Module.moduleMgr:RegisterModule(ModuleId.COMMERCEANDPITCH, "Main.CommerceAndPitch.CommercePitchModule")
Module.moduleMgr:RegisterModule(ModuleId.SYSTEM_SETTING, "Main.SystemSetting.SystemSettingModule")
Module.moduleMgr:RegisterModule(ModuleId.WING, "Main.Wing.WingModule")
Module.moduleMgr:RegisterModule(ModuleId.FABAO, "Main.Fabao.FabaoModule")
Module.moduleMgr:RegisterModule(ModuleId.PARTNER, "Main.partner.PartnerModule")
Module.moduleMgr:RegisterModule(ModuleId.FLY, "Main.Fly.FlyModule")
Module.moduleMgr:RegisterModule(ModuleId.MAPITEM, "Main.Map.MapItemModule")
Module.moduleMgr:RegisterModule(ModuleId.TITLE, "Main.title.TitleModule")
Module.moduleMgr:RegisterModule(ModuleId.AWARD, "Main.Award.AwardModule")
Module.moduleMgr:RegisterModule(ModuleId.GANG, "Main.Gang.GangModule")
Module.moduleMgr:RegisterModule(ModuleId.LEITAI, "Main.PVP.LeitaiModule")
Module.moduleMgr:RegisterModule(ModuleId.DUNGEON, "Main.Dungeon.DungeonModule")
Module.moduleMgr:RegisterModule(ModuleId.OCCUPATIONCHANLLENGE, "Main.OccupationChallenge.OccupationChanllengeModule")
Module.moduleMgr:RegisterModule(ModuleId.TEAM_PLATFORM, "Main.TeamPlatform.TeamPlatformModule")
Module.moduleMgr:RegisterModule(ModuleId.MALL, "Main.Mall.MallModule")
Module.moduleMgr:RegisterModule(ModuleId.CREDITSSHOP, "Main.CreditsShop.CreditsShopModule")
Module.moduleMgr:RegisterModule(ModuleId.RANK_LIST, "Main.RankList.RankListModule")
Module.moduleMgr:RegisterModule(ModuleId.UPDATE_NOTICE, "Main.UpdateNotice.UpdateNoticeModule")
Module.moduleMgr:RegisterModule(ModuleId.SOUND, "Main.Sound.SoundModule")
Module.moduleMgr:RegisterModule(ModuleId.FX, "Main.FX.FXModule")
Module.moduleMgr:RegisterModule(ModuleId.PRESENT, "Main.Present.PresentModule")
Module.moduleMgr:RegisterModule(ModuleId.GUIDE, "Main.Guide.GuideModule")
Module.moduleMgr:RegisterModule(ModuleId.LOTTERY, "Main.Lottery.LotteryModule")
Module.moduleMgr:RegisterModule(ModuleId.PK, "Main.PK.PKModule")
Module.moduleMgr:RegisterModule(ModuleId.IMAGEPVP, "Main.PVP.ImagePvpModule")
Module.moduleMgr:RegisterModule(ModuleId.LEADER_BATTLE, "Main.PVP.LeaderBattleModule")
Module.moduleMgr:RegisterModule(ModuleId.KEJU, "Main.Keju.KejuModule")
Module.moduleMgr:RegisterModule(ModuleId.GROW, "Main.Grow.GrowModule")
Module.moduleMgr:RegisterModule(ModuleId.DYEING, "Main.Dyeing.DyeingModule")
Module.moduleMgr:RegisterModule(ModuleId.SWORN, "Main.Sworn.SwornModule")
Module.moduleMgr:RegisterModule(ModuleId.WORLDBOSS, "Main.WorldBoss.WorldBossModule")
Module.moduleMgr:RegisterModule(ModuleId.BADGE, "Main.Badge.BadgeModule")
Module.moduleMgr:RegisterModule(ModuleId.PHANTOMCAVE, "Main.PhantomCave.PhantomCaveModule")
Module.moduleMgr:RegisterModule(ModuleId.PAY, "Main.Pay.PayModule")
Module.moduleMgr:RegisterModule(ModuleId.MARRIAGE, "Main.Marriage.MarriageModule")
Module.moduleMgr:RegisterModule(ModuleId.FESTIVAL, "Main.Festival.FestivalModule")
Module.moduleMgr:RegisterModule(ModuleId.RELATIONSHIPCHAIN, "Main.RelationShipChain.RelationShipChainModule")
Module.moduleMgr:RegisterModule(ModuleId.QINGYUNZHI, "Main.QingYunZhi.QingYunZhiModule")
Module.moduleMgr:RegisterModule(ModuleId.FEATURE, "Main.FeatureOpenList.FeatureOpenListModule")
Module.moduleMgr:RegisterModule(ModuleId.WORLD_QUESTION, "Main.WorldQuestion.WorldQuestionModule")
Module.moduleMgr:RegisterModule(ModuleId.WEDDING_TOUR, "Main.WeddingTour.WeddingTourModule")
Module.moduleMgr:RegisterModule(ModuleId.TRADING_ARCADE, "Main.TradingArcade.TradingArcadeModule")
Module.moduleMgr:RegisterModule(ModuleId.SHITU, "Main.Shitu.ShituModule")
Module.moduleMgr:RegisterModule(ModuleId.GANGRACE, "Main.GangRace.GangRaceModule")
Module.moduleMgr:RegisterModule(ModuleId.QIMAI_HUIWU, "Main.Qimai.QimaiModule")
Module.moduleMgr:RegisterModule(ModuleId.BIYILIANZHI, "Main.BiYiLianZhi.BiYiLianZhiModule")
Module.moduleMgr:RegisterModule(ModuleId.IDIP, "Main.IDIP.IDIPModule")
Module.moduleMgr:RegisterModule(ModuleId.QUICK_LAUNCH, "Main.QuickLaunch.QuickLaunchModule")
Module.moduleMgr:RegisterModule(ModuleId.FASHION, "Main.Fashion.FashionModule")
Module.moduleMgr:RegisterModule(ModuleId.CUSTOM_ACTIVITY, "Main.CustomActivity.CustomActivityModule")
Module.moduleMgr:RegisterModule(ModuleId.SHARE, "Main.Share.ShareModule")
Module.moduleMgr:RegisterModule(ModuleId.ACHIEVEMENT, "Main.achievement.AchievementModule")
Module.moduleMgr:RegisterModule(ModuleId.EXCHANGE, "Main.Exchange.ExchangeModule")
Module.moduleMgr:RegisterModule(ModuleId.PERSONAL_INFO, "Main.PersonalInfo.PersonalInfoModule")
Module.moduleMgr:RegisterModule(ModuleId.QINGYUAN, "Main.QingYuan.QingYuanModule")
Module.moduleMgr:RegisterModule(ModuleId.GROUP, "Main.Group.GroupModule")
Module.moduleMgr:RegisterModule(ModuleId.HOMELAND, "Main.Homeland.HomelandModule")
Module.moduleMgr:RegisterModule(ModuleId.BANQUET, "Main.Banquet.BanquetModule")
Module.moduleMgr:RegisterModule(ModuleId.STORYWALL, "Main.Storywall.StoryWallModule")
Module.moduleMgr:RegisterModule(ModuleId.MOUNTS, "Main.Mounts.MountsModule")
Module.moduleMgr:RegisterModule(ModuleId.CAT, "Main.Cat.CatModule")
Module.moduleMgr:RegisterModule(ModuleId.MULTIOCCUPATION, "Main.MultiOccupation.MultiOccupationModule")
Module.moduleMgr:RegisterModule(ModuleId.CROSS_SERVER, "Main.CrossServer.CrossServerModule")
Module.moduleMgr:RegisterModule(ModuleId.LUCKYSTAR, "Main.LuckyStar.LuckyStarModule")
Module.moduleMgr:RegisterModule(ModuleId.ANTIADDICTION, "Main.AntiAddiction.AntiAddictionModule")
Module.moduleMgr:RegisterModule(ModuleId.DOUDOU_CLEAR, "Main.DoudouClear.DoudouClearModule")
Module.moduleMgr:RegisterModule(ModuleId.MINI_GAME, "Main.MiniGame.MiniGameModule")
Module.moduleMgr:RegisterModule(ModuleId.INTERACTIVE_TASK, "Main.InteractiveTask.InteractiveTaskModule")
Module.moduleMgr:RegisterModule(ModuleId.CHILDREN, "Main.Children.ChildrenModule")
Module.moduleMgr:RegisterModule(ModuleId.MAGIC_MARK, "Main.MagicMark.MagicMarkModule")
Module.moduleMgr:RegisterModule(ModuleId.CONSTELLATION, "Main.Constellation.ConstellationModule")
Module.moduleMgr:RegisterModule(ModuleId.PLANT_TREE, "Main.PlantTree.PlantTreeModule")
Module.moduleMgr:RegisterModule(ModuleId.VOTE, "Main.Vote.VoteModule")
Module.moduleMgr:RegisterModule(ModuleId.WORSHIP, "Main.Worship.WorshipModule")
Module.moduleMgr:RegisterModule(ModuleId.SOARING, "Main.Soaring.SoaringModule")
Module.moduleMgr:RegisterModule(ModuleId.MENPAISTAR, "Main.MenpaiStar.MenpaiStarModule")
Module.moduleMgr:RegisterModule(ModuleId.ORACLE, "Main.Oracle.OracleModule")
Module.moduleMgr:RegisterModule(ModuleId.GANG_DUNGEON, "Main.GangDungeon.GangDungeonModule")
Module.moduleMgr:RegisterModule(ModuleId.AVATAR, "Main.Avatar.AvatarModule")
Module.moduleMgr:RegisterModule(ModuleId.DELIVERY, "Main.DeliveryGame.DeliveryGameModule")
Module.moduleMgr:RegisterModule(ModuleId.POKEMON, "Main.Pokemon.PokemonModule")
Module.moduleMgr:RegisterModule(ModuleId.CORPS, "Main.Corps.CorpsModule")
Module.moduleMgr:RegisterModule(ModuleId.GANG_CROSS, "Main.GangCross.GangCrossModule")
Module.moduleMgr:RegisterModule(ModuleId.DRAGON_BOAT_RACE, "Main.DragonBoatRace.DragonBoatRaceModule")
Module.moduleMgr:RegisterModule(ModuleId.CROSS_BATTLE, "Main.CrossBattle.CrossBattleModule")
Module.moduleMgr:RegisterModule(ModuleId.FABAO_SPIRIT, "Main.FabaoSpirit.FabaoSpiritModule")
Module.moduleMgr:RegisterModule(ModuleId.GOD_WEAPON, "Main.GodWeapon.GodWeaponModule")
Module.moduleMgr:RegisterModule(ModuleId.CTF, "Main.CaptureTheFlag.CaptureTheFlagModule")
Module.moduleMgr:RegisterModule(ModuleId.CROSS_BATTLEFIELD, "Main.CrossBattlefield.CrossBattlefieldModule")
Module.moduleMgr:RegisterModule(ModuleId.CARNIVAL, "Main.Carnival.CarnivalModule")
Module.moduleMgr:RegisterModule(ModuleId.PLAYER_PK, "Main.PlayerPK.PlayerPKModule")
Module.moduleMgr:RegisterModule(ModuleId.BACK_TO_GAME, "Main.BackToGame.BackToGameModule")
Module.moduleMgr:RegisterModule(ModuleId.VOICE_QUESTION, "Main.VoiceQuestion.VoiceQuestionModule")
Module.moduleMgr:RegisterModule(ModuleId.WELCOME_PARTY, "Main.WelcomeParty.WelcomePartyModule")
Module.moduleMgr:RegisterModule(ModuleId.SOCIAL_SPACE, "Main.SocialSpace.SocialSpaceModule")
Module.moduleMgr:RegisterModule(ModuleId.QIXI, "Main.Qixi.QixiModule")
Module.moduleMgr:RegisterModule(ModuleId.AFK_DETECT, "Main.AFKDetect.AFKDetectModule")
Module.moduleMgr:RegisterModule(ModuleId.NEW_TERM, "Main.NewTerm.NewTermModule")
Module.moduleMgr:RegisterModule(ModuleId.CHESS, "Main.Chess.ChessModule")
Module.moduleMgr:RegisterModule(ModuleId.DOUBLE_INTERACTION, "Main.DoubleInteraction.DoubleInteractionModule")
Module.moduleMgr:RegisterModule(ModuleId.NATIONAL_DAY, "Main.activity.NationalDay.NationalDayModule")
Module.moduleMgr:RegisterModule(ModuleId.RECALL, "Main.Recall.RecallModule")
Module.moduleMgr:RegisterModule(ModuleId.TURNED_CARD, "Main.TurnedCard.TurnedCardModule")
Module.moduleMgr:RegisterModule(ModuleId.TOKEN_MALL, "Main.TokenMall.TokenMallModule")
Module.moduleMgr:RegisterModule(ModuleId.GROUP_SHOPPING, "Main.GroupShopping.GroupShoppingModule")
Module.moduleMgr:RegisterModule(ModuleId.AIRCRAFT, "Main.Aircraft.AircraftModule")
Module.moduleMgr:RegisterModule(ModuleId.YIYUANDUOBAO, "Main.YiYuanDuoBao.YiYuanDuoBaoModule")
Module.moduleMgr:RegisterModule(ModuleId.ANNIVERSARY, "Main.activity.Anniversary.AnniversaryModule")
Module.moduleMgr:RegisterModule(ModuleId.ALLLOTTO, "Main.AllLotto.AllLottoModule")
Module.moduleMgr:RegisterModule(ModuleId.AUCTION, "Main.Auction.AuctionModule")
Module.moduleMgr:RegisterModule(ModuleId.SNAPSHOT, "Main.Snapshot.SnapshotModule")
Module.moduleMgr:RegisterModule(ModuleId.PETTEAM, "Main.PetTeam.PetTeamModule")
Module.moduleMgr:RegisterModule(ModuleId.AAGR, "Main.Aagr.AagrModule")
Module.sendProtocol = Module.network.sendProtocol
function Module.gameStart()
  local moduleSetting = require("Main.module.ModuleSetting").Instance()
  moduleSetting:Init()
  Module.network.networkStartup()
  Module.moduleMgr:GetModule(ModuleId.LOGIN):Start()
  Module.moduleMgr:InitAllModules()
  Module.moduleMgr:LateInitAllModules()
  Module.ProLoadRes()
end
function Module.ProLoadRes()
  AsyncLoadArray({
    RESPATH.MODEL_ALPHA_SKIN,
    RESPATH.WEAPON_ALPHA_SKIN,
    RESPATH.MODEL_ALPHA_GENERAL,
    RESPATH.WING_ALPHA_SKIN,
    RESPATH.CHILD_ALPHA_SKIN,
    RESPATH.MODEL_STONE_SKIN,
    RESPATH.WEAPON_STONE_SKIN,
    RESPATH.MODEL_STONE_GENERAL,
    RESPATH.WING_STONE_SKIN
  }, function(objList)
    local shaderList = require("Model.ECModel").alphaShaderList
    for _, obj in pairs(objList) do
      shaderList[obj.name] = obj
    end
  end)
  AsyncLoadArray({
    RESPATH.MODEL_DISSOLVE_SKIN,
    RESPATH.MODEL_DISSOLVE_GENERAL,
    RESPATH.MODEL_DISSOLVE_WEAPON,
    RESPATH.MODEL_DISTORTION_SKIN,
    RESPATH.MODEL_DISTORTION_GENERAL,
    RESPATH.MODEL_DISTORTION_WEAPON
  }, function(objList)
    local shaderList = require("Model.ECModel").dissolveShaderList
    for _, obj in pairs(objList) do
      shaderList[obj.name] = obj
    end
  end)
  AsyncLoadArray({
    RESPATH.MODEL_GHOST_SKIN,
    RESPATH.MODEL_GHOST_WING,
    RESPATH.MODEL_GHOST_GENERAL,
    RESPATH.MODEL_GHOST_COLOR,
    RESPATH.MODEL_GHOST_WEAPON
  }, function(objList)
    local shaderList = require("Model.ECModel").ghostShaderList
    for _, obj in pairs(objList) do
      shaderList[obj.name] = obj
      GameUtil.AddGhostShader(obj.name, obj)
    end
  end)
  AsyncLoadArray({
    RESPATH.TEX_DISSOLVE,
    RESPATH.TEX_DISSOLVE_Ram
  }, function(objList)
    local dissolvesTexture = require("Model.ECModel").dissolvesTexture
    dissolvesTexture.tex = objList[1]
    dissolvesTexture.ramTex = objList[2]
  end)
  AsyncLoadArray({
    RESPATH.MODEL_LIGHT_SHADER,
    RESPATH.MODEL_LIGHT_TEX
  }, function(objList)
    local lightRes = require("Model.ECModel").lightRes
    lightRes.shader = objList[1]
    lightRes.tex = objList[2]
  end)
end
return Module
