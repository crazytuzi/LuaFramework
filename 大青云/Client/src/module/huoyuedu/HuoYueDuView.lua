--[[仙界界面
    jiayong
2015年2月2日19:59:00
]]
_G.UIHuoYueDuView = BaseUI:new("UIHuoYueDuView")

UIHuoYueDuView.const = 1;

UIHuoYueDuView.chkBoxUsebtn = true;
UIHuoYueDuView.currentShowLevel = nil
UIHuoYueDuView.nextShowlevel = nil
UIHuoYueDuView.showModelId = nil
function UIHuoYueDuView:Create()
	self:AddSWF("huoyueduPanel.swf", true, "center")
end

function UIHuoYueDuView:OnLoaded(objSwf, name)


	objSwf.btnClose.click = function() self:Hide(); end
	objSwf.listtask.itemClick = function(e) self:OnListTaskClick(e); end

	objSwf.listtask.TaskBtnRollOver = function(e) self:OnListTaskRollOver(e); end
	objSwf.listtask.TaskBtnkRollOut = function(e) self:OnListTaskRollOut(e); end

	objSwf.btnPre.click = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click = function() self:OnBtnNextClick(); end
	objSwf.btn_autoAdd.click = function() self:onBtnAutoaddClick(); end
	objSwf.btn_autoAdd.rollOver = function() self:OnBtnLevelUpRollOver() end
	objSwf.btn_autoAdd.rollOut = function() self:OnBtnLevelUpRollOut() end
	--objSwf.chkBoxUseModel.click=function () self:OnBtnBoxUseModel() end
	-- body
	objSwf.chkBoxUseModel._visible = false;

	RewardManager:RegisterListTips(objSwf.rewardList);
end

function UIHuoYueDuView:OnListTaskRollOver(e)


	TipsManager:ShowBtnTips(StrConfig['huoyuedu019'])
end

function UIHuoYueDuView:OnListTaskRollOut(e)
	TipsManager:Hide();
end

function UIHuoYueDuView:OnBtnBoxUseModel()


	local objSwf = self.objSwf
	if not objSwf then return end
	local currentShowLevel = self.currentShowLevel
	local showModelId = self.showModelId;
	if not currentShowLevel then return end
	local useThisModel = objSwf.chkBoxUseModel.selected
	local currentLevel = math.max(HuoYueDuModel:GetHuoyueLevel(), 1);
	local currentmodel = t_xianjielv[currentLevel];
	if not currentmodel then return; end

	if showModelId == currentmodel.title and useThisModel == false then

		return
	end
	local modelLevel = useThisModel and showModelId or currentmodel.title
	HuoYueDuController:ReqChangeXianjieModel(modelLevel)
end

--升级按钮
UIHuoYueDuView.lastSendTime = 0;
function UIHuoYueDuView:onBtnAutoaddClick()

	local objSwf = self.objSwf;
	if not objSwf then return; end
	--点击间隔
	if GetCurTime() - self.lastSendTime < 1000 then
		return;
	end
	self.lastSendTime = GetCurTime();
	if HuoYueDuUtil:GetMaxModelLevel() then

		UIHuoYueDuShowView:OpenPanel();
	else
		FloatManager:AddNormal(StrConfig["huoyuedu016"], objSwf.btn_autoAdd);
	end
	-- self:Hide(); 
end

function UIHuoYueDuView:OnBtnLevelUpRollOut()

	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i = 1, 7 do
		local txt = objSwf["increment" .. i];
		if txt then
			txt._visible = false;
		end;
	end;
end

function UIHuoYueDuView:GetPanelType()
	return 1;
end

function UIHuoYueDuView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil
	end
end

function UIHuoYueDuView:OnBtnLevelUpRollOver()

	self:ShowLevelInfo();
end

function UIHuoYueDuView:OnBtnPreClick()


	self:showXinajieModel(self.showModelId - 1, true)
end

function UIHuoYueDuView:OnBtnNextClick()

	self:showXinajieModel(self.showModelId + 1, true)
end

