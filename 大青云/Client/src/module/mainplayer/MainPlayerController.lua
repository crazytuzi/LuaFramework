
--玩家系统类似于me ，Myself
--玩家系统被创建的时候，游戏已经进入主状态，主要是第一个场景的创建
_G.classlist['MainPlayerController'] = 'MainPlayerController'
_G.MainPlayerController = setmetatable({},{__index = IController});
MainPlayerController.objName = 'MainPlayerController'

CPlayerControl:AddPickListen(MainPlayerController);
MainPlayerController.bCanUse = true;--开启鼠标拾取
MainPlayerController.name = "MainPlayerController"

MainPlayerController.isSelfNameShow = true;--是否显示自己的名字
MainPlayerController.isSelfCardShow = true;--是否显示自己的血条
MainPlayerController.isSelfSkipShow = true;--是否显示自己的跳字
MainPlayerController.isOtherNameShow = true;--是否显示其他人的名字
MainPlayerController.isOtherCardShow = true;--是否显示其他人的血条
MainPlayerController.isOtherSkipShow = true;--是否显示其他人的跳字
MainPlayerController.enterGameCB = {};--主玩家创建回调
MainPlayerController.lastPortalTime = 0;--上次请求传送门时间
MainPlayerController.isEnter = false;
MainPlayerController.isFristEnter = true;--是否首次登陆
MainPlayerController.laseOpTime = 0 --玩家进行上一次走路或者释放技能操作的时间
MainPlayerController.standInState = false
MainPlayerController.attackTargetTime = 0
MainPlayerController.attackTargetCid = 0
MainPlayerController.AutoMountDis = 200--自动上坐骑距离
MainPlayerController.AutoMountDelayTime = 2000--自动上坐骑时间
MainPlayerController.petLastPickTime = 0 --宠物自动拾取时间
MainPlayerController.isInterServer = false;--全局跨服状态

function MainPlayerController:OnShowMeInfo(msg)
    local info = {};
	info.dwRoleID = msg.roleID;
	info.szRoleName = msg.roleName;
	info.dwFashionsHead = msg.fashionshead;
	info.dwFashionsDress = msg.fashionsdress;
	info.dwFashionsArms = msg.fashionsarms;
	info.dwProf = msg.prof;
	info.dwIconID = msg.icon;
	info.dwDress = msg.dress;
	info.dwArms = msg.arms;
	info.dwShoulder = msg.shoulder;
	info.dwSex = msg.sex;
    info.dwHorseID = 0
	info.dwwuhun = msg.wuhun
	info.magicWeapon = msg.shenbin
	info.dwfaction = msg.dwfact
	info.roleCamp = msg.faction
	info.roleRealm = msg.realm
	info.lovelypet = msg.actpet
	info.dwWing = msg.wing
	info.suitflag = msg.suitflag
	info.footprints = msg.footprints
	info.shenwuId = msg.shenwuId
	info.zhuanZhiLv = msg.zhuanshenglv or 0
	info.xuanBingId = msg.xuanbing or 0;
	info.lingQi = msg.lingqi
	info.mingYu = msg.mingyu
	MainPlayerModel.sMeShowInfo = info;
	MainPlayerModel.sMePlayerInfo = nil
    MainPlayerModel.mainRoleID = info.dwRoleID;
end

---
--收到进入场景协议
---
function MainPlayerController:OnEnterGameMsg(msg)
	CPlayerMap.currLine = msg.lineID;
	MapController:OnEnterGameMsg(msg.mapID)
	SetServerSTime(msg.serverSTime)
	SetMergeSTime(msg.MergeSTime)
	local type = msg.type; --0:登录游戏 1:切场景
	if type == 0 then
		LogManager:Send(140);
		UILoadingScene:Open(true);
		 if LoginModel.isPlayBornStory then
	    	UICreateRole:Hide();
	    end
		UILoginWait:Hide();
		CLoginScene:Clear()
		local flag = {false,false,false};
		local checkFunc = function()
			if flag[1] and flag[2] and flag[3] then
				LogManager:Send(150);
				--主界面UI预加载
				MainMenuController:Preload();
				--剧情UI预加载进内存
				if MainPlayerModel.humanDetailInfo.eaLevel <= 10 then
					UIStory:Open()
					UIStory:Hide()
				end
				GameController:EnterGame()  --- trigger all module enter game
				self:DoEnterGame();
			end
		end
		--加载场景
		CPlayerMap:OnEnterGameResult(msg,function()
			flag[1] = true;
			checkFunc();
		end);
		--加载二包
		UILoaderManager:LoadGroup("pack2",false,function()
			flag[2] = true;
			checkFunc();
		end);
		--加载职业二包
		local profPack = "prof" .. MainPlayerModel.sMeShowInfo.dwProf;
		UILoaderManager:LoadGroup(profPack,false,function()
			flag[3] = true;
			checkFunc();
		end);
	elseif type == 1 then
		-- UILoadingScene:getMapId(msg.mapID);
		UILoadingScene:Open(false);
		CPlayerMap:ExecChangeMap(msg.result, msg)
	end
	CControlBase:SetControlDisable(true);
end

--请求进入游戏
function MainPlayerController:DoEnterGame()
	--进入游戏回调
	for i,callback in ipairs(MainPlayerController.enterGameCB) do
		callback();
	end
	MainPlayerController.enterGameCB = {};
	--进入完成，获取其他玩家,Monster,Npc
	local reqSceneEnterMsg = ReqSceneEnterSceneMsg:new();
	reqSceneEnterMsg.initGame = 0;
	MsgManager:Send(reqSceneEnterMsg);
	--显示主UI
	MainMenuController:ShowMainMenu();
	--登录初始化检测功能消息球提醒
	RemindController:CheckShow();
	--启动其他
	QuestController:UnlockCurrentMapJiguan()
	--预加载三包
	if MainPlayerModel.humanDetailInfo.eaLevel == 1 then
		TimerManager:RegisterTimer(function()
			UILoaderManager:LoadGroup("v_home_xiqi02",true);
		end,10000,1);
	end
	--UIEffect延时加载,避开加载高峰
	if MainPlayerModel.humanDetailInfo.eaLevel >= 10 then
		UILoaderManager:LoadGroup("uieffect",true);
	else
		TimerManager:RegisterTimer(function()
			--加载必要UI特效包
			UILoaderManager:LoadGroup("uieffect",true);
		end,600000,1);
	end
	--自动微端
	if MainPlayerModel.humanDetailInfo.eaLevel >= 32 then
		LoginController:NoticeMClient();
	end
end

---服务器回应主角进入场景
function MainPlayerController:OnEnterSceneResult(msg)
	if not StoryController:IsStorying() then
		CControlBase:SetControlDisable(false);
	end
	
	UILoadingScene:Hide();
	self.lastPortalTime = 0;
	--第一次进入播放剧情

	MainPlayerController.isEnter = true;		--暂时屏蔽序言导致自动战斗进不去
   -- 帮派
    UnionController:CheckChatGuildNotice();
    
	if self.isFristEnter then
		ActivityController:SendActivityOnLineTime(ActivityConsts.T_DaBaoMiJing)
		self.isFristEnter = false
	end

	-- if not self.isFristEnter then--暂时屏蔽序言
	-- 	MainPlayerController.isEnter = true;
	-- 	self.isFristEnter = false;
	-- 	MainPlayerController:ResetAutoSitTime();
	-- 	--检查是否假兵魂
	-- 	QuestController:CheckSpecialBingHun();
	-- 	UnionController:CheckChatGuildNotice();
	-- 	--
	-- 	local cfg = ConfigManager:GetRoleCfg();
	-- 	if (not cfg.isBornStoryPlayed or LoginModel.isPlayBornStory) and MainPlayerModel.humanDetailInfo.eaLevel == 1 then 
	-- 		StoryController:StoryStartMsg('profq100000', function()
	-- 			QuestGuideManager:RecoverGuide();
	-- 			-- StoryController:ShowStoryDialog(15)
	-- 		end,false,false)
	-- 		cfg.isBornStoryPlayed = true;
	-- 		ConfigManager:Save();
	-- 		LoginModel.isCreateRole = false
	-- 	end
	-- 	Version:OnEnterGame();
	-- end
	Version:DuoWanChangeScene();
	ShampublicityModel:Out()
end
local vecTar = _Vector3.new()
local bUseCanTo = false
function MainPlayerController:OnMoveToResult(value)
    --Debug("OnMoveToResult: result", value.result, value.dirX, value.dirY)
    local ret = value.result;
    if ret ~= 0 then return end;
    local objSelf = self:GetPlayer();
    local fSpeed =  MainPlayerModel.speed and MainPlayerModel.speed or _G.fSpeed; -- onObjAttrInfoNotify
    vecTar.x = value.dirX;
    vecTar.y = value.dirY;
    bUseCanTo = value.useCanTo
    --objSelf:GetAvatar():DoMoveTo(vecTar,CPlayerControl.MoveCamplete,bUseCanTo,fSpeed);--注释掉,不依赖server
end;


function MainPlayerController:OnMoveStopResult(value)
	--Debug("OnMoveStopResult: result", value.result, value.stopX, value.stopY)
    local objSelf = self:GetPlayer();
    vecTar.x = value.stopX; vecTar.y = value.stopY;
    local avt = objSelf:GetAvatar()
    if avt.moveState == true then
        --assert(false) --we shouldnot run here
        --avt:DoStopMove(vecTar, value.dir) --注释掉，不依赖server
    end
