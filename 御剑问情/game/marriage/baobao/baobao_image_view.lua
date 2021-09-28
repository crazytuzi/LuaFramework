BaoBaoImageView = BaoBaoImageView or BaseClass(BaseRender)
local PageLeft = 1
local PageRight = 2
local MOTHER = 0
local FATHER = 1
function BaoBaoImageView:__init(instance, mother_view)
	self:ListenEvent("ChangeNameClick", BindTool.Bind(self.ChageNameClick, self))
	self:ListenEvent("LeftButtonClick", BindTool.Bind(self.ChangePage, self, PageLeft))
	self:ListenEvent("RightButtonClick", BindTool.Bind(self.ChangePage, self, PageRight))
	self:ListenEvent("AbandonmentClick", BindTool.Bind(self.AbandonmentClick, self))
	self:ListenEvent("HelpClick",BindTool.Bind(self.HelpClick,self))
	self.name = self:FindVariable("Name")
	self.baobao = self:FindObj("BaobaoDisplay")
	self.btn_left = self:FindVariable("BtnLeft")
	self.btn_right = self:FindVariable("BtnRight")
	self.flag = self:FindVariable("Flag")
	self.level = self:FindVariable("Level")
	self.activie = self:FindVariable("activie")
	self.mother_name = self:FindVariable("MotherName")
	self.father_name = self:FindVariable("FatherName")
	self.select_res_id = 0
	self:InitScroller()
	self.selected_baby_index = 1
	self:FlushBaobaoModel()
end

function BaoBaoImageView:__delete()
	if self.baobao_model then
		self.baobao_model:DeleteMe()
		self.baobao_model = nil
	end
end
--初始化滚动条
function BaoBaoImageView:CloseCallBack()
	BaobaoData.Instance:SetSelectedBabyIndex(nil)
end

