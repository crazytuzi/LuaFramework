castMagic = {};

castMagic.selectMagic = -1;
castMagic.selectGridX = -1;
castMagic.selectGridY = -1;
castMagic.isCanCast = false;
castMagic.isSending = false;

castMagic.lastClickGridX = -1;
castMagic.lastClickGridY = -1;

castMagic.specialbufferid_SoulHarvest = 119 


castMagic.skillSignUnitAttZhanSha  = {}
castMagic.skillSignUnitAttShensheng  = {}
castMagic.skillSignFloatArray  = {}
--RemoveSkillAttack

function castMagic.init()
	castMagic.selectMagic = -1;
	castMagic.selectGridX = -1;
	castMagic.selectGridY = -1;
	castMagic.isCanCast = false;
	castMagic.isSending = false;

	castMagic.lastClickGridX = -1;
	castMagic.lastClickGridY = -1;
	
end

function castMagic.signSkillGrid(selectMagic)
 
		local res = {}	
		castMagic.cleanSign()
		local skillinfo =  dataManager.kingMagic:getSkillConfig(selectMagic)	
		if(skillinfo == nil)then
			return res
		end
	
		local castside = skillinfo.targetType
		

		
		 if castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND then
			 	--友军			
			 	local friends = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive and v:isFriendlyForces())then
							
							table.insert(friends, {x = v.m_PosX,y = v.m_PosY})
						end						
				end						
				 res =   friends		
				 
		 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ENEMY then
			 	--敌军
			 	local other = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive and v:isFriendlyForces()== false)then
							table.insert(other, {x = v.m_PosX,y = v.m_PosY})
						end						
				end						
				 		
				res =   other  
				
				-----------------------------------------------------------------------------------------------------
				local aoeAttName = "zhanshatubiao.att";
					if(selectMagic == 72)then   ---斩杀
						for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
									if(v.m_bAlive and v:isFriendlyForces()== false  and v:getHPPercent() < 0.3 )then
										v:getActor():AddSkillAttack(aoeAttName, v:getActor(),false);
										table.insert(castMagic.skillSignUnitAttZhanSha, { unit = v, attname = aoeAttName} )
									end						
							end	
					end		
					
				---------------------------------------------------------------------------------------------	
					
	
					if(selectMagic == 5)then   ---神圣审批
							
						local level = dataManager.kingMagic:getMagic(selectMagic):getStar()
						local king = dataManager.battleKing[battlePlayer.force]
						if(king == nil)then
							king = dataManager.playerData
						end					
				
						local hurtLimit =   global.parseHurtLimitFormText(selectMagic, king:getIntelligence(),level)  
						local hurt = 0
						for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
									if(v.m_bAlive and v:isFriendlyForces()== false )then
										local hurt = battlePlayer.allHurtNum[v.index] or 0
										if(hurt > hurtLimit )then
											hurt = math.floor(hurtLimit)
										end
										--[[local hp = v:getTotalHP()
										hp = hp - hurt
										local reduceNum =  v.m_CropsNum - math.ceil( hp / v:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP))
										]]--
										reduceNum = hurt
										table.insert(castMagic.skillSignUnitAttShensheng, { unit = v, reduceNum = reduceNum,isLimit = (hurt == hurtLimit)} )
										v:showTipReduceInfo(reduceNum);
									end						
							end	
					end		
	 	
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_UNIT then
			 	--敌我双方
			  	local all = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive)then
							table.insert(all,{x = v.m_PosX,y = v.m_PosY})
						end						
				end												
				res =  all 
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_SPACE then
			 	--空地			
			  
				local empty_ground = {}				
			 									
				local col = battlePrepareScene.map:getColumns()	 -- 7			
				local row = battlePrepareScene.map:getRows() --3
								
				for i = 0,col -1 do				
					for j = 0,row -1   do    
						if(  ( i == col -1 and   (j == 0 or j == row -1)) == false  )then
							local Unit = sceneManager.battlePlayer():GetCropsByPosition(i , j )
							if(Unit == nil)then
								table.insert(empty_ground,{x = i ,y = j})
							end
						end											
					end
					
				end								
				res =  empty_ground
		
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ANY then
			 	 -- 任意地点
			 	 
				local empty_ground = {}												
				local col = battlePrepareScene.map:getColumns()				
				local row = battlePrepareScene.map:getRows()				
				for i = 0,col -1 do				
					for j = 0,row -1   do    
						if(  ( i == col -1 and   (j == 0 or j == row -1)) == false  )then											
							table.insert(empty_ground,{x = i ,y = j})
						end
																					
					end
					
				end							
				res =  empty_ground
				
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_NONE then	
				
				res = {}
				
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND_DEAD then		 ----友方死亡		
				
				local friends_dead = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive == false and v:isFriendlyForces() and  v:isSummonUnit() == false and v:hasSpecialBufferWithId(castMagic.specialbufferid_SoulHarvest)== false )then
				 
							table.insert(friends_dead, {x = v.m_PosX,y = v.m_PosY})
						end						
				end													
				res =  friends_dead			
			end	


	
 
		if(skillinfo.isAidDisplay == true )then
			local skillFloatArray = 	global.parseTextFloatArray(selectMagic)
			local size = #skillFloatArray  
			if( size > 0 )then
				local level = dataManager.kingMagic:getMagic(selectMagic):getStar()
				
				for i,v in ipairs (res) do
					
					local Unit = sceneManager.battlePlayer():GetCropsByPosition(v.x ,v.y )
					if(Unit and Unit.m_bAlive) then
						local sub = 	 Unit.starLevel - level
						if(sub <= 0 ) then 
							sub = 1 
						elseif(sub > size ) then 	
							sub = size
						else
							sub = sub +1	
						end	
						table.insert(castMagic.skillSignFloatArray, { unit = Unit} )
						Unit:showTipFloatArrayInfo(skillFloatArray[sub]);
					end	
				end
			end
		
		
		
		
		end
 
		for i,v in ipairs (res) do
			--if(castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ANY)then
					sceneManager.battlePlayer():signGrid(v.x,v.y,"r2");
			--else
					local unit = sceneManager.battlePlayer():GetCropsByPosition(v.x, v.y);
					if unit then
						if unit:isFriendlyForces() then
							sceneManager.battlePlayer():signGrid(v.x,v.y,"b2")
						else
							sceneManager.battlePlayer():signGrid(v.x,v.y,"r2")
						end
					else
						sceneManager.battlePlayer():signGrid(v.x,v.y,"r2");
					end
			
			--end
		
		end	
		return res			
