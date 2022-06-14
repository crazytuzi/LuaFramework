
local GUIDE_PROCESS_LIMIT = 6

function Guide.checkMagicBarParamIs1()
	return Guide.curGuideEvent.arg1 == 1	
end	

function Guide.checkMagicBarParamIs2()
	return Guide.curGuideEvent.arg1 == 2	
end	

function Guide.checkMagicBarParamIs3()
	return Guide.curGuideEvent.arg1 == 3	
end	

function Guide.checkSkillBagParamIs3()
	return Guide.curGuideEvent.arg1 == 3	
end	

function Guide.checkGridIs51()
	--return Guide.curGuideEvent.arg1 == 5	and  Guide.curGuideEvent.arg2 == 1	
	--临时更改
	return true
end	

function Guide.checkGridIs61()
	--return Guide.curGuideEvent.arg1 == 6	and  Guide.curGuideEvent.arg2 == 1	
	--临时更改
	return true
end	

function Guide.checkGridIs61SP()
	return Guide.curGuideEvent.arg1 == 6	and  Guide.curGuideEvent.arg2 == 1	
end	

function Guide.checkGridIs00SP()
	return Guide.curGuideEvent.arg1 == 0	and  Guide.curGuideEvent.arg2 == 0	
end	

function Guide.checkAdventureNormalProcessEL0()
	return dataManager.playerData:getAdventureNormalProcess() 	== 0 
end	

function Guide.checkAdventureNormalProcessEL1()
	return dataManager.playerData:getAdventureNormalProcess() 	== 1
end	

function Guide.checkAdventureNormalProcessThan0()
	return dataManager.playerData:getAdventureNormalProcess() 	> 0 
end	
 
function Guide.checkAdventureNormalProcessET2()
	return dataManager.playerData:getAdventureNormalProcess() 	>= 2 
end	

function Guide.checkAdventureNormalProcessET2SP() --换装指引
	local process = dataManager.playerData:getAdventureNormalProcess()
  local stage =  dataManager.instanceZonesData:getStageWithAdventureID( 2,enum.Adventure_TYPE.NORMAL )
	local star = stage:getVisStarNum()
	print("BILIBILI")
	print(process)
	print(star)
	if process >= 2 and star ==3 then
		return true
	else
		return false
	end

	
end	

function Guide.checkAdventureNormalProcessThan2()
	return dataManager.playerData:getAdventureNormalProcess() 	> 2 
end	

function Guide.playerShip3HasNoActor( )--【废弃】
	 	local cardType =	PLAN_CONFIG.getShipCardType(3)
		if(cardType)then
			return  (cardType > 0) == false
		else
			return  true
		end		
end

--[[
function Guide.playerShipHasNoActor( )	--【条件】【废弃】可以上阵新军团
	 	local count = 0
		for i=1,6 do
			if(PLAN_CONFIG.getShipCardType(i)>0)then
				count = count + 1
			end
		end
		if count<cardData.getOwnedCardCount() and count<6 then
			return  true
		else
			return  false
		end
end
]]--

function Guide.getShipAmount( )
	local shipNumLimit = dataConfig.configs.ConfigConfig[0].shipNumLevelLimit;
	local progressLimit
	local count = 0
	for i = 1, 6 do
		progressLimit = shipNumLimit[i];	
		if dataManager.playerData:getAdventureNormalProcess() >= progressLimit then
			count = count + 1
		end
	end
	return count
end

function Guide.playerShipHasNoActor( )	--【条件】【最新】可以上阵新军团
	 	local count = 0
		for i=1,6 do
			if(PLAN_CONFIG.getShipCardType(i)>0)then
				count = count + 1
			end
		end
		if count<cardData.getOwnedCardCount() and count<Guide.getShipAmount() then
			return  true
		else
			return  false
		end
end

function Guide.playerShipAllHasActor( )	--【条件】已上阵6个军团
	 	local count = 0
		for i=1,6 do
			if(PLAN_CONFIG.getShipCardType(i)>0)then
				count = count + 1
			end
		end
		if count>5 then
			return  true
		else
			return  false
		end
end

function Guide.getCurSELShipHasNoActor() --【条件】点击的是空船
	local cardType =	PLAN_CONFIG.getShipCardType(Guide.curGuideEvent.arg1)
	if( cardType and cardType<=0)then
		return true
	else
		return false
	end
end

function Guide.getIfHaveCanGainedReward() --【条件】判断是否有任务或奖励可领取
	if dataManager.playerData:isHaveCanGainedReward() and Guide.checkPlayerLevelTE5()then   --为避免4级时因登陆奖励可领而出现指引，限制了5级开放
		return true
	else
		return false
	end
end

function Guide.checkChallengeCondition() --副本挑战指引条件
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	local process = dataManager.playerData:getAdventureNormalProcess() --检查进度是否开启了5条船
	local order = 12003
	if(card:getStar() > 0 and process >= 7 and Guide.getServerDataWithOrder(order) == true)then
		return true
	else

		return false
	end
end

function Guide.checkMainControlGuide() --【条件】检查主城是否有指引
	local index
	local arr = {4003,5001,7003,8003,9001,10003,11003,13003,14003,15003,16003}
	if Guide.getIfHaveCanGainedReward() then
		return true
	end
	if Guide.checkChallengeCondition() then
			return true
	end
	for _,i in ipairs(arr) do
		index = Guide.findIdWithOrder(i)
		if(Guide.serverData[index] ==true)then
			return true
		end
	end
	return false
end	

function Guide.getEquipedMagicNum()
	local num = 0
	for i=1, 7 do
		local magicID = getEquipedMagicData(i).id;
		if magicID > 0 then
			 num = num + 1
		end
	end
	return num
end	

function Guide.getEquipedMagicWithPos(pos)
		local magicID = getEquipedMagicData(pos).id;
		return   magicID > 0  
 
end	
	

function Guide.checkAdventureNormalProcessET5AndEquipMagicLE3()
	 local p = dataManager.playerData:getAdventureNormalProcess() >= 5  
	 local n =  Guide.getEquipedMagicNum() <= 3
	 return p and n
end	

function Guide.checkAdventureNormalProcessET5AndEquipMagicThan3()
	  local p = dataManager.playerData:getAdventureNormalProcess() >= 5  
	  local n =  Guide.getEquipedMagicNum() > 3
	  return p and n
end	


function Guide.checkEquipMagicPos3()
	return Guide.getEquipedMagicWithPos(3)
end	

function Guide.checkMagicBarHasNoMagic( )	--【条件】可以装备新魔法
	 	local count = 0
		for i=1,6 do			
			if(Guide.getEquipedMagicWithPos(i))then
				count = count + 1
			end
		end
		--print(count)
		--print(dataManager.kingMagic:getMagicCount())
		if count<dataManager.kingMagic:getMagicCount()-1 and count<6 then
			return  true
		else
			return  false
		end
end

function Guide.checkMagicBarAllHasMagic( )	--【条件】已装备所有魔法
	 	local count = 0
		for i=1,6 do			
			if(Guide.getEquipedMagicWithPos(i))then
				count = count + 1
			end
		end
		if count>5 then
			return  true
		else
			return  false
		end
end

function Guide.playerNoActorNoMagic() --【条件】无法触发换兵换魔法指引
	return Guide.checkMagicBarHasNoMagic() == false and Guide.playerShipHasNoActor() == false 
end

function Guide.checkStageId()         --【条件】敌军信息指引，判断关卡
	local id = Guide.curGuideEvent.arg1
	--return id == 452
	return id == 5 --检查的其实是冒险ID，而不是StageId
end	

function Guide.checkStageId402()         --【条件】副本挑战指引，判断关卡
	local id = Guide.curGuideEvent.arg1
	if Guide.checkChallengeCondition() and id == 402 then --StageId
		return true
	else
		return false
	end
end	

function Guide.checkUnitId()         --【条件】敌军信息指引，判断兵种
	local id = Guide.curGuideEvent.arg1
	return id == 27
end	

function Guide.checkHpChangeNum()         --【条件】检查血量变化值
	local num = Guide.curGuideEvent.arg1
	--return num == -302834
	return num == -996000
end	

function Guide.checkOnTouchMoveShip()         --【条件】检查拖拽的是哪条船
	if Guide.curGuideEvent.arg1 == 0 and Guide.curGuideEvent.arg2 == 0 and Guide.curGuideEvent.arg3 == 2 then
		return true
	else
		return false
	end
end

function Guide.checkCard39()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	return card:getStar() > 0
end	

function Guide.checkPlayerLevel(l)
	local level = dataManager.playerData:getLevel()
	return level >= l
end	

function Guide.checkPlayerLevelTE3()
	return Guide.checkPlayerLevel(3)
end	

function Guide.checkPlayerLevelTE4()
	return Guide.checkPlayerLevel(4)
end	

function Guide.checkPlayerLevelTE5()
	return Guide.checkPlayerLevel(5)
end	

function Guide.checkPlayerLevelTE6()
	return Guide.checkPlayerLevel(6)
end	

function Guide.checkPlayerLevelTE7()
		return Guide.checkPlayerLevel(7)
end	

function Guide.checkPlayerLevelTE8()
		return Guide.checkPlayerLevel(8)
end	


function Guide.checkPlayerLevelTE9()
	return Guide.checkPlayerLevel(9)
end	

function Guide.checkPlayerLevelTE10()
		return Guide.checkPlayerLevel(10)
end	


function Guide.checkPlayerLevelTE11()
		return Guide.checkPlayerLevel(11)
end	

function Guide.checkPlayerLevelTE12()
		return Guide.checkPlayerLevel(12)
end	

function Guide.checkPlayerLevelTE15()
		return Guide.checkPlayerLevel(15)
end	

function Guide.checkPlayerLevelTE16()
		return Guide.checkPlayerLevel(16)
end	

function Guide.checkPlayerLevelTE17()
		return Guide.checkPlayerLevel(17)
end	

function Guide.checkPlayerLevelTE18()
		return Guide.checkPlayerLevel(18)
end	

function Guide.checkPlayerLevelTE25()
		return Guide.checkPlayerLevel(25)
end	

function Guide.checkHasNoticeGuideTip()
	local name = "noticeGuideTip"
	local ui = engine.GetGUIWindowWithName(name)
	if ui and ui:IsVisible() then
		return true
	else
		return false
	end
end


function Guide.enterStageInstance()
		-- sceneManager.battlePlayer():QuitBattle()
end

function Guide._addMagicBarTip(clickImage,id,angle) --【操作】添加指引箭头
	angle = angle or 0
	if(not clickImage)then
		return 
	end
		local ui = getFreeGuideUi(id)
		ui:SetVisible(true)
		local rect = clickImage:GetUnclippedOuterRect();
		--[[
		print("-----addMagicBar1Tip "..rect.left)
		print(rect.top)
		print(rect.right)
		print(rect.bottom)
		]]--
	    --ui:SetArea(  LORD.UDim(0,rect.left), LORD.UDim(0,rect.top - (rect.bottom - rect.top)*0.5), LORD.UDim(0,rect.right - rect.left ), LORD.UDim(0,rect.bottom - rect.top))
		if(ui:GetParent())then
			ui:GetParent():RemoveChildWindow(ui)
		end
		clickImage:AddChildWindow(ui)
		ui:SetLevel(clickImage:GetLevel())
		local u =  (clickImage:GetHeight() * LORD.UDim(0, 0.5))  +  LORD.UDim(0, -100)
		ui:SetProperty("HorizontalAlignment","Centre")
		ui:SetPosition(LORD.UVector2(LORD.UDim(0, 0),  u ));
		ui:SetSize(LORD.UVector2(LORD.UDim(0, 100), LORD.UDim(0, 100)));
		ui:SetProperty("EffectRotate",angle)
