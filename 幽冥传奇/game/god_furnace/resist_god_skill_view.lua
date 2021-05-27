
-- 抗暴神技
ResistGodSkillView = ResistGodSkillView or BaseClass(BaseView)

function ResistGodSkillView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/godfurnace.png',
	}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
		{"god_furnace_ui_cfg", 3, {0}},
	}
    self.equip_list = {}
	self.gf_data = GodFurnaceData.Instance
end

function ResistGodSkillView:__delete()
end

function ResistGodSkillView:ReleaseCallBack()
	if self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil
	end

	for k, v in pairs(self.equip_list) do
		v:DeleteMe()
	end
	self.equip_list = {}
end

function ResistGodSkillView:LoadCallBack(index, loaded_times)
	self:CreateTopTitle(ResPath.GetGodFurnace("word_kbsj"), 275, 695)

	XUI.AddClickEventListener(self.node_t_list.layout_decompose.node, BindTool.Bind(self.OnClickDecompose, self), true)

	self.num_bar = NumberBar.New()
    self.num_bar:Create(self.ph_list.ph_kb_val.x, self.ph_list.ph_kb_val.y, 0, 0, ResPath.GetGodFurnace("num_124_"))
    self.num_bar:SetSpace(0)
    self.node_t_list.layout_resist_godskill.node:addChild(self.num_bar:GetView(), 101)

	self.node_t_list.rich_skill_desc.node:setVerticalSpace(10)

    self.equip_list = {}
    local ph_equips = self.ph_list.ph_equips
    local layout_equips = XUI.CreateLayout(ph_equips.x, ph_equips.y, 0, 0)
    self.node_t_list.layout_resist_godskill.node:addChild(layout_equips, 10)
    local num = 0
    local x_interval = 20
    local HeartItemRender = ResistGodSkillView.HeartItemRender
    for i = GodFurnaceData.EquipPos.gfFirstHeartMin, GodFurnaceData.EquipPos.gfFirstHeartMax do
    	num = num + 1

    	local heart_item = HeartItemRender.New()
    	heart_item:SetEquipSlot(i)
    	local x = (num - 1) * (HeartItemRender.size.width + x_interval)
    	heart_item:GetView():setPosition(x, 0)
    	layout_equips:addChild(heart_item:GetView(), 1)
    	self.equip_list[i] = heart_item
    end
    layout_equips:setContentWH(num * HeartItemRender.size.width + (num - 1) * x_interval, 80)

    -- 获取材料
    if not IS_AUDIT_VERSION then
		self.link_stuff = RichTextUtil.CreateLinkText("获取心法", 20, COLOR3B.GREEN)
		self.link_stuff:setPosition(255, 15)
		self.node_t_list.layout_resist_godskill.node:addChild(self.link_stuff, 99)
		XUI.AddClickEventListener(self.link_stuff, function()
			local item_id = CLIENT_GAME_GLOBAL_CFG.heart_item_id
			local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
			local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
			TipCtrl.Instance:OpenBuyTip(data)
		end, true)
	end
	
    EventProxy.New(self.gf_data, self):AddEventListener(GodFurnaceData.EQUIP_CHANGE, BindTool.Bind(self.OnEquipChange, self))
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function ResistGodSkillView:OpenCallBack()
end

function ResistGodSkillView:CloseCallBack(is_all)
end

function ResistGodSkillView:ShowIndexCallBack(index)
	self:Flush()
end

