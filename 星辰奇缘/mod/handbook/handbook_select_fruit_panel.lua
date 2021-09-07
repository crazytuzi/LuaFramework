-- ------------------------------------
-- 选择要升级的幻化果
-- pwj 2019 0122
-- ------------------------------------
HandBookSelectFruitPanel = HandBookSelectFruitPanel or BaseClass()

function HandBookSelectFruitPanel:__init(parent,gameObject)
		self.parent = parent
		self.gameObject = gameObject
		self.itemList = {}
		self:InitPanel()
end

function HandBookSelectFruitPanel:__delete()
end

function HandBookSelectFruitPanel:InitPanel()
		self.transform = self.gameObject.transform
		self.closeBtn = self.transform:FindChild("CloseButton"):GetComponent(Button)
		self.closeBtn.onClick:AddListener(function() self:Hide() end)

		self.Container = self.transform:Find("mask/ItemContainer")
		self.item = self.transform:Find("mask/ItemContainer/Item")
		self.item.gameObject:SetActive(false)

		self.noTips = self.transform:Find("mask/NoTips")
		self.noTips.gameObject:SetActive(false)

		self.slotParent = self.noTips:Find("Slot")
		self.noItemText = self.noTips:Find("Text"):GetComponent(Text)
		
		self.layout = LuaBoxLayout.New(self.Container, {axis = BoxLayoutAxis.Y, cspacing = 2, border = 2})

		self:Hide()
end

function HandBookSelectFruitPanel:SetData(baseid, targetid, times)
		self:Show()
		--图鉴信息
		self.handbook_data = DataHandbook.data_base[targetid]
		--BaseUtils.dump(BackpackManager.Instance.itemDic,"itemDic")
		self.datalist = BackpackManager.Instance:GetFruitTimes(baseid, times)
		local tab = nil
		local data = DataItem.data_get[baseid]
		if next(self.datalist) == nil then
				self.slot = ItemSlot.New()
				UIUtils.AddUIChild(self.slotParent, self.slot.gameObject)
				local itemdata = ItemData.New()
				itemdata:SetBase(data)
				self.slot:SetAll(itemdata)

				self.noItemText.text = string.format(TI18N("背包暂无<color='#ffff00'>[%s]</color>可强化"),data.name)
			  self.noTips.gameObject:SetActive(true)
		end
		for i,v in pairs(self.datalist) do
				tab = self.itemList[i]
				if tab == nil then
						tab = {}
						tab.obj = GameObject.Instantiate(self.item)
						tab.trans = tab.obj.transform
						tab.select = tab.trans:Find("Select")
						tab.name = tab.trans:Find("Name"):GetComponent(Text)
						tab.desc = tab.trans:Find("Desc"):GetComponent(Text)
						tab.btn = tab.trans:GetComponent(Button)
						tab.btn.onClick:AddListener(function() self:OnOkButton(i) end)
						local slotParent = tab.trans:Find("Item").gameObject
						tab.slot = ItemSlot.New()
						UIUtils.AddUIChild(slotParent, tab.slot.gameObject)
						self.layout:AddCell(tab.obj.gameObject)
						self.itemList[i] = tab
				end
				local itemdata = ItemData.New()
				itemdata:SetBase(data)
				tab.slot:SetAll(itemdata)
				tab.slot:SetNotips()
				local fruitdata = BackpackManager.Instance:GetCurrFruitData(v.id)
				--BaseUtils.dump(fruitdata,"fruitdata")
				if fruitdata.lev == 0 then
						tab.name.text = v.name
				else
					  tab.name.text = v.name..string.format("Lv%s", fruitdata.lev)
				end
				if fruitdata.lev == 0 then
						tab.desc.text = TI18N("未强化")
				else
					  local str = ""
					  local mapp = BackpackManager.Instance:MergeSameAttr(fruitdata, targetid)
						for ii, vv in pairs(mapp) do
								str = str..KvData.attr_name[ii]..string.format("+%s ", vv)
						end	
					  tab.desc.text = str
				end
		end
end

function HandBookSelectFruitPanel:OnOkButton(index)
	  local currData = self.datalist[index]
		self.parent:ReturnSelectFruit(currData.id)
		self:Hide()
end

function HandBookSelectFruitPanel:Show()
		if self.gameObject ~= nil then
			self.gameObject:SetActive(true)
		end
end

function HandBookSelectFruitPanel:Hide()
		if self.gameObject ~= nil then
			self.gameObject:SetActive(false)
		end
end