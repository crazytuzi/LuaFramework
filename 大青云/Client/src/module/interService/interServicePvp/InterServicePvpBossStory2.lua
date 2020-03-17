--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceBossStory2 = BaseUI:new("UIInterServiceBossStory2");
UIInterServiceBossStory2.timeId = nil
UIInterServiceBossStory2.curSelected = 1

function UIInterServiceBossStory2:Create()
	self:AddSWF("interBossStory2Panel.swf", true, "interserver");
end

function UIInterServiceBossStory2:OnLoaded(objSwf)
	objSwf.mcStory.btnExit.click = function()
		local exitfunc = function ()
			InterServicePvpController:ReqQuitCrossBoss()
			self:Hide()
		end
		UIConfirm:Open(StrConfig["interServiceDungeon6"],exitfunc);
	end
	
	objSwf.mcStory.btnGo.click = function()
		self:goToKillMonster()
	end
	
	objSwf.mcStory.btnTab1.click = function()
		self:TabClick(1)
	end
	objSwf.mcStory.btnTab2.click = function()
		self:TabClick(2)
	end
	objSwf.mcStory.btnTab3.click = function()
		self:TabClick(3)
	end
	objSwf.mcStory.btnTab4.click = function()
		self:TabClick(4)
	end
	
	objSwf.mcStory.listtxt.rewardItemRollOver = function(e) 
		-- FPrint('///////////////////////////'..e.index)
		local itemId = InterServicePvpModel:GetRankRewardByLevel(e.index+1, self.curSelected)
		TipsManager:ShowItemTips(itemId);
	end
	objSwf.mcStory.listtxt.rewardItemRollOut = function(e) TipsManager:Hide(); end
	RewardManager:RegisterListTips( objSwf.mcStory.rewardList )
	
	objSwf.mcZhuizong.click = function() 
		objSwf.mcZhuizong.visible = false
		objSwf.mcStory._visible = true
		objSwf.mcStory.hitTestDisable = false
	end
	
	objSwf.mcStory.btnColse.click = function() 
		objSwf.mcZhuizong.visible = true
		objSwf.mcStory._visible = false
		objSwf.mcStory.hitTestDisable = true
	end	
	
	objSwf.mcStory.btnPre.click  = function() self:OnBtnPreClick(); end
	objSwf.mcStory.btnNext.click = function() self:OnBtnNextClick(); end
	
	objSwf.mcStory.txtTitle1.text = StrConfig['interServiceDungeon37']
	objSwf.mcStory.txtTitle2.text = StrConfig['interServiceDungeon38']
	objSwf.mcStory.txtTitle3.text = StrConfig['interServiceDungeon39']
	objSwf.mcStory.txtTitle4.text = StrConfig['interServiceDungeon40']
	objSwf.mcStory.txtleiji.text = StrConfig['interServiceDungeon41']
	objSwf.mcStory.txtjianglifafang.text = StrConfig['interServiceDungeon42']
	
	objSwf.mcStory.btnshouhu1.click = function()
		self:goToKillShouhu(1)
	end
	objSwf.mcStory.btnshouhu2.click = function()
		self:goToKillShouhu(2)
	end
	objSwf.mcStory.btnshouhu3.click = function()
		self:goToKillShouhu(3)
	end
	objSwf.mcStory.btnshouhu4.click = function()
		self:goToKillShouhu(4)
	end
	
	objSwf.mcStory.btnshouhu1.rollOver = function()
		self:OnBuffItemOver(1)
	end
	objSwf.mcStory.btnshouhu2.rollOver = function()
		self:OnBuffItemOver(2)
	end
	objSwf.mcStory.btnshouhu3.rollOver = function()
		self:OnBuffItemOver(3)
	end
	objSwf.mcStory.btnshouhu4.rollOver = function()
		self:OnBuffItemOver(4)
	end
	
	objSwf.mcStory.btnshouhu1.rollOut = function()
		TipsManager:Hide();
	end
	objSwf.mcStory.btnshouhu2.rollOut = function()
		TipsManager:Hide();
	end
	objSwf.mcStory.btnshouhu3.rollOut = function()
		TipsManager:Hide();
	end
	objSwf.mcStory.btnshouhu4.rollOut = function()
		TipsManager:Hide();
	end
end

