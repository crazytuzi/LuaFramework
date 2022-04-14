--
-- @Author: chk
-- @Date:   2018-10-31 17:52:41
--
EquipSuitView = EquipSuitView or class("EquipSuitView",BaseItem)
local EquipSuitView = EquipSuitView

function EquipSuitView:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipSuitView"
	self.layer = layer

	self.iconSettors = {}
	self.suitAttrSettors = {}
	self.type1SuitItemSettor = {}
	self.type2SuitItemSettor = {}
	self.globalEvents = {}
	self.events = {}
	self.needIconContain = {}
	self.needIconImgs = {}
	self.needCountTxts = {}
	self.locks = {}
	self.attrSettors = {}
	self.attrTitle = {}
	self.typeItemScrollView = {}
	self.typeItemContent = {}
	self.typeItemContentRectTra = {}
	self.model = EquipSuitModel:GetInstance()
	self.model.crntSuitLv = 1
	EquipSuitView.super.Load(self)

	--EquipController.Instance:RequestEquipSuit(1)
	--EquipController.Instance:RequestEquipSuit(2)
end

function EquipSuitView:dctor()
	self:CleanIconSettors()

	if self.iconSettor ~= nil then
		self.iconSettor:destroy()
		self.iconSettor = nil
	end

	for i, v in ipairs(self.attrSettors) do
		v:destroy()
	end


	for i, v in ipairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end

	for i, v in pairs(self.type1SuitItemSettor) do
		v:destroy()
	end

	for i, v in pairs(self.type2SuitItemSettor) do
		v:destroy()
	end

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end
	if self.reddot_lv1 then
		self.reddot_lv1:destroy()
		self.reddot_lv1 = nil
	end
	if self.reddot_lv2 then
		self.reddot_lv2:destroy()
		self.reddot_lv2 = nil
	end
	if self.reedot_button then
		self.reedot_button:destroy()
		self.reedot_button = nil
	end
	self.typeItemContent = nil
	self.typeItemContentRectTra = nil
	self.attrTitle = nil
	self.attrSettors = nil
	self.iconSettors = nil
	self.suitAttrSettors = nil
	self.type1SuitItemSettor = nil
	self.type2SuitItemSettor = nil
	self.needIconContain = nil
	self.needIconImgs = nil
	self.needCountTxts = nil
	self.locks = nil
	self.typeItemScrollView = nil
end

