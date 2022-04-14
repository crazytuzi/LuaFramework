--
-- @Author: chk
-- @Date:   2018-12-05 11:50:32
--
FactionWareView = FactionWareView or class("FactionWareView",BaseItem)
local FactionWareView = FactionWareView

function FactionWareView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionWareHouseView"
	self.layer = layer
	self.logItems = {}
	self.scrollView = nil
	self.events = {}
	self.globalEvents = {}
	self.qualityIdxMapQuality = {}
	self.stepIdxMapSetp = {}
	self.isMapSelfCareer = false --是否只匹配自己的职业
	self.model = FactionModel:GetInstance()
	FactionWareView.super.Load(self)
end

function FactionWareView:dctor()
	self.model.isOpenWarePanel = false
	self.model.isMgrStatus = false
	self.model.isDonateEquip = false
	self.model.isEchEquip = false
	if self.scrollView ~= nil then
		self.scrollView:OnDestroy()
		self.scrollView:destroy()
	end

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end

	if self.emptyGirl ~= nil then
		self.emptyGirl:destroy()
	end

	if self.exchItemSettor ~= nil then
		self.exchItemSettor:destroy()
	end
end

function FactionWareView:LoadCallBack()
	self.nodes = {
		"girlContain",
		"Left",
		"Right",
		"Right/FactionWareItem",
		"Right/qulityDropdown",
		"Right/qulityDropdown/qualityLabel",
		"Right/setDropdown",
		"Right/setDropdown/setLabel",
		"Right/integral",
		"Right/DonateBtn",
		"Right/BatchBtn",
		"Right/QuitBatchBtn",
		"Right/destroyEquipBtn",
		"Right/GoodsScrollView",
		"Right/GoodsScrollView/Viewport/GoodsContent",
		"Right/mapSelfToggle",
		"Left/FactionWareLogItem",
		"Left/LogScrollView",
		"Left/LogScrollView/Viewport/LogContent",
		"Left/no_log",
	}
	self:GetChildren(self.nodes)
	self.model.isOpenWarePanel = true
	self.qulityDropdown = GetDropDown(self.qulityDropdown)
	self.model.isEchEquip = true
	--self:CreateExchItem()

	self.qualityIdxMapQuality[0] = 0
	self.qualityIdxMapQuality[1] = 4
	self.qualityIdxMapQuality[2] = 5
	self.qualityIdxMapQuality[3] = 6
	self.qualityIdxMapQuality[4] = 7

	self.stepIdxMapSetp[0] = 0
	self.stepIdxMapSetp[1] = 4
	self.stepIdxMapSetp[2] = 5
	self.stepIdxMapSetp[3] = 6
	self.stepIdxMapSetp[4] = 7
	self.stepIdxMapSetp[5] = 8
	self.stepIdxMapSetp[6] = 9
	self.stepIdxMapSetp[7] = 10
	self.stepIdxMapSetp[8] = 11
	self.stepIdxMapSetp[9] = 12
	self.stepIdxMapSetp[10] = 13
	self.stepIdxMapSetp[11] = 14
	self.stepIdxMapSetp[12] = 15
	self.stepIdxMapSetp[13] = 16

	self:AddQulityDropDown()
	self:AddStepDropDown()
	self.model.selectQuality = self.qulityDropdown:GetComponent('Dropdown').value
	self.model.selectStep = self.setDropdown:GetComponent('Dropdown').value
	self.model.isMapSelf = self.mapSelfToggle:GetComponent('Toggle').isOn

	if self.model.roleData.guild == "0" then
		if self.emptyGirl == nil then
			self.emptyGirl = EmptyGirl(self.girlContain,ConfigLanguage.Faction.EnterFactionPlease)
		end
		SetVisible(self.emptyGirl.gameObject,true)

		SetVisible(self.Left.gameObject,false)
		SetVisible(self.Right.gameObject,false)
	else

		self:AddEvent()



		FactionWareController.GetInstance():RequestWareInfo()
	end

	local desLimitCfg = self.model:GetPermCfg(enum.GUILD_PERM.GUILD_PERM_DESTROY)
	if desLimitCfg.post > self.model.selfCareer then
		SetVisible(self.BatchBtn.gameObject,false)
	end

	--self.qualityLabel:GetComponent('Text').text = "0"
	--self.setLabel:GetComponent('Text').text = "0"
