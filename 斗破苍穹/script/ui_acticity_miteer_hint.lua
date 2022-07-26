UIActivityMiteerHint={}
function UIActivityMiteerHint.init()
	local btn_check = ccui.Helper:seekNodeByName(UIActivityMiteerHint.Widget, "btn_check")
	btn_check:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
    	if eventType == ccui.TouchEventType.ended then
    		UIManager.popScene()
    		if sender == btn_check then 
    			UIActivityPanel.scrollByName("auctionShop","auctionShop")
	    		UIManager.showWidget("ui_notice", "ui_team_info", "ui_activity_panel", "ui_menu")
	    		AudioEngine.playMusic("sound/activity.mp3", true)
	    	end
   		end
	end
	btn_check:addTouchEventListener(btnTouchEvent)
	UIActivityMiteerHint.Widget:addTouchEventListener(btnTouchEvent)
end

function UIActivityMiteerHint.setup()
	UIFightTask.setBasemapPercent(nil)
	local image_frame_good = {}
	for i=1,3 do 
		image_frame_good[i] = ccui.Helper:seekNodeByName(UIActivityMiteerHint.Widget, "image_frame_good" .. i)
	end
	
	if net.InstAuctionShop then
	  local i = 0
      for key,obj in pairs(net.InstAuctionShop) do
      	 i = i +1 
         if i <= 3 then 
         	local  tableTypeId = obj.int["3"]
		    local  tableFieldId = obj.int["4"] 
		    local  value = obj.int["5"] 
		    local  ui_image_good = image_frame_good[i]:getChildByName("image_good" .. i)
		    local  thingName,thingIcon = utils.getDropThing(tableTypeId,tableFieldId)
		    utils.addBorderImage(tableTypeId,tableFieldId,image_frame_good[i])
		    ui_image_good:loadTexture(thingIcon)
         end
      end
    end
end