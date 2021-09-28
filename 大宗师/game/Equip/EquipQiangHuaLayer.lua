local data_equipen_equipen = require("data.data_equipen_equipen")
local data_item_nature = require("data.data_item_nature")

local EquipQiangHuaLayer = class("EquipQiangHuaLayer", function ( data )
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
	display.addSpriteFramesWithFile("ui/ui_equip.plist", "ui/ui_equip.png")
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")

	return require("utility.ShadeLayer").new()
end)

local IS_AUTO = 1
local NOT_AUTO = 0

local TIP_NO_MONEY = 0
local TIP_REACH_LIMIT = 1

local ccs = ccs or {}
ccs.MovementEventType = {
    START = 0,
    COMPLETE = 1,
    LOOP_COMPLETE = 2,
}

function EquipQiangHuaLayer:ctor(param)

	-- local boardZorder = 10
	-- local cardZorder = 12
	self.removeListener = param.removeListener
	self.listTable = param.tableView
	self:setNodeEventEnabled(true)
	local list = param.listData
	self.listData = param.listData
	local _id = param._id 
	self.index = param._id + 1
    self.lvl = list[_id+1]["level"]
	self.star = list[_id+1]["star"] or 0
    local itemId = list[_id+1]["resId"]
    --服务器传过来的ID 用来发强化请求
    self.serverId = list[_id+1]["_id"]

    print("equip data")
    dump(list[_id + 1])

    
   --<<增加上下的框
    self.bottom = require("game.scenes.BottomLayer").new(true)
    self:addChild(self.bottom,1)

    self.top = require("game.scenes.TopLayer").new()
    self:addChild(self.top,1)
