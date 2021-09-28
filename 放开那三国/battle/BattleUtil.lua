
-- Filename: BattleUtil.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景

module("BattleUtil", package.seeall)
require "script/battle/BattleLayer"

function playerBattleReportById( p_reportId, sender ,callFunc, p_showFightForce)

   	local reportId = p_reportId or tolua.cast(sender:getUserObject(), "CCInteger"):getValue()
   	if p_showFightForce == nil then
   		p_showFightForce = true
   	end
	if(reportId == nil) then
      print("p_reportId", p_reportId)
      print("userobject", tolua.cast(sender:getUserObject(), "CCInteger"):getValue())
      error("error in function playerBattleReportById p_reportId = nil")
		return
	end

	local requestCallback =  function( fightRet )
		-- 调用战斗接口 参数:atk 
		-- 调用结算面板
		local amf3_obj = Base64.decodeWithZip(fightRet)
		local lua_obj = amf3.decode(amf3_obj)
		require "script/ui/guild/city/VisitorBattleLayer"
      	local fightDate = {}
      	fightDate.server = lua_obj
      	local visitor_battle_layer = VisitorBattleLayer.createAfterBattleLayer(fightDate,nil,callFunc)
	   BattleLayer.showBattleWithString(fightRet, nil, visitor_battle_layer,nil,nil,nil,nil,nil,p_showFightForce)
	end
    require "script/ui/mail/MailService"
	MailService.getRecord(reportId, requestCallback)
end

function playTwoBattle( pBirdA, pBirdB, pCallback)
	local fightStrA = nil
	local fightStrB = nil
	local playABattleEndCallback = function ( ... )
		local amf3_obj = Base64.decodeWithZip(fightStrB)
		local lua_obj = amf3.decode(amf3_obj)
		require "script/ui/guild/city/VisitorBattleLayer"
      	local fightDate = {}
      	fightDate.server = lua_obj
      	local visitor_battle_layer = VisitorBattleLayer.createAfterBattleLayer(fightDate,nil,pCallback)
	  	BattleLayer.showBattleWithString(fightStrB, nil, visitor_battle_layer,nil,nil,nil,nil,nil,p_showFightForce)
	end
	local requestACallback =  function( fightRet )
		fightStrA = fightRet
		MailService.getRecord(pBirdB, function ( fightRet )
			fightStrB = fightRet
			local emptyReportLayer = CCLayer:create()
			emptyReportLayer:registerScriptHandler(function ( nodeType )
				if nodeType == "enter" then
					performCallfunc(function ( ... )
						BattleLayer.closeLayer()
						playABattleEndCallback()
					end, 0.5)
				end
			end)
			BattleLayer.showBattleWithString(fightStrA, nil, emptyReportLayer,nil,nil,nil,nil,nil,p_showFightForce)
		end)
	end
	require "script/ui/mail/MailService"
	MailService.getRecord(pBirdA, requestACallback)
end



function playerTestBattleReportById( p_reportId, sender ,callFunc, p_showFightForce)

   	local reportId = p_reportId or tolua.cast(sender:getUserObject(), "CCInteger"):getValue()
   	if p_showFightForce == nil then
   		p_showFightForce = true
   	end
	if(reportId == nil) then
      print("p_reportId", p_reportId)
      print("userobject", tolua.cast(sender:getUserObject(), "CCInteger"):getValue())
      error("error in function playerBattleReportById p_reportId = nil")
		return
	end

	local requestCallback =  function( fightRet )
		-- 调用战斗接口 参数:atk 
		-- 调用结算面板
		local amf3_obj = Base64.decodeWithZip(fightRet)
		local lua_obj = amf3.decode(amf3_obj)
		require "script/ui/guild/city/VisitorBattleLayer"
      local fightDate = {}
      fightDate.server = lua_obj
      local visitor_battle_layer = VisitorBattleLayer.createAfterBattleLayer(fightDate,nil,callFunc)
      require "script/fight/FightScene"
      FightScene.setReportLayer(visitor_battle_layer)
	  FightScene.showFightWithString(fightRet)
	end
    require "script/ui/mail/MailService"
	MailService.getRecord(reportId, requestCallback)
end