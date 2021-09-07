-- ------------------------------------
-- 幻化强化面板
-- pwj 2019 0123
-- ------------------------------------
HandbookMergePanel = HandbookMergePanel or BaseClass(BasePanel)

function HandbookMergePanel:__init(parent)
		self.parent = parent
		self.model = HandbookManager.Instance.model
		self.resList = {
				{file = AssetConfig.handbook_merge, type = AssetType.Main}
				,{file = AssetConfig.rolebgnew, type = AssetType.Dep}
				,{file = AssetConfig.petskinwindow_bg1, type = AssetType.Dep}
		}
		self._UpdateMergeState = function(currId) self:SetData(currId) end
		self._UpdateMergeselect = function(index, val) self:ReturnSelectType(index, val) end
    self.OnOpenEvent:Add(function() self:OnShow() end)
		self.OnHideEvent:Add(function() self:OnHide() end)

		self.left_msg_list = {}
		self.right_msg_list = {}

		self.consumeList = {}  --消耗碎片list

		self.HasChooseType = false
end

function HandbookMergePanel:__delete()
	self:OnHide()
	if self.left_slot_1 ~= nil then
		  self.left_slot_1:DeleteMe()
		  self.left_slot_1 = nil
	end

	if self.left_slot_2 ~= nil then
		  self.left_slot_2:DeleteMe()
		  self.left_slot_2 = nil
end

	if self.right_slot ~= nil then
		  self.right_slot:DeleteMe()
		  self.right_slot = nil
	end

	if self.selectFruitPanel ~= nil then
			self.selectFruitPanel:DeleteMe()
			self.selectFruitPanel = nil
	end
	
end

function HandbookMergePanel:OnShow()
		HandbookManager.Instance.onUpdateMergeState:AddListener(self._UpdateMergeState)
		HandbookManager.Instance.onUpdateMergeselect:AddListener(self._UpdateMergeselect)
	  self.targetid = self.openArgs
	  self:SetData()
end

function HandbookMergePanel:OnHide()
		HandbookManager.Instance.onUpdateMergeState:RemoveListener(self._UpdateMergeState)
		HandbookManager.Instance.onUpdateMergeselect:RemoveListener(self._UpdateMergeselect)
end

function HandbookMergePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbook_merge))
    self.gameObject.name = "HandbookMergePanel"
    UIUtils.AddUIChild(self.parent.parent.parent.gameObject, self.gameObject)
		self.transform = self.gameObject.transform
		self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
		self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)
		self.okButton = self.transform:FindChild("Main/OkButton"):GetComponent(Button)
		self.okButton.onClick:AddListener(function() self:OnOkButton() end)

		self.left = self.transform:FindChild("Main/Left")
		self.leftName_1 = self.left:Find("Name1"):GetComponent(Text)
		local name1trans = self.leftName_1.transform
		name1trans.sizeDelta = Vector2(116, 25)
		name1trans.anchoredPosition = Vector2(-61, 17)
		self.leftName_2 = self.left:Find("Name2"):GetComponent(Text)
		local name2trans = self.leftName_2.transform
		name2trans.sizeDelta = Vector2(116, 25)
		name2trans.anchoredPosition = Vector2(61, 17)

		self.leftslotRes_1 = self.left:Find("Slot1/ItemSlot")
		self.left_slot_1 = ItemSlot.New(self.leftslotRes_1.gameObject)
		self.leftslotRes_2 = self.left:Find("Slot2/ItemSlot")
		self.left_slot_2 = ItemSlot.New(self.leftslotRes_2.gameObject)
		self.left_Desc_container = self.left:Find("Desc/ScrollRext/Container")
		self.left_desc_item = self.left:Find("Desc/ScrollRext/Container/Item")
		self.left_desc_item.gameObject:SetActive(false)
		self.leftLayout = LuaBoxLayout.New(self.left_Desc_container,{axis = BoxLayoutAxis.Y})
    --自定义的组件
		self.specuarSlotNum = self.left_slot_1.transform:Find("SpeNum"):GetComponent(Text)
		self.leftsqrLevbg = self.left_slot_1.transform:Find("levNumBg")
		self.leftsqrLev = self.left_slot_1.transform:Find("levNum"):GetComponent(Text)
		self.left_slot_select = self.left_slot_1.transform:Find("ChangeBtn"):GetComponent(Button)
		self.left_slot_select.onClick:AddListener(function() self:OnSelectFruit() end)
		self.right = self.transform:FindChild("Main/Right")
		self.rightName = self.right:Find("Name"):GetComponent(Text)
		self.rightslotRes_1 = self.right:Find("Slot/ItemSlot")
		self.right_slot = ItemSlot.New(self.rightslotRes_1.gameObject)

		self.specuarSlotNum_right = self.right_slot.transform:Find("SpeNum"):GetComponent(Text)
		
    self.rightsqrLevbg = self.right_slot.transform:Find("levNumBg")
		self.rightsqrLev = self.right_slot.transform:Find("levNum"):GetComponent(Text)
		self.right_Desc_container = self.right:Find("Desc/ScrollRext/Container")
		self.right_desc_item = self.right:Find("Desc/ScrollRext/Container/Item")
		self.right_desc_item.gameObject:SetActive(false)
		self.rightLayout = LuaBoxLayout.New(self.right_Desc_container,{axis = BoxLayoutAxis.Y})
		
		self.selectFruitPanel = HandBookSelectFruitPanel.New(self,self.transform:FindChild("SelectFruitPanel").gameObject)

		self.openButton = self.transform:FindChild("Main/OptionCon/OpenButton"):GetComponent(Button)
		self.openButton.onClick:AddListener(function() self:OpenSelectType() end)
		self.chooseType = self.openButton.transform:Find("Text"):GetComponent(Text)
		self.arrow = self.openButton.transform:Find("ImgArrow")
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
    self:OnShow()