end	



function castMagic.checkSkillCanCaste(selectMagic,level)
	
		local king = dataManager.battleKing[battlePlayer.force]
		if(king == nil)then
			king = dataManager.playerData
		end
	
	
		local rate = king:getCasterMPRate() 
 		local mp = king:getMp()	
		if(mp < 0 )then
			mp = 0
		end				
		local skillinfo =  dataManager.kingMagic:getSkillConfig(selectMagic)	
		if(skillinfo == nil)then
			return false
		end
	
		local cd = dataManager.kingMagic:getMagic(selectMagic):getCurCD()	
		local numOver = dataManager.kingMagic:getMagic(selectMagic):isNumOver()	
		local costMp  = skillinfo.cost[level] or skillinfo.cost[1]
		
		costMp = math.floor(costMp * rate +0.5)		
		
		if(numOver  or mp < costMp or cd > 0)then
			 return false
		end		
	    
		local castside = skillinfo.targetType
		local res = false	
		
		 if castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND then
			 	--友军			
			 	local friends = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive and v:isFriendlyForces())then
							table.insert(friends,v)
						end						
				end						
				 res =  #friends > 0			
				 
		 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ENEMY then
			 	--敌军
			 	local other = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive and v:isFriendlyForces()== false)then
							table.insert(other,v)
						end						
				end						
				 		
				res =  #other > 0
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_UNIT then
			 	--敌我双方
			  	local all = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive)then
							table.insert(all,v)
						end						
				end												
				res =  #all > 0
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_SPACE then
			 	--空地			
			  
				local empty_ground = {}				
			 									
				local col = battlePrepareScene.map:getColumns()	 -- 7			
				local row = battlePrepareScene.map:getRows() --3
								
				for i = 0,col -1 do				
					for j = 0,row -1   do    
						if(  ( i == col -1 and   (j == 0 or j == row -1)) == false  )then
							local Unit = sceneManager.battlePlayer():GetCropsByPosition(i , j )
							if(Unit == nil)then
								table.insert(empty_ground,{x = i ,y = j})
							end
						end											
					end
					
				end								
				res =  #empty_ground > 0
		
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ANY then
			 	 -- 任意地点
			 	 
				local empty_ground = {}												
				local col = battlePrepareScene.map:getColumns()				
				local row = battlePrepareScene.map:getRows()				
				for i = 0,col -1 do				
					for j = 0,row -1   do    
						if(  ( i == col -1 and   (j == 0 or j == row -1)) == false  )then											
							table.insert(empty_ground,{x = j ,i = j})
						end
																					
					end
					
				end							
				res =  #empty_ground > 0
				
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_NONE then	
				
				res = true
				
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND_DEAD then		 ----友方死亡		
				
				local friends_dead = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive == false and v:isFriendlyForces() and  v:isSummonUnit() == false and v:hasSpecialBufferWithId(castMagic.specialbufferid_SoulHarvest)== false  )then
							table.insert(friends_dead,v)
						end						
				end													
				res =  #friends_dead > 0			
			end	
		return res			
