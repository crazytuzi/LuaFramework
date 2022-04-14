--
-- @Author: chk
-- @Date:   2018-12-05 16:54:10
--
FactionCreatePanel = FactionCreatePanel or class("FactionCreatePanel",WindowPanel)
local FactionCreatePanel = FactionCreatePanel

function FactionCreatePanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionCreatePanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 5
	self.lv = 1
	self.events = {}
	self.iconSettor = {}
	self.limitPeopleTxt = {}
	self.conditionTxt = {}
	self.costCon = {}
	self.costSettor = {}
	self.lastSelect = nil
	self.model = FactionModel:GetInstance()
end

function FactionCreatePanel:dctor()
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	for i, v in pairs(self.iconSettor) do
		v:destroy()
	end
end

function FactionCreatePanel:Open( )
	FactionCreatePanel.super.Open(self)
end

function FactionCreatePanel:LoadCallBack()
	self.nodes = {
		"CreateName/InputField",
		"CreateName/nameDefault",
		"btn_ok",
		"btn_cancle",
		"oneLVBtn",
		"twoLVBtn",
		"oneLVBtn/oneSelect",
		"oneLVBtn/one_limit_value",
		"oneLVBtn/oneLVCost",
		"oneLVBtn/walfe/oneWalfeContain",
		"oneLVBtn/condition/oneConditionValue",
		"twoLVBtn/twoSelect",
		"twoLVBtn/two_limit_value",
		"twoLVBtn/twoLVCost",
		"twoLVBtn/walfe/twoWalfeContain",
		"twoLVBtn/condition/twoConditionValue",
		"CloseBtn",
	}
	self:GetChildren(self.nodes)
	self:SetTileTextImage("faction_image","faction_f_c")
	self.lastSelect = self.oneSelect
	self.limitPeopleTxt[1] = self.one_limit_value
	self.limitPeopleTxt[2] = self.two_limit_value
	self.conditionTxt[1] = self.oneConditionValue
	self.conditionTxt[2] = self.twoConditionValue
	self.costCon[1] = self.oneLVCost
	self.costCon[2] = self.twoLVCost
	self.InputIpt = self.InputField:GetComponent('InputField')
	self:AddEvent()
end

function FactionCreatePanel:AddEvent()
	local function call_back()
		if self.lv == 1 then
			local factionCfg = Config.db_guild[self.lv]
			local costAry = String2Table(factionCfg.cost)
			local id = costAry[1][1]
			local number = costAry[1][2]
			if BagModel:GetInstance():GetItemNumByItemID(id) < 1 then
				local itemCfg = Config.db_item[id]
				local color = itemCfg.color
				local name = itemCfg.name
				local price = Config.db_voucher[id].price
				Dialog.ShowTwo("Tip", string.format("<color=#%s>%sx1</color>Not enough.Spend %s bound diamonds to creat?\n(Use bound diamonds first.Diamonds will be used if you don't have enough bound diamonds)",ColorUtil.GetColor(color),name,price), "Confirm", handler(self, self.Ok_Call_back), nil, "Cancel", nil, nil)
			else
				self:Ok_Call_back()
			end
		else
			self:Ok_Call_back()
		end

	end
	AddClickEvent(self.btn_ok.gameObject,call_back)

	local function call_back(str)
		if str ~= "" then
			SetVisible(self.nameDefault.gameObject,false)

		end
	end
	self.InputIpt.onValueChanged:AddListener(call_back)

	local function call_back(str)
		if str == "" then
			SetVisible(self.nameDefault.gameObject,true)
		end
	end
	self.InputIpt.onEndEdit:AddListener(call_back)
	--local function call_back()
	--	self:Close()
	--end
	--AddClickEvent(self.btn_cancle.gameObject,call_back)

	local function call_back()
		self.lv = 1
		SetVisible(self.lastSelect.gameObject,false)
		SetVisible(self.oneSelect.gameObject,true)
		self.lastSelect = self.oneSelect
	end
	AddClickEvent(self.oneLVBtn.gameObject,call_back)

	local function call_back()
		self.lv = 2
		SetVisible(self.lastSelect.gameObject,false)
		SetVisible(self.twoSelect.gameObject,true)
		self.lastSelect = self.twoSelect
	end
	AddClickEvent(self.twoLVBtn.gameObject,call_back)

	--local function call_back()
	--	self:Close()
	--end
	--AddClickEvent(self.CloseBtn.gameObject,call_back)

	self.events[#self.events+1] = self.model:AddListener(FactionEvent.FactionCreateSucess,handler(self,self.DealFactionCreate))
end

function FactionCreatePanel:OpenCallBack()
	self:UpdateView()
end

function FactionCreatePanel:DealFactionCreate()
	self:Close()
end

function FactionCreatePanel:UpdateView( )
	self:ShowCondition(1)
	self:ShowCondition(2)

end

function FactionCreatePanel:ShowCondition(lv)
	local factionCfg = Config.db_guild[lv]
	self.limitPeopleTxt[lv]:GetComponent('Text').text = factionCfg.memb

	local condition = String2Table(factionCfg.reqs)
	local conditionStr = ""
	local count = table.nums(condition)
	local crntC = 1
	for i, v in pairs(condition) do
		if v[1] == "level" then
			conditionStr = conditionStr .. string.format(ConfigLanguage.Faction.ToLevel,v[2])
			if crntC < count then
				conditionStr = conditionStr .. "\n"
			end
		elseif v[1] == "vip" then
			conditionStr = conditionStr .. string.format(ConfigLanguage.Faction.ToVip,v[2])
			if crntC < count then
				conditionStr = conditionStr .. "/n"
			end
		end

		crntC = crntC + 1
	end

	self.conditionTxt[lv]:GetComponent('Text').text = conditionStr

	local count = 1
	local costAry = String2Table(factionCfg.cost)
	for i, v in pairs(costAry) do
		self.costSettor[#self.costSettor+1] = FactionCreateCostItemSettor(self.costCon[lv])
		self.costSettor[#self.costSettor]:SetData(v[1],v[2],count)

		count = count + 1
	end
end

function FactionCreatePanel:Ok_Call_back()
	local oneLen = string.len("Me")
	local limitLen = oneLen * 6
	local name1 = string.gsub(self.InputIpt.text, "^%s*(.-)%s*$", "%1")
	local len1 = string.len(name1)
	local name2 = string.filterSpeChars(name1)
	local len2 = string.len(name2)
	if len1 ~= len2 then
		Notify.ShowText("Improper contents found in your guild name")
		return
	end

	if len1 > limitLen then
		Notify.ShowText(ConfigLanguage.Faction.NameLength)
		return
	end

	if len1 < oneLen then
		Notify.ShowText(ConfigLanguage.Faction.NameLength2)
		return
	end

	--if string.find(self.InputIpt.text," ") then
	--	Notify.ShowText(ConfigLanguage.Mix.FeiFaZiFu)
	--	return
	--end
	if name1 == "" then
		Notify.ShowText(ConfigLanguage.Faction.NameCantAllEasp)
	else
		if self.InputIpt.text == "" then
			Notify.ShowText(ConfigLanguage.Faction.InputFactionName)
		else
			if FilterWords:GetInstance():isSafe(name2) then
				FactionController.GetInstance():RequestCreateFaction(name2,self.lv)
			else
				Notify.ShowText("Improper contents found in your guild name")
			end
		end
	end
end


function FactionCreatePanel:CloseCallBack(  )

end