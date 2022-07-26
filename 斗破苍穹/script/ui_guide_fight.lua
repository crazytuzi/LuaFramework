UIGuideFight = {}
local checkedChapterId = nil

local function Jump()
	if checkedChapterId then 
		local LayerColor1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
        local LayerColor2 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
        LayerColor1:setPosition(cc.p(-UIManager.screenSize.width,0))
        LayerColor2:setPosition(cc.p(UIManager.screenSize.width,0))
        UIManager.gameLayer:addChild(LayerColor1, 1000000)
        UIManager.gameLayer:addChild(LayerColor2, 1000000)
		local subWidth = 0
		local t= 0.01
		local function changeFunc(sender,table)
			if table[1] == 1 then 
				subWidth = subWidth + 10
				LayerColor1:setPosition(cc.p(-UIManager.screenSize.width+subWidth,0))
        		LayerColor2:setPosition(cc.p(UIManager.screenSize.width-subWidth,0))
				if subWidth <= UIManager.screenSize.width/2 then 
					sender:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc,{1})))
				else 
					---切换到另一场景
					UIFightTask.setChapterId(checkedChapterId)
					UIManager.flushWidget(UIFightTask)
					sender:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc,{2})))
					checkedChapterId = nil
				end
			else 
				subWidth = subWidth - 10
				LayerColor1:setPosition(cc.p(-UIManager.screenSize.width+subWidth,0))
        		LayerColor2:setPosition(cc.p(UIManager.screenSize.width-subWidth,0))
				if subWidth ~= 0 then 
					sender:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc,{2})))
				else 
					---切换完场景
					LayerColor1:removeFromParent()
					LayerColor2:removeFromParent()
				end
			end
		end
		UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc,{1})))
	else 
		cclog(" checkedChapterId = nil !!! ")
	end
end

function UIGuideFight.init()
	local btn_sure = ccui.Helper:seekNodeByName(UIGuideFight.Widget, "image_system")
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_sure then 
				AudioEngine.playEffect("sound/button.mp3")
				UIManager.popScene()
				-- Jump()
				UIFightTask.setChapterId(checkedChapterId)
				UIManager.flushWidget(UIFightTask)
				checkedChapterId = nil 
			else 
				UIManager.popScene()
			end
		end
	end
	btn_sure:addTouchEventListener(btnTouchEvent)
	UIGuideFight.Widget:addTouchEventListener(btnTouchEvent)
end

function UIGuideFight.setup( ... )
	if checkedChapterId then 
		local btn_sure = ccui.Helper:seekNodeByName(UIGuideFight.Widget, "image_system")
		local backGroundPictureS = DictChapter[tostring(checkedChapterId)].backGroundPictureS
		btn_sure:loadTexture("image/" .. backGroundPictureS)
		if checkedChapterId == 2 or checkedChapterId == 3 then
			UIGuidePeople.isGuide(nil,UIGuideFight)
		end
	end
end


function UIGuideFight.checkNewChapter(barrierId)
	local chapterId = DictBarrier[tostring(barrierId)].chapterId
	local nextBarrierId = DictBarrier[tostring(barrierId)].barrierId
	local nextChapterId = DictBarrier[tostring(nextBarrierId)].chapterId
	if nextBarrierId ~= 0 and type(nextChapterId) == "number" and chapterId ~= nextChapterId then 
		local openLevel = DictChapter[tostring(nextChapterId)].openLeve
		if net.InstPlayer.int["4"] >= openLevel then 
			checkedChapterId = DictBarrier[tostring(nextBarrierId)].chapterId
			UIManager.pushScene("ui_guide_fight")
			return true
		else 
			return false
		end
	end
	return false
end

