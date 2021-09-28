StylePanel = BaseClass(LuaUI)

function StylePanel:__init(...)
	self:RegistUI()
	self:Config()
end

function StylePanel:SetProperty(...)
	
end

function StylePanel:Config()
	
end

function StylePanel:RegistUI()
	self.ui = UIPackage.CreateObject("Style","StylePanel");
		
	self.n6 = self.ui:GetChild("n6")
	self.listBg = self.ui:GetChild("listBg")
	self.list = self.ui:GetChild("list")
	self.role3D = self.ui:GetChild("role3D")
	self.n7 = self.ui:GetChild("n7")
	self.name = self.ui:GetChild("name")
	self.n13 = self.ui:GetChild("n13")
	self.proListBg = self.ui:GetChild("proListBg")
	self.proList = self.ui:GetChild("proList")
	self.proName = self.ui:GetChild("proName")
	self.n12 = self.ui:GetChild("n12")
	self.effectName = self.ui:GetChild("effectName")
	self.proListBg_2 = self.ui:GetChild("proListBg")
	self.eftTxt = self.ui:GetChild("eftTxt")
	self.n11 = self.ui:GetChild("n11")
	self.descName = self.ui:GetChild("descName")
	self.proListBg_3 = self.ui:GetChild("proListBg")
	self.descTxt = self.ui:GetChild("descTxt")
	self.allBtn = self.ui:GetChild("allBtn")
	self.touch = self.ui:GetChild("touch")
	self.getInfo = self.ui:GetChild("getInfo")
	self.getInfo.visible = false

	self.items = {}
	self.viewItemList = {}
	self.curShowData = nil
	self.curShowDynamciData = nil
	self.clickType = 1 --1:装备 2:卸下 3:获取

	self.touchId = -1
	self.lastTouchX = 0
	self.playerModel = nil

	self.isRefreshing = false
	self.isRefreshOK = false
	self.curListData = nil
	self.curListType = 1 --1:全部 2:拥有
	self.activeNewVo = nil

	self:AddEvent()

	-- 标签
	local res0 = UIPackage.GetItemURL("Common","btn_fenye1")
	local res1 = UIPackage.GetItemURL("Common","btn_fenye2")
	local tabDatas = {
		{label="全部", res0=res0, res1=res1, id="0", red=false}, 
		{label="已拥有", res0=res0, res1=res1, id="1", red=false},
	}
	local offX, offY = 10, 46

	self.btn1ClickFirst = true
	local btn1Click = function()
		if self.btn1ClickFirst then
			self.btn1ClickFirst = false
			return
		end
		self.curListType = 1
		self:ShowAllList()
	end
	local btn2Click = function()
		self.curListType = 2
		self:ShowActivedList()
	end

	local function tabClickCallback( idx, id )
		if id == "0" then
			btn1Click()
		elseif id == "1" then
			btn2Click()
		end
	end
	local ctrl, tabs = CreateTabbar(self.ui, 1, tabClickCallback, tabDatas, offX, offY-55, 0, 111, 111, 46)
end

function StylePanel.Create(ui, ...)
	return StylePanel.New(ui, "#", {...})
end

function StylePanel:AddEvent()
	self.allBtn.onClick:Add(self.OnPutOnBtnClickHandler, self)
	self.touch.onTouchBegin:Add(self.RotationPlayerModel,self)

	self.selectHandler = StyleModel:GetInstance():AddEventListener(StyleConst.SelectStyleItem, function (data) self:OnSelectItemHandler(data) end)
	self.readyHandler = StyleModel:GetInstance():AddEventListener(StyleConst.StyleDataReadyOk, function () self:MappingRefreshList() end)
	self.updateHandler = StyleModel:GetInstance():AddEventListener(StyleConst.StyleDataUpdateOk, function () self:Refresh() end)
	self.activeHandler = StyleModel:GetInstance():AddEventListener(StyleConst.StyleActive, function (data) self:Active(data) end)
end

function StylePanel:RemoveEvent()
	self.allBtn.onClick:Remove(self.OnPutOnBtnClickHandler, self)
	self.touch.onTouchBegin:Remove(self.RotationPlayerModel,self)
	Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
	Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)

	StyleModel:GetInstance():RemoveEventListener(self.selectHandler)
	StyleModel:GetInstance():RemoveEventListener(self.readyHandler)
	StyleModel:GetInstance():RemoveEventListener(self.updateHandler)
	StyleModel:GetInstance():RemoveEventListener(self.activeHandler)
end

function StylePanel:SetVisible(v)
	self:ModelToggleShow(v)
	LuaUI.SetVisible(self, v)
