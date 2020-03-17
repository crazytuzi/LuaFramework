--[[
	扫荡UI
	2015年6月5日, PM 10:42:46
	wangyanwei
]]

_G.UIDominateRouteMopup = BaseUI:new('UIDominateRouteMopup');

function UIDominateRouteMopup:Create()
	self:AddSWF('dominateRouteMopup.swf',true,'top');
end

function UIDominateRouteMopup:OnLoaded(objSwf)
	objSwf.txt_title.text = UIStrConfig['dominateRoute20'];
	objSwf.btn_cancel.click = function () self:Hide(); end
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_enter.click = function ()
		local enterNum = DominateRouteModel:OnGetEnterNum();
		if enterNum < 1 then
			FloatManager:AddNormal( StrConfig['dominateRoute0213'] );
			return
		end
		--[[
		if enterNum < objSwf.nsNum.value then
			FloatManager:AddNormal( StrConfig['dominateRoute0213'] );
			return
		end
		local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;

		if t_zhuzairoad[self.dominateRouteID].level_energy*objSwf.nsNum.value > num then
			FloatManager:AddNormal( StrConfig['dominateRoute0210'] );
			self:Hide();
			return
		end
		--]]
	
		DominateRouteController:SendDominateRouteWipe(self.dominateRouteID)
		self:Hide();
	end
	
	objSwf.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function() TipsManager:Hide(); end
	
	objSwf.nsNum.change = function () self:OnListChangeClick(); end
	objSwf.nsNum.visible = false;
end

function UIDominateRouteMopup:OnShow()
	self:OnDrawRewardList();
	self:OnButtonSetData();
end

UIDominateRouteMopup.dominateRouteID = nil;
function UIDominateRouteMopup:Open(id)
	self.dominateRouteID = id;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

--改变奖励点击  + -  i++
UIDominateRouteMopup.rewardNumValue = 1;
function UIDominateRouteMopup:OnListChangeClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local nsNum = objSwf.nsNum.value;
	if self.rewardNumValue == nsNum then
		return 
	end
	self.rewardNumValue = objSwf.nsNum.value;
	local cfg = t_zhuzairoad[self.dominateRouteID];
	if not cfg then return end
	local rewardVOList = RewardManager:ParseToVO(cfg.rewardStr);
	for i,vo in pairs(rewardVOList) do
		vo.count = vo.count * nsNum;
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

--list
function UIDominateRouteMopup:OnDrawRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.dominateRouteID];
	if not cfg then return end
	local rewardList = RewardManager:Parse(cfg.rewardStr);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardList:invalidateData();
	objSwf.nsNum.value = 1;
end

--按钮设置
function UIDominateRouteMopup:OnButtonSetData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.dominateRouteID];
	if not cfg then return end
	-- local dominateRoute = DominateRouteModel:OnGetDominateVO(self.dominateRouteID);
	self:OnChangeNsMaxValue();						---设置可挑战次数的最大值
	if objSwf.nsNum.maximum < 1 then
		objSwf.nsNum.value = 1;
		return
	end
end

function UIDominateRouteMopup:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.nsNum.value = 1;
	self.rewardNumValue = 1;
end

function UIDominateRouteMopup:OnChangeNsMaxValue()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local jlNum = MainPlayerModel.humanDetailInfo.eaDominJingLi;
	local cfg = t_zhuzairoad[self.dominateRouteID];
	if not cfg then return end
	-- local mopupNum = toint( jlNum / cfg.level_energy );
	local enterNum = DominateRouteModel:OnGetEnterNum();
	objSwf.nsNum.maximum = enterNum;
	-- print("剩余次数:",enterNum)
	objSwf.nsNum.disabled = objSwf.nsNum.maximum < 1;
	objSwf.btn_enter.disabled = objSwf.nsNum.maximum < 1;
	objSwf.nsNum.input = not (objSwf.nsNum.maximum < 1);
end

function UIDominateRouteMopup:HandleNotification(name,body)
	if name == NotifyConsts.DominateRouteAddJingLi then
		self:OnChangeNsMaxValue();
	end
end

function UIDominateRouteMopup:ListNotificationInterests()
	return {
		NotifyConsts.DominateRouteAddJingLi,
	}
end