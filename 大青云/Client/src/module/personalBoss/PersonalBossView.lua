--[[
	2015年10月31日16:25:07
	wangyanwei
	个人BOSS
]]

_G.UIPersonalBoss = BaseUI:new('UIPersonalBoss');

UIPersonalBoss.scene = nil;
UIPersonalBoss.objAvatar = nil;--模型
UIPersonalBoss.sceneLoaded = false;

function UIPersonalBoss:Create()
	self:AddSWF('personalbossPanel.swf',true,nil);
end

UIPersonalBoss.autoNum = 1;
-- UIPersonalBoss.curPage = 1;
-- UIPersonalBoss.maxPage = 1;
function UIPersonalBoss:OnLoaded(objSwf)
	objSwf.bossList.change = function (e)
		self.curPage = 1;
		self.selectBossID = PersonalBossModel:GetPersonalBossDate()[objSwf.bossList.selectedIndex + 1].bossId
		self:DrawBoss();
		self:ShowKeyTxt();
		self:DrawReward();
		self:UpdateBtnState()
	end
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.txt_2.text = StrConfig['personalboss11'];
	-- objSwf.txt_3.htmlText = StrConfig['personalboss13']
	
	-- objSwf.icon_head.loaded = function () objSwf.icon_head._x = objSwf.mc_headBG._x - objSwf.icon_head._width/2 end
	
	objSwf.btn_enter.click = function () self:EnterHandler(); end
	objSwf.btn_auto.click = function () self:AutoEnterHandler(); end
	objSwf.btn_auto.visible = false
	objSwf.btn_timeEnter.click = function() self:SingleAutoEnterHandler() end
	objSwf.btn_timeEnter.visible = false

	objSwf.btnPagePre.click     = function() self:OnBtnPreClick(); end
	objSwf.btnPageNext.click    = function() self:OnBtnNextClick(); end

	objSwf.btn_auto.rollOver = function() TipsManager:ShowBtnTips(StrConfig["personalboss202"],TipsConsts.Dir_RightDown) end
	objSwf.btn_auto.rollOut = function() TipsManager:Hide() end

	objSwf.btn_timeEnter.rollOver = function() TipsManager:ShowBtnTips(StrConfig["personalboss203"],TipsConsts.Dir_RightDown) end
	objSwf.btn_timeEnter.rollOut = function() TipsManager:Hide() end
	
	objSwf.btn_item.rollOver = function (e) self:ItemRollOverHandler(); end
	objSwf.btn_item.rollOut = function () TipsManager:Hide(); end
	
	objSwf.ddList.dataProvider:cleanUp();
	local cfg = PersonalUtil:GetAutoNumCfg();
	if not cfg then return end
	for i,vo in ipairs(cfg) do
		objSwf.ddList.dataProvider:push(vo);
	end
	objSwf.ddList.change = function(e) if not e then return end self.autoNum = e.index + 1 ; end
	objSwf.ddList:invalidateData();
	objSwf.ddList.rowCount = 15;
	objSwf.ddList.selectedIndex = 0;
	objSwf.ddList.visible = false

	objSwf.ddList.rollOver = function()
		local color = "#FF0000"
		local cfg = PersonalUtil:GetBossIDCfg(self.selectBossID);
		local enterItemCfg = split(cfg.itemNumber,',');
		local BgItemNum = BagModel:GetItemNumInBag(toint(enterItemCfg[1]))
		if BgItemNum >= toint(enterItemCfg[2]) then
			color = "#00FF00"
		end
		TipsManager:ShowBtnTips(string.format(StrConfig["personalboss204"], color, t_item[toint(enterItemCfg[1])].name),TipsConsts.Dir_RightDown)
	end
	objSwf.ddList.rollOut = function() TipsManager:Hide() end
end

function UIPersonalBoss:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.btnPagePre.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.btnPageNext.disabled = selectedIndex == numlist - 1
end

