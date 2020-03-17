--[[
功能指引
lizhuangzhuang
2015年2月27日18:06:59
]]

_G.UIFuncGuide = BaseUI:new("UIFuncGuide");

--类型

UIFuncGuide.Type_QuestWaBao = 1;--挖宝任务
UIFuncGuide.Type_QuestQiYu = 2;--奇遇任务
UIFuncGuide.Type_QuestFengYao = 3;--悬赏任务
UIFuncGuide.Type_DailyQuest = 4;--日环任务
UIFuncGuide.Type_DailyQuestStar = 5;--日环任务
UIFuncGuide.Type_Quest = 6;--任务
UIFuncGuide.Type_NPC = 7;--NPC对话
UIFuncGuide.Type_FuncGuide = 8;--功能指引
UIFuncGuide.Type_EquipGuide = 9;--新手任务穿装备
UIFuncGuide.Type_QuestSuper = 10;--卓越任务

--方向
UIFuncGuide.Up = 1;
UIFuncGuide.Right = 2;
UIFuncGuide.Down = 3;
UIFuncGuide.Left = 4;

--显示类型
UIFuncGuide.ST_Public = 1;--使用UIFuncGuide里的指引
UIFuncGuide.ST_Private = 2;--执行单独的指引逻辑

UIFuncGuide.list = {};
UIFuncGuide.currVO = nil;

function UIFuncGuide:Create()
	self:AddSWF("funcGuide.swf",true,"float");
end

function UIFuncGuide:OnLoaded(objSwf)
	self.arrowW = objSwf.mcArrow._width;
	self.arrowH = objSwf.mcArrow._height;
	objSwf.mcArrow._visible = false;
	objSwf.mcArrow.hitTestDisable = true;
	objSwf.mcTxt._visible = false;
	objSwf.mcTxt.hitTestDisable = true;
	objSwf.mask.visible = false;
	objSwf.btnEffect._visible = false;
	objSwf.btnEffect.hitTestDisable = true;
end

function UIFuncGuide:OnResize(dwWidth,dwHeight)
	TimerManager:RegisterTimer(function()
		self:DoShowArrow();
	end,50,1);
end

--开启
--@param type 多人争夺控制权时,type值高的优先控制权
--@param showtype 显示类型,1只用全局的指引,2只用单独的指引.类型为2时,仅传showFunc,unshowFunc,updateFunc即可
--@param showFunc 显示指引时附带执行的方法
--@param unshowFunc 关闭指引时附带执行的方法
--@param updateFunc 显示指引时的更新函数
--@param getButton 按钮实例或者获取按钮的function;为function时获取不到按钮,就不显示
--@param pos 方位,上下左右
--@param offset 偏移量
--@param btnMask 是否使用遮罩
--@param text 要显示的文字
function UIFuncGuide:Open(vo)
	if self.currVO and self.currVO.type==vo.type then
		self:DoSetCurr(vo);
		return;
	end
	if self.currVO and vo.type > self.currVO.type then
		table.push(self.list,self.currVO);
		self:DoClearCurr();
		self:DoSetCurr(vo);
		return;
	end
	for i,listVO in ipairs(self.list) do
		if listVO.type == vo.type then
			listVO.getButton = vo.getButton;
			listVO.pos = vo.pos;
			listVO.offset = vo.offset;
			listVO.btnMask = vo.btnMask;
			listVO.showFunc = vo.showFunc;
			listVO.unshowFunc = vo.unshowFunc;
			listVO.updateFunc = vo.updateFunc;
			listVO.text = vo.text;
			return;
		end
	end
	--
	if self.currVO then
		vo.lastButtonX = 0;
		vo.lastButtonY = 0;
		table.push(self.list,vo);
	else
		self:DoSetCurr(vo);
	end
end

--关闭
function UIFuncGuide:Close(type)
	if not self.currVO then return; end
	if self.currVO.type == type then
		if self.currVO.unshowFunc then
			self.currVO.unshowFunc();
		end
		self.currVO.getButton = nil;
		if self.currVO.showtype == UIFuncGuide.ST_Public then
			if self.objSwf then
				self.objSwf.mcArrow._visible = false;
			end
			if self.objSwf then
				self.objSwf.mcTxt._visible = false;
			end
			if self.currVO.btnMask then
				self.objSwf.mask.visible = false;
				self.objSwf.btnEffect._visible = false;
			end
		end
		self.currVO = nil;
		self:ShowNext();
		return;
	end
	for i,vo in ipairs(self.list) do
		if vo.type == type then
			vo.getButton = nil;
			vo.showFunc = nil;
			vo.unshowFunc = nil;
			vo.updateFunc = nil;
			table.remove(self.list,i,1);
			return;
		end
	end
end

function UIFuncGuide:DoSetCurr(vo)
	local objSwf = self.objSwf;
	if self.currVO then
		print("Error:UIFuncGuide Do Set Curr");
	end
	vo.lastButtonX = 0;
	vo.lastButtonY = 0;
	self.currVO = vo;
	if self.currVO.showFunc then
		self.currVO.showFunc();
	end
	if self.currVO.showtype == UIFuncGuide.ST_Public then
		if not self.currVO.text or self.currVO.text=="" then return; end
		if not self.objSwf then return; end
		local mcTxt = self.objSwf.mcTxt;
		local textField = mcTxt.textField;
		textField._width = 300;
		textField.text = self.currVO.text;
		textField._width = textField.textWidth+5 > 300 and 300 or toint(textField.textWidth+5);
		textField._height = toint(textField.textHeight+5);
		textField._x = toint(-textField._width/2);
		local mcBg = mcTxt.mcBg;
		mcBg._width = toint(textField._width + 16);
		mcBg._x = toint(-mcBg._width/2);
		mcBg._height = toint(textField._height + 24);
		mcBg._y = toint(-mcBg._height/2);
		--
		textField._y = mcBg._y + 12;
	end