function BaoBaoImageView:ChageNameClick()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	local func = function(name)
		local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
		if selected_baby_index then
			BaobaoCtrl.Instance:SendBabyRenameReq(selected_baby_index - 1, name)
		end
	end
	TipsCtrl.Instance:ShowRename(func, true, ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").other[1].rename_card_id)
end

function BaoBaoImageView:AbandonmentClick()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end

	local function remove_baby()
		local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
		if selected_baby_index then
			BaobaoCtrl.SendRemoveBabyReq(selected_baby_index -1)
		end
	end

	TipsCtrl.Instance:ShowCommonTip(remove_baby, nil, Language.Marriage.BabyIsRemove, nil, nil, false)
end

function BaoBaoImageView:HelpClick()
    TipsCtrl.Instance:ShowHelpTipView(261)
end

--初始化滚动条
function BaoBaoImageView:InitScroller()
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = ListViewDelegate()

	PrefabPool.Instance:Load(AssetID("uis/views/marriageview_prefab", "BaoBaoItem"), function (prefab)
		if nil == prefab then
			return
		end

		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.scroller.scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
	self.scroller.scroller.scrollerScrolled = function ()
		self:ReSetBtnVisible()
	end
end

--滚动条数量
function BaoBaoImageView:GetNumberOfCells()
	return #BaobaoData.Instance:GetListBabyData()
end

--滚动条大小
function BaoBaoImageView:GetCellSize()
	return 120
end

--滚动条刷新
function BaoBaoImageView:GetCellView(scroller, data_index, cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1

	if nil == self.cell_list[cell] then
		self.cell_list[cell] = BaoBaoScrollerItem.New(cell.gameObject)
		self.cell_list[cell].parent = self
		-- self.cell_list[cell].toggle.group = self.scroller.toggle_group
	end

	local data_list = BaobaoData.Instance:GetListBabyData()
	if data_list[data_index] then
		self.cell_list[cell]:SetIndex(data_list[data_index].baby_index + 1)
		self.cell_list[cell]:SetData(data_list[data_index])
		self.cell_list[cell]:ShowHight(BaobaoData.Instance:GetSelectedBabyIndex())
	end
	return cell
end

--设置按钮是否可见
function BaoBaoImageView:ReSetBtnVisible()

	local position = self.scroller.scroller.ScrollPosition
	local disable_height = self.scroller.scroller.ScrollSize						--listview不可见的画布长度

	if disable_height < 10 then
		self.btn_left:SetValue(false)
		self.btn_right:SetValue(false)
		return
	end

	self.btn_left:SetValue(true)
	self.btn_right:SetValue(true)

	if position <= 0 then
		self.btn_left:SetValue(false)
	elseif disable_height - position <= 10 or position > disable_height then
		self.btn_right:SetValue(false)
	end
end

function BaoBaoImageView:ChangePage(value)
	local position = self.scroller.scroller.ScrollPosition
	local disable_height = self.scroller.scroller.ScrollSize						--listview不可见的画布长度
	local visible_height = self.scroller.scroller.ScrollRectSize					--listview可见的画布长度

	self.btn_left:SetValue(true)
	self.btn_right:SetValue(true)

	local temp_position = 0
	if value == PageLeft then
		temp_position = position - visible_height
		if temp_position < 0 then
			temp_position = 0
			self.btn_left:SetValue(false)
		end
	else
		temp_position = position + visible_height
		if temp_position > disable_height then
			temp_position = disable_height
			self.btn_right:SetValue(false)
		end
	end

	local index = self.scroller.scroller:GetCellViewIndexAtPosition(temp_position)

	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller.scroller.snapTweenType
	local scrollerTweenTime = 0
	local scroll_complete = nil
	self.scroller.scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function BaoBaoImageView:FlushBaobaoModel(resid)
	if not self.baobao_model then
		self.baobao_model = RoleModel.New()
		self.baobao_model:SetDisplay(self.baobao.ui3d_display)
	end
	if resid and self.select_res_id ~= resid then
		self.baobao_model:SetMainAsset(ResPath.GetSpiritModel(resid))
		self.select_res_id = resid
	end
end

function BaoBaoImageView:FlushView()
	-- self.activie:SetValue(true)
	self.activie:SetValue(false) 

	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end
	if self.scroller.scroller.isActiveAndEnabled then
		local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
		if selected_baby_index == 1 then
			self.scroller.scroller:ReloadData(0)
		else
			self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
    if self.hadremove then
    	local data = BaobaoData.Instance:GetAllBabyInfo()
			local index = 0
			for k,v in pairs(data) do
				if tonumber(v.baby_id)>=0 then
					index = v.baby_index + 1
					break
				end
			end
	    BaobaoData.Instance:SetSelectedBabyIndex(index)
	    self.hadremove = false
	end
    self.baobao:SetActive(true)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then
		self.activie:SetValue(false)
		self.name:SetValue("")
		self.baobao:SetActive(false)
		return
	end

	local index = BaobaoData.Instance:GetSelectedBabyIndex()
	local baby_info_cfg = BaobaoData.Instance:GetBabyInfo(index)
	local baby_grade = baby_info_cfg.grade

    local daxie = CommonDataManager.GetDaXie(baby_grade)
    self.level:SetValue(daxie..Language.Common.Jie)

    if baby_grade >= 5 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(5)
	elseif baby_grade == 0 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(1)
	else
		 bundle, asset = ResPath.GetMountGradeQualityBG(baby_grade)
	end
	-- self.flag:SetAsset(bundle, asset)

	self:FlushBaobaoModel(BaobaoData.BabyModel[baby_info.baby_id + 1] or BaobaoData.BabyModel[1])
	self.name:SetValue(baby_info.baby_name)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local mother_name = vo.sex == MOTHER and vo.name or baby_info.lover_name
	local father_name = vo.sex == FATHER and vo.name or baby_info.lover_name
	self.mother_name:SetValue(mother_name)
	self.father_name:SetValue(father_name)
end

--宝宝滚动条格子
BaoBaoScrollerItem = BaoBaoScrollerItem or BaseClass(BaseCell)
function BaoBaoScrollerItem:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.OnFlush, self)
	self.name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.red_point = self:FindVariable("RedPoint")
	self.show_lihun = self:FindVariable("ShowLihun")
	self.show_hight = self:FindVariable("ShowHight")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function BaoBaoScrollerItem:ClickItem()
	self.root_node.toggle.isOn = true
	local select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if select_index == self.index then
		return
	end

	BaobaoData.Instance:SetSelectedBabyIndex(self.index)
	-- 重置当前记录的宝宝守护精灵等级Fag
	BaobaoCtrl.Instance:ResetValue()
	ViewManager.Instance:FlushView(ViewName.MarryBaby)
end

function BaoBaoScrollerItem:__delete()
	self.name = nil
	self.icon = nil
end

function BaoBaoScrollerItem:ShowHight(index)
	self.show_hight:SetValue(self.index == index)
end

function BaoBaoScrollerItem:OnFlush()
	if not self.data then return end
	self.name:SetValue(self.data.baby_name)
	-- 刷新选中特效
	local select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	-- if self.root_node.toggle.isOn and select_index ~= self.index then
	-- 	self.root_node.toggle.isOn = false
	-- elseif self.root_node.toggle.isOn == false and select_index == self.index then
	-- 	self.root_node.toggle.isOn = true
	-- end

	local bundle, asset = ResPath.GetBabyIcon("baby_icon_" .. self.data.baby_id)
	self.icon:SetAsset(bundle, asset)
	-- local point = self.parent:GetRedPointByIndex(self.index - 1)
	local red = BaobaoData.Instance:SetBaobaoRedPoint(self.index)
	local cur_tab_index = BaobaoData.Instance:GetCurTabIndex()
	if cur_tab_index == TabIndex.marriage_baobao_guard then
		self.red_point:SetValue(red > 0)
	else
		self.red_point:SetValue(false)
	end

   if self.data.lover_name ~= BaobaoData.Instance:GetLoveID() then
   		self.show_lihun:SetValue(true)
   	else
   		self.show_lihun:SetValue(false)
   end
end
