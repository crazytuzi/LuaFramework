GodFightRunePanel = BaseClass(CommonBackGround)

function GodFightRunePanel:__init( ... )
	self.ui = UIPackage.CreateObject("GodFightRune","GodFightRunePanel")
	self.id = "GodFightRunePanel"
	self.useFade = false
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = { 1 , 2}
	self:SetTitle("斗神印")
	self.tabBar = {
		{label="", res0="dsy01", res1="dsy00", id="0", red=false }
	}
	self.defaultTabIndex = 0
end

function GodFightRunePanel:InitEvent()
	--这里注册各种一次性创建事件
	self.closeCallback = function ()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
	self.openCallback  = function () 
		self:Update()
		--打开斗神印界面，取消斗神印红点
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.godFightRune , state = false})
	end
	
	self.eventHandler0 =  self.model:AddEventListener(GodFightRuneConst.OnTypeSelect , function (typeData)
		self:HandleOnTypeSelect(typeData)
	end)
	self.eventHandler1 = self.model:AddEventListener(GodFightRuneConst.SelectRuneItem , function (cellData)
		self:HandleSelectRuneItem(cellData)
	end)
	self.eventHandler2=GlobalDispatcher:AddEventListener(EventName.RefershGodFightRune, function ()
		self:HandleRefershGodFightRune()
	end)
	self.eventHandler3=GlobalDispatcher:AddEventListener(EventName.RefershWeaponInscription, function ()
		self:HandleRefershWeaponInscription()
	end)
	self.eventHandler4= self.model:AddEventListener(GodFightRuneConst.EquipmentChange , function ()
		self:HanlderWeaponChange()
	end)
	self.eventHandler5 = self.model:AddEventListener(GodFightRuneConst.EpigraphSucc , function (holeIndex)
		self:HanldeEpigraphSucc(holeIndex)
	end)

	for index = 1 , #self.godFightRuneItems do
		self.godFightRuneItems[index].ui.onClick:Add(function ()
			self:OnGodFightRuneItemClick(index , isDefault)
		end)
	end

	self.btnUse.onClick:Add(self.OnBtnUseClick , self)
	self.tipsBtn.onClick:Add(self.OnBtnTipsClick ,self)

	for index = 1 , #self.godFightRuneItems do
		self:PressUpShowGodFightRuneItemTips(index , 1)
	end

end
-- 布局UI
function GodFightRunePanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- Dispose use GodFightRunePanel obj:Destroy()
function GodFightRunePanel:__delete()
	self:CleanEvent()
	self:CleanEffect()
	self:CleanUI()
end

function GodFightRunePanel:Update()
	self:UpdateData()
	self:UpdateUI()
end

function GodFightRunePanel:InitData()
	self.model = GodFightRuneModel:GetInstance()

	self.godFightRuneType = GodFightRuneConst.GodFightRuneType.All --默认选中全部类型的斗神印材料
	self.godFightRuneItems = {} --3个铭文槽位
	self.weaponCellItem = {} --主武器Cell

	self.weaponData = {} --玩家身上主武器数据（equipInfo 的实例）
	self.inscriptionData = {} --各个槽位上的斗神印效果数据
	self.godFightRuneData = {} --背包中的斗神印材料数据
	self.curSelectedRuneInstanceId = -1 --当前选中的斗神印记材料
	self.curSelectedSlotIndex = -1 --当前选中的铭文槽位
	self.effectObj = nil

	self.defaultRuneTabType = GodFightRuneConst.GodFightRuneType.All
	self.lastRuneTabType = self.defaultRuneTabType
	self.defaultSelectItemIndex = 1 --某人选中该页签第一个格子的物品，如果该格子不为空的话

	self.descTipsUI = nil

	self.godFightRuneItemTipsUI = nil
	self.godFightRuneItemLongPressKey = "GodFightRunePanel.LongPressGodFightRuneItem"
end

function GodFightRunePanel:CleanEvent()
	if self.model then
		self.model:RemoveEventListener(self.eventHandler0)
		self.model:RemoveEventListener(self.eventHandler1)
		self.model:RemoveEventListener(self.eventHandler4)
		self.model:RemoveEventListener(self.eventHandler5)
		GlobalDispatcher:RemoveEventListener(self.eventHandler2)
		GlobalDispatcher:RemoveEventListener(self.eventHandler3)
	end
