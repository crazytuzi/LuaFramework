--[[
流水副本 追踪面板
2015年6月24日17:30:38
haohu
]]

_G.UIWaterDungeonProgress = BaseUI:new("UIWaterDungeonProgress")

UIWaterDungeonProgress.state = 0;  --非挂机状态
UIWaterDungeonProgress.currentWave = 1  --刚进去为第一波
function UIWaterDungeonProgress:Create()
	self:AddSWF( "waterDungeonProgress.swf", true, "center" )
end

function UIWaterDungeonProgress:OnLoaded( objSwf )
	self:Init(objSwf)
	objSwf.panel.btnTitle.click = function() self:OnBtnTitleClick() end
	local panel = objSwf.panel
	panel.btnQuit.click = function() self:OnBtnQuitClick() end
	panel.btnAuto.click = function() self:OnBtnAutoClick() end
	-- panel.btnHang.click = function() self:OnBtnHangClick() end
	-- panel.btnBag.click = function() self:OnBtnBagClick() end
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick() end
	objSwf.btnCloseState._visible = false
	objSwf.panel.toGet.click = function() self:OnToOpenPetPanel()end;
	objSwf.panel.toGet.htmlLabel = string.format(StrConfig['waterDungeon113']);
	objSwf.panel.btnRule.rollOver = function() 
		TipsManager:ShowBtnTips( StrConfig['waterDungeon006'], TipsConsts.Dir_RightDown )
	 end
	objSwf.panel.btnRule.rollOut = function() TipsManager:Hide(); end
end

function UIWaterDungeonProgress:Init( objSwf )
	local panel = objSwf.panel
	panel.txtDes.text          = StrConfig['waterDungeon101']
	panel.lblMonster.text      = StrConfig['waterDungeon102']
	panel.lblTotalMonster.text = StrConfig['waterDungeon103']
	panel.lblTotalExp.text     = StrConfig['waterDungeon104']
	panel.lblTime.text         = StrConfig['waterDungeon105']
	panel.lblFlowerPet.htmlText = StrConfig['waterDungeon112']
end

function UIWaterDungeonProgress:OnShow()
	self:UpdateShow()
	self:StartTimer()
	self.isAutoBattle = true;  --默认开始为非挂机状态
	self.currentWave = 1
end

function UIWaterDungeonProgress:UpdateShow()
	self:ShowWave()
	self:ShowWaveMonster()
	-- self:ShowExpMultiple()
	self:ShowTotalMonster()
	self:ShowExp()
end

function UIWaterDungeonProgress:ShowWave()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	self.currentWave  = WaterDungeonModel:GetCurrentWave()
	local numMonster   = WaterDungeonModel:GetCurrentWaveMonster()
	local waveMonster  = WaterDungeonConsts:GetWaveMonsterNum()
	local leftMonsterMeetBoss = waveMonster - numMonster >= 0 and waveMonster - numMonster or 0
	panel.txtWave.htmlText = string.format( StrConfig['waterDungeon106'], leftMonsterMeetBoss )
end

function UIWaterDungeonProgress:ShowWaveMonster()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	local numMonster         = WaterDungeonModel:GetCurrentWaveMonster()
	local waveMonster        = WaterDungeonConsts:GetWaveMonsterNum()
	local allMonster         = WaterDungeonConsts:GetMaxWave() * waveMonster
	numMonster               = (self.currentWave - 1) * waveMonster + numMonster
	panel.txtMonster.text    = string.format("%.2f%%", numMonster/allMonster * 100)
	panel.siMonster.value    = numMonster
	panel.siMonster.maximum  = allMonster + 15
end

function UIWaterDungeonProgress:ShowExpMultiple()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	-- local expMultiple = self:GetExpMultiple()
	-- panel.txtMultipleExp.text = string.format( StrConfig['waterDungeon107'], expMultiple * 100 )
end

-- 计算玩家当前的经验加成状态
function UIWaterDungeonProgress:GetExpMultiple()
	local expMultiple = 0
	local myBuffs = BuffModel:GetAllBuff()
	for id, buff in pairs(myBuffs) do
		local cfg = _G.t_buff[buff.tid]
		for i = 1, 5 do
			local buffEffect = cfg[ "effect_" .. i ]
			if WaterDungeonConsts:IsMultipleExpEff( buffEffect ) then
				local buffEffCfg = _G.t_buffeffect[ buffEffect ]
				expMultiple = expMultiple + buffEffCfg.func_param2
			end
		end
	end
	return (expMultiple ~= 0) and (1 + expMultiple) or expMultiple
end

function UIWaterDungeonProgress:ShowTotalMonster()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	local totalMonster = WaterDungeonModel:GetTotalMonster()   --累计击杀怪物数量
	panel.monsterNum.text = _G.getNumShow( totalMonster, true )
end

function UIWaterDungeonProgress:ShowExp()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	local exp = WaterDungeonModel:GetExp()
	panel.expNum:drawStr( self:GetExpNumShow( exp, true ) )
	-- 经验占升级经验的比例
	local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlUpExp    = t_lvup[ playerLevel ].exp
	local percentage  = exp / lvlUpExp * 100
	panel.txtExpProportion.text = string.format( StrConfig['waterDungeon108'], percentage )
end

