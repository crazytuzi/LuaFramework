--[[
今日杀戮（每日杀戮属性）
2015年3月18日16:56:43
haohu
]]
_G.classlist['UIKillValueDetail'] = 'UIKillValueDetail'
_G.UIKillValueDetail = BaseUI:new("UIKillValueDetail");
UIKillValueDetail.objName = 'UIKillValueDetail'
function UIKillValueDetail:Create()
	self:AddSWF("killValueDetailPanel.swf", true, "center")
end

function UIKillValueDetail:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end

	objSwf.lblPrompt.text = StrConfig["killTask001"];
	objSwf.txtRule1.htmlText = StrConfig["killTask003"];
	objSwf.txtRule2.htmlText = StrConfig["killTask004"];
	objSwf.txtRule3.htmlText = StrConfig["killTask005"];
	objSwf.txtRule4.htmlText = StrConfig["killTask006"];
end

function UIKillValueDetail:OnShow()
	self:UpdateShow();
end

function UIKillValueDetail:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local killValue = KillValueModel:GetKillValue();
	local level = KillValueUtils:GetLevel(killValue); -- 当前杀戮等级
	-- 杀戮值显示
	local killValueMaximum = KillValueUtils:GetKillValueMaximum(level);
	objSwf.numLoader:drawStr( toint( 100 * killValue / killValueMaximum, 0.5 ) .. "e" ); -- e:%
	objSwf.si:setLayer( level, killValue, killValueMaximum );
	-- 历史累计属性显示
	self:ShowHistoryAttr();
end

function UIKillValueDetail:ShowHistoryAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local historyAttrMap = KillValueUtils:GetHistoryAttrMap();
	objSwf.txtAttrTotal.htmlText = KillValueUtils:ParseAttrMap( historyAttrMap, "#29cc00", 123 ); -- 123 两个属性文本距离
end

function UIKillValueDetail:OnHide()
	-- body
end

function UIKillValueDetail:OnBtnCloseClick()
	self:Hide();
end

-------------------------------消息处理------------------------------
--监听消息
function UIKillValueDetail:ListNotificationInterests()
	return { NotifyConsts.KillValueChange, NotifyConsts.KillHistoryChange };
end

--消息处理
function UIKillValueDetail:HandleNotification( name, body )
	if name == NotifyConsts.KillValueChange then
		self:UpdateShow();
	elseif name == NotifyConsts.KillHistoryChange then
		self:ShowHistoryAttr();
	end
end