end	

function Guide.showMmButton()  --显示指引小助手的按钮
	local name = "guidedialogue-button"
	local ui = engine.GetGUIWindowWithName(name)
	ui:SetProperty("Visible",1)
end	

function Guide.hideMmButton()  --隐藏指引小助手的按钮
	local name = "guidedialogue-button"
	local ui = engine.GetGUIWindowWithName(name)
	ui:SetProperty("Visible",0)
end	

function Guide.hideMmActor() --引导小助手模型常规模式
		Guide.hideMmButton()
		
		name = "guidedialogue-chacter"
		ui = engine.GetGUIWindowWithName(name)
		ui:SetProperty("Visible",1)

		name = "guidedialogue-actor"
		ui = engine.GetGUIWindowWithName(name)
		ui:SetProperty("Visible",0)
end

function Guide.showMmActor(actor) --引导小助手模型展示模式
		Guide.showMmButton()
		
		name = "guidedialogue-chacter"
		ui = engine.GetGUIWindowWithName(name)
		ui:SetProperty("Visible",0)

		name = "guidedialogue-actor"
		ui = engine.GetGUIWindowWithName(name)
		ui:SetProperty("Visible",1)
		ui:SetProperty("ActorName",actor)
end

function Guide.addBigBoMm(str,pos_x,pos_y,flag,parent,level,indexSp,func) --【操作】添加指引小助手，flag为0时相对于屏幕而不是本身触发器的箭头位置
	flag = flag or 1	--为1时为相对位置，为0时为绝对位置
	parent = parent or 0 --为1时以指引控件为parent，flag失效
	local level_define = 90 --默认层级
	level = level or level_define
	indexSp = indexSp or 0 --同一order指引既有界面指引又有场景指引时使用该值做出区别

	--添加引导小助手	
	local ui = getFreeGuideUi(Guide.curGuideEvent_data.order+indexSp)
	local rect = ui:GetUnclippedOuterRect();
 	local pos = LORD.UVector2(LORD.UDim(0, rect.left*flag+pos_x), LORD.UDim(0, rect.top*flag+pos_y))
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_SHOW, text = str,pos = pos ,func = func})
	--更改层级
	local layout = layoutManager.getUI("guidedialogue")
	if(ui:GetParent() and parent == 1 )then	
		if(layout._view:GetParent())then
			layout._view:GetParent():RemoveChildWindow(layout._view)
		end
		ui:GetParent():AddChildWindow(layout._view)
		local _pos = ui:GetPosition();
		pos = LORD.UVector2( _pos.x + LORD.UDim(0,pos_x), _pos.y + LORD.UDim(0, pos_y))
		layout._view:SetPosition(pos)	
	end
	if(level ~= level_define )then	
		layout._view:SetLevel(level)
	end
	Guide.hideMmActor()
end

function Guide.changeMmImage(imageType)  --改变指引小助手的立绘
	local name = "guidedialogue-chacter"
	local ui = engine.GetGUIWindowWithName(name)
	local imageName = ""
	if imageType == 1 then
		imageName = "set:guiderole1.xml image:guiderole1"	--卖萌，一般用于以波浪号结尾的句子~
	elseif imageType == 2 then
		imageName = "set:guiderole2.xml image:guiderole2"	--陈述，一般用于以句号结尾的句子。
	else
		imageName = "set:guiderole3.xml image:guiderole3"	--燃，一般用于以叹号结尾的句子!
	end
	ui:SetProperty("ImageName",imageName)
end	

function Guide.addMagicBar1Tip()
		local name = "battle-skillitem1"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		Guide.addBigBoMm("战斗开始时可以立刻施放一个魔法，来试试吧！",80,-200,1,0,10)
		Guide.changeMmImage(3)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 178 ,y= 530 ,w = 104 ,h = 104 }  }) 
end

function Guide.addMagicBar2Tip()
		local name = "battle-skillitem2"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		Guide.addBigBoMm("巫妖王已经很虚弱了，这次使用斩杀魔法吧。",80,-200,1,0,10)
		Guide.changeMmImage(2)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 315 ,y= 530 ,w = 104 ,h = 104 }  })
end

function Guide._addMagicBarTipWithRect(rect,id)
		local ui = getFreeGuideUi(id)
		addGuideUiInScene(ui)
		ui:SetVisible(true)
		ui:SetProperty("HorizontalAlignment","left")
	    ui:SetArea(  LORD.UDim(0,rect.left), LORD.UDim(0,rect.top - (rect.bottom - rect.top)*0.5), LORD.UDim(0,rect.right - rect.left ), LORD.UDim(0,rect.bottom - rect.top))
		ui:SetLevel(95)
		ui:SetProperty("EffectRotate",0)
		return ui:GetName()
end	


function Guide.__addGridTip(worldPos)
		local initPos = LORD.Vector2(0, 0);
		initPos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);
 
		local x = initPos.x
		local y = initPos.y
		local rect = {}
		rect.left = x - 50
		rect.right = rect.left + 100
		rect.top = y - 80
		rect.bottom = rect.top + 100
		return  Guide._addMagicBarTipWithRect(rect,Guide.curGuideEvent_data.order)
end

function Guide.addGridTip1()
		local worldPos = battlePrepareScene.grid:getWorldPostion(4, 1);
		Guide.addBigBoMm("选择巫妖王所在的高亮格子，施放魔法箭吧！",180,300,0,0,0);
		Guide.changeMmImage(3);
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 655 ,y= 240 ,w = 300 ,h = 200 }  }) 
		return Guide.__addGridTip(worldPos);
end

function Guide.addGridTip2()
		local worldPos = battlePrepareScene.grid:getWorldPostion(3, 1);
		Guide.addBigBoMm("选择巫妖王施放，就是现在！",150,110,0,0,0);
		Guide.changeMmImage(3);
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 480 ,y= 240 ,w = 300 ,h = 200 }  }) 
		return Guide.__addGridTip(worldPos);
end

--第一关选择魔法箭指引
function Guide.addMagicBar2TipSP()
		local name = "battle-skillitem2"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		Guide.addBigBoMm("魔法箭是单体伤害魔法，再来试试吧。",80,-200,1,0,10) 	
		Guide.changeMmImage(2)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 315 ,y= 530 ,w = 104 ,h = 104 }  }) 
end
--第一关魔法箭选择目标
function Guide.addGridTip1SP()
		local worldPos = battlePrepareScene.grid:getWorldPostion(6, 1);
		Guide.addBigBoMm("可选的目标格子会以高亮状态显示哟~",450,200,0,0,0);
		Guide.changeMmImage(1);
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1060 ,y= 320 ,w = 180 ,h = 80 }  }) 
		return Guide.__addGridTip(worldPos);
end
--第一关施放魔法后清除遮罩
function Guide.clearModaltip()
		eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE}) 
end

function Guide.addGridTipTuFu()  --【操作】敌人信息指引
		local worldPos = battlePrepareScene.grid:getWorldPostion(3, 2);
		Guide.addBigBoMm("掌握敌人的属性和技能，非常重要哦~",400,500,0,0,0);
		Guide.changeMmImage(1);
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1000 ,y= 460 ,w = 180 ,h = 80 }  }) 
		return Guide.__addGridTip(worldPos)
end

function Guide.addStageEntryTip() --【操作】推图入口指引
		local v = enum.HOMELAND_BUILD_TYPE.INSTANCE
	  local clickImage = homeland.buildPanels.root[v]
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		--强制引导
		local process = dataManager.playerData:getAdventureNormalProcess()
		if process<=GUIDE_PROCESS_LIMIT then
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 360 ,y= 380 ,w = 160 ,h = 150 }  }) 
		end
end

function Guide.hasUIVisible(id)
	local wname = "guideRootWindow"..id
	local v = engine.GetGUIWindowWithName(wname)
	
	function _isVisible(v)
		local r = v:IsVisible()
		if(v:GetParent())then
			return r and _isVisible(v:GetParent())
		end	
		return r
	end	
	if(v)then
		return _isVisible(v)
	end
	return false
end	

function Guide.instanceinforIsVisible()
	local name = "instanceinfor-container"
	local ui = engine.GetGUIWindowWithName(name)
	return ui and ui:IsVisible();
	
end	

function Guide.hasUI6102Visible()
	local id = 6102
	return Guide.hasUIVisible(id)
end	

function Guide.hasUI99002Visible()
	local id = 99002
	return Guide.hasUIVisible(id)
end	

function Guide.hasUI99003Visible()
	local id = 99003
	return Guide.hasUIVisible(id)
end	

function Guide.hasUI2001Visible()
	local id = 2001
	return Guide.hasUIVisible(id)
end	

function Guide.hasUI3004Visible()
	local id = 3004
	return Guide.hasUIVisible(id)
end	

function Guide.addStageInfoBattleTIP()
	local name = "instanceinfor-event"
	local ui = engine.GetGUIWindowWithName(name)
	local clickImage
	if ui and ui:IsVisible() then
		clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
	else
		name = "instanceinfor-start"
		clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)

		local process = dataManager.playerData:getAdventureNormalProcess()
		if process<=GUIDE_PROCESS_LIMIT then
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1160 ,y= 504 ,w = 87 ,h = 87 }  }) 
		end
		
	end
end

function Guide.showFirstNormalStageInfo()
	eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE,visible = true} )  
	Guide.addStageInfoBattleTIP()
	Guide.addBigBoMm("点击战斗，开始一段新的冒险吧！",-420,-170,1,1)
	Guide.changeMmImage(3)
end	

function Guide.addStageExitGuideTip() --【操作】在推图关闭按钮处添加指引
	local name = "instanceinfor-close"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	local index = Guide.curGuideEvent_data.order + 100000	--【测试】使用特殊的命名规则
	Guide._addMagicBarTip(clickImage,	index,180)
end

function Guide.addGuideWithSatgeActor99951( )--屠夫
	Guide.toCloseGuid({99951},1)
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	Guide.addGuideWithSatgeActor( )
end

function Guide.addGuideWithSatgeActor99952( )--牛头人
	Guide.toCloseGuid({99952},1)
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	Guide.addGuideWithSatgeActor( )
end

function Guide.addGuideWithSatgeActor99953( )--小鹿
	Guide.toCloseGuid({99953},1)
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	Guide.addGuideWithSatgeActor( )
end

function Guide.addGuideWithSatgeActor99954( )--狮鹫
	Guide.toCloseGuid({99954},1)
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	Guide.addGuideWithSatgeActor( )
end

function Guide.checkAdventureEliteProcessAndPlayerLv() --判断精英关卡指引
	local flag = true
	local name = "instanceinfor-style2-effect"
	local ui = engine.GetGUIWindowWithName(name)
	if ui and ui:IsVisible() then
		flag = false
	end
	return dataManager.playerData:getAdventureEliteProcess() <= 0 and Guide.checkPlayerLevel(8) and flag
end

function Guide.addAdventureEliteTIP() --精英关卡指引
	local name = "instanceinfor-style2"
	local ui = engine.GetGUIWindowWithName(name)
	local clickImage
	if ui and ui:IsVisible() then
		clickImage = engine.GetGUIWindowWithName(name);
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order+200000)
	end
