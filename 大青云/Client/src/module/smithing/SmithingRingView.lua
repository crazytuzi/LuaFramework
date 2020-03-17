_G.UISmithingRing = BaseUI:new("UISmithingRing");

local s_Pro = {}
local s_maxPro = 0
local s_Skill = {}
local s_maxSkill = 0

UISmithingRing.baseSlot = {}
UISmithingRing.WashSlot = {}
UISmithingRing.GemSlot = {}

function UISmithingRing:Create()
	self:AddSWF("smithingRingPanelV.swf",true,nil);
end

function UISmithingRing:OnLoaded(objSwf)
	self.baseSlot = {}
	self.WashSlot = {}
	self.GemSlot = {}
	table.push(self.baseSlot, objSwf.base_pro)
	for i = 1, 5 do
		if objSwf["wash_pro" .. i] then
			table.push(self.WashSlot, objSwf["wash_pro" .. i])
		end
		if objSwf["gem_pro" .. i] then
			table.push(self.GemSlot, objSwf["gem_pro" .. i])
		end
	end
	self:InitProAndSkillActiveInfo()
	objSwf.tipsBtn.rollOver = function()
		local RingCid = SmithingModel:GetRingCid()
		local ring = BagModel:GetEquipByUid(RingCid)
		TipsManager:ShowBagTips(ring:GetBagType(), ring.pos)
	end
	objSwf.tipsBtn.rollOut = function() TipsManager:Hide() end

	objSwf.btnLvUp.rollOver = function()
		if self.haveNext then 
			objSwf.addFight._visible = true
		end
	end

	objSwf.btnLvUp.rollOut = function() 
		objSwf.addFight._visible = false
	end

end