end

function GodFightRunePanel:CleanUI()
	self:DisposeGodFightRuneItems()
	self:DisposeGodFightRuneEffectUI()
	self.godFightRuneContent:Destroy()
	self.tabGodFightRune:Destroy()
	self.weaponCellItem:Destroy()
	self:CleanDescTipsUI()
	self:CleanGodFightItemTipsUI()
end

function GodFightRunePanel:InitUI()
	self:InitChildUI()
	self:InitTabsUI()
	self:InitGodFightRuneItemsUI()
	self:InitGodFightRuneContentUI()
	self:InitWeaponCellItemUI()
	self:InitGodFightRuneEffectUI()
end

function GodFightRunePanel:InitChildUI()
	self.tabGodFightRune = self.ui:GetChild("tabGodFightRune")
	self.godFightRuneContent = self.ui:GetChild("godFightRuneContent")
	self.godFightRuneEffect0 = self.ui:GetChild("godFightRuneEffect0")
	self.godFightRuneEffect1 = self.ui:GetChild("godFightRuneEffect1")
	self.imgArrow = self.ui:GetChild("imgArrow")
	self.groupLeftUI = self.ui:GetChild("groupLeftUI")
	self.bg0 = self.ui:GetChild("bg0")
	self.bg1 = self.ui:GetChild("bg1")
	self.bgName = self.ui:GetChild("bgName")
	self.labelName = self.ui:GetChild("labelName")
	self.godFightRuneItem0 = self.ui:GetChild("godFightRuneItem0")
	self.godFightRuneItem1 = self.ui:GetChild("godFightRuneItem1")
	self.godFightRuneItem2 = self.ui:GetChild("godFightRuneItem2")
	self.labelTips = self.ui:GetChild("labelTips")
	self.btnUse = self.ui:GetChild("btnUse")
	self.effectRoot0 = self.ui:GetChild("effectRoot0")
	
	self.groupRightUI = self.ui:GetChild("groupRightUI")
	self.tipsBtn = self.ui:GetChild("tipsBtn")

	self.labelTips.text = "人物战败时，斗神印记会脱落"

	self.ui:SetXY(143 , 101)
end

function GodFightRunePanel:UpdateData()
	self:SetWeaponData()
	self:SetInscriptionData()
	self:SetGodFightRuneData()
end

function GodFightRunePanel:SetWeaponData()
	self.weaponData = self.model:GetWeaponData()
end

function GodFightRunePanel:SetInscriptionData()
	self.inscriptionData = self.model:GetInscriptionData()
end

function GodFightRunePanel:SetGodFightRuneData()
	self.godFightRuneData = self.model:GetGodFightRuneDataByLevel(self.lastRuneTabType)
end

function GodFightRunePanel:SetLastGodFightRuneType(typeData)
	self.lastRuneTabType = typeData or self.defaultRuneTabType
end

function GodFightRunePanel:UpdateUI()
	self:SetGodFightRuneContentUI()
	self:SetGodFightRuneItemsUI()
	--self:SetGodFightRuneEffectUI()
	self:SetWeaponUI()
	self:SetDefaultSelectItemUI()
	self:SetDefaultSelectRuneItemUI()
end

function GodFightRunePanel:LoadEffect()
	local function LoadCallBack(effect)
		if effect then
			if self.effectObj ~= nil then
				destroyImmediate(self.effectObj)
				self.effectObj = nil
			end
			local effectObj = GameObject.Instantiate(effect)
			effectObj.transform.localPosition = Vector3.New(0 , 0 , 0)
			effectObj.transform.localScale = Vector3.New(70, 70, 70)
	 		effectObj.transform.localRotation = Quaternion.Euler(0, 0, 0)

			self.effectRoot0:SetNativeObject(GoWrapper.New(effectObj))
			self.effectObj = effectObj
		end
	end
	LoadEffect("4503" , LoadCallBack)
end

function GodFightRunePanel:CleanEffect()
	if self.effectObj ~= nil then
		destroyImmediate(self.effectObj)
		self.effectObj = nil
	end
end

