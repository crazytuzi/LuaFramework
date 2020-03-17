--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceBossResult = BaseUI:new("UIInterServiceBossResult");
UIInterServiceBossResult.timeId = nil
UIInterServiceBossResult.showCount = 30

UIInterServiceBossResult.countDownTimeId = nil

function UIInterServiceBossResult:Create()
	self:AddSWF("interBossResultPanel.swf", true, "interserver");
end

function UIInterServiceBossResult:OnLoaded(objSwf)
	objSwf.btn_out.click = function()
		-- local exitfunc = function ()
			InterServicePvpController:ReqQuitCrossBoss()
			self:Hide()
		-- end
		-- UIConfirm:Open(StrConfig["interServiceDungeon6"],okfun);
	end
	
	RewardManager:RegisterListTips( objSwf.rewardList2 )	
	RewardManager:RegisterListTips( objSwf.rewardList1 )
	objSwf.txtTuichu.text = StrConfig['interServiceDungeon35']
end

-----------------------------------------------------------------------
function UIInterServiceBossResult:IsTween()
	return false;
end

function UIInterServiceBossResult:GetPanelType()
	return 0;
end

function UIInterServiceBossResult:IsShowSound()
	return false;
end

function UIInterServiceBossResult:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	
	self.showCount = 30
	objSwf.txt_time.text = self.showCount
	self.timeId = TimerManager:RegisterTimer(function()
					if self.showCount <= 0 then 
						TimerManager:UnRegisterTimer(self.timeId)
						self.timeId = nil	
						InterServicePvpController:ReqQuitCrossBoss()
						self:Hide()
						return 
					end
					self.showCount = self.showCount - 1		
					objSwf.txt_time.text = self.showCount
				end,1000,30)
	self:UpdateResultInfo()	
end

function UIInterServiceBossResult:OnHide()
	
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end	
end

function UIInterServiceBossResult:UpdateResultInfo()	
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	local i = 1
	for k,v in pairs(InterServicePvpModel.bossResult.rankList) do
		if v.rank <= 0 or v.rank > 10 then
			objSwf['txt_rank'..i].htmlText = '<font color="#cc0000">'..StrConfig['interServiceDungeon45']..'</font>'				
		else
			objSwf['txt_rank'..i].htmlText = v.rank		
		end
		if v.result == 1 then
			objSwf['txtKill'..i].htmlText = StrConfig['interServiceDungeon46']
		else
			objSwf['txtKill'..i].htmlText = '<font color="#cc0000">'..StrConfig['interServiceDungeon47']..'</font>'		
		end
		i = i + 1
	end
	objSwf.txt_baoxiangshu.text = InterServicePvpModel.bossResult.treasurenum
	
	local reward = InterServicePvpModel:GetRankReward()
	objSwf.rewardList2.dataProvider:cleanUp()
	objSwf.rewardList2.dataProvider:push( unpack( RewardManager:Parse( reward ) ) )
	objSwf.rewardList2:invalidateData()
	
	local reward = InterServicePvpModel:GetBaoxiangReward()
	objSwf.rewardList1.dataProvider:cleanUp()
	objSwf.rewardList1.dataProvider:push( unpack( RewardManager:Parse( reward ) ) )
	objSwf.rewardList1:invalidateData()
	
	local playerLevel = InterServicePvpModel.bossStatus.level
	local bossCfg = t_kuafuboss[playerLevel]
	if bossCfg then 
		local monsterCfg = t_monster[bossCfg.monster1]
		if monsterCfg then
			objSwf.txt_name1.text = monsterCfg.name			
		end
		monsterCfg = t_monster[bossCfg.monster2]
		if monsterCfg then
			objSwf.txt_name2.text = monsterCfg.name			
		end
		monsterCfg = t_monster[bossCfg.monster3]
		if monsterCfg then
			objSwf.txt_name3.text = monsterCfg.name			
		end
		monsterCfg = t_monster[bossCfg.monster4]
		if monsterCfg then
			objSwf.txt_name4.text = monsterCfg.name			
		end
		monsterCfg = t_monster[bossCfg.boss]
		if monsterCfg then
			objSwf.txt_name5.text = monsterCfg.name			
		end
	end
end

function UIInterServiceBossResult:GetWidth()
	return 938;
end

function UIInterServiceBossResult:GetHeight()
	return 473;
end

function UIInterServiceBossResult:OnBtnCloseClick()
	self:Hide();
end

function UIInterServiceBossResult:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceBossResult:ListNotificationInterests()
	-- return {
		-- NotifyConsts.ISKuafuBossResultRankList
	-- };
end

--处理消息
function UIInterServiceBossResult:HandleNotification(name, body)
	-- if not self:IsShow() then
		-- return
	-- end 

	-- if name == NotifyConsts.ISKuafuBossResultRankList then
		-- self:UpdateResultInfo()	
	-- end	
end

