local AutoConfigNode = class("AutoConfigNode", function() return cc.Node:create() end)
AutoConfigNode.showList = {}

function AutoConfigNode:ctor(propId,c_type,countDown,tag,params,npc_node,specialForEquip)
	if (c_type == 2 and getGameSetById(GAME_SET_EQUIPTIP) == 0) or 
		(c_type ~= 2 and MPackStruct:getCategoryByPropId(propId) ~= MPackStruct.eMedicine and getGameSetById(GAME_SET_PROPTIP) == 0) then
		return
	end
	-- print("propId================",MPackStruct.protoIdFromGird(params.gird))
	--玩家获得的第一件装备不弹出快捷提示，进入背包引导
	if params then
		if MPackStruct.protoIdFromGird(params.gird) == 2000501 + MRoleStruct:getAttr(ROLE_SCHOOL) *10000 + (MRoleStruct:getAttr(PLAYER_SEX) - 1) *1000 then 
			return 
		end
	end



	self.specialForEquip = specialForEquip
	if params then
		self.replaceGirdId = params.replaceGirdId
	end
	self.c_type = c_type or 1
	if c_type == 2 then
		countDown = nil
	end
	self:init(propId,countDown,tag,params,npc_node)
end

function AutoConfigNode:init(propId,countDown,tag,params,npc_node)
	local type_map = {
		-- 普通物品
		[1] = {menu_str = game.getStrByKey("useNow")},
		--装备
		[2] = {menu_str = game.getStrByKey("auto_equipment")},
		--卷轴
		[3] = {},
	}
	local bg = createSprite(self, "res/tuto/images/autobg.png", cc.p(display.width-200, display.height/2), cc.p(0.5, 0.5))
	Mnode.listenTouchEvent(
	{
		node = bg,
		swallow = true,
		begin = function(touch, event)
			print("touch")
			local touchOutside = Mnode.isTouchInNodeAABB(bg, touch)
			return touchOutside
		end,
	})
	local bg_size = bg:getContentSize()
	--local string = getConfigItemByKey("propCfg","q_id",propId,"q_name")
	local buttonFun = function()
		if G_ROLE_MAIN and MRoleStruct:getAttr(ROLE_LEVEL) >= 30 and MPackStruct:getCategoryByPropId(propId) == MPackStruct.eMedicine then
			G_MAINSCENE:buyDrug(propId,true)
		end
		local function UseItemByProtoId(propId)
			if G_ROLE_MAIN and G_ROLE_MAIN:isAlive() then 
				local MPackManager = require "src/layers/bag/PackManager"
				return MPackManager:useByProtoId(propId)
			end
		end
		UseItemByProtoId(propId)
		removeFromParent(self)
		if npc_node then
			--g_msgHandlerInst:sendNetDataByFmtExEx(DIGMINE_CS_DIGMINE,"is",userInfo.currRoleId,npc_node:getTag())
		end
	end
	local p_num= nil
	local pack = MPackManager:getPack(MPackStruct.eBag)
	if self.c_type == 2 then		
		local Mconvertor = require "src/config/convertor"
		local dressPack = MPackManager:getPack(MPackStruct.eDress)	
		buttonFun = function()
			local girdId = MPackStruct.girdIdFromGird(params.gird)
			dump(params.battle)
			dump(MPackStruct.attrFromGird(params.gird, MPackStruct.eAttrCombatPower))

			local function dress()
				if params.battle == MPackStruct.attrFromGird(params.gird, MPackStruct.eAttrCombatPower) then
					MPackManager:dress(girdId)
				else
					TIPS({type = 1, str = game.getStrByKey("tip_equipment_changed")})
				end
				AutoConfigNode.showList[propId] = 0
				table.remove(G_SETPOSTEMPE,1)
        		removeFromParent(self)
        		G_MAINSCENE:setEquip()
			end
			local function noDress()
				AutoConfigNode.showList[propId] = 0
				table.remove(G_SETPOSTEMPE,1)
        		removeFromParent(self)
        		G_MAINSCENE:setEquip()
			end
			-- if not self:checkYourDress(params.gird) then
			-- 	local mbox = getRunScene():getChildByTag(8989)
			-- 	if not mbox then
			-- 		local equ = MessageBoxYesNo(nil,game.getStrByKey("tipForEp") ,dress,noDress,game.getStrByKey("tipForDress"))
			-- 		equ:setTag(8989)
			-- 	end
			-- else
				dress()
			-- end
			
		end
		----------------------------------------
		if params then
			-- local pack = MPackManager:getPack(MPackStruct.eBag)
			local tmp_node = cc.Node:create()
			local tmp_func = function(observable, event, pos, pos1, new_grid)
				if event == "-" or event == "+" or event == "=" or event == "reset" then
					local girdId = MPackStruct.girdIdFromGird(params.gird)
					local girdPropNum = pack:numOfOverlay(girdId)
					local girdPropId = pack:protoId(girdId)
					if not girdPropNum or (girdPropId and girdPropId ~= propId) then
						removeFromParent(bg) 
						bg = nil 
						table.remove(G_SETPOSTEMPE,1)
		        		removeFromParent(self)
		        		G_MAINSCENE:setEquip()
					end
				end
			end

			tmp_node:registerScriptHandler(function(event)
				if event == "enter" then
					pack:register(tmp_func)
				elseif event == "exit" then
					pack:unregister(tmp_func)
				end
			end)
			bg:addChild(tmp_node)
		end
		----------------------------------------------
		--战斗力
		local f_bg = createSprite(bg, "res/common/misc/powerbg_s.png", cc.p(bg_size.width/2, 5), cc.p(0.5, 1.0))
		f_bg:setScaleX(0.7)
		local fightBg = createSprite(bg, "res/common/misc/power_b.png", cc.p(40, 5), cc.p(0.0, 1.0))
		fightBg:setScale(0.7)
		if params.addBattle then
			local  labelAtlas = MakeNumbers:create("res/component/number/10.png",params.addBattle,-2)
			fightBg:addChild(labelAtlas)
			--labelAtlas:setAnchorPoint(cc.p(0, 0.5))
			labelAtlas:setPosition(150, 35)
		end
		--createSprite(bg, "res/tuto/images/4.png", cc.p(170, 260), cc.p(0.5, 0.5))
		propId = MPackStruct.protoIdFromGird(params.gird)
		createSprite(bg, "res/group/arrows/1.png", cc.p(20, 0), cc.p(0, 1.0))
		if G_MAINSCENE and AutoConfigNode.showList[propId] then
			if AutoConfigNode.showList[propId] == params.battle and self.specialForEquip then				
				-- startTimerAction(self, 0.5, false, function() removeFromParent(bg) bg = nil removeFromParent(self) end)
				local locL, locR = nil, nil
				local dealWithDouble = function()
					local cur_l_grid = dressPack:getGirdByGirdId(locL)
					local cur_r_grid = dressPack:getGirdByGirdId(locR)
					if cur_r_grid or cur_l_grid then
						removeFromParent(bg) 
						bg = nil 
						table.remove(G_SETPOSTEMPE,1)
		        		removeFromParent(self)
		        		G_MAINSCENE:setEquip()
					end
				end
				if equipId == Mconvertor.eCuff then -- 护腕
					locL = MPackStruct.eCuffLeft
					locR = MPackStruct.eCuffRight
					dealWithDouble()
				elseif equipId == Mconvertor.eRing then -- 戒指
					locL = MPackStruct.eRingLeft
					locR = MPackStruct.eRingRight
					dealWithDouble()
				else
					removeFromParent(bg) 
					bg = nil 
					table.remove(G_SETPOSTEMPE,1)
	        		removeFromParent(self)
	        		G_MAINSCENE:setEquip()
				end
				
			else				
				AutoConfigNode.showList[propId] = params.battle
			end
		else
			AutoConfigNode.showList[propId] = params.battle
			AudioEnginer.playEffect("sounds/uiMusic/ui_item.mp3",false)
		end
	elseif self.c_type == 3 then
		-- local pack = MPackManager:getPack(MPackStruct.eBag)
		p_num = pack:countByProtoId(propId)
		MPackManager:organize(MPackStruct.eBag)  --整理物品
	
		buttonFun = function()
			local expNum = pack:countByProtoId(propId)
			if expNum == 0 then
				TIPS( { type = 1 , str = "^c(yellow)"..game.getStrByKey("notInBag").."^" }  )
			else
				local function UseItemByProtoId(propId)
					return MPackManager:useByProtoId(propId,expNum)
				end
				UseItemByProtoId(propId)
			end
			removeFromParent(self)
		end
	end

	local Mprop = require( "src/layers/bag/prop")
	local MpropOp = require("src/config/propOp")
	local iconSpr = nil
	if params then
		local girdId = MPackStruct.girdIdFromGird(params.gird)
		local gird = pack:getGirdByGirdId(girdId)
	  	iconSpr = Mprop.new(
		{
			grid = gird,
			swallow = true,
			num = p_num,
			cb = "tips",
		})
	else
		iconSpr = Mprop.new(
		{
			protoId = propId,
			swallow = true,
			num = p_num,
			cb = "tips",
		})
	end
	if bg then
  		bg:addChild(iconSpr)
	  	iconSpr:setPosition(cc.p(bg_size.width/2,bg_size.height-90))
	  	local nameStr = MpropOp.name(propId)
	  	createLabel(bg, nameStr, cc.p(bg_size.width/2,145), cc.p(0.5, 0.5), 20, nil, nil, nil, MpropOp.nameColor(propId))

		local menuItem = createMenuItem(bg, "res/component/button/50.png", cc.p(bg_size.width/2, 70), buttonFun)
		menuItem:setScale(0.95)
		local menu_str = type_map[self.c_type].menu_str or game.getStrByKey("useNow")
		local menu_lable = addLableToMenuItem(menuItem,menu_str,20,MColor.lable_yellow)
		createTouchItem(bg,"res/component/button/x3.png",cc.p(bg_size.width-25,bg_size.height-25),function() 
				AutoConfigNode.showList[propId] = 0
				if self.c_type == 2 then
					table.remove(G_SETPOSTEMPE,1)
	        		removeFromParent(self)
	        		G_MAINSCENE:setEquip()
	        	else
	        		removeFromParent(self)
				end
			end)
		menuItem:blink()
		G_TUTO_NODE:setTouchNode(menuItem,TOUCH_AUTOCONFIG_USE)
		if G_MAINSCENE.tipLayer then
			if tag then
				G_MAINSCENE.tipLayer:addChild(self,0,tag)
			else
				G_MAINSCENE.tipLayer:addChild(self,0)
			end
			if countDown then
				self.autoActionTime = countDown
				if self.autoActionTime <= 0 then
					buttonFun()
				end
				menu_lable:setString(menu_str.."("..self.autoActionTime..")")
				local function countDownFunc()
					self.autoActionTime = self.autoActionTime - 1
					if self.autoActionTime <= 0 then
						buttonFun()
					else
						menu_lable:setString(menu_str.."("..self.autoActionTime..")")
					end
				end

				if self:getParent() then
					startTimerAction(self, 1, true, countDownFunc)
				end
			end
			G_TUTO_NODE:setShowNode(self,SHOW_AUTOCONFIG)
		end
	end
