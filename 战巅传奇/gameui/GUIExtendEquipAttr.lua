local GUIExtendEquipAttr={}
local var = {}

--继承消耗
local shiftTable = {
	[1] ={needMoney=100000,  needVcion=0,  needBindVcion=0},
	[2] ={needMoney=100000,  needVcion=0,  needBindVcion=0},
	[3] ={needMoney=100000, needVcion=0,  needBindVcion=0},
	[4] ={needMoney=100000, needVcion=0,  needBindVcion=0},
	[5] ={needMoney=100000,needVcion=0,  needBindVcion=0},
	[6] ={needMoney=100000,needVcion=0,  needBindVcion=0},
	[7] ={needMoney=100000,needVcion=0,  needBindVcion=0},
	[8] ={needMoney=100000,needVcion=0,  needBindVcion=0},
	[9] ={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[10]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[11]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[12]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[13]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[14]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[15]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[16]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[17]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[18]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[19]={needMoney=100000,     needVcion=0,  needBindVcion=0},
	[20]={needMoney=100000,     needVcion=0,  needBindVcion=0},
}

--快速继承点击是操作
local function funcClickConfirm(pSender)
	local money = GameSocket.mCharacter.mGameMoney or 0
	local bMoney = GameSocket.mCharacter.mGameMoneyBind or 0
	local vcion = GameSocket.mCharacter.mVCoin or 0
	local bvcion = GameSocket.mCharacter.mVCoinBind or 0
	vcion = vcion + bvcion
	-- print(money,bMoney,vcion)
	-- var.uiQuickJiCheng:hide()
	print(pSender.mLevel,shiftTable[pSender.mLevel],"=========9999999999999")
	if pSender.mLevel>0 and shiftTable[pSender.mLevel] then
		local itemData = shiftTable[pSender.mLevel]
		if itemData.needBindVcion>0 then
			if itemData.needBindVcion>bvcion then
				GameSocket:alertLocalMsg("快速继承所需钻石不足！","alert")
				return
			end
		end
		if itemData.needMoney>0 then
			if itemData.needMoney>(money+bMoney) then
				GameSocket:alertLocalMsg("快速继承所需元宝不足！","alert")
				return
			end
		end
		if itemData.needVcion>0 then
			if itemData.needVcion>(vcion+bvcion) then
				GameSocket:alertLocalMsg("快速继承所需钻石不足！","alert")
				return
			end
		end
		local result={}
		result.oldPos=pSender.oldPos
		result.oldTypeid=pSender.oldTypeid
		result.newPos=pSender.newPos
		result.newTypeid=pSender.newTypeid
		-- print(GameUtilSenior.encode(result),"=======8888888888888")
		GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid = "startJiCheng",params=result}))
	end
end

--如果是手镯或者戒指的话
local function getNeedPos(equipType)
	local pos1 = -2*equipType
	local pos2 = -2*equipType-1

	local newItem1 = GameSocket.mItems[pos1]
	local newItem2 = GameSocket.mItems[pos2]

	if newItem1 and newItem2 then
		local itemDef1 = GameSocket:getItemDefByID(newItem1.mTypeID)
		local itemDef2 = GameSocket:getItemDefByID(newItem2.mTypeID)
		if itemDef1 and itemDef2 then
			if itemDef1.mNeedZsLevel>0 or itemDef2.mNeedZsLevel>0 then
				if itemDef1.mNeedZsLevel < itemDef2.mNeedZsLevel then
					return pos1
				end
				if itemDef1.mNeedZsLevel > itemDef2.mNeedZsLevel then
					return pos2
				end
				if itemDef1.mNeedZsLevel == itemDef2.mNeedZsLevel then
					if newItem1.mLevel<=newItem2.mLevel then
						return pos2
					else
						return pos1
					end
				end
			else
				if itemDef1.mNeedParam < itemDef2.mNeedParam then
					return pos1
				end
				if itemDef1.mNeedParam > itemDef2.mNeedParam then
					return pos2
				end
				if itemDef1.mNeedParam == itemDef2.mNeedParam then
					if newItem1.mLevel<=newItem2.mLevel then
						return pos2
					else
						return pos1
					end
				end
			end
		end
	end
	return pos1
end

