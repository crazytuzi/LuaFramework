
local FuwenView = BaseClass(SubView)

function FuwenView:__init()
	self.texture_path_list = {
		'res/xui/fuwen.png',
	}
	self.config_tab = {
		{"fuwen_ui_cfg", 1, {0}},
	}
	require("scripts/game/fuwen/view/fuwen_suit_attr").New(ViewDef.Role.RoleInfoList.BiSha.SuitAttr)
	require("scripts/game/fuwen/view/fuwen_zhuling").New(ViewDef.Role.RoleInfoList.BiSha.FuwenZhuling)

	self.fuwen_list = {}
end

function FuwenView:__delete()
end

function FuwenView:ReleaseCallBack()
	if self.fuwen_cap then
		self.fuwen_cap:DeleteMe()
		self.fuwen_cap = nil
	end

	for k, v in pairs(self.fuwen_list) do
		v:DeleteMe()
	end
	self.fuwen_list = {}

	self.fuwen_suit_eff = nil
	self.btn_fw_zl = nil
end

function FuwenView:LoadCallBack(index, loaded_times)
	self.btn_fw_zl = XUI.CreateImageView(508, 508, ResPath.GetFuwen("fuwen_zhuling"))
	local size = self.btn_fw_zl:getContentSize()
	self.btn_fw_zl.remind_img = XUI.CreateImageView(size.width - 15, size.height - 15, ResPath.GetRemindImg())
	self.btn_fw_zl:addChild(self.btn_fw_zl.remind_img, 1)
	self.node_t_list.layout_fuwen.node:addChild(self.btn_fw_zl, 99)
	self.btn_fw_zl:setVisible(false)
	self.btn_fw_zl.remind_img:setVisible(false)

	XUI.AddClickEventListener(self.btn_fw_zl, function()
		if ViewManager.Instance:IsOpen(ViewDef.Role.RoleInfoList.BiSha.FuwenZhuling) then
			ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList.BiSha.SuitAttr)
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList.BiSha.FuwenZhuling)
		end
	end)

	self.fuwen_cap = FightPowerView.New(275, 38, self.node_t_list.layout_fuwen.node, 300, false)

	self.node_t_list.layout_fuwen_grid.node:setTouchEnabled(true)
	self.node_t_list.layout_fuwen_grid.node:addTouchEventListener(BindTool.Bind(self.OnTouchFuwenGrid, self))

	self.fuwen_list = {}
	local size = self.node_t_list.layout_fuwen_grid.node:getContentSize()
	local c_x, c_y = size.width / 2, size.height / 2
	local r = 80

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(20)
    self.fuwen_suit_eff = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
    self.fuwen_suit_eff:setPosition(size.width / 2 + 2, size.height / 2 + 1)
    self.node_t_list.layout_fuwen_grid.node:addChild(self.fuwen_suit_eff, 10)
    self.fuwen_suit_eff:setVisible(false)

	for i = 1, FuwenData.RUNE_PARTS do
		local fuwen = FuwenView.FuwenRender.New(i, self.ph_list.ph_fuwen_render, self.node_t_list.layout_fuwen_grid.node, self)
		fuwen:SetPosition(c_x, c_y)
		self.fuwen_list[i] = fuwen
	end

	-- 符文精华图标
	local jh_icon = XUI.CreateImageView(self.ph_list.ph_jinghua.x, self.ph_list.ph_jinghua.y, ResPath.GetItem(CLIENT_GAME_GLOBAL_CFG.fuwen_jh_id))
	jh_icon:setScale(0.5)
	self.node_t_list.layout_fuwen.node:addChild(jh_icon, 99)

	-- 获取材料
	self.link_stuff = RichTextUtil.CreateLinkText("获取符文", 20, COLOR3B.GREEN)
	self.link_stuff:setPosition(500, 30)
	self.node_t_list.layout_fuwen.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, function()
		TipCtrl.Instance:OpenGetStuffTip(CLIENT_GAME_GLOBAL_CFG.fuwen_equip_id)
	end, true)

	local fuwen_data_proxy = EventProxy.New(FuwenData.Instance, self)
	fuwen_data_proxy:AddEventListener(FuwenData.FUWEN_ITEM_CHNAGE, BindTool.Bind(self.OnFuwenItemChange, self))
	fuwen_data_proxy:AddEventListener(FuwenData.FUWEN_ZHULING_CHANGE, BindTool.Bind(self.OnFuwenZhulingChange, self))
	fuwen_data_proxy:AddEventListener(FuwenData.FUWEN_ZHULING_STATE, BindTool.Bind(self.OnFuwenZhulingState, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end

function FuwenView:OpenCallBack()
end

function FuwenView:ShowIndexCallBack(index)
	self:Flush()
end

function FuwenView:OnFlush(param_t, index)
	self:FlushCrystalNum()
	self:FlushFuwenParts()
	self:FlushZhulingBtn()
end
------------------------------------------------------------------------------------
function FuwenView:OnFuwenZhulingChange()
	self:FlushFuwenParts()
end

function FuwenView:OnFuwenItemChange()
	self:FlushFuwenParts()
end

function FuwenView:OnTouchFuwenGrid(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		local location = sender:convertToNodeSpace(touch:getLocation())
		for k, v in pairs(FuwenView.FuwenRender.FUWEN_POS) do
			if GameMath.IsInPolygon(v.points, location) then
				self:OnClickFuwen(k)
				break
			end
		end
	end
end

function FuwenView:OnClickFuwen(fuwen_index)
	if ViewManager.Instance:IsOpen(ViewDef.Role.RoleInfoList.BiSha.FuwenZhuling) then
		return
	end

	local max_data = FuwenData.Instance:GetMaxFuwenByInBag(fuwen_index)
	if max_data then
		FuwenCtrl.Instance.SendFuwenEquipReq(max_data.series)
	else
		local fuwen_data = FuwenData.Instance:GetFuwenData(fuwen_index)
		if fuwen_data then
			TipCtrl.Instance:OpenItem(fuwen_data, EquipTip.FROM_RUNE)
		end
	end
end

function FuwenView:OnBagItemChange()
	self:Flush()
end

function FuwenView:OnFuwenZhulingState()
	self:FlushZhulingBtn()
end

function FuwenView:RemindChange(remind_name)
	if remind_name == RemindName.FuwenCanZhuling then
		self:FlushZhulingBtn()
	end
end

function FuwenView:FlushZhulingBtn()
	self.btn_fw_zl:setVisible(FuwenData.Instance:GetZhulingActState())
	self.btn_fw_zl.remind_img:setVisible(RemindManager.Instance:GetRemind(RemindName.FuwenCanZhuling) > 0)
end

function FuwenView:FlushFuwenParts()
	for k, v in pairs(self.fuwen_list) do
		v:Flush()
	end
	self.fuwen_suit_eff:setVisible(FuwenData.Instance:IsFullEquip())
	self.fuwen_cap:SetNumber(CommonDataManager.GetAttrSetScore(FuwenData.Instance:GetFuwenAllAttr()))
end

function FuwenView:FlushCrystalNum()
	local num = BagData.Instance:GetItemNumInBagById(CLIENT_GAME_GLOBAL_CFG.fuwen_jh_id)
	self.node_t_list.txt_crystal_num.node:setString(num)
end

-------------------------------------------------------------
-- 符文装备
-------------------------------------------------------------
FuwenView.FuwenRender = BaseClass(BaseRender)
local FuwenRender = FuwenView.FuwenRender
FuwenRender.FIRST_ANGLE = 120
FuwenRender.ANGLE_INTERVAL = 360 / FuwenData.RUNE_PARTS
function FuwenRender:__init(fuwen_idx, ui_cfg, parent, view_obj)
	self:SetIsUseStepCalc(true)
	self.fuwen_idx = fuwen_idx
	self.angle = (fuwen_idx - 1) * FuwenRender.ANGLE_INTERVAL % 360
	self.parent = parent
	self.view_obj = view_obj

	self.parent:addChild(self.view, -1)
	self:SetUiConfig(ui_cfg, true)

	-- self.view:addChild(XUI.CreateTextByType(80, 80, 100, 20, self.fuwen_idx, 1), 999)
	self.view:setAnchorPoint(0.5, 0.5)
	self.view:setContentSize(cc.size(0, 0))
	-- self.view:setBackGroundColor(COLOR3B.GREEN)
	-- self.view:setBackGroundColorOpacity(100)
	self:Flush()
end

function FuwenRender:__delete()
end

function FuwenRender:FuwenIndex()
	return self.fuwen_idx
end

local real_width = 145
local real_height = 175
local dis1 = math.sqrt(real_width * real_width / 2)
local dis2 = 120
local dis3 = math.sqrt(dis2 * dis2 / 2)
local remind_dis1 = real_height - 20
local remind_dis2 = math.sqrt(remind_dis1 * remind_dis1 / 2)
FuwenRender.FUWEN_POS = {
	{anchorp = cc.p(0.5, 0), center_pos = {x = 0, y = dis2},  points = {
		{x = dis1, y = real_height * 2}, {x = dis1 + real_width, y = real_height * 2}, {x = real_height, y = real_height}
	}},
	{anchorp = cc.p(0, 0), center_pos = {x = dis3, y = dis3}, points = {
		{x = dis1 + real_width, y = real_height * 2}, {x = real_height * 2, y = dis1 + real_width}, {x = real_height, y = real_height}
	}},
	{anchorp = cc.p(0, 0.5), center_pos = {x = dis2, y = 0},  points = {
		{x = real_height * 2, y = dis1 + real_width}, {x = real_height * 2, y = dis1}, {x = real_height, y = real_height}
	}},
	{anchorp = cc.p(0, 1), center_pos = {x = dis3, y = -dis3}, points = {
		{x = real_height * 2, y = dis1}, {x = dis1 + real_width, y = 0}, {x = real_height, y = real_height}
	}},
	{anchorp = cc.p(0.5, 1), center_pos = {x = 0, y = -dis2},  points = {
		{x = dis1 + real_width, y = 0}, {x = dis1, y = 0}, {x = real_height, y = real_height}
	}},
	{anchorp = cc.p(1, 1), center_pos = {x = -dis3, y = -dis3}, points = {
		{x = dis1, y = 0}, {x = 0, y = dis1}, {x = real_height, y = real_height}
	}},
	{anchorp = cc.p(1, 0.5),center_pos = {x = -dis2, y = 0},  points = {
		{x = 0, y = dis1}, {x = 0, y = dis1 + real_height}, {x = real_height, y = real_height}
	}},
	{anchorp = cc.p(1, 0), center_pos = {x = -dis3, y = dis3}, points = {
		{x = 0, y = dis1 + real_height}, {x = dis1, y = real_height * 2}, {x = real_height, y = real_height}
	}},
}
function FuwenRender:CreateChildCallBack()
	self.node_tree.img_fwen_light.node:setAnchorPoint(0.5, 1)
	self.node_tree.img_fwen_light.node:setPosition(0, 0)
	self.node_tree.img_fwen_light.node:setRotation(self.angle + 180)
	self.node_tree.img_fwen_light.node:setVisible(false)

	local pos_cfg = FuwenRender.FUWEN_POS[self:FuwenIndex()]
	if nil == pos_cfg then
		return
	end

	self.node_tree.img_fuwen.node:setScale(1)
	self.node_tree.img_fuwen.node:setPosition(0, 0)
	self.node_tree.img_fuwen.node:setAnchorPoint(pos_cfg.anchorp)
	self.node_tree.img_fuwen.node:setVisible(false)

	self.node_tree.img_add.node:setPosition(pos_cfg.center_pos.x, pos_cfg.center_pos.y)
	self.node_tree.img_add.node:setLocalZOrder(99)
	self.node_tree.img_add.node:setVisible(false)

	XUI.RichTextSetCenter(self.node_tree.rich_zhuling_num.node)
	self.node_tree.rich_zhuling_num.node:setAnchorPoint(0.5, 0.5)
	self.node_tree.rich_zhuling_num.node:setPosition(pos_cfg.center_pos.x, pos_cfg.center_pos.y)

	local x_abs = math.abs(pos_cfg.center_pos.x)
	local y_abs = math.abs(pos_cfg.center_pos.y)
	local remind_dis = x_abs ~= y_abs and remind_dis1 or remind_dis2
	local x = pos_cfg.center_pos.x == 0 and 0 or (x_abs / pos_cfg.center_pos.x * remind_dis)
	local y = pos_cfg.center_pos.y == 0 and 0 or (y_abs / pos_cfg.center_pos.y * remind_dis)
	self.remind_img = XUI.CreateImageView(x, y, ResPath.GetRemindImg())
	self.view:addChild(self.remind_img, 99)
	self.remind_img:setVisible(false)
end

function FuwenRender:OnFlush()
	local data = FuwenData.Instance:GetFuwenData(self:FuwenIndex())
	local is_open_zhuling = ViewManager.Instance:IsOpen(ViewDef.Role.RoleInfoList.BiSha.FuwenZhuling)

	local max_data = FuwenData.Instance:GetMaxFuwenByInBag(self:FuwenIndex())

	if data then
		local boss_index, fuwen_index = ItemData.GetItemFuwenIndex(data.item_id)
		self.node_tree.img_fuwen.node:loadTexture(ResPath.GetFuwen(string.format("boss_%d_%d", boss_index, self:FuwenIndex())))
	end
	self.node_tree.img_fuwen.node:setVisible(not is_open_zhuling and nil ~= data)
	-- self.node_tree.img_add.node:setVisible(not is_open_zhuling and nil ~= max_data)
	self.remind_img:setVisible(not is_open_zhuling and nil ~= max_data)

	self.node_tree.rich_zhuling_num.node:setVisible(is_open_zhuling)
	self.node_tree.img_fwen_light.node:setVisible(is_open_zhuling and self:FuwenIndex() == FuwenData.Instance:GetZhulingSlotIndex())

	if is_open_zhuling then
		RichTextUtil.ParseRichText(self.node_tree.rich_zhuling_num.node, string.format("{colorandsize;36c4ff;24;+%d}", FuwenData.Instance:GetZhulingLevel(self:FuwenIndex())))
	end	
end

return FuwenView