function EquipSuitView:LoadCallBack()
	self.nodes = {
		"rightInfo",
		"rightInfoEmpty",
		"leftInfo/itemScrollView",
		"rightInfo/icon/iconContain",
		"leftInfo/Btns/CS_Btn",
		"leftInfo/Btns/CS_Btn/cs_select",
		"leftInfo/Btns/SY_Btn",
		"leftInfo/Btns/SY_Btn/sy_select",
		"rightInfo/BuildSuitBtn",
		"rightInfo/BuildSuitBtn/BuildText",
		"leftInfo/Type1ItemScrollView",
		"leftInfo/Type1ItemScrollView/Viewport/Type1ItemContent",
		"leftInfo/Type2ItemScrollView",
		"leftInfo/Type2ItemScrollView/Viewport/Type2ItemContent",
		"rightInfo/attrAbout/attrTitleCon/suitType_1",
		"rightInfo/attrAbout/attrTitleCon/suitType_2",
		"rightInfo/attrAbout/attrTitleCon/suitName",
		"rightInfo/attrAbout/attrContain",
		"rightInfo/attrAbout/noattrdesc",
		"rightInfo/name/nameValue",
		"rightInfo/attrAbout",
		"rightInfo/attrAbout/attrTitleCon",
		"rightInfo/attrAbout/suitline",

		"rightInfo/needContain/need_1/need_1_icon",
		"rightInfo/needContain/need_1/need_1_count",
		"rightInfo/needContain/need_1/need_1_lock",
		"rightInfo/needContain/need_2/need_2_icon",
		"rightInfo/needContain/need_2/need_2_count",
		"rightInfo/needContain/need_2/need_2_lock",
		"rightInfo/needContain/need_3/need_3_icon",
		"rightInfo/needContain/need_3/need_3_count",
		"rightInfo/needContain/need_3/need_3_lock",

		"rightInfo/helpBtn",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()
	self:LoadItems()
	self.noattrdesc = GetText(self.noattrdesc)

	self:ShowRedDot()
end

function EquipSuitView:AddEvent()
	local function call_back()
		if not self.BuildSuitBtnBtn.interactable then
			--Notify.ShowText(ConfigLanguage.Equip.CannotSuit)
		else
			local equipCfg = Config.db_equip[self.equipItem.id]
			EquipController.Instance:RequestBuildSuit(self.model.crntSuitLv,equipCfg.slot)
		end
	end
	AddClickEvent(self.BuildSuitBtn.gameObject,call_back)


	local function call_back()
		SetVisible(self.cs_select.gameObject,true)
		SetVisible(self.sy_select.gameObject,false)
		self.model.crntSuitLv = 1
		self:LoadItems()
		--EquipController.Instance
	end
	AddClickEvent(self.CS_Btn.gameObject,call_back)

	local function call_back()
		SetVisible(self.cs_select.gameObject,false)
		SetVisible(self.sy_select.gameObject,true)

		self.model.crntSuitLv = 2
		self:LoadItems()
	end
	AddClickEvent(self.SY_Btn.gameObject,call_back)

	local function	call_back()
		ShowHelpTip(HelpConfig.Equip.Suit, true)
	end
	AddClickEvent(self.helpBtn.gameObject,call_back)
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SuitList,handler(self,self.DealSluitList))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail,handler(self,self.DealEquipUpdate))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.ShowSuitViewInfo,handler(self,self.DealShowSuitInfo))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.SuitItemPos,handler(self,self.DealSetScrollPos))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.BuildSuitSucess,handler(self,self.DealBuildSucess))

	local function call_back( )
		self:ShowRedDot()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)

	local function call_back(desc)
		self.noattrdesc.text = desc
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.ShowSuiteDesc, call_back)
end

function EquipSuitView:GetRectTransform()
	self.BuildSuitBtnBtn = self.BuildSuitBtn:GetComponent('Button')
	self.BuildSuiteImage = GetImage(self.BuildSuitBtn)

	self.needIconContain[1] = self.need_1_icon
	self.needIconContain[2] = self.need_2_icon
	self.needIconContain[3] = self.need_3_icon

	self.needIconImgs[1] = self.need_1_icon:GetComponent('Image')
	self.needIconImgs[2] = self.need_2_icon:GetComponent('Image')
	self.needIconImgs[3] = self.need_3_icon:GetComponent('Image')

	self.needCountTxts[1] = self.need_1_count:GetComponent('Text')
	self.needCountTxts[2] = self.need_2_count:GetComponent('Text')
	self.needCountTxts[3] = self.need_3_count:GetComponent('Text')

	self.locks[1] = self.need_1_lock
	self.locks[2] = self.need_2_lock
	self.locks[3] = self.need_3_lock

	self.attrTitle[1] = self.suitType_1
	self.attrTitle[2] = self.suitType_2

	self.typeItemScrollView[1] = self.Type1ItemScrollView
	self.typeItemScrollView[2] = self.Type2ItemScrollView
	self.typeItemContent[1] = self.Type1ItemContent
	self.typeItemContent[2] = self.Type2ItemContent
	self.typeItemContentRectTra[1] = self.typeItemContent[1]:GetComponent('RectTransform')
	self.typeItemContentRectTra[2] = self.typeItemContent[2]:GetComponent('RectTransform')

	--self.itemContentRectTra = self.itemContent:GetComponent('RectTransform')
	self.suitNameTxt = self.suitName:GetComponent('Text')
	self.nameValueTxt = self.nameValue:GetComponent('Text')
	self.BuildTextTxt = self.BuildText:GetComponent('Text')
end
function EquipSuitView:SetData(data)

end

