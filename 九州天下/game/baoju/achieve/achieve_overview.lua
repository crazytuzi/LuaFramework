------------------------------------------------------------
--成就总览View
------------------------------------------------------------
AchieveOverViewView = AchieveOverViewView or BaseClass(BaseRender)
local MAX_ACHIEVE_COUNT = 10

function AchieveOverViewView:__init(instance, parent_view)
	self.parent_view = parent_view
	self.select_index = 1
	self.second_index = 1

end

function AchieveOverViewView:LoadCallBack()
	-- self.scroller_1_select_number = 1

	-- local cell_data = AchieveData.Instance:GetRewardTitleDataList()
	-- for i=1,#cell_data do
	-- 	if cell_data[i].flag then
	-- 		self.scroller_1_select_number = i
	-- 		break
	-- 	end
	-- end

	self:ListenEvent("GetAllClick", BindTool.Bind(self.GetAllClick, self))
	self.receive_bt = self:FindObj("ReceiveBt")

	self:CreatCell()
	self:InitScroller_2()
end

function AchieveOverViewView:__delete()
	if self.cell_list_2 then
		for k,v in pairs(self.cell_list_2) do
			v:DeleteMe()
		end
		self.cell_list_2 = {}
	end

	if self.item_cell_list then
		for _,v in pairs(self.item_cell_list) do
			if type(v) == "table" then
				for _,v2 in pairs(v) do
					v2:DeleteMe()
				end
			end
		end
		self.item_cell_list = {}
	end

end

function AchieveOverViewView:GetAllClick()
	local data = AchieveData.Instance:GetCompleteList()

	for k,v in pairs(data) do
		AchieveCtrl.Instance:SendFetchReward(v.reward_id)
	end
end

function AchieveOverViewView:FlushReceiveBt()
	self.receive_bt.button.interactable = false
	self.receive_bt.grayscale.GrayScale = 255
	local data = AchieveData.Instance:GetCompleteList()

	for k,v in pairs(data) do
		if v.flag == AchieveRewardFlag.CanFetch then
			self.receive_bt.button.interactable = true
			self.receive_bt.grayscale.GrayScale = 0
			break
		end
	end
end

function AchieveOverViewView:OnAchieveChange()
	self.leftBarList[self.select_index].select_btn.accordion_element.isOn = true
	self.item_cell_list[self.select_index][self.second_index].root_node.toggle.isOn = true
	self:Scoller2ReloadData(true)
	self:FlushReceiveBt()
end

--默认选择第一个
function AchieveOverViewView:OpenCallBack()
	GlobalTimerQuest:AddDelayTimer(function()
		self:OnAchieveChange()
	end, 0)
end

--滚动条2-重新加载数据
function AchieveOverViewView:Scoller2ReloadData(keep_position)
	if self.scroller_2 == nil then
		return
	end
	self.scroller_2_data = AchieveData.Instance:GetThirdRewardDataList(self.select_index, self.second_index)
	if self.scroller_2_data == nil then
		return
	end
	if keep_position then
		self.scroller_2.scroller:RefreshActiveCellViews()
	else
		self.scroller_2.scroller:ReloadData(0)
	end
	local achieve_list = AchieveData.Instance:GetAllCfgInfo()
	-- 刷新红点
	for i = 1, #achieve_list do
		local is_show = false
		for k,v in pairs(self.item_cell_list[i]) do
			v:FlushNum()
			if v:GetIsShowRed() then
				is_show = true
				break
			end
		end
		self.leftBarList[i].red_point:SetValue(is_show)
	end	
end

-- -- 滚动条2-初始化
function AchieveOverViewView:InitScroller_2()
	self.cell_list_2 = {}
	self.scroller_2_data = {}
	self.scroller_2 = self:FindObj("ScrollView2")

	local delegate_2 = self.scroller_2.list_simple_delegate
	-- 生成数量
	delegate_2.NumberOfCellsDel = function()
		return #self.scroller_2_data
	end
	-- 格子刷新
	delegate_2.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local data = self.scroller_2_data[data_index]

		if nil == self.cell_list_2[cell] then
			self.cell_list_2[cell] = Achieve_ScrollCell_2.New(cell.gameObject)
			self.cell_list_2[cell].mother_view = self
		end
		data.data_index = data_index
		self.cell_list_2[cell]:SetData(data)
	end
end

