--[[

]]
_G.classlist['UIBabelMainView'] = 'UIBabelMainView'

_G.UIBabelMainView = BaseUI:new("UIBabelMainView");

UIBabelMainView.tabButton = {};
UIBabelMainView.currSelect = nil;
UIBabelMainView.selectPage = 0;

UIBabelMainView.objName = 'UIBabelMainView'

function UIBabelMainView:Create()
	self:AddSWF("babelMainPanel.swf",true,"center");
	self:AddChild(UIBabel,FuncConsts.Babel);            --单人爬塔
	-- 2016年11月24日 02:03:10
	-- self:AddChild(UIGodDynastyDungeon,FuncConsts.zhuxianDungeon);    --朱仙阵
	-- self:AddChild(UIQiZhanDungeon,FuncConsts.teamDungeon);			--组队副本  封妖试炼  组队爬塔
	-- self:AddChild(UIMakinoBattleDungeon,FuncConsts.muyeDungeon);     --牧野之战副本
end

function UIBabelMainView:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	self:GetChild(FuncConsts.Babel):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.zhuxianDungeon):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.teamDungeon):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.muyeDungeon):SetContainer(objSwf.childPanel);
	---设置分页按钮----
	self.tabButton[FuncConsts.Babel]            = objSwf.btnSinglePata;
	-- self.tabButton[FuncConsts.zhuxianDungeon]   = objSwf.btnzhuxianzhenfuben;
	-- self.tabButton[FuncConsts.teamDungeon]      = objSwf.btnzuduifuben;
	-- self.tabButton[FuncConsts.muyeDungeon]      = objSwf.btnmuyezhizhanfuben;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() if name~=self.selectPage then self:OnTabButtonClick(name); end end
	end
end

