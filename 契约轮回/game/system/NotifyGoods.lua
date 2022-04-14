-- 
-- @Author: LaoY
-- @Date:   2018-07-13 20:38:02
-- 
NotifyGoods = NotifyGoods or class("NotifyGoods",BaseWidget)
NotifyGoods.__cache_count = 5

function NotifyGoods:ctor(parent_node,builtin_layer)
	self.abName = "system"
	self.assetName = "NotifyGoods"

	NotifyGoods.super.Load(self)
end

function NotifyGoods:dctor()
	self:StopAction()

	if self.iconSettor ~= nil then
		self.iconSettor:destroy()
	end
end

function NotifyGoods:__reset(...)
	NotifyGoods.super.__reset(self,...)
	self:SetPosition(self.start_x,self.start_y,self.start_z)
	self:SetAlpha(1)
	SetVisible(self.img_bg,true)
	SetVisible(self.icon_bg,true)
end

function NotifyGoods:__clear()
	self:StopAction()
	SystemTipManager:GetInstance():RemoveTextNotify(self)
	NotifyGoods.super.__clear(self)
end

function NotifyGoods:LoadCallBack()
	self.nodes = {
		"text","img_bg","icon","icon_bg","starContain","step",
	}
	self:GetChildren(self.nodes)

	self:SetPosition(140,240)
	self.start_x,self.start_y,self.start_z = self:GetPosition()
	self.show_text = self.text:GetComponent('Text')
	self.img_component = self.img_bg:GetComponent('Image')
	-- self.outline_text = self.text:GetComponent('Outline')

	self.icon_component = self.icon:GetComponent('Image')
	self.icon_bg_component = self.icon_bg:GetComponent('Image')

	SetVisible(self.img_bg,true)
	SetVisible(self.icon_bg,true)

	self:AddEvent()
end

function NotifyGoods:AddEvent()
end

function NotifyGoods:SetAlpha(a)
	SetAlpha(self.show_text,a)	
	-- SetAlpha(self.outline_text,a)
	SetAlpha(self.img_component,a)
	SetAlpha(self.icon_component,a)
	SetAlpha(self.icon_bg_component,a)
end

function NotifyGoods:StartAction()
	local move_time = 0.3
	local delay_time_1 = 0.3
	local delay_time_2 = 0.5
	local action
	self:SetAlpha(0)
	local fade_time = 0.4
	local function GetFadeAction(time,flag)
		local tab = {self.show_text,self.img_component,self.icon_component,self.icon_bg_component}
		local action = flag and cc.FadeIn or cc.FadeOut
		local t = {}
		for k,transform in pairs(tab) do
			t[#t+1] = action(time,transform)
		end
		return cc.Spawn(unpack(t))
	end
	local fadein_action = GetFadeAction(fade_time,true)
	action = self:ComboAction(action,fadein_action)
	local delayaction = cc.DelayTime(delay_time_1)
	action = self:ComboAction(action,delayaction)
	local moveAction = cc.MoveTo(move_time,10,self.start_y,self.start_z)
	action = self:ComboAction(action,moveAction)
	local delayaction = cc.DelayTime(delay_time_2)
	action = self:ComboAction(action,delayaction)
	local fadeout_action = GetFadeAction(fade_time,false)
	action = self:ComboAction(action,fadeout_action)
	local function on_end_callback()
		self:destroy()
	end
	local end_action = cc.CallFunc(on_end_callback)
	action = self:ComboAction(action,end_action)
	cc.ActionManager:GetInstance():addAction(action,self.transform)
end

function NotifyGoods:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

function NotifyGoods:ComboAction(action1,action2)
	if action1 and action2 then
		return cc.Sequence(action1,action2)
	elseif not action1 then
		return action2
	elseif not action2 then
		return action1
	end
end

function NotifyGoods:SetData(goods_id,number)
	local config = Config.db_item[goods_id]
	if not config then
		return
	end
	-- self.show_text.text = string.format("<color=#%s>%sx%s</color>",ColorUtil.GetColor(config.color),config.name,number)
	self.show_text.text = string.format("%sx%s",config.name,number)

	local icon = config.icon
	local abName = GoodIconUtil.GetInstance():GetABNameById(icon)
	abName = "iconasset/" .. abName
	if self.icon_abName ~= abName or self.icon_name ~= tostring(icon) then
		self.icon_abName = abName
        self.icon_name = tostring(icon);
		lua_resMgr:SetImageTexture(self,self.icon_component,abName,tostring(icon),true)
	end

	-- SetVisible(self.icon_bg_component,false)
	local quality = config.color
	if self.last_quality ~= quality then
		self.last_quality = quality
		lua_resMgr:SetImageTexture(self,self.icon_bg_component,"common_image","com_icon_bg_" .. quality,true,nil,false)
	end

	local equipCfg = Config.db_equip[goods_id]
	if equipCfg ~= nil and config.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
		self:UpdateStar(equipCfg.star)
		self:UpdateStep("j" .. equipCfg.order)
	else
		self:UpdateStep("")
		self:UpdateStar(0)
	end

	local bg_id = config.color
	if bg_id < 4 then
		bg_id = 4
	end
	if self.last_bg_id ~= bg_id then
		self.last_bg_id = bg_id
		lua_resMgr:SetImageTexture(self,self.img_component,"system_image","img_notify_goods_bg_" .. bg_id,true,nil,false)
	end
end

function NotifyGoods:UpdateStep(step)
	self.step:GetComponent('Text').text = step
end

function NotifyGoods:UpdateStar(star)
	SetVisible(self.starContain, true)
	local startCount = self.starContain.childCount
	for i = 0, startCount - 1 do
		if i < star then
			SetVisible(self.starContain:GetChild(i), true)
		else
			SetVisible(self.starContain:GetChild(i), false)
		end
	end
end