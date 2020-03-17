--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/9/1
    Time: 19:27
   ]]

_G.NoOperationView = BaseUI:new("UINoOperation");
NoOperationView.okCallBack = nil;
function NoOperationView:Create()
	self:AddSWF("noOperation.swf", true, "highTop");
end


function NoOperationView:OnLoaded(objSwf, name)
	objSwf.okButton.click = function() self:OnOkClicked() end

end

function NoOperationView:OnShow()
	-- 查看args中第一位的参数有没有，如果有的话，说明是要直接跳转到某一个tab
	if #self.args > 0 then
		self.objSwf.txtContent.htmlText = self.args[1];
		self.objSwf.okButton.label = self.args[2];
		self.okCallBack = self.args[3];
	end
end

function NoOperationView:OnOkClicked()
	if self.okCallBack then
		self.okCallBack();
	end
	self:Hide();
end

function NoOperationView:IsTween()
	return false;
end

function NoOperationView:ESCHide()
	return false;
end