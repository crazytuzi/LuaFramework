--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/7/17
-- Time: 22:13
-- 
--
_G.classlist['GameController'] = 'GameController'
_G.GameController = {}
_G.GameController.objName = 'GameController'
_G.enNormalUpdate = 1
_G.enLoadingScene = 2

GameController.loginState = false--创角
GameController.controllers = {}
GameController.currentState = nil
GameController.loadingState = true
function GameController:Create()
    Debug("GameController:Create()")
	if _G.sceneTest then
		table.insert(self.controllers, LoginController)
		table.insert(self.controllers, MainPlayerController)
		table.insert(self.controllers, CharController)
        table.insert(self.controllers, SkillController)
        table.insert(self.controllers, NpcController)
        table.insert(self.controllers, MonsterController)
        table.insert(self.controllers, DropItemController)
        table.insert(self.controllers, AutoBattleController);
		table.insert(self.controllers, EditeController);

    else
		table.insert(self.controllers, ToolsController);
		table.insert(self.controllers, LoginController)
		table.insert(self.controllers, MainPlayerController)
		table.insert(self.controllers, NpcController)
		table.insert(self.controllers, MonsterController)
		table.insert(self.controllers, MainMenuController);
		table.insert(self.controllers, SkillController)
		table.insert(self.controllers, CharController)
		table.insert(self.controllers, BagController);
		table.insert(self.controllers, QuestController);
		table.insert(self.controllers, DropItemController)
		table.insert(self.controllers, CollectionController)
		table.insert(self.controllers, BuffController)
		table.insert(self.controllers, ChatController);
		table.insert(self.controllers, RoleController);
		table.insert(self.controllers, TeamController);
		table.insert(self.controllers, SpiritsController);
		table.insert(self.controllers, StoryController);
		table.insert(self.controllers, DungeonController);
		table.insert(self.controllers, FriendController);
		table.insert(self.controllers, RemindController);
		table.insert(self.controllers, AutoBattleController);
		table.insert(self.controllers, DealController);
		table.insert(self.controllers, MailController);
		table.insert(self.controllers, ShopController);
		table.insert(self.controllers, SitController);
		table.insert(self.controllers, FuncOpenController);
		table.insert(self.controllers, RemindFuncController);
		table.insert(self.controllers, MountController);
		table.insert(self.controllers, MountLingShouController);
		table.insert(self.controllers, HallowsController);
		table.insert(self.controllers, EquipController);
        table.insert(self.controllers, UnionController);
        table.insert(self.controllers, UnionDungeonController);
		table.insert(self.controllers, UnionDungeonHellController);
		table.insert(self.controllers, TitleController);
		table.insert(self.controllers, FengYaoController);
		table.insert(self.controllers, ActivityController);
		table.insert(self.controllers, RegisterAwardController);
        table.insert(self.controllers, ArenaController);
		table.insert(self.controllers, HeChengController);
        table.insert(self.controllers, ZhChFlagController);
        table.insert(self.controllers, RankListController);
        table.insert(self.controllers, SetSystemController);
        table.insert(self.controllers, DropValueController);
        table.insert(self.controllers, FashionsController);
        table.insert(self.controllers, UnionWarController);
		table.insert(self.controllers, BabelController);
		table.insert(self.controllers, TimeDungeonController);
        table.insert(self.controllers, HuoYueDuController)
        table.insert(self.controllers, UnionCityWarController);
		table.insert(self.controllers, KillValueController);
        table.insert(self.controllers, SuperGloryController);
        table.insert(self.controllers, DailyMustDoController);
        table.insert(self.controllers, PersonalBossController);
        table.insert(self.controllers, QiZhanDungeonController);
        table.insert(self.controllers, DekaronDungeonController);
		table.insert(self.controllers, OperActController);
        table.insert(self.controllers, FangChenMiController);
        table.insert(self.controllers, WarPrintController);
        table.insert(self.controllers, MapController);
        table.insert(self.controllers, PhoneContrller);
        table.insert(self.controllers, BaoJiaController);
		table.insert(self.controllers, LingLiHuiZhangController);
        table.insert(self.controllers, VplanController);
        table.insert(self.controllers, AchievementController);
		table.insert(self.controllers, YunYingController);
		table.insert(self.controllers, DominateRouteController);
        table.insert(self.controllers, MClientController);
        table.insert(self.controllers, EquipBuildController);
        table.insert(self.controllers, TargetController);
        table.insert(self.controllers, LovelyPetController);
		table.insert(self.controllers, BingHunController);
		table.insert(self.controllers, RedPacketController);
		table.insert(self.controllers, QiZhanController);
        table.insert(self.controllers, WishController);
        table.insert(self.controllers, ExtremitChallengeController);
        table.insert(self.controllers, GiftsController);
		table.insert(self.controllers, WaterDungeonController);
		table.insert(self.controllers,WingController);
        table.insert(self.controllers, ConsignmentController);
        table.insert(self.controllers, LSController);
        table.insert(self.controllers,WaBaoController);
        table.insert(self.controllers, RandomQuestController);
		table.insert(self.controllers, ZhuoyueGuideController);
		table.insert(self.controllers, ChargesController);
        table.insert(self.controllers, WeekSignController);
        table.insert(self.controllers, ChristmasController);
        table.insert(self.controllers, QihooQuickController);
        table.insert(self.controllers, UnionBossController);
		table.insert(self.controllers, UnionDiGongController);
		table.insert(self.controllers, DiGongFlagController);
		table.insert(self.controllers, CrossFightController);
		table.insert(self.controllers, VipController);
        table.insert(self.controllers, HomesteadController);
        table.insert(self.controllers, WeishiController);
		table.insert(self.controllers, InterServicePvpController);
        table.insert(self.controllers, ZhuanContoller);
		table.insert(self.controllers, OperactivitiesController);
		table.insert(self.controllers, GMController);
        table.insert(self.controllers, TrapController);
        table.insert(self.controllers, PortalController);
        table.insert(self.controllers, ShunwangContrller);
        table.insert(self.controllers, BossMedalController);
        table.insert(self.controllers, DiGongFlagController);
		table.insert(self.controllers, InterContestController);
        table.insert(self.controllers, MarriagController);
		table.insert(self.controllers, ShenWuController);
        table.insert(self.controllers, HuncheController);
        table.insert(self.controllers, ShouHunController);
		table.insert(self.controllers, LingJueController);
		table.insert(self.controllers, MagicWeaponController);
		table.insert(self.controllers, LingQiController);
		table.insert(self.controllers, MingYuController);
		table.insert(self.controllers, ArmorController);
		------------------NEW------------------
		-----------------VENUS-----------------
		table.insert(self.controllers, FabaoController);
        table.insert(self.controllers, InterSerSceneController);
		table.insert(self.controllers, SmithingController);
        table.insert(self.controllers, FumoController)
        table.insert(self.controllers, XingtuController)
		table.insert(self.controllers, StoveController);
        table.insert(self.controllers, ZhuanZhiController)
        table.insert(self.controllers, WeatherController)
        table.insert(self.controllers, GoalController)
		table.insert(self.controllers, UpdateNoticeController)
		table.insert(self.controllers, SimDropItemController)
		table.insert(self.controllers, EditeController);
        table.insert(self.controllers, TianShenController);
        table.insert(self.controllers, TransformController);
		table.insert(self.controllers, NoOperationController);
		table.insert(self.controllers, XiuweiPoolController);
		table.insert(self.controllers, RemindFuncTipsController);
		table.insert(self.controllers, TaoFaController);
        table.insert(self.controllers, RealmController);
        table.insert(self.controllers, GodDynastyDungeonController);
		table.insert(self.controllers, AgoraController);
		table.insert(self.controllers, MakinoBattleController);
		table.insert(self.controllers, ZiZhiController);
        table.insert(self.controllers, RelicController)
        table.insert(self.controllers, NewTianshenController)
	end

    for idx, c in ipairs(self.controllers) do
        if c.Create ~= nil then
            Debug("controller name: ", c.name)
            c:Create()
        end
    end

