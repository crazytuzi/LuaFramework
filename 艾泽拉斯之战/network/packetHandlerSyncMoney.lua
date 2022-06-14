function SyncMoneyHandler( __optional_flag__money,  money, lastReason )
	king = dataManager.playerData;
	local tipText = {}
	local yellow = "^FFFF00"
	local Z = "^BE4BF9"
	local GREEND = "^00FF00"
	
	for i=1, 16 do
		if __optional_flag__money:isSetbit(i-1) then
			
			local intMoney = money[i]:GetInt();
			local oldMoney = 0;
			local text = nil
			local moneyEnum = i-1;
			if moneyEnum == enum.MONEY_TYPE.MONEY_TYPE_GOLD then
				--金矿
				oldMoney = king:getGold();
				king:setGold(intMoney);
				
				eventManager.dispatchEvent({name = global_event.RESOURCE_MONEY_CHANGE, 
										moneyType = enum.MONEY_TYPE.MONEY_TYPE_GOLD, oldMoney = oldMoney, newMoney = intMoney});
				
				if(intMoney > oldMoney)then
					text = yellow.."获得"..Z.."金币"..GREEND.." +"..(intMoney-oldMoney)
				end
		
				
			elseif moneyEnum == enum.MONEY_TYPE.MONEY_TYPE_LUMBER then
				--木材
				oldMoney = king:getWood();
				king:setWood(intMoney);
				eventManager.dispatchEvent({name = global_event.SKILLLEVELUP_UPDATE });
				
				eventManager.dispatchEvent({name = global_event.RESOURCE_MONEY_CHANGE, 
										moneyType = enum.MONEY_TYPE.MONEY_TYPE_LUMBER, oldMoney = oldMoney, newMoney = intMoney});
				
				if enum.LOG_SOURCE_TYPE.LOG_SOURCE_ADD_BUILD_GATHER == lastReason then
					
					-- 暴击是skill02
					local criticalBase = dataManager.lumberMillData:getConfig().criticalBase;
					local rate = (intMoney - oldMoney) / criticalBase;
					if rate == 1 then
						print("handleBuildSkill01Effect");
						homeland.handleBuildSkill01Effect(enum.HOMELAND_BUILD_TYPE.WOOD);
					else
						print("handleBuildSkill02Effect");
						homeland.handleBuildSkill02Effect(enum.HOMELAND_BUILD_TYPE.WOOD);
					end
					
					eventManager.dispatchEvent( { name  = global_event.WOOD_GATHER_EFFECT, rate = rate});
					
				end
				if(intMoney > oldMoney)then
					text = yellow.."获得"..Z.."木材"..GREEND.." +"..(intMoney-oldMoney)
				end
										
			elseif moneyEnum == enum.MONEY_TYPE.MONEY_TYPE_DIAMOND then
				--钻石
				oldMoney = king:getGem();
				king:setGem(intMoney);
				
				eventManager.dispatchEvent({name = global_event.RESOURCE_MONEY_CHANGE, 
										moneyType = enum.MONEY_TYPE.MONEY_TYPE_DIAMOND, oldMoney = oldMoney, newMoney = intMoney});
										
				if(intMoney > oldMoney)then
					text = yellow.."获得"..Z.."钻石"..GREEND.." +"..(intMoney-oldMoney)
				end
														
			elseif moneyEnum == enum.MONEY_TYPE.MONEY_TYPE_VIGOR then
				--体力
				oldMoney = king:getVitality();
				king:setVitality(intMoney);
				
				if intMoney > oldMoney then
					eventManager.dispatchEvent({name = global_event.MAIN_UI_VIGOR_DELTA, delta = (intMoney - oldMoney)});
					
					eventManager.dispatchEvent({name = global_event.RESOURCE_MONEY_CHANGE, 
						moneyType = enum.MONEY_TYPE.MONEY_TYPE_VIGOR, oldMoney = oldMoney, newMoney = intMoney});
				end
				
				if(intMoney > oldMoney)then
					text = yellow.."获得"..Z.."体力"..GREEND.." +"..(intMoney-oldMoney)
				end
				
			elseif moneyEnum == enum.MONEY_TYPE.MONEY_TYPE_MAGICEXP then
				-- 万能碎片经验
				oldMoney = dataManager.kingMagic:getExtraExp()
				
				dataManager.kingMagic:setExtraExp(intMoney);
				eventManager.dispatchEvent({name = global_event.SKILLTOWER_UPDATE, buildType = BUILD.BUILD_MAGIC_TOWER});	
	
				eventManager.dispatchEvent({name = global_event.RESOURCE_MONEY_CHANGE, 
										moneyType = enum.MONEY_TYPE.MONEY_TYPE_MAGICEXP, oldMoney = oldMoney, newMoney = intMoney});
										
				if(intMoney > oldMoney)then
					text = yellow.."获得"..Z.."魔法精华"..GREEND.." +"..(intMoney-oldMoney)
				end	
		
			elseif moneyEnum == enum.MONEY_TYPE.MONEY_TYPE_HONOR then
				--荣誉
				oldMoney = king:getHonor();
				king:setHonor(intMoney);
				eventManager.dispatchEvent({name = global_event.RESOURCE_MONEY_CHANGE, 
										moneyType = enum.MONEY_TYPE.MONEY_TYPE_HONOR, oldMoney = oldMoney, newMoney = intMoney});
										
				if(intMoney > oldMoney)then
					text = yellow.."获得"..Z.."荣誉"..GREEND.." +"..(intMoney-oldMoney)
				end										
										
										
			elseif moneyEnum == enum.MONEY_TYPE.MONEY_TYPE_CONQUEST then
				oldMoney = king:getConquest();
				king:setConquest(intMoney);
				eventManager.dispatchEvent({name = global_event.RESOURCE_MONEY_CHANGE, 
										moneyType = enum.MONEY_TYPE.MONEY_TYPE_CONQUEST, oldMoney = oldMoney, newMoney = intMoney});				
			
				if(intMoney > oldMoney)then
					text = yellow.."获得"..Z.."徽章"..GREEND.." +"..(intMoney-oldMoney)
				end
		
			end
			if(text)then
				table.insert(tipText,text)
			end
		end
	end
	
	eventManager.dispatchEvent({name = global_event.PLAYER_ATTR_SYNC});
	eventManager.dispatchEvent({name = global_event.BUYRESOURCE_UPDATE, });
	eventManager.dispatchEvent({name = global_event.SHIPLEVELUP_UPDATE });
	eventManager.dispatchEvent({name =  global_event.WARNINGHINT_SHOW,tip =  tipText ,RESGET = true})
	eventManager.dispatchEvent({name = global_event.IDOLSTATUSLEVELUP_UPDATE});
	eventManager.dispatchEvent({name = global_event.MIRACLE_UPDATE});
	
end
