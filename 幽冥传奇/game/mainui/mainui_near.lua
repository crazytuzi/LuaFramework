MainuiNear = MainuiNear or BaseClass()

function MainuiNear:__init(main_view)
	self.main_view = main_view
	self.view = nil
	self.mt_layout_root = nil

	self.list_view = nil
end

function MainuiNear:__delete()
	if nil ~= self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
end

function MainuiNear:Init()
	self.mt_layout_root = self.main_view:GetRootLayout()
	return self
end

local touch_pos = {x = 0, y = 0}
local move_location = {x = 0, y = 0}
local move_x = 0
local move_y = 0
function MainuiNear:NearOpen()
	if nil == self.view then
		local root_size = self.mt_layout_root:getContentSize()
		local w, h = 280, 350
		self.view = XUI.CreateLayout(root_size.width - 240, root_size.height - 240, w, h)
		self.view:setAnchorPoint(1, 1)
		self.view:setTouchEnabled(true)
		self.mt_layout_root:EffectLayout():addChild(self.view, 100)
		-- HandleRenderUnit:AddUi(self.view, 999)

		local close_btn = XUI.CreateImageView(0, 0, ResPath.GetMainui("btn_close"), true)
		close_btn:setPosition(w - 25, h - 25)
		self.view:addChild(close_btn, 10)
		XUI.AddClickEventListener(close_btn, BindTool.Bind(self.Close, self))
		self.view:addTouchEventListener(function (sender, event_type, touch)
			if event_type == XuiTouchEventType.Began then
				touch_pos = sender:convertToNodeSpace(touch:getLocation())
			end
			move_location = touch:getLocation()
			move_x = math.min(root_size.width, move_location.x + (w - touch_pos.x))
			move_x = math.max(w, move_x)
			move_y = math.min(root_size.height, move_location.y + (h - touch_pos.y))
			move_y = math.max(h, move_y)
			self.view:setPosition(move_x, move_y)
		end)

		local img_bg = XUI.CreateImageViewScale9(w / 2, h / 2, w, h, ResPath.GetCommon("img9_121"), true, cc.rect(15, 15, 25, 25))
		self.view:addChild(img_bg)

		self.check_only_atk = XCheckBox:create(ResPath.GetCommon("part_104"), ResPath.GetCommon("bg_checkbox_hook"))
		self.check_only_atk:setPosition(60, 32)
		self.check_only_atk:setSelected(true)
		self.view:addChild(self.check_only_atk)
		self.check_only_atk:addClickEventListener(function()
			self:UpdateNearList()
		end)

		local text_near_player = XUI.CreateText(w / 2, h - 35, 200, 25, cc.TEXT_ALIGNMENT_CENTER, Language.Mainui.NearPlayer, nil, 25)
		text_near_player:setAnchorPoint(0.5, 0.5)
		self.view:addChild(text_near_player)

		local text_only_atk = XUI.CreateText(90, 32, 200, 25, cc.TEXT_ALIGNMENT_LEFT, Language.Mainui.NearOnlyAttack, nil, 25)
		text_only_atk:setAnchorPoint(0, 0.5)
		self.view:addChild(text_only_atk)

		self.list_view = ListView.New()
		self.list_view:Create(w / 2, h / 2, w - 40, h - 140, nil, MainuiNearItem)
		self.list_view:SetMargin(2)
		self.view:addChild(self.list_view:GetView())

		self.list_view:SetSelectCallBack(BindTool.Bind(self.OnSelectItemHandler, self))
	else
		self.view:setVisible(not self.view:isVisible())
	end
	self:UpdateNearList()
	if nil == self.eh_on_select_obj then
		self.eh_on_select_obj = GlobalEventSystem:Bind(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObj, self))
		self.eh_on_create_obj = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnCreateObj, self))
		self.eh_on_delete_obj = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnDeleteObj, self))
		self.pk_mode_listen = RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_PK_MODE, BindTool.Bind(self.OnMainRolePKModeChange, self))
	end
end

function MainuiNear:Close()
	self.view:setVisible(false)
	if self.eh_on_select_obj then
		GlobalEventSystem:UnBind(self.eh_on_select_obj)
		self.eh_on_select_obj = nil
	end
	if self.eh_on_create_obj then
		GlobalEventSystem:UnBind(self.eh_on_create_obj)
		self.eh_on_create_obj = nil
	end
	if self.eh_on_delete_obj then
		GlobalEventSystem:UnBind(self.eh_on_delete_obj)
		self.eh_on_delete_obj = nil
	end
	if self.update_near_timer then
		GlobalTimerQuest:CancelQuest(self.update_near_timer)
		self.update_near_timer = nil
	end
	if RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.pk_mode_listen)
	end
