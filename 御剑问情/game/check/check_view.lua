require("game/check/check_present_view")
require("game/check/check_wing_view")
require("game/check/check_mount_view")
require("game/check/check_shengong_view")
require("game/check/check_shenyi_view")
require("game/check/check_goddess_view")
require("game/check/check_spirit_view")
require("game/check/check_fight_mount_view")
require("game/check/check_foot_view")
require("game/check/check_halo_view")
require("game/check/check_waist_view")
require("game/check/check_head_view")
require("game/check/check_arm_view")
require("game/check/check_xianbao_view")
require("game/check/check_lingzhu_view")
require("game/check/check_mask_view")
require("game/check/check_lingchong_view")
require("game/check/check_linggong_view")
require("game/check/check_lingqi_view")
-- ranktag
CheckView = CheckView or BaseClass(BaseView)

function CheckView:__init()
	self.ui_config = {"uis/views/checkview_prefab","CheckView"}
	-- if UIScene.scene_asset == nil then
	-- 	self.ui_scene = {"scenes/map/jszs01", "Jszs01"}
	-- end
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.full_screen = true
	self.play_audio = true
	self.is_cell_active = false
	self.is_set_jump = false
	self.tab_index = 1
end

function CheckView:LoadCallBack()
	-- ranktag
	self:ListenEvent("close_click",BindTool.Bind(self.CloseOnClick,self))
	self:ListenEvent("add_money_click",BindTool.Bind(self.AddMoneyClick,self))
	self.check_present_view = CheckPresentView.New(self:FindObj("check_present_view"))
	self.check_wing_view = CheckWingView.New(self:FindObj("check_wing_view"))
	self.check_halo_view = CheckHaloView.New(self:FindObj("check_halo_view"))
	self.check_mount_view = CheckMountView.New(self:FindObj("check_mount_view"))
	self.check_shengong_view = CheckShenGongView.New(self:FindObj("check_shengong_view"))
	self.check_shenyi_view = CheckShenyiView.New(self:FindObj("check_shenyi_view"))
	self.check_goddess_view = CheckGoddessView.New(self:FindObj("check_goddess_view"))
	self.check_spirit_view = CheckSpiritView.New(self:FindObj("check_spirit_view"))
	self.check_fight_mount_view = CheckFightMountView.New(self:FindObj("check_fight_mount_view"))
	self.check_foot_view = CheckFootView.New(self:FindObj("check_foot_view"))
	self.check_waist_view = CheckWaist.New(self:FindObj("check_waist_view"))
	self.check_head_view = CheckHead.New(self:FindObj("check_head_view"))
	self.check_arm_view = CheckArm.New(self:FindObj("check_arm_view"))
	self.check_mask_view = CheckMask.New(self:FindObj("check_mask_view"))
	self.check_lingzhu_view = CheckLingZhu.New(self:FindObj("check_lingzhu_view"))
	self.check_xianbao_view = CheckXianBao.New(self:FindObj("check_xianbao_view"))
	self.check_lingchong_view = CheckLingChongView.New(self:FindObj("check_lingchong_view"))
	self.check_linggong_view = CheckLingGongView.New(self:FindObj("check_linggong_view"))
	self.check_lingqi_view = CheckLingQiView.New(self:FindObj("check_lingqi_view"))
	self.gold_text = self:FindVariable("gold_text")
	self.bind_gold_text = self:FindVariable("bind_gold_text")
	self.is_fazhen = self:FindVariable("is_fazhen")
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	self.rotate_event_trigger = self:FindObj("RotateEventTrigger")
	local event_trigger = self.rotate_event_trigger:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
	self.cell_list = {}
	self:InitListView()
end

