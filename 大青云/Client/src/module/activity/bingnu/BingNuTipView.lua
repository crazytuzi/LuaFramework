--[[
快速解救
zhangshuhui
2015年1月7日20:16:36
]]

_G.UIBingNuTipView = BaseUI:new("UIBingNuTipView");

UIBingNuTipView.curModel = nil;
UIBingNuTipView.smallId = 0;--冰奴的小型的Id，中+1，大+2
UIBingNuTipView.posX = nil;
UIBingNuTipView.posY = nil;

function UIBingNuTipView:Create()
	self:AddSWF("bingnutipPanel.swf",true,"top");
end

function UIBingNuTipView:OnLoaded(objSwf)
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
end

function UIBingNuTipView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIBingNuTipView:OnHide()
	self.posX 		= nil;
	self.posY		= nil;
	
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.curModel then
		self.curModel = nil
	end
end

function UIBingNuTipView:GetWidth()
	return 469;
end

function UIBingNuTipView:GetHeight()
	return 224;
end

--显示Tip
function UIBingNuTipView:OnShow()
	self:ShowBingNuInfo();
	self:UpdatePos();
end

function UIBingNuTipView:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local monsePos = _sys:getRelativeMouse();--获取鼠标位置
	self.posX = monsePos.x;
	self.posY = monsePos.y;
	objSwf._x = monsePos.x - self:GetWidth() - 10;
	objSwf._y = monsePos.y - self:GetHeight() - 18;
end

function UIBingNuTipView:ShowBingNuInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--模型
	self:DrawModel(self.modelId);
	
	objSwf.imgyinliang.visible = false;
	objSwf.imgzhenqi.visible = false;
	objSwf.imglijin.visible = false;
	objSwf.imgexp.visible = false;
	
	local strname = "";
	--冰奴名称
	if self.smallId == UIBingNuMainView.tartertIdStart then
		objSwf.tfbingnu.htmlText = StrConfig['bingnu006'];
		objSwf.imgyinliang.visible = true;
		strname = StrConfig['bingnu010']
	elseif self.smallId == UIBingNuMainView.tartertIdStart + 3 then
		objSwf.tfbingnu.htmlText = StrConfig['bingnu007'];
		objSwf.imgexp.visible = true;
		strname = StrConfig['bingnu011']
	elseif self.smallId == UIBingNuMainView.tartertIdStart + 6 then
		objSwf.tfbingnu.htmlText = StrConfig['bingnu008'];
		objSwf.imglijin.visible = true;
		strname = StrConfig['bingnu012']
	elseif self.smallId == UIBingNuMainView.tartertIdStart + 9 then
		objSwf.tfbingnu.htmlText = StrConfig['bingnu009'];
		objSwf.imgzhenqi.visible = true;
		strname = StrConfig['bingnu013']
	end
	
	--小
	local smallvo = t_collection[self.smallId];
	objSwf.lablebingnusmall.htmlLabel = string.format( strname, smallvo.name) ;
	--奖励值
	objSwf.tfrewardsmall.text = BingNuUtils:GetRewardInfo(smallvo.type);
	
	--中
	local midvo = t_collection[self.smallId + 1];
	objSwf.lablebingnumid.htmlLabel = string.format( strname, midvo.name) ;
	--奖励值
	objSwf.tfrewardmid.text = BingNuUtils:GetRewardInfo(midvo.type);
	
	--大
	local bigvo = t_collection[self.smallId + 2];
	objSwf.lablebingnubig.htmlLabel = string.format( strname, bigvo.name) ;
	--奖励值
	objSwf.tfrewardbig.text = BingNuUtils:GetRewardInfo(bigvo.type);
end

--显示Tips
--@param modelId	模型Id
--@param smallId	冰奴的小型的Id
function UIBingNuTipView:Open(modelId, smallId)
	self:Hide();
	if not modelId then
		return;
	end
	self.modelId = modelId;
	self.smallId = smallId

	if self:IsShow() then
		self:ShowBingNuInfo();
	else
		self:Show();
	end
end

function UIBingNuTipView:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local monsePos = _sys:getRelativeMouse();--获取鼠标位置
		if self.posX ~= monsePos.x or self.posY ~= monsePos.y then
			self.posX = monsePos.x;
			self.posY = monsePos.y;
			objSwf._x = monsePos.x - self:GetWidth() - 10;
			objSwf._y = monsePos.y - self:GetHeight() - 18;
			self:Top();
		end
	end
end

function UIBingNuTipView:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end

-- 创建配置文件
UIBingNuTipView.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(1000,500),
									Rotation = 0,
								  };
function UIBingNuTipView : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = self.defaultCfg.Rotation;
	return cfg;
end

function UIBingNuTipView : DrawModel(modelId)
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local colAvater = CollectionAvatar:NewCollectionAvatar(modelId);
	colAvater:InitAvatar();
	self.curModel = colAvater;
	local drawcfg = UIDrawBingNuConfig[modelId]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();

		UIDrawBingNuConfig[modelId] = drawcfg;
	end;
	
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("BingNuMonster",colAvater, objSwf.modelload,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(colAvater);
	end
	-- 模型旋转
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	self.objUIDraw:SetDraw(true);
end