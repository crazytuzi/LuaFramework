--[[封妖界面
zhangshuhui
2014年12月04日14:20:20
]]

_G.UIFengYao = BaseUI:new("UIFengYao")

--封妖难度
UIFengYao.btnlevellist = {}
--奖励
UIFengYao.btnjianglilist = {}
--积分奖励tipsID
UIFengYao.rewardTop = {};
--宝箱
UIFengYao.btnboxlist = {}
UIFengYao.fengyaocount = 5--封妖数
UIFengYao.jianglicount = 3--奖励数
UIFengYao.boxcount = 6--宝箱数
UIFengYao.allneedstore = 0--积分总数
UIFengYao.isUIFengYaoBoxTips=false;--是否为封妖宝箱tips

UIFengYao.isopenfengyin = false;

UIFengYao.curModel = nil;

--封妖刷新后经过的时间
UIFengYao.timelast = 0; 
--距离下次刷新的时间
UIFengYao.remaintime = 0;
--剩余时间定时器key
UIFengYao.lastTimerKey = nil;

--封妖间隔播放一次动作
UIFengYao.actiontime = 0; 
--播放动作前的延迟时间
UIFengYao.beforeplaytime = 0;
UIFengYao.isbeforeplay = false;

-- 是否返回了刷新信息 返回刷新信息前不允许继续刷新难度
--UIFengYao.isreturnrefreshinfo = true;

function UIFengYao:Create()
	self:AddSWF("fengyaoPanel.swf", true, "center")
end

function UIFengYao:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.btnmoney.click = function() self:OnBtnMoneyGetClick() end--银两领取
	objSwf.btnyuanbaoGet.click = function() self:OnBtnYuanBaoGetClick() end--元宝领取
	objSwf.btnyuanbao.click = function() self:OnBtnYuanBaoClick() end--元宝刷新
	
	objSwf.btnmoney.rollOver = function() self:OnBtnMoneyOver(); end
	objSwf.btnmoney.rollOut = function() TipsManager:Hide(); end
	objSwf.btnyuanbaoGet.rollOver = function() self:OnBtnYuanbaoGetOver(); end
	objSwf.btnyuanbaoGet.rollOut = function() TipsManager:Hide(); end
	objSwf.btnyuanbao.rollOver = function() self:OnBtnYuanBaoOver(); end
	objSwf.btnyuanbao.rollOut = function() TipsManager:Hide(); end
	objSwf.btnGoTo.rollOver = function() self:OnBtnGoToOver(); end
	objSwf.btnGoTo.rollOut = function() TipsManager:Hide(); end
	
	objSwf.btnGoTo.click = function() self:OnBtnMoneyClick() end--银两刷新
	objSwf.btnTeleport.click = function() self:OnBtnTeleportClick() end
	objSwf.btnTeleport.rollOver = function() self:OnBtnTeleportRollOver() end
	objSwf.btnTeleport.rollOut = function() self:OnBtnTeleportRollOut() end
	objSwf.btnGetReward.click = function() self:OnBtnGetRewardClick() end
	
	objSwf.tfKillNum.click = function() self:OnbtnFindRoadClick() end
	
	objSwf.btnstaterefresh.click = function() self:OnBtnStateRefreshClick() end
	objSwf.btnstaterefresh.rollOver = function() self:OnStateRefreshRollOver(); end
	objSwf.btnstaterefresh.rollOut = function() TipsManager:Hide(); end
	
	objSwf.btnScoreReward.click = function() self:OnBtnGetScoreClick() end
	
	for i = 1 ,6 do
		local rewardID = split(t_fengyaojifen[i].itemReward,",");
		self.rewardTop[i] = tonumber(rewardID[1]);
	end
	
	self:UpdateGetBtnText();
	
	--难度
	self.btnlevellist = {}
	for i=1,self.fengyaocount do
		self.btnlevellist[i] = objSwf["fengyaolevel"..i];
	end
	
	for k=1, self.fengyaocount do
		self.btnlevellist[k].btnlevel.rollOver = function() self:OnbtnLevelRollOver(k); end
		self.btnlevellist[k].btnlevel.rollOut = function() TipsManager:Hide(); end
		self.btnlevellist[k].imgselect.rollOver = function() self:OnbtnLevelRollOver(k); end
		self.btnlevellist[k].imgselect.rollOut = function() TipsManager:Hide(); end
		self.btnlevellist[k].btnleveltip.rollOver = function() self:OnbtnLevelRollOver(k); end
		self.btnlevellist[k].btnleveltip.rollOut = function() TipsManager:Hide(); end
	end
	
	self.btnjianglilist = {}
	self.btnjianglilist[1] = objSwf.jiangli1;
	self.btnjianglilist[2] = objSwf.jiangli2;
	self.btnjianglilist[3] = objSwf.jiangli3;
	
	--宝箱
	self.btnboxlist = {}
	self.btnboxlist[1] = objSwf.boxlevel1;
	self.btnboxlist[2] = objSwf.boxlevel2;
	self.btnboxlist[3] = objSwf.boxlevel3;
	self.btnboxlist[4] = objSwf.boxlevel4;
	self.btnboxlist[5] = objSwf.boxlevel5;
	self.btnboxlist[6] = objSwf.boxlevel6;
	
	for i=1, self.boxcount do
		objSwf["rewardList"..i].itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id);  end
		objSwf["rewardList"..i].itemRollOut = function () TipsManager:Hide(); end
		objSwf["tfScoreReName"..i].text = t_item[self.rewardTop[i]].name
		objSwf["btnTips"..i].click = function() self:OnBtnGetBoxClick(i); end
		objSwf["btnTips"..i].rollOver = function() TipsManager:ShowItemTips(self.rewardTop[i]); end
		objSwf["btnTips"..i].rollOut = function() TipsManager:Hide(); end
		objSwf["canGetEffect"..i]._visible = false
		objSwf["hasGetSciore"..i]._visible = false
	end
	
	--规则
	objSwf.rulesBtn.rollOver = function() TipsManager:ShowBtnTips(StrConfig['fengyao9'],TipsConsts.Dir_RightDown); end
	objSwf.rulesBtn.rollOut = function() TipsManager:Hide(); end
	
	--发送邀请
	objSwf.lableyaoqing.click = function() self:OnbtnyaoqingClick(); end
	
	--TIP
	-- RewardManager:RegisterListTips(objSwf.rewardList);
	
	--封妖名称居中
	objSwf.iconname.loaded = function()
									objSwf.iconname.content._x = 0 - objSwf.iconname.content._width / 2
								end
	--积分奖励居中
	self.levelnumLoaderx = objSwf.boxlevel1.boxlevelnumLoader._x;
	for i=1,self.boxcount do
		objSwf["boxlevel"..i].boxlevelnumLoader.loadComplete = function()
									objSwf["boxlevel"..i].boxlevelnumLoader._x = self.levelnumLoaderx - objSwf["boxlevel"..i].boxlevelnumLoader.width / 2
								end
	end
								
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
	
	
	objSwf.tfrewardadd1._visible = false;
	objSwf.tfrewardadd2._visible = false;
	objSwf.tfrewardadd3._visible = false;
	objSwf.tffengyaonum._visible = false;
	objSwf.tfdaojishi._visible = false
	objSwf.tficonname._visible = false
	objSwf.modelload._visible = false
	objSwf.btnTeleport.visible = false
	-- objSwf.rewardList._visible = false
	
end
function UIFengYao:OnBtnMoneyGetClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
		--判断银两够不够
	if FengYaoUtil:IsHaveGoldRefresh() == false then
		FloatManager:AddNormal( StrConfig["fengyao5"], objSwf.btnmoney);
		return;
	end
	FengYaoController:ReqFengYaoLvlRefresh(1);
end
function UIFengYao:OnBtnYuanBaoGetClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--判断元宝够不够
	if FengYaoUtil:IsHaveMoneyRefresh() == false then
		FloatManager:AddNormal( StrConfig["fengyao6"], objSwf.btnyuanbao);
		return;
	end
	FengYaoController:ReqFengYaoLvlRefresh(2);
end
function UIFengYao:OnBtnGetScoreClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--达到积分条件
	local boxid = FengYaoUtil:IsNextNotGetBoxid();
	if boxid == 0 then
		FloatManager:AddNormal( StrConfig["fengyao11"], objSwf.btnScoreReward);
		return;
	end
	
	FengYaoController:ReqGetFengYaoBox(boxid)
end


function UIFengYao:IsShowLoading()
	return true;
end

function UIFengYao:IsTween()
	return true;
end

function UIFengYao:GetPanelType()
	return 1;
end

function UIFengYao:IsShowSound()
	return true;
end

function UIFengYao:GetWidth()
	return 1146;
end

function UIFengYao:GetHeight()
	return 687;
end

function UIFengYao:OnShow(name)
	--初始化数据
	self:InitData();
	--申请数据
	-- self:ReqFengYaoList();
	--显示
	self:ShowFengYao(false);
	self:updataScoreReward()
	--开启计时器
	-- self:StartLastTimer();
	self:StopTimer()
	self:StartTimer();
	--播放打开菜单封妖特效
	self:PlayOpenFengyinEffect();
end

function UIFengYao:OnHide()
	self:DelTimerKey();
	self:StopTimer();
	-- for k,_ in pairs(self.btnlevellist) do
	-- 	self.btnlevellist[k] = nil;
	-- end
	-- for k,_ in pairs(self.btnjianglilist) do
	-- 	self.btnjianglilist[k] = nil;
	-- end
	-- for k,_ in pairs(self.btnboxlist) do
	-- 	self.btnboxlist[k] = nil;
	-- end
	-- for k,_ in pairs(self.rewardTop) do
	-- 	self.rewardTop[k] = nil;
	-- end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.curModel then
		self.curModel = nil
	end
	UIConfirm:Close(self.confirmID);
	RemindController:AddRemind(RemindConsts.Type_FengYao,0);
end

