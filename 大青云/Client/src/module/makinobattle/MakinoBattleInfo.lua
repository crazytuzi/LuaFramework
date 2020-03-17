--[[
	时间:  2016年10月21日 19:46:25
	开发者:houxudong
	功能:  副本追踪界面
]]

_G.UIMakinobattleInfo = BaseUI:new('UIMakinobattleInfo');

UIMakinobattleInfo.totalNpcHp = 0;     --NPC总血量
function UIMakinobattleInfo:Create()
	self:AddSWF("makinobattle.swf",true,"bottom");
end

function UIMakinobattleInfo:OnLoaded( objSwf )
	objSwf.minPanel.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.minPanel.rewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.minPanel.btn_out.click = function () self:OnQuitMakinoDungeon(); end
	objSwf.minPanel.btnOpen.click = function () self:PanelStateClick(); end   
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick() end
	objSwf.minPanel.siGrowValue.trackWidthGap = 32;
	objSwf.minPanel.siGrowValue.surfacePolicy = "always";
	objSwf.minPanel.siGrowValue.tweenDuration = 0.5;
	objSwf.minPanel.btnRule.rollOver = function() 
		TipsManager:ShowBtnTips( StrConfig['makinoBattle5000'], TipsConsts.Dir_RightDown )
	 end
	objSwf.minPanel.btnRule.rollOut = function() TipsManager:Hide(); end
end

function UIMakinobattleInfo:OnShow()
	self:SetUIState()
	-- self:StartTimer(30)
	MainMenuController:HideRight();
	MainMenuController:HideRightTop();
	self:UpdateWaveAndReward()
	self:UpdateMonsterTime()
	self:InitGiValue()
end

-- 设置界面的排版
function UIMakinobattleInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.minPanel._visible = true
	objSwf.btnCloseState._visible = false
end;

-- 初始化进度条(城门血量)
function UIMakinobattleInfo:InitGiValue( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local totalNpcHp = MakinoBattleDungeonModel:GetInintNpcHp( )
	self.totalNpcHp = totalNpcHp
	objSwf.minPanel.txt_Hp.htmlText = self.totalNpcHp..'/'..self.totalNpcHp  
	local gi = objSwf.minPanel.siGrowValue
	gi:setProgress(totalNpcHp , totalNpcHp )
	-- gi.maximum   = totalNpcHp;
	-- gi.value     = totalNpcHp;
end

-- 设置进度条(城门血量)
function UIMakinobattleInfo:UpdateGiValue(num)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local curNum = num ~= nil and num or 0
	objSwf.minPanel.txt_Hp.htmlText = curNum..'/'..self.totalNpcHp
	local gi = objSwf.minPanel.siGrowValue
	gi:tweenProgress(num , self.totalNpcHp )  --进度条倒计时
end

-- 更新波数和奖励
function UIMakinobattleInfo:UpdateWaveAndReward( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 波数
	local curWave = MakinoBattleDungeonModel:GetCurWave( )
	objSwf.minPanel.txt_curLayer.htmlText = string.format(StrConfig['makinoBattle8002'],curWave)
	-- 奖励
	local curWaveRewardList = MakinoBattleDungeonModel:GetEveryWaveReward( )
	if not curWaveRewardList then
		return;
	end
	objSwf.minPanel.rewardList.dataProvider:cleanUp();
	local rewardStr = '';
	local rewardCfg = '';
	for i , v in ipairs(curWaveRewardList) do
		if v.itemId ~= 0 then
			rewardStr = rewardStr .. ( i >= #curWaveRewardList and v.itemId .. ',' .. v.itemNum or v.itemId .. ',' .. v.itemNum .. '#'  )
		end
	end
	rewardCfg = RewardManager:Parse( rewardStr );
	objSwf.minPanel.rewardList.dataProvider:push(unpack(rewardCfg));
	objSwf.minPanel.rewardList:invalidateData();
end

-- 下拨怪物刷新
function UIMakinobattleInfo:UpdateMonsterTime( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_consts[322]
	if not cfg then return; end
	local times = cfg.val2
	if not times then return; end
	objSwf.minPanel.txt_updateTime.htmlText = DungeonUtils:ParseTime( times )
end

-- 展开
function UIMakinobattleInfo:OnBtnCloseClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.minPanel._visible = true;
	objSwf.btnCloseState._visible = false;
end

-- 合起
function UIMakinobattleInfo:PanelStateClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.minPanel._visible = false;
	objSwf.btnCloseState._visible = true;
end

-- 退出副本
function UIMakinobattleInfo:OnQuitMakinoDungeon()
	local func = function () 
		MakinoBattleController:ReqQuitMakinoBattleDungeon()
	end
	self.uiconfirmID = UIConfirm:Open(StrConfig['makinoBattle9000'],func);
end

local timerKey
local time 
-- 开始刷怪计时
function UIMakinobattleInfo:StartTimer(num)
	self:StopTimer(num)
	local func = function() 
		time = time - 1
		if time <= 0 then
			time = 30
		end
		self:UpdateCountDown()
	 end
	time = num
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateCountDown()
end

function UIMakinobattleInfo:StopTimer(num)
	if timerKey then
		time = num
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		self:UpdateCountDown()
	end
end

function UIMakinobattleInfo:UpdateCountDown()
	local objSwf = self.objSwf
	if not objSwf then return end
	local sec = DungeonUtils:ParseTime( time )
	objSwf.minPanel.txt_updateTime.htmlText = sec
	-- FloatManager:AddAnnounceForMakinoBattle(StrConfig['makinoBattle99999'])
end


function UIMakinobattleInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:StopTimer(0)
	local gi = objSwf.minPanel.siGrowValue
	gi:tweenProgress(0 , 0)
	objSwf.minPanel.txt_curLayer.htmlText =""
	objSwf.minPanel.txt_updateTime.htmlText = ""
	UIConfirm:Close(self.uiconfirmID);
end

function UIMakinobattleInfo:GetWidth()
	return 237
end

function UIMakinobattleInfo:GetHeight()
	return 380
end