--[[
	神炉面板
]]

_G.StovePanelView = BaseUI:new("UIStove");

StovePanelView.MAX_LEVEL = 10;
StovePanelView.MAX_STAR = 5;
StovePanelView.tabButton = {};
StovePanelView.currentViewType = 0; --当前显示的类型
StovePanelView.currentViewVO = nil; --当前显示的护盾VO
StovePanelView.currentShowLevel = 0; --当前显示的模型的Level
StovePanelView.nextLevel = 0; --下一个等级
StovePanelView.XUANBING = 0;
StovePanelView.BAOJIA = 1;
StovePanelView.MINGYU = 2;
StovePanelView.nameLabelList = nil;
StovePanelView.valueLabelList = nil;
StovePanelView.plusLabelList = nil;
StovePanelView.oldStar = -1;
StovePanelView.oldLevel = -1;
StovePanelView.UI_PERFUSION_SUBPANEL_VIEW = "UIPerfusionSubPanelView";
StovePanelView.funcMapper = {
	-- [FuncConsts.XuanBing]	= 	StovePanelView.XUANBING,
	[FuncConsts.BaoJia]		=	StovePanelView.BAOJIA,
	[FuncConsts.MingYu]		=	StovePanelView.MINGYU,
};
function StovePanelView:Create()
	self:AddSWF("stovePanel.swf", true, "center");
	self:AddChild(UIPerfusionSubPanelView, self.UI_PERFUSION_SUBPANEL_VIEW);
end


function StovePanelView:OnLoaded(objSwf, name)
	self:GetChild(self.UI_PERFUSION_SUBPANEL_VIEW):SetContainer(objSwf.childPanel);
end

function StovePanelView:InitView(objSwf)
	self:GetChild(self.UI_PERFUSION_SUBPANEL_VIEW):Show();
	-- 界面加载完成后的
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;

	self.tabButton[ StovePanelView.XUANBING ]	= objSwf.btnXuanBing;
	self.tabButton[ StovePanelView.BAOJIA ]     = objSwf.btnBaoJia;
	self.tabButton[ StovePanelView.MINGYU ] 	= objSwf.btnMingYu;

	objSwf.progressBar.trackWidthGap = 26;
	objSwf.progressBar.surfacePolicy = "always";
	objSwf.progressBar.tweenDuration = 0.5;

	objSwf.btnPre.click = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click = function() self:OnBtnNextClick(); end
	objSwf.modelCheck.click = function() self:OnModelCheckClick() end
	for name, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end

	self.nameLabelList = {
		self.objSwf.attrName1,
		self.objSwf.attrName2,
		self.objSwf.attrName3,
		self.objSwf.attrName4,
		self.objSwf.attrName5,
	};
	self.valueLabelList = {
		self.objSwf.roleAttrValue1,
		self.objSwf.roleAttrValue2,
		self.objSwf.roleAttrValue3,
		self.objSwf.roleAttrValue4,
		self.objSwf.roleAttrValue5,
	};
	self.plusLabelList = {
		self.objSwf.plusAttrValue1,
		self.objSwf.plusAttrValue2,
		self.objSwf.plusAttrValue3,
		self.objSwf.plusAttrValue4,
		self.objSwf.plusAttrValue5,
	};

	--功能开启
	self.tabButton[ StovePanelView.BAOJIA ]._visible = FuncManager:GetFuncIsOpen( FuncConsts.BaoJia );
	self.tabButton[ StovePanelView.MINGYU ]._visible = FuncManager:GetFuncIsOpen( FuncConsts.MingYu );

	local layoutButtons = {};
	table.push(layoutButtons, self.tabButton[ StovePanelView.XUANBING ]);
	if FuncManager:GetFuncIsOpen( FuncConsts.BaoJia ) then
		table.push(layoutButtons, self.tabButton[ StovePanelView.BAOJIA ]);
	end
	if FuncManager:GetFuncIsOpen( FuncConsts.MingYu ) then
		table.push(layoutButtons, self.tabButton[ StovePanelView.MINGYU ]);
	end
	UIDisplayUtil:HLayout(layoutButtons, 98, 75, 77);
	layoutButtons = nil;
end