function UIFengYao:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	for k,_ in pairs(self.btnlevellist) do
		self.btnlevellist[k] = nil;
	end
	for k,_ in pairs(self.btnjianglilist) do
		self.btnjianglilist[k] = nil;
	end
	for k,_ in pairs(self.btnboxlist) do
		self.btnboxlist[k] = nil;
	end
	for k,_ in pairs(self.rewardTop) do
		self.rewardTop[k] = nil;
	end
end
function UIFengYao:OnFullShow()
	if FengYaoModel.fengyaoinfo.fengyaoId ~= 0 then
		local fengyaovo = FengYaoUtil:GetFengYaoListVO(FengYaoModel.fengyaoinfo.fengyaoId);
		if fengyaovo then
			-- self:DrawMonster(fengyaovo.monsterid);
		end
	end
end

function UIFengYao:DelTimerKey()
	if self.lastTimerKey then
		TimerManager:UnRegisterTimer( self.lastTimerKey );
		self.lastTimerKey = nil;
		self.timelast = 0; 
		self.remaintime = 0;
		self.actiontime = 0;
	end
end

--点击关闭按钮
function UIFengYao:OnBtnCloseClick()
	self:Hide();
end

-------------------事件------------------
function UIFengYao:OnBtnMoneyClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	-- 未返回刷新难度前不允许再次刷新
	-- if self.isreturnrefreshinfo == false then
		-- print('================未返回刷新难度前不允许再次刷新')
		-- return;
	-- end
	
	--当前状态不符合
	-- if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
		-- FloatManager:AddNormal( StrConfig["fengyao17"], objSwf.btnmoney);
		-- return;
	 -- end
	--次数已满
	 -- if FengYaoModel.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
		-- print('==================次数已满')
		-- return;
	 -- end
	 --没有封妖
	 -- if FengYaoModel.fengyaoinfo.fengyaoId == 0 then
		-- print('==================没有封妖')
		-- return;
	 -- end
	
	--是否已是最高状态
	local vo = FengYaoModel.fengyaolist[5];
	if vo == nil then
		-- print('==================最高难度为空')
		return;
	end
	local highvo = FengYaoModel.fengyaolist[4];
	if highvo == nil then
		-- print('==================高品质难度为空')
		return;
	end
	if vo.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
		local content = StrConfig["fengyao22"];
		self.confirmID = UIConfirm:Open( content );
	--高品质弹出框
	elseif highvo.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
		local content = StrConfig["fengyao37"];
		local confirmFunc = function()
			 --判断银两够不够
			if FengYaoUtil:IsHaveGoldRefresh() == false then
				FloatManager:AddNormal( StrConfig["fengyao5"], objSwf.btnmoney);
				return;
			end
			FengYaoController:ReqFengYaoLvlRefresh(1);
		end
		self.confirmID = UIConfirm:Open( content, confirmFunc );
	else
		--判断银两够不够
		if FengYaoUtil:IsHaveGoldRefresh() == false then
			FloatManager:AddNormal( StrConfig["fengyao5"], objSwf.btnmoney);
			return;
		end
		FengYaoController:ReqFengYaoLvlRefresh(1);
		-- print('==================刷新参数 为1')
	end

end
function UIFengYao:OnBtnYuanBaoClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--是否已是最高状态
	local vo = FengYaoModel.fengyaolist[5];
	if vo == nil then
		return;
	end
	local highvo = FengYaoModel.fengyaolist[4];
	if highvo == nil then
		return;
	end
	if vo.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
		local content = StrConfig["fengyao22"];
		self.confirmID = UIConfirm:Open( content );
	
	--高品质弹出框
	elseif highvo.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
		local content = StrConfig["fengyao37"];
		local confirmFunc = function()
			--判断元宝够不够
			if FengYaoUtil:IsHaveMoneyRefresh() == false then
				FloatManager:AddNormal( StrConfig["fengyao6"], objSwf.btnyuanbao);
				return;
			end
			
			self.isreturnrefreshinfo = false;
			FengYaoController:ReqFengYaoLvlRefresh(2);
		end
		self.confirmID = UIConfirm:Open( content, confirmFunc );
	else
		--判断元宝够不够
		if FengYaoUtil:IsHaveMoneyRefresh() == false then
			FloatManager:AddNormal( StrConfig["fengyao6"], objSwf.btnyuanbao);
			return;
		end
		
		--self.isreturnrefreshinfo = false;
		FengYaoController:ReqFengYaoLvlRefresh(2);
	end
end
	
function UIFengYao:OnBtnGetQuestClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--已达上限
	 if FengYaoModel.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
			FloatManager:AddNormal( StrConfig["fengyao8"], objSwf.btnGetQuest);
		return;
	end
	
	 --已完成
	 if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
			FloatManager:AddNormal( StrConfig["fengyao7"], objSwf.btnGetQuest);
		return;
	end
	
	--未选中
	 if FengYaoModel.fengyaoinfo.fengyaoId == 0 then
		FloatManager:AddNormal( StrConfig["fengyao10"], objSwf.btnGetQuest);
		return;
	 end
	 
	--如果当前未接受
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAccept then
		-- print('------------------------接受任务')
		FengYaoController:ReqAcceptFengYao(FengYaoModel.fengyaoinfo.fengyaoId);
	end
	
end
-- function UIFengYao:OnBtnGiveupQuestClick()
	--是否已接受
	-- if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
		-- FengYaoController:ReqGiveupFengYao(FengYaoModel.fengyaoinfo.fengyaoId)
	-- end
	
-- end
function UIFengYao:OnBtnGetRewardClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	 
	--是否可领奖
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 0)
	end
end
function UIFengYao:OnBtnGetRewardTwoClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	 
	--是否可领奖
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		if FengYaoModel:GetIsSelectTwoConfirmPanel() == false then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			local groupcfg = t_fengyaogroup[playerinfo.eaLevel];
			if not groupcfg then
				return;
			end
			local okfunb = function (desc) 
				FengYaoModel:SetIsSelectTwoConfirmPanel(desc);
				if playerinfo.eaBindGold + playerinfo.eaUnBindGold < groupcfg.times then
					FloatManager:AddNormal( StrConfig["fengyao28"]);
					return;
				end
				
				FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 1);
			end;
			local val1,val2 = self:GetMultipleNum(2);
			UIConfirmWithNoTip:Open(string.format(StrConfig["fengyao26"],groupcfg.times,val1),okfunb);
		else
			--判断条件
			local playerinfo = MainPlayerModel.humanDetailInfo;
			local groupcfg = t_fengyaogroup[playerinfo.eaLevel];
			if not groupcfg then
				return;
			end
			if playerinfo.eaBindGold + playerinfo.eaUnBindGold < groupcfg.times then
				FloatManager:AddNormal( StrConfig["fengyao28"], objSwf.btnGetRewardTwo);
				return;
			end
			FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 1)
		end
	end
end
function UIFengYao:OnBtnGetRewardThreeClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	 
	--是否可领奖
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		if FengYaoModel:GetIsSelectThreeConfirmPanel() == false then
			local okfunb = function (desc) 
				FengYaoModel:SetIsSelectThreeConfirmPanel(desc);
				
				local playerinfo = MainPlayerModel.humanDetailInfo;
				if playerinfo.eaUnBindMoney < t_consts[51].val2 then
					FloatManager:AddNormal( StrConfig["fengyao29"]);
					return;
				end
				
				FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 2);
			end;
			local val1,val2 = self:GetMultipleNum(3);
			UIConfirmWithNoTip:Open(string.format(StrConfig["fengyao27"],t_consts[51].val2,val1),okfunb);
		else
			--判断条件
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaUnBindMoney < t_consts[51].val2 then
				FloatManager:AddNormal( StrConfig["fengyao29"], objSwf.btnGetRewardThree);
				return;
			end
			FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 2)
		end
	end
end

function UIFengYao:OnGetRewardTwoRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local groupcfg = t_fengyaogroup[playerinfo.eaLevel];
	if groupcfg then
		local valNum = getNumShow(groupcfg.times);
		local str = string.format(StrConfig["fengyao30"],valNum);
		TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
	end
	
	local cfg = t_fengyao[FengYaoModel.fengyaoinfo.fengyaoId];
	if cfg then
		local val1,val2 = self:GetMultipleNum(2);
		local morenum = val1 - 1;
		-- objSwf.tfrewardadd1.text = "+"..self:GetShowCountHanZi(cfg.expReward*morenum);
		-- objSwf.tfrewardadd2.text = "+"..self:GetShowCountHanZi(cfg.moneyReward*morenum);
		-- objSwf.tfrewardadd3.text = "+"..self:GetShowCountHanZi(cfg.zhenqiReward*morenum);
	end
end
function UIFengYao:OnGetRewardThreeRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local str = string.format(StrConfig["fengyao31"],t_consts[51].val2);
	TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
	
	local cfg = t_fengyao[FengYaoModel.fengyaoinfo.fengyaoId];
	if cfg then
		local val1,val2 = self:GetMultipleNum(3);
		local morenum = val1 - 1;
		-- objSwf.tfrewardadd1.text = "+"..self:GetShowCountHanZi(cfg.expReward*morenum);
		-- objSwf.tfrewardadd2.text = "+"..self:GetShowCountHanZi(cfg.moneyReward*morenum);
		-- objSwf.tfrewardadd3.text = "+"..self:GetShowCountHanZi(cfg.zhenqiReward*morenum);
	end
end

function UIFengYao:OnGetMoreRewardRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	TipsManager:Hide()
	-- objSwf.tfrewardadd1.text = "";
	-- objSwf.tfrewardadd2.text = "";
	-- objSwf.tfrewardadd3.text = "";
end