-->

	local proxy = CCBProxy:create()
    self._rootnode = {}
	local node = CCBuilderReaderLoad("equip/equip_qianghua.ccbi", proxy, self._rootnode,self,CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - self.top:getContentSize().height ))
    node:setAnchorPoint(ccp(0.5,0.5))
    node:setPosition(display.width/2,display.height/2) --self.bottom:getContentSize().height)
    self:addChild(node)

    self._rootnode["titleLabel"]:setString("装备强化")

    self._rootnode["back_btn"]:addHandleOfControlEvent(function()
        self:removeSelf()
    end, CCControlEventTouchDown)
    self._rootnode["closeBtn"]:setVisible(false)

    self.lvlCurNum = self._rootnode["cur_lv_up"]
    self.lvlMaxNum = self._rootnode["max_lv"]
	self.cardBg = self._rootnode["card_bg"]
    
	self.boardBg = self._rootnode["board_bg"]
    self._rootnode["item_image"]:setDisplayFrame(ResMgr.getLargeFrame(ResMgr.EQUIP, itemId, 0))
	self._rootnode["card_bg"]:setDisplayFrame(display.newSprite("#item_card_bg_" .. self.star .. ".png"):getDisplayFrame())
    for i = 1,5 do
        if i > self.star then
            self._rootnode["star"..i]:setVisible(false)
        else
            self._rootnode["star"..i]:setVisible(true)
        end
    end

 --    --道具名称
    local nameStr = data_item_item[itemId]["name"]
    self._rootnode["cardName"]:setString(nameStr)
    self._rootnode["item_name"]:setString(nameStr)
    self._rootnode["item_name"]:setColor(NAME_COLOR[self.star])
    self._rootnode["cur_lv_up"]:setString("Lv."..self.lvl)
    self.lvlCurNum:setPosition(self.lvlMaxNum:getPositionX(),self.lvlMaxNum:getPositionY())
    -- self._rootnode["max_lv"]:setPosition(self._rootnode["cur_lv_up"]:getPositionX()+self._rootnode["cur_lv_up"]:getContentSize().width,self._rootnode["cur_lv_up"]:getPositionY())
    self._rootnode["max_lv"]:setString("/"..game.player.m_level * 2)

    self._rootnode["cur_lv"]:setString("lv."..self.lvl)
    self._rootnode["next_lv"]:setString("lv."..self.lvl+1)

 --    --当前强化所化的比率的10000倍（为了消除小数）
    self.qianghuaRatio =data_item_item[itemId]["ratio"]/10000
 --    --当前强化需要消耗的钱数
    self.qianghuaNum = math.round(data_equipen_equipen[self.lvl+1]["coin"][self.star] * self.qianghuaRatio)
    
	self.playerMoney = game.player.m_silver
	self.weaponLimit = game.player.m_level * 2

	
	self.itemData = data_item_item[itemId]


	self._rootnode["qianghua_btn"]:addHandleOfControlEvent(function()
    	if self.weaponLimit <= self.lvl  then --如果武器达到上限
		
		self:createTips(TIP_REACH_LIMIT)
		elseif self.qianghuaNum > game.player.m_silver then--如果金币不足强化一次
			self:createTips(TIP_NO_MONEY)
		else --以上都满足 强化吧			
			self:qiangHuaRes(NOT_AUTO)			
		end

    end, CCControlEventTouchDown)

    self._rootnode["auto_btn"]:addHandleOfControlEvent(function()
      	if self.weaponLimit <= self.lvl  then --如果武器达到上限
			print("达到上限")
			self:createTips(TIP_REACH_LIMIT)
		elseif  self.qianghuaNum > game.player.m_silver then--如果金币不足强化一次
			print("No money")
			self:createTips(TIP_NO_MONEY)
		else --以上都满足 自动强化
			print("auto qiang hua") 
			
			self:qiangHuaRes(IS_AUTO)
		end

    end, CCControlEventTouchDown)


	--属性
	local stateTable = data_item_item[itemId]["arr_nature"]
	--属性名
	self.stateStrs = {}
	--属性TTF
	self.stateBefTTFs = {} --之前的
	self.stateAftTTFs = {} --之后的
	self.arrows = {}
	for i =1,#stateTable do 
		local str = data_item_nature[stateTable[i]]["nature"]
		self.stateStrs[#self.stateStrs + 1] = str		
	end

	for i = 1,5 do 
		if i > #self.stateStrs then
			self._rootnode["state_name_"..i]:setVisible(false)
			self._rootnode["state_num_"..i]:setVisible(false)
			self._rootnode["arrow_"..i]:setVisible(false)
			self._rootnode["state_add_"..i]:setVisible(false)
		else
			self._rootnode["state_name_"..i]:setVisible(true)
			self._rootnode["state_num_"..i]:setVisible(true)
			self._rootnode["arrow_"..i]:setVisible(true)
			self._rootnode["state_add_"..i]:setVisible(true)

			self._rootnode["state_name_"..i]:setString(self.stateStrs[i].."：")

				-- 	--属性值 = 基础值 + 极差 X 级别
			local curStateNum = self.itemData["arr_value"][i] + self.itemData["arr_addition"][i] * self.lvl
			local nexStateNum = self.itemData["arr_value"][i] + self.itemData["arr_addition"][i] * (self.lvl+1)

			self._rootnode["state_num_"..i]:setString(curStateNum)			
			self._rootnode["state_add_"..i]:setString(nexStateNum)

			local arrowLen = self._rootnode["arrow_"..i]:getContentSize().height

			self._rootnode["arrow_"..i]:setPosition(self._rootnode["state_num_"..i]:getPositionX() + self._rootnode["state_num_"..i]:getContentSize().width + 10 + arrowLen/2 , self._rootnode["state_num_"..i]:getPositionY())
			self._rootnode["state_add_"..i]:setPosition(self._rootnode["state_num_"..i]:getPositionX() + self._rootnode["state_num_"..i]:getContentSize().width + 10 + arrowLen , self._rootnode["state_num_"..i]:getPositionY())
		end
	end

	self._rootnode["cost_silver"]:setString(self.qianghuaNum)

	


	
end

function EquipQiangHuaLayer:qiangHuaAnim()
	local EFFECT_ZORDER = 100000
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ccs/effect/chuizi/chuizi.ExportJson")
	local chuiziAnim = CCArmature:create("chuizi")
	chuiziAnim:setAnchorPoint(ccp(0,0.5))

	chuiziAnim:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex) --setMovementEventCallFunc(function(armatureBack,movementType,movementID) 			
			if evt == "effect" then	
				local curData = self.subData[self.curIndex]
				self:qiangHuaUpdate(curData)					
				
				self:shake(1)
				local effect = ResMgr.createArma({
                        resType = ResMgr.UI_EFFECT, 
                        armaName = "zhuangbeiqianghua", 
                        isRetain = false, 
                        finishFunc = function()
                           
                        end
                    })
				
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_qianghua))
                effect:setPosition(self._rootnode["card_bg"]:getContentSize().width*0.6, self._rootnode["card_bg"]:getContentSize().height*1.1)
               	self._rootnode["card_bg"]:addChild(effect)		
			end
		end)
	chuiziAnim:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.COMPLETE then
			if self.curIndex < self.endIndex then				
				self.curIndex = self.curIndex + 1
				chuiziAnim:getAnimation():playWithIndex(0)
			else
				chuiziAnim:removeSelf()
				CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("ccs/effect/chuizi/chuizi.ExportJson")
				self:setUpSilver(self.curSilver)
			end
		end
	end)
	-- chuiziAnim:setPosition(self.cardBg:getPositionX()+self.cardBg:getContentSize().width*0.4,self.cardBg:getPositionY())
	chuiziAnim:setPosition(self.cardBg:getPositionX()+self.cardBg:getContentSize().width*0.4,self.cardBg:getPositionY())
	-- self.cardBg:addChild(chuiziAnim,EFFECT_ZORDER)
	self.boardBg:addChild(chuiziAnim,EFFECT_ZORDER)

	chuiziAnim:getAnimation():playWithIndex(0)
