--[[
副本主面板
hoxudong
2016年6月1日15:49:15
]]

_G.UIDungeonMain = BaseUI:new("UIDungeonMain");
UIDungeonMain.tabButton = {};
UIDungeonMain.currSelect = nil;
UIDungeonMain.selectPage = 0;
UIDungeonMain.isOpen = false
UIDungeonMain.isOpenPataDungeon = false;   --通过世界聊天打开组队爬塔
UIDungeonMain.isOpenExpDungeon = false;    --通过世界聊天打开组队经验
UIDungeonMain.isOpenSingleDungeon = false; --通过任务栏打开单人爬塔副本

function UIDungeonMain:Create()
	self:AddSWF("dungeonMainPanel.swf",true,"center");
	
	self:AddChild(UIDungeon,FuncConsts.singleDungeon); 				--单人副本
	-- self:AddChild(UIWaterDungeon,FuncConsts.experDungeon); 		--经验副本
	self:AddChild(UITimerDungeon,FuncConsts.teamExper);				--组队经验  妖域幻境
	self:AddChild(UIQiZhanDungeon,FuncConsts.teamDungeon);			--组队副本  封妖试炼  组队爬塔
	self:AddChild(UIGodDynastyDungeon,FuncConsts.zhuxianDungeon);   --朱仙阵副本
	self:AddChild(UIMakinoBattleDungeon,FuncConsts.muyeDungeon);    --牧野之战副本
	-- self:AddChild(UIBabel,FuncConsts.singlePataDungeon);			--单人爬塔  通天之路
	
end

function UIDungeonMain:OnLoaded(objSwf)
	self:GetChild(FuncConsts.singleDungeon):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.experDungeon):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.teamExper):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.teamDungeon):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.zhuxianDungeon):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.muyeDungeon):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.singlePataDungeon):SetContainer(objSwf.childPanel);
	
	
	---设置分页按钮----
	self.tabButton[FuncConsts.singleDungeon]    = objSwf.btngerenfuben;
	-- self.tabButton[FuncConsts.experDungeon]     = objSwf.btnjingyanfuben;
	self.tabButton[FuncConsts.teamExper]        = objSwf.btnzuduijingyan;
	self.tabButton[FuncConsts.teamDungeon]      = objSwf.btnzuduifuben;
	self.tabButton[FuncConsts.zhuxianDungeon]   = objSwf.btnzhuxianzhenfuben;
	self.tabButton[FuncConsts.muyeDungeon]      = objSwf.btnmuyezhizhanfuben;
	-- self.tabButton[FuncConsts.singlePataDungeon] = objSwf.btndanrenpata;

	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	-- test code
	-- objSwf.btnTest.click = function () self:OnTestClick(); end
	for name,btn in pairs(self.tabButton) do
		btn.click = function() if name~=self.selectPage then self:OnTabButtonClick(name); end end
	end
end

-- function UIDungeonMain:OnTestClick( )
-- 	UIQuickBuyConfirm:Open(self,91)
-- end

function UIDungeonMain:HandleNotification(name,body)
	
end

function UIDungeonMain:ListNotificationInterests()
	
end



function UIDungeonMain:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:InitTileName();
	self:InitBtnPos()
	self:UnRegisterTime();
	self:InitDungeonRedPoint();
	self:RegisterTime();
	self:InitPageState();
	-- 查看args中第一位的参数有没有，如果有的话，说明是要直接跳转到某一个tab
	if #self.args > 0 then
		local args1 = tonumber(self.args[1]);
		if self.tabButton[args1] then
			self:OnTabButtonClick(args1);
			return;
		end
	end
	if UIDungeonMain.isOpen then
		self:OnTabButtonClick(FuncConsts.experDungeon);
		return;
	end

	-- if UIDungeonMain.isOpenPataDungeon then
	-- 	self:OnTabButtonClick(FuncConsts.teamDungeon);
	-- 	return;
	-- end
	
	if UIDungeonMain.isOpenExpDungeon then
		self:OnTabButtonClick(FuncConsts.teamExper);
		return;
	end
	local funcOpen,Openlv = DungeonUtils:CheckDungeonOpenFunc(13)
	if funcOpen then
		self:OnTabButtonClick(FuncConsts.singleDungeon);
	end
end

