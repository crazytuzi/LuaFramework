
local instancejiesuanuiclass = class("instancejiesuanuiclass",layout)

function instancejiesuanuiclass:ctor( id )
	 instancejiesuanuiclass.super.ctor(self,id)	
	 self:addEvent({ name = global_event.INSTANCEJIESUAN_UI_SHOW, eventHandler = self.onshow})				
	 self:addEvent({ name = global_event.INSTANCEJIESUAN_UI_HIDE, eventHandler = self.onHide})
	 self:addEvent({ name = global_event.RECEIVE_BEST_BATTLE_RECORD, eventHandler = self.onReceiveRecord});
end	
function instancejiesuanuiclass:onReceiveRecord(event)
	if not self._show then
		return;
	end
	global.GlobalReplaySummaryInfo.name = global.GlobalReplaySummaryInfo.name or ""
	self.instancejiesuan_rec_name:SetText(global.GlobalReplaySummaryInfo.name)
	
	if(global.GlobalReplaySummaryInfo.name == "")then
		self.instancejiesuan_bestrec:SetVisible(false);
		self.instancejiesuan_rec_back:SetVisible(false);
	else
		local  isShowBestRepaly = global.isShowBestRepaly(battlePlayer.battleType)
		self.instancejiesuan_bestrec:SetVisible(isShowBestRepaly);
		self.instancejiesuan_rec_back:SetVisible(isShowBestRepaly);
	end

 