end

function Guide.addGuideWithAdventureSatge(adID) --在关卡节点处添加指引
		local stage =  dataManager.instanceZonesData:getStageWithAdventureID( adID,enum.Adventure_TYPE.NORMAL )
		local process = dataManager.playerData:getAdventureNormalProcess()
		local gameobj =   instanceScene.allActor[adID]
		local worldPos = gameobj:GetPosition();
		local name2 = Guide.__addGridTip(worldPos)
		instanceScene.onaddGuideWithActor(stage,name2)

		local closeId = 99901
		local index = Guide.findIdWithOrder(closeId)
		
		--触发时延迟了1帧，否则摄像机尚未移动完成，渠道的screenPos不对
		local screenPos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);
		--强制引导
		if process<= GUIDE_PROCESS_LIMIT then
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = screenPos.x-40 ,y= screenPos.y-40 ,w = 80 ,h = 80 }  })
		end
		--
		
		if(Guide.serverData[index] ==true and Guide.checkAdventureNormalProcessThan0())then
			Guide.addBigBoMm("你好棒！赶紧进入下一关吧。",400,400,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
end


function Guide.addGuideWithSatgeActor( )  --【操作】判断是否需要显示奖励预告，判断主城有无指引，有则在退出按钮处加指引，否则在最新关卡处添加指引
  local process = dataManager.playerData:getAdventureNormalProcess()
  local stage =  dataManager.instanceZonesData:getStageWithAdventureID( process,enum.Adventure_TYPE.NORMAL )
	local star = stage:getVisStarNum()
  local func
  --清理
  FreeGuideUi(99002)
	FreeGuideUi(199002)
	FreeGuideUi(299002)
	--再战指引
	if process <=GUIDE_PROCESS_LIMIT and star == 2 and process%2 == 0 then
			Guide.addGuideWithAdventureSatge(process)
			return
  end
  
  if Guide.instanceinforIsVisible() == false then
  
	--屠夫奖励预览
	if process == 2 and star == 3 then
				if Guide.getServerDataWithOrder(99951) == true then
						--Guide.toCloseGuid({99951},1)
						Guide.addStageExitGuideTip()
						func = Guide.addGuideWithSatgeActor99951
						--Guide.addBigBoMm("通关1-2即可获得新兵种——【屠夫】",-600,320,1,1,100,100000,func)
						--Guide.showMmActor("tufuA.actor")
						eventManager.dispatchEvent({name = global_event.REWARDGUIDE_SHOW,unitID = 27,text = "通关1-2即可获得新兵种",func = func})
						FreeGuideUi(199002)
						return
				end
  end
  --小鹿奖励预览
	if process == 4 and star == 3 then
				if Guide.getServerDataWithOrder(99953) == true then
						Guide.addStageExitGuideTip()
						func = Guide.addGuideWithSatgeActor99953
						eventManager.dispatchEvent({name = global_event.REWARDGUIDE_SHOW,unitID = 60,text = "通关1-3即可获得新兵种",func = func})
						FreeGuideUi(199002)
						return
				end
  end
  --狮鹫奖励预览
	if process == 6 and star == 3 then
				if Guide.getServerDataWithOrder(99954) == true then
						Guide.addStageExitGuideTip()
						func = Guide.addGuideWithSatgeActor99954
						eventManager.dispatchEvent({name = global_event.REWARDGUIDE_SHOW,unitID = 12,text = "通关1-5即可获得新兵种",func = func})
						FreeGuideUi(199002)
						return
				end
  end
	--牛头人酋长奖励预览
	--if process == 10 and star == 3 then
	if process == 10 then
				if Guide.getServerDataWithOrder(99952) == true then
						--Guide.toCloseGuid({99952},1)
						Guide.addStageExitGuideTip()
						func = Guide.addGuideWithSatgeActor99952
						--Guide.addBigBoMm("通关1-8即可获得新兵种——【牛头人酋长】",-600,320,1,1,100,100000,func)
						--Guide.showMmActor("niutourenqiuzhangA.actor")
						eventManager.dispatchEvent({name = global_event.REWARDGUIDE_SHOW,unitID = 51,text = "通关1-8即可获得新兵种",func = func})
						FreeGuideUi(199002)
						return
				end
  end
	--判断主城有无指引，有则在退出按钮处加指引，否则在最新关卡处添加指引
	local flag = Guide.checkMainControlGuide()
	if(flag)then
		Guide.addStageExitGuideTip()
		local closeId = 99905
		local index = Guide.findIdWithOrder(closeId)
		--强制引导
		if process<= GUIDE_PROCESS_LIMIT then
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1216 ,y= 5 ,w = 63 ,h = 74 }  })
		end
		--
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("进入家园，去装备新武器吧。",-510,260,1,1,100,100000)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		else
			Guide.addBigBoMm("家园传来了新的消息，快回去看看吧。",-510,260,1,1,100,100000)
			Guide.changeMmImage(2)
		end
	elseif Guide.checkAdventureEliteProcessAndPlayerLv() then
		Guide.addAdventureEliteTIP()
	elseif Guide.checkPlayerLevelTE8() == false then --八级关闭在关卡节点指引
	
		local zones = dataManager.instanceZonesData
		local stage2 = zones:getNewInstance(enum.Adventure_TYPE.NORMAL)
		local adID = stage2:getAdventureID()
		Guide.addGuideWithAdventureSatge(adID)
		
	end
	
	end
end

function Guide.addGuideShip3Actor( ) --【废弃】
	 local posx,posy  = PLAN_CONFIG.getShipPosition(3)
	 local worldPos = battlePrepareScene.grid:getWorldPostion(posx, posy);
	
	print("worldPos .."..worldPos.x.." "..worldPos.y.." "..worldPos.z)
	 return Guide.__addGridTip(worldPos)
end

function Guide.addGuideShipActor( ) --【操作】在空船位置添加箭头
	local posx
	local posy
	local worldPos
	for i=1,6 do
		if(PLAN_CONFIG.getShipCardType(i)<1)then
			posx,posy  = PLAN_CONFIG.getShipPosition(i)
			worldPos = battlePrepareScene.grid:getWorldPostion(posx, posy);
			print("worldPos .."..worldPos.x.." "..worldPos.y.." "..worldPos.z)

			local closeId = 99903
			local index = Guide.findIdWithOrder(closeId)
			if(Guide.serverData[index] ==true)then
				Guide.addBigBoMm("点击标有军团编号的格子，派遣新兵种上阵。",150,200,0)
				Guide.changeMmImage(2)
				Guide.toCloseGuid({closeId},1)
			end
			

			return Guide.__addGridTip(worldPos)
		end
	end
end

function Guide.delGUIDEUI3001_3005() --【操作】删除空船箭头
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	local id = 3001
	FreeGuideUi(id)
	id = 3005
	FreeGuideUi(id)
end

function Guide.addSelShipActorUi(i) --【操作】在角色位添加箭头
		local index  = i
		local name = "battleprepare_"..index.."_battleprepareitem-itemcell"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,270)
end	

function Guide.addActorTabUi(i) --【操作】在种族页签处添加箭头
		local index  = i
		local name = "battleprepare-tab"..index
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,270)
		
		local closeId = 99922
		local index2 = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index2] ==true)then
		  --暂时关闭指引小助手
			--Guide.addBigBoMm("点击页签，看看你新获得的兵种吧。",-260,150,1,0,0)
			--Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
end	

function Guide.findNewUnit(s,e)  --【操作】寻找未上阵军团，返回基本体ID和族内可上阵序号
		local card
		local cardType
		local flag
		local newunit = 0	--新军团的基本体ID
		local order			--新军团在可选列表中的序号
		for i=s,e do
			if(math.mod(i,18)==1)then
				order = 0
			end
			card = cardData.getCardInstance(i);
			if(card:getStar() > 0)then	
				order = order+1
				flag = 1
				for j=1,6 do
					cardType =	PLAN_CONFIG.getShipCardType(j)
					if(cardType == i)then
						flag = 0
						break
					end
				end
				if(flag == 1)then
					newunit = i
					break
				end
			end
		end
		return newunit,order
end

function Guide.changeTabOrder(tabnum)  --【操作】标签与种族序号对换，从基本体种族转换为页签名
	if(tabnum == 0)then
		tabnum = 1
	elseif(tabnum == 1)then
		tabnum = 4
	elseif(tabnum == 2)then
		tabnum = 2
	elseif(tabnum == 3)then
		tabnum = 3
	end
	return tabnum
end

function Guide.changeTabOrder2(tabnum)  --【操作】标签与种族序号对换，从页签名转换为基本体种族
	if(tabnum == 1)then
		tabnum = 0
	elseif(tabnum == 4)then
		tabnum = 1
	elseif(tabnum == 2)then
		tabnum = 2
	elseif(tabnum == 3)then
		tabnum = 3
	end
	return tabnum
end

function Guide.addSelShipActorGuideDefine() --【操作】上阵选人指引，默认
		eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
		FreeGuideUi(3004)
		FreeGuideUi(3007)
		local newunit,order = Guide.findNewUnit(1,72)
		local tabnum = math.floor( (newunit-1)/18 )
		if (newunit>0 and newunit<=18) then
			Guide.addSelShipActorUi(order)
					local closeId = 99921
					local index2 = Guide.findIdWithOrder(closeId)
					if(Guide.serverData[index2] ==true)then
						Guide.addBigBoMm("点击该兵种，将其派上战场。",300,300,0,0,0)
						Guide.changeMmImage(2)
						Guide.toCloseGuid({closeId},1)
					end
		elseif(newunit>0)then
			tabnum = Guide.changeTabOrder(tabnum)
			Guide.addActorTabUi(tabnum)
		end
end	

function Guide.addSelShipActorGuideTab() --【操作】上阵选人指引，切换页签后
		eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
		FreeGuideUi(3004)
		FreeGuideUi(3007)
		local tabnum_now = Guide.changeTabOrder2(Guide.curGuideEvent.arg1+1)
		local newunit,order = Guide.findNewUnit(tabnum_now*18+1,(tabnum_now+1)*18)
		if(newunit == 0)then
			newunit,order = Guide.findNewUnit(1,72)
		end
		local tabnum = math.floor( (newunit-1)/18 )
		if (newunit>0 and tabnum == tabnum_now) then
			Guide.addSelShipActorUi(order)
		elseif(newunit>0)then
			tabnum = Guide.changeTabOrder(tabnum)
			Guide.addActorTabUi(tabnum)
		end
end

function Guide.freeBattlePrePareBattleTip() --【操作】删除挑战按钮处的箭头
		FreeGuideUi(99004) --挑战按钮指引
		FreeGuideUi(99102) --换阵指引
		FreeGuideUi(99103) --拖拽指引
		FreeGuideUi(3005) --军团指引
		FreeGuideUi(6004) --魔法指引
end

