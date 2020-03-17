_G.UIRelicView = BaseUI:new("UIRelicView");

function UIRelicView:Create()
	self:AddSWF("relicView.swf",true,"center");
end

function UIRelicView:OnLoaded(objSwf)
	objSwf.btn_close.click = function(e) self:Hide() end
	objSwf.btnLevel.click = function() self:AskStarUp() end

	objSwf.selecetItem.iconEquip.rollOver = function() self:OnSelectOver(); end
	objSwf.selecetItem.iconEquip.rollOut = function() TipsManager:Hide(); end
end

function UIRelicView:OnSelectOver()
	if not self.currSelect then
		return;
	end
	TipsManager:ShowBagTips(self.currSelect:GetBagType(), self.currSelect.pos);
end

function UIRelicView:OnShow()
	self:RefreshSelect();
	self:ShowRelicInfo()
end

function UIRelicView:AskStarUp()
	if not self.currSelect then
		return
	end
	local relicID = self.currSelect:GetParam()
	if not relicID then
		relicID = BagUtil:GetRelicId(self.currSelect:GetTid())
		if not relicID then self:Hide() return end
	end
	local nextCfg = t_newequip[relicID + 1]
	if not nextCfg then return end
	if nextCfg.astrict > MainPlayerModel.humanDetailInfo.eaLevel then
		FloatManager:AddNormal("角色等级不足！")
		return
	end
	if MainPlayerModel.humanDetailInfo.eaBindGold < nextCfg.num then
		FloatManager:AddNormal("银两不足")
		return
	end
	RelicController:SendRelicLvUp(self.currSelect:GetId(), self.currSelect:GetBagType())
end

function UIRelicView:RefreshSelect()
	self.objSwf.txt_name.htmlText = string.format("<font color ='%s'>%s</font>", TipsConsts:GetItemQualityColor(t_item[self.currSelect:GetTid()].quality), t_item[self.currSelect:GetTid()].name)
	self.objSwf.txt_desc.htmlText = "温馨提示：更换" .. StrConfig["role" ..(t_newequip[self.currSelect:GetParam()].part + 244)] .."不会影响精炼等级！"
	self.objSwf.selecetItem.iconEquip:setData(self:getSelectVo())
end

function UIRelicView:getSelectVo()
	local config = t_item[self.currSelect:GetTid()]
	local data = {}
	data.id = config.id;
	data.count = self.currSelect:GetCount();
	data.showCount = "";
	data.iconUrl = ResUtil:GetItemIconUrl(config.icon);
	data.bigIconUrl = ResUtil:GetItemIconUrl(config.icon,54);
	data.iconUrl64 = ResUtil:GetItemIconUrl(config.icon,64);
	data.bind = self.currSelect:GetBindState();
	data.showBind = data.bind==BagConsts.Bind_GetBind or data.bind==BagConsts.Bind_Bind
	data.qualityUrl = ResUtil:GetSlotQuality(config.quality);
	data.bigQualityUrl = ResUtil:GetSlotQuality(config.quality, 54)
	data.qualityUrl64 = ResUtil:GetSlotQuality(config.quality, 64)
	data.quality = config.quality
	data.isBlack = false;
	data.super = 0;
	data.biaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying)
	data.bigBiaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying, 54)
	data.biaoshiUrl64 = ResUtil:GetBiaoShiUrl(config.identifying, 64)
	data.strenLvl = t_newequip[self.currSelect:GetParam()].lv
	return UIData.encode(data)
end

function UIRelicView:ShowRelicInfo()
	if not self.currSelect then
		self:Hide()
		return
	end
	local relicID = self.currSelect:GetParam()
	if not relicID then
		relicID = BagUtil:GetRelicId(self.currSelect:GetTid())
		if not relicID then self:Hide() return end
	end
	local cfg = t_newequip[relicID]
	self:ShowAttr(self.objSwf.label1, cfg)
	local nextCfg = t_newequip[relicID + 1]
	if nextCfg then
		self:ShowAttr(self.objSwf.label2, nextCfg)
		self.objSwf.txt_max._visible = false
		self.objSwf.label2._visible = true
		local color = "#00ff00"
		local bCanUp = true
		if nextCfg.astrict > MainPlayerModel.humanDetailInfo.eaLevel then
			color = "#FF0000"
			bCanUp = false
		end
		self.objSwf.txt_lv.htmlText = "角色等级达到" .. string.format("<font color='%s'>%s</font>", color, nextCfg.astrict) .. "级" --"强化限制：" .. nextCfg.astrict
		color = "#00ff00"
		if MainPlayerModel.humanDetailInfo.eaBindGold < nextCfg.num then
			color = "#FF0000"
			bCanUp = false
		end
		self.objSwf.txt_cost.htmlText = "精炼消耗：" .. string.format("<font color='%s'>%s</font>", color, getNumShow(nextCfg.num)) .."银两"
		if bCanUp then
			self.objSwf.btnLevel:showEffect(ResUtil:GetButtonEffect10())
		else
			self.objSwf.btnLevel:clearEffect()
		end
		self.objSwf.btnLevel._visible = true
	else
		self.objSwf.txt_lv.htmlText = ""
		self.objSwf.txt_cost.htmlText = ""
		self.objSwf.btnLevel._visible = false
		self.objSwf.txt_max._visible = true
		self.objSwf.label2._visible = false
	end
end

function UIRelicView:ShowAttr(UI, cfg)
	if not UI then
		return
	end
	UI.txt_lv.text = "Lv：" .. cfg.lv
	local slot = {}
	for i = 1, 6 do
		table.push(slot, UI["txt_pro" ..i])
	end
	PublicUtil:ShowProInfoForUI(AttrParseUtil:Parse(cfg.att), slot, nil, nil, nil, nil,"#d5d0c2","#00ff00")
	local fight = PublicUtil:GetFigthValue(AttrParseUtil:Parse(cfg.att))
	UI.fightcur.fightLoader.num = fight
	UI.fightcur.fightLoader._x = toint(63 - 10* string.len(tostring(fight))/2)
end

function UIRelicView:OpenView(currSelect)
	if not currSelect then
		return
	end
	self.currSelect = currSelect
	if not self:IsShow() then
		self:Show()
	else
		self:OnShow()
	end
end

function UIRelicView:ListNotificationInterests()
	return {
		NotifyConsts.RelicUpdata,
		NotifyConsts.PlayerAttrChange,
	}
end

function UIRelicView:HandleNotification(name, body)
	self:ShowRelicInfo()
end