function UIHuoYueDuView:showXinajieModel(level, isShow)

	local objSwf = self.objSwf;
	if not objSwf then return; end
	local curLevel = math.max(HuoYueDuModel:GetHuoyueLevel(), 1);
	local modelId = t_xianjielv[curLevel]
	if not modelId then return; end

	if not level then
		level = modelId.title;
	end
	if level == 0 then
		level = HuoYueDuConsts.GetlevelId + 1;
	end
	objSwf.btnPre.disabled = level <= HuoYueDuConsts.GetlevelId + 1
	local maxlevel = t_xianjielv[HuoYueDuUtil:GetMaxLevel()];
	if not maxlevel then return; end

	if level == maxlevel.title or level >= maxlevel.title + 1 then
		objSwf.btnNext.disabled = true
	else
		objSwf.btnNext.disabled = false
	end
	self.showModelId = level;
	self.currentShowLevel = curLevel;

	local levl = self.showModelId - HuoYueDuConsts.GetlevelId;

	self:ShowFairyLandModel(HuoYueDuConsts.GetLevel[levl].level);
	self:ShowImgTitle(HuoYueDuConsts.GetLevel[levl].level)
	local openmodel = HuoYueDuConsts.GetLevel[levl]
	if not openmodel then return; end

	if openmodel.level > curLevel then
		objSwf.nextleveloshow.text = "LV:" .. openmodel.level .. StrConfig["huoyuedu017"];
	else
		objSwf.nextleveloshow.text = " ";
	end
	-- self:ShowUseModelState()
end

function UIHuoYueDuView:ShowUseModelState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local currentlevel = t_xianjielv[self.currentShowLevel]
	if not currentlevel then return; end
	objSwf.chkBoxUseModel.selected = HuoYueDuModel:GetmodelId() == self.showModelId;
	objSwf.chkBoxUseModel.disabled = self.showModelId > currentlevel.title;
end

function UIHuoYueDuView:OnShow(name)
	--初始化数据
	self:InitData();
	--显示列表
	self:ShowHuoYueDuInfo()
	-- 显示等级
	self:HideIncrement();
	--初始化隐藏tips
	self:OnBtnLevelUpRollOut();

	self:showXinajieModel(nil, true);

	self:UpdateMountUpInfo();
end

-- 升级成功信息
function UIHuoYueDuView:UpdateMountUpInfo()

	--奖励信息
	self:ShowAwardInfo();
	--显示仙级
	self:ShowAttr();
	--显示经验
	self:ShowExpValue()
	--显示战斗力信息
	self:ShowHuoyueFight();
	--显示仙界等级名字
	self:ShowLevelSign();
end

--显示经验
function UIHuoYueDuView:ShowExpValue()

	local objSwf = self.objSwf
	if not objSwf then return; end
	local level = HuoYueDuModel:GetHuoyueLevel()
	local cfg = t_xianjielv[level]
	if not cfg then return; end
	objSwf.currentlevel.text = "LV" .. level;
	if HuoYueDuUtil:GetMaxModelLevel() then
		objSwf.nextlevel.text = "LV" .. level + 1;
	else
		objSwf.nextlevel.text = StrConfig["huoyuedu018"];
	end

	local ExpValue = HuoYueDuModel:GetHuoyueExp() or 0
	objSwf.siGrowValue:setProgress(ExpValue, cfg.exp)
	objSwf.Progressvalue.text = ExpValue .. "/" .. cfg.exp;

	local expfull = ExpValue >= cfg.exp
	local levelfull = HuoYueDuUtil:GetMaxModelLevel()
	objSwf.btn_autoAdd.disabled = not expfull
	objSwf.effect._visible = expfull;
	if not expfull then self:OnBtnLevelUpRollOut(); end
end

function UIHuoYueDuView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if HuoYueDuController:GetXianjieUpdate() then
		RemindController:AddRemind(RemindConsts.Type_HuoYueDuUp, 1);
	else
		RemindController:AddRemind(RemindConsts.Type_HuoYueDuUp, 0);
	end
end

function UIHuoYueDuView:HideIncrement()
end

