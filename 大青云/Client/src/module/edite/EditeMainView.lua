_G.UIEditeMain = BaseUI:new("UIEditeMain");
UIEditeMain.tabButton = nil;

function UIEditeMain:Create()
	PanelPosConfig["UIEditeMain"] = {bottom=674,left=0};
	self:AddSWF("editeMainPanel.swf",true,"center");
end

function UIEditeMain:OnLoaded(objSwf)
	self.tabButton = {};
	self.tabButton[objSwf.lightBtn._name] = objSwf.lightBtn;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() 
			self:OnTabButtonClick(name);
		end
	end
	
	UIEditeLight.Button = self.tabButton[objSwf.lightBtn._name];
	self.tabButton[objSwf.lightBtn._name] = UIEditeLight;
	
	objSwf.goBtn.click = function() self:OnGoSceneClick(); end
	objSwf.sceneLabel.restrict   = "0-9\\\\";
	objSwf.closeBtn.click = function() self:OnBtnCloseClick(); end
end

function UIEditeMain:OnGoSceneClick()
	local mapid = tonumber( self.objSwf.sceneLabel.text ) or 0;
	ChatController:SendChat(ChatConsts.Channel_World,'/gotofb/'..mapid);
end

function UIEditeMain:OnShow()
	self:OnTabButtonClick(self.objSwf.lightBtn._name);
end

function UIEditeMain:OnTabButtonClick(name)
	for i,view in pairs(self.tabButton) do
		if i == name then
			view.Button.selected = true;
			view:Show();
		else
			view.Button.selected = false;
			view:Hide();
		end
	end
end

function UIEditeMain:OnBtnCloseClick()
	self:Hide();
end

function UIEditeMain:OnHide()
	self:OnTabButtonClick();
end