function Guide.addBattlePrePareBattleTip() --【操作】在挑战按钮处添加箭头
		local process = dataManager.playerData:getAdventureNormalProcess()
		Guide.clearAll()
		--Guide.freeBattlePrePareBattleTip()
		local name = "battleprepare-start"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)

		local closeId = 99902
		local index = Guide.findIdWithOrder(closeId)
		local closeId2 = 99904
		local index2 = Guide.findIdWithOrder(closeId2)
		if(battlePrepareScene.copyID == 1) then	--判断stageID
			Guide.addBigBoMm("点击开战，结束战备开始战斗。",-420,-170,1,1)
			Guide.changeMmImage(2)
			if process<=GUIDE_PROCESS_LIMIT then
			--if(Guide.serverData[index] ==true) then
				eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1137 ,y= 560 ,w = 96 ,h = 120 }  }) 
				Guide.toCloseGuid({closeId},1)
			end
		elseif (Guide.serverData[index2] == true) then
			Guide.addBigBoMm("万事俱备，狠狠的打击敌人吧！",-420,-170,1,1)
			Guide.changeMmImage(3)
			Guide.toCloseGuid({closeId2},1)
		end
end	

function Guide.addBattlePrePareBattleTipEx() --【操作】判断是否需要继续引导，如不需要则在挑战按钮处添加箭头
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	FreeGuideUi(3004)
	FreeGuideUi(3007)
	local flag = Guide.playerShipHasNoActor( )
	if(flag)then
		Guide.addGuideShipActor( )
	else
		Guide.addBattlePrePareBattleTip()
	end
end

function Guide.addShipEntryTip() --【操作】战船（兵营）指引
		FreeGuideUi(4003)
		FreeGuideUi(13002)
		FreeGuideUi(13003)
		local name = "maincontrol-huodong"
		if(engine.GetGUIWindowWithName(name) ~= nil)then
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		if Guide.checkPlayerLevelTE4() == false then
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1138 ,y= 593 ,w = 106 ,h = 114 }  })  
		end
		local closeId = 99906
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("现在进入军团界面，装上刚获得的武器吧。",-480,-300)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
	end
		
end


function Guide.addRolequip_wuqiGuideTip()
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })  --关闭指引小助手
	local name = "rolequip-wuqi-empty"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
	
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 578 ,y= 165 ,w = 108 ,h = 108 }  }) 
		local closeId = 99907
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("装备栏位上有红点，就表示该换装备啦。",-100,250,1,0,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
end	

function Guide.addRolequip_BagItem1GuideTip()
	local index  = 1
	local name = "equip_item"..index.."_rolequipitem-item"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
	
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 769 ,y= 224 ,w = 449 ,h = 100 }  })
		local closeId = 99908
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("通常，排最前面的装备是最好的。",-50,200,1,0,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
end	

function Guide.addRolequipcloseGuideTip() --【操作】在战船界面退出按钮处添加箭头	 
	local name = "rolequip-close"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,180) 
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1211 ,y= 72 ,w = 60 ,h = 66 }  })
	Guide.addBigBoMm("现在回到家园，招募新的兵种吧。",-480,240,1,0,0)
	Guide.changeMmImage(2)
	--判断是否需要抽卡引导
	if Guide.checkCard39() == false then
			Guide.toOPENGuid({5001},1)
	end
end

function Guide.addRolequipTabGuideTip() --【操作】在2号战船页签处添加箭头
	local index = 2
	local name = "rolequip-ship"..index
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,0)
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 183 ,y= 554 ,w = 103 ,h = 103 }  })
		local closeId = 99909
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("现在给另外一个军团装备武器吧。",280,-180,1,0,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
end	

function Guide.addZhaoHuanEntryTip()
		local v = enum.HOMELAND_BUILD_TYPE.CARD
	  local clickImage = homeland.buildPanels.root[v] 
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 650 ,y= 300 ,w = 140 ,h = 110 }  })
		local closeId = 99910
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("点击召唤阵，进行兵种的招募。",80,300,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
end

function Guide.addCardOneGuideTip()
	 
	local name = "card-card-one-free"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 282 ,y= 441 ,w = 156 ,h = 156 }  })
	Guide.addBigBoMm("单次招募每46个小时免费一次哦~",-250,-170,1,0,30)
	Guide.changeMmImage(1)
end

function Guide.addprepareMagicBar3Tip()
		local name = "battleprepare-skillitem3"
		 local clickImage =  ( engine.GetGUIWindowWithName(name));
		 Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	 
end	

function Guide.addprepareMagicBarTip() --【操作】在第一个空的魔法棒控件出添加指引
		for i=1,6 do
			if(Guide.getEquipedMagicWithPos(i) == false)then
				local index = i
				local name = "battleprepare-skillitem"..index
				local clickImage =  ( engine.GetGUIWindowWithName(name));
				Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)

				local closeId = 99911
				local index = Guide.findIdWithOrder(closeId)
				if (Guide.serverData[index] ==true) then
					Guide.addBigBoMm("哇，你有新的魔法可以使用啦！",0,-300)
					Guide.changeMmImage(3)
					Guide.toCloseGuid({closeId},1)
				end
				return true
			end
		end	 
end	

function Guide.addSpeedMagicBarTip() --【极速挑战】在第一个魔法棒控件出添加指引
				local index = 1
				local name = "battleprepare-skillitem"..index
				local clickImage =  ( engine.GetGUIWindowWithName(name));
				Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)

				Guide.addBigBoMm("活动中可以使用专用的超级魔法，虽然超级魔法具有扭转战局的奇效，但每个魔法只能使用一次，使用时要格外谨慎哦。",0,-350)
				Guide.changeMmImage(2)
end

function Guide.clearSpeedMagicBarTip() --【极速挑战】扫除
	if Guide.getServerDataWithOrder(99990) == false then
		FreeGuideUi(99990)
		Guide.toCloseGuid({99991},1)
		eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	end
end


function Guide.addBattleSkill3GuideTip()
	local index  = 3
	local name = "battleskill_"..index.."_battleskillitem-item"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
end	

function Guide.addSkillInfoGuideTip()  --【操作】敌军技能信息指引
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	FreeGuideUi(6102)
	FreeGuideUi(6103)
  Guide.addBigBoMm("按住技能图标可以查看技能说明。",400,400,0,0,0)
	Guide.changeMmImage(2)
	local index  = 1
	local name = "corpsdetail-skill-"..index.."_skillitem-head"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 420 ,y= 309 ,w = 125 ,h = 125 }  }) 
end	

function Guide.addSkillInfoGuideTip2()  --【操作】敌军技能信息指引2
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE})
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	FreeGuideUi(6103)
  Guide.addBigBoMm("屠夫可以钩住同一行的目标，对阵时要多加小心。",400,400,0,0,0)
	Guide.changeMmImage(2)
	
	local name = "corpsdetail-close"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	if clickImage then
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		--eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 879 ,y= 63 ,w = 60 ,h = 66 }  })
	end 
end	

function Guide.delGUIDEUI6103()  --【操作】删除敌军技能信息指引
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	FreeGuideUi(6103)
end
	
--解锁界面相关功能函数
function Guide.setNoticeGuideTipTitle(imagename)
	local name = "noticeGuideTip-light"
	local ui = engine.GetGUIWindowWithName(name)
	if ui then
		ui:SetProperty("EffectFileName",imagename)
	end
end

function Guide.setNoticeGuideTipName(imagename,pos_x,pos_y,w,h)
	local name = "noticeGuideTip-name"
	local ui = engine.GetGUIWindowWithName(name)
	if ui then
		ui:SetProperty("ImageName",imagename)
		local pos = LORD.UVector2(LORD.UDim(0,pos_x),LORD.UDim(0,pos_y))
		ui:SetPosition(pos)
		local _w = LORD.UDim(0, w)
		local _h = LORD.UDim(0, h)
		ui:SetWidth(_w)
		ui:SetHeight(_h)
	end
end

function Guide.setNoticeGuideTipImage(imagename,pos_x,pos_y,w,h,pos_x2,pos_y2,w2,h2,sp)
	local name = "noticeGuideTip-image"
	local ui = engine.GetGUIWindowWithName(name)
	if ui then
		ui:SetProperty("ImageName",imagename)
		local pos = LORD.UVector2(LORD.UDim(0,pos_x),LORD.UDim(0,pos_y))
		ui:SetPosition(pos)
		local _w = LORD.UDim(0, w)
		local _h = LORD.UDim(0, h)
		ui:SetWidth(_w)
		ui:SetHeight(_h)
	end
	name = "noticeGuideTip-effect"
	ui = engine.GetGUIWindowWithName(name)
	if ui then
		ui:SetProperty("EffectFileName","ui_tiaozhanchenggong.effect")
		local pos2 = LORD.UVector2(LORD.UDim(0,pos_x2),LORD.UDim(0,pos_y2))
		ui:SetPosition(pos2)
		local _w2 = LORD.UDim(0, w2)
		local _h2 = LORD.UDim(0, h2)
		ui:SetWidth(_w2)
		ui:SetHeight(_h2)
	end
	name = "noticeGuideTip-image-text"
	ui = engine.GetGUIWindowWithName(name)
	if ui then
		if sp>0 then
			ui:SetProperty("Visible",1)
			ui:SetProperty("ImageName","set:battle.xml image:auto-text")
			local pos3 = LORD.UVector2(LORD.UDim(0,21),LORD.UDim(0,22))
			ui:SetPosition(pos3)
			local _w3 = LORD.UDim(0, 72)
			local _h3 = LORD.UDim(0, 44)
			ui:SetWidth(_w3)
			ui:SetHeight(_h3)
		else
			ui:SetProperty("Visible",0)
			ui:SetProperty("ImageName","")
		end
	end
end

function Guide.setNoticeGuideTipActor(actorname,pos_x,pos_y,w,h,x,y)
	local name = "noticeGuideTip-actor"
	local ui = engine.GetGUIWindowWithName(name)
	if ui then
		ui:SetProperty("Visible",1)
		ui:SetProperty("ActorName",actorname)
		local pos = LORD.UVector2(LORD.UDim(0,pos_x),LORD.UDim(0,pos_y))
		ui:SetPosition(pos)
		local _w = LORD.UDim(0, w)
		local _h = LORD.UDim(0, h)
		ui:SetWidth(_w)
		ui:SetHeight(_h)
		ui:SetProperty("ActorRotationX",x)
		ui:SetProperty("ActorRotationY",y)
	end
end

function Guide.setNoticeGuideTipChild(title,npc,image1)
	local name = "_noticeGuideTip1-title"
	local ui = LORD.GUIWindowManager:Instance():GetGUIWindow("noticeGuideTip_"..name)	
	if ui then
		ui:SetProperty("ImageName",title)
	end
	name = "_noticeGuideTip1-npc"
	ui = LORD.GUIWindowManager:Instance():GetGUIWindow("noticeGuideTip_"..name)
	if ui then
		ui:SetProperty("ImageName",npc)
	end
	name = "_noticeGuideTip1-image1"
	ui = LORD.GUIWindowManager:Instance():GetGUIWindow("noticeGuideTip_"..name)
	if ui then
		ui:SetProperty("ImageName",image1)
	end
	name = "_noticeGuideTip1"
	ui = LORD.GUIWindowManager:Instance():GetGUIWindow("noticeGuideTip_"..name)
	if ui then
		ui:SetProperty("Visible",1)
		local pos = LORD.UVector2(LORD.UDim(0,109),LORD.UDim(0,129))
		ui:SetPosition(pos)
	end
	name = "noticeGuideTip-effect"
	ui = engine.GetGUIWindowWithName(name)
	if ui then
		ui:SetProperty("EffectFileName","ui_tiaozhanchenggong.effect")
		local pos2 = LORD.UVector2(LORD.UDim(0,55),LORD.UDim(0,-20))
		ui:SetPosition(pos2)
		local _w2 = LORD.UDim(0, 343)
		local _h2 = LORD.UDim(0, 319)
		ui:SetWidth(_w2)
		ui:SetHeight(_h2)
	end