end	
function instancejiesuanuiclass:onshow(args)

	local actorManager = LORD.ActorManager:Instance();
	actorManager:SetSpeedUp(1);
		
	if self._show then
		return
	end
	
	dataManager.playerData:checkLevelup();
	
	global.triggerNewCardAndMagic();
		
	eventManager.dispatchEvent( {name = global_event.ENEMYINFORMATION_HIDE})
	eventManager.dispatchEvent( {name = global_event.CORPSDETAIL_HIDE})
	eventManager.dispatchEvent( {name = global_event.BATTLEHELP_HIDE})
	
	self:Show();	
	self.stage = args.stage
	self:Child("instancejiesuan-out"):subscribeEvent("ButtonClick", "onclickout");
	self.instancejiesuan_again = self:Child("instancejiesuan-again");
		
	self.instancejiesuan_again:subscribeEvent("ButtonClick", "onclickagain");
	self:Child("instancejiesuan-replay"):subscribeEvent("ButtonClick", "onclickReplay");
	
	self.instancejiesuan_rec_name = self:Child("instancejiesuan-rec-name")
	self.instancejiesuan_rec_name:SetText("")
	
	function instancejiesuanuiclass_onclickAskBestBattleRecord()
		global.askGlobalReplay(battlePlayer.battleType,battlePrepareScene.ReplaySummaryIndex) 
		sceneManager.battlePlayer():onQuitBattle(true);
		self:onHide(true);
	end
	self.instancejiesuan_bestrec = self:Child("instancejiesuan-bestrec")
	self.instancejiesuan_bestrec:subscribeEvent("ButtonClick", "instancejiesuanuiclass_onclickAskBestBattleRecord");

	self.instancejiesuan_rec_back = self:Child("instancejiesuan-rec-back")
  
	self.instancejiesuan_star = {};
	self.instancejiesuan_effect = {};
	
	self.instancejiesuan_starRoot = self:Child("instancejiesuan-star")
	self.instancejiesuan_star_black=  self:Child("instancejiesuan-star-black")
	for i =1,3 do
		self.instancejiesuan_star[i]  =   self:Child("instancejiesuan-star"..i)
		self.instancejiesuan_star[i]:SetVisible(false);
		
		self.instancejiesuan_effect[i] = self:Child("instancejiesuan-effect"..i);
		self.instancejiesuan_effect[i]:SetVisible(false);
	end	
	self.instancejiesuan_starRoot:SetVisible(false);
	self.instancejiesuan_star_black:SetVisible(false);
	
	local  isShowBestRepaly = global.isShowBestRepaly(battlePlayer.battleType)
	self.instancejiesuan_bestrec:SetVisible(isShowBestRepaly);
	self.instancejiesuan_rec_back:SetVisible(isShowBestRepaly);
	if(isShowBestRepaly)then
		global.askGlobalReplaySummary(battlePlayer.battleType,battlePrepareScene.ReplaySummaryIndex) 
	end
	

	--self.instancejiesuan_monnum =  self:Child("instancejiesuan-monnum")
	--self.instancejiesuan_woodnum =  self:Child("instancejiesuan-woodnum")
	--self.instancejiesuan_expnum =  self:Child("instancejiesuan-expnum")
	--self.instancejiesuan_diamond_num =  self:Child("instancejiesuan-diamond-num")
	self.instancejiesuan_itemkuang =  LORD.toScrollPane(self:Child("instancejiesuan-itemkuang"))
	self.instancejiesuan_itemkuang:init();
		
	--self.instancejiesuan_diamond_image =  self:Child("instancejiesuan-diamond-image")
	--self.instancejiesuan_expima =  self:Child("instancejiesuan-expima")
	--self.instancejiesuan_mon =  self:Child("instancejiesuan-mon")	
	--self.instancejiesuan_woodimage =  self:Child("instancejiesuan-woodimage")

	-- 金钱用数组表示
	self.instancejiesuan_money = {};
	self.instancejiesuan_money_icon = {};
	self.instancejiesuan_money_num = {};
	
	self.instancejiesuan_money[1] = self:Child("instancejiesuan-money");
	self.instancejiesuan_money_icon[1] = LORD.toStaticImage(self:Child("instancejiesuan-mon"));
	self.instancejiesuan_money_num[1] = self:Child("instancejiesuan-monnum");
	
	self.instancejiesuan_money[2] = self:Child("instancejiesuan-wood");
	self.instancejiesuan_money_icon[2] = LORD.toStaticImage(self:Child("instancejiesuan-woodimage"));
	self.instancejiesuan_money_num[2] = self:Child("instancejiesuan-woodnum");

	self.instancejiesuan_money[3] = self:Child("instancejiesuan-exp");
	self.instancejiesuan_money_icon[3] = LORD.toStaticImage(self:Child("instancejiesuan-expima"));
	self.instancejiesuan_money_num[3] = self:Child("instancejiesuan-expnum");
	
	self.instancejiesuan_money[4] = self:Child("instancejiesuan-diamond");
	self.instancejiesuan_money_icon[4] = LORD.toStaticImage(self:Child("instancejiesuan-diamond-image"));
	self.instancejiesuan_money_num[4] = self:Child("instancejiesuan-diamond-num");
			
	self.instancejiesuan_reward =  self:Child("instancejiesuan-reward")
	

	
 
	self.instancejiesuan_itemkuang:ClearAllItem()
	function onclickout()
		self:onHide();
	end
	
	function onclickagain()
		local again = false 
		
		if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
		   self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
			again = true
		end
	
		if(again == true)then
			--sceneManager.battlePlayer():AgainBattle()
			
			if(dataManager.playerData:getVitality() < self.stage:getVigourCost() )then
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.VIGOR,-1,-1});
				return
			end
						
			sceneManager.battlePlayer():onQuitBattle(true);
			if(instanceinfor_clickStageStat() == false)then
				eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, showStageInfo = false});
			end
		end
		
		self:onHide(true);
	end
	
	function onclickReplay()
 	
 		global.changeGameState(function()
			sceneManager.battlePlayer():loadAndRePlayBattleRecord()
			self:onHide(true);
			local sceneInfo = dataConfig.configs.sceneConfig[battlePrepareScene.sceneID];
			if(sceneInfo)then
				engine.playBackgroundMusic(sceneInfo.music, true);
			end
		end);
		
	end
	
	self.unit = {}
	self.unitProcess = {}
	for i =1 ,6 do
		self.unit[i] = self.unit[i] or {}
		local name = "instancejiesuan-bing"..i.."-image"			
		self.unit[i].icon = LORD.toStaticImage(self:Child(name))
		self.unit[i].icon:SetImage("")
		name = "instancejiesuan-bing"..i.."-bar-image"
		self.unitProcess[i] = self:Child(name)	
		

		name = "instancejiesuan-bing"..i
		self.unit[i].root = self:Child(name)	
		self.unit[i].root:SetVisible(false);
		
		self.unit[i].star =  self.unit[i].star  or {}
		for k = 1,5 do
			local sname = "instancejiesuan-bing"..i.."-star"..k	
			self.unit[i].star[k] = LORD.toStaticImage(self:Child(sname))
			self.unit[i].star[k]:SetVisible(false);
		end	
	end
	
	--self.instancejiesuan_expima:SetVisible(false)
	--self.instancejiesuan_expnum:SetVisible(false)
	self.instancejiesuan_again:SetVisible(false)

	--self:updateMoney(0, 0, 0);
	self:updateBattleStateInfo();
 
	self.battleType = battlePlayer.battleType 
	
	local exp = 0;


	function jiesuanFlyStar(window)

		function jiesuanFlyEndFunc()
			uiaction.shake(self._view);
			LORD.SoundSystem:Instance():playEffect("star.mp3");
		end
	
		if window then
			local action = LORD.GUIAction:new();

			action:addKeyFrame(LORD.Vector3(-100, 100, 0), LORD.Vector3(0, 0, 720), LORD.Vector3(5, 5, 0), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
			window:playAction(action);
			
			window:removeEvent("UIActionEnd");
			window:subscribeEvent("UIActionEnd", "jiesuanFlyEndFunc");

		end
	end
		
	if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
	   self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
		self.instancejiesuan_starRoot:SetVisible( self.stage:isMain());
		self.instancejiesuan_star_black:SetVisible(self.stage:isMain());
		local star = self.stage:getVisStarNum()
		
		self.flyIndex = 1;
		self.effectIndex = 1;
		
		for i = 1, 3 do	
			--self.instancejiesuan_star[i]:SetVisible(i <= star) 
			
			self.instancejiesuan_star[i]:SetVisible(false);
			
			if i <= star then
				scheduler.performWithDelayGlobal(function(dt)
					 
					if self.instancejiesuan_star and self.instancejiesuan_star[self.flyIndex] then
						self.instancejiesuan_star[self.flyIndex]:SetVisible(true);
						jiesuanFlyStar(self.instancejiesuan_star[self.flyIndex]);
	
						scheduler.performWithDelayGlobal(function() 
							
							if self.instancejiesuan_effect and self.instancejiesuan_effect[self.effectIndex] then 
								self.instancejiesuan_effect[self.effectIndex]:SetVisible(true);
							end				
							print("instancejiesuan_effect "..self.effectIndex);
							self.effectIndex = self.effectIndex + 1;
							
						end, 0.2);

					end
					self.flyIndex = self.flyIndex  or 1;
					self.flyIndex = self.flyIndex + 1;
			 
				end, i*0.1);
			else
				
			end
		end
		
		self.instancejiesuan_again:SetVisible(self.stage:isMain());
		
		-- 设置经验
		local sexp,fexp = self.stage:getExp();
		if battlePlayer.win then
			exp = sexp;
		else
			exp = fexp;
		end
		--触发新手引导事件
		if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE then
				--local adID = self.stage:getId()
				local adID = self.stage:getAdventureID()   
				--local score = star
				local score = self.stage:getScore()
				eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_JIESUAN , arg1 = adID, arg2 = score}); 
		end
		--
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_EVENT then	-- 每日活动
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE then	-- 在线PVP
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE then	-- 离线PVP
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then	-- 领地事件
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then	-- 急速挑战
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
				self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
				self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then	-- 副本挑战
	--触发新手引导事件
	local sID = battlePrepareScene.copyID;
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_JIESUAN_CHALLENGE , arg1 = sID });
	
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then	-- 伤害输出挑战
	end
	
	self:updateRewardInfo(exp);
	
	
	
	--
	local sound = "battle_lose.mp3"
	
	if battlePlayer.win then
		sound = "battle_win.mp3"
	else
		if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then	-- 伤害输出挑战
			sound = "battle_win.mp3"
		end
	end
	local  audioEngine = LORD.SoundSystem:Instance()
	audioEngine:playBackgroundMusic(sound, false)
	
