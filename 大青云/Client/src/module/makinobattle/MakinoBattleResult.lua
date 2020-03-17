--[[
	时间:   2016年10月21日, PM 23:55:24
	开发者: houxudong
	功能:   牧野之战结算面板
]]

_G.UIMakinoBatleDungeonResultView = BaseUI:new('UIMakinoBatleDungeonResultView');

function UIMakinoBatleDungeonResultView:Create()
	self:AddSWF("makinoBattleDungeonResult.swf",true,"center");
end

function UIMakinoBatleDungeonResultView:OnLoaded(objSwf)
	objSwf.btn_quit.click = function() 
		self:OnBtnQuitClick() 
	end
	objSwf.rewardlist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardlist.itemRollOut = function () TipsManager:Hide(); end
end

function UIMakinoBatleDungeonResultView:OnShow()
	self:ShowWave()
	self:ShowReward()
	self:StartTimer()
end

-- 显示挑战波数
function UIMakinoBatleDungeonResultView:ShowWave( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local curWave = MakinoBattleDungeonModel:GetCurWave( )
	objSwf.info.htmlText = string.format(StrConfig['makinoBattle8003'],curWave)
end

-- 显示奖励
function UIMakinoBatleDungeonResultView:ShowReward( )
	local objSwf = self.objSwf
	if not objSwf then return end
	-- 奖励
	objSwf.win._visible = false
	objSwf.lose._visible = false
	objSwf.info._visible = false
	objSwf.bgWin._visible = false
	objSwf.bgfail._visible = false
	objSwf.preLook._visible = false
	objSwf.failInfo._visible = false
	local curWaveRewardList = MakinoBattleDungeonModel:GetEveryWaveReward( )
	local curWave = MakinoBattleDungeonModel:GetCurWave( )
	if curWave == 0 then   --失败
		objSwf.lose._visible = true
		objSwf.bgfail._visible = true
		objSwf.failInfo._visible = true
		objSwf.failInfo.htmlText = StrConfig['makinoBattle8004']
		objSwf.btn_quit.label = UIStrConfig['waterDungeon0066']
		return; 
	else
		objSwf.win._visible = true
		objSwf.info._visible = true
		objSwf.bgWin._visible = true
		objSwf.preLook._visible = true
		objSwf.btn_quit.label = UIStrConfig['waterDungeon006']
	end
	objSwf.rewardlist.dataProvider:cleanUp();
	local rewardStr = '';
	local rewardCfg = '';
	for i , v in ipairs(curWaveRewardList) do
		if v.itemId ~= 0 then
			rewardStr = rewardStr .. ( i >= #curWaveRewardList and v.itemId .. ',' .. v.itemNum or v.itemId .. ',' .. v.itemNum .. '#'  )
		end
	end
	rewardCfg = RewardManager:Parse( rewardStr );
	objSwf.rewardlist.dataProvider:push(unpack(rewardCfg));
	objSwf.rewardlist:invalidateData();
end

local timerKey
local time 
function UIMakinoBatleDungeonResultView:StartTimer()
	local func = function() self:OnTimer() end
	time = 10
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateCountDown()
end

function UIMakinoBatleDungeonResultView:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		MakinoBattleController:ReqQuitMakinoBattleDungeon()  --退出
		return
	end
	self:UpdateCountDown()
end

function UIMakinoBatleDungeonResultView:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		time = 0;
		self:UpdateCountDown()
	end
end

-- 退出副本
function UIMakinoBatleDungeonResultView:OnBtnQuitClick( )
	MakinoBattleController:ReqQuitMakinoBattleDungeon()
end

function UIMakinoBatleDungeonResultView:OnHide( )
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end

function UIMakinoBatleDungeonResultView:UpdateCountDown()
	local objSwf = self.objSwf
	if not objSwf then return end
	local textField = objSwf.txtTime
	textField.htmlText = string.format( StrConfig['waterDungeon301'], time )
end