end

function HandbookMergePanel:SetData(currId)
		self.handbook_data = DataHandbook.data_base[self.targetid]
		--fuse_id：碎片id  illusion_id：幻化果base id
		--fuse_num1 = 升1级碎片消耗数量, lev_num1：+4值
		self.handbook = HandbookManager.Instance:GetDataById(self.targetid)
		self.isActive = false
		if self.handbook ~= nil then
			  self.isActive = (self.handbook.status == HandbookEumn.Status.Active)
		end
		self.HasChooseType = false
		self.chooseType.text = TI18N("请选择强化方案")
		if self.handbook_data.fuse_flag == 1 and self.isActive and self.handbook.star_step >= 1 then
				self:UpdateLeft(currId)
				self:UpdateRight()
		end
end

function HandbookMergePanel:UpdateLeft(currId)
		self.currId = nil
		local BackPack = BackpackManager.Instance
		local itemDic = BackpackManager.Instance.itemDic
		self.illusion_id = self.handbook_data.illusion_id  --幻化果id
		self.need_illusion_Num = self.handbook_data.times--消耗幻化果的次数
		local CanUsedList = BackPack:GetFruitTimes(self.illusion_id, self.need_illusion_Num)
		self.currItemList = BackPack:GetItemByBaseid(self.illusion_id)  --同一baseid的所有物品列表
		if BackPack:GetFruitLev(currId) >= 3 then
			  currId = nil
		end
		if currId == nil then
				if next(CanUsedList) ~= nil then
						self.currItemData = CanUsedList[1]
				else
					  self.currItemData = self.currItemList[1]  --默认取第一个
				end
				if self.currItemData ~= nil then
						self.currId = self.currItemData.id
				end
		else
				self.currItemData = itemDic[currId]
				self.currId = currId
		end
		self.illusion_lev = 0 
		if self.currId ~= nil then
				--1.没有该种幻化果 2.有幻化果次数不够 3.够
				self.illusion_lev = BackPack:GetFruitLev(self.currId)  --得到该幻化果的等级
		end
		local left_base_1 = DataItem.data_get[self.illusion_id]
		local left_item_Data_1 = ItemData.New()
		left_item_Data_1:SetBase(left_base_1)
		self.left_slot_1:SetAll(left_item_Data_1)
		self.left_slot_1:SetNotips(true)
		self.left_slot_1:SetSelectSelfCallback(function() self:OnSelectFruit() end)

		if next(CanUsedList) ~= nil then
			  self.HasEnoughIllusion = true
				self.specuarSlotNum.text = string.format("<color='#ffff00'>%s次</color>", self.need_illusion_Num)
		else
			  self.HasEnoughIllusion = false
			  self.specuarSlotNum.text = string.format("<color='#ff0000'>%s次</color>", self.need_illusion_Num)
		end
		if self.illusion_lev == 0 then
			  self.leftsqrLevbg.gameObject:SetActive(false)
				self.leftsqrLev.transform.gameObject:SetActive(false)
		else
			  self.leftsqrLev.text = string.format("+%s", self.illusion_lev)
			  self.leftsqrLevbg.gameObject:SetActive(true)
			  self.leftsqrLev.transform.gameObject:SetActive(true)
		end
		self.leftName_1.text = left_base_1.name
		--BaseUtils.dump(BackpackManager.Instance.itemDic)
		local universalId = 28607  --万能碎片特殊处理
		local Num_fuse_univer = BackpackManager.Instance:GetItemCount(universalId)
		self.fuse_id = self.handbook_data.fuse_id   --图鉴id
		local Num_fuse = BackpackManager.Instance:GetItemCount(self.fuse_id)
		local curr_fuse_num = self.illusion_lev + 1
		if curr_fuse_num > 3 then curr_fuse_num = 3 end
		local need_Num_fuse = self.handbook_data["fuse_num"..curr_fuse_num]
		self.consumeList = {}
		if need_Num_fuse > Num_fuse then
				self.consumeList[self.fuse_id] = Num_fuse
				self.consumeList[universalId] = need_Num_fuse - Num_fuse
				Num_fuse = Num_fuse + Num_fuse_univer
				if need_Num_fuse > Num_fuse then
						self.HasEnoughFuse = false
				else
					  self.HasEnoughFuse = true
				end
		else
			  self.HasEnoughFuse = true
			  self.consumeList[self.fuse_id] = Num_fuse
		end
		local showIconId = self.fuse_id
		if self.HasEnoughFuse then
				--可强化时
				if self.consumeList[universalId] ~= nil then
						showIconId = universalId
				end
		end
		local left_base_2 = DataItem.data_get[showIconId]
		local left_item_Data_2 = ItemData.New()
		left_item_Data_2:SetBase(left_base_2)
		self.left_slot_2:SetAll(left_item_Data_2)
		self.left_slot_2:SetNum(Num_fuse, need_Num_fuse)
		self.left_slot_2:SetNotips(true)
		self.leftName_2.text = left_base_2.name
		self:SetLeftMsgData()
