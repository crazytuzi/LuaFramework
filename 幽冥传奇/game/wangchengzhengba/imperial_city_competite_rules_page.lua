--攻城战规则奖励页面
ImperialCityRulesPage = ImperialCityRulesPage or BaseClass()


function ImperialCityRulesPage:__init()
	self.view = nil
	self.conq_cells_list = {}
	self.cap_cells_list = {}
end	

function ImperialCityRulesPage:__delete()
	self:RemoveEvent()
	self.view = nil
	self.parent_layout = nil
	
	if next(self.conq_cells_list) then
		for k,v in pairs(self.conq_cells_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.conq_cells_list = {}
	end

	if next(self.cap_cells_list) then
		for k,v in pairs(self.cap_cells_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cap_cells_list = {}
	end
end	

--初始化页面接口
function ImperialCityRulesPage:InitPage(view)
	if not view then ErrorLog("ImperialCityRulesPage View Does Not Exist. InitPage Failed!!!!!") return end
	--绑定要操作的元素
	self.view = view
	self.parent = view and view.node_t_list.layout_atk_rules
	self:CreateCells()
	self:InitEvent()
	local scroll_node = self.parent.scroll_base_rules.node
	self.rich_content = XUI.CreateRichText(100, 10, 450, 0, false)
	scroll_node:addChild(self.rich_content, 100, 100)
end	

--初始化事件
function ImperialCityRulesPage:InitEvent()
	if not self.parent then return end

	XUI.AddClickEventListener(self.parent.btn_back.node, BindTool.Bind(self.OnBack, self), true)
	self.manager_info_handler = GlobalEventSystem:Bind(GongchengEventType.GONGCHENG_WIN_MANAGER_INFO,BindTool.Bind(self.OnManagerInfoChange,self))
end

--移除事件
function ImperialCityRulesPage:RemoveEvent()
	if self.manager_info_handler then
		GlobalEventSystem:UnBind(self.manager_info_handler)
		self.manager_info_handler = nil
	end

end

function ImperialCityRulesPage:OnManagerInfoChange()
	self:UpdateData()
end	

--更新视图界面
function ImperialCityRulesPage:UpdateData(data)
	if not self.parent then return end
	self.parent.lbl_conq_guild.node:setString(WangChengZhengBaData.Instance:GetWinnerGuildName())
	local temp_name = WangChengZhengBaData.Instance:GetHighJifenGuildName()
	self.parent.lbl_top1_guild.node:setString(temp_name)
	
	local date_t = WangChengZhengBaData.GetNextOpenTimeDate() or {}
	local weekday = date_t and (date_t.weekday == 0 and 7 or date_t.weekday) or 2
	local content = string.format(Language.WangChengZhengBa.Rule_Content[1], date_t.month or "01", date_t.day or "01", Language.Common.CHNWeekDays[weekday])
	local scroll_node = self.parent.scroll_base_rules.node
	HtmlTextUtil.SetString(self.rich_content, content or "")
	self.rich_content:refreshView()

	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(self.rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	self.rich_content:setPosition(scroll_size.width / 2, inner_h - 10)

	-- 默认跳到顶端
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
	-- RichTextUtil.ParseRichText(self.parent.rich_base_rules.node, content)
end	

function ImperialCityRulesPage:CreateCells()
	if not self.view then return end
	self.conq_cells_list = {}
	self.cap_cells_list = {}
	local ph = nil
	for i = 1, 4 do
		ph = self.view.ph_list["ph_conq_cell_" .. i]
		local conq_cell = BaseCell.New()
		conq_cell:SetPosition(ph.x, ph.y)
		self.parent.node:addChild(conq_cell:GetView(), 90)
		table.insert(self.conq_cells_list, conq_cell)

		ph = self.view.ph_list["ph_cap_cell_" .. i]
		local cap_cell = BaseCell.New()
		cap_cell:SetPosition(ph.x, ph.y)
		self.parent.node:addChild(cap_cell:GetView(), 90)
		table.insert(self.cap_cells_list, cap_cell)
	end

    self:SetCellsData()
end


function ImperialCityRulesPage:SetCellsData()  
    local data = WangChengZhengBaData.Instance:GetGongChengZhanReward()
    local data_1 = WangChengZhengBaData.Instance:GetGongChengZhanMaxScoreReward()
    
    for i, v in ipairs(self.conq_cells_list) do
        if data[i] then
            v:SetData(data[i])
        end
    end
    for i,v in ipairs(self.cap_cells_list) do
        v:SetData(data_1[i])
    end
end


function ImperialCityRulesPage:OnBack()
	self.view:ShowIndex(TabIndex.imperial_city_competite)
end