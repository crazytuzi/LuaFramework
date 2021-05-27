-- 掉落信息
local NativeDropView = BaseClass(SubView)

function NativeDropView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 2, {0}},
	}
end

function NativeDropView:__delete()
end

function NativeDropView:ReleaseCallBack()
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end
end

function NativeDropView:LoadCallBack(index, loaded_times)
	NewBossCtrl.Instance:SendBossKillInfoReq()

	EventProxy.New(NewBossData.Instance, self):AddEventListener(NewBossData.UPDATA_KILL_INFO, BindTool.Bind(self.BossKillWorldInfo, self))

	self:TreasureRecord()
	
end

function NativeDropView:BossKillWorldInfo()
	self:Flush()
end

function NativeDropView:ShowIndexCallBack()
	self:Flush()
end

function NativeDropView:TreasureRecord()
	if nil == self.record_list then
		local ph = self.ph_list.ph_record_list
		self.record_list = ListView.New()
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, NativeDropView.BossDropRender, nil, nil, self.ph_list.ph_record_item)
		self.record_list:GetView():setAnchorPoint(0, 0)
		self.record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_kill_info.node:addChild(self.record_list:GetView(), 100)
	end		
end

function NativeDropView:OnFlush(param_t)
	-- PrintTable(NewBossData.Instance:GetBossRecastList())
	self.record_list:SetDataList(NewBossData.Instance:GetBossRecastList())
end

NativeDropView.BossDropRender = BaseClass(BaseRender)
local BossDropRender = NativeDropView.BossDropRender
function BossDropRender:__init()	
end

function BossDropRender:__delete()	
end

function BossDropRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossDropRender:OnFlush()
	if self.data == nil then return end
	
	local id = tonumber(self.data.item_id)

	local item_cfg = ItemData.Instance:GetItemConfig(id)

	if nil == item_cfg then 
		return 
	end
	
	local color = string.format("%06x", item_cfg.color)
	self.rolename_color = "00ffff"
	local scene_config = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	local boss_cfg = BossData.GetMosterCfg(self.data.boss_id)

	local text = string.format(Language.Boss.WorldRecord, self.data.mon, self.data.day, self.data.hour, self.data.minute, self.rolename_color, self.data.name, scene_config.name, boss_cfg.name, color, item_cfg.name, id)
	RichTextUtil.ParseRichText(self.node_tree.rich_record.node, text, 18, COLOR3B.G_Y)
end

function BossDropRender:CreateSelectEffect()
end

return NativeDropView