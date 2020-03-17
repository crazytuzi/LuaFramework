--[[
主界面功能界面
lizhuangzhuang
2014年11月4日11:19:56
]]

_G.UIMainFunc = BaseUI:new("UIMainFunc");

--位置参数 
--rowHeight:行高,
--rowDir:行方向,1向下,-1向上
--columnDir:列方向,1向右,-1向左
--hSpace:水平方向间距,1向右,-1向左
UIMainFunc.posMap = {
	[1] = {rowHeight = 60,rowDir = -1,columnDir = -1,hSpace = 5,
	rowsXOffset = { 0, 0, 0 }}, --每行的X偏移量
	[2] = { rowHeight = 50, rowDir = -1, columnDir = -1, hSpace = 3 },
	[3] = { rowHeight = 60, rowDir = 1, columnDir = -1, hSpace = 7 },
	[4] = { rowHeight = 55, rowDir = 1, columnDir = -1, hSpace = 10 },
};

--特殊按钮的偏移
UIMainFunc.OffsetMap = {
	[102] = { x = 0, y = -10 }
}
--显示的功能列表，按位置分类
UIMainFunc.funcMap = {};
--是否显示世界BOSS
UIMainFunc.isBtnCollect = false;
UIMainFunc.isbattleground = false;
UIMainFunc.TransfoBuffcost = nil
function UIMainFunc:Create()
	self:AddSWF("mainFunc.swf", true, "bottom");
end

function UIMainFunc:OnLoaded(objSwf)
	self.posMap[1].panel = objSwf.bottom;
	self.posMap[2].panel = objSwf.center;
	self.posMap[3].panel = objSwf.top;
	self.posMap[4].panel = objSwf.otherbutton;
	objSwf.btnHideTop.click = function() self:OnBtnHideTop(); end
	objSwf.btnHideBottom.click = function() self:OnBtnHideBottom(); end
	objSwf.BtnCollect.visible = false;
	objSwf.btnbattleground.visible = false;

	objSwf.BtnCollect.click = function() self:OnBtnCollectClick(); end
	objSwf.btnbattleground.click = function() self:OnBtnbattlegroundClick(); end	
end

function UIMainFunc:NeverDeleteWhenHide()
	return true;
end

function UIMainFunc:OnResize(wWidth, wHeight)
	self:SetUIPos();
end

function UIMainFunc:HideTop()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.top._visible = false;

	objSwf.top.hitTestDisable = true;
	objSwf.BtnCollect.visible = false;
	objSwf.btnbattleground.visible = false;
	objSwf.btnHideTop._visible = false;
	objSwf.btnHideTop.hitTestDisable = true;
end

function UIMainFunc:UnHideTop()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnHideTop._visible = true;
	objSwf.btnHideTop.hitTestDisable = false;
	objSwf.top._visible = not objSwf.btnHideTop.selected;
	objSwf.top.hitTestDisable = not objSwf.top._visible;
	if self.isBtnCollect then
		objSwf.BtnCollect.visible = objSwf.top._visible;
	end
	if self.isbattleground then
		objSwf.btnbattleground.visible = objSwf.top._visible;
	end
end

function UIMainFunc:CloseTop()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnHideTop.selected = true;
	self:OnBtnHideTop();
	AchievementBtnView:ChangeHideType()
end

function UIMainFunc:UnCloseTop()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnHideTop.selected = false;
	self:OnBtnHideTop();
	AchievementBtnView:ChangeShowType();
end

function UIMainFunc:OnBtnHideTop()

	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.top._visible = not objSwf.btnHideTop.selected;
	objSwf.top.hitTestDisable = not objSwf.top._visible;
	if self.isBtnCollect then
		objSwf.BtnCollect.visible = objSwf.top._visible;
	end
	if self.isbattleground then
		objSwf.btnbattleground.visible = objSwf.top._visible;
	end

	FuncManager:OnAllFuncContraction(); --所有功能按钮执行收缩方法
	if objSwf.top._visible then
		UIMainYunYingFunc:UnCloseTop();
		--DominateRouteFuncTip:Open()
	else
		UIMainYunYingFunc:CloseTop();
		RemindFuncTipsView:CloseAll();
		--DominateRouteFuncTip:Hide();
	end
