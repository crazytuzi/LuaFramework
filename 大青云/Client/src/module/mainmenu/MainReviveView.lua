--[[
复活面板
haohu
2014年9月3日16:31:13
]]

_G.classlist['UIRevive'] = 'UIRevive'
_G.UIRevive = BaseUI:new("UIRevive");
UIRevive.objName = 'UIRevive'

-- 是否自动购买复活道具
UIRevive.autoBuy = true;

function UIRevive:Create()
	self:AddSWF("revivePanel.swf", true, "top");
end

function UIRevive:OnLoaded( objSwf )
	objSwf.btnReviveSitu.click  = function() self:OnBtnReviveSituClick() end  --原地复活
	objSwf.btnReviveTp.click    = function() self:OnBtnReviveTpClick() end    --安全复活
	objSwf.chkBoxAutoBuy.click  = function(e) self:OnAutoBuyClick(e) end
	--显示复活道具图标
	local item    = objSwf.item
	local slotVO  = RewardSlotVO:new()
	slotVO.id     = MainMenuConsts:GetReviveItem()
	slotVO.count  = 0
	item:setData( slotVO:GetUIData() )
	item.rollOver = function() self:OnItemOver() end
	item.rollOut  = function() self:OnItemOut() end
end

function UIRevive:OnShow()
	self:UpdateShow()
	self:StartBtnEnableTimer();
end

function UIRevive:OnHide()
	self:StopReviveTimer();
	self:StopBtnEnableTimer();
end

function UIRevive:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	--button label
	local currentMapId = CPlayerMap:GetCurMapID()
	local mapCfg = t_map[currentMapId]
	if not mapCfg then return end
	-- print('------------------------------currentMapId',currentMapId)
	if mapCfg.can_fuhuo then--不能原地复活
		objSwf.txtTIP._visible = true
		objSwf.btnReviveSitu.disabled = true;
	else
		objSwf.txtTIP._visible = false
	end
	local reviveMap = mapCfg.relive -- 配置回城复活的地图ID，0表示当前地图
	objSwf.btnReviveTp.label = mapCfg.relive == 0 and StrConfig["mainmenuRevive05"] or StrConfig["mainmenuRevive06"]
	--label text
	local freeLevel           = MainMenuConsts:GetReviveFreeLevel()
	local itemId              = MainMenuConsts:GetReviveItem()
	local itemCfg             = t_item[itemId]
	local itemName            = itemCfg and itemCfg.name
	-- objSwf.txtInfo.htmlText   = string.format( StrConfig["mainmenuRevive01"], freeLevel, itemName )
	local bagItemNum = BagModel:GetItemNumInBag(MainMenuConsts:GetReviveItem())
	objSwf.txtInfo.htmlText   = string.format( StrConfig["mainmenuRevive01"], bagItemNum)
	objSwf.txtTime.text       = ""
	objSwf.txtTime1.text       = ""
	-- local killer              = CPlayerMap:GetPlayer( self.killerCid )
	local killerName          = '';--killer and string.format( StrConfig["mainmenuRevive07"], killer:GetName() ) or StrConfig["mainmenuRevive08"]
	if self.killerType == enEntType.eEntType_Player then
		killerName 			  = string.format( StrConfig["mainmenuRevive07"], self.killerName );
	else
		killerName			  = StrConfig["mainmenuRevive08"];
	end
	objSwf.txtKiller.htmlText = string.format( StrConfig["mainmenuRevive09"], killerName )
	-- unit为时刻值的单位，1为秒，60为分钟，0.001为毫秒， <=0.000001为微秒，以此类推，默认毫秒。
	local timeTable           = _G._time( {}, _now() )
	-- objSwf.txtDeathTime.text  = string.format( StrConfig["mainmenuRevive10"], timeTable.month, timeTable.day, timeTable.hour, timeTable.min, timeTable.sec )
	-- auto buy
	objSwf.chkBoxAutoBuy.selected = self.autoBuy
	-- 复活石价格
	local price1 = MainMenuConsts:GetReviveLijin()
	local price2 = MainMenuConsts:GetReviveYuanBao()
	-- local playerInfo = MainPlayerModel.humanDetailInfo
	-- local color1 = playerInfo.eaBindMoney < price1 and "#FF0000" or "#00FF00"
	-- local color2 = playerInfo.eaUnBindMoney < price2 and "#FF0000" or "#00FF00"
	-- objSwf.txtFuhuoshi.htmlText = string.format( "复活丹价格：<font color='%s'>%s绑元</font>/个 或<font color='%s'>%s元宝</font>/个。优先扣绑元",
	-- 	color1, price1, color2, price2 )
	-- objSwf.txtFuhuoshi.htmlText = string.format( StrConfig['mainmenuRevive11'], price1, price2 )
	--show as model window
	local wWidth, wHeight = UIManager:GetWinSize();
	objSwf.mcMask._width  = wWidth;
	objSwf.mcMask._height = wHeight;
