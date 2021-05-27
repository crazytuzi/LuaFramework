ShenbinPanel = ShenbinPanel or BaseClass(SubView)

function ShenbinPanel:__init()
	self.texture_path_list = {
		'res/xui/qiege.png',
		
		}	
	self.config_tab = {
		{"qiege_ui_cfg", 2, {0}},
		
	}
	self.page_index = 1
	self.cell_num = 0
end

function ShenbinPanel:__delete( ... )
	-- body
end

function ShenbinPanel:LoadCallBack(loaded_times, index)
	self:CreateGridList()
	XUI.AddClickEventListener(self.node_t_list.layout_left.node, BindTool.Bind1(self.MoveLeft, self), true)

	XUI.AddClickEventListener(self.node_t_list.layout_right.node, BindTool.Bind1(self.MoveRight, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_qgsb_ques.node, BindTool.Bind2(self.OpenTip, self))
	self.wapon_level_change = GlobalEventSystem:Bind(QIEGE_EVENT.QieGeShenBinUp, BindTool.Bind1(self.FlushList, self))
	self.level_change = GlobalEventSystem:Bind(QIEGE_EVENT.UpGrade_Result, BindTool.Bind1(self.FlushList, self))
end

function ShenbinPanel:OpenTip()
    DescTip.Instance:SetContent(Language.DescTip.ShenbingContent, Language.DescTip.ShenbingTitle)
end

function ShenbinPanel:ReleaseCallBack( ... )
	if self.shen_bin_grid then
		self.shen_bin_grid:DeleteMe()
		self.shen_bin_grid = nil
	end 
	if self.wapon_level_change then
		GlobalEventSystem:UnBind(self.wapon_level_change)
		self.wapon_level_change = nil
	end
	if self.level_change then
		GlobalEventSystem:UnBind(self.level_change)
		self.level_change = nil
	end
end

function ShenbinPanel:OpenCallBack()
	-- body
end

function ShenbinPanel:ShowIndexCallBack(index)
	self:Flush(index)
end

function ShenbinPanel:CreateGridList( ... )
	local ph_list = self.ph_list.ph_grid_list
	local config = QieGeData.Instance:GetWeaponData()
	local cell_num = #config
	self.cell_num  = cell_num
	if nil == self.shen_bin_grid  then
		self.shen_bin_grid = BaseGrid.New() 
		local grid_node = self.shen_bin_grid:CreateCells({w = ph_list.w, h = ph_list.h, itemRender = ShenbinPanelRender, ui_config = self.ph_list.ph_grid_item, cell_count = cell_num, col = 3, row = 1})
		self.node_t_list.layout_shenbin.node:addChild(grid_node, 100)
		self.shen_bin_grid:GetView():setPosition(ph_list.x, ph_list.y)
		self.shen_bin_grid:SetPageChangeCallBack(BindTool.Bind(self.OnShenBinPageChangeCallBack, self))
		self.shen_bin_grid:SelectCellByIndex(0)
	end
end

function ShenbinPanel:OnFlush(param_t, index)
	self:FlushList()
	
end

function ShenbinPanel:FlushList()
	local config = QieGeData.Instance:GetWeaponData()
	local data = {}
	local index = 0
	for i,v in ipairs(config) do
		data[index] = v
		index = index + 1
	end
	self.shen_bin_grid:SetDataList(data)
	self:SetMoveBtnShow()
end


function ShenbinPanel:MoveLeft(... )
	if self.page_index > 1 then
		self.page_index = self.page_index - 1 
		self.shen_bin_grid:ChangeToPage(self.page_index)
		self:SetMoveBtnShow()
	end
end

function ShenbinPanel:MoveRight()
	if self.page_index < math.floor(self.cell_num/3) then
		self.page_index = self.page_index + 1
		self.shen_bin_grid:ChangeToPage(self.page_index)
		self:SetMoveBtnShow()
	end
end

function ShenbinPanel:SetMoveBtnShow()
	self.node_t_list.layout_left.node:setVisible(self.page_index ~= 1)
	self.node_t_list.layout_right.node:setVisible(self.page_index ~= math.floor(self.cell_num/3))

	self.node_t_list.img_left_point.node:setVisible(QieGeData.Instance:PageIndexPoint(self.page_index, true))
	self.node_t_list.img_right_point.node:setVisible(QieGeData.Instance:PageIndexPoint(self.page_index, false))
end


function ShenbinPanel:OnShenBinPageChangeCallBack(grid_view, cur_page_index, prve_page_index)
	self.page_index = cur_page_index
	self:SetMoveBtnShow()
end

ShenbinPanelRender = ShenbinPanelRender or BaseClass(BaseRender)
function ShenbinPanelRender:__init()
	-- body
end

function ShenbinPanelRender:__delete()
	if self.effect then
		self.effect:setStop()
		self.effect = nil
	end
	if self.level_num then
		self.level_num:DeleteMe()
		self.level_num = nil
	end
end

function ShenbinPanelRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_check.node, BindTool.Bind1(self.UpGradeShenBin, self), true)
	local ph = self.ph_list.layout_effect
	if self.effect == nil then
		self.effect = AnimateSprite:create()
		self.view:addChild(self.effect)
		self.effect:setPosition(ph.x, ph.y)
	end
	if self.level_num == nil then
		local ph = self.ph_list["ph_number"]
		self.level_num = NumberBar.New()
		self.level_num:SetRootPath(ResPath.GetCommon("num_2_"))
		self.level_num:SetPosition(ph.x, ph.y)
		self.level_num:SetGravity(NumberBarGravity.Left)
		self.view:addChild(self.level_num:GetView(), 300, 300)
	end
end

function ShenbinPanelRender:OnFlush()
	if self.data == nil then return end
	local text1 = Language.QieGe.BtnText1[2]
	self.node_tree.btn_check.node:setTitleText(text1)
	self.node_tree.img_can_up.node:setVisible(QieGeData.Instance:GetSingleWeaponUpgrade(self.data))

	self.node_tree.img_name.node:loadTexture(ResPath.GetQieGePath("name"..self.data.type))

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.data.effect)
	self.effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.level_num:SetNumber(self.data.level)
	--self.effect:makeGray(self.data.level<=0)
	AdapterToLua:makeGray(self.effect, self.data.level<=0)
end

function ShenbinPanelRender:UpGradeShenBin()
	-- if self.data.level <= 0 then
	-- 	QieGeCtrl.Instance:SendQieGeShenBinUpgradeReq(self.data.type)
	-- else
		
	-- end
	QieGeCtrl.Instance:OpenUpgradeView(self.data)
end

function ShenbinPanelRender:CreateSelectEffect()
	-- body
end