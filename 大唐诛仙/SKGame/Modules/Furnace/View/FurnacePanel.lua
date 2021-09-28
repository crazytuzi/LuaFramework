FurnacePanel=BaseClass(LuaUI)
--donot use param in ctor for create fuiobj
function FurnacePanel:__init(root, type)
	self.type = type
	self.URL="ui://wt6b3levu156m"
	self:__property(root)
end
function FurnacePanel:SetProperty(root)
	self.parent = root
end
function FurnacePanel:RegistUI(ui)
	self.ui = ui or UIPackage.CreateObject("Furnace","FurnacePanel")
	ui = self.ui
	self:SetXY(140, 103)
	-- debugDrag(ui)
	self.c_switchRight = ui:GetControllerAt(0)
	self.funBg = ui:GetChild("funBg")
	self.listbg = ui:GetChild("listbg")
	self.txtTarget = ui:GetChild("txtTarget")
	self.btnTip = ui:GetChild("btnTip")
	self.p1 = ui:GetChild("p1")
	self.p2 = ui:GetChild("p2")
	self.btnGot = ui:GetChild("btnGot")
	self.btnApply = ui:GetChild("btnApply")
	self.progressBar = ui:GetChild("progressBar")
	self.starConn = ui:GetChild("starConn")
	self.tipPane = ui:GetChild("tipPane")
	self.leftGroup = ui:GetChild("leftGroup")
	self.gotLabelBg = ui:GetChild("gotLabelBg")
	self.gotTitle = ui:GetChild("gotTitle")
	self.gotList = ui:GetChild("gotList")
	self.gotGroup = ui:GetChild("gotGroup")
	self.itemTitleBg1 = ui:GetChild("itemTitleBg1")
	self.itemTitle1 = ui:GetChild("itemTitle1")
	self.itemTitleBg2 = ui:GetChild("itemTitleBg2")
	self.itemTitle2 = ui:GetChild("itemTitle2")
	self.itemList = ui:GetChild("itemList")
	self.moneyItem1 = ui:GetChild("moneyItem1")
	self.moneyItem2 = ui:GetChild("moneyItem2")
	self.gotConn = ui:GetChild("gotConn")
	self.itemListGroup = ui:GetChild("itemListGroup")

	self.model = FurnaceModel:GetInstance()
	self:AddTo(self.parent)

	self.isActive = false -- 是否激活
	self.isConfig = false -- 是否配置完成
	self.stars = {}
	self.gots = {}
	self.items = {}
	self.labels = {}
	self.furnaceId = FurnaceConst.cfgType[self.type] -- 当前面板的熔炼id
	self:InitEvent()
end

function FurnacePanel:InitEvent()
	self.btnTip.onClick:Add(function ()
		self.tipPane.visible = not self.tipPane.visible
		if self.tipPane.visible then
			self.tipPane.title = FurnaceConst.paneTip[self.type]
		end
	end)
	self.btnGot.onClick:Add(function ()
		self.tipPane.visible = false
	end)
	local delay = os.clock()
	self.btnApply.onClick:Add(function ()
		self.tipPane.visible = false
		if os.clock() - delay < 0.3 then
			 UIMgr.Win_FloatTip("您操作过快，系统忙不过来，请稍候再试!")
			return
		end
		delay = os.clock()
		FurnaceCtrl:GetInstance():C_UpgradeFurnace(self.furnaceId)
	end)
	local player = SceneModel:GetInstance():GetMainPlayer()
	if player then
		local function attrChange( k, v, old )
			if k == "gold" or k == "diamond" then -- or k == "stone" or k == "bindDiamond" 
				self:SetMoney()
			end
		end
		player:RemoveEventListener(self.roleChange) -- 先清除
		self.roleChange = player:AddEventListener(SceneConst.OBJ_UPDATE, attrChange) --角色属性变化
	end

	local getMoneyFunc = function ( v )
		local data = {id="Chongzi", v=v}
		GlobalDispatcher:DispatchEvent(EventName.OPENVIEW, data)
		if data.v == 1 then
			MallController:GetInstance():OpenMallPanel(nil, 0, 3)
		elseif data.v == 2 then
			MallController:GetInstance():OpenMallPanel(1, 2)
		end
	end
	self.moneyItem1.onClick:Add(function ()
		getMoneyFunc(1)
	end)
	self.moneyItem2.onClick:Add(function ()
		getMoneyFunc(2)
	end)
	self.furnaceListChangeHandler = self.model:AddEventListener(FurnaceConst.FurnaceListChange, function (  )
		self:Update()
	end)
	self.furnaceUplevelChangeHandler = self.model:AddEventListener(FurnaceConst.FurnaceUplevelChange, function ( playerFurnace )
		self.model:UpdateItem(playerFurnace)
		if self.furnaceId == playerFurnace.furnaceId then
			self:Update()
		end
	end)