end

function UIFuncGuide:DoClearCurr()
	if not self.currVO then return; end
	if self.currVO.showtype == UIFuncGuide.ST_Public then
		if self.objSwf then
			self.objSwf.mcArrow._visible = false;
			self.objSwf.mcTxt._visible = false;
			self.objSwf.mask.visible = false;
		end
	end
	if self.currVO.unshowFunc then
		self.currVO.unshowFunc();
	end
	self.currVO = nil;
end

function UIFuncGuide:ShowNext()
	if #self.list == 0 then return; end
	local nextVO = nil;
	local index = 0;
	for i,vo in ipairs(self.list) do
		if not nextVO or vo.type>nextVO.type then
			nextVO = vo;
			index = i;
		end
	end
	table.remove(self.list,index,1);
	self:DoSetCurr(nextVO);
end

function UIFuncGuide:DoGetButton(getButton)
	if type(getButton) == "function" then
		return getButton();
	end
	return getButton;
end

function UIFuncGuide:Update()
	if not self.bShowState then return; end
	self:DoShowArrow();
end

local btnPos = {x=0,y=0};--按钮的全局坐标
UIFuncGuide.lastUpdateTime = 0;
function UIFuncGuide:DoShowArrow()
	local objSwf = self.objSwf;
	if not self.currVO then
		return;
	end
	--控制更新频率
	if GetCurTime() - self.lastUpdateTime < 200 then
		return;
	end
	self.lastUpdateTime = GetCurTime();
	-------------------走单独逻辑的处理-------------------------
	if self.currVO.showtype == UIFuncGuide.ST_Private then
		if self.currVO.updateFunc then
			self.currVO.updateFunc();
		end
		return;
	end
	-----------------------------------------------------------
	-------------------走通用逻辑的处理------------------------
	local button = self:DoGetButton(self.currVO.getButton);
	if not button then
		objSwf.mcArrow._visible = false;
		objSwf.mcTxt._visible = false;
		objSwf.mask.visible = false;
		return;
	end
	--
	local mcArrow = objSwf.mcArrow;
	local mcTxt = objSwf.mcTxt;
	mcArrow._visible = true;
	mcTxt._visible = true;
	--
	UIManager:PosLtoG(button,0,0,btnPos);
	local btnW = button.width or button._width;
	local btnH = button.height or button._height;
	if self.currVO.pos == 1 then
		mcArrow._rotation = 0;
		mcArrow._x = btnPos.x + btnW/2;
		mcArrow._y = btnPos.y - self.arrowH/2;
	elseif self.currVO.pos == 2 then
		mcArrow._rotation = 90;
		mcArrow._x = btnPos.x + btnW + self.arrowH/2;
		mcArrow._y = btnPos.y + btnH/2;
	elseif self.currVO.pos == 3 then
		mcArrow._rotation = 180;
		mcArrow._x = btnPos.x + btnW/2;
		mcArrow._y = btnPos.y + btnH + self.arrowH/2;
	elseif self.currVO.pos == 4 then
		mcArrow._rotation = -90;
		mcArrow._x = btnPos.x - self.arrowH/2;
		mcArrow._y = btnPos.y + btnH/2;
	end
	if self.currVO.offset then
		mcArrow._x = mcArrow._x + self.currVO.offset.x;
		mcArrow._y = mcArrow._y + self.currVO.offset.y;
	end
	mcArrow._x = toint(mcArrow._x);
	mcArrow._y = toint(mcArrow._y);
	if self.currVO.pos == 1 then
		mcTxt._x = mcArrow._x;
		mcTxt._y = mcArrow._y - self.arrowH/2 - (mcTxt.height or mcTxt._height)/2;
	elseif self.currVO.pos == 2 then
		mcTxt._x = mcArrow._x + self.arrowW/2 + (mcTxt.width or mcTxt._width)/2 - 20;
		mcTxt._y = mcArrow._y;
	elseif self.currVO.pos == 3 then
		mcTxt._x = mcArrow._x;
		mcTxt._y = mcArrow._y + self.arrowH/2 + (mcTxt.height or mcTxt._height)/2;
	elseif self.currVO.pos == 4 then
		mcTxt._x = mcArrow._x - self.arrowW/2 - (mcTxt.width or mcTxt._width)/2 + 20;
		mcTxt._y = mcArrow._y;
	end
	-------------------------
	if self.currVO.btnMask then
		objSwf.mask.visible = true;
		objSwf.btnEffect._visible = true;
		if self.currVO.lastButtonX~=btnPos.x or self.currVO.lastButtonY~=btnPos.x then
			self.currVO.lastButtonX = btnPos.x;
			self.currVO.lastButtonY = btnPos.y;
			local wWidth,wHeight = UIManager:GetWinSize();
			objSwf.mask:drawRect(btnPos.x-5,btnPos.y-5,btnW+10,btnH+10,wWidth,wHeight);
			objSwf.btnEffect._x = btnPos.x-10;
			objSwf.btnEffect._y = btnPos.y-10;
			objSwf.btnEffect._width = btnW + 20;
			objSwf.btnEffect._height = btnH + 20;
		end
	else
		objSwf.mask.visible = false;
		objSwf.btnEffect._visible = false;
	end
end