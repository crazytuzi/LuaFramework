function CardResultHandler( cardResultType, cardInfo )
	
	local resultCardInfo = {};
	
	print("cardResultHandler type: "..cardResultType);
	for k, v in ipairs(cardInfo) do
		local card = cardData.cardlist[v.cardID];
		if card == nil then
			print("cardResultHandler type error: "..v.cardID);
			resultCardInfo[k] = {
				cardID = v.cardID;
				cardExp = v.cardExp;
			};
		else
			
			local oldExp = card:getExp();
			
			resultCardInfo[k] = {
				cardID = v.cardID;
				cardExp = v.cardExp - oldExp;
				firstGain = v.firstGain,
				preStar = v.preStar,
				currentStar = v.currentStar,
			};
			
			card:setExp(v.cardExp);
		end
		
		
		-- 升星
		if not v.firstGain and v.preStar < v.currentStar then
		
				local data = {
					promptType = "cardlevelup",
					cardType = v.cardID,
					oldUnitID = dataConfig.configs.unitCompatableConfig[v.cardID].starLevel[v.preStar],
					newUnitID = dataConfig.configs.unitCompatableConfig[v.cardID].starLevel[v.currentStar],
				};

				table.insert(global.newCardMagicList, data);
		end
		
		print("cardResultHandler type: "..v.cardID.." exp: "..v.cardExp.." firstGain "..tostring(v.firstGain));
	end
	
	--dump(resultCardInfo);
	
	-- 如果是抽卡的结果，需要弹出界面
	if cardResultType == enum.CARD_RESULT_TYPE.CARD_RESULT_TYPE_DRAW_ONCE 
		or cardResultType == enum.CARD_RESULT_TYPE.CARD_RESULT_TYPE_DRAW_FREE 
		or cardResultType == enum.CARD_RESULT_TYPE.CARD_RESULT_TYPE_DRAW_TEN then

		--eventManager.dispatchEvent({ name = global_event.CORPSGET1_SHOW, resultType = cardResultType, resultData = resultCardInfo, });
		
		displayCardLogic.initDisplay(cardResultType, resultCardInfo);
		
		global.setFlag("sendDrawCard", false);
	end
	
end