end
function UIMainFunc:OnBtnHideBottom()

	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bottom._visible = not objSwf.btnHideBottom.selected;
	objSwf.otherbutton._visible = not objSwf.btnHideBottom.selected;
	objSwf.bottom.hitTestDisable = not objSwf.bottom._visible;
	objSwf.otherbutton.hitTestDisable = not objSwf.otherbutton._visible;
end

function UIMainFunc:DoShow()
end

function UIMainFunc:OnGetTopIsShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local isShow = objSwf.top._visible;
	return isShow;
end

function UIMainFunc:SetUIPos()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local wWidth, wHeight = UIManager:GetWinSize();
    
   if FuncManager:GetFuncIsOpen(FuncConsts.NewTianshen) then 
	  objSwf.bottom._x = wWidth -107;
   else
      objSwf.bottom._x = wWidth -30;
   end
	objSwf.bottom._y = wHeight + 8;
	objSwf.otherbutton._x=wWidth-28;
	objSwf.otherbutton._y=wHeight-115;


	objSwf.center._x = wWidth/2 +393;
	objSwf.center._y = wHeight - 94;
	objSwf.top._x = wWidth - 210;
	objSwf.top._y = 30;
	if self.isBtnCollect then
		objSwf.BtnCollect._x = wWidth -272;
		objSwf.BtnCollect._y = 30;
		objSwf.top._x = wWidth - 280;
	end
	if self.isbattleground then
		objSwf.btnbattleground._x = wWidth - 528
		objSwf.btnbattleground._y = 30;
		objSwf.top._x = wWidth - 500;
	end
	objSwf.btnHideTop._x = wWidth - 165;
	objSwf.btnHideTop._y = 22;
	objSwf.btnHideBottom._x = wWidth - 35;
	objSwf.btnHideBottom._y = wHeight - 35;
end

UIMainFunc.lastPlayerLv = 1;
function UIMainFunc:OnShow()
	local info = MainPlayerModel.humanDetailInfo;
	local playerLv = info.eaLevel;
	self.lastPlayerLv = playerLv;
	self:ShowOtherBtn(playerLv);
	self:SetUIPos();
	self:ShowFuncBtn();
	 --self:HideTop();
	if CPlayerMap:GetCurMapID() == MapConsts.FirstMap then
		self:HideTop();
		UIMainYunYingFunc:Hide();
	end
end

function UIMainFunc:ShowFuncBtn()

	self:ShowFuncBtnLv()
	self:ShowFuncBtnDay()
	for funcId, func in pairs(FuncManager.funcs) do
		if func:GetState() == FuncConsts.State_Open  or func:GetState()==FuncConsts.State_ReadyOpen or func:GetDayState() == FuncConsts.State_OpenPrompt then
			self:AddFuncButton(funcId, false);
		end
	end
end
--按等级开启的功能图标
function UIMainFunc:ShowFuncBtnLv()
	local playerLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	for funcId, func in pairs(FuncManager.funcs) do
		if func:GetOpenType() == 1 and func:GetIsClickOpen() == 1  then
			local click_lv = func:GetCfg().click_lv;
			local open_prama = func:GetCfg().open_prama;
			if playerLvl> click_lv-1 and playerLvl<open_prama then
				self:AddFuncButton(funcId, false);
				func:SetDayState(FuncConsts.State_OpenPrompt);
			end
		end
	end
end
--按天开启的功能图标
function UIMainFunc:ShowFuncBtnDay()
	for funcId, func in pairs(FuncManager.funcs) do
		if func:GetDayState() == FuncConsts.State_OpenPrompt then
			self:AddFuncButton(funcId, false);
		end
	end