end

function instancejiesuanuiclass:updateFailure()
	
	self.instancejiesuan_monnum:SetText("")
	self.instancejiesuan_woodnum:SetText("")
	self.instancejiesuan_diamond_num:SetText("") 
	self.instancejiesuan_diamond_image:SetVisible(false)
	self.instancejiesuan_mon:SetVisible(false)
	self.instancejiesuan_woodimage:SetVisible(false)
end

function instancejiesuanuiclass:updateMoney(gold, wood, diamond)
			
	self.instancejiesuan_monnum:SetText(gold)
	self.instancejiesuan_mon:SetVisible(gold > 0 )
	self.instancejiesuan_monnum:SetVisible(gold > 0 )

	self.instancejiesuan_woodnum:SetText(wood)
	self.instancejiesuan_woodnum:SetVisible(wood > 0 )
	self.instancejiesuan_woodimage:SetVisible(wood > 0 )
	
	self.instancejiesuan_diamond_num:SetText(diamond);
	self.instancejiesuan_diamond_num:SetVisible(diamond > 0 )
	self.instancejiesuan_diamond_image:SetVisible(diamond > 0 )
end

-- 由于经验是额外的需要传入
function instancejiesuanuiclass:updateRewardInfo(exp)
	self.instancejiesuan_itemkuang:ClearAllItem()
	for k,v in ipairs(self.instancejiesuan_money_icon) do
		v:SetImage("");
	end
	
	for k,v in ipairs(self.instancejiesuan_money_num) do
		v:SetText("");
	end
	
	local moneyRewardIndex = 1;
	local itemRewardIndex = 1;
	
	if exp > 0 then
		self.instancejiesuan_money_icon[moneyRewardIndex]:SetImage(enum.EXP_ICON_STRING);
		self.instancejiesuan_money_num[moneyRewardIndex]:SetText(exp);
		moneyRewardIndex = moneyRewardIndex + 1;
	end
	
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 5)
	
	if sceneManager.battlePlayer().mergedRewardList then	
	
		for k,v in ipairs(sceneManager.battlePlayer().mergedRewardList) do
			local rewardInfo = dataManager.playerData:getRewardInfo(v.type, v.id, v.count);
			if rewardInfo then
				if v.type == enum.REWARD_TYPE.REWARD_TYPE_MONEY and self.instancejiesuan_money_icon[moneyRewardIndex] then
					self.instancejiesuan_money_icon[moneyRewardIndex]:SetImage(rewardInfo.icon);
					self.instancejiesuan_money_num[moneyRewardIndex]:SetText(rewardInfo.count);
					moneyRewardIndex = moneyRewardIndex + 1;
				else
					-- 除了钱其他的奖励
					local itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("instancejiesuan_item"..k, "instanceawarditem.dlg");
					local itemStar  = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instancejiesuan_item"..k.."_instanceawarditem-equity"));										
					local itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instancejiesuan_item"..k.."_instanceawarditem-item-image"));	
					local itemName= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instancejiesuan_item"..k.."_instanceawarditem-num"));
					
					local instanceawarditem_rare= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instancejiesuan_item"..k.."_instanceawarditem-rare"));
					local instanceawarditem_item = LORD.toStaticImage(self:Child("instancejiesuan_item"..k.."_instanceawarditem-item"));
					instanceawarditem_rare:SetVisible(false);
					
					instanceawarditem_item:SetImage(rewardInfo.backImage);
					
					local uistars = {};
					for starIndex=1, 5 do
						uistars[starIndex] = self:Child("instancejiesuan_item"..k.."_instanceawarditem-star"..starIndex);
						uistars[starIndex]:SetVisible(starIndex <= rewardInfo.showstar);
					end
																			
					--local item_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instancejiesuan_item"..k.."_item-chose"));	
					--local item_stLevel = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instancejiesuan_item"..k.."_item-stLevel"));	
					--itemIcon.item_chose = item_chose
					--itemIcon.item_chose:SetVisible(false)			
					--item_stLevel:SetVisible(false)
					
					itemWind:SetPosition(LORD.UVector2(xpos, ypos));
					
					-- 绑定tips事件
					itemWind:SetUserData(v.id);
					
					if v.type == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
						itemWind:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
					end					
					
					
					--itemWind:SetProperty("ImageName",itemManager.getBackImage(rewardInfo.isDebris))
					--item_chose:SetProperty("ImageName",itemManager.getSelectImage(rewardInfo.isDebris) )				 
				
					global.onItemTipsShow(itemWind, v.type, "top");
					global.onItemTipsHide(itemWind);
					--global_scalewnd(itemWind,0.7)
					 		
					self.instancejiesuan_itemkuang:additem(itemWind);
					local width = itemWind:GetWidth()
					xpos = xpos + width	+ LORD.UDim(0, 0)		
					if itemIcon then
						itemIcon:SetImage(rewardInfo.icon)
						global.setMaskIcon(itemIcon, rewardInfo.maskicon);			
					end
									
					if itemName then
						if(rewardInfo.count > 1)then
							itemName:SetText(rewardInfo.count)
						else
							itemName:SetText("")
						end
					end		
	
					itemStar:SetImage(itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris));
			
					itemRewardIndex = itemRewardIndex + 1;
				end
			end
	
		end
	
	end
	
