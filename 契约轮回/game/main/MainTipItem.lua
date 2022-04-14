--
-- @Author: LaoY
-- @Date:   2019-01-04 17:40:42
--

MainTipItem = MainTipItem or class("MainTipItem",BaseCloneItem)

function MainTipItem:ctor(obj,parent_node,layer)
	self.model = MainModel:GetInstance()
	MainTipItem.super.Load(self)
end

function MainTipItem:dctor()
    self:StopAction()
	self:StopTime()
end

function MainTipItem:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)

	self.img_component = self.transform:GetComponent('Image')

	self:AddEvent()
end

function MainTipItem:AddEvent()
	local function call_back(target,x,y)
		if self.data.call_back then
			self.data.call_back()
		end
		self:StopAction()
		if self.config.is_delete then
			self.model:RemoveMidTipIcon(self.data.key_str,self.data.sign)
		end
	end
	AddClickEvent(self.gameObject,call_back)
end

function MainTipItem:StartAction()
    self:StopAction()
    local action
    local action_time = 0.8
    local blink_time = 0.1
    -- 原地缩放
    if self.config.action_type == 1 then
        local time_1 = action_time / 2
        action = cc.ScaleTo(time_1,0.85)
        action = cc.Sequence(action,cc.ScaleTo(time_1,1))
    -- 闪烁效果
    elseif self.config.action_type == 2 then
        action = cc.Blink:Create(blink_time * 2,2,self)
    -- 原地缩放 + 闪烁效果
    elseif self.config.action_type == 3 then
    	local time_1 = action_time /2
        action = cc.ScaleTo(time_1,0.85)
        action = cc.Sequence(action,cc.ScaleTo(time_1,1))
        action = cc.Repeat(action,4)
        local blink_action = cc.Blink:Create(blink_time * 4,4,self)
        action = cc.Sequence(action,blink_action)
    end
    if not action then
        return
    end
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action,self.transform)
end

function MainTipItem:StopAction()
	self:SetScale(1.0)
	if self.transform then
		cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
	end
end

function MainTipItem:StartTime()
	self:StopTime()
	if not self.data.end_time then
		return
	end
	local function step()
		if self.data.end_time - os.time() < 0 then
			self:StopTime()
			self.model:RemoveMidTipIcon(self.data.key_str,self.data.sign)
		end
	end
	self.time_id = GlobalSchedule:Start(step,1.0)
end

function MainTipItem:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function MainTipItem:SetData(index,data)
	self.index = index
	self.data = data
	self.config = IconConfig.MidTipConfig[self.data.key_str]

	self:LoadImageTexture()
	self:StartAction()
	self:StartTime()
end

function MainTipItem:LoadImageTexture()
    local icon = self.config.res
    if not icon then
        return
    end
    local res_tab = string.split(icon,":")
    local abName = res_tab[1]
    local assetName =  res_tab[2]
    if self.res_name == assetName then
        return
    end
    self.res_name = assetName
    lua_resMgr:SetImageTexture(self,self.img_component,abName,assetName,false,nil)
end