function GodFightRunePanel:InitTabsUI()
	self.tabGodFightRune = TabGodFightRune.Create(self.tabGodFightRune)
	self.tabGodFightRune:SetVisible(false) --关闭旧的tab

	--创建新的tab
	local tabDatas = {
		{label="全部", res0=res0, res1=res1, id="0", red=false}, 
		{label="一级", res0=res0, res1=res1, id="1", red=false},
		{label="二级", res0=res0, res1=res1, id="2", red=false},
		{label="三级", res0=res0, res1=res1, id="3", red=false},
	}

	local function tabClickCallback( idx, id )
		self.model:DispatchEvent(GodFightRuneConst.OnTypeSelect , tonumber(id))
	end

	local ctrl, tabs = CreateTabbar(self.ui, 1, tabClickCallback, tabDatas, 20, 16, 0, 105, 100, 46)
end

function GodFightRunePanel:InitGodFightRuneItemsUI()
	self.godFightRuneItem0 = GodFightRuneItem.Create(self.godFightRuneItem0)
	self.godFightRuneItem1 = GodFightRuneItem.Create(self.godFightRuneItem1)
	self.godFightRuneItem2 = GodFightRuneItem.Create(self.godFightRuneItem2)
	self.godFightRuneItems[1] = self.godFightRuneItem0
	self.godFightRuneItems[2] = self.godFightRuneItem1
	self.godFightRuneItems[3] = self.godFightRuneItem2
	for index = 1, #self.godFightRuneItems do
		self.godFightRuneItems[index]:CleanUI()
	end
end

function GodFightRunePanel:InitGodFightRuneContentUI()
	self.godFightRuneContent = GodFightRuneContent.Create(self.godFightRuneContent)
end

function GodFightRunePanel:InitWeaponCellItemUI()
	local function OnWeaponCellItemClick( cellObj )
		-- body
		self:OnWeaponCellItemClick(cellObj)
	end
	self.weaponCellItem = PkgCell.New(self.ui, nil , OnWeaponCellItemClick)
	self.weaponCellItem:SetData(nil)
	self.weaponCellItem:OpenTips(true, false)
	--self.weaponCellItem:SetupPressShowTips(true , 1)
	self.weaponCellItem:SetXY(673 , 271)
end

function GodFightRunePanel:InitGodFightRuneEffectUI()
	self.godFightRuneEffect0 = GodFightRuneEffect.Create(self.godFightRuneEffect0)
	self.godFightRuneEffect1 = GodFightRuneEffect.Create(self.godFightRuneEffect1)
	self.godFightRuneEffect0:SetTitleUI("当前效果")
	self.godFightRuneEffect1:SetTitleUI("使用效果")
end

function GodFightRunePanel:DisposeGodFightRuneEffectUI()
	self.godFightRuneEffect0:Destroy()
	self.godFightRuneEffect1:Destroy()
end

function GodFightRunePanel:DisposeGodFightRuneItems()
	for index = 1, #self.godFightRuneItems do
		if not TableIsEmpty(self.godFightRuneItems[index]) then
			self.godFightRuneItems[index]:Destroy() 
		end
	end
	self.godFightRuneItems = {}
end

function GodFightRunePanel:HandleOnTypeSelect(typeData)
	if self.lastRuneTabType ~= typeData then
		self:SetLastGodFightRuneType(typeData)
		self:SetGodFightRuneData()
		self:SetGodFightRuneContentUI()
		self:SetDefaultSelectItemUI()
	end
end

function GodFightRunePanel:HandleSelectRuneItem(instanceId)
	self.curSelectedRuneInstanceId = instanceId or -1
	self:SetNewGodFightRuneEffect()
end

function GodFightRunePanel:UpdateSelectedRuneInstanceId()
	local isHas , isHasIndex = self.model:IsHasGodFightRune(self.curSelectedRuneInstanceId)
	if isHas == true and isHasIndex ~= -1 then
		
	else
		self.curSelectedRuneInstanceId = -1
	end
end

function GodFightRunePanel:HandleRefershGodFightRune()
	self:SetGodFightRuneData()
	self:UpdateSelectedRuneInstanceId()
	self:SetGodFightRuneContentUI()
	self:SetGodFightRuneEffectUI()
end

function GodFightRunePanel:HandleRefershWeaponInscription()
	self:SetInscriptionData()
	self:SetGodFightRuneItemsUI()
	self:SetGodFightRuneEffectUI()
