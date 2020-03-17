--[[
UIManager
lizhuangzhuang
2014年12月19日15:39:26
]]
_G.UIManager = {}

UIManager.stage = nil;
UIManager.layers = {};
UIManager.uiList = {};
UIManager.escList = {};
UIManager.mouseOn = false;--鼠标是否在UI上
UIManager.isHideUI = false;--UI是否被隐藏
UIManager.waitGCList = {};
UIManager.GCNUM = 0;
UIManager.MinWidth = 1280;--最小宽度
UIManager.MinHeight = 800;--最小高度
--------------------------------------------------------------
local function onGuiCallback(command,param,swf)
	print("UI Cmd:"..command..",param:"..param);
end
--------------------------------------------------------------
function UIManager:Create()
	self.nWinWidth,self.nWinHeight = _rd.w,_rd.h;
	self.eWinWidth,self.eWinHeight = _rd.w,_rd.h;
	self.stage = _SWFManager.new('Main.swf');
	self.stage._x = 1;
	self.stage._y = 1
	if not self.stage then
		Error("self.stage is null")
	end
	self.stage:onFSCommand(onGuiCallback);
	self.stage:onFocus(function(focus,swf) self:OnStageFocusChange(focus,swf); end);
	--监听舞台事件
	self.stage._root.stageClick = function(e) self:OnStageClick(e); end
	self.stage._root.stageMove = function(e) self:OnStageMove(e); end
	--在舞台上创建显示层级
	self:AddLayer("scene");--该层在跨服中也会保留
	self:AddLayer("storyBottom");--剧情--该层在跨服中也会保留
	self:AddLayer("bottom2");
	self:AddLayer("bottom1");
	self:AddLayer("interserver");--跨服层(需要在跨服中保留的UI放在该层)
	self:AddLayer("bottom");
	self:AddLayer("bottomFloat");--bottom层的浮动，有一些东西必须要在bottom层之上，center层之下的
	self:AddLayer("center");
	self:AddLayer("top");
	self:AddLayer("effect");
	self:AddLayer("story");--剧情
	self:AddLayer("highTop");--该层在跨服中也会保留
	self:AddLayer("float");
	self:AddLayer("popup");
	self:AddLayer("loading");
	--向swf注册字典表
	if self.stage.lang then
		for k,v in pairs(UIStrConfig) do
			self.stage.lang[k] = v;
		end
	end
	--初始化UI
	 for i,UI in pairs(self.uiList) do
		if UI.Create then
			UI:Create();
		end;
	end;
	UILoaderManager:Create();
	UIMutexManager:Create();
	--注册面板位置组
	for k,groupCfg in pairs(PanelPosGroup) do
		for j,uiName in ipairs(groupCfg.panels) do
			local ui = UIManager:GetUI(uiName);
			if ui then
				table.push(ui.posGroup,k);
			end
		end
	end
	CControlBase:RegControl( self, true );
	
	-- self:PrintUIHandler();
	
	return true;
end;

--添加Layer
function UIManager:AddLayer(layerName)
	if self.layers[layerName] then
		return;
	end
	local layer = self.stage:createLayer(layerName);
	layer._x,layer._y = toint(-(_rd.w/2),-1),toint(-(_rd.h/2),-1);
	self.layers[layerName] = layer;
end

--获取Layer
function UIManager:GetLayer(layerName)
	return self.layers[layerName];
end

--隐藏Layer
function UIManager:HideLayer(layerName)
	if self.layers[layerName] then
		self.layers[layerName]._visible = false;
		self.layers[layerName].hitTestDisable = true;
	end
end

--除某层之外的所有层隐藏
function UIManager:HideLayerBeyond(...)
	local unhideLayers = {...};
	for name,layer in pairs(self.layers) do
		local hasFind = false;
		for i,unhideLayername in pairs(unhideLayers) do
			if name == unhideLayername then
				hasFind = true;
				break;
			end
		end
		if not hasFind then
			self:HideLayer(name);
		end
	end
end