end

function FactionWareView:AddEvent()
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.WareInfo,handler(self,self.UpdateView))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.DonateLog,handler(self,self.DealDonateLog))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.ExchangeSucess,handler(self,self.DealExchangeSucess))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.OpenBatchExchangeView,handler(self,self.DealOpenBatchExchangeView))
	--self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(FactionEvent.DestroyEquipSucess,handler(self,self.DealDelItem))

	local function call_back()
		lua_panelMgr:GetPanelOrCreate(FactionDonatePanel):Open()
	end
	AddClickEvent(self.DonateBtn.gameObject,call_back)

	local function call_back(index)
		self.model.selectQuality = self.qualityIdxMapQuality[index]
		self.model:SetWareItems(self.model.selectQuality,self.model.selectStep,self.model.isMapSelf)
		self.model:Brocast(BagEvent.LoadItemByBagId,self.model.wareId)
	end
	self.qulityDropdown:GetComponent('Dropdown').onValueChanged:AddListener(call_back)


	local function call_back(index)
		self.model.selectStep = self.stepIdxMapSetp[index]
		self.model:SetWareItems(self.model.selectQuality,self.model.selectStep,self.model.isMapSelf)
		self.model:Brocast(BagEvent.LoadItemByBagId,self.model.wareId)
	end
	self.setDropdown:GetComponent('Dropdown').onValueChanged:AddListener(call_back)

	local function call_back(select)
		self.model.isMapSelf = select
		self.model:SetWareItems(self.model.selectQuality,self.model.selectStep,self.model.isMapSelf)
		self.model:Brocast(BagEvent.LoadItemByBagId,self.model.wareId)
	end
	 self.mapSelfToggle:GetComponent('Toggle').onValueChanged:AddListener(call_back)

	local function call_back()
		FactionWareController.GetInstance():RequestDestroyEquip()
	end
	AddClickEvent(self.destroyEquipBtn.gameObject,call_back)


	local function call_back()
		SetVisible(self.BatchBtn.gameObject,false)
		SetVisible(self.DonateBtn.gameObject,false)

		SetVisible(self.QuitBatchBtn.gameObject,true)
		SetVisible(self.destroyEquipBtn.gameObject,true)

		self.model.isMgrStatus = true
		self.model.isEchEquip = false
	
		GlobalEvent:Brocast(GoodsEvent.MultySelect,FactionModel.GetInstance().wareId)
	end
	AddClickEvent(self.BatchBtn.gameObject,call_back)


	local function call_back()
		SetVisible(self.BatchBtn.gameObject,true)
		SetVisible(self.DonateBtn.gameObject,true)

		SetVisible(self.QuitBatchBtn.gameObject,false)
		SetVisible(self.destroyEquipBtn.gameObject,false)

		self.model.isEchEquip = true
		self.model.isMgrStatus = false
		GlobalEvent:Brocast(GoodsEvent.SingleSelect,FactionModel.Instance.wareId)
	end
	AddClickEvent(self.QuitBatchBtn.gameObject,call_back)
end

function FactionWareView:AddQulityDropDown()
	self.qulityDropdown = GetDropDown(self.qulityDropdown)

	local od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Quality.QualityAll;              --0
	self.qulityDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = enumName.COLOR[enum.COLOR.COLOR_PURPLE];              --1
	self.qulityDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = enumName.COLOR[enum.COLOR.COLOR_ORANGE];              --2
	self.qulityDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = enumName.COLOR[enum.COLOR.COLOR_RED];              --3
	self.qulityDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = enumName.COLOR[enum.COLOR.COLOR_PINK];              --3
	self.qulityDropdown.options:Add(od);
end


