--[[
UI基类
取消一个UI可以加载多个swf的方式
lizhuangzhuang
2014年11月5日16:02:07
]]

_G.BaseUI ={};

--创建新的flash，并且加载
function BaseUI:new(szName)
	local obj = {};
	obj.szName = szName; 
	for i,v in pairs(BaseUI) do
		if type(v) == "function" then
			obj[i] = v;
		end;
	end; 
	obj.swfCfg = nil;
	obj.isLoading = false;--是否正在加载
	obj.isLoaded = false;--是否已加载
	obj.bShowState = false;--UI是否已显示
	obj.isFullShow = false;--是否完全打开
	obj.isFullHide = true;--是否完全关闭
	obj.bOpen = false;--是否打开了UI
	obj.objSwf = nil;--显示对象
	obj.tweenStartPos = nil;--缓动开始位置
	obj.posGroup = {};--面板关联的位置组
	obj.hideWhenLoading = false;--加载时被隐藏
	obj.args = nil;--传入的变参
	--
	obj.parent = nil;
	obj.childlist = {}; -- 子UI
	--
	
	obj.isTween = false;
	obj.isAbsSize = false;
	
	UIManager:AddUI(obj);
	return obj;
end

function BaseUI:Create()
	return true;
end

function BaseUI:Update(dwInterval)
	return true;
end

function BaseUI:Destroy()
	
end 

function BaseUI:OnResize(dwWidth,dwHeight)
end 

function BaseUI:OnLoaded(objSwf)
end

--面板显示
function BaseUI:OnShow()
end

--缓动前
function BaseUI:BeforeTween()
end

--面板完全显示,缓动结束
function BaseUI:OnFullShow()
end

--面板关闭前调用,返回flase可以阻止关闭
function BaseUI:OnBeforeHide()
	return true;
end

function BaseUI:OnHide()
end

function BaseUI:OnTop()
end

--是否使用缓动打开,关闭
function BaseUI:IsTween()
	return self.isTween;
end

--是否显示加载过程
function BaseUI:IsShowLoading()
	if self:GetPanelType() == 1 then
		return true;
	else
		return false;
	end
end

--面板加载的附带资源
function BaseUI:WithRes()
end

--面板类型
function BaseUI:GetPanelType()
	return 0;
end

--是否触发ESC
function BaseUI:ESCHide()
	if self:GetPanelType() == 1 then
		return true;
	end
	return false;
end

--按ESC时的行为
function BaseUI:OnESC()
	self:Hide();
end

--是否播放开启音效
function BaseUI:IsShowSound()
	return false;
end

--从来不被回收
function BaseUI:NeverDeleteWhenHide()
	return false;
end

--关闭时卸载UI
function BaseUI:DeleteWhenHide()
	if self:NeverDeleteWhenHide() then
		return false;
	end
	return false;
end

--删除时回调
function BaseUI:OnDelete()
end

function BaseUI:GetWidth()
	if not self.isLoaded then return 0; end
	if not self.swfCfg then return 0; end
	if not self.swfCfg.objSwf then return 0; end
	local mc = self.swfCfg.objSwf.content;
	return toint(mc._width/mc._xscale*100,-1);
end

function BaseUI:GetHeight()
	if not self.isLoaded then return 0; end
	if not self.swfCfg then return 0; end
	if not self.swfCfg.objSwf then return 0; end
	local mc = self.swfCfg.objSwf.content;
	return toint(mc._height/mc._yscale*100,-1);
end

function BaseUI:GetPos()
	if not self.isLoaded then return 0,0; end
	if not self.swfCfg then return 0,0; end
	if not self.swfCfg.objSwf then return 0,0; end
	return toint(self.swfCfg.objSwf.content._x,-1), toint(self.swfCfg.objSwf.content._y,-1);
end

--消息处理
function BaseUI:RegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then
		self.notifierCallBack = function(name,body)
			self:HandleNotification(name, body);
		end
	end
	for i,name in pairs(setNotificatioin) do
		Notifier:registerNotification(name, self.notifierCallBack)
	end
end

--取消消息注册
function BaseUI:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--子类处理消息
function BaseUI:HandleNotification(name, body)
end
--子类返回需要监听的消息
function BaseUI:ListNotificationInterests()
	return nil;
end