--恢复所有layer
--@param 缓动显示
function UIManager:RecoverAllLayer(isTween)
	for name,layer in pairs(self.layers) do
		if not layer._visible then
			if isTween and layer._alpha<100 then
				Tween:To(layer,0.5,{_alpha=100},{
					onComplete = function()
						layer._visible = true;
						layer.hitTestDisable = false;
					end
				});
			else
				layer._visible = true;
				layer.hitTestDisable = false;
			end
		end
	end
end

function UIManager:Update(dwInterval) 
	if _G.sceneTest then
		return;
	end
	for i,UI in pairs(self.uiList) do
		UI:Update(dwInterval);
	end;
	--
	UIDrawManager:Update(dwInterval);
	Tween:Update(dwInterval);
	return true
end

--打开UI时,从回收队列中移除
function UIManager:OnUIShow(uiName)
	for i,name in ipairs(self.waitGCList) do
		if name == uiName then
			table.remove(self.waitGCList,i);
			return;
		end
	end
end

--关闭UI时,将UI放入待回收队列
function UIManager:OnUIHide(uiName)
	table.push(self.waitGCList,uiName);
	for i=#self.waitGCList-UIManager.GCNUM,1,-1 do
		local name = self.waitGCList[i];
		if not name then break; end
		local ui = UIManager:GetUI(name);
		if not ui then break; end
		print("Do UI GC:",name);
		if ui:DeleteSWF() then
			table.remove(self.waitGCList,i);
		end
	end
end

--舞台点击处理
function UIManager:OnStageClick(e)
	Notifier:sendNotification(NotifyConsts.StageClick, {button=e.button,target=e.clickTarget});
end

--舞台鼠标移动
function UIManager:OnStageMove(e)
	Notifier:sendNotification(NotifyConsts.StageMove);
	self:SetMouseOn(true);
end

function UIManager:SetMouseOn(on)
	if self.mouseOn ~= on then
		self.mouseOn = on;
		if self.mouseOn then
			GameController:SceneFocusOut();
		else
			TipsManager:Hide();
		end
	end
end

--舞台焦点变化
function UIManager:OnStageFocusChange(focus,swf)
	if focus then
		_sys.enableIME = true
	else
		_sys.enableIME = false
	end
	if not focus then
		Notifier:sendNotification(NotifyConsts.StageFocusOut);
	end
end

function UIManager:Destroy()
	for i,UI in pairs(self.uiList) do
		UI:Destroy();
	end;
end;

function UIManager:AddUI(objUI)
	self.uiList[objUI:GetName()] = objUI;
end;

function UIManager:GetUI(szName)
	return self.uiList[szName];
end;

function UIManager:OnWinResize(dwWidth,dwHeight)
	if dwWidth==0 and dwHeight==0 then return end;
	
	self.nWinWidth,self.nWinHeight = dwWidth,dwHeight;
	self.eWinWidth,self.eWinHeight = dwWidth,dwHeight;
	local x,y = toint(-(_rd.w/2),-1),toint(-(_rd.h/2),-1);
	for k,layer in pairs(self.layers) do
		if k ~= 'popup' then
			--UI最小自适应
			if dwWidth < UIManager.MinWidth then
				layer._xscale = toint(dwWidth/UIManager.MinWidth*100);
			else
				layer._xscale = 100;
			end
			if dwHeight < UIManager.MinHeight then
				layer._yscale = toint(dwHeight/UIManager.MinHeight*100);
			else
				layer._yscale = 100;
			end
		end
		layer._x,layer._y = x,y;
	end
	self.nWinWidth = self.nWinWidth<UIManager.MinWidth and UIManager.MinWidth or self.nWinWidth;
	self.nWinHeight = self.nWinHeight<UIManager.MinHeight and UIManager.MinHeight or self.nWinHeight;
	for i,UI in pairs(self.uiList) do
		UI:DoResize(self.nWinWidth,self.nWinHeight);
	end; 
end;

