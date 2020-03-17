--[[
讨伐副本结算
2016年10月7日 23:51:33
houxudong
]]

_G.TaoFaDungeonResult = BaseUI:new("TaoFaDungeonResult")

function TaoFaDungeonResult:Create()
	self:AddSWF( "taofaDungeonResult.swf", true, "center" )
end

function TaoFaDungeonResult:OnLoaded( objSwf )
	objSwf.btn_quit.click = function() 
		self:OnBtnQuitClick() 
	end
	objSwf.rewardlist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardlist.itemRollOut = function () TipsManager:Hide(); end
end

function TaoFaDungeonResult:OnShow()
	self:ShowReward()
	self:StartTimer()
end

-- 显示奖励
function TaoFaDungeonResult:ShowReward( )
	local objSwf = self.objSwf
	if not objSwf then return end
	if TaoFaModel.curTaskID ==0 then return; end
	local cfg = t_taofa[TaoFaModel.curTaskID];
	if not cfg then return end
	local rewardItemList = RewardManager:Parse( cfg.reward );
	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push( unpack(rewardItemList) );
	objSwf.rewardlist:invalidateData();
end

function TaoFaDungeonResult:OnBtnQuitClick()
	TaoFaController:ReqQuitDungeon()
end

local timerKey
local time
function TaoFaDungeonResult:StartTimer()
	local func = function() self:OnTimer() end
	time = 10
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateCountDown()
end

function TaoFaDungeonResult:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		TaoFaController:ReqQuitDungeon()
		return
	end
	self:UpdateCountDown()
end

function TaoFaDungeonResult:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		time = 0;
		self:UpdateCountDown()
	end
end

function TaoFaDungeonResult:OnHide( )
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end

function TaoFaDungeonResult:UpdateCountDown()
	local objSwf = self.objSwf
	if not objSwf then return end
	local textField = objSwf.txtTime
	textField.htmlText = string.format( StrConfig['waterDungeon301'], time )
end