end

function MainuiNear:OnMainRolePKModeChange()
	self:UpdateNearList()
end

function MainuiNear:UpdateNearList()
	if nil == self.view or not self.view:isVisible() then
		return
	end

	local only_attack = self.check_only_atk:isSelected()

	local data_list = {}
	local role_list = Scene.Instance:GetRoleList()
	for k, v in pairs(role_list) do
		if (not only_attack or Scene.Instance:IsEnemy(v)) and v:GetVo().is_shadow ~= 1 then
			table.insert(data_list, {obj_id = v:GetObjId(), role_id = v:GetVo().role_id})
		end
	end

	self.list_view:SetDataList(data_list)
end

function MainuiNear:OnSelectObj(target_obj, select_type)
	for k, v in pairs(self.list_view:GetAllItems()) do
		v:UpdateSelectEffect()
	end
end

-- 人物创建回调(0.1秒内,只更新列表一次)
function MainuiNear:OnCreateObj(obj)
	if obj.obj_type == SceneObjType.Role then
		if self.update_near_timer == nil then
			self.update_near_timer = GlobalTimerQuest:AddDelayTimer(function()
					self:UpdateNearList()
					GlobalTimerQuest:CancelQuest(self.update_near_timer)
					self.update_near_timer = nil
				end, 0.1)
		end
	end
end

-- 人物删除回调(0.1秒内,只更新列表一次)
function MainuiNear:OnDeleteObj(obj)
	if obj.obj_type == SceneObjType.Role then
		if self.update_near_timer == nil then
			self.update_near_timer = GlobalTimerQuest:AddDelayTimer(function()
				self:UpdateNearList()
				GlobalTimerQuest:CancelQuest(self.update_near_timer)
				self.update_near_timer = nil
			end, 0.1)
		end
	end
end

function MainuiNear:OnSelectItemHandler(item)
	local obj = Scene.Instance:GetObjectByObjId(item:GetData().obj_id)
	if nil ~= obj and obj:IsRole() then
		Scene.Instance:GetMainRole():StopMove()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, obj, "near")
	end
end

----------------------------------------------------
-- MainuiNearItem
----------------------------------------------------
MainuiNearItem = MainuiNearItem or BaseClass(BaseRender)

function MainuiNearItem:__init(w, h)
	self.view:setContentWH(w - 5, 50)
end

function MainuiNearItem:__delete()
end

function MainuiNearItem:CreateChild()
	BaseRender.CreateChild(self)

	local size = self.view:getContentSize()
	local img_bg = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("btn_108_select"), true, cc.rect(15, 15, 25, 25))
	self.view:addChild(img_bg)

	self.rich_name = XUI.CreateRichText(size.width / 2, size.height / 2, size.width, 40, false)
	self.rich_name:setVerticalAlignment(RichVAlignment.VA_CENTER)
	XUI.RichTextSetCenter(self.rich_name)
	self.view:addChild(self.rich_name)

	local size = self.view:getContentSize()
	self.item_select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_120"), true)
	self.view:addChild(self.item_select_effect, 999)
	self.item_select_effect:setVisible(false)
end

function MainuiNearItem:OnFlush()
	if nil == self.data then
		self.rich_name:removeAllElements()
		return
	end
	local role = Scene.Instance:GetRoleByObjId(self.data.obj_id)
	if nil == role then
		return
	end

	self.rich_name:removeAllElements()
	local text_t = {}
	for k,v in pairs(Scene.Instance:GetSceneLogic():GetRoleNameBoardText(role:GetVo())) do
		if v.text then
			table.insert(text_t, v)
		end
	end
	for i, v in ipairs(text_t) do
		if i <= 3 then
			XUI.RichTextAddText(self.rich_name, v.text, COMMON_CONSTS.FONT, 22, v.color)
		end
	end

	self:UpdateSelectEffect()
end

function MainuiNearItem:UpdateSelectEffect(vis)
	if nil == vis then
		vis = false
		local role = Scene.Instance:GetRoleByObjId(self.data.obj_id)
		if role and role.is_select then
			vis = true
		end
	end

	if self.item_select_effect then
		self.item_select_effect:setVisible(vis)
	end
end

function MainuiNearItem:CreateSelectEffect()
end
