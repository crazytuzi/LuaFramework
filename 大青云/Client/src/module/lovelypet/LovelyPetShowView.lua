--[[萌宠展示面板
zhangshuhui
2015年9月18日11:41:11
]]

_G.UILovelyPetShowView = BaseUI:new("UILovelyPetShowView")

UILovelyPetShowView.timerKey = nil;
UILovelyPetShowView.lovelypetid = 0;
UILovelyPetShowView.objUIDraw = nil;
UILovelyPetShowView.meshDir = 0; --模型的当前方向

function UILovelyPetShowView:Create()
	self:AddSWF("lovelypetShowPanel.swf", true, "top")
end

function UILovelyPetShowView:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
	
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
end

function UILovelyPetShowView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.objUIDrawPfx then
		self.objUIDrawPfx:SetUILoader(nil);
	end
end

function UILovelyPetShowView:GetHeight()
	return 353;
end

function UILovelyPetShowView:GetWidth()
	return 370;
end

function UILovelyPetShowView:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UILovelyPetShowView:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 100
	objSwf.mcMask._height = wHeight + 100
end

function UILovelyPetShowView:OnShow()
	self:ShowInfo();
	self:UpdateAttrInfo();
	self:UpdateMask();
end

function UILovelyPetShowView:OnHide()
	if self.objUIDraw and self.objUIDrawPfx then
		self.objUIDraw:SetDraw(false);
		self.objUIDrawPfx:SetDraw(false);
	end	
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
end

function UILovelyPetShowView:OpenPanel(lovelypetid)
	self.lovelypetid = lovelypetid;
	if self:IsShow() then
		self:ShowInfo();
		self:UpdateAttrInfo();
	else
		self:Show();
	end
	
	--播放音效
	self:PlayUpSound();
end

function UILovelyPetShowView:PlayUpSound()
	
end

local viewLovelyPetShowPort;
function UILovelyPetShowView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local cfg = t_lovelypet[self.lovelypetid];
	if not cfg then
		Error("Cannot find config of t_lovelypet. id:"..self.lovelypetid);
		return;
	end
	
	objSwf.nameloader.source = ResUtil:GetLovelyPetIcon(cfg.nameicon);
	local modelId = cfg.model;
	
	local modelCfg = t_petmodel[modelId];
	if not modelCfg then
		Error("Cannot find config of t_petmodel. id:"..modelId);
		return;
	end
	if not self.objUIDraw then
		if not viewLovelyPetShowPort then viewLovelyPetShowPort = _Vector2.new(1900, 900); end
		self.objUIDraw = UISceneDraw:new( "UILovelyPetShowView", objSwf.modelload, viewLovelyPetShowPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	
	self.objUIDraw:SetScene( cfg.ui_get_sen, function()
		local aniName = modelCfg.san_idle;
		if not aniName or aniName == "" then return end
		if not cfg.ui_node then return end
		local nodeName = split(cfg.ui_node, "#")
		if not nodeName or #nodeName < 1 then return end
			
		for k,v in pairs(nodeName) do
			self.objUIDraw:NodeAnimation( v, aniName );
		end
	end );
	self.objUIDraw:NodeVisible(cfg.ui_node,true);
	self.objUIDraw:SetDraw( true );
	
	objSwf.loader._x = -750;
	objSwf.loader._y = -570;
	if not self.objUIDrawPfx then 
		self.objUIDrawPfx = UIPfxDraw:new("UILovelyPetShowViewPfx",objSwf.loader,
									_Vector2.new(1800,1200),
									_Vector3.new(0,-150,25),
									_Vector3.new(1,0,35),
									0x00000000);
		self.objUIDrawPfx:PlayPfx("zuoqifazhen.pfx")
	else
		self.objUIDrawPfx:SetUILoader(objSwf.loader);
		self.objUIDrawPfx:SetCamera(_Vector2.new(1800,1200),_Vector3.new(0,-150,25),_Vector3.new(1,0,35));
	end;
	self.objUIDrawPfx:SetDraw(true)
	
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:Hide();
		FuncManager:OpenFunc(FuncConsts.LovelyPet,true);
	end,MountConsts.MountShowTime,0);
end

function UILovelyPetShowView:OnHitAreaClick()
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		local curPetId = LovelyPetModel:GetFightLovelyPetId()
		LovelyPetController:ReqSendLovelyPet(curPetId, LovelyPetConsts.type_rest);
		 FloatManager:AddSkill("当前活动中不能与萌宠相伴")
		 self:Hide();
		return;
	end
	self:Hide();
	FuncManager:OpenFunc(FuncConsts.LovelyPet,true);
end

function UILovelyPetShowView:Update()
	if not self.bShowState then return end
end

function UILovelyPetShowView:UpdateAttrInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local lovelypetcfg = t_lovelypet[self.lovelypetid];
	if not lovelypetcfg then
		return;
	end
	objSwf.numAttr.num = toint(t_buffeffect[t_buff[lovelypetcfg.buff_id].effect_1].func_param2 * 100);
end