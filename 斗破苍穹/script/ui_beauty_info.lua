UIBeautyInfo = {}
local dictBeautyCardId = nil
function UIBeautyInfo.init()
	local btn_go = ccui.Helper:seekNodeByName(UIBeautyInfo.Widget, "btn_go")
	local btn_close = ccui.Helper:seekNodeByName(UIBeautyInfo.Widget, "btn_close")
	btn_go:setPressedActionEnabled(true)
	btn_close:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if UIBeautyInfo.Widget:getChildByTag(100) then 
				UIBeautyInfo.Widget:removeChildByTag(100)
			end
			if sender == btn_go then 
				if UIGuidePeople.guideStep then 
					UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
				else 
					UIManager.showScreen("ui_notice", "ui_beauty", "ui_menu")
				end
			else
				UIManager.popScene()
			end
		end
	end
	btn_go:addTouchEventListener(btnTouchEvent)
	btn_close:addTouchEventListener(btnTouchEvent)
end

function UIBeautyInfo.setup()
	if not UIGuidePeople.guideStep then 
		UIBeautyInfo.Widget:setEnabled(true)
	else 
		UIBeautyInfo.Widget:setEnabled(false)
	end
	local beautyCardTable = {}
	for i = 1,9 do 
		beautyCardTable[i] = ccui.Helper:seekNodeByName(UIBeautyInfo.Widget, "image_beauty" .. i)
		if dictBeautyCardId > i then 
			utils.GrayWidget(beautyCardTable[i],false)
		elseif dictBeautyCardId == i then 
			utils.GrayWidget(beautyCardTable[i],true)
			local lightCard = beautyCardTable[i]:clone()
			lightCard:setScale(5)
			local pos = beautyCardTable[i]:getWorldPosition()
			lightCard:setPosition(pos)
			UIBeautyInfo.Widget:addChild(lightCard,100,100)
			utils.GrayWidget(lightCard,false)
			lightCard:setVisible(false)
			local function showCard(sender)
				sender:setVisible(true)
				sender:setOpacity(78)
			end
			local function itemScaleAction(sender)
				sender:removeFromParent()
				utils.GrayWidget(beautyCardTable[i],false)
				local function guide()
					UIGuidePeople.isGuide(nil,UIBeautyInfo)
				end
				UIBeautyInfo.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(guide)))
			end
			lightCard:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(showCard),cc.Spawn:create(cc.ScaleTo:create(0.3,1),cc.FadeTo:create(0.3, 255)),
				cc.CallFunc:create(itemScaleAction)))
		else 
			utils.GrayWidget(beautyCardTable[i],true)
		end
	end
end

function UIBeautyInfo.free()
	dictBeautyCardId = nil 
	-- UIGuidePeople.isGuide(nil,UIFightTask)
	-- if UIGuidePeople.guideStep == guideInfo["2B1"].step then
	-- 	local image_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget,"image_basemap")
 --        UIGuidePeople.addGuideUI(UIFightTask,image_basemap:getChildByName("box1"))
	-- end
end

function UIBeautyInfo.checkNewBeauty(barrierId)
	for key,obj in pairs(DictBeautyCard) do 
		if tonumber(obj.unblock) == tonumber(barrierId) then 
			dictBeautyCardId = obj.id
		end
	end
	if dictBeautyCardId then 
		UIManager.pushScene("ui_beauty_info")
	end
end