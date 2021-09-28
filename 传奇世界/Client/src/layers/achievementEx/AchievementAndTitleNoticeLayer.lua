local AchievementAndTitleNoticeLayer = class("AchievementAndTitleNoticeLayer", function() return cc.Layer:create() end)

local path = "res/achievement/"
local pathCommon = "res/common/"

function AchievementAndTitleNoticeLayer:ctor(achieveRecord, titleRecord)
	local bg = createSprite(self, "res/achievement/get/bg.png", cc.p(display.cx, display.cy + 50), cc.p(0.5, 0))
	
	createSprite(bg, "res/achievement/get/1.png", cc.p(bg:getContentSize().width/2, 146), cc.p(0.5, 0.5))
	createSprite(bg, "res/achievement/get/2.png", cc.p(bg:getContentSize().width/2, 20), cc.p(0.5, 0.5))

	createSprite(bg, "res/achievement/get/6.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-15), cc.p(0.5, 0))
	createSprite(bg, "res/achievement/get/5.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-15), cc.p(0.5, 0))

	local topBg = createSprite(bg, "res/achievement/get/9.png", cc.p(bg:getContentSize().width/2, 120), cc.p(0.5, 0))
	--createSprite(bg, "res/chievement/get/8.png", getCenterPos(topBg), cc.p(0.5, 0.5))
	createSprite(topBg, "res/achievement/get/8.png", getCenterPos(topBg), cc.p(0.5, 0.5))
	local titleBg = createSprite(topBg, "res/achievement/get/7.png", cc.p(topBg:getContentSize().width/2, -10), cc.p(0.5, 0))

	-- local effect = Effects:create(false)
	-- effect:playActionData("newachget", 6, 1, 1)
 --    bg:addChild(effect)
 --    effect:setAnchorPoint(cc.p(0.5, 0))
 --    effect:setPosition(cc.p(bg:getContentSize().width/2 , 125))
 --    addEffectWithMode(effect, 2)

	createLabel(bg, game.getStrByKey("achievement_touch_close"), cc.p(bg:getContentSize().width/2, 25), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_black)
	AudioEnginer.playEffect("sounds/uiMusic/ui_achieve.mp3",false)

	local achieveLabel
	if achieveRecord then
		createSprite(titleBg, "res/achievement/get/4.png", cc.p(titleBg:getContentSize().width/2, 2), cc.p(0.5, 0))
		achieveLabel = createLabel(bg, string.format(achieveRecord.q_conditonDesc, achieveRecord.q_value), getCenterPos(bg, 0, 0), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)
	end 

	if titleRecord then
		titleBg:removeAllChildren()
		createSprite(titleBg, "res/achievement/get/3.png", cc.p(titleBg:getContentSize().width/2, 2), cc.p(0.5, 0))
		--achieveLabel:setString(titleRecord.q_titleName)
		createLabel(bg, titleRecord.q_titleName, getCenterPos(bg, 0, 0), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)

		-- achieveLabel:setPosition(getCenterPos(bg, 0, 15))
		-- createLabel(bg, game.getStrByKey("achievement_title_notice"), cc.p(bg:getContentSize().width/2-50, bg:getContentSize().height/2-12), cc.p(1, 0.5), 22, true, nil, nil, MColor.lable_black)
		-- createLabel(bg, titleRecord.q_titleName or game.getStrByKey("achievement_no_name"), cc.p(bg:getContentSize().width/2-45, bg:getContentSize().height/2-12), cc.p(0, 0.5), 22, true, nil, nil, MColor.lable_yellow)
		-- local btnFunc = function()
		-- 	--g_msgHandlerInst:sendNetDataByFmtExEx(ACHIEVE_CS_SETTITLE, "ii", G_ROLE_MAIN.obj_id, titleRecord.q_titleID)
		-- 	local t = {}
		-- 	t.titleID = titleRecord.q_titleID
		-- 	g_msgHandlerInst:sendNetDataByTableExEx(ACHIEVE_CS_SETTITLE, "AchieveSetTitle", t)
		-- 	removeFromParent(self)
		-- end
		-- local btn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2+110, bg:getContentSize().height/2-5), btnFunc)
		-- btn:setScale(0.7)
		-- createLabel(btn, game.getStrByKey("achievement_title_on"), cc.p(btn:getContentSize().width/2, btn:getContentSize().height/2), cc.p(0.5, 0.5), 30, true)

		-- --10级以下不显示快速装备称号
		-- local MRoleStruct = require("src/layers/role/RoleStruct")
		-- if MRoleStruct and MRoleStruct:getAttr(ROLE_LEVEL) < 10 then
		-- 	removeFromParent(btn)
		-- end

		--开启装备称号的引导
		-- if getLocalRecord("tuto"..22) ~= true then
		-- 		removeFromParent(btn)
		-- 	if G_TUTO_DATA then
		-- 		for k,v in pairs(G_TUTO_DATA) do
		-- 			if v.q_id == 22 then
		-- 				v.q_state = TUTO_STATE_OFF
		-- 			end
		-- 		end
		-- 	end
		-- end
	end

	AudioEnginer.playEffect("sounds/uiMusic/ui_achievement.mp3", false)

	startTimerAction(self, 6, false, function() removeFromParent(self) self = nil end)
	local  listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
	listenner:registerScriptHandler(function(touch, event)
			removeFromParent(self)
			self = nil
	   		return true
	    end,cc.Handler.EVENT_TOUCH_BEGAN )

	listenner:registerScriptHandler(function(touch, event)
		end,cc.Handler.EVENT_TOUCH_MOVED )

	listenner:registerScriptHandler(function(touch, event)
	        end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

return AchievementAndTitleNoticeLayer