end;

function MainPlayerController:OnGetRoleResult(msg)
    local result = msg.result
    local count = msg.count   --玩家数量
end

function MainPlayerController:OnTriggerStaticObjResult(msg)
    local result = msg.result;
    local cID = msg.cID;
    CPlayerMap.changePosState = false
	if msg.jiguan >0 then
		if msg.result == 0 then
		else
			CPlayerMap:GimmickReset(msg.jiguan);
		end
	else
		if msg.result == -1 then
			self.lastPortalTime = self.lastPortalTime - 4;
		elseif msg.result == 0 then
			local id = CPlayerMap:GetPortalByCid(cID)
			local portalVo = t_portal[id]
			if portalVo and portalVo.type == 4 then
				self.lastPortalTime = 0
				if not _rd.screenBlender then _rd.screenBlender = _Blender.new(); end
				_rd.screenBlender:fade(0, 1, 0, toint(500))
				CPlayerControl:OnAreaTelport();
			end
			-- 地图主玩家图标同步
			MapController:OnPosChange( self:GetPlayer(), self:GetPos() );
		elseif msg.result == -2 then

		elseif msg.result == -3 then
		elseif msg.result == -4 then
			FloatManager:AddCenter(StrConfig['skill10000001'])
		end
	end
	
end



function MainPlayerController:OnOpenPortalResult(value)
    --
    local curMapInfo = CPlayerMap.curMapInfo;
    --
    --TriggerSelectMapCmd:create():execute()
    --local msg = ReqTriggerSelectMapMsg:new()
    --msg.cID = 1;
    --msg.mapID = 1;
    --MsgManager:send(msg)
end

function MainPlayerController:ReqChangeLine(line)
	if line == CPlayerMap:GetCurLineID() then
		return false;
	end
	local player = MainPlayerController:GetPlayer()
	if player:IsDead() then
		return false
	end
	if ActivityController:InActivity() then
		FloatManager:AddCenter(StrConfig['mainmenu001']);
		return false;
	end
	if CPlayerMap:GetCurrMapIsChangeLine() == false then
		FloatManager:AddCenter(StrConfig['mainmenu002'])
		return false
	end
	GameController:BeforeLineChange();
	MainPlayerController:StopMove()
	CPlayerMap.changeLineState = true
	local msg = ReqSwitchLineMsg:new()
	msg.lineID = line;
	MsgManager:Send(msg);
	return true;
end

function MainPlayerController:OnSwitchLineRet(msg)
    local ret = msg.result;
    local lineID = msg.lineID
    CPlayerMap.changeLineState = false
    if ret == 0 then
        CPlayerMap:SetCurLineID(lineID)
        CPlayerMap:ClearPortalPfx()
        MonsterController:ClearMonster()
        CollectionController:ClearCollection()
		MainPlayerController:ClearPlayerState()
		MainPlayerController:GetPlayer():InitBuffInfo()
		MainPlayerController:GetPlayer():InitStateInfo()
		GameController:OnLineChange()
    else
        local t = {[-1]  = StrConfig['mainmenu004'], 
					[-2] = StrConfig['mainmenu005'], 
					[-3] = StrConfig['mainmenu006'], 
					[-4] = StrConfig['mainmenu007'], 
					[-5] = StrConfig['mainmenu008'],
					[-6] = StrConfig['mainmenu009'] }
		if t[ret] then
        	FloatManager:AddCenter(t[ret]);
		end
		GameController:OnLineChangeFail();
    end
    self:sendNotification(NotifyConsts.SceneLineChanged,{ret = ret})
end

function MainPlayerController:OnLineListRet(value)
    local list = {}
    for i, lineVo in ipairs(value.lineList) do
        Debug("###lineID ", lineVo.lineID)
        table.insert(list, lineVo.lineID)
    end
    MainPlayerModel.lines = list;
    self:sendNotification(NotifyConsts.SceneLineChanged)
end
---空气墙事件
function MainPlayerController:OnDungeonBlock(msg)
	local enable = msg.enable;
	local flag = (enable == 1) and true or false;
	local blockname = msg.blockname;
	local jiguan = CPlayerMap.objSceneMap:GetJiguan(blockname);
	if jiguan and jiguan>0 then
		if not CPlayerMap:PlayGimmickById(jiguan,flag) then
			CPlayerMap.objSceneMap:SwitchAirWall(blockname, flag)
			CPlayerMap.objSceneMap:PlayTriggerAnima(blockname, flag)
		end
	else
		CPlayerMap.objSceneMap:SwitchAirWall(blockname, flag)
		CPlayerMap.objSceneMap:PlayTriggerAnima(blockname, flag)
		if msg.music and msg.music > 0 then
			SoundManager:PlaySkillSfx(msg.music)
		end
	end

end

function MainPlayerController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_SCENE_ENTER_GAME,self,self.OnEnterGameMsg);
	MsgManager:RegisterCallBack(MsgType.SC_SCENE_ENTER_SCENE_RET,self,self.OnEnterSceneResult);
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_MOVE_TO_RET,self,self.OnMoveToResult);
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_MOVE_STOP_RET,self,self.OnMoveStopResult);
	MsgManager:RegisterCallBack(MsgType.SC_SCENE_SHOW_ME_INFO,self,self.OnShowMeInfo);
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_GET_ROLE_RET,self,self.OnGetRoleResult);
    MsgManager:RegisterCallBack(MsgType.SC_TriggerObjectResult,self,self.OnTriggerStaticObjResult);
    MsgManager:RegisterCallBack(MsgType.SC_OpenPortal,self,self.OnOpenPortalResult);   --服务器通知客户端打开传送门
	MsgManager:RegisterCallBack(MsgType.SC_Revive,self,self.OnRevive);
    MsgManager:RegisterCallBack(MsgType.WC_SwitchLineRet,self,self.OnSwitchLineRet);
    MsgManager:RegisterCallBack(MsgType.WC_LineListRet,self,self.OnLineListRet);
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_PLAYER_SHOW_CHANGE,self,self.OnPlayerShowChange)   --玩家形象(状态)改变
    MsgManager:RegisterCallBack(MsgType.SC_DungeonBlock,self,self.OnDungeonBlock)
    MsgManager:RegisterCallBack(MsgType.SC_BackHomeResult,self,self.OnBackHomeRes)
    MsgManager:RegisterCallBack(MsgType.SC_UnitBitInfo,self,self.OnUnitBitInfo)
    MsgManager:RegisterCallBack(MsgType.SC_AcrossDayInform,self,self.OnAcrossDay)	
	MsgManager:RegisterCallBack(MsgType.SC_ChangePlayerName,self,self.OnChangePlayerName)
	-- MsgManager:RegisterCallBack(MsgType.SC_FireworkInfo, self, self.OnFirework)
	
    --注册接口
	if not CPlayerControl:Create() then
        Debug("MainPlayerController CPlayerControl:Create() failed")
		return false;
	end; 
	if not CPlayerMap:Create() then
        Debug("MainPlayerController CPlayerMap:Create() failed")
		return false;
	end;
	-- if not MapController:Create() then
	-- 	Debug("MainPlayerController MapController:Create() failed")
 --        return false;
	-- end;
	
	self.isSelfNameShow = true;--是否显示自己的名字
	self.isSelfCardShow = true;--是否显示自己的血条
	self.isSelfSkipShow = true;--是否显示自己的跳字
	self.isOtherNameShow = true;--是否显示其他人的名字
	self.isOtherCardShow = true;--是否显示其他人的血条
	self.isOtherSkipShow = true;--是否显示其他人的跳字
	
	self.isLoading = true;--当前是否没有加载完成
	
	return true;
end;
-- 回城
function MainPlayerController:OnBackHomeRes(msg)
	local result = msg.result;
	if result == 0 then 
		-- 成功。计时器
		MainPlayerModel:SetCurBackHomeCD(msg.time)
	elseif result == 1 then 
		-- cd 未结，束
		FloatManager:AddCenter(StrConfig['backHome001']);
	elseif result == 2 then 
		--非传送场景
		FloatManager:AddCenter(StrConfig['backHome002']);
	elseif result == 3 then 
		-- 当前是pk状态
		FloatManager:AddCenter(StrConfig['backHome003']);
	elseif result == 5 then 
		-- 在主城
		FloatManager:AddCenter(StrConfig['backHome004']);
	end;
end;
function MainPlayerController:OnBackHome()
	if not MainPlayerController:IsCanTeleport() then
		FloatManager:AddNormal( StrConfig["map216"] )
		return
	end
	MainPlayerController:ClearPlayerState()
	local msg = ReqBackHomeMsg:new();
	msg.mapid = 11000010;
	MsgManager:Send(msg)
end;

function MainPlayerController:OnUnitBitInfo(msg)
	local ubit = msg.buff
	local player = MainPlayerController:GetPlayer()
	player:SetUbit(ubit)
end

function MainPlayerController:Update(dwInterval)
    CPlayerControl:Update(dwInterval);
	CPlayerMap:Update(dwInterval);
	MainPlayerController:AutoSit()
	MainPlayerController:SetSafeArea()
	self:CheckSitArea()
	SceneRoute:UpdateRoute()
	self:CheckAutoRide(dwInterval)
	MainPlayerController:PetAutoPickUp()
	return true;