function FactionWareView:AddStepDropDown()
	self.setDropdown = GetDropDown(self.setDropdown)
	local od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepAll;              --0
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepFour;
	self.setDropdown.options:Add(od);                   --1

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepFive;             --2
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepSix;              --3
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepSeven;           --4
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepEight;           --5
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepNight;          --6
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepTen;           --7
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepElven;         --8
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepTwelve;        --9
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepThirty;        --10
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepForty;         --11
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepFifty;         --12
	self.setDropdown.options:Add(od);

	od = UnityEngine.UI.Dropdown.OptionData();
	od.text = ConfigLanguage.Step.StepSixteen;       --13
	self.setDropdown.options:Add(od);
end
function FactionWareView:SetData(data)

end

function FactionWareView:CreateExchItem(itemCLS)
	
	if self.exchItemSettor ~= nil then
		self.exchItemSettor:destroy()
	end
	self.exchItemSettor = nil
	if self.exchItemSettor == nil then
		for i, v in pairs(Config.db_guild_exch) do
			local operate_param = {}
			GoodsTipController.Instance:SetExchangeCB(operate_param,handler(self,self.RequestExchangeBuyOne),{v.item_id,1})
			GoodsTipController.Instance:SetBatchExchangeCB(operate_param,handler(self,self.OpenBatchExchangeView),{v.item_id})


			local param = {}
			local cfg = Config.db_item[v.item_id]
			param["cfg"] = cfg
			param["can_click"] = true
			param["operate_param"] = operate_param
			param["size"] = {x = 78,y = 78}
			self.exchItemSettor = GoodsIconSettorTwo(self.GoodsContent)
			self.exchItemSettor:SetIcon(param)
			SetAnchoredPosition(self.exchItemSettor.transform,-281.2,1030)
		end

		itemCLS:UpdateRayTarget(false)
	end

end

function FactionWareView:CreateLogsItems()
	if table.nums(self.model.wareInfo.logs) <=0 then
		SetVisible(self.no_log.gameObject,true)
	else
		SetVisible(self.no_log.gameObject,false)
	end
	table.sort(self.model.wareInfo.logs, function (a, b) return a.time < b.time end)

	for i=1, #self.model.wareInfo.logs do
		self:CreateLogItem(self.model.wareInfo.logs[i], i)
	end
end

function FactionWareView:CreateLogItem(log, index)
	local item = newObject(self.FactionWareLogItem)

	local logItem = FactionLogItemSettor(item , log, index);
	--logItem.parent = self.transform;
	logItem.transform:SetParent(self.LogContent.transform)
	table.insert(self.logItems,logItem)
	SetLocalScale(logItem.transform, 1, 1, 1);
	--SetLocalPosition(logItem.transform,0,0,0)
	logItem.transform:SetAsFirstSibling()
	SetVisible(self.no_log.gameObject,false)
end

function FactionWareView:ClickItemCB()

end

function FactionWareView:CreateGoodsItem()
	local param = {}
	local cellSize = {width = 76,height = 76}
	param["scrollViewTra"] = self.GoodsScrollView:GetComponent('RectTransform')
	param["cellParent"] = self.GoodsContent
	param["instanceObj"] = self.FactionWareItem
	param["cellSize"] = cellSize
	param["cellClass"] = FactionWareItemSettor
	param["begPos"] = Vector2(0,-5)
	param["begIdx"] = 1
	param["spanX"] = 4
	param["spanY"] = 10
	param["createCellCB"] = handler(self,self.CreateCellCB)
	param["updateCellCB"] = handler(self,self.UpdateCellCB)
	param["cellCount"] = 200
	self.scrollView = ScrollViewUtil.CreateItems(param)
end

function FactionWareView:CreateCellCB(itemCLS)
	self:UpdateCellCB(itemCLS)
end

function FactionWareView:DealExchangeSucess(logParam, index)
	local roleData = RoleInfoModel:GetInstance():GetMainRoleData()
	--dump(roleData.id,"id")
	--dump(roleData.uid,"uid")
	--print2(logParam.role_id)
	if logParam.role_id == roleData.id then
		GetText(self.integral).text = tostring(self.model.wareInfo.score)
	end
	self:CreateLogItem(logParam, index)
end