end

--创建角色3d模型
function StylePanel:CreatePlayerModel(dressStyle)
	local callback = function ( o )
		if o == nil then return end
		if self.playerModel then
			self:UnloadPlayer()
			destroyImmediate(self.playerModel) 
		end
		self.playerModel = GameObject.Instantiate(o)
		self.playerModel.name = dressStyle
		self.playerModel.transform.localScale = Vector3.New(260, 260, 260)
		self.playerModel.transform.localPosition = Vector3.New(40, -80, 2000)
		self.playerModel.transform.localEulerAngles = Vector3.New(0, 180, 0)

		self.role3D:SetNativeObject(GoWrapper.New(self.playerModel)) -- ui 3d对象加入
	end
	if (not self.playerModel) or (self.playerModel and tostring(self.playerModel.name) ~= tostring(dressStyle)) then
		LoadPlayer(dressStyle, callback)
	end
end
function StylePanel:Close()
	if self.playerModel then
		self:UnloadPlayer()
		destroyImmediate(self.playerModel) 
	end
	self.playerModel = nil
end

function StylePanel:ModelToggleShow(value)
	if self.activeNewVo then
		self.role3D.visible = false
	else
		self.role3D.visible = value
	end
end

--旋转角色模型
function StylePanel:RotationPlayerModel( context )
	if self.touchId == -1 then
		local evt = context.data
		self.touchId = evt.touchId
		Stage.inst.onTouchMove:Add( self.onTouchMove, self )
		Stage.inst.onTouchEnd:Add( self.onTouchEnd, self )
	end
end

--touchmove
function StylePanel:onTouchMove(context)
	if not self.playerModel then log("人物数据模型为nil") return end
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local evt = context.data
		if self.lastTouchX ~= 0 then
			local rotY = self.playerModel.transform.localEulerAngles.y - (evt.x - self.lastTouchX)
			self.playerModel.transform.localEulerAngles = Vector3.New(0, rotY, 0)
		end
	end
	self.lastTouchX = evt.x
end

--touchend
function StylePanel:onTouchEnd( context )
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		self.lastTouchX = 0
		Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
		Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	end
end

function StylePanel:OnPutOnBtnClickHandler()
	if not self.curShowData then return end
	if self.clickType == 1 then --装备
		StyleController:GetInstance():C_PutonFashion(self.curShowData.fashionId)
	elseif self.clickType == 2 then --卸下
		StyleController:GetInstance():C_PutdownFashion(self.curShowData.fashionId)
	else --购买
		local itemId = nil
		cfg = GetCfgData("market"):Get(self.curShowData.marketId)
		if cfg then
			itemId = cfg.itemId
		end
		if itemId and PkgModel:GetInstance():GetTotalByBid(itemId) > 0 then
			UIMgr.Win_Alter("提示", StringFormat("背包已经有[{0}]，无法重复购买!", self.curShowData.name), "确定", function() end, nil)		
		else
			MallController:GetInstance():QuickBuy(self.curShowData.marketId)
		end
	end
end

function StylePanel:Active(data)
	self.activeNewVo = data
	if self.isRefreshOK then
		self:PlayActiveEft()
	end
end

function StylePanel:PlayActiveEft()
	if not self.activeNewVo then return end
	self:SelectItem(self.activeNewVo.fashionId)
	local styleActivePanel = StyleActivePanel.New()
	styleActivePanel:SetData(self.activeNewVo)
	UIMgr.ShowCenterPopup(styleActivePanel,function()
		self:ModelToggleShow(true)
	end)
	self.activeNewVo = nil
	self:ModelToggleShow(false)
end

function StylePanel:OnSelectItemHandler(data)
	self.curShowData = data
	self:Refresh()
end

