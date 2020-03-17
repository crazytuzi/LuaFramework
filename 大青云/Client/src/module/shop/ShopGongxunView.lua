--[[
	荣誉商店
	wangshuai
]]

_G.UIShopGongxun = BaseUI:new("UIShopGongxun");

UIShopGongxun.isMyShopIng = false;
function UIShopGongxun:Create()
	self:AddSWF("shopGongxun.swf",true,"top")
end;

function UIShopGongxun:OnLoaded(objSwf)
	objSwf.closeBtn.click = function ()self:CloseClick()end;


	objSwf.list.itemClick = function (e)self:OnBtnClick(e)end;
	objSwf.list.iconRollOver  = function(e) self:OnIconOver(e); end
	objSwf.list.iconRollOut   = function()  self:OnIconOut(); end

end;
function UIShopGongxun:OnShow()
	local objSwf = self.objSwf;
	objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaCrossExploit;
	self:ShowList();
end;

function UIShopGongxun:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.list.dataProvider:cleanUp();
	for i,info in ipairs(ShopModel.gongxunlist) do 
		local vo = info;
		objSwf.list.dataProvider:push(vo:GetGongxunUIdata());
	end;
	objSwf.list:invalidateData();
	
end;

function UIShopGongxun:OnIconOver(e)
	local target = e.renderer;
	local cid = e.item.id;
	local cfg = t_shop[cid];
--	local vo = ShopModel:GetHonorList(cid);
	--if not vo then return; end
	TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown);
end;
function UIShopGongxun:OnIconOut()
	TipsManager:Hide();
end;

function UIShopGongxun:OnBtnClick(e) 
	-- 购买
	local id = e.item.id;
	if e.item.lanum <= 0 then 
		FloatManager:AddNormal(StrConfig['shop222']);
	end;
	local honor = MainPlayerModel.humanDetailInfo.eaCrossExploit;
	local cfg = t_shop[id];
	if cfg.price > honor then 
		FloatManager:AddNormal(StrConfig['shop514']);
		return
	end;
	ShopController:ReqBuyItem(id,1)
	self.isMyShopIng = true
end;

function UIShopGongxun:CloseClick()
	self:Hide();
end;

function UIShopGongxun:ShopResult()
	if self.isMyShopIng == true then
		--BagFunc:ShowPickEffect(id)
		self:ShowList();
		self.isMyShopIng = false
	end;
end;


function UIShopGongxun:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange
		}
end;
function UIShopGongxun:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaCrossExploit then 
			local objSwf = self.objSwf;
			objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaCrossExploit;
			self:ShowList();
		end;
	end;
end;