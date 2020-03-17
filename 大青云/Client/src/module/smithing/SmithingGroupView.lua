_G.UISmithingGroup = BaseUI:new("UISmithingGroup");
UISmithingGroup.curPos= 1 --默认选中第一个
UISmithingGroup.curSelect = 1 --默认选中第一个
UISmithingGroup.linkBtns = {};


function UISmithingGroup:Create()
	self:AddSWF("EquipGroupPanelV.swf", true, nil);
end

function UISmithingGroup:OnLoaded(objSwf)

	for i = 1, 10 do
		local loader = self.objSwf['equip'..i];
		if loader then
			loader.click = function(e) self:OnEquipItemClick(i); end
			-- loader.rollOver = function() self:OnEquipItemOver(i) end
			-- loader.rollOut = function() TipsManager:Hide() end
		end
	end
	self.slot = {}
	for i = 1, 11 do
		table.push(self.slot, self.objSwf['txt_pro' ..i])
	end
end

function UISmithingGroup:OnShow()
	self:RefreshEquips();
	self:RefreshSelecte()
	self:RefreshGroupInfo()
	self:RefreshFightInfo()
end

function UISmithingGroup:OnEquipItemClick(pos)
	if self.curPos == pos then
		return
	end
	self.curPos = pos
	self.curSelect = 1
	self:RefreshSelecte()
end

function UISmithingGroup:RefreshEquips()
	local objSwf = self.objSwf
	if not objSwf then return end

	for i = 1, 10 do
		local loader = self.objSwf['equip'..i];
		if loader then
			if self.curPos == i then
				loader.selected = true
			end

			local icon = ResUtil:GetSmithingIcon(t_equipgem[i].icon)
			if loader.icon.source ~= icon then
				loader.icon.source = icon
			end
			loader.txt_level.text = 3 - EquipUtil:GetEquipGroupLockNum(i)
		end
	end
end

function UISmithingGroup:RefreshSelecte()
	local objSwf = self.objSwf
	if not objSwf then return end

	local icon = ResUtil:GetGemIcon(self.curPos)
	if objSwf.equipIcon.source ~= icon then
		objSwf.equipIcon.source = icon
	end
	objSwf.txt_lock.htmlText = StrConfig['smithinggroup1'] ..EquipUtil:GetEquipGroupLockNum(self.curPos)

	local info = SmithingModel:GetEquipGroupInfo(self.curPos)
	local cfg = t_equipgroupextra[self.curPos]
	local groupId = split(cfg.groupId, ",")
	for i = 1, 3 do
		local UI = objSwf["pos" ..i]
		UI.mcForbidden._visible = false
		local icon = ResUtil:GetGroupIcon(t_equipgroup[toint(groupId[i])].image)
		if UI.icon.source ~= icon then
			UI.icon.source = icon
		end
		UI.icon._visible = true
		if self.curSelect == i then
			UI.selected = true
		end
		UI.click = function()
			if self.curSelect ~= i then
				self.curSelect = i
			end
			self.curSelect = i
			self:RefreshCost()
		end
		UI.rollOver = function() self:OnSlotRollOver(groupId[i], i, self.curPos) end
		UI.rollOut = function() TipsManager:Hide() end
		if not info[i] or info[i] == -2 then
			--未激活
			UI.mcForbidden._visible = true
			UI.icon._visible = false
			objSwf["txt_level" ..i].htmlText = StrConfig["smithinggroup2"]

			UI.rollOver = function() end
			UI.rollOut = function() TipsManager:Hide() end
		elseif info[i] == -1 then
			objSwf["txt_level" ..i].htmlText = StrConfig["smithinggroup3"]
		else
			objSwf["txt_level" ..i].htmlText = "Lv." .. info[i]
		end
	end
	self:RefreshCost()
end

function UISmithingGroup:OnSlotRollOver(groupId, slot, pos)
	local vo = {}
	vo.id = toint(groupId)
	if pos then
		vo.pos = pos
		vo.lv = EquipUtil:GetEquipGroupByPos(pos, slot)
	end
	vo.group = EquipUtil:GetGroupInfo(vo.id)
	TipsManager:ShowTips(TipsConsts.Type_NewEquipGroup,vo,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown)
end

