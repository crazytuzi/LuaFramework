-- 单个快捷穿戴cellui
QuickEquipCell = BaseClass(LuaUI)
function QuickEquipCell:__init( ... )
	self.URL = "ui://0042gnitukjyel";
	self:__property(...)
	self:AddEvent()
end
-- Set self property
function QuickEquipCell:SetProperty( ... )
end
-- start
function QuickEquipCell:Config()
end
-- wrap UI to lua
function QuickEquipCell:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","QuickEquipCell")
	self.btnEquip = self.ui:GetChild("btnEquip")
	self.btnClose = self.ui:GetChild("btnClose")
end
-- Combining existing UI generates a class
function QuickEquipCell.Create( ui, ...)
	return QuickEquipCell.New(ui, "#", {...})
end
function QuickEquipCell:__delete()
	self:RemoveEvent()
	self:DestroyCell()
	self:RemoveFromParent()
	self.data = nil
end

function QuickEquipCell:AddEvent()
	self.btnEquip.onClick:Add( self.OnEquipClick, self )
	self.btnClose.onClick:Add( self.OnCloseClick, self )
end

function QuickEquipCell:RemoveEvent()
	self.btnEquip.onClick:Remove( self.OnEquipClick, self )
	self.btnClose.onClick:Remove( self.OnCloseClick, self )
end

function QuickEquipCell:OnEquipClick()
	if not self.isGoods then
		if self.data:GetEquipType() == 7 and self.data:IsHaveEquip() and GodFightRuneModel:GetInstance():IsPutOn() then
			-- 是武器则提示斗神印
			UIMgr.Win_Confirm("温馨提示", StringFormat("更换武器会销毁已装备武器上\n的斗神印效果，[COLOR=#228B22]是否继续？[/COLOR]"), "确定", "取消",
				function ()
					self:PutAndHide()
				end,
				nil)
		else
			self:PutAndHide()
		end
	else
		local data = PkgModel:GetInstance():GetGoodsVoByBid(self.data.bid)
		if not data then return end
		if data.goodsType == GoodsVo.GoodType.equipment then
			PkgCtrl:GetInstance():C_PutOnEquipment(data.equipId)
		else
			local cfg = data:GetCfgData()
			if cfg.useType == 3 then -- 跳转注灵界面
				SkillController:GetInstance():OpenSkillPanel(1)
			elseif cfg.useType == 4 then -- 跳转斗神印界面
				GodFightRuneController:GetInstance():OpenGodFightRunePanel()
			elseif cfg.useType == 5 then --跳转改名界面
			
			elseif cfg.useType == 6 then --秘境
				local enterPanel1 = EnterPanel1.New()
				enterPanel1:Update(cfg)
				UIMgr.ShowCenterPopup(enterPanel1, function()  end)
				PkgCtrl:GetInstance():Close()
			elseif cfg.useType == 7 then --点击技能书，打开技能界面
				SkillController:GetInstance():OpenSkillPanel()
			elseif cfg.useType == 10 then --打开合成界面
				if CompositionModel:GetInstance():IsSameWithPlayerCareer(cfg.id) then
					PkgCtrl:GetInstance():OpenByType(PkgConst.PanelType.composition , CompositionModel:GetInstance():GetTargetID(cfg.id))
				else
					UIMgr.Win_FloatTip("物品职业不符")
				end
			elseif cfg.useType == 13 then
				RechargeController:GetInstance():Open(RechargeConst.RechargeType.Turn)
			elseif cfg.useType == 11 then
				RechargeController:GetInstance():Open(RechargeConst.RechargeType.Tomb)
			else
				if cfg.effectType == 17 then --加buff
					local mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
					if mainPlayer and mainPlayer.buffManager and mainPlayer.buffManager:HasBuffGroup(cfg.effectValue) then
						UIMgr.Win_Confirm("温馨提示", "已有该类型buff，再次使用将会覆盖，确定使用？", "确定", "取消", function()
							PkgCtrl:GetInstance():C_UseItem(data.id, 1)
						end, nil)
					else
						PkgCtrl:GetInstance():C_UseItem(data.id, 1)
					end
				else
					if cfg.tinyType == GoodsVo.TinyType.hp or cfg.tinyType == GoodsVo.TinyType.mp then
						if self.mphpCD then UIMgr.Win_FloatTip("药品使用冷却中, 请稍后再使用!") return end
						PkgCtrl:GetInstance():C_UseItem(data.id, 1)
						self.mphpCD = true
						setupFuiOnceRender(self.ui, function ()
							self.mphpCD = false
						end, 6)
					elseif cfg.useType ~= 8 and cfg.useType ~= 9 then
						PkgCtrl:GetInstance():C_UseItem(data.id, 1)
					end
				end

				if cfg.useType == 8 then --打开翅膀
					local isActive = WingModel:GetInstance():IsActive(cfg.id)
					if not isActive then
						PkgCtrl:GetInstance():C_UseItem(data.id, 1)
						PlayerInfoController:GetInstance():Open(2)
					else
						local data1 = GetCfgData("wing"):Get(cfg.id)
						local itemId = data1.decomposeStr[1][2]
						local cfg1 = GoodsVo.GetItemCfg(itemId)
						local str = StringFormat("该翅膀已激活，使用将转化为{0}个{1}？", data1.decomposeStr[1][3], cfg1.name)
						UIMgr.Win_Confirm("温馨提示", str, "确定", "取消", function()
							PkgCtrl:GetInstance():C_UseItem(data.id, 1)
						end, nil)
					end
				elseif cfg.useType == 9 then --打开时装
					if StyleModel:GetInstance():IsActive(cfg.id) then
						UIMgr.Win_FloatTip("你已激活该时装，无法再次使用")
					else
						PkgCtrl:GetInstance():C_UseItem(data.id, 1)
						PlayerInfoController:GetInstance():Open(1)
					end
				end
			end
		end
		--MainUIModel:GetInstance():DispatchEvent(MainUIConst.E_QuickGoodsChange, {num = -1, vo = self.data})
	end