function FactionWareView:UpdateCellCB(itemCLS)
	--logError(table.nums(self.model.wareItems))
	if itemCLS.__item_index == 1 then
		self:CreateExchItem(itemCLS)
		return
	end
	if self.model.wareItems ~=nil then
		local itemBase = self.model.wareItems[itemCLS.__item_index - self.model.spanIdx]
		if itemBase ~= nil and itemBase ~= 0 then
			local configItem = Config.db_item[itemBase.id]
			if configItem ~= nil then --配置表存该物品
				local param = {}
				param["parent"] = self.GoodsContent
				param["type"] = configItem.type
				param["uid"] = itemBase.uid
				param["id"] = configItem.id
				param["num"] = itemBase.num
				param["bag"] = self.model.wareId
				param["bind"] = itemBase.bind
				param["outTime"] = itemBase.etime
				param["itemSize"] = {x = 78,y = 78}
				param["model"] = self.model
				param["multy_select"] = self.model.isMgrStatus
				param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
				param["selectItemCB"] = handler(self,self.SelectItemCB)
				param["delItemCB"] = handler(self,self.DelItemCB)
				param["click_call_back"] = handler(self,self.RequireEquipInfo)
				param["get_item_select_cb"] = handler(self,self.GetItemSelect)
				itemCLS:DeleteItem()
				itemCLS:UpdateItem(param)
			end
		else
			local param = {}
			--param["multy_select"] = false
			param["multy_select"] = self.model.isMgrStatus
			param["model"] = self.model
			param["bag"] = self.model.wareId
			param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
			param["selectItemCB"] = handler(self,self.SelectItemCB)
			param["click_call_back"] = handler(self,self.RequireEquipInfo)
			param["get_item_select_cb"] = handler(self,self.GetItemSelect)
			itemCLS:InitItem(param)
		end
	else
		local param = {}
		--param["multy_select"] = false
		param["multy_select"] = self.model.isMgrStatus
		param["model"] = self.model
		param["bag"] = self.model.wareId
		param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
		param["selectItemCB"] = handler(self,self.SelectItemCB)
		param["click_call_back"] = handler(self,self.RequireEquipInfo)
		param["get_item_select_cb"] = handler(self,self.GetItemSelect)
		itemCLS:InitItem(self.GoodsContent)
	end
	itemCLS:UpdateRayTarget(true)
end

function FactionWareView:UpdateView()

	self:CreateLogsItems()
	self:CreateGoodsItem()

	GetText(self.integral).text = tostring(self.model.wareInfo.score)
end

function FactionWareView:DealDelItem()

end

function FactionWareView:DealOpenBatchExchangeView(itemId)
	lua_panelMgr:GetPanelOrCreate(FactionExchangePanel):Open(itemId)
end

function FactionWareView:DealDonateLog(log, index)
	self:CreateLogItem(log, index)
	local roleData = RoleInfoModel:GetInstance():GetMainRoleData()
	if log.role_id == roleData.id then
		GetText(self.integral).text = tostring(self.model.wareInfo.score)
	end
	--GetText(self.integral).text = tostring(self.model.wareInfo.score)
end

function FactionWareView:GetItemSelect(uid)
	--logError(uid)
	return self.model:GetWareItemSelect(uid)
end

function FactionWareView:DelItemCB(uid)
	self.model:DelWareItemByUid(uid)
end

function FactionWareView:GetItemDataByIndex(index)
	return self.model:GetItemDataByIndex(index)
end

function FactionWareView:SelectItemCB(uid,is_select)
	self.model:SetWareItemSelect(uid,is_select)
end


function FactionWareView:RequireEquipInfo(uid)
	self.model.isEchEquip = true
	FactionWareController.GetInstance():RequestEquipDetailInfo(uid)
end

--兑换装备
function FactionWareView:RequestExchange(call_back_param)
	FactionWareController.Instance:RequestExchEquip(call_back_param[1],call_back_param[2])
end


--单个换购物品
function FactionWareView:RequestExchangeBuyOne(call_back_param)
	FactionWareController.GetInstance():RequestExchBuy(call_back_param[1],call_back_param[2])
end

function FactionWareView:OpenBatchExchangeView(call_back_param)
	FactionModel.Instance:Brocast(FactionEvent.OpenBatchExchangeView,call_back_param[1])
	GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end


