--[[
最小化界面
]]

_G.UIInterServiceMinPanel = BaseUI:new("UIInterServiceMinPanel");


function UIInterServiceMinPanel:Create()
	self:AddSWF("interServerPvpMinPanel.swf", true, "center");
end;
function UIInterServiceMinPanel:OnLoaded(objSwf)	
	objSwf.btnMax.click = function()
		self:Hide()		
		MainInterServiceUI.isMax = true
		MainInterServiceUI:Show()
		UIInterPvp1VsAn:Show()
	end
	objSwf.btnMax.rollOver = function () TipsManager:ShowBtnTips(StrConfig['interServiceDungeon23'],TipsConsts.Dir_RightDown); end
	objSwf.btnMax.rollOut = function () TipsManager:Hide(); end
end;
function UIInterServiceMinPanel:OnShow()
	
end;

function UIInterServiceMinPanel:OnHide()
	
end;

function UIInterServiceMinPanel:CloseClick()
	self:Hide();
end;
------ 消息处理 ---- 
function UIInterServiceMinPanel:ListNotificationInterests()
	return {
		NotifyConsts.KuafuPvpExitCatching,
		}
end;
function UIInterServiceMinPanel:HandleNotification(name,body)
	if not self.bShowState then return; end  
	if name == NotifyConsts.KuafuPvpExitCatching then 
		self:Hide();
	end;
end;