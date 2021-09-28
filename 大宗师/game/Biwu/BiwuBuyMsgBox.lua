--
-- Author: Daneil
-- Date: 2015-01-25 15:12:18
--
local BiwuBuyMsgBox = class("BiwuBuyMsgBox", function()
    return display.newLayer("BiwuBuyMsgBox")
end)

function BiwuBuyMsgBox:ctor(param)
	self:loadRes()
    self:setUpView(param)
end

function BiwuBuyMsgBox:setUpView(param)

	self:createMask()
	--背景
	local mainBng = display.newScale9Sprite("#win_base_bg2.png", 0, 0, 
                    cc.size(display.width * 0.8,display.width * 0.5))
                    :pos(display.cx,display.cy)
                    :addTo(self)
    local mainBngSize = mainBng:getContentSize()
    local innnerBng = display.newScale9Sprite("#win_base_inner_bg_light.png", 0, 0, 
                        cc.size(mainBngSize.width * 0.96,mainBngSize.width * 0.48))
                        :pos(mainBngSize.width/2,mainBngSize.height/2 - 25)
                        :addTo(mainBng)
    local btnCloseRes = {
	    normal   =  "#win_base_close.png",
	    pressed  =  "#win_base_close.png",
	    disabled =  "#win_base_close.png"
	}

   	--关闭按钮
    local closeBtn = cc.ui.UIPushButton.new(btnCloseRes)
    closeBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
            if event.name == "began" then 
                closeBtn:setScale(1.2)
                return true
            elseif event.name == "ended" then 
                closeBtn:setScale(1.0)
                self:close()
            end
        end)   
    closeBtn:pos(mainBngSize.width - 30, mainBngSize.height- 30)
    closeBtn:addTo(mainBng):setAnchorPoint(cc.p(0.5,0.5))


    local innerSize = innnerBng:getContentSize()

    local confirmBtn = display.newSprite("#com_btn_ok.png")
		confirmBtn:setPosition(cc.p(innerSize.width * 0.2,innerSize.height * 0.2))
		confirmBtn:setAnchorPoint(cc.p(0.5,0.5))
		confirmBtn:setTouchEnabled(true)
	    innnerBng:addChild(confirmBtn)
	    confirmBtn:setTouchEnabled(true)
	    confirmBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then 
            confirmBtn:setScale(1.2)
            return true
        elseif event.name == "ended" then 
            if param.confirmFunc then
            	param.confirmFunc()
            end
            self:close()
        end
    end)

	local cancelBtn = display.newSprite("#com_btn_cancel.png")
		cancelBtn:setPosition(cc.p(innerSize.width * 0.8,innerSize.height * 0.2))
		cancelBtn:setAnchorPoint(cc.p(0.5,0.5))
		cancelBtn:setTouchEnabled(true)
	    innnerBng:addChild(cancelBtn)
	    cancelBtn:setTouchEnabled(true)
	    cancelBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then 
            cancelBtn:setScale(1.2)
            return true
        elseif event.name == "ended" then 
        	if param.cancelFun then
        		param.cancelFun()
        	end
            self:close()
        end
    end)



	local label_01 = ui.newTTFLabelWithShadow({  text = "花费", 
											size = 20, 
											color = ccc3(92,38,1),
											shadowColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	local label_02 = ui.newTTFLabelWithShadow({  text = param.cost, 
											size = 20, 
											color = ccc3(6,129,18),
											shadowColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	local icon    = display.newSprite("#icon_gold.png")
	local label_03 = ui.newTTFLabelWithShadow({  text = "购买1挑战次数", 
											size = 20, 
											color = ccc3(92,38,1),
											shadowColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	label_01:setPosition(innerSize.width * 0.22, innerSize.height * 0.8)
	label_02:setPosition(label_01:getContentSize().width + label_01:getPositionX() + 10, innerSize.height * 0.8)
	icon:setPosition(label_02:getContentSize().width + label_02:getPositionX() + 10, innerSize.height * 0.75)
	label_03:setPosition(icon:getContentSize().width + icon:getPositionX() + 10, innerSize.height * 0.8)
	innnerBng:addChild(label_01)
	innnerBng:addChild(label_02)
	innnerBng:addChild(icon)
	innnerBng:addChild(label_03)
	icon:setAnchorPoint(cc.p(0,0))


	local label_04 = ui.newTTFLabelWithShadow({ text = string.format("今日剩余购买次数:%d", param.timeleft), 
											size = 20, 
											color = ccc3(6,129,18),
											shadowColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	label_04:setPosition(innerSize.width / 3.3, innerSize.height * 0.5)
	label_04:setAnchorPoint(cc.p(0.5,0))
	innnerBng:addChild(label_04)
end

---
-- 创建蒙板
function BiwuBuyMsgBox:createMask()
	local winSize = CCDirector:sharedDirector():getWinSize()
    local mask = CCLayerColor:create()
    mask:setContentSize(winSize)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(150)
    mask:setAnchorPoint(cc.p(0,0))
    mask:setTouchEnabled(true)
    self:addChild(mask)
end
  
function BiwuBuyMsgBox:loadRes()
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")

end

function BiwuBuyMsgBox:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "res/ui/ui_coin_icon.png")

end

function BiwuBuyMsgBox:close()
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
	self:releaseRes()
	self:removeFromParent()
end
return BiwuBuyMsgBox