function UIFengYao:OnBtnGetScoreRewardClick(i)
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	
	-- 达到积分条件
	-- local boxid = FengYaoUtil:IsNextNotGetBoxid();
	-- if boxid == 0 then
		-- for i=1,self.boxcount do
			-- FloatManager:AddNormal( StrConfig["fengyao11"], objSwf["boxlevel"..i].btnScoreReward.click);
		-- end
		-- return;
	-- end
	-- for i=1,self.boxcount do
		-- if boxid == i then
			-- FengYaoController:ReqGetFengYaoBox(boxid)
			-- objSwf["boxlevel"..i].btnScoreReward.label = StrConfig["fengyao005"]
			-- objSwf["boxlevel"..i].btnScoreRewardEff._visible =false
			-- self.btnboxlist[i].btnScoreReward.disabled = true;
		-- end
	-- end
	
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local vo = t_fengyaojifen[i];
	if vo then
		local boxstate = FengYaoUtil:IsGetBoxState(vo.id);
		
		--是否达到条件
		if boxstate ~= FengYaoConsts.ShowType_NotGetBox then
			return;
		end
	
		FengYaoController:ReqGetFengYaoBox(vo.id)
	end
	
end

function UIFengYao:OnBtnStateRefreshClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if FengYaoModel.fengyaoinfo.curState ~= FengYaoConsts.ShowType_Awarded then
		-- print('------------------------------FengYaoModel.fengyaoinfo.curState ~= FengYaoConsts.ShowType_Awarded')
		return;
	end
	--达到上限次数
	-- if FengYaoModel.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
		-- return;
	-- end
	local type = FengYaoUtil:GetIsStateRefresh();
	if type == 2 then
		FloatManager:AddNormal( string.format(StrConfig["fengyao44"],t_consts[107].val1,t_consts[107].val2), objSwf.btnstaterefresh);
		return;
	elseif type == 3 then
		FloatManager:AddNormal( StrConfig["fengyao44"], objSwf.btnstaterefresh);
		return;
	end
	if type == 1 then
		FengYaoController:ReqRefreshFengYaoState();
	end
end
function UIFengYao:OnStateRefreshRollOver()
	local strcan = "";
	local strLevel = "";
	local strVip = "";
	local strMoney = "";
	local strfreeLevel = "";
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaLevel < t_consts[107].val1 then
		strLevel = "<font color='#cc0000'>"..t_consts[107].val1.. StrConfig["fengyao301"] .."</font>";
	else
		strLevel = "<font color='#00ff00'>"..t_consts[107].val1.. StrConfig["fengyao301"] .."</font>";
	end
	if VipController:GetVipLevel() < t_consts[107].val2 then
		strVip = "<font color='#cc0000'>VIP"..t_consts[107].val2.."</font>";
	else
		strVip = "<font color='#00ff00'>VIP"..t_consts[107].val2.."</font>";
	end
	if playerinfo.eaUnBindMoney < t_consts[107].val3 then
		strMoney = "<font color='#cc0000'>"..t_consts[107].val3.. StrConfig["fengyao302"] .."</font>";
	else
		strMoney = "<font color='#00ff00'>"..t_consts[107].val3.. StrConfig["fengyao302"] .."</font>";
	end
	if playerinfo.eaLevel < t_consts[107].fval then
		strfreeLevel = "<font color='#cc0000'>"..t_consts[107].fval.. StrConfig["fengyao301"] .."</font>";
	else
		strfreeLevel = "<font color='#00ff00'>"..t_consts[107].fval.. StrConfig["fengyao301"] .."</font>";
	end
	local type = FengYaoUtil:GetIsStateRefresh();
	if type == 1 then
		strcan = "<font color='#00ff00'>(已达成)</font>";
	else
		strcan = "<font color='#cc0000'>(未达成)</font>";
	end
	local str = string.format(StrConfig["fengyao43"],strcan,strLevel,strVip,strMoney,strfreeLevel);
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIFengYao:OnbtnNameRollOver()
end
function UIFengYao:OnbtnNameRollOut()
end
	
function UIFengYao:OnbtnFindRoadClick()
	-- print('-----------------OnbtnFindRoadClick()')
	self:AutoRunToFight()
end

function UIFengYao:GetFengYaoPoint()
	local fengyaovo = FengYaoUtil:GetFengYaoListVO( FengYaoModel.fengyaoinfo.fengyaoId )
	local position = fengyaovo and fengyaovo.endid
	if not position then return end
	return QuestUtil:GetQuestPos( position )
end

function UIFengYao:AutoRunToFight()
	if not MapUtils:CanTeleport() then
		FloatManager:AddCenter( StrConfig['fengyao34'] );
		return;
	end
	if FengYaoModel.fengyaoinfo.curState ~= FengYaoConsts.ShowType_Accepted then
		return
	end
	local point = self:GetFengYaoPoint()
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun( point.mapId, _Vector3.new(point.x,point.y,0), completeFuc );
end

-- 直飞
local needChangeScene = false
function UIFengYao:OnBtnTeleportClick()
	local point = self:GetFengYaoPoint()
	if not point then return end
	needChangeScene = CPlayerMap:GetCurMapID() ~= point.mapId
	local teleportType = MapConsts.Teleport_FengYao
	local onfoot = function() self:AutoRunToFight() end
	MapController:Teleport( teleportType, onfoot, point.mapId, point.x, point.y )
end

function UIFengYao:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function UIFengYao:OnBtnTeleportRollOut()
	TipsManager:Hide()
end

function UIFengYao:OnTeleportDone()
	local cb = function()
		AutoBattleController:OpenAutoBattle()
	end
	if needChangeScene then
		MapController:AddSceneChangeCB( cb )
	else
		cb()
	end
end

function UIFengYao:OnbtnyaoqingClick()
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
		local fengyaovo = FengYaoUtil:GetFengYaoListVO(FengYaoModel.fengyaoinfo.fengyaoId);
		if fengyaovo then
			if self.noticeTimeKey then
				FloatManager:AddNormal(StrConfig["fengyao45"])
				return
			end
			self.noticeTimeKey = TimerManager:RegisterTimer(function()
				TimerManager:UnRegisterTimer(self.noticeTimeKey);
				self.noticeTimeKey= nil;
			end,600000);
			ChatController:OnSendWorldNotice(ChatConsts.WorldNoticeXuanShang);
		end
	end
end

function UIFengYao:UpdateKillMonsterNum()
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlCfg = t_fengyaogroup[level]
	if lvlCfg then
		local monsterNum = lvlCfg.number;
		self.objSwf.tfKillNum._visible =  true
		self.objSwf.tfKillNum.tfKillNum.htmlText =  string.format(StrConfig["fengyao303"], FengYaoModel.curKillMonserNum,monsterNum);
	end
end
function UIFengYao:UpdateKillAllMonster()
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlCfg = t_fengyaogroup[level]
	if lvlCfg then
		local monsterNum = lvlCfg.number;
		self.objSwf.tfKillNum._visible =  true
		self.objSwf.tfKillNum.tfKillNum.htmlText =  string.format(StrConfig["fengyao303"], monsterNum,monsterNum);
	end
end
function UIFengYao:OnbtnLevelRollOver(k)
	if FengYaoModel.fengyaolist[k] and FengYaoModel.fengyaolist[k].fengyaoid then
		local vo = t_fengyao[FengYaoModel.fengyaolist[k].fengyaoid];
		local strreward = "";
		if vo.itemReward then
			local strreward = "";
			local rewardList = RewardManager:ParseToVO(vo.itemReward);
			for k,cfg in pairs(rewardList) do
				if cfg and t_item[cfg.id] then
					strreward = strreward.."<br>       "..t_item[cfg.id].name.."X"..cfg.count;
				end
			end
		end
		local reward = nil;
		if FengYaoModel.fengyaoinfo.finishCount	> t_consts[19].val3-1 then
			reward = vo.itemReward_1
		else
			reward = vo.itemReward
		end
		local t = split(reward,"#");
		local posTable = split(t[1],",");
		local expReward = tonumber(posTable[2]);
		local posTable_1 = split(t[2],",");
		local moneyReward = tonumber(posTable_1[2]);
		local str = string.format( StrConfig['fengyao14'], ResUtil:GetTipsLineUrl(), StrConfig["fengyao10"..vo.quality], StrConfig["fengyao20"..vo.quality], vo.finish_score, self:GetShowCount(expReward), self:GetShowCount(moneyReward));--, strreward);
		TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	end
end

function UIFengYao:OnBtnGetBoxClick(k)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local vo = t_fengyaojifen[k];
	if vo then
		local boxstate = FengYaoUtil:IsGetBoxState(vo.id);
		
		--是否达到条件
		if boxstate ~= FengYaoConsts.ShowType_NotGetBox then
			return;
		end
	
		FengYaoController:ReqGetFengYaoBox(vo.id)
	end
end

function UIFengYao:OnbtnBoxRollOver(k)
	local vo = t_fengyaojifen[k];
	if vo then
		self.isUIFengYaoBoxTips=true;
		local strreward = "";
		local rewardList = RewardManager:Parse(vo.itemReward);
		UIQuestTips:Show(vo.needStore, rewardList);
		-- for k,cfg in pairs(rewardList) do
			-- if cfg and t_item[cfg.id] then
				-- strreward = strreward.."<font color='"..TipsConsts:GetItemQualityColor(t_item[cfg.id].quality).."'>"..t_item[cfg.id].name.."</font><font color='#dcdcdc'>X"..cfg.count.."</font><br/>";
			-- end
		-- end
		
		-- local str = string.format( StrConfig['fengyao13'], vo.needStore, ResUtil:GetTipsLineUrl(), strreward);
		-- TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
	end
end
function UIFengYao:setBtnyuanbaoState()
	--是否已是最高状态
	local vo = FengYaoModel.fengyaolist[5];
	if vo == nil then
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if vo.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then	
		objSwf.btnyuanbao.disabled = true;
	end
end

