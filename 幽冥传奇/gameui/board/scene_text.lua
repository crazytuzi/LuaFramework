
SceneText = SceneText or {}
SceneText.TextQueue = {}
SceneText.CapabilityEffect = {
	timerhandler = nil,
	capability_node = nil,
	old_role_capability = -1,
	effect_display = nil,							-- 特效
	effect_id = 3059,								-- 特效ID
	CapabilityShowTime = 0.7,						-- 战斗力出现总时间
	CapaBilityFreshTime = 0.07,						-- 战斗力刷新时间间隔
}
SceneText.ExpEffect = {
	timerhandler = nil,
	exp_node = nil,
	old_role_exp = -1,
	ExpShowTime = 0.7,								-- 经验变化出现总时间
	ExpFreshTime = 0.07,							-- 经验变化刷新时间间隔
}

function SceneText.EnterFight()
	SceneText.CreateRemind(ResPath.GetFightResPath("enter_fight"))
end

function SceneText.LeaveFight()
	SceneText.CreateRemind(ResPath.GetFightResPath("leave_fight"))
end

function SceneText.EnterSafe()
	SceneText.CreateRemind(ResPath.GetFightResPath("enter_safe"), "enter_safe")
end

function SceneText.LeaveSafe()
	SceneText.CreateRemind(ResPath.GetFightResPath("leave_safe"), "leave_safe")
end

function SceneText.CreateRemind(path, key)
	local sprite = cc.Sprite:createWithSpriteFrameName(path)
	if nil == sprite then return end

	sprite:setPosition(HandleRenderUnit:GetWidth() * 3 / 4, 220)
	local move_by = cc.MoveBy:create(1, cc.p(-150, 0))
	local action_complete_callback = function()
		sprite:removeFromParent()
		if nil ~= SceneText.TextQueue[key] then
			SceneText.TextQueue[key] = nil
		end
	end
	local callback = cc.CallFunc:create(action_complete_callback)
	local action = cc.Sequence:create(move_by, callback)
	sprite:runAction(action)
	if nil ~= key then
		SceneText.TextQueue[key] = sprite
	end
	HandleRenderUnit:AddUi(sprite, -1, 0)
end

-- 战斗力改变特效
function SceneText.PlayCapabilityChangeEffect(capability)
	capability = math.floor(capability)
	local old_role_capability = SceneText.CapabilityEffect.old_role_capability
	SceneText.CapabilityEffect.old_role_capability = capability

	local mul_value = capability - old_role_capability
	--战斗力变化有个资源报错问题，查不出，在此log
	if mul_value ~= math.floor(mul_value) then
		Log("注意：战斗力变化有小数点出现，有大Bug--------------------------------------------------------------------------------")
		mul_value = math.floor(mul_value)
	end
	if mul_value <= 0 then 
		return
	end
	if nil == SceneText.CapabilityEffect.capability_node then
		SceneText.CapabilityEffect.capability_node = cc.Node:create()
		SceneText.CapabilityEffect.capability_node:setPosition(150, HandleRenderUnit:GetHeight() / 11*4)
		local capability_icon = XUI.CreateImageView(20, 0, ResPath.GetScene("zhandouli"), true)
		SceneText.CapabilityEffect.capability_node:addChild(capability_icon, 999, 999)
		HandleRenderUnit:AddUi(SceneText.CapabilityEffect.capability_node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
		local fire_eff = RenderUnit.CreateEffect(1126, SceneText.CapabilityEffect.capability_node, -1, nil, nil, 180, 12)
		fire_eff:setScaleX(1.5)
		fire_eff:setScaleY(1.65)
	else
		return
	end

	local num_list = {old_capability = {}, cur_capability = {}}
	local old_capability = {}
	local old_len = string.len(old_role_capability)
	local len = string.len(capability)
	local max_num = 0
	local path = "zdl_y_"
	for i = 0, old_len - 1 do		-- 拆分战力
		local num = string.sub(old_role_capability, 1, old_len - i) % 10
		old_capability[old_len - i] = num
	end
	local num_sprite = cc.Sprite:create()
	num_sprite:setPosition(140, -20)
	SceneText.CapabilityEffect.capability_node:addChild(num_sprite, 999, 998)
	for i = 1, #old_capability do
		local sprite = XUI.CreateImageView((i -1) * 25, 0, ResPath.GetScene(path .. old_capability[i]), true)
		num_sprite:addChild(sprite, 999, 999)
	end
	local total_times = math.ceil(SceneText.CapabilityEffect.CapabilityShowTime / SceneText.CapabilityEffect.CapaBilityFreshTime)
	local mul_capability = math.ceil(mul_value / total_times)
	mul_capability = 0 ~= mul_capability and mul_capability or 1
	local fresh_arg = {curr_capability = old_role_capability, target_capability = capability, path = path, mul_capability = mul_capability, total_times = total_times, curr_times = 1, mul_value = mul_value}
	SceneText.CapabilityEffect.timerhandler = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(SceneText.RefreshCapabilityEffect, fresh_arg), SceneText.CapabilityEffect.CapaBilityFreshTime, total_times)