function EquipSuitView:CleanIconSettors()
	for i, v in pairs(self.iconSettors) do
		v:destroy()
	end

	self.iconSettors = {}
end

function EquipSuitView:DealEquipUpdate(equipDetail)
	if self.equipItem ~= nil and self.equipItem.id == equipDetail.id then
		self.equipItem = equipDetail
	end
end

function EquipSuitView:DealBuildSucess()
	if self.sucessEffect ~= nil then
		self.sucessEffect:destroy()
	end

	self.sucessEffect = UIEffect(self.iconContain,10004,false,self.layer)
	--self.sucessEffect:SetConfig({is_loop = false})
	SoundManager.GetInstance():PlayById(54)

	--SetVisible(self.BuildSuitBtn.gameObject,false)
	self.BuildSuitBtnBtn.interactable = false
	SetGray(self.BuildSuiteImage, true)
	self.BuildTextTxt.text = ConfigLanguage.Equip.HadActive
	self:ShowRedDot()
	self:SetButtonReddot(false)
end
--设置位置
function EquipSuitView:DealSetScrollPos(itemSettor)
	local scrollRectTra = self.typeItemScrollView[self.model.crntSuitLv]:GetComponent('RectTransform')
	local itemContentRectTra = self.typeItemContentRectTra[self.model.crntSuitLv]
	local itemRectTra = itemSettor.transform:GetComponent('RectTransform')
	local posY = GetLocalPositionY(itemSettor.transform)

	local itemH = math.abs(posY) + 100
	if itemH > scrollRectTra.sizeDelta.y then
		itemContentRectTra.anchoredPosition = Vector2(itemContentRectTra.anchoredPosition.x,itemH - scrollRectTra.sizeDelta.y)
	end

end

function EquipSuitView:DealSluitList()
	local equipCfg = Config.db_equip[self.equipItem.id]
	local suitMakeCfg = self.model:GetSuitMakeConfig(equipCfg.slot,equipCfg.order,self.model.crntSuitLv)

	local costTbl = String2Table( suitMakeCfg.cost or {})
	local career = RoleInfoModel:GetInstance():GetRoleValue("career")
	costTbl = costTbl[career]
	local canSuit = true
	for i, v in ipairs(costTbl) do
		--table.remove(notNeed,i)

		SetVisible(self.needIconImgs[i].gameObject,true)
		SetVisible(self.locks[i].gameObject,false)

		local itemCfg = Config.db_item[v[1]]
		local hasNum = BagModel.Instance:GetItemNumByItemID(itemCfg.id)

		--self.needCountTxts = ""
		local countInfo = ""
		if hasNum >= v[2] then
			countInfo = string.format("<color=#%s>%s</color>",
					ColorUtil.GetColor(ColorUtil.ColorType.Green),hasNum .. "/" .. v[2] )
		else
			canSuit = false
			countInfo = string.format("<color=#%s>%s</color>",
					ColorUtil.GetColor(ColorUtil.ColorType.Red),hasNum .. "/" .. v[2] )
		end

		if self.iconSettors[i] ~= nil then
			self.iconSettors[i]:UpdateNum(countInfo)
		end
	end
	self:ShowAttr(self.equipItem)
end

