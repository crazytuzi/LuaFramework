require"Lang"
UIAwardGet = {
	operateType = {
		award = 1,
		box   = 2,
		giftBag = 3,
        dailyTaskBox = 4,
        goddess = 5 ,
	}
}
local scrollView = nil
local sv_item = nil
local _param = nil                                                                                                                                
local _operateType = nil
local _uiItem  =nil
local function CallbackFunc(pack)
	if pack.header == StaticMsgRule.openWelfareBox then 
		if UIGuidePeople.guideStep then 
			UIManager.popScene()
			UIManager.flushWidget(UIFightTask)
			local function afterPlayEvent(armature)
			    UIGuidePeople.isGuide(armature:getBone("ren"),UIAwardGet)
			end
			local armature =  ActionManager.getEffectAnimation(36, afterPlayEvent)
			armature:setPosition(cc.p(UIManager.screenSize.width/2+30,UIManager.screenSize.height/2))
			UIManager.uiLayer:addChild(armature,100,100)
		else 
			local param = _param
			UIManager.popScene()
     		utils.showGetThings(param.welfareBox)
     		local image_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget,"image_basemap")
            image_basemap:getChildByName("box" .. param.key):getAnimation():playWithIndex(2)
			-- UIManager.flushWidget(UIFightTask)
		end
	end
end
local function sendOpenWelfareBox()
	local barrierId = _param.id 
	local chapterId = _param.chapterId 
	local instThing = nil 
	if net.InstPlayerBarrier then
	  for key,obj in pairs(net.InstPlayerBarrier) do
	      if obj.int["5"] == chapterId and obj.int["3"] == barrierId then
	        instThing = obj 
	        break
	      end
	  end
	end
    local sendData = nil
    if UIGuidePeople.guideStep == "2B3" then
         sendData = {
            header = StaticMsgRule.openWelfareBox,
            msgdata = {
      		    int = {
      			    instPlayerBarrierId = instThing.int["1"],
      		        },
                string = {
                    step = "2B4"
                    }
  		        }
        }
    else
        sendData = {
            header = StaticMsgRule.openWelfareBox,
            msgdata = {
      		    int = {
      			    instPlayerBarrierId = instThing.int["1"],
      		    },
  		    }
        }
    end
    UIManager.showLoading()
    netSendPackage(sendData, CallbackFunc)
end

local function cleanScrollView(_isRelease)
	if _isRelease then
		if sv_item and sv_item:getReferenceCount() >= 1 then
	  	sv_item:release()
	  	sv_item = nil
	  end
	  if scrollView then
	  	scrollView:removeAllChildren()
	  	scrollView = nil
		end
	else
	  if sv_item and sv_item:getReferenceCount() == 1 then
	  	sv_item:retain()
	  end
      if scrollView then
	    scrollView:removeAllChildren()
      end
	end
end

local function setScrollViewItem(item, _reward)
	local itemIcon = item:getChildByName("image_good")
	local itemName = itemIcon:getChildByName("text_name")
	local itemNums = ccui.Helper:seekNodeByName(item, "text_number")

	local data = utils.stringSplit(_reward, "_") --[1]:TableTypeId [2]:FieldId [3]:Nums
	local name,icon =utils.getDropThing(data[1],data[2])
    local tableTypeId, tableFieldId, value = data[1],data[2],data[3]
    itemName:setString(name)
    itemIcon:loadTexture(icon)
    itemNums:setString(tostring(value))
    utils.addBorderImage(tableTypeId,tableFieldId,item)
    if _operateType == UIAwardGet.operateType.giftBag or _operateType == UIAwardGet.operateType.dailyTaskBox or _operateType == UIAwardGet.operateType.goddess then
    	utils.showThingsInfo(itemIcon, data[1], data[2])
  	end
end

function UIAwardGet.init()
	local btn_close = ccui.Helper:seekNodeByName(UIAwardGet.Widget, "btn_close")
	local btn_sure = ccui.Helper:seekNodeByName(UIAwardGet.Widget, "btn_sure")
	btn_close:setPressedActionEnabled(true)
	btn_sure:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_sure then 
				if _operateType == UIAwardGet.operateType.box then 
					sendOpenWelfareBox()
				elseif _operateType == UIAwardGet.operateType.award then 
					UIManager.popScene()
                elseif _operateType == UIAwardGet.operateType.dailyTaskBox or _operateType == UIAwardGet.operateType.goddess then
                    local _callbackFuncParam = _param.callbackFunc
                    UIManager.popScene(nil, function()
                        if _callbackFuncParam then
                            _callbackFuncParam()
                        end
                    end)
				end
			elseif sender == btn_close then 
				UIManager.popScene()
			end
			if _uiItem == UITaskDay then 
				UIGuidePeople.levelGuideTrigger()
			end
		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	btn_sure:addTouchEventListener(btnTouchEvent)
	scrollView = ccui.Helper:seekNodeByName(UIAwardGet.Widget, "view_list")
	sv_item = scrollView:getChildByName("image_frame_good"):clone()
end