function CheckView:ReleaseCallBack()
	if self.check_present_view ~= nil then
		self.check_present_view:DeleteMe()
		self.check_present_view = nil
	end
	if self.check_mount_view ~= nil then
		self.check_mount_view:DeleteMe()
		self.check_mount_view = nil
	end
	if self.check_wing_view ~= nil then
		self.check_wing_view:DeleteMe()
		self.check_wing_view = nil
	end
	if self.check_halo_view ~= nil then
		self.check_halo_view:DeleteMe()
		self.check_halo_view = nil
	end
	if self.check_shenyi_view ~= nil then
		self.check_shenyi_view:DeleteMe()
		self.check_shenyi_view = nil
	end
	if self.check_shengong_view ~= nil then
		self.check_shengong_view:DeleteMe()
		self.check_shengong_view = nil
	end

	if self.check_goddess_view ~= nil then
		self.check_goddess_view:DeleteMe()
		self.check_goddess_view = nil
	end

	if self.check_spirit_view ~= nil then
		self.check_spirit_view:DeleteMe()
		self.check_spirit_view = nil
	end

	if self.check_fight_mount_view ~= nil then
		self.check_fight_mount_view:DeleteMe()
		self.check_fight_mount_view = nil
	end

	if self.check_foot_view ~= nil then
		self.check_foot_view:DeleteMe()
		self.check_foot_view = nil
	end

	if self.check_waist_view then
		self.check_waist_view:DeleteMe()
		self.check_waist_view = nil
	end

	if self.check_head_view then
		self.check_head_view:DeleteMe()
		self.check_head_view = nil
	end

	if self.check_arm_view then
		self.check_arm_view:DeleteMe()
		self.check_arm_view = nil
	end

	if self.check_mask_view then
		self.check_mask_view:DeleteMe()
		self.check_mask_view = nil
	end

	if self.check_lingzhu_view then
		self.check_lingzhu_view:DeleteMe()
		self.check_lingzhu_view = nil
	end

	if self.check_xianbao_view then
		self.check_xianbao_view:DeleteMe()
		self.check_xianbao_view = nil
	end

	if self.check_lingchong_view then
		self.check_lingchong_view:DeleteMe()
		self.check_lingchong_view = nil
	end

	if self.check_linggong_view then
		self.check_linggong_view:DeleteMe()
		self.check_linggong_view = nil
	end

	if self.check_lingqi_view then
		self.check_lingqi_view:DeleteMe()
		self.check_lingqi_view = nil
	end

	-- ranktag
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)

	-- 清理变量和对象
	self.gold_text = nil
	self.is_fazhen = nil
	self.bind_gold_text = nil
	self.rotate_event_trigger = nil
	self.list_view = nil
	self.is_cell_active = false
	self.is_set_jump = false --是否外部设置跳转
end

function CheckView:InitListView()
	self.list_view = self:FindObj("tab_list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	self.list_view.scroller:ReloadData(0)
end

function CheckView:GetNumberOfCells()
	return #CheckData.Instance:GetShowTabIndex()
end

function CheckView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		--self:CheckToJump()
	end
end

function CheckView:Open(index)
	BaseView.Open(self, index)
end

function CheckView:OpenCallBack()
	local open_type = CheckData.Instance:GetOpenIndex()
	self.tab_index = open_type
	-- if UIScene.scene_asset == nil then
	-- 	local scene_load_callback = function()
	self:FlushPanel()
	self:Flush()
	-- 	end
	-- 	UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}}, scene_load_callback)
	-- end
	-- if self.is_set_jump == false then
	-- 	self.tab_index = 1
	-- end
	self.jump_flag = true
	self:ChangeToIndex(self.tab_index)
	self.list_view.scroller:ReloadData(0)
	self:ListJumpToIndex()
end

function CheckView:CloseCallBack()
	self.is_set_jump = false
	IS_BOOL = false
	-- UIScene:IsNotCreateRoleModel(false)
end

function CheckView:OnRoleDrag(data)
	-- if UIScene.role_model then
	-- 	UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	-- end
end

function CheckView:OnUiSceneLoadingQuite()
	-- local role_info = CheckData.Instance:GetRoleInfo()
	-- UIScene:ResetLocalPostion()
	-- UIScene:SetRoleModelResInfo(role_info)
	-- UIScene:SetActionEnable(true)
end

function CheckView:ShowIndexCallBack(index)
	-- local scene_load_callback = function()
	-- 	self:FlushPanel()
	-- 	self:Flush()
	-- end
	-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}}, scene_load_callback)
	self:FlushPanel()
	self:Flush()
end