end

function EquipQiangHuaLayer:startActQiangHua(data)
	
	self.curIndex = 1
	self.endIndex = #(data["1"])
	self.subData = data["1"]
	dump(data)
	self.curSilver = data["3"]

	print("end data")
	dump(data)


	local cellData = self.listData[self.index]
	print("cellData")
	dump(cellData)

	self:qiangHuaAnim()
end


function EquipQiangHuaLayer:qiangHuaRes(isAuto)
	

	RequestHelper.sendEquipQianghuaRes({
		auto = isAuto,
		id = self.serverId,
		callback = function(data)
			self.data = data
			print("qianghua")
			dump(data)
			self:startActQiangHua(self.data)
		end
		})
	

end

function EquipQiangHuaLayer:qiangHuaUpdate(subData)
	--改等级
	self.lvl = self.lvl + subData["lv"]
	print("fdfdkdkdkdkdkddk")
	self.lvlCurNum:setString("Lv."..self.lvl)
	self.lvlCurNum:setPosition(self.lvlMaxNum:getPositionX(),self.lvlMaxNum:getPositionY())
	-- self.lvlMaxNum:setPosition(self.lvlCurNum:getPositionX()+self.lvlCurNum:getContentSize().width,self.lvlCurNum:getPositionY())
	--扣掉金钱
	game.player.m_silver = game.player.m_silver - subData["coin"]
	self.baseNatrues = {21,22,23,24,77,78}
	self.baseAftState = {0,0,0,0,0,0}
	--改各种奇怪的属性
	for index = 1,#self.stateStrs do

		self:createFloatNum({
			delayIndex = index,
			stateStr = self.stateStrs[index],
			stateNum = self.itemData["arr_addition"][index] * subData["lv"] --* self.lvl
			})
		local curStateNum = self.itemData["arr_value"][index] + self.itemData["arr_addition"][index] * self.lvl
		local nexStateNum = self.itemData["arr_value"][index] + self.itemData["arr_addition"][index] * (self.lvl+1)

		local curNature = self.itemData["arr_nature"][index]
		print("curNature "..curNature)
		for k = 1,#self.baseNatrues do
			if self.baseNatrues[k] == curNature then
				self.baseAftState[k] = curStateNum
				break
			end
		end

		self._rootnode["state_num_"..index]:setString(curStateNum)			
		self._rootnode["state_add_"..index]:setString(nexStateNum)

		local arrowLen = self._rootnode["arrow_"..index]:getContentSize().height

		self._rootnode["arrow_"..index]:setPosition(self._rootnode["state_num_"..index]:getPositionX() + 10+ self._rootnode["state_num_"..index]:getContentSize().width + arrowLen/2 , self._rootnode["state_num_"..index]:getPositionY())
		self._rootnode["state_add_"..index]:setPosition(self._rootnode["state_num_"..index]:getPositionX() + 10 + self._rootnode["state_num_"..index]:getContentSize().width + arrowLen , self._rootnode["state_num_"..index]:getPositionY())

	end

	--非常恶心的后台问题 因为后台在这一级界面不穿数据，前端只能自己查表 并且制造一个数据结构赋值给上一级 cao
	local baseData = self.listData[self.index]["base"]
	for i =1,#baseData do
		baseData[i] = self.baseAftState[i]
	end
	--刷新级别
	self.listData[self.index].level = self.lvl
	-- self.listTable[self.index].base = baseData


	self._rootnode["cur_lv_up"]:setString(self.lvl)
 	self._rootnode["cur_lv"]:setString("lv."..self.lvl)
    self._rootnode["next_lv"]:setString("lv."..self.lvl+1)
	-- self.curSilver
	--改消耗的金币数
	self.qianghuaNum = math.round(data_equipen_equipen[self.lvl+1]["coin"][self.star] * self.qianghuaRatio)
	self._rootnode["cost_silver"]:setString(self.qianghuaNum)
	--播放强化成功//强化暴击的动画
	self:createSuccessTTF(subData["lv"])
end

function EquipQiangHuaLayer:createFloatNum(param)
	--延迟时间
	local delay = param.delayIndex - 1
	--属性名字
	local stateStr = param.stateStr 
	--增加的属性数值
	local stateNum = param.stateNum

	local stateTTF = ui.newBMFontLabel({
		text = stateStr.."+"..stateNum,
		font = "fonts/font_equip_enhance.fnt"
		})
	stateTTF:setVisible(false)
	local delay = CCDelayTime:create(delay*0.8)
	local setVis = CCCallFunc:create(function() stateTTF:setVisible(true) end)
	local moveUp = CCMoveBy:create(1, ccp(0,30))
	local fadeOut = CCFadeOut:create(1)
	local spawn = CCSpawn:createWithTwoActions(moveUp,fadeOut)
	local rev = CCRemoveSelf:create(true)
	local seq = transition.sequence({delay,setVis,spawn,rev})
	stateTTF:runAction(seq)
	self.boardBg:addChild(stateTTF,100000)
	stateTTF:setPosition(display.width/2,display.height/2)