--container,swf要加载进的容器
--传字符串时会加载到主舞台layer上，top最上层layer,center中间层layer,bottom底层layer
function BaseUI:AddSWF(szUrl,bCanTop,container)
	local loadInContainer = nil;
	if container and type(container)=='string' then
		loadInContainer = UIManager:GetLayer(container);
	else
		loadInContainer = container;
	end
	if self.swfCfg then
		print("Error:BaseUI.禁止添加多个swf.");
		return;
	end
	self.swfCfg = 
	{
		objSwf 		= nil;  --对应的uiswf
		szUrl   	= szUrl;
		bCanTop 	= bCanTop;
		container  	= loadInContainer;
	};
end

--设置swf要加载进的容器
function BaseUI:SetContainer(container)
	if not container then return; end
	if not self.swfCfg then return; end
	self.swfCfg.container = container;
end

--添加子UI
--childName, 子面板名,默认使用子面板的GetName()方法获取名字
function BaseUI:AddChild(childUI, childName)
	if not childName then
		childName = childUI:getName();
	end
	self.childlist[childName] = childUI;
	childUI.parent = self;
end

--移除子UI
function BaseUI:RemoveChild(childName)
	local child = self.childlist[childName];
	if child then
		child.parent = nil;
		self.childlist[childName] = nil;
	end
end

--显示子面板
--unshowOther是否关闭其他子面板,nil默认为true
function BaseUI:ShowChild(childName, unshowOther,...)
	local child = self.childlist[childName];
	if not child then return; end
	child:Show(...);
	if unshowOther == nil then
		unshowOther = true;
	end
	if unshowOther then
		for name,child in pairs(self.childlist) do
			if name ~= childName then
				child:Hide();
			end
		end
	end
end

--获取子面板
function BaseUI:GetChild(childName)
	return self.childlist[childName];
end

--删除Swf
function BaseUI:DeleteSWF()
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	if not self:CanDeleteSWF() then return; end
	for name,child in pairs(self.childlist) do
		child:DeleteSWF();
		child.swfCfg.container = nil;
	end
	print('UI GC:',self.szName);
	self.swfCfg.objSwf:unload();
	self.swfCfg.objSwf.source = nil;
	self.swfCfg.objSwf:removeMovieClip();
	self.swfCfg.objSwf = nil;
	self.objSwf = nil;
	self.isLoaded = false;
	self.isLoading = false;
	self:OnDelete();
	return true;
end

--是否可以被回收
--如果子面板正在加载,不可以被回收
function BaseUI:CanDeleteSWF()
	if self.isLoading then return false; end
	for name,child in pairs(self.childlist) do
		if not child:CanDeleteSWF() then
			return false;
		end
	end
	return true;
end

--返回对应swf的content
function BaseUI:GetSWF()
	if not self.isLoaded then
		return nil;
	end
	if not self.swfCfg then
		return nil;
	end
	if not self.swfCfg.objSwf then
		return nil;
	end
	return self.swfCfg.objSwf.content;
end

function BaseUI:GetName()
	return self.szName;
end

function BaseUI:DoResize(nWidth,nHeight)
	if self.bShowState then
		self:AutoSetPos();
		self:OnResize(nWidth,nHeight);
	end
end

--打开UI
function BaseUI:Show(...)
	self.args = {...};
	self.isFullHide = false;
	self.hideWhenLoading = false;
	UIManager:OnUIShow(self.szName);
	if self.isLoaded then
		self:showSwf();
	else
		if self.isLoading then 
			if self:IsShowLoading() then
				UILoadingPanel:Open(self.szName);
			end
			return; 
		end
		self:loadSwf();
	end
end

function BaseUI:loadSwf()
	
	if not UIManager:CanLoadSWF(self) then
		return;
	end

	if self.isLoaded then return; end
	if self.isLoading then return; end
	self.isLoading = true;
	
	local onFinish = function ()
		if self:IsShowLoading() then
			UILoadingPanel:Close(self.szName);
		end
		local objSwf = UIManager.stage:createLoader(self.swfCfg.container._target, self.szName);--子swf中的到底要不要有UILoader,很蛋疼的问题，待查
		if not objSwf then return; end
		self.swfCfg.objSwf = objSwf;
		objSwf.source = self.swfCfg.szUrl;
		objSwf.popTop = self.swfCfg.bCanTop;
		objSwf.visible = false;
		objSwf.loaded = function()
			self.objSwf = objSwf.content;
			self.isLoading = false;
			self.isLoaded = true;
			self:OnLoaded(objSwf.content);
			self:showSwf();
		end
	end;
	local onProgress = function(p)
		if self:IsShowLoading() then
			UILoadingPanel:SetPercent(self.szName,p);
		end
	end
	local list = {};
	table.push(list,ResUtil:GetUIUrl(self.swfCfg.szUrl));
	local withResList = self:WithRes();
	if withResList then
		for i,url in ipairs(withResList) do
			if url:tail(".swf") then
				table.push(list,ResUtil:GetUIUrl(url));
			else
				table.push(list,url);
			end
		end
	end
	if self:IsShowLoading() then
		UILoadingPanel:Open(self.szName);
	end

	UILoaderManager:LoadList(list,onFinish,onProgress);
