--[[
 --
 -- add by vicky
 -- 2014.10.13
 --
 --]]  

 
 local WorldBossEndResultLayer = class("WorldBossEndResultLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 function WorldBossEndResultLayer:ctor(param) 
 	local data = param.data 
 	local confirmFunc = param.confirmFunc 
 	local rstObj = data["1"] 
	local awardAry = data["2"] 

 	local rootnode = {} 
 	local proxy = CCBProxy:create()
 	local node = CCBuilderReaderLoad("huodong/worldBoss_result_layer.ccbi", proxy, rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node) 

 	rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName, sender)
 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if confirmFunc ~= nil then 
        	confirmFunc() 
        end 
    end, CCControlEventTouchUpInside)  

	if rstObj.kill ~= nil and rstObj.kill ~= "" then 
		rootnode["state_lbl"]:setString(rstObj.kill .. "击杀了异兽") 
	else
		rootnode["state_lbl"]:setString("异兽未被击杀") 
	end 
	
	rootnode["attack_lbl"]:setString(rstObj.hurt) 
	if rstObj.rank ~= nil and rstObj.rank <= 0 then 
		rootnode["rank_lbl"]:setString("无") 
	else
		rootnode["rank_lbl"]:setString("第" .. rstObj.rank .. "名") 
	end 

	-- 银币和声望 
	for i, v in ipairs(awardAry) do 
		if v.t == 7 and v.id == 2 then 
			rootnode["silver_lbl"]:setString(tostring(v.n))
		elseif v.t == 7 and v.id == 5 then 
			rootnode["shengwang_lbl"]:setString(tostring(v.n))
		end 
	end 
 end 


 return WorldBossEndResultLayer 
 
