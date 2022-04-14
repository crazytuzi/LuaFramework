--
-- @Author: LaoY
-- @Date:   2019-10-09 15:00:58
--

LoadingResItem = LoadingResItem or class("LoadingResItem",BaseWidget)

function LoadingResItem:ctor(parent_node,builtin_layer)
	self.abName = "system"
	self.assetName = "LoadingResItem"
	self.events = {}
	-- 场景对象才需要修改
	-- self.builtin_layer = builtin_layer

	LoadingResItem.super.Load(self)
end

function LoadingResItem:dctor()
	--if self.effect then
	--	self.effect:destroy()
	--	self.effect = nil
	--end
	self:RemoveAction()
	self:StopTime()
	GlobalEvent:RemoveTabListener(self.events)
end

function LoadingResItem:LoadCallBack()
	self.nodes = {
		"bg/img_d_1","bg","bg/img_d_3","bg/img_d_2","bg/img_close_btn","bg/con",
		"img","resText",
	}
	self:GetChildren(self.nodes)

	self.resText = GetText(self.resText)
	-- 10007
	--self.effect = UIEffect(self.con, 10007, false)

	--SetLocalPosition(self.con,-40,20)
	--SetLocalScale(self.con,0.45,0.45,0.45)
	self:AddEvent()
	self:PlayAni()
end

local space_count = 0
function LoadingResItem:PlayAni()
	local action = cc.RotateTo(1, 360)
	action = cc.Sequence(action, cc.RotateTo(0, 360))
	action = cc.RepeatForever(action)
	cc.ActionManager:GetInstance():addAction(action, self.img)

	self:StopTime()
	local str = ""
	local function step()
		str = ""
		for i=1,space_count do
			str = str .. " . "
		end
		self.resText.text = "Loading" .. str
		space_count = space_count + 1
		if space_count > 3 then
			space_count = 0
		end
	end
	self.time_id = GlobalSchedule:Start(step,0.5)

end

function LoadingResItem:RemoveAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.img)
end

function LoadingResItem:AddEvent()
	local function call_back(target,x,y)
		if self.close_btn_callback then
			self.close_btn_callback()
		end
	end
	AddClickEvent(self.img_close_btn.gameObject,call_back)

	--local function call_back(name)
	--	if name ~= self.panelName then
	--		if self.close_btn_callback then
	--			self.close_btn_callback()
	--		end
	--	end
	--end
	--self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.ShowPreRes,call_back)
end

function LoadingResItem:SetCloseCallBack(close_btn_callback,name)
	self.close_btn_callback = close_btn_callback
	self.panelName = name
end

function LoadingResItem:SetData(data)

end

function LoadingResItem:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = 0
	end
end

function LoadingResItem:ClearPanel()
	if self.close_btn_callback then
		self.close_btn_callback()
	end
end