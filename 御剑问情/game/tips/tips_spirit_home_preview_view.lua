TipsSpiritHomePreviewView = TipsSpiritHomePreviewView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 40			-- 最大格子数
local BAG_PAGE_NUM = 2					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页个数
local BAG_ROW = 4						-- 行数
local BAG_COLUMN = 5					-- 列数
local BOX_NUM = 4 					-- 箱子个数

function TipsSpiritHomePreviewView:__init()
	self.ui_config = {"uis/views/tips/spirithometip_prefab","SpiritHomePreviewTip"}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false

	self.select_index = 1
	self.box_render_list = {}
	self.bag_cell = {}
	self.data_list = {}
end

function TipsSpiritHomePreviewView:__delete()
end

function TipsSpiritHomePreviewView:ReleaseCallBack()
	self.select_index = 1
	self.data_list = {}

	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	for k,v in pairs(self.box_render_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.box_render_list = {}

    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end

	self.bag_list_view = nil	
	self.btn_str = nil
	self.title_str = nil
	self.show_other_text = nil
	self.other_text = nil
end

function TipsSpiritHomePreviewView:LoadCallBack()
	self.bag_list_view = self:FindObj("ListView")
	local list_delegate = self.bag_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	for i = 1, BOX_NUM do
		local obj = self:FindObj("BoxRender" .. i)
		if obj ~= nil then
			self.box_render_list[i] = SpiritHomePreviewRender.New(obj)
			self.box_render_list[i]:SetIndex(i)			
		end
	end

	self.btn_str = self:FindVariable("BtnStr")
	self.title_str = self:FindVariable("Title")
	self.show_other_text = self:FindVariable("ShowOtherText")
	self.other_text = self:FindVariable("OtherText")

	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("Opera", BindTool.Bind(self.OnClickOpera, self))
end

function TipsSpiritHomePreviewView:OpenCallBack()
	local cfg = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)
	if cfg ~= nil and cfg.reward_item_list ~= nil then
		self.data_list = cfg.reward_item_list
	end

	if self.bag_list_view and self.bag_list_view.list_page_scroll2.isActiveAndEnabled then
		self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
		self:Flush()
	end
end

function TipsSpiritHomePreviewView:CloseCallBack()
    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end
end

function TipsSpiritHomePreviewView:OnClickClose()
	self:Close()
end

function TipsSpiritHomePreviewView:OnClickOpera()
	if self.select_index == nil then
		return
	end

    local is_my = SpiritData.Instance:GetIsMyHome()
    if is_my then
      local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
      SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_GET_REWARD, main_role_vo.role_id, self.select_index - 1)
    else
        local cfg = SpiritData.Instance:GetMySpiritInOther()
        if cfg.item_id <= 0 then
            SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseEquipJingLing)
            return
        end

        local _, num = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)
        if num == nil or num <= 0 then
            SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritHomeNoThing)
            return
        end

        TipsCtrl.Instance:OpenSpiritHomeConfirmView(self.select_index)
    end
end

function TipsSpiritHomePreviewView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function TipsSpiritHomePreviewView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN
	cell:SetHighLight(false)
	cell:SetInteractable(false)
	cell:SetData(self.data_list[grid_index + 1] or {}, false)
	cell:SetIconGrayScale(false)
end

function TipsSpiritHomePreviewView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function TipsSpiritHomePreviewView:GetSelectIndex()
	return self.select_index
end

function TipsSpiritHomePreviewView:FlushList()
	local cfg = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)
	if cfg ~= nil and cfg.reward_item_list ~= nil then
		self.data_list = cfg.reward_item_list
	end

	if self.bag_list_view ~= nil then
		self.bag_list_view.list_view:Reload()
	end

	if self.box_render_list ~= nil then
		for k,v in pairs(self.box_render_list) do
			if v ~= nil then
				v:SetData({select_index = self.select_index})
			end
		end
	end
end

function TipsSpiritHomePreviewView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "all" == k then
			self:FlushList()
			self:CheckTimer()
			if self.btn_str ~= nil then
				local str_tab = Language.JingLing.SpiritHomeHarvestBtn
				local btn_index = SpiritData.Instance:GetIsMyHome() and 0 or 1
				self.btn_str:SetValue(str_tab[btn_index])
			end

			if self.title_str then
				local str_tab = Language.JingLing.SpiritHomePerviewTitle
				local btn_index = SpiritData.Instance:GetIsMyHome() and 0 or 1
				self.title_str:SetValue(str_tab[btn_index])
			end

			local is_my_home =  SpiritData.Instance:GetIsMyHome() 
			if self.show_other_text ~= nil then
				self.show_other_text:SetValue(not is_my_home)
			end
			
			if not is_my_home then
				if self.other_text ~= nil then
                    local per = SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_hunli_per") or 0
                    local value_max =SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_lingjing_max") or 0
                    local min_num = SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_item_min") or 0
                    local max_num = SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_item_max") or 0
                    self.other_text:SetValue(string.format(Language.JingLing.SpiritHomeHarvestHelp, per, value_max, min_num, max_num))
				end
			end

		elseif "flush_item" == k then
			if v.index ~= nil then
				self.select_index = v.index
				self:FlushList()
			end
		end
	end
end

function TipsSpiritHomePreviewView:CheckTimer()
    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end

    if self.select_index == nil then
        return
    end

    local limlit = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit")
    if limlit == nil then
        return
    end

    local cfg = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)
    if cfg == nil or next(cfg) == nil then
        return
    end

    local need_send = false
    local read_index = self.select_index

    if cfg.reward_times >= limlit then
    	local index = SpiritData.Instance:GetHasRewardIndex()
    	if index ~= nil then
    		read_index = index
    		need_send = true
    	end
    else
		need_send = true
    end

    if need_send then
        local interval = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_interval")
        local total_time = cfg.reward_beging_time + interval - TimeCtrl.Instance:GetServerTime()
        if total_time <= 0 then
            total_time = interval
        end

        if total_time > 0 then
            self.count_timer = CountDown.Instance:AddCountDown(total_time, 0.1, BindTool.Bind(self.UpdateBottom, self, read_index))
        end 
    end
