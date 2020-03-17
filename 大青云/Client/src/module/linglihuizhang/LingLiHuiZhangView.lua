--[[灵力徽章面板
zhangshuhui
2015年5月13日11:09:16
]]

_G.UILingLiHuiZhangView = BaseUI:new("UILingLiHuiZhangView")

UILingLiHuiZhangView.objUIDraw = nil;--3d渲染器

function UILingLiHuiZhangView:Create()
	self:AddSWF("linglihuizhangPanel.swf", true, nil)
end

function UILingLiHuiZhangView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	objSwf.btnshouyi.click     		= function() self:OnBtnShouYiClick(); end;

	objSwf.lablespeedactivevip.click = function() self:OnBtnVipClick(); end
	objSwf.lablespeedactivevip.rollOver = function() self:OnSpeedActiveRollOver(); end
	objSwf.lablespeedactivevip.rollOut = function() self:OnSpeedActiveRollOut(); end
	
	objSwf.MainBG.hitTestDisable = true;
	
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
end

function UILingLiHuiZhangView:IsShowLoading()
	return true;
end

function UILingLiHuiZhangView:GetPanelType()
	return 0;
end

function UILingLiHuiZhangView:IsShowSound()
	return true;
end

-- function UILingLiHuiZhangView:GetWidth()
	-- return XXXX;
-- end

-- function UILingLiHuiZhangView:GetHeight()
	-- return XXXX;
-- end

function UILingLiHuiZhangView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UILingLiHuiZhangView:BeforeTween()
	local func = FuncManager:GetFunc(FuncConsts.Role);
	if not func then return; end
	self.tweenStartPos = func:GetBtnGlobalPos();
end

function UILingLiHuiZhangView:OnShow(name)
	--初始化数据
	self:InitData();
	--初始化UI
	self:InitUI();
	--显示灵力信息
	self:UpdatePlayerLingLiInfo();
	--显示聚灵信息
	self:UpdateJuLingInfo();
	--刷新聚灵累计收益
	self:UpdateLeiJiShouYi();
	--显示3D摩西
	self:DrawJuLingWan();
end

function UILingLiHuiZhangView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

--点击关闭按钮
function UILingLiHuiZhangView:OnBtnCloseClick()
	self:Hide();
end

function UILingLiHuiZhangView:OnBtnVipClick()
	-- if VipController:GetVipLevel() > 0 then
		UIVip:Show()
	-- else
		-- FloatManager:AddCenter( StrConfig['common001'] );
	-- end
end

function UILingLiHuiZhangView:OnBtnShouYiClick()
	self:OnGuideClick() -- 引导任务接口

	if LingLiHuiZhangModel:GetJuLingCount() < 0 then
		return;
	end
	
	LingLiHuiZhangController:ReqGetJuLing();
end

-- 居中
function UILingLiHuiZhangView:AutoSetPos()
	if self.parent == nil then return; end
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	local objSwf = self.swfCfg.objSwf;

	local Vx = toint(HomesteadConsts.MainViewWH.width / 2) - objSwf._width/2
	local Vy = toint(HomesteadConsts.MainViewWH.height / 2) - objSwf._height/2
	objSwf.content._x = Vx--toint(x or objSwf.content._x,  -1); 
	objSwf.content._y = Vy--toint(y or objSwf.content._y, -1);
end;

function UILingLiHuiZhangView:OnSpeedActiveRollOver()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	local vipcfg = t_vip[playerinfo.eaVIPLevel + 1];
	if not vipcfg then
		local str = StrConfig["linglihuizhang41"];
		TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
		return;
	end
	
	self:UpdateNextChanLiangInfo();
end
function UILingLiHuiZhangView:OnSpeedActiveRollOut()
	TipsManager:Hide();
	self:UpdateJuLingInfo();
	self:UpdateLeiJiShouYi();
end
-------------------事件------------------

