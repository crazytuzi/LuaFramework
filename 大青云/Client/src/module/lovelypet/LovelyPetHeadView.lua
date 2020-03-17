--[[萌宠头顶面板
zhangshuhui
2015年9月14日11:41:11
]]

_G.UILovelyPetHeadView = BaseUI:new("UILovelyPetHeadView")

UILovelyPetHeadView.timerKey = nil;
UILovelyPetHeadView.objUIDraw = nil;--3d渲染器
UILovelyPetHeadView.objUIDrawFight = nil;--3d渲染器
UILovelyPetHeadView.lovelypetid = 0;
UILovelyPetHeadView.actiontime = 0;

function UILovelyPetHeadView:Create()
	self:AddSWF("lovelypetHeadPanel.swf", true, "bottom")
end

function UILovelyPetHeadView:OnLoaded(objSwf,name)
	--萌宠
	objSwf.btnLovelyPetNo.rollOver = function() self:OnBtnLovelyPetOver(); end
	objSwf.btnLovelyPetNo.rollOut  = function() self:OnBtnLovelyPetOut(); end
	objSwf.btnLovelyPetNo.click    = function() self:OnBtnLovelyPetClick(); end
	objSwf.btnLovelyPet.rollOver = function() self:OnBtnLovelyPetOver(); end
	objSwf.btnLovelyPet.rollOut  = function() self:OnBtnLovelyPetOut(); end
	objSwf.btnLovelyPet.click    = function() self:OnBtnLovelyPetClick(); end
	objSwf.btnLovelyPetPass.rollOver = function() self:OnBtnLovelyPetOver(); end
	objSwf.btnLovelyPetPass.rollOut  = function() self:OnBtnLovelyPetOut(); end
	objSwf.btnLovelyPetPass.click    = function() self:OnBtnLovelyPetClick(); end
end

function UILovelyPetHeadView:OnShow(name)
	--初始化数据
	self:InitData();
	--计时器
	self:StartTimer();
	--显示
	self:ShowLovelyPetHeadInfo();
end

function UILovelyPetHeadView:OnHide()
	self:DelTimerKey();
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.objUIDrawFight then
		self.objUIDrawFight:SetDraw(false);
	end
end

function UILovelyPetHeadView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.objUIDrawFight then
		self.objUIDrawFight:SetUILoader(nil);
	end
end

function UILovelyPetHeadView:GetWidth()
	return 277;
end

function UILovelyPetHeadView:InitData()
	self.actiontime = 0;
	local id, state = LovelyPetUtil:GetCurLovelyPetState(self.lovelypetid);
	if state == LovelyPetConsts.type_notactive then
	elseif state == LovelyPetConsts.type_fight then
	elseif state == LovelyPetConsts.type_rest then
	elseif state == LovelyPetConsts.type_passtime then
	end
end

--显示信息
function UILovelyPetHeadView:ShowLovelyPetHeadInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	objSwf.btnLovelyPet.visible = false;
	objSwf.btnLovelyPetNo.visible = false;
	objSwf.btnLovelyPetPass.visible = false;
	objSwf.modelload.visible = false;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.objUIDrawFight then
		self.objUIDrawFight:SetDraw(false);
	end
	local openLevel = _G.t_funcOpen[FuncConsts.LovelyPet].open_prama;
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaLevel < openLevel then
		return;
	end
	
	if t_funcOpen[FuncConsts.LovelyPet].isHide == 0 then
		local id, state = LovelyPetUtil:GetCurLovelyPetState();
		if state == LovelyPetConsts.type_fight then
			objSwf.btnLovelyPet.visible = true;
			objSwf.btnLovelyPet.selected = true;
			local lovelypetvo = t_lovelypet[id];
			if lovelypetvo then
				for i=1,4 do
					-- objSwf.btnLovelyPet["iconLoader"..i].source = ResUtil:GetLovelyPetIcon("pet"..id.."_title"..i);
				end
			end
			self:DrawLovelyPetModel(id);
		elseif state == LovelyPetConsts.type_rest then
			objSwf.btnLovelyPet.visible = true;
			objSwf.btnLovelyPet.selected = false;
			local lovelypetvo = t_lovelypet[id];
			if lovelypetvo then
				for i=1,4 do
					-- objSwf.btnLovelyPet["iconLoader"..i].source = ResUtil:GetLovelyPetIcon("pet"..id.."_title"..i);
				end
			end
			self:DrawLovelyPetModel(id);
		elseif state == LovelyPetConsts.type_notactive then
			objSwf.modelload.visible = true;
			self:DrawWingModel(1);
			objSwf.btnLovelyPetNo.visible = true;
			objSwf.btnLovelyPetNo.levelLoader.num = LovelyPetUtil:GetNiuNiuLevel();
		elseif state == LovelyPetConsts.type_passtime then
			objSwf.btnLovelyPetPass.visible = true;
			self:DrawLovelyPetModel(id);
		end
	end