function UIAwardGet.setup()
	local ui_text_preview = ccui.Helper:seekNodeByName(UIAwardGet.Widget, "text_preview")
	local btn_sure = ccui.Helper:seekNodeByName(UIAwardGet.Widget, "btn_sure")
	local text_hint = ccui.Helper:seekNodeByName(UIAwardGet.Widget, "text_hint")
    local text_hint_money = ccui.Helper:seekNodeByName(UIAwardGet.Widget, "text_hint_money")
    if _param.isJoinAlliance == true then
        scrollView:setPositionY(scrollView:getPositionY() + 20)
        text_hint_money:setVisible(true)
    else
        text_hint_money:setVisible(false)
    end
	text_hint:setVisible(false)
	btn_sure:setVisible(true)
    cleanScrollView()
	local innerWidth, space = 0, 35
	local param = nil
	if _operateType == UIAwardGet.operateType.box then 
		ui_text_preview:setString(Lang.ui_award_get1)
		local barrierId = _param.id 
		local chapterId = _param.chapterId 
		param = utils.stringSplit(_param.welfareBox,";")
		local instThing = nil 
		if net.InstPlayerBarrier then
		  for key,obj in pairs(net.InstPlayerBarrier) do
		      if obj.int["5"] == chapterId and obj.int["3"] == barrierId then
		        instThing = obj 
		        break
		      end
		  end
		end
		if instThing then 
		    if instThing.int["9"] == 1 then 
		      btn_sure:setEnabled(true)
		      btn_sure:setBright(true)
		      btn_sure:setTitleText(Lang.ui_award_get2)
		    elseif instThing.int["9"] == 2 then 
		      btn_sure:setEnabled(false)
		      btn_sure:setBright(false)
		      btn_sure:setTitleText(Lang.ui_award_get3)
		    end
	  	else 
	  		btn_sure:setEnabled(false)
	      	btn_sure:setBright(false)
	      	btn_sure:setTitleText(Lang.ui_award_get4)
	  	end
	elseif _operateType == UIAwardGet.operateType.award then  
		ui_text_preview:setString(Lang.ui_award_get5)
		btn_sure:setEnabled(true)
     	btn_sure:setBright(true)
     	btn_sure:setTitleText(Lang.ui_award_get6)
     	if _uiItem == UIFightTask then 
     		param = utils.stringSplit(_param.welfareBox,";")
     	else 
     		param = _param
     	end
  elseif _operateType == UIAwardGet.operateType.giftBag then
  	ui_text_preview:setString(Lang.ui_award_get7)
    btn_sure:setVisible(false)
    text_hint:setVisible(true)
    param = utils.stringSplit(_param, ";")
    elseif _operateType == UIAwardGet.operateType.dailyTaskBox then
        ui_text_preview:setString(Lang.ui_award_get8)
        btn_sure:setEnabled(_param.enabled)
		btn_sure:setBright(_param.enabled)
        btn_sure:setTitleText(_param.btnTitleText)
        btn_sure:setVisible(true)
        text_hint:setVisible(false)
        param = utils.stringSplit(_param.things, ";")
        if _uiItem == UIAllianceEscortRank or _uiItem == UIAllianceRunRank or _uiItem == UIAllianceRun then
            btn_sure:setVisible(false)
            text_hint:setVisible(true)
            text_hint:setTextColor(cc.c3b(255,0,0))
            text_hint:setString(Lang.ui_award_get9)
        end
     elseif _operateType == UIAwardGet.operateType.goddess then
        ui_text_preview:setString(Lang.ui_award_get10)
        btn_sure:setEnabled(_param.enabled)
		btn_sure:setBright(_param.enabled)
        btn_sure:setTitleText(_param.btnTitleText)
        btn_sure:setVisible(true)
        text_hint:setVisible(false)
        param = utils.stringSplit(_param.things, ";")      
	end 
	if param then
		for key, obj in pairs(param) do
			local scrollViewItem = sv_item:clone()
			innerWidth = innerWidth + scrollViewItem:getContentSize().width + space
			scrollView:addChild(scrollViewItem)
			setScrollViewItem(scrollViewItem, obj)
		end
		innerWidth = innerWidth + space
	end
	if innerWidth < scrollView:getContentSize().width then
		innerWidth = scrollView:getContentSize().width
	end
	scrollView:setInnerContainerSize(cc.size(innerWidth, scrollView:getContentSize().height))
	local childs = scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + space, childs[i]:getPositionY()))
		else
			childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + space, childs[i]:getPositionY()))
		end
		prevChild = childs[i]

	end
	UIGuidePeople.isGuide(btn_sure,UIAwardGet)
end

--operateType 操作类型
--param 参数
function UIAwardGet.setOperateType(operateType,param,uiItem)
	_operateType = operateType
	_param = param
	_uiItem = uiItem
end

function UIAwardGet.free()
    cleanScrollView(true)
	UIGuidePeople.isGuide(nil,UIAwardGet)
	_uiItem = nil
	_param  = nil
	_operateType  = nil
end

