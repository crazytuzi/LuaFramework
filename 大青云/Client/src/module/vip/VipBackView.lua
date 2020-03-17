--[[
VIP 返还面板
2015-7-24 16:55:00
ly
]]
--------------------------------------------------------------

_G.UIVipBack = BaseUI:new("UIVipBack")
UIVipBack.backType = 0

UIVipBack.defaultDrawCfg = {
	EyePos   = _Vector3.new( 0, -150, 50 ),
	LookPos  = _Vector3.new( -20, 10, 30 ),
	VPort    = _Vector2.new( 1200, 800 ),
	Rotation = 45
}

function UIVipBack:Create()
	self:AddSWF("vipBackPanel.swf", true, 'top')
end

function UIVipBack:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:Hide() end
	objSwf.btnGet.click   = function() self:OnBtnGetClick() end
	objSwf.btnRenew.click = function() self:OnBtnRenewClick() end
	objSwf.numLoader.loadComplete = function() self:OnNumLoadeComplete() end
	objSwf.sign._visible = false
	objSwf.txtItem.autoSize = "left"
end

function UIVipBack:OnBtnGetClick()
	local vo = VipModel:GetBackItemInfo(self.backType);
	if not vo then return end
	local numCanBack = vo.numCanBack
	if numCanBack == 0 then
		FloatManager:AddNormal( StrConfig['vip101'] )
		return
	end
	VipController:ReqGetVipBack(self.backType)
	self:Hide()
end

function UIVipBack:OnBtnRenewClick()
	UIVip:Show()
	self:Hide()
end

function UIVipBack:Open(backType)
	self.backType = backType
	if self:IsShow() then
		self:GetInfo()
	else
		self:Show()
	end
end

function UIVipBack:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.avatar then
		self.avatar:ExitMap();
		self.avatar = nil;
	end
	if self.objSceneDraw then
		self.objSceneDraw:SetDraw(false);
	end
end

function UIVipBack:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.objSceneDraw then
		self.objSceneDraw:SetUILoader(nil);
	end
end

function UIVipBack:GetWidth()
	return 570
end

function UIVipBack:GetHeight()
	return 421
end

function UIVipBack:OnShow()
	self:GetInfo()
end

function UIVipBack:GetInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	VipController:ReqVipBackInfo(self.backType)
	local isOpen = 0
	if self.backType == VipConsts.TYPE_LINGSHOU then
		isOpen = VipController:GetIsLingshouBack()
	elseif self.backType == VipConsts.TYPE_QIANGHUA then
		isOpen = VipController:GetIsEquipBack()
	elseif self.backType == VipConsts.TYPE_MOUNT then
		isOpen = VipController:GetIsMountBack()
	elseif self.backType == VipConsts.TYPE_REALM then
		isOpen = VipController:GetIsJingJieBack()
	end
	-- 是否有VIP权限
	-- print('==================isOpen',isOpen)
	objSwf.btnRenew._visible = isOpen <= 0
	objSwf.btnGet.visible    = isOpen > 0
	if self.backType == VipConsts.TYPE_REALM then
		self:Show3DScene();
	else
		self:Show3DModel()
	end
	self:ShowType()
end

function UIVipBack:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local vo = VipModel:GetBackItemInfo(self.backType);
	if not vo then return end
	local itemId, itemNum, numCanBack = vo.itemId, vo.itemNum, vo.numCanBack
	if itemId and itemId > 0 then
		objSwf.btnGet.disabled = false			
		local itemName = ""
		if t_item[itemId] then
			itemName = t_item[itemId].name
		elseif t_equip[itemId] then
			itemName = t_equip[itemId].name
		end
		objSwf.txtItem.htmlText = string.format( '<font color="#00FF00">%s×%s</font>', itemName, itemNum )
		local numCannotBack = itemNum - numCanBack
		local str1, str2, str3 = "", "", ""
		if itemId ~= enAttrType.eaZhenQi then
			str3 = StrConfig['vip102']
		end
		str1 = string.format( StrConfig['vip103'], self:GetShowNum(numCanBack) .. str3)
		if numCannotBack > 0 then
			str2 = string.format( StrConfig['vip104'], self:GetShowNum(numCannotBack) .. str3 )
		end
		objSwf.txtCanBack.htmlText = string.format( '<i>%s</i>', str1 .. str2 )
		if itemNum and itemNum <= 0 then
			objSwf.btnGet.disabled = true
		end
	else
		objSwf.txtItem.text = ''
		objSwf.btnGet.disabled = true
	end
	self:ShowSaveMoney(itemId, itemNum)
