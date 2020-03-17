--[[
	2015年1月23日, PM 03:40:37
	通天塔主界面
	wangyanwei 
]]

_G.UIBabel = BaseUI:new('UIBabel');


function UIBabel:Create()
	self:AddSWF("babelPanel.swf",true,nil);
	self:AddChild(UIBabelRank, "babelRank");
end

function UIBabel:OnLoaded(objSwf,name)
	self:GetChild("babelRank"):SetContainer(objSwf.rankPanel);
	objSwf.rewardlist.txt_equip._visible = false;
	-- objSwf.rewardlist.txt_equip.text = UIStrConfig['babel12'];
	-- objSwf.btn_next.click = function () self:OnNextLayerClick(); end	 --上一关
	-- objSwf.btn_last.click = function () self:OnLastLayerClick(); end	 --下一关
	-- objSwf.btn_close.click = function () self:OnCloseClick(); end
	objSwf.btn_close._visible = false
	objSwf.rewardlist.btn_challenge.click = function () self:OnChallengeClick(); end--挑战
	objSwf.rewardlist.btn_challenges.click = function () self:OnChallengeClick(); end--挑战
	objSwf.rewardlist.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardlist.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.panel_sweep.sweepList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardlist.firstList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.panel_sweep.sweepList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.rewardlist.firstList.itemRollOut = function () TipsManager:Hide(); end
	
	-- objSwf.randomList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	-- objSwf.randomList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.btnRule.rollOver = function () TipsManager:ShowBtnTips(StrConfig['babel100'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function () TipsManager:Hide(); end
	objSwf.rewardlist.btn_rank.click = function () self:ShowBabelRank(); end
	objSwf.ranklist.btn_back.click = function () self:ShowBabelReward(); end
	-- objSwf.btn_nowLayer.click = function () 
		-- if BabelModel:GetNowLayer() == BabelModel:GetTallestLayer() + 1 then 
			-- return 
		-- end 
		-- self.objSwf.pic_already._visible = false;
		-- self.objSwf.pic_open._visible = false;
		-- self.objSwf.pic_no._visible = false;
		-- BabelController:OnGetBabelInfo(0); 
	-- end
	
	-- objSwf.firstItem.rollOver = function(e) if not self.firstRewardItemId then return end TipsManager:ShowItemTips(self.firstRewardItemId); end
	-- objSwf.firstItem.rollOut = function() TipsManager:Hide(); end
	
	self.objSwf.pic_already._visible = false;
	self.objSwf.pic_open._visible = false;
	self.objSwf.pic_no._visible = false;
	
	objSwf.titleBar.babelTitleList.itemClick = function(e)
		local obj = e.item;
		if not obj then return end
		local id = e.item.id;
		local babelCfg = t_doupocangqiong[id];
		if not babelCfg then return end
		self:TitleListClick(id);
	end
	
	objSwf.btn_headNext.click = function () 
		if self:TimeBtnClick() then
			self:OnHeadNextHandler();
		end
	end
	objSwf.btn_headLast.click = function () if self:TimeBtnClick() then self:OnHeadLastHandler(); end end
	
	objSwf.btn_jumpNext.click = function () self:JumpClickHandler(1); end
	objSwf.btn_jumpLast.click = function () self:JumpClickHandler(2); end
	
	objSwf.rewardlist.btn_sweep.click = function ()
		self:OnSweepClick();
	end
	objSwf.panel_sweep._visible = false;
	objSwf.panel_sweep.btn_enter.click = function() 
		self:OnSendSweepClikc();
	end
	objSwf.panel_sweep.btn_close.click = function()
		self.sweepState = false;
		objSwf.panel_sweep._visible = false;
	end
	objSwf.BtnIntegral.click = function() self:ShowIntegralShop();end
end

function UIBabel:OnSendSweepClikc()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if not self.sweepID  then return end
	if self.sweepState then 
		self.sweepState = false
		objSwf.panel_sweep._visible = false
		return 
	end
	local data = BabelModel.babelData;
	if not data then return end
	local nowLayer = data.layer;
	if not nowLayer then return end
	if self.sweepID > data.maxLayer then return end
	-- if data.daikyNum < data.num then
		-- FloatManager:AddNormal( StrConfig['babel10012'] );
		-- return 
	-- end
	
	BabelController:OnSendSweep(self.sweepID);
	self.sweepState = true;
end

UIBabel.sweepID = nil;
function UIBabel:OnSweepClick()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	
	local data = BabelModel.babelData;
	if not data then return end
	local nowLayer = data.layer;
	if not nowLayer then return end
	-- print('选定扫荡',nowLayer)
	if data.num < 1 then
		FloatManager:AddNormal( StrConfig['babel10012'] );
		return
	end
	if data.daikyNum < 1 then
		FloatManager:AddNormal( StrConfig['babel10012'] );
		return
	end
	if nowLayer > data.maxLayer then
		FloatManager:AddNormal( StrConfig['babel10013'] );
		return
	end
	
	if not objSwf.panel_sweep._visible then
		objSwf.panel_sweep._visible = true;
	end
	
	local cfg = t_doupocangqiong[nowLayer];
	if not cfg then return end
	
	local sweepList = cfg.sweepReward;
	if not sweepList then return end
	
	self.sweepID = data.layer;
	
	local rewardList = RewardManager:Parse(sweepList);
	objSwf.panel_sweep.sweepList.dataProvider:cleanUp();
	objSwf.panel_sweep.sweepList.dataProvider:push(unpack(rewardList));
	objSwf.panel_sweep.sweepList:invalidateData();
	
	objSwf.panel_sweep.btn_enter.label = UIStrConfig['babel18'];
	
	objSwf.panel_sweep.tf1.htmlText = string.format(StrConfig['babel800'],data.num > data.daikyNum and data.daikyNum or data.num);
	objSwf.panel_sweep.tf2.htmlText = StrConfig['babel801'];
end
function UIBabel:ShowIntegralShop()
	UIShopCarryOn:OpenShopByType(ShopConsts.T_Babel)

	if UIRankRewardView:IsShow() then
		UIRankRewardView:Hide();
	end;
end;

UIBabel.sweepState = false;
function UIBabel:ShowSweepReward(list,layerID)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	self.sweepState = true;
	local cfg = t_doupocangqiong[layerID];
	if not cfg then return end
	--[[
	-- 删除 date:2016年12月2日 17:48:25
	-- reason: 单人挑战取消每日通关额外几率获得奖励
	local stoneCfg = split(cfg.extrareward,',');
	local stoneID = toint(stoneCfg[1])
	if type(stoneID) ~= 'number' then return end
	if not objSwf.panel_sweep._visible then
		objSwf.panel_sweep._visible = true
	end
	local newlist = {};
	for i , rewardVO in ipairs(list) do				--数据合并
		if not newlist[rewardVO.id] then
			newlist[rewardVO.id] = {};
			newlist[rewardVO.id].id = rewardVO.id;
			newlist[rewardVO.id].num = rewardVO.num;
			newlist[rewardVO.id].index = i;
		else
			newlist[rewardVO.id].num = newlist[rewardVO.id].num + rewardVO.num ;
		end
	end
	local newlist2 = {};
	for i , v in pairs(newlist) do					--提取ID
		if v.id == stoneID then
			local vo = {};
			vo.id = v.id;
			vo.num = v.num;
			table.push(newlist2,vo);
			break
		end
	end
	for i , v in pairs(newlist) do					--补充
		if v.id ~= stoneID then
			local vo = {};
			vo.id = v.id;
			vo.num = v.num;
			table.push(newlist2,vo);
		end
	end
	local rewardStr = '';
	for index , rewardVO in ipairs(newlist2) do
		rewardStr = rewardStr .. ( index >= #newlist2 and rewardVO.id .. ',' .. rewardVO.num or rewardVO.id .. ',' .. rewardVO.num .. '#'); 
	end
	
	local rewardList = RewardManager:Parse(rewardStr);
	objSwf.panel_sweep.sweepList.dataProvider:cleanUp();
	objSwf.panel_sweep.sweepList.dataProvider:push(unpack(rewardList));
	objSwf.panel_sweep.sweepList:invalidateData();
	--]]
	objSwf.panel_sweep.btn_enter.label = UIStrConfig['babel19'];
	objSwf.panel_sweep.tf1.htmlText = StrConfig['babel805'];
	objSwf.panel_sweep.tf2.htmlText = StrConfig['babel806'];
end

UIBabel.JumpLayerNum = 4;
function UIBabel:JumpClickHandler(_type)
	local babelData = BabelModel.babelData;
	local nowLayer = babelData.layer;
	if not nowLayer then return end
	local maxLayer = #t_doupocangqiong;
	local layer = 0;
	if _type == 1 then
		if nowLayer == maxLayer then return end
		if nowLayer == #t_doupocangqiong then 					--已到顶层
			FloatManager:AddNormal( StrConfig['babel10011'] );
			return
		end
		if nowLayer == babelData.maxLayer + 4 then				--无法继续查看
			FloatManager:AddNormal( StrConfig['babel10010'] );
			return
		end
		if nowLayer > babelData.maxLayer then
			FloatManager:AddNormal( StrConfig['babel10010'] );
			return
		else
			if nowLayer > babelData.maxLayer - 3 then
				layer = babelData.maxLayer + 1;
			else
				layer = maxLayer - nowLayer >= self.JumpLayerNum and nowLayer + self.JumpLayerNum or maxLayer;
			end
		end
	else
		if nowLayer == 1 then return end
		layer = nowLayer - self.JumpLayerNum >= self.JumpLayerNum and nowLayer - self.JumpLayerNum or 1;
	end
	self.lastLayerID = 0;
	self.initLayerID = 0;
	BabelController:OnGetBabelInfo(layer);
end

function UIBabel:TimeBtnClick()
	if self.headTimeKey then 
		return false
	else
		self.headTimeKey = TimerManager:RegisterTimer(function()
			TimerManager:UnRegisterTimer(self.headTimeKey);
			self.headTimeKey = nil;
		end,500,1);
		return true;
	end 
end

function UIBabel:OnShow()
	if self.args[1] then
		BabelController:OnGetBabelInfo(self.args[1]);
	else
		BabelController:OnGetBabelInfo(0);
	end
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.rewardlist._visible = true
	objSwf.ranklist._visible = false
	BabelController:OnGetBabelRankList();
	
    self:ShowTrialScore()

end

function UIBabel:ShowBabelRank()
	-- if UIBabelRank:IsShow() then
	-- 	UIBabelRank:Hide();
	-- 	return
	-- end
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.rewardlist._visible = false
	BabelController:OnGetBabelRankList();  --请求排行榜数据
	-- self:OnChangeRankList()
	objSwf.ranklist._visible = true
end


function UIBabel:ShowBabelReward( )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.rewardlist._visible = true
	objSwf.ranklist._visible = false
end

function UIBabel:OnChangeRankList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.ranklist.listPlayer.dataProvider:cleanUp();
	objSwf.ranklist.listMy.dataProvider:cleanUp();
	local list = BabelModel.rankListInfo;
	if list == {} then return end
	-- 特殊处理排名第一的玩家
	objSwf.ranklist.name.htmlText = list[1].name
	objSwf.ranklist.layer.htmlText = StrConfig['babel013'];--string.format(StrConfig['babel013'],list[1].tier);
	objSwf.ranklist.layerNum.htmlText = list[1].tier;
	for i , v in ipairs(list)  do
		if i > 1 then
			local vo = {};
			vo.rank = i; 
			vo.playerLevel = v.level;
			vo.layer = string.format(StrConfig['babel008'],v.tier);
			vo.playerName = v.name
			objSwf.ranklist.listPlayer.dataProvider:push(UIData.encode(vo));
		end
	end
	objSwf.ranklist.listPlayer:invalidateData();

	local roleID = MainPlayerController:GetRoleID()
	local index = 0;
	for i,v in ipairs(list) do
		if v.roleID == roleID then
			local vo = {};
			vo.rank =  i;
			vo.layer = string.format(StrConfig['babel008'],v.tier);
			vo.playerName = v.name
			objSwf.ranklist.listMy.dataProvider:push(UIData.encode(vo));
			objSwf.ranklist.listMy:invalidateData();
		else
			index = index +1;
		end 
	end
	--未上榜
	if index >= #list then
		local info = MainPlayerModel.humanDetailInfo
		local vo = {};
		vo.playerName = info.eaName
		vo.rank = 'z';   --未上榜 默认为z和字体资源保持一致
		vo.layer = string.format(StrConfig['babel008'],BabelModel:GetTallestLayer());
		objSwf.ranklist.listMy.dataProvider:push(UIData.encode(vo));
		objSwf.ranklist.listMy:invalidateData();
	end
end

function UIBabel:showMyRank( )
	local objSwf = self.objSwf;
	if not objSwf then return end

end
--点击挑战
function UIBabel:OnChallengeClick()
	if TeamModel:IsInTeam() then
		FloatManager:AddNormal( StrConfig["babel200"] );
		return 
	end
	if not BabelModel.babelData.layer then return end
	if (BabelModel.babelData.daikyNum or 0) < 1 then
		FloatManager:AddNormal( StrConfig["babel600"] );
		return 
	end
	if BabelModel.babelData.num < 1 and BabelModel.babelData.layer < BabelModel:GetTallestLayer() + 1 then
		FloatManager:AddNormal( StrConfig["babel400"] );
		return
	end
	if BabelModel.babelData.layer > BabelModel:GetTallestLayer() + 1 then
		FloatManager:AddNormal( StrConfig["babel300"] );
		return
	end
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	local babelCfg = t_doupocangqiong[BabelModel.babelData.layer];
	if not babelCfg then return end
	if myLevel < babelCfg.level then
		FloatManager:AddNormal( StrConfig["babel700"] );
		return
	end
	BabelController:OnGetEnterBabel(BabelModel.babelData.layer);
end

function UIBabel:OnCloseClick()
	if UIBabelRank:IsShow() then
		UIBabelRank:Hide();
	end
	self:Hide();
end

-- function UIBabel:GetWidth()
-- 	return 1146;
-- end

-- function UIBabel:GetHeight()
-- 	return 687;
-- end

function UIBabel:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.lastLayerID = 0;
	self.initLayerID = 0;
	self.tweening = false;
	for i = 1 , 3 do
		if self['objUIDraw' .. i] then
			self['objUIDraw' .. i]:SetDraw(false);
			self['objUIDraw' .. i]:SetMesh(nil);
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.headTimeKey then
		TimerManager:UnRegisterTimer(self.headTimeKey);
		self.headTimeKey = nil;
	end
	objSwf.titleBar.babelTitleList.dataProvider:cleanUp();
	objSwf.titleBar.babelTitleList:invalidateData();
	objSwf.panel_sweep._visible = false;
	self.sweepState = false;
end

--UI		bossTitleList
UIBabel.MaxLayerNum = 4;							--UI上最多显示的BOSS头像个数
function UIBabel:OnShowTitleList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local babelData = BabelModel.babelData;
	local nowLayer = babelData.layer;
	self:OnDrawBossList(nowLayer);
end

--绘制titleList
UIBabel.headIconConsts = 4;			--UI显示头像个数
UIBabel.initLayerID = 0;			--最下面怪物的ID
function UIBabel:OnDrawBossList(nowLayer)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if self.lastLayerID ~= 0 then		--如果已经画好了list  点击时将不再重绘
		return 
	end
	objSwf.titleBar.babelTitleList.dataProvider:cleanUp();
	
	local startID ;
	local startIndex;
	if self.initLayerID ~= 0 then
		startID = self.initLayerID + 1;
	else
		startID = nowLayer;
		if startID > #t_doupocangqiong - self.headIconConsts + 1 then
			startIndex = startID - (#t_doupocangqiong - self.headIconConsts + 1);
			startID = #t_doupocangqiong - self.headIconConsts + 1;
		end
	end
	-- startID 当前的层数
	local babelData = BabelModel.babelData;
	local myMaxLayer = babelData.maxLayer;
	for i = startID - 1 , startID + self.headIconConsts  do
		local vo = {};
		local babelCfg = t_doupocangqiong[i];
		if not babelCfg then
			print('not babelLayer ----' .. i);
		end
		if babelCfg then
			local bossCfg = t_monster[babelCfg.bossId];
			if not bossCfg then print('not monsterID`t_monster!!!!') return end
			if i == startID then
				self.initLayerID = i;
				self.lastLayerID = i;
			end
			vo.name = bossCfg.name;
			if i > myMaxLayer then
				vo.bossheadURl = ImgUtil:GetGrayImgUrl(ResUtil:GetMonsterIconName(babelCfg.icon));
			else
				vo.bossheadURl = ResUtil:GetMonsterIconName(babelCfg.icon);
			end
			vo.id = i
			local one = "第";
			local two = "层"
			vo.layer = one..i..two;
		end
		objSwf.titleBar.babelTitleList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.titleBar.babelTitleList:invalidateData();
	if self.initLayerID == nowLayer then
		objSwf.titleBar.babelTitleList.selectedIndex = 1;
	end
	if startIndex then
		objSwf.titleBar.babelTitleList.selectedIndex = 1 + startIndex;
	end
end

UIBabel.lastLayerID = 0;
function UIBabel:TitleListClick(id)
	self.lastLayerID = id;
	-- print("点击item:",id)
	BabelController:OnGetBabelInfo(id);
end

function UIBabel:OnHeadNextHandler()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if self.tweening then return end
	local cfg = t_doupocangqiong[self.initLayerID + self.headIconConsts - 1];
	if not cfg then print('self.initLayerID' , 'self.headIconConsts',self.initLayerID , self.headIconConsts,self.initLayerID + self.headIconConsts)return end
	local babelData = BabelModel.babelData;
	local nowLayer = babelData.layer;
	if not nowLayer then return end
	BabelController:OnGetBabelInfo(nowLayer + 1);
	if objSwf.titleBar.babelTitleList.selectedIndex <= self.headIconConsts - 1 then
		objSwf.titleBar.babelTitleList.selectedIndex = objSwf.titleBar.babelTitleList.selectedIndex + 1
		return
	end
	self.lastLayerID = 0;
	if self.initLayerID > #t_doupocangqiong - self.headIconConsts then
		print('self.initLayerID',self.initLayerID,'#t_doupocangqiong - self.headIconConsts',#t_doupocangqiong - self.headIconConsts)
		return
	end
	self:OnTweenNext();
end

function UIBabel:OnHeadLastHandler()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if self.tweening then return end
	local babelData = BabelModel.babelData;
	local nowLayer = babelData.layer;
	if not nowLayer then return end
	local cfg = t_doupocangqiong[nowLayer - 1];
	if not cfg then return end
	BabelController:OnGetBabelInfo(nowLayer - 1);
	if objSwf.titleBar.babelTitleList.selectedIndex > 1 then
		objSwf.titleBar.babelTitleList.selectedIndex = objSwf.titleBar.babelTitleList.selectedIndex - 1;
		return
	end
	self.initLayerID = self.initLayerID - 2;
	
	self.lastLayerID = 0;
	if self.initLayerID  < 0 then
		return
	end
	self:OnTweenLast();
end

UIBabel.TweenNum = 110;
function UIBabel:OnTweenNext()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.tweening = true;
	objSwf.titleBar._y = objSwf.titleBar._y - self.TweenNum;
	Tween:To(objSwf.titleBar , 0.5,{_y = objSwf.titleBar._y + self.TweenNum},{onComplete = function ()
		self.tweening = false;
	end
	},false);
end

function UIBabel:OnTweenLast()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.tweening = true;
	objSwf.titleBar._y = objSwf.titleBar._y + self.TweenNum;
	Tween:To(objSwf.titleBar , 0.5,{_y = objSwf.titleBar._y - self.TweenNum},{onComplete = function ()
		self.tweening = false;
	end
	},false);
end

function UIBabel:DisabledChangeBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local babelData = BabelModel.babelData;
	local nowLayer = babelData.layer;
	objSwf.btn_headLast.disabled = nowLayer == 1;
	if nowLayer >= babelData.maxLayer + 4 or nowLayer == #t_doupocangqiong then
		objSwf.btn_headNext.disabled = true;
	else
		objSwf.btn_headNext.disabled = false;
	end
end

function UIBabel:OnChangePanelData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.pic_already._visible = false;
	objSwf.pic_open._visible = false;
	objSwf.pic_no._visible = false;
	local babelData = BabelModel.babelData;
	local cfg = t_doupocangqiong[babelData.layer];
	local bossId = cfg.bossId
	if not bossId then return end
	local monsterCfg = t_monster[bossId]
	if not monsterCfg then return end
	local monsterHp = monsterCfg.hp
	local maxTime = cfg.maxTime
	if not monsterHp or not maxTime then
		Debug("not find monster Hp or not find maxTime.....")
		return
	end
	local minAtt = math.floor(monsterHp / maxTime)
	objSwf.txt_minAtt.htmlText = minAtt; --最低秒伤
	objSwf.rewardlist.txt_needLv.htmlText = PublicUtil.GetString("babel014", MainPlayerModel.humanDetailInfo.eaLevel < cfg.level and "#ff0000" or "#00ff00", cfg.level)
	objSwf.rewardlist.txt_max.htmlText = string.format(StrConfig['babel006'],babelData.maxLayer);
	objSwf.rewardlist.txt_maxNum.htmlText = string.format(StrConfig['babel007'],babelData.num,2) .. ''; --剩余次数
	local total = BabelModel:GetTotalTimes()
	objSwf.rewardlist.txt_dayNum.htmlText = string.format(StrConfig['babel011'],(babelData.daikyNum or 0),total) .. ''; --总剩余次数
	
	self:OnListIcon(cfg);  --show出两个list
--	self:OnTweenHandler();

--文本BOSS名字txt_bossName
	local bossCfg = t_monster[cfg.bossId];
	objSwf.txt_bossName.text = bossCfg.name;
	if self.tweenState == 0 then
		self:OnBossDraw();
	else
		self:OnTweenHandler();
	end
	
	objSwf.rewardlist.btn_sweep.visible = babelData.layer <= babelData.maxLayer;
	objSwf.rewardlist.btn_challenges.visible = babelData.layer <= babelData.maxLayer;
	objSwf.rewardlist.btn_challenge.visible = babelData.layer > babelData.maxLayer;
end

function UIBabel:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if sec < 10 then sec = '0' .. sec; end 
	return min,sec
end

--滚动
-- UIBabel.oldLayer = nil;
-- UIBabel.nowLayer = nil;
function UIBabel:OnTweenHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.tweenState == 1 then
		objSwf.bossPanel._y = objSwf.bossPanel._y + 355;
		self:OnBossDraw();
		Tween:To(objSwf.bossPanel , 0.5,{_y = objSwf.bossPanel._y - 355},{onComplete = function ()
			self:OnTweenComplete();
		end
		},false);
	else
		objSwf.bossPanel._y = objSwf.bossPanel._y - 355;
		self:OnBossDraw();
		Tween:To(objSwf.bossPanel , 0.5,{_y = objSwf.bossPanel._y + 355},{onComplete = function ()
			self:OnTweenComplete();
		end
		},false);
	end
end

function UIBabel:OnTweenComplete()
	local objSwf = self.objSwf;
	self.tweenState = 0;
	self.tweening = false;
	--objSwf.bossPanel._y = -520.25;
	--self:OnBossDraw();
end

-- 创建配置文件
UIBabel.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(900,600),
									Rotation = 0
								  };
function UIBabel:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	return cfg;
end

--画出BOSS
function UIBabel:OnBossDraw()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local obj = {};
	obj[1] = BabelModel:GetNowLayer() - 1;
	obj[2] = BabelModel:GetNowLayer();
	obj[3] = BabelModel:GetNowLayer() + 1;
	local babelCfg = t_doupocangqiong[obj[2]];
	if not babelCfg then return end
	self:DisabledChangeBtn();
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	local nowMonsterAvater = {};
	for i = 1 , 3 do
		if obj[#obj - i + 1] < 1 or obj[#obj - i + 1] > #t_doupocangqiong then
			if self['objUIDraw' .. i] then
				self['objUIDraw' .. i]:SetDraw(false);
				self['objUIDraw' .. i]:SetMesh(nil);
			end
		else
			local bossId = t_doupocangqiong[obj[#obj - i + 1]].bossId;
			local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,bossId);
			monsterAvater:InitAvatar();
			local drawcfg = UIDrawBabelBossCfg[bossId];
			if i == 2 then
				nowMonsterAvater = monsterAvater;
			end
			if not drawcfg then 
				drawcfg = self:GetDefaultCfg();
			end
			if not self['objUIDraw' .. i] then 
				self['objUIDraw' .. i] = UIDraw:new("babelBoss" .. i,monsterAvater, objSwf.bossPanel['boss' .. i],  
				drawcfg.VPort,   drawcfg.EyePos,  
				drawcfg.LookPos,  0x00000000, "Babel" );
			else
				self['objUIDraw' .. i]:SetUILoader(objSwf.bossPanel['boss' .. i]);
				self['objUIDraw' .. i]:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
				self['objUIDraw' .. i]:SetMesh(monsterAvater);
			end;
			local openIndex = obj[#obj - i + 1];
			if openIndex > BabelModel:GetTallestLayer() + 1 then
				if i == 2 then
					objSwf.pic_no._visible = true;
					objSwf.num_level.htmlText = string.format(StrConfig["babel807"],babelCfg.level);
					objSwf.num_level._visible = myLevel < babelCfg.level;
				end
				self['objUIDraw' .. i]:SetGrey(true);
			elseif openIndex == BabelModel:GetTallestLayer() + 1 then
				if i == 2 then
					self.objSwf.pic_open._visible = myLevel >= babelCfg.level;
					objSwf.num_level.htmlText = string.format(StrConfig["babel807"],babelCfg.level);
					objSwf.num_level._visible = myLevel < babelCfg.level;
				end
				self['objUIDraw' .. i]:SetGrey(false);
			else
				if i == 2 then
					self.objSwf.pic_already._visible = true;
					objSwf.num_level.htmlText = string.format(StrConfig["babel807"],babelCfg.level);
					objSwf.num_level._visible = myLevel < babelCfg.level;
				end
				self['objUIDraw' .. i]:SetGrey(false);
			end
			
			self['objUIDraw' .. i]:SetDraw(true);
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function()
		local actionFile = {};
		local cfg = t_monster[t_doupocangqiong[BabelModel:GetNowLayer()].bossId];
		if BabelModel:GetNowLayer() > BabelModel:GetTallestLayer() then
			actionFile = t_model[cfg.modelId]['san_atk'];
		else
			nowMonsterAvater:StopAllAction();
			actionFile = t_model[cfg.modelId]['san_dead'];
		end
		nowMonsterAvater:DoAction(actionFile,false)
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,1);
	-- objSwf.openIcon._visible = objSwf.num_level.visible;
	if objSwf.pic_no._visible then
		objSwf.pic_no._visible = not objSwf.num_level._visible;
	end
end

--show出两个list
UIBabel.firstRewardItemId = nil;
function UIBabel:OnListIcon(cfg)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local isfirst = BabelModel.babelData.layer > BabelModel:GetTallestLayer();
	-- objSwf.rewardlist.firstList.visible = isfirst;
	-- objSwf.rewardlist.txt_equip._visible = isfirst;
	print("已一一一一一一一",isfirst,BabelModel.babelData.layer,BabelModel:GetTallestLayer())
	objSwf.rewardlist.getReward._visible = not isfirst
	-- if isfirst then
		objSwf.rewardlist.everyDayPic._visible = true;
		objSwf.rewardlist.firstPic._visible = true;
		objSwf.rewardlist.rewardList.dataProvider:cleanUp();
		objSwf.rewardlist.rewardList:invalidateData();
		objSwf.rewardlist.firstList.dataProvider:cleanUp();
		objSwf.rewardlist.firstList:invalidateData();
		
		local randomList = RewardManager:Parse(cfg.firstReward);
		objSwf.rewardlist.firstList.dataProvider:cleanUp();   --首通奖励
		objSwf.rewardlist.firstList.dataProvider:push(unpack(randomList));
		objSwf.rewardlist.firstList:invalidateData();
		
		local equipItem = t_equip[toint(split(split(cfg.firstReward,'#')[1],',')[1])];
		if not equipItem then
			-- objSwf.rewardlist.txt_equip._visible = false;
		end
	-- else
		-- objSwf.rewardlist.firstList.dataProvider:cleanUp();
		-- objSwf.rewardlist.firstList:invalidateData();
		objSwf.rewardlist.everyDayPic._visible = true;
		objSwf.rewardlist.firstPic._visible = true;
		local extrarewardCfg;
		local extrarewardStr;
		if cfg.extrareward then
			extrarewardCfg = split(cfg.extrareward,',');
			if extrarewardCfg then
				-- extrarewardStr = extrarewardCfg[1] .. ',' .. extrarewardCfg[2];
			else
				extrarewardStr = ''
			end
			
		end
		local rewardList = RewardManager:Parse(cfg.reward);   --按几率掉落   每日奖励
		objSwf.rewardlist.rewardList.dataProvider:cleanUp();
		objSwf.rewardlist.rewardList.dataProvider:push(unpack(rewardList));
		objSwf.rewardlist.rewardList:invalidateData();
	-- end
end
function UIBabel:ShowTrialScore()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playScore=MainPlayerModel.humanDetailInfo.eaTrialScore
	objSwf.Integralhtml.htmlText=playScore;
end
--关闭事件
function UIBabel:OnBeforeHide()
	if UIBabelRank:IsShow() then
		UIBabelRank:Hide();
	end
	return true;
end

-- function UIBabel:IsTween()
-- 	return true;
-- end

-- function UIBabel:GetPanelType()
-- 	return 1;
-- end

function UIBabel:IsShowSound()
	return true;
end

-- function UIBabel:IsShowLoading()
-- 	return true;
-- end

function UIBabel:HandleNotification(name,body)
	if name == NotifyConsts.BabelUpData then
		self:OnChangePanelData();
		self:OnShowTitleList();									-------绘制bosstitlelist
	elseif name == NotifyConsts.BabelSweep then
		self:ShowSweepReward(body.list,body.layerID);
		print("收到服务器扫荡通知.................")
	elseif name == NotifyConsts.BabelRankUpdate then
		self:OnChangeRankList()
    elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaTrialScore then
		   self:ShowTrialScore()
		end
	end
end

function UIBabel:ListNotificationInterests()
	return {
		NotifyConsts.BabelUpData,
		NotifyConsts.BabelSweep,
		NotifyConsts.BabelRankUpdate,
		NotifyConsts.PlayerAttrChange,
	}
end