end

function BaseUI:showSwf()
	if self.hideWhenLoading then return; end
	if self.bShowState then return; end
	self.bShowState = true;
	self:RegisterNotification();
	self:Top();
	UIMutexManager:Check(self.szName,self:GetPanelType());--隐藏互斥UI
	self.swfCfg.objSwf.visible = true;
	self:AutoSetPos();
	self:OnShow();
	if self:ESCHide() then
		UIManager:AddESCUI(self.szName);
	end
	if self:IsShowSound() then
		SoundManager:PlaySfx(2004);
	end
	if self:IsTween() then
		self:BeforeTween();
		self:DoTweenShow();
	else
		self:DoShow();
	end
	
	if _G.isDebug then
		print("ui opened <<<<<<<<<<--------->>>>>>>>>> " .. self.swfCfg.szUrl);
	end
end

--执行显示
function BaseUI:DoShow()
	--子UI显示时,判断父UI的状态
	if self.parent then
		if self.parent.isFullShow and not self.isFullShow then
			self.isFullShow = true;
			self:OnFullShow();
		end
	else
		self.isFullShow = true;
		self:OnFullShow();
	end
	self:GroupCheck();
	--遍历自己的子UI中,有在显示的
	for name,child in pairs(self.childlist) do
		if child.bShowState and not child.isFullShow then
			child.isFullShow = true;
			child:OnFullShow();
		end
	end
end

--执行打开缓动
function BaseUI:DoTweenShow()
	if not self.tweenStartPos then
		self.tweenStartPos = UIManager:GetMousePos();
	end
	local startX,startY = self.tweenStartPos.x,self.tweenStartPos.y;
	local endX,endY = self:GetCfgPos();
	--
	local mc = self.swfCfg.objSwf.content;
	mc._xscale = 0;
	mc._yscale = 0;
	mc._alpha = 50;
	mc._x = startX;
	mc._y = startY;			
	Tween:To(mc,0.5,{_alpha=100,_xscale=100,_yscale=100,_x=endX,_y=endY},
				{onComplete=function()
					self:DoShow();
				end},true);
end

--关闭UI
function BaseUI:Hide()
	if self.isLoading then
		self.hideWhenLoading = true;
	end
	if not self.bShowState then return; end
	if not self:OnBeforeHide() then return; end
	self.bShowState = false;
	self:UnRegisterNotification();
	if self:ESCHide() then
		UIManager:RemoveESCUI(self.szName);
	end
	if self:IsTween() then
		self:DoTweenHide();
	else
		self:DoHide();
	end
	self.args = nil;
end


--执行关闭
function BaseUI:DoHide()
	self.isFullShow = false;
	self:HideGroupCheck();
	self:hideSwf();
	self:OnHide();
	self.tweenStartPos = nil;
	for name,child in pairs(self.childlist) do
		child:Hide();
	end
	if self:DeleteWhenHide() then
		self:DeleteSWF();
	elseif self.parent==nil and not self:NeverDeleteWhenHide() then
		UIManager:OnUIHide(self.szName);
	end
	self.isFullHide = true;
end

--隐藏一个swf
function BaseUI:hideSwf()
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	self.swfCfg.objSwf.visible = false;
end

--执行缓动
function BaseUI:DoTweenHide()
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	local endX,endY;
	if self.tweenStartPos then
		endX = self.tweenStartPos.x;
		endY = self.tweenStartPos.y;
	else
		local winW,winH = UIManager:GetWinSize();
		endX = winW/2;
		endY = winH;
	end
	--
	local mc = self.swfCfg.objSwf.content;			
	Tween:To(mc,0.45,{_alpha=0,_width=20,_height=20,_x=endX,_y=endY},
				{onComplete=function()
					self:DoHide();
					mc._xscale = 100;
					mc._yscale = 100;
					mc._alpha = 100;
				end},true);