end

function UIRevive:GetWidth()
	return 454;
end

function UIRevive:GetHeight()
	return 261;
end

function UIRevive:OnResize(wWidth, wHeight)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.mcMask._width = wWidth;
	objSwf.mcMask._height = wHeight;
end

--点击原地复活
function UIRevive:OnBtnReviveSituClick()
	self:ReqRevive( REVIVE_TYPE.IN_SITU_REVIVE );
end

--点击回城复活
function UIRevive:OnBtnReviveTpClick()
	self:ReqRevive( REVIVE_TYPE.BACK_TO_REVIVE );
end

--自动购买复活道具复选框
function UIRevive:OnAutoBuyClick(e)
	self.autoBuy = e.target.selected
end

--鼠标悬浮复活道具
function UIRevive:OnItemOver()
	local itemId = MainMenuConsts:GetReviveItem()
	TipsManager:ShowItemTips( itemId )
end

--鼠标滑离复活道具
function UIRevive:OnItemOut()
	TipsManager:Hide();
end

--请求复活
function UIRevive:ReqRevive(reviveType)
	local moneyType -- 原地复活的花费类型 0:不需要金钱 1:元宝 2:绑元
	if reviveType == REVIVE_TYPE.IN_SITU_REVIVE then
		local canSitu, mType = self:CheckSituReviveCondition()
		moneyType = mType
		if not canSitu then	return end
	elseif reviveType == REVIVE_TYPE.BACK_TO_REVIVE then
		moneyType = 0
	end
	MainPlayerController:SendReqRevive( reviveType, moneyType );
end

-- 检查原地复活条件
-- @return 1 : 条件是否满足
-- @return 2 : 原地复活的花费类型 0:不需要金钱 1:元宝 2:绑元
function UIRevive:CheckSituReviveCondition()
	local playerInfo = MainPlayerModel.humanDetailInfo
	if playerInfo.eaLevel < MainMenuConsts:GetReviveFreeLevel() then
		return true, 0
	end
	if BagModel:GetItemNumInBag( MainMenuConsts:GetReviveItem() ) > 0 then
		return true, 0
	end
	if self.autoBuy then
		if playerInfo.eaBindMoney >= MainMenuConsts:GetReviveLijin() then
			return true, 2
		end
		if playerInfo.eaUnBindMoney >= MainMenuConsts:GetReviveYuanBao() and playerInfo.eaBindMoney < MainMenuConsts:GetReviveLijin() then
			return true, 1
		end
		FloatManager:AddCenter( StrConfig["mainmenuRevive03"] ); -- 金钱不足
		return false
	end
	FloatManager:AddCenter( StrConfig["mainmenuRevive04"] ); -- 道具不足
	return false
end

function UIRevive:GetReviveTime()
	local mapId = CPlayerMap:GetCurMapID();
	local mapCfg = t_map[mapId];
	return mapCfg.relive_time;
end

