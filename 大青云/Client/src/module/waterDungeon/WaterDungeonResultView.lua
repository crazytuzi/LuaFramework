--[[
流水副本 结算
2015年6月24日18:08:56
haohu
]]

_G.UIWaterDungeonResult = BaseUI:new("UIWaterDungeonResult")

UIWaterDungeonResult.wave = nil -- 累计波数
UIWaterDungeonResult.exp  = nil -- 累计获得经验

function UIWaterDungeonResult:Create()
	self:AddSWF( "waterDungeonResult.swf", true, "center" )
end

function UIWaterDungeonResult:OnLoaded( objSwf )
	objSwf.btn_quit.click = function() 
		-- UIConfirm:Close(self.confirmUID); 
		-- WaterDungeonEnterTip:Open(function() 
			self:OnBtnQuitClick(1) 
			-- end) 
	end
	-- objSwf.bnt_double.click = function() self:OnBtnQuitClick(2) end
	-- objSwf.bnt_triple.click = function() self:OnBtnQuitClick(3) end
end

function UIWaterDungeonResult:OnShow()
	self:OnBtnTxt();
	self:UpdateShow()
	self:StartTimer()
end

function UIWaterDungeonResult:OnBtnTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_consts[94];
	if not cfg then return end
	local btnCfg = split(cfg.param,'#');
	
	local getNum = 0;
	local strType = '';
	local val = 0;
	getNum = tonumber(split(btnCfg[1],',')[1])
	strType = tonumber(split(btnCfg[1],',')[2]);
	val = toint(split(btnCfg[1],',')[3])
	-- objSwf.bnt_double.htmlLabel = string.format(StrConfig['quest505'],getNum,val,ResUtil:GetMoneyIconURL( strType ));
	
	getNum = tonumber(split(btnCfg[2],',')[1])
	strType = tonumber(split(btnCfg[2],',')[2]);
	val = toint(split(btnCfg[2],',')[3])
	-- objSwf.bnt_triple.htmlLabel = string.format(StrConfig['quest505'],getNum,val,ResUtil:GetMoneyIconURL( strType ));
	
end

function UIWaterDungeonResult:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtWave.text = self.wave                     --累计杀怪
	objSwf.txtExp.text = _G.getNumShow( self.exp )      --获得经验
	local exp = WaterDungeonModel:GetExp()              --当前升级经验的百分比
	local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlUpExp    = t_lvup[ playerLevel ].exp
	if lvlUpExp == 0 then return; end
	local percentage  = exp / lvlUpExp * 100
	objSwf.txtExpProportion.text = string.format( StrConfig['waterDungeon108'], percentage )
end

function UIWaterDungeonResult:OnBtnQuitClick(_type)
	if self.confirmUID ~= nil then
		UIConfirm:Close( self.confirmUID );
	end
	if _type == 1 then
		self:Quit( _type );
		return
	end
	if WaterDungeonEnterTip:IsShow() then
		WaterDungeonEnterTip:Hide();
	end
	local cfg = t_consts[94];
	if not cfg then return end
	local btnCfg = split(cfg.param,'#');
	local getNum = 0;
	local strType = '';
	local val = 0;
	local moneyType;
	if _type == 2 then
		getNum = tonumber(split(btnCfg[1],',')[1])
		moneyType = tonumber( split(btnCfg[1], ',')[2] )
		strType = enAttrTypeName[moneyType];
		val = toint(split(btnCfg[1],',')[3])
	elseif _type == 3 then
		getNum = tonumber(split(btnCfg[2],',')[1])
		moneyType = tonumber(split(btnCfg[2],',')[2])
		strType = enAttrTypeName[moneyType];
		val = toint(split(btnCfg[2],',')[3])
	end
	local playerInfo = MainPlayerModel.humanDetailInfo;
	if playerInfo[moneyType] < val then
		FloatManager:AddNormal( string.format( StrConfig['waterDungeon501'], strType ) )
		return
	end
	local func = function () 
		self:Quit( _type );
		self.confirmUID = nil
	end
	self.confirmUID = UIConfirm:Open( string.format( StrConfig['waterDungeon410'], val, strType, getNum ), func );
end

function UIWaterDungeonResult:Quit(_type)
	if not _type then
		_type = 1
	end
	self:StopTimer()
	WaterDungeonController:ExitWaterDungeonReward(_type);
	WaterDungeonController:ExitWaterDungeon()
end

function UIWaterDungeonResult:OnHide()
	self:StopTimer();
	UIConfirm:Close(self.confirmUID);
	if WaterDungeonEnterTip:IsShow() then
		WaterDungeonEnterTip:Hide();
	end
end

function UIWaterDungeonResult:Open( wave, exp )
	self.wave = wave
	self.exp = exp
	self:Show()
end

-------------------------------------倒计时处理------------------------------------------
local timerKey
local time
function UIWaterDungeonResult:StartTimer()
	local func = function() self:OnTimer() end
	time = WaterDungeonConsts.resultPanelTime
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateCountDown()
end

function UIWaterDungeonResult:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
	self:UpdateCountDown()
end

function UIWaterDungeonResult:OnTimeUp()
	if UIConfirm:IsShow() then
		UIConfirm:Hide();
	end
	if self.confirmUID == nil then
		UIConfirm:Close( self.confirmUID );
	end
	self:Quit()
end

function UIWaterDungeonResult:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		self:UpdateCountDown()
	end
end

function UIWaterDungeonResult:UpdateCountDown()
	local objSwf = self.objSwf
	if not objSwf then return end
	local textField = objSwf.txtTime
	textField.htmlText = string.format( StrConfig['waterDungeon301'], time )
end

function UIWaterDungeonResult:GetWidth()
	return 729;
end

function UIWaterDungeonResult:GetHeight()
	return 454;
end