end

function HandbookMergePanel:UpdateRight(index, val)
		self.illusion_id = self.handbook_data.illusion_id  --幻化果id
		local Num_illu = BackpackManager.Instance:GetItemCount(self.illusion_id)
		local right_base = DataItem.data_get[self.illusion_id]
		local right_item_Data = ItemData.New()
		right_item_Data:SetBase(right_base)
		self.right_slot:SetAll(right_item_Data)
		self.right_slot:SetNotips(true)
		self.rightName.text = right_base.name
		local right_illusion_lev = self.illusion_lev + 1
		if right_illusion_lev == 0 then
				self.rightsqrLevbg.gameObject:SetActive(false)
				self.rightsqrLev.transform.gameObject:SetActive(false)
		else
				self.rightsqrLev.text = string.format("+%s", right_illusion_lev)
				self.rightsqrLevbg.gameObject:SetActive(true)
				self.rightsqrLev.transform.gameObject:SetActive(true)
		end
		self.specuarSlotNum_right.text = string.format("<color='#ffff00'>%s次</color>", self.need_illusion_Num)
		self:SetRightMsgData(index, val)
end

function HandbookMergePanel:OnClickClose()
		if self.parent ~= nil then
			  self.parent:UpdateItem()
			  self.parent:CheckMergeRedpoint()
			  self.parent:HideMergePanel()
	  end
	  
end

function HandbookMergePanel:OnOkButton()
		if self.HasChooseType then
				if self.HasEnoughFuse and self.HasEnoughIllusion then
						local universalId = 28607
						local list = {}
						local universalNum = self.consumeList[universalId]
						
						if universalNum ~= nil then
							  local data = NoticeConfirmData.New()
						    data.type = ConfirmData.Style.Normal
								data.content = string.format(TI18N("您背包中<color='#ae22da'>%s</color>不足，但有<color='#ae22da'>万能碎片</color>，是否直接消耗<color='#ae22da'>万能碎片x%s</color>?"),DataItem.data_get[self.fuse_id].name,universalNum)
								data.sureLabel = TI18N("确定")
						    data.cancelLabel = TI18N("取消")
						    data.sureCallback = function()
										table.insert(list,{base_id = self.fuse_id, num = self.consumeList[self.fuse_id]})
										table.insert(list,{base_id = universalId, num = self.consumeList[universalId]})
								    HandbookManager.Instance:Send17113(self.targetid, self.currId, list, self.attr_id)
						    end
								NoticeManager.Instance:ConfirmTips(data)
						else
							  table.insert(list,{base_id = self.fuse_id, num = self.consumeList[self.fuse_id]})
							  HandbookManager.Instance:Send17113(self.targetid, self.currId, list, self.attr_id)
						end
				elseif not self.HasEnoughFuse then
					  NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s不足{face_1,2}"),DataItem.data_get[self.fuse_id].name))
				elseif not self.HasEnoughIllusion then
					  NoticeManager.Instance:FloatTipsByString(TI18N("幻化果次数不足{face_1,2}"))
				end
		else
			  NoticeManager.Instance:FloatTipsByString(TI18N("请选择方案再强化{face_1,2}"))
		end
		