function UIPersonalBoss:OnBtnPreClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	if list.scrollPosition > 0 then
		list.scrollPosition = list.scrollPosition - 1
		list.selectedIndex = math.min( list.selectedIndex, list.scrollPosition + list.rowCount - 1 )
	elseif list.selectedIndex > 0 then
		list.selectedIndex = list.selectedIndex - 1
	end
end

function UIPersonalBoss:OnBtnNextClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	if list.scrollPosition < numlist - list.rowCount then
		list.scrollPosition = list.scrollPosition + 1
		list.selectedIndex = math.max( list.selectedIndex, list.scrollPosition )
	elseif list.selectedIndex < numlist - 1 then
		list.selectedIndex = list.selectedIndex + 1
	end
end

function UIPersonalBoss:ItemRollOverHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if not self.selectBossID then return end
	local cfg = PersonalUtil:GetBossIDCfg(self.selectBossID);
	local enterItemCfg = split(cfg.itemNumber,',');
	local itemCfg = t_item[toint(enterItemCfg[1])];
	if not itemCfg then print('not item id',enterItemCfg[1])return end
	
	TipsManager:ShowItemTips(toint(enterItemCfg[1]));
end

function UIPersonalBoss:SingleAutoEnterHandler()
	if not self.selectBossID then return end

	local bossCfg = PersonalUtil:GetBossIDCfg(self.selectBossID);
	if not bossCfg then return end
	
	local personalBossVO = PersonalBossModel:GetIDPersonalBossDate(bossCfg.id);
	if not personalBossVO then return end
	
	if TeamModel:IsInTeam() then
		FloatManager:AddNormal( StrConfig['personalboss104'] );
		return
	end

	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if level < bossCfg.playerLevel then
		FloatManager:AddNormal( StrConfig['personalboss101'] );
		return
	end
	
	if PersonalBossModel:GetAutoNum() >0 or PersonalBossModel:GetAutoFlag() then 
		FloatManager:AddNormal( StrConfig['personalboss108'] );
		return 
	end

	local enterItemCfg = split(bossCfg.itemNumber,',')
	local itemCfg = t_item[toint(enterItemCfg[1])];
	local BgItemNum = BagModel:GetItemNumInBag(itemCfg.id);

	-- self.autoNum
	local enterItemNum = PersonalBossModel:GetItemEnterNum();

	local enterNum = enterItemNum + personalBossVO.num;
	if enterNum < 1 then
		FloatManager:AddNormal(StrConfig['personalboss102'])
		return
	end
	if BgItemNum + personalBossVO.num < 1 then
		FloatManager:AddNormal( StrConfig['personalboss107'] )
		return
	end

	PersonalBossModel:SetAutoNum(self.autoNum);
	PersonalBossController:SendEnter(bossCfg.id);
end

function UIPersonalBoss:AutoEnterHandler()
	if TeamModel:IsInTeam() then
		FloatManager:AddNormal( StrConfig['personalboss104'] );
		return
	end

	if PersonalBossModel:GetAutoNum() >0 or PersonalBossModel:GetAutoFlag() then 
		FloatManager:AddNormal( StrConfig['personalboss108'] );
		return 
	end

	for k, bossCfg in ipairs(t_personalboss) do
		local personalBossVO = PersonalBossModel:GetIDPersonalBossDate(bossCfg.id);
		if personalBossVO then
			local level = MainPlayerModel.humanDetailInfo.eaLevel;
			if level >= bossCfg.playerLevel then
				if personalBossVO.num > 0 then
					PersonalBossController:SendEnter(bossCfg.id)
					PersonalBossModel:SetAutoFlag(true);
					return
				end
			end
		end
	end
	PersonalBossModel:SetAutoFlag(false);
	FloatManager:AddNormal(StrConfig['personalboss201']);
end