function UISmithingGroup:RefreshCost()
	local objSwf = self.objSwf
	if not objSwf then return end

	local cfg, nLevel = EquipUtil:GetEquipGroupCfg(self.curPos, self.curSelect)
	local nextCfg = EquipUtil:GetEquipNextGroupCfg(self.curPos, self.curSelect)

	objSwf.btnLvUp.visible = true
	objSwf.costtips._visible = true
	objSwf.costLabel._visible = true
	objSwf.txt_max._visible = false
	local cost
	if nLevel == -2 then
		objSwf.btnLvUp.htmlLabel = StrConfig['smithinggroup4']
		cost = split(cfg.unlock, ',')
	elseif nLevel == -1 then
		objSwf.btnLvUp.htmlLabel = StrConfig['smithinggroup5']
		cost = split(cfg.activate, ',')
	elseif not nextCfg then
		-- 满级了
		objSwf.btnLvUp.visible = false
		objSwf.costtips._visible = false
		objSwf.costLabel._visible = false
		objSwf.txt_max._visible = true
	else
		cost = split(nextCfg.item, ',')
		objSwf.btnLvUp.htmlLabel = StrConfig['smithinggroup6']
	end
	if cost then
		local count = BagModel:GetItemNumInBag(toint(cost[1]))
		local color = count < toint(cost[2]) and "#FF0000" or "#00FF00";
		objSwf.costLabel.htmlLabel = string.format("<font color='%s'>%s:%s/%s</font>", color, t_item[toint(cost[1])].name, count, cost[2])
		objSwf.costLabel.rollOver = function(e) TipsManager:ShowItemTips(toint(cost[1])) end
		objSwf.costLabel.rollOut = function(e) TipsManager:Hide() end
		objSwf.btnLvUp.click = function()
			if count < toint(cost[2]) then
				FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
				UIQuickBuyConfirm:Open(self,toint(cost[1]))
				return
			end
			local extraCfg = t_equipgroupextra[self.curPos]
			local equipGroupID = split(extraCfg.groupId, ",")
			local groupId = toint(equipGroupID[self.curSelect])
			if nLevel == -2 then
				SmithingController:AskActiveEquipGroup(self.curPos, self.curSelect - 1, groupId)
			elseif nLevel == -1 then
				SmithingController:AskOpenEquipGroup(self.curPos, self.curSelect - 1, groupId)
			else
				SmithingController:AskUpLvEquipGroup(self.curPos, self.curSelect - 1, groupId)
			end
		end
	end
end

function UISmithingGroup:RefreshGroupInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.group1.htmlText = '(' .. EquipUtil:GetGroupActiveNumByType(1) ..StrConfig['smithinggroup7']
	objSwf.group2.htmlText = '(' .. EquipUtil:GetGroupActiveNumByType(2) ..StrConfig['smithinggroup8']
	for i = 1, 2 do
		local groupId = EquipUtil:GetGroupIDByType(i)
		for k, v in pairs(groupId) do
			local UI = objSwf["equipgroup" ..(3 *(i - 1) + k)]
			if UI.group.icon.source ~= ResUtil:GetGroupIcon(t_equipgroup[toint(v)].image) then
				UI.group.icon.source = ResUtil:GetGroupIcon(t_equipgroup[toint(v)].image)
			end

			UI.groupNum.htmlText = #EquipUtil:getEquipGroupActiveInfo(toint(v)) .. "/" .. (i == 1 and 6 or 4)
			if EquipUtil:getGroupIsHaveActive(toint(v)) then
				UI.group.mcForbidden._visible = false
				UI.group.icon._visible = true
				UI.group.rollOver = function() self:OnSlotRollOver(groupId[i]) end
				UI.group.rollOut = function() TipsManager:Hide() end
			else
				UI.group.rollOver = function() end
				UI.group.mcForbidden._visible = true
				UI.group.icon._visible = false
			end

			local skillid = EquipUtil:GetGroupSkillId(toint(v))

			for j = 1, 2 do
				if UI['skill'..j].icon.source ~= ResUtil:GetSkillIconUrl(t_passiveskill[skillid[j]].icon) then
					UI['skill'..j].icon.source = ResUtil:GetSkillIconUrl(t_passiveskill[skillid[j]].icon)
				end

				if EquipUtil:GroupIsHaveActiveSkill(toint(v), j) then
					UI['skill'..j].rollOver = function() TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillid[j]},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp) end
					UI['skill'..j].rollOut = function() TipsManager:Hide() end
					UI['skill'..j].mcForbidden._visible = false
				else
					UI['skill'..j].rollOver = function() end
					UI['skill'..j].mcForbidden._visible = true
				end
			end
		end
	end
end

function UISmithingGroup:RefreshFightInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	local pro = EquipUtil:getEquipGroupAllPro()

	PublicUtil:ShowProInfoForUI(pro, self.slot, nil, nil, nil, true)

	objSwf.fightLoader.num = PublicUtil:GetFigthValue(pro)
end

function UISmithingGroup:OnHide()
	self.curPos = 1;
	self.curSelect = 1
end

function UISmithingGroup:HandleNotification(name,body)
	if name == NotifyConsts.EquipGroupOpenSlot then
		self:RefreshEquips()
		self:RefreshSelecte()
	elseif name == NotifyConsts.EquipGroupActive then
		self:RefreshSelecte()
	elseif name == NotifyConsts.EquipGroupUpdate then
		self:RefreshSelecte()
		self:RefreshGroupInfo()
		self:RefreshFightInfo()
	else
		self:RefreshCost()
	end
end

function UISmithingGroup:ListNotificationInterests()
	return {	
				NotifyConsts.EquipGroupOpenSlot,
				NotifyConsts.EquipGroupActive,
				NotifyConsts.EquipGroupUpdate,
				NotifyConsts.BagAdd,
				NotifyConsts.BagRemove,
				NotifyConsts.BagUpdate,
			}
end