end
--[[
function AutoConfigNode:checkYourDress(gird)
	-- local dressPack = MPackManager:getPack(MPackStruct.eDress)
	-- local replaceGird = dressPack:getGirdByGirdId(replaceGirdId)
	-- local newBattle = MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower)
	-- local oldBattle = MPackStruct.attrFromGird(replaceGird, MPackStruct.eAttrCombatPower) or 0

	-- if newBattle > oldBattle then
	-- 	return true
	-- else
	-- 	return false
	-- end

	local dressPack = MPackManager:getPack(MPackStruct.eDress)
	local bagPack = MPackManager:getPack(MPackStruct.eBag)
	local replaceGirdId = nil
	local replaceGirdBattle = nil

	--当前新装备战斗力
	local battleNew = MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower)
	--新装备类型
	local protoId = MPackStruct.protoIdFromGird(gird)
	local kind = require("src/config/equipOp").kind(protoId)

	--老装备战斗力
	--local bag = MPackManager:getPack(MPackStruct.eBag)
	for i=MPackStruct.eWeapon, MPackStruct.eMedal do
		while true do
			-- log("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii = "..i)
			--如果是同一装备位置
			if MPackStruct.equipId(i) == kind then
				log("test 1")
				local dressGird = dressPack:getGirdByGirdId(i)
				local battleOld

				--dressGird = nil 表明该格子没装备任何东西
				if dressGird == nil then
					-- log("dressGird = nilaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
					battleOld = 0
				else
					--套装检测
					local MequipOp = require "src/config/equipOp"
					local Mconvertor = require "src/config/convertor"
					local protoIdOld = MPackStruct.protoIdFromGird(dressGird)
					local isSuit = MequipOp.isSuit(protoIdOld)
					-- print(isSuit,"cccccccccccccccccccccccccccccccccccc")
					if isSuit then
						if kind ~= Mconvertor.eRing and kind ~= Mconvertor.eCuff then
							return
						else
							break
						end
					end

					battleOld = MPackStruct.attrFromGird(dressGird, MPackStruct.eAttrCombatPower)
				end
				-- print(battleOld,battleNew,"dddddddddddddddddddddddddddddddddddd")
				--如果新装备战斗力比老装备战斗力高
				if battleNew > battleOld then
					--如果有几个老装备对应同一个位置则选择战斗力最低的替换
					if replaceGirdId == nil then
						log("test 7")
						replaceGirdId = i
						replaceGirdBattle = battleOld
					else
						if battleOld < replaceGirdBattle then
							log("test 8")
							replaceGirdId = i
							replaceGirdBattle = battleOld
						end
					end
				end
			end
			break
		end
	end
	if replaceGirdId ~= nil then
		self.replaceGirdId = replaceGirdId
		return true
	else
		return false
	end	
end
]]
return AutoConfigNode