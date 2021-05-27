--装备Boss

BossEquipmentPage = BossEquipmentPage or BaseClass()


function BossEquipmentPage:__init()
	
end	

function BossEquipmentPage:__delete()
	self:RemoveEvent()
	self.view = nil
end	

--初始化页面接口
function BossEquipmentPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateCell()
	self:InitEvent()
	-- self:OnEquipBossDataChange()
end	

--初始化事件
function BossEquipmentPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_eqboss_tip.node, BindTool.Bind(self.OnHelp, self), true)
	self.equip_boss_evt = GlobalEventSystem:Bind(EquipBossEvent.EQUIP_BOSS_DATA_CHANGE, BindTool.Bind(self.OnEquipBossDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end


--移除事件
function BossEquipmentPage:RemoveEvent()
	if self.equip_boss_evt then
		GlobalEventSystem:UnBind(self.equip_boss_evt)
		self.equip_boss_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--更新视图界面
function BossEquipmentPage:UpdateData(data)
	self:OnEquipBossDataChange()
end

function BossEquipmentPage:CreateCell()
	local cfg = BossSportData.Instance:GetEquipBossCfg()
	self.boss_equipment_cell = {}
	for i = 1, 8 do
		local ph = self.view.ph_list["ph_item_cell_"..i]
		local cur_data =  cfg[i]
		local cell = self:CreateRender(ph, cur_data, i)
		table.insert(self.boss_equipment_cell, cell)
	end
end

function BossEquipmentPage:CreateRender(ph, cur_data, index)
	local cell = BossEquipmentRender.New()
	local render_ph = self.view.ph_list.ph_item_cell 
	cell:SetIndex(index)
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x, ph.y)
	self.view.node_t_list["page7"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function BossEquipmentPage:OnEquipBossDataChange()
	local fb_point = BossSportData.Instance:GetEquipBossData()
	self.view.node_t_list.txt_point.node:setString(fb_point)
	self:FlushTime()
end

function BossEquipmentPage:FlushTime()
	local _, rest_time = BossSportData.Instance:GetEquipBossData()
	local add_rest_time = BossSportData.Instance:GetEqBossAddRestTime()
	local time_str = ""
	if rest_time >= 0 then
		time_str = TimeUtil.FormatSecond(add_rest_time, 2)
	elseif rest_time == -1 then
		time_str = Language.Boss.EqPointLimit
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
	end
	self.view.node_t_list.txt_remian_time.node:setString(time_str)
end

function BossEquipmentPage:SetData()
	-- body
end

function BossEquipmentPage:OnHelp()
	DescTip.Instance:SetContent(Language.Boss.Content[1], Language.Boss.Title[1])
end

--Render
BossEquipmentRender = BossEquipmentRender or BaseClass(BaseRender)

function BossEquipmentRender:__init()

end

function BossEquipmentRender:__delete()
end

function BossEquipmentRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.view, BindTool.Bind(self.OnViewClick, self), true)
end

function BossEquipmentRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.img_stage_bg.node:loadTexture(ResPath.GetBoss("beq_icon_" .. self.data.idx))
	self.node_tree.img_fb_name.node:loadTexture(ResPath.GetBoss("beq_txt_" .. self.data.idx))
	local cost_str = string.format(Language.Boss.EqCost, self.data.cost or 0)
	self.node_tree.txt_consume.node:setString(cost_str)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if level >= self.data.level_limit[2] and circle_level >= self.data.level_limit[1] then
		self.node_tree.txt_need_lev.node:setVisible(false)
	else
		self.node_tree.txt_need_lev.node:setVisible(true)
		self.node_tree.txt_need_lev.node:setColor(COLOR3B.RED)
		self.node_tree.txt_need_lev.node:setString(string.format(Language.Boss.ConsumeLevel, self.data.level_limit[2]))
	end
end

function BossEquipmentRender:OnViewClick()
	if not self.data then return end
	BossSportCtrl.Instance:EquipBossReq(2, self.data.idx)
end