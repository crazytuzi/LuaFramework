require"Lang"
UIAwardOnLine ={}
local awardData = nil
local function netCallbackFunc(pack)
    local InstData = nil 
    for key,obj in pairs(net.InstActivityOnlineRewards) do 
      InstData = obj
    end
    UITeamInfo.setup()
    local btn_prize = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "btn_prize")
    utils.GrayWidget(btn_prize,true)
    btn_prize:setEnabled(false)
    UIManager.popScene()
    UIHomePage.countDownTime = math.ceil(InstData.int["4"]/1000)
    if UIHomePage.countDownTime ~= 0 then 
      UIHomePage.ScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UIHomePage.updateTime,1,false)
    else 
      ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_award"):setVisible(false)
    end
    UIAwardGet.setOperateType(UIAwardGet.operateType.award,awardData)
    UIManager.pushScene("ui_award_get")
end
local function sendRewardsData()
    local InstData = nil 
    for key,obj in pairs(net.InstActivityOnlineRewards) do 
      InstData = obj
    end
    local  sendData = {
      header = StaticMsgRule.onlineRewards,
      msgdata = {
        int = {
          instActivityOnlineRewardsId = InstData.int["1"]
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
function UIAwardOnLine.init( ... )
	local btn_close = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "btn_close")
	local btn_prize = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "btn_prize")
	btn_close:setPressedActionEnabled(true)
	btn_prize:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
        AudioEngine.playEffect("sound/button.mp3")
      	if sender == btn_close then 
      		UIManager.popScene()
      	elseif sender == btn_prize then --领取奖励
          sendRewardsData()
      	end
  	  end
  	end
  	btn_close:addTouchEventListener(btnTouchEvent)
	btn_prize:addTouchEventListener(btnTouchEvent)
end

function UIAwardOnLine.setup( ... )
  if UIHomePage.countDownTime == nil or  UIHomePage.countDownTime == 0 then 
    local text_countdown = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "text_countdown")
    text_countdown:setString(string.format(Lang.ui_award_online1,0,0,0))
  end
  local image_frame_good ={}
  for i=1,4 do 
     image_frame_good[i] = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "image_frame_good"..i)
  end
	if net.InstActivityOnlineRewards then 
      if UIHomePage.countDownTime ~= nil then 
        local btn_prize = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "btn_prize")
        utils.GrayWidget(btn_prize,true)
        btn_prize:setEnabled(false)
      end
      local InstData = nil 
      for key,obj in pairs(net.InstActivityOnlineRewards) do 
        InstData = obj
      end
      local data = InstData.string["5"]
      awardData = utils.stringSplit(data, ";")
      if next(awardData) then 
        for  i=1,4 do 
          if i>#awardData then 
            image_frame_good[i]:setVisible(false)
          else 
            image_frame_good[i]:setVisible(true)
          end
        end
        for i,obj in pairs(awardData) do 
            local _awardTableData = utils.stringSplit(obj, "_")
            local name,icon =utils.getDropThing(_awardTableData[1],_awardTableData[2])
            local thingIcon = image_frame_good[i]:getChildByName("image_good")
            local thingName = image_frame_good[i]:getChildByName("text_name")
            local thingCount = ccui.Helper:seekNodeByName(image_frame_good[i], "text_number")
            local tableTypeId, tableFieldId, value = _awardTableData[1],_awardTableData[2],_awardTableData[3]
            thingName:setString(name)
            thingIcon:loadTexture(icon)
            thingCount:setString(tostring(value))
            utils.addBorderImage(tableTypeId,tableFieldId,image_frame_good[i])
        end
      else 
        UIManager.showToast(Lang.ui_award_online2)
      end
  end
end

function UIAwardOnLine.free( ... )
  awardData = nil
end
