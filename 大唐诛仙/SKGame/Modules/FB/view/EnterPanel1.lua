EnterPanel1 = BaseClass(CommonBackGround)

function EnterPanel1:__init( ... )

	self.ui = UIPackage.CreateObject("FB","EnterPanel1");
	
	self.n0 = self.ui:GetChild("n0")
	self.btnClose = self.ui:GetChild("btnClose")
	self.n6 = self.ui:GetChild("n6")
	self.title = self.ui:GetChild("title")
	self.desc = self.ui:GetChild("desc")
	self.n10 = self.ui:GetChild("n10")
	self.hasLabel = self.ui:GetChild("hasLabel")
	self.count = self.ui:GetChild("count")
	self.icon = self.ui:GetChild("icon")
	self.btn1 = self.ui:GetChild("btn1")
	self.btn2 = self.ui:GetChild("btn2")

	self.mapId1 = 0
	self.mapId2 = 0
	self.costItemId = 0
	self.costName = nil
	self.map1NeedCost = 0
	self.map2NeedCost = 0

	self:AddEvent()
end

function EnterPanel1:AddEvent()
	self.btnClose.onClick:Add(self.OnBtnCloseClick, self)
	self.btn1.onClick:Add(self.OnBtn1Click, self)
	self.btn2.onClick:Add(self.OnBtn2Click, self)
end

function EnterPanel1:RemoveEvent()
	self.btnClose.onClick:Remove(self.OnBtnCloseClick, self)
	self.btn1.onClick:Remove(self.OnBtn1Click, self)
	self.btn2.onClick:Remove(self.OnBtn2Click, self)
end

function EnterPanel1:OnBtnCloseClick()
	UIMgr.HidePopup()
end

function EnterPanel1:EnterFB(mapId)
	local zdModel = ZDModel:GetInstance()
	local num = zdModel:GetMemNum()

	local model = PkgModel:GetInstance()
	local now = #model:GetOnGrids() or 0
	local total = model.bagGrid or 0
	local msg = StringFormat("您的背包快满了( [COLOR=#ff0000]{0}[/COLOR]/{1} ) 请尽快清理", now, total)
	local mapcfg = GetCfgData("mapManger"):Get(mapId)
	local needBagTip = true
	if mapcfg and mapcfg.rewardType == 0 then
		needBagTip = false
	end

	if (zdModel:GetTeamId() > 0 and num == 1) or zdModel:GetTeamId() == 0 then
		local function cb()
			if FBModel:GetInstance():CheckNeedTransfer(mapId) then
				GlobalDispatcher:DispatchEvent(EventName.StopCollect)
				local data = { tType = "enterfb", text = "副本传送中", args = mapId }
				GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity, data)
				FBController:GetInstance():CloseMainPanel()
			else
				FBController:GetInstance():RequireEnterInstance(mapId)
			end
			UIMgr.HidePopup()
		end
		if total - now < 8 and needBagTip then
			UIMgr.Win_Confirm("背包提示", msg, "进入副本", "整理背包", cb, function()
				PkgCtrl:GetInstance():Open()
			end, true)
		else
			cb()
		end
	else
		local tipsContent = GetCfgData("game_exception"):Get(1207)
		if not TableIsEmpty(tipsContent) and tipsContent.exceptionMsg then
			UIMgr.Win_FloatTip(tipsContent.exceptionMsg)
		end
	end
end

function EnterPanel1:OnBtn1Click()
	local player = SceneController:GetInstance():GetScene():GetMainPlayer()
	if player:IsDie() then return end
	if PkgModel:GetInstance():GetTotalByBid(self.costItemId) < self.map1NeedCost then
		Message:GetInstance():TipsMsg(StringFormat("{0}数量不足，无法进入",self.costName))
	else
		self:EnterFB(self.mapId1)
	end
 	UIMgr.HidePopup()
end

function EnterPanel1:OnBtn2Click()
	local player = SceneController:GetInstance():GetScene():GetMainPlayer()
	if player:IsDie() then return end
	if PkgModel:GetInstance():GetTotalByBid(self.costItemId) < self.map2NeedCost then
		Message:GetInstance():TipsMsg(StringFormat("{0}数量不足，无法进入",self.costName))
	else
		self:EnterFB(self.mapId2)
	end
	UIMgr.HidePopup()
end

function EnterPanel1:Update(itemData)
	if #itemData.effectValue1 == 2 then
		self.mapId1 = itemData.effectValue1[1]
		self.mapId2 = itemData.effectValue1[2]
	else
		error("item表 "..itemData.id.."行的 effectValue1列 必须有2个元素")
	end
	self.costItemId = itemData.id
	self.costName = itemData.name
	local cfgData1 = GetCfgData("mapManger"):Get(self.mapId1)
	if cfgData1 then
		self.title.text = cfgData1.map_name
		self.desc.text = cfgData1.mapDes
		self.hasLabel.text = StringFormat("拥有的{0}",itemData.name)
		self.count.text = PkgModel:GetInstance():GetTotalByBid(self.costItemId)
		local expendStr = cfgData1.expendStr[1]

		local costItemData1 = GetCfgData("item"):Get(expendStr[2])
		if costItemData1 then
			self.icon.url = StringFormat("Icon/Goods/{0}", costItemData1.icon)
			self.btn1:GetChild("icon").url = StringFormat("Icon/Goods/{0}", costItemData1.icon)
		end
		self.map1NeedCost = tonumber(expendStr[3])
		if PkgModel:GetInstance():GetTotalByBid(self.costItemId) < self.map1NeedCost then
			self.btn1:GetChild("count").text = "[color=#ff0000]"..self.map1NeedCost.."[/color]"
		else
			self.btn1:GetChild("count").text = "[color=#FFF9E2]"..self.map1NeedCost.."[/color]"
		end
	end

	local cfgData2 = GetCfgData("mapManger"):Get(self.mapId2)
	if cfgData2 then
		local expendStr = cfgData2.expendStr[1]
		local costItemData2 = GetCfgData("item"):Get(expendStr[2])
		if costItemData2 then
			self.btn2:GetChild("icon").url = StringFormat("Icon/Goods/{0}", costItemData2.icon)
		end
		self.map2NeedCost = tonumber(expendStr[3])
		if PkgModel:GetInstance():GetTotalByBid(self.costItemId) < self.map2NeedCost then
			self.btn2:GetChild("count").text = "[color=#ff0000]"..self.map2NeedCost.."[/color]"
		else
			self.btn2:GetChild("count").text = "[color=#FFF9E2]"..self.map2NeedCost.."[/color]"
		end
	end
end

-- 布局UI
function EnterPanel1:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
end

function EnterPanel1:__delete()
	self:RemoveEvent()
end