function CheckView:OnFlush()
	if self.tab_index == CHECK_TAB_TYPE.JUE_SE then
		self.check_present_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.MOUNT then
		self.check_mount_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.WING then
		self.check_wing_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.HALO then
		self.check_halo_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.FIGHT_MOUNT then
		self.check_fight_mount_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.SPIRIT then
		self.check_spirit_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.GODDESS then
		self.check_goddess_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.SHEN_GONG then
		self.check_shengong_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.SHEN_YI then
		self.check_shenyi_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.FOOT then
		self.check_foot_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.WAIST then
		self.check_waist_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.HEAD then
		self.check_head_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.ARM then
		self.check_arm_view:SetAttr()
		-- ranktag
	elseif self.tab_index == CHECK_TAB_TYPE.MASK then
		self.check_mask_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.LINGZHU then
		self.check_lingzhu_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.XIANBAO then
		self.check_xianbao_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.LINGCHONG then
		self.check_lingchong_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.LINGGONG then
		self.check_linggong_view:SetAttr()
	elseif self.tab_index == CHECK_TAB_TYPE.LINGQI then
		self.check_lingqi_view:SetAttr()
	end
end

function CheckView:CloseOnClick()
	self:Close()
end

function CheckView:AddMoneyClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function CheckView:SetCurIndex(tab_index, is_set_jump)
	self.tab_index = tab_index
	self.is_set_jump = is_set_jump
end

function CheckView:GetCurIndex()
	return self.tab_index
end