-- 二级滚动条格子-重载数据
function AchieveOverViewView:GetScrollerData(data_index)
	return self.scroller_2_data[data_index]
end


----------------------- 左边滚动
-----------------------------------------------动态生成Cell------------------------------------------------------
function AchieveOverViewView:CreatCell()
	self.achieve_all_list = AchieveData.Instance:GetAllCfgInfo()
	self.leftBarList = {}
	for i = 1, MAX_ACHIEVE_COUNT do
		self.leftBarList[i] = {}
		self.leftBarList[i].select_btn = self:FindObj("Btn_" .. i)
		self.leftBarList[i].list = self:FindObj("List_" .. i)
		self.leftBarList[i].btn_text = self:FindVariable("Name_" .. i)
		self.leftBarList[i].icon = self:FindVariable("Icon_" .. i)
		self.leftBarList[i].red_point = self:FindVariable("Red_point_" .. i)
		self:ListenEvent("OnClick_" .. i ,BindTool.Bind(self.OnClickButton, self, i))
	end
	self:CreateList()
end

function AchieveOverViewView:OnClickButton(index)
	self.select_index = index
end

function AchieveOverViewView:CreateList()
	self.leftBarList[self.select_index].select_btn.accordion_element.isOn = false
	self.leftBarList[self.select_index].list:SetActive(false)
	local cfg_list = AchieveData.Instance:GetAllCfgInfo()
	self.item_list = {}
	self.item_cell_list = {}
	for i = 1, #cfg_list do
		self.leftBarList[i].select_btn:SetActive(true)
		self.leftBarList[i].btn_text:SetValue(cfg_list[i].client_type_str)
		self:LoadCell(i)
	end
	if #cfg_list == MAX_ACHIEVE_COUNT then
		return
	end
	for i = #cfg_list + 1, MAX_ACHIEVE_COUNT do
		self.leftBarList[i].select_btn:SetActive(false)
	end
end

