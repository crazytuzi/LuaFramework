--[[
翅膀开启tips
lizhuangzhuang
2015年7月10日22:02:25
]]

_G.UIWingOpenTips = BaseUI:new("UIWingOpenTips");

UIWingOpenTips.objUIDraw = nil;
UIWingOpenTips.objAvatar = nil;

function UIWingOpenTips:Create()
	self:AddSWF("wingOpenTips.swf",true,"highTop");
end

function UIWingOpenTips:OnLoaded(objSwf)
	
end

function UIWingOpenTips:OnShow()
	self:UpdatePos();
	self:ShowAttr();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:DrawWingModel();
end
local viewWingHeChengPort;
--显示模型
function UIWingOpenTips:DrawWingModel()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(1200, 1200); end
		self.objUIDraw = UISceneDraw:new( "UIGetWingTips", objSwf.loader, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.loader);
	
	self.objUIDraw:SetScene( "v_wing_jixiechibang_ui.sen", function()
	
	end );
	self.objUIDraw:SetDraw( true );
end

function UIWingOpenTips:ShowAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_wing[1002];
	if not cfg then return; end
	local str = "";
	local list = AttrParseUtil:Parse(cfg.sattr);
	for i,vo in ipairs(list) do
		local attrStr = "";
		-- attrStr = attrStr .. "<img width='13' height='16' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/> ";
		attrStr = attrStr .. enAttrTypeName[vo.type] .. ":".." +" .. getAtrrShowVal(vo.type,vo.val);
		str = str .. "<font color='#30f100' size='14'>" .. attrStr .. "</font><br/>";
	end
	local list = AttrParseUtil:Parse(cfg.attr);
	for i,vo in ipairs(list) do
		local attrStr = "";
		-- attrStr = attrStr .. "<img width='13' height='16' vspace='-4' src='" .. ResUtil:GetTipsFlagUrl() .. "'/> ";
		attrStr = attrStr .. enAttrTypeName[vo.type] ..":".. "<font color='#d5d0c2' size='14'>".." +" .. getAtrrShowVal(vo.type,vo.val).. "</font>";
		str = str .. attrStr .. "<br/>";
	end
	-- str = string.format("<font color='#ffcc33' size='18'>%s级获得翅膀</font><br/>",WingController.wingOpenLevel) .. str;
	objSwf.tfInfo.htmlText = str;
	objSwf.numFight.num = cfg.fight;
end

function UIWingOpenTips:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIWingOpenTips:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIWingOpenTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		-- self:UpdatePos();
	end
end

function UIWingOpenTips:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end

function UIWingOpenTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local mousePos = _sys:getRelativeMouse();
	objSwf._x = mousePos.x + 25;
	objSwf._y = mousePos.y - self:GetHeight() +155;
end
--执行缓动
function UIWingOpenTips:DoTweenHide()
	local endX,endY;
	-- if self.tweenStartPos then
		-- endX = self.tweenStartPos.x;
		-- endY = self.tweenStartPos.y;
	-- else
	local pos = UIWingRightOpen:GetTouchPos();
	local endX = pos.x+100;
	local endY = pos.y+50;
		-- endX = 0;
		-- endY = winH/2;
	-- end
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- local mc = self.swfCfg.objSwf.content;			
	Tween:To(objSwf,0.45,{_alpha=0,_width=20,_height=20,_x=endX,_y=endY},
				{onComplete=function()
					self:DoHide();
					objSwf._xscale = 100;
					objSwf._yscale = 100;
					objSwf._alpha = 100;
				end},true);
end
function UIWingOpenTips:IsTween()
	return true;
end