function UISmithingRing:InitProAndSkillActiveInfo()
	for k, v in ipairs(t_ring) do
		local pro = split(v.attr, "#")
		local skill = split(v.skill, ",")
		if not s_Pro[#pro] then
			s_Pro[#pro] = v.lv
		end
		if not s_Skill[#skill] then
			s_Skill[#skill] = v.lv
		end
		if k == #t_ring then
			s_maxPro = #pro
			s_maxSkill = #skill
		end
	end
end

function UISmithingRing:GetMaxValueInfo()
	if s_maxPro == 0 then
		self:InitProAndSkillActiveInfo()
	end
	return s_maxPro, s_Pro, s_maxSkill, s_Skill
end

function UISmithingRing:OnShow()
	self:ShowRingInfo()
	self:ShowRingGradeInfo()
	self:ShowRingCostInfo()
	self:DrawScene()
end

function UISmithingRing:AskGradeUP()
	SmithingController:AskRingUpGrade(SmithingModel:GetRingCid())
end

function UISmithingRing:ShowRingInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local RingCid = SmithingModel:GetRingCid()
	local ring = BagModel:GetEquipByUid(RingCid)
	local lv = SmithingModel:GetRingLv()
	local itemTipsVO = ItemTipsVO:new()
	itemTipsVO.tipsType = TipsConsts.Type_Equip
	ItemTipsUtil:CopyItemDataToTipsVO(ring, itemTipsVO)

	-- EquipTips:Parse(itemTipsVO);
	local fightValue = itemTipsVO:GetTotalFight()
	objSwf.fightLoader.num = fightValue
	local itemid = ring:GetTid()
	-- local basePro = itemTipsVO:GetEquipBaseAttr()
	-- PublicUtil:ShowProInfoForUI(basePro, self.baseSlot)
	-- local washPro = itemTipsVO:GetEquipWashAttr()
	-- PublicUtil:ShowProInfoForUI(washPro, self.WashSlot)
	-- local gemPro = itemTipsVO:GetEquipGemAttr()
	-- PublicUtil:ShowProInfoForUI(gemPro, self.GemSlot)

	--todo 这里还需要处理下左戒自己的属性战斗力添加 应该是设置下TIPS里面的等级就可以了
	local nextCfg = t_ring[lv + 1]
	if nextCfg and nextCfg.tid ~= itemid then
		-- ring:SetTid(nextCfg.tid)
		ItemTipsUtil:CopyItemDataToTipsVO(ring, itemTipsVO)
		itemTipsVO.id = nextCfg.tid
		itemTipsVO.baseAttrList = nil
		itemTipsVO.ring = lv + 1
		itemTipsVO.ringAttrList = nil

		objSwf.addFight.txt.text = itemTipsVO:GetTotalFight() - fightValue
		self.haveNext = true
	elseif nextCfg then
		itemTipsVO.ring = lv + 1
		itemTipsVO.ringAttrList = nil
		objSwf.addFight.txt.text = itemTipsVO:GetTotalFight() - fightValue
		self.haveNext = true
	else
		self.haveNext = false
	end
	objSwf.addFight._visible = false

	local value = 0
	if lv%10 == 0 then
		objSwf.lvIcon1.visible = false
		if lv > 10 then
			if objSwf.lvIcon2.source ~= ResUtil:GetRingIcon("v_ring_" .. math.floor(lv/10)) then
				objSwf.lvIcon2.source = ResUtil:GetRingIcon("v_ring_" .. math.floor(lv/10))
			end
			objSwf.lvIcon2.visible = true
			value = 2
		else
			value = 1
			objSwf.lvIcon2.visible = false
		end
		if objSwf.lvIcon3.source ~= ResUtil:GetRingIcon("v_ring_10") then
			objSwf.lvIcon3.source = ResUtil:GetRingIcon("v_ring_10")
		end
	else
		if lv > 20 then
			objSwf.lvIcon1.visible = true
			if objSwf.lvIcon1.source ~= ResUtil:GetRingIcon("v_ring_" .. math.floor(lv/10)) then
				objSwf.lvIcon1.source = ResUtil:GetRingIcon("v_ring_" .. math.floor(lv/10))
			end
			value = 3
		else
			objSwf.lvIcon1.visible = false
			value = 2
		end
		if lv > 10 then
			objSwf.lvIcon2.visible = true
			if objSwf.lvIcon2.source ~= ResUtil:GetRingIcon("v_ring_10") then
				objSwf.lvIcon2.source = ResUtil:GetRingIcon("v_ring_10")
			end
			if objSwf.lvIcon3.source ~= ResUtil:GetRingIcon("v_ring_" .. (lv%10)) then
				objSwf.lvIcon3.source = ResUtil:GetRingIcon("v_ring_" .. (lv%10))
			end
		else
			objSwf.lvIcon2.visible = false
			if objSwf.lvIcon3.source ~= ResUtil:GetRingIcon("v_ring_" .. lv) then
				objSwf.lvIcon3.source = ResUtil:GetRingIcon("v_ring_" .. lv)
			end
			value = 1
		end
	end
	for i = 1, 5 do
		objSwf['lvIcon' .. i]._x = SmithingConsts.namePosX[value][i]
	end
end

function UISmithingRing:ShowRingGradeInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local lv = SmithingModel:GetRingLv()
	local cfg = t_ring[lv]
	objSwf.txt_curpro.htmlText = self:GetRingPro(cfg)
	local nextCfg = t_ring[lv + 1]
	if not nextCfg then
		objSwf.txt_nextpro.htmlText = ""
		objSwf.nextLabel._visible = false
		return
	end
	objSwf.txt_nextpro.htmlText = self:GetRingPro(nextCfg)
end

local nameColor = '#d68637'
local valueColor = '#ffffff'
local s_proStr = "<font color = '%s'>%s：  </font><font color = '%s'>%s</font>"
local s_Str = "<font color = '%s'>%s</font>"
function UISmithingRing:GetRingPro(cfg)
	local pro = AttrParseUtil:Parse(cfg.attr)
	local skill = split(cfg.skill, ",")
	local str = "<br>"
	for k, v in pairs(pro) do
		str = str .. string.format(s_proStr, nameColor, PublicAttrConfig.proSpaceName[v.name], valueColor, v.val) .. "<br>" .. "<br>"
	end
	for i = #pro + 1, s_maxPro do
		str = str .. string.format(s_Str, valueColor, string.format(StrConfig['ring1001'], s_Pro[i])) .. "<br>" .. "<br>" -- str .. "此条属性" .. s_Pro[i] .. "级开启" .. "<br>"
	end

	for k, v in pairs(skill) do
		local cfg = t_passiveskill[toint(v)]
		str = str .."<textformat leading='10'><p>";
		str = str .. string.format(s_Str, nameColor, cfg.name .. "：")
		str = str .. cfg.effectStr .. "<br>"
		str = str .. "</p></textformat>";
	end
	for i = #skill + 1, s_maxSkill do
		str = str .. string.format(s_Str, valueColor, string.format(StrConfig['ring1002'], s_Skill[i])) .. "<br>" .. "<br>"
	end
	return str
end

function UISmithingRing:ShowRingCostInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	local lv = SmithingModel:GetRingLv()
	local cfg = t_ring[lv]
	if not t_ring[lv + 1] then
		objSwf.costLabel._visible = false
		objSwf.icon_xing._visible = false
		objSwf.costLabelRingCost._visible = false
		objSwf.btnLvUp.visible = false
		objSwf.maxLv._visible = true
		objSwf.line._visible = false
		return
	end
	objSwf.line._visible = true
	objSwf.maxLv._visible = false
	objSwf.btnLvUp.click = function() self:AskGradeUP() end
	if MainPlayerModel.humanDetailInfo.eaLevel < cfg.needlv then
		objSwf.costLabel.htmlLabel = StrConfig["ring1003"] .. string.format(s_Str, "00FF00", cfg.needlv .. StrConfig['gem25']) ..StrConfig['ring1009']
		objSwf.btnLvUp.click = function() FloatManager:AddNormal(StrConfig["ring1004"]) end
	else
		objSwf.costLabel.htmlLabel = StrConfig["ring1003"] .. string.format(s_Str, "00FF00", cfg.needlv .. StrConfig['gem25']) ..StrConfig['ring1010']
	end
	self.monster = false
	if not cfg.consume or cfg.consume == "" then
		--升级
		objSwf.btnLvUp.htmlLabel = StrConfig['ring1005']

		local monsterInfo = split(cfg.killmonster, ",")
		if SmithingModel:GetRingTaskNum() < toint(monsterInfo[2]) then
			objSwf.costLabelRingCost.htmlLabel = StrConfig['ring1006'] .. "<u>" .. string.format(s_Str, "#00FF00", t_monster[toint(monsterInfo[1])].name) .. "</u>" .. string.format(s_Str, "#00FF00", SmithingModel:GetRingTaskNum() .. "/" .. monsterInfo[2]) ..StrConfig['ring1009']
			objSwf.btnLvUp.click = function() FloatManager:AddNormal(StrConfig['ring1007']) end
		else
			objSwf.costLabelRingCost.htmlLabel = StrConfig['ring1006'] .. "<u>" .. string.format(s_Str, "#00FF00", t_monster[toint(monsterInfo[1])].name)  .. "</u>" .. string.format(s_Str, "#00FF00", monsterInfo[2] .. "/" .. monsterInfo[2]) ..StrConfig['ring1010']
		end
		objSwf.costLabelRingCost.rollOver = function() TipsManager:ShowBtnTips(cfg.position,TipsConsts.Dir_RightDown) end
		objSwf.costLabelRingCost.rollOut = function() TipsManager:Hide() end
		self.monster = true
	else
		--升级
		objSwf.btnLvUp.htmlLabel = StrConfig['ring1005']
		local cost = split(cfg.consume, ",")
		local has = BagModel:GetItemNumInBag(toint(cost[1]));
		if has < toint(cost[2]) then
			objSwf.btnLvUp.click = function() FloatManager:AddNormal(StrConfig['ring1008']) end
			objSwf.costLabelRingCost.htmlLabel = "<u>" .. t_item[toint(cost[1])].name  .. "</u>" .. has .. "/" .. cost[2] ..StrConfig['ring1009']
		else
			objSwf.costLabelRingCost.htmlLabel = "<u>" .. t_item[toint(cost[1])].name  .. "</u>" .. has .. "/" .. cost[2] ..StrConfig['ring1010']
		end
		objSwf.costLabelRingCost.rollOver = function() TipsManager:ShowItemTips(toint(cost[1])) end
		objSwf.costLabelRingCost.rollOut = function() TipsManager:Hide() end
		objSwf.costLabelRingCost.stageClick = function() end
	end

end

function UISmithingRing:DrawScene()
	local objSwf = self.objSwf
	if not objSwf then return end

	local lv = SmithingModel:GetRingLv()
	local cfg = t_ring[lv]

	objSwf.lvIcon5.source = ResUtil:GetRingIcon(cfg.icon)
	if not self.objUIDraw then
		local viewPort = _Vector2.new(1020, 600)
		self.objUIDraw = UISceneDraw:new( "UISmithingRing", objSwf.loadScene, viewPort )
	end
	self.objUIDraw:SetUILoader(objSwf.loadScene)
	self.objUIDraw:SetScene(cfg.cj)
	self.objUIDraw:SetDraw(true)
end

function UISmithingRing:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil
	end
end

function UISmithingRing:HandleNotification(name,body)
	if name == NotifyConsts.StageClick then
		if string.find(body.target,"costLabelRingCost") then
			if self.monster then
				UIYaota:Show()
			end
		end
	elseif name == NotifyConsts.RingUpGrade then
		self:ShowRingInfo()
		self:ShowRingGradeInfo()
		self:ShowRingCostInfo()
		local lv = SmithingModel:GetRingLv()
		if t_ring[lv].step ~= t_ring[lv - 1].step then
			self:DrawScene()
		end
	else
		self:ShowRingCostInfo()
	end
end

function UISmithingRing:ListNotificationInterests()
	return {
		NotifyConsts.RingTaskUpdate,
		NotifyConsts.RingUpGrade,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.StageClick,
	}
end