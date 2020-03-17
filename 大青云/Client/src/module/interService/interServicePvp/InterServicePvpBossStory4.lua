--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceBossStory4 = BaseUI:new("UIInterServiceBossStory4");
UIInterServiceBossStory4.timeId = nil
UIInterServiceBossStory4.BaoxiangTime = _G.CrossBossTimeConfig[1]*60
UIInterServiceBossStory4.countDownTime = 0

function UIInterServiceBossStory4:Create()
	self:AddSWF("interBossStory4Panel.swf", true, "interserver");
end

function UIInterServiceBossStory4:OnLoaded(objSwf)
	objSwf.mcStory.btnExit.click = function()			
		local exitfunc = function ()
			InterServicePvpController:ReqQuitCrossBoss()
			self:Hide()
		end
		UIConfirm:Open(StrConfig["interServiceDungeon6"],exitfunc);
	end
	
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
	
	RewardManager:RegisterListTips( objSwf.mcStory.rewardList )
	objSwf.mcStory.btnPre.click  = function() self:OnBtnPreClick(); end
	objSwf.mcStory.btnNext.click = function() self:OnBtnNextClick(); end
	
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
	
	objSwf.mcStory.numLoaderFight.loadComplete = function ()		
		objSwf.mcStory.numLoaderFight._x = objSwf.mcStory.rankPos._x - objSwf.mcStory.numLoaderFight._width * 0.5;
		objSwf.mcStory.numLoaderFight._y = objSwf.mcStory.rankPos._y - objSwf.mcStory.numLoaderFight._height * 0.5;
	end
end

--BuffItem tips
function UIInterServiceBossStory4:OnBuffItemOver(buffType)
	local cfg = _G.CrossBossStatueConfig[buffType]
	local buffCfg = t_buff[cfg.buff]
	local statueList = InterServicePvpModel.statueList
	local str = '<textformat leftmargin="5">'
	str = str ..'<font color="#ffcc33" size="16">'.. buffCfg.name ..'</font><br/>'
	str = str .. '<font color="#dcdcdc" size="14">'.. buffCfg.des ..'</font><br/>'
	str = str .. '<font color="#dcdcdc" size="14">占领守卫后，本服成员可获得属性加成' ..'</font><br/>'
	if statueList and statueList[buffType] then
		if statueList[buffType].status == 1 then
			str = str .. '<font size = "14" color="#2FE00D">当前已占领，点击前往</font>'
		else
			str = str .. '<font size = "14" color="#CC0000">当前未占领，点击前往</font>'
		end
	end
	str = str .. '</textformat>'
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIInterServiceBossStory4:OnBtnPreClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.mcStory.rewardList;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos - 1;
	self:CheckNavigateBtnState();
end

function UIInterServiceBossStory4:OnBtnNextClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.mcStory.rewardList;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos + 1;
	self:CheckNavigateBtnState();
end

function UIInterServiceBossStory4:CheckNavigateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.mcStory.rewardList;
	objSwf.mcStory.btnPre.disabled = list.scrollPosition <= 0;
	local numUnionDungeon = list.dataProvider.length;
	local numOnePage = 5;
	FPrint(numUnionDungeon..','..list.scrollPosition)
	objSwf.mcStory.btnNext.disabled = list.scrollPosition >= numUnionDungeon - numOnePage;
end


--杀怪
function UIInterServiceBossStory4:goToKillShouhu(shouhuType)
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
function UIInterServiceBossStory4:IsTween()
	return false;
end

function UIInterServiceBossStory4:GetPanelType()
	return 0;
end

function UIInterServiceBossStory4:IsShowSound()
	return false;
end

function UIInterServiceBossStory4:Update()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	if not InterServicePvpModel.bossStatus then return end
	objSwf.mcStory.actTime.text = DungeonUtils:ParseTime(InterServicePvpModel.bossStatus.remainsec)
end

function UIInterServiceBossStory4:UpdateBaoxiang()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

	self:UpdateTotalAward()
	objSwf.mcStory.txtbaoxiang.text = InterServicePvpModel.treasurenum
end

function UIInterServiceBossStory4:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	objSwf.mcZhuizong.visible = false
	objSwf.mcStory._visible = true
	objSwf.mcStory.hitTestDisable = false
	
	self:ResetCountDown()
	self:UpdateBaoxiang()
	objSwf.mcStory.txtRefreashTime.text = string.format(StrConfig['interServiceDungeon43'], _G.CrossBossTimeConfig[1])
	objSwf.mcStory.txtjishabaoxiang.text = StrConfig['interServiceDungeon44']
	objSwf.mcStory.txtleiji.text = StrConfig['interServiceDungeon41']
	objSwf.mcStory.txtjianglifafang.text = StrConfig['interServiceDungeon42']
end

function UIInterServiceBossStory4:ResetCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

	-- FPrint('倒计时1')
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	
	if not InterServicePvpModel.bossStatus or not InterServicePvpModel.bossStatus.baoxiangremainsec or InterServicePvpModel.bossStatus.baoxiangremainsec <= 0 then
		self.countDownTime = UIInterServiceBossStory4.BaoxiangTime
	end
	-- FPrint('倒计时2'..self.countDownTime)
	self.timeId = TimerManager:RegisterTimer(function()
					if self.countDownTime <= 0 then 
						self.countDownTime = UIInterServiceBossStory4.BaoxiangTime
						return 
					end
					-- FPrint('倒计时3')
					objSwf.mcStory.numLoaderFight.num = self.countDownTime
					self.countDownTime = self.countDownTime - 1		
				end,1000,0)
	
	local statueList = InterServicePvpModel.statueList
	if statueList then
		for k,v in ipairs(statueList) do
			if v.status == 1 then
				objSwf.mcStory['btnshouhu'..k].htmlLabel = '<u><font color = "#2FE00D">'..StrConfig['interServiceDungeon5'..k]..'</font></u>'
			else
				objSwf.mcStory['btnshouhu'..k].htmlLabel = '<u><font color = "#CC0000">'..StrConfig['interServiceDungeon5'..k]..'</font></u>'
			end
		end
	end
end

function UIInterServiceBossStory4:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	-- if self.confirmID then
		-- UIConfirm:Close(self.confirmID);
	-- end
end

function UIInterServiceBossStory4:GetWidth()
	return 369;
end

function UIInterServiceBossStory4:GetHeight()
	return 541;
end

function UIInterServiceBossStory4:OnBtnCloseClick()
	self:Hide();
end

function UIInterServiceBossStory4:OnDelete()
	
end

function UIInterServiceBossStory4:UpdateTotalAward()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

	local reward = InterServicePvpModel:GetTotalReward()
	objSwf.mcStory.rewardList.dataProvider:cleanUp()
	objSwf.mcStory.rewardList.dataProvider:push( unpack( RewardManager:Parse( reward ) ) )
	objSwf.mcStory.rewardList:invalidateData()
	
	self:CheckNavigateBtnState()
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceBossStory4:ListNotificationInterests()
	return {
		NotifyConsts.ISKuafuBossBaoxiang,
		NotifyConsts.ISKuafuBossInfoRefresh
	};
end

--处理消息
function UIInterServiceBossStory4:HandleNotification(name, body)
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.ISKuafuBossBaoxiang then
		self:UpdateBaoxiang()
	elseif name == NotifyConsts.ISKuafuBossInfoRefresh then
		self:ResetCountDown()
	end
end

