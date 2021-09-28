local TransmitNode= class("TransmitNode")

function TransmitNode:ctor(mapid,posx,posy)
  	local findWayFunc = function()
  	
        local tempData = { targetType = 4 , mapID =  mapid ,  x = posx  , y = posy  }
        if __TASK then __TASK:findPath( tempData ) end

		__removeAllLayers()
	end

	local TransmitFunc = function()
		local suiji = getConfigItemByKey("MapInfo","q_map_id",mapid,"q_suiji")
		local shoewNeedData = { targetData = { mapID = mapid , 
											   pos = { { x = posx , y = posy } } 
											 } ,  
                                noTipShop = false ,
                                q_done_event = 0 ,
                                is_suiji = suiji,
                              }
                           
        if __TASK:portalGo( shoewNeedData ) then
       		__removeAllLayers(true)   
			DATA_Mission:setAutoPath(false)
			DATA_Mission.isStopFind = true  
			if G_MAINSCENE and G_MAINSCENE.map_layer then
				G_MAINSCENE.map_layer:resetHangup()
				if mapid == G_MAINSCENE.map_layer.mapID then
					__removeAllLayers()
				end
			end
			return 
        end
	end
	local q_map_name = getConfigItemByKey("MapInfo","q_map_id",mapid,"q_map_name")
	local spr, yesBtn, noBtn = MessageBoxYesNoEx(nil,string.format( game.getStrByKey("tradesmt_tips") ,q_map_name) ,findWayFunc ,TransmitFunc,game.getStrByKey("auto_find_way"), game.getStrByKey("delivery"),true)
	registerOutsideCloseFunc(spr,function() removeFromParent(spr) spr = nil end,true)
	G_TUTO_NODE:setTouchNode(noBtn, TOUCH_TRANSMIT_CONFIRM_TRANSMIT)

	G_TUTO_NODE:setShowNode(self, SHOW_TRANSMIT_CONFIRM)
end

return TransmitNode