function EquipSuitView:DealShowSuitInfo(equipDetail)
	self.equipItem = equipDetail
	if self.iconSettor == nil then
		self.iconSettor = GoodsIconSettorTwo(self.iconContain)
	end

	local itemCfg = Config.db_item[equipDetail.id]
	local equipConfig = Config.db_equip[equipDetail.id]
	--local suitCfg = self.model:GetSuitConfig(equipConfig.slot,equipConfig.order,self.model.crntSuitLv)

	if self.model:GetActiveByEquip(equipConfig.slot,2) then
		self.nameValueTxt.text = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(itemCfg.color),
				"[" .. self.model.suitTypeName[2] .. "]" .. equipConfig.name)
	elseif self.model:GetActiveByEquip(equipConfig.slot,1) then
		self.nameValueTxt.text = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(itemCfg.color),
				"[" .. self.model.suitTypeName[1] .. "]" .. equipConfig.name)
	else
		self.nameValueTxt.text = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(itemCfg.color),
				equipConfig.name)
	end


	local param = {}
	param["not_need_compare"] = true
	param["model"] = self.model
	param["p_item"] = equipDetail
	param["item_id"] = equipDetail.id
	--param["size"] = {x = 104,y=104}
	param["can_click"] = true
	self.iconSettor:SetIcon(param)
	--self.iconSettor:UpdateIconClick(equipDetail)


	local equipCfg = Config.db_equip[equipDetail.id]
	local suitMakeCfg = self.model:GetSuitMakeConfig(equipCfg.slot,equipCfg.order,self.model.crntSuitLv)

	local notNeed = {}
	table.insert(notNeed,1)
	table.insert(notNeed,2)
	table.insert(notNeed,3)

	self:CleanIconSettors()

	local costTbl = String2Table( suitMakeCfg.cost or {})
	local career = RoleInfoModel:GetInstance():GetRoleValue("career")
	costTbl = costTbl[career] or {}
	local canSuit = true
	for i, v in ipairs(costTbl) do
		table.removebyvalue(notNeed,i)

		SetVisible(self.needIconImgs[i].gameObject,true)
		SetVisible(self.locks[i].gameObject,false)

		local itemCfg = Config.db_item[v[1]]
		local hasNum = BagModel.Instance:GetItemNumByItemID(itemCfg.id)
		--GoodIconUtil.Instance:CreateIcon(self,self.needIconImgs[i],itemCfg.icon,true)

		self.needCountTxts[i].text = ""
		local countInfo = ""
		if hasNum >= v[2] then
			countInfo = string.format("<color=#%s>%s</color>",
					ColorUtil.GetColor(ColorUtil.ColorType.Green),hasNum) .. "/" .. v[2]
		else
			canSuit = false
			countInfo = string.format("<color=#%s>%s</color>",
					ColorUtil.GetColor(ColorUtil.ColorType.Red),hasNum) .. "/" .. v[2]
		end

		local param = {}
		param["item_id"] = itemCfg.id
		param["can_click"] = true
		param["num"] = countInfo
		self.iconSettors[#self.iconSettors+1] = GoodsIconSettorTwo(self.needIconContain[i])
		self.iconSettors[#self.iconSettors]:SetIcon(param)

		--self.iconSettors[#self.iconSettors]:UpdateIconByItemIdClick(itemCfg.id,countInfo)
	end

	for i, v in ipairs(notNeed) do
		self.needCountTxts[v].text = ""
		SetVisible(self.locks[v].gameObject,true)
		SetVisible(self.needIconImgs[v].gameObject,false)
	end
	if canSuit and self.model.crntSuitLv == 2 then
		canSuit = self.model:GetActiveByEquip(equipConfig.slot, 1)
	end

	Jlprint('--Jl EquipSuitView.lua,line 378-- canSuit=',canSuit)
	local active = self.model:GetActiveByEquip(equipConfig.slot,self.model.crntSuitLv)
	if active then
		--SetVisible(self.BuildSuitBtn.gameObject,false)
		self.BuildSuitBtnBtn.interactable = false
		SetGray(self.BuildSuiteImage, true)
		self:SetButtonReddot(false)
		self.BuildTextTxt.text = ConfigLanguage.Equip.HadActive
	else
		--SetVisible(self.BuildSuitBtn.gameObject,true)
		--self.BuildSuitBtnBtn.interactable = true
		self.BuildSuitBtnBtn.interactable = canSuit
		SetGray(self.BuildSuiteImage, not canSuit)
		self:SetButtonReddot(canSuit)
		self.BuildTextTxt.text = ConfigLanguage.Equip.ActiveSuit
	end


	self:ShowAttr(equipDetail)
end

function EquipSuitView:LoadItems()
	local putOnedEquips = EquipModel.GetInstance():GetCanSuitEquips()

	if table.nums(putOnedEquips) > 0 then
		SetVisible(self.rightInfoEmpty.gameObject,false)
		SetVisible(self.rightInfo.gameObject,true)

		if self.model.crntSuitLv == 1 then
			self.model.last_select_item = nil
			SetVisible(self.typeItemScrollView[1].gameObject,true)
			SetVisible(self.typeItemScrollView[2].gameObject,false)
			if table.isempty(self.type1SuitItemSettor) then
				local count = 0
				for i, v in pairs(putOnedEquips) do
					count  = count + 1
					self.type1SuitItemSettor[#self.type1SuitItemSettor+1] = EquipSuitItemSettor(self.typeItemContent[self.model.crntSuitLv],"UI")
					self.type1SuitItemSettor[#self.type1SuitItemSettor]:UpdateInfo(v,count,self.model.crntSuitLv)
				end

				self:SetScrollViwe()
			else
				self.model:Brocast(EquipEvent.SelectDefaultSuit,self.model.selectDefaultEquip[self.model.crntSuitLv],
						self.model.crntSuitLv)
			end
		elseif self.model.crntSuitLv == 2 then
			self.model.last_select_item = nil
			SetVisible(self.typeItemScrollView[2].gameObject,true)
			SetVisible(self.typeItemScrollView[1].gameObject,false)
			if table.isempty(self.type2SuitItemSettor) then
				local count = 0
				for i, v in pairs(putOnedEquips) do
					count  = count + 1
					self.type2SuitItemSettor[#self.type2SuitItemSettor+1] = EquipSuitItemSettor(self.typeItemContent[self.model.crntSuitLv],"UI")
					self.type2SuitItemSettor[#self.type2SuitItemSettor]:UpdateInfo(v,count,self.model.crntSuitLv)
				end

				self:SetScrollViwe()
			else
				self.model:Brocast(EquipEvent.SelectDefaultSuit,self.model.selectDefaultEquip[self.model.crntSuitLv],
						self.model.crntSuitLv)
			end
		end
	else
		SetVisible(self.rightInfoEmpty.gameObject,true)
		SetVisible(self.rightInfo.gameObject,false)
	end
end

function EquipSuitView:ShowAttr(equipDetail)
	if table.isempty(self.suitAttrSettors) then
		for i = 1, 3 do
			local attrSettor = SuitAttrItemSettor(self.attrContain,"UI")
			table.insert(self.suitAttrSettors,attrSettor)
		end
	end

	local notAttr = {}
	table.insert(notAttr,1)
	table.insert(notAttr,2)
	table.insert(notAttr,3)

	local equipCfg = Config.db_equip[equipDetail.id]
	local showSuitLv = self.model.crntSuitLv
	if self.model.crntSuitLv == 1 then
		if self.model:GetActiveByEquip(equipCfg.slot,2) then
			showSuitLv = 2
		end
	end


	local suitCount = self.model:GetActiveSuitCount(equipCfg.slot,equipCfg.order,showSuitLv)
	local suitCfg = self.model:GetSuitConfig(equipCfg.slot,equipCfg.order,showSuitLv)
	local attrsTb = String2Table(suitCfg.attribs)

	if not table.isempty(suitCfg) then
		local totalCount = self.model:GetSuitCount(equipCfg.slot,equipCfg.order,showSuitLv)
		local hasCount = self.model:GetActiveSuitCount(equipCfg.slot,equipCfg.order,showSuitLv)

		self.suitNameTxt.text = string.format("<color=#bc3f07>%s</color>",
				suitCfg.title .. "(" .. hasCount .. "/" .. totalCount .. ")")
	end

	if not self.model:GetCanBuildSuit(self.equipItem,showSuitLv) then
		SetVisible(self.BuildSuitBtn.gameObject,false)
		SetVisible(self.attrTitleCon.gameObject,false)
		SetVisible(self.BuildSuitBtn.gameObject,false)
		SetVisible(self.attrContain.gameObject,false)
		SetVisible(self.noattrdesc, true)
		--SetVisible(self.attrAbout.gameObject,false)
		self.BuildSuitBtnBtn.interactable = false
		--SetGray(self.BuildSuiteImage, true)
		self:SetButtonReddot(false)

		return
	else
		if self.model:GetActiveByEquip(equipCfg.slot,2) then
			SetVisible(self.attrTitleCon.gameObject,true)
			self.BuildTextTxt.text = ConfigLanguage.Equip.HadActive
			self.BuildSuitBtnBtn.interactable = false
			--[[SetGray(self.BuildSuiteImage, true)
			self:SetButtonReddot(false)--]]
		else
			SetVisible(self.BuildSuitBtn.gameObject,true)
			SetVisible(self.attrAbout.gameObject,true)
			SetVisible(self.attrTitleCon.gameObject,true)
			SetVisible(self.BuildSuitBtn.gameObject,true)
			SetVisible(self.attrContain.gameObject,true)
			--[[SetGray(self.BuildSuiteImage, false)
			self:SetButtonReddot(true)--]]
		end
		SetVisible(self.noattrdesc, false)
	end

	if showSuitLv == 1 then
		SetVisible(self.attrTitle[1].gameObject,true)
		SetVisible(self.attrTitle[2].gameObject,false)
	else
		SetVisible(self.attrTitle[1].gameObject,false)
		SetVisible(self.attrTitle[2].gameObject,true)
	end

	for i, v in ipairs(attrsTb or {}) do
		table.removebyvalue(notAttr,i)

		local active = false
		if suitCount >= v[1] then
			active = true
		end
		
		local attrInfo = ""
		local attrCount = table.nums(v[2])
		local crntCount = 1
		for i, v in pairs(v[2]) do
			if active then
				attrInfo = attrInfo .. string.format("<color=#%s>%s</color>","aa5d25",enumName.ATTR[v[1]])
				attrInfo = attrInfo .. string.format("<color=#%s>%s</color>","18c114",EquipModel.Instance:GetAttrTypeInfo(v[1],v[2]))
			else
				attrInfo = attrInfo .. string.format("<color=#%s>%s</color>","7d5941",enumName.ATTR[v[1]])
				attrInfo = attrInfo .. string.format("<color=#%s>%s</color>","7d5941",EquipModel.Instance:GetAttrTypeInfo(v[1],v[2]))
			end


			if crntCount < attrCount then
				attrInfo = attrInfo .. "\n"
			end


			crntCount = crntCount + 1
		end

		self.suitAttrSettors[i]:UpdateInfo(active,{suitCount = v[1],attrValue = attrInfo,index = i})

		SetVisible(self.attrContain.gameObject,false)
		SetVisible(self.attrContain.gameObject,true)
	end

	for i, v in ipairs(notAttr) do
		self.suitAttrSettors[v]:DisShowInfo()
	end
end

function EquipSuitView:SetScrollViwe()
	local count = table.nums(EquipModel.Instance:GetCanSuitEquips())
	local y =  100 * count
	self.typeItemContentRectTra[self.model.crntSuitLv].sizeDelta = Vector2(self.typeItemContentRectTra[self.model.crntSuitLv].sizeDelta.x,y)
end


function EquipSuitView:ShowRedDot()
	local show_lv1 = self.model:GetNeedShowRedDotLevel(nil, 1)
	local show_lv2 = self.model:GetNeedShowRedDotLevel(nil, 2)
	if not self.reddot_lv1 then
		self.reddot_lv1 = RedDot(self.CS_Btn)
		SetLocalPosition(self.reddot_lv1.transform, 55, 14)
	end
	SetVisible(self.reddot_lv1, show_lv1)
	if not self.reddot_lv2 then
		self.reddot_lv2 = RedDot(self.SY_Btn)
		SetLocalPosition(self.reddot_lv2.transform, 55, 14)
	end
	SetVisible(self.reddot_lv2, show_lv2)
end

function EquipSuitView:SetButtonReddot(flag)
	if not self.reedot_button then
		self.reedot_button = RedDot(self.BuildSuitBtn)
		SetLocalPosition(self.reedot_button.transform, 55, 14)
	end
	SetVisible(self.reedot_button, flag)
end