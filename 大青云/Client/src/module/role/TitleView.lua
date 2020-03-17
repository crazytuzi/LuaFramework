--[[
	称号面板
	2014年11月21日, AM 11:37:00
	wangyanwei
]]
_G.UITitle =  BaseUI:new("UITitle");

UITitle.panelTOpneIndex = -1;

UITitle.indexId = 1;

UITitle.objAvatar = nil;--人物模型
UITitle.objUIDraw = nil;--3d渲染器
UITitle.meshDir = 0; --模型的当前方向

UITitle.timeKey = nil; --刷新称号时间计时器

UITitle.panelTMap = {
	{type=TitleConsts.RType_Ranking,label=""},
	{type=TitleConsts.RType_Activity,label=""},
	{type=TitleConsts.RType_Special,label=""},
};

function UITitle:Create()
	self:AddSWF("titlePanel.swf",true,nil);
end

function UITitle:OnLoaded(objSwf)
	self:InitTitleInfoTxt();  --默认文本text赋值；
	
	objSwf.titleInfoPanel.sendBtn.click = function() self:OnSendBtnClickHandler();end;
	
	objSwf.titleRuleInfo.rollOver = function() self:OnTxtOverHandler(); end
	objSwf.titleRuleInfo.rollOut = function() self:OnTxtOutHandler();end
	
	objSwf.titleInfoPanel._visible = false; --隐藏属性面板
	
	
	objSwf.treeList.itemClick = function (e)
		self:ItemClick(e);
	end
	objSwf.roleLoader.hitTestDisable = true;
end

--点击事件
function UITitle:ItemClick(e)
	if not e.item.id then return end
	local objSwf = self.objSwf;
	self.selectedTitleId = e.item.id;
	objSwf.treeList:selectedState(e.item.id);
	self:OnChangeTreeList(e);
end

function UITitle:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UITitle:OnShow()
	local objSwf = self:GetSWF("UITitle");
	if not objSwf then return ; end;
	for i = 1 , #t_titlegroup do
		self.panelTMap[i].label = t_titlegroup[i].name;
	end
	self:OnShowTitlePanel();  --显示初始的方法
	self:DrawRole();
end
--------------------------------------UI面板显示的设置-------------------------------------------
--关闭显示
function UITitle:OnHide()
	local objSwf = self:GetSWF("UITitle");
	if not objSwf then return; end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil)
	end
	self.meshDir = 0;
	if self.objAvatar then 
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.selectedTitleId = 0;
end
--显示
function UITitle:OnShowTitlePanel()
	--self:ShowTitleOnlineNum();--显示所有称号类型的标签
	self:NewShowTitleHandler();--------------new显示所有称号类型的标签
	--self:ShowTitleList(self.panelTOpneIndex);
end
--=================================================================================             new
UITitle.treeData = {};
UITitle.selectedTitleId = 0;
function UITitle:NewShowTitleHandler()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	UIData.cleanTreeData( objSwf.treeList.dataProvider.rootNode);
	local verSionName = Version:GetName();
	self.treeData.label = "root";
	self.treeData.open = true;
	self.treeData.isShowRoot = false;
	self.treeData.nodes = {};
	
	local oneListinHight = false;
	
	for i , v in pairs(self.panelTMap) do
		local trunkVO = v;
		if trunkVO then
			local trunkNode = {};
			trunkNode.open = true;
			trunkNode.withIcon = true;
			trunkNode.str = v.label;
			trunkNode.nodes = {};
			trunkNode.nodeType = 1;
			trunkNode.id = i;
			--标题
			trunkNode.label = v.label;
			local typeTitles = TitleModel:GetTitleTable(v.type)
			for j , k in pairs(typeTitles) do
				local nowCfg = TitleModel:GetTitleCfg(k.id);
				if nowCfg then
					local branchTitleNode = {};
					branchTitleNode.nodeType = 2;
					branchTitleNode.unDress = TitleModel:OnEquipBoolean(k.id);
					branchTitleNode.iconSource = ResUtil:GetTitleIconUrl(k.icon);
					branchTitleNode.id = k.id;
					if k.id == self.selectedTitleId then
						branchTitleNode.btnSelected = true;
					end
					table.push(trunkNode.nodes, branchTitleNode);
				end
			end
			for j , k in pairs(TitleModel:GetTitleTable(v.type)) do
				-- local nowCfg = TitleModel.oldTitleData[i][j];
				if not TitleModel:GetTitle(k.id) and k.type ~= 1 then
					local branchTitleNode = {};
					branchTitleNode.nodeType = 2;
					branchTitleNode.unDress = TitleModel:OnEquipBoolean(k.id);
					branchTitleNode.iconSource = ResUtil:GetNotTitleIconUrl(k.grayicon);
					branchTitleNode.id = k.id;
					branchTitleNode.btnSelected = false;
					branchTitleNode.index = i;
					if k.id == self.selectedTitleId then
						branchTitleNode.btnSelected = true;
					end
					table.push(trunkNode.nodes, branchTitleNode);
				end
			end
			if self.selectedTitleId == 0 then 
				if #trunkNode.nodes >= 1 and oneListinHight == false then
					oneListinHight = true;
					self:OnListItemClickHandler(trunkNode.nodes[1].id);
					trunkNode.nodes[1].btnSelected = true;
					if #trunkNode.nodes > 1 then
						trunkNode.nodes[2].btnSelected = false;
					end
				end
				
			end
			table.push(self.treeData.nodes, trunkNode);
		end
	end
	UIData.copyDataToTree(self.treeData,objSwf.treeList.dataProvider.rootNode);
	objSwf.treeList.dataProvider:preProcessRoot();
	objSwf.treeList:invalidateData();
