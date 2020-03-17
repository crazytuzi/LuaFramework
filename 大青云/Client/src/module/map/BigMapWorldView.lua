--[[
大地图:世界地图
lizhuangzhuang
2014年7月20日11:36:08
]]

_G.UIBigMapWorld = BaseUI:new("UIBigMapWorld");

UIBigMapWorld.TweenScale = 10;
function UIBigMapWorld:Create()
	self:AddSWF("bigMapWorld.swf", true, nil );
end

function UIBigMapWorld:OnLoaded(objSwf)
	local btn, tipVO;
	for id, btnName in pairs(MapConsts.mapWorldMap) do
		btn = objSwf[btnName];
		if btn then
			tipVO = MapTipsVO:new(id);
			btn.data = tipVO;
			btn.label = "("..tipVO:GetRecomandLvl().. "级" .. ")";--推荐等级改为显示图片，注释
			-- btn.label = "("..string.gsub( tipVO:GetRecomandLvl(), "-", "~" ) .. "级" .. ")";
			-- btn.levelLabel = string.gsub( tipVO:GetRecomandLvl(), "~", "h" )
			btn.rollOver   = function(e) self:OnMapRollOver(e); end
			btn.rollOut    = function() self:OnMapRollOut(); end
			btn.click      = function(e) self:OnMapClick(e); end
		end
	end
	objSwf.btnReturn.click = function() self:OnBtnReturnClick(); end
end

function UIBigMapWorld:OnShow()
end

function UIBigMapWorld:OnDelete()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for id, btnName in pairs( MapConsts.mapWorldMap ) do
		local btn = objSwf[btnName];
		if btn then
			btn.data = nil;
		end
	end
end

function UIBigMapWorld:OnBtnReturnClick()
	self.parent:ShowCurrMap();
	-- UIBigMap:Show()
end

function UIBigMapWorld:OnMapRollOver(e)
	local tipsVO = e.target.data;
	if not tipsVO then return end
	-- 判断等级是否足够
	local needLevel = tipsVO:GetLimitLvl();
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if myLevel < needLevel then
		TipsManager:ShowBtnTips( string.format( StrConfig["map210"], needLevel ) );
		return;
	end
	TipsManager:ShowTips( tipsVO.tipsType, tipsVO, tipsVO.tipsShowType, TipsConsts.Dir_RightDown );
end

function UIBigMapWorld:OnMapRollOut()
	TipsManager:Hide();
end

function UIBigMapWorld:OnMapClick(e)
	local tipsVO = e.target.data;
	if not tipsVO then return; end
	-- 判断等级是否足够
	local needLevel = tipsVO:GetLimitLvl();
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if myLevel < needLevel then
		FloatManager:AddNormal( StrConfig["map209"] );
		return;
	end
	local pos = _sys:getRelativeMouse(); --获取鼠标位置
	UIWorldMapOper:Open(tipsVO, pos);
	TipsManager:Hide();
end

-- function UIBigMapWorld:IsShowSound()
-- 	return true;
-- end

-- function UIBigMapWorld:ESCHide()
-- 	return true;
-- end

-- function UIBigMapWorld:IsTween()
-- 	return true
-- end

-- function UIBigMapWorld:DoTweenShow()
-- 	-- self:TweenShowEff(function()
-- 	-- 	self:DoShow();
-- 	-- end);
-- end

-- function UIBigMapWorld:TweenShowEff(callback)
-- 	local objSwf = self.objSwf;
-- 	local endX,endY = self:GetCfgPos();
-- 	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
-- 	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
-- 	--
-- 	objSwf._x = startX;
-- 	objSwf._y = startY;
-- 	objSwf._alpha = 50;
-- 	objSwf._xscale = self.TweenScale;
-- 	objSwf._yscale = self.TweenScale;
-- 	--
-- 	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
-- 			{onComplete=callback});
-- end