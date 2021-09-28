local honourLayer = class("honourLayer",function() return cc.Layer:create() end)
local honourProp = class("honourProp",require("src/TabViewLayer"))

function honourLayer:ctor(id,school,isMe,gird)
	local msgids = {}
	self.gird = gird
	require("src/MsgHandler").new(self, msgids)
	local job = school or require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	self.isMe = isMe
	if id then
		id = id + 1000*job
	else
		id = 1000 * job
	end
	self.id = id  --temp
	--local bg = createBgSprite(self,game.getStrByKey("title_honour"))
	local bg =  createSprite(self,"res/common/bg/bg18.png",g_scrCenter)

	local rootSize = bg:getContentSize()
	-- 背景图
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 17),
       	cc.size(rootSize.width-60, rootSize.height-74),
        5
    )
	createLabel( bg , game.getStrByKey("title_honour"), cc.p(bg:getContentSize().width/2,bg:getContentSize().height -30)  , cc.p( 0.5 , 0.5 ) ,  24,true )
	self.bg = bg
  	local closeFunc = function() 
      	removeFromParent(self)
  	end
  	local allNum = #require("src/config/honourCfg")
  	
  	self.isFull = false
  	if id >= 1000*job + allNum/3 - 1 then
  		self.isFull = true
  	end
  	local closeBtn = createTouchItem(bg,"res/component/button/x2.png",cc.p(bg:getContentSize().width - 40 ,bg:getContentSize().height - 25),closeFunc)
  	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_MEDAL_CLOSE)
  	registerOutsideCloseFunc(bg, closeFunc,true)
	-- local bg1 = createSprite(bg,"res/common/bg/bg18-2.png",cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2-22))
	createSprite(bg, "res/common/bg/bg44-3.png",cc.p(237,242))
	local bgTemp = createSprite(bg, "res/common/bg/bg44-4.png",cc.p(625,242))
	self.bgTemp = bgTemp
	self.arrow = createSprite(bg,"res/group/arrows/17.png",cc.p(235,355))
	createLabel(bg,game.getStrByKey("consume"),cc.p(235,225),nil,24,true,nil,nil,MColor.lable_yellow)
	createSprite(bg,"res/common/bg/bg44-3-2.png",cc.p(235,120))
	createSprite(bg,"res/common/bg/bg44-3-2.png",cc.p(235,225))
	-- local bgFrame = createSprite(bg,"res/common/bg/bg-4.png",cc.p(bg:getContentSize().width/2,bg:getContentSize().height/4))
	-- bgFrame:setScale(0.87,0.88)
	-- self.bgFrame = bgFrame
	self.bgFrame_size = bg:getContentSize()
	-- self.leftCircle = createSprite(bg,"res/common/bg/iconBg2.png",cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2+120))
	-- self.midArrow = createSprite(bg1,"res/group/arrows/15.png",cc.p(bg1:getContentSize().width/2-10,bg1:getContentSize().height/2+120))
	-- self.rightCircle = createSprite(bg1,"res/common/bg/iconBg2.png",cc.p(bg1:getContentSize().width/5*4,bg1:getContentSize().height/2+120))
	-- createSprite(bg,"res/common/bg/titleBg.png",cc.p(self.bgFrame_size.width/5,self.bgFrame_size.height-35))
	-- createLabel(bg,game.getStrByKey("base_attr"),cc.p(self.bgFrame_size.width/5,self.bgFrame_size.height-35),nil,22,nil,nil,nil,MColor.lable_yellow)
	-- createSprite(bg,"res/common/bg/titleBg.png",cc.p(self.bgFrame_size.width/5*4,self.bgFrame_size.height-35))
	-- createLabel(bg,game.getStrByKey("next_attr"),cc.p(self.bgFrame_size.width/5*4,self.bgFrame_size.height-35),nil,22,nil,nil,nil,MColor.lable_yellow)
	self.stars = { } 

	for i = 1 , 10 do
		if i < 6 then
			self.stars[i] = createSprite( self.bg , "res/group/star/s3.png" , cc.p(475+50*i,430))
		else
			self.stars[i] = createSprite( self.bg , "res/group/star/s3.png" , cc.p(475+50*(i-5),390))
		end
    end
	self.job = job
	
	if isMe then
		self.sw = createLabel(self.bg,game.getStrByKey("upcost"),cc.p(45,170),cc.p(0,0.5),24,true,nil,nil,MColor.lable_black)
		self.costShow = createLabel(self.bg,"",cc.p(110,170),cc.p(0,0.5),24,true,nil,nil,MColor.white)
		self.zqLabel = createLabel(bg,game.getStrByKey("allzq"),cc.p(235,170),cc.p(0,0.5),24,true,nil,nil,MColor.lable_black)
		self.vital = createLabel(bg,MRoleStruct:getAttr(PLAYER_VITAL),cc.p(325,170),cc.p(0,0.5),24,true,nil,nil,MColor.red)		
		self:honourOperator()
	end
	self:showStates(self.id)
	self:showProp()

	createLabel(bg,game.getStrByKey("honourRole"),cc.p(235,120),nil,22,true,nil,nil,MColor.lable_yellow)
	local richText = require("src/RichText").new( bg , cc.p( 50, 100 ) , cc.size( 500 , 305 ) , cc.p( 0 , 1 ) , 26 , 20 , MColor.green )
	richText:addText( require("src/config/PromptOp"):content(34) , MColor.lable_black , true )
	richText:format()

	local onDressChanged = function(observable, event, id, grid)
		-- dump(event, "event")
		self.gird = grid
		-- if event == "+" or event == "=" or event == "-" then
		-- 	-- 更新着装
		-- 	refreshDressSlot(id, event)
		-- end
		if id == MPackStruct.eMedal then -- 勋章
			local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
			self.strengthLv = strengthLv
			if strengthLv then
				self.id = strengthLv+self.job*1000
				if self.id <= 1000*self.job + allNum/3 - 1 then
					AudioEnginer.playEffect("sounds/uiMusic/ui_treasure.mp3", false)
					local effectNode = Effects:create(false) -- true -> 自动clean
					effectNode:playActionData("equipRefine", 27, 1.9, 1)
					performWithDelay(effectNode,function() removeFromParent(effectNode) effectNode = nil end,1.9)
					effectNode:setPosition(bgTemp:getContentSize().width/2,bgTemp:getContentSize().height/2+12)
					bgTemp:addChild(effectNode,10)
					self:update()
				else
					self.menuitem1:setEnabled(false)
				end
			end			
		end
	end
	self:registerScriptHandler(function(event)
		local pack = MPackManager:getPack(MPackStruct.eDress)
			if event == "enter" then
				pack:register(onDressChanged)
				G_TUTO_NODE:setShowNode(self, SHOW_MEDAL)
			elseif event == "exit" then
				pack:unregister(onDressChanged)
			end
		end)