function ResistGodSkillView:OnFlush(param_t, index)
	local suit_id = self.gf_data:GetHeartSuitId()
	local cur_suit_info = GodFurnaceData.GetHeartSuitInfo(suit_id)
	local next_suit_info = GodFurnaceData.GetNextHeartSuitInfo(suit_id)

	-- 抗暴+xxx%
	local word_list = {"plus"}
	local rate_num_str = tostring(cur_suit_info.rate)
	for i = 1, #rate_num_str do
		word_list[#word_list + 1] = string.sub(rate_num_str, i, i)
	end
	word_list[#word_list + 1] = "%"
	self.num_bar:SetNumberList(word_list)

	RichTextUtil.ParseRichText(self.node_t_list.rich_skill_desc.node, cur_suit_info.skill_desc)
	RichTextUtil.ParseRichText(self.node_t_list.rich_next_skill.node,
		string.format("{color;1eff00;【%s】}     {color;edd9b2;%s(%d/%d)}",
		next_suit_info.name, next_suit_info.act_desc, self.gf_data:GetHeartSuitIdCount(self.gf_data.GetHeartSuitNextId(suit_id)), GodFurnaceData.HEART_SUIT_NEED_COUNT))

	self:FlushEquips()
end
------------------------------------------------------------------
function ResistGodSkillView:FlushEquips()
	for k, v in pairs(self.equip_list) do
		v:Flush()
	end
end

function ResistGodSkillView:OnEquipChange()
	self:Flush()
end

function ResistGodSkillView:OnBagItemChange()
	self:Flush()
end

function ResistGodSkillView:OnClickDecompose()
	self:GetViewManager():OpenViewByDef(ViewDef.HeartDecompose)
end
------------------------------------------------------------------
local HeartItemRender = BaseClass()
ResistGodSkillView.HeartItemRender = HeartItemRender

HeartItemRender.size = cc.size(80, 80)
function HeartItemRender:__init()
	self.equip_slot = 0
	self.view = XUI.CreateLayout(0, 0, HeartItemRender.size.width, HeartItemRender.size.height)
	self.view:setAnchorPoint(0, 0)

	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(HeartItemRender.size.width / 2, HeartItemRender.size.height / 2)
	self.item_cell:SetAnchorPoint(0.5, 0.5)
	self.item_cell:SetEventEnabled(false)
	self.view:addChild(self.item_cell:GetView(), 100)

	XUI.AddClickEventListener(self.view, BindTool.Bind(self.OnClick, self))

	self.icom_img = nil
	self.remind_img = nil
end
	
function HeartItemRender:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil

	self.icom_img = nil
	self.remind_img = nil
end

function HeartItemRender:OnClick()
	self.best_equip = GodFurnaceData.Instance:GetBestEquipInBag(self.equip_slot)
	if self.best_equip then
		GodFurnaceCtrl.SendPutOnEquipReq(self.best_equip.series, self.equip_slot)
	else
		TipCtrl.Instance:OpenItem(self.item_cell:GetData())
	end
end

function HeartItemRender:GetView()
	return self.view
end

function HeartItemRender:SetEquipSlot(equip_slot)
	if nil == equip_slot then
		return
	end

	self.equip_slot = equip_slot
end

function HeartItemRender:Flush()
	local equip_data = GodFurnaceData.Instance:GetEquip(self.equip_slot)
	self.item_cell:SetData(equip_data)
	self:ShowSlotIconImg(nil == equip_data)
	local item_data = GodFurnaceData.Instance:GetBestEquipInBag(self.equip_slot)
	local show_remind = GodFurnaceData.IsHeartEquipCondMatch(item_data)
	self:ShowRemindImg(show_remind)
end

function HeartItemRender:ShowSlotIconImg(is_show)
	if is_show and nil == self.icom_img then
		local img_path = ResPath.GetGodFurnace(GodFurnaceData.Instance:GetEquipSlotIconImgName(self.equip_slot))
		self.icom_img = XUI.CreateImageView(HeartItemRender.size.width / 2, HeartItemRender.size.height / 2, img_path, true)
		self.view:addChild(self.icom_img, 888)
	elseif nil ~= self.icom_img then
		self.icom_img:setVisible(is_show)
	end
end

function HeartItemRender:ShowRemindImg(is_show)
	if is_show and nil == self.remind_img then
		self.remind_img = XUI.CreateImageView(HeartItemRender.size.width + (-15), HeartItemRender.size.height + (-15), ResPath.GetRemindImg(), true)
		self.view:addChild(self.remind_img, 888)
	elseif nil ~= self.remind_img then
		self.remind_img:setVisible(is_show)
	end
end

return ResistGodSkillView