end

function GodFightRunePanel:HanlderWeaponChange()
	self:SetWeaponData()
	self:SetWeaponUI()
end

function GodFightRunePanel:HanldeEpigraphSucc(holeIndex)
	if self.godFightRuneItems[holeIndex] ~= nil then
		
		self.godFightRuneItems[holeIndex]:LoadEffect1()
	end
end

function GodFightRunePanel:OnGodFightRuneItemClick(index , isDefault)
	if not TableIsEmpty(self.godFightRuneItems[index]) then
		self:UnSelectGodFightRuneItems()
		self.godFightRuneItems[index]:SetSelected(true)
		self.curSelectedSlotIndex = index
		self:SetCurGodFightRuneEffect()
		if not isDefault then
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		end
	end
end

function GodFightRunePanel:UnSelectGodFightRuneItems()
	for index = 1 , #self.godFightRuneItems do
		if not TableIsEmpty(self.godFightRuneItems[index]) then
			self.godFightRuneItems[index]:SetSelected(false)
		end
	end
end

--设置左侧斗神印记内容UI表现
function GodFightRunePanel:SetGodFightRuneContentUI()
	self.godFightRuneContent:SetData(self.godFightRuneData)
	self.godFightRuneContent:SetUI()
end

--设置右侧武器斗神印记槽位UI表现
--斗神印孔位跟随武器，武器卸下或者掉了，孔位也没了
function GodFightRunePanel:SetGodFightRuneItemsUI()
	for index = 1 , #self.godFightRuneItems do
		if not TableIsEmpty(self.weaponData) then
			if index > self.weaponData.holeNum then
				self.godFightRuneItems[index]:CleanAllEffect()
				self.godFightRuneItems[index]:CleanUI()
				self.godFightRuneItems[index]:SetClockUI(true)
			else
				local isHas , hasIndex = self.model:IsHasInscriptionDataByHoldId(index)
				local curInscriptionData = self.inscriptionData[hasIndex] or {}
				
				self.godFightRuneItems[index]:SetData(curInscriptionData)
				self.godFightRuneItems[index]:SetUI()
				self.godFightRuneItems[index]:CleanAllEffect()
				if isHas and (not TableIsEmpty(curInscriptionData)) and curInscriptionData.inscriptionId ~= 0 then
					
					self.godFightRuneItems[index]:LoadEffect0()
				end
			end

			if index == self.curSelectedSlotIndex then
				self.godFightRuneItems[index]:SetSelected(true)
			end
		else
			self.godFightRuneItems[index]:CleanAllEffect()
			self.godFightRuneItems[index]:CleanUI()
			self.godFightRuneItems[index]:SetClockUI(true)
		end
	end
end

--设置斗神印记效果UI表现
function GodFightRunePanel:SetGodFightRuneEffectUI()
	self:SetCurGodFightRuneEffect()
	self:SetNewGodFightRuneEffect()
end

function GodFightRunePanel:SetCurGodFightRuneEffect()
	local curSelectedInscription = {}
	local strContent = ""
	for index = 1, #self.inscriptionData do
		local curInscriptionData = self.inscriptionData[index]
		if curInscriptionData.slotPos == self.curSelectedSlotIndex then
			curSelectedInscription = curInscriptionData
			break
		end
	end
	
	if not TableIsEmpty(curSelectedInscription) then
		if curSelectedInscription.effectType == GodFightRuneConst.EffectType.SwapSkill then
			local baseSkillId = curSelectedInscription.effectId
			local skillIndex = curSelectedInscription.attrValue
			local newSkillId = SkillModel:GetInstance():GetSkillIdByBaseIdAndSkillIndex(baseSkillId, skillIndex)
			if newSkillId ~= -1 then
				local skillInfo = self.model:GetSkillCfgInfo(newSkillId)
			 	if not TableIsEmpty(skillInfo) then
				 	strContent = skillInfo.name
			 	end
			end
		elseif curSelectedInscription.effectType == GodFightRuneConst.EffectType.AddBuff then
			local attrInfo = self.model:GetAttrCfgInfo(curSelectedInscription.effectId)
			if not TableIsEmpty(attrInfo) then
				strContent = string.format("%s+%s", attrInfo.name, curSelectedInscription.attrValue or "")
			end
		else
			strContent = "当前槽位未解锁"
		end
	else
		strContent = "当前槽位未解锁"
	end

	self.godFightRuneEffect0:SetContentUI(strContent)
