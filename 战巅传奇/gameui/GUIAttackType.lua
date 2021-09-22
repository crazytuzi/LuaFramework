local GUIAttackType = {}

local attack_tab = {
	[101] = "attack_peace",
	[102] = "attack_team",
	[103] = "attack_guild",
	[100] = "attack_all",
	[105] = "attack_pk",
}
local attackName_tab = {
	[101] = "和平",
	[102] = "队伍",
	[103] = "帮会",
	[100] = "全体",
	[105] = "阵营",
}

local var = {}

local function setAttackVisible(visible)
	for k,v in pairs(attack_tab) do
		local btn = var.attackModel:getWidgetByName(v)
		if btn then
			btn:setVisible(visible)
		end
	end
	var.attackModel:getWidgetByName("img_attack_switch_bg"):setVisible(visible)
	var.attackVisible = visible
end

-- 按钮回调
local function pushAttackControl(sender, tocuhType)
	if tocuhType == ccui.TouchEventType.began then
		var.showAttack = var.attackVisible == false and true or false
	elseif tocuhType == ccui.TouchEventType.ended then
		if var.showAttack then setAttackVisible(true) end
	end
end


local function onChangeAttackMode(event)
	local curState = GameSocket.mAttackMode -- 99

	if not var.attackControl or not curState then return end
	if not attack_tab[curState] then return end
	
	-- var.attackControl:loadTextures(attack_tab[curState], attack_tab[curState].."_sel", "", ccui.TextureResType.plistType)
	var.attackControl:setTitleText("  "..attackName_tab[curState])

	local needUpdate
	if curState == 103 then
		if G_AttackGuild == 0 then
			G_AttackGuild = 1
			needUpdate = true
		end
	else
		if G_AttackGuild == 1 then
			G_AttackGuild = 0
			needUpdate = true
		end
	end
	var.attackControl:setTouchEnabled(curState ~= 105)
	if curState == 105 then
		setAttackVisible(false)
		needUpdate = true
	end
	if CCGhostManager then CCGhostManager:updatePlayerName() end
end

local function pushAttackModel(sender)
	GameSocket:ChangeAttackMode(sender.mode)
end

function GUIAttackType.init(attackModel)
	var = {
		attackModel,
		attackVisible = false,
		showAttack = false
	}

	var.attackModel = attackModel

	if var.attackModel then
		local btnAttack
		for k,v in pairs(attack_tab) do
			btnAttack = var.attackModel:getWidgetByName(v)
			if btnAttack then
				btnAttack:hide()
				btnAttack.mode = k
				GUIFocusPoint.addUIPoint(btnAttack, pushAttackModel)
			end
		end

		var.attackControl = var.attackModel:getWidgetByName("btn_switch_attack"):setPressedActionEnabled(true)
		GUIFocusPoint.addUIPoint(var.attackControl, pushAttackControl, true)
		setAttackVisible(false)
		
		if PLATFORM_BANSHU then --版署版本切换攻击模式不可用
			var.attackControl:setTouchEnabled(false)
		end
		onChangeAttackMode()
		cc.EventProxy.new(GameSocket,var.attackModel)
			:addEventListener(GameMessageCode.EVENT_ATTACKMODE_CHANGE, onChangeAttackMode)
			:addEventListener(GameMessageCode.EVENT_SCREEN_TOUCHED, function ()
				setAttackVisible(false)
			end)
		onChangeAttackMode("")

		var.attackModel:getWidgetByName("Button_chongzhi"):addClickEventListener(function ()
  			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
  		end)
	end
end

return GUIAttackType