end; 


function MainPlayerController:Destroy()
	CPlayerControl:Destroy();
	CPlayerMap:Destroy();
end;

-- 处理pcik回调
-- 1玩家，2npc 3怪物,4物品...
function MainPlayerController:OnBtnPick(dwBtnID, dwType, objEntity)
    if dwType == enEntType.eEntType_Player then
    	local cid = objEntity:GetRoleID()
    	if cid ~= MainPlayerController:GetRoleID()
    		and not objEntity:IsPickNull() then
    		return
    	end
    	SkillController:ClickLockChar(cid)
		local completeFuc = function()
			-- dosth
		end
		local selfPlayer = MainPlayerController:GetPlayer();
		local selfPos = selfPlayer:GetPos();
		local playerPos = objEntity:GetPos();
		local dis = GetDistanceTwoPoint(selfPos, playerPos);
		local interactiveDis = 20;
		if MainPlayerController:PlayerIsAttack(cid) ~= 0 then
			if dis < interactiveDis then
				completeFuc()
			else
				if dwBtnID == 1 then
					NpcController:RunToTargetNpc(objEntity, interactiveDis/2, completeFuc)
				end;
			end
		else
			AutoBattleController:DoNormalAttack(dwBtnID)
		end
    end
end


function MainPlayerController:OnChangeSceneMap(dwMapID)
	self:DoCSceneAutoRun();
	--加载优化,主城
	if CPlayerMap:GetCurMapID() == 10200001 then
		UILoaderManager:LoadGroup("zc_with1");
		TimerManager:RegisterTimer(function()
			UILoaderManager:LoadGroup("zc_with2");
		end,15000,1);
		TimerManager:RegisterTimer(function()
			UILoaderManager:LoadGroup("zc_with3");
		end,30000,1);
	end
end;

function MainPlayerController:OnLeaveSceneMap()
	self.rampageState = 0
	-- MainPlayerController:ResetScale()
end

function MainPlayerController:OnLineChange()
	self.rampageState = 0
	-- MainPlayerController:ResetScale()
end

-- 创建主玩家
function MainPlayerController:CreatePlayer()
	Debug("#########################@@@@@@@@@@@@ MainPlayerController:CreatePlayer")
    local sMeInfo = MainPlayerModel.sMeShowInfo;

	self.objPlayer = CPlayer:new(sMeInfo.dwRoleID);
	self.objPlayer:Create(sMeInfo, nil)

	if MainPlayerModel.sMePlayerInfo then
		self.objPlayer:UpdatePlayerInfo(MainPlayerModel.sMePlayerInfo)
	end

	local objAvatar = self.objPlayer:GetAvatar();
	objAvatar.dwRotTime = 150;
	objAvatar.objSkeleton:ignoreShake(false);
	objAvatar.pickFlag = enPickFlag.EPF_Null  --不让点选
	objAvatar.dnotDelete = true --切换地图是不删除
	return true;
end;

--添加主玩家创建回调
function MainPlayerController:AddEnterGameCB(func)
	for i,callback in ipairs(self.enterGameCB) do
		if callback == func then
			return;
		end
	end
	table.push(self.enterGameCB,func);
end

--是否进入游戏
function MainPlayerController:IsEnterGame()
	return self.isEnter;
end

function MainPlayerController:OnEnterGame()
    -- local sMeInfo = MainPlayerModel.sMeShowInfo;
    -- local mePos = self.objPlayer:GetPos();--获取自己的位置
    -- local playerAvatar = self.objPlayer:GetAvatar();
    -- self.objPlayer:GetAvatar():StopAllPfx();
    Debug("MainPlayerController OnEnterGame============",self.objPlayer:GetRoleID(), self:GetRoleID())
end


--得到主玩家
function MainPlayerController:GetPlayer()
	--Debug("MainPlayerController:GetPlayer: ", self.objPlayer)
    return self.objPlayer;
end;

--获取当前地图id
function MainPlayerController:GetMapId()
	return CPlayerMap:GetCurMapID();
end

--得到主玩家的位置
function MainPlayerController:GetPos()
    if self.objPlayer == nil then return nil end
	return self.objPlayer:GetPos();
end;

--得到主玩家的ID
function MainPlayerController:GetRoleID()
	--return CSelectRoleState.dwCurRoleID; --stefan
	if not MainPlayerModel.sMeShowInfo then return "" end
	
    local sMeInfo = MainPlayerModel.sMeShowInfo;
    return sMeInfo.dwRoleID
end;

--玩家形象改变
function MainPlayerController:OnPlayerShowChange(msg)
	local mplayer = CPlayerMap:GetPlayer(msg.roleID)  --得到地图上的玩家
	if not mplayer then
		Debug('Error:玩家形象改变.没有找到玩家,roleID=' .. msg.roleID);
		return;
	end
	if msg.type == 1
		or msg.type == 2
		or msg.type == 3
		or msg.type == 4
		or msg.type == 11 
		or msg.type == 12 
		or msg.type == 13 
		or msg.type == 19
		or msg.type == 28
		or msg.type == 31 
		or msg.type == 35 then --装备改变

		local key = nil;
		if msg.type == 3 then--衣服
			key = "dwDress";
		elseif msg.type == 4 then--武器
			key = "dwArms";
		elseif msg.type == 11 then--时装头
			key = "dwFashionsHead";
		elseif msg.type == 12 then--时装衣服
			key = "dwFashionsDress";
		elseif msg.type == 13 then--时装武器
			key = "dwFashionsArms";
		elseif msg.type == 19 then --翅膀
			key = "dwWing";
		elseif msg.type == 28 then --套装
			key = "suitflag";
		elseif msg.type == 31 then -- 神武
			key = "shenwuId";
		elseif msg.type == 35 then --肩甲
			key = "dwShoulder";
		end
		if not key then return; end
		if msg.type == 4 then
			if msg.newVal ~= 0 then
				SpiritsUtil:SetWuhunWeaponPfx(msg.roleID) --武魂武器处理
			else
				SpiritsUtil:RemoveWuhunWeaponPfx(msg.roleID)
			end
		elseif msg.type == 28 then
			mplayer:SetEquipGroup(msg.newVal)
		elseif msg.type == 31 then
			mplayer:SetShenwuId(msg.newVal)
		end

		CPlayerMap:OnPlayerEquipChange(msg.roleID, key, msg.newVal);
		if msg.roleID == self:GetRoleID() then
			MainPlayerModel.sMeShowInfo[key] = msg.newVal;
			self:sendNotification(NotifyConsts.PlayerModelChange);
		end

	elseif msg.type == 5 then--武魂改变
		local oldWuHun = mplayer:GetWuhun();
		mplayer:SetWuhun(msg.newVal)
		SpiritsUtil:RemoveWuhunPfx(msg.roleID, oldWuHun, mplayer:GetAvatar(),mplayer:GetPlayerInfoByType(enAttrType.eaProf));
		if msg.newVal ~= 0 then
			SpiritsUtil:SetWuhunPfx(msg.roleID, msg.newVal, mplayer:GetAvatar(),mplayer:GetPlayerInfoByType(enAttrType.eaProf));
			--if msg.roleID ~= MainPlayerController:GetRoleID() then
				--mplayer:PlayHeti()
			--end
		end
	elseif msg.type == 6 then--坐骑改变
		local horseId = MountUtil:GetModelIdByLevel(msg.newVal,mplayer:GetPlayerInfoByType(enAttrType.eaProf));
		CPlayerMap:OnPlayerMountChange(msg.roleID,horseId);
	elseif msg.type == 7 then--打坐状态改变
		local sitIndex = bit.rshift(msg.newVal, 30)
		local sitId = bit.lshift(msg.newVal, 2)
		sitId = bit.rshift(sitId, 2)
		mplayer:SetSitState(sitId, sitIndex)
	elseif msg.type == 8 then -- 更换称号
		mplayer:SetTitleInfo(msg.newVal)
	elseif msg.type == 9 then -- 删除称号
		mplayer:SetDeleteTitleInfo(msg.newVal)
	elseif msg.type == 10 then --更改PK状态
		mplayer:SetPKState(msg.newVal)
	elseif msg.type == 14 then --更改神兵
		mplayer:SetMagicWeapon(msg.newVal);
	elseif msg.type == 15 then --阵营属性
		mplayer:SetCamp(msg.newVal);
	elseif msg.type == 16 then --灵值发生改变
		mplayer:SetLingZhi(msg.newVal);
	elseif msg.type == 17 then
		mplayer:SetRealm(msg.newVal)
	elseif msg.type == 18 then --萌宠
		local lovelypet = LovelyPetUtil:GetLovelyPetModelId(msg.newVal);
		mplayer:SetLovelyPet(msg.newVal)
		mplayer:SetPetModelId(lovelypet)
	elseif msg.type == 26 then --午夜PK状态
		mplayer:SetNightState(msg.newVal)
	elseif msg.type == 29 then --脚印
		mplayer:SetFootprints(msg.newVal)
	elseif msg.type == 30 then --宝箱值
		mplayer:SetTreasure(msg.newVal)
	elseif msg.type == 36 then
		mplayer:SetZhuanZhi(msg.newVal)
    elseif msg.type==37 then  --仙阶
     	--mplayer:SetPendantModelId(msg.newVal)
    elseif msg.type==38 then  --坐在桌边吃饭
    	--mplayer:UpdateShowEquip(msg.chairID,msg.chairDir)    --处理玩家坐在椅子上,椅子id，椅子方向
     	local chair = CollectionController:GetCollection(msg.chairID);
		mplayer:SitChair(chair)
     	mplayer:StartZhuoBianEat()
    elseif msg.type==39 then  --坐在地上吃饭
     	mplayer:StartLandEat()
    elseif msg.type==40 then  
     	mplayer:StopLandEat()
     	mplayer:StopZhuoBianEat()
	elseif msg.type==41 then --玄兵
		mplayer:SetXuanBingModelId(msg.newVal)
	elseif msg.type==43 then --灵器
		mplayer:SetLingQi(msg.newVal);
	elseif msg.type==44 then --玉佩
		mplayer:SetMingYu(msg.newVal);
	end