--BuffItem tips
function UIInterServiceBossStory2:OnBuffItemOver(buffType)
	local cfg = _G.CrossBossStatueConfig[buffType]
	local buffCfg = t_buff[cfg.buff]
	local statueList = InterServicePvpModel.statueList
	local str = '<textformat leftmargin="5">'
	str = str ..'<font color="#ffcc33" size="16">'.. buffCfg.name ..'</font><br/>'
	str = str .. '<font color="#dcdcdc" size="14">'.. buffCfg.des ..'</font><br/>'
	str = str .. '<font color="#dcdcdc" size="14">占领守卫后，本服成员可获得属性加成' ..'</font><br/>'
	if statueList and statueList[buffType] then
		local sid = InterServicePvpModel:GetGroupId()
		FPrint('自己的服务器id'..sid)
		if statueList[buffType].groupid == sid then
			str = str .. '<font size = "14" color="#2FE00D">当前已占领，点击前往</font>'
		else
			str = str .. '<font size = "14" color="#CC0000">当前未占领，点击前往</font>'
		end
	end
	str = str .. '</textformat>'
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIInterServiceBossStory2:OnBtnPreClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.mcStory.rewardList;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos - 1;
	self:CheckNavigateBtnState();
end

function UIInterServiceBossStory2:OnBtnNextClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.mcStory.rewardList;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos + 1;
	self:CheckNavigateBtnState();
end

function UIInterServiceBossStory2:CheckNavigateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.mcStory.rewardList;
	objSwf.mcStory.btnPre.disabled = list.scrollPosition <= 0;
	local numUnionDungeon = list.dataProvider.length;
	local numOnePage = 5;
	objSwf.mcStory.btnNext.disabled = list.scrollPosition >= numUnionDungeon - numOnePage;
end

--杀怪
function UIInterServiceBossStory2:goToKillMonster()
	FPrint('杀怪'..self.curSelected)
	local point = _G.CrossBossConfig[self.curSelected]
	if not point then return end

	local completeFuc = function()
		AutoBattleController:OpenAutoBattle()
	end
	
	local mapId = t_consts[160].val3
	MainPlayerController:DoAutoRun(mapId,_Vector3.new(point.x,point.y,0),completeFuc)
end

--杀怪
function UIInterServiceBossStory2:goToKillShouhu(shouhuType)
	FPrint('雕像1')
	local point = _G.CrossBossStatueConfig[shouhuType]
	if not point then return end
	FPrint('雕像2')
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle()
	end
	
	local mapId = t_consts[160].val3
	MainPlayerController:DoAutoRun(mapId,_Vector3.new(point.x,point.y,0),completeFuc)
end

-----------------------------------------------------------------------
function UIInterServiceBossStory2:IsTween()
	return false;
end

function UIInterServiceBossStory2:GetPanelType()
	return 0;
end

function UIInterServiceBossStory2:IsShowSound()
	return false;
end

function UIInterServiceBossStory2:Update()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	if not InterServicePvpModel.bossStatus then return end
	objSwf.mcStory.actTime.text = DungeonUtils:ParseTime(InterServicePvpModel.bossStatus.remainsec)
end

function UIInterServiceBossStory2:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	objSwf.mcZhuizong.visible = false
	objSwf.mcStory._visible = true
	objSwf.mcStory.hitTestDisable = false
	
	if not InterServicePvpModel.bossStatus then return end
	
	if InterServicePvpModel.bossStatus.status == 2 then
		self.curSelected = 5
	else
		self.curSelected = 1
	end
	self:UpdateBossState()
end

function UIInterServiceBossStory2:TabClick(bossType)
	self.curSelected = bossType
	self:UpdateRankList()
	self:UpdateBossState()
end

function UIInterServiceBossStory2:UpdateRankList()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

	local rankList = InterServicePvpModel.bossRank[self.curSelected]
	FTrace(rankList, '排行列表'..self.curSelected)
	local isRank = false
	if rankList then
		local voc = {}
		for i,info in ipairs(rankList) do
			local vo = InterServicePvpModel:GetRoleItemUIdata(info)
			local playName = MainPlayerModel.humanDetailInfo.eaName;
			if vo then 
				table.push(voc,vo)
			end
			
			if info.name == playName then 
				objSwf.mcStory.txtMyRankinfo.htmlText = '<font color = "#2FE00D">'..info.rank..'</font>'
				isRank = true
			end
		end;
		objSwf.mcStory.listtxt.dataProvider:cleanUp();
		objSwf.mcStory.listtxt.dataProvider:push(unpack(voc));
		objSwf.mcStory.listtxt:invalidateData();
	end	
	
	if not isRank then
		objSwf.mcStory.txtMyRankinfo.htmlText = '<font color = "#CC0000">'..StrConfig['interServiceDungeon45']..'</font>'
	end
	self:UpdateTotalAward()	
end