end	
	
function castMagic.randomSkill(selectMagic)
	
	if castMagic.isSending then
		return;
	end
		
	if(selectMagic <= 0)then
		--castMagic.sendCancelMagic()
		return
	end
	
     castMagic.selectMagic = 	selectMagic
	 local skillinfo = dataConfig.configs.magicConfig[selectMagic]
	 local castside = enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_INVALID;
	 if skillinfo then
			 castside = skillinfo.targetType
	 end
		
			 local selectUnit = nil	
			 if castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND then
			 	--友军			
			 	local friends = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive and v:isFriendlyForces())then
							table.insert(friends,v)
						end						
				end						
				local random_key = math.random(1,#friends)				
				selectUnit = friends[random_key]				
				castMagic.selectGridX, castMagic.selectGridY  = selectUnit.m_PosX, selectUnit.m_PosY
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ENEMY then
			 	--敌军
			 	local other = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive and v:isFriendlyForces() == false)then
							table.insert(other,v)
						end						
				end						
				local random_key = math.random(1,#other)				
				selectUnit = other[random_key]	
				castMagic.selectGridX, castMagic.selectGridY  = selectUnit.m_PosX, selectUnit.m_PosY
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_UNIT then
			 	--敌我双方
			  	local all = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive)then
							table.insert(all,v)
						end						
				end						
				local random_key = math.random(1,#all)				
				selectUnit = all[random_key]	
				castMagic.selectGridX, castMagic.selectGridY  = selectUnit.m_PosX, selectUnit.m_PosY
			 	
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_SPACE then
			 	--空地
			  
			  
				local empty_ground = {}				
			 									
				local col = battlePrepareScene.map:getColumns()	 -- 7			
				local row = battlePrepareScene.map:getRows() --3
				
				
				for i = 0,row -1 do				
					for j = 0,col -1   do    
						if(  ( i == col -1 and   (j == 0 or j == row -1)) == false  )then
							local Unit = sceneManager.battlePlayer():GetCropsByPosition(i , j )
							if(Unit == nil)then
								table.insert(empty_ground,{x = j ,y = i})
							end
						end											
					end
					
				end
				local random_key = math.random(1,#empty_ground)				
				castMagic.selectGridX, castMagic.selectGridY  = empty_ground[random_key].x,empty_ground[random_key].y	
		
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ANY then
			 	 -- 任意地点
			 	 
				local empty_ground = {}												
				local col = battlePrepareScene.map:getColumns()				
				local row = battlePrepareScene.map:getRows()				
				for i = 0,row -1 do				
					for j = 0,col -1   do    
						if(  ( i == col -1 and   (j == 0 or j == row -1)) == false  )then											
							table.insert(empty_ground,{x = j ,y = i})
						end
																					
					end
					
				end
				local random_key = math.random(1,#empty_ground)				
				castMagic.selectGridX, castMagic.selectGridY  = empty_ground[random_key].x,empty_ground[random_key].y		
				
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_NONE then	
				-- do nothing
					castMagic.selectGridX, castMagic.selectGridY = 0,0
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND_DEAD then		 ----友方死亡		

				local friends_dead = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive == false and v:isFriendlyForces() and  v:isSummonUnit() == false and v:hasSpecialBufferWithId(castMagic.specialbufferid_SoulHarvest)== false )then
							table.insert(friends_dead,v)
						end						
				end						
				local random_key = math.random(1,#friends_dead)				
				selectUnit = friends_dead[random_key]				
				castMagic.selectGridX, castMagic.selectGridY  = selectUnit.m_PosX, selectUnit.m_PosY
				
			end
			--echoInfo("castMagic.randomSkill skill id = %d x = %d y = %d ",castMagic.selectMagic,castMagic.selectGridX,castMagic.selectGridY)
			sceneManager.battlePlayer():signGrid(castMagic.selectGridX, castMagic.selectGridY, "r2")
			castMagic.isCanCast = true			
			castMagic.sendMagic();
end

function castMagic.triggerClickEffect(pos)

	if sceneManager.battlePlayer() and battlePrepareScene.grid then		
	 	local ishit = battlePrepareScene.grid:isHitGrid(pos);
	 	if ishit then
		
			local gridX = battlePrepareScene.grid:getHitX();
			local gridY = battlePrepareScene.grid:getHitY();
			
			--if gridX ~= castMagic.lastClickGridX or gridY ~= castMagic.lastClickGridY then
				
			--	castMagic.lastClickGridX = gridX;
			--	castMagic.lastClickGridY = gridY;
				
			--	battlePrepareScene.clickEffectInCastMagic(castMagic.lastClickGridX, castMagic.lastClickGridY);
				
			--end
			battlePrepareScene.clickEffectInCastMagic(gridX, gridY);
		end
	end
		
end

function castMagic.triggerClickMoveEffect(pos)
	
	if sceneManager.battlePlayer() and battlePrepareScene.grid then		
	 	local ishit = battlePrepareScene.grid:isHitGrid(pos);
	 	if ishit then
		
			local gridX = battlePrepareScene.grid:getHitX();
			local gridY = battlePrepareScene.grid:getHitY();
			
			if gridX ~= castMagic.lastClickGridX or gridY ~= castMagic.lastClickGridY then
				
				castMagic.lastClickGridX = gridX;
				castMagic.lastClickGridY = gridY;
				
				battlePrepareScene.clickEffectInCastMagic(castMagic.lastClickGridX, castMagic.lastClickGridY, true);
				
			end

		end
	end
	
end

function castMagic.cancelClickMoveEffect()
	
	castMagic.lastClickGridX = -1;
	castMagic.lastClickGridY = -1;
	
	battlePrepareScene.disableAllHighlight();
	
end


function castMagic.SelectTarget(pos)
		
		if castMagic.isSending then
			return;
		end
		

		if castMagic.selectMagic ~= -1 and sceneManager.battlePlayer().wait_action == true then
			 
			 local skillinfo = dataConfig.configs.magicConfig[castMagic.selectMagic];
			 local castside = enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_INVALID;
			 local shape = enum.MAGIC_SHAPE.MAGIC_SHAPE_POINT;
			 local scope = 0;
			 if skillinfo then
				castside = skillinfo.targetType;
				shape = skillinfo.shape;
				scope = skillinfo.scope;
			 end
			 
			-- 查询选中的格子
			castMagic.selectGridX = -1;
			castMagic.selectGridY = -1; 
			
			 castMagic.isCanCast = false;
			 if sceneManager.battlePlayer() and battlePrepareScene.grid then		
			 	local ishit = battlePrepareScene.grid:isHitGrid(pos);
			 	if ishit then
			 		castMagic.selectGridX = battlePrepareScene.grid:getHitX();
			 		castMagic.selectGridY = battlePrepareScene.grid:getHitY();
			 		--castMagic.highlightGrid(shape, scope, castMagic.selectGridX, castMagic.selectGridY);
			 		
			 	--[[------------不查包围盒了-----------------------
			 	else
			 		-- 格子没查到，查包围盒
			 		local actorManager = LORD.ActorManager:Instance()
					local actor = actorManager:RayPickActor(pos.x,pos.y)		
					if(actor ~= nil )then
						local cropsUnit = sceneManager.battlePlayer().m_AllCrops[actor:getUserData()];
						castMagic.selectGridX = cropsUnit.m_PosX;
						castMagic.selectGridY = cropsUnit.m_PosY;
					end
				--]]-----------------------------------
			 	end
			 end
			 
			 -- 规则检查
			 local selectUnit = sceneManager.battlePlayer():GetCropsByPosition(castMagic.selectGridX, castMagic.selectGridY);
			 if castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND then
			 	--友军
			 	if selectUnit and selectUnit:isFriendlyForces() then
			 		castMagic.isCanCast = true;
			 	else
			 		castMagic.isCanCast = false;
			 	end
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ENEMY then
			 	--敌军
			 	if selectUnit and (not selectUnit:isFriendlyForces()) then
			 		castMagic.isCanCast = true;
			 	else
			 		castMagic.isCanCast = false;
			 	end
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_UNIT then
			 	--敌我双方
			 	if selectUnit then
			 		castMagic.isCanCast = true;
			 	else
			 		castMagic.isCanCast = false;
			 	end
			 	
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_SPACE then
			 	--空地
			 	if (not selectUnit) and castMagic.selectGridX ~= -1 and castMagic.selectGridY ~= -1 then
			 		castMagic.isCanCast = true;
			 	else
			 		castMagic.isCanCast = false;
			 	end
			 	
			 elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ANY then
			 	 -- 任意地点
			 	if castMagic.selectGridX ~= -1 and castMagic.selectGridY ~= -1 then
			 		castMagic.isCanCast = true;
			 	else
			 		castMagic.isCanCast = false;
			 	end
				
				
			elseif castside == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ANY then		 ----友方死亡		
				
				local friends_dead = {}				
				for k,v in pairs( sceneManager.battlePlayer().m_AllCrops)do				
						if(v.m_bAlive == false and v:isFriendlyForces())then
							table.insert(friends_dead,v)
						end						
				end						
				local size =  #friends_dead						
				castMagic.isCanCast = size> 0;			
			 end			 
		end
		
		if(castMagic.isCanCast)then
				-- 清除所有高亮
				---sceneManager.battlePlayer():setAllGridNormal();
		end
		
		 
		if castMagic.selectGridX ~= -1 and castMagic.selectGridY ~= -1 then
			--print(" castMagic.selectGridX "..castMagic.selectGridX.." castMagic.selectGridY"..castMagic.selectGridY)
			eventManager.dispatchEvent( {name = global_event.GUIDE_ON_BATTLE_CLICK_GRID ,arg1 = castMagic.selectGridX,arg2 = castMagic.selectGridY } )
		end
			
end

function castMagic.SelectMagic(index)
		if castMagic.isSending then
			return;
		end
		
	 	castMagic.cleanUp();
	 	local playerSkill = getEquipedMagicServerData(index);
 		if playerSkill then
 			local skillinfo =   dataManager.kingMagic:getSkillConfig(playerSkill.id)
 			if skillinfo then
 				castMagic.selectMagic = playerSkill.id;
 				if skillinfo.targetType == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_NONE or skillinfo.targetType == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND_DEAD then	
						castMagic.selectGridX, castMagic.selectGridY = 0,0		---------解决服务器的bug 		MAGIC_TARGET_TYPE_NONE 要求xy为地图内的点 不能为-1 -1 	
 						castMagic.isCanCast = sceneManager.battlePlayer().wait_action;
 						castMagic.sendMagic();
 				end
 			end
 		end
end

function castMagic.cleanUp()
	castMagic.selectMagic = -1;
	castMagic.isCanCast = false;
	--castMagic.selectGridX = -1;
	--castMagic.selectGridY = -1;
end

function castMagic.cleanSign()
	
	-- 清除所有高亮
	sceneManager.battlePlayer():setAllGridNormal();
	
	for i,v in ipairs(castMagic.skillSignUnitAttZhanSha) do
		if(v and v.unit)then
			v.unit:getActor():RemoveSkillAttack(v.attname) 
		end
	end	
	castMagic.skillSignUnitAttZhanSha = {}
	
	
	for i,v in ipairs(castMagic.skillSignUnitAttShensheng) do
		if(v.unit)then
			v.unit:hideTipReduceInfo();
		end	
	end	
	castMagic.skillSignUnitAttShensheng= {}
	
	for i,v in ipairs(castMagic.skillSignFloatArray) do
		if(v.unit)then
			v.unit:hideTipFloatArrayInfo();
		end	
	end	
	castMagic.skillSignFloatArray= {}
end

function castMagic.sendMagic()

	if  not castMagic.isCanCast then
		eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "请选择高亮格子施放魔法！"});
		return 
	end	

	if castMagic.isCanCast and not castMagic.isSending then
		castMagic.cleanSign()	
		if( castMagic.selectMagic == 5 )then   --- 神圣审批
			----battlePlayer.allHurtNum  
		end
		-- 清理正在施法的标志位
		sceneManager.battlePlayer().turn_self_caster_magic = nil;		
		
		if(battlePlayer.rePlayStatus ~= true )then
			castMagic.isSending = true;
			sendMagic(castMagic.selectMagic, castMagic.selectGridX, castMagic.selectGridY);		
			castMagic.cleanUp();
		end
	end

end

function castMagic.autoKingSkill()
	castMagic.cleanSign()		
	sceneManager.battlePlayer().turn_self_caster_magic = nil;
	sendMagic(-1,0,0);		
end


function castMagic.sendCancelMagic()
	castMagic.cleanUp();
end

function castMagic.highlightGrid(shape, scope, x, y)
	
	-- 选中的那个高亮
	sceneManager.battlePlayer():signGrid(x, y, "r2");
	
	-- 判断其他的
	if shape == enum.MAGIC_SHAPE.MAGIC_SHAPE_CIRCLE then
		-- 圆形
		local column = battlePrepareScene.map:getColumns();
		local row = battlePrepareScene.map:getRows();
				
		for i = 0, row-1 do
			for j = 0, column-1 do			
				local d = battleDistance.distance(x, y, j, i);
				if d and d <= scope then
					sceneManager.battlePlayer():signGrid(j, i, "r2");
				end
			end
		end
		
	end
	
end