function StovePanelView:OnShow()
	self:InitStoveRedPoint( )
	self:InitView(self.objSwf);

	-- 查看args中第一位的参数有没有，如果有的话，说明是要直接跳转到某一个tab
	if #self.args > 0 then
		local args1 = tonumber(self.args[1]);
		if self.funcMapper[args1] or self.tabButton[args1] then
			self:OnTabButtonClick(args1);
			return;
		end
	end
	-- 默认打开第一个tab
	self:OnTabButtonClick(StovePanelView.XUANBING);
	
end

--adder:houxudong date:2016/7/29
--技能红点提示
StovePanelView.timerKey = nil;
StovePanelView.stoveLoader1 = nil;
StovePanelView.stoveLoader2 = nil;
StovePanelView.stoveLoader3 = nil;
function StovePanelView:InitStoveRedPoint( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	self.timerKey = TimerManager:RegisterTimer(function()

	--玄冰
	if StoveController:IsCanProgress(StovePanelView.XUANBING) then
		PublicUtil:SetRedPoint(objSwf.btnXuanBing, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnXuanBing, nil, 0)
	end

	--宝甲
	if StoveController:IsCanProgress(StovePanelView.BAOJIA) then
		PublicUtil:SetRedPoint(objSwf.btnBaoJia, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnBaoJia, nil, 0)
	end

	--玉佩
	if StoveController:IsCanProgress(StovePanelView.MINGYU) then
		PublicUtil:SetRedPoint(objSwf.btnMingYu, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnMingYu, nil, 0)
	end
	end,1000,0); 
end



--点击标签
function StovePanelView:OnTabButtonClick(type)
	self:TurnToSubpanel(type)
end

function StovePanelView:TurnToSubpanel(type)
	if not self.tabButton[type] then
		return;
	end
	
	self.tabButton[type].selected = true;
	--当前护盾类型 XUANBING = 0 , BAOJIA = 1, MINGYU = 2
	self.currentViewType = type;
	--初始化以下进度条
	local vo = EquipModel:GetStoveInfoVOByType(type);
	if not vo then return; end
	local maxExp = StoveUtil:GetStovePlan(type, vo.currentLevel);
	local currentExp = vo.currentProgress;
	self.objSwf.progressBar.maximum   = maxExp;
	self.objSwf.progressBar.value     = currentExp;
	self:UpdateProgressTxt(currentExp, maxExp);
	if vo.currentLevel < self.MAX_LEVEL then
		self.nextLevel = vo.currentLevel + 1;
	end
	self.oldStar = vo.currentStar;
	if vo.currentLevel == 0 then self.oldStar = -1; end
	self.oldLevel = -1;
	UIPerfusionSubPanelView.selectedTid = -1;
	self.currentShowLevel = vo.currentLevel;
	-- 当前显示的模型阶段
	self:UpdateView(type);
end

function StovePanelView:UpdateViewOnResponseInfo()
	-- 更新数据VO
	self.currentViewVO = EquipModel:GetStoveInfoVOByType(self.currentViewType);
	UIPerfusionSubPanelView.currentLevel = self.currentViewVO.currentLevel;
	UIPerfusionSubPanelView.currentProgress = self.currentViewVO.currentProgress;
	if not self.currentViewVO then return end
	if not self:IsShow() then return end

	if self.currentViewVO.currentLevel < self.MAX_LEVEL then
		self.nextLevel = self.currentViewVO.currentLevel + 1;
	end

	if self.currentViewVO.currentLevel == self.currentShowLevel then
		self.currentShowLevel = self.currentViewVO.currentLevel + 1;
	end


	self:UpdateView(self.currentViewType);
end

function StovePanelView:UpdateView(type)
	local vo = EquipModel:GetStoveInfoVOByType(type);
	if not vo then return; end
	-- 当前护盾VO
	self.currentViewVO = vo;

	self:UpdateModelView(type);
	self:UpdateInfoView(type, vo.currentLevel);
	self:UpdatePreNextBtnView();
	if not UIPerfusionSubPanelView:IsShow() then
		self:ShowChild(StovePanelView.UI_PERFUSION_SUBPANEL_VIEW, false, self.currentViewType, self.currentViewVO.currentLevel, self.currentViewVO.currentProgress)
	else
		UIPerfusionSubPanelView.currentType = self.currentViewType;
		UIPerfusionSubPanelView.currentLevel = self.currentViewVO.currentLevel;
		UIPerfusionSubPanelView.currentProgress = self.currentViewVO.currentProgress;
		UIPerfusionSubPanelView:UpdateView()
	end

end

-- 更新左侧的模型区域的显示
function StovePanelView:UpdateModelView(type)

	if self.currentShowLevel <= 0 then self.currentShowLevel = 1; end


	--是否显示未获得
	if self.currentShowLevel > self.currentViewVO.currentLevel then
		self.objSwf.lossImg._visible = true;
	else
		self.objSwf.lossImg._visible = false;
	end
	if self.currentViewVO.currentLevel > 0 then
		self.objSwf.shenbingjihuoImg._visible = false;
		self.objSwf.shenbingjinjieImg._visible = true;
		self.objSwf.starBar._visible = true;
	else
		self.objSwf.shenbingjihuoImg._visible = true;
		self.objSwf.shenbingjinjieImg._visible = false;
		self.objSwf.starBar._visible = false;
	end
	self:SetModelCheckBoxVisible(type, self.currentShowLevel);
	local showTid = StoveUtil:GetStoveTid(type, self.currentShowLevel);
	if StoveController.outLookTid == showTid then
		self.objSwf.modelCheck.selected = true;
	else
		self.objSwf.modelCheck.selected = false;
	end

	self:UpdateUIDraw(type);
end

function StovePanelView:UpdateUIDraw(type)
	if self.currentShowLevel > self.currentViewVO.currentLevel then
		self.objSwf.lossImg._visible = true;
	else
		self.objSwf.lossImg._visible = false;
	end
	if self.oldLevel == self.currentViewVO.currentLevel then return; end
	self.oldLevel = self.currentViewVO.currentLevel
	self.objSwf.nameLoad.source =  ResUtil:GetStoveNameIcon(StoveUtil:GetStoveNameIcon(type, self.currentShowLevel));
	self.objSwf.levelLoad.source = ResUtil:GetStoveLevelIcon(StoveUtil:GetStoveLevelIcon(type, self.currentShowLevel));
	self.objSwf.bottomLine._visible = true;
	--模型
	if not self.objUIDraw then
		local viewPort = _Vector2.new(1000, 630);
		self.objUIDraw = UISceneDraw:new( "UIStove", self.objSwf.modelLoad, viewPort);
	end
	self.objUIDraw:SetUILoader( self.objSwf.modelLoad);
	self.objUIDraw:SetScene(StoveUtil:GetStoveUISen(type, self.currentShowLevel));
	self.objUIDraw:SetDraw( true );
end

-- 更新右侧的信息显示
function StovePanelView:UpdateInfoView(type, _level)
	local star = self.currentViewVO.currentStar;
	--星级显示
	self.objSwf.starBar:gotoAndStop(self.currentViewVO.currentStar + 1);

	--之前的满星的
	if self.currentShowLevel < self.currentViewVO.currentLevel then
		self.objSwf.starBar:gotoAndStop(6);
		star = 5;
	end

	--属性值 --0级的时候显示一阶段的
	local level = _level;
	if level < 1 then level = 1; end
	if level <= self.currentViewVO.currentLevel or self.currentViewVO.currentLevel == 0 then
		local attrStr = StoveUtil:GetStoveAttr(type, level);
		local attrList = AttrParseUtil:Parse(attrStr);
		local attrStarStr = StoveUtil:GetStoveAttrStar(type, level);
		local attrStarList = AttrParseUtil:Parse(attrStarStr);
		for i = 1, #self.nameLabelList do
			if i <= #attrList then
				self.nameLabelList[i].visible = true;
				self.valueLabelList[i].visible = true;
				self.plusLabelList[i].visible = true;
			else
				self.nameLabelList[i].visible = false;
				self.valueLabelList[i].visible = false;
				self.plusLabelList[i].visible = false;
			end
		end

		for j = 1, #attrList do
			local attrVO = attrList[j];
			local attrStarVO = attrStarList[j];
			local starVal = 0;
			if not attrStarVO then
				starVal = 0;
			else
				starVal = attrStarVO.val * star;
			end
			self.nameLabelList[j].htmlLabel = PublicStyle:GetAttrNameStr(enAttrTypeName[attrVO.type]);
			self.valueLabelList[j].htmlLabel = PublicStyle:GetAttrValStr(getAtrrShowVal(attrVO.type, attrVO.val + starVal)) .. "       ";
		end

		for k, v in pairs(attrStarList) do
			v.val = v.val * star;
		end

		--战斗力计算
		local resultList = PublicUtil:GetFightListPlus(attrList, attrStarList);
		self.objSwf.fightLoader.num = PublicUtil:GetFigthValue(resultList);
	end

	--满星处理
	if self.currentViewVO.currentStar >= StoveUtil:GetStoveXingJi(type, level) or level < self.currentViewVO.currentLevel then
		--self.objSwf.startProgressBtn._visible = false;
		UIPerfusionSubPanelView:ShowPerfusionBtn(false);
		self.objSwf.progressBar._visible = false;
		self.objSwf.progressTxt._visible = false;
	else
		UIPerfusionSubPanelView:ShowPerfusionBtn(true);
		self.objSwf.progressBar._visible = true;
		self.objSwf.progressTxt._visible = true;
	end

	--进度条显示
	if self.currentViewVO.currentLevel > 0 or self.currentViewVO.currentProgress > 0 then
		local maxExp = StoveUtil:GetStovePlan(type, self.currentViewVO.currentLevel);
		local currentExp = self.currentViewVO.currentProgress;
		if self.oldStar ~= self.currentViewVO.currentStar and self.currentViewVO.currentLevel > 0 then
			self.objSwf.progressBar:tweenProgress(currentExp, maxExp, 1);
			self.oldStar = self.currentViewVO.currentStar;
		else
			self.objSwf.progressBar:tweenProgress(currentExp, maxExp, 0);
		end
		self:UpdateProgressTxt(currentExp, maxExp);
	end

	--下一个的
	if level - self.currentViewVO.currentLevel == 1 and self.currentViewVO.currentLevel > 0 then
		self:ShowNextInfoView();
	end
end

function StovePanelView:UpdateProgressTxt(currentExp, maxExp)
	self.objSwf.progressTxt.text = string.format(StrConfig["stove1002"], currentExp, maxExp);
end

-- 更新左右按钮的显示
function StovePanelView:UpdatePreNextBtnView()
	local currentVO = self.currentViewVO;
	if self.currentShowLevel <= 1 then
		self.objSwf.btnPre.disabled = true;
	elseif self.currentShowLevel > 1 then
		self.objSwf.btnPre.disabled = false;
	end
	if (self.currentShowLevel - currentVO.currentLevel) == 1 or currentVO.currentLevel == 0 or self.currentShowLevel >= StovePanelView.MAX_LEVEL then
		self.objSwf.btnNext.disabled = true;
	else
		self.objSwf.btnNext.disabled = false;
	end
end

function StovePanelView:OnBtnPreClick()
	self.oldLevel = -1;
	self.currentShowLevel = self.currentShowLevel - 1;
	self:UpdatePreNextBtnView();
	self:UpdateModelView(self.currentViewType)
	self:UpdateInfoView(self.currentViewType, self.currentShowLevel);
end

function StovePanelView:OnBtnNextClick()
	self.oldLevel = -1;
	self.currentShowLevel = self.currentShowLevel + 1;
	self:UpdatePreNextBtnView();
	self:UpdateModelView(self.currentViewType)
	self:UpdateInfoView(self.currentViewType, self.currentShowLevel);
end

function StovePanelView:OnModelCheckClick()
	if not self.objSwf.modelCheck.selected then
		self.objSwf.modelCheck.selected = true;
		return;
	end
	StoveController:ReqOutLook(self.currentViewType, self.currentShowLevel, self.objSwf.modelCheck.selected);
end

function StovePanelView:OnStartProgressRollOver()
	if not self.currentViewVO then return; end
	if self.currentViewVO.currentLevel <=0 then return; end
	if self.currentViewVO.currentLevel >= self.MAX_LEVEL then return; end
	if self.currentShowLevel - self.currentViewVO.currentLevel == 1 then return; end
	self:OnBtnNextClick();
end

function StovePanelView:ShowNextInfoView()
	if self.currentViewVO.currentLevel == 0 then
		self:ClearNextInfoView();
		return;
	end
	if self.currentViewVO.currentLevel == self.MAX_LEVEL then return; end

	local type = self.currentViewType;
	local currentVO = self.currentViewVO;
	local level = self.nextLevel;
	if not currentVO then return; end
	if level == currentVO.currentlevel then
		level = level + 1;
	end
	if level <= 1 then level = level + 1; end
	local currentLevel = currentVO.currentLevel;
	if currentLevel <= 0 then currentLevel = 1; end
	local attrStrNext = StoveUtil:GetStoveAttr(type, level)
	local attrListNext = AttrParseUtil:Parse(attrStrNext);

	local attrStr = StoveUtil:GetStoveAttr(type, currentLevel);
	local attrList = AttrParseUtil:Parse(attrStr);
	local attrStarStr = StoveUtil:GetStoveAttrStar(type, currentLevel);
	local attrStarList = AttrParseUtil:Parse(attrStarStr);
	for j = 1, #attrList do
		local attrVONext = attrListNext[j];
		local attrNextVal = attrVONext.val;

		local attrVO = attrList[j];
		local attrStarVO = attrStarList[j];
		local starVal = 0;
		if not attrStarVO then
			starVal = 0;
		else
			starVal = attrStarVO.val;
		end

		local attrVal = attrVO.val + starVal * currentVO.currentStar;
		--local plusVal = getAtrrShowVal(attrVO.type, attrNextVal - attrVal) .. "(" .. (self.MAX_STAR - currentVO.currentStar) .. "颗星)";
		local plusVal = getAtrrShowVal(attrVO.type, starVal) .. StrConfig["stove1001"];
		self.plusLabelList[j].label = "+" .. plusVal .. "       ";
	end
	local nextFightValue =  PublicUtil:GetFigthValue(attrListNext);
	local fightValue = PublicUtil:GetFigthValue(attrList);
	self.objSwf.plusFightValue.label = "+" .. (nextFightValue - fightValue) .. "       ";
end

function StovePanelView:OnStartProgressRollOut()
	if not self.currentViewVO then return; end
	if self.currentViewVO.currentLevel <=0 then return; end
	if self.currentViewVO.currentLevel >= self.MAX_LEVEL then return; end
	self:OnBtnPreClick();
	self:ClearNextInfoView();
end

function StovePanelView:ClearNextInfoView()
	if not self.plusLabelList then return; end
	for k, v in pairs(self.plusLabelList) do
		v.label = "                     ";
	end
	self.objSwf.plusFightValue.label = "                     ";
end

--目前只有玄兵，并且是
function StovePanelView:SetModelCheckBoxVisible(type, showLevel)
	local type = self.currentViewType;
	local currentVO = self.currentViewVO;
	local visible = false;
	if type == StovePanelView.BAOJIA or type == StovePanelView.MINGYU then
		visible = false;
	else
		--玄兵
		if showLevel <= currentVO.currentLevel and currentVO.currentLevel > 0 and showLevel > 0 then
			visible = true;
		else
			visible = false;
		end
	end
	self.objSwf.modelCheck._visible = visible;
end


function StovePanelView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
		self.objUIDraw = nil;
	end

	for k, v in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
	self.currentViewVO = nil;
	self.nameLabelList = nil;
	self.valueLabelList = nil;
	self.plusLabelList = nil;
	if self.stoveLoader1 then
		self:RemoveRedPoint(self.stoveLoader1)
		self.stoveLoader1 = nil;
	end
	if self.stoveLoader2 then
		self:RemoveRedPoint(self.stoveLoader2)
		self.stoveLoader2 = nil;
	end
	if self.stoveLoader3 then
		self:RemoveRedPoint(self.stoveLoader3)
		self.stoveLoader3 = nil;
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end

--人物面板中详细信息为隐藏面板，不计算到总宽度内
function StovePanelView:GetWidth()
	return 1397;
end

function StovePanelView:GetHeight()
	return 823;
end

function StovePanelView:IsTween()
	return true;
end

function StovePanelView:GetPanelType()
	return 1;
end

function StovePanelView:ESCHide()
	return true;
end

function StovePanelView:IsShowLoading()
	return true;
end

function StovePanelView:IsShowSound()
	return true;
end

function StovePanelView:WithRes()
	return {"stovePerfusionSubPanel.swf"}
end

--点击关闭按钮
function StovePanelView:OnBtnCloseClick()
	self:Hide();
end