end


function GodFightRunePanel:SetNewGodFightRuneEffect()
	local strContent = ""
	if self.curSelectedRuneInstanceId ~= -1 then
		strContent = self.model:GetInscriptionDesc(self.curSelectedRuneInstanceId)
	end
	self.godFightRuneEffect1:SetContentUI(strContent)
end

function GodFightRunePanel:SetWeaponUI()
	self:SetWeaponNameUI()
	self:SetWeaponCellItemUI()
	self:SetWeaponEffectUI()
end

--设置当前主武器名称UI表现
function GodFightRunePanel:SetWeaponNameUI()
	if not TableIsEmpty(self.weaponData) then
		local equipmentCfg = self.weaponData:GetCfgData()
		if not TableIsEmpty(equipmentCfg) then
			local strColor = ""
			if equipmentCfg.rare == 1 then
				strColor = "#000000"
			else
				strColor = GoodsVo.RareColor2[equipmentCfg.rare] or ""
			end
			self.labelName.text = StringFormat("[color={0}]{1}[/color]" , strColor , equipmentCfg.name)
		end
	else
		self.labelName.text = ""
	end
end

--设置主武器Cell表现
function GodFightRunePanel:SetWeaponCellItemUI()
	if not TableIsEmpty(self.weaponCellItem) then
		if not TableIsEmpty(self.weaponData) then
			local isBinding = 0 --不绑定
			self.weaponCellItem:SetDataByCfg(GoodsVo.GoodType.equipment , self.weaponData.bid , 1 , isBinding)
		else
			self.weaponCellItem:SetData(nil)
		end
	end
end

function GodFightRunePanel:SetWeaponEffectUI()
	if not TableIsEmpty(self.weaponData) then
		self:LoadEffect()
	else
		self:CleanEffect()
	end
end

function GodFightRunePanel:OnWeaponCellItemClick(cellObj)

end

function GodFightRunePanel:OnBtnUseClick()
	if self.curSelectedSlotIndex == -1 or  self.curSelectedRuneInstanceId == -1 then
		UIMgr.Win_FloatTip("请选择铭文和铭文槽")
		return		
	end
	local weaponEquipmentId = self.weaponData.id or -1
	local runeDataInstanceId = self.curSelectedRuneInstanceId
	if weaponEquipmentId ~= -1 and runeDataInstanceId ~= -1 then
		GodFightRuneController:GetInstance():ReqUseGodFightRune(weaponEquipmentId, runeDataInstanceId, self.curSelectedSlotIndex)
	end
	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

function GodFightRunePanel:OnBtnTipsClick()
	if self.descTipsUI == nil then
		self.descTipsUI = DescPanel.New()
	end
	self.descTipsUI:SetContent(GodFightRuneConst.SystemDescKey)
	UIMgr.ShowPopup(self.descTipsUI, false, 0, 0, function()
		if self.descTipsUI ~= nil then
			UIMgr.HidePopup(self.descTipsUI.ui)
			self:CleanDescTipsUI()
		end
	end)
end

function GodFightRunePanel:PressUpShowGodFightRuneItemTips(index , delayTime)
	local curItem = self.godFightRuneItems[index] or nil
	local key = StringFormat("{0}{1}" , self.godFightRuneItemLongPressKey , index)
	if curItem == nil or type(delayTime) ~= 'number' then return end
	local ui = curItem.ui 
	if ui then
		ui.onTouchBegin:Add(function ()
				RenderMgr.AddInterval(function ()
					self.godFightRuneItemTipsUI = GodFightRuneTips.New()
					local title , content = self:GetGodFightRuneItemTipsContent(index)
					self.godFightRuneItemTipsUI:SetContent(title , content)
					UIMgr.ShowPopup(self.godFightRuneItemTipsUI)
				end, key, delayTime or 0.5, delayTime or 0.5)
			end)

		ui.onTouchEnd:Add(function ()
			RenderMgr.Realse(key)
			if self.godFightRuneItemTipsUI and self.godFightRuneItemTipsUI.ui then
				UIMgr.HidePopup(self.godFightRuneItemTipsUI.ui)
				self:CleanGodFightItemTipsUI()
			end
		end)
	end