end

--

function Guide.addSpeedUpTipText() --加速功能开启提示
	local t = "解锁新功能#n#n2倍速战斗"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("kaiqixingongneng.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name9",79,13,164,44)
	--Guide.setNoticeGuideTipImage("set:battle.xml image:speed",177,235,111,81,111,49,254,280,0)
	Guide.setNoticeGuideTipImage("set:battle.xml image:speed",177,235,111,81,121,44,222,234,0)
end	

function Guide.addAutoMagicTipText() --自动施法功能开启提示
	local t = "解锁新功能#n#n自动施法"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("kaiqixingongneng.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name6",79,13,164,44)
	Guide.setNoticeGuideTipImage("set:common.xml image:button4",177,235,111,81,121,44,222,234,1)
end

function Guide.addTieJiangPuGuideTipText()
	local t = "解锁新建筑#n铁匠铺"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
end	

function Guide.addEQUIPEntryTip() --【操作】铁匠铺
	local name = "rolequip-strengthen-button"
	if name and engine.GetGUIWindowWithName(name) then
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 762 ,y= 555 ,w = 120 ,h = 120 }  }) 
		local closeId = 99913
		local index = Guide.findIdWithOrder(closeId)
		--if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("强化可以进一步提高装备的属性，快来试试吧！",-250,-200,1,1)
			Guide.changeMmImage(3)
			Guide.toCloseGuid({closeId},1)
		--end
	end
end

function Guide.addEQUIPEntryTipWithText()
		Guide.addEQUIPEntryTip()
		Guide.addTieJiangPuGuideTipText()
end
 

function Guide.addstrengthen_buttonTip() --【操作】铁匠铺 强化
	local name = "rolequip-strengthen-button1"
	if name and engine.GetGUIWindowWithName(name) then
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1071 ,y= 490 ,w = 134 ,h = 55 }  }) 
		Guide.addBigBoMm("强化消耗的金币会在出售时100%返还哟~。",-630,-260,1,1)
		Guide.changeMmImage(1)
	end
end	


function Guide.addGoldGuideTipText()
	local t = "解锁新建筑#n#n、金矿"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("jiesuoxinjianzhu.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name3",118,13,84,44)
	Guide.setNoticeGuideTipActor("jy_jinkuang.actor",231,412,36,47,10,60)
end

function Guide.addGoldEntryTip() --【操作】金矿
		FreeGuideUi(8002)
		FreeGuideUi(8003)
		local v = enum.HOMELAND_BUILD_TYPE.GOLD
	    local clickImage = homeland.buildPanels.root[v] 
	if(homeland.buildPanels.root[v] ~= nil)then
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		local closeId = 99914
		local index = Guide.findIdWithOrder(closeId)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 750 ,y= 428 ,w = 124 ,h = 142 }  })
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("金矿生产金币，时间就是金钱！",400,200,0)
			Guide.changeMmImage(3)
			Guide.toCloseGuid({closeId},1)
		end
	end
end

function Guide.addGoldEntryTipWithText()
		Guide.addGoldEntryTip()
		Guide.addGoldGuideTipText()
end

function Guide.addgoldmine_shoujiTip() --【操作】金矿 采集
		local name = "goldmine-shouji"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		Guide.addBigBoMm("收集金币，然后去强化装备吧！",-450,-120,1,1) 
		Guide.changeMmImage(3)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1135 ,y= 578 ,w = 124 ,h = 112 }  }) 
end	

function Guide.addgoldmine_levelupTip() 
		local name = "goldmine-level"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		Guide.addBigBoMm("升级金矿获得更多金币。",-450,-220,1,1) 
		Guide.changeMmImage(2)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1135 ,y= 438 ,w = 124 ,h = 112 }  }) 
end	

function Guide.addgoldmine_levelup2Tip() 
		local name = "countrylevle-jianzao"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		Guide.addBigBoMm("点击开始建造进行金矿升级。",170,-100,1,1) 
		Guide.changeMmImage(2)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 130 ,y= 472 ,w = 184 ,h = 68 }  }) 
end	

function Guide.addGoldEntryCloseGuideTip() --【操作】金矿退出按钮处添加箭头	 
	local name = "goldmine-close"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,180) 
	Guide.addBigBoMm("建筑升级需要一定的时间，过会儿再来吧。",-700,300,1,1) 
	Guide.changeMmImage(2)
	--判断是否需要伐木引导
	if Guide.getServerDataWithOrder(10005) == true then
			Guide.toOPENGuid({10003,10004},1)
	end
end


function Guide.addWoodEntryCloseGuideTip() --【操作】伐木场退出按钮处添加箭头	 
	local name = "wood-close"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,180) 
end


function Guide.hasUISPVisible()
	return Guide.hasUIVisible(12002) == false and Guide.hasUIVisible(12003) == false and Guide.hasUIVisible(14002) == false and Guide.hasUIVisible(14003) == false
end	

function Guide.addmaincontrol_QiandaoTip() --【操作】日常

	if Guide.hasUISPVisible() then
	
	local name = "maincontrol-qiandao"
	if(engine.GetGUIWindowWithName(name) ~= nil)then
		 local clickImage =  ( engine.GetGUIWindowWithName(name));
		 Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		local closeId = 99915
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			--Guide.addBigBoMm("日常很重要，千万不要错过了哦~",0,-200)
			--Guide.changeMmImage(1)
			Guide.toCloseGuid({closeId},1)
		end 
	end
	
	end
	
end	


function Guide.addWoodGuideTipText()
	local t = "解锁新建筑#n伐木场"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("jiesuoxinjianzhu.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name1",99,13,124,44)
	Guide.setNoticeGuideTipActor("jy_shujing.actor",231,412,36,47,0,30)
end	

function Guide.addWoodEntryTip()  --【操作】伐木场
		local v = enum.HOMELAND_BUILD_TYPE.WOOD
	    local clickImage = homeland.buildPanels.root[v]
	if(homeland.buildPanels.root[v] ~= nil)then 
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		local closeId = 99916
		local index = Guide.findIdWithOrder(closeId)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 135 ,y= 200 ,w = 124 ,h = 250 }  }) 
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("木材很重要，建设和军团扩容都用它。",350,240,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end	
	end
end

function Guide.addWoodEntryTipWithText()
		Guide.addWoodEntryTip()
		Guide.addWoodGuideTipText()
end

function Guide.addwood_jiagongTip() --【操作】伐木场 加工
		local name = "wood-jiagong"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		Guide.addBigBoMm("加工时有几率暴击呦~",-450,-120,1,1)  
		Guide.changeMmImage(1)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1135 ,y= 578 ,w = 124 ,h = 112 }  })
end

function Guide.addSHOPGuideTipText()
	local t = "解锁新建筑#n#n商店"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("jiesuoxinjianzhu.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name5",118,13,84,44)
	Guide.setNoticeGuideTipActor("jy_shangdian.actor",231,377,45,47,10,30)
end	

function Guide.addSHOPEntryTip()  --【操作】商店
		FreeGuideUi(11002)
		FreeGuideUi(11003)
		local v = enum.HOMELAND_BUILD_TYPE.SHOP
	    local clickImage = homeland.buildPanels.root[v] 
	if(homeland.buildPanels.root[v] ~= nil)then
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		local closeId = 99917
		local index = Guide.findIdWithOrder(closeId)
		--if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("商店每天刷新四次，买到就是赚到！",700,270,0)
			Guide.changeMmImage(3)
			Guide.toCloseGuid({closeId},1)
		--end	
	end
end

function Guide.addSHOPEntryTipWithText()
		Guide.addSHOPEntryTip()
		Guide.addSHOPGuideTipText()
end


function Guide.addNewActiveCopyStageBattleGuideTipText()
	local t = "解锁新活动#n#n副本挑战"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip = t,newUi = 1});
	Guide.setNoticeGuideTipTitle("kaiqixinwanfa.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name11",79,13,164,44)
	Guide.setNoticeGuideTipChild("set:activity.xml image:acticity-instance","rolebig1.png","set:activity1.xml image:image1")
end	

function Guide.addmaincontrol_huodongTip() --【操作】活动指引
		FreeGuideUi(12002)
		FreeGuideUi(12003)
		FreeGuideUi(16002)
		FreeGuideUi(16003)		
		local v = enum.HOMELAND_BUILD_TYPE.SHIP
	  local clickImage = homeland.buildPanels.root[v] 
		if(homeland.buildPanels.root[v] ~= nil)then
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		
		local closeId = 99918
		local index = Guide.findIdWithOrder(closeId)
		--if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("开放新的活动啦，快去看看吧~",350,350,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		--end	 
	end
end

function Guide.addmaincontrol_huodongTipWithText()
		 Guide.addmaincontrol_huodongTip(); 	
		 Guide.addNewActiveCopyStageBattleGuideTipText() 
end	

 
function Guide.addIdolStatusTipText()
	local t = "解锁新建筑#n#n、神像"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("jiesuoxinjianzhu.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name13",120,13,83,43)
	Guide.setNoticeGuideTipActor("jy_gonghui.actor",223,391,29,51,20,30)
end

function Guide.addIdolStatusTip() --【操作】神像指引
		FreeGuideUi(17001)
		FreeGuideUi(17002)		
		local v = enum.HOMELAND_BUILD_TYPE.GONGHUI
	  local clickImage = homeland.buildPanels.root[v] 
		if(homeland.buildPanels.root[v] ~= nil)then
			Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		
			--Guide.addBigBoMm("神像系统开放啦，升级神像可以全方位提高军团的战斗力。",350,350,0)
			--Guide.changeMmImage(2)
		end
end	

function Guide.addIdolStatusTipWithText()
		Guide.addIdolStatusTip()
		Guide.addIdolStatusTipText()
end 

function Guide.addSHIPGuideTipText()
	local t = "军团自动升级结束，以后需要使用木材手动升级啦~"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("kaiqixingongneng.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name10",79,13,164,44)
	Guide.setNoticeGuideTipImage("set:ship.xml image:corps-levelup",173,216,120,118,121,44,222,234,0)
end	

function Guide.addSHIPEntryTipWithText()
		Guide.addShipEntryTip()
		Guide.addSHIPGuideTipText()
end

function Guide.addShipLevelUpTip()
		local name = "rolequip-lv-button"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		Guide.addBigBoMm("扩充编制，提升军团的士兵数量，人多势众！",400,0,1,0,0)	
		Guide.changeMmImage(3) 
end	


function Guide.addARENAGuideTipText()
	local t = "解锁新建筑#n#n竞技场"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("jiesuoxinjianzhu.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name4",99,13,124,44)
	Guide.setNoticeGuideTipActor("jy_jingjichang.actor",231,390,17,47,10,60)
end	

function Guide.addARENAEntryTip() --【操作】竞技场
	FreeGuideUi(14002)
	FreeGuideUi(14003)
		local v = enum.HOMELAND_BUILD_TYPE.ARENA
	    local clickImage = homeland.buildPanels.root[v] 
	if(homeland.buildPanels.root[v] ~= nil)then
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
		local closeId = 99919
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("进入竞技场，迎接真正的挑战，为了荣耀而战！",570,380,0)
			Guide.changeMmImage(3)
			Guide.toCloseGuid({closeId},1)
		end	
	end
end

function Guide.addARENAEntryTipWithText()
		Guide.addARENAEntryTip()
		Guide.addARENAGuideTipText()
end


function Guide.addMAGICGuideTipText()
	local t = "解锁新建筑#n#n法师塔"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("jiesuoxinjianzhu.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name2",99,13,124,44)
	Guide.setNoticeGuideTipActor("jy_fashita.actor",197,386,23,47,10,25)
end	

function Guide.addMAGICEntryTip() --【操作】法师塔
	FreeGuideUi(15002)
	FreeGuideUi(15003)
		local v = enum.HOMELAND_BUILD_TYPE.MAGIC
	    local clickImage = homeland.buildPanels.root[v] 
	if(homeland.buildPanels.root[v] ~= nil)then
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		local closeId = 99920
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("在法师塔中冥想可以习得魔法，知识就是力量！",320,350,0)
			Guide.changeMmImage(3)
			Guide.toCloseGuid({closeId},1)
		end	
	end
end

function Guide.addMAGICEntryTipWithText()
		Guide.addMAGICEntryTip()
		Guide.addMAGICGuideTipText()
end

function Guide.addskilltower_mingxiangTip()
		 local name = "skilltower-mingxiang"
		 local clickImage =  ( engine.GetGUIWindowWithName(name));
		 Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	 
		 Guide.addBigBoMm("法师塔升级后，冥想的质量会更高哦~",-450,-80,1,1)
		Guide.changeMmImage(2)
end	



function Guide.addNewActiveHurtRankGuideTipText()
	local t = "解锁新活动#n#n伤害排行榜"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t,newUi = 1});
	Guide.setNoticeGuideTipTitle("kaiqixinwanfa.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name8",59,13,204,44)
	Guide.setNoticeGuideTipChild("set:activity.xml image:activity-rank","rolebig13.png","set:activity3.xml image:image3")
