--
-- Author: Daneil
-- Date: 2015-01-15 14:56:24
-- 比武系统资源管理器
--
local BiwuGiftPrePopup  = {}

local buttomBtnRes = { "shouye","zhenrong","fuben","huodong","beibao","shop"}
local gameState    = { 2,3,4,5,6,7,}
local gameStateManager = require("game.GameStateManager")

---
-- 加载底部按钮
function BiwuGiftPrePopup:loadButtomBtnGroup(node)
	local currentGameState = gameStateManager.currentState
	for k, v in pairs(buttomBtnRes) do
		local res = { normal   = "#bl_"..v.."_up.png", 
				      pressed  = "#bl_"..v.."_down.png",
					  disabled = "#bl_"..v.."_down.png" }
		local getBtn = cc.ui.UIPushButton.new(res)
        :onButtonClicked(function()
             gameStateManager:ChangeState(gameState[k])
        end)
        getBtn:setAnchorPoint(cc.p(0,0))
        getBtn:setPosition(cc.p((k - 1)*(display.width / #buttomBtnRes),0))
        node:addChild(getBtn,200)
	end
	
end

---
-- 底部按钮注册监听事件
function BiwuGiftPrePopup:registButtomBtnsListener(state)
	
end


return BiwuGiftPrePopup