end


function EquipQiangHuaLayer:createTips(tip)
	local ttfNode = display.newNode()
	self.boardBg:addChild(ttfNode,100000)
	-- local tipBg = display.newSprite("#equip_tip_bg.png", x, y, params)
	-- ttfNode:addChild(tipBg)
	local qianghuaText = ""
	if tip == TIP_NO_MONEY then
		-- qianghuaText = "银币不足"
		-- show_tip_label("银币不足")
		ResMgr.showErr(2300006)
	elseif tip == TIP_REACH_LIMIT then
		-- qianghuaText = "强化等级已达上限"
		-- show_tip_label("强化等级已达上限")
		ResMgr.showErr(500009)
	end
	
	
	
	local small = CCCallFunc:create(function() 
		ttfNode:setScale(0.1)
		ttfNode:setVisible(true)
		end)
	local bigger = CCScaleTo:create(0.3, 1)
	local delay = CCDelayTime:create(1.5)
	local smaller = CCScaleTo:create(0.2, 0.2)
	local rev = CCRemoveSelf:create(true)
	local seq = transition.sequence({small,bigger,delay,smaller,rev})
	ttfNode:runAction(seq)

end

function EquipQiangHuaLayer:createSuccessTTF(num)
	local ttfNode = display.newNode()
	ttfNode:setPosition(display.width/2,display.height/2)
	self:addChild(ttfNode,100000)
	local upper = nil
	if num > 1 then
	--强化暴击
		upper = display.newSprite("#equip_qianghua_baoji.png", x, y, params)
		ttfNode:addChild(upper)
	else
	--普通强化
		upper = display.newSprite("#equip_qianghua_success.png", x, y, params)
		ttfNode:addChild(upper)
	end
	local lower = display.newSprite("#equip_tisheng.png", x, y, params)
	
	lower:setAnchorPoint(ccp(0.5,1))
	lower:setPosition(upper:getPositionX(),upper:getPositionY() - upper:getContentSize().height/2)
	local lowerNum = display.newSprite("#equip_qianghua_num_"..num..".png", x, y, params)
	lowerNum:setAnchorPoint(ccp(0.5,1))
	lowerNum:setPosition(lower:getContentSize().width*0.6,lower:getContentSize().height *1)
	lower:addChild(lowerNum)
	ttfNode:addChild(lower)
	ttfNode:setVisible(false)

	local small = CCCallFunc:create(function() 
		ttfNode:setScale(0.1)
		ttfNode:setVisible(true)
		end)
	local bigger = CCScaleTo:create(0.3, 1)
	local delay = CCDelayTime:create(1.5)
	local smaller = CCScaleTo:create(0.2, 0.2)
	local rev = CCRemoveSelf:create(true)
	local seq = transition.sequence({small,bigger,delay,smaller,rev})
	ttfNode:runAction(seq)
end

function EquipQiangHuaLayer:onExit(  )
	-- body
	if self.removeListener ~= nil then
		self.removeListener()

	end
	 self.listTable:reloadData()

	display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
end

function EquipQiangHuaLayer:setUpSilver(num)
    self.top:setSilver(num)
end

function EquipQiangHuaLayer:setUpGoldNum(num)
    self.top:setGodNum(num)
end

function EquipQiangHuaLayer:shake( direction)
	if direction ~= 0 then 
		local rate = 0.01
		local delayTime = 0.08
		
		local cPosX = self.boardBg:getPositionX()
		local cPosY = self.boardBg:getPositionY()

		local xDirection = 1
		local yDirection = -1
		if direction == 1 then 
		
			xDirection = 1
			yDirection = -1
		elseif direction == 2 then 
			--右下角
			xDirection = 1
			yDirection = -1
			-- rate = 0.05
			-- delayTime = 0.1

		end

		local delayAct = CCDelayTime:create(delayTime)

		local offSetWidth = display.width * rate 
		local offSetcHeight = display.height * rate

		local moveAct1 =CCCallFunc:create(function ()
			self.boardBg:setPosition(ccp(cPosX + offSetWidth*xDirection ,cPosY + offSetcHeight* yDirection))
		end)
		local moveAct2 =CCCallFunc:create(function ()
			self.boardBg:setPosition(ccp(cPosX,cPosY))
		end)
		local sequence = transition.sequence({
				moveAct1,delayAct,moveAct2	
	        	        	
	        	})
	    		self.boardBg:runAction(sequence)
	 end
end

return EquipQiangHuaLayer