end

--重绘
function UITitle:OnChangeTreeList(e)
	if e.item.nodeType == 2 then
		self:OnListItemClickHandler(e.item.id);
	end
end

--=============================================================================================


--穿戴卸下按钮点击事件
function UITitle:OnSendBtnClickHandler()
	local objSwf = self:GetSWF("UITitle");
	if not objSwf then return ; end;
	
	local boolean = RoleUtil:GetProTitleData(self.indexId);
	if boolean then
		TitleModel:SetTitleStateHandler(self.indexId);
	else
		return ;
	end
end

--规则tip
function UITitle:OnTxtOverHandler()
	TipsManager:ShowBtnTips(StrConfig['title200'],TipsConsts.Dir_RightDown);
end

--规则tip移除
function UITitle:OnTxtOutHandler()
	TipsManager:Hide();
end

--按钮文本显示
function UITitle:OnChangeBtnTxtHandler(id)
	local objSwf = self:GetSWF("UITitle");
	if not objSwf then return ; end;
	objSwf.titleInfoPanel.sendBtn.label = TitleModel:GetBtnState(id);
end

--list 点击事件 变换属性和介绍的文本内容
function UITitle:OnListItemClickHandler(id)
	local objSwf = self:GetSWF("UITitle");
	if not objSwf then return; end
	local cfg = t_title[id];
	if not cfg then return end;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.indexId = cfg.id;
	self:OnChangeTxtHandler(cfg);
	self:OnChangeBtnTxtHandler(self.indexId);
	objSwf.titleInfoPanel._visible = true;
	if TitleModel:GetTitleTimeHandler(id) ~= 0 and TitleModel:GetTitleTimeHandler(id) ~= -1 then
		objSwf.titleInfoPanel.statusMess_txt._visible = true;
	else
		objSwf.titleInfoPanel.statusMess_txt._visible = false;
	end
	-- if TitleModel:GetTitleType(id) ~= TitleConsts.RType_Activity then
		-- objSwf.titleInfoPanel.statusMess_txt._visible = false;
		-- objSwf.titleInfoPanel.status_txt._visible = false;
	-- else
		-- objSwf.titleInfoPanel.statusMess_txt._visible = true;
		-- objSwf.titleInfoPanel.status_txt._visible = true;
	-- end
end