function UIFengYao:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.FengYaoLevelRefresh then
		--self.isreturnrefreshinfo = true;
		self:ShowFengYao();
		self:ShowRefreshNotice();
		self:setBtnyuanbaoState();
	elseif name == NotifyConsts.FengYaoStateChanged then
		self:UpdateFengYaoState();
		self:UpdateStateEffect();
		self:UpdateBtnState();
		--self:UpdateDaoJiShi();
	elseif name == NotifyConsts.FengYaoListChanged then
		self:ShowFengYao();
	elseif name == NotifyConsts.FengYaoGetBox then
		self:updataScoreReward()
		self:UpdateBox(body);
		self:ShowFengYao();
	elseif name == NotifyConsts.FengYaoBaoScoreAdd then
		self:updataScoreReward()
		self:UpdateAfterGetReward();
		self:PlayGetRewardEffect();
		self:UpdateScoreAdd();
		self:UpdateStateEffect();
		self:UpdateBtnState();
	elseif name == NotifyConsts.FengYaoTastFinish then
		self:UpdateBtnState();
		self:ShowFengYao();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel then
			self:UpdateStateRefreshBtn();
		end
	elseif name == NotifyConsts.FengYaoKillMonsterNum then
		self:UpdateKillMonsterNum();
	elseif name == NotifyConsts.FengYaoTimeLeft then
		self:StopTimer()
		self:StartTimer();
	end
end

function UIFengYao:ListNotificationInterests()
	return {NotifyConsts.FengYaoLevelRefresh,
			NotifyConsts.FengYaoStateChanged,
			NotifyConsts.FengYaoListChanged,
			NotifyConsts.FengYaoGetBox,
			NotifyConsts.FengYaoBaoScoreAdd,
			NotifyConsts.FengYaoTastFinish,
			NotifyConsts.FengYaoKillMonsterNum,
			NotifyConsts.FengYaoTimeLeft,
			NotifyConsts.PlayerAttrChange};
end

function UIFengYao:InitData()
	self.allneedstore = FengYaoUtil:GetAllNeedStore();
	
	--开启计时器
	self.timelast = 0;
	--距离下次刷新的时间
	local istoday, shijian = FengYaoUtil:GetTimeNextRefresh();
	self.remaintime = shijian * 10;
	
	--self.isreturnrefreshinfo = true;
end

--申请数据
function UIFengYao:ReqFengYaoList()
	-- FengYaoController:ReqFengYaoLvlRefresh(0);
end

--是否播放特效
function UIFengYao:PlayEffectSelect(k, nisplay)
	-- WriteLog(LogType.Normal,true,'-----------------nisplay----PlayEffectSelect',nisplay)
	-- WriteLog(LogType.Normal,true,'----------------k-----PlayEffectSelect',k)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	-- if nisplay == 1 then
		-- self.btnlevellist[k].effectselect.visible = true;
		-- self.btnlevellist[k].effectselect:playEffect(0);
		-- self.btnlevellist[k].effectbg.visible = true;
		-- self.btnlevellist[k].effectbg:playEffect(0);
		
	-- else
		-- self.btnlevellist[k].effectselect.visible = false;
		-- self.btnlevellist[k].effectselect:stopEffect();
		-- self.btnlevellist[k].effectbg.visible = false;
		-- self.btnlevellist[k].effectbg:stopEffect();
	-- end
end

--显示列表
function UIFengYao:ShowFengYao(bshowmodel)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	-- for i=1,self.fengyaocount do
		-- btnlevellist[k].visible = false;
	-- end
	
	
	objSwf.modelload.visible = false;
	
	objSwf.txtbtnname.htmlLabel = "";
	
	-- 如果选中
	if FengYaoModel.fengyaoinfo.fengyaoId ~= 0 then
		local fengyaovo = FengYaoUtil:GetFengYaoListVO(FengYaoModel.fengyaoinfo.fengyaoId);
		if fengyaovo then
			--objSwf.iconname.source = fengyaovo.icon_name;
			-- objSwf.modelload.visible = true;
			
			--显示怪物
			if bshowmodel == nil then
				-- self:DrawMonster(fengyaovo.monsterid);
			end
			
			--状态
			self:UpdateState();
			
			--倒计时
			self:UpdateDaoJiShi();
			
			--名字
			local monsterinfo = t_monster[fengyaovo.monsterid];
			if monsterinfo then
				-- objSwf.txtbtnname.htmlLabel = string.format( StrConfig['fengyao21'], StrConfig["fengyao20"..fengyaovo.quality], monsterinfo.name);
				-- objSwf.tficonname._visible = true
				objSwf.tficonname.htmlText = string.format( StrConfig['fengyao38'], monsterinfo.name);
				objSwf.tfFinishCount.htmlText = string.format( StrConfig['fengyao309'], FengYaoModel.fengyaoinfo.finishCount);
			end
			--奖励
			-- objSwf.rewardPic._visible = true
			-- for i=1,4 do
				-- objSwf["item"..i]._visible = true;
			-- end
			local reward = nil;
			if FengYaoModel.fengyaoinfo.finishCount	> t_consts[19].val3-1 then
				reward = fengyaovo.itemReward_1
			else
				reward = fengyaovo.itemReward
			end
			-- local rewardList = RewardManager:Parse(enAttrType.eaExtremityVal..","..fengyaovo.finish_score,reward);
			-- objSwf.rewardList.dataProvider:cleanUp();
			-- objSwf.rewardList.dataProvider:push(unpack(rewardList));
			-- objSwf.rewardList:invalidateData();
			
			-- objSwf.tfrewardadd1.text = "";
			-- objSwf.tfrewardadd2.text = "";
			-- objSwf.tfrewardadd3.text = "";
		end
	else--如果当前没有选中
		local fengyaovo = FengYaoUtil:GetFengYaoListVO(11);
		if fengyaovo then
			-- objSwf.modelload.visible = true;
			--显示怪物
			-- self:DrawMonster(fengyaovo.monsterid);
			--名字
			local monsterinfo = t_monster[fengyaovo.monsterid];
			if monsterinfo then
				-- objSwf.tficonname._visible = true
				objSwf.tficonname.htmlText = string.format( StrConfig['fengyao38'], monsterinfo.name);
				objSwf.tfFinishCount.htmlText = string.format( StrConfig['fengyao309'], FengYaoModel.fengyaoinfo.finishCount);
			end
		end
		
	end
	--妖怪难度
	for k,cfg in ipairs(FengYaoModel.fengyaolist) do
		local reward = nil;
		if FengYaoModel.fengyaoinfo.finishCount	> t_consts[19].val3-1 then
			reward = cfg.itemReward_1
		else
			reward = cfg.itemReward
		end
		local t = split(reward,"#");
		local expReward = nil
		local moenyReward = nil
		if t[1] then
			local expTable = split(t[1],",");
			expReward = tonumber(expTable[2]);
		end
		if t[2] then
			local moenyTable = split(t[2],",");
			moenyReward = tonumber(moenyTable[2]);
		end
		if cfg.finish_score>0 then
			self.btnlevellist[k].tfReward.htmlText = string.format( StrConfig['fengyao310'], self:GetShowCount(cfg.finish_score),expReward,moenyReward);
		end
		-- 图标
		if #t >3 then
			local rewardList = RewardManager:Parse(t[3] ,t[4])
			local uiList = objSwf["rewardListD"..k]
			uiList.dataProvider:cleanUp()
			uiList.dataProvider:push( unpack(rewardList) )
			uiList:invalidateData()
		else
			local rewardList = RewardManager:Parse(t[3])
			local uiList = objSwf["rewardListD"..k]
			uiList.dataProvider:cleanUp()
			uiList.dataProvider:push( unpack(rewardList) )
			uiList:invalidateData()			
		end
		RewardManager:RegisterListTips(objSwf["rewardListD"..k]);
		if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAccept then
			self.btnlevellist[k].fengyaores.source = cfg.icon_normal;
			self.btnlevellist[k].imgselect.visible = false;
			self:PlayEffectSelect(k, 0);
			self.btnlevellist[k].btnlevel.visible = true;
			self.btnlevellist[k].btnlevel.disabled = false;
			self.btnlevellist[k].btnleveltip.visible = false;
			-- self.btnlevellist[k].btnGetQuest.visible = false;
			-- self.btnlevellist[k].getEff._visible = false;
			
			--选中
			if cfg.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
				--显示选中icon
				self.btnlevellist[k].fengyaores.source = cfg.icon_select;
				-- self.btnlevellist[k].btnlevel.visible = false;
				self.btnlevellist[k].btnlevel.disabled = true;
				self.btnlevellist[k].imgselect.visible = true;
				self:PlayEffectSelect(k, 1);
				-- self.btnlevellist[k].btnGetQuest.visible = true;
				-- self.btnlevellist[k].btnGetQuest.disabled = false;
				-- self.btnlevellist[k].btnGetQuest.label = StrConfig['fengyao006']; 
				-- self.btnlevellist[k].getEff._visible = true;
				-- self.btnlevellist[k].btnScoreRewardEff._visible = true;
			end
		elseif FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted or FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
			self.btnlevellist[k].fengyaores.source = cfg.icon_disabled;
			self.btnlevellist[k].imgselect.visible = false;
			self:PlayEffectSelect(k, 0);
			self.btnlevellist[k].btnlevel.visible = true;
			self.btnlevellist[k].btnlevel.disabled = true;
			self.btnlevellist[k].btnleveltip.visible = true;
			-- self.btnlevellist[k].btnGetQuest.visible = false;
			-- self.btnlevellist[k].getEff._visible = false;
			-- self.btnlevellist[k].btnScoreRewardEff._visible = false;
			-- if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
				-- self.btnlevellist[k].btnGetQuest.visible = true;
				-- self.btnlevellist[k].btnGetQuest.disabled = true;
				-- self.btnlevellist[k].btnGetQuest.label = StrConfig['fengyao008'];
			-- else
				-- self.btnlevellist[k].btnGetQuest.visible = true;
				-- self.btnlevellist[k].btnGetQuest.disabled = true;
				-- self.btnlevellist[k].btnGetQuest.label = StrConfig['fengyao007'];
			-- end
			--选中
			if cfg.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
				-- WriteLog(LogType.Normal,true,'-----------------kkkkkkkkkkkkk',k)
				-- print('-----------------kkkkkkkkkkkkk')
				--显示选中icon
				self.btnlevellist[k].fengyaores.source = cfg.icon_select;
				-- self.btnlevellist[k].btnlevel.visible = false;
				self.btnlevellist[k].btnlevel.disabled = true;
				self.btnlevellist[k].imgselect.visible = true;
				self:PlayEffectSelect(k, 1);
				-- if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
					-- self.btnlevellist[k].btnGetQuest.visible = true;
					-- self.btnlevellist[k].getEff._visible = false;
					-- self.btnlevellist[k].btnGetQuest.disabled = true;
					-- self.btnlevellist[k].btnGetQuest.label = StrConfig['fengyao008'];
				-- else
					-- self.btnlevellist[k].getEff._visible = false;
					-- self.btnlevellist[k].btnGetQuest.visible = true;
					-- self.btnlevellist[k].btnGetQuest.disabled = true;
					-- self.btnlevellist[k].btnGetQuest.label = StrConfig['fengyao007'];
				-- end
			end
		else
			self.btnlevellist[k].fengyaores.source = cfg.icon_disabled;
			self.btnlevellist[k].imgselect.visible = false;
			self:PlayEffectSelect(k, 0);
			self.btnlevellist[k].btnlevel.visible = true;
			self.btnlevellist[k].btnlevel.disabled = false;
			self.btnlevellist[k].btnleveltip.visible = true;
			-- self.btnlevellist[k].btnGetQuest.visible = false;
			-- self.btnlevellist[k].getEff._visible = false;
		end
	end
	
	--按钮状态
	self:UpdateBtnState();
	
	--积分进度条
	self:UpdateProcessBar()
	
	--宝箱
	for i=1,self.boxcount do
		-- self.btnboxlist[i].boxlevel.box1.visible = false;
		-- self.btnboxlist[i].boxlevel.box2.visible = false;
		-- self.btnboxlist[i].boxlevel.box3.visible = false;
		-- self.btnboxlist[i].boxlevel.box4.visible = false;
		-- self.btnboxlist[i].boxlevel.btnScoreReward._visible = false;
		-- self.btnboxlist[i].boxlevel.effectbox.visible = false;
		-- self.btnboxlist[i].boxlevel.effectbox:stopEffect();
		-- self.btnboxlist[i].boxlevel.btngetbox.visible = false;
		self.btnboxlist[i].boxlevelnumLoader.text = "";
		
		objSwf["rewardList"..i].dataProvider:cleanUp();
		local rewardListTop = {};

		local vo = t_fengyaojifen[i];
		if vo then
			local boxstate = FengYaoUtil:IsGetBoxState(vo.id);
			self.btnboxlist[i].boxlevelnumLoader.text = string.format(StrConfig["fengyao0027"],vo.needStore);
			--不到积分
			if boxstate == FengYaoConsts.ShowType_NoGetBox then
				objSwf["canGetEffect"..i]._visible = false
				objSwf["hasGetSciore"..i]._visible = false
				rewardListTop = RewardManager:Parse(vo.itemReward);
				-- self.btnboxlist[i].boxlevel.box4.visible = true;
				-- self.btnboxlist[i].btnScoreReward.disabled = true;
				-- self.btnboxlist[i].btnScoreReward.label = StrConfig["fengyao006"];
				-- self.btnboxlist[i].btnScoreRewardEff._visible =false
			--未领奖
			elseif boxstate == FengYaoConsts.ShowType_NotGetBox then
				objSwf["canGetEffect"..i]._visible = true
				objSwf["hasGetSciore"..i]._visible = false
				rewardListTop = RewardManager:Parse(vo.itemReward);
				-- self.btnboxlist[i].boxlevel.box2.visible = true;
				-- self.btnboxlist[i].boxlevel.effectbox.visible = true;
				-- self.btnboxlist[i].boxlevel.effectbox:playEffect(0);
				-- self.btnboxlist[i].boxlevel.btngetbox.visible = true;
				-- self.btnboxlist[i].btnScoreReward.disabled = false;				
				-- self.btnboxlist[i].btnScoreReward.label = StrConfig['fengyao006'];	
				-- self.btnboxlist[i].btnScoreRewardEff._visible =true				
			--已领奖
			else
				objSwf["canGetEffect"..i]._visible = false
				objSwf["hasGetSciore"..i]._visible = true
				rewardListTop = RewardManager:ParseBlack(vo.itemReward);
				-- self.btnboxlist[i].boxlevel.box3.visible = true;
				-- self.btnboxlist[i].btnScoreReward.label = StrConfig['fengyao005'];
				-- self.btnboxlist[i].btnScoreReward.disabled = true;	
				-- self.btnboxlist[i].btnScoreRewardEff._visible =false				
			end
			objSwf["rewardList"..i].dataProvider:push(unpack(rewardListTop));
			objSwf["rewardList"..i]:invalidateData();
		end
	end
	--领奖按钮
	-- local boxid = FengYaoUtil:IsNextNotGetBoxid();
	-- local isCanReward = FengYaoUtil:GetCanScoreReward()
	-- objSwf.scoreRewardEffect._visible = false;
	-- if not isCanReward then
		-- objSwf.btnScoreReward:clearEffect();
		-- objSwf.btnScoreReward.disabled = true;
		-- WriteLog(LogType.Normal,true,'---------------------objSwf.btnScoreReward:clearEffect();',isCanReward)
	-- else
		-- objSwf.btnScoreReward.disabled = false;
		-- objSwf.btnScoreReward:showEffect(ResUtil:GetButtonEffect7());
		-- WriteLog(LogType.Normal,true,'---------------------objSwf.btnScoreReward:showEffect(ResUtil:GetButtonEffect7());',isCanReward)
		-- if boxid > 0 then
			-- objSwf.scoreRewardEffect._visible = true;
		-- end
	-- end

	
	--今日可封妖次数
	local j = FengYaoConsts.FengYaoMaxCount - FengYaoModel.fengyaoinfo.finishCount
	objSwf.tffengyaonum.text = j.."次";
