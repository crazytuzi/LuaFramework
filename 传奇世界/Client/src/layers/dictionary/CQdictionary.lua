local cqd = class("cqd",require("src/TabViewLayer"))

function cqd:ctor(parent)
	self.parent = parent
	self.tableViewOffsetTemp = false
	-- local bg = createBgSprite(self)
	-- local bg = createSprite(self,"res/common/bg/bg.png",cc.p(480,290))
	-- local bg1 = cc.Layer:create()
	-- bg1:setContentSize(cc.size(958,607))
	-- bg1:setPosition(cc.p(100,10))
	-- self:addChild(bg1)	
	-- bg1:runAction(cc.MoveTo:create(0.5,cc.p(195,10)))
	-- createSprite(self,"res/common/bg/bg55-1.png",cc.p(578,533),nil,50)
	createSprite(self,"res/common/bg/bg55-2.png",cc.p(578,75),nil,50)
	local tbook = getConfigItemByKeys("bookDB", {
		"q_school",
		"q_id",
	})
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)
	local lv = MRoleStruct:getAttr(ROLE_LEVEL)
	self.lv = lv
	local MroleOp = require("src/config/roleOp")
	local highestLv = MroleOp:highestLv()
	--防止没有内容的等级段按钮显示
	local tabNum = table.size(tbook[school])
	local theHighestLvInBook = tbook[school][100*(school-1)+tabNum].q_lv
	if theHighestLvInBook < highestLv then
		highestLv = theHighestLvInBook
	end 
	--	
	local lvTab = {}
	self.tablelist = {}
	local showBtnTemp = 0
	local chooseTemp = 0
	for i=0 ,highestLv,10 do
		local temp = i + 9
		if lv > temp and lv <= highestLv then
			chooseTemp = chooseTemp + 1
		end
		if temp <= highestLv then
			local temp1 = i
			if temp1 == 0 then
				temp1 = 1
			end
			local tabTemp = {}		
			for m = 1,tabNum do				
				if tbook[school][100*(school-1)+m] and tbook[school][100*(school-1)+m]["q_lv"] <= temp and temp1 <= tbook[school][100*(school-1)+m]["q_lv"] then
					table.insert(tabTemp,tbook[school][100*(school-1)+m])
				elseif tbook[school][100*(school-1)+m]["q_lv"] > temp then
					break
				end	
			end			
			table.insert(self.tablelist,tabTemp)			
			table.insert(lvTab,string.format(game.getStrByKey("dic_lv1"),temp1,temp))
			if showBtnTemp == 1 then
				break
			end
			if temp >= lv then
				showBtnTemp = 1
			end
		else
			if i == highestLv then
				table.insert(lvTab,string.format(game.getStrByKey("dic_lv2"),i))
			elseif i < highestLv then 
				table.insert(lvTab,string.format(game.getStrByKey("dic_lv1"),i,highestLv))
			end
			local tabTemp = {}
			for m = 1,tabNum do
				if tbook[school][100*(school-1)+m] and tbook[school][100*(school-1)+m]["q_lv"] <= highestLv and i <= tbook[school][100*(school-1)+m]["q_lv"] then
					table.insert(tabTemp,tbook[school][100*(school-1)+m])
				end
			end
			table.insert(self.tablelist,tabTemp)
			break
		end
	end

	G_CONTROL:controlDataFilter( self.tablelist , "q_link" )

	self.title_select_idx = chooseTemp+1
	local choose = chooseTemp
  	if lvTab and highestLv <= lv then
  		choose = #lvTab - 1
  		self.title_select_idx = #lvTab
  	end
  	local callback = function(idx)
    	self.title_select_idx = idx
    	self:getTableView():reloadData()
  	end
  	
  	local btnGroup = {def = "res/component/button/58.png",sel = "res/component/button/58_sel.png"}
	require("src/LeftSelectNode").new(self,lvTab,cc.size(200,465),cc.p(85,70),callback,btnGroup,true,choose)
	-- self:createTableView(bg , cc.size( 730 , 515 ),cc.p( 195 , 10 ) , true ,true)
	self:createTableView(self , cc.size( 602 , 457 ),cc.p( 278 , 73 ) , true ,true)
	-- self:getTableView():setBounceable(false)
	self.tableViewOffsetTemp = true
end

function cqd:tableCellTouched(table,cell)
end

function cqd:cellSizeForTable(table,idx)
	return 105 , 600
end

function cqd:numberOfCellsInTableView(table)
	return #self.tablelist[self.title_select_idx]
end

function cqd:tableCellAtIndex(tableView,idx)
	if self.tableViewOffsetTemp then
		local tableTemp = self:getTableView()
		if tableTemp then
			local contentPos = tableTemp:getContentOffset()
		end		
	end

	local idex = idx + 1
	local cell = tableView:dequeueCell()
    if cell == nil then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local icon = createSprite(cell , "res/common/table/cell23.png" , cc.p( 4 , 3 ) , cc.p( 0 , 0 ))
    createLabel(cell,string.format(game.getStrByKey("dic_lv3"),self.tablelist[self.title_select_idx][idex]["q_lv"]),cc.p(53,75),nil,18,nil,nil,nil,MColor.brown_gray)
    createLabel(cell,self.tablelist[self.title_select_idx][idex]["q_top"],cc.p(53,40),nil,18,nil,nil,nil,MColor.brown_gray)
    
    -- print(string.len(self.tablelist[self.title_select_idx][idex]["q_depict"]),"cccccccccccccccccccccccc")
 --    local posy = 50 
 --    if string.len(self.tablelist[self.title_select_idx][idex]["q_depict"]) > 55 then
 --    	posy = posy + 20
	-- end
	createScale9Sprite(cell,"res/common/table/cell23-1.png",cc.p(273,57),cc.size(350,86))
    createLabel(cell,self.tablelist[self.title_select_idx][idex]["q_depict"],cc.p(102,56),cc.p(0,0.5),18,nil,nil,nil,MColor.deep_brown,nil,345)
    
    local callFun = function()
    	if self.lv >= self.tablelist[self.title_select_idx][idex]["q_lv"] then
    		local isOpen = false
    		local word
    		if self.tablelist[self.title_select_idx][idex]["Value"] then
    			__GotoTarget( {ru = tostring(self.tablelist[self.title_select_idx][idex]["q_link"]),Value = tonumber(self.tablelist[self.title_select_idx][idex]["Value"]) } )
    			isOpen = true
    		else
				word,isOpen = __GotoTarget( {ru = tostring(self.tablelist[self.title_select_idx][idex]["q_link"])} )
			end
			if self.parent and isOpen then
				removeFromParent(self.parent:getParent():getParent())	
			end
		else
			TIPS( { type = 1 ,str = game.getStrByKey("unLevel")})
		end
	end
    local btn = createTouchItem(cell,"res/component/button/39.png",cc.p(520,55),callFun,true)
    createLabel(btn,self.tablelist[self.title_select_idx][idex]["q_function"],cc.p(btn:getContentSize().width/2,btn:getContentSize().height/2),cc.p(0.5,0.5),22,true,nil,nil,MColor.label_yellow)
    return cell
end

return cqd