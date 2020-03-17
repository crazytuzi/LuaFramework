--[[
副本结算界面(胜利)
2015年6月3日15:57:17
haohu
]]

_G.UIDungeonSuccess = BaseUI:new("UIDungeonSuccess");
UIDungeonSuccess.rewardNum = 1;  --默认奖励数量
function UIDungeonSuccess:Create()
	self:AddSWF("dungeonSuccess.swf", true, "center");
end

function UIDungeonSuccess:OnLoaded(objSwf)
	RewardManager:RegisterListTips( objSwf.effect.rew.rewardList )
	RewardManager:RegisterListTips( objSwf.effect.sperew.vipRewardList )
	objSwf.effect.txtArea.btnQuit.label = StrConfig['dungeon301']
	objSwf.effect.txtArea.btnQuit.click = function() self:OnBtnQuitClick() end
	objSwf.effect:gotoAndStop(1);
	objSwf.effect.txtArea.txt1.text = StrConfig['dungeon307']
	objSwf.effect.txtArea.txt2.text = StrConfig['dungeon308']
	--objSwf.btnClose.click = function() self:OnBtnQuitClick() end
end

function UIDungeonSuccess:OnShow()
	self:UpdateShow()
	self:StartTimer()
	self:ShowPassTimer()
	self:Playpfx()
	
end

function UIDungeonSuccess:Playpfx( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local star;
	local passTime = self.PassTime;
	local dungeonCfg = t_dungeons[self.id]
	if not dungeonCfg then return; end
	if not dungeonCfg.limit_time then return; end
	local totalNum = dungeonCfg.limit_time * 60
	local differNum = totalNum - passTime
	if differNum > totalNum*0.7 then
		star = 5;		
	elseif  differNum > totalNum*0.5 then
		star = 4;
	elseif differNum > totalNum*0.3 then
		star = 3;
	elseif differNum > totalNum*0.1 then
		star = 2;
	elseif differNum >= 0 then
		star = 1;
	end
	-- 2016/11/12 强制给5星
	star = 5
	local speCfg = t_dunreward[self.id]
	if not speCfg then return; end
	local reward;
	if star == 5 then
		reward = split(speCfg.reward_1,',')
	elseif star == 4 then
		reward = split(speCfg.reward_2,',')
	else
		reward = split(speCfg.reward_3,',')
	end
	local rewardData =reward[3]..','..reward[4]..'#';
	rewardData = rewardData..rewardData..reward[3]..','..reward[4];
	local isVip = VipController:GetFubenTongguanJiangli() == 1
	self:ShowReward( objSwf.effect.sperew.vipRewardList, rewardData, not isVip )
	objSwf.effect.index = star;   --回调索引
	objSwf.effect.rewardNum = self.rewardNum;
	objSwf.effect:gotoAndPlay(1);
end

function UIDungeonSuccess:OnHide()
	self:StopTimer()
end

function UIDungeonSuccess:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = t_dungeons[self.id]
	
	if not cfg then return end
	local rewardCfg = split(cfg.rewards,"#")
	self.rewardNum = #rewardCfg;    --@得到奖励数量
	self:ShowReward( objSwf.effect.rew.rewardList, cfg.rewards )    
	-- local isVip = VipController:GetFubenTongguanJiangli() == 1
	-- objSwf.txtVipActive.text = isVip and "" or StrConfig['dungeon302']
	 -- self:ShowReward( objSwf.effect.sperew.vipRewardList, cfg.vip_reward, not isVip )
	
	local ismaxdugeonDiff = DungeonUtils:GetDungeonIsMaxDiff(self.id);
	if not ismaxdugeonDiff then
--		objSwf.mc_leveltip._visible = true;
	else
--		objSwf.mc_leveltip._visible = false;
	end
end

function UIDungeonSuccess:ShowReward( uiList, rewardStr, isBlack )
	local rewardProvider
	-- if isBlack then
	-- 	rewardProvider = RewardManager:ParseBlack( rewardStr )
	-- else
		rewardProvider = RewardManager:Parse( rewardStr )
	-- end
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack(rewardProvider) )
	uiList:invalidateData()
end

function UIDungeonSuccess:OnBtnQuitClick()
	self:QuitDungeon()
end

--领奖退出
function UIDungeonSuccess:QuitDungeon()
	DungeonController:ReqGetAward()
	self:Hide()
end

--------------------------------------通关时间-------------------------------------------
function UIDungeonSuccess:ShowPassTimer()
	local objSwf = self.objSwf;
	objSwf.effect.txtArea.labCountDown.htmlText = string.format( StrConfig["dungeon309"], DungeonUtils:ParseTime(tonumber(self.PassTime)));
end
-------------------------------------倒计时处理------------------------------------------

local timerKey
UIDungeonSuccess.time = 0;
function UIDungeonSuccess:StartTimer()
	local func = function() self:OnTimer() end
	self.time = DungeonConsts.AutoQuitDelay
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateTimeShow()
end

function UIDungeonSuccess:OnTimer()
	self.time = self.time - 1
	if self.time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
	self:UpdateTimeShow()
end

--关闭界面
function UIDungeonSuccess:OnTimeUp()
	self:QuitDungeon()
end

function UIDungeonSuccess:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		self:UpdateTimeShow()
	end
end

function UIDungeonSuccess:UpdateTimeShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local textField = objSwf.effect.txtArea.txtTime
	textField._visible = timerKey ~= nil
	textField.htmlText = string.format( StrConfig['dungeon303'], self.time )
end

function UIDungeonSuccess:Open(id,PassTime)
	self.id = id
	self.PassTime = PassTime
	self:Show()
end

--手动控制界面的显示位置
function UIDungeonSuccess:GetWidth()
	return 1000;
end

function UIDungeonSuccess:GetHeight()
	return 800;
end