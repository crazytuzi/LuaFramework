--[[
神武 激活view
haohu
2015年12月25日16:36:03
]]

_G.UIShenWuActive = {}

UIShenWuActive.objSwf = nil

UIShenWuActive.bShowState = nil
UIShenWuActive.objSwf = nil

function UIShenWuActive:OnLoaded( objSwf )
	self.objSwf = objSwf
	objSwf.btnActive.click = function() self:OnBtnActiveClick() end
	objSwf.txtNum.rollOver = function(e) self:OnItemRollOver(e) end
	objSwf.txtNum.rollOut = function(e) TipsManager:Hide() end
	objSwf.btnActive.label = StrConfig['shenwu12']
	objSwf.txtDamage.autoSize = "left"
	self:Hide()
end

function UIShenWuActive:OnDelete()
	self.bShowState = nil
	self.objSwf = nil
end

function UIShenWuActive:Show()
	if self.bShowState == true then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf._visible = true
	objSwf.hitTestDisable = false
	self.bShowState = true
	self:UpdateShow()
end

function UIShenWuActive:Hide()
	if self.bShowState == false then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf._visible = false
	objSwf.hitTestDisable = true
	self.bShowState = false
end

function UIShenWuActive:OnBtnActiveClick()
	ShenWuController:ReqShenWuLevelUp()
end

function UIShenWuActive:OnItemRollOver(e)
	local material = ShenWuUtils:GetLevelUpMaterial(0)
	local vo = material[1]
	if vo then
		TipsManager:ShowItemTips( vo.id )
	end
end

function UIShenWuActive:UpdateShow()
	self:ShowWeapon()
	self:ShowMaterial()
	self:ShowAttr()
end

function UIShenWuActive:ShowWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local vo = EquipUtil:GetEquipUIVO( BagConsts.Equip_WuQi, false )
	if not vo.hasItem then
		ShenWuUtils:GetDataToShenWuUIVO(vo)
	end
	
end

function UIShenWuActive:ShowMaterial()
	local objSwf = self.objSwf
	if not objSwf then return end
	local material = ShenWuUtils:GetLevelUpMaterial(0)
	local vo = material[1]
	if vo then
		local slotVO = RewardSlotVO:new();
		slotVO.id = vo.id
		slotVO.count = 0
		local playerHasNum = BagModel:GetItemNumInBag(vo.id)
		local color = playerHasNum < vo.num and "#FF0000" or "#00FF00"
		objSwf.txtNum.htmlLabel = string.format( StrConfig['shenwu30'], color, t_item[vo.id].name .."*"..vo.num )
	else
		objSwf.txtNum.htmlLabel = ""
	end
end
function UIShenWuActive:ShowAttr()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = math.max( ShenWuModel:GetLevel(), 1 )
	local star = ShenWuModel:GetStar()
	local attrMap = ShenWuUtils:GetAttrMap(level, star)
	local nameFormat, value
	for i = 1, 5 do
		local textField = objSwf['txtAttr'..i]
		if textField then
			local att = ShenWuConsts.Attrs[i]
			if att and att ~= "" then
				local attrType = AttrParseUtil.AttMap[att]
				nameFormat = ShenWuConsts.AttrNames[att]
				value = getAtrrShowVal( attrType, attrMap[att] )
				textField.htmlText = string.format(nameFormat, value)
			else
				textField.htmlText = ""
			end
		end
	end
	local cfg = ShenWuUtils:GetStarCfg(level, star)
	objSwf.txtDamage.text = cfg and string.format( "+%0.2f%%", cfg.promote * 0.01 ) or "+0.00%"
end

--处理消息
function UIShenWuActive:HandleNotification(name, body)
	if not self.bShowState then return end
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Role then
			self:ShowWeapon()
		end
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowMaterial()
	end
end


-- NotifyConsts.BagAdd,
-- NotifyConsts.BagRemove,
-- --
-- NotifyConsts.BagItemNumChange,