function UIDungeonMain:InitTileName( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btngerenfuben.titleName.htmlText       = DungeonUtils:GetTitleName(FuncConsts.singleDungeon)
	-- objSwf.btnjingyanfuben.titleName.htmlText  = DungeonUtils:GetTitleName(FuncConsts.experDungeon)
	objSwf.btnzuduijingyan.titleName.htmlText     = DungeonUtils:GetTitleName(FuncConsts.TimeDugeon )
	objSwf.btnzhuxianzhenfuben.titleName.htmlText = DungeonUtils:GetTitleName(FuncConsts.zhuxianDungeon)
	objSwf.btnzuduifuben.titleName.htmlText       = DungeonUtils:GetTitleName(FuncConsts.teamDungeon )
	objSwf.btnmuyezhizhanfuben.titleName.htmlText = DungeonUtils:GetTitleName(FuncConsts.muyeDungeon )
end

function UIDungeonMain:InitBtnPos( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btngerenfuben._x          = self:GetBtnPos(FuncConsts.singleDungeon)
	-- objSwf.btnjingyanfuben._x     = self:GetBtnPos(FuncConsts.experDungeon)
	-- objSwf.btnjingyanfubenAdd._x  = self:GetBtnPos(FuncConsts.experDungeon)
	objSwf.btnzuduijingyan._x        = self:GetBtnPos(FuncConsts.TimeDugeon)
	objSwf.btnzuduijingyanAdd._x     = self:GetBtnPos(FuncConsts.TimeDugeon)
	objSwf.btnzhuxianzhenfuben._x    = self:GetBtnPos(FuncConsts.zhuxianDungeon)
	objSwf.btnzhuxianzhenAdd._x      = self:GetBtnPos(FuncConsts.zhuxianDungeon)
	objSwf.btnzuduifuben._x          = self:GetBtnPos(FuncConsts.teamDungeon)
	objSwf.btnzuduifubenAdd._x       = self:GetBtnPos(FuncConsts.teamDungeon)
	objSwf.btnmuyezhizhanfuben._x    = self:GetBtnPos(FuncConsts.muyeDungeon)
	objSwf.btnmuyezhizhanfubenAdd._x = self:GetBtnPos(FuncConsts.muyeDungeon)
end

function UIDungeonMain:GetBtnPos(id)
	local btnData = DungeonUtils:GetBtnData(self.tabButton,71,68,108,1)
	if not btnData then return 0 end
	local btnPosX,btnPosY= 0,0
	for i,v in ipairs(btnData) do
		if v.id == id then
			btnPosX = v.x
		end
	end
	return btnPosX
end

-- 更改页签状态
function UIDungeonMain:InitPageState( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 经验副本等级控制
	--[[
	local funcOpen,Openlv = DungeonUtils:CheckDungeonOpenFunc(39)
	if funcOpen then
		objSwf.btnjingyanfuben.disabled = false
		objSwf.btnjingyanfubenAdd._visible = false
	else
		objSwf.btnjingyanfuben.disabled = true
		objSwf.btnjingyanfubenAdd.rollOver = function() TipsManager:ShowBtnTips(string.format('<font color="#ff0000">%s级开启</font>',Openlv)) end
		objSwf.btnjingyanfubenAdd.rollOut = function() TipsManager:Hide() end
	end
	--]]
	-- 灵光魔冢等级控制
	local funcOpen,Openlv = DungeonUtils:CheckDungeonOpenFunc(20)
	if funcOpen then
		objSwf.btnzuduijingyan.disabled = false
		objSwf.btnzuduijingyanAdd._visible = false
	else
		objSwf.btnzuduijingyan.disabled = true
		objSwf.btnzuduijingyanAdd.rollOver = function() TipsManager:ShowBtnTips(string.format('<font color="#ff0000">%s级开启</font>',Openlv)) end
		objSwf.btnzuduijingyanAdd.rollOut = function() TipsManager:Hide() end
	end
	-- 单人爬塔等级控制
	--[[
	local cfg = t_funcOpen[19];   
	local openLevel = cfg.open_level
	if curRoleLvl >= openLevel then
		objSwf.btndanrenpata.disabled = false
		objSwf.btndanrenpataAdd._visible = false
	else
		objSwf.btndanrenpata.disabled = true
		objSwf.btndanrenpataAdd.rollOver = function() TipsManager:ShowBtnTips(cfg.open_level .. "级开启") end
		objSwf.btndanrenpataAdd.rollOut = function() TipsManager:Hide() end
	end
	--]]
	-- 朱仙阵副本开启等级限制
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
end

function UIDungeonMain:GetSigleDungeonOpenLevel(  )
	local cfg = t_funcOpen[13]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	return curRoleLvl >= openLevel
end

function UIDungeonMain:GetWaterDungeonOpenLevel(  )
	local cfg = t_funcOpen[39]
	if not cfg then return false,0; end
	local openLevel = cfg.open_level
	if not openLevel then return false,0; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	return curRoleLvl >= openLevel
end

function UIDungeonMain:GetSiglePataDungeonOpenLevel(  )
	local cfg = t_funcOpen[19]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	if not openLevel then return false; end
	return curRoleLvl >= openLevel
end

function UIDungeonMain:GetTeamExperOpenLevel(  )
	local cfg = t_funcOpen[20]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	return curRoleLvl >= openLevel
end

function UIDungeonMain:GetTeamDungeonOpenLevel(  )
	local cfg = t_funcOpen[74]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	return curRoleLvl >= openLevel
end

-- 诛仙阵开启条件
function UIDungeonMain:GetGodDinastyDungeonOpenLevel(  )
	local cfg = t_funcOpen[121]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	return curRoleLvl >= openLevel
end

--副本红点提示
--adder:houxudong
--date:2016/8/27 21:33:25
UIDungeonMain.timerKey = nil;

function UIDungeonMain:InitDungeonRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--单人副本 
	local canEnter1,signelDungeonEnterNum = DungeonUtils:CheckSingeDungen()
	if self:GetSigleDungeonOpenLevel() then
		if canEnter1 then
			PublicUtil:SetRedPoint(objSwf.btngerenfuben, RedPointConst.showNum, signelDungeonEnterNum , true)
		else
			PublicUtil:SetRedPoint(objSwf.btngerenfuben, RedPointConst.showNum, 0)
		end
	end
	--经验副本 
	--[[
	local canEnter2,waterDungeonEnterNum = DungeonUtils:CheckWaterDungenNew()
	if self:GetWaterDungeonOpenLevel() then
		if canEnter2 then
			PublicUtil:SetRedPoint(objSwf.btnjingyanfuben, RedPointConst.showNum, waterDungeonEnterNum, true)
		else
			PublicUtil:SetRedPoint(objSwf.btnjingyanfuben, RedPointConst.showNum, 0)
		end
	end
	--]]
	--单人爬塔 
	--[[
	local canEnter,siglePataDungeonEnterNum = DungeonUtils:CheckPataDungen()
	if self:GetSiglePataDungeonOpenLevel() then
		if canEnter then
			PublicUtil:SetRedPoint(objSwf.btndanrenpata, RedPointConst.showNum, siglePataDungeonEnterNum, true)
		else
			PublicUtil:SetRedPoint(objSwf.btndanrenpata, RedPointConst.showNum, 0)
		end
	end
	--]]
	--组队经验
	local canEnter3,teamExperDungeonEnterNum = DungeonUtils:CheckTimeDungen()
	if self:GetTeamExperOpenLevel() then
		if canEnter3 then
			PublicUtil:SetRedPoint(objSwf.btnzuduijingyan, RedPointConst.showNum, teamExperDungeonEnterNum, true)
		else
			PublicUtil:SetRedPoint(objSwf.btnzuduijingyan, RedPointConst.showNum, 0)
		end
	end
	--组队副本 
	local canEnter4,teamDungeonEnterNum = DungeonUtils:CheckQizhanDungen()
	if self:GetTeamDungeonOpenLevel() then
		if canEnter4 then
			PublicUtil:SetRedPoint(objSwf.btnzuduifuben, RedPointConst.showNum, teamDungeonEnterNum, true)
		else
			PublicUtil:SetRedPoint(objSwf.btnzuduifuben, RedPointConst.showNum, 0)
		end
	end
	--诛仙阵副本 
	local canEnter5,godDynastyDungeonEnterNum = DungeonUtils:CheckGodDynastyDungen()
	local godDynastyIsOpen,_ = DungeonUtils:CheckDungeonOpenFunc(121)
	if godDynastyIsOpen then
		if canEnter5 then
			PublicUtil:SetRedPoint(objSwf.btnzhuxianzhenfuben, RedPointConst.showNum, godDynastyDungeonEnterNum, true)
		else
			PublicUtil:SetRedPoint(objSwf.btnzhuxianzhenfuben, RedPointConst.showNum, 0)
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
end

function UIDungeonMain:RegisterTime()
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitDungeonRedPoint();
	end,1000,0); 
end

function UIDungeonMain:UnRegisterTime()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end

function UIDungeonMain:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	if UIDungeonRewardPreView:IsShow() then
		UIDungeonRewardPreView:Hide()
	end
end

function UIDungeonMain:OnTabButtonClick(name)
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

function UIDungeonMain:OnBtnCloseClick()
	UIDungeonMain.isOpen = false
	self.isOpenPataDungeon = false
	self.isOpenExpDungeon = false
	self:Hide();
	if UIDungeonRewardPreView:IsShow() then
		UIDungeonRewardPreView:Hide()
	end
end

function UIDungeonMain:WithRes()
	return {"dungeonPanel.swf"};
end

function UIDungeonMain:IsTween()
	return true;
end

function UIDungeonMain:GetPanelType()
	return 1;
end

function UIDungeonMain:IsShowSound()
	return true;
end

-- 取bg得宽和高
function UIDungeonMain:GetWidth()
	return 1146;
end

function UIDungeonMain:GetHeight()
	return 681.35;
end

function UIDungeonMain:ListNotificationInterests()
	return {NotifyConsts.PlayerAttrChange};
end

function UIDungeonMain:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel then
			self:InitPageState()
		end
	end
end