end

--更新领取积分奖励按钮
function UIFengYao:updataScoreReward()
	local objSwf = UIFengYao.objSwf;
	if not objSwf then return; end
		--领奖按钮
	local isCanReward = false;
	for i=1,self.boxcount do
		if objSwf["canGetEffect"..i]._visible==true then
			-- WriteLog(LogType.Normal,true,'---------------------objSwf["canGetEffect"..i]._visible==true',i)
			isCanReward = true;
		end
	end
	if not isCanReward then
		objSwf.btnScoreReward:clearEffect();
		objSwf.btnScoreReward.disabled = true;
		-- WriteLog(LogType.Normal,true,'---------------------objSwf.btnScoreReward:clearEffect();',FengYaoUtil:GetCanScoreReward())
	else
		objSwf.btnScoreReward.disabled = false;
		objSwf.btnScoreReward:showEffect(ResUtil:GetButtonEffect7());
		-- WriteLog(LogType.Normal,true,'---------------------objSwf.btnScoreReward:showEffect(ResUtil:GetButtonEffect7());',FengYaoUtil:GetCanScoreReward())
	end
end
--清空封妖状态
function UIFengYao:ClearState()
	local objSwf = UIFengYao.objSwf;
	if not objSwf then return; end
	
	-- objSwf.fengyinpanel.imgfengyin.visible = false;
	-- objSwf.fengyinpanel.effectbolang.visible = false;
	-- objSwf.fengyinpanel.effectbolang:stopEffect();
	-- objSwf.fengyinpanel.effectyanwu.visible = false;
	-- objSwf.fengyinpanel.effectyanwu:stopEffect();
	-- objSwf.fengyinpanel.effectjinxingstart.visible = false;
	-- objSwf.fengyinpanel.effectjinxingstart:stopEffect();
end

--更新封妖状态
function UIFengYao:UpdateState()
	local objSwf = UIFengYao.objSwf;
	if not objSwf then return; end
	
	-- objSwf.fengyinpanel.imgfengyin.visible = false;
	-- objSwf.fengyinpanel.effectbolang.visible = false;
	-- objSwf.fengyinpanel.effectbolang:stopEffect();
	-- objSwf.fengyinpanel.effectyanwu.visible = false;
	-- objSwf.fengyinpanel.effectyanwu:stopEffect();
	
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted or FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		-- objSwf.fengyinpanel.effectbolang.visible = true;
		-- objSwf.fengyinpanel.effectbolang:playEffect(0);
		-- objSwf.fengyinpanel.effectyanwu.visible = true;
		-- objSwf.fengyinpanel.effectyanwu:playEffect(0);
	--奖励已领取并且当前没有可接任务
	elseif FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
		-- objSwf.fengyinpanel.imgfengyin.visible = true;
	end
end