function UIPersonalBoss:EnterHandler()
	if not self.selectBossID then return end
	
	local bossCfg = PersonalUtil:GetBossIDCfg(self.selectBossID);
	if not bossCfg then return end
	
	local personalBossVO = PersonalBossModel:GetIDPersonalBossDate(bossCfg.id);
	if not personalBossVO then return end
	
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if level < bossCfg.playerLevel then
		FloatManager:AddNormal( StrConfig['personalboss101'] );
		return
	end
	
	if personalBossVO.num <= 0 and PersonalBossModel:GetItemEnterNum() <= 0 then
		FloatManager:AddNormal( StrConfig['personalboss102'] );
		return
	end
	
	if PersonalBossModel:GetAutoNum() >0 then return end
	
	if personalBossVO.num > 0 then
		PersonalBossController:SendEnter(bossCfg.id)
		return
	end
	
	local cfg = split(bossCfg.itemNumber,',');
	local BgItemNum = BagModel:GetItemNumInBag(toint(cfg[1]));
	
	if BgItemNum < toint(cfg[2]) then
		FloatManager:AddNormal( StrConfig['personalboss107'] );
		return
	end
	
	PersonalBossController:SendEnter(bossCfg.id)
end

function UIPersonalBoss:OnShow()
	self:OnDrawBossList();
	self:ShowKeyTxt();
end

function UIPersonalBoss:ShowKeyTxt()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	
	if not self.selectBossID then return end
	local cfg = PersonalUtil:GetBossIDCfg(self.selectBossID);
	if not cfg then return end
	local data = PersonalBossModel:GetIDPersonalBossDate(cfg.id);
	
	if data.num <= 0 then
		objSwf.txt_2._visible = true;
		-- objSwf.txt_3._visible = true;
		objSwf.txt_num._visible = true;
		objSwf.txt_enterNum._visible = false;
		objSwf.btn_item.visible = true;
		local itemEnterNum = PersonalBossModel:GetItemEnterNum();
		objSwf.txt_num.htmlText = string.format(StrConfig['personalboss7'],itemEnterNum);
	else
		objSwf.txt_2._visible = false;
		-- objSwf.txt_3._visible = false;
		objSwf.txt_num._visible = false;
		objSwf.txt_enterNum._visible = true;
		objSwf.btn_item.visible = false;
		objSwf.txt_enterNum.htmlText = string.format(StrConfig['personalboss14'],data.num)
	end
	
	local enterItemCfg = split(cfg.itemNumber,',');
	local itemCfg = t_item[toint(enterItemCfg[1])];
	if not itemCfg then print('not item id',enterItemCfg[1])return end
	
	local itemName = itemCfg.name;
	
	local BgItemNum = BagModel:GetItemNumInBag(itemCfg.id);
	
	objSwf.btn_item.htmlLabel = '<u>' .. string.format( BgItemNum >= toint(enterItemCfg[2]) and StrConfig['personalboss5'] or StrConfig['personalboss6'] , itemName .. '*' .. enterItemCfg[2] ) .. '</u>';
end

UIPersonalBoss.selectBossID = nil;
function UIPersonalBoss:OnDrawBossList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local personalBossList = PersonalBossModel:GetPersonalBossDate();
	
	self.selectBossID = personalBossList[1].bossId;	--默认选中第一个BOSS
	
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	
	objSwf.bossList.dataProvider:cleanUp();
	for index , personalBossVO in ipairs(personalBossList) do
		local vo = {};
		local cfg = t_personalboss[personalBossVO.id];
		if cfg then
			vo.nameUrl 	= ResUtil:GetBossMapIcon(cfg.nameIcon)
			vo.headUrl 	= ResUtil:GetBossMapIcon(cfg.bossIcon)
			vo.id 		= personalBossVO.id;
			vo.bossId 	= personalBossVO.bossId;
			vo.isfirst 	= personalBossVO.isfirst;
			vo.level 	= personalBossVO.level;
			vo.levelStr = string.format(level >= vo.level and StrConfig['personalboss1'] or StrConfig['personalboss2'],personalBossVO.level);
			vo.num 		= personalBossVO.num;
			if cfg.freeTime == 0 then
				vo.numStr = ""
			else
				vo.numStr 	= string.format(vo.num > 0 and StrConfig['personalboss3'] or StrConfig['personalboss4'],personalBossVO.num);
			end
			objSwf.bossList.dataProvider:push(UIData.encode(vo));
		else
			print('not personalBossID ------   ' .. personalBossVO.id)
		end
	end
	objSwf.bossList:invalidateData();
	
	self:DrawBoss();
	self:DrawReward();
	
	objSwf.bossList.selectedIndex = 0;
