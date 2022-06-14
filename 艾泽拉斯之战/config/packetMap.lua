
packetMap = {}

--[[
packetMap[enum.PACKET_ID.ASK_SYNC_BUILD ] = { response = true, packet = {enum.PACKET_ID.ERROR,enum.PACKET_ID.NOTIFY_BUILD_LEVEL_UP,enum.PACKET_ID.SYNC_BUILD }    }
packetMap[enum.PACKET_ID.BATTLE ] ={response = true, packet = {enum.PACKET_ID.SYNC_BATTLE,enum.PACKET_ID.ERROR}}
packetMap[enum.PACKET_ID.CANCEL_BATTLE ] ={response = true, packet = {enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR}}
packetMap[enum.PACKET_ID.GATHER ] ={response = true, packet = {enum.PACKET_ID.SYNC_BUILD,enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR}}
packetMap[enum.PACKET_ID.GM ] ={response = false, packet = { }}
packetMap[enum.PACKET_ID.LOGIN ] ={response = true, packet = {enum.PACKET_ID.LOGIN_RESULT }}
packetMap[enum.PACKET_ID.MAGIC ] ={response = true, packet = { enum.PACKET_ID.BATTLE_RESULT,enum.PACKET_ID.SYNC_KING,enum.PACKET_ID.ERROR }}
packetMap[enum.PACKET_ID.UPGRADE_BUILD ] ={response = false, packet = { }}
packetMap[enum.PACKET_ID.DRAW_CARD ] ={response = true, packet = {enum.PACKET_ID.CARD_RESULT,enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR  }}
packetMap[enum.PACKET_ID.ASK_DEL_ITEM ] ={response = false, packet = { enum.PACKET_ID.DEL_ITEM_RESULT }} 
packetMap[enum.PACKET_ID.EQUIP ] ={response = false, packet = {   }} 
packetMap[enum.PACKET_ID.EQUIP_ENHANCE ] ={response = false, packet = { enum.PACKET_ID.EQUIP_ENHANCE_RESULT,enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR  }} 
packetMap[enum.PACKET_ID.SHIP_UPGRADE ] ={response = false, packet = { enum.PACKET_ID.SHIP_UPGRADE_RESULT,enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR  }} 
packetMap[enum.PACKET_ID.ASK_MAIL ] ={response = true, packet = { enum.PACKET_ID.MAIL_RESULT ,enum.PACKET_ID.MAIL,enum.PACKET_ID.MAIL_PREVIEW ,enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR  }} 
packetMap[enum.PACKET_ID.AGIOTAGE ] ={response = true, packet = { enum.PACKET_ID.SYNC_COUNTER }} 
packetMap[enum.PACKET_ID.PLAN ] ={response = true, packet = { enum.PACKET_ID.SYNC_PLAN   ,enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR }}    
packetMap[enum.PACKET_ID.CHOOSE_MAGIC_RESULT ] ={response = true, packet = { enum.PACKET_ID.SYNC_MAGIC   ,enum.PACKET_ID.MEDITATE_RESULT,enum.PACKET_ID.ERROR }}    
packetMap[enum.PACKET_ID.SYSTEM_REWARD ] ={response = true, packet = {enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR }}    
packetMap[enum.PACKET_ID.TRADE ] ={response = false, packet = {  }}    
packetMap[enum.PACKET_ID.INCIDENT ] ={response = true, packet = { enum.PACKET_ID.INCIDENT_RESULT ,enum.PACKET_ID.SYNC_INCIDENT ,enum.PACKET_ID.ERROR }}    
packetMap[enum.PACKET_ID.CANCEL_WAITLINE ] ={response = true, packet = { enum.PACKET_ID.SUCCESS ,enum.PACKET_ID.ERROR }}    
packetMap[enum.PACKET_ID.SWEEP ] ={response = true, packet = { enum.PACKET_ID.SWEEP_REWARD ,enum.PACKET_ID.ERROR }}     
packetMap[enum.PACKET_ID.USE_ITEM ] ={response = false, packet = {  }}     
packetMap[enum.PACKET_ID.SHOP_REFRESH ] ={response = false, packet = {  }}     
packetMap[enum.PACKET_ID.SHOP_BUY_ITEM ] ={response = false, packet = {  }}      
packetMap[enum.PACKET_ID.PVP_REFRESH ] ={response = true, packet = { enum.PACKET_ID.PVP_CANDIDATE ,enum.PACKET_ID.ERROR   }}      
packetMap[enum.PACKET_ID.PVP_CANDIDATE_RANK ] ={response = true, packet = { enum.PACKET_ID.PVP_CANDIDATE_RANK_RESULT ,enum.PACKET_ID.ERROR   }}      
packetMap[enum.PACKET_ID.ASK_LADDER ] ={response = true, packet = { enum.PACKET_ID.LADDER,enum.PACKET_ID.ERROR   }}  
packetMap[enum.PACKET_ID.ASK_DAMAGE_RANK ] ={response = true, packet = { enum.PACKET_ID.SYNC_DAMAGE_RANK   }}  
packetMap[enum.PACKET_ID.ASK_TOP_DAMAGE ] ={response = true, packet = { enum.PACKET_ID.TOP_DAMAGE,enum.PACKET_ID.ERROR    }}   
packetMap[enum.PACKET_ID.ASK_LADDER_DETAIL ] ={response = true, packet = { enum.PACKET_ID.LADDER_DETAIL }}   
packetMap[enum.PACKET_ID.ASK_REPLAY ] ={response = true, packet = {enum.PACKET_ID.SYNC_BATTLE,enum.PACKET_ID.ERROR  }} 
packetMap[enum.PACKET_ID.ASK_REPLAY_SUMMARY ] ={response = true, packet = {enum.PACKET_ID.REPLAY_SUMMARY}} 
packetMap[enum.PACKET_ID.CREATE_ROLE ] ={response = false, packet = { enum.PACKET_ID.SYNC_PLAYER ,enum.PACKET_ID.LOGIN_RESULT,enum.PACKET_ID.ERROR}} 
packetMap[enum.PACKET_ID.CHANGE_NAME ] ={response = true, packet = {  enum.PACKET_ID.SYNC_PLAYER   ,enum.PACKET_ID.ERROR }} 
packetMap[enum.PACKET_ID.CHANGE_ICON ] ={response = true, packet = {enum.PACKET_ID.SYNC_PLAYER }} 
packetMap[enum.PACKET_ID.TICK ] ={response = false, packet = {}} 
packetMap[enum.PACKET_ID.FUSE_MAGIC ] ={response = false, packet = {}}  
packetMap[enum.PACKET_ID.SHIP_REMOULD ] ={response = false, packet = {enum.PACKET_ID.SHIP_REMOULD_RESULT,enum.PACKET_ID.ERROR}}  

packetMap[enum.PACKET_ID.SEARCH_FRIEND ] ={response = true, packet = {enum.PACKET_ID.SEARCH_FRIEND_RESULT,enum.PACKET_ID.ERROR}}  
packetMap[enum.PACKET_ID.FRIENDS_OP ] ={response = true, packet = {enum.PACKET_ID.SYNC_FRIEND_DEL ,enum.PACKET_ID.SYNC_FRIEND,enum.PACKET_ID.SYNC_FRIEND_APPLICANTS,enum.PACKET_ID.SYNC_FRIEND_MESSAGE,enum.PACKET_ID.ERROR,enum.PACKET_ID.SUCCESS}}  
packetMap[enum.PACKET_ID.ASK_CHAT] ={response = true, packet = {enum.PACKET_ID.CHAT,enum.PACKET_ID.ERROR}}  
packetMap[enum.PACKET_ID.ASK_INSPECT] ={response = true, packet = {enum.PACKET_ID.INSPECT,enum.PACKET_ID.ERROR}}  

]]--
-- k                                v
-- enum.PACKET_ID.ASK_SYNC_BUILD = 0;
for k,v in  pairs  (enum.PACKET_ID ) do
	
	if( packetHandlerRegister[v] == nil  )then    --- ==nil 
		packetMap[v] = {response = true, packet = {enum.PACKET_ID.SUCCESS,enum.PACKET_ID.ERROR}}  
	end
end
packetMap[enum.PACKET_ID.TICK] = {response = false, packet = {}}  