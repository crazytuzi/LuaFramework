--[[
家园，主建筑ui
wangshuai
]]

_G.UIHomesMainBuildView = BaseUI:new('UIHomesMainBuildView')
UIHomesMainBuildView.FLUTTER_TIME  = 1 -- 飘时间
UIHomesMainBuildView.IsPlaying = false
function UIHomesMainBuildView:Create()
	self:AddSWF('homesteadMainBuildpanle.swf',true,nil)
	self:AddChild(UIHomesBuildLvlUp,"buidlvlup");
end;

function UIHomesMainBuildView:OnLoaded(objSwf)
	self:GetChild("buidlvlup"):SetContainer(objSwf.childPanel);
	objSwf.vip_btn.click = function() self:OnVipClick()end;
	objSwf.vip_btn.rollOver = function() self:OnVipRollOver()end;
	objSwf.vip_btn.rollOut = function() self:OnVipRollOut()end;
	objSwf.rule.rollOver = function() self:RuleOver()end;
	objSwf.rule.rollOut  = function() TipsManager:Hide()end;
	objSwf.lingliGet_btn.click = function() self:julingwanReward() end;
	objSwf.upbulid_btn.click = function() self:ShowBuildUpView()end;
	objSwf.mcLingliEffect.hitTestDisable = true
	objSwf.mcLingliqiu.hitTestDisable = true
	objSwf.mcLingliqiu._visible = false
end;

function UIHomesMainBuildView:OnShow()
	self:JuLingwan();
	self:Sethomename();
	self:SceneLoadFun();
end;

function UIHomesMainBuildView:OnHide()
	if self.avatar then
		self.avatar:ExitUIScene()
		self.avatar = nil
	end
	-- 停止绘画模型
	if self.objUISceneDraw then 
		self.objUISceneDraw:SetDraw(false)
	end;
	self.isLoadScene = false;
end;

--显示升级panel
function UIHomesMainBuildView:ShowBuildUpPanel()
	local child = self:GetChild("buidlvlup");
	if not child then return end;
	child:Show({HomesteadConsts.MainBuild});
end;


function UIHomesMainBuildView:ShowBuildUpView()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local buildLvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild)
	local lvl = t_homebuild[buildLvl+1]
	if not lvl then 
		FloatManager:AddNormal(StrConfig["homestead044"])
		return 
	end;
	self:ShowBuildUpPanel()
end


UIHomesMainBuildView.isLoadScene = false;

function UIHomesMainBuildView:SceneLoadFun()
	local objSwf = self.objSwf;
	if not self.viewPort then self.viewPort = _Vector2.new(940, 580); end
	if not self.objUISceneDraw then
		self.objUISceneDraw = UISceneDraw:new("HomesteadSence", objSwf.sceneLoad, self.viewPort, true);
	end
	self.objUISceneDraw:SetUILoader( objSwf.sceneLoad )
	local src = "ZM_dixing01.sen"
	self.objUISceneDraw:SetScene(src, function()
		self.isLoadScene = true;
		self:AddSceneModel()
	end );
	self.objUISceneDraw:SetDraw( true );
end;



function UIHomesMainBuildView:RuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	TipsManager:ShowBtnTips(StrConfig["homestead058"],TipsConsts.Dir_RightDown)
end;

function UIHomesMainBuildView:OnVipClick()
	if not UIVip:IsShow() then 
		UIVip:Show();
	end;
end;

function UIHomesMainBuildView:Sethomename()
	local roleName = MainPlayerModel.humanDetailInfo.eaName;
	local buildLvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild)
	local objSwf = self.objSwf;
	objSwf.homesaaaLvl_txt.htmlText = string.format(StrConfig["homestead060"],roleName,buildLvl)
end;

function UIHomesMainBuildView:julingwanReward()
	self:OnGuideClick() -- 引导任务接口
	if LingLiHuiZhangModel:GetJuLingCount() <= 0 then
		return;
	end
	LingLiHuiZhangController:ReqGetJuLing();
	self:Play();
end;

function UIHomesMainBuildView:OnVipRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:UpdateNextChanLiangInfo();
end;

function UIHomesMainBuildView:OnVipRollOut()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:JuLingwan()
end;