end

function UIPersonalBoss:OnHide()
	
	if self.scene then 
		self.scene:SetDraw(false)
		self.scene:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.scene);
		self.scene = nil
	end
	
	self.sceneLoaded = false;
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	
	-- self.selectBossID = nil;
end

UIPersonalBoss.personalBossIsFirst = false;
function UIPersonalBoss:DrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.selectBossID then return end
	local cfg = PersonalUtil:GetBossIDCfg(self.selectBossID);
	if not cfg then return end
	local isfirst = false --PersonalUtil:GetIDIsFirst(self.selectBossID);
	
	objSwf.txt_1.text = isfirst and StrConfig['personalboss9'] or StrConfig['personalboss10'];
	
	self.personalBossIsFirst = isfirst;
	
	local randomList = RewardManager:Parse( isfirst and cfg.firstReward or cfg.dropReward);
	-- self.maxPage = math.ceil(#randomList/8)

	-- objSwf.btnPre._visible = self.maxPage > 1
	-- objSwf.btnNext._visible = self.maxPage > 1
	-- local list = {}
	-- for i = 8*(self.curPage - 1) + 1, 8*(self.curPage - 1) + 8 do
	-- 	if randomList[i] then
	-- 		table.push(list, randomList[i])
	-- 	else
	-- 		break
	-- 	end
	-- end
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));
	objSwf.rewardList:invalidateData();
end

function UIPersonalBoss:DrawBoss()
	local objSwf = self.objSwf;
	if not objSwf then return end 
	if not self.selectBossID then return end
	
	local drawCfg = UIDrawPersonalBossConfig[self.selectBossID];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawPersonalBossConfig[monsterId] = drawCfg;
	end
	
	if not self.scene then
		self.scene = UISceneDraw:new("UIPersonalBoss", objSwf.load_boss, _Vector2.new(1010, 620), false);
	end
	self.scene:SetUILoader(objSwf.load_boss);
	
	if self.sceneLoaded then
		if self.objAvatar then
			self.objAvatar:ExitMap();
			self.objAvatar = nil;
		end
		self.objAvatar = MonsterAvatar:NewMonsterAvatar(nil,self.selectBossID);
		self.objAvatar:InitAvatar();
		
		self.scene:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation or 0 );
		local rotation = drawCfg.Rotation or 0;
		self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
		self.objAvatar:EnterUIScene(self.scene.objScene,nil,nil,nil, enEntType.eEntType_Monster);
	else
		self.scene:SetScene('v_panel_boss.sen', function()
			if self.objAvatar then
				self.objAvatar:ExitMap();
				self.objAvatar = nil;
			end
			self.objAvatar = MonsterAvatar:NewMonsterAvatar(nil,self.selectBossID);
			self.objAvatar:InitAvatar();
			
			self.scene:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
			self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation or 0 );
			local rotation = drawCfg.Rotation or 0;
			self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
			self.objAvatar:EnterUIScene(self.scene.objScene,nil,nil,nil, enEntType.eEntType_Monster);
			self.sceneLoaded = true;
		end );
		self.scene:SetDraw( true );
	end
	
	local cfg = PersonalUtil:GetBossIDCfg(self.selectBossID);
	if not cfg then return end
	objSwf.nameLoader.source = ResUtil:GetBossMapIcon(cfg.nameIcon)
	-- objSwf.txtCondition.htmlText = cfg.playerLevel .. "级"
end

UIPersonalBoss.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	Rotation = 0
};
function UIPersonalBoss:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIPersonalBoss:GetWidth()
	return 1059;
end

function UIPersonalBoss:GetHeight()
	return 676;
end