end

function FurnacePanel:CloseTips()
	if not self.tipPane then return end
	self.tipPane.visible = false
end

function FurnacePanel:Update()
	local model = self.model
	if not self.isConfig then
		self.isConfig = true
		self.gotTitle.text = FurnaceConst.paneListTitle[self.type]

		local list = model:GetCfgByFurnaceId(self.furnaceId)
		for i,v in ipairs(list) do
			if i > 1 and v.star==7 then
				local item = self.gotList:AddItemFromPool()
				item.title = v.furnaceName
				item.icon = "Icon/Goods/"..v.icon
				item.data = v
				item = FurnaceItemII.Create(item)
				item:SetData(v)
				item:SetStarNum( v.star )
				item:SetSelectCallback(function ( data )
					print("SetSelectCallback")
				end)
				-- item:SetActive( true )
				self.gots[i] = item
			end
		end

		for i,v in ipairs(FurnaceConst.fromGoods[self.type]) do
			local item = self.itemList:AddItemFromPool()
			local maketItemCfg = GetCfgData("market"):Get(v)
			local goods = GoodsVo.GetItemCfg(maketItemCfg.itemId)
			item.title = goods.name
			item:GetChild("title").color = newColorByString( GoodsVo.RareColor[goods.rare] )
			item:GetChild("txtPrice").text = maketItemCfg.price or "?"
			item:GetChild("payIcon").url = GoodsVo.GetIconUrl( maketItemCfg.moneyType )
			item.data = v
			item = FurnaceItemI.Create(item)
			item:SetData(goods)
			self.items[i] = item
		end

		for i=1,7 do
			local star = StarComp.New()
			star:AddTo(self.starConn, 46*(i-1), 0)
			self.stars[i] = star
		end
		
		self.moneyItem1.icon = GoodsVo.GetIconUrl( GoodsVo.GoodType.gold )
		self.moneyItem2.icon = GoodsVo.GetIconUrl( GoodsVo.GoodType.diamond )
		self:SetMoney()

		local gotLabel1 = GotFromComp.New()
		gotLabel1.ui.title = "击杀野外boss有几率掉落"
		gotLabel1.tlink.text = ""
		gotLabel1:AddTo(self.gotConn, 0, 10)

		local gotLabel1 = GotFromComp.New()
		gotLabel1.ui.title = "通关副本有几率获得"
		gotLabel1.tlink.text = "挑战"
		gotLabel1:AddTo(self.gotConn, 0, 52)
		gotLabel1.ui.onClick:Add(function ()
			GuideController:GetInstance():GotoFB()
		end)
		-- 
	end
	local cfgItem = nil
	local ownerPiece = 0
	local star = 0
	if not model.furnaceList[self.furnaceId] then
		cfgItem = model:GetCfgItem(0,0,self.furnaceId)
	else
		local v = model.furnaceList[self.furnaceId]
		ownerPiece = v.piece or 0
		star = v.star or 0
		cfgItem = model:GetCfgItem(v.stage, v.star, v.furnaceId)
	end
	self.txtTarget.text = cfgItem.furnaceName
	self:SetProgress(ownerPiece, cfgItem.needPiece, FurnaceConst.progressHead[self.type])
	self:SetActiveStar(star)
	if cfgItem.stage == 0 then
		self.btnApply.title = "激 活"
	else
		self.btnApply.title = "升 级"
	end
	self.ui.icon = "Icon/Goods/"..cfgItem.icon


	-- cfgItem.curProperty={{9,0},{11,0}},
	-- cfgItem.nextProperty={{9,10},{11,10}},

	-- AttrLabel  SetContent( label, value up) AddTo(self.starConn, 46*(i-1), 0)

	local label
	for i=1,#self.labels do
		label = self.labels[i]
		label:SetVisible(false)
	end
	local tempLabels = {}
	if cfgItem.curProperty then
		for i,v in ipairs(cfgItem.curProperty) do
			label = self:GetAttrLabel()
			label:SetContent( RoleVo.GetPropDefine(v[1]).name, v[2], false)
			label:AddTo(self.p1, 10, (i-1)*32+80)
			label:SetVisible(true)
			table.insert(tempLabels, label)
		end
	end
	if cfgItem.nextProperty then
		for i,v in ipairs(cfgItem.nextProperty) do
			label = self:GetAttrLabel()
			label:SetContent( RoleVo.GetPropDefine(v[1]).name, v[2], true, v[2]-cfgItem.curProperty[i][2])
			label:AddTo(self.p2, -20, (i-1)*32+80)
			label:SetVisible(true)
			table.insert(tempLabels, label)
		end
	end
	self.labels = tempLabels
	tempLabels = nil
