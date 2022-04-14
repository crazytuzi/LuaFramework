--
-- @Author: LaoY
-- @Date:   2018-12-18 20:09:45
--

GiftRewardMaigcItem = GiftRewardMaigcItem or class("GiftRewardMaigcItem",BaseCloneItem)
local GiftRewardMaigcItem = GiftRewardMaigcItem

function GiftRewardMaigcItem:ctor(obj,parent_node,layer)
	GiftRewardMaigcItem.super.Load(self)
end

function GiftRewardMaigcItem:dctor()
	self:StopAction()
	self:RemoveEffect()
	if self.magic_card then
		self.magic_card:destroy()
	end
end

function GiftRewardMaigcItem:LoadCallBack()
	self.nodes = {
		"con","text_name"
	}
	self:GetChildren(self.nodes)

	SetLocalScale(self.con,0.6)
	self.text_name_component = self.text_name:GetComponent('Text')
	self:AddEvent()
end

function GiftRewardMaigcItem:AddEvent()
end

function GiftRewardMaigcItem:SetData(index,item_id,num)
	self.index = index
	local cf = Config.db_magic_card[item_id]
	if not self.magic_card then
		self.magic_card = MagicCard(self.con,cf)
	else
		-- self.magic_card:
	end

	local item_cf = Config.db_item[item_id]
	self.text_name_component.text = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(item_cf.color),cf.name)

	if item_cf.color == 5 then
		self:AddEffect(20424)
	elseif item_cf.color == 6 then
		self:AddEffect(20423)
	else
		self:RemoveEffect()
	end

	self:StartAction()
end

function GiftRewardMaigcItem:AddEffect(effect_id)
    if not self.value_effect then
        self.value_effect = UIEffect(self.transform, effect_id, false)
    end
end

function GiftRewardMaigcItem:RemoveEffect()
    if self.value_effect then
        self.value_effect:destroy()
        self.value_effect = nil
    end
end

function GiftRewardMaigcItem:StartAction()
	self:StopAction()
	-- local action = cc.Show()
	local scale_time = 0.4
	local action = cc.ScaleTo(0,0.01)
	action = cc.Sequence(action,cc.DelayTime(self.index * 0.1))
	action = cc.Sequence(action,cc.ScaleTo(0,3))
	-- action = cc.Sequence(action)
	action = cc.Sequence(action,cc.ScaleTo(scale_time,0.7),cc.ScaleTo(scale_time,1.0))
	
	cc.ActionManager:GetInstance():addAction(action,self.transform)
end

function GiftRewardMaigcItem:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end