function CheckView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CheckTabItem.New(cell.gameObject,self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	cell_index = cell_index + 1

	local show_index_list = CheckData.Instance:GetShowTabIndex()
	the_cell:SetData(show_index_list[cell_index])
	self.is_cell_active = true
end

function CheckView:ListJumpToIndex()
	self.list_view.scroller:JumpToDataIndex(self.tab_index - 1)
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
end

function CheckView:SetOpenType(open_type)
	self.open_type = open_type
end

function CheckView:FlushPanel()
	self:HidePanel()
	if self.tab_index == CHECK_TAB_TYPE.JUE_SE then
		if self.check_present_view then
			self.check_present_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.MOUNT then
		if self.check_mount_view then
			self.check_mount_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.WING then
		if self.check_wing_view  then
			self.check_wing_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.HALO then
		if self.check_halo_view  then
			self.check_halo_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.FIGHT_MOUNT then
		if self.check_fight_mount_view then
			self.check_fight_mount_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.SPIRIT then
		if self.check_spirit_view then
			self.check_spirit_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.GODDESS then
		if self.check_goddess_view then
			self.check_goddess_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.SHEN_GONG then
		if self.check_shengong_view then
			self.check_shengong_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.SHEN_YI then
		if self.check_shenyi_view then
			self.check_shenyi_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.FOOT then
		if self.check_foot_view then
			self.check_foot_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.WAIST then
		if self.check_waist_view then
			self.check_waist_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.HEAD then
		if self.check_head_view then
			self.check_head_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.ARM then
		if self.check_arm_view then
			self.check_arm_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.MASK then
		if self.check_mask_view then
			self.check_mask_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.LINGZHU then
		if self.check_lingzhu_view then
			self.check_lingzhu_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.XIANBAO then
		if self.check_xianbao_view then
			self.check_xianbao_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.LINGCHONG then
		if self.check_lingchong_view then
			self.check_lingchong_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.LINGGONG then
		if self.check_linggong_view then
			self.check_linggong_view:SetActive(true)
		end
	elseif self.tab_index == CHECK_TAB_TYPE.LINGQI then
		if self.check_lingqi_view then
			self.check_lingqi_view:SetActive(true)
		end
		-- ranktag
	end
	if self.tab_index == CHECK_TAB_TYPE.SHEN_YI then
		self.is_fazhen:SetValue(true)
	else
		self.is_fazhen:SetValue(false)
	end
end

function CheckView:HidePanel()
	if self.check_present_view then
		self.check_present_view:SetActive(false)
	end
	if self.check_mount_view then
		self.check_mount_view:SetActive(false)
	end
	if self.check_wing_view then
		self.check_wing_view:SetActive(false)
	end
	if self.check_halo_view then
		self.check_halo_view:SetActive(false)
	end
	if self.check_spirit_view then
		self.check_spirit_view:SetActive(false)
	end
	if self.check_goddess_view then
		self.check_goddess_view:SetActive(false)
	end
	if self.check_shengong_view then
		self.check_shengong_view:SetActive(false)
	end
	if self.check_shenyi_view then
		self.check_shenyi_view:SetActive(false)
	end
	if self.check_fight_mount_view then
		self.check_fight_mount_view:SetActive(false)
	end
	if self.check_foot_view then
		self.check_foot_view:SetActive(false)
	end
	if self.check_waist_view then
		self.check_waist_view:SetActive(false)
	end
	if self.check_head_view then
		self.check_head_view:SetActive(false)
	end
	if self.check_arm_view then
		self.check_arm_view:SetActive(false)
	end
	-- ranktag
	if self.check_mask_view then
		self.check_mask_view:SetActive(false)
	end
	if self.check_lingzhu_view then
		self.check_lingzhu_view:SetActive(false)
	end
	if self.check_xianbao_view then
		self.check_xianbao_view:SetActive(false)
	end
	if self.check_lingchong_view then
		self.check_lingchong_view:SetActive(false)
	end
	if self.check_linggong_view then
		self.check_linggong_view:SetActive(false)
	end
	if self.check_lingqi_view then
		self.check_lingqi_view:SetActive(false)
	end
end

-- 玩家钻石改变时
function CheckView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.gold_text:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "bind_gold" then
		self.bind_gold_text:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function CheckView:CancellAllQuest()
	if self.check_shengong_view then
		self.check_shengong_view:CancelTheQuest()

	end
	if self.check_shenyi_view then
		self.check_shenyi_view:CancelTheQuest()
	end
end

function CheckView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end
----------------------------------------------------------
CheckTabItem = CheckTabItem  or BaseClass(BaseCell)

function CheckTabItem:__init(instance, parent)
	self.parent = parent
	self:ListenEvent("click",BindTool.Bind(self.OnItemClick, self))
	self.text = self:FindVariable("text")
	self.show_hl = self:FindVariable("show_hl")
	self.tab_icon = self:FindVariable("tab_icon")
	self.tab_index = -1
end

function CheckTabItem:__delete()
	self.parent = nil
end

function CheckTabItem:OnFlush()
	self:SetTabIndex(self.data)
	self:FlushName()
end

function CheckTabItem:SetTabIndex(tab_index)
	self.root_node.gameObject:SetActive(tab_index ~= nil)
	self.tab_index = tab_index
end

function CheckTabItem:FlushName()
	if self.tab_index == nil then
		return
	end
	local check_data = CheckData.Instance
	local text = check_data:GetTabName(self.tab_index)
	if self.parent:GetCurIndex() == self.tab_index then
		self.show_hl:SetValue(true)
		self.root_node.toggle.isOn = true
	else
		self.show_hl:SetValue(false)
		self.root_node.toggle.isOn = false
	end
	self.text:SetValue(text)
	self.root_node:SetActive(check_data:GetTabIsOpen(self.tab_index))
	self.tab_icon:SetAsset(check_data:GetTabAsset(self.tab_index))
end

function CheckTabItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function CheckTabItem:OnItemClick(is_click)
	if is_click then
		-- IS_BOOL 代表从精灵炫耀传闻打开界面
		if IS_BOOL then
			if self.parent:GetCurIndex() ~= self.tab_index then
				self.parent:SetHighLighFalse()
				self.show_hl:SetValue(true)
				self.parent:FlushPanel()
				self.parent:ChangeToIndex(self.tab_index)
			end
		else
			if self.parent:GetCurIndex() ~= self.tab_index then
				self.parent:SetHighLighFalse()
				self.show_hl:SetValue(true)
				self.parent:SetCurIndex(self.tab_index)
				self.parent:FlushPanel()
				self.parent:ChangeToIndex(self.tab_index)
			end
		end
	end
end

function CheckTabItem:SetHighLigh(show_hl)
	self.show_hl:SetValue(show_hl)
end

function CheckTabItem:SetToggle(is_on)
	self.root_node.toggle.isOn = is_on
end
