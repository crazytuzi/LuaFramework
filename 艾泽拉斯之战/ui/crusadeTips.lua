local crusadeTips = class( "crusadeTips", layout );

global_event.CRUSADETIPS_SHOW = "CRUSADETIPS_SHOW";
global_event.CRUSADETIPS_HIDE = "CRUSADETIPS_HIDE";

function crusadeTips:ctor( id )
	crusadeTips.super.ctor( self, id );
	self:addEvent({ name = global_event.CRUSADETIPS_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CRUSADETIPS_HIDE, eventHandler = self.onHide});
end

function crusadeTips:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	
	for i=1, 3 do
		local crusadeTips_money_image = LORD.toStaticImage(self:Child( "crusadeTips-money"..i.."-image" ));
		local crusadeTips_money_num = self:Child( "crusadeTips-money"..i.."-num" );
		local crusadeTips_money_dw = self:Child("crusadeTips-money"..i.."-dw");
		
		crusadeTips_money_image:SetImage("");
		crusadeTips_money_num:SetText("");
		crusadeTips_money_dw:SetVisible(false);
		
	end

	-- moneyIndex
	local moneyIndex = 1;
	
	local xPosition = LORD.UDim(0, 5);
	local yPosition = LORD.UDim(0, 5);
	
	local playerData = dataManager.playerData;
	
	local stageInfo = dataManager.crusadeActivityData:getStageInfo(event.stageIndex);
	
	if stageInfo then
	
		for k,v in ipairs(stageInfo.rewardType) do
			
			local rewardInfo = playerData:getRewardInfo(v, stageInfo.rewardID[k], stageInfo.rewardCount[k]);
			
			--dump(rewardInfo);
			
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY then
			
				local crusadeTips_money_image = LORD.toStaticImage(self:Child( "crusadeTips-money"..moneyIndex.."-image" ));
				local crusadeTips_money_num = self:Child( "crusadeTips-money"..moneyIndex.."-num" );
				
				if crusadeTips_money_image then
					crusadeTips_money_image:SetImage(rewardInfo.icon);
				end
				
				if crusadeTips_money_num then
					crusadeTips_money_num:SetText(rewardInfo.count);
				end
				
				local crusadeTips_money_dw = self:Child("crusadeTips-money"..moneyIndex.."-dw");
				crusadeTips_money_dw:SetVisible(true);
				
				moneyIndex = moneyIndex + 1;
			else

			end
			
		end
		
	end	

		
	self:calcTipsPositionFree(event);
	
end

function crusadeTips:onHide(event)
	self:Close();
end

function crusadeTips:calcTipsPositionFree(event)
	
	if not self._show then
		return;
	end
	
	local clickWindowRect = event.windowRect;
	local clickWindowWidth = clickWindowRect:getWidth();
	local clickWindowHeight = clickWindowRect:getHeight();

	print("clickWindowWidth "..clickWindowWidth);
	print("clickWindowHeight "..clickWindowHeight);

	local layoutWidth = self._view:GetWidth().offset;
	local layoutHeight = self._view:GetHeight().offset;

	print("layoutWidth "..layoutWidth);
	print("layoutHeight "..layoutHeight);
	
	local x = clickWindowRect.left - layoutWidth*0.5;
	local y = clickWindowRect.top - layoutHeight-10;
	
	print("clickWindowRect.left "..clickWindowRect.left);
	print("clickWindowRect.top "..clickWindowRect.top);
	
	print("x  "..x);
	print("y  "..y);
	
	local layoutSize = self._view:GetPixelSize();
	
	if y < 0 then
		
		x = clickWindowRect.right+10;
		y = clickWindowRect.top-15;
		
		if x + layoutSize.x > engine.rootUiSize.w then
			x = clickWindowRect.left - layoutWidth;
			y = clickWindowRect.top;
		end
	
	elseif x < 0 then
		
		x = 0;
	
	elseif x + layoutSize.x > engine.rootUiSize.w then
		
		x = engine.rootUiSize.w - layoutSize.x;
			
	end
	
	print(x);	
	print(y);
	
	self._view:SetXPosition(LORD.UDim(0, x));
	self._view:SetYPosition(LORD.UDim(0, y));
	
end

return crusadeTips;