end

--萌宠
function UILovelyPetHeadView:OnBtnLovelyPetOver()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaLevel >= LovelyPetUtil:GetNiuNiuLevel() then
		--出战状态
		local id, state = LovelyPetUtil:GetCurLovelyPetState();
		if state == LovelyPetConsts.type_fight then
			local name,qua = LovelyPetUtil:GetLovelyPetNameId(id)
			local color = TipsConsts:GetItemQualityColor(qua)
			TipsManager:ShowBtnTips(string.format(StrConfig["lovelypet13"],color,name,LovelyPetUtil:GetLovelyPetBuffInfoId(id)), TipsConsts.Dir_RightDown );
		else
			TipsManager:ShowBtnTips(StrConfig["lovelypet12"], TipsConsts.Dir_RightDown );
		end
	else
		UILovelyPetTipView:Show();
	end
end
function UILovelyPetHeadView:OnBtnLovelyPetOut()
	UILovelyPetTipView:Hide();
	TipsManager:Hide();
end

function UILovelyPetHeadView:OnBtnLovelyPetClick()
	local lovelypetvo = t_lovelypet[1];
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaLevel < LovelyPetUtil:GetNiuNiuLevel() then
		return;
	end
	FuncManager:OpenFunc( FuncConsts.LovelyPet, true );
end

local viewLoveyPetHeadPort;
function UILovelyPetHeadView:DrawLovelyPetModel(lovelypetid)
	if lovelypetid == 0 then
		self:DrawWingModel();
	else
		self:DrawWingModelFight(lovelypetid);
	end
end
--显示模型
function UILovelyPetHeadView:DrawWingModel(lovelypetid)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.objUIDraw then
		if not viewLoveyPetHeadPort then viewLoveyPetHeadPort = _Vector2.new(350, 300); end
		self.objUIDraw = UISceneDraw:new( "UILovelyPetHeadView", objSwf.modelload, viewLoveyPetHeadPort);
	end
	local cfg = t_lovelypet[lovelypetid];
	if not cfg then
		Error("Cannot find config of t_lovelypet. id:"..self.lovelypetid);
		return;
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	objSwf.modelload.hitTestDisable = true;
	if lovelypetid==1 then
		self.objUIDraw:SetScene( cfg.ui_xiuxian, function()
				-- local aniName = modelCfg.ui_xiuxian;
				-- if not aniName or aniName == "" then return end
				-- if not cfg.ui_node then return end
				-- local nodeName = split(ui_node, "#")
				-- if not nodeName or #nodeName < 1 then return end
					
				-- for k,v in pairs(nodeName) do
					-- self.objUIDraw:NodeAnimation( v, aniName );
				-- end
			end );
	else
		self.objUIDraw:SetScene( cfg.ui_xiuxian)
	end
	--self.objUIDraw:NodeVisible(ui_node,true);
	self.objUIDraw:SetDraw( true );
end

--显示模型
local viewLoveyPetFightHeadPort;
function UILovelyPetHeadView:DrawWingModelFight(lovelypetid)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_lovelypet[lovelypetid];
	if cfg then
		if not self.objUIDrawFight then
			if not viewLoveyPetFightHeadPort then viewLoveyPetFightHeadPort = _Vector2.new(350, 300); end
			self.objUIDrawFight = UISceneDraw:new( "UILovelyPetHeadFightView", objSwf.modelloadfight, viewLoveyPetFightHeadPort);
		end
		self.objUIDrawFight:SetUILoader(objSwf.modelloadfight);
		objSwf.modelloadfight.hitTestDisable = true;
		if lovelypetid==1 then
			self.objUIDrawFight:SetScene( cfg.ui_xiuxian, function()
					-- local aniName = modelCfg.san_show;
					-- if not aniName or aniName == "" then return end
					-- if not cfg.ui_node then return end
					-- local nodeName = split(ui_node, "#")
					-- if not nodeName or #nodeName < 1 then return end
						
					-- for k,v in pairs(nodeName) do
						-- self.objUIDrawFight:NodeAnimation( v, aniName );
					-- end
				end );
		else
			self.objUIDrawFight:SetScene( cfg.ui_xiuxian)
		end
		--self.objUIDrawFight:NodeVisible(ui_node,true);
		self.objUIDrawFight:SetDraw( true );
	end
end

function UILovelyPetHeadView:StartTimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0);
end

function UILovelyPetHeadView:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--计时器
function UILovelyPetHeadView:OnTimer()
	
end;

--处理消息
function UILovelyPetHeadView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.LovelyPetStateUpdata then
		self:ShowLovelyPetHeadInfo();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel then
			self:ShowLovelyPetHeadInfo();
		end
	end
end

--监听消息
function UILovelyPetHeadView:ListNotificationInterests()
	return {NotifyConsts.LovelyPetStateUpdata,NotifyConsts.PlayerAttrChange};
end
