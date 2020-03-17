--[[
翅膀即将开启UI
lizhuangzhuang
2015年7月9日23:04:30
]]

_G.UIWingRightOpen = BaseUI:new("UIWingRightOpen");

function UIWingRightOpen:Create()
	self:AddSWF("wingRightOpen.swf",true,"center");
end

function UIWingRightOpen:OnLoaded(objSwf)
	objSwf.hitArea.rollOver = function() self:OnHitAreaOver(); end
	objSwf.hitArea.rollOut = function() self:OnHitAreaOut(); end
	objSwf.hitArea.click = function() self:OnBtnTouchClick() end;
	objSwf.toGet.click = function() self:OnToGetClick()end;
	objSwf.clickHe.click = function() self:OnBtnTouchClick()end;
	objSwf.textCaiLiao.rollOver = function() self:OnCaiLiaoRollOver(); end
	-- objSwf.effBomb.complete = function() self:OnEffBombOver(); end
end
function UIWingRightOpen:OnCaiLiaoRollOver()
	local cfg = t_wing[1002]
	local reCfg = split(cfg.compound,',');
	local NbItemId = toint(reCfg[1]);
	if t_item[NbItemId] then
		TipsManager:ShowItemTips(NbItemId);
	end
end
function UIWingRightOpen:OnToGetClick()
	local cfg = t_wing[1002]
	local reCfg = split(cfg.compound,',');
	local NbItemId = toint(reCfg[1]);
	UIQuickBuyConfirm:Open(self,NbItemId)
end
function UIWingRightOpen:OnBtnTouchClick()
	TipsManager:Hide();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not MainWingUI:IsShow() then
		MainWingUI:Show();
	else
		MainWingUI:Hide();
	end
end
function UIWingRightOpen:GetWidth()
	return 386;
end

function UIWingRightOpen:GetHeight()
	return 166;
end

function UIWingRightOpen:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- objSwf.numloader.num = WingController.wingOpenLevel;
	if self.args[1] and self.args[1]=="guide" then
		objSwf.mcBg._visible = false;
		-- objSwf.numloader.visible = false;
		objSwf.levelGet._visible = false;
	else
		-- objSwf.eff:playEffect(0);
	end
	self:DrawWingModel();
	
	-- objSwf.levelGet.text = string.format( StrConfig['goal007'], WingController.wingOpenLevel);--暂时屏蔽
	-- self:setPro();--暂时屏蔽
	objSwf.clickHe._visible = false
	objSwf.textCaiLiao._visible = false
	objSwf.txtXu._visible = false
	objSwf.txtYoong._visible = false
	objSwf.textCaiLiaoHave._visible = false
	objSwf.toGet._visible = false
	self:setCailiao()
end
function UIWingRightOpen:setCailiao()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local cfg = t_wing[1002]
	local reCfg = split(cfg.compound,',');
	if toint(reCfg[1]) > 0 then 
		local NbItemId = toint(reCfg[1]);
		local NbNum = BagModel:GetItemNumInBag(NbItemId);
		objSwf.textCaiLiaoHave.text = NbNum
		objSwf.toGet.htmlLabel = string.format(StrConfig['goal011']);

		local daoItem = t_item[tonumber(NbItemId)];
		if NbNum >= toint(reCfg[2]) then --已获得足够材料
			objSwf.clickHe._visible = true
			objSwf.textCaiLiao._visible = false
			objSwf.txtXu._visible = false
			objSwf.txtYoong._visible = false
			objSwf.textCaiLiaoHave._visible = false
			objSwf.toGet._visible = false
		else--未获得足够材料
			objSwf.clickHe._visible = false
			objSwf.textCaiLiao._visible = true
			objSwf.txtXu._visible = true
			objSwf.txtYoong._visible = true
			objSwf.textCaiLiaoHave._visible = true
			objSwf.toGet._visible = true
			objSwf.textCaiLiao.htmlLabel = string.format( StrConfig['goal010'], daoItem.name,reCfg[2]);
		end
	end
end
local viewWingHeChengPort;
--显示模型
function UIWingRightOpen:DrawWingModel()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(500, 500); end
		self.objUIDraw = UISceneDraw:new( "UIGetWing", objSwf.modelLoader, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelLoader);
	
	self.objUIDraw:SetScene( "v_wing_jixiechibang_ui.sen", function()
	
	end );
	self.objUIDraw:SetDraw( true );
end

function UIWingRightOpen:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end
function UIWingRightOpen:OnHitAreaOver()
	UIWingOpenTips:Show();
end

function UIWingRightOpen:OnHitAreaOut()
	UIWingOpenTips:Hide();
end
function UIWingRightOpen:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end
function UIWingRightOpen:GetStarEndPos()
	local objSwf = self.objSwf;
	if not objSwf then return {x=0,u=0}; end
	return UIManager:PosLtoG(objSwf,186,100);	
end
function UIWingRightOpen:setPro()
	local objSwf = self.objSwf;
	if not objSwf then return ; end
	objSwf.proLevel.maximum = WingController.wingOpenLevel;
	objSwf.proLevel.value = MainPlayerModel.humanDetailInfo.eaLevel;
	objSwf.proLevel.txt.text = MainPlayerModel.humanDetailInfo.eaLevel..'/'..WingController.wingOpenLevel;
	
end
function UIWingRightOpen:GetTouchPos()
	local objSwf = self.objSwf;
	if not objSwf then return {x=0,y=0}; end
	return UIManager:PosLtoG(objSwf.hitArea,0,0);
end
------ 消息处理 ---- 
function UIWingRightOpen:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate
		}
end;
function UIWingRightOpen:HandleNotification(name,body)
	if body.type == enAttrType.eaLevel then
		-- self:setPro()
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:setCailiao()
	end;
end;