function AchieveOverViewView:LoadCell(index)
	local achieve_list = AchieveData.Instance:GetSingleList(index)
	self.item_cell_list[index] = {}
	UtilU3d.PrefabPreLoad("uis/views/baoju", "AchieveItem3", function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #achieve_list do
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.leftBarList[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.leftBarList[index].list.toggle_group
			local item_cell = AchieveItem.New(obj)
			item_cell:InitCell(i, achieve_list[i])
			item_cell:SetAchieve(self)
			item_cell:SetFirstType(index)
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[index][i] = item_cell
		end
	end)
end

function AchieveOverViewView:GetCurrentIndex()
	return self.select_index
end

------------------------------------------------
AchieveItem = AchieveItem or BaseClass(BaseCell)
function AchieveItem:__init(instance)
	self.name = self:FindVariable("Name")
	self.is_show_red = self:FindVariable("IsShowRedPoint")
	self.idnex = 0
	self.first_type = 0
	self.is_show = false
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
	self.can_buy_num = 0
end

function AchieveItem:__delete()
	self.can_buy_num = nil
	self.idnex = nil
end

function AchieveItem:InitCell(idnex, data_list)
	self.idnex = idnex
	self.data_list = data_list
end

function AchieveItem:SetAchieve(achieve_view)
	self.achieve_view = achieve_view
end

function AchieveItem:SetFirstType(first_type)
	self.first_type = first_type
	self:FlushNum()
end

function AchieveItem:FlushNum()
	local complete_num, is_show = AchieveData.Instance:GetCompleteNum(self.first_type, self.idnex)
	local all_num = AchieveData.Instance:GetChildNum(self.first_type, self.idnex)
	self.name:SetValue(string.format(Language.Achieve.AchieveName, self.data_list.client_childtype_str, complete_num, all_num))
	self.is_show = is_show
	self.is_show_red:SetValue(self.is_show)
end

function AchieveItem:OnItemClick(is_click)
	if is_click then
		self.achieve_view.second_index = self.idnex
		self.achieve_view:Scoller2ReloadData()
	end
end

function AchieveItem:GetIsShowRed()
	return self.is_show
end

----------------------------------------------------------------------------
--Achieve_ScrollCell_1 		一级滚动条格子
----------------------------------------------------------------------------

-- Achieve_ScrollCell_1 = Achieve_ScrollCell_1 or BaseClass(BaseCell)
-- function Achieve_ScrollCell_1:__init()
-- 	self.achieve_name = self:FindVariable("Name")
-- 	self.toggle = self.root_node.toggle
-- 	self.icon = self:FindVariable("Icon")
-- 	self.toggle:AddValueChangedListener(BindTool.Bind(self.OnClick,self))
-- 	self.is_show_red_point = self:FindVariable("IsShowRedPoint")
-- end

-- function Achieve_ScrollCell_1:__delete()

-- end

-- function Achieve_ScrollCell_1:OnFlush()
-- 	self.achieve_name:SetValue(self.data.client_type_str)
-- 	self.icon:SetAsset(ResPath.GetAchieveIcon(self.data.client_type))
-- 	self.is_show_red_point:SetValue(self.data.flag)
-- 	if self.achieve_overview.scroller_1_select_number == self.data.client_type then
-- 		self.toggle.isOn = true
-- 	else
-- 		self.toggle.isOn = false
-- 	end
-- end

-- function Achieve_ScrollCell_1:OnClick(p_bool)
-- 	if p_bool then
-- 		if self.achieve_overview.scroller_1_select_number ~= self.data.client_type then
-- 			self.achieve_overview.scroller_1_select_number = self.data.client_type
-- 			self.achieve_overview:Scoller2ReloadData()
-- 		end
-- 	end
-- end



----------------------------------------------------------------------------
--Achieve_ScrollCell_2 		二级滚动条格子
----------------------------------------------------------------------------

Achieve_ScrollCell_2 = Achieve_ScrollCell_2 or BaseClass(BaseCell)
function Achieve_ScrollCell_2:__init()
	self.bt_text = self:FindVariable("bt_text")
	self.title = self:FindObj2("Image/Text")
	self.describe = self:FindObj2("Container/Text2")
	self.reward_bind_gold = self:FindObj2("Container/Money/Image (2)/Text")
	self.reward_achieve_point = self:FindObj2("Container/Money2/Image (2)/Text")
	self.process_slider = self:FindObj2("Container/Progress01")
	self.process_text = self:FindObj2("Container/ProgressText")
	self.got_icon = self:FindObj2("Got_Icon")
	self.get_button = self:FindObj2("Get_Button")
	self.img_icon = self:FindVariable("Icon")
	self.get_button.button:AddClickListener(BindTool.Bind(self.ClickGetReward, self))
end

function Achieve_ScrollCell_2:FindObj2(path)
	local tran = self.root_node.transform:Find(path)
	return U3DObject(tran.gameObject, tran)
end

function Achieve_ScrollCell_2:__delete()
end

function Achieve_ScrollCell_2:OnFlush()
	-- print_error(self.data)
	self.title.text.text = self.data.cfg.sub_type_str
	self.describe.text.text = self.data.cfg.client_desc
	self.reward_bind_gold.text.text = self.data.cfg.bind_gold
	self.reward_achieve_point.text.text = self.data.cfg.chengjiu
	self.process_slider.slider.value = self.data.process
	self.process_text.text.text = self.data.process_text
	self.img_icon:SetAsset(ResPath.GetAchieveIcon(self.data.icon_id))

	if self.data.flag == 0 then				--未完成
		self.got_icon:SetActive(false)
		if self.data.cfg.goto_panel ~= "" then
			self.bt_text:SetValue(Language.BaoJu.GoToFinish)
			self.get_button:SetActive(true)
		else
			self.get_button:SetActive(false)
		end

		-- self.get_button.button.interactable = false
	elseif self.data.flag == 1 then			--已完成未领取
		self.bt_text:SetValue(Language.Common.LingQuJiangLi)
		self.got_icon:SetActive(false)
		self.get_button:SetActive(true)

		self.get_button.button.interactable = true
	elseif self.data.flag == 2 then			--已领取
		self.got_icon:SetActive(true)
		self.get_button:SetActive(false)
	end
end

function Achieve_ScrollCell_2:ClickGetReward()
	if self.data.flag == 0 then
		if self.data.cfg.goto_panel ~= "" then
			local t = Split(self.data.cfg.goto_panel, "#")
			local view_name = t[1]
			local tab_index = t[2]
			ViewManager.Instance:Open(view_name,TabIndex[tab_index])		
			if OpenFunData.Instance:CheckIsHide(TabIndex[tab_index]) and view_name ~= ViewName.BaoJu then
				ViewManager.Instance:Close(ViewName.BaoJu)
			end	
		end
	else
		AchieveCtrl.Instance:SendFetchReward(self.data.cfg.id)
	end
end