end

function honourLayer:getProp(isme,id,job)
	local jobAt = {
					{ROLE_MIN_AT,ROLE_MAX_AT},
					{ROLE_MIN_MT,ROLE_MAX_MT},
					{ROLE_MIN_DT,ROLE_MAX_DT}
				}
	local jobAt1 = {
					{"q_attack_min","q_attack_max"},
					{"q_magic_attack_min","q_magic_attack_max"},
					{"q_sc_attack_min","q_sc_attack_max"}
				}
	local propAddGroup = {	
							"q_max_hp",
							jobAt1[job],
							{"q_defence_min","q_defence_max"},
							{"q_magic_defence_min","q_magic_defence_max"},
							"q_crit"
							--,"","","","","","","","","","","",""
						}
	local propGroup = {
						ROLE_MAX_HP, --生命
						jobAt[job], --攻击
						{ROLE_MIN_DF,ROLE_MAX_DF}, --物防
						{ROLE_MIN_MF,ROLE_MAX_MF}, --魔防
						ROLE_CRIT,  --暴击
						-- ROLE_HIT,  --命中
						-- ROLE_DODGE, --闪避
						-- PLAYER_LUCK, --幸运
						-- ROLE_TENACITY, --韧性
						-- PLAYER_PROJECT, --护身
						-- PLAYER_PROJECT_DEF,--穿透
						-- PLAYER_BENUMB,--冰冻
						-- PLAYER_BENUMB_DEF,--冰冻抵抗
					}
	-- self.propGroup = propGroup
	local propTable = {}
	local propAddTable = {}
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local isNext = getConfigItemByKey("honourCfg","q_ID",id+1,"q_max_hp")

	for i=1,#propGroup do
		if type(propAddGroup[i]) == "table" then
			local propTemp = {}
			local propTempAdd = {}
			for j = 1,#propGroup[i] do
				--table.insert(propTemp,MRoleStruct:getAttr(self.propGroup[i][j]))
				table.insert(propTemp,getConfigItemByKey("honourCfg","q_ID",id,propAddGroup[i][j]))
				if isNext then
					table.insert(propTempAdd,getConfigItemByKey("honourCfg","q_ID",id+1,propAddGroup[i][j]))
				else
					table.insert(propTempAdd," - ")
				end
			end
			table.insert(propTable,propTemp)
			table.insert(propAddTable,propTempAdd)
		else
			--table.insert(self.propTable,MRoleStruct:getAttr(self.propGroup[i]))
			table.insert(propTable,getConfigItemByKey("honourCfg","q_ID",id,propAddGroup[i]))
			if isNext then
				table.insert(propAddTable,getConfigItemByKey("honourCfg","q_ID",id+1,propAddGroup[i]))
			else
				table.insert(propAddTable," - ")
			end
		end
	end
	local biao = {"prop_attack1","prop_magicAttack1","prop_scAttack1"}
	local getStr = {
				"prop_hp",biao[job],"prop_defence1","prop_magicDefence1","prop_cirt",
				--"prop_hit","prop_dodge","prop_luck","my_tenacity","hu_shen","hu_shen_rift","freeze","freeze_oppose"
			}
	if isme then
		return getStr,propTable,propAddTable,isNext
	else
		local star = ((id-(job*1000)+1)%10 ~= 0 and (id-(job*1000)+1)%10) or 10
		local level = math.floor((id-(job*1000))/10)+1
		local lv = game.getStrByKey("num_"..level)..game.getStrByKey("grade")..game.getStrByKey("num_"..star)..game.getStrByKey("task_d_x")
		return getStr,propTable,lv
	end
