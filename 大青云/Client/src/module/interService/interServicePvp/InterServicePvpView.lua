--[[
跨服副本面板
liyuan
]]

_G.UIInterServicePvpView = BaseUI:new("UIInterServicePvpView");
UIInterServicePvpView.avatList = {};
function UIInterServicePvpView:Create()
	self:AddSWF("interServerPvpPanel.swf", true, nil);
end

function UIInterServicePvpView:OnLoaded(objSwf)	
	objSwf.btnEnter.click = function() 
		local myInfo = InterServicePvpModel:GetMyroleInfo()
		if not myInfo.remaintimes or myInfo.remaintimes <= 0 then		
			FloatManager:AddNormal( StrConfig['interServiceDungeon7']);
			return
		end
		
		SitController:ReqCancelSit()
		InterServicePvpController:ReqStartMatchPvp()
		
	end
	objSwf.btn_Skin1.click = function() self:SetSkInfoPanel()end;
	objSwf.skinfopanel.btn_Skin2.click = function() self:SetInfoPanel2()end;
	objSwf.btn_award.click = function()
		-- FloatManager:AddNormal( '体验版本暂不开放' );	
		
		if UIInterServiceRankReward:IsShow() then
			UIInterServiceRankReward:Hide()
			return
		end
		
		self:HideAllChild()
		UIInterServiceRankReward:Show()
	end
	objSwf.btn_honor.click = function()
		-- FloatManager:AddNormal( '体验版本暂不开放' );	
	
		UIShopCarryOn:OpenShopByType(ShopConsts.T_Gongxun)
	
		self:HideAllChild()
	end
	objSwf.btn_ranking.click = function()
		
		if UIInterServiceRanking:IsShow() then
			UIInterServiceRanking:Hide()
			return
		end
		self:HideAllChild()
		UIInterServiceRanking:Show()
	end

	objSwf.btn_rongyaobang.click = function()
		
		if UIInterServiceRongyaoRanking:IsShow() then
			UIInterServiceRongyaoRanking:Hide()
			return
		end
		self:HideAllChild()
		UIInterServiceRongyaoRanking:Show()
	end
	
	objSwf.btnPre.click = function()
		objSwf.btnPre.disabled = true
		objSwf.btnNext.disabled = true
		if InterServicePvpModel.lastSeasonid and InterServicePvpModel.lastSeasonid > -1 then
			InterServicePvpController:ReqCrossSeasonPvpInfo(InterServicePvpModel.lastSeasonid)
		end
	end
	
	objSwf.btnNext.click = function()
		objSwf.btnPre.disabled = true
		objSwf.btnNext.disabled = true
		if InterServicePvpModel.nextSeasonid and InterServicePvpModel.nextSeasonid > -1 then
			InterServicePvpController:ReqCrossSeasonPvpInfo(InterServicePvpModel.nextSeasonid)
		end		
	end	
	
	objSwf.btnRule.rollOver = function () TipsManager:ShowBtnTips(StrConfig['interServiceDungeon8'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function () TipsManager:Hide(); end
	
	local constCfg = t_consts[103]
	if constCfg then
		local year, month, day, hour, minute, second = CTimeFormat:todate(GetServerTime(),true);
		if day > constCfg.val3 then
			objSwf.txtjiesuanri.text = StrConfig['interServiceDungeon32']		
		else
			objSwf.txtjiesuanri.text = StrConfig['interServiceDungeon33']	
		end
		
	end
end

function UIInterServicePvpView:InitView()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	local listStr = split(t_consts[105].param, '#')
	FPrint(t_consts[105].param)
	local listStr1 = split(listStr[1], ',')
	local listStr2 = split(listStr[2], ',')
	
	local myInfo = InterServicePvpModel:GetMyroleInfo()
	objSwf.actTime.text = string.sub(listStr1[1],1,#listStr1[1]-3)..'-'..string.sub(listStr1[2],1,#listStr1[2]-3)..'  '..string.sub(listStr2[1],1,#listStr1[1]-3)..'-'..string.sub(listStr2[2],1,#listStr1[2]-3)
	objSwf.txtRemindNum.text = myInfo.remaintimes or 0
	
	if not myInfo.remaintimes or myInfo.remaintimes <= 0 then
		objSwf.btnEnter.disabled = true
	else
		objSwf.btnEnter.disabled = false
	end	
	self:UpdateEffect()
	
end

function UIInterServicePvpView:UpdateEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local myInfo = InterServicePvpModel:GetMyroleInfo()
	if myInfo.rewardflag == 0 then 
		objSwf.btn_award.effect._visible = false
	else
		objSwf.btn_award.effect._visible = tru
	end;
	
end

-----------------------------------------------------------------------
function UIInterServicePvpView:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	local url1 = ResUtil:GetTitleIconSwf('title2_51')
	UILoaderManager:LoadList({url1},function()
		objSwf.chenghaoLoader1.source = url1;
	end);
	
	local url2 = ResUtil:GetTitleIconSwf('title2_50')
	UILoaderManager:LoadList({url2},function()
		objSwf.chenghaoLoader2.source = url2;
	end);
	
	local url3 = ResUtil:GetTitleIconSwf('title2_52')
	UILoaderManager:LoadList({url3},function()
		objSwf.chenghaoLoader3.source = url3;
	end);
	objSwf.btnPre.disabled = true
	objSwf.btnNext.disabled = true
	self.avatList = {};
	objSwf.btn_Skin1._visible = true;
	objSwf.skinfopanel._visible = false;
	InterServicePvpController:ReqCrossPvpInfo()
	-- self:UpdateMask()
	
	if UIInterServiceMinPanel:IsShow() then
		UIInterServiceMinPanel:Hide()
		UIInterPvp1VsAn:Show()
	end
end

function UIInterServicePvpView:OnHide()
	
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	-- 停止绘画模型
	if self.objUISceneDraw then 
		self.objUISceneDraw:SetDraw(false)
	end;
	for i,info in pairs(self.avatList) do 
		info:ExitMap();
		self.avatList[i] = nil;
	end;		
	objSwf.chenghaoLoader1.source = nil;
	objSwf.chenghaoLoader2.source = nil;
	objSwf.chenghaoLoader3.source = nil;
	self:HideAllChild()
end

function UIInterServicePvpView:OnDelete()
	if self.objUISceneDraw then
		self.objUISceneDraw:SetUILoader(nil);
	end
end

function UIInterServicePvpView:HideAllChild()
	UIInterServiceRankReward:Hide()
	UIInterServiceRanking:Hide()
	UIInterServiceRongyaoRanking:Hide()
end

function UIInterServicePvpView:OnBtnCloseClick()
	self:Hide();
end

-- function UIInterServicePvpView:OnResize(wWidth, wHeight)
	-- if not self.bShowState then return end
	-- self:UpdateMask()
-- end

-- function UIInterServicePvpView:UpdateMask()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.mcMask._width = wWidth + 10
	-- objSwf.mcMask._height = wHeight + 10
	-- self:UpdateCloseButton();
-- end

-- function UIInterServicePvpView:UpdateCloseButton()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.closebtn._x = math.min( math.max( wWidth - 50, 1225 ), 1251 )
-- end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServicePvpView:ListNotificationInterests()
	return {
		NotifyConsts.KuafuPvpInfoUpdate,
		NotifyConsts.KuafuPvpUpFirstRank,
		NotifyConsts.KuafuPvpExitCatching,
	};
end

--处理消息
function UIInterServicePvpView:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.KuafuPvpInfoUpdate then
		self:InitView() 
	elseif name == NotifyConsts.KuafuPvpUpFirstRank then
		self:DrawScene()
	elseif name == NotifyConsts.KuafuPvpExitCatching then 
		UIInterServicePvpView.isMax = false
		UIInterServicePvpView.isMin = false
	end
end

------------------------------------------------------------------------------------
-- 设置自己的信息
function UIInterServicePvpView : SetSkInfoPanel()
	--请求竞技战报
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.skinfopanel._visible = true;
	objSwf.btn_Skin1._visible = false;
	local myRoleInfo = InterServicePvpModel : GetMyroleInfo()
	objSwf.skinfopanel.score.text = MainPlayerModel.humanDetailInfo.eaCrossScore; --积分
	if not myRoleInfo.rank or myRoleInfo.rank == 0 then
		objSwf.skinfopanel.rank.text = '未上榜'
	else
		objSwf.skinfopanel.rank.text = myRoleInfo.rank
	end
	
	objSwf.skinfopanel.maxWin.text = myRoleInfo.contwin
	
	objSwf.skinfopanel.duanwei.text = InterServicePvpModel:GetMyDuanwei(MainPlayerModel.humanDetailInfo.eaCrossDuanwei); --段位
	objSwf.skinfopanel.gongxun.text = MainPlayerModel.humanDetailInfo.eaCrossExploit; --功勋
	FTrace(myRoleInfo)
	if myRoleInfo.totalwin == 0 or myRoleInfo.totalcnt == 0 then
		objSwf.skinfopanel.winRate.text = '0%'
	else
		objSwf.skinfopanel.winRate.text = math.floor(myRoleInfo.totalwin/myRoleInfo.totalcnt*100) ..'%'
	end
end;

-- 关闭自己的信息
function UIInterServicePvpView : SetInfoPanel2()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.skinfopanel._visible = false;
	objSwf.btn_Skin1._visible = true;
end;

_G.InterServicePvpDrawSceneUI = "InterServicePvpDrawSceneUI" 
function UIInterServicePvpView:DrawScene(isFrist)
	local objSwf = self.objSwf;
	if not objSwf then return end	
	local seasonid = InterServicePvpModel.seasonid or 0
	seasonid = seasonid + 1
	objSwf.numLoader.num = seasonid 
	if seasonid < 10 then
		objSwf.numLoader._x = 937
	else
		objSwf.numLoader._x = 927
	end
	
	
	if not InterServicePvpModel.lastSeasonid or InterServicePvpModel.lastSeasonid < 0 then
		objSwf.btnPre.disabled = true
	else
		objSwf.btnPre.disabled = false
	end	
	
	if not InterServicePvpModel.nextSeasonid or InterServicePvpModel.nextSeasonid < 0 then
		objSwf.btnNext.disabled = true
	else
		objSwf.btnNext.disabled = false
	end
	
	--debug.debug();
	if not self.viewPort then self.viewPort = _Vector2.new(1200, 720); end
	if not self.objUISceneDraw then
		self.objUISceneDraw = UISceneDraw:new(_G.InterServicePvpDrawSceneUI, objSwf.scene_load, self.viewPort, true);
	end
	self.objUISceneDraw:SetUILoader( objSwf.scene_load )	
	local src = "pvp_xiaochangjing_ui.sen"
	self.objUISceneDraw:SetScene(src, function()
		self:ShowFristRank();
	end );	
	self.objUISceneDraw:SetDraw( true );
end;

-- 显示123名list
function UIInterServicePvpView : ShowFristRank()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local paSwf = self.objSwf.fristpanel;
	local list = InterServicePvpModel : GetFristList()
	if not list then return end;
	paSwf.fristlist.dataProvider:cleanUp();
	for i,info in ipairs(list) do
		if info.prof and info.prof ~= 0 then
			local vo = {};			
			vo.id =  info.id;
			vo.prof = info.prof;
			vo.name = info.roleName;
			vo.fight = info.fight;
			vo.rank =  string.format(StrConfig["arena102"],info.rank);
			vo.ranks = info.rank;
			vo.ranksf = "dt"..info.rank.."tm"
			paSwf.fristlist.dataProvider:push(UIData.encode(vo));
		end		
	end;
	paSwf.fristlist:invalidateData();

	for i=1,#list,1 do 
		if list[i].prof and list[i].prof ~= 0 then
			local obj = self.objSwf.fristpanel["load"..i]
			self:DrawRole(list[i],i*10,i+4)
		end		
		
		if list[i].xuweiyidai then
			objSwf.mcXuweiyidai1._visible = false
			objSwf.mcXuweiyidai2._visible = false
			objSwf.mcXuweiyidai3._visible = false
		else
			objSwf.mcXuweiyidai1._visible = true
			objSwf.mcXuweiyidai2._visible = true
			objSwf.mcXuweiyidai3._visible = true
		end
	end;

end

function UIInterServicePvpView : DrawRole(vo,ic,index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.avatList[ic] ~= nil then 
		self.avatList[ic]:ExitMap();
		self.avatList[ic] = nil;
	end;
	self.avatList[ic] =  CPlayerAvatar:new();
	self.curModel = self.avatList[ic];
	self.avatList[ic]:CreateByVO(vo);

	local list = self.objUISceneDraw:GetMarkers();
	local indexc = index;
	if index > 4 then
		indexc = index - 4;
	end;
	local indexc = "marker"..indexc
	self.avatList[ic]:EnterUIScene(self.objUISceneDraw.objScene,list[indexc].pos,list[indexc].dir,list[indexc].scale, enEntType.eEntType_Player)
end;
