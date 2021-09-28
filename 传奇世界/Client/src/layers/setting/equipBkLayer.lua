local equipBkLayer = class("equipBkLayer",require ("src/TabViewLayer") )

function equipBkLayer:ctor(equip,school,sex,weaponKind)
	-- local bg = cc.Layer:create()
	-- bg:setContentSize(cc.size(380,450))
	-- bg:setPosition(pos)
	self.weaponKind = weaponKind
	self.MpropOp = require("src/config/propOp")
	self.equipTable = {}
	self.equipTable1 = {}
	self.equipTable2 = {}
	-- createLabel(self,string.format(game.getStrByKey("youngWeapon"),kindName).."(1-30级)",cc.p(543,530),nil,24,true,nil,nil,MColor.lable_yellow)
	-- createLabel(self,string.format(game.getStrByKey("oldWeapon"),kindName).."(30级以上)",cc.p(543,310),nil,24,true,nil,nil,MColor.lable_yellow)
	-- self.equipHad = unserialize(equipStr)
	-- self:addChild(bg)
	-- bg:runAction(cc.MoveTo:create(0.1,pos))
	-- self.bg = bg

	self.lastTouch = {}
	local tab2 = {}
	local equip_tab = getConfigItemByKey("equipCfg","q_id")
	for k,v in pairs(equip_tab)do
		if equip == v.q_kind then
			table.insert(tab2,v)
		end
	end
	table.sort(tab2, function(a , b ) return a.q_id<b.q_id end )
    for k,v in pairs(tab2) do
        if v.isread and tonumber(v.isread) == 1 and (v.q_sex == sex or v.q_sex == 0) then
        	if getConfigItemByKey("propCfg","q_id",v.q_id,"q_job") == school or getConfigItemByKey("propCfg","q_id",v.q_id,"q_job") == 0 then
            	local pinzhi = getConfigItemByKey("propCfg","q_id",v.q_id,"q_default")
            	if v.F3 <= 30 then
            		self.equipTable[#self.equipTable+1] = v.q_id
            	elseif pinzhi >= 1 and pinzhi <= 4 and v.F3 > 30 then
            		self.equipTable1[#self.equipTable1+1] = v.q_id
            	elseif pinzhi == 5 and v.F3 >= 40 then            	
            		self.equipTable2[#self.equipTable2+1] = v.q_id
            	end
            end
        end
    end

    local num , num1 , num2 = 0,0,0
	num = ((#self.equipTable % 5 == 0) and (#self.equipTable / 5)) or math.floor(#self.equipTable / 5) + 1
	num1 = ((#self.equipTable1 % 5 == 0) and (#self.equipTable1 / 5)) or math.floor(#self.equipTable1 / 5) + 1
	num2 = ((#self.equipTable2 % 5 == 0) and (#self.equipTable2 / 5)) or math.floor(#self.equipTable2 / 5) + 1
	self.num = num
	self.num1 = num1
	self.num2 = num2
    self:createTableView(self,cc.size(800,450) , cc.p(0,75) ,true,true )
end

function equipBkLayer:tableCellTouched(table,cell)
	
end

function equipBkLayer:cellSizeForTable(table,idx)
	if idx == 0 or idx == self.num+1 or idx == self.num + self.num1 + 2 then
		return 50,800
	else
		return 180,800
	end
end

function equipBkLayer:showTip(temp)
	if self:isVisible() then
		local MpropOp = require "src/config/propOp"
		local protoId = temp
		local equipCanCompound = MpropOp.equipCanCompound(protoId)
		local actions = nil
		if equipCanCompound then
			actions = {}
			actions[#actions+1] = 
			{
				label = "合成",
				cb = function(act_params)
					MequipCompound = require "src/layers/equipment/equipCompound"
					local Manimation = require "src/young/animation"
					Manimation:transit(
					{
						ref = getRunScene(),
						node = MequipCompound.new({ protoId=protoId }),
						--trend = "-",
						zOrder = 200,
						curve = "-",
						swallow = true,
					})
				end,
			}
		end
		
		local Mtips = require "src/layers/bag/tips"
		Mtips.new({ protoId = temp, actions = actions })
	end
end

function equipBkLayer:tableCellAtIndex(tableView,idx)

	local cell = tableView:dequeueCell()
	if cell == nil then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end
	if idx == 0 then
		createSprite(cell,"res/common/bg/bg12-3.png",cc.p(400,30))
		createLabel(cell,string.format(game.getStrByKey("youngWeapon"),self.weaponKind),cc.p(400,30),nil,26,true,nil,nil,MColor.lable_yellow)
	elseif idx == self.num+1 then
		createSprite(cell,"res/common/bg/bg12-3.png",cc.p(400,30))
		createLabel(cell,string.format(game.getStrByKey("oldWeapon"),self.weaponKind),cc.p(400,30),nil,26,true,nil,nil,MColor.lable_yellow)
	elseif idx == self.num + self.num1 + 2 then
		createSprite(cell,"res/common/bg/bg12-3.png",cc.p(400,30))
		createLabel(cell,string.format(game.getStrByKey("godWeapon"),self.weaponKind),cc.p(400,30),nil,26,true,nil,nil,MColor.lable_yellow)
	else
		local tabTemp = {}
		local idxTemp,idxTemp1,idxTemp2 = 0,0,5*idx-4
		if idx > 0 and idx < self.num+1 then
			tabTemp = self.equipTable
			idxTemp,idxTemp1 = 5*(idx-1)+1 , 5*(idx-1)+5
		elseif idx > self.num+1 and idx < self.num + self.num1 + 2 then
			tabTemp = self.equipTable1
			idxTemp,idxTemp1,idxTemp2 = 5*(idx-self.num-2)+1,5*(idx-self.num-2)+5,5*idx-9
		else
			tabTemp = self.equipTable2
			idxTemp,idxTemp1,idxTemp2 = 5*(idx-self.num-self.num1-3)+1 , 5*(idx-self.num-self.num1-3)+5,5*idx-14
		end
		local posx,posy = 100,100
		for i = idxTemp ,idxTemp1 do
			if tabTemp[i] then
				local Mprop = require "src/layers/bag/prop"
				local cellSpr = createSprite(cell,"res/common/bg/itemBg2.png",cc.p(posx,posy))
				local redPot = createSprite(cellSpr,"res/component/flag/red.png",cc.p(115,130),nil,5)

				if not self.MpropOp.equipCanCompound(tabTemp[i]) then
					redPot:setVisible(false)
				end
				local icon = Mprop.new(
				{
					protoId = tabTemp[i],
				})
				icon:setPosition(cc.p(70,90))
				local nameStr = self.MpropOp.name(tabTemp[i])
			  	createLabel(cellSpr, nameStr, cc.p(70,25), cc.p(0.5, 0.5), 20, nil, nil, nil, self.MpropOp.nameColor(tabTemp[i]))
				cellSpr:addChild(icon)
				local  listenner = cc.EventListenerTouchOneByOne:create()
			    listenner:setSwallowTouches(false)
				listenner:registerScriptHandler(function(touch, event)
					local pt = touch:getLocation()
					local ptTemp = pt		
					pt = icon:getParent():convertToNodeSpace(pt)
					if cc.rectContainsPoint(icon:getBoundingBox(),pt) then
						self.lastTouch[idxTemp2+i] = icon:getParent():convertToWorldSpace( ptTemp )		
						return true
					end
			    	end,cc.Handler.EVENT_TOUCH_BEGAN )

				listenner:registerScriptHandler(function(touch,event)
					local pt = touch:getLocation()
					local theTouch = icon:getParent():convertToWorldSpace( pt )
					pt = icon:getParent():convertToNodeSpace(pt)
					if self.lastTouch and math.abs(self.lastTouch[idxTemp2+i].x - theTouch.x) < 30 and math.abs(self.lastTouch[idxTemp2+i].y - theTouch.y) < 30 then			
						if cc.rectContainsPoint(icon:getBoundingBox(),pt) then				
							self:showTip(tabTemp[i])
						end
					end
			    end,cc.Handler.EVENT_TOUCH_ENDED)
				local eventDispatcher =  icon:getEventDispatcher()
				eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, icon)
				posx = posx + 150
			end
		end
	end
	return cell
end

function equipBkLayer:numberOfCellsInTableView(table)	
	return (self.num + self.num1 + self.num2) + 3
end

return equipBkLayer

