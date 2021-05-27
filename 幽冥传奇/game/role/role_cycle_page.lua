--角色轮回页面
RoleCyclePage = RoleCyclePage or BaseClass()


function RoleCyclePage:__init()
	self.view = nil
end	

function RoleCyclePage:__delete()

	self:RemoveEvent()
	-- if self.locks_list ~= nil then
	-- 	for k,v in pairs(self.locks_list) do
	-- 		if v then
	-- 			v:DeleteMe()
	-- 		end
	-- 	end
	-- end
	-- self.locks_list = {}
	
	if nil ~= self.buy_scroll_list then
		self.buy_scroll_list:DeleteMe()
		self.buy_scroll_list = nil
	end	

	if self.cycle_progressbar then
		self.cycle_progressbar:DeleteMe()
		self.cycle_progressbar = nil
	end
	self.view = nil
end	

--初始化页面接口
function RoleCyclePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:IsWndRPartShowExchange(false)
	self:CreateViewElement()
	self:CreateLocks()
	self.cycle_progressbar = ProgressBar.New()
	self.cycle_progressbar:SetView(self.view.node_t_list.prog9_role_cycle.node)
	self.cycle_progressbar:SetTotalTime(1)
	self.cycle_progressbar:SetTailEffect(991, nil, true)
	self.cycle_progressbar:SetEffectOffsetX(-20)
	self.cycle_progressbar:SetPercent(0)
	-- for i = 1, 5 do
	-- 	self.view.node_t_list["lock_" .. i].node:setVisible(false)
	-- end

	self:UpdateShop()
	self:InitEvent()
	
end	

--初始化事件
function RoleCyclePage:InitEvent()
	self.view.node_t_list.btn_get_xiuwei.node:addClickEventListener(BindTool.Bind(self.OnGetXiuwei, self))
	self.view.node_t_list.btn_practice.node:addClickEventListener(BindTool.Bind(self.OnPractice, self))
	self.view.node_t_list.btn_back.node:addClickEventListener(BindTool.Bind(self.OnBack, self))
	self.view.node_t_list.btn_confir_exc.node:addClickEventListener(BindTool.Bind(self.OnConfirExchange, self))
	self.view.node_t_list.btn_interp.node:addClickEventListener(BindTool.Bind(self.OnInterp, self))

	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)
	
	self.shop_event = GlobalEventSystem:Bind(ShopEventType.FAST_SHOP_DATA_UPDATE, BindTool.Bind(self.UpdateShop, self))
end

--移除事件
function RoleCyclePage:RemoveEvent()
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end

	if self.shop_event then
		GlobalEventSystem:UnBind(self.shop_event)
		self.shop_event = nil
	end
end

--更新视图界面
function RoleCyclePage:UpdateData(data)
	self:IsWndRPartShowExchange(false)
	self:FlushCycleInfo()
	self:FlushExchaCultivation()
	self:FlushCycleWndLPart()
end	

function RoleCyclePage:CreateViewElement()
	if nil == self.buy_scroll_list then
		local ph = self.view.ph_list.ph_cyc_buy_list
		self.buy_scroll_list = ListView.New()
		self.buy_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ComposeShopItemRender, nil, nil, self.view.ph_list.ph_cyc_buy_item)
		self.view.node_t_list.layout_cycle_exchange.node:addChild(self.buy_scroll_list:GetView(), 100)
		self.buy_scroll_list:SetItemsInterval(5)
		self.buy_scroll_list:SetJumpDirection(ListView.Top)
		-- self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_2))
		self.buy_scroll_list:JumpToTop()
	end
end	