end

function instancejiesuanuiclass:updateBattleStateInfo()
	
	for i =1 ,6 do
			self.unit[i].icon:SetImage("")
			self.unitProcess[i]:SetProperty("Progress",0)
			self.unitProcess[i]:SetProperty("ProgressImage", "set:common.xml image:jindu2" )
	end
	if(sceneManager.battlePlayer().m_AllCrops == nil)then
		return
	end
		
	local index = 0
	for i,v in pairs ( sceneManager.battlePlayer().m_AllCrops)do
		if(v:isFriendlyForces() and not v:isCharmed() and  not v:isSummonUnit())then
			index = index + 1 
			self.unit[index].icon:SetImage(v.m_Icon)	
			local p = v.m_CropsNum  / v.m_TotalCropsNum
			self.unitProcess[index]:SetProperty("Progress",p )
			if( p < 1)then
				self.unitProcess[index]:SetProperty("ProgressImage", "set:common.xml image:jindu1" )
			end
			--[[
			local slevel = v:getStarLevel() or 0		
			for k = 1,5 do
				self.unit[index].star[k]:SetVisible( k <= slevel);
			end		
			]]--		
			self.unit[index].root:SetVisible(true);
			
		end
	end
	
end

function instancejiesuanuiclass:onHide(notquit)
		
	self:Close();
	
	self.unit = nil
	self.unitProcess = nil
	
	self.instancejiesuan_star = nil;
	self.instancejiesuan_effect = nil;
	
	if notquit ~= true then
		sceneManager.battlePlayer():QuitBattle();
	end
end

return instancejiesuanuiclass