function StylePanel:Refresh()
	self.curShowDynamciData = StyleModel:GetInstance():GetStyleDynamicData(self.curShowData.fashionId) 

	self.name.text = self.curShowData.name
	self.descTxt.text = self.curShowData.des

	self.proList:RemoveChildrenToPool()
	for i = 1, #self.curShowData.baseProperty do
		local prop = self.proList:AddItemFromPool()	
		local pName = prop:GetChild("TitleName")
		local pValue = prop:GetChild("TitleValue")
		pName.text = RoleVo.GetPropDefine(self.curShowData.baseProperty[i][1]).name
		pValue.x = pName.x + pName.width + 10
		pValue.text = self.curShowData.baseProperty[i][2]

		if i == #self.curShowData.baseProperty then
			prop:GetChild("line").visible = false
		end
	end

	--if self.curShowDynamciData then
		--self:CreatePlayerModel(self.curShowData.dressStyle)
		--self.getInfo.visible = false
	--else
		--self.getInfo.visible = true

		-- local playerVo = SceneModel:GetInstance():GetMainPlayer()
		-- local roleCfg = GetCfgData("newroleDefaultvalue"):Get(playerVo.career)
		-- local dressStyle = 0
		-- if roleCfg and roleCfg.dressStyle then
		-- 	dressStyle = tostring(roleCfg.dressStyle)
		-- end
		-- self:CreatePlayerModel(dressStyle)
	--end
	self:CreatePlayerModel(self.curShowData.dressStyle)
	
	local buffCfg = GetCfgData("buff"):Get(self.curShowData.buffId[1])
	if buffCfg then
		self.eftTxt.text = buffCfg.desc
	else
		self.eftTxt.text = ""
	end

	if self.curShowDynamciData then
		if self.curShowDynamciData.dressFlag == 1 then
			self.allBtn.text = "卸下"
			self.clickType = 2
		else
			self.allBtn.text = "装备"
			self.clickType = 1
		end
	else
		self.allBtn.text = "获取"
		self.clickType = 3
	end

	for i = 1, #self.viewItemList do
		self.viewItemList[i]:UpdateState()
	end
end

function StylePanel:MappingRefreshList()
	if self.curListType == 1 then
		self:ShowAllList()
	elseif self.curListType == 2 then
		self:ShowActivedList()
	end
end

function StylePanel:ShowAllList()
	local data = StyleModel:GetInstance():GetStyleData()
	self:RefreshItemList(data)
end

function StylePanel:ShowActivedList()
	local data = StyleModel:GetInstance():GetActivedStyleData()
	self:RefreshItemList(data)
end

function StylePanel:RefreshItemList(data)
	if not self.isRefreshing then 
		self.curListData = data
		self:ClearContent()
		self.index = 1
		self.isRefreshing = true
		self.frameCount = 0
		self.viewItemList = nil
		self.viewItemList = {}
		self.isRefreshOK = false
		RenderMgr.Remove("StylePanel:RefreshContentInFrame")
		RenderMgr.Add(function () self:RefreshContentInFrame() end, "StylePanel:RefreshContentInFrame")
	end
end

function StylePanel:RefreshContentInFrame()
	if self.frameCount % 2 == 0 then
		if self.curListData and self.index <= #self.curListData then
			local item = self:GetStyleItemFromPool()
			item:Update(self.curListData[self.index])
			item.ui.x = 324
			item.ui.y = (self.index - 1)*138

			if self.index == 1 then
				item:Select()
			end

			local posTweener = TweenUtils.TweenFloat(item.ui.x, 0, 0.2, function(data)
					item.ui.x = data
				end)
			TweenUtils.SetEase(posTweener, 21)
			self.list:AddChild(item.ui)
			self.index = self.index + 1
			table.insert(self.viewItemList, item)
		else
			RenderMgr.Remove("StylePanel:RefreshContentInFrame")
			self.curListData = nil
			self.index = nil
			self.isRefreshing = false
			self.isRefreshOK = true
			if self.activeNewVo then
				self:PlayActiveEft()
			end
		end
	end
	self.frameCount = self.frameCount + 1
end

function StylePanel:SelectItem(fashionId)
	if #self.viewItemList < 1 then return end
	for i = 1, #self.viewItemList do
		if self.viewItemList[i] and self.viewItemList[i].data and self.viewItemList[i].data.fashionId == fashionId then
			self.viewItemList[i]:Select()
		end
	end
end

function StylePanel:GetStyleItemFromPool()
	for i = 1, #self.items do
		if self.items[i].ui.parent == nil then
			return self.items[i]
		end
	end
	local item = StyleItem.New()
	table.insert(self.items, item)
	return item
end

function StylePanel:DestoryPool()
	for i = 1, #self.items do
		self.items[i]:Destroy()
	end
	self.items = {}
end

function StylePanel:ClearContent()
	self.list:RemoveChildren()
end

function StylePanel:UnloadPlayer()
	if self.curShowData  and self.curShowData.dressStyle then
		UnLoadPlayer(self.curShowData.dressStyle , false)
	end
end

function StylePanel:__delete()
	self:RemoveEvent()
	if self.playerModel then
		self:UnloadPlayer();
		destroyImmediate(self.playerModel) 
	end

	self.playerModel = nil
	self:DestoryPool()
	self.viewItemList = nil
	self.curShowData = nil
	self.curListData = nil
	self.curShowDynamciData = nil
	self.activeNewVo = nil

	StyleItem.CurSelectItem = nil
end