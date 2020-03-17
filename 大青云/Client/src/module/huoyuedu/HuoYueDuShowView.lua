--[[
弹窗显示
jiayong
]]

_G.UIHuoYueDuShowView = BaseUI:new("UIHuoYueDuShowView");

UIHuoYueDuShowView.TweenScale = 10;
function UIHuoYueDuShowView:Create()
	self:AddSWF("huoyuedushowview.swf",true,"top");
end

function UIHuoYueDuShowView:OnLoaded(objSwf)
	objSwf.btn_autoAdd.click=function() self:onBtnAutoaddClick();end
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end	
end
function UIHuoYueDuShowView:OnShow()
      
	--弹窗显示信息
	 self:ShowHuoYueDu();
	 
	 self:ShowMask();	 
end
function UIHuoYueDuShowView:OnResize()
	self:ShowMask();
end
function UIHuoYueDuShowView:IsTween()
	return true;
end
function UIHuoYueDuShowView:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIHuoYueDuShowView:DoTweenHide()
	self:DoHide();
end

function UIHuoYueDuShowView:TweenShowEff(callback)
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
function UIHuoYueDuShowView:GetWidth()
	return 963;
end

function UIHuoYueDuShowView:GetHeight()
	return 382;
end

function UIHuoYueDuShowView:ShowInfo()
	 self:ShowHuoYueDu();
end
function UIHuoYueDuShowView:onBtnAutoaddClick()
	
	local level = HuoYueDuModel:GetHuoyueLevel()
	local cfg = t_xianjielv[level]
	if not cfg then return; end
	local ExpValue = HuoYueDuModel:GetHuoyueExp() or 0

	local expfull=ExpValue>=cfg.exp
	if not HuoYueDuUtil:GetMaxModelLevel()  then return end
    if not expfull then return end
    HuoYueDuController:ReqHuoYueLevelup();
    HuoYueDuController:GetXianjieModelId()
     
end
function UIHuoYueDuShowView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end
function UIHuoYueDuShowView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil
	end
end
function UIHuoYueDuShowView:OpenPanel(level)
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
	
end
function UIHuoYueDuShowView:ShowHuoYueDu()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--奖励信息
	self:ShowAwardInfo();
	--显示仙级
	self:ShowAttr();
	--显示名字
	self:ShowLevelInfo();
     --显示战斗力
	self:ShowHuoyueFight();
end
function UIHuoYueDuShowView:ShowAwardInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local lvl = math.max(HuoYueDuModel:GetHuoyueLevel(),1);
	local cfg = t_xianjielv[lvl];
	if not cfg then return; end
	local list =  RewardManager:Parse(cfg.item);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(list));
	objSwf.rewardList:invalidateData();
	
	local itemList = {};
	itemList[1] = objSwf.item1;
	itemList[2] = objSwf.item2;
	itemList[3] = objSwf.item3;
	UIDisplayUtil:HCenterLayout(#list, itemList, 64, 650, 235);
end
function UIHuoYueDuShowView:ShowFairyLandModel(index)
	if not t_xianjielv[index] then 

		return 
	end
	self:DisposeFairyLand();
	
	if not self.objUIDraw then
	local viewPort = _Vector2.new(450, 400);
	self.objUIDraw = UISceneDraw:new( "UIHuoYueDuShowView", self.objSwf.fairylandloader, viewPort);
    end
    self.objUIDraw:SetUILoader( self.objSwf.fairylandloader);
	self.objUIDraw:SetScene(t_xianjielv[index].ui_sen);
	self.objUIDraw:SetDraw( true );
	
end
function UIHuoYueDuShowView:DisposeFairyLand()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	   self.objUIDraw:SetUILoader(nil);
	end
	
	if self.objAvatar then
	   self.objAvatar:ExitMap();
	   self.objAvatar = nil;
	end
end
function UIHuoYueDuShowView:ShowAttr()
	
	local objSwf = self.objSwf
	if not objSwf then return; end
	local level = math.max( HuoYueDuModel:GetHuoyueLevel(), 1);
    local levelname=t_xianjielv[level];
    local title=levelname.name;
   --显示3D模型
	self:ShowFairyLandModel(level+1);
	local attrMap = HuoYueDuUtil:GetAttrMap(level);
	local current = math.floor(level/9);
	current=current+1
	if current>9 then

		current=9;	
    end
  --  objSwf.mcBossMedal:gotoAndStop(current)
    
    for i,info in ipairs(HuoYueDuConsts.Attrs) do 
	    local textField = objSwf["txtAttr"..i];
    	
    	local val = attrMap[info];
    	local atname = enAttrTypeName[AttrParseUtil.AttMap[info]] or "";
    	local nameFormat
    	nameFormat = HuoYueDuConsts.AttrNames[info]
    	textField.htmlText = string.format(nameFormat, val);
    	
	    	if textField then 
	    		textField.htmlText = string.format(nameFormat, val);
	    	end;
	   
    end;
end
--
function UIHuoYueDuShowView:ShowRewardFlyIcon()
	
	local objSwf = self.objSwf
	if not objSwf then return; end
    local lvl = math.max(HuoYueDuModel:GetHuoyueLevel(),1);
	local cfg = t_xianjielv[lvl];
	if not cfg then return; end
	local rewardList = RewardManager:ParseToVO(cfg.item);
    local startPos = UIManager:PosLtoG(objSwf.rewardList,70,17);
    RewardManager:FlyIcon(rewardList,startPos,5,true,60);
    self:Hide();
end
function UIHuoYueDuShowView:ShowLevelInfo()
    
 local objSwf = self.objSwf
	if not objSwf then return; end
	local nextlevel = math.max( HuoYueDuModel:GetHuoyueLevel() + 1, 1 )
	local level = math.max(HuoYueDuModel:GetHuoyueLevel(),1);
	local nextAttrMap = HuoYueDuUtil:GetAttrMap(nextlevel);
    local attrMap = HuoYueDuUtil:GetAttrMap(level);
    
    for i,info in ipairs(HuoYueDuConsts.Attrs) do 
	    local txt = objSwf["increment"..i];
    	
    	local val = nextAttrMap[info]; 
    	local oldVla = attrMap[info] 
    	
	    	if txt and val~=oldVla then 	
	    		txt.label = val - oldVla;
	    		txt._visible = true;
	    	else
	    		txt._visible = false;
	    	end;
    end;
end
function UIHuoYueDuShowView:ShowHuoyueFight()
    local objSwf = self.objSwf;
	if not objSwf then return end
	local level= math.max(HuoYueDuModel:GetHuoyueLevel(),1);
	local cfg =t_xianjielv[level]
	local nextcfg = t_xianjielv[level+1]
    if not nextcfg or not cfg then 
    	objSwf.addfight._visible=false
    	return 
    end
    local curfight=PublicUtil:GetFigthValue(AttrParseUtil:Parse(cfg.prop))
	objSwf.fightLoader.num = curfight
    objSwf.nextfightLoader.num=PublicUtil:GetFigthValue(AttrParseUtil:Parse(nextcfg.prop))-curfight 

end
function UIHuoYueDuShowView:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end
function UIHuoYueDuShowView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name==NotifyConsts.HuoYueDuInfoUpdata then
       self:ShowRewardFlyIcon()
    end
end


function UIHuoYueDuShowView:ListNotificationInterests()
	return {
	    NotifyConsts.HuoYueDuInfoUpdata};
end
function UIHuoYueDuShowView:GetPanelType()
	return 0;
end
function UIHuoYueDuShowView:ESCHide()
	return true;
end