end

function honourLayer:showProp()
	local getStr,propTable,propAddTable,isNext = self:getProp(true,self.id,self.job)
	if self.tab == nil and self.tab1 == nil then		
		if isNext then
			self.tab = honourProp.new(self.bg,cc.p(-5,230),propTable,self.job,1,getStr)
			self.tab1 = honourProp.new(self.bg,cc.p(235,230),propAddTable,self.job,2,getStr)
		else
			self.tab = honourProp.new(self.bg,cc.p(115,230),propTable,self.job,1,getStr)
			self.leftNum:setPosition(cc.p(234,440))
		end
	else		
		if isNext then
			self.tab.propTable1 = propTable
			self.tab:getTableView():reloadData()
			self.tab1.propTable1 = propAddTable		
			self.tab1:getTableView():reloadData()
		else
			self.tab.propTable1 = propTable
			self.tab:getTableView():reloadData()
			self.tab:getTableView():setPosition(cc.p(129,230))
			self.leftNum:setPosition(cc.p(234,440))
			removeFromParent(self.tab1)
			self.tab1 = nil
		end
	end
end

function honourLayer:showStates(num)
	print(num,"77777777777")
	if num and num ~= 0 then
		local star = ((num-(self.job*1000)+1)%10 ~= 0 and (num-(self.job*1000)+1)%10) or 10
		local level = math.floor((num-(self.job*1000))/10)+1
		local lev,st = 0,0
		local tempNum = getConfigItemByKey("honourCfg","q_ID",num,"q_nextID") or 0
		if tempNum ~= 0 then
			st = ((tempNum-(self.job*1000)+1)%10 ~= 0 and (tempNum-(self.job*1000)+1)%10) or 10
			lev = math.floor((tempNum-(self.job*1000))/10)+1
		end
		if self.leftNum and self.rightNum then
			self.leftNum:setString(game.getStrByKey("num_"..level)..game.getStrByKey("grade")..game.getStrByKey("num_"..star)..game.getStrByKey("task_d_x"))
			self.rightNum:setString("")
			if getConfigItemByKey("honourCfg","q_ID",num+1,"q_max_hp") then
				self.rightNum:setString(game.getStrByKey("num_"..lev)..game.getStrByKey("grade")..game.getStrByKey("num_"..st)..game.getStrByKey("task_d_x"))
			end
		else
			self.leftNum = createLabel(self.bg,game.getStrByKey("num_"..level)..game.getStrByKey("grade")..game.getStrByKey("num_"..star)..game.getStrByKey("task_d_x"),cc.p(100,440),nil,24,true,nil,nil,MColor.lable_yellow)
			self.rightNum = createLabel(self.bg,"",cc.p(340,440),nil,24,true,nil,nil,MColor.lable_yellow)
			
			if getConfigItemByKey("honourCfg","q_ID",num+1,"q_max_hp") then
				self.rightNum:setString(game.getStrByKey("num_"..lev)..game.getStrByKey("grade")..game.getStrByKey("num_"..st)..game.getStrByKey("task_d_x"))
			end
		end
		---------------------------------------------------------------
		if self.icon then
			removeFromParent(self.icon)
			self.icon = nil
		end
		-- local jobkind = {"zs","fs","ds"}
	 --    local color = {MColor.green,cc.c3b(24,133,243),MColor.purple}
	 --    local eff = function(super,lv)
		-- 	local effect = Effects:create(false)
		--     effect:playActionData(jobkind[self.job].."xz"..math.ceil(lv/3), 9, 1.5, -1)
		--     super:addChild(effect, 2)
		--     effect:setPosition(cc.p(super:getContentSize().width/2, super:getContentSize().height/2))
		--     effect:setColor(color[math.ceil(1+(lv-1)%3)])
		--     effect:setOpacity(200)
		-- end
		local propId = self.job+30003
		-- if cc.FileUtils:getInstance():isFileExist("res/layers/role/honourIcon/"..propId.."_"..math.ceil(level/3)..".png") then
		--     self.icon = createSprite(self.bg,"res/layers/role/honourIcon/"..propId.."_"..math.ceil(level/3)..".png",cc.p(625,254))
		--     self.icon:setScale(0.8)
		-- 	eff(self.icon,level)
		-- end
		---------------------------------------------------------------
		local Mprop = require "src/layers/bag/prop"
		self.icon = Mprop.new(
		{
			grid = self.gird,
		})
		self.icon:setPosition(cc.p(171,228))
		self.bgTemp:addChild(self.icon)

		-- if cc.FileUtils:getInstance():isFileExist("res/layers/role/honourIcon/"..propId.."_"..math.ceil(lev/3)..".png") then
		-- 	self.icon1 = createSprite(self.rightCircle,"res/layers/role/honourIcon/"..propId.."_"..math.ceil(lev/3)..".png",cc.p(self.rightCircle:getContentSize().width/2,self.rightCircle:getContentSize().height/2))
		-- 	eff(self.icon1,lev)
		-- end
		for i = 1 , 10 do
			if i < 6 then
	        	self.stars[i]:setTexture( "res/group/star/s" .. (((star >= i) and 4) or 3) .. ".png" )
	        else
	        	self.stars[i]:setTexture( "res/group/star/s" .. (((star >= i) and 4) or 3) .. ".png" )
	        end
	    end
	    if self.isMe then
		    local cost = getConfigItemByKey("honourCfg","q_ID",num,"q_cost")
		    self.vital:setString(MRoleStruct:getAttr(PLAYER_VITAL))
		    if cost and cost <= MRoleStruct:getAttr(PLAYER_VITAL) then
		    	self.vital:setColor(MColor.white)
		    else
		    	self.vital:setColor(MColor.red)
		    end
		    if cost then
		    	self.costShow:setString(tostring(cost))		    	
		    else
		    	if self.sw then
		    		removeFromParent(self.sw)
		    		self.sw = nil
		    	end
		    	if self.zqLabel then
		    		removeFromParent(self.zqLabel)
		    		self.zqLabel = nil
		    	end
		    	if self.vital then
		    		removeFromParent(self.vital)
		    		self.vital = nil
		    	end
		    	if self.arrow then
		    		removeFromParent(self.arrow)
		    		self.arrow = nil
		    	end
				self.costShow:setString(game.getStrByKey("fullLevel2"))
				self.costShow:setPosition(cc.p(185,170))
				self.menuitem1:setEnabled(false)
				self.menuitem1:setVisible(false)
		    end
		end
	end