--更新按钮状态
function UIFengYao:UpdateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:UpdateStateRefreshBtn();
	
	-- objSwf.btnGetQuest.visible = false;
	-- objSwf.btnGetQuest.disabled = false;
	objSwf.tfFinishCount.htmlText = string.format( StrConfig['fengyao309'], FengYaoModel.fengyaoinfo.finishCount);
	objSwf.btnGoTo.visible = false;
	objSwf.btnyuanbao.visible = false;
	objSwf.ha._visible = false;
	-- objSwf.rewardPic._visible = false
	-- objSwf.jinxing.visible = false;
	-- for k,cfg in ipairs(FengYaoModel.fengyaolist) do
		-- self.btnlevellist[k].btnGoTo.visible = false;
	-- end
	objSwf.btnTeleport.visible = false;
	objSwf.btnGetReward.visible = false;
	objSwf.btnGetReward:clearEffect();
	objSwf.btnGetRewardEff._visible = false;
	objSwf.btnGetRewardEff1._visible = false;
	objSwf.btnGetRewardEff2._visible = false;
	objSwf.btnGetRewardTwo.visible = false;
	objSwf.btnGetRewardThree.visible = false;
	objSwf.btnFinishQuest.visible = false;
	-- objSwf.btnFinishQuest.disabled = false;
	objSwf.txtbtngiveup.visible = false;
	objSwf.lableyaoqing.visible = false;
	objSwf.btnTodayEnd.visible = false;
	
	objSwf.btnmoney.disabled = false;
	objSwf.btnyuanbaoGet.disabled = false;
	-- objSwf.btnyuanbao.disabled = false;
	
	objSwf.tfjianyi._visible = false;
	
	-- objSwf["numScore0"]._visible = false;
	-- objSwf["numScore1"]._visible = false;
	-- objSwf["numScore2"]._visible = false;
	-- objSwf["numScore4"]._visible = false;
	-- objSwf["numScore5"]._visible = false;
	objSwf.txtpinzhi._visible = false;
	
	if FengYaoModel.fengyaoinfo.curState ~= FengYaoConsts.ShowType_Awarded then
		-- 任务积分
		local vo = t_fengyao[FengYaoModel.fengyaoinfo.fengyaoId];
		if vo then
			-- objSwf["numScore"..vo.quality]._visible = true;
			
			-- objSwf.txtpinzhi._visible = true;
			-- objSwf.txtpinzhi.htmlLabel = StrConfig["fengyao10"..vo.quality];
			
			if vo.quality > 1 then
				-- objSwf.tfjianyi._visible = true;
			end
		end
	end
	
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAccept then
		-- print('----------------------------FengYaoConsts.ShowType_NoAccept')
		-- objSwf.btnGetQuest.visible = true;
		-- objSwf.btnGetQuest.disabled = false;
		objSwf.btnmoney.visible = true;
		objSwf.btnyuanbaoGet.visible = true;
		-- objSwf.btnyuanbao.visible = true;
		objSwf.diIcon._visible = true;
		if FengYaoModel.curHasTime>0 then 
			objSwf.btnmoney.disabled = true;
			objSwf.btnyuanbaoGet.disabled = true;
			-- objSwf.btnyuanbao.disabled = true;
		else
			objSwf.btnmoney.disabled = false;
			objSwf.btnyuanbaoGet.disabled = false;
			-- objSwf.btnyuanbao.disabled = false;
		end
	elseif FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
		
		objSwf.btnGoTo.visible = true;
		objSwf.btnyuanbao.visible = true;
		objSwf.btnyuanbao.disabled = false;
		-- objSwf.rewardPic._visible = true;
		-- for i=1,4 do
				-- objSwf["item"..i]._visible = true;
		-- end
		self:UpdateKillMonsterNum()
		self:StopTimer()
		self:StartTimer();
		-- objSwf.ha._visible = true;
		-- objSwf.btnTeleport.visible = true;
		-- objSwf.txtbtngiveup.visible = true;
		-- objSwf.lableyaoqing.visible = true;
		objSwf.btnmoney.visible = false;
		objSwf.btnyuanbaoGet.visible = false;
		-- objSwf.btnyuanbao.disabled = false;
		-- objSwf.btnyuanbao.visible = true;
		objSwf.diIcon._visible = true;
	elseif FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward  then
		-- print('----------------------------FengYaoConsts.ShowType_NoAward')
		objSwf.btnGetReward.visible = true;
		objSwf.btnGetReward:showEffect(ResUtil:GetButtonEffect10());
		-- UIFengyaoReward:Show()
		self:UpdateKillAllMonster()
		-- objSwf.btnGetRewardEff._visible = true;
		-- objSwf.rewardPic._visible = true;
		-- objSwf.btnGetRewardEff1._visible = true;
		-- objSwf.btnGetRewardEff2._visible = true;
		-- objSwf.btnGetRewardTwo.visible = true;
		-- objSwf.btnGetRewardThree.visible = true;
		objSwf.btnmoney.disabled = true;
		objSwf.btnyuanbaoGet.disabled = true;
		objSwf.btnmoney.visible = false;
		objSwf.btnyuanbaoGet.visible = false;
		objSwf.btnyuanbao.disabled = true;
		objSwf.btnyuanbao.visible = false;
		objSwf.diIcon._visible = false;
		self:UpdateGetBtnText();
	elseif FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
		-- objSwf.btnFinishQuest.visible = true;
		-- objSwf.btnFinishQuest.disabled = true;
		-- print('------------------------FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded')
		-- objSwf.rewardPic._visible = false
		-- for i=1,4 do
			-- objSwf["item"..i]._visible = false;
		-- end
		if FengYaoModel.curHasTime>0 then
			-- print('-------------------->０----FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded')
			objSwf.btnmoney.disabled = true;
			objSwf.btnyuanbaoGet.disabled = true;
			-- objSwf.btnyuanbao.disabled = true;
			FengYaoModel.fengyaoinfo.fengyaoId = 0;
			-- FengYaoModel:SetFengYaoState(0, FengYaoConsts.ShowType_NoAccept);
		else
			-- print('--------------------<０----FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded')
			objSwf.btnmoney.disabled = false;
			objSwf.btnyuanbaoGet.disabled = false;
			-- objSwf.btnyuanbao.disabled = false;
			FengYaoModel.fengyaoinfo.fengyaoId = 0;
			FengYaoModel:SetFengYaoState(0, FengYaoConsts.ShowType_NoAccept);
		end
		objSwf.btnmoney.visible = true;
		objSwf.btnyuanbaoGet.visible = true;
		-- objSwf.btnyuanbao.visible = true;
		objSwf.diIcon._visible = true;
		self.objSwf.tfKillNum._visible =  false
		--目前没有未刷新状态(0-10之间没有悬赏任务)
		if FengYaoUtil:GetIsNotRefreshState() == true then
			-- objSwf.btnTodayEnd.visible = true;
			-- objSwf.btnTodayEnd.htmlLabel = UIStrConfig["fengyao3"];
			return;
		end
		--达到上限次数后今日已完成
		if FengYaoModel.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
			-- objSwf.btnTodayEnd.visible = true;
			-- objSwf.btnTodayEnd.htmlLabel = StrConfig["fengyao39"];
			return;
		end
		
		--今日已结束
		local istoday, shijian, isupdate = FengYaoUtil:GetTimeNextRefresh();
		if istoday == false then
			-- objSwf.btnTodayEnd.visible = true;
			-- objSwf.btnTodayEnd.htmlLabel = StrConfig["fengyao40"];
			return;
		end
	end
end

--更新状态刷新按钮
function UIFengYao:UpdateStateRefreshBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnstaterefresh.visible = false;
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
		if FengYaoModel.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
			return;
		end
		-- objSwf.btnstaterefresh.visible = true;
	end
end

--更新倒计时
function UIFengYao:UpdateDaoJiShi()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.tfdaojishi.text = "";
	
	--达到上限次数后今日已完成
	if FengYaoModel.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
		return;
	end
	
	--今日已结束
	local istoday, shijian, isupdate = FengYaoUtil:GetTimeNextRefresh();
	if istoday == false then
		return;
	end
	
	-- local shijian = UIFengYao.remaintime - UIFengYao.timelast;
	-- shijian = (shijian - shijian % 10) / 10;
	-- local hour,min,sec = CTimeFormat:sec2format(shijian);
	-- if min < 10 then
		-- min = "0"..min;
	-- end
	-- if sec < 10 then
		-- sec = "0"..sec;
	-- end
	
	-- objSwf.tfdaojishi.htmlText = string.format( StrConfig['fengyao12'], "00", min, sec);
	
	
end

UIFengYao.timerKey = nil;
local time;
function UIFengYao:StartTimer()
	-- print('--------------UIFengYao:StartTimer()',FengYaoModel.curHasTime)
	if FengYaoModel.curHasTime==0  then 
		self.objSwf.tfdaojishi._visible = false
		return;
	end
	time =FengYaoModel.curHasTime - (GetServerTime()-FengYaoModel.getAServerTime);
	local cb = function(count)
		self:OnTimer(count);
	end
	self.timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local hour,min,sec = self:OnBackNowLeaveTime(time);
	-- WriteLog(LogType.Normal,true,'---------------------time  FengYaoModel.curHasTime',time,FengYaoModel.curHasTime)
	if time>0 then
		self.objSwf.tfdaojishi._visible = true
	end
	self.objSwf.tfdaojishi.htmlText = string.format( StrConfig['fengyao12'], min ,sec);
end
function UIFengYao:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end

function UIFengYao:OnTimer(count)
	time = FengYaoModel.curHasTime - (GetServerTime()-FengYaoModel.getAServerTime);
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp();
		return;
	end
	-- FengYaoModel:UpdataToQuest()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local hour,min,sec = self:OnBackNowLeaveTime(time);
	-- WriteLog(LogType.Normal,true,'---------------------time  FengYaoModel.curHasTime',time,FengYaoModel.curHasTime)
	if time>0 then
		self.objSwf.tfdaojishi._visible = true
	end
	self.objSwf.tfdaojishi.htmlText = string.format( StrConfig['fengyao12'], min ,sec);
end
function UIFengYao:OnTimeUp()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfdaojishi._visible = false
	FengYaoModel.curHasTime=0
	if FengYaoModel.fengyaoinfo.curState ~= FengYaoConsts.ShowType_Awarded then
		return;
	end
	objSwf.btnmoney.disabled = false;
	objSwf.btnyuanbaoGet.disabled = false;
	FengYaoModel.fengyaoinfo.fengyaoId = 0;
	FengYaoModel:SetFengYaoState(0, FengYaoConsts.ShowType_NoAccept);
end
function UIFengYao:StopTimer()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey,true);
		self.timerKey = nil;
		objSwf.tfdaojishi._visible = false
	end
end