--killerCid击杀者ID killerName击杀者名字 killerType击杀者类型
UIRevive.Killer_Player = 0;
UIRevive.Killer_Monster = 1;
function UIRevive:Open(killerCid,killerName,killerType)
	self.killerCid = killerCid
	self.killerName = killerName
	self.killerType = killerType
	self:Show()
end

--------------------------------按钮生效掉计时--------------------------------

local btnEnableTime;
local btnEnableTimerKey;
function UIRevive:StartBtnEnableTimer()
	btnEnableTime = self:GetReviveTime();
	local cb = function() self:OnBtnEnableTimer() end
	btnEnableTimerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	self:BtnEnableCountDown()
end

--倒计时按钮变为可点击状态
function UIRevive:OnBtnEnableTimer()
	btnEnableTime = btnEnableTime - 1
	self:BtnEnableCountDown()
end

UIRevive.IsShowOriginLifeRevive = false;
function UIRevive:BtnEnableCountDown()

	local objSwf = self.objSwf
	if not objSwf then return end
	if self.IsShowOriginLifeRevive then
		objSwf.btnReviveSitu._visible = false   --btnReviveSitu 原地复活    --btnReviveTp  安全复活
		objSwf.btnReviveTp._x = 188
		objSwf.btnReviveTp._y = 276

		objSwf.item._visible= false;
		objSwf.txtInfo._visible = false;
		objSwf.chkBoxAutoBuy._visible = false;
	else
		objSwf.btnReviveSitu._visible = true    --两个都可见
		objSwf.btnReviveTp._x = 268
		objSwf.btnReviveTp._y = 276

		objSwf.item._visible = true;
		objSwf.txtInfo._visible = true
		objSwf.chkBoxAutoBuy._visible = true;
	end
	if btnEnableTime == 0 then
		self:StopBtnEnableTimer()
		self:OnBtnEnableTimeUp()
		return
	end

	objSwf.num._visible           = true
	objSwf.reviveWaiting._visible = true
	objSwf.btnReviveSitu.disabled = true
	objSwf.btnReviveTp.disabled   = true
	objSwf.num.htmlText = string.format( StrConfig["importantNotice007"], btnEnableTime ); 
end

function UIRevive:StopBtnEnableTimer()
	if btnEnableTimerKey then
		TimerManager:UnRegisterTimer( btnEnableTimerKey );
		btnEnableTimerKey = nil;
	end
end

function UIRevive:OnBtnEnableTimeUp()
	self:StartReviveTimer();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.num._visible           = false;
	objSwf.reviveWaiting._visible = false;
	objSwf.btnReviveSitu.disabled = false;
	local mapId = CPlayerMap:GetCurMapID();
	local mapCfg = t_map[mapId];
	if mapCfg.can_fuhuo then
		objSwf.btnReviveSitu.disabled = true;
	end
	objSwf.btnReviveTp.disabled   = false;
end

--------------------------------无操作自动回城复活倒计时--------------------------------

local timeRevive
local reviveTimerKey
function UIRevive:StartReviveTimer()
	timeRevive = MainMenuConsts.ReviveWait;
	local cb = function() self:OnReviveTimer(); end
	reviveTimerKey = TimerManager:RegisterTimer( cb, 1000, timeRevive );
	self:ReviveCountDown();
end

function UIRevive:StopReviveTimer()
	if reviveTimerKey then
		TimerManager:UnRegisterTimer( reviveTimerKey );
		reviveTimerKey = nil;
	end
end

--倒计时自动回城复活
function UIRevive:OnReviveTimer()
	timeRevive = timeRevive - 1;
	self:ReviveCountDown();
end

function UIRevive:ReviveCountDown()
	if timeRevive == 0 then
		self:StopReviveTimer()
		self:OnReviveTimeUp()
		return
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime.text= StrConfig["mainmenuRevive02"]
	objSwf.txtTime1.text= string.format( StrConfig["mainmenuRevive000002"], timeRevive );
end

--原地计时结束
function UIRevive:OnReviveTimeUp()
	self:Hide();
end
