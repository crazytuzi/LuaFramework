--boss个人页面
BossPersonPage = BossPersonPage or BaseClass()


function BossPersonPage:__init()
	
end	

function BossPersonPage:__delete()

	self:RemoveEvent()
	self.view = nil

	if self.chest_grid_boss ~=nil then
		self.chest_grid_boss:DeleteMe()
		self.chest_grid_boss = nil 
	end 
end	

--初始化页面接口
function BossPersonPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.cur_index = 1 
	XUI.AddClickEventListener(self.view.node_t_list.btn_left.node, BindTool.Bind1(self.TurnLeft, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_right.node, BindTool.Bind1(self.TurnRight, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_personal_boss_tip.node, BindTool.Bind1(self.OpenPersonalBossDescTip, self), true)
	self:CreateChest()
	local pos_t = {}
	local index = 0
	for i = 1, 7 do
		local ph = self.view.ph_list["ph_item_cell_"..i]
		pos_t[index] = {x = ph.x, y = ph.y}
		index = index + 1
	end
	BossSportData.Instance:SetBossPosition(pos_t)
	self:InitEvent()
	
end	

function BossPersonPage:TurnLeft()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self:FlushView()
	end
end

function BossPersonPage:TurnRight()
	if self.cur_index < 2 then
		self.cur_index = self.cur_index + 1
		self:FlushView()
	end
end

function BossPersonPage:CreateChest()
	if self.chest_grid_boss == nil then
		local ph = self.view.ph_list.ph_chest_grid
		self.chest_grid_boss = BaseGrid.New()
		local grid_node = self.chest_grid_boss:CreateCells({w = ph.w, h = ph.h, cell_count = 7, col = 7, row = 1, itemRender = BossPersonalRender, direction = ScrollDir.Horizontal, ui_config = self.view.ph_list.ph_item})
		grid_node:setPosition(ph.x, ph.y)
		grid_node:setAnchorPoint(0, 0)
		self.view.node_t_list.page3.node:addChild(grid_node, 100)
	end
end

--初始化事件
function BossPersonPage:InitEvent()
end

function BossPersonPage:OnTransmit()
end

function BossPersonPage:UpdateData(data)
	self:FlushView()
end

function BossPersonPage:FlushView()
	local data = BossSportData.Instance:GetBossSportData()
	local index = 0 
	local cur_data  = {}
	for k, v in pairs(data) do
		if v.tabIdx == self.cur_index then
			cur_data[index] = v
			index = index + 1
		end
	end
	self.chest_grid_boss:SetDataList(cur_data)
	self.cells = self.chest_grid_boss:GetAllCell()
	for k, v in pairs(self.cells) do
		if v:GetData() ~= nil then
			v:GetView():setVisible(true)
		else
			v:GetView():setVisible(false)
		end
	end
	self.view.node_t_list.btn_left.node:setVisible(self.cur_index ~=1)
	self.view.node_t_list.btn_right.node:setVisible(self.cur_index ~=2)
end

--移除事件
function BossPersonPage:RemoveEvent()
	ClientCommonButtonDic[CommonButtonType.BOSS_PERSON_TIAOZHAN_BTN] = nil
end

--更新视图界面
function BossPersonPage:UpdateData(data)
	self:FlushView()
end	

function BossPersonPage:OpenPersonalBossDescTip()
	DescTip.Instance:SetContent(Language.Boss.PersonalBossContent, Language.Boss.PersonalBossTitle)
end
 ----------------------------------------------------
BossPersonalRender = BossPersonalRender or BaseClass(BaseRender)
function BossPersonalRender:__init()

end

function BossPersonalRender:__delete()	
end

function BossPersonalRender:CreateChild()
	BaseRender.CreateChild(self)
	local n = self.index%7
	local data = BossSportData.Instance:GetBossPosition()
	self.view:setPosition(data[n].x, data[n].y)
	XUI.AddClickEventListener(self.view, BindTool.Bind1(self.OpenPersonalTip, self), true)
end

function BossPersonalRender:OnFlush()
	if self.data == nil then return end
	RichTextUtil.ParseRichText(self.node_tree.rich_name.node, self.data.boss_name)
	XUI.RichTextSetCenter(self.node_tree.rich_name.node)
	self.node_tree.txt_time.node:setString(string.format(Language.Boss.RemainTime, self.data.enter_time, (self.data.time_limit or 3)))
	local cfg = BossData.GetMosterCfg(self.data.boss_id)
	if cfg ~= nil then
		local monster_id = cfg.modelid
		local path = ResPath.GetBossHead("boss_icon_"..monster_id)
		self.node_tree.img_stage_bg.node:loadTexture(path)
		self.node_tree.txt_level.node:setString(cfg.level)
	end
	self.node_tree.img_stage_bg.node:setGrey(self.data.boss_state ~= 1)

end

function BossPersonalRender:OpenPersonalTip()
	local bool_enter = BossSportData.Instance:CanEnter(self.data.boss_pos)
	if bool_enter == true then
		BossSportCtrl.Instance:OpenPersonalBossTip(self.data.boss_pos, self.data, bool_enter)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Boss.TipBossDess)
	end
end


