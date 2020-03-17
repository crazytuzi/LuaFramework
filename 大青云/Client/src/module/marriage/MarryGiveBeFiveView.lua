--[[
结婚，收到红包，查看界面
wangshuai
]]

_G.MarryGiveBeFive = BaseUI:new("MarryGiveBeFive")

function MarryGiveBeFive:Create()
	self:AddSWF("MarryGiveBeFivePanel.swf",true,"center")
end;

function MarryGiveBeFive:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.sureBtn.click = function() self:Hide()end;
end;


-- 显示前的判断，每个show方法第一步
function MarryGiveBeFive:ShowJudge()

	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if not isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage042"]);
		return 
	end;
	self:Show();
end;

function MarryGiveBeFive:OnShow()
	MarriagController:ReqLookMarryRedPackets()
end;

function MarryGiveBeFive:OnHide()

end;

function MarryGiveBeFive:OnUpdataShow()
	self:OnUpdatalist();
end;


function MarryGiveBeFive:OnUpdatalist()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local data = MarriageModel.MarryRedMoney;
	local list = {};
	for i,info in ipairs(data) do 
		local item = objSwf["item_"..i];
		local vo = {};
		vo.name = info.name;
		vo.num  = info.num;
		vo.desc = info.blessing;
		table.push(list,UIData.encode(vo))
	end;

	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();

end;

-- 是否缓动
function MarryGiveBeFive:IsTween()
	return true;
end

--面板类型
function MarryGiveBeFive:GetPanelType()
	return 1;
end
