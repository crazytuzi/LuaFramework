--[[
VIP 返还tips
]]
--------------------------------------------------------------

_G.UIVipBackTips = BaseUI:new("UIVipBackTips")

function UIVipBackTips:Create()
	self:AddSWF("vipBackTips.swf", true, "top")
end

function UIVipBackTips:OnLoaded( objSwf )
	objSwf.txtBack.autoSize = "center"
	objSwf.hitTestDisable = true;
end

function UIVipBackTips:OnShow()
	self:ShowType()
	self:ShowItem()
	self:UpdatePos()
end

function UIVipBackTips:ShowItem()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.backType then return end
	local vo = VipModel:GetBackItemInfo(self.backType);
	if not vo or ( vo and vo.ischange == true) then
		VipController:ReqVipBackInfo( self.backType );
	else
		local itemId, itemNum, numCanBack = vo.itemId, vo.itemNum, vo.numCanBack
		local suffix = ""
		if itemId ~= enAttrType.eaZhenQi then
			suffix = StrConfig['vip102']
		end
		objSwf.mc.txtItem.text = itemNum .. suffix
		local cfg = self:GetBackCfg()
		local numLimit = cfg[self.backType].numLimit
		objSwf.txtLingqu.htmlText = (numLimit == -1) and "" or string.format( StrConfig['vip106'], numLimit )
		objSwf.txtCanBack.htmlText = StrConfig['vip107']
		self:ShowSaveMoney(itemId, itemNum)
		self:ShowNextLevel(itemNum)
	end
end

local cfg
function UIVipBackTips:GetBackCfg()
	if not cfg then
		cfg = {
			[VipConsts.TYPE_MOUNT]    = { numLimit = t_consts[127].val1, lvLimit = t_consts[127].val2 },
			[VipConsts.TYPE_LINGSHOU] = { numLimit = t_consts[128].val1, lvLimit = t_consts[128].val2 },
			[VipConsts.TYPE_REALM]    = { numLimit = t_consts[129].val1, lvLimit = t_consts[129].val2 }
		}
	end
	return cfg
end

function UIVipBackTips:ShowSaveMoney(itemId, itemNum)
	local objSwf = self.objSwf
	if not objSwf then return end
	local price = 0
	if itemId == enAttrType.eaZhenQi then
		price = VipConsts.LingLiPrice
	else
		for _, cfg in pairs(t_shop) do
			if cfg.itemId == itemId and cfg.moneyType == enAttrType.eaUnBindMoney then
				price = cfg.price
				break
			end
		end
	end
	objSwf.txtBack.htmlText = string.format( StrConfig['vip108'], toint(price * itemNum, 0.5) )
end

function UIVipBackTips:ShowType()
	local objSwf = self.objSwf
	if not objSwf then return end
	local frameName
	if self.backType == VipConsts.TYPE_MOUNT then
		frameName = "zq"
	elseif self.backType == VipConsts.TYPE_LINGSHOU then
		frameName = "ls"
	elseif self.backType == VipConsts.TYPE_REALM then
		frameName = "jj"
	end
	if not frameName then return end
	objSwf.mc:gotoAndPlay(frameName)
	objSwf.txtLingqu.text = StrConfig['vip109']
end
function UIVipBackTips:ShowNextLevel(itemNum)
	local objSwf = self.objSwf
	if not objSwf then return end
	local num
	if self.backType == VipConsts.TYPE_MOUNT then
		local mountId = MountModel.ridedMount.ridedId;
		if t_horse[mountId] then
			num = t_horse[mountId].return_item+itemNum;
		else
			num = 0;
		end
	elseif self.backType == VipConsts.TYPE_LINGSHOU then
		num = 0
	elseif self.backType == VipConsts.TYPE_REALM then
		local realmId = RealmModel:GetRealmOrder();
		if t_jingjie[realmId] then
			num = t_jingjie[realmId].return_item+itemNum;
		else
			num = 0;
		end
	end
	objSwf.next.htmlText = string.format( StrConfig['vip133'], num )
end

function UIVipBackTips:OnHide()
	self.backType = nil
end

function UIVipBackTips:GetWidth()
	return 203
end

function UIVipBackTips:GetHeight()
	return 188
end

function UIVipBackTips:Open(backType)
	self.backType = backType
	self:Show()
end

-- 位置
function UIVipBackTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end


---------------------------------消息处理------------------------------------
--监听消息列表
function UIVipBackTips:ListNotificationInterests()
	return {
		NotifyConsts.StageMove,
		NotifyConsts.VipBackInfo
	};
end

--处理消息
function UIVipBackTips:HandleNotification(name, body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos();
	elseif name == NotifyConsts.VipBackInfo then
		self:ShowItem()
	end
end