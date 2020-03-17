--[[
婚礼喜帖
wangshuai
]]

_G.UIMarryCard = BaseUI:new("UIMarryCard")

UIMarryCard.itemId = "";

function UIMarryCard:Create()
	self:AddSWF("marryCardPanel.swf",true,"center")
end;

function UIMarryCard:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.enterBtn.click = function() self:btnOk() end;
end;

function UIMarryCard:OnShow()
	local objSwf = self.objSwf;
	local data = MarriageModel:GetMarryCardData(self.itemId)
	self.data = data
	objSwf.tfName11.htmlText = "";
	objSwf.tfName22.htmlText = "";
	objSwf.time_text.htmlText = "";
	if not objSwf then return end;
	if not data then return end;

	objSwf.tfName11.htmlText = data.naroleName or "";
	objSwf.tfName22.htmlText = data.nvroleName or "";

	local year, month, day, hour, minute, second = CTimeFormat:todate(data.time,true);
	
	objSwf.time_text.htmlText = string.format('%02d-%02d-%02d',year, month, day) .."<br/>" .. string.format('%02d:%02d:%02d',hour, minute, second);


	if t_playerinfo[data.naprof] and t_playerinfo[data.nvprof] then 
		objSwf.icon1.source = ResUtil:GetHeadIcon(data.naprof);
		objSwf.icon2.source = ResUtil:GetHeadIcon(data.nvprof);
	else
		objSwf.icon1.source = "";
		objSwf.icon2.source = "";
	end;
end;

function UIMarryCard:SetCid(id)
	self.itemId = id or "";
	if id and id ~= "" then 
		self:Show();
	end;
end;

function UIMarryCard:OnHide()

end;

function UIMarryCard:btnOk()
	if not self.data then 
		trace(self.data)
		print(self.itemId,debug.traceback())
		return 
	end;
	if self.data.state == -1 then 
		FloatManager:AddNormal(StrConfig['marriage218'])
		return
	elseif self.data.state == 0 then 
		FloatManager:AddNormal(StrConfig['marriage219'])
		return
	end;
	MarriagController:ReqEnterMarryChurch()
	self:Hide();
end;

function UIMarryCard:btnNo()

	self:Hide();
end;


-- 是否缓动
function UIMarryCard:IsTween()
	return true;
end

--面板类型
function UIMarryCard:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIMarryCard:IsShowSound()
	return true;
end

function UIMarryCard:IsShowLoading()
	return true;
end