end

-- 战斗力变化时每秒刷新数据
function SceneText.RefreshCapabilityEffect(fresh_arg)
	if nil == SceneText.CapabilityEffect.capability_node or nil == fresh_arg then
		return
	end
	if fresh_arg.total_times == fresh_arg.curr_times then
		SceneText.CompleteCapabilityEffect(fresh_arg.mul_value)
		return
	end
	if fresh_arg.curr_capability == fresh_arg.target_capability then
		SceneText.CompleteCapabilityEffect(fresh_arg.mul_value)
		return
	end
	local num_sprite = SceneText.CapabilityEffect.capability_node:getChildByTag(998)
	if nil == num_sprite then
		return
	end
	fresh_arg.curr_times = fresh_arg.curr_times + 1
	local curr_capability = fresh_arg.curr_capability + fresh_arg.mul_capability
	if fresh_arg.total_times == fresh_arg.curr_times then
		curr_capability = fresh_arg.target_capability
	end
	fresh_arg.curr_capability = curr_capability
	local len = string.len(curr_capability)
	local num_list = {}


	for i = 0, len - 1 do		-- 拆分战力
		local num = string.sub(curr_capability, 1, len - i) % 10
		num_list[len - i] = num
	end
	num_sprite:removeAllChildren()
	for i = 1, #num_list do
		local sprite = XUI.CreateImageView((i -1) * 32, 0, ResPath.GetScene(fresh_arg.path .. num_list[i]), true)
		num_sprite:addChild(sprite, 999, 999)
	end
end

-- 战斗力变化完成后效果
function SceneText.CompleteCapabilityEffect(mul_value)
	mul_value = math.floor(mul_value)

	if nil == SceneText.CapabilityEffect.capability_node then
		return
	end
	if nil ~= SceneText.CapabilityEffect.timerhandler then
		GlobalTimerQuest:CancelQuest(SceneText.CapabilityEffect.timerhandler)
	end

	local path = "zdl_y_"
	local symbol = "zdl_symbol"
	local up_icon = "uparrow_green2"

	local num_sprite = SceneText.CapabilityEffect.capability_node:getChildByTag(996)
	if nil ~= num_sprite then
		num_sprite:removeFromParent()
		num_sprite = nil
	end

	mul_sprite = cc.Sprite:create()
	mul_sprite:setPosition(110, 40)

	SceneText.CapabilityEffect.capability_node:addChild(mul_sprite, 999, 996)
	local symbol_sprite = XUI.CreateImageView(30, 0, ResPath.GetScene(symbol), true)
	mul_sprite:addChild(symbol_sprite)

	local up_sprite = XUI.CreateImageView(-20, 0, ResPath.GetCommon(up_icon), true)
	mul_sprite:addChild(up_sprite)

	local len = string.len(mul_value)
	for i = 1, len do
		local n = mul_value % 10
		mul_value = math.floor(mul_value / 10)

		local sprite = XUI.CreateImageView((len - i + 1) * 25 + 40, 0, ResPath.GetScene(path .. n), true)
		sprite:setScale(0.8, 0.8)
		mul_sprite:addChild(sprite, 999, 999)
	end
	local move_to = cc.MoveTo:create(1.5, cc.p(110, 40 + 50))
	local effect_complete_callback = function()
		SceneText.CapabilityEffect.capability_node:removeFromParent()

		SceneText.CapabilityEffect.timerhandler = nil
		SceneText.CapabilityEffect.capability_node = nil
		BagCtrl.Instance:StartFlyEff(MainUiNodeName.HeadbarCap, 150, HandleRenderUnit:GetHeight() / 11*4)
	end
	local callback = cc.CallFunc:create(effect_complete_callback)
	local action = cc.Sequence:create(move_to, callback)
	mul_sprite:runAction(action)
end


