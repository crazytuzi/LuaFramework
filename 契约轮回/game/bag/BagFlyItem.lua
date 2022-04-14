BagFlyItem = BagFlyItem or class("BagFlyItem",BaseItem)
local BagFlyItem = BagFlyItem

function BagFlyItem:ctor(parent_node,layer)
	self.abName = "bag"
	self.assetName = "BagFlyItem"
	self.layer = layer

	self.model = BagModel:GetInstance()
	BagFlyItem.super.Load(self)
end

function BagFlyItem:dctor()
end

function BagFlyItem:LoadCallBack()
	self.nodes = {
		"icon",
	}
	self:GetChildren(self.nodes)
	self.icon = GetImage(self.icon)
	self:AddEvent()

	self:UpdateView()
end

function BagFlyItem:AddEvent()
end

function BagFlyItem:SetData(data)
	self.res_icon = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function BagFlyItem:UpdateView()
	local abName = GoodIconUtil.GetInstance():GetABNameById(self.res_icon)
	abName = "iconasset/" .. abName
	local function call_back(sp)
		self.icon.sprite = sp
		--飞行动画
		local x, y = self.model:GetBagPos()
		--[[local start_x, start_y = x+BagItemFlyConfig.off_x, y+BagItemFlyConfig.off_y
		if x then
			SetLocalPositionXY(self.transform, start_x, start_y)
			local action1 = cc.MoveTo(BagItemFlyConfig.time1, start_x, start_y+BagItemFlyConfig.up_y)
			local action2 = cc.DelayTime(BagItemFlyConfig.delay_time)
			local action3 = cc.MoveTo(BagItemFlyConfig.time2, x, y)
			local function end_func()
				self:destroy()
			end
			local action4 = cc.CallFunc(end_func)
    		local action = cc.Sequence(action1, action2, action3, action4)
    		cc.ActionManager:GetInstance():addAction(action, self.transform)
		else
			self:destroy()
		end--]]
		local start_x, start_y = x+BagItemFlyConfig.off_x, y+BagItemFlyConfig.off_y
		local start_pos = Vector2(start_x, start_y)
		SetLocalPositionXY(self.transform, start_x, start_y)
	    local end_pos = Vector2(x, y)
	    local distance = Vector2.Distance(start_pos, end_pos)
	    local radian = math.angle2radian(60)
	    local cos = math.cos(radian)
	    local dir = GetDirByVector(start_pos, end_pos, distance)
	    local dis1 = distance * BagItemFlyConfig.dis1
	    local dis2 = distance * BagItemFlyConfig.dis2
	    local config = {
	        control_1 = Vector2(start_pos.x + dir.x * dis1, start_pos.y + BagItemFlyConfig.up_y + cos * (distance - dis1)),
	        control_2 = Vector2(start_pos.x + dir.x * dis2, start_pos.y + BagItemFlyConfig.up_y + cos * (distance - dis2)),
	        end_pos = end_pos
	    }
	    local action = cc.BezierTo(BagItemFlyConfig.time1, config)
	    action = cc.EaseExponentialOut(action)
	    local function call_back()
	        self:destroy()
	    end
	    local call_action = cc.CallFunc(call_back)
	    action = cc.Sequence(action, call_action)
	    cc.ActionManager:GetInstance():addAction(action, self.transform)
	end
	lua_resMgr:SetImageTexture(self, self.icon, abName, tostring(self.res_icon), true, call_back)
end