end

function GodFightRunePanel:GetGodFightRuneItemTipsContent(index)
	local rtnTitle = "" 
	local rtnContent = ""
	
	if self.model ~= nil then
		local weaponData = self.model:GetWeaponData()
		local inscriptionData = self.model:GetInscriptionData()
		if self.godFightRuneItems[index] then
			if not TableIsEmpty(weaponData) then
				if index > weaponData.holeNum then
					rtnTitle = "未解锁"
					rtnContent = "该槽位未解锁"
				else
					local isHas , hasIndex = self.model:IsHasInscriptionDataByHoldId(index)
					local curInscriptionData = inscriptionData[hasIndex] or {}
					if isHas and (not TableIsEmpty(curInscriptionData)) and curInscriptionData.inscriptionId ~= 0 then
						if curInscriptionData.effectType == GodFightRuneConst.EffectType.SwapSkill then
							local baseSkillId = curInscriptionData.effectId
							local skillIndex = curInscriptionData.attrValue
							local newSkillId = SkillModel:GetInstance():GetSkillIdByBaseIdAndSkillIndex(baseSkillId, skillIndex)
							if newSkillId ~= -1 then
								local skillInfo = self.model:GetSkillCfgInfo(newSkillId)
							 	if not TableIsEmpty(skillInfo) then
							 		rtnTitle = skillInfo.name
							 		rtnContent = skillInfo.des
							 	end
							end
						elseif curInscriptionData.effectType == GodFightRuneConst.EffectType.AddBuff then
								local attrInfo = self.model:GetAttrCfgInfo(curInscriptionData.effectId)
								if not TableIsEmpty(attrInfo) then
									rtnTitle = attrInfo.name
									rtnContent = StringFormat("{0}+{1}" , rtnTitle , curInscriptionData.attrValue)
								end
						elseif curInscriptionData.effectType == GodFightRuneConst.EffectType.None then
							rtnTitle = "铭文为空"
							rtnContent = "镶嵌印记石，可提升您的能力哦"
						else

						end
					else
						rtnTitle = "铭文为空"
						rtnContent = "镶嵌印记石，可提升您的能力哦"
					end
				end
			else
				rtnTitle = "未解锁"
				rtnContent = "该槽位未解锁"
			end
		end
	end

	return rtnTitle , rtnContent
end


function GodFightRunePanel:CleanDescTipsUI()
	self.descTipsUI = nil
end

function GodFightRunePanel:CleanGodFightItemTipsUI()
	self.godFightRuneItemTipsUI = nil
end

function GodFightRunePanel:SetDefaultSelectItemUI()
	self.model:DispatchEvent(GodFightRuneConst.DefaultSelectItem , self.defaultSelectItemIndex)
end

--如果玩家有选中某个槽位，则保留选中。反之，则选中第一个可以镶嵌的孔位
function GodFightRunePanel:SetDefaultSelectRuneItemUI()
	if self.curSelectedSlotIndex == -1 then
		local selectIndex = -1
		local firstSpaceIdx = 1000
		for index = 1 , #self.inscriptionData do
			local curInscriptionData = self.inscriptionData[index]
			--取第一个可以空孔位
			if not TableIsEmpty(curInscriptionData) and curInscriptionData.effectType == 0 then
				if firstSpaceIdx > curInscriptionData.slotPos then
					firstSpaceIdx = curInscriptionData.slotPos
				end
			end
		end

		if firstSpaceIdx ~= 1000  then 
			if not TableIsEmpty(self.weaponData) then
				--容错（武器的孔位数和铭文数据的孔位数不一致,请后端大大改下）
				if self.weaponData.holeNum and self.weaponData.holeNum >= firstSpaceIdx then
					selectIndex = firstSpaceIdx 
				end
			end
		end

		--如果武器身上铭文槽位装满了铭文，则选中第一个槽位
		if selectIndex == -1 then
			if not TableIsEmpty(self.weaponData) then
				if self.weaponData.holeNum then
					selectIndex = 1
				end
			end
		end

		if selectIndex ~= -1 then
			local isDefault = true
			self:OnGodFightRuneItemClick(selectIndex , isDefault)
		end
	end
end