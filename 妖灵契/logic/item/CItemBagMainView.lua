---------------------------------------------------------------
--背包主界面


---------------------------------------------------------------

local CItemBagMainView = class("CItemBagMainView", CViewBase)

function CItemBagMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemBagMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_RegDict = {}
	self.m_RegList = {}
end

function CItemBagMainView.OnCreateView(self)

	g_ItemCtrl.m_RecordItembBagViewState = 1
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MainItemPart = self:NewUI(2, CItemBagPropPart, true, self)	
	self.m_BagWealthPart = self:NewUI(3, CItemBagWealthInfoPart, true, self)
	self.m_SellInfoPart = self:NewUI(4, CItemBagSellInfoPart, true, self)
	
	self:InitContent()
end

function CItemBagMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

--part 之间数据交互使用通知
--[[注册的事件类型
1.ShowSellInfo, 
参数1,bool，true表示进入出售状态，false表示退出出售状态
参数2,int  表示进入出售状态时，默认选中出售的道具系统id(0表示没有选中)

2.SelectSellItem
参数1,bool，true选择为出售状态，false表示取消出售状态
参数2,int， 表示当前背包类型下，该道具的序号
参数3.int,  表示当前物品出售的个数(如果当前为取消状态下时，忽略)
参数4,tItem, 物品信息

3.ChangeSellCount
参数1,int， 表示当前背包类型下，该道具的序号
参数2,int,  表示该道具的出售数量

4.SwitchTab
参数1,int  表示切换后的标签Id

5.OnSort
参数1,int  表示切换后的排序方式

5.OnRefreshBagItem 刷新背包界面

6.SyncSelectSellItem
参数1，int 表示该选中道具，新的序号
参数2，tItem 物品信息
]]
function CItemBagMainView.SetValueChangeCallback( self ,regid, callback)

	self.m_RegDict[regid] = callback
	table.insert(self.m_RegList, regid)

end

function CItemBagMainView.OnValueChange(self, bType, ...)

	for i, regid in ipairs(self.m_RegList) do
		local callback = self.m_RegDict[regid]
		if callback then
			callback(self, bType, ...)
		end
	end
end

function CItemBagMainView.Destroy(self )
	g_ItemCtrl.m_RecordItembBagViewState = 0
	self.m_RegDict = {}
	self.m_RegList = {}	
	--关闭背包需要整理背包
	-- if g_ItemCtrl:CanArrangeItem() then
	-- 	g_ItemCtrl:C2GSArrangeItem()
	-- end
	self:CloseSubView()
	CViewBase.Destroy(self)
end

function CItemBagMainView.SetActive(self, bActive, noMotion)
	CViewBase.SetActive(self, bActive, noMotion)
	if bActive == false then
		self:CloseSubView()
	end
end

function CItemBagMainView.CloseSubView(self)
	local closeViewTable = {"CItemTipsBaseInfoView", "CItemTipsMoreView", "CItemTipsEquipChangeView", "CItemTipsAttrEquipChangeView",
							"CItemTipsPackageSelectView", "CItemTipsPropComposeView", "CExchangeCoinView", "CExchangeEnergyView", "CItemPartnerChipExchangeView"}
	for k, v in pairs(g_ViewCtrl:GetViews()) do
		for _k, _v in pairs(closeViewTable) do
			if v.classname == _v then
				v:CloseView()
			end
		end
	end
end


return CItemBagMainView		