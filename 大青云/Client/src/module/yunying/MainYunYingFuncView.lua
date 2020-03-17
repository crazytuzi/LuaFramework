--[[
主界面运营活动
lizhuangzhuang
2015年5月7日11:02:14
]]

--临时处理

_G.UIMainYunYingFunc = BaseUI:new("UIMainYunYingFunc");


function UIMainYunYingFunc:Create()
	self:AddSWF("mainYunyingFunc.swf",true,"bottom");
end
function UIMainYunYingFunc:OnLoaded(objSwf)
	--注册按钮
	for i,list in ipairs(YunYingConsts.BtnPosMap) do
		for j,id in ipairs(list) do
			local button = YunYingBtnManager:GetBtn(id);
			if button then
				local btnName = button:GetStageBtnName();
				if btnName and btnName~="" then

					local uiBtn = objSwf.content[btnName];
					if uiBtn then
						button:SetButton(uiBtn);
					else
					--	print("Error:找不到指定运营按钮.ID",id);
					end
				end
			end
		end
	end
end

function UIMainYunYingFunc:CloseTop()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.content._visible = false;
	objSwf.content.hitTestDisable = true;
end

function UIMainYunYingFunc:UnCloseTop()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.content._visible = true;
	objSwf.content.hitTestDisable = false;
end

function UIMainYunYingFunc:OnResize(wWidth,wHeight)
	self:SetUIPos();
end

function UIMainYunYingFunc:SetUIPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wWidth, wHeight = UIManager:GetWinSize();
	objSwf.content._x =wWidth - 200;
	objSwf.content._y = 150;
end
function UIMainYunYingFunc:OnShow()
	self:SetUIPos();
	self:DrawLayout();
	-- YunYingUti:CountDownTimes();
end
--按钮布局
function UIMainYunYingFunc:DrawLayout()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for line,list in ipairs(YunYingConsts.BtnPosMap) do
		local x = 0;
		for i=#list,1,-1 do
			local id = list[i];
			local button = YunYingBtnManager:GetBtn(id);
			if button and button:GetButton() then
				local uiBtn = button:GetButton()
				uiBtn.visible = button:IsShow();
				if uiBtn.visible then
					button:OnRefresh();
					x = x - uiBtn.width -7;
					uiBtn._x = x;
					uiBtn._y = (line-1) * 70;
				end
			end
		end	
	end
end

function UIMainYunYingFunc:HandleNotification(name,body)

	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:DrawLayout();
		end

	end
end

function UIMainYunYingFunc:ListNotificationInterests()
	return {NotifyConsts.PlayerAttrChange};

end