end

function HandbookMergePanel:OnSelectFruit()
		if self.selectFruitPanel ~= nil then
			  self.selectFruitPanel:SetData(self.illusion_id, self.targetid, self.need_illusion_Num)
		end
end

function HandbookMergePanel:ReturnSelectFruit(currId)
		--print("返回的id"..currId)
		self.HasChooseType = false
		self.chooseType.text = TI18N("请选择强化方案")
		self:UpdateLeft(currId)
		self:UpdateRight()
end


function HandbookMergePanel:OpenSelectType()
		self.arrow.transform.localScale = Vector3(1, -1, 1)
		print("self.illusion_lev"..self.illusion_lev)
		local illusion_lev = self.illusion_lev + 1
		if illusion_lev > 3 then illusion_lev = 3 end
	  self.model:OpenSelect({illusion_lev, self.targetid})
end


function HandbookMergePanel:ReturnSelectType(index, val)
		self.arrow.transform.localScale = Vector3(1, 1, 1)
		self.HasChooseType = true
		self.attr_id = index
    self.chooseType.text = KvData.attr_name[index].." +"..val
		--print("选择的属性是".. KvData.attr_name[index].."--"..val)
    self:UpdateRight(index, val)
end

function HandbookMergePanel:SetLeftMsgData()
		self.leftLayout:ReSet()
		for i,v in pairs(self.left_msg_list) do
				GameObject.DestroyImmediate(v.go)
				v = nil
		end
		self.left_msg_list = {}
		local effectList = self:GetChangeBufferData()
		-- BaseUtils.dump(effectList,"effectList")
		for i, v in pairs(effectList) do
			  local varition = v.varition
				local nattr, nattr_key = self:GetNattrData(v, true)
				if #(nattr) ~= nil then
						local tab = { }
						tab.go = GameObject.Instantiate(self.left_desc_item).gameObject
						tab.word = tab.go:GetComponent(Text)
						tab.wordRect = tab.go:GetComponent(RectTransform)

						local str = ""
						if not varition then  --变异
								str  = str.."<color='#D9BC09'>幻化效果</color>"
						else
								str  = str.."<color='#D9BC09'>变异幻化效果</color>"
						end
						for _,value in ipairs(nattr_key) do
							  local k = nattr[value]
								if k.name == 100 then
										local skill = DataSkill.data_skill_other[k.val]
										str = str..string.format("\n    %s:<color='#00ffff'>[%s]</color>", TI18N("附加技能"), skill.name)
							  elseif k.name == 101 or k.name == 102 or k.name == 103 or k.name == 104 or k.name == 105 then
									  str = str..string.format("\n    <color='#ffff00'>%s</color><color='#00ff00'>+%s</color>", KvData.attr_name[k.name], k.val)
								else
										if k.val > 0 then
											str = str..string.format("\n    %s<color='#00ff00'>+%s%%</color>", KvData.attr_name[k.name], k.val / 10)
										else
											str = str..string.format("\n    %s<color='#ff0000'>%s%%</color>", KvData.attr_name[k.name], k.val / 10)
										end
								end
						end
						tab.word.text = str
						tab.wordRect.sizeDelta = Vector2(219, tab.word.preferredHeight)
						local height = tab.word.preferredHeight
						tab.wordRect.sizeDelta = Vector2(219, height)
						self.leftLayout:AddCell(tab.go)
						self.left_msg_list[i] = tab	
				end
		end
end

