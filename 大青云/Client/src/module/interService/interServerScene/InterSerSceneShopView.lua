--[[
	跨服战场积分商店
	wangshuai
]]

_G.UIInterSerSceneShop = BaseUI:new("UIInterSerSceneShop");

UIInterSerSceneShop.isMyShopIng = false;
function UIInterSerSceneShop:Create() --shopArenaHonor
	self:AddSWF("shopArenaHonor.swf",true,"center")
end;

function UIInterSerSceneShop:OnLoaded(objSwf)
	objSwf.closeBtn.click = function ()self:CloseClick()end;


	objSwf.list.itemClick = function (e)self:OnBtnClick(e)end;
	objSwf.list.iconRollOver  = function(e) self:OnIconOver(e); end
	objSwf.list.iconRollOut   = function()  self:OnIconOut(); end
	objSwf.title:gotoAndStop(2)
	objSwf.desc.htmlText = StrConfig['shop805']
end;
function UIInterSerSceneShop:OnShow()
	local objSwf = self.objSwf;
	objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaInterSSVal;
	self:ShowList();
end;

function UIInterSerSceneShop:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.list.dataProvider:cleanUp();
	for i,info in ipairs(ShopModel.interSerSceneShop) do 
		local vo = info;
		objSwf.list.dataProvider:push(vo:GetinterSSceneUIdata());
	end;
	objSwf.list:invalidateData();
	
end;

function UIInterSerSceneShop:OnIconOver(e)
	local target = e.renderer;
	local cid = e.item.id;
	local cfg = t_shop[cid];
--	local vo = ShopModel:GetHonorList(cid);
	--if not vo then return; end
	TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown);
end;
function UIInterSerSceneShop:OnIconOut()
	TipsManager:Hide();
end;

function UIInterSerSceneShop:OnBtnClick(e) 
	-- 购买
	local id = e.item.id;
	-- if e.item.lanum <= 0 then 
	-- 	FloatManager:AddNormal(StrConfig['shop508']);
	-- end;
	local honor = MainPlayerModel.humanDetailInfo.eaInterSSVal;
	local cfg = t_shop[id];
	if cfg.price > honor then 
		FloatManager:AddNormal(StrConfig['shop804']);
		return
	end;
	-- print(id)
	ShopController:ReqBuyItem(id,1)
	self.isMyShopIng = true
end;

function UIInterSerSceneShop:CloseClick()
	self:Hide();
end;

function UIInterSerSceneShop:ShopResult()
	if self.isMyShopIng == true then
		--BagFunc:ShowPickEffect(id)
		self:ShowList();
		self.isMyShopIng = false
	end;
end;


function UIInterSerSceneShop:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange
		}
end;
function UIInterSerSceneShop:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaInterSSVal then 
			local objSwf = self.objSwf;
			objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaInterSSVal;
			self:ShowList();
		end;
	end;
end;

function UIInterSerSceneShop:ESCHide()
	return true;
end;