end
function UIMainFunc:AddFuncButton(funcId, withTween)
	local func = FuncManager:GetFunc(funcId);
	if not func then return; end
    if not func:IsShow() then return; end
	--子功能不显示按钮
	if func:GetCfg().parentId > 0 then 
		return;
	end
	-- if func:GetState() == FuncConsts.State_UnOpen then
	-- 	return;
	-- end

	if func:GetPos() == 0 then return; end

	local objSwf = self:GetSWF();
	if not objSwf then return; end
	local posMap = self.funcMap[func:GetPos()];
	if not posMap then
		posMap = {};
		self.funcMap[func:GetPos()] = posMap;
	end
	local rowMap = posMap[func:GetLine()];
	if not rowMap then
		rowMap = {};
		posMap[func:GetLine()] = rowMap;
	end
	for i, vo in ipairs(rowMap) do
		if vo.id == funcId then
			Debug("Error:已存在功能按钮.funcId:" .. funcId);
			return;
		end
	end
	local posCfg = self.posMap[func:GetPos()];
	local panel = posCfg.panel;
	if not panel then return; end
	--创建新按钮

	local depth = panel:getNextHighestDepth();
	local button = panel:attachMovie(func:GetLibUrl(), "func" .. func:GetId(), depth);
	if not button then return; end

	--数据插入
	local insertIndex = self:GetNewFuncBtnIndex(funcId);
	local vo = {};
	vo.id = funcId;
	vo.button = button;
	func:SetButton(button);
	table.insert(rowMap, insertIndex, vo);
	--显示插入
	local pos = self:GetNewFuncBtnPos(funcId, insertIndex);

	button._x = pos.x;
	button._y = pos.y;

	local moveX = 0;
	if self.posMap[func:GetPos()].columnDir > 0 then
		moveX = button.width + posCfg.hSpace
	else
		moveX = -1 * (button.width + posCfg.hSpace);
	end
	for i = insertIndex + 1, #rowMap do

		local moveButton = rowMap[i].button;
		if not moveButton.data then
			moveButton.data = moveButton._x;
		end
		moveButton.data = moveButton.data + moveX;
		if withTween then
			Tween:To(moveButton, 0.5, { _x = moveButton.data }, {
				onComplete = function()
					moveButton._x = moveButton.data;
				end
			});
		else
			moveButton._x = moveButton.data;
		end
	end
	self:SetUIPos();
end

--获取新添加按钮的索引
function UIMainFunc:GetNewFuncBtnIndex(funcId)
	local func = FuncManager:GetFunc(funcId);
	if not func then return 1; end
	local posMap = self.funcMap[func:GetPos()];
	if not posMap then return 1; end
	local rowMap = posMap[func:GetLine()];
	if not rowMap then return 1; end
	if #rowMap == 0 then return 1; end
	--判断是不是在开头
	local firstVOFunc = FuncManager:GetFunc(rowMap[1].id);
	if func:GetIndex() < firstVOFunc:GetIndex() then
		return 1;
	end
	--在后面找位置
	for i, vo in ipairs(rowMap) do
		local voFunc = FuncManager:GetFunc(vo.id);
		if func:GetIndex() >= voFunc:GetIndex() then
			if i < #rowMap then
				local nextFunc = FuncManager:GetFunc(rowMap[i + 1].id);
				if nextFunc and func:GetIndex() < nextFunc:GetIndex() then
					return i + 1;
				end
			else
				return i + 1;
			end
		end
	end
	return #rowMap + 1;