--更新封妖难度
function UIFengYao:UpdateFengYaoCurLevel(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for k,cfg in ipairs(FengYaoModel.fengyaolist) do
		--以前的难度恢复
		if cfg.fengyaoid == body.oldid then
			self.btnlevellist[k].fengyaores.source = cfg.icon_normal;
			self.btnlevellist[k].btnlevel.visible = true;
			self.btnlevellist[k].btnlevel.disabled = false;
			self.btnlevellist[k].imgselect.visible = false;
			self:PlayEffectSelect(k, 0);
			-- self.btnlevellist[k].btnGetQuest.visible = false;
			-- self.btnlevellist[k].getEff._visible = false;
		--点亮新的难度
		elseif cfg.fengyaoid == body.fengyaoid then
			local fengyaovo = FengYaoUtil:GetFengYaoListVO(body.fengyaoid);
			if fengyaovo then
				--objSwf.iconname.source = fengyaovo.icon_name;
				--objSwf.model.visible = true;
				--objSwf.model.source = "";
				-- objSwf.modelload.visible = true;
				
				--显示怪物
				-- self:DrawMonster(fengyaovo.monsterid);
				
				--名字
				local monsterinfo = t_monster[fengyaovo.monsterid];
				if monsterinfo then
					-- objSwf.txtbtnname.htmlLabel = string.format( StrConfig['fengyao21'], StrConfig["fengyao20"..fengyaovo.quality], monsterinfo.name);
					objSwf.tficonname.htmlText = string.format( StrConfig['fengyao38'], StrConfig["fengyao20"..fengyaovo.quality], monsterinfo.name);
					objSwf.tfFinishCount.htmlText = string.format( StrConfig['fengyao309'], FengYaoModel.fengyaoinfo.finishCount);
				end
				local reward = nil;
				if FengYaoModel.fengyaoinfo.finishCount	> t_consts[19].val3-1 then
					reward = fengyaovo.itemReward_1
				else
					reward = fengyaovo.itemReward
				end
				--奖励
				-- local rewardList = RewardManager:Parse(reward);
				-- objSwf.rewardList.dataProvider:cleanUp();
				-- objSwf.rewardList.dataProvider:push(unpack(rewardList));
				-- objSwf.rewardList:invalidateData();
			end
			
			self.btnlevellist[k].fengyaores.source = cfg.icon_select;
			-- self.btnlevellist[k].btnlevel.visible = false;
			self.btnlevellist[k].btnlevel.disabled = true;
			self.btnlevellist[k].imgselect.visible = true;
			self:PlayEffectSelect(k, 1);
			-- self.btnlevellist[k].btnGetQuest.visible = true;
			-- self.btnlevellist[k].btnGetQuest.disabled = false;
			-- self.btnlevellist[k].btnGetQuest.label = StrConfig['fengyao006']; 
			-- self.btnlevellist[k].getEff._visible = true;
			-- self.btnlevellist[k].btnScoreRewardEff._visible = true;
			
		end
	end
end

--更新封妖状态
function UIFengYao:UpdateFengYaoState()
	--妖怪难度
	for k,cfg in ipairs(FengYaoModel.fengyaolist) do
		if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAccept then
			self.btnlevellist[k].fengyaores.source = cfg.icon_normal;
			self.btnlevellist[k].imgselect.visible = false;
			self:PlayEffectSelect(k, 0);
			self.btnlevellist[k].btnlevel.visible = true;
			self.btnlevellist[k].btnlevel.disabled = false;
			self.btnlevellist[k].btnleveltip.visible = false;
				
			--选中
			if cfg.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
				--显示选中icon
				self.btnlevellist[k].fengyaores.source = cfg.icon_select;
				-- self.btnlevellist[k].btnlevel.visible = false;
				self.btnlevellist[k].btnlevel.disabled = true;

				self.btnlevellist[k].imgselect.visible = true;
				self:PlayEffectSelect(k, 1);
			end
		elseif FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted or FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
			self.btnlevellist[k].fengyaores.source = cfg.icon_disabled;
			self.btnlevellist[k].imgselect.visible = false;
			self:PlayEffectSelect(k, 0);
			self.btnlevellist[k].btnlevel.visible = true;
			self.btnlevellist[k].btnlevel.disabled = false;
			self.btnlevellist[k].btnlevel.disabled = true;

			self.btnlevellist[k].btnleveltip.visible = true;
			
			--选中
			if cfg.fengyaoid == FengYaoModel.fengyaoinfo.fengyaoId then
				--显示选中icon
				self.btnlevellist[k].fengyaores.source = cfg.icon_select;
				-- self.btnlevellist[k].btnlevel.visible = false;
				self.btnlevellist[k].btnlevel.disabled = true;
				self.btnlevellist[k].imgselect.visible = true;
				self:PlayEffectSelect(k, 1);
			end
		else
			self.btnlevellist[k].fengyaores.source = cfg.icon_disabled;
			self.btnlevellist[k].imgselect.visible = false;
			self:PlayEffectSelect(k, 0);
			self.btnlevellist[k].btnlevel.visible = true;
			self.btnlevellist[k].btnlevel.disabled = false;
			self.btnlevellist[k].btnleveltip.visible = true;
		end
	end
end

--更新宝箱
function UIFengYao:UpdateBox(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--宝箱
	for i=1,self.boxcount do
		objSwf["rewardList"..i].dataProvider:cleanUp();
		local rewardListTop = {};
		local vo = t_fengyaojifen[i];
		if vo then
			if vo.id == body.boxId then
				objSwf["canGetEffect"..i]._visible = false
				objSwf["hasGetSciore"..i]._visible = true
				rewardListTop = RewardManager:ParseBlack(vo.itemReward);
				-- self.btnboxlist[i].boxlevel.box1.visible = false;
				-- self.btnboxlist[i].boxlevel.box2.visible = false;
				-- self.btnboxlist[i].boxlevel.box3.visible = true;
				-- self.btnboxlist[i].boxlevel.box4.visible = false;
				-- self.btnboxlist[i].boxlevel.effectbox.visible = false;
				-- self.btnboxlist[i].boxlevel.effectbox:stopEffect();
				-- self.btnboxlist[i].boxlevel.btngetbox.visible = false;
				-- self.btnboxlist[i].boxlevel.btnScoreReward._visible = false;
				objSwf["rewardList"..i].dataProvider:push(unpack(rewardListTop));
				objSwf["rewardList"..i]:invalidateData();
				--播放物品动画
				local rewardList = RewardManager:ParseToVO(vo.itemReward);
				local startPos = UIManager:PosLtoG(objSwf['btnTips' .. i]);
				RewardManager:FlyIcon(rewardList,startPos,6,true,60);
				break;
			end
		end
	end
	self:updataScoreReward()
	--领奖按钮
	-- local boxid = FengYaoUtil:IsNextNotGetBoxid();
	-- local isCanReward = FengYaoUtil:GetCanScoreReward()
	-- objSwf.scoreRewardEffect._visible = false;
	-- if not isCanReward then
		-- objSwf.btnScoreReward:clearEffect();
		-- objSwf.btnScoreReward.disabled = true;
		-- WriteLog(LogType.Normal,true,'---------------------objSwf.btnScoreReward:clearEffect();',isCanReward)
	-- else
		-- objSwf.btnScoreReward.disabled = false;
		-- objSwf.btnScoreReward:showEffect(ResUtil:GetButtonEffect7());
		-- WriteLog(LogType.Normal,true,'---------------------objSwf.btnScoreReward:showEffect(ResUtil:GetButtonEffect7());',isCanReward)
		-- if boxid > 0 then
			-- objSwf.scoreRewardEffect._visible = true;
		-- end
	-- end
end

--更新信息
function UIFengYao:UpdateProcessBar()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--积分进度条
	objSwf.processBarScore.maximum = self.allneedstore;
	objSwf.processBarScore.minimun = 0;
	-- objSwf.processBarScore.tfscore.text = FengYaoModel.fengyaoinfo.curScore;
	objSwf.tfjifen.text = FengYaoModel.fengyaoinfo.curScore;
	
	--宝箱积分
	local scorevalue = 0; 
	local scorespace = 0;
	local jieduanscorespace = 0;
	for i=1,self.boxcount-1 do
		--加一个阶段，一共6个阶段
		scorevalue = scorevalue + t_fengyaojifen[self.boxcount].needStore / self.boxcount;
		if FengYaoModel.fengyaoinfo.curScore >= t_fengyaojifen[i].needStore and FengYaoModel.fengyaoinfo.curScore <= t_fengyaojifen[i+1].needStore then
			scorespace = t_fengyaojifen[i+1].needStore - t_fengyaojifen[i].needStore;
			jieduanscorespace = FengYaoModel.fengyaoinfo.curScore - t_fengyaojifen[i].needStore;
			break;
		end
	end
	
	if scorespace == 0 then
		--每一个数对应的比例
		local scorerate = (t_fengyaojifen[self.boxcount].needStore / self.boxcount) / t_fengyaojifen[1].needStore;
		
		
		objSwf.processBarScore.value = FengYaoModel.fengyaoinfo.curScore * scorerate;
	else
		--每一个数对应的比例
		local scorerate = (t_fengyaojifen[self.boxcount].needStore / self.boxcount) / scorespace;
		objSwf.processBarScore.value = scorevalue + jieduanscorespace * scorerate;
		
		-- debug.debug()
	end
end

--领取奖励更新面板
function UIFengYao:UpdateAfterGetReward()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self:UpdateFengYaoState();
	self:UpdateState();
	self:UpdateBtnState();
	
	self:InitData();
	--self:UpdateDaoJiShi()
	
	--今日可封妖次数
	local j = FengYaoConsts.FengYaoMaxCount - FengYaoModel.fengyaoinfo.finishCount
	objSwf.tffengyaonum.text = j.."次";
end

--更新积分信息
function UIFengYao:UpdateScoreAdd()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--积分进度条
	self:UpdateProcessBar()
	
	--宝箱
	for i=1,self.boxcount do
		objSwf["rewardList"..i].dataProvider:cleanUp();
		local rewardListTop = {};
		-- self.btnboxlist[i].boxlevel.box1.visible = false;
		-- self.btnboxlist[i].boxlevel.box2.visible = false;
		-- self.btnboxlist[i].boxlevel.box3.visible = false;
		-- self.btnboxlist[i].boxlevel.box4.visible = false;
		-- self.btnboxlist[i].boxlevel.effectbox.visible = false;
		-- self.btnboxlist[i].boxlevel.effectbox:stopEffect();
		-- self.btnboxlist[i].boxlevel.btngetbox.visible = false;
		self.btnboxlist[i].boxlevelnumLoader.text = "";
		-- self.btnboxlist[i].boxlevel.btnScoreReward._visible = false;
		
		local vo = t_fengyaojifen[i];
		if vo then
			local boxstate = FengYaoUtil:IsGetBoxState(vo.id);
			self.btnboxlist[i].boxlevelnumLoader.text =  string.format(StrConfig["fengyao0027"],vo.needStore);
			--不到积分
			if boxstate == FengYaoConsts.ShowType_NoGetBox then
				objSwf["canGetEffect"..i]._visible = false
				objSwf["hasGetSciore"..i]._visible = false
				rewardListTop = RewardManager:Parse(vo.itemReward);
				-- self.btnboxlist[i].boxlevel.box4.visible = true;
				-- self.btnboxlist[i].btnScoreReward.disabled = true;
				-- self.btnboxlist[i].btnScoreReward.label = StrConfig['fengyao006'];
				-- self.btnboxlist[i].btnScoreRewardEff._visible = false;
			--未领奖
			elseif boxstate == FengYaoConsts.ShowType_NotGetBox then
				objSwf["canGetEffect"..i]._visible = true
				objSwf["hasGetSciore"..i]._visible = false
				rewardListTop = RewardManager:Parse(vo.itemReward);
				-- self.btnboxlist[i].boxlevel.box2.visible = true;
				-- self.btnboxlist[i].boxlevel.effectbox.visible = true;
				-- self.btnboxlist[i].boxlevel.effectbox:playEffect(0);
				-- self.btnboxlist[i].boxlevel.btnScoreReward._visible = true;
				-- self.btnboxlist[i].boxlevel.btngetbox.visible = true;
				-- self.btnboxlist[i].btnScoreReward.disabled = false;
				-- self.btnboxlist[i].btnScoreReward.label = StrConfig['fengyao006'];
				-- self.btnboxlist[i].btnScoreRewardEff._visible = true;
			--已领奖
			else
				objSwf["canGetEffect"..i]._visible = false
				objSwf["hasGetSciore"..i]._visible = true
				rewardListTop = RewardManager:ParseBlack(vo.itemReward);
				-- self.btnboxlist[i].boxlevel.box3.visible = true;
				-- self.btnboxlist[i].btnScoreRewardEff._visible = false;
				-- self.btnboxlist[i].boxlevel.btnScoreReward._visible = false;
				-- self.btnboxlist[i].btnScoreReward.disabled = true;
				-- self.btnboxlist[i].btnScoreReward.label = StrConfig['fengyao005'];
			end
			objSwf["rewardList"..i].dataProvider:push(unpack(rewardListTop));
			objSwf["rewardList"..i]:invalidateData();
		end
	end
end

--更新信息
function UIFengYao:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	
end

function UIFengYao:StartLastTimer()
	if not self.lastTimerKey then
		self.lastTimerKey = TimerManager:RegisterTimer( self.DecreaseTimeLast, 100, 0 );
	end
end

--倒计时自动
function UIFengYao.DecreaseTimeLast( count )
	UIFengYao.timelast = UIFengYao.timelast +1;
	UIFengYao.actiontime = UIFengYao.actiontime +1;
	
	UIFengYao:UpdateDaoJiShi();
	
	if UIFengYao.timelast >= UIFengYao.remaintime then
		-- FengYaoController:ReqFengYaoLvlRefresh(0);
		
		--开启计时器
		UIFengYao.timelast = 0;
		--距离下次刷新的时间
		local istoday, shijian = FengYaoUtil:GetTimeNextRefresh();
		UIFengYao.remaintime = shijian * 10;
	
	end
	
	if UIFengYao.actiontime >= FengYaoConsts.ActionSpaceTime then
		UIFengYao.actiontime = 0;
		
		UIFengYao:PlayFengYaoAction();
	end
	
	if UIFengYao.isbeforeplay == true then
		UIFengYao.beforeplaytime = UIFengYao.beforeplaytime + 1;
		
		if UIFengYao.beforeplaytime >= FengYaoConsts.BeforePlayTime then
			UIFengYao:PlayFengYaoAction();
			UIFengYao.actiontime = 0;
			UIFengYao.beforeplaytime = 0;
			UIFengYao.isbeforeplay = false;
		end
	end
end

-- 创建配置文件
UIFengYao.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(500,600),
									Rotation = 0,
								  };
function UIFengYao : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = self.defaultCfg.Rotation;
	return cfg;
end

--显示怪物
function UIFengYao:DrawMonster(modelid)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,modelid)
	monsterAvater:InitAvatar();
	self.curModel = monsterAvater;
	local drawcfg = UIDrawFengYaoMonsterConfig[modelid]
	if not drawcfg then
		drawcfg = self:GetDefaultCfg();
	end
	
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("FengyaoMonster",monsterAvater, objSwf.modelload,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000, "FengYao" );
	else
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end
	-- 模型旋转
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	self.objUIDraw:SetDraw(true);
	
	UIFengYao.beforeplaytime = 0;
	UIFengYao.isbeforeplay = true;
