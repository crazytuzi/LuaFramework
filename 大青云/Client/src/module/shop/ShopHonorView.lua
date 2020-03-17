--[[
	荣誉商店
	wangshuai
]]

_G.UIShopHonor = BaseUI:new("UIShopHonor");

UIShopHonor.isMyShopIng = false;
function UIShopHonor:Create()
	self:AddSWF("shopArenaHonor.swf",true,"center")
end;

function UIShopHonor:OnLoaded(objSwf)
	-- objSwf.closeBtn.click = function ()self:CloseClick()end;


	objSwf.list.itemClick = function (e)self:OnBtnClick(e)end;
	objSwf.list.iconRollOver  = function(e) self:OnIconOver(e); end
	objSwf.list.iconRollOut   = function()  self:OnIconOut(); end
	objSwf.title:gotoAndStop(1)
end;
function UIShopHonor:OnShow()
	local objSwf = self.objSwf;
	objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaHonor;
	self:ShowList();
end;

function UIShopHonor:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.list.dataProvider:cleanUp();
	for i,info in ipairs(ShopModel.honorlist) do 
		local vo = info;
		objSwf.list.dataProvider:push(vo:GetHonorUIdata());
	end;
	objSwf.list:invalidateData();
	
end;

function UIShopHonor:OnIconOver(e)
	local target = e.renderer;
	local cid = e.item.id;
	local cfg = t_shop[cid];
--	local vo = ShopModel:GetHonorList(cid);
	--if not vo then return; end
	TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown);
end;
function UIShopHonor:OnIconOut()
	TipsManager:Hide();
end;

function UIShopHonor:OnBtnClick(e) 
	-- 购买
	local id = e.item.id;
	-- if e.item.lanum <= 0 then 
	-- 	FloatManager:AddNormal(StrConfig['shop508']);
	-- end;
	local honor = MainPlayerModel.humanDetailInfo.eaHonor;
	local cfg = t_shop[id];
	if cfg.price > honor then 
		FloatManager:AddNormal(StrConfig['shop507']);
		return
	end;
	ShopController:ReqBuyItem(id,1)
	self.isMyShopIng = true
end;

function UIShopHonor:CloseClick()
	self:Hide();
end;

function UIShopHonor:ShopResult()
	if self.isMyShopIng == true then
		--BagFunc:ShowPickEffect(id)
		self:ShowList();
		self.isMyShopIng = false
	end;
end;


function UIShopHonor:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange
		}
end;
function UIShopHonor:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaHonor then 
			local objSwf = self.objSwf;
			objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaHonor;
		end;
	end;
end;