--[[
当前选中目标-父类
haohu
2014年9月15日18:25:36
]]

_G.UITarget = setmetatable( {}, {__index = BaseUI} ); --BaseUI:new("UITarget");

function UITarget:new(szName)
	local ui = BaseUI:new(szName);
	for i,v in pairs(self) do
		if type(v) == "function" then
			ui[i] = v;
		end
	end
	return ui;
end

function UITarget:Create()
	local swf = self:GetSwfName();
	self:AddSWF( swf, true, "interserver" );
end

function UITarget:GetSwfName()
	-- override
end

function UITarget:OnLoaded(objSwf)
	self:Init( objSwf );
	self:HandleNormalEvents( objSwf );
	self:HandleEvents( objSwf );
end

function UITarget:Init( objSwf )
	objSwf.txtName.autoSize = "left";

end

function UITarget:HandleNormalEvents( objSwf )
	objSwf.headLoader.loaded = function(e) self:OnHeadLoaded(e) end
	local hpbar = objSwf.hpbar;
	hpbar.rollOver = function() self:OnHpRollOver() end;
	hpbar.rollOut = function() self:OnHpRollOut() end;
	local buffList = objSwf.buffList;
	buffList.itemRollOver = function(e) self:OnBuffRollOver(e) end;
	buffList.itemRollOut  = function()  self:OnBuffRollOut() end;
	-- local btnLock = objSwf.btnLockTarget
	-- btnLock.click = function() self:OnBtnLockClick() end
	-- btnLock.rollOver = function() self:OnBtnLockRollOver() end
	-- btnLock.rollOut = function() self:OnBtnLockRollOut() end
end

function UITarget:HandleEvents( objSwf )
	-- override
end

function UITarget:OnShow()
	self:UpdateTarget();
	self:CheckInterServer();
end

function UITarget:OnHeadLoaded(e)
	-- override
end

function UITarget:OnChildUpdate()
	-- override
end

--鼠标移动到血条上
function UITarget:OnHpRollOver()
	local hp = TargetModel:GetHp();
	local maxHp = TargetModel:GetMaxHp();
	if hp and maxHp then
		local hpTxt = toint( hp, -1 );
		local maxHpTxt = toint( maxHp, 1 );
		local tipTxt = string.format(StrConfig["hpbar1"], hpTxt, maxHpTxt );
		TipsManager:ShowBtnTips( tipTxt );
	end
end

--鼠标移出血条
function UITarget:OnHpRollOut()
	TipsManager:Hide();
end

function UITarget:OnBuffRollOver(e)
	local buffVO = BuffTargetModel:GetBuff(e.item.id);
	if not buffVO then return; end
	TipsManager:ShowTips( TipsConsts.Type_Buff, buffVO, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UITarget:OnBuffRollOut()
	TipsManager:Hide();
end

-- function UITarget:OnBtnLockClick()
-- 	TargetController:ToggleLock()
-- end

-- function UITarget:OnBtnLockRollOver()
-- 	local lockState = TargetModel:GetLockState()
-- 	local tips = lockState and StrConfig['tips1201'] or StrConfig['tips1202']
-- 	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
-- end

-- function UITarget:OnBtnLockRollOut()
-- 	TipsManager:Hide()
-- end

--显示
function UITarget:ShowTarget()
	if not self:IsShow() then
		self:Show();
	else
		self:UpdateTarget();
	end
end

--隐藏
function UITarget:HideTarget()
	self:Hide();
end

--更新
function UITarget:UpdateTarget()
    self:UpdateIcon();
    self:UpdateName();
    self:UpdateLvl();
    self:UpdateHpBar(self.objSwf);
    self:UpdateHp();
    self:UpdateBuffList();
    self:UpdateLockState()
    self:OnChildUpdate();
end

function UITarget:UpdateIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local iconURL = self:GetIconUrl();
	if iconURL and objSwf.headLoader.source ~= iconURL then
		objSwf.headLoader.source = iconURL; --头像
	end
end

function UITarget:UpdateName()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.txtName.text = self:GetName();
end

function UITarget:UpdateLvl()
    local objSwf = self.objSwf;
    if not objSwf then return end;
    objSwf.lvlLoader.num = self:GetLevel();
end

function UITarget:UpdateHpBar(objSwf)
	self.objSwf.hpbar.siHp1.surfacePolicy = "always";
	self.objSwf.hpbar.siHp1.tweenDuration = 0.5;
	self.objSwf.hpbar.siHp1:setProgress(TargetModel:GetHp(), TargetModel:GetMaxHp());
end

function UITarget:UpdateHp()
    local objSwf = self.objSwf
    if not objSwf then return end
	self.objSwf.hpbar.siHp1:tweenProgress(TargetModel:GetHp(), TargetModel:GetMaxHp(), 0);
end

function UITarget:GetIconUrl()
    -- override
end

function UITarget:GetName()
	-- override
end

function UITarget:GetLevel()
	-- override
end

------------------------------跨服时的处理-------------------------
function UITarget:CheckInterServer()
	-- override
end

--更新buff列表
function UITarget:UpdateBuffList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local buffTileList = objSwf.buffList;

	buffTileList.dataProvider:cleanUp();
	local buffList, debuffList = BuffUtils:DivideBuffList( BuffTargetModel:GetShowList() );
	if getTableLen( buffList ) > 0 then
		for _, buffVO in ipairs( buffList ) do
			buffTileList.dataProvider:push( UIData.encode(buffVO) );
		end
	end
	if getTableLen( debuffList ) > 0 then
		for _, debuffVO in ipairs( debuffList ) do
			buffTileList.dataProvider:push( UIData.encode(debuffVO) );
		end
	end
	buffTileList:invalidateData();
end

-- 更新锁定状态
function UITarget:UpdateLockState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- local btnLock = objSwf.btnLockTarget   --changer:houxudong date:2016/6/27
	-- local lockState = TargetModel:GetLockState()
	-- if btnLock.selected ~= lockState then
	-- 	btnLock.selected = lockState
	-- end
end


----------------------------------------------处理消息------------------------------------------

--监听消息列表
function UITarget:ListNotificationInterests()
	return {
		NotifyConsts.TargetAttrChange,
		NotifyConsts.TargetLockStateChange,
        NotifyConsts.TargetBuffRefresh,
        NotifyConsts.InterServerState
    }
end

--处理消息
function UITarget:HandleNotification(name, body)
	if name == NotifyConsts.TargetAttrChange then
		if body.type == enAttrType.eaHp or body.type == enAttrType.eaMaxHp then
			self:UpdateHp();
		elseif body.type == enAttrType.eaName then
			self:UpdateName();
		elseif body.type == enAttrType.eaLevel then
			self:UpdateLvl();
		end
	elseif name == NotifyConsts.TargetLockStateChange then
		self:UpdateLockState()
	elseif name == NotifyConsts.TargetBuffRefresh then
		self:UpdateBuffList();
	elseif name == NotifyConsts.InterServerState then
		self:CheckInterServer();
	end
end