function UIHomesMainBuildView:JuLingwan()
	local objSwf = self.objSwf
	local vipValue = VipController:GetJulingwanChanchu()
	local huizhangaddpre = 0;
	if vipValue > 0 then
		huizhangaddpre = vipValue
	end
	if vipValue <= 0 then
		objSwf.vipSpeed_txt.htmlText = string.format(StrConfig["linglihuizhang12"],t_vippower[10101].c_v1/100);
		objSwf.vip_btn.htmlLabel = StrConfig["linglihuizhang14"];
		-- if vipValue == 0 then
		-- 	objSwf.vip_btn.htmlLabel = StrConfig["linglihuizhang15"];
		-- end
	else
		objSwf.vipSpeed_txt.htmlText = string.format(StrConfig["linglihuizhang13"],VipController:GetVipLevel(),huizhangaddpre);
		objSwf.vip_btn.htmlLabel = StrConfig["linglihuizhang15"];
	end

	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if cfg then
		local huizhangaddpre = 0;
		local vipValue = VipController:GetJulingwanChanchu()
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

		local zhenqimax = cfg.zhenqimax;
		local vipMax = VipController:GetJulingwanShangxianZengjia()
		if vipMax > 0 then
			zhenqimax = zhenqimax * (100 + vipMax) / 100;
		end
		if LingLiHuiZhangModel:GetJuLingCount() >= zhenqimax / 10 then
			objSwf.tfshouyi.text = string.format(StrConfig["linglihuizhang30"],LingLiHuiZhangModel:GetJuLingCount().."/"..zhenqimax);
		else
			objSwf.tfshouyi.text = LingLiHuiZhangModel:GetJuLingCount().."/"..zhenqimax;
		end
	end;
end;



--显示下一级vip产量信息
function UIHomesMainBuildView:UpdateNextChanLiangInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if not cfg then
		return;
	end
	local vipLvl =  VipController:GetVipLevel() + 1;
	local MaxVipLvl = VipConsts:GetMaxVipLevel()
	if vipLvl >= MaxVipLvl then 
		vipLvl = MaxVipLvl
		if VipController:IsSupremeVip() then 
			return 
		end;
	end;

	local playerinfo = MainPlayerModel.humanDetailInfo;
	local vipNextValue = VipController:GetJulingwanChanchu(vipLvl)
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
	
	-- if vipValue <= 0 then
	-- 	objSwf.vipSpeed_txt.htmlText = string.format(StrConfig["linglihuizhang12"],t_vippower[10101].c_v1 / 100);
	-- else
		objSwf.vipSpeed_txt.htmlText = string.format(StrConfig["linglihuizhang13"],vipLvl,vipNextValue);
	-- end
	self:NextLeiJiShouYi(LingLiHuiZhangModel:GetHuiZhangOrder(), vipLvl);
end

--刷新聚灵累计收益
function UIHomesMainBuildView:NextLeiJiShouYi(order, viplevel)
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

	-- notifaction
function UIHomesMainBuildView:ListNotificationInterests()
	return {
		NotifyConsts.HomesteadBuildInfo,
		NotifyConsts.JuLingProgress,
		}
end;
function UIHomesMainBuildView:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.HomesteadBuildInfo then
		self:PlayBuild3DFpx()
		self:JuLingwan();
		self:Sethomename();
	elseif name == NotifyConsts.JuLingProgress then 
		self:JuLingwan();
	end;
end;

--播放建筑物升级特效
function UIHomesMainBuildView:PlayBuild3DFpx()
	if self.isLoadScene then 
		self:PlayBornSan()
	end;
end

function UIHomesMainBuildView:PlayBornSan()
	if self.avatar then
		self.avatar:ExitUIScene()
		self.avatar = nil
	end
	UIHomesMainBuildView:AddSceneModel()
	if self.avatar then
		self.avatar:ExecAction(self.avatar.bornSan, false)
	end
end

function UIHomesMainBuildView:AddSceneModel()
	local modelId = self:GetMainBuildModelId()
	if modelId then
		local avatar = self:CreateAvatar(modelId)
		if avatar then
			local list = self.objUISceneDraw:GetMarkers()
			local markerName = "marker1"
			avatar:EnterUIScene(self.objUISceneDraw.objScene,
				list[markerName].pos,
				list[markerName].dir,
				list[markerName].scale,
				enEntType.eEntType_mainBuild)
			self.avatar = avatar
		end
	end
end

function UIHomesMainBuildView:GetMainBuildModelId()
	local currLevel = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild)
	local mainBuild = t_homebuild[currLevel]
	if not mainBuild then
		return
	end
	return mainBuild.modelId