end

function honourLayer:honourOperator()
	-- local menuitem = createMenuItem(self.bg,"res/component/button/39_sel.png",cc.p(235,70),function() self:ruleShow() end)
	-- createLabel(menuitem, game.getStrByKey("honourRole"),getCenterPos(menuitem), cc.p(0.5,0.5),22,true)
	local menuitem1 = createMenuItem(self.bg,"res/component/button/1_sel.png",cc.p(628,70),function() self:send() end)
	createLabel(menuitem1, game.getStrByKey("honourUpdate"),getCenterPos(menuitem1), cc.p(0.5,0.5),22,true)
	self.menuitem1 = menuitem1
	if self.isFull then
		menuitem1:setEnabled(false)
		menuitem1:setVisible(false)
	end
	G_TUTO_NODE:setTouchNode(menuitem1, TOUCH_MEDAL_UPDATE)
end

function honourLayer:ruleShow()
	local show = createSprite(self,"res/common/bg/bg37.png",g_scrCenter)
	  local closeFunc = function() 
      	show:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(function() removeFromParent(show) end)))  
  	end
  	local closeBtn = createTouchItem(show,"res/component/button/x3.png",cc.p(show:getContentSize().width - 30 ,show:getContentSize().height - 25),closeFunc)
	--popupBox({parent = self,isNoSwallow = true,pos = cc.p( 200 , 268 ),createScale9Sprite = { size = cc.size( 706 , 445 ) } , close = { scale = 0.7 , offX = 28,offY = 15 , callback = function() end } ,  bg = "res/common/5.png" ,  actionType = 5 ,  zorder = 300,noNewAction = true} )
    local showsize = show:getContentSize()
    createLabel(show,game.getStrByKey("honourRole"),cc.p(show:getContentSize().width/2,show:getContentSize().height-30),nil,22,nil,nil,nil,MColor.lable_yellow)
    registerOutsideCloseFunc( show , closeFunc,true)
    local richText = require("src/RichText").new( show , cc.p( 35, 300 ) , cc.size( 500 , 305 ) , cc.p( 0 , 1 ) , 22 , 20 , MColor.green )
	richText:addText( require("src/config/PromptOp"):content(34) , MColor.lable_yellow , true )
	richText:format()