function UIWaterDungeonProgress:GetExpNumShow(num, bUseInNumLoader)
    local str;
    local formatStr1 = bUseInNumLoader and "%sy" or StrConfig['commonNum002']
    local formatStr2 = bUseInNumLoader and "%sw" or StrConfig['commonNum001']
    local absNum = math.abs(num)
    if 100000000 <= absNum then -- 大于1亿
        local tenBillion = toint( num / 100000000 , -1); -- xx亿
        local billion = toint( (num % 100000000) / 10000000, 0.5 )
        str = string.format( formatStr1, tenBillion .. "d" .. billion );
    elseif 10000 <= absNum then
        local tenThound = toint( num / 10000 , -1); -- xx万
        str = string.format( formatStr2, tenThound );
    else
        str = tostring( toint(num, 0.5) )
    end
    return str;
end

function UIWaterDungeonProgress:OnToOpenPetPanel( )
	FuncManager:OpenFunc(FuncConsts.LovelyPet,true)
end

function UIWaterDungeonProgress:OnBtnTitleClick()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	panel._visible = false
	objSwf.btnCloseState._visible = true
end

function UIWaterDungeonProgress:OnBtnCloseClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btnCloseState._visible = false
	objSwf.panel._visible = true;
end

function UIWaterDungeonProgress:OnBtnQuitClick()
	local content = StrConfig['waterDungeon109']
	local confirmFunc = function()
		WaterDungeonController:ExitWaterDungeon()
	end
	self.confirmUID = UIConfirm:Open( content, confirmFunc )
end

function UIWaterDungeonProgress:CancelQuitConfirm()
	if self.confirmUID then
		UIConfirm:Close(self.confirmUID)
		self.confirmUID = nil
	end
end

function UIWaterDungeonProgress:OnBtnHangClick()
	AutoBattleController:SetAutoHang()
end

function UIWaterDungeonProgress:OnBtnBagClick()
	FuncManager:OpenFunc( FuncConsts.Bag, true )
end


-------------------------------------倒计时处理------------------------------------------
local timerKey
local time
function UIWaterDungeonProgress:StartTimer()
	local func = function() self:OnTimer() end
	time = WaterDungeonConsts:GetLimitTime()
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateCountDown()
end

function UIWaterDungeonProgress:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
	self:UpdateCountDown()
end

-- 经验副本增加buffer时间
function UIWaterDungeonProgress:AddBuffTime( )
	local bufferTime = WaterDungeonModel:GetBufferTime()
	time = time + bufferTime;
end

function UIWaterDungeonProgress:OnTimeUp()
	self:CancelQuitConfirm()
end

function UIWaterDungeonProgress:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		self:UpdateCountDown()
	end
end

function UIWaterDungeonProgress:UpdateCountDown()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	local textField = panel.txtTime
	textField.htmlText = DungeonUtils:ParseTime( time )
end

--改变挂机按钮文本
function UIWaterDungeonProgress:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.state = state;
	if state then   --state: true 开启自动挂机模式  false 关闭自动关机模式 
		AutoBattleController:OpenAutoBattle()   --自动战斗
		objSwf.panel.btnAuto.labelID = 'waterDungeon012'
	else
		objSwf.panel.btnAuto.labelID = 'waterDungeon009'
	end
end

function UIWaterDungeonProgress:OnBtnAutoClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.isAutoBattle = not self.isAutoBattle
	if self.state ~= true then
		AutoBattleController:OpenAutoBattle();
	else
		AutoBattleController:CloseAutoHang()
	end
end

function UIWaterDungeonProgress:OnHide()
	if UIAutoBattleTip:IsShow() then
		UIAutoBattleTip:Hide();
	end
	self:StopTimer()
	self:CancelQuitConfirm()
	self.currentWave = 1
end

function UIWaterDungeonProgress:GetWidth()
	return 237
end

function UIWaterDungeonProgress:GetHeight()
	return 430
end

---------------------------------消息处理------------------------------------

--监听消息列表
function UIWaterDungeonProgress:ListNotificationInterests()
	return {
		NotifyConsts.WaterDungeonWave,
		NotifyConsts.WaterDungeonWaveMonster,
		NotifyConsts.WaterDungeonExp,
		NotifyConsts.BuffRefresh,
		NotifyConsts.AutoHangStateChange,
		NotifyConsts.WaterDungeonTotalMonster,
		NotifyConsts.WaterDungeonBufferTime,
	}
end

--处理消息
function UIWaterDungeonProgress:HandleNotification(name, body)
	if name == NotifyConsts.WaterDungeonWave then
		self:ShowWave()
	elseif name == NotifyConsts.WaterDungeonWaveMonster then
		self:ShowWaveMonster()
		self:ShowWave()
		   --hxd
	elseif name == NotifyConsts.WaterDungeonTotalMonster then
		self:ShowTotalMonster()
	elseif name == NotifyConsts.WaterDungeonExp then
		self:ShowExp()
	elseif name == NotifyConsts.BuffRefresh then
		-- self:ShowExpMultiple()
	elseif name == NotifyConsts.AutoHangStateChange then
		self:OnChangeAutoText(body.state);
	elseif name == NotifyConsts.WaterDungeonBufferTime then
		self:AddBuffTime();
	end
end