function HandbookMergePanel:SetRightMsgData(attr, val)
	  -- 属性 + 值
		self.rightLayout:ReSet()
		for i,v in pairs(self.right_msg_list) do
				GameObject.DestroyImmediate(v.go)
				v = nil
		end
		self.right_msg_list = {}
		local effectList = self:GetChangeBufferData()
		for i, v in pairs(effectList) do
				local varition = v.varition
				local nattr, nattr_key = self:GetNattrData(v, true)
				if attr ~= nil and val ~= nil then
						if nattr[attr] ~= nil then
								local val2 = nattr[attr].val + val
								nattr[attr] = {name = attr, val = val2}
						else
								nattr[attr] = {name = attr, val = val}
								table.insert(nattr_key, 1, attr)
						end
				end
				if #(nattr) ~= nil then
						local tab = { }
						tab.go = GameObject.Instantiate(self.left_desc_item).gameObject
						tab.word = tab.go:GetComponent(Text)
						tab.wordRect = tab.go:GetComponent(RectTransform)

						local str = ""
						if not varition then  --变异
								str  = str.."<color='#D9BC09'>幻化效果</color>"
						else
								str  = str.."<color='#D9BC09'>变异幻化效果</color>"
						end
						for _,value in ipairs(nattr_key) do
							  local k = nattr[value]
								if k.name == 100 then
										local skill = DataSkill.data_skill_other[k.val]
										str = str..string.format("\n    %s:<color='#00ffff'>[%s]</color>", TI18N("附加技能"), skill.name)
								elseif k.name == 101 or k.name == 102 or k.name == 103 or k.name == 104 or k.name == 105 then
									  str = str..string.format("\n    <color='#ffff00'>%s</color><color='#00ff00'>+%s</color>", KvData.attr_name[k.name], k.val)
								else
										if k.val > 0 then
											str = str..string.format("\n    %s<color='#00ff00'>+%s%%</color>", KvData.attr_name[k.name], k.val / 10)
										else
											str = str..string.format("\n    %s<color='#ff0000'>%s%%</color>", KvData.attr_name[k.name], k.val / 10)
										end
								end
						end
						tab.word.text = str
						tab.wordRect.sizeDelta = Vector2(219, tab.word.preferredHeight)
						local height = tab.word.preferredHeight
						tab.wordRect.sizeDelta = Vector2(219, height)
						self.rightLayout:AddCell(tab.go)
						self.right_msg_list[i] = tab	
				end
		end
end


--得到道具对应的属性数据
function HandbookMergePanel:GetChangeBufferData()
	  local list = {}
		local handbook = DataHandbook.data_attr[string.format("%s_0",self.targetid)]
					table.insert(list, {data = DataBuff.data_list[handbook.buff], varition = false})
					if handbook.ratio > 0 then
						-- 变异几率大于0才显示变异属性
						table.insert(list, {data = DataBuff.data_list[handbook.varition_buff], varition = true})
					end
    return list
end

--设置文本
function HandbookMergePanel:GetNattrData(info, isForward)
		local nattr = {}
		local nattr_key = {}
		local currData = self.currItemData
		local curr_data_id = 0
		if currData ~= nil then
			curr_data_id = currData.id
		end
		for ii,vv in pairs(info.data.attr) do
				nattr[vv.attr_type] = {name = vv.attr_type, val = vv.val}
				table.insert(nattr_key, vv.attr_type)
		end
		if #info.data.attr_cli == 0 then
				for a, b in ipairs(info.data.effect) do
						if b.effect_type == 1 then
								nattr[100] = {name = 100, val = b.val}
								table.insert(nattr_key, 100)
						end
				end
		else
				for a, b in ipairs(info.data.attr_cli) do
						if b.effect_type == 100 then
								nattr[100] = {name = 100, val = b.val}
								table.insert(nattr_key, 100)
						end
				end
		end
		local fruitdata = BackpackManager.Instance:GetCurrFruitData(curr_data_id)
		if fruitdata.lev ~= 0 then
				local mapp = {}
				local type_num = nil
				local type = nil
				local str = ""
				for c = 1, fruitdata.lev do
						type_num = self.handbook_data["lev_num"..c]
						local type = fruitdata["fruit_lev"..c]
						if mapp[type] ~= nil then
								mapp[type] = mapp[type] + type_num
						else
								mapp[type] = type_num
						end
				end
				for ii, vv in pairs(mapp) do
						nattr[ii] = {name = ii, val = vv}
						if isForward then
								table.insert(nattr_key, 1, ii)
						else
							table.insert(nattr_key, ii)
						end
						
				end
		end
		return nattr, nattr_key
end