end	

function Guide.addNewNoticeGuideTip01()
	local t = "解锁新玩法#n#n精英关卡"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t});
	Guide.setNoticeGuideTipTitle("kaiqixinwanfa.effect",79,13,164,44)
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name12",79,13,164,45)
	Guide.setNoticeGuideTipImage("set:stage.xml image:type2",126,164,213,213,55,-20,343,319,0)
end


function Guide.addNewNoticeGuideTip02()
	local t = "解锁新活动#n#n极速挑战"
	eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,tip =t,newUi = 1});
	Guide.setNoticeGuideTipTitle("kaiqixinwanfa.effect")
	Guide.setNoticeGuideTipName("set:guide_hand.xml image:name7",79,13,164,44)
	Guide.setNoticeGuideTipChild("set:activity.xml image:activity-speed","rolebig15.png","set:activity2.xml image:image2")
end	

 

function Guide.addNewActiveHurtRankGuideTipTextWithText()
		 Guide.addmaincontrol_huodongTip(); 	
		 Guide.addNewActiveHurtRankGuideTipText() 
end	


function Guide.addNewActiveHurtRankGuideTipTextWithText()
		 Guide.addmaincontrol_huodongTip(); 	
		 Guide.addNewActiveHurtRankGuideTipText() 
end	

function Guide.delGUIDEUI16003()
	local id = 16003
	FreeGuideUi(id)
	id = 16002
	FreeGuideUi(id)
end

function Guide.delGUIDEUI17002()
	local id = 17001
	FreeGuideUi(id)
	id = 17002
	FreeGuideUi(id)
end

function Guide.delGUIDEUI12003()
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	local id = 12003
	FreeGuideUi(id)
	id = 12002
	FreeGuideUi(id)
end

function Guide.delGUIDEUI9001()
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	local id = 9001
	FreeGuideUi(id)
	id = 8005
	FreeGuideUi(id)
end

function Guide.delGUIDEUI99981()
	--eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	local id = 99981
	FreeGuideUi(id)
end

function Guide.addBattleSkillFirUnselectSkill() --【操作】在魔法选择界面第一个没有被选中的魔法处添加指引
	local battleskill = layoutManager.getUI("battleskill");
	local name  =  battleskill:getfirstUnSelWinNameIndex()
	
	if(name and engine.GetGUIWindowWithName(name))then
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
	end
end

function addBattleSkillCloseTip()  --【操作】在魔法包裹的关闭按钮处添加指引
		local name = "battleskill-close"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,270)
end

function Guide.addBattleSkillFirUnselectSkill01() --【操作】删除魔法棒箭头，并在第一个空魔法包裹控件处添加箭头
	Guide.clearAll()
	--FreeGuideUi(6001)

	Guide.addBattleSkillFirUnselectSkill()
		local closeId = 99912
		local index = Guide.findIdWithOrder(closeId)
		if(Guide.serverData[index] ==true)then
			Guide.addBigBoMm("最多只能选择6个魔法上场，即点即带。",0,300,1,0,0)
			Guide.changeMmImage(2)
			Guide.toCloseGuid({closeId},1)
		end
end

function Guide.addBattleSkillFirUnselectSkill02() --【操作】删除魔法包箭头，并在第一个空魔法包裹控件处添加箭头
	Guide.clearAll()
	--eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	--FreeGuideUi(6003)
	--FreeGuideUi(6004)
	if(Guide.checkMagicBarHasNoMagic())then
		Guide.addBattleSkillFirUnselectSkill()
	else
		addBattleSkillCloseTip()
	end
end	

function Guide.showGameToGuideHurt() --返回伤害数字位置
	local count = #battleText.hitList;
	local index = 1;
	if(count < 0)then
		return 
	end
	local instance = battleText.hitList[index];
  return instance
end	

function Guide.skullGuideFinish() --完成骷髅头指引
	Guide.clearAll()
	Guide.continueGame()
	--强制指引，遮罩位置与大小需谨慎，可能需要根据文字长度自适应而改变
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 0 ,y= 0 ,w = 0 ,h = 0 }  }) 
	--eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	--FreeGuideUi(1101)
end

function Guide.skullGuideStart() --显示骷髅头指引
	Guide.clearAll()
	local func = Guide.skullGuideFinish 
	Guide.addBigBoMm("守望者军团中有600名士兵战死了。#n",100,100,0,0,30,0,func)
	Guide.changeMmImage(2)
	Guide.showMmButton()

	local worldPos = battlePrepareScene.grid:getWorldPostion(2, 1)
	Guide.__addGridTip(worldPos)
	
	if ui then
		local ui = getFreeGuideUi(Guide.curGuideEvent_data.order) 
		ui:SetEffectName("uitexiao_shuzikuang.effect") 
		ui:SetSize(LORD.UVector2(LORD.UDim(0, 75), LORD.UDim(0, 100)));
	
		local _pos = ui:GetPosition();
		local pos = LORD.UVector2( _pos.x + LORD.UDim(0,80), _pos.y + LORD.UDim(0, 50))
		ui:SetPosition(pos)
	end
	--强制引导
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 495 ,y= 170 ,w = 103 ,h = 58 }  }) 
	--
end

function Guide.pauseGameWhenHpChange() --【操作】暂停游戏，显示指引
  local func = Guide.skullGuideStart
	Guide.addBigBoMm("形势不妙，我方的守望者军团受到了大量伤害。#n",100,100,0,0,30,0,func)
	Guide.changeMmImage(2)
	Guide.showMmButton()

	local worldPos = battlePrepareScene.grid:getWorldPostion(2, 1);--坐标貌似没用
  Guide.__addGridTip(worldPos)

  local ui = getFreeGuideUi(Guide.curGuideEvent_data.order)
  if ui then
		ui:SetEffectName("uitexiao_shuzikuang.effect")
		ui:SetSize(LORD.UVector2(LORD.UDim(0, 135), LORD.UDim(0, 100)));

		local instance = Guide.showGameToGuideHurt()
  	--local pos = LORD.UVector2(LORD.UDim(0,instance.pos.x+180),LORD.UDim(0,instance.pos.y-108))
  	local pos = LORD.UVector2(LORD.UDim(0,instance.pos.x+5),LORD.UDim(0,instance.pos.y-90))
  	ui:SetPosition(pos)
  end
	Guide.pauseGame()
	--强制引导
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 495 ,y= 170 ,w = 103 ,h = 58 }  }) 
	--
end

function Guide.getScoreWithAdventureID(id) --返回当前冒险关卡的得分（0-3星）
	local stage =  dataManager.instanceZonesData:getStageWithAdventureID(id,enum.Adventure_TYPE.NORMAL)	
	if(stage:isMain())then
	 	local num = stage:getScore()
		return num
	else
	  return -1
	end
end

function Guide.addGuideAtReFight() --【操作】在再次挑战按钮处添加指引
	local name = "instancejiesuan-again"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
end

function Guide.addGuideAtFinishFight() --【操作】在胜利结算界面退出按钮处添加指引
	local name = "instancejiesuan-out"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
end

function Guide.addGuideAtReFightLOSE() --【操作】在再次挑战按钮处添加指引，失败界面版
	local name = "battlelose-again"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
end

function Guide.reFightGuideCommon() --冒险关卡再战指引
  				Guide.addGuideAtReFight()
  				Guide.addBigBoMm("想到了一个可以取得三星的战术。一起来试试吧~",250,-150,1,1)
  				eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE})
					Guide.changeMmImage(1)
					--隐藏退出按钮
					name = "instancejiesuan-out"
					ui = engine.GetGUIWindowWithName(name)
					ui:SetProperty("Visible",0)
end

function Guide.reFightGuideCHALLENGE() --副本挑战再战指引
  				Guide.addGuideAtReFightLOSE()
  				Guide.addBigBoMm("想到了一个可以取胜的战术。一起来试试吧~",250,-150,1,1)
					Guide.changeMmImage(1)
					--隐藏退出按钮
					name = "battlelose-close"
					ui = engine.GetGUIWindowWithName(name)
					ui:SetProperty("Visible",0)
end

function Guide.hasOrc()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	if(card:getStar() > 0) then
		return true
	else
		return false
	end
end

function Guide.addReFightGuide() --【操作】判断是否需要再战指引
  local adId = Guide.curGuideEvent.arg1
  local score = Guide.curGuideEvent.arg2

  if adId<=16 and ((adId%2 == 0 and score == 3) or adId%2 == 1) then
  		Guide.addGuideAtFinishFight()
  elseif adId == 2 then --第1-1主关
  		if score == 2 then
					Guide.reFightGuideCommon()
  		end
  elseif adId == 4 and Guide.hasOrc() then
  		if score == 2 then
  				Guide.reFightGuideCommon()
  		end
  elseif adId == 6 and Guide.hasOrc() then
  		if score == 2 then
  				Guide.reFightGuideCommon()
  		end
  elseif adId == 8 and Guide.hasOrc() then
  		if score == 2 then
  				Guide.reFightGuideCommon()
  		end
  elseif adId == 10 and Guide.hasOrc() then
  		if score == 2 then
  				Guide.reFightGuideCommon()
  end
  elseif adId == 12 and Guide.hasOrc() then
  		if score == 2 then
  				Guide.reFightGuideCommon()
  end
  elseif adId == 14 and Guide.hasOrc() then
  		if score == 2 then
  				Guide.reFightGuideCommon()
  end
  elseif adId == 16 then
  		if score == 2 then
  				--Guide.reFightGuideCommon()
  		end
  end
end

