local BossKillView = BaseClass(SubView)

function BossKillView:__init()
	self.texture_path_list = {
		--'res/xui/boss.png',
	}
    self.config_tab = {
		{"diamond_back_ui_cfg", 5, {0}},
	}
end

function BossKillView:__delete()
end

function BossKillView:ReleaseCallBack()
	if self.boss_kill_list then
		self.boss_kill_list:DeleteMe()
		self.boss_kill_list = nil
	end
end

function BossKillView:LoadCallBack(index, loaded_times)
	self:BossKillList()
	
	EventProxy.New(DiamondBackData.Instance, self):AddEventListener(DiamondBackData.BOSS_FIRST_KILL, BindTool.Bind(self.BosskillInfo, self))

	local _s, _e = DiamondBackData.Instance:ActOpenStartTime()
	self.node_t_list.lbl_boss_time.node:setString(string.format(Language.DiamondBack.OpneTimeShow, _s.year, _s.month, _s.day, _e.year, _e.month, _e.day))
end

function BossKillView:ShowIndexCallBack()
	self:Flush()
end

function BossKillView:BosskillInfo()
	self:Flush()
end

function BossKillView:BossKillList()
	if nil == self.boss_kill_list then
		local ph = self.ph_list.ph_boss_list
		self.boss_kill_list = ListView.New()
		self.boss_kill_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossKillView.BossKillRender, nil, nil, self.ph_list.ph_boss_item)
		-- self.boss_kill_list:GetView():setAnchorPoint(0, 0)
		self.boss_kill_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_boss_kill.node:addChild(self.boss_kill_list:GetView(), 100)
	end			
end

function BossKillView:OnFlush(param_t)
	self.boss_kill_list:SetDataList(DiamondBackData.Instance:GetBossKillList())
end

BossKillView.BossKillRender = BaseClass(BaseRender)
local BossKillRender = BossKillView.BossKillRender
function BossKillRender:__init()	

end

function BossKillRender:__delete()	
end

function BossKillRender:CreateChild()
	BaseRender.CreateChild(self)

	local parent = self.view
	local ph = self.ph_list["ph_cell"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = ActBaseCell.New()
	cell:SetIsShowTips(false)
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.cell = cell
end

function BossKillRender:OnFlush()
	if self.data == nil then return end

	local cfg = self.data.cfg or {}

	local award = cfg.awards and cfg.awards[1] or {}
	self.cell:SetData(ItemData.InitItemDataByCfg(award))

	local color = self.data.kill_name ~= "" and Str2C3b("9c9181") or COLOR3B.GREEN
	self.node_tree.lbl_boss_name.node:setString(cfg.name)
	self.node_tree.lbl_boss_name.node:setColor(color)
	self.node_tree.lbl_boss_map.node:setString(cfg.SceneName)
	self.node_tree.lbl_boss_map.node:setColor(color)
	self.node_tree.lbl_boss_state.node:setString(self.data.kill_name ~= "" and self.data.kill_name or "未击杀")
	self.node_tree.lbl_boss_state.node:setColor(color)
end

function BossKillRender:CreateSelectEffect()
end

return BossKillView