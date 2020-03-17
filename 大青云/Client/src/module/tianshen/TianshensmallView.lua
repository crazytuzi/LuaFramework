--[[
天神突破
版本1.0
]]
_G.UITianshensmallView = BaseUI:new('UITianshensmallView');

UITianshensmallView.timerKey = nil;
UITianshensmallView.currVO=nil;

UITianshensmallView.TweenScale = 10;
function UITianshensmallView:Create()
	self:AddSWF("TianshensmallView.swf",true,"top");
end

function UITianshensmallView:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:Hide(); end
	--突破
	objSwf.btnbreakup.click = function() self:OnbtnShentuClick(); end
	objSwf.btnConsume.rollOver = function(e) self:OnbtnStarItemRollOver(); end
	objSwf.btnConsume.rollOut = function(e) TipsManager:Hide(); end
	objSwf.siStar.maximum = TianShenConsts.MaxStar
end
function UITianshensmallView:OnShow()
     self:OnShowInfo()
	 self:ShowMask();	 
end
function UITianshensmallView:OnResize()
	self:ShowMask();
end
function UITianshensmallView:OpenPanel(currVO)
	self.currVO=currVO;
	if self:IsShow() then
		self:OnShowInfo();
	else
		self:Show();
	end
end
function  UITianshensmallView:OnShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end

    self:ShowUpdateInfo();
    self:ShowTitleInfo()
   -- self:StartTimer()
end
function UITianshensmallView:ShowTitleInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--objSwf.titleloader.source=ResUtil:GetTianshenMainIcon(self.currVO.tid);
end
function UITianshensmallView:OnbtnShentuClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
    if TianShenUtil:IsLevelFull(self.currVO) then return end
	local itemId, itemNum = TianShenConsts:GetStarItem(self.currVO.step)
	local itemCfg = t_item[itemId];
	if BagModel:GetItemNumInBag(itemId) < itemNum then
		FloatManager:AddNormal(StrConfig["tianshen014"], objSwf.btnbreakup);
		return;
	end
	TianShenController:ReqConsumerShentu(self.currVO.tid)
	self:Hide();
end
function UITianshensmallView:OnbtnStarItemRollOver()

	if t_tianshenlv[self.currVO.step] and t_tianshenlv[self.currVO.step].item_cost1 then
		local desTable = split(t_tianshenlv[self.currVO.step].item_cost1, ",")
		local itemid = tonumber(desTable[1]);
		if t_item[itemid] then
			TipsManager:ShowItemTips(itemid);
		end
	end
end

function UITianshensmallView:ShowBreakUpInfo()

	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local staritemId, staritemNum = TianShenConsts:GetStarItem(self.currVO.step)
	local staritemCfg = t_item[staritemId];
	if not staritemCfg then return; end

	local staritemName = staritemCfg and staritemCfg.name or "无道具";
	local starbagnum = BagModel:GetItemNumInBag(staritemId)
	
	local starlabelItemColor = starbagnum >= staritemNum and "#00ff00" or "#ff0000";
	objSwf.btnConsume.htmlLabel = string.format(StrConfig['tianshen020'], starlabelItemColor, staritemName, staritemNum);
	local numcolor = starbagnum >= staritemNum and StrConfig['tianshen022'] or StrConfig['tianshen023']
	objSwf.consumeNum.htmlText=starbagnum..")";
    if starbagnum >= staritemNum then 
	   objSwf.btnbreakup:showEffect(ResUtil:GetButtonEffect10())
    else
       objSwf.btnbreakup:clearEffect();
    end
--	objSwf.consumeNum.htmlText=string.format(StrConfig['tianshen020'], starlabelItemColor, staritemName, staritemNum);
end
function UITianshensmallView:ShowStarUpdate()
	local objSwf = self.objSwf
	if not objSwf then return; end
    local nextstar=self.currVO.star+1<5 and self.currVO.star+1 or 5;
	objSwf.siStar.value = nextstar;
end
function UITianshensmallView:ShowUpdateInfo()
	if not self.currVO then
		return;
	end
	self:ShowStarUpdate();
	--self:ShowTianShenSkill();
	self:ShowBreakUpInfo();
    self:ShowFightInfo();
    self:ShowAttrInfo()
end
function UITianshensmallView:ShowAttrInfo()
	local objSwf = self.objSwf
	if not objSwf then return; end
    
    local cfg =t_tianshenlv[self.currVO.step];
    local nextcfg =t_tianshenlv[self.currVO.step+1];
    if not cfg then return end;
    objSwf.curquality.htmlText=cfg.quality;
    objSwf.curquality.htmlText=cfg and cfg.quality or "";
    objSwf.Nextquality.htmlText=nextcfg and nextcfg.quality or "";
    objSwf.curstar.htmlText=self.currVO.star;
    local nextstar=self.currVO.star+1<5 and self.currVO.star+1 or 5;       
    objSwf.NextStar.htmlText=nextstar;
    objSwf.describestar.htmlText=string.format(StrConfig['tianshen039'],nextstar);
    local curattr=TianShenUtil:GetCurPro(self.currVO.tid);
    local curattrinfo=TianShenUtil:GetTransforNum(curattr)
   -- objSwf.curfight.htmlText=PublicUtil:GetFigthValue(curattrinfo);
  --  objSwf.Nextfight.htmlText=
end
function UITianshensmallView:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end
function UITianshensmallView:ShowFightInfo()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local cfg=t_tianshenlv[self.currVO.step];
	if cfg and cfg.reward_star ~="" then
	objSwf.fightLoader.num=PublicUtil:GetFigthValue(AttrParseUtil:Parse(cfg.reward_star))
	end    
end
function UITianshensmallView:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UITianshensmallView:DoTweenHide()
	self:DoHide();
end

function UITianshensmallView:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end
--时间
local timerKey
local time
function UITianshensmallView:StartTimer()
	local func = function() self:OnTimer() end
	time = TianShenConsts.resultime
	timerKey = TimerManager:RegisterTimer(func, 1000, 0 )
	self:UpdateCountTime()
end
function UITianshensmallView:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
end
function UITianshensmallView:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
	self:UpdateCountTime()
end
function UITianshensmallView:OnTimeUp()
	self:Hide()
end
function UITianshensmallView:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		self:UpdateCountTime()
	end
end
function UITianshensmallView:ListNotificationInterests()
	return {
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.TianShenStarUpdate,
		NotifyConsts.PlayerAttrChange,
	};
end
--处理消息
function UITianshensmallView:HandleNotification(name,body)
	local objSwf = self.objSwf
	if not objSwf then return; end

	if name == NotifyConsts.BagItemNumChange then
		self:ShowBreakUpInfo();
	elseif name == NotifyConsts.TianShenStarUpdate then
		self:ShowUpdateInfo();
	end
end
function UITianshensmallView:UpdateCountTime()
	local objSwf = self.objSwf
	if not objSwf then return end
	local textField = objSwf.txtTime
	textField.htmlText = string.format( StrConfig['waterDungeon301'], time )
end
function UITianshensmallView:GetWidth()
	return 715;
end

function UITianshensmallView:GetHeight()
	return 350;
end
function UITianshensmallView:GetPanelType()
	return 0;
end
function UITianshensmallView:IsTween()
	return true;
end
function UITianshensmallView:OnHide()

end