--轮回升级界面刷新
function RoleCyclePage:FlushCycleInfo()
	local cyclLv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CYCLE_LEVEL)
	--print("===cyclLv==", cyclLv)
	local consumeCfg = RoleCycleData.GetCycleUpgradeConsumCfg(cyclLv + 1)
	-- PrintTable(consumeCfg)
	local attrAddCfg = RoleCycleData.GetCycleAttrAddCfgByProf()
	local curAttrAddCfg = attrAddCfg[cyclLv]
	local nLvAttrAddCfg = attrAddCfg[cyclLv + 1]
	local cur_attr_content = Language.Common.No
	local nxt_attr_content = Language.Common.AlreadyTopLv
	if curAttrAddCfg then
		cur_attr_content = RoleData.FormatAttrContent(curAttrAddCfg)
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_cur_attr.node, cur_attr_content, 22)

	if nLvAttrAddCfg then
		nxt_attr_content = RoleData.FormatAttrContent(nLvAttrAddCfg, {value_str_color = COLOR3B.GREEN})
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_nex_attr.node, nxt_attr_content, 22, COLOR3B.BRIGHT_GREEN)
	local circleSoul = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CYCLE_SOUL)
	local percent = 0 
	if consumeCfg then
		percent = math.min(100, circleSoul / consumeCfg[1].count * 100)
		self.view.node_t_list.lbl_xiuwei_rate.node:setString(circleSoul .. "/" .. consumeCfg[1].count)
	else
		self.view.node_t_list.lbl_xiuwei_rate.node:setString(Language.Common.AlreadyTopLv)
		percent = 100
	end
	self.cycle_progressbar:SetPercent(percent, false)
	self.view.node_t_list.btn_practice.node:setEnabled((consumeCfg or nLvAttrAddCfg) and percent >= 100)
end

--兑换修为界面刷新
function RoleCyclePage:FlushExchaCultivation()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	self.view.node_t_list.lbl_cur_lv.node:setString(role_level)
	local exchanCfg = RoleCycleData.GetCurRoleLvExchanCultivaCfg(role_level)
	-- PrintTable(exchanCfg)
	if exchanCfg then
		self.view.node_t_list.lbl_afterExc_xiuwei.node:setString(exchanCfg.addSoul)
		self.view.node_t_list.lbl_cycle_consu_money.node:setString(exchanCfg.consumes[1].count)
	else
		self.view.node_t_list.lbl_afterExc_xiuwei.node:setString(0)
		self.view.node_t_list.lbl_cycle_consu_money.node:setString(0)
	end
	self.view.node_t_list.lbl_afterExc_lv.node:setString(role_level - 1)

end

--刷新轮回等级层级信息
function RoleCyclePage:FlushCycleWndLPart()
	-- print("+++++RoleCyclePage:FlushCycleWndLPart+++++")
	local cycLv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CYCLE_LEVEL)
	-- self.view.node_t_list.img_dao.node:setVisible(cycLv > 0)
	-- self.view.node_t_list.img_floor.node:setVisible(cycLv > 0)
	local daoGrade = 1
	local floor = 0
	if cycLv > 0 then
		daoGrade = math.floor((cycLv - 1) / PerCycleLvStep) + 1 
		floor = cycLv % PerCycleLvStep
	end
	self.view.node_t_list.img_dao.node:loadTexture(ResPath.GetRole("dao_" .. daoGrade))
	self.view.node_t_list.img_floor.node:loadTexture(ResPath.GetRole("floor_" .. floor))
	for i = 1, 5 do
		if self.locks_list[i] then
			self.locks_list[i]:setVisible(i > floor)
		end
	end

end

function RoleCyclePage:UpdateShop()
	if self.buy_scroll_list then
		self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_2))
	end
end	

function RoleCyclePage:CreateLocks()
	self.locks_list = {}
	for i = 1, 6 do
		local ph = self.view.ph_list["lock_" .. i]
		local lockImg = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("lockChain"), true)
		lockImg:setVisible(i >= 6)
		self.view.node_t_list.layout_cycle_common.node:addChild(lockImg, 99)
		table.insert(self.locks_list, lockImg)
	end
end

function RoleCyclePage:IsWndRPartShowExchange(is_show)
	self.view.node_t_list.layout_cycle_info.node:setVisible(not is_show)
	self.view.node_t_list.layout_cycle_exchange.node:setVisible(is_show)
end

function RoleCyclePage:OnGetXiuwei()
	self:IsWndRPartShowExchange(true)
end

function RoleCyclePage:OnPractice()
	RoleCycleCtrl.CycleReq()
end

function RoleCyclePage:OnBack()
	self:IsWndRPartShowExchange(false)
end

function RoleCyclePage:OnConfirExchange()
	RoleCycleCtrl.ExchanCycleCultivaReq()
end

function RoleCyclePage:OnInterp()
	DescTip.Instance:SetContent(Language.Role.LunHuiContent, Language.Role.LunHuiTitle)
end

function RoleCyclePage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_CYCLE_SOUL then
		self:FlushCycleInfo()
	elseif key == OBJ_ATTR.ACTOR_CYCLE_LEVEL then
		self:FlushCycleWndLPart()
	elseif key == OBJ_ATTR.CREATURE_LEVEL then
		self:FlushExchaCultivation()
	end
end