function UIBabelMainView:InitBtnPos( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnSinglePata._x          = self:GetBtnPos(FuncConsts.Babel)
	-- objSwf.btnzhuxianzhenfuben._x    = self:GetBtnPos(FuncConsts.zhuxianDungeon)
	-- objSwf.btnzhuxianzhenAdd._x      = self:GetBtnPos(FuncConsts.zhuxianDungeon)
	-- objSwf.btnzuduifuben._x          = self:GetBtnPos(FuncConsts.teamDungeon)
	-- objSwf.btnzuduifubenAdd._x       = self:GetBtnPos(FuncConsts.teamDungeon)
	-- objSwf.btnmuyezhizhanfuben._x    = self:GetBtnPos(FuncConsts.muyeDungeon)
	-- objSwf.btnmuyezhizhanfubenAdd._x = self:GetBtnPos(FuncConsts.muyeDungeon)
end

function UIBabelMainView:GetBtnPos(id)
	local btnData = DungeonUtils:GetBtnData(self.tabButton,70,71,108,1)
	if not btnData then return 0 end
	local btnPosX,btnPosY= 0,0
	for i,v in ipairs(btnData) do
		if v.id == id then
			btnPosX = v.x
		end
	end
	return btnPosX
end

--技能红点提示
UIBabelMainView.skillTimerKey = nil;
function UIBabelMainView:RegisterTimes(  )
	self.skillTimerKey = TimerManager:RegisterTimer(function()
		self:InitSkillRedPoint()
	end,1000,0); 
end

UIBabelMainView.skillLoader = nil;
function UIBabelMainView:InitSkillRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--单人爬塔
	local canEnter1,num1 = DungeonUtils:CheckPataDungen( )
	if canEnter1 then
		PublicUtil:SetRedPoint(objSwf.btnSinglePata,RedPointConst.showNum,num1,true)
	else
		PublicUtil:SetRedPoint(objSwf.btnSinglePata, RedPointConst.showNum, 0)
	end
	--[[
	--朱仙阵
	local canEnter2,num2 = DungeonUtils:CheckGodDynastyDungen( )
	if canEnter2 then
		PublicUtil:SetRedPoint(objSwf.btnzhuxianzhenfuben,RedPointConst.showNum,num2,true)
	else
		PublicUtil:SetRedPoint(objSwf.btnzhuxianzhenfuben,RedPointConst.showNum,0)
	end
	--组队副本 
	local canEnter4,teamDungeonEnterNum = DungeonUtils:CheckQizhanDungen()
	local qizhanIsOpen,_ = DungeonUtils:CheckDungeonOpenFunc(74)
	if qizhanIsOpen then
		if canEnter4 then
			PublicUtil:SetRedPoint(objSwf.btnzuduifuben, RedPointConst.showNum, teamDungeonEnterNum, true)
		else
			PublicUtil:SetRedPoint(objSwf.btnzuduifuben, RedPointConst.showNum, 0)
		end
	end
	--牧野之战副本 
	local canEnter6,makionBattleDungeonEnterNum = DungeonUtils:CheckMakinoBattleDungen()
	local makionBattleIsOpen,_ = DungeonUtils:CheckDungeonOpenFunc(123)
	if makionBattleIsOpen then
		if canEnter6 then
			PublicUtil:SetRedPoint(objSwf.btnmuyezhizhanfuben, RedPointConst.showNum, makionBattleDungeonEnterNum, true)
		else
			PublicUtil:SetRedPoint(objSwf.btnmuyezhizhanfuben, RedPointConst.showNum, 0)
		end
	end
	--]]

end

function UIBabelMainView:OnHide()
	if self.skillTimerKey then
		TimerManager:UnRegisterTimer(self.skillTimerKey);
		self.skillTimerKey = nil;
	end
end

function UIBabelMainView:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return; end
	self:InitSkillRedPoint()
	self:RegisterTimes()
	self:InitPageBtn()
	self:InitTileName()
	self:InitBtnPos()
	if #self.args > 0 then
		local args1 = tonumber(self.args[1]);
		if self.tabButton[args1] then
			self:OnTabButtonClick(args1);
			return;
		end
	end
	self:OnTabButtonClick(FuncConsts.Babel);
end

function UIBabelMainView:InitTileName( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnSinglePata.titleName.htmlText       = DungeonUtils:GetTitleName(FuncConsts.Babel)
	-- objSwf.btnzhuxianzhenfuben.titleName.htmlText = DungeonUtils:GetTitleName(FuncConsts.zhuxianDungeon)
	-- objSwf.btnzuduifuben.titleName.htmlText       = DungeonUtils:GetTitleName(FuncConsts.teamDungeon )
	-- objSwf.btnmuyezhizhanfuben.titleName.htmlText = DungeonUtils:GetTitleName(FuncConsts.muyeDungeon )
end

function UIBabelMainView:InitPageBtn( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--[[
	--朱仙阵副本开启等级限制
	local funcOpen,Openlv = DungeonUtils:CheckDungeonOpenFunc(121)
	if funcOpen then
		objSwf.btnzhuxianzhenfuben.disabled  = false
		objSwf.btnzhuxianzhenAdd._visible    = false
		objSwf.btnzhuxianzhenAdd.disabled    = true
	else
		objSwf.btnzhuxianzhenfuben.disabled  = true
		objSwf.btnzhuxianzhenAdd._visible    = true
		objSwf.btnzhuxianzhenAdd.disabled    = false
		objSwf.btnzhuxianzhenAdd.rollOver     = function() TipsManager:ShowBtnTips(string.format('<font color="#ff0000">%s级开启</font>',Openlv)) end
		objSwf.btnzhuxianzhenAdd.rollOut      = function() TipsManager:Hide() end
	end
	-- 封妖试炼等级开启限制
	local funcOpen,Openlv = DungeonUtils:CheckDungeonOpenFunc(74)
	if funcOpen then
		objSwf.btnzuduifuben.disabled = false
		objSwf.btnzuduifubenAdd._visible = false
	else
		objSwf.btnzuduifuben.disabled = true
		objSwf.btnzuduifubenAdd.rollOver = function() TipsManager:ShowBtnTips(string.format('<font color="#ff0000">%s级开启</font>',Openlv)) end
		objSwf.btnzuduifubenAdd.rollOut = function() TipsManager:Hide() end
	end
	--牧野之战副本开启等级限制
	local funcOpen,Openlv = DungeonUtils:CheckDungeonOpenFunc(123)  
	if funcOpen then
		objSwf.btnmuyezhizhanfuben.disabled       = false
		objSwf.btnmuyezhizhanfubenAdd._visible    = false
		objSwf.btnmuyezhizhanfubenAdd.disabled    = true
	else
		objSwf.btnmuyezhizhanfuben.disabled       = true
		objSwf.btnmuyezhizhanfubenAdd._visible    = true
		objSwf.btnmuyezhizhanfubenAdd.disabled    = false
		objSwf.btnmuyezhizhanfubenAdd.rollOver    = function() TipsManager:ShowBtnTips(string.format('<font color="#ff0000">%s级开启</font>',Openlv)) end
		objSwf.btnmuyezhizhanfubenAdd.rollOut     = function() TipsManager:Hide() end
	end
	--]]
end
function UIBabelMainView:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	
	self.tabButton[name].selected = true;
	self:ShowChild(name);
	self.selectPage = name;
end


function UIBabelMainView:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		self:InitPageBtn()
	end
end

function UIBabelMainView:ListNotificationInterests()

	return {NotifyConsts.PlayerAttrChange};
end

function UIBabelMainView:IsTween()
	return true;
end

function UIBabelMainView:GetPanelType()
	return 1;
end

function UIBabelMainView:WithRes()
	return {"babelPanel.swf"};
end

function UIBabelMainView:IsShowSound()
	return true;
end

function UIBabelMainView:GetWidth()
	return 1146
end;
function UIBabelMainView:GetHeight()
	return 687
end;

function UIBabelMainView:OnBtnCloseClick()
	self:Hide();
end