end
--获取新添加按钮的位置
function UIMainFunc:GetNewFuncBtnPos(funcId, index, isFly)
	local pos = { x = 0, y = 0 };
	if not index then index = self:GetNewFuncBtnIndex(funcId); end
	local func = FuncManager:GetFunc(funcId);
	if not func then return pos; end
	--计算y
	local posCfg = self.posMap[func:GetPos()];
	if not posCfg then return pos; end
	if posCfg.rowDir < 0 then
		pos.y = -func:GetLine() * posCfg.rowHeight;
	else
		pos.y = (func:GetLine() - 1) * posCfg.rowHeight;
	end
	--计算x
	local posMap = self.funcMap[func:GetPos()];
	if not posMap then
		posMap = {};
		self.funcMap[func:GetPos()] = posMap;
	end
	local rowMap = posMap[func:GetLine()];
	if not rowMap then
		rowMap = {};
		posMap[func:GetLine()] = rowMap;
	end
	local width = 0;
	for i, vo in ipairs(rowMap) do
		if i >= index then break; end
		width = width + vo.button.width + posCfg.hSpace;
	end
	if posCfg.columnDir < 0 then
		if func.button then
			pos.x = -width - func.button.width;
		else
			pos.x = -width - 50;
		end
	else
		pos.x = width;
	end
	--是否每行有偏移量
	if posCfg.rowsXOffset and posCfg.rowsXOffset[func:GetLine()] then
		pos.x = pos.x + posCfg.rowsXOffset[func:GetLine()];
	end
	--是否按钮有特殊的偏移量
	if UIMainFunc.OffsetMap[funcId] then
		pos.x = pos.x + UIMainFunc.OffsetMap[funcId].x;
		pos.y = pos.y + UIMainFunc.OffsetMap[funcId].y;
	end
	if isFly then
		local panel = self.posMap[func:GetPos()].panel;
		if panel then
			pos = UIManager:PosLtoG(panel, pos.x, pos.y);
		end
	end
	return pos;
end



--changer：houxudong date:2016/8/3 15:35:25
function UIMainFunc:ShowOtherBtn(playerLv)

	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not playerLv then
		return;
	end
	--神装收集
    self.isBtnCollect=SmithingController:IsOpen()
    if self.isBtnCollect then
		objSwf.BtnCollect.visible = objSwf.top._visible;
	else
		objSwf.BtnCollect.visible = false;
	end
    
	local InterSerSceneOpenLevel = t_funcOpen[FuncConsts.KuaFuPVP].open_level; --跨服战场开启等级
	local openkuafulevel = t_consts[308].val1;
	self.isbattleground = InterSerSceneController:IsExist()
	local isopenkuafu = InterSerSceneController:IsOpen()
	--boss
	-- --跨服
	if self.isbattleground then
		objSwf.btnbattleground.visible = objSwf.top._visible;
		if not isopenkuafu then
			local InterSerSceneSchedule = math.floor((toint(playerLv - openkuafulevel) / (InterSerSceneOpenLevel - openkuafulevel)) * 100)
			objSwf.btnbattleground.bar:gotoAndStop(InterSerSceneSchedule);
			objSwf.btnbattleground.effect._visible = false;
			objSwf.btnbattleground.disabled = true;
			objSwf.btnbattleground.bar._visible = true;
			objSwf.btnbattleground.levelopentxt.htmlText = string.format(StrConfig["mainmenutopbutton02"], InterSerSceneOpenLevel);
		else
			objSwf.btnbattleground.effect._visible = true;
			objSwf.btnbattleground.disabled = false;
			objSwf.btnbattleground.bar._visible = false;
			objSwf.btnbattleground.levelopentxt.htmlText = ' ';
		end
	end
	self:SetUIPos();
	self.lastPlayerLv = playerLv;
end

--监听消息列表
function UIMainFunc:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange, NotifyConsts.QuestFinish,
	}
end

--处理消息
function UIMainFunc:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:ShowOtherBtn(body.val);
			self:ShowFuncBtnLv()
			self:ShowFuncBtnDay()
		elseif name == NotifyConsts.QuestFinish then
		end
	end
end
function UIMainFunc:OnBtnCollectClick()
	if UISmithingCollect:IsShow() then
		UISmithingCollect:Hide();
	else
		UISmithingCollect:Show();
	end

end
function UIMainFunc:OnBtnbattlegroundClick()
	if MainInterServiceUI:IsShow() then
		MainInterServiceUI:Hide();
	else
		MainInterServiceUI:Show();
	end
end

function UIMainFunc:GetransforPosG()
	local objSwf = self.objSwf
	if not objSwf then return end
	local posXL = objSwf.btnHideBottom._x+10
	local posYL = objSwf.btnHideBottom._y+10
	return UIManager:PosLtoG(objSwf,posXL,posYL)
end
function UIMainFunc:GetBtnCollect()
	return self.objSwf.BtnCollect;
end

function UIMainFunc:GetTopVisible()
	if not self.objSwf then return; end
	if not self.objSwf.top then
		return;
	end
	return self.objSwf.top._visible;
end

