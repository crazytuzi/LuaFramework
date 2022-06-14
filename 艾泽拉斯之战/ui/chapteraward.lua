local chapteraward = class( "chapteraward", layout );

global_event.CHAPTERAWARD_SHOW = "CHAPTERAWARD_SHOW";
global_event.CHAPTERAWARD_HIDE = "CHAPTERAWARD_HIDE";
global_event.CHAPTERAWARD_UPDATE = "CHAPTERAWARD_UPDATE";
function chapteraward:ctor( id )
	chapteraward.super.ctor( self, id );
	self:addEvent({ name = global_event.CHAPTERAWARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CHAPTERAWARD_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.CHAPTERAWARD_UPDATE, eventHandler = self.onUpdate});
end

function chapteraward:onShow(event)
	self.Chapter = event.chapter
	self.curSelStafeMode = event.curSelStafeMode
	
	
	 
	if self._show then
		return;
	end

	self:Show();
	
	self.chapteraward_box_close = self:Child( "chapteraward-box-close" );
	self.chapteraward_box_open = self:Child( "chapteraward-box-open" );

	
	
	self.chapteraward_close = self:Child( "chapteraward-close" );
	function on_chapteraward_close_click()
		self:onHide()
	end	
	self.chapteraward_close:subscribeEvent("ButtonClick", "on_chapteraward_close_click");	
	
	self.chapteraward_money = {}
	self.chapteraward_money_num = {}
	
	for i = 1 ,4 do
		
		self.chapteraward_money[i] = LORD.toStaticImage(self:Child( "chapteraward-money1" ));
		self.chapteraward_money_num[i] = self:Child( "chapteraward-money"..i.."-num" );
		
	end
	self.chapteraward_item_image_back = {}
	self.chapteraward_item_image = {}
	self.chapteraward_item_num = {}
	self.chapteraward_item = {}
  	for i = 1 ,4 do	
		self.chapteraward_item_image[i] = LORD.toStaticImage(self:Child( "chapteraward-item"..i.."-image" ));
		self.chapteraward_item_num[i] = self:Child( "chapteraward-item"..i.."-num" );	
		
		self.chapteraward_item[i] =LORD.toStaticImage( self:Child( "chapteraward-item"..i ));	
		self.chapteraward_item_image_back[i] = LORD.toStaticImage(self:Child( "chapteraward-item"..i.."-back" ));
 					
	end		
	self.chapteraward_button = self:Child( "chapteraward-button" );
	self.chapteraward_button1 = self:Child( "chapteraward-button1" );
 
	self.chapteraward_star_num = self:Child( "chapteraward-star-num" );
	
	function on_chapteraward_button_click()

		if(global.tipBagFull())then
			return
		end		
		
		local rewardType = nil
		if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL )then
			rewardType = enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_CHAPTER_NORMAL
		elseif(self.curSelStafeMode == enum.Adventure_TYPE.ELITE )then
			rewardType	= enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_CHAPTER_ELITE
		end
		
		local zones = dataManager.instanceZonesData	
		local curChapter = zones:getAllChapter()[self.Chapter]			
		sendSystemReward(rewardType, curChapter:getId())	
		self:onHide()	
	end
	
	self.chapteraward_button:subscribeEvent("ButtonClick", "on_chapteraward_button_click");	 
 
	self:update()
 
end

function chapteraward:update()
	local zones = dataManager.instanceZonesData	
	local curChapter = zones:getAllChapter()[self.Chapter]	
	local num ,all = curChapter:getPerfectProcess(self.curSelStafeMode)
	local pro =  num.."/"..all
	self.chapteraward_star_num:SetText(pro)	
	
	local v = curChapter:haveAward(self.curSelStafeMode)
	self.chapteraward_button:SetEnabled(num >= all  )	---and (not curChapter:haveAward(self.curSelStafeMode)) 	
	
	self.chapteraward_button:SetVisible(not v)
	self.chapteraward_button1:SetVisible(  v)
	
	
	self.chapteraward_box_close:SetVisible(not v)
	self.chapteraward_box_open:SetVisible( v)
	
	
	
	local reward = curChapter:getChapterReward(self.curSelStafeMode)
		
 
	local t = { enum.MONEY_TYPE.MONEY_TYPE_GOLD, enum.MONEY_TYPE.MONEY_TYPE_LUMBER,enum.MONEY_TYPE.MONEY_TYPE_DIAMOND,enum.MONEY_TYPE.MONEY_TYPE_VIGOR} 
	for i = 1 ,4 do	
		local num = curChapter:getRewardMoney(t[i],self.curSelStafeMode)
		--self.chapteraward_money[i]:SetVisible(num > 0)
		self.chapteraward_money_num[i]:SetText( num )
	end
 
  	for i = 1 ,4 do	
		self.chapteraward_item_image[i]:SetImage("")
		self.chapteraward_item_num[i]:SetText("")	
		self.chapteraward_item_image_back[i]:SetVisible(false)
		
	end		
	
	
	local nums = #reward
	if(nums > 4)then
		nums = 4
	end
	local itemIndex = 0
	for z = 1,nums do	
		local item = reward[i]			
		if (item  and  item._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY )then		
					 itemIndex = itemIndex + 1
					 self.chapteraward_item_image[itemIndex]:SetImage(item._icon)	
					 self.chapteraward_item_num[itemIndex]:SetText(item._num)
					 global.setMaskIcon(self.chapteraward_item_image[itemIndex], item._maskicon);	
			-- °ó¶¨tipsÊÂ¼þ
			self.chapteraward_item_image[itemIndex]:SetUserData(item._id);

			if item._type == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
				self.chapteraward_item_image[itemIndex]:SetUserData(dataManager.kingMagic:mergeIDLevel(item._id, item._star));
			 	
			end
			self.chapteraward_item_image_back[itemIndex]:SetVisible(true)								 
			global.onItemTipsShow(self.chapteraward_item_image[itemIndex], item._type, "top");
			global.onItemTipsHide(self.chapteraward_item_image[itemIndex]);
			
			self.chapteraward_item_image_back[itemIndex]:SetImage(itemManager.getBackImage(item._isDebris))
			self.chapteraward_item[itemIndex]:SetImage(itemManager.getImageWithStar(item._star, item._isDebris));	
							 								
		end		
	end					
	
end

function chapteraward:onHide(event)
	self:Close();
end

function chapteraward:onUpdate(event)
	
	if(event.chapter)then	
		self.Chapter = event.chapter
	end
	if(event.curSelStafeMode)then	
		self.curSelStafeMode = event.curSelStafeMode
	end
 
	if not self._show then
		return;
	end
	self:update()
end


return chapteraward;
