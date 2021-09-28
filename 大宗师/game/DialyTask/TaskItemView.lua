local btnGoRes = {
    normal   =  "#btn_go.png",
    pressed  =  "#btn_go.png",
    disabled =  "#btn_go.png"
}
local GameConst = require("game.GameConst")
local TaskItemView = class("TaskItemView", function()
    return display.newLayer("TaskItemView")
end)

function TaskItemView:ctor(size,data)
    self:setContentSize(size)
    self._leftToRightOffset = 10
    self._topToDownOffset = 2
    self._frameSize = size
    self._data = data
    self._containner = nil
    self._padding = {
        left  = 20,
        right = 10,
        top   = 15,
        down  = 10 
    }
    self:setUpView()
    --控件
    self._icon = nil
end


function TaskItemView:setUpView()
    self._containner =  display.newScale9Sprite("#reward_item_bg.png", 0, 0, 
                            cc.size(self._frameSize.width - self._leftToRightOffset * 2, 
                                self._frameSize.height - self._topToDownOffset * 2))
                            :pos(self._frameSize.width / 2, self._frameSize.height / 2)
    local containnerSize = self._containner:getContentSize()
    self._containner:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(self._containner)

    --图标
    self._icon = display.newSprite("res/items/icon/"..self._data.icon..".png")
                     :pos(self._padding.left , containnerSize.height / 2)
                     :addTo(self._containner)
    
     
    self._icon:setAnchorPoint(cc.p(0,0.5)) 
    local iconSize = self._icon:getContentSize()
    local iconPosX  = self._icon:getPositionX()
    --标题背景
    local titleBngSize = cc.size(280,40)
    local marginLeft = 15                  
    local titleBng = display.newScale9Sprite("#panel_bng.png", 0, 0, 
                        titleBngSize)
                        :pos( iconPosX + iconSize.width + marginLeft , 
                            containnerSize.height - self._padding.top)
                        :addTo(self._containner)
    titleBng:setAnchorPoint(cc.p(0,1))
    --标题
    local marginLeft  = 10
    local marginRight = 10
    self._titleLabel  = ui.newTTFLabelWithShadow({text = self._data.name,font = FONTS_NAME.font_fzcy,size = 22, 
        color = ccc3(255,255,255) ,shadowColor = ccc3(255, 255, 255), align = ui.TEXT_ALIGN_LEFT})
        :pos(marginLeft, titleBngSize.height / 2)
        :addTo(titleBng)
    self._titleLabel:setAnchorPoint(cc.p(0,0.5))

    --进度
    self._progresslabel  = ui.newTTFLabel({text = "/"..self._data.totalStep, font = FONTS_NAME.font_fzcy, align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(0,219,52) })
        :pos(titleBngSize.width - marginRight, titleBngSize.height / 2)
        :addTo(titleBng)
    self._progresslabel:setAnchorPoint(cc.p(1,0.5))


    local posPreX = self._progresslabel:getPositionX()
    local posPreY = self._progresslabel:getPositionY()
    local preWidth = self._progresslabel:getContentSize().width
    self._data.missionDetail = tonumber(self._data.missionDetail) >= tonumber(self._data.totalStep) and tonumber(self._data.totalStep) or tonumber(self._data.missionDetail)
    self._progresslabel = ui.newTTFLabel({  text = self._data.missionDetail, font = FONTS_NAME.font_fzcy,  align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(255,222,0)}) 
        :pos(posPreX - preWidth, posPreY)
        :addTo(titleBng) 
    self._progresslabel:setAnchorPoint(cc.p(1,0.5))


    local posPreX = self._progresslabel:getPositionX()
    local posPreY = self._progresslabel:getPositionY()
    local preWidth = self._progresslabel:getContentSize().width
    local marginRight = 60
    --进度
    self._progresslabel = ui.newTTFLabel({  text = "进度：", font = FONTS_NAME.font_fzcy,  align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(0,219,52)}) 
        :pos(titleBngSize.width - marginRight, posPreY)
        :addTo(titleBng) 
    self._progresslabel:setAnchorPoint(cc.p(1,0.5))


    local titleBngPosX = titleBng:getPositionX()
    local titleBngPosY = titleBng:getPositionY()
    --描述
    local marginLeft = 10
    local marginTop  = 15
    
    self._disLabel = ui.newTTFLabelWithShadow({text = self._data.dis, size = 20, 
         align = ui.TEXT_ALIGN_LEFT , font = FONTS_NAME.font_fzcy , color = ccc3(170, 91, 28) ,shadowColor = ccc3(0,0,0)})
        :pos(titleBngPosX + marginLeft, titleBngPosY - titleBngSize.height - marginTop)
        :addTo(self._containner)

    self._disLabel:setAnchorPoint(cc.p(0,1))
    local dislabelPosY = self._disLabel:getPositionY()
    local dislabelSize = self._disLabel:getContentSize()

    ------------每日任务
    local marginLeft = 10
    local marginTop  = 10
    self._disLabel = ui.newTTFLabelWithShadow({text = "获得积分", size = 20, align = ui.TEXT_ALIGN_LEFT,
        font = FONTS_NAME.font_fzcy, color = ccc3(170, 91, 28),shadowColor = ccc3(0,0,0)})
        :pos(titleBngPosX + marginLeft, dislabelPosY - dislabelSize.height - marginTop)
        :addTo(self._containner)
    self._disLabel:setAnchorPoint(cc.p(0,1))
    self._disLabel:setVisible(self._data.missionCategory == 1)
    local size = self._disLabel:getContentSize()
    self._disLabel = ui.newTTFLabel({text = self._data.jifen, size = 20, align = ui.TEXT_ALIGN_LEFT,
        font = FONTS_NAME.font_fzcy, color = ccc3(147, 5, 5)})
        :pos(titleBngPosX + marginLeft + size.width + 10, dislabelPosY - dislabelSize.height )
        :addTo(self._containner)
    self._disLabel:setAnchorPoint(cc.p(0,1))
    self._disLabel:setVisible(self._data.missionCategory == 1)

    -----------成长之路
    local marginLeft = 10
    local marginTop  = 10
    self._disLabel = ui.newTTFLabelWithShadow({text = "奖励", size = 20, align = ui.TEXT_ALIGN_LEFT,
        font = FONTS_NAME.font_fzcy, color = ccc3(170, 91, 28),shadowColor = ccc3(0,0,0)})
        :pos(titleBngPosX + marginLeft, dislabelPosY - dislabelSize.height)
        :addTo(self._containner)
    self._disLabel:setAnchorPoint(cc.p(0,1))
    self._disLabel:setVisible(self._data.missionCategory == 2)

    local x,y = self._disLabel:getPosition()
    local width = self._disLabel:getContentSize().width
    local marginLeft = 10
    local itemOne = self:createMoney(1,10)
    itemOne:addTo(self._containner)
    itemOne:setAnchorPoint(cc.p(0,1))
    itemOne:setPosition(x + width + marginLeft,y)
    itemOne:setVisible(self._data.missionCategory == 2)


    local x,y = itemOne:getPosition()
    local width = itemOne:getContentSize().width
    local marginLeft = 10
    local itemTwo = self:createMoney(2,10)
    itemTwo:addTo(self._containner)
    itemTwo:setAnchorPoint(cc.p(0,1))
    itemTwo:setPosition(x + width + marginLeft,y)
    itemTwo:setVisible(self._data.missionCategory == 2)

    
    --按钮
    self.closeBtn = display.newSprite(btnGoRes.normal)  
    self.closeBtn:setTouchEnabled(true)  
    self.closeBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
            if event.name == "began" then 
                self.closeBtn:setScale(1.1)
                return true
            elseif event.name == "ended" then 
                self.closeBtn:setScale(1.0)
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
				if self._data.goto == 33 then
	            	RequestHelper.worldBoss.history({
			 		callback = function(data) 
			 			dump(data)
			 			if data["0"] ~= "" then 
			 				CCMessageBox(data["0"], "Error")
			 			else 
			 				if data["1"] <= 0 then 
			 					GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS)
			 				else 
				 				GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS_NORMAL, data)
				 			end 
			 			end 
					end
					}) 
            	elseif  self._data.goto == 38 then
	            	RequestHelper.dialyTask.checkBPSignIn({
	                callback = function(data)
	                    if data.rtnObj.success == 0 then
	                    	GameStateManager:ChangeState(self._data.goto)
	                    else
	                    	show_tip_label(data_error_error[1200006].prompt)
	                    	return
	                    end
	                end 
	                }) 
	            elseif self._data.goto == GAME_STATE.STATE_FUBEN then
	            	local msg = {}
	            	msg.bigMapID = game.player.bigmapData["1"]
        			msg.subMapID = game.player.bigmapData["2"]
        			GameStateManager:ChangeState(self._data.goto,msg)
	            else
	            	GameStateManager:ChangeState(self._data.goto)
				end
			end
        end)
    self.closeBtn:setPosition(cc.p(containnerSize.width - self._padding.right - 70 , containnerSize.height / 2))
    self._containner:addChild(self.closeBtn)

    self.closeBtn:setAnchorPoint(cc.p(0.5,0.5))
    --已完成   
    self.completeTag = display.newSprite("#complete.png")
        :pos(containnerSize.width - self._padding.right , containnerSize.height / 2)
        :addTo(self._containner)
        self.completeTag:setAnchorPoint(cc.p(1,0.5))
        
    self.closeBtn:setVisible(self._data.status == 1)
    self.completeTag:setVisible(self._data.status == 3)
end

--- 1元宝 2金币 3魂魄
function TaskItemView:createMoney(type,count)
    local node = CCNode:create()
    local icon 
    if type == 1 then
        icon = display.newSprite("#spirit_gold_icon.png")
    elseif type == 2 then
        icon = display.newSprite("#spirit_silver_icon.png")
    else 
        icon = display.newSprite("#spirit_item_icon.png")
    end
    
    local offset = 10
    local iconSize = icon:getContentSize()
    local countLabel = ui.newTTFLabel({text = count, size = 20, align = ui.TEXT_ALIGN_LEFT,
        font = FONTS_NAME.font_fzcy, color = ccc3(147, 5, 5)})
        :pos(iconSize.width + offset , 0)
    local labelSize = countLabel:getContentSize()
    icon:setAnchorPoint(cc.p(0,0))
    countLabel:setAnchorPoint(cc.p(0,0))
    node:addChild(icon)
    node:addChild(countLabel)
    node:setContentSize(cc.size(iconSize.width +labelSize.width + offset,iconSize.height))
    return node
end

function TaskItemView:setData()
    
end

return TaskItemView
    
    
