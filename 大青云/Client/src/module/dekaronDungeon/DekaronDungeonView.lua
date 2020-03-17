--[[
	2016年1月8日14:36:05
	wangyanwei
	挑战副本UI
]]

_G.UIDekaronDungeon = BaseUI:new('UIDekaronDungeon');

function UIDekaronDungeon:Create()
	self:AddSWF('dekaronDungeonPanel.swf',true,'center');
end

function UIDekaronDungeon:OnLoaded(objSwf)
	objSwf.txt_1.htmlText = StrConfig['dekaronDungeon001'];
	local cfg = t_funcOpen[FuncConsts.DekaronDungeon];
	if cfg then
		objSwf.txt_2.htmlText = string.format(StrConfig['dekaronDungeon002'],cfg.open_level);
	end
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_rank.click = function () self:OnShowRankPanel(); end
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.panel_rank.btn_close.click = function () objSwf.panel_rank.visible = false; end
	
	objSwf.btn_enter.click = function () self:OnEnterDekaronDungeonClick(); end
	objSwf.btn_info.rollOver = function () TipsManager:ShowBtnTips(StrConfig['dekaronDungeon050'],TipsConsts.Dir_RightDown); end
	objSwf.btn_info.rollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_headNext.click = function () self:NextClick(); end
	objSwf.btn_headLast.click = function () self:LastClick(); end
end

UIDekaronDungeon.dungeonIndex = 1;
function UIDekaronDungeon:NextClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local maxLayer = DekaronDungeonUtil:GetMaxDungeonLayer();
	if self.dungeonIndex >= maxLayer then
		return
	end
	self.dungeonIndex = self.dungeonIndex + 1;
	self:ShowBossInfo();
end

function UIDekaronDungeon:LastClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.dungeonIndex <= 1 then
		return
	end
	self.dungeonIndex = self.dungeonIndex - 1;
	self:ShowBossInfo();
end

function UIDekaronDungeon:ShowBossInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_tiaozhanfuben[self.dungeonIndex];
	if not cfg then return end
	objSwf.txt_layer.text = cfg.layerStr;
	local monsterCfg = t_monster[cfg.monsterid];
	if not monsterCfg then return end
	objSwf.txt_name.text = monsterCfg.name;
	
	self:DisBtn();
	self:OnDrawBoss();
	self:ShowReward();
end

function UIDekaronDungeon:DisBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local nowLayer = self.dungeonIndex;
	local maxLayer = DekaronDungeonUtil:GetMaxDungeonLayer();
	local cfg = t_tiaozhanfuben[nowLayer];
	if not cfg then return end
	objSwf.btn_headLast.disabled = cfg.id <= 1 and true or false;
	objSwf.btn_headNext.disabled = cfg.id >= maxLayer and true or false;
end

function UIDekaronDungeon:OnEnterDekaronDungeonClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if not FuncManager:GetFuncIsOpen(FuncConsts.DekaronDungeon) then
		FloatManager:AddNormal(FuncManager:GetFuncUnOpenTips(FuncConsts.DekaronDungeon))
		return true
	end
	
	if DekaronDungeonController:GetInDekaronDungeonState() then
		FloatManager:AddNormal( StrConfig['dekaronDungeon1003'] );
		return
	end
	
	local enterNum = DekaronDungeonUtil:GetNowEnterNum();
	if not enterNum then return end
	
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon1002'] );
		return
	end
	DekaronDungeonController:SendEnterDekaronDungeon();	--//请求进入
end

function UIDekaronDungeon:OnShow()
	self:ShowBossInfo();
	DekaronDungeonController:SendDekaronDungeonData();  --//请求数据
end

function UIDekaronDungeon:ShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = t_tiaozhanreward[self.dungeonIndex];
	if not cfg then return end
	local randomList = RewardManager:Parse( cfg.reward );
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));
	objSwf.rewardList:invalidateData();
	
	
end

function UIDekaronDungeon:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_rank.visible = true;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.dungeonIndex = 1;
end

function UIDekaronDungeon:OnShowRankPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_rank.visible = not objSwf.panel_rank.visible;
end

