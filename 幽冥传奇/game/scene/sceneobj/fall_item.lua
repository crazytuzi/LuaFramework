
FallItem = FallItem or BaseClass(SceneObj)
local NAME_BOARD_OFFY = 30
function FallItem:__init()
	self.obj_type = SceneObjType.FallItem

	self.icon_id = 100
	self.height = 0
	self.name_board = nil

	self.last_pick_time = 0
end

function FallItem:__delete()
	--删除头顶名字窗口
	if self.name_board ~= nil then
		self.name_board:DeleteMe()
		self.name_board = nil
	end
end

function FallItem:LoadInfoFromVo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)

	if self.vo.item_id == 0 then
		self.icon_id = 398						-- 铜币
		if self.vo.item_num >= 20000 then
			self.icon_id = 403
		elseif self.vo.item_num >= 10001 then
			self.icon_id = 402
		elseif self.vo.item_num >= 5001 then
			self.icon_id = 401
		elseif self.vo.item_num >= 2001 then
			self.icon_id = 400
		elseif self.vo.item_num >= 1001 then
			self.icon_id = 399
		end
	elseif self.vo.item_id == 65535 then
		self.icon_id = 603
	else
		self.icon_id = self.vo.icon_id
	end

	if nil == self.name_board then
		local name_board = NameBoard.New()
		if self.vo.item_id == 0 then
			name_board:SetName("元宝", UInt2C3b(self.vo.color))
		else		
			name_board:SetName(self.vo.name, UInt2C3b(self.vo.color))
		end
		self:SetNameBoard(name_board)
	end
end

function FallItem:InitAnimation()
	local sprite = XUI.CreateSprite(ResPath.GetItem(self.icon_id), false)
	if nil == sprite then
		Log("FallItem create sprite error item_id:" .. self.vo.item_id .. " icon_id:" .. self.icon_id)
		return
	end

	local effect_id = CleintItemEffectCfg[self.vo.item_id]
	if effect_id then
		local act_eff = RenderUnit.CreateEffect(effect_id, sprite, -10, nil, nil)
		act_eff:setScale(1.5)
	end

	sprite:setScale(0.1)
	sprite:setPosition(0, 80)
	self.model:AttachNode(sprite, cc.p(0, 80), GRQ_SCENE_OBJ, InnerLayerType.Main)

	local server_time = TimeCtrl.Instance:GetServerTime()
	local fall_time = self.vo.fall_time
	if fall_time and server_time - fall_time > 0 and server_time - fall_time <  2 then	
		local move_to = cc.JumpTo:create(0.6, cc.p(0, 0), math.random(30, 70), 1)
		local scale_to = cc.ScaleTo:create(0.3, 0.5)
		local ease_sine = cc.EaseSineIn:create(cc.Spawn:create(move_to, scale_to))
		local call_back = cc.CallFunc:create(function()

		end)
		local action = cc.Sequence:create(ease_sine, call_back)

		sprite:runAction(action)
	else
		sprite:setScale(0.5)
		sprite:setPosition(0, 0)
	end
end

function FallItem:GetItemID()
	return self.vo.item_id
end

function FallItem:IsClick(x, y)
	return self.real_pos.x - 30 <= x and x <= self.real_pos.x + 30 and self.real_pos.y - 30 <= y and y <= self.real_pos.y + 30
end

function FallItem:IsCoin()
	return self.vo.item_id == 0
end

function FallItem:GetAutoPickupMaxDis()
	return 1
end

function FallItem:GetItemColor()
	return 0
end

function FallItem:OnClick()

end

function FallItem:SetLockTime(lock_time)
	self.vo.lock_time = lock_time
end

function FallItem:GetNameBoard()
	return self.name_board
end

function FallItem:SetNameBoard(value)
	if self.name_board ~= nil then
		self.name_board:GetRootNode():removeFromParent()
		self.name_board:DeleteMe()
	end

	self.name_board = value
	self.model:AttachNode(value:GetRootNode(), cc.p(0, self.height + NAME_BOARD_OFFY), GRQ_SCENE_OBJ, InnerLayerType.Name)
end

function FallItem:SetNameLayerVisible(is_visible)
	if self.name_board then
		self.name_board:SetVisible(is_visible)
	end
end

function FallItem:SetHeight(height)
	self.height = height
	if self.name_board then
		self.name_board:SetHeight(self.height + NAME_BOARD_OFFY)
	end
end

function FallItem:ResetPickTime()
	self.last_pick_time = Status.NowTime
end

function FallItem:CanPick(ignore_setting)
	if (SettingProtectData.CheckPickFallItemSetting(self.vo) or ignore_setting)
		and self.vo.lock_time <= TimeCtrl.Instance:GetServerTime()
		and self.last_pick_time + 0.5 < Status.NowTime then
		return true
	end
	return false
end