end

function MainPlayerController:IsEatOnland()
	local selfPlayer = MainPlayerController:GetPlayer()
	return selfPlayer:GetEatonLandState()
end

function MainPlayerController:IsEatOnChair()
	local selfPlayer = MainPlayerController:GetPlayer()
	return selfPlayer:GetEatonChairState()
end

local temp_dir = _Vector3.new()
local temp_target = _Vector3.new()
--自动寻路接口
--vecTarget不传跑到目标地图就停止
function MainPlayerController:DoAutoRun(mapId,vecTarget,completeFunc,completeParam,failFunc,failParam, dwDis)
	if not mapId or mapId==0 then return false; end
	local objPlayer = self:GetPlayer();
	if not objPlayer then
		Debug("objPlayer is null by MainPlayerController:DoAutoRun()");
		return false;
	end
	if objPlayer:IsDead() then
		return false;
	end
	--打断自动施法
	AutoBattleController:InterruptAutoBattle();
	--打断任务引导
	QuestGuideManager:BreakGuide();
	--
	if self.autoRunInfo then
		if self.autoRunInfo.failFunc then
			if type(self.autoRunInfo.failParam) == "table" then
				self.autoRunInfo.failFunc(unpack(self.autoRunInfo.failParam));
			else
				self.autoRunInfo.failFunc(self.autoRunInfo.failParam);
			end
		end
		self.autoRunInfo = nil;
	end
	self.autoRunInfo = {};
	self.autoRunInfo.completeFunc = completeFunc;
	self.autoRunInfo.completeParam = completeParam;
	self.autoRunInfo.failFunc = failFunc;
	self.autoRunInfo.failParam = failParam;
	self.autoRunInfo.mapId = mapId;
	if not vecTarget then
		vecTarget = MapUtils:GetMapBirthPoint(mapId);
	end
	self.autoRunInfo.vecTarget = vecTarget;
	local currMapId = CPlayerMap:GetCurMapID();
	if mapId == currMapId then --当前地图,跑
		if vecTarget then
			UIAutoRunIndicator:SetAutoRun( true );
			local rst = CPlayerControl:AutoRun(vecTarget,{func = self.WhenAutoComplete,param = self}, nil, dwDis);
			if not rst then 
				UIAutoRunIndicator:SetAutoRun(false);
				return false; 
			end
		end
	else --跨场景,找路
		self.dwDis = dwDis
		local mapPath = MapPathFinder:FindPath(currMapId,mapId);
		if not mapPath or #mapPath==0 then return false; end
		self.autoRunInfo.mapPath = mapPath;
		UIAutoRunIndicator:SetAutoRun( true );
		self:RutoToNextMap();
	end
	--[[自动上马
	if(not MountModel:isRideState() ) then
		temp_target.x = vecTarget.x
		temp_target.y = vecTarget.y
		temp_target.z = CPlayerMap:GetSceneMap():getSceneHeight(vecTarget.x, vecTarget.y)
		if temp_target.z then
			local selfPos = MainPlayerController:GetPlayer():GetPos()
			_Vector3.sub( selfPos, temp_target,temp_dir )
			local m = temp_dir:magnitude( )
			if( m > MainPlayerController.AutoMountDis ) then
				local fun = function()
					if(MainPlayerController:IsCanRide() and not MountModel:isRideState() and UIAutoRunIndicator:GetAutoRun() and MountModel:IsGetMount() ) then
						MountController:RideMount()
					end
				end
				TimerManager:RegisterTimer(fun, MainPlayerController.AutoMountDelayTime, 1)
			end
		end	
	end--]]
	return true;
end

--自动寻路中 每隔几秒就自动上马
local checkAutoRideTime = 0
function MainPlayerController:CheckAutoRide(dwInterval)
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	if not selfPlayer:GetAvatar() then
		return
	end
	if not self:IsMoveState() then
		return
	end
	if not self.autoRunInfo then
		return
	end
	if not MountModel:IsGetMount() then
		return
	end
	if MountModel:isRideState() then
		return
	end
	
	checkAutoRideTime = checkAutoRideTime + dwInterval
	if checkAutoRideTime >= MainPlayerController.AutoMountDelayTime then
		checkAutoRideTime = checkAutoRideTime - MainPlayerController.AutoMountDelayTime
		if(MainPlayerController:IsCanRide() and not MountModel:isRideState() and UIAutoRunIndicator:GetAutoRun() and MountModel:IsGetMount() ) then
			MountController:RideMount()
		end
	end	
end

--往下张地图跑
function MainPlayerController:RutoToNextMap()
	local nextMapId = self.autoRunInfo.mapPath[1];
	local currMapId = CPlayerMap:GetCurMapID();
	--找去下张地图的传送门
	local protalCfg = nil;
	if MapPoint[currMapId] and MapPoint[currMapId].portal then
		for i,cfg in pairs(MapPoint[currMapId].portal) do
			local protalCfg1 = t_portal[cfg.id];
			if protalCfg1 and protalCfg1.targetMap==tostring(nextMapId) then
				protalCfg = cfg;
				break;
			end
		end
	end
	if not protalCfg then
		print("Error:寻路错误,没有找到去下张地图的传送门.",CPlayerMap:GetCurMapID(),nextMapId);
		return;
	end
	CPlayerControl:AutoRun(_Vector3.new(protalCfg.x,protalCfg.y,0),{func = self.WhenAutoComplete,param = self});
end


--跨地图寻路
function MainPlayerController:DoCSceneAutoRun()
	if not self.autoRunInfo then return; end
	if not self.autoRunInfo.mapPath then return; end
	if self.autoRunInfo.mapPath[1] ~= CPlayerMap:GetCurMapID() then
		print("Error:寻路错误,进入场景不是下一目标场景");
		return;
	end
	table.remove(self.autoRunInfo.mapPath,1);
	if #self.autoRunInfo.mapPath > 0 then
		UIAutoRunIndicator:SetAutoRun(true);
		self:RutoToNextMap();
	else
		--到达目标场景,跑过去
		if self.autoRunInfo.vecTarget then
			UIAutoRunIndicator:SetAutoRun(true);
			CPlayerControl:AutoRun(self.autoRunInfo.vecTarget,{func = self.WhenAutoComplete,param = self}, nil, self.dwDis);
		end
	end
end;

--自动寻路通知函数
--@param bBreak 寻路是否被打断
function MainPlayerController:WhenAutoComplete(bBreak)
	if self.autoRunInfo then
		if bBreak then
			if self.autoRunInfo.failFunc then
				if type(self.autoRunInfo.failParam) == "table" then
					self.autoRunInfo.failFunc(unpack(self.autoRunInfo.failParam));
				else
					self.autoRunInfo.failFunc(self.autoRunInfo.failParam);
				end
			end
		else
			--这里应该跑到传送门了
			if self.autoRunInfo.mapPath and #self.autoRunInfo.mapPath>0 then
				return;
			end
			if self.autoRunInfo.completeFunc then
				if type(self.autoRunInfo.completeParam) == "table" then
					self.autoRunInfo.completeFunc(unpack(self.autoRunInfo.completeParam));
				else
					self.autoRunInfo.completeFunc(self.autoRunInfo.completeParam);
				end
			end
		end
		self:BreakAutoRun();
		self.autoRunInfo = nil;
	end
end

--打断自动寻路
function MainPlayerController:BreakAutoRun()
	if self.autoRunInfo then
		MainPlayerController:StopMove();
		if self.autoRunInfo.failFunc then
			if type(self.autoRunInfo.failParam) == "table" then
				self.autoRunInfo.failFunc(unpack(self.autoRunInfo.failParam));
			else
				self.autoRunInfo.failFunc(self.autoRunInfo.failParam);
			end
		end
		self.autoRunInfo = nil;
		UIAutoRunIndicator:SetAutoRun( false );
	end
end



local lastBreakRunTime = 0;
--自动寻路中,两次点击取消寻路
function MainPlayerController:TryBreakAutoRun(nButton,nXPos,nYPos)
	if not self:IsMoveState() then return false; end
	if not self.autoRunInfo then return false; end
	if nButton == 0 then
		if lastBreakRunTime==0 or GetCurTime()-lastBreakRunTime>2000 then
			lastBreakRunTime = GetCurTime();
			FloatManager:AddNormal(StrConfig['mainmenu003']);
		else
			MainPlayerController:BreakAutoRun();
			lastBreakRunTime = 0;
		end
		return true;
	end
	return false;
