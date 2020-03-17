--[[
主界面：杀戮值tips（每日杀戮属性）
2015年1月23日18:43:36
haohu
]]
_G.classlist['UIMainKillValueTips'] = 'UIMainKillValueTips'
_G.UIMainKillValueTips = BaseUI:new("UIMainKillValueTips");
UIMainKillValueTips.objName = 'UIMainKillValueTips'
function UIMainKillValueTips:Create()
	self:AddSWF("killValueTips.swf", true, "top");
end

function UIMainKillValueTips:OnLoaded( objSwf )
	objSwf.lblPrompt.text = StrConfig["killTask001"];
	self:InitAttrLabel();
end

function UIMainKillValueTips:InitAttrLabel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for _, cfg in pairs(t_killtask) do
		local lblAttr = objSwf["lblAttr" .. cfg.level];
		if lblAttr then
			lblAttr.text = cfg.name;
		end
	end
end

function UIMainKillValueTips:OnShow()
	self:UpdateShow();
	self:PlayEffect(true);
	self:UpdatePos();
end

function UIMainKillValueTips:OnHide()
	self:PlayEffect(false);
end

function UIMainKillValueTips:GetWidth()
	return 400
end

function UIMainKillValueTips:GetHeight()
	return 400
end

function UIMainKillValueTips:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local killValue = KillValueModel:GetKillValue();
	local level = KillValueUtils:GetLevel(killValue); -- 当前杀戮等级
	-- 杀戮值显示
	local killValueMaximum = KillValueUtils:GetKillValueMaximum(level);
	-- 下一杀戮等级的达成度
	local nextLevel = math.min( level + 1, KillValueConsts:GetMaxLevel() );
	objSwf.titleLoader.source = ResUtil:GetKillValueTipsTitleURL( nextLevel );
	objSwf.numLoader:drawStr( toint( 100 * killValue / killValueMaximum, 0.5 ) .. "e" ); -- e:%
	objSwf.si:setLayer( level, killValue, killValueMaximum );
	-- 属性显示
	self:ShowAttrs();
	-- 历史累计属性显示
	self:ShowHistoryAttr();
end

function UIMainKillValueTips:ShowAttrs()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for level = 1, KillValueConsts:GetMaxLevel() do
		local txtAttr = objSwf["txtAttr" .. level];
		if txtAttr then
			txtAttr.htmlText = self:GetAttrTxt(level);
		end
	end
end

function UIMainKillValueTips:ShowHistoryAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local historyAttrMap = KillValueUtils:GetHistoryAttrMap();
	objSwf.txtAttrTotal.htmlText = KillValueUtils:ParseAttrMap( historyAttrMap, "#29cc00", 123 ); -- 123 两个属性文本距离
end

function UIMainKillValueTips:GetAttrTxt( level )
	local htmlText = "";
	local killValue = KillValueModel:GetKillValue();
	local currentLevel = KillValueUtils:GetLevel( killValue ); -- 当前杀戮等级
	local attrStr = KillValueUtils:GetAttrStr(level)
	local attrMap = AttrParseUtil:ParseAttrToMap(attrStr);
	local color = currentLevel >= level and "#29cc00" or "#828282";
	htmlText = KillValueUtils:ParseAttrMap(attrMap, color);
	return htmlText;
end

function UIMainKillValueTips:PlayEffect(play)
	local objSwf = self.objSwf;
	local effect = objSwf and objSwf.effect;
	if not effect then return; end
	if play then
		effect:playEffect(0);
	else
		effect:stopEffect();
	end
end

-- 位置
function UIMainKillValueTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end


-------------------------------消息处理------------------------------
--监听消息
function UIMainKillValueTips:ListNotificationInterests()
	return {
		NotifyConsts.KillValueChange,
		NotifyConsts.KillHistoryChange,
		NotifyConsts.StageMove,
	}
end

--消息处理
function UIMainKillValueTips:HandleNotification( name, body )
	if name == NotifyConsts.KillValueChange then
		self:UpdateShow();
	elseif name == NotifyConsts.KillHistoryChange then
		self:ShowHistoryAttr();
	elseif name == NotifyConsts.StageMove then
		self:UpdatePos();
	end
end