function UIInterServiceBossStory2:UpdateTotalAward()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

	local reward = InterServicePvpModel:GetTotalReward()
	objSwf.mcStory.rewardList.dataProvider:cleanUp()
	objSwf.mcStory.rewardList.dataProvider:push( unpack( RewardManager:Parse( reward ) ) )
	objSwf.mcStory.rewardList:invalidateData()
	self:CheckNavigateBtnState();
end

local bossStatusStr = {StrConfig['interServiceDungeon48'],StrConfig['interServiceDungeon49'],StrConfig['interServiceDungeon50']}
function UIInterServiceBossStory2:UpdateBossState()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	if not InterServicePvpModel.bossStatus then return end
	
	if InterServicePvpModel.bossStatus.status == 2 then
		self.curSelected = 5
		objSwf.mcStory.btnTab1.visible = false
		objSwf.mcStory.btnTab2.visible = false
		objSwf.mcStory.btnTab3.visible = false
		objSwf.mcStory.btnTab4.visible = false		
		
		local playerLevel = InterServicePvpModel.bossStatus.level
		local bossCfg = t_kuafuboss[playerLevel]
		if bossCfg then 
			local monsterCfg = t_monster[bossCfg.boss]
			if monsterCfg then
				objSwf.mcStory.txtBigBossName.text = monsterCfg.name			
			end
		end		
	else
		objSwf.mcStory.btnTab1.visible = true
		objSwf.mcStory.btnTab2.visible = true
		objSwf.mcStory.btnTab3.visible = true
		objSwf.mcStory.btnTab4.visible = true
		objSwf.mcStory.txtBigBossName.text = ''		
		
		local playerLevel = InterServicePvpModel.bossStatus.level
		local bossCfg = t_kuafuboss[playerLevel]
		
		if bossCfg then 
			local monsterCfg = t_monster[bossCfg.monster1]
			if monsterCfg then				
				objSwf.mcStory.btnTab1.label = monsterCfg.name			
			end
			monsterCfg = t_monster[bossCfg.monster2]
			if monsterCfg then
				objSwf.mcStory.btnTab2.label = monsterCfg.name			
			end
			monsterCfg = t_monster[bossCfg.monster3]
			if monsterCfg then
				objSwf.mcStory.btnTab3.label = monsterCfg.name			
			end
			monsterCfg = t_monster[bossCfg.monster4]
			if monsterCfg then
				objSwf.mcStory.btnTab4.label = monsterCfg.name			
			end
		end		
	end
	
	local bossStatus = InterServicePvpModel.statusList[self.curSelected]
	if bossStatus then
		local showStr = bossStatusStr[bossStatus.status + 1]
		if bossStatus.status == 1 then
			objSwf.mcStory.txtBossState.htmlText = '<font color = "#2FE00D">'..showStr..'</font>'
		else
			objSwf.mcStory.txtBossState.htmlText = showStr
		end
	end
	
	local statueList = InterServicePvpModel.statueList
	if statueList then
		for k,v in ipairs(statueList) do
			local sid = InterServicePvpModel:GetGroupId()
			FPrint('自己的服务器id'..sid)
			if v.groupid == sid then
				objSwf.mcStory['btnshouhu'..k].htmlLabel = '<u><font color = "#2FE00D">'..StrConfig['interServiceDungeon5'..k]..'</font></u>'
			else
				objSwf.mcStory['btnshouhu'..k].htmlLabel = '<u><font color = "#CC0000">'..StrConfig['interServiceDungeon5'..k]..'</font></u>'
			end
		end
	end

	self:UpdateTotalAward()	
end

function UIInterServiceBossStory2:OnHide()
	-- if self.timeId then
		-- TimerManager:UnRegisterTimer(self.timeId)
		-- self.timeId = nil
	-- end
	-- if self.confirmID then
		-- UIConfirm:Close(self.confirmID);
	-- end
end

function UIInterServiceBossStory2:GetWidth()
	return 369;
end

function UIInterServiceBossStory2:GetHeight()
	return 541;
end

function UIInterServiceBossStory2:OnBtnCloseClick()
	self:Hide();
end

function UIInterServiceBossStory2:OnDelete()
	
end




---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceBossStory2:ListNotificationInterests()
	return {
		NotifyConsts.ISKuafuBossRankList,
		NotifyConsts.ISKuafuBossInfoRefresh
	};
end

--处理消息
function UIInterServiceBossStory2:HandleNotification(name, body)
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.ISKuafuBossRankList then
		self:UpdateRankList()
	elseif name == NotifyConsts.ISKuafuBossInfoRefresh then
		self:UpdateBossState()
	end	
end