end;

-- 封妖播放动作
function UIFengYao:PlayFengYaoAction()
	local modelid = nil;
	if FengYaoModel.fengyaoinfo.fengyaoId ~= 0 then
		local fengyaovo = FengYaoUtil:GetFengYaoListVO(FengYaoModel.fengyaoinfo.fengyaoId);
		if fengyaovo then
			modelid = fengyaovo.monsterid;
		end
	end
	
	if not modelid then
		return;
	end
	
	local cfgMonster = t_monster[modelid]
	if not cfgMonster then
		Error("don't exist this monster monsterId:" .. modelid)
		return
	end

	local model = t_model[cfgMonster.modelId]
	if not model then
		Error("don't exist this monster model:" .. cfgMonster.modelId)
		return
	end
	
	local stunActionFile = model["san_atk"]
	local atkList = GetPoundTable(stunActionFile)
	if self.curModel then
		self.curModel:DoAction(atkList[1], false)
	end
	--时间归零
	self.actiontime = 0;
end

--更新状态
function UIFengYao:UpdateStateEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	--清空状态
	UIFengYao:ClearState();
	
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
		--播放进行中开始
		-- objSwf.fengyinpanel.effectjinxingstart.visible = true;
		-- objSwf.fengyinpanel.effectjinxingstart:playEffect(1);
	elseif FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
		-- objSwf.fengyinpanel.effectfengyining.visible = true;
		-- objSwf.fengyinpanel.effectfengyining:playEffect(1);
	else
		self:UpdateState();
	end
end;

--更新状态
function UIFengYao:PlayOpenFengyinEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	if self.isopenfengyin == true then
		self:UpdateStateEffect();
		self.isopenfengyin = false;
	end
end;

--播放获取奖励特效
function UIFengYao:PlayGetRewardEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	-- objSwf.getrewardeffect.visible = true;
	-- objSwf.getrewardeffect:playEffect(1);
	
	if FengYaoModel.fengyaoinfo.fengyaoId ~= 0 then
		local fengyaovo = FengYaoUtil:GetFengYaoListVO(FengYaoModel.fengyaoinfo.fengyaoId);
		if fengyaovo then
			--奖励
			local reward = nil;
			if FengYaoModel.fengyaoinfo.finishCount	> t_consts[19].val3-1 then
				reward = fengyaovo.itemReward_1
			else
				reward = fengyaovo.itemReward
			end
			local rewardList = RewardManager:ParseToVO(reward);
			local startPos = UIManager:PosLtoG(objSwf.item1,0,0);
			RewardManager:FlyIcon(rewardList,startPos,6,true,60);
		end
	end
end

--显示数量
function UIFengYao:GetShowCount(num)
	-- if num < 10000 then
		return num;
	-- else
		-- return toint( num / 10000, -1 ) .. "W";
	-- end
end

--更新按钮文本
function UIFengYao:UpdateGetBtnText()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local multipleInfoMap = FengYaoUtil:GetDQMultipleRewardMap()
	-- objSwf.btnGetReward.htmlLabel = multipleInfoMap[1].label
	objSwf.btnGetReward.htmlLabel = StrConfig["fengyao305"]
	objSwf.btnGetRewardTwo.htmlLabel = multipleInfoMap[2].label
	objSwf.btnGetRewardThree.htmlLabel = multipleInfoMap[3].label
end

--得到多倍奖励倍数
function UIFengYao:GetMultipleNum(multipleindex)
	local itemList = split(t_consts[74].param,"#");
	local index = 1;
	for i,itemStr in ipairs(itemList) do
		local item = split(itemStr,",");
		if index == multipleindex then
			return item[1],item[2];
		elseif index == multipleindex then
			return item[1],item[2];
		elseif index == multipleindex then
			return item[1],item[2];
		end
		
		index = index + 1;
	end
end

--刷新品质提示
function UIFengYao:ShowRefreshNotice()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local vo = t_fengyao[FengYaoModel.fengyaoinfo.fengyaoId];
	if vo then
		FloatManager:AddNormal(string.format(StrConfig["fengyao35"],StrConfig["fengyao21"..vo.quality]));
	end
end

--显示数量汉字
function UIFengYao:GetShowCountHanZi(count)
	if count < 10000 then
		local num = toint(count, 1);
		if num >= 10000 then
			return toint(num/10000,-1).."万";
		else
			return num;
		end
	elseif count < 100000000 then
		return toint(count/10000,-1).."万";
	else
		return toint(count/100000000,-1).."亿";
	end
end

function UIFengYao:OnBtnGoToOver()
	TipsManager:ShowBtnTips(string.format(StrConfig['fengyao18'],t_consts[20].val1),TipsConsts.Dir_RightDown);
end

function UIFengYao:OnBtnMoneyOver()
	TipsManager:ShowBtnTips(string.format(StrConfig['fengyao311']),TipsConsts.Dir_RightDown);
end
function UIFengYao:OnBtnYuanbaoGetOver()
	TipsManager:ShowBtnTips(string.format(StrConfig['fengyao312']),TipsConsts.Dir_RightDown);
end
function UIFengYao:OnBtnYuanBaoOver()
	TipsManager:ShowBtnTips(string.format(StrConfig['fengyao19'],t_consts[20].val2),TipsConsts.Dir_RightDown);
end