-- 经验改变特效
function SceneText.PlayExpChangeEffect(exp)
	exp = math.floor(exp)
	local old_role_exp = 0
	SceneText.ExpEffect.old_role_exp = exp

	local mul_value = exp - 0
	--经验变化有个资源报错问题，查不出，在此log
	if mul_value ~= math.floor(mul_value) then
		Log("注意：经验变化有小数点出现，有大Bug--------------------------------------------------------------------------------")
		mul_value = math.floor(mul_value)
	end
	if mul_value <= 0 then 
		return
	end
	if nil == SceneText.ExpEffect.exp_node then
		SceneText.ExpEffect.exp_node = cc.Node:create()
		SceneText.ExpEffect.exp_node:setPosition(HandleRenderUnit:GetWidth() / 3, HandleRenderUnit:GetHeight() / 11*8)
		local exp_icon = XUI.CreateImageView(-0, 0, ResPath.GetScene("exp"), true)
		SceneText.ExpEffect.exp_node:addChild(exp_icon, 999, 999)
		local exp_symbol = XUI.CreateImageView(0, - 40, ResPath.GetScene("exp_symbol"), true)
		SceneText.ExpEffect.exp_node:addChild(exp_symbol, 999, 997)
		HandleRenderUnit:AddUi(SceneText.ExpEffect.exp_node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
	else
		return
	end

	local num_list = {old_exp = {}, cur_exp = {}}
	local old_exp = {}
	local old_len = string.len(old_role_exp)
	local len = string.len(exp)
	local max_num = 0
	local path = "exp_g_"
	for i = 0, old_len - 1 do		-- 拆分战力
		local num = string.sub(old_role_exp, 1, old_len - i) % 10
		old_exp[old_len - i] = num
	end
	local num_sprite = cc.Sprite:create()
	num_sprite:setPosition(0, - 40)
	SceneText.ExpEffect.exp_node:addChild(num_sprite, 999, 998)
	local total_width = (#old_exp - 1) * 25
	SceneText.ExpEffect.exp_node:getChildByTag(997):setPositionX(- total_width / 2 - 30)
	for i = 1, #old_exp do
		local sprite = XUI.CreateImageView((i - 1) * 25 - total_width / 2, 0, ResPath.GetScene(path .. old_exp[i]), true)
		num_sprite:addChild(sprite, 999, 999)
	end
	local total_times = math.ceil(SceneText.ExpEffect.ExpShowTime / SceneText.ExpEffect.ExpFreshTime)
	local mul_exp = math.ceil(mul_value / total_times)
	mul_exp = 0 ~= mul_exp and mul_exp or 1
	local fresh_arg = {curr_exp = old_role_exp, target_exp = exp, path = path, mul_exp = mul_exp, total_times = total_times, curr_times = 1, mul_value = mul_value}
	SceneText.ExpEffect.timerhandler = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(SceneText.RefreshExpEffect, fresh_arg), SceneText.ExpEffect.ExpFreshTime, total_times)
end

-- 经验变化时每秒刷新数据
function SceneText.RefreshExpEffect(fresh_arg)
	if nil == SceneText.ExpEffect.exp_node or nil == fresh_arg then
		return
	end
	if fresh_arg.total_times == fresh_arg.curr_times then
		SceneText.CompleteExpEffect(fresh_arg.mul_value)
		return
	end
	if fresh_arg.curr_exp == fresh_arg.target_exp then
		SceneText.CompleteExpEffect(fresh_arg.mul_value)
		return
	end
	local num_sprite = SceneText.ExpEffect.exp_node:getChildByTag(998)
	if nil == num_sprite then
		return
	end
	fresh_arg.curr_times = fresh_arg.curr_times + 1
	local curr_exp = fresh_arg.curr_exp + fresh_arg.mul_exp
	if fresh_arg.total_times == fresh_arg.curr_times then
		curr_exp = fresh_arg.target_exp
	end
	fresh_arg.curr_exp = curr_exp
	local len = string.len(curr_exp)
	local num_list = {}


	for i = 0, len - 1 do
		local num = string.sub(curr_exp, 1, len - i) % 10
		num_list[len - i] = num
	end
	num_sprite:removeAllChildren()
	local total_width = (#num_list - 1) * 25
	SceneText.ExpEffect.exp_node:getChildByTag(997):setPositionX(- total_width / 2 - 30)
	for i = 1, #num_list do
		local sprite = XUI.CreateImageView((i - 1) * 25 - total_width / 2, 0, ResPath.GetScene(fresh_arg.path .. num_list[i]), true)
		num_sprite:addChild(sprite, 999, 999)
	end
end

-- 经验变化完成后效果
function SceneText.CompleteExpEffect(mul_value)
	mul_value = math.floor(mul_value)

	if nil == SceneText.ExpEffect.exp_node then
		return
	end
	if nil ~= SceneText.ExpEffect.timerhandler then
		GlobalTimerQuest:CancelQuest(SceneText.ExpEffect.timerhandler)
	end
	local effect_complete_callback = function()
		SceneText.ExpEffect.exp_node:removeFromParent()
		SceneText.ExpEffect.timerhandler = nil
		SceneText.ExpEffect.exp_node = nil
		BagCtrl.Instance:StartFlyEff(MainUiNodeName.RoleExp, HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 11*8)
	end
	local callback = cc.CallFunc:create(effect_complete_callback)
	local delay = cc.DelayTime:create(1)
	local action = cc.Sequence:create(delay, callback)
	SceneText.ExpEffect.exp_node:runAction(action)
	
end
