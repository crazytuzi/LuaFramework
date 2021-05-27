-- 世界杯BOSS界面
OperActWorldCupBossPage = OperActWorldCupBossPage or BaseClass()

function OperActWorldCupBossPage:__init()
	self.view = nil

end

function OperActWorldCupBossPage:__delete()
	self:RemoveEvent()

	if self.show_items_list then
		self.show_items_list:DeleteMe()
		self.show_items_list = nil
	end

	self.view = nil
end



function OperActWorldCupBossPage:InitPage(view)
	self.view = view
	XUI.RichTextSetCenter(self.view.node_t_list.rich_now_refr_info.node)
	XUI.SetRichTextVerticalSpace(self.view.node_t_list.rich_world_cup_boss_des.node,7)
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnWorldCupBossDataEvt()
end



function OperActWorldCupBossPage:InitEvent()
	self.data_evt = GlobalEventSystem:Bind(OperateActivityEventType.WORLD_CUP_BOSS_DATA, BindTool.Bind(self.OnWorldCupBossDataEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function OperActWorldCupBossPage:RemoveEvent()
	if self.data_evt then
		GlobalEventSystem:UnBind(self.data_evt)
		self.data_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function OperActWorldCupBossPage:UpdateData()
	local act_id = OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS
	local cfg = OperateActivityData.Instance:GetActCfgByActID(act_id)
	local boss_cfg = BossData.GetMosterCfg(cfg.config.BossList[1].boss[1].monsterId)
	local icon = 1
	local name = ""
	if boss_cfg then
		name = boss_cfg.name
		if boss_cfg.icon and boss_cfg.icon ~= 0 then
			icon = boss_cfg.icon
		else	
			icon = boss_cfg.modelid
		end	
	end
	self.view.node_t_list.img_world_cup_boss_head.node:loadTexture(ResPath.GetBossHead("boss_icon_" .. icon))
	self.view.node_t_list.txt_world_cup_boss_name.node:setString(name)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_world_cup_boss_des.node, content, 18, COLOR3B.YELLOW)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
end

function OperActWorldCupBossPage:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_world_cup_list
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateActWorldCupBossRender, gravity, is_bounce, self.view.ph_list.ph_world_cup_item)
		local margin = 1
		local gap = (ph.w - 2 * margin - 2 * self.view.ph_list.ph_world_cup_item.w)
		self.show_items_list:SetItemsInterval(gap)
		self.show_items_list:SetMargin(margin)
		-- self.show_items_list:SetJumpDirection(ListView.Left)
		self.view.node_t_list.layout_world_cup_boss.node:addChild(self.show_items_list:GetView(), 90)
	end
end

function OperActWorldCupBossPage:OnWorldCupBossDataEvt()
	local refr_info = OperateActivityData.Instance:GetWorldCupBossRefrSceneInfo()
	local content = refr_info.name and string.format(Language.OperateActivity.WorldCupBossRefr, refr_info.name or "", 
		refr_info.pos_x or 0, refr_info.pos_y or 0) or Language.OperateActivity.WorldCupBossNoRefr
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_now_refr_info.node, content)
	local data_list = OperateActivityData.Instance:GetWorldCupBossData()
	self.show_items_list:SetDataList(data_list)
	self:FlushRemainTime()
end

function OperActWorldCupBossPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.text_world_cup_boss_rest_time then
		self.view.node_t_list.text_world_cup_boss_rest_time.node:setString(Language.Common.RemainTime.."："..time)
	end
end