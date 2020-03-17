--[[
	世界地图：地域操作面板
	郝户
	2014年9月11日15:02:51
]]


_G.UIWorldMapOper = BaseUI:new("UIWorldMapOper");

--地图Id
UIWorldMapOper.mapId = nil;
--面板位置
UIWorldMapOper.pos = {x = 0, y = 0};

function UIWorldMapOper:Create()
	self:AddSWF("bigMapWorldOper.swf", true, "top");
end

function UIWorldMapOper:OnLoaded(objSwf)
	objSwf.btnView._visible = false
	objSwf.btnClose.click       = function()  self:OnBtnCloseClick();   end
	-- objSwf.btnView.click        = function(e) self:OnBtnViewClick(e);   end
	objSwf.btnOnFoot.click      = function(e) self:OnBtnOnFootClick(e); end
	objSwf.btnTeleport.click    = function(e) self:OnBtnTeleportClick(e); end
	objSwf.btnTeleport.rollOver = function(e) self:OnBtnTeleportRollOver(e); end
	objSwf.btnTeleport.rollOut  = function(e) self:OnBtnTeleportRollOut(e); end

end

function UIWorldMapOper:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	--显示位置/内容
	local pos = self.pos;
	objSwf._x = pos.x;
	objSwf._y = pos.y;
	objSwf.textField.htmlText = self:GetTextContent();
end

function UIWorldMapOper:GetTextContent()
	local mapInfo = self.mapInfo
	local format = StrConfig['map201']
	local name = mapInfo:GetName()
	local canPk = mapInfo:CanPk()
	local canPkStr = canPk and StrConfig['map101'] or StrConfig['map102']
	local limitLv = mapInfo:GetLimitLvl()
	local recommandLv = mapInfo:GetRecomandLvl()
	local bossInfo = mapInfo:GetBossInfo()
	local bossStr = bossInfo and string.format( StrConfig['map214'], bossInfo.bossType, bossInfo.bossName) or ""
	return string.format( format, name, canPkStr, limitLv, recommandLv )
end

function UIWorldMapOper:Open(mapInfo, pos)
	self.mapInfo = mapInfo;
	self.pos = pos;
	self:Show();
end

----------------------------------------------------按钮点击---------------------------------------------------
--关闭面板
function UIWorldMapOper:OnBtnCloseClick()
	self:Hide();
end

--查看地图
function UIWorldMapOper:OnBtnViewClick()
	if not self.mapInfo then return end
	local mapId = self.mapInfo:GetId();
	self:Hide();
	if mapId == MainPlayerController:GetMapId() then
		UIBigMap:ShowCurrMap();
	else
		MapController:DrawLocalMap( mapId );
		UIBigMap:ShowLocalMap();
	end
end

--徒步前往
function UIWorldMapOper:OnBtnOnFootClick(e)
	if not self.mapInfo then return end
	local mapId = self.mapInfo:GetId();
	-- 如果是当前地图，提示
	if CPlayerMap:GetCurMapID() == mapId then
		FloatManager:AddNormal( StrConfig["map203"] );
		return;
	end
	-- 如果是副本活动等地图，提示
	if not MapUtils:CanTeleport() then
		FloatManager:AddNormal( StrConfig["map211"] );
		return;
	end
	print('地图id',mapId)
	MainPlayerController:DoAutoRun( mapId );
	self:Hide();
end

--立即传送
function UIWorldMapOper:OnBtnTeleportClick(e)
	local mapInfo = self.mapInfo;
	if not mapInfo then return end
	local mapId = mapInfo:GetId();
	-- 如果是当前地图，提示
	if MainPlayerController:GetMapId() == mapId then
		FloatManager:AddNormal( StrConfig["map203"] );
		return;
	end
	-- 以上条件满足
	MapController:Teleport( MapConsts.Teleport_Map, nil, mapId );
end

function UIWorldMapOper:OnBtnTeleportRollOver(e)
	MapUtils:ShowTeleportTips()
end

function UIWorldMapOper:OnBtnTeleportRollOut(e)
	TipsManager:Hide()
end


-----------------------------------------------消息监听-----------------------------------------
--监听的消息
function UIWorldMapOper:ListNotificationInterests()
	--点击舞台
	return {
		NotifyConsts.StageClick,
		NotifyConsts.StageFocusOut
	}
end

--处理消息
function UIWorldMapOper:HandleNotification(name, body)
	if name == NotifyConsts.StageClick then
		self:OnStageClick( body.target );
	elseif name == NotifyConsts.StageFocusOut then
		self:OnStageFocusOut();
	end
end

--点击舞台其他地方面板关闭
function UIWorldMapOper:OnStageClick( targetClick )
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local target = string.gsub( objSwf._target, "/", "." );
	if string.find( targetClick, target ) then return; end
	self:Hide();
end

--舞台失去焦点时面板关闭
function UIWorldMapOper:OnStageFocusOut()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end

	self:Hide();
end