function UIHuoYueDuView:HandleNotification(name, body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.HuoYueDuListRefresh then
		self:ShowHuoYueDuInfo()
		self:ShowExpValue()
	elseif name == NotifyConsts.HuoYueDuLevelUpdata then

	elseif name == NotifyConsts.HuoYueDuInfoUpdata then
		self:UpdateMountUpInfo();
		self:showXinajieModel(nil, true);
	elseif name == NotifyConsts.HuoYueDuChangeModel then
		--self:ShowUseModelState();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:ShowHuoYueDuInfo()
		end
	end
end


function UIHuoYueDuView:ListNotificationInterests()
	return {
		NotifyConsts.HuoYueDuListRefresh, NotifyConsts.HuoYueDuLevelUpdata,
		NotifyConsts.HuoYueDuInfoUpdata, NotifyConsts.HuoYueDuChangeModel,
		NotifyConsts.PlayerAttrChange
	};
end

function UIHuoYueDuView:InitData()
end

--显示3D模型
local const = 0;
function UIHuoYueDuView:ShowFairyLandModel(index)

	local cfg = t_xianjielv[index];
	if not cfg then return end;

	if const == cfg.title and self.objUIDraw then return end
	const = cfg.title;
	self:DisposeFairyLand();
	if not self.objUIDraw then
		local viewPort = _Vector2.new(650, 550);
		self.objUIDraw = UISceneDraw:new("UIHuoYueDuView", self.objSwf.fairylandloader, viewPort);
	end
	self.objUIDraw:SetUILoader(self.objSwf.fairylandloader);
	self.objUIDraw:SetScene(cfg.ui_sen);
	self.objUIDraw:SetDraw(true);
end

function UIHuoYueDuView:DisposeFairyLand()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
	end

	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end

function UIHuoYueDuView:ShowLevelInfo()

	local objSwf = self.objSwf
	if not objSwf then return; end
	if not HuoYueDuUtil:GetMaxModelLevel() then return; end
	local nextlevel = math.max(HuoYueDuModel:GetHuoyueLevel() + 1, 1)


	local nextAttrMap = HuoYueDuUtil:GetAttrMap(nextlevel);
	local attrMap = HuoYueDuUtil:GetAttrMap(self.currentShowLevel);
	for i, info in ipairs(HuoYueDuConsts.Attrs) do
		local txt = objSwf["increment" .. i];

		local val = nextAttrMap[info];
		local oldVla = attrMap[info]

		if txt and val ~= oldVla then
			txt.label = val - oldVla;
			txt._visible = true;
		end
	end;
end

function UIHuoYueDuView:ShowLevelSign()
	local objSwf = self.objSwf;
	if not objSwf then return; end;


	self:ShowImgTitle(self.currentShowLevel)
end

--显示仙阶名字
function UIHuoYueDuView:ShowImgTitle(level)

	local cfg = t_xianjielv[level];
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.titleImg.source = ResUtil:GetHuoyueduLvlName(cfg.name);
end

function UIHuoYueDuView:ShowAttr()

	local objSwf = self.objSwf
	if not objSwf then return; end
	local levelname = t_xianjielv[self.currentShowLevel];
	local title = levelname.name;
	self.const = HuoYueDuUtil:GetAttrIndex(self.currentShowLevel);
	local attrMap = HuoYueDuUtil:GetAttrMap(self.currentShowLevel);

	for i, info in ipairs(HuoYueDuConsts.Attrs) do
		local textField = objSwf["txtAttr" .. i];

		local val = attrMap[info];
		local atname = enAttrTypeName[AttrParseUtil.AttMap[info]] or "";
		local nameFormat
		nameFormat = HuoYueDuConsts.AttrNames[info]
		--textField.htmlText = string.format(nameFormat, val);
		if textField then
			textField.htmlText = string.format(nameFormat, val);
		end;
	end;
end

--显示活跃度信息
function UIHuoYueDuView:ShowHuoYueDuInfo()


	local objSwf = self.objSwf;
	if not objSwf then return; end

	local datalist = HuoYueDuUtil:GetHuoYueDuList();

	objSwf.listtask.dataProvider:cleanUp();
	objSwf.listtask.dataProvider:push(unpack(datalist));
	objSwf.listtask:invalidateData();
	objSwf.listtask:scrollToIndex(0);
end

--显示奖励信息
function UIHuoYueDuView:ShowAwardInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currentShowLevel = math.max(HuoYueDuModel:GetHuoyueLevel(), 1);
	local cfg = t_xianjielv[self.currentShowLevel];
	if not cfg then return; end;
	local list = RewardManager:Parse(cfg.item);

	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(list));
	objSwf.rewardList:invalidateData();
end

--显示战斗力信息
function UIHuoYueDuView:ShowHuoyueFight()

	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_xianjielv[self.currentShowLevel]

	objSwf.fightLoader.num = PublicUtil:GetFigthValue(AttrParseUtil:Parse(cfg.prop))
end

function UIHuoYueDuView:OnListTaskClick(e)

	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end

	if e.item.type == 0 then
		FloatManager:AddNormal(StrConfig['huoyuedu020']);
		return
	end
	local id = e.item.id;
	local cfg = t_xianjie[id]
	if not cfg then
		Error("Cannot find config of UIHuoYueDuView. e.item.id:" .. id);
		return
	end
	if FuncManager:GetFunc(cfg.funcOpen) then
		FuncManager:OpenFunc(cfg.funcOpen, true);
		return
	end
	if id == 1 then
		local questVO = QuestModel:GetDailyQuest();
		if questVO then
			questVO:Proceed(); -- 进行任务
		end
	end
end

function UIHuoYueDuView:GetHeight()
	return 687
end

function UIHuoYueDuView:GetWidth()
	return 1146
end

function UIHuoYueDuView:IsShowLoading()
	return true;
end

function UIHuoYueDuView:IsTween()
	return true;
end

function UIHuoYueDuView:IsShowSound()
	return true;
end