function UILingLiHuiZhangView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.ZhuLingProgress then
	elseif name == NotifyConsts.JuLingProgress then
		self:UpdateJuLingInfo();
		self:UpdateLeiJiShouYi();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaZhenQi then
			self:UpdatePlayerLingLiInfo();
		end
	elseif name == NotifyConsts.KillLingLiUpdate then
	elseif name == NotifyConsts.GetShouYiUpdate then
		self:GetLeiJiShouYiEffect();
	end
end

function UILingLiHuiZhangView:ListNotificationInterests()
	return {NotifyConsts.ZhuLingProgress,
			NotifyConsts.JuLingProgress,
			NotifyConsts.PlayerAttrChange,
			NotifyConsts.KillLingLiUpdate,
			NotifyConsts.GetShouYiUpdate};
end

function UILingLiHuiZhangView:InitData()
end

function UILingLiHuiZhangView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--显示灵力信息
function UILingLiHuiZhangView:UpdatePlayerLingLiInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	objSwf.lingliNumLoader.num = playerinfo.eaZhenQi;
end

--显示聚灵信息
function UILingLiHuiZhangView:UpdateJuLingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.tfjuling.text = "";
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if cfg then
		local huizhangaddpre = 0;
		local vipValue = VipController:GetJulingwanChanchu(VipController:GetVipLevel())
		if vipValue > 0 then
			huizhangaddpre = vipValue
		end
		local addnum = cfg.zhenqi[1] * (100 + huizhangaddpre) / 100;
		if addnum % 1 > 0 then
			addnum = addnum - addnum % 1 + 1;
		end
		local str = "";
		if cfg.zhenqi[2]/60 == 1 then
			str = string.format(StrConfig["linglihuizhang5"],addnum,"");
		else
			str = string.format(StrConfig["linglihuizhang5"],addnum,cfg.zhenqi[2]/60);
		end
		objSwf.tfjuling.text = str;
		
		if vipValue <= 0 then
			objSwf.vipspeedinfo.htmlText = string.format(StrConfig["linglihuizhang12"],t_vippower[10101].c_v1/100);
			objSwf.lablespeedactivevip.htmlLabel = StrConfig["linglihuizhang14"];
			if vipValue == 0 then
				objSwf.lablespeedactivevip.htmlLabel = StrConfig["linglihuizhang15"];
			end
		else
			objSwf.vipspeedinfo.htmlText = string.format(StrConfig["linglihuizhang13"],VipController:GetVipLevel(),huizhangaddpre);
			objSwf.lablespeedactivevip.htmlLabel = StrConfig["linglihuizhang15"];
		end
	end
end

--显示下一级vip产量信息
function UILingLiHuiZhangView:UpdateNextChanLiangInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if not cfg then
		return;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local vipNextValue = VipController:GetJulingwanChanchu(VipController:GetVipLevel() + 1)
	-- local vipcfg = t_vip[playerinfo.eaVIPLevel + 1];
	if vipNextValue < 0 then
		return;
	end
	
	local huizhangaddpre = 0;
	local vipValue = VipController:GetJulingwanChanchu(VipController:GetVipLevel())
	if vipValue > 0 then
		huizhangaddpre = vipValue;
	end
	local addnum = cfg.zhenqi[1] * (100 + huizhangaddpre) / 100;
	if addnum % 1 > 0 then
		addnum = addnum - addnum % 1 + 1;
	end
	
	local curvipzhenqi = 0;
	if vipValue > 0 then
		curvipzhenqi = vipValue;
	end
	
	local addchanliang = cfg.zhenqi[1] * (vipNextValue - curvipzhenqi) / 100;
	if addchanliang % 1 > 0 then
		addchanliang = addchanliang + 1;
	end
	if cfg.zhenqi[2]/60 == 1 then
		objSwf.tfjuling.text = string.format(StrConfig["linglihuizhang10"],addnum,addchanliang,"")
	else
		objSwf.tfjuling.text = string.format(StrConfig["linglihuizhang10"],addnum,addchanliang,cfg.zhenqi[2]/60)
	end
	
	if vipValue <= 0 then
		objSwf.vipspeedinfo.htmlText = string.format(StrConfig["linglihuizhang12"],t_vippower[10101].c_v1 / 100);
	else
		objSwf.vipspeedinfo.htmlText = string.format(StrConfig["linglihuizhang13"],VipController:GetVipLevel() + 1,vipNextValue);
	end
	self:NextLeiJiShouYi(LingLiHuiZhangModel:GetHuiZhangOrder(), VipController:GetVipLevel() + 1);