end


--将画面蒙灰
--isGray---->true：变灰；false：恢复正常
function MainPlayerController:MakeViewGray(isGray, time)
	if isGray then
		_rd.screenBlender = _Blender.new();
		_rd.screenBlender:gray(0,1,time);
	else
		_rd.screenBlender = nil;
	end;
end;

--震动屏幕
function MainPlayerController:DoShake(dwTime)
	_rd.camera:shake(0.01,0.05,dwTime);
end;


--设置是否显示自己的血条
function MainPlayerController:SetSelfCardShow(isShow)
	self.isSelfCardShow = isShow;
end;

--设置是否显示别人的血条
function MainPlayerController:SetOtherCardShow(isShow)
	self.isOtherCardShow = isShow;
	
	for id,objPlayer in pairs(CPlayerMap.setAllPlayer)do
		if id ~= self:GetRoleID() then
			if isShow then
			else
				if not SkillController:IsLock(objPlayer) then
				end
			end
		end
	end
end;

function MainPlayerController:SetSelfSkipShow(isShow)
	self.isSelfSkipShow = isShow;
end;

function MainPlayerController:SetOtherSkipShow(isShow)
	self.isOtherSkipShow = isShow;
end;

function MainPlayerController:addMapPortalPoint(vo)
    CPlayerMap:addMapPortalPoint(vo)
end

function MainPlayerController:AddItem(vo)
	if MainPlayerModel.allDropItem[vo.charId] then
		Debug(" add item error ~~~~~~~~~~~~~~~ " .. vo.charId)
		return
	end
    local item = DropItem:NewDropItem(vo)
	if not item then
    	Debug(" add item error ~~~~~~~~~~~~~~~ ")
    	return
    end
    if vo.born == 1 then
    	DropItemController:AddItem(vo.source, item)
    else
    	DropItemController:ShowItem(item)
    end
	if StoryController:IsStorying() then
		item:HideSelf(true);
	end
end

function MainPlayerController:RemoveItem(cid)
	DropItemController:RemoveItem(cid)
	local item = self:GetItemByCid(cid)
	if not item then
		Debug(" remove item error ~~~~~~~~~~~~~~~ " .. cid)
        return
    end
    --DropItemController:PrintItem()
	MainPlayerModel.allDropItem[cid] = nil
	item:Delete()
	item = nil
end

function MainPlayerController:GetItemList()
	return MainPlayerModel.allDropItem
end

function MainPlayerController:GetItemByCid(cid)
	return MainPlayerModel.allDropItem[cid]
end

function MainPlayerController:SendReqRevive(reviveType, moneyType)
	local msg = ReqReviveMsg:new()
	msg.reviveType = reviveType
	msg.moneyType = moneyType
	MsgManager:Send(msg)
end

function MainPlayerController:OnRevive(msg)
	local roleId = msg.roleID
	local reviveType = msg.reviveType
	local posX = msg.posX
	local posY = msg.posY
	local result = msg.result
	local player = CPlayerMap:GetPlayer(roleId)
	if not player then
		return
	end
	if roleId == MainPlayerController:GetRoleID() then --自己复活
		if result == 0 then --成功
			MainPlayerController:AddViewPfx()
			UIRevive:Hide()
			MapController:OnMainPlayerRevive()
			QuestGuideManager:WhenStop()
			MainPlayerController:ResetAutoSitTime()
			MainPlayerController:MainRoleRevive(posX, posY)
			ExtremitChallengeController:OnReviveAutoStart()
		elseif result == -3 then -- 道具不足
			FloatManager:AddCenter( StrConfig["mainmenuRevive04"] )
		elseif result == -4 then -- 金钱不足
			FloatManager:AddCenter( StrConfig["mainmenuRevive03"] )
		end
	else
		if result == 0 then
			MainPlayerController:OtherRoleRevive(roleId, posX, posY)
		end
    end
end

function MainPlayerController:MainRoleRevive(posX, posY)
	local selfPlayer = MainPlayerController:GetPlayer() 
	selfPlayer:Revive(posX, posY)
	AutoBattleController:MainPlayerRevive()
end

function MainPlayerController:OtherRoleRevive(roleId, posX, posY)
	local player = CPlayerMap:GetPlayer(roleId)
    if player then
    	player:Revive(posX, posY)
    end
end

function MainPlayerController:OnChangePos(msg)
	local roleId = msg.roleId
	local posX = msg.posX
	local posY = msg.posY
	CPlayerMap:DoChangePos(roleId, posX, posY)
end

function MainPlayerController:OnPlayerDead(value)
	local roleId = value.deadid
    local killerCid = value.killerID
    local killerName = value.killerName
    local killerType = value.killerType
    local killerLevel = value.killerLevel
    if roleId == MainPlayerController:GetRoleID() then --自己死亡
    	MainPlayerController:MainRoleDead(killerCid,killerName,killerType,killerLevel)
    else
    	MainPlayerController:OtherRoleDead(roleId, killerCid) --别人死亡
    end
end

--自己死亡的处理
function MainPlayerController:MainRoleDead(killerCid,killerName,killerType,killerLevel)
	AutoBattleController:MainPlayerDead()
    CCursorManager:DelState("battle")
    AutoBattleController:InterruptAutoBattle()
    MainPlayerController:BreakAutoRun()
	MainPlayerController:StopMove()
	local selfPlayer = MainPlayerController:GetPlayer() 
	selfPlayer:Dead()
	if self:CanShowRevive() then
		UIRevive:Open( killerCid , killerName ,killerType )
	end
	if InterServicePvpModel:GetIsInCrossBoss() or InterSerSceneModel:GetSceneIsIng() then
		UIQiZhanDungeonTip:Open(3);
	end	
    FriendController:UpdateKillTime(killerCid)
    UIBeatenAnimation:StopAnimation()
    MapController:OnMainPlayerDie()
	ActivityZhanChang:PlayerOverFalgNil()
	-- local player = CPlayerMap:GetPlayer(killerCid)
	if killerType == enEntType.eEntType_Player then
		UIMainKillRecord:OpenKillMe(killerCid,killerName,killerLevel)
	end
end

function MainPlayerController:CanShowRevive()
	if BabelController:GetIsBabel() then                    --爬塔副本界面不显示复活界面
		return false
	end
	-- if GodDynastyDungeonController:GetIsInGodDynasty() then  --在诛仙阵中不显示复活界面
	-- 	return false
	-- end
	if UnionDungeonHellModel:IsInHell() then
		return false
	end
	if InterServicePvpController:IsInPvp1() then
		return false
	end
	if QiZhanDungeonController:GetInQiZhanDungeonState() then
		--QiZhanDungeonDieTip:Show();     -- changer:houxudong date:2016/6/27 reason: 爬塔副本界面特殊处理，显示复活界面
		return true    
	end
	if DekaronDungeonController:GetInDekaronDungeonState() then
		QiZhanDungeonDieTip:Show();
		return false
	end
	return true
end

--别人的死亡处理
function MainPlayerController:OtherRoleDead(roleId, killerCid)
	local player = CPlayerMap:GetPlayer(roleId)
    if player then
    	player:Dead()
    end
	if killerCid == MainPlayerController:GetRoleID() then
		UIMainKillRecord:OpenKillOther(roleId)
	end
end

--获取普通攻击的技能ID
function MainPlayerController:GetNormalAttackSkillId()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local dwProfID = selfPlayer:GetPlayerInfoByType(enAttrType.eaProf)
	return RoleConfig.ProfConfig[dwProfID].dwSkillId
end

function MainPlayerController:GetNormalSkillIdByMoues(mouseId)
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local skill = SkillModel:GetSkillByPos(mouseId);
	if not skill then
		return
	end;
	return skill.skillId;
end

function MainPlayerController:GetNormalAttackSkillIdByProf(dwProfID)
	if not RoleConfig.ProfConfig[dwProfID] then
		return
	end
	return RoleConfig.ProfConfig[dwProfID].dwSkillId
end

function MainPlayerController:GetRollSkillId()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local dwProfID = selfPlayer:GetPlayerInfoByType(enAttrType.eaProf)
	return RoleConfig.ProfConfig[dwProfID].dwRollSkillId
end

function MainPlayerController:LevelUp()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local avatar = selfPlayer:GetAvatar()
	if avatar then
		avatar:PlayerPfx(90004)
	end
	SoundManager:PlaySkillSfx(2001)
    GameController:OnMainPlayerLevelup()

	--每次升级，检测是否有新的主宰之路副本开启
	DominateRouteModel:OnAddInitData();
end

--@param keepPath 是否保持原有路径,跨区域传送门时使用
function MainPlayerController:StopMove(keepPath)
    CPlayerControl:MoveStop(keepPath)
	if not keepPath then
		UIAutoRunIndicator:SetAutoRun(false)
	end
end

function MainPlayerController:GetProfID()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local dwProfID = selfPlayer:GetPlayerInfoByType(enAttrType.eaProf)
	return dwProfID
end

