--[[
	主宰之路扫荡完成UI
	2015年6月8日, AM 01:04:02
	wangyanwei
]]

_G.UIDominateRouteMopupInfo = BaseUI:new('UIDominateRouteMopupInfo');

function UIDominateRouteMopupInfo:Create()
	self:AddSWF('dominateRouteMopupInfo.swf',true,'center');
end

function UIDominateRouteMopupInfo:OnLoaded(objSwf)
	objSwf.txt_title.text = UIStrConfig['dominateRoute21'];
	objSwf.btn_quit.click = function () self:Hide(); end
	objSwf.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function() TipsManager:Hide(); end
	objSwf.btn_close.click = function () self:Hide(); end
end

function UIDominateRouteMopupInfo:OnShow()
	self:OnChangeReard();
end

function UIDominateRouteMopupInfo:OnChangeReard()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.rewardID];
	if not cfg then return end
	
	local rewardVOList = RewardManager:ParseToVO(cfg.rewardStr);
	for i,vo in pairs(rewardVOList) do
		vo.count = vo.count * self.rewardNum;
	end
	objSwf.rewardList.dataProvider:cleanUp();
	for i,vo in ipairs(rewardVOList) do
		for k,v in pairs(RewardSlotVO) do
			if type(v) == "function" then
				vo[k] = v;
			end
		end
		objSwf.rewardList.dataProvider:push(vo:GetUIData());
	end
	
	objSwf.rewardList:invalidateData();
	
end

UIDominateRouteMopupInfo.rewardID = 0;
UIDominateRouteMopupInfo.rewardNum = 0;
function UIDominateRouteMopupInfo:Open(id,num)
	self.rewardID = id;
	if num == 0 then
		num = 1;
	end
	self.rewardNum = num;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIDominateRouteMopupInfo:OnHide()
	
end