end

--显示下一级vip聚灵信息
function UILingLiHuiZhangView:UpdateNextJuLingInfo(order, viplevel)
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--刷新聚灵累计收益
function UILingLiHuiZhangView:UpdateLeiJiShouYi()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	-- objSwf.jlwgetshouyieffect._visible = false;
	-- objSwf.jlwgetshouyieffect:stopEffect();
	
	objSwf.btnshouyi.disabled = true;
	if LingLiHuiZhangModel:GetJuLingCount() > 0 then
		objSwf.btnshouyi.disabled = false;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	local huizhangcfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if huizhangcfg then
		local zhenqimax = huizhangcfg.zhenqimax;
		local vipMax = VipController:GetJulingwanShangxianZengjia()
		if vipMax > 0 then
			zhenqimax = zhenqimax * (100 + vipMax) / 100;
		end
		if LingLiHuiZhangModel:GetJuLingCount() >= zhenqimax / 10 then
			objSwf.tfshouyi.text = string.format(StrConfig["linglihuizhang30"],LingLiHuiZhangModel:GetJuLingCount().."/"..zhenqimax);
			objSwf.shouyiEffect._visible = true;
		else
			objSwf.tfshouyi.text = LingLiHuiZhangModel:GetJuLingCount().."/"..zhenqimax;
			objSwf.shouyiEffect._visible = false;
		end
		
		--特殊处理 如果是右下角提示框弹出的面板
		if LingLiHuiZhangModel:GetIsItemGuide() == true then
			if LingLiHuiZhangUtil:GetIsOverpercent() == true then
				objSwf.shouyiEffect._visible = true;
			end
			LingLiHuiZhangModel:SetIsItemGuide(false);
		end
	end
end

--刷新聚灵累计收益
function UILingLiHuiZhangView:NextLeiJiShouYi(order, viplevel)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local vipMax = VipController:GetJulingwanShangxianZengjia()
	
	local huizhangcfg = t_huizhang[order];
	if huizhangcfg then
		local zhenqimax = huizhangcfg.zhenqimax;
		if vipMax > 0 then
			zhenqimax = zhenqimax * (100 + vipMax) / 100;
		end
		
		objSwf.tfshouyi.text = LingLiHuiZhangModel:GetJuLingCount().."/"..zhenqimax;
	end
end

--播放获取聚灵累计收益后特效
function UILingLiHuiZhangView:GetLeiJiShouYiEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--objSwf.shouyiEffect._visible = false;
	-- objSwf.jlwgetshouyieffect._visible = true;
	-- objSwf.jlwgetshouyieffect:playEffect(1);
end

-- 显示等级为level的3d碗模型
-- showActive: 是否播放激活动作
local viewJulingwanPort;
function UILingLiHuiZhangView : DrawJuLingWan( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = LingLiHuiZhangModel:GetHuiZhangOrder();
	end
	local cfg = t_huizhang[level];
	if not cfg then
		Error("Cannot find config of huizhang. level:"..level);
		return;
	end
	
	if not self.objUIDraw then
		if not viewJulingwanPort then viewJulingwanPort = _Vector2.new(788, 505); end
		self.objUIDraw = UISceneDraw:new( "UILingLiHuiZhangView", objSwf.modelload, viewJulingwanPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	
	self.objUIDraw:SetScene( cfg.ui_sen, nil );
	self.objUIDraw:NodeVisible(cfg.ui_node,true);
	self.objUIDraw:SetDraw( true );
end;

-----------------------引导接口----------------


function UILingLiHuiZhangView:GetShouYiBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnshouyi;
end


----------------------------------  点击任务接口 ----------------------------------------

function UILingLiHuiZhangView:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.GetLingliClick )
end

------------------------------------------------------------------------------------------