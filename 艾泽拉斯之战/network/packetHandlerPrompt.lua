function PromptHandler( promptType, id, preExp, exp, preStar, star, overflow, firstGain )
	
	print("PromptHandler overflow "..overflow.." promptType "..promptType);
	
	-- 直接提示
	if game.state ~= game.GAME_STATE_BATTLE and promptType == enum.PROMPT_TYPE.PROMPT_TYPE_CARD_OVERFLOW and overflow > 0 then
	
		local honor = overflow * dataConfig.configs.ConfigConfig[0].overflowCardexpToHonor;
		
		local tipsInfo = string.format("^FFFF00溢出^00FF00%d个^BE4BF9军团碎片，^FFFF00已转化成^BE4BF9荣誉",overflow);
		
		print(tipsInfo);
		
		eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = tipsInfo});
		
	end
			
	local isDrawCard = global.getFlag("sendDrawCard");
	if isDrawCard then
		-- 如果是抽卡的获得的话，在抽卡的结果包里有信息
		return;
	end
	
	local preCount = #global.newCardMagicList;
	
	if promptType == enum.PROMPT_TYPE.PROMPT_TYPE_CARD then
		
			if firstGain then

				local data = {
					promptType = "newcard",
					cardType = id,
					unitID = dataConfig.configs.unitCompatableConfig[id].starLevel[star],
				};
				
				table.insert(global.newCardMagicList, data);
				
			else
				local data = {
					promptType = "cardlevelup",
					cardType = id,
					oldUnitID = dataConfig.configs.unitCompatableConfig[id].starLevel[preStar],
					newUnitID = dataConfig.configs.unitCompatableConfig[id].starLevel[star],
				};

				table.insert(global.newCardMagicList, data);
			end
			
	elseif promptType == enum.PROMPT_TYPE.PROMPT_TYPE_MAGIC then
		
			local data = {
				promptType = "magiclevelup",
				magicID = id,
				oldLevel = preStar,
				newLevel = star,
				preExp = preExp,
				exp = exp,
				firstGain = firstGain,
				extraExp = overflow,
			};
			
			table.insert(global.newCardMagicList, data);
	end
	
	dump(global.newCardMagicList);
	
	if preCount == 0 and game.state ~= game.GAME_STATE_BATTLE then
		global.triggerNewCardAndMagic();
	end
	
end