end

function UIHomesMainBuildView:CreateAvatar(modelId)
	local avatar = CAvatar:new()
	avatar.avtName = "mainBuild"
	local cfg = t_model[modelId]
	if not cfg then
		return
	end
	local mesh = cfg.skn
	local skl = cfg.skl
	local idleSan = cfg.san_idle
	local bornSan = cfg.san_born
    avatar:SetPart("Body", mesh)
    avatar:ChangeSkl(skl)
    avatar:ExecAction(idleSan, true)
    avatar.bornSan = bornSan
    return avatar
end

-----------------------引导接口----------------
function UIHomesMainBuildView:GetShouYiBtn()
	if not self:IsShow() then return; end
	return self.objSwf.lingliGet_btn;
end
----------------------------------  点击任务接口 ----------------------------------------
function UIHomesMainBuildView:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.GetLingliClick )
end
------------------------------------------------------------------------------------------



-------------------------------灵力特效-------------------------------
function UIHomesMainBuildView:Play()
	if not self:IsShow() then return false end
	if self.IsPlaying then return false end
	self.IsPlaying = true	
	
	local ease = Cubic.easeOut
	local p = self:GetLingliEffect()
	p.complete = function() 	
		self:Flutter() 
		self:ReturnLingliEffect(p)
	end
	p:playEffect(1)
	return true
end

function UIHomesMainBuildView:Flutter()
	local p = UIHomesMainBuildView:GetLingliqiu()
	local x, y = UIHomesMainBuildView:GetTarPos()
	Tween:To( p, UIHomesMainBuildView.FLUTTER_TIME, { _y = y, _x = x, ease = Cubic.easeOut}, { onComplete = function()
		self:Boom()
		self:ReturnLingliqiu(p)
	end} )
end

function UIHomesMainBuildView:Boom()
	--UIMainHead:PlayEffectLingli()
	self.IsPlaying = false
end
---------------------------------------------------------------------------------------------------------------
local lingliMcPool = {}
function UIHomesMainBuildView:GetLingliEffect()		
	local objSwf = self.objSwf
	if not objSwf then return end
	-- local depth = objSwf:getNextHighestDepth()
	-- local mc = table.remove( lingliMcPool ) or objSwf:attachMovie( "McLingliEffect",
		-- self:GetMcName("McLingliEffect"), depth )
	-- mc.hitTestDisable = true
	
	objSwf.mcLingliEffect.visible = true
	return objSwf.mcLingliEffect
end

function UIHomesMainBuildView:ReturnLingliEffect(mc)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- if #lingliMcPool < 10 then
		-- table.push( lingliMcPool, mc )
		-- return
	-- end
	-- mc:removeMovieClip()
	objSwf.mcLingliEffect.visible = false
end

local homemainbuildcount = 0
function UIHomesMainBuildView:GetMcName(prefix)
	homemainbuildcount = homemainbuildcount + 1
	return prefix .. homemainbuildcount
end

--------------------------------------------------------
local lingliqiuPool = {}
function UIHomesMainBuildView:GetLingliqiu()		
	local objSwf = self.objSwf
	if not objSwf then return end
	-- local depth = objSwf:getNextHighestDepth()
	-- local mc = table.remove( lingliqiuPool ) or objSwf:attachMovie( "mcLingliqiu",
		-- self:GetMcLingliqiuName("mcLingliqiu"), depth )
	-- mc.hitTestDisable = true
	-- mc._visible = true
	objSwf.mcLingliqiu._x = 730
	objSwf.mcLingliqiu._y = 560
	objSwf.mcLingliqiu._visible = true
	return objSwf.mcLingliqiu
end

function UIHomesMainBuildView:ReturnLingliqiu(mc)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- if #lingliqiuPool < 10 then
		-- table.push( lingliqiuPool, mc )
		-- return
	-- end
	-- mc._visible = false
	-- mc:removeMovieClip()
	-- objSwf.mcLingliEffect.hitTestDisable = true
	objSwf.mcLingliqiu._visible = false
end

local count = 0
function UIHomesMainBuildView:GetMcLingliqiuName(prefix)
	count = count + 1
	return prefix .. count
end

function UIHomesMainBuildView:GetTarPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	local posg = UIMainHead:GetLingliPosG()
	if not posg then return end
	local posl = UIManager:PosGtoL( objSwf, posg.x, posg.y )
	return posl.x, posl.y
end