--自己受到攻击
function MainPlayerController:UnderAttack(castCid)
	MainPlayerController:ShowAttackUI()
	local char, charType = CharController:GetCharByCid(castCid)
	if charType and charType == enEntType.eEntType_Monster then
		AutoBattleController:AutoBattleUnderAttack()
	elseif charType and charType == enEntType.eEntType_Player then	
		if AutoBattleController.isAutoHang then
			--如果自己是和平模式  申请善恶 并且反击 else 直接反击
			if AutoBattleModel.autoCounter then
				if MainRolePKModel:GetPKState() == 0 then 
					MainMenuController:OnSendPkState(5);
				end
			end
		else
			if ActivityController:InActivity() then
				local activityID = ActivityController:GetCurrId();
				for i , v in pairs(MainMenuConsts.HideActivityConsts) do
					if activityID == v.id then
						return
					end
				end
			end
			if UnionWarModel:GetIsAtUnionActivity() then return end			--帮派战
			if UnionCityWarModel:GetIsAtUnionActivity() then return end		--帮派王城战
			
			local mapId =  CPlayerMap:GetCurMapID();
			for i , v in ipairs(MainMenuConsts.HideMapConsts) do
				if mapId == v.id then
					return
				end
			end
			
			if MainRolePKModel:GetPKIndex() == 0 then
				if UIMainPKSuspend:IsShow() == false then
					UIMainPKSuspend:Open(1);
				else
					UIMainPKSuspend:UpDataTime();
				end
			end
		end
		local cfg = CPlayerMap:GetPlayer(castCid);
		local name = cfg:GetName();
		local icon = cfg.icon;
		local minCfg = cfg:GetPlayerInfo();
		local level = minCfg.eaLevel;
				
		if ActivityController:InActivity() then
			local activityID = ActivityController:GetCurrId();
			for i , v in pairs(MainMenuConsts.HideActivityConsts) do
				if activityID == v.id then
					return
				end
			end
		end
		if UnionWarModel:GetIsAtUnionActivity() then return end			--帮派战
		if UnionCityWarModel:GetIsAtUnionActivity() then return end		--帮派王城战
		
		local mapId =  CPlayerMap:GetCurMapID();
		for i , v in ipairs(MainMenuConsts.HideMapConsts) do
			if mapId == v.id then
				return
			end
		end
		
		if UIMainPKCaution:IsShow() then
			self:sendNotification( NotifyConsts.NowPlayerFuckME,{name,icon} );
		else
			UIMainPKCaution:Open(name,icon,level,castCid);
		end
	end
end

function MainPlayerController:ShowAttackUI()
	if SetSystemController.hideAttackUI then
		return
	end
	if UIBeatenAnimation:IsShow() then 
		UIBeatenAnimation:onBeating()
	else
		UIBeatenAnimation:Show()
	end
end

function MainPlayerController:ChangeDir(pos)
	local selfRoleID = self:GetRoleID()
    local pos1 = self:GetPlayer():GetPos()
    local dir = GetDirTwoPoint(pos1, pos)
    CharController:OnPlayerChangeDir(selfRoleID, dir)
    self:RequsetChangeDir(dir)
end

function MainPlayerController:RequsetChangeDir(dir)
	local msg = ReqChangeDir:new()
	msg.dir = dir
	MsgManager:Send(msg)
end

-- 获得玩家的移动状态
function MainPlayerController:IsMoveState()
	local player = self:GetPlayer()
	if not player then return false end
	
	return player:IsMoveState()
end

-- 获得玩家的释放技能状态
function MainPlayerController:IsSkillPlaying()
	local player = self:GetPlayer()
	if not player then return false end
	
	return player:IsSkillPlaying()
end

--请求跨传送门(5s发一次协议)
function MainPlayerController:ReqPortalDoor(cid,tid)
	if GetServerTime() - self.lastPortalTime < 5 then
		return;
	end
	self.lastPortalTime = GetServerTime();
	if MainPlayerController:IsCanChangeMap() == false then
		print("MainPlayerController:IsCanChangeMap() == false")
		return
	end
	local questPortal = QuestModel:GetQuestPortal()
	--当前任务是传送门任务，且与当前走到的传送门相同时，走任务的传送
	if questPortal == tid then
		print("questPortal = QuestModel:GetQuestPortal()")
		return
	end 
	local cfg = t_portal[tid]
	if not cfg then
		print("cfg = t_portal[tid]")
		return
	end

	if cfg.type == 3 then--活动传送门
		if MainPlayerController:IsMoveState() then
			MainPlayerController:StopMove()
		end
		ActivityController:EnterActivity(cfg.targetActivity);
	else
		local id = CPlayerMap:GetPortalByCid(cid)
		local portalVo = t_portal[id]
		if portalVo and portalVo.type == 4 then
			CPlayerMap.changePosState = true
			if MainPlayerController:IsMoveState() then
				MainPlayerController:StopMove(true)
			end
		else
			if MainPlayerController:IsMoveState() then
				MainPlayerController:StopMove()
			end
		end
		AutoBattleController:InterruptAutoBattle()
		local msg = ReqTriggerObjMsg:new();
		msg.cID = cid;
		MsgManager:Send(msg)

		_app.console:print("req portal door")
	end
end

function MainPlayerController:CheckSitArea()
	if StoryController:IsStorying() then
		return
	end
	local isInSitArea = SitController:IsInSitArea()
	if isInSitArea ~= self.sitAreaState then
		if self.sitAreaState ~= nil then
			UISitAreaIndicator:Open( isInSitArea )
		end
		self.sitAreaState = isInSitArea
	end
end

function MainPlayerController:SetSafeArea()
	local player = self:GetPlayer()
	local safeAreaState = player:IsSafeArea()
	if safeAreaState == true and not self.safeAreaState then
		--FloatManager:AddCenter(StrConfig["skill100001"])
		UISafe:Open(1);
	elseif safeAreaState == false and self.safeAreaState then
		--FloatManager:AddCenter(StrConfig["skill100002"])
		UISafe:Open(0);
	end
	if self.safeAreaState ~= safeAreaState then
		self.safeAreaState = safeAreaState
		self:sendNotification( NotifyConsts.PkStateChange );
	end
end

function MainPlayerController:GetSafeArea()
	return self.safeAreaState and 1 or 0
end

function MainPlayerController:OnPlayerAttrChange(attrType, value, oldValue)
	
end

--获取服务器等级
function MainPlayerController:GetServerLvl()
	if _G.serverSTime == 0 then
		return 1;
	end
	local serverDay = self:GetServerOpenDay();
	local num = #t_worldlevel;
	for i,cfg in ipairs(t_worldlevel) do
		if serverDay <= cfg.days then
			num = i;
		else
			break;
		end
	end
	return num;
end

--获取当前是开服第几天
function MainPlayerController:GetServerOpenDay()
	if _G.serverSTime == 0 then
		return 0;
	end
	local serverSTimeLocal = GetZeroTime(_G.serverSTime);--开服的0点
	local currTime = GetServerTime();
	return toint((currTime-serverSTimeLocal)/86400,1);
end

--跨天刷新
function MainPlayerController:OnAcrossDay(msg)
	--10s
	TimerManager:RegisterTimer(function()
		self:sendNotification(NotifyConsts.AcrossDayInform);
	end, 10000, 1)
end;

function MainPlayerController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function MainPlayerController:OnRollOut(type, node)
	self:OnMouseOut(node)
end

function MainPlayerController:OnMouseOver(node)
	if node == nil then
		return
	end
    local cid = node.dwRoleID
    if cid == self:GetRoleID() then
    	return
    end
	local player = CPlayerMap:GetPlayer(cid)
	if player and player:IsPickNull() then
		player.showHp = true
		if MainPlayerController:PlayerIsAttack(cid) == 0 then
			CCursorManager:AddStateOnChar("battle", cid)
		end
	end
end

function MainPlayerController:OnMouseOut(node)
	if node == nil then
		return
	end
    local cid = node.dwRoleID
    if cid == self:GetRoleID() then
    	return
    end
	local player = CPlayerMap:GetPlayer(cid)
	if player and player:IsPickNull() then
		player.showHp = false
		CCursorManager:DelState("battle")
	end
end



