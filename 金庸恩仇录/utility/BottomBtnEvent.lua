BottomBtnEvent = {}
BottomBtnEvent.canTouchEnabled = true
BottomBtnEvent.extraCallBack = nil

function BottomBtnEvent.setTouchEnabled(bEnabled)
	BottomBtnEvent.canTouchEnabled = bEnabled
end
function BottomBtnEvent.registerBottomEvent(btnMaps)
	local function onTouchBtn(tag)
		BottomBtnEvent.tag = tag
		if BottomBtnEvent.canTouchEnabled ~= nil and BottomBtnEvent.canTouchEnabled == true then
			if BottomBtnEvent.extraCallBack then
				BottomBtnEvent.extraCallBack()
				return
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			do
				local nextState = 0
				if tag == 1 then
					nextState = GAME_STATE.STATE_MAIN_MENU
				elseif tag == 2 then
					RequestHelper.formation.list({
					m = "fmt",
					a = "list",
					pos = "0",
					param = {},
					callback = function (data)
						game.player.m_formation = data
						game.player.addCulianAttr()
						nextState = GAME_STATE.STATE_ZHENRONG
						GameStateManager:ChangeState(nextState, {type = 1, pos = 1})
					end
					})
				elseif tag == 3 then
					nextState = GAME_STATE.STATE_FUBEN
				elseif tag == 4 then
					nextState = GAME_STATE.STATE_HUODONG
				elseif tag == 5 then
					nextState = GAME_STATE.STATE_BEIBAO
				elseif tag == 6 then
					nextState = GAME_STATE.STATE_SHOP
				end
				for k, v in pairs(G_BOTTOM_BTN) do
					if GameStateManager.currentState == v and 2 < GameStateManager.currentState then
						btnMaps[G_BOTTOM_BTN_NAME[k]]:selected()
						break
					end
				end
				if tag ~= 2 then
					GameStateManager:ChangeState(nextState)
				end
			end
		end
	end
	BottomBtnEvent.reCall = onTouchBtn
	for k, v in pairs(G_BOTTOM_BTN_NAME) do
		if btnMaps[v] then
			btnMaps[v]:registerScriptTapHandler(onTouchBtn)
		end
	end
end
function BottomBtnEvent.lightenBottomMenu(btnMaps)
	-- 高亮选择中的底部按钮
	-- 重复点击，保持高亮，不切换状态
	for k,v in pairs(G_BOTTOM_BTN) do
		if (GameStateManager.currentState == v and GameStateManager.currentState > GAME_STATE.STATE_MAIN_MENU) then
			btnMaps[G_BOTTOM_BTN_NAME[k]]:selected()
			break
		end
	end
end

return BottomBtnEvent