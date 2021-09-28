--[[
 --
 -- add by vicky
 -- 2014.10.13
 --
 --]]  


 local WorldBossBattleResultLayer = class("WorldBossBattleResultLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 function WorldBossBattleResultLayer:ctor(param)
 	local confirmFunc = param.confirmFunc 
 	local data = param.data 

 	local rootnode = {} 
 	local proxy = CCBProxy:create()
 	local node = CCBuilderReaderLoad("huodong/worldBoss_challenge_layer.ccbi", proxy, rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node) 

	-- 伤害值
	rootnode["hurt_lbl"]:setString(tostring(data["4"].curHurt))

	-- 声望 
	for i, v in ipairs(data["3"]) do 
		if v.t == 7 and v.id == 5 then 
			rootnode["shengwang_lbl"]:setString(tostring(v.n))
		end 
	end 

    rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName, sender)
    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if confirmFunc ~= nil then 
        	confirmFunc()
        end 
    end, CCControlEventTouchUpInside)  

    rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName, sender)
GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        if confirmFunc ~= nil then 
        	confirmFunc()
        end 
    end, CCControlEventTouchUpInside)  


 end


 return WorldBossBattleResultLayer 