--设置文本方法
UITitle.propertyNum = 1;
function UITitle:OnChangeTxtHandler(cfg)
	local objSwf = self:GetSWF("UITitle");
	if not objSwf then return; end
	objSwf.titleInfoPanel.titleStateMess_txt.text = cfg.info ;
	objSwf.titleInfoPanel.conditionMess_txt.text = cfg.getInfo .. cfg.prop;
	
	self:OnChangeTitleTxt();  --改变称号时间剩余文本
	
	-----------------改变展示称号---------------
	local func = function ()
		objSwf.titleInfoPanel.bigIconItem.source = ResUtil:GetTitleIconSwf(cfg.bigIcon);
	end
	UILoaderManager:LoadList({ResUtil:GetTitleIconSwf(cfg.bigIcon)},func);
	objSwf.titleInfoPanel.bigIconItem.loaded = function() 
											   objSwf.titleInfoPanel.bigIconItem.content._xscale = cfg.titleUIscale*100;
											   objSwf.titleInfoPanel.bigIconItem.content._yscale = cfg.titleUIscale*100;
											   objSwf.titleInfoPanel.bigIconItem.content._x = -toint(cfg.titleWidth * cfg.titleUIscale/2)
											   objSwf.titleInfoPanel.bigIconItem.content._y = -toint(cfg.titleHeight * cfg.titleUIscale/2)
											   end
	--属性文本
	local obj =	TitleModel:GetTitleData(self.indexId);
	objSwf.titleInfoPanel["txt_property" .. self.propertyNum].htmlText = StrConfig['title10'].. string.format(StrConfig['title50'],obj.att); self.propertyNum = self.propertyNum + 1 ;
	objSwf.titleInfoPanel["txt_property" .. self.propertyNum].htmlText = StrConfig['title11'].. string.format(StrConfig['title50'],obj.def); self.propertyNum = self.propertyNum + 1 ;
	objSwf.titleInfoPanel["txt_property" .. self.propertyNum].htmlText = StrConfig['title12'].. string.format(StrConfig['title50'],obj.hit); self.propertyNum = self.propertyNum + 1 ;
	objSwf.titleInfoPanel["txt_property" .. self.propertyNum].htmlText = StrConfig['title13'].. string.format(StrConfig['title50'],obj.dodge); self.propertyNum = self.propertyNum + 1 ;
	objSwf.titleInfoPanel["txt_property" .. self.propertyNum].htmlText = StrConfig['title14'].. string.format(StrConfig['title50'],obj.cri); self.propertyNum = self.propertyNum + 1 ;
	objSwf.titleInfoPanel["txt_property" .. self.propertyNum].htmlText = StrConfig['title15'].. string.format(StrConfig['title50'],obj.hp); self.propertyNum = self.propertyNum + 1 ;
	objSwf.titleInfoPanel["txt_property" .. self.propertyNum].htmlText = StrConfig['title16'].. string.format(StrConfig['title50'],obj.defcri); self.propertyNum = self.propertyNum + 1 ;
	self.propertyNum = 1;
end

--改变称号时间剩余文本
function UITitle:OnChangeTitleTxt()
	local objSwf = UITitle:GetSWF("UITitle");
	if not objSwf then return; end
	local objTime = TitleModel:GetTitleTimeHandler(UITitle.indexId);
	
	
	if objTime == 0 then
		objSwf.titleInfoPanel.statusMess_txt.htmlText = "" ;
		if self.timeKey then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
	elseif objTime == -1 then
		objSwf.titleInfoPanel.statusMess_txt.htmlText = StrConfig['title202'] ;
		if self.timeKey then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
	else
		if self.timeKey then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		local func = function()
			local objTimes = TitleModel:GetTitleTimeHandler(UITitle.indexId);
			if objTimes == 0 or objTimes == -1 then 
				UITitle:OnChangeTitleTxt();
				return;
			end
			if objTimes.hour < 10 then objTimes.hour = '0' .. objTimes.hour; end
			if objTimes.min < 10 then objTimes.min = '0' .. objTimes.min; end
			if objTimes.sec < 10 then objTimes.sec = '0' .. objTimes.sec; end
			if objTimes.day > 0 then
				objSwf.titleInfoPanel.statusMess_txt.htmlText = string.format(StrConfig['title205'], objTimes.day,objTimes.hour,objTimes.min,objTimes.sec);
			else
				objSwf.titleInfoPanel.statusMess_txt.htmlText = StrConfig['title203'] .. string.format(StrConfig['title204'], objTimes.hour,objTimes.min,objTimes.sec);
			end
		end
		self.timeKey = TimerManager:RegisterTimer(func,1000);
		func();
	end;
end

--设置称号属性文本
function UITitle:InitTitleInfoTxt()
	local objSwf = self:GetSWF("UITitle");
	if not objSwf then return; end
	objSwf.title_txt.text = UIStrConfig['title024'];
end
------------------------------------人物----------------------------------------
function UITitle:DrawRole()
	local uiLoader = self.objSwf.roleLoader;
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local info = MainPlayerModel.sMeShowInfo;
	local vo = {};
	vo.prof = prof;
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.wuhunId = SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);	

	if not self.objUIDraw then
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
		self.objUIDraw = UIDraw:new("titlepanel", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	--播放特效
	local sex = MainPlayerModel.humanDetailInfo.eaSex;
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	if sex == PlayerConsts.Sex_woman then
		pfx.transform:setRotationX(UIDrawRoleCfg[prof].TeXiao);
	end
end



-----------------------------------------------------------------------------------
------------------------------        UI      -------------------------------------
-----------------------------------------------------------------------------------
--侦听人物称号信息来改变称号面板信息
function UITitle:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.TitleNumChange then
		--self:ShowTitleList(self.panelTOpneIndex);
		self:NewShowTitleHandler();
		self:OnChangeBtnTxtHandler(self.indexId);
	elseif name == NotifyConsts.TitleGetItem then 
		self:OnChangeBtnTxtHandler(self.indexId);
		self:OnChangeTitleTxt();
	end
	
end
function UITitle:ListNotificationInterests()
	return {
		NotifyConsts.TitleNumChange,NotifyConsts.TitleGetItem
	}
end