function Guide.toOPENGuid99999()
			--开启军团换位功能
			local openId = 99999
			Guide.toOPENGuid({openId},1)
end

function Guide.getServerDataWithOrder(order)
	local index = Guide.findIdWithOrder(order)
	return Guide.serverData[index]
end


function Guide.transfer00() --改变阵型
	Guide.clearAll()
	local card = cardData.getCardInstance(4); --判断是否拥有火枪手
	if(card:getStar() > 0)then
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,-1,-1,-1},{{x = 2,y= 1},{x = 0,y= 2},{x = 0,y= 1},{x = 2,y= 2},{x = 2,y= 0},{x = 0,y= 2}})
	end
end

function Guide.transfer01() --改变阵型
	Guide.clearAll()
	local card = cardData.getCardInstance(4); --判断是否拥有火枪手
	if(card:getStar() > 0)then
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,-1,-1,-1},{{x = 2,y= 1},{x = 0,y= 0},{x = 0,y= 1},{x = 2,y= 2},{x = 2,y= 0},{x = 0,y= 2}})
		Guide.addBattlePrePareBattleTip() --在挑战按钮处添加箭头
	end
end



function Guide.transfer02() --改变阵型
	Guide.clearAll()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	if(card:getStar() > 0)then
		--battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,39,-1,-1},{{x = 2,y= 0},{x = 0,y= 0},{x = 0,y= 2},{x = 2,y= 2},{x = 2,y= 1},{x = 0,y= 1}})
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,39,-1,-1},{{x = 2,y= 1},{x = 0,y= 0},{x = 0,y= 1},{x = 2,y= 2},{x = 2,y= 0},{x = 0,y= 2}})

		local worldPos = battlePrepareScene.grid:getWorldPostion(2, 1);
		Guide.addBigBoMm("点击军团所在格子进行换兵操作。",630,250,0,0,0);
		Guide.changeMmImage(2);
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 395 ,y= 310 ,w = 150 ,h = 90 }  }) 
		return Guide.__addGridTip(worldPos);
	end
end

function Guide.transfer03() --改变阵型
	Guide.clearAll()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	if(card:getStar() > 0)then
		--battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,39,-1,-1},{{x = 2,y= 2},{x = 0,y= 2},{x = 0,y= 0},{x = 2,y= 0},{x = 2,y= 1},{x = 0,y= 1}})
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{27,20,4,39,-1,-1},{{x = 2,y= 1},{x = 0,y= 0},{x = 0,y= 1},{x = 2,y= 2},{x = 2,y= 0},{x = 0,y= 2}})

		local worldPos = battlePrepareScene.grid:getWorldPostion(0, 0);
		Guide.addBigBoMm("点击军团所在格子进行换兵操作。",630,250,0,0,0);
		Guide.changeMmImage(2);
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 200 ,y= 210 ,w = 150 ,h = 100 }  }) 
		return Guide.__addGridTip(worldPos);
	end
end

function Guide.transfer04() --改变阵型
	Guide.clearAll()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	if(card:getStar() > 0)then
		--battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,39,27,-1},{{x = 2,y= 2},{x = 0,y= 2},{x = 0,y= 1},{x = 0,y= 0},{x = 1,y= 1},{x = 1,y= 0}})
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{27,60,4,39,1,-1},{{x = 2,y= 1},{x = 0,y= 0},{x = 0,y= 1},{x = 2,y= 0},{x = 2,y= 2},{x = 0,y= 2}})
		Guide.addBattlePrePareBattleTip() --在挑战按钮处添加箭头
	end
end

function Guide.transfer05() --改变阵型，小鹿加速
	Guide.clearAll()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	if(card:getStar() > 0)then
		--battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,39,27,-1},{{x = 2,y= 2},{x = 0,y= 2},{x = 0,y= 1},{x = 0,y= 0},{x = 1,y= 1},{x = 1,y= 0}})
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{27,60,4,39,1,-1},{{x = 2,y= 1},{x = 0,y= 0},{x = 0,y= 1},{x = 2,y= 0},{x = 2,y= 2},{x = 0,y= 2}})
		battlePrepareScene.resetAllSkillWithTables({2,156,23,32,0,0,1})
		Guide.addBattlePrePareBattleTip() --在挑战按钮处添加箭头
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1137 ,y= 560 ,w = 96 ,h = 120 }  }) 
	end
end

function Guide.transfer06() --改变阵型
	Guide.clearAll()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	if(card:getStar() > 0)then
		--battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,39,27,-1},{{x = 2,y= 2},{x = 0,y= 2},{x = 0,y= 1},{x = 0,y= 0},{x = 1,y= 1},{x = 1,y= 0}})
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{27,60,4,39,12,-1},{{x = 2,y= 1},{x = 0,y= 0},{x = 0,y= 1},{x = 2,y= 0},{x = 2,y= 2},{x = 0,y= 2}})
		Guide.addBattlePrePareBattleTip() --在挑战按钮处添加箭头
	end
end

function Guide.transfer07() --改变阵型
	Guide.clearAll()
	local card = cardData.getCardInstance(39); --判断是否拥有兽人步兵
	if(card:getStar() > 0)then
		battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{27,60,4,37,1,20},{{x = 0,y= 1},{x = 0,y= 2},{x = 1,y= 2},{x = 0,y= 0},{x = 2,y= 2},{x = 1,y= 0}})
		Guide.addBattlePrePareBattleTip() --在挑战按钮处添加箭头
	end
end

--function Guide.transfer08() --改变阵型

--end

function Guide.transferC() --改变阵型
	Guide.clearAll()
	local card
	for _,v in ipairs({1,4,20,39,58}) do
		card = cardData.getCardInstance(v)
		if card:getStar() <=0 then
			return false
		end
	end
	battlePrepareScene.resetAllUnitWithTables({1,2,3,4,5,6},{1,20,4,39,58,-1},{{x = 1,y= 2},{x = 0,y= 1},{x = 0,y= 2},{x = 1,y= 1},{x = 0,y= 0},{x = 1,y= 0}})
	Guide.addBattlePrePareBattleTip() --在挑战按钮处添加箭头
end

function Guide.addBattlePrePareGuideLoop() --【核心】战备界面指引大全【循环】
	Guide.clearAll()
	--检查是否需要军团指引
  if Guide.getServerDataWithOrder(3001) == true and Guide.playerShipHasNoActor() == true then	
  	Guide.addGuideShipActor( )
  	return
  end
  --检查是否需要魔法指引
  if Guide.getServerDataWithOrder(6001) == true and Guide.checkMagicBarHasNoMagic() == true then	
  	Guide.addprepareMagicBarTip()
  	return
  end
	Guide.addBattlePrePareBattleTip() --在挑战按钮处添加箭头
end

function Guide.addBattlePrePareGuideMain() --【核心】战备界面指引【初始】
	Guide.clearAll()
	--获取事件参数
	local adId = Guide.curGuideEvent.arg1
  local score = Guide.curGuideEvent.arg2
  local process = dataManager.playerData:getAdventureNormalProcess()
  local func
  --关闭技能查看指引
	if process >= 2 then
			Guide.toCloseGuid({6101,6102,6103,6104,6105},1)
	end
	--第1-1主关拖拽指引
	if adId == 2 then
	  	if score == 2 then
	  			Guide.transfer00()
					Guide.toOPENGuid({99103},1)
					if Guide.getServerDataWithOrder(99103) == true then
						Guide.showGuidHand(0,2,0,0)
						Guide.addBigBoMm("将下路的军团拖拽到上路高亮格子处躲避肉钩。",450,250,0)
						--标记格子
						battlePrepareScene.signGrid(0, 0, "b2")
						Guide.changeMmImage(2)
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 70 ,y= 173 ,w = 560 ,h = 360 }  }) 
						return
					end
  		end
  end
	--第1-2主关换阵
	if adId == 4 and Guide.hasOrc() then
	  	if score == 2 then
						func = Guide.transfer02
						Guide.addBigBoMm("使用屠夫将敌方关键军团钩过来，优先击杀。#n",450,250,0,0,90,0,func)
						Guide.changeMmImage(2)
						Guide.showMmButton()
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  }) 
						return
  		end
  end
	--第1-3主关换阵
	if adId == 6 and Guide.hasOrc() then
	  	if score == 2 then
						func = Guide.transfer03
						Guide.addBigBoMm("魅惑魔女可以魅惑敌方的残血军团，这次派她上场吧。#n",450,250,0,0,90,0,func)
						Guide.changeMmImage(2)
						Guide.showMmButton()
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  })
						return
  		end
  end
  --第1-4主关换阵
  if adId == 8 and Guide.hasOrc() then
	  	if score == 2 then
						func = Guide.transfer04
						Guide.addBigBoMm("利用速度较快兽人步兵突击上路敌军。#n",450,250,0,0,90,0,func)
						Guide.changeMmImage(2)
						Guide.showMmButton()
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  })
						return
  		end
  end
  --第1-5主关换阵
  if adId == 10 and Guide.hasOrc() then
	  	if score == 2 then
						func = Guide.transfer05
						Guide.addBigBoMm("使用加速魔法提高魅惑魔女的出手速度。#n",450,250,0,0,90,0,func)
						Guide.changeMmImage(2)
						Guide.showMmButton()
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  })
						return
  		end
  end
  --第1-6主关换阵
  if adId == 12 and Guide.hasOrc() then
	  	if score == 2 then
						func = Guide.transfer06
						Guide.addBigBoMm("使用狮鹫奇袭敌方脆弱的后排军团。#n",450,250,0,0,90,0,func)
						Guide.changeMmImage(2)
						Guide.showMmButton()
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  })
						return
  		end
  end
	--第1-7主关换阵
	if adId == 14 and Guide.hasOrc() then
	  	if score == 2 then
						func = Guide.transfer07
						Guide.addBigBoMm("利用屠夫的肉钩技能打乱敌军的阵型。#n",450,250,0,0,90,0,func)
						Guide.changeMmImage(2)
						Guide.showMmButton()
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  })
						return
  		end
  end
  --第1-8主关换阵
	if adId == 16 then
	  	if score == 2 then
	  	--[[
						func = Guide.transfer08
						Guide.addBigBoMm("利用女猎手的射程优势减少斧王反击次数。#n",450,250,0,0,90,0,func)
						Guide.changeMmImage(2)
						Guide.showMmButton()
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  })
						return
			]]--
  		end
  end

  --1-1技能查看指引
  if adId == 2 then
	  	if process <2 then
					if Guide.getServerDataWithOrder(6102) == true then
						local worldPos = battlePrepareScene.grid:getWorldPostion(5, 2);
						Guide.__addGridTip(worldPos)
						Guide.addBigBoMm("掌握敌人的技能非常重要，来看看吧~",450,200,0)
						--强制引导
						eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1035 ,y= 400 ,w = 180 ,h = 130 }  }) 
						--
						Guide.changeMmImage(1)
						--Guide.toCloseGuid({6102},1)
						Guide.toOPENGuid({6101,6103},1)    
						return
					end
  		end
  end
  
  --检查是否需要军团指引
  if Guide.getServerDataWithOrder(3001) == true and Guide.playerShipHasNoActor() == true then	
  	Guide.addGuideShipActor( )
  	return
  end
  --检查是否需要魔法指引
  if Guide.getServerDataWithOrder(6001) == true and Guide.checkMagicBarHasNoMagic() == true then	
  	Guide.addprepareMagicBarTip()
  	return
  end
  Guide.addBattlePrePareBattleTip()	--在挑战按钮处添加箭头