function UIManager:GetWinSize()
	return self.nWinWidth,self.nWinHeight;
end;

function UIManager:GetEWinSize()
	return self.eWinWidth,self.eWinHeight;
end;

--需要回复
function UIManager:HideAll(bIsNeedRecover)
	self.stage.show = false;
	self.isHideUI = true;
end;

--回复所有UI
function UIManager:RecoverAll()
	self.stage.show = true;
	self.isHideUI = false;
end;

function UIManager:Switch()
    if self.isHideUI then
        self:RecoverAll()
    else
        self:HideAll()
    end
end

--ESC处理
function UIManager:OnKeyDown(dwKeyCode)
	if not FuncOpenController.keyEnable then return; end
	if dwKeyCode == _System.KeyESC then
		if #self.escList > 0 then
			local uiName = self.escList[#self.escList];
			local ui = UIManager:GetUI(uiName);
			ui:OnESC();
		end
	end
end

function UIManager:AddESCUI(uiName)
	for i,name in ipairs(self.escList) do
		if name == uiName then
			return;
		end
	end
	table.push(self.escList,uiName);
end

function UIManager:RemoveESCUI(uiName)
	for i,name in ipairs(self.escList) do
		if name == uiName then
			table.remove(self.escList,i);
			return;
		end
	end
end

--获得鼠标位置
function UIManager:GetMousePos()
	return _sys:getRelativeMouse();
end

--将mc的本地坐标转换为全局坐标
function UIManager:PosLtoG(mc,posx,posy,inPoint)
	if not mc then return {x=0,y=0}; end;
	posx = posx or 0;
	posy = posy or 0;
	local point = self.stage:LtoG(mc._target,posx,posy);
	local pos = inPoint and inPoint or {};
	pos.x = point.x;
	pos.y = point.y;
	-- print("大小*************************",pos.x,pos.y)
	--相对引擎做偏移
	local winW,winH = self:GetWinSize();
	--------------屏幕自适应做的处理----------------
	pos.y = toint(pos.y*winH/_rd.h);
	pos.x = toint(pos.x*winW/_rd.w);
	------------------------------------------------
	pos.x = winW*0.5 + pos.x;
	pos.x = toint(pos.x, -1);
	pos.y = winH*0.5 + pos.y;
	pos.y = toint(pos.y, -1);
	return pos;
end

--将全局坐标转换成mc的本地坐标
function UIManager:PosGtoL(mc,stageX,stageY,inPoint)
	if not mc then return {x=0,y=0}; end
	stageX = stageX or 0;
	stageY = stageY or 0;
	--相对引擎的偏移
	local winW,winH = self:GetWinSize();
	stageX = stageX - winW*0.5;
	stageY = stageY - winH*0.5;
	-------------屏幕自适应做的处理----------------
	stageX = toint(stageX*_rd.w/winW);
	stageY = toint(stageY*_rd.h/winH);
	-----------------------------------------------
	local point = self.stage:GtoL(mc._target,stageX,stageY);
	local pos = inPoint and inPoint or {};
	pos.x = point.x;
	pos.y = point.y;
	return pos;
end

--获得一个Mc的舞台坐标
function UIManager:GetMcPos(objMc)
	if not objMc then return {x=0,y=0} end;
	local point = self:PosLtoG(objMc,0,0);
	local pos = {x=point.x,y=point.y};
	return pos;
end

--打印现在正在显示的UI
function UIManager:DumpNowUI()
	print("======================内存中的UI======================");
	 for i,ui in pairs(self.uiList) do
		if ui.isLoaded then
			print(ui.szName);
		end
	end
end

--删除所有UI
function UIManager:DeleteAllUI()
	TimerManager:RegisterTimer(function()
		print("=====================删除所有UI===================");
		for i,ui in pairs(self.uiList) do
			if ui.isLoaded then
				if ui:IsShow() then
					ui:Hide();
				end
				ui:DeleteSWF();
			end
		end
	end,1000,1);
end

function UIManager:DeleteUI(name,showing)
	showing = showing or false;
	local list = {};
	for i,ui in pairs(self.uiList) do
		if ui.isLoaded then
			local has = showing == ui:IsShow();
			if has then
				if ui:GetName() == name then
					ui.isTween = false;
					ui:Hide();
					ui:DeleteSWF();
					break;
				end
				
				ui.isTween = false;
				ui:Hide();
				ui:DeleteSWF();
			end
		end
	end
end

UIManager.noLoadSWFs = nil;
UIManager.loadSWFFilters = {
	UILogin = 'loginPanel.swf',
	UICreateRole = 'createRolePanelOld.swf',
	UILoginWait = 'loginWaitPanelOld.swf',
	-- UIChat = 'chat.swf',
	-- UILog = 'logPanel.swf',
	-- UIShampublicity = 'ShampublicityV.swf',
	-- UILoadingScene = 'loadingScene.swf',
	-- UIFangChenMiView = 'fangchenmiPanel.swf',
	-- UISkillNameEffect = 'skillNameEffect.swf',
	-- UIFuncGuide = 'funcGuide.swf',
	-- UIMainYunYingFunc = 'mainYunyingFunc.swf',
	-- UIMainAttr = 'mainPageAttr.swf',
	-- UIFloat = 'float.swf',
	-- UIRemind = 'remindPanel.swf',
	-- UIFloatBottom = 'floatbottom.swf',
	-- UIMainTeammate = 'mainPageTeammate.swf',
	-- UIMainSkill = 'mainPageSkill.swf',
	-- UIMainMap = 'mapSmallPanel.swf',
	-- UIMainHead = 'mainPageHead.swf',
	-- UILingliEffect = 'lingliEffectPanel.swf',
	-- UIGoal = 'GoalPanel.swf',
	-- UIMainQuest = 'mainPageTask.swf',
	-- UIMainLvQuestTitle = 'mainPageTask.swf',
	-- UIMainFunc = 'mainFunc.swf',
	-- UIMainQuestTrunk = 'mainPageTaskTrunk.swf',
	-- UIMainLvQuest = 'mainPageTaskLv.swf',
	-- UIAutoRunIndicator = 'autoRunIndicator.swf',
	-- UINpcQuestPanel = 'npcQuestPanel.swf',
	-- UIMainFightFly = 'mainPageFightFly.swf',
	-- UIMainEquipNewTips = 'equipNewTips.swf',
	-- UIMainQuestAll = 'mainPageTaskAll.swf',
	-- UIAutoBattleIndicator = 'autoBattleIndicator.swf',
	-- UIBeatenAnimation = 'beatenAnimation.swf',
	-- UIMultiCutEffect = 'miltiCutEffect.swf',
	-- UIMainColletProgress = 'mainCollectProgress.swf',
	-- UIStoryDialog = 'storyDialogPanel.swf',
	-- UIFly = 'fly.swf',
	-- UITipsTool = 'tipsTool.swf',
	-- UITipsBtn = 'tipsBtn.swf',
	-- UILoadingPanel = 'loadingPanel.swf',
	-- UIRole = 'roleMainPanelV.swf',
	-- UIRoleBasic = 'roleBasicPanelV.swf',
	-- UIBag = 'bagPanel.swf',
	-- UISkill = 'skillMainPanel.swf',
	-- UISkillBasic = 'skillBasicPanel.swf',
	-- UIRegisterAward = 'registerAwardMainPanel.swf',
	-- UISignPanel = 'registerSignPanel.swf',
	-- UILevelAwardOpen = 'levelRewardOpenPanel.swf',
	-- UIItemGuideUse = 'itemGuideUse.swf',
	-- UIWuhunDungeonExit = 'wuhunDungeonExit.swf',
	-- UISafe = 'safePanel.swf',
	-- UISkillNewTips = 'skillNewTips.swf',
	-- UIActivityNotice = 'activityNotice.swf',
	-- UIActivity = 'activityPanel.swf',
	-- UIWorldBossRight = 'zhanchangRightPanel.swf',
	-- UIMascotComeRight = 'mascotComeRight.swf',
	-- UIWeekSign = 'weekSignTabPanel.swf',
	-- UIActivityNoticeTips = 'activityNoticeTips.swf',
	-- UIRegisterTimePanel = 'registerTime.swf',
	-- UIBagOpenGift = 'bagOpenGiftView.swf',
	-- UIItemGuide = 'itemGuide.swf',
	-- UISmithing = 'smithingMainPanel.swf',
	-- UISmithingStar = 'smithingStarPanelV.swf',
	-- UILianQiMainPanelView = 'LianQiMainPanel.swf',
	-- UIWarPrintBag = 'spiritWarPrintBag.swf',
	-- UIWarPrintEquip = 'SpiritWarPrint.swf',
	-- UIConsigmentMain = 'consignmentMainPanel.swf',
	-- UIConsignmentBuy = 'consignmentBuyPanel.swf',
	-- UIMount = 'mountMainPanel.swf',
	-- UIMountBasic = 'mountBasicPanel.swf',
	-- UIXingtu = 'xingtu.swf',
	-- UIFumo = 'fuMoPanel.swf',
	-- UIFabao = 'fabaoMainPanel.swf',
	-- UIFabaoInfo = 'fabaoInfoPanel.swf',
	-- UIQuestTips = 'taskTips.swf',
	-- UIGoalTips = 'GoalPanelTips.swf',
	-- UIWingOpen = 'wingOpen.swf',
	-- UIShoppingMall = 'shoppingMallView.swf',
	-- UIShoppingMallTehui = 'shoppingMallTehui.swf',
	-- UIFriendRecommend = 'friendRecommend.swf',
	-- UIBigMap = 'bigMapMainPanel.swf',
	-- UIBigMapCurr = 'bigMapCurr.swf',
	-- UIDungeonMain = 'dungeonMainPanel.swf',
	-- UIDungeon = 'dungeonPanel.swf',
	-- UIDungeonStory = 'dungeonStoryPanel.swf',
	-- UIConfirm = 'confirmPanel.swf',
	-- UIBeicangjieRight = 'beicangjieRightPanel.swf',
}
function UIManager:CanLoadSWF(ui,filters)
	-- if not ui then
		-- return;
	-- end
	
	-- if not self.noLoadSWFs then
		-- self.noLoadSWFs = {};
		-- if not filters then
			-- filters = self.loadSWFFilters;
		-- end
		-- for name,data in pairs(self.uiList) do
			-- if not filters[name] then
				-- self.noLoadSWFs[name] = data;
			-- end
		-- end
		-- filters = nil;
	-- end
	
	-- if filters then
		-- for name,data in pairs(self.uiList) do
			-- if not filters[name] then
				-- self.noLoadSWFs[name] = data;
			-- end
		-- end		
	-- end
	
	-- return self.noLoadSWFs[ui:GetName()] == nil;
	
	return true;
end

function UIManager:PrintUIHandler()
	TimerManager:UnRegisterTimer(UIManager.FileTimer);
	UIManager.FileTimer = TimerManager:RegisterTimer(function()
		TimerManager:UnRegisterTimer(UIManager.FileTimer);
		local file = _File:new();
		file:create('UIFilter.lua');
		file:write("UIManager.loadSWFFilters = { \n");
		local swfs = {};
		for name,ui in pairs(self.uiList) do
			if ui.swfCfg then
				file:write("  " .. name..' = ' .."'"..ui.swfCfg.szUrl.."'"..',\n');
			else
				swfs[ui:GetName()] = ui;
			end
		end
		file:write("}");
		file:close();
		
		local file = _File:new();
		file:create('invalidUI.lua');
		file:write("UIInvalid.content = { \n");
		for name,ui in pairs(swfs) do
			file:write("  " .. name..' = ' .."'invalid!!!'"..',\n');
		end
		file:write("}");
		file:close();
		
		print('======================打印完成=====================================');
	end,5000);
end