end

function FurnacePanel:GetAttrLabel()
	if #self.labels ~= 0 then
		return table.remove(self.labels, 1)
	end
	return AttrLabel.New()
end

-- 设置激活星数
function FurnacePanel:SetActiveStar( num )
	for i=1,#self.stars do
		local star = self.stars[i]
		if i <= num then
			star:Active( true )
		else
			star:Active( false )
		end
	end
end

function FurnacePanel:SetMoney()
	local player = SceneModel:GetInstance():GetMainPlayer()
	if not player then return end
	self.moneyItem1.title = player.gold
	self.moneyItem2.title = player.diamond
end

function FurnacePanel:SetProgress( v, max, head )
	self.progressBar.value = v
	if max then
		self.progressBar.max=max
	end
	local content
	if self.progressBar.value < self.progressBar.max then
		content  = "{2}：[COLOR=#cc3333]{0}/{1}[/COLOR]"
	else
		content  = "{2}：[COLOR=#33cc33]{0}/{1}[/COLOR]"
	end
	self.progressBar:GetChild("title").text = StringFormat(content, self.progressBar.value, self.progressBar.max, head)
end

function FurnacePanel:SetVisible(b)
	LuaUI.SetVisible(self, b)
	if not b and self.tipPane then
		self.tipPane.visible = false
	end
end

function FurnacePanel:SetActive(b)
	if self.isActive == b then return end
	self.isActive = b
	self:Update()
end

function FurnacePanel:__delete()
	local player = SceneModel:GetInstance():GetMainPlayer()
	if player then player:RemoveEventListener(self.roleChange) end
	if self.model then
		self.model:RemoveEventListener(self.furnaceListChangeHandler)
		self.model:RemoveEventListener(self.furnaceUplevelChangeHandler)
	end
	self.btnTip.onClick:Clear()
	self.btnGot.onClick:Clear()
	self.btnApply.onClick:Clear()
	self.btnTip= nil
	self.btnGot= nil
	self.btnApply= nil
	self.tipPane = nil
	self.isConfig = nil
	self.model = nil
end