end

function honourLayer:send()
	--g_msgHandlerInst:sendNetDataByFmt(ITEM_CS_UPGRADE, "i", G_ROLE_MAIN.obj_id)
	g_msgHandlerInst:sendNetDataByTable(ITEM_CS_UPGRADE, "ItemUpgradeProtocol" , {} )
end

function honourLayer:update()

	-- self.id = (getConfigItemByKey("honourCfg","q_ID",self.id,"q_nextID") or (getConfigItemByKey("honourCfg","q_ID",self.id+1,"q_max_hp") and self.id)) or 0
	-- print(self.id,"66666666666666666666")
	if self.id then
		-- local one = function()
		-- 	local c1 = Effects:create(false)
		--     c1:playActionData("honourCircle1", 7, 0.2, 1)
		-- 	self.leftCircle:addChild(c1)
		-- 	c1:setPosition(cc.p(self.leftCircle:getContentSize().width/2, self.leftCircle:getContentSize().height/2))
		-- 	return 0.1
		-- end
		-- local two = function()
		-- 	local arrows = Effects:create(false)
		--     arrows:playActionData("honourArrow", 6, 0.4, 1)
		-- 	self.midArrow:addChild(arrows)
		-- 	arrows:setPosition(cc.p(self.midArrow:getContentSize().width/2, self.midArrow:getContentSize().height/2))
		-- 	return 0.3
		-- end
		-- local three = function()
		-- 	local c2 = Effects:create(false)
		--     c2:playActionData("honourCircle2", 6, 0.4, 1)
		-- 	self.leftCircle:addChild(c2)
		-- 	c2:setPosition(cc.p(self.leftCircle:getContentSize().width/2, self.leftCircle:getContentSize().height/2))
		-- 	self:showProp()
		-- 	self:showStates(self.id)
		-- 	return 0.2
		-- end
		-- local idx = 1
		-- local actions = {}
		-- local funTemp = {three}
		-- local fun = nil
		-- fun = function()
		-- 	if funTemp[idx] ~= nil then
		-- 		local time = funTemp[idx]()
		-- 		idx = idx + 1
		-- 		actions = {}
		-- 		if time and time ~= 0 then
		-- 			actions[#actions + 1] = cc.DelayTime:create(time)
		-- 		end
		-- 		actions[#actions + 1] = cc.CallFunc:create(fun)
		-- 		self:runAction(cc.Sequence:create(actions))
		-- 	end
		-- end
		-- self:runAction(cc.CallFunc:create(fun))		
		self:showStates(self.id)
		self:showProp()
	end
end

function honourLayer:networkHander(buff,msgid)
	local switch = {
		
	}
 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function honourProp:ctor(parent,pos,propTable1,myjob,way,getStr)
	self.way = way
	-- local biao = {"prop_attack1","prop_magicAttack1","prop_scAttack1"}
	-- self.getStr = {
	-- 				"prop_hp",biao[myjob],"prop_defence1","prop_magicDefence1","prop_cirt",
	-- 				--"prop_hit","prop_dodge","prop_luck","my_tenacity","hu_shen","hu_shen_rift","freeze","freeze_oppose"
	-- 			}
	self.getStr = getStr
	self.propTable1 = propTable1
	self:createTableView(self, cc.size(290, 195), pos, true)
	if parent then
		parent:addChild(self)
	end
end

function honourProp:cellSizeForTable(table, idx) 
    return 30, 290
end

function honourProp:tableCellTouched(table, cell)

end

function honourProp:tableCellAtIndex(tableView, idx)
	local cell = tableView:dequeueCell()
	local idex = idx + 1
	if cell == nil then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end
	if self.way == 1 then
		if type(self.propTable1[idex]) == "table" and #self.propTable1[idex] == 2 then
			createLabel(cell,game.getStrByKey(self.getStr[idex]),cc.p(50,15),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)
			createLabel(cell," "..self.propTable1[idex][1].."~"..self.propTable1[idex][2],cc.p(100,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
		else
			createLabel(cell,game.getStrByKey(self.getStr[idex]),cc.p(50,15),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)
			createLabel(cell," "..self.propTable1[idex],cc.p(100,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
		end
	else 
		if type(self.propTable1[idex]) == "table" and #self.propTable1[idex] == 2 then
			createLabel(cell,game.getStrByKey(self.getStr[idex]),cc.p(50,15),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)
			createLabel(cell," "..self.propTable1[idex][1].."~"..self.propTable1[idex][2],cc.p(100,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
		else
			createLabel(cell,game.getStrByKey(self.getStr[idex]),cc.p(50,15),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)
			createLabel(cell," "..self.propTable1[idex],cc.p(100,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
		end
	end
	return cell
end

function honourProp:numberOfCellsInTableView(table)
	return #self.getStr
end

return honourLayer