
-- 神炉-龙魂
DragonSpiritView = BaseClass(GFCommonView)

function DragonSpiritView:__init()
	self.select_slot = GodFurnaceData.Slot.DragonSpiritPos
end

function DragonSpiritView:__delete()
end

function DragonSpiritView:LoadCallBack(index, loaded_times)
	DragonSpiritView.super.LoadCallBack(self, index, loaded_times)

	-- 抗暴
	self.fire_god_power = XUI.CreateLayout(875, 590, 90, 90)
	self.fire_god_power.SetRemind = function(obj, vis)
		if vis and nil == obj.img_remind then
			obj.img_remind = XUI.CreateImageView(75, 75, ResPath.GetRemindImg())
			obj:addChild(obj.img_remind, 99)
		elseif obj.img_remind ~= nil then
			obj.img_remind:setVisible(vis)
		end
	end
	self.node_t_list.layout_gf_common.node:addChild(self.fire_god_power, 300)
	XUI.AddClickEventListener(self.fire_god_power, BindTool.Bind(self.OnClickFireGodPower, self), true)

	self.fire_god_power:addChild(XUI.CreateImageView(45, 45, ResPath.GetGodFurnace("icon_101")))
	self.fire_god_power:addChild(XUI.CreateImageView(45, 8, ResPath.GetGodFurnace("word_kbsj2")))

    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	self.fire_god_power:setVisible(false)
	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChange, self))
	self:OnRemindChange(RemindName.HeartEquip)
end

function DragonSpiritView:OnFlush(param_t, index)
	DragonSpiritView.super.OnFlush(self, param_t, index)
	
end

function DragonSpiritView:OnClickFireGodPower()
	if GameCondMgr.Instance:GetValue("CondId14") then
		self:GetViewManager():OpenViewByDef(ViewDef.ResistGodSkill)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.GodFurnace.ResistGodSkillOpenTips)
	end
end

function DragonSpiritView:OnRemindChange(remind_name, num)
	if remind_name == RemindName.HeartEquip then
		self.fire_god_power:SetRemind(RemindManager.Instance:GetRemind(RemindName.HeartEquip) > 0)
	end
end

function DragonSpiritView:OnGameCondChange(cond_def)
	if cond_def == "CondId14" then
		self.fire_god_power:setVisible(GameCondMgr.Instance:GetValue("CondId14"))
	end
end

return DragonSpiritView