end

function BaseUI:IsShow()
	return self.bShowState;
end

function BaseUI:IsFullShow()
	return self.isFullShow;
end

function BaseUI:Top()
	if not self.swfCfg.bCanTop then return; end
	if not self.swfCfg.objSwf then return; end
	self.swfCfg.objSwf:hopTop();
end

--获取界面的配置坐标
function BaseUI:GetCfgPos()
	local winW,winH = UIManager:GetWinSize();
	if self.isAbsSize then
		winW,winH = UIManager:GetEWinSize();
	end
	local uiW,uiH = self:GetWidth(),self:GetHeight();
	local x,y = UIPosUtil:GetPos(self.szName, winW, winH, uiW, uiH);
	return x,y;
end

--自动更新界面位置
function BaseUI:AutoSetPos()
	if self.parent ~= nil then return; end
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	local objSwf = self.swfCfg.objSwf;
	local x,y = self:GetCfgPos();
	objSwf.content._x = toint(x or objSwf.content._x, -1); 
	objSwf.content._y = toint(y or objSwf.content._y, -1);
end

--设置界面位置
function BaseUI:SetPos(x,y)
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	local objSwf = self.swfCfg.objSwf;
	objSwf.content._x = x;
	objSwf.content._y = y;
end

--设置界面的高宽
function BaseUI:SetSize(nWidth,nHeight)
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	local objSwf = self.swfCfg;
	objSwf.content._width = nWidth;
	objSwf.content._height = nHeight;
end

--组检测
function BaseUI:GroupCheck()
	if #self.posGroup <= 0 then return; end
	for i,groupK in ipairs(self.posGroup) do
		local groupCfg = PanelPosGroup[groupK];
		local allShow = true;
		for j,uiName in ipairs(groupCfg.panels) do	
			if uiName ~= self.szName then
				local ui = UIManager:GetUI(uiName);
				if not (ui and ui:IsShow()) then
					allShow = false;
				end
			end
		end
		if allShow then
			local totalWidth = 0;
			for j,uiName in ipairs(groupCfg.panels) do
				local ui = UIManager:GetUI(uiName);
				totalWidth = totalWidth + ui:GetWidth() + groupCfg.gap;
			end
			local winW,winH = UIManager:GetWinSize();
			local uiW,uiH = totalWidth, self:GetHeight();
			local groupX, groupY = UIPosUtil:CalcPos(groupCfg, winW, winH, uiW, uiH);
			local startX = groupX or (_rd.w-totalWidth)/2;
			for j,uiName in ipairs(groupCfg.panels) do
				local ui = UIManager:GetUI(uiName);
				local x,y = ui:GetCfgPos();
				ui:GroupMoveTo(startX,y);
				startX = startX + ui:GetWidth() + groupCfg.gap;
			end
			break;
		end
	end
end

--关闭面板时的组检测
function BaseUI:HideGroupCheck()
	if #self.posGroup <= 0 then return; end
	local list = {};--要归位的UI
	for i,groupK in ipairs(self.posGroup) do
		local groupCfg = PanelPosGroup[groupK];
		for j,uiName in ipairs(groupCfg.panels) do	
			if uiName ~= self.szName then
				local ui = UIManager:GetUI(uiName);
				if ui and ui:IsShow() then
					local x,y = ui:GetCfgPos();
					ui:GroupMoveTo(x,y);
				end
			end
		end

	end
end

--组移动
function BaseUI:GroupMoveTo(x,y)
	local mc = self.swfCfg.objSwf.content;
	Tween:To(mc,0.3,{_x=x,_y=y,_xscale=100,_yscale=100,_alpha=100});
end

function BaseUI:GetShowingChild()
	for key,child in pairs(self.childlist) do
		if not child.isFullHide then
			return child;
		end
	end
end

function BaseUI:SetSelect(data)
end

-- 设置添加红点提醒
local num = 0;
function BaseUI:SetRedPoint(mc,value,source,showTypes)
	return nil;
end

-- 设置移除当前红点提醒
function BaseUI:RemoveRedPoint(loader)
	return nil;
end

-- 设置移除全部红点提醒
function BaseUI:RemoveAllRedPoint()
end

--检查是否可以打开 子类可以重写
function BaseUI:CheckOpen()
	return true;
end