end

function Guide.addBattlePrePareGuideCHALLENGE() --【核心】副本战备界面指引
	--Guide.clearAll()
	local func = Guide.transferC
	Guide.addBigBoMm("使用密集阵型保护我方远程军团。#n",450,250,0,0,90,0,func)
	Guide.changeMmImage(2)
	Guide.showMmButton()
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  })
end


function Guide.castMagicGuide() --【开场录像】魔法1指引
	if Guide.checkGridIs51() then
				Guide.clearAll()
				Guide.toCloseGuid({1004},1)
				Guide.toOPENGuid({1005,1101},1)
				Guide.nextPlayBattle()
				--强制指引，遮罩位置与大小需谨慎，可能需要根据文字长度自适应而改变
				eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 0 ,y= 0 ,w = 0 ,h = 0 }  }) 
	else
				--[[
				local name = "battle-skillitem1-xuanzhong"
				local ui =  ( engine.GetGUIWindowWithName(name));
				if ui then
					ui:SetVisible(true)
				end
				castMagic.signSkillGrid(3)
				]]--
	end
end

function Guide.battleSkip()
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE}) 
	sceneManager.battlePlayer():SkipBattle(true);
end

function Guide.friendlyUnitDead() --【操作】友军死亡指引
	if battlePrepareScene.copyID>=1 and battlePrepareScene.copyID<=7 and battlePlayer.rePlayStatus == false then
		local func = Guide.battleSkip
		local text = "我方一支军团全军覆没了，为了完美通关再战一次吧。#n"
		if battlePrepareScene.copyID == 2 then
			text = "敌方的魅惑技能导致我方内讧，再战一次吧。#n"
		elseif battlePrepareScene.copyID == 3 then
			text = "脆弱的后排被敌方奇袭，损失惨重，再战一次吧。#n"
		elseif battlePrepareScene.copyID == 4 then
			text = "对方火力太强，优先压制住敌方的主要火力点吧。#n"
		elseif battlePrepareScene.copyID == 5 then
			text = "敌方的狮鹫提高了出手速度，成功秒杀了我方军团。#n"
		elseif battlePrepareScene.copyID == 6 then
			text = "又是魅惑技能，为了完美通关再战一次吧。#n"
		elseif battlePrepareScene.copyID == 7 then
			text = "敌方发动了【为了部落】技能，输出了成吨的伤害。#n"
		end
		Guide.addBigBoMm(text,320,360,0,0,10,0,func)
		Guide.changeMmImage(2)
		Guide.showMmButton()
		Guide.pauseGame()
		--强制指引，遮罩位置与大小需谨慎，可能需要根据文字长度自适应而改变
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 720 ,y= 430 ,w = 103 ,h = 58 }  }) 
	end
end
function Guide.addBattlePrePareBattleTipF()
	Guide.addBattlePrePareBattleTip()
	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1137 ,y= 560 ,w = 96 ,h = 120 }  })  
end

function Guide.addSelShipActorGuideSP() --【操作】换人指引
	local copyX=battlePrepareScene.copyID
	local temp = copyX*2
	local star
	local stage =  dataManager.instanceZonesData:getStageWithAdventureID( temp,enum.Adventure_TYPE.NORMAL )
  if stage then
		star = stage:getVisStarNum()
	end
	if copyX>=1 and copyX<=7 and star == 2 then
		Guide.clearAll()
		if copyX == 2 then
			if Guide.curGuideEvent.arg1 == 4-1 then
			Guide.addSelShipActorUi(2)
			Guide.addBigBoMm("点击屠夫，将其换上战场。",300,350,0,0,0)
			Guide.changeMmImage(2)
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 676 ,y= 178 ,w = 478 ,h = 147 }  }) 
			else
			Guide.addActorTabUi(4)
			Guide.addBigBoMm("切换页签可以查看不同种族的兵种。",300,300,0,0,0)
			Guide.changeMmImage(2)
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1161 ,y= 381 ,w = 109 ,h = 67 }  }) 
			end
		elseif copyX == 3 then
			if Guide.curGuideEvent.arg1 == 3-1 then
			Guide.addSelShipActorUi(1)
			Guide.addBigBoMm("点击魅惑魔女，将其换上战场。",300,300,0,0,0)
			Guide.changeMmImage(2)
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 676 ,y= 31 ,w = 478 ,h = 147 }  }) 
			else
			Guide.addActorTabUi(3)
			Guide.addBigBoMm("这次选择暗夜种族页签。",300,300,0,0,0)
			Guide.changeMmImage(2)
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1161 ,y= 267 ,w = 109 ,h = 67 }  }) 
			end
		end
	end

end

function Guide.addSelShipActorGuideSPTAB() --【操作】换人指引-切换页签后
--（废弃）
end

function Guide.addBattlePrePareBattleTipSP()--【操作】换人指引-完成
	local copyX=battlePrepareScene.copyID
	local temp = copyX*2
	local star
	local stage =  dataManager.instanceZonesData:getStageWithAdventureID( temp,enum.Adventure_TYPE.NORMAL )
  if stage then
		star = stage:getVisStarNum()
	end
	if copyX>=1 and copyX<=3 and star == 2 then
		Guide.clearAll()
		if copyX == 2 then
			func = Guide.addBattlePrePareBattleTipF
			Guide.addBigBoMm("新换上的兵种不需要重新培养，根据需要随意切换吧~#n",450,250,0,0,90,0,func)
			Guide.changeMmImage(1)
			Guide.showMmButton()
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  }) 
		elseif copyX == 3 then
			func = Guide.addBattlePrePareBattleTipF
			Guide.addBigBoMm("根据策略需要可以随意切换兵种，不需要重新培养哦~#n",450,250,0,0,90,0,func)
			Guide.changeMmImage(1)
			Guide.showMmButton()
			eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 845 ,y= 320 ,w = 103 ,h = 58 }  }) 		
		end
	end

end


function Guide.checkSwapCorpSP()
	local copyX=battlePrepareScene.copyID
	local temp = copyX*2
	local star
	local stage =  dataManager.instanceZonesData:getStageWithAdventureID( temp,enum.Adventure_TYPE.NORMAL )
  if stage then
		star = stage:getVisStarNum()
	end
	if copyX>=1 and copyX<=3 and star == 2 then
		return true
	else
		return false
	end
end

function Guide.checkSwapCorpN_open()
	if Guide.getCurSELShipHasNoActor() and Guide.checkSwapCorpSP()==false then
		return true
	else
		return false
	end
end

function Guide.checkSwapCorpN_tab()
	if Guide.playerShipHasNoActor() and Guide.checkSwapCorpSP()==false then
		return true
	else
		return false
	end	
end

function Guide.checkSwapCorpN_finish()
	if Guide.checkSwapCorpSP()==false then
		return true
	else
		return false
	end	
end

function Guide.checkXiaoLuSpeedUp_stage()
	local copyX=battlePrepareScene.copyID
	if copyX ~= 5 then
		return false
	end
	local temp = copyX*2
	local star
	local stage =  dataManager.instanceZonesData:getStageWithAdventureID( temp,enum.Adventure_TYPE.NORMAL )
  if stage then
		star = stage:getVisStarNum()
	end
	if star == 2 then
		return true
	else
		return false
	end
end

function Guide.checkXiaoLuSpeedUp_myturn()
	if Guide.curGuideEvent.arg1 == 1 and Guide.checkXiaoLuSpeedUp_stage() then
		return true
	else
		return false
	end	
end

function Guide.checkXiaoLuSpeedUp_target()
	if Guide.checkXiaoLuSpeedUp_stage() then
		return true
	else
		return false
	end	
end

function Guide.checkXiaoLuSpeedUp_finish()
	if Guide.checkGridIs00SP() and Guide.checkXiaoLuSpeedUp_stage() then
		return true
	else
		return false
	end	
end

--小鹿指引选择魔法箭指引
function Guide.addMagicBarTipXiaoLu()
		local name = "battle-skillitem4"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order)
		Guide.addBigBoMm("加速魔法可以改变军团的行动顺序。",0,-300,1,0,10)
		Guide.changeMmImage(2)
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 590 ,y= 530 ,w = 104 ,h = 104 }  }) 
end
--小鹿加速指引魔法箭选择目标
function Guide.addGridTipXiaoLu()
		local worldPos = battlePrepareScene.grid:getWorldPostion(0, 0);
		Guide.addBigBoMm("对我方的魅惑魔女施放加速吧~",450,200,0,0,0);
		Guide.changeMmImage(1);
		eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 200 ,y= 210 ,w = 150 ,h = 100 }  })
		return Guide.__addGridTip(worldPos);
end


function Guide.addCorpGetTip()
		local process = dataManager.playerData:getAdventureNormalProcess()
		if process >=3 then
			Guide.toCloseGuid({5004},1)
		else
			local name = "corpsget1-button1"
			local clickImage =  ( engine.GetGUIWindowWithName(name));
			if clickImage then
				Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 
				eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 520 ,y= 605 ,w = 240 ,h = 60 }  }) 
			end
		end

end

function Guide.addIdolStatus_mainTip() --神像指引 
		if Guide.getServerDataWithOrder(17005) == true then
			Guide.addIdolStatus_levelupTip()
		else
			Guide.addIdolStatus_plunderTip()
		end
end	


function Guide.addIdolStatus_levelupTip() --神像升级指引 
		local name = "idolStatus-level"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		Guide.addBigBoMm("升级神像可以全方位提高军团的战斗能力。",-450,-220,1,1) 
		Guide.changeMmImage(2)
		--eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1135 ,y= 438 ,w = 124 ,h = 112 }  }) 
end	


function Guide.addIdolStatus_plunderTip() --神像抢夺指引 
		local name = "idolStatus-robthing1-button"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		Guide.addBigBoMm("掠夺是获取神像材料的重要途径，千万不要错过哦。",150,0,1,1) 
		Guide.changeMmImage(2)
		--eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1135 ,y= 438 ,w = 124 ,h = 112 }  }) 
end


function Guide.addIdolStatus_levelupTip2() --神像建造指引 
		local name = "idolStatusLevelup-jianzao"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order) 	
		Guide.addBigBoMm("只要材料和资源充足就可以升级神像哦。",250,-150,1,1) 
		Guide.changeMmImage(2)
		--eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,rect  =  {x = 1135 ,y= 438 ,w = 124 ,h = 112 }  }) 
end


function Guide.addIdolStatusLvUpCloseGuideTip() --神像升级完毕返回指引	 
	local name = "idolStatusLevelup-close"
	local clickImage =  ( engine.GetGUIWindowWithName(name));
	Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,180) 
	Guide.addBigBoMm("缺少升级材料就不能继续升级了，先去收集材料吧。",-700,200,1,1) 
	Guide.changeMmImage(2)

end

function Guide.addActivityCopyStartTip() --副本挑战，判断开战指引
	if dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_STAGE_TIMES)>0 then
		Guide.toCloseGuid({99989},1)
	else
		local name = "activitycopy-start"
		local clickImage =  ( engine.GetGUIWindowWithName(name));
		Guide._addMagicBarTip(clickImage,	Guide.curGuideEvent_data.order,0) 
		--Guide.addBigBoMm("缺少升级材料就不能继续升级了，先去收集材料吧。",-200,-500,1,1) 
		--Guide.changeMmImage(2)
	end

end