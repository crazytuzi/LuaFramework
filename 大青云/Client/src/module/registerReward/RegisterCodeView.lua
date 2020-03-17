--[[
激活码面板
zhangshuhui
2015年3月7日11:15:00
]]

_G.UIRegisterCodeView = BaseUI:new("UIRegisterCodeView");

UIRegisterCodeView.lastSendTime = 0;

function UIRegisterCodeView:Create()
	if Version:IsLianYun() then
		self:AddSWF("registerCodePanelLianYun.swf",true,nil);
	else
		self:AddSWF("registerCodePanel.swf",true,nil);
	end
end

function UIRegisterCodeView:OnLoaded(objSwf)
	--激活
	objSwf.btnactivaty.click = function() self:OnBtnActivatyClick() end
	
	--输入激活码
	objSwf.inputCode.textChange = function() self:OnCodeChange(); end
end

function UIRegisterCodeView:OnShow(name)
	--显示
	self:ShowPanel();
end

function UIRegisterCodeView:OnHide()
end

function UIRegisterCodeView:OnBtnActivatyClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--当前搜索内容为空或不存在
	if objSwf.inputCode.text == "" or objSwf.inputCode.text == objSwf.inputCode.defaultText then
		FloatManager:AddCenter( StrConfig['registerReward3'] );
		return 
	end
	if GetCurTime() - self.lastSendTime < 1000 then
		return;
	end
	self.lastSendTime = GetCurTime();
	RegisterAwardController:ReqActivatyCode(objSwf.inputCode.text);
end

function UIRegisterCodeView:OnCodeChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local text = objSwf.inputCode.text;
	text = string.gsub(text,"\r",function()
							return "";
						end);
	objSwf.inputCode.text = text;
end

function UIRegisterCodeView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.GetCodeReward then
		self:GetReward(body);
	end
end

function UIRegisterCodeView:ListNotificationInterests()
	return {NotifyConsts.GetCodeReward};
end

--输入文本失去焦点
function UIRegisterCodeView:OnIpCodeFocusOut()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if objSwf.inputCode.focused then
		objSwf.inputCode.focused = false;
	end
end

--显示
function UIRegisterCodeView:ShowPanel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.inputCode.text = objSwf.inputCode.defaultText;
end

--获取奖励
function UIRegisterCodeView:GetReward(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.inputCode.text = "";
	
	local vo = t_jihuoma[body.id];
	if vo then
		UIRewardGetPanel:Open("礼包",vo.reward)
	end
end