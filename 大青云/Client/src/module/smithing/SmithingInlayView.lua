_G.UISmithingInlay = BaseUI:new("UISmithingInlay");
UISmithingInlay.currSelect = nil;


function UISmithingInlay:Create()
	self:AddSWF("smithingGemPanel.swf",true,nil);
end

function UISmithingInlay:OnLoaded(objSwf)

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["smithingRule2"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
	
	local count = SmithingModel:GetEquipCount();
	for i = 0,count do
		local loader = self.objSwf['equip'..i];
		if loader then
			loader.click = function(e) self:OnEquipItemClick(i); end
			loader.rollOver = function() self:OnEquipItemOver(i) end
			loader.rollOut = function() TipsManager:Hide() end
			loader.txt_proText.text = enAttrTypeName[AttrParseUtil:getType(SmithingModel:GetGemProTypeByHole(i, 1))]
		end
	end
	for i = 1, 5 do
		local item = objSwf.panel.itemPanel["gemitem" ..i]
		-- item.itemBtn.rollOver = function() self:OnGemOver(i) end
		-- item.itemBtn.rollOut = function() self:OnGemOut() end
		item.lvBtn.click = function() self:OnLvBtnClick(i) end
		item.lvBtn.rollOver = function() self.lvBtnRollNum = i self:ShowGemPro() end
		item.lvBtn.rollOut = function() self.lvBtnRollNum = 0 self:ShowGemPro() end
		item.tfNeedItem.rollOver = function(e) self:OnNeedItemOver(i) end
		item.tfNeedItem.rollOut = function(e) TipsManager:Hide() end
	end
	objSwf.itemGetBtn.htmlLabel = StrConfig['smithing031']
	objSwf.itemGetBtn.click = function() UIQuickBuyConfirm:Open(self, 150001001) end
end

local s_str = "<font color = '#ffffff'>%s</font>"
function UISmithingInlay:OnEquipItemOver(i)
	local equip = SmithingModel:GetEquipByPos(i)
	if not equip then return end
	local str = "            "
	str = str .. BaseTips:GetHtmlText(BagConsts:GetEquipName(i), "#e6b800", 18, false)
	str = str .. "<p><img height='".. 5 .."'/></p><p><img width='".. 210 .."' height='1' align='baseline' vspace='".. 
		8 .."' src='" .. ResUtil:GetTipsLineUrl() .."'/></p>"
	local typeStr = string.format("<font color = '#d68637'>%s</font>", enAttrTypeName[AttrParseUtil:getType(SmithingModel:GetGemProTypeByHole(i, 1))] .. "：")
	for i = 1, 5 do
		local gem = equip.gems[i]
		if i ~= 1 then
			str = str ..BaseTips:GetVGap(3)
		end
		local type = SmithingModel:GetGemProTypeByHole(self.currSelect.pos, i)
		if gem.used then
			local cfg = t_gemgroup[gem.id];
			str = str .. BaseTips:GetHtmlText(StrConfig['smithing' .. (300 + i)] .. StrConfig['gem22'] .. typeStr .. string.format(s_str, cfg.atr1), "#e6b800", 14, false)
		elseif gem.lvLimit > MainPlayerModel.humanDetailInfo.eaLevel then
			str = str .. BaseTips:GetHtmlText(StrConfig['smithing' .. (300 + i)] .. StrConfig['gem23'].. typeStr .. string.format(s_str, 0), "#e6b800", 14, false)
		else
			str = str .. BaseTips:GetHtmlText(StrConfig['smithing' .. (300 + i)] .. StrConfig['gem23'] ..typeStr .. string.format(s_str, 0), "#e6b800", 14, false)
		end
	end

	TipsManager:ShowBtnTips(str, TipsConsts.Dir_RightDown)
end

function UISmithingInlay:PlayUnInlayPfx(pos)
	if not self.objSwf then return end

	self.objSwf.panel.itemPanel["gemitem" ..pos].takeoutPfx:play()
end

function UISmithingInlay:PlayInlayPfx(pos)
	if not self.objSwf then return end

	self.objSwf.panel.itemPanel["gemitem" ..pos].opeatePfx:play()
	self.objSwf.panel.itemPanel.equipPfx4:play()
end

function UISmithingInlay:HandleNotification(name,body)
	if name == NotifyConsts.GemInlayInfoChange then
		self:RefreshEquips();
	elseif name == NotifyConsts.GemInlayResult then
		if body then
			if body.host == self.currSelect then
				self:RefreshEquips()
			end
		end
		SoundManager:PlaySfx(2008)
	elseif name == NotifyConsts.GemInlayUnResult then
		self:PlayUnInlayPfx(body[1])
		self:RefreshEquips()
	elseif name == NotifyConsts.GemInlayChangeResult then
		self:RefreshEquips();
	elseif name == NotifyConsts.GemInlayUpgradeResult then
		self:RefreshEquips()
		SoundManager:PlaySfx(2008)
	else
		self:RefreshEquips()
	end
	self:RefreshGemLink()
end

function UISmithingInlay:OnEquipItemClick(i)
	self:SelectEquip(i);
end

function UISmithingInlay:SelectEquip(pos)
	local equip = SmithingModel:GetEquipByPos(pos);
	if not equip then
		return;
	end
	self.currSelect = equip;
	self.objSwf.panel.itemPanel.equipIcon.source = ResUtil:GetGemIcon(pos)
	self:RefreshGems();
end

local btnPos = {x=0,y=0};--按钮的全局坐标
function UISmithingInlay:OnGemOver(i)
	
	local gem = SmithingModel:GetInEquipGem(self.currSelect.pos,i);
	if not gem then
		return;
	end
	if gem.used then
		TipsManager:ShowItemTips(t_gemgroup[gem.id].itemid)
	-- else
	-- 	local str = enAttrTypeName[AttrParseUtil:getType(SmithingModel:GetGemProTypeByHole(self.currSelect.pos, gem.pos))]
	-- 	TipsManager:ShowBtnTips(string.format(StrConfig['smithing204'], str), TipsConsts.Dir_RightUp)
	end
end

function UISmithingInlay:OnNeedItemOver(i)
	local gem = SmithingModel:GetInEquipGem(self.currSelect.pos,i);
	if not gem then
		return;
	end
	local cost = SmithingModel:GetGemCost(self.currSelect.pos, i, gem.level + 1)
	if cost then
		if BagModel:GetItemNumInBag(cost[1]) > 0 then
			TipsManager:ShowItemTips(cost[1])
		else
			TipsManager:ShowItemTips(cost[2])
		end
	end
end

function UISmithingInlay:OnLvBtnClick(i)
	local gem = SmithingModel:GetInEquipGem(self.currSelect.pos, i)
	if not gem then
		return
	end
	local cost = SmithingModel:GetGemCost(self.currSelect.pos, i, gem.level + 1)
	if gem.used then
		local bCan, bMax = SmithingModel:GemIsCanLvUp(self.currSelect.pos, i)
		if bMax then
			-- FloatManager:AddNormal(StrConfig['smithing209'])
			return
		end
		if self.objSwf.checkZiDong.selected then
			SmithingController:SendGemUpgrade(cost[4], self.currSelect.pos, i, 1, 0)
		else
			if not bCan then
				FloatManager:AddNormal(StrConfig['smithing208'])
				UIQuickBuyConfirm:Open(self,cost[2])
				return
			end
			SmithingController:SendGemUpgrade(cost[4], self.currSelect.pos, i, 1, 1)
		end
	else
		if SmithingModel:IsGemHoleLocked(gem) then
			return
		end
		if self.objSwf.checkZiDong.selected then
			SmithingController:SendReqGemInstall(self.currSelect.pos, i, cost[4], 0);
		else
			if not SmithingModel:GemIsCanActive(self.currSelect.pos, i) then
				FloatManager:AddNormal(StrConfig['smithing208'])
				UIQuickBuyConfirm:Open(self,cost[2])
				return
			end
			SmithingController:SendReqGemInstall(self.currSelect.pos, i, cost[4], 1);
		end
	end
end

function UISmithingInlay:OnGemOut()
	TipsManager:Hide()
end

function UISmithingInlay:ListNotificationInterests()
	return {	
				NotifyConsts.GemInlayInfoChange,
				NotifyConsts.GemInlayResult,
				NotifyConsts.GemInlayUnResult,
				NotifyConsts.GemInlayChangeResult,
				NotifyConsts.GemInlayUpgradeResult,
				NotifyConsts.BagAdd,
				NotifyConsts.BagRemove,
				NotifyConsts.BagUpdate,
			}
end

function UISmithingInlay:OnShow()
	self:RefreshEquips();
	self:RefreshGemLink();
end

function UISmithingInlay:RefreshEquips()
	local count = SmithingModel:GetEquipCount();
	for i = 0,count do
		local loader = self.objSwf['equip'..i];
		if loader then
			local equip = SmithingModel:GetEquipByPos(i);
			loader.zbw:gotoAndStop(i + 1)
			loader.txt_level.text = "" --SmithingModel:GetEquipGemLv(i)
			local nValue = SmithingModel:GetNoticeStr(i)
			loader.txt_tishi.text = ""
			loader.operateIcon._visible = nValue ~= 0
		end
	end
	
	if not self.currSelect then
		for i = 0, 10 do
			local equip = SmithingModel:GetEquipByPos(i)
			if not self.currSelect then
				self.currSelect = equip
			end
			if SmithingModel:GetNoticeStr(i) ~= 0 then
				self.currSelect = equip
				break
			end
		end
	end

	local fightValue = 0
	local pro = {}
	for i = 0, 10 do
		local equip = SmithingModel:GetEquipByPos(i)
		for k, v in pairs(equip.gems) do
			if v.used then
				local gemCfg = t_gemgroup[v.id];
				if gemCfg then
					local vo = {}
					vo.type = AttrParseUtil.AttMap[gemCfg.atr];
					vo.val = gemCfg.atr1;
					vo.name = gemCfg.atr
					fightValue = fightValue + PublicUtil:GetFigthValue({vo})
					pro = PublicUtil:GetFightListPlus(pro, {vo})
				end
			end
		end
	end
	local linkId = SmithingModel:GetGemLinkId()
	local linkCfg = t_gemlock[linkId]
	if linkCfg then
		local list = AttrParseUtil:Parse(linkCfg.atb)
		pro = PublicUtil:GetFightListPlus(pro, list)
		fightValue = fightValue + PublicUtil:GetFigthValue(list)
	end
	self.objSwf.fightLoader.num = fightValue
	self.objSwf.fightLoader._x = 820 - math.floor(string.len(tostring(fightValue))/2)*25
	local slot = {}
	for i = 1, 6 do
		table.insert(slot, self.objSwf["txt_pro" ..i].txt_pro)
	end
	PublicUtil:ShowProInfoForUI(pro, slot, nil, nil, nil, false,"#a97a42","#FFFFFF")
	self:SelectEquip(self.currSelect.pos);
end

function UISmithingInlay:RefreshGems()
	if not self.currSelect then
		return;
	end
	self.objSwf["equip"..self.currSelect.pos].selected = true
	local gems = self.currSelect.gems;
	local proType = enAttrTypeName[AttrParseUtil:getType(SmithingModel:GetGemProTypeByHole(self.currSelect.pos, 1))]
	local proValue = 0
	for i=1,#gems do
		local gem = gems[i];
		local item = self.objSwf.panel.itemPanel['gemitem' ..i]
		if item then
			local canIn = false
			local lvLimit = ""
			item.canAddPfx._visible = false
			self.objSwf['txt_curPro' ..i].htmlText = proType .. "：" .. string.format("<font color = '#ffffff'>%s<font>", 0)
			self.objSwf['txt_curLv' .. i].htmlText = gem.level .. "级"
			if gem.used then
				item.lvBtn.htmlLabel = "升级"
				local cfg = t_gemgroup[gem.id];
				proValue = proValue + cfg.atr1
				self.objSwf['txt_curPro' ..i].htmlText = proType .. "：" .. string.format("<font color = '#ffffff'>%s<font>", cfg.atr1)		
			elseif gem.lvLimit > MainPlayerModel.humanDetailInfo.eaLevel then
				if gem.lvLimit > 99 then
					lvLimit = gem.lvLimit .. "级"
				else
					lvLimit = gem.lvLimit .. "级"
				end
			else
				item.lvBtn.htmlLabel = "激活"
				canIn = true
				-- item.canAddPfx._visible = SmithingModel:GemIsCanActive(self.currSelect.pos, i)
			end
			local cost = SmithingModel:GetGemCost(self.currSelect.pos, i, gem.level + 1)
			if cost and gem.lvLimit <= MainPlayerModel.humanDetailInfo.eaLevel then
				local costStr
				if BagModel:GetItemNumInBag(cost[1]) > 0 then
					local color = TipsConsts:GetItemQualityColor(t_item[cost[1]].quality)
					costStr = string.format("<font color = '%s'><u>%s</u></font><font color = '#00ff00'> *1</font>", color, t_item[cost[1]].name)
				else
					local color = TipsConsts:GetItemQualityColor(t_item[cost[2]].quality)
					costStr = string.format("<font color = '%s'><u>%s</u></font><font color = '%s'> *%s</font>", color, t_item[cost[2]].name, BagModel:GetItemNumInBag(cost[2]) >= cost[3] and "#00ff00" or "#ff0000", cost[3])
				end
				item.tfNeedItem._visible = true;
				item.tfNeedItem.htmlLabel = costStr;
			else
				item.tfNeedItem._visible = false;
			end
			if gem.used then
				if item.iconLoader.source ~= gem.view.iconUrl then
					item.iconLoader.source = gem.view.iconUrl
				end
				item.iconGray._visible = false
				item.iconLight._visible = true
				item.activePfx._visible = true
			else
				if item.iconLoader.source ~= SmithingModel:GetGemIcon(self.currSelect.pos, i) then
					item.iconLoader.source = SmithingModel:GetGemIcon(self.currSelect.pos, i)
				end
				item.iconGray._visible = true
				item.iconLight._visible = false
				item.activePfx._visible = false
			end
			item.tfHint.text = gem.level .. "级"
			item.icon_in._visible = false --canIn;
			item.canChangePfx._visible = false --SmithingModel:GemIsCanLvUp(self.currSelect.pos, i)
			if SmithingModel:GemIsCanLvUp(self.currSelect.pos, i) then
				item.lvBtn:showEffect(ResUtil:GetButtonEffect9())
			else
				item.lvBtn:clearEffect()
			end
			if lvLimit ~= "" then
				item.lvBtn.htmlLabel = lvLimit .. "开启"
			elseif gem.level == 9 then
				item.lvBtn.htmlLabel = "暂满级"
			end
			item.numLv._visible = false;
			item.numLv.txt_level.text = ""
			item.tfName.text = "";
		end
	end
	self:ShowGemPro()
end

function UISmithingInlay:ShowGemPro()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.currSelect then
		return;
	end
	local proValue = 0
	local gems = self.currSelect.gems
	local proType = enAttrTypeName[AttrParseUtil:getType(SmithingModel:GetGemProTypeByHole(self.currSelect.pos, 1))]
	local addAtt = nil
	for i=1,#gems do
		local gem = gems[i];
		objSwf['txt_curPro' ..i].htmlText = proType .. "：" .. string.format("<font color = '#ffffff'>%s<font>", 0)
		if self.lvBtnRollNum == i and gem.level ~= 9 then
			objSwf['txt_curLv' .. i].htmlText = (gem.level + 1) .. "级" .. "<font color = '#ffffff'>[预览]<font>"
			local pro = SmithingModel:GetGemAtt(self.currSelect.pos, i, gem.level + 1)
			objSwf['txt_curPro' ..i].htmlText = proType .. "：" .. string.format("<font color = '#ffffff'>%s<font>", pro.val)
			addAtt = {{type = AttrParseUtil:getType(pro.type), val = pro.val - (gem.used and t_gemgroup[gem.id].atr1 or 0)}}
			proValue = proValue + (gem.used and t_gemgroup[gem.id].atr1 or 0)
		else
			objSwf['txt_curLv' .. i].htmlText = gem.level .. "级"
			if gem.used then
				local cfg = t_gemgroup[gem.id];
				proValue = proValue + cfg.atr1
				objSwf['txt_curPro' ..i].htmlText = proType .. "：" .. string.format("<font color = '#ffffff'>%s<font>", cfg.atr1)
			else
				objSwf['txt_curPro' ..i].htmlText = proType .. "：" .. string.format("<font color = '#ffffff'>%s<font>", 0)
			end
		end
	end
	objSwf.txt_curProAll.htmlText = proType .. "：" .. string.format("<font color = '#ffffff'>%s<font>", proValue) 
	objSwf.txt_myGem.htmlText = string.format(StrConfig['smithing310'], BagModel:GetItemNumInBag(150001001))
	if addAtt then
		objSwf.txt_addPro.text = "+" .. PublicUtil:GetFigthValue(addAtt)
	else
		objSwf.txt_addPro.text = ""
	end
end

function UISmithingInlay:RefreshGemLink()
	local bOpen = false
	local linkId = SmithingModel:GetGemLinkId();
	if self.currLinkId and self.currLinkId < linkId then
		bOpen = true
	end
	self.currLinkId = linkId; 

	for i = 1, 6 do
		local button = self.objSwf["linkBtn" ..i]
		if button then
			button._visible = false
		end
		self.objSwf['linkPfx' ..i]._visible = false
	end
	for i,config in ipairs(t_gemlock) do
		if self.currLinkId == config.id then
			self:ShowStrenLinkBtn(i,true, bOpen);
		elseif self.currLinkId >= config.id then 
			self:ShowStrenLinkBtn(i,true);
		else
			self:ShowStrenLinkBtn(i,false);
			break
		end
	end
end

function UISmithingInlay:ShowStrenLinkBtn(index,active, bOpen)

	local objSwf = self.objSwf;
	if not objSwf then return; end
	local button = objSwf["linkBtn" ..index]
	if not button then
		return;
	end

	button.alwaysRollEvent = true;
	button._visible = true
	button.disabled = not active;
	objSwf['linkPfx' ..index]._visible = active
	if bOpen then
		objSwf['linkPfx' ..index].lightPfx:play()
	end
	button.rollOut = function() TipsManager:Hide(); end
	button.rollOver = function() self:OnStrenLinkRollOver(index,button); end
end

function UISmithingInlay:OnStrenLinkRollOver(index,button)
	local num = 0;
	local config = t_gemlock[index];
	if not config then return; end

	local tipsVO = {};
	tipsVO.activeNum = SmithingModel:GetAllEquipGemLv();
	tipsVO.linkId = index;
	TipsManager:ShowTips(TipsConsts.Type_GemLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UISmithingInlay:OnHide()
	self.currSelect = nil;
end

function UISmithingInlay:OnRulesClick()
	
end
