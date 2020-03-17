--[[
	2016年8月22日, PM 21:00:05
	houxudong
	大摆筵席弹框信息面板
]]
_G.UILunchAnnounce = BaseUI:new('UILunchAnnounce');

function UILunchAnnounce:Create()
	self:AddSWF("lunchtips.swf", true, "center");
end

function UILunchAnnounce:OnLoaded(objSwf)
	objSwf.NormalTaocan.text = UIStrConfig['lunchNormal'];
	objSwf.VipTaocan.text = UIStrConfig['lunchVip'];
	objSwf.reward1.text = UIStrConfig['lunchReward1'];
	objSwf.reward2.text = UIStrConfig['lunchReward2'];    
	objSwf.btnCommon.click = function () self:ChooseNormaLunch(); end
	objSwf.btnVip.click = function () self:ChooseVipLunch(); end
	objSwf.btnClose.click = function () self:OnHide(); end
end

function UILunchAnnounce:OnShow()
	self:InitCostType()
end

UILunchAnnounce.costItemNum =0;
UILunchAnnounce.needVipLevel =0;
UILunchAnnounce.costItemName = ""
function UILunchAnnounce:InitCostType( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	-- 套餐一
	local cfg = t_lunch[2];
	if not cfg then return end
	local costType = t_lunch[2].cost_type
	local cost= t_lunch[2].cost
	if not costType or not cost then return; end
	if costType == 1 then    --消耗物品
		self.costItemName = enAttrTypeName[toint(split(cost,',')[1])]
		self.costItemNum = toint(split(cost,',')[2])
		objSwf.normalExpend.htmlText = string.format(StrConfig['lunchexpend'],self.costItemName..getNumShow(self.costItemNum))
	elseif costType == 2 then  --消耗vip
		self.needVipLevel = toint(t_lunch[2].cost)
		objSwf.normalExpend.htmlText = string.format(StrConfig['lunchVipFree'],self.needVipLevel)
	elseif costType == 3 then  --无消耗
	end

	-- 套餐二
	local cfg = t_lunch[3];
	if not cfg then return end
	local costType = t_lunch[3].cost_type
	local cost= t_lunch[3].cost
	if not costType or not cost then return; end
	if costType == 1 then    --消耗物品
		self.costItemName = enAttrTypeName[toint(split(cost,',')[1])]
		self.costItemNum = toint(split(cost,',')[2])
		objSwf.vipExpend.htmlText = string.format(StrConfig['lunchexpend'],self.costItemName..getNumShow(self.costItemNum))
	elseif costType == 2 then  --消耗vip
		self.needVipLevel = toint(t_lunch[3].cost)
		objSwf.vipExpend.htmlText = string.format(StrConfig['lunchVipFree'],self.needVipLevel)
	elseif costType == 3 then  --无消耗
	end
end


function UILunchAnnounce:OnHide()
	self:Hide();
end

--选择普通套餐
function UILunchAnnounce:ChooseNormaLunch()
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		local costType,itemOrPlayerInfo,id,costName,needNum,needVipLevel = ActivityLunchUtil:CheckMealCost(2)
		local _,_,_,_,_,needVipLevels = ActivityLunchUtil:CheckMealCost(3)
		local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;            --vip等级
		local func = function ()
			if costType == ActivityLunchConsts.ITEM_COST_TYPE then      --消耗物品(属性)
				local currHave = 0
				if itemOrPlayerInfo then    --消耗属性
					currHave = MainPlayerModel.humanDetailInfo[id]
				else                        --消耗道具
					currHave = BagModel:GetItemInBag(id)
				end
				if currHave < needNum then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailMoney"],costName))
				    return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.NormalChoose)
			elseif costType == ActivityLunchConsts.VIP_COST_TYPE then   --消耗vip等级
				if vipLevel < needVipLevel then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailVips"]))
					return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.NormalChoose)
			end
		end
		local str = "";
		if vipLevel >= needVipLevels and needVipLevels ~= 0 then
			str =string.format( StrConfig['lunchVipTips'], getNumShow(needNum))
		else
			if costType == ActivityLunchConsts.ITEM_COST_TYPE then
				str = string.format(StrConfig["lunchNormalTips"],costName)
			elseif costType == ActivityLunchConsts.VIP_COST_TYPE then
				str = string.format(StrConfig["lunchNormalTipsuseVip"])
			end
		end
		UIConfirm:Open(str,func);
	end
end

--选择普通套餐(旧)
function UILunchAnnounce:ChooseNormaLunchs()
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		local func = function ()
			local eaBindGold = MainPlayerModel.humanDetailInfo.eaBindGold   --银两
			if eaBindGold < self.costItemNum then
				FloatManager:AddNormal(string.format(StrConfig["lunchFailMoney"],self.costItemName))
				return;
			end
			ActivityLunch:ChooseMealType(ActivityLunchConsts.NormalChoose)
		end
		local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;            --vip等级
		local str = "";
		if vipLevel > ActivityLunchConsts.eaVipLevel then
			str = string.format(StrConfig['lunchVipTips'],getNumShow(self.costItemNum)..self.costItemName)
		else
			str = string.format(StrConfig["lunchNormalTips"],getNumShow(self.costItemNum)..self.costItemName)
		end
		UIConfirm:Open(str,func)
	end
end

--选择VIP套餐
function UILunchAnnounce:ChooseVipLunch()
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		-- 豪华套餐的消耗
		local costType,itemOrPlayerInfo,id,costName,needNum,needVipLevel = ActivityLunchUtil:CheckMealCost(3)
		local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
		local func = function ()
			if costType == ActivityLunchConsts.ITEM_COST_TYPE then      --消耗物品(属性)
				local currHave = 0
				if itemOrPlayerInfo then    --消耗属性
					currHave = MainPlayerModel.humanDetailInfo[id]
				else                        --消耗道具
					currHave = BagModel:GetItemInBag(id)
				end
				if currHave < needNum then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailMoney"],costName))
				    return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.VIPChoose)
			elseif costType == ActivityLunchConsts.VIP_COST_TYPE then   --消耗vip等级
				if vipLevel < needVipLevel then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailVips"]))
					return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.VIPChoose)
			end
		end
		local str = ''
		if costType == ActivityLunchConsts.ITEM_COST_TYPE then
			str = string.format(StrConfig["lunchhaohuaTips"],costName)
		elseif costType == ActivityLunchConsts.VIP_COST_TYPE then
			str = string.format(StrConfig["lunchHaohuaVipTips"])
		end
		UIConfirm:Open(str,func)
	end
end

--选择VIP套餐(旧)
function UILunchAnnounce:ChooseVipLunchs()
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
		if vipLevel < self.needVipLevel then
			FloatManager:AddNormal(StrConfig["lunchFailVips"])
			return;
		end
		local str = StrConfig['lunchHaohuaVipTips'];
		local func = function ()
			local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel; 
			ActivityLunch:ChooseMealType(ActivityLunchConsts.VIPChoose)
		end
		UIConfirm:Open(str,func);
	end
end