end

function TipsSpiritHomePreviewView:UpdateBottom(index, elapse_time, total_time)
    if elapse_time - total_time >= 0 then
        self:CompleteBottom()
    end
end

function TipsSpiritHomePreviewView:CompleteBottom()
    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end

    --local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local role_id = SpiritData.Instance:GetHomeRoleId()
    SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_REASON.JING_LING_HOME_REASON_DEF, role_id)
end

-----------------------------------------------------------------------------
SpiritHomePreviewRender = SpiritHomePreviewRender or BaseClass(BaseRender)

function SpiritHomePreviewRender:__init()
	self.is_select = false
	self.is_has_spirit = self:FindVariable("HasSpirit")
	self.is_has_reward = self:FindVariable("HasReward")
	self.is_nothing = self:FindVariable("NoThing")
	self.box_res = self:FindVariable("BoxRes")
	self.spirit_name = self:FindVariable("SpiritName")
	self.show_select = self:FindVariable("ShowSelect")
	self.type_str = self:FindVariable("SpiritType")
	self.img_select = self:FindObj("ImgSeltct")
	self.is_show_select = self:FindVariable("IsSelect")
	self.show_red = self:FindVariable("ShowRed")

	self:ListenEvent("EventBox", BindTool.Bind(self.OnClickItem, self))
	self:ListenEvent("OnClickItem", BindTool.Bind(self.OnClickItem, self))
end

function SpiritHomePreviewRender:__delete()
	self.is_has_spirit = nil
	self.is_has_reward = nil
	self.is_nothing = nil
	self.box_res = nil
	self.spirit_name = nil
	self.show_select = nil
	self.type_str = nil
	self.img_select = nil
	self.is_show_select = nil
	self.show_red = nil
end

function SpiritHomePreviewRender:OnClickBox()

end

function SpiritHomePreviewRender:OnClickItem()
	if self.index ~= nil then
		TipsCtrl.Instance:FlushPreviewByIndex(self.index)
	end
end

function SpiritHomePreviewRender:SetIndex(index)
	self.index = index
end

function SpiritHomePreviewRender:GetIndex()
	return self.index
end

function SpiritHomePreviewRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomePreviewRender:FlushAll(data)
end

function SpiritHomePreviewRender:OnFlush()
	if self.index == nil then
		return
	end

	local data, reward_num = SpiritData.Instance:GetSpiritHomeRewardList(self.index)
	if data == nil or next(data) == nil then
		return
	end

	local has_reward = false
	if self.is_has_reward ~= nil then
		has_reward = reward_num > 0
		self.is_has_reward:SetValue(has_reward)
	end

	local has_spirit = false
	if self.is_has_spirit ~= nil then
		has_spirit = has_reward and data.item_id > 0
		self.is_has_spirit:SetValue(has_spirit and has_reward)
		if has_spirit and has_reward then
			local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
			if self.spirit_name ~= nil and item_cfg ~= nil then
				self.spirit_name:SetValue(item_cfg.name)
			end
		end
	end

	if self.is_nothing ~= nil then
		self.is_nothing:SetValue((not has_spirit) and (not has_reward))
	end

	-- if self.show_select ~= nil then
	-- 	local flag = false
	-- 	if self.data.select_index ~= nil then
	-- 		flag = self.data.select_index == self.index
	-- 	end

	-- 	self.show_select:SetValue(flag)
	-- end
	local is_my = SpiritData.Instance:GetIsMyHome()

	if self.show_red ~= nil then
		--local max_num = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit") or 0
		--self.show_red:SetValue(data.reward_times >= max_num and is_my)
		local other_cfg = SpiritData.Instance:GetSpiritOtherCfg() or {}
		local is_can_reward = TimeCtrl.Instance:GetServerTime() - data.last_get_time >= (other_cfg.home_get_reward_interval or 0) * 8
		self.show_red:SetValue(reward_num > 0 and is_my and is_can_reward)
	end

	if self.box_res ~= nil then
		local box_color = SpiritData.Instance:GetSpiritBoxType(data.reward_times)
		self.box_res:SetAsset(ResPath.GetGuildBoxIcon(box_color, false))
	end

	local is_my_home =  SpiritData.Instance:GetIsMyHome() 
	if data.item_id and data.item_id > 0 then
		local str = ""
		if is_my_home then
			local data = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)
			if data ~= nil and data.jingling_quality ~= nil then
				local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
				if item_cfg ~= nil and ITEM_COLOR[item_cfg.color] ~= nil then
					str = ToColorStr(data.jingling_quality, ITEM_COLOR[item_cfg.color])
				end
			end
		else
			str = string.format(Language.JingLing.SpiritHomePreviewCap, data.capability or 0)
		end

		if self.type_str ~= nil then
			self.type_str:SetValue(str)
		end
	end

	if self.data.select_index ~= nil then
		self:ShowSelectAni(self.data.select_index == self.index and has_reward)
	end
end

function SpiritHomePreviewRender:ShowSelectAni(is_show)
	if self.img_select ~= nil then
		if self.is_show_select ~= nil then
			self.is_show_select:SetValue(is_show)
		end

		self.img_select.animator.enabled = is_show
		self.img_select.animator:SetBool("Show",is_show)
		if not is_show then
			self.img_select.transform.localScale = Vector3(1, 1, 1)
		end
	end
end