--获取此人物是否可攻击  缺少自定义机制 需要补充：是否同帮派
--												 是否同服
--												 是否同阵营
--												 自定义 结盟 敌对帮派
function MainPlayerController:PlayerIsAttack(roleID)
	local player = CPlayerMap:GetPlayer(roleID)
	if not player then
		return 0
	end
	
	if not CPlayerMap:GetCurrMapIsPk() then
		return 101;
	end

	-- if MainPlayerController:GetSafeArea() == 1 then
	-- 	return 101;
	-- end

	if player:IsSafeArea() == true then
		return 101
	end

	if player.pkState == 1 or player.pkState == 4 or player:GetNightState() then --判断是否是PK保护或新手保护 直接跳出
		return 102;
	end
	
	if MainRolePKModel:GetPKIndex() == 0 then 
		return 103;
	elseif MainRolePKModel:GetPKIndex() == 1 then --队伍
		if TeamModel:IsTeammate(roleID) then
			return 103;
		end
	elseif MainRolePKModel:GetPKIndex() == 2 then --同帮派
		if UnionModel.MyUnionInfo.guildId ~= player.guildId then
			return 0;
		end
		return 103
	elseif MainRolePKModel:GetPKIndex() == 3 then --本服务器玩家
		local selfServerId = InterServicePvpModel:GetGroupId()
		local otherServerId = player:GetServerId()
		if selfServerId ~= 0 then
			if selfServerId == otherServerId then
				return 103
			end
		end
	elseif MainRolePKModel:GetPKIndex() == 4 then --同阵营
		if player:GetCamp() == self:GetPlayer():GetCamp() then
			return 103;
		end
	elseif MainRolePKModel:GetPKIndex() == 5 then --善恶
		if player.pkState == 2 or player.pkState == 3 then
			return 0;
		end
		return 103;
	elseif MainRolePKModel:GetPKIndex() == 6 then --全体
		if player.pkState == 1 or player.pkState == 4 then
			return 103
		end
	elseif MainRolePKModel:GetPKIndex() == 7 then --自定义 暂时全部可攻击
		if MainRolePKModel.PKData[1].pkBoolean then 
			if player.guildId == '0_0' then
				return 0;
			end
			if UnionModel.MyUnionInfo.guildId == player.guildId then
				return 103
			end
		end
		if MainRolePKModel.PKData[2].pkBoolean then
			if player.guildId == '0_0' or UnionModel.MyUnionInfo.alianceGuildId ~= player.guildId then
				return 0
			end
			return 103
		end
		if MainRolePKModel.PKData[3].pkBoolean then-- 敌对帮派
			
		end
		if MainRolePKModel.PKData[4].pkBoolean then
			if TeamModel:IsTeammate(roleID) then
				return 103;
			end
		end
		if MainRolePKModel.PKData[5].pkBoolean then
			if player.pkState == 2 then
				return 103;
			end
		end
		if MainRolePKModel.PKData[6].pkBoolean then
			if player.pkState == 3 then
				return 103
			end
		end
	end
	return 0
end

function MainPlayerController:GetMoveMusic()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return 0
	end
	local dwProfID = selfPlayer:GetPlayerInfoByType(enAttrType.eaProf)
	local horse = selfPlayer:GetAvatar():GetHorse()
	local musicId = 0
	if horse then
		musicId = horse:GetMoveMusic()
	else
		musicId = RoleConfig.ProfConfig[dwProfID].moveMusic
	end
	return musicId
end

function MainPlayerController:ClearPlayerState()
	MainPlayerController:StopMove()
	AutoBattleController:InterruptAutoBattle()
	UIMainXuLiProgress:End(0)
	UIMainSkill:HideSkillQuickClick()
	UIMainLianXuDaJiProgress:Hide()
	local selfPlayer = self:GetPlayer()
	selfPlayer.isSitAreaPfx = nil
	selfPlayer.stateMachine:changeState(IdleState:new(selfPlayer))
	selfPlayer:ClearTarget()
	SkillController:ClearTarget()
	--selfPlayer:InitStateInfo()
	local avatar = selfPlayer:GetAvatar()
	avatar:StopAllPfx()
	avatar:StopAllAction()
	avatar:ExecIdleAction()
	avatar.chanState = ChanSkillState.StateInit
	avatar.prepState = 0
	avatar.jumpState = false
	avatar.flyState = false
	avatar.rollState = false
	avatar.knockBackState = false
	avatar.stoneGazeState = false
	avatar.skillPlaying = false
	avatar.setSkipNormal = {}
	SkillController.comboing = false
	--SkillController.stiffTime = 0
	SkillController.PrepState = false
	SkillController.CollectState = false
	MountController.ridingState = false
	SitController.ReqSitState = false
	CPlayerMap.bChangeMaping = false
	CPlayerMap.changePosState = false
	CPlayerMap.changeLineState = false
	CPlayerMap.teleportState = false
	CCursorManager:ClearState()
	selfPlayer:ResetPfx()
	selfPlayer:ClearTimePlan()
	selfPlayer:SetBattleState(false)
	selfPlayer.sitState = nil
end

function MainPlayerController:AutoSit()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local nowTime = GetCurTime()
	if not selfPlayer.autoSitTime then
		return;
	end
	if MainPlayerController:IsCanSit() == false 
		or selfPlayer:IsMoveState()
		or AutoBattleController:GetAutoHang() then
		selfPlayer.autoSitTime = nowTime
		return
	end
	if nowTime - selfPlayer.autoSitTime > SitConsts.AutoSitTime then
		SitController:ReqSit(nil, nil, true)
		selfPlayer.autoSitTime = nil;
	end
end

--重置自动打坐计时
function MainPlayerController:ResetAutoSitTime()
	local selfPlayer = self:GetPlayer();
	if not selfPlayer then
		return
	end
	selfPlayer.autoSitTime = GetCurTime();
end
--添加复活特效
function MainPlayerController:AddViewPfx()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local avatar = selfPlayer:GetAvatar()
	if avatar then
		avatar:PlayerPfx(100000001)
	end
end

--清除自动
function MainPlayerController:ClearAutoSitTime()
	local selfPlayer = self:GetPlayer();
	if not selfPlayer then
		return
	end
	selfPlayer.autoSitTime = nil;
end

function MainPlayerController:IsCanSit()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return false
	end
	if self:IsSpecialState() == false then
		return false
	end
	if CPlayerMap:GetCurrMapIsSit() == false then
		return false
	end
	if selfPlayer:IsSitState() then
		return false
	end
    if InterServicePvpController:IsInPvp1() then
    	return false
    end
	if MountController.ridingState == true then
        return false
    end
	if SitController.ReqSitState == true then
		return false
	end
	if HuncheController.followerGuid
		and HuncheController.followerGuid ~= "0_0" then
    	return false
    end

	return true
end

function MainPlayerController:IsCanRide()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return false
	end
	if self:IsSpecialState() == false then
		return false
	end
	if CPlayerMap:GetCurrMapIsRide() == false then
		return false
	end
	if MountController.ridingState == true then
        return false
    end
	if SitController.ReqSitState == true then
		return false
	end
	return true
end

function MainPlayerController:IsCanChangeMap()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return false
	end
	if self:IsSpecialState() == false then
		return false
	end
	if SitController.ReqSitState == true then
		return false
	end
	if MountController.ridingState == true then
        return false
    end
    return true
end

function MainPlayerController:IsCanCollect(collection)
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return false
	end
	if self:IsSpecialState() == false then
		return false
	end
	if SitController.ReqSitState == true then
		return false
	end
	if MountController.ridingState == true then
        return false
    end
    if ActivityLunchModel:CheckCanCollect(collection) == false then
		return false
	end
    return true
end

function MainPlayerController:GetDir()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return 0
	end
	return selfPlayer:GetDir()
end

--该状态下不能坐骑、打坐或传送
function MainPlayerController:IsSpecialState()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return false
	end
	if not selfPlayer:GetAvatar() then
		return false
	end
	if selfPlayer:IsDead() then --死亡
		return false, -1
	end
	if not selfPlayer:IsPunish() then --技能
		--print("==============IsPunish")
		return false, -2
	end
	if selfPlayer:IsChanState() then --技能
		--print("==============IsChanState")
		return false, -3
	end
	if selfPlayer:IsPrepState() then --技能
		--print("==============IsPrepState")
        return false, -4
    end
    if SkillController.CollectState == true then --采集
    	--print("==============CollectState")
    	return false, -5
    end
    if SkillController.comboing then --技能
    	--print("==============comboing")
        return false, -6
    end

	if StoryController:IsStorying() then --剧情
		--print("==============IsStorying")
		return false, -7
	end

	if GameController.loginState then --登录界面
		--print("==============loginState")
		return false, -8
	end

	if CPlayerMap.bChangeMaping == true then --切换地图
		--print("==============bChangeMaping")
		return false, -9
	end
	if CPlayerMap.changePosState == true then --切换地图huo 同场景传送
		--print("==============changePosState")
		return false, -10
	end
	if CPlayerMap.changeLineState == true then -- 换线
		--print("==============changeLineState")
		return false, -11
	end
	if CPlayerMap.teleportState == true then -- 传送
		--print("==============teleportState")
		return false, -12
	end
	if ArenaBattle.inArenaScene ~= 0 then  -- 在竞技场
		--print("==============inArenaScene")
		return false, -13
	end
	if MainPlayerController.standInState then -- 变身状态
		--print("==============standInState")
		return false, -14
	end
    if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_STIFF) == 1 then-- 技能
    	--print("==============UNIT_BIT_STIFF")
        return false, -15
    end 
    if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_CASTING) == 1 then-- 技能
    	--print("==============UNIT_BIT_CASTING")
        return false, -16
    end
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_PALSY) == 1 then--麻痹中
		return false, -16
	end
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_HOLD) == 1 then--定身中
		return false, -16
	end	
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_STUN) == 1 then--眩晕中
		return false, -16
	end	
	return true
end

function MainPlayerController:IsCanTeleport()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return false
	end
	if not selfPlayer:GetAvatar() then
		return false
	end

	if selfPlayer:IsDead() then --死亡
		return false, -1
	end

	if StoryController:IsStorying() then --剧情
		return false, -7
	end

	if GameController.loginState then --登录界面
		return false, -8
	end

	if CPlayerMap.bChangeMaping == true then --切换地图
		return false, -9
	end

	if CPlayerMap.changePosState == true then --切换地图huo 同场景传送
		return false, -10
	end

	if CPlayerMap.changeLineState == true then -- 换线
		return false, -11
	end

	if CPlayerMap.teleportState == true then -- 传送
		return false, -12
	end

	if ArenaBattle.inArenaScene ~= 0 then  -- 在竞技场
		return false, -13
	end

	if MainPlayerController.standInState then -- 变身状态
		return false, -14
	end

	if SitController.ReqSitState == true then
		return false, -101
	end
	if MountController.ridingState == true then
        return false, -102
    end

	return true

