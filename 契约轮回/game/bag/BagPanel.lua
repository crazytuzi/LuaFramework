--
-- @Author: chk
-- @Date:   2018-08-20 16:44:11
--
BagPanel = BagPanel or class("BagPanel",WindowPanel)
local BagPanel = BagPanel

function BagPanel:ctor()
	self.abName = "bag"
	self.assetName = "BagPanel"
	self.layer = "UI"
	--self.use_background = true
	self.panel_type = 2
	self.events = {}
	self.global_events = {}
	self.stigmataEvents = {}
	self.model = BagModel.GetInstance()
	self.stigmataModel = StigmataModel:GetInstance()
	self.is_exist_always = false
	self.show_sidebar = true		--是否显示侧边栏
	if self.show_sidebar then		-- 侧边栏配置
		self.sidebar_data = {
			{text = ConfigLanguage.Bag.Bag,id = 1,img_title = "bag:bag_bag_f", title_icon = "system:title_icon_1", icon = "bag:bag_icon_bag_s",dark_icon = "bag:bag_icon_bag_n",},
			{text = ConfigLanguage.Bag.Warehouse,id = 2,img_title = "bag:bag_ware_f",title_icon = "system:title_icon_1",icon = "bag:bag_icon_ware_s",dark_icon = "bag:bag_icon_ware_n",},
			
			{text = ConfigLanguage.Bag.Stigmata,id = 3,img_title = "bag:bag_soul_f",title_icon = "system:title_icon_1",icon = "bag:bag_icon_ware_s",dark_icon = "bag:bag_icon_ware_n",
			  show_lv = GetSysOpenDataById("110@6"), 
			  show_task = GetSysOpenTaskById("110@6"),
			  open_lv = GetSysOpenDataById("110@6"), 
			  open_task = GetSysOpenTaskById("110@6"),
			}
		}
	end

	self.jump_param = {}
end

function BagPanel:dctor()
	GlobalEvent:Brocast(GoodsEvent.CloseTipView)
	self.model.baseGoodSettorCLS = nil

	for i, v in pairs(self.global_events) do
		GlobalEvent:RemoveListener(v)
	end
	for i=1, #self.events do
		self.model:RemoveListener(self.events[i])
	end
	self.model = nil

	for i=1, #self.stigmataEvents do
		self.stigmataModel:RemoveListener(self.stigmataEvents[i])
	end
	self.stigmataModel = nil
	self.stigmataEvents = nil

	self.jump_param = nil
end

function BagPanel:OnDisable()
	--GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function BagPanel:Open(jump_param)
	self.jump_param = jump_param
	WindowPanel.Open(self)
end