end

function GameController:Update(e)
	if CPlayerMap.EngineUpdate then
		CPlayerMap:EngineUpdate(e);
	end
	
    if self.currentState == enNormalUpdate then
        for _, c in ipairs(self.controllers) do
            if c.Update then
                c:Update(e)
            end
        end
        return true
    end
	
	if CLoginScene.EngineUpdate then
		CLoginScene:EngineUpdate(e);
	end
	
	if self.loginState then
		if CLoginScene.Update then
			CLoginScene:Update(e)
		end
		if LoginController.Update then
			LoginController:Update(e);
		end
        return true
    end
	
    return false
end

--主角进入游戏
function GameController:EnterGame()
    GameController.currentState = enNormalUpdate
    for _, c in ipairs(self.controllers) do
        if c.OnEnterGame then
            Debug("EnterGame : ", c.name)
            c:OnEnterGame()
        end
    end
    return true
end

--进入创建角色
function GameController:EnterCreateRole()
    self.loginState = true
	if CLoginScene.OnEnterGame then
		CLoginScene:OnEnterGame()
	end
    return true
end

function GameController:ExitCreateRole()
	self.loginState = false
end

function GameController:OnChangeSceneMap()
    for _, c in ipairs(self.controllers) do
        if c.OnChangeSceneMap then
            c:OnChangeSceneMap()
        end
    end
end

function GameController:OnLeaveSceneMap()
    for _, c in ipairs(self.controllers) do
        if c.OnLeaveSceneMap then
            c:OnLeaveSceneMap()
        end
    end
end

function GameController:BeforeEnterCross()
	for _, c in ipairs(self.controllers) do
        if c.BeforeEnterCross then
            c:BeforeEnterCross()
        end
    end
end


function GameController:BeforeLineChange()
	for _,c in ipairs(self.controllers) do
		if c.BeforeLineChange then
			c:BeforeLineChange();
		end
	end
end

function GameController:OnLineChange()
    for _, c in ipairs(self.controllers) do
        if c.OnLineChange then
            c:OnLineChange()
        end
    end
end

function GameController:OnLineChangeFail()
    for _, c in ipairs(self.controllers) do
        if c.OnLineChangeFail then
            c:OnLineChangeFail()
        end
    end
end

--场景失去焦点
function GameController:SceneFocusOut()
	for _, c in ipairs(self.controllers) do
        if c.OnSceneFocusOut then
            c:OnSceneFocusOut()
        end
    end
    CPlayerControl:OnMouseOut()
end
--主角升级
function GameController:OnMainPlayerLevelup()
    for _, c in ipairs(self.controllers) do
        if c.OnMainPlayerLevelup then
            c:OnMainPlayerLevelup()
        end
    end
end
--主角换装备
function GameController:OnMainPlayerChangeEquip()
    for _, c in ipairs(self.controllers) do
        if c.OnMainPlayerChangeEquip then
            c:OnMainPlayerChangeEquip()
        end
    end
end