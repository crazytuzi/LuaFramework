--[[
帮派:帮派弹劾面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionTanheDialog = BaseUI:new("UIUnionTanheDialog")

function UIUnionTanheDialog:Create()
	self:AddSWF("unionTanheDialogPanel.swf", true, "top");
end

function UIUnionTanheDialog:OnLoaded(objSwf, name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.btnGotoBuy.click = function() UIShoppingMall:Show() end
	objSwf.txtUnionInfo.text = UIStrConfig['union106']
	objSwf.btnTanhe.click = function()
		local itemId, itemNum = self:GetTanheItem()	
		local hasNum = BagModel:GetItemNumInBag(itemId) or 0 
		if hasNum < itemNum then 
			FloatManager:AddNormal(StrConfig["union78"])
			return 
		end
		UnionController:ReqGuildTanHeMsg()
		self:Hide()
	end
	
	local slotVO = RewardSlotVO:new();
	local itemId, itemNum = self:GetTanheItem()	
	slotVO.id = itemId
	slotVO.count = 0
	objSwf.tanheitem:setData( slotVO:GetUIData() );
	objSwf.tanheitem.rollOver = function() self:OnItemRollOver(); end
	objSwf.tanheitem.rollOut = function() self:OnItemRollOut(); end
	
	
end

function UIUnionTanheDialog:UpdateItemCount()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local itemId, itemNum = self:GetTanheItem()	
	local hasNum = BagModel:GetItemNumInBag(itemId) or 0 
	
	local textColor = '#ff0000'
	if hasNum >= itemNum then 
		textColor = '#00ff00'
	end
	objSwf.labItemNum.htmlText = '<font color="'..textColor..'">'..hasNum..'/'..itemNum..'</font>'
end

function UIUnionTanheDialog:OnBtnCloseClick()
	self:Hide()
end

function UIUnionTanheDialog:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end

	-- objSwf.btnTanhe.disabled = true
	UnionController:ReqGuildTanHeQuanXian()
	self:UpdateItemCount()
end

function UIUnionTanheDialog:IsShowSound()
	return true;
end

function UIUnionTanheDialog:IsShowLoading()
	return true;
end

function UIUnionTanheDialog:OnItemRollOver()
	local itemId, itemNum = self:GetTanheItem()	
	TipsManager:ShowItemTips(itemId);
end

function UIUnionTanheDialog:OnItemRollOut()
	TipsManager:Hide();
end

function UIUnionTanheDialog:GetTanheItem()	
	local paramList = split(t_consts[142].param, ',')
	local itemId = toint(paramList[1])
	local itemNum = toint(paramList[2])
	
	return itemId, itemNum
end

function UIUnionTanheDialog:ListNotificationInterests()
	return {
		NotifyConsts.BagItemNumChange,
		NotifyConsts.GuildTanHeQuanXian,
	}
end

function UIUnionTanheDialog:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.BagItemNumChange then
		local itemId, itemNum = self:GetTanheItem()	
		if itemId == body.id then
			self:UpdateItemCount()		
		end
	elseif name == NotifyConsts.GuildTanHeQuanXian then
			self:UpdateTanheRight(body.btanhe)
	end 
end


function UIUnionTanheDialog:UpdateTanheRight(btanhe)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	-- objSwf.btnTanhe.disabled = true
	-- if btanhe == 1 then
		-- objSwf.btnTanhe.disabled = false
	-- end
end