--被替换的部件有强化等级时调用 返回值为true 需要执行快速继承操作
local function checkQiangHuaLevel(newPos)
	local btnConfirm = var.uiQuickJiCheng:getWidgetByName("btnConfirm")
	btnConfirm.mLevel=0

	if not newPos then return 0 end
	local newItem = GameSocket.mItems[newPos]
	if not newItem then return 0 end
	local itemDef = GameSocket:getItemDefByID(newItem.mTypeID)
	if not itemDef then return 0 end
		-- print(GameUtilSenior.encode(itemDef),"================")
		-- print(GameUtilSenior.encode(newItem))
	local equipType = itemDef.mEquipType
	local targetPos = -2*equipType

	if equipType==5 or equipType==6 then
		targetPos = getNeedPos(equipType)
	end

	local targetItem = GameSocket.mItems[targetPos]
	
	if targetItem then
		if targetItem.mLevel>0 then
			btnConfirm.mLevel=targetItem.mLevel

			btnConfirm.oldPos=targetPos
			btnConfirm.oldTypeid=targetItem.mTypeID
			btnConfirm.newPos=newPos
			btnConfirm.newTypeid=newItem.mTypeID
			var.oldPos=targetPos
			var.newPos=newPos

			local param = {
				parent = var.uiQuickJiCheng:getWidgetByName("iconOld"),
				pos = targetPos,
				iconType = GameConst.ICONTYPE.BAG,
				-- tipsType = GameConst.TIPS_TYPE.BAG,
			}
			GUIItem.getItem(param)

			local param = {
				parent = var.uiQuickJiCheng:getWidgetByName("iconNew"),
				pos = newPos,
				iconType = GameConst.ICONTYPE.BAG,
				-- tipsType = GameConst.TIPS_TYPE.BAG,
			}
			GUIItem.getItem(param)

			return targetItem.mLevel
		else
			return 0
		end
	else
		return 0--对应装备位无装备
	end

end

-- GameSocket:ItemPositionExchange(from,to)

--点击否时的操作
local function funcClickCancel(pSender)
	if var.oldPos and var.newPos then
		GameSocket:ItemPositionExchange(var.newPos,var.oldPos)
		var.uiQuickJiCheng:hide()
	end
	var.oldPos=nil
	var.newPos=nil
end

--戒指和手镯有空位置不出快速继承
local function checkHaveEmpty(newPos)
	local newItem = GameSocket.mItems[newPos]
	local equipType = nil
	if newItem then
		if not GameBaseLogic.IsRing(newItem.mTypeID) and not GameBaseLogic.IsGlove(newItem.mTypeID) then
			return true
		end
		local itemDef = GameSocket:getItemDefByID(newItem.mTypeID)
		if itemDef then
			equipType=itemDef.mEquipType
		end
		if not equipType then return true end
		if (not GameSocket.mItems[-2*equipType]) or (not GameSocket.mItems[-2*equipType-1]) then
			return false
		end
	end
	return true
end


function GUIExtendEquipAttr.useCheckJiCheng(newPos)
	-- print("--------1111111111111111111===",newPos,checkQiangHuaLevel(newPos));
	local newItem = GameSocket.mItems[newPos]
	if newItem and newItem.mLevel>0 then return false end
	if not checkHaveEmpty(newPos) then return false end

	local mLevel = checkQiangHuaLevel(newPos)
	if mLevel>0 then 
		var.uiQuickJiCheng:show()
		local labNeedDesp = var.uiQuickJiCheng:getWidgetByName("labNeedDesp")
		if shiftTable[mLevel] then
			local itemData = shiftTable[mLevel]
			if itemData.needMoney>0 then
				labNeedDesp:setString("需要消耗："..itemData.needMoney.."元宝")
			elseif itemData.needBindVcion>0 then
				labNeedDesp:setString("需要消耗："..itemData.needBindVcion.."钻石")
			elseif itemData.needVcion>0 then
				labNeedDesp:setString("需要消耗："..itemData.needVcion.."钻石")
			end
		end

		-- var.uiQuickJiCheng:hide()
		return true
	end
	return false
end

local function handlePanelData(event)
	if event.type ~= "ContainerSmelt" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd =="successTransfer" then
		print(var.newPos,var.oldPos,"====777777777777777777777777")
		if var.oldPos and var.newPos then
			GameSocket:ItemPositionExchange(var.newPos,var.oldPos)
			var.uiQuickJiCheng:hide()
		end
		var.oldPos=nil
		var.newPos=nil
	end
end


function GUIExtendEquipAttr.init(scene)
	var = {
		uiQuickJiCheng,
		oldPos=nil,
		newPos=nil,
	}
	if scene then
		var.uiQuickJiCheng = GUIAnalysis.load("ui/layout/GUIExtendEquipAttr.uif")
		if var.uiQuickJiCheng then
			cc.EventProxy.new(GameSocket,var.uiQuickJiCheng)
				:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, handlePanelData)

			var.uiQuickJiCheng:align(display.LEFT_BOTTOM, 0, 0):addTo(scene,51):hide()
			-- GameUtilSenior.asyncload(var.uiQuickJiCheng, "tipsbg", "ui/image/prompt_bg.png")
			-- GameUtilSenior.asyncload(var.uiQuickJiCheng, "imgBg", "ui/image/img_tips_fly_bg.png")

			var.uiQuickJiCheng:getWidgetByName("tipsbg"):setTouchEnabled(true)

			local btnConfirm = var.uiQuickJiCheng:getWidgetByName("btnConfirm")
			GUIFocusPoint.addUIPoint(btnConfirm, funcClickConfirm)
			local btnCancel = var.uiQuickJiCheng:getWidgetByName("btnCancel")
			GUIFocusPoint.addUIPoint(btnCancel, funcClickCancel)
		end
	end
end

return GUIExtendEquipAttr