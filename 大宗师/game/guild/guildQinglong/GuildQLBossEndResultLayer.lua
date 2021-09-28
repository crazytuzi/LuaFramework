--[[
 --
 -- add by vicky
 -- 2015.01.23 
 --
 --]]  

 
 local GuildQLBossEndResultLayer = class("GuildQLBossEndResultLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 function GuildQLBossEndResultLayer:ctor(param) 
 	local rtnObj = param.data.rtnObj  
 	local confirmFunc = param.confirmFunc 
 	local rstObj = rtnObj.res  
	local awardAry = rtnObj.awardAry  

 	local rootnode = {} 
 	local proxy = CCBProxy:create()
 	local node = CCBuilderReaderLoad("guild/guild_worldBoss_result_layer.ccbi", proxy, rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node) 

 	rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName, sender)
 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if confirmFunc ~= nil then 
        	confirmFunc() 
        end 
    end, CCControlEventTouchUpInside)  

	if rstObj.kill ~= nil and rstObj.kill ~= "" then 
		rootnode["state_lbl"]:setString(rstObj.kill .. "击杀了青龙") 
	else
		rootnode["state_lbl"]:setString("青龙未被击杀") 
	end 
	
	rootnode["attack_lbl"]:setString(rstObj.hurt) 
	if rstObj.rank ~= nil and rstObj.rank <= 0 then 
		rootnode["rank_lbl"]:setString("无") 
	else
		rootnode["rank_lbl"]:setString("第" .. rstObj.rank .. "名") 
	end 

	-- 银币、声望、帮贡  
	for i, v in ipairs(awardAry) do 
		-- 银币
		if v.t == 7 and v.id == 2 then 
			rootnode["silver_lbl"]:setString(tostring(v.n))

		-- 声望
		elseif v.t == 7 and v.id == 5 then 
			rootnode["shengwang_lbl"]:setString(tostring(v.n))

		-- 帮贡 
		elseif v.t == 7 and v.id == 8 then 
			rootnode["guild_contribute_lbl"]:setString(tostring(v.n))
		end 
	end 
 end 


 return GuildQLBossEndResultLayer 
 
