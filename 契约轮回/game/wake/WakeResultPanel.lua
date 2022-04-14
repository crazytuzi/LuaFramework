WakeResultPanel = WakeResultPanel or class("WakeResultPanel",BasePanel)
local WakeResultPanel = WakeResultPanel

function WakeResultPanel:ctor()
	self.abName = "wake"
	self.assetName = "WakeResultPanel"
	self.layer = "Top"

	self.use_background = true
	self.change_scene_close = true
	click_bg_close = true -- 点击背景关闭

	self.model = WakeModel:GetInstance()
end

function WakeResultPanel:dctor()
end

function WakeResultPanel:Open()
	WakeResultPanel.super.Open(self)
end

function WakeResultPanel:LoadCallBack()
	self.nodes = {
		"bg","boy","girl",
	}
	self:GetChildren(self.nodes)

	self.bg = GetImage(self.bg)
	self:AddEvent()
end

function WakeResultPanel:AddEvent()

end

function WakeResultPanel:OpenCallBack()
	self:UpdateView()
end

function WakeResultPanel:UpdateView( )
	local career = RoleInfoModel:GetInstance():GetRoleValue("career")
	local res = "wake_boy_bg"
	local node = self.boy
	if career == 2 then
		res = "wake_girl_bg"
		SetVisible(self.boy, false)
		SetVisible(self.girl, true)
		node = self.girl
	else
		SetVisible(self.boy, true)
		SetVisible(self.girl, false)
		node = self.boy
	end
    lua_resMgr:SetImageTexture(self,self.bg, "iconasset/icon_big_bg_"..res, res)
    self:DoAction(node)
end

function WakeResultPanel:DoAction(action_node)
	local x, y = GetLocalPosition(action_node)
	local action = cc.MoveTo(0.5, 0, y, 0)
	--[[local function call_back()
		local function end_func()
			local action2 = cc.MoveTo(0.4, 100, y, 0)
			local function end_call_back()
		        self:Close()
		    end
		    local call_action2 = cc.CallFunc(end_call_back)
		    local action4 = cc.Sequence(action2, call_action2)
			cc.ActionManager:GetInstance():addAction(action4, action_node)
		end
		GlobalSchedule:StartOnce(end_func, 0.7)
	end--]]
	local action2 = cc.MoveTo(1.5, 200, y, 0)
	local function call_back(  )
		self:Close()
	end
	local call_action = cc.CallFunc(call_back)
	local action3 = cc.Sequence(action, action2, call_action)
	cc.ActionManager:GetInstance():addAction(action3, action_node)
end

function WakeResultPanel:CloseCallBack(  )

end