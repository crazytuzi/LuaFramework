local BossKillRecordView = BaseClass(SubView)

function BossKillRecordView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"boss_ui_cfg", 8, {0}},
	}
end

function BossKillRecordView:__delete()
end

function BossKillRecordView:ReleaseCallBack()
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end
end

function BossKillRecordView:LoadCallBack(index, loaded_times)
	NewBossCtrl.Instance:SendBossKillInfoReq()

	EventProxy.New(NewBossData.Instance, self):AddEventListener(NewBossData.UPDATA_KILL_INFO, BindTool.Bind(self.BossKillWorldInfo, self))

	self:TreasureRecord()
	
end

function BossKillRecordView:BossKillWorldInfo()
	self:Flush()
end

function BossKillRecordView:ShowIndexCallBack()
	self:Flush()
end

function BossKillRecordView:TreasureRecord()
	if nil == self.record_list then
		local ph = self.ph_list.ph_record_list
		self.record_list = ListView.New()
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossKillRecordView.BossRecordRender, nil, nil, self.ph_list.ph_record_item)
		self.record_list:GetView():setAnchorPoint(0, 0)
		self.record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_kill_info.node:addChild(self.record_list:GetView(), 100)
	end		
end

function BossKillRecordView:OnFlush(param_t)
	self.record_list:SetDataList(NewBossData.Instance:GetBossRecastList())
end

BossKillRecordView.BossRecordRender = BaseClass(BaseRender)
local BossRecordRender = BossKillRecordView.BossRecordRender
function BossRecordRender:__init()	
end

function BossRecordRender:__delete()	
end

function BossRecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossRecordRender:OnFlush()
	if self.data == nil then return end
	
	local id = tonumber(self.data.item_id)

	local item_cfg = ItemData.Instance:GetItemConfig(id)

	if nil == item_cfg then 
		return 
	end
	
	local color = string.format("%06x", item_cfg.color)
	self.rolename_color = "00ffff"
	
	local text = string.format(Language.Boss.WorldRecord, self.data.mon, self.data.day, self.data.hour, self.data.minute, self.rolename_color, self.data.name, self.data.map_name, self.data.boss_name, color, item_cfg.name, id)
	if self.data.mon and self.data.day and self.data.hour and self.data.minute and self.rolename_color and self.data.name and self.data.map_name and self.data.boss_name then
		RichTextUtil.ParseRichText(self.node_tree.rich_record.node, text, 18, COLOR3B.G_Y)
	end
end

function BossRecordRender:CreateSelectEffect()
end

return BossKillRecordView