end

function MainPlayerController:SetRampage(rampageState)
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local avatar = selfPlayer:GetAvatar()
	if not avatar then
		return
	end
	if not self.rampageState then
		self.rampageState = 0
	end
	if self.rampageState == 0 and rampageState == 1 then
		-- local oldScale = avatar:GetScale()
		-- local newScale = 1.2 / oldScale
		-- avatar:SetScale(newScale)
		StoryController:ZoomInCamera(nil, nil, nil, 200)
	elseif self.rampageState == 1 and rampageState == 0 then
		-- local oldScale = avatar:GetScale()
		-- local newScale = 1 / oldScale
		-- avatar:SetScale(newScale)
	end
	self.rampageState = rampageState
end

function MainPlayerController:ResetScale()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local avatar = selfPlayer:GetAvatar()
	if not avatar then
		return
	end
	local oldScale = avatar:GetScale()
	local newScale = 1 / oldScale
	avatar:SetScale(newScale)
end

function MainPlayerController:StopSelfPfx()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local avatar = selfPlayer:GetAvatar()
	if not avatar then
		return
	end
	if not avatar.objSkeleton then
		return
	end
	MainPlayerController:ClearPlayerState()
end

function MainPlayerController:ChangeMesh(questId, isBegin)
	local questInfo = t_quest[questId]
	if not questInfo then
		return
	end
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	local avatar = selfPlayer:GetAvatar()
	if not avatar then
		return
	end
	local modelId = 0
	if isBegin == 1 then
		modelId = t_quest[questId].beginChange
	else
		modelId = t_quest[questId].endChange
	end
	if modelId == 1 then
		if not MainPlayerController.standInState then
			return
		end
		MainPlayerController.standInState = false
		avatar.objNode.mesh = avatar.objMesh
		avatar:StopAllAction()
		avatar:Create(avatar.dwRoleID, avatar.dwProfID)
		avatar:ChangeArms()
		avatar:SetAttackAction(false)
		avatar.objSkeleton:ignoreShake(false)
		selfPlayer:ResetPfx()
		selfPlayer:ResetWing()
		return
	end
	local model = t_model[modelId]
	if not model then
		return
	end
	if MainPlayerController.standInState then
		return
	end
	MountController:RemoveRideMount()
	local meshFile = model.skn
	local sklFile = model.skl
	local IdleAnima = model.san_idle
	local moveAnima = model.san_walk
	local pfx = model.changeEffect
	local mesh = _Mesh.new(meshFile)
	local skeleton = mesh:attachSkeleton(sklFile)
	avatar.objNode.mesh = mesh
    avatar.objSkeleton = mesh.skeleton
    avatar:SetIdleAction(IdleAnima, true)
    avatar:SetMoveAction(moveAnima)
    if pfx and pfx ~= "" then
	    avatar:PlayerPfxOnSkeleton(pfx)
	end
    MainPlayerController.standInState = true
end

function MainPlayerController:AttackTarget(targetCid)
	local monster = MonsterController:GetMonster(targetCid)
	if not monster then
		return
	end
	local monsterConfigId = monster:GetMonsterId()
	--打boss log
	if monsterConfigId == 10010008 then
		if not ClickLog.sendAttackBoss then
			ClickLog:Send(ClickLog.T_Attack_Boss);
			ClickLog.sendAttackBoss = true;
		end
	end
	--洪荒之力 log
	if monsterConfigId == 10208001 then
		if not ClickLog.sendAttackEgg then
			ClickLog:Send(ClickLog.T_Attack_Egg);
			ClickLog.sendAttackEgg = true;
		end
	end
	local targetMonsterCid = FengYaoUtil:GetCurMonsterId()
	if monsterConfigId == targetMonsterCid then
		local nowTime = GetCurTime()
		if MainPlayerController.attackTargetCid ~= targetCid then
			MainPlayerController.attackTargetTime = nowTime
			MainPlayerController.attackTargetCid = targetCid
		else
			if nowTime - MainPlayerController.attackTargetTime >= 3000 then
				MainPlayerController.attackTargetTime = nowTime + ONE_HOUR_MSEC
				--通知弹出UI
				if UIFengYaoConfirmView:IsShow() == false then
					-- UIFengYaoConfirmView:OpenPanel(targetMonsterCid);
				end
			end
		end
	else
		if MainPlayerController.attackTargetTime ~= 0 then
			MainPlayerController.attackTargetCid = 0
			MainPlayerController.attackTargetTime = 0
		end
	end
end

function MainPlayerController:GetFrontPos(dis)
	local player = MainPlayerController:GetPlayer()
    local pos = player:GetPos()
    local dir = player:GetAvatar():GetDir()
    local pos1 = {}
    pos1.x = pos.x + dis * math.sin(dir)
    pos1.y = pos.y - dis * math.cos(dir)
    pos1.z = CPlayerMap:GetSceneMap():getSceneHeight(pos1.x, pos1.y)
    if not pos1.z then
    	pos1.z = pos.z
    end
    return pos1
end

function MainPlayerController:IsMainCity()
	if MapPath.MainCity == CPlayerMap:GetCurMapID() then
		return true
	end
	return false
end

-- 请求取消打坐
function MainPlayerController:ReqCancelSit()
	if SitModel:GetSitState() ~= SitConsts.NoneSit then
		SitController:ReqCancelSit()
		local selfPlayer = MainPlayerController:GetPlayer()
		selfPlayer:StopSit()
	end
end

-- adder:houxudong 
-- date:2016/9/1 11:37:25
-- 请求取消吃饭
function MainPlayerController:ReqCancelEatLunch()
	--print("-------走路，有位移变化",self:IsEatOnChair(),self:IsEatOnland())
	if self:IsEatOnChair() then 
		ActivityLunch:SendMove( )
		local selfPlayer = MainPlayerController:GetPlayer()
		selfPlayer:StopZhuoBianEat()
	end
	if self:IsEatOnland() then
		ActivityLunch:SendMove( )
		local selfPlayer = MainPlayerController:GetPlayer()
		selfPlayer:StopLandEat()
	end
end

function MainPlayerController:OnCannotMove()
	MainPlayerController:StopMove()
end

function MainPlayerController:PetAutoPickUp()
	local selfPlayer = self:GetPlayer()
	if not selfPlayer then
		return
	end
	if not selfPlayer.pet then
		return
	end
	if AutoBattleController:GetAutoHang() then
		return
	end
	local nowTime = GetCurTime()
    if nowTime - MainPlayerController.petLastPickTime < 2000 then
        return
    end
	AutoBattleController:PickUpItem()
	MainPlayerController.petLastPickTime = nowTime
end

function MainPlayerController:InitSelfState()
	MainPlayerController:ClearPlayerState()
	--MainPlayerController:GetPlayer():InitBuffInfo()
	MainPlayerController:GetPlayer():InitStateInfo()
end

function MainPlayerController:AddBinghun(binghunId)
	MainPlayerController.addBinghunState = binghunId
	local player = MainPlayerController:GetPlayer()
	if not player then
		return
	end
	local avatar = player:GetAvatar()
	avatar:ChangeArms()
end

function MainPlayerController:DeleteBinghun()
	if not MainPlayerController.addBinghunState then
		return
	end
	MainPlayerController.addBinghunState = nil
	local player = MainPlayerController:GetPlayer()
	if not player then
		return
	end
	local avatar = player:GetAvatar()
	avatar:ChangeArms()
end

function MainPlayerController:SetInterServerState(val)
	self.isInterServer = val;
	self:sendNotification(NotifyConsts.InterServerState);
	if self.isInterServer then
		UIChat:Hide();
		if not UIInterServiceChat:IsShow() then
			UIInterServiceChat:Show();
		end
	else
		if not UIChat:IsShow() then
			UIChat:Show();
		end
		UIInterServiceChat:Hide()
	end
end

function MainPlayerController:OnChangePlayerName(msg)
	FTrace(msg, '返回改名')
	MainPlayerModel:ChangePlayerName(msg)	
end

function MainPlayerController:ReqChangePlayerName(newName, itemId)
	FPrint('请求改名')
	
	local msg = ReqChangePlayerNameMsg:new();
	msg.roleName = newName
	msg.itemId = itemId
	FTrace(msg)
	MsgManager:Send(msg);
end

function MainPlayerController:OnFirework(msg)
	local list = msg.list
	for index, info in pairs(list) do
		MainPlayerController:PlayFirework(info.id, info.x, info.y)
	end
end

function MainPlayerController:PlayFirework(id, x, y)
	local cfg = t_firework[id]
	if not cfg then
		Error("don't exist this Firework configId" .. id)
		return
	end
	local pfx = cfg.model
	if pfx and pfx ~= "" then
		local z = CPlayerMap:GetSceneMap():getSceneHeight(x, y)
		local mat = _Matrix3D.new()
		mat:setTranslation(x, y, z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(pfx, pfx, mat)
	end
end

--是否处于变身状态
function MainPlayerController:InTransforming()
	local player = self:GetPlayer()
	if not player then
		return;
	end
	
	return player:InTransforming();
end

function MainPlayerController:InTransform()
	return TianShenController:HasFighting();
end