end

function QuickEquipCell:PutAndHide()
	PkgCtrl:GetInstance():C_PutOnEquipment(self.data:GetEquipId())
	MainUIModel:GetInstance():DispatchEvent(MainUIConst.E_QuickEquipDelete, self.data:GetEquipType())
end

function QuickEquipCell:OnCloseClick()
	if not self.isGoods then
		MainUIModel:GetInstance():DispatchEvent(MainUIConst.E_QuickEquipDelete, self.data:GetEquipType())
	else
		MainUIModel:GetInstance():DispatchEvent(MainUIConst.E_QuickGoodsChange, {num = -1, vo = self.data})
	end
end

function QuickEquipCell:SetData(data, isGoods)
	self.data = data
	self.isGoods = isGoods
	self:RefreshUI()
end

function QuickEquipCell:GetData()
	return self.data
end

function QuickEquipCell:RefreshUI()
	if not self.cell then
		local icon = PkgCell.New(self.ui)
		icon:SetXY(45, 30)
		icon:OpenTips(false)
		local data = nil
		if self.isGoods then
			self.btnEquip.title = "点击使用"
			local data = { self.data.goodsType, self.data.bid, 1, self.data.isBinding }
			icon:SetDataByCfg(data[1], data[2], data[3], data[4])
			icon:SetSelectCallback(function()
				local vo = self.data
				CustomTipLayer.Show(vo, true, nil)
			end)
		else
			self.btnEquip.title = "点击装备"
			local data = self.data:GetGoodsData()
			icon:SetDataByCfg(data[1], data[2], data[3], data[4])
			icon:SetSelectCallback(function()
				local vo = self.data:GetEquipInfo()
				CustomTipLayer.Show(vo:ToGoodsVo(), true, nil, vo)
			end)
		end
		self.cell = icon
	end
end

function QuickEquipCell:DestroyCell()
	if self.cell then
		self.cell:Destroy()
		self.cell = nil
	end
end