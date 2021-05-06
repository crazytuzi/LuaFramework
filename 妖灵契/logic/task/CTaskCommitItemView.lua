local CTaskCommitItemView = class("CTaskCommitItemView", CViewBase)

function CTaskCommitItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/CommitItemView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTaskCommitItemView.OnCreateView(self)
	self.m_Sessionidx = ""
	self.m_RecordTable = {}

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CommitBtn = self:NewUI(2, CButton)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_ItemBoxSry = self:NewUI(4, CScrollView)
	self.m_BoxGrid = self:NewUI(5, CGrid)
	self.m_CloneCommitBox = self:NewUI(6, CCommitBox)

	self:InitContent()
end

function CTaskCommitItemView.InitContent(self)
	self.m_CloneCommitBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CommitBtn:AddUIEvent("click", callback(self, "OnCommitBtn"))
end

function CTaskCommitItemView.SetContent(self, oTask, sessionidx)
	self.m_Sessionidx = sessionidx
	self.m_TitleLabel:SetText("[b][502E10]任务提交物品[-][/b]")
	local sidList, tNeedItem = CTaskHelp.GetTaskFindItemDic(oTask)
	self.m_NeedItem = tNeedItem
	--local itemTable = g_ItemCtrl:GetBagItemTableBySidList(sidList)
	--self:InitItemBoxGrid(itemTable)
end

function CTaskCommitItemView.InitItemBoxGrid(self, itemTable)
	if not itemTable then
		return
	end
	-- 获取可提交道具数据
	for _,t in pairs(itemTable) do
		-- 排序
		table.sort(t, function (a, b)
			local aPos = a:GetValue("pos")
			local bPos = b:GetValue("pos")
			return aPos < bPos
		end)
		
		for _,v in ipairs(t) do
			local oItemBox = self.m_CloneCommitBox:Clone(function (commitBox)
				local exist = false
				local sid = commitBox.m_Item:GetValue("sid")
				local itemList = self.m_RecordTable[sid] or {}
				local needCount = (self.m_NeedItem and self.m_NeedItem[sid].amount) or 0

				for i,m in ipairs(itemList) do
					if m.m_ID == commitBox.m_Item.m_ID then
						exist = true
						commitBox:ForceSelected(false)
						table.remove(itemList, i)
						break
					end
				end
				if not exist then
					local count = 0
					for _,m in ipairs(itemList) do
						count = count + m:GetValue("amount")
					end
					
					if count < needCount then
						table.insert(itemList, commitBox.m_Item)
						self.m_RecordTable[sid] = itemList
					else
						g_NotifyCtrl:FloatMsg("已经足够了（More Enough）")
						commitBox:ForceSelected(false)
					end
				end
				return exist
			end)
			self.m_BoxGrid:AddChild(oItemBox)
			oItemBox:SetBagItem(v)
			oItemBox:SetActive(true)
		end
	end
end

function CTaskCommitItemView.OnCommitBtn(self)
	local itemCount = 0
	local amountTable = {}
	for k,t in pairs(self.m_RecordTable) do
		amountTable[k] = {}
		for _,v in ipairs(t) do
			if not amountTable[k].itemName then
				amountTable[k].id = v:GetValue("id")
				amountTable[k].itemName = v:GetValue("name")
				amountTable[k].amount = 0
			end
			local amount = v:GetValue("amount")
			itemCount = itemCount + amount
			amountTable[k].amount = amountTable[k].amount + amount
		end
	end

	if itemCount > 0 then
		for k,v in pairs(self.m_NeedItem) do
			local amount = amountTable[k].amount or 0
			if amount < v.amount then
				g_NotifyCtrl:FloatMsg(string.format("提交物品#G%s[-]数量不足#G%s[-]个", amountTable[k].itemName, v.amount))
				return
			end
		end

		local commitList = {}
		for k,v in pairs(amountTable) do
			local t = {
				id = v.id,
				amount = v.amount,
			}
			table.insert(commitList, t)
		end

		netother.C2GSCallback(self.m_Sessionidx, nil, commitList)
		self.m_RecordTable = nil
		self:CloseView()
	else
		g_NotifyCtrl:FloatMsg("未选择提交物品")
	end
end

return CTaskCommitItemView