--显示副本数据
function UIDekaronDungeon:OnShowData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local dungeonData = DekaronDungeonModel:GetDekaronDungeonData();
	objSwf.txt_bestTeamLayer.text = string.format(StrConfig['dekaronDungeon006'],dungeonData.bestTeamLayer) 	--最强队伍层数
	objSwf.txt_bestLayer.htmlText = string.format(StrConfig['dekaronDungeon003'],dungeonData.bestLayer);		--自己历史最高
	objSwf.txt_nowLayer.htmlText = string.format(StrConfig['dekaronDungeon004'],dungeonData.nowBestLayer);		--今日最高
	local enterNum = DekaronDungeonUtil:GetNowEnterNum();														--今日剩余次数
	if enterNum then
		local cfg = t_consts[148];
		if cfg then
			objSwf.txt_enterNum.htmlText = string.format(StrConfig['dekaronDungeon005'],enterNum > 0 and '#00ff00' or '#ff0000',enterNum .. '/' .. cfg.val1);
		end
	end
	
	self:ShowBestTeam();
	self:ShowRankList();
end

--show出最强队伍列表
function UIDekaronDungeon:ShowBestTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local bestTeamList = DekaronDungeonModel:GetDekaronDungeonBestTeamData();
	
	for i = 1 , 4 do
		if bestTeamList[i] then
			objSwf['txt_team' .. i]._visible = true;
			objSwf['txt_team' .. i].text = bestTeamList[i].name;
		else
			objSwf['txt_team' .. i]._visible = false;
		end
	end
end

--show排行榜
function UIDekaronDungeon:ShowRankList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rankList = DekaronDungeonModel:GetDekaronDungeonRankData();
	
	if not rankList then return end
	
	for i = 1 , 3 do
		if rankList[i] then
			objSwf.panel_rank['txt_name' .. i]._visible = true;
			objSwf.panel_rank['txt_layer' .. i]._visible = true;
			objSwf.panel_rank['txt_name' .. i].text = rankList[i].name;
			objSwf.panel_rank['txt_layer' .. i].htmlText = string.format(StrConfig['dekaronDungeon010'],rankList[i].layer);
		else
			objSwf.panel_rank['txt_name' .. i]._visible = false;
			objSwf.panel_rank['txt_layer' .. i]._visible = false;
		end
	end
	
	objSwf.panel_rank.listPlayer.dataProvider:cleanUp();
	
	for i = 4 , 10 do
		if rankList[i] then
			local vo = {};
			vo.rank = i;
			vo.playerName = rankList[i].name;
			vo.layer = string.format(StrConfig['dekaronDungeon010'],rankList[i].layer);
			objSwf.panel_rank.listPlayer.dataProvider:push(UIData.encode(vo));
		end
	end
	objSwf.panel_rank.listPlayer:invalidateData();
end

--绘制BOSS
function UIDekaronDungeon:OnDrawBoss()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local dekaronCfg = t_tiaozhanfuben[self.dungeonIndex];
	if not dekaronCfg then return end
	local monsterCfg = t_monster[dekaronCfg.monsterid];
	if not monsterCfg then return end
	local monsterID = monsterCfg.id;
	
	local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,monsterID);
	monsterAvater:InitAvatar();
	
	local drawCfg = UIDrawDekaronBossCfg[monsterID];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawDekaronBossCfg[monsterID] = drawCfg;
	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("UIDekaronDungeon",monsterAvater, objSwf.load_boss,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000);
	else
		self.objUIDraw:SetUILoader(objSwf.load_boss);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end
	local rotation = drawCfg.Rotation or 0;
	monsterAvater.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
end

UIDekaronDungeon.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	VPort = _Vector2.new(1100,700),
	Rotation = 0
};
function UIDekaronDungeon:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIDekaronDungeon:HandleNotification(name, body)
	if name == NotifyConsts.DekaronDungeonUpDate then			--波数信息刷新
		self:OnShowData();
	end
end

--监听消息列表
function UIDekaronDungeon:ListNotificationInterests()
	return { 
		NotifyConsts.DekaronDungeonUpDate,
	};
end

function UIDekaronDungeon:IsTween()
	return true;
end

function UIDekaronDungeon:GetPanelType()
	return 1;
end

function UIDekaronDungeon:IsShowSound()
	return true;
end

function UIDekaronDungeon:IsShowLoading()
	return true;
end

function UIDekaronDungeon:GetWidth()
	return 1060
end

function UIDekaronDungeon:GetHeight()
	return 650
end