end

function UIVipBack:GetShowNum(num)
	local numStr = ""
	if num >= 10000 then
		numStr = string.format( "%0.1f"..StrConfig['vip105'], num / 10000 )
	else
		numStr = tostring(num)
	end
	return numStr
end

function UIVipBack:Show3DModel()
	if self.backType ~= VipConsts.TYPE_LINGSHOU and self.backType ~= VipConsts.TYPE_MOUNT then
		return
	end
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.avatar then
		self.avatar = self:GetAvatar()
	end
	local drawcfg = self.defaultDrawCfg
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new( "UIVipBack", self.avatar, objSwf.loader, drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos, 0x00000000 )
	else
		self.objUIDraw:SetUILoader( objSwf.loader )
		self.objUIDraw:SetCamera( drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos )
		self.objUIDraw:SetMesh( self.avatar )
	end
	self.avatar.objMesh.transform:setRotation( 0, 0, 1, drawcfg.Rotation );
	-- 模型旋转
	self.objUIDraw:SetDraw(true);
end

function UIVipBack:Show3DScene()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.objSceneDraw then
		self.objSceneDraw = UISceneDraw:new( "UIVipBackScene", objSwf.loader, _Vector2.new(1200, 1200));
	end
	self.objSceneDraw:SetUILoader(objSwf.loader);
	self.objSceneDraw:SetScene("v_mubiao_jingjie_ui.sen");
	self.objSceneDraw:SetDraw( true );
end

function UIVipBack:GetAvatar()
	local avatar = nil
	local bType = self.backType
	if bType == VipConsts.TYPE_LINGSHOU then
		local wuhunId = VipConsts.BackLingShou
		local cfg = t_wuhun[wuhunId]
		if not cfg then return end
		local uiCfg = t_lingshouui[cfg.ui_id]
		avatar = CZhanshouAvatar:new(uiCfg.model)
	elseif bType == VipConsts.TYPE_MOUNT then
		local modelid = MountUtil:GetPlayerMountModelId( VipConsts.BackMount );
		avatar = CHorseAvatar:new(modelid)
		avatar:Create(modelid);
	end
	return avatar
end

function UIVipBack:OnNumLoadeComplete()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.numLoader._x = objSwf.sign._x - objSwf.numLoader.width * 0.5
end

function UIVipBack:ShowSaveMoney(itemId, itemNum)
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
	objSwf.numLoader.num = toint(price * itemNum, 0.5)
end

function UIVipBack:ShowType()
	local objSwf = self.objSwf
	if not objSwf then return end
	local bType = self.backType
	local frameName = ""
	if bType == VipConsts.TYPE_LINGSHOU then
		frameName = "ls"
	elseif bType == VipConsts.TYPE_QIANGHUA then
		frameName = "qh"
	elseif bType == VipConsts.TYPE_MOUNT then
		frameName = "zq"
	elseif bType == VipConsts.TYPE_REALM then
		frameName = "jj"
	end
	objSwf.mc:gotoAndPlay(frameName)
end

function UIVipBack:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.VipPeriod,
		NotifyConsts.VipBackInfo,
		NotifyConsts.VipBackInfoChange,
	}
end

function UIVipBack:HandleNotification( name, body )
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaVIPLevel then
			self:GetInfo()
		end
	elseif name == NotifyConsts.VipPeriod then
		self:GetInfo()
	elseif name == NotifyConsts.VipBackInfo then
		self:UpdateShow()
	elseif name == NotifyConsts.VipBackInfoChange then
		self:GetInfo()
	end
end
