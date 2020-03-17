--[[
寄售行 收益信息
wangshuai
]]

_G.UIConsignmentEarn = BaseUI:new("UIConsignmentEarn")

function UIConsignmentEarn:Create()
	self:AddSWF("consignmentEarnPanel.swf",true,nil)
end;

function UIConsignmentEarn:OnLoaded(objSwf)

end;

function UIConsignmentEarn:OnShow()
	-- 请求我的盈利信息
	ConsignmentController:ResqMyProfitInfo()
	self:ShowList();
end;

function UIConsignmentEarn:OnHide()

end;


function UIConsignmentEarn:SetMyEarn()
	local objSwf = self.objSwf;
	local va1,va2 = ConsignmentModel:GetEarnMoney()
	--objSwf.gold.htmlText = va2;
end;

function UIConsignmentEarn:ShowList()
	local objSwf = self.objSwf;
	local datalist = ConsignmentModel:GetEarnInfoData();
	local uiData = {};
	for i,info in pairs(datalist) do 
		local vo =  ConsignmentUtils:GetEarnUIData(info);
		table.push(uiData,vo)
	end;
	objSwf.enarlist.dataProvider:cleanUp();
	objSwf.enarlist.dataProvider:push(unpack(uiData));
	objSwf.enarlist:invalidateData();
	self:SetMyEarn();
end;

-- notifaction
function UIConsignmentEarn:ListNotificationInterests()
	return {
			NotifyConsts.ConsignmentMyProfitInfo;
		}
end;
function UIConsignmentEarn:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.ConsignmentMyProfitInfo then  
		self:ShowList();
	end;
end;