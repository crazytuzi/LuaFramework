
-- 神炉-宝石
GemStoneView = BaseClass(GFCommonView)

function GemStoneView:__init()
	self.select_slot = GodFurnaceData.Slot.GemStonePos
	
end

function GemStoneView:__delete()
end

function GemStoneView:LoadCallBack(index, loaded_times)
	GemStoneView.super.LoadCallBack(self, index, loaded_times)
	-- 烈焰神力
	self.fire_god_power = XUI.CreateLayout(875, 590, 90, 90)
	self.fire_god_power.SetRemind = function(obj, vis)
		if vis and nil == obj.img_remind then
			obj.img_remind = XUI.CreateImageView(75, 75, ResPath.GetRemindImg())
			obj:addChild(obj.img_remind, 99)
		elseif obj.img_remind ~= nil then
			obj.img_remind:setVisible(vis)
		end
	end
	self.fire_god_power:setVisible(false)
	self.node_t_list.layout_gf_common.node:addChild(self.fire_god_power, 300)
	XUI.AddClickEventListener(self.fire_god_power, BindTool.Bind(self.OnClickFireGodPower, self), true)

	self.fire_god_power:addChild(XUI.CreateImageView(45, 45, ResPath.GetGodFurnace("icon_100")))
	self.fire_god_power:addChild(XUI.CreateImageView(45, 8, ResPath.GetGodFurnace("word_lysl2")))

    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	-- self.fire_god_power:setVisible(GameCondMgr.Instance:GetValue("CondId13"))
	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChange, self))
	self:OnRemindChange(RemindName.FireGodPowerCanUp)
	
end

function GemStoneView:OnFlush(param_t, index)
	GemStoneView.super.OnFlush(self, param_t, index)
end

function GemStoneView:OnClickFireGodPower()
	if GameCondMgr.Instance:GetValue("CondId13") then
	--	self:GetViewManager():OpenViewByDef(ViewDef.FireGodPower)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.GodFurnace.FireGodPowerOpenTips)
	end
end

function GemStoneView:OnGameCondChange(cond_def)
	if cond_def == "CondId13" then
		self.fire_god_power:setVisible(GameCondMgr.Instance:GetValue("CondId13"))
	end
end

function GemStoneView:OnRemindChange(remind_name, num)
	if remind_name == RemindName.FireGodPowerCanUp then
		self.fire_god_power:SetRemind(RemindManager.Instance:GetRemind(RemindName.FireGodPowerCanUp) > 0)
	end
end

return GemStoneView