function BagPanel:LoadCallBack()
	self.nodes = {
		"PanelContainer",
		"BagContainer",
		"bg",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()

	self.bg = GetImage(self.bg)
	self:LoadRolePanel()
	--self:SwitchCallBack(1)
	local baground = self:GetChild("PanelBackgroundTwo(Clone)")
	local bagroundRect = baground.transform:GetComponent('RectTransform')
	SetAnchoredPosition(baground,0,bagroundRect.anchoredPosition.y)
	local res = "bag_big_bg"
	lua_resMgr:SetImageTexture(self,self.bg, "iconasset/icon_big_bg_"..res, res,nil,nil,false)

	--请求已佩戴圣痕数据
	StigmataController:GetInstance():RequestSoulList()
end

function BagPanel:AddEvent()
	self.global_events [#self.global_events+1] = GlobalEvent:AddListener(BagEvent.CloseBagPanel,handler(self,self.DealClosePanel))
	self.events[#self.events+1] = self.model:AddListener(BagEvent.SmeltRedDotEvent, handler(self,self.UpdateRedDot))
	self.events[#self.events+1] = self.model:AddListener(BagEvent.OpenBagShowPanel,handler(self,self.BagShowPanelOpen))

	self.stigmataEvents[#self.stigmataEvents+1] = self.stigmataModel:AddListener(StigmataEvent.UpdateReddot, handler(self, self.UpdateRedDotWithStigmata))
end

function BagPanel:DealClosePanel()
	self:Close()
end

function BagPanel:LoadRolePanel()
	self.bagPanel = BagShowPanel(self.BagContainer,"UI")
end

function BagPanel:OpenCallBack()
	self:UpdateView()
	self:SetTabIndex(BagModel.openPanelIndex)

	--index相同的情况下不会触发switch callback 只能这样了
	if self.switch_index == 3 and self.jump_param[1] == 3 then
		self.stigmata_panel:SetJumpParam(self.jump_param)
	end

end

function BagPanel:UpdateView( )
	
end

function BagPanel:CloseCallBack(  )

	if self.role_panel then
		self.role_panel:destroy()
		self.role_panel = nil
	end

	if self.warehouse_panel ~= nil then
		self.warehouse_panel:destroy()
		self.warehouse_panel = nil
	end

	if self.stigmata_panel ~= nil then
		self.stigmata_panel:destroy()
		self.stigmata_panel = nil
	end

	if self.bagPanel ~= nil then
		self.bagPanel:destroy()
		self.bagPanel = nil
	end
end

function BagPanel:SwitchCallBack(index)
	if self.child_node then
	   	 self.child_node:SetVisible(false)
	end
	if index == 1 then
		SetVisible(self.bg,true)
		GoodsModel.GetInstance().isOpenWarePanel  = false
		self.model:Brocast(BagEvent.OpenWarePanel,false)
		self.model:Brocast(BagEvent.OpenBagShowPanel,true)
		--self.model.baseGoodSettorCLS:SetSelected(false)
		--self.model.baseGoodSettorCLS = nil

		if not self.role_panel then
			self.role_panel = BagRolePanel(self.PanelContainer,"UI")
		end
		self:PopUpChild(self.role_panel)
	elseif index == 2 then
		SetVisible(self.bg,true)
		GoodsModel.GetInstance().isOpenWarePanel  = true
		self.model:Brocast(BagEvent.OpenWarePanel,true)
		self.model:Brocast(BagEvent.OpenBagShowPanel,true)
		--self.model.baseGoodSettorCLS = nil

		if not self.warehouse_panel then
			self.warehouse_panel = WareHouseShowPanel(self.PanelContainer,"UI")
		end
		self:PopUpChild(self.warehouse_panel)
	elseif index == 3 then	--圣痕
		SetVisible(self.bg,false)
		GoodsModel.GetInstance().isOpenWarePanel  = false
		self.model:Brocast(BagEvent.OpenWarePanel,false)
		self.model:Brocast(BagEvent.OpenBagShowPanel,false)
		if not self.stigmata_panel then
			self.stigmata_panel = StigmataPanel(self.PanelContainer,"UI")
		end
		self:PopUpChild(self.stigmata_panel)
		self.stigmata_panel:SetJumpParam(self.jump_param)
		
	end
end

function BagPanel:BagShowPanelOpen(enable)
	SetVisible(self.BagContainer,enable)
end

--更新红点
function BagPanel:UpdateRedDot( )
	local results = self.model:GetCanSmeltEquips()
	local sell_num = self.model:GetCanSellItems()
	local num = self.model:FilterSmelt()
	local open_level = tonumber(String2Table(Config.db_game["smelt_lv"].val)[1])
	local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    local show_reddot = ((level>=open_level and num > 5) or sell_num >= 20)
	self:SetIndexRedDotParam(1, show_reddot)
end

--更新圣痕相关红点
function BagPanel:UpdateRedDotWithStigmata(param)

	
	--判断是否有可升级圣痕
	local show_reddot1 = self.stigmataModel:GetCanStigmataLevelUp()

	--判断是否有可佩戴圣痕
	local show_reddot2 = self.stigmataModel:GetCanStigmataPutOn()

	self:SetIndexRedDotParam(3, show_reddot1 or show_reddot2)
end

