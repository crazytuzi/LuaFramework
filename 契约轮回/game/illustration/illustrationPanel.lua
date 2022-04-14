illustrationPanel = illustrationPanel or class("illustrationPanel",BaseItem)

function illustrationPanel:ctor (parent_node)
    self.abName = "illustration"
	self.assetName = "illustrationPanel"
	self.layer = "UI"

--[[ 	self.panel_type = 2
	self.use_background = true ]]

	self.global_events = {}

	self.ill_model = illustrationModel:GetInstance()
	self.ill_model_events = {}

	self.bag_model = BagModel.GetInstance()
	self.bag_model_events = {}

	self.cur_first_id = nil  --当前一级菜单id
	self.cur_second_id = nil --当前二级菜单id

	self.right_normal_panel = nil --右侧没有组合的界面
	self.right_compose_panel =nil --右侧有组合的界面

	self.btn_decompose_red_dot = nil  --分解按钮上的红点

	BaseItem.Load(self)

	BagController.GetInstance():RequestBagInfo(BagModel.illustration)
end

function illustrationPanel:dctor (  )
    if self.fold_menu then
		self.fold_menu:destroy()
		self.fold_menu = nil
	end
	if self.right_normal_panel then
		self.right_normal_panel:destroy()
		self.right_normal_panel = nil
	end
	if self.right_compose_panel then
		self.right_compose_panel:destroy()
		self.right_compose_panel = nil
	end
	if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end
    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
	end
	
	if self.btn_decompose_red_dot then
		self.btn_decompose_red_dot:destroy()
		self.btn_decompose_red_dot = nil
	end
end

function illustrationPanel:LoadCallBack(  )
    self.nodes = {
		"left_content/left_menu",
		"left_content/btn_bag",
		"left_content/btn_decompose",
		"right_content",
    }
    self:GetChildren(self.nodes)

	self:InitUI()
	self:AddEvent()

	self:CheckReddot()
end

function illustrationPanel:InitUI()
    self:InitMenuList()
end

function illustrationPanel:AddEvent(  )

	local function call_back()
		self:CheckReddot()
	end
	self.bag_model_events[#self.bag_model_events + 1] = self.bag_model:AddListener(illustrationEvent.LoadillustrationItems,call_back)
	
	local function call_back()
		self:CheckReddot()
	end
	self.ill_model_events[#self.ill_model_events + 1] = self.ill_model:AddListener(illustrationEvent.Updateillustration,call_back)

	--在图鉴界面获取图鉴时也能触发红点刷新
	local function call_back(bag_id)
		if bag_id == BagModel.illustration  then
			BagController.GetInstance():RequestBagInfo(BagModel.illustration)
		end
	end
	self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum,call_back)
	self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(BagEvent.AddItems,call_back)

	--监听树形菜单点击事件
	self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick))
	self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecondItemClick))
	
	
	--图鉴背包
    local function call_back(  )
		local panel = lua_panelMgr:GetPanelOrCreate(illustrationBagPanel)
  		panel:Open()
	end
	AddClickEvent(self.btn_bag.gameObject,call_back)

	--图鉴分解
	local function call_back(  )
		local panel = lua_panelMgr:GetPanelOrCreate(illustrationDecomposePanel)
		panel:Open()
	end
	AddClickEvent(self.btn_decompose.gameObject,call_back)


end

--初始化树形菜单
function illustrationPanel:InitMenuList ()
	self.fold_menu = illustrationFoldMenu(self.left_menu, nil, self, illustrationOneMenu, illustrationTwoMenu)
	--self.fold_menu:SetStickXAxis(8.5)
	
	self.fold_menu:SetData(self.ill_model.first_menu, self.ill_model.second_menu, 1, 2, 2)
	self.fold_menu:SetDefaultSelected(1,1)
	self:UpdateRightContent(1,1)
end

--一级菜单点击监听
function illustrationPanel:HandleLeftFirstClick(index)
	--logError("点击了一级菜单："..index)
	self:UpdateRightContent(index,1)
end

--二级菜单点击监听
function illustrationPanel:HandleLeftSecondItemClick(first_id, second_id)
	--logError("点击了二级菜单："..first_id.."-"..second_id)
	self:UpdateRightContent(first_id,second_id)
end

--刷新右侧界面
function illustrationPanel:UpdateRightContent (first_id,second_id)

	if self.cur_first_id == first_id and self.cur_second_id == second_id then
		return
	end

	self.cur_first_id = first_id
	self.cur_second_id = second_id

	local cfg = self.ill_model.menu_cfg[first_id][second_id]

	for k,v in pairs(cfg) do
		if v.ill_id[1] == 0 then
			--logError("点击了有组合的菜单")
			self.right_compose_panel = self.right_compose_panel or illustrationRightComposePanel(self.right_content)
			
			SetVisible(self.right_compose_panel.transform,true)
			if self.right_normal_panel then
				SetVisible(self.right_normal_panel.transform,false)
			end

			local data = {}
			data.com_ids = v.com_id
			self.right_compose_panel:SetData(data)
		else
			--logError("点击了没有组合的菜单")
			self.right_normal_panel = self.right_normal_panel or illustrationRightNormalPanel(self.right_content)
			
			SetVisible(self.right_normal_panel.transform,true)

			if self.right_compose_panel then
				SetVisible(self.right_compose_panel.transform,false)
			end
			
			local data = {}
			data.top_btn_config = cfg
			data.top_btn_config.first_id = first_id
			data.top_btn_config.second_id = second_id
			self.right_normal_panel:SetData(data)
		end
		return
	end
end

--检查红点
function illustrationPanel:CheckReddot()
	--logError("检查树形菜单红点")
	self.fold_menu:CheckReddot()

	--检查分解按钮红点
	local flag = self.ill_model:CheckDecomposeReddot()
	if not flag and not self.btn_decompose_red_dot then
		return
	end

	self.btn_decompose_red_dot = self.btn_decompose_red_dot or RedDot(self.btn_decompose.transform)
    self.btn_decompose_red_dot:SetRedDotParam(flag)
    SetLocalPositionZ(self.btn_decompose_red_dot.transform,0)
    SetAnchoredPosition(self.btn_decompose_red_dot.transform,27.6,25.1)
end