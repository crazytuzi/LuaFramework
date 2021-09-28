local wingSKillLayer = class("wingSKillLayer",function() return cc.Layer:create() end)
local wingList = class("wingList",require ("src/TabViewLayer") )
local offsetTemp = {}

function wingList:ctor(parent,skills,pos,noGraySkill,graySkill,speSkill,jnc)
	self.skillRedTab = {}
	self.expLabel = {}
	self.bar = {}
	self.selectIdx = jnc or 1
	self.showLayer = nil
	self.help = nil
	self.noGraySkill = noGraySkill
	self.graySkill = graySkill
	self.speSkill = speSkill
	self.select_cell_index = 0
	self.load_data = skills
	
	local title = CreateListTitle(self, cc.p(197.5,510), 326, 45)
	createLabel(title,game.getStrByKey("baseSkill"),cc.p(title:getContentSize().width/2,title:getContentSize().height/2),cc.p(0.5,0.5),23,nil,nil,nil,MColor.lable_yellow)
	self:createTableView(self,cc.size(327,440),pos,true)
	self:getTableView():reloadData()

	if parent then 
		parent:addChild(self)
	end
	if type(skills[self.selectIdx]) ~= "table" and skills[self.selectIdx] >= 1000 then
		self.showLayer = require("src/layers/skill/wingSkill").new(parent,skills[self.selectIdx],1,2)
	else
		self.showLayer = require("src/layers/skill/wingSkill").new(parent,skills[self.selectIdx][1],skills[self.selectIdx][2],1,skills[self.selectIdx][4])
	end	
	self.parent = parent
end

function wingList:cellSizeForTable(table,idx)
	-- if idx == 0  or idx == self.noGraySkill+self.graySkill then
	-- 	return 50,200
	-- else
    	return 120,200
    -- end
end

function wingList:numberOfCellsInTableView(table)
	-- if self.speSkill and self.speSkill > 0 then
 --  		return #self.load_data + 2
 --  	else
 --  		return #self.load_data + 1
 --  	end
 	return #self.load_data
end

function wingList:tableCellTouched(table,cell)
	local data = nil
	local button = nil
	if self.parent:isVisible() then
		-- if cell:getIdx() == 0 or (cell:getIdx() == self.noGraySkill+self.graySkill and self.speSkill and self.speSkill > 0 ) then
		-- else
			local old_cell = table:cellAtIndex(self.selectIdx-1)
			if old_cell then 
				local button = tolua.cast(old_cell:getChildByTag(10),"cc.Sprite")
				if button then
					button:setTexture("res/component/button/42.png")
				end
			end
			local button = cell:getChildByTag(10)
			if button then
				button:setTexture("res/component/button/42_sel.png")
			end
			-- if self.speSkill and self.speSkill > 0 and cell:getIdx() > self.noGraySkill+self.graySkill then
			-- 	data = self.load_data[cell:getIdx()-1]
			-- else
			-- 	data = self.load_data[cell:getIdx()]
			-- end
			data = self.load_data[cell:getIdx()+1]
			if (not self:isVisible()) or (not data) then
				return
			end
			AudioEnginer.playTouchPointEffect()
			if self.help then
				removeFromParent(self.help)
				self.help = nil
			end
			if self.showLayer then
				removeFromParent(self.showLayer)
				self.showLayer = nil
			end
			local skillID
			if type(data) ~= "table" and data >= 1000 then

				self.showLayer = require("src/layers/skill/wingSkill").new(self.parent,data,1,2)
				skillID = data
			else
				self.showLayer = require("src/layers/skill/wingSkill").new(self.parent,data[1],data[2],1,data[4])
				skillID = data[1]

			end
			if getConfigItemByKey("SkillCfg","skillID",skillID,"Is_jh") then
				self.help = __createHelp(
				{
					parent = self.parent,
					str = game.getStrByKey("skill_tip"),
					pos = cc.p(890, 505),
				})
				self.help:setScale(0.8)
			end

			if cell:getChildByTag(1) then
				cell:removeChildByTag(1)
				self.skillRedTab[data[1]..""] = 2
			end
			self.selectIdx = cell:getIdx()+1
		-- end
	end
end

function wingList:tableCellAtIndex(table, idx)
	local data = nil
	local name = ""
	local icon = 0
	local iconSpr = ""
	local expSum = 0
	local nameLabel = nil
	-- local expLabel = nil
	
	local cell = table:dequeueCell()
	if nil == cell then
        cell = cc.TableViewCell:new()
    else 
    	cell:removeAllChildren()
    end
    
    -- if idx == 0 or (idx == self.noGraySkill+self.graySkill and self.speSkill and self.speSkill > 0) then
    -- 	local title = createSprite(cell,"res/layers/skill/title.png",cc.p(165,28))
    -- 	if idx == 0 then
    -- 		createLabel(title,game.getStrByKey("wr_wing_skill"),cc.p(title:getContentSize().width/2,title:getContentSize().height/2),cc.p(0.5,0.5),23,nil,nil,nil,MColor.lable_yellow)
    -- 	end
    -- else
    	local button = createSprite(cell, "res/component/button/42.png",cc.p(165,60))
    	-- if self.speSkill and self.speSkill > 0 and idx > self.noGraySkill+self.graySkill then
    	-- 	data = self.load_data[idx-1]
    	-- else
    	-- 	data = self.load_data[idx]
    	-- end
    	data = self.load_data[idx+1]
    	if idx+1 == self.selectIdx then
			button:setTexture("res/component/button/42_sel.png")
		end
    	if not data then 
			return
		end
    	button:setTag(10)
	    if type(data) ~= "table" and data >= 1000 then
	    	local skillInfo = getConfigItemByKey("SkillCfg","skillID",data)
	    	createSprite(cell,"res/common/bg/itemBg.png",cc.p(60,60))
	    	icon = skillInfo.ico or data
	    	iconSpr = GraySprite:create( "res/skillicon/"..icon..".png" )
	    	cell:addChild(iconSpr)
	    	iconSpr:setAnchorPoint(cc.p( 0.5 , 0.5 ))
	    	iconSpr:setPosition( cc.p( 60,61 ))
	    	iconSpr:setScale(0.8)
	    	iconSpr:addColorGray()
	    	name = skillInfo.name or data 
	    	createLabel(cell,name,cc.p(115,80),cc.p(0.0,0.5),22,nil,nil,nil,MColor.gray)
	    	createLabel(cell,game.getStrByKey("skill_nlearn"),cc.p(105,45),cc.p(0.0,0.5),20,nil,nil,nil,MColor.gray)
	    else
	    	--local skillSit = {44,50,51,52,53}
	    	local tempForColor = 1
	    	local skillInfo = getConfigItemByKey("SkillCfg","skillID",data[1])
	    	local skillLevelInfo = getConfigItemByKey("SkillLevelCfg","skillID",data[1]*1000+data[2])
	    	createSprite(cell,"res/common/bg/itemBg.png",cc.p(60,61))
		    icon = skillInfo.ico or data[1]
		    iconSpr = createSprite(cell,"res/skillicon/"..icon..".png",cc.p(60,61),cc.p(0.5,0.5),nil,0.8)
		    name = skillLevelInfo.name1
		    nameLabel = createLabel(cell,name,cc.p(115,63),cc.p(0.0,0.5),22,nil,nil,nil,MColor.lable_yellow)
		    local explab,lvLabel = nil,nil		 
		    if skillLevelInfo.skill_color then
		    	nameLabel:setPosition(cc.p(115,80))
		    	lvLabel = createLabel(cell,game.getStrByKey(tostring("skillLevel"..skillLevelInfo.skill_color)),cc.p(115,50),cc.p(0,0.5),22,nil,nil,nil,MColor.lable_yellow)
		    end
			if skillLevelInfo.sld then
				expSum = skillLevelInfo.sld
				local skEx = data[4] or 0
				-- self.expLabel[data[1]] = createLabel(cell,"Exp  "..skEx.."/"..expSum,cc.p(115,45),cc.p(0.0,0.5),22,nil,nil,nil,MColor.lable_yellow)
				explab = createLabel(cell,"Exp",cc.p(115,32),cc.p(0.0,0.5),22,nil,10,nil,MColor.lable_yellow)
				self.bar[data[1]] = createBar( {
					bg = "res/common/progress/jd20-bg.png" ,
					front = {path = "res/common/progress/jd20-bar.png", offX = 2,offY = 1} ,
					parent = cell,
					pos = cc.p(155,30) ,
					anchor = cc.p(0,0.5) ,
					percentage = 100*skEx/expSum,
				})
				self.expLabel[data[1]] = createLabel(cell,tostring(math.floor(10000*skEx/expSum)/100).."%",cc.p(230,30),cc.p(0.5,0.5),22,nil,10,nil,MColor.white)
				nameLabel:setPosition(cc.p(115,90))
				lvLabel:setPosition(cc.p(115,60))
			end
			--if data[1] ~= 1000 and data[1] ~= 1001 then
			if skillInfo.canUpgrade and (skillInfo.maxlv and skillInfo.maxlv > 1) then
				local colorOfStar = {"s4","s3"}
				local starNum = skillLevelInfo.skill_starNum
				if starNum and  starNum > 0 then
					for i = 1 ,3 do
						local pos = cc.p( 165+40*i , 60 )
						if not skillLevelInfo.sld then
							pos = cc.p( 165+40*i , 50 )
						end
						if i <= starNum then
							createSprite( cell , "res/group/star/"..colorOfStar[1]..".png" , pos) 
						else
							createSprite( cell , "res/group/star/"..colorOfStar[2]..".png" , pos) 
						end
					end
				end
			end
			if wingSKillLayer:canUpdate(data)	then
				if not self.skillRedTab[data[1]..""] or (self.skillRedTab[data[1]..""] and self.skillRedTab[data[1]..""] ~= 2) then
					local red_hot = createSprite( cell ,"res/component/flag/red.png" ,cc.p(310 , 105 ) , cc.p( 0.5 , 0.5 ) )
					red_hot:setTag(1)
					G_TUTO_NODE:setTouchNode(iconSpr, TOUCH_SKILL_UPDATE_SKILL1)
					self.skillRedTab[data[1]..""] = 1
				end
			end
		end
	-- end
    return cell
end

function wingSKillLayer:ctor(parent,jnc)
	createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(30, 40),
        cc.size(335,500),
        5
    )
    local right_bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(370, 40),
        cc.size(556,500),
        5
    )
	createSprite(right_bg, "res/common/bg/bg66-1.jpg",cc.p(1,3),cc.p(0,0))

	self:init()

	self.tab1 = wingList.new(self,self.skills1,cc.p(32,45),self.specialSkill,self.skillGrayNum,self.specialSkill1,jnc)

	-- self.tab2 = wingList.new(self,self.skills2,cc.p(50,20))
	self:initTouch() 
end

function wingSKillLayer:canUpdate(data)
	-- if data and data[4] and tonumber(data[4]) > 0 then
	-- 	local sld = getConfigItemByKey("SkillLevelCfg","skillID",data[1]*1000+data[2],"sld") 
	-- 	local skill_info = getConfigItemByKey("SkillCfg","skillID",data[1])
	-- 	if sld and skill_info.maxlv and sld <= tonumber(data[4]) and skill_info.maxlv > data[2] then --(not (skill_info.q_jieduan == 1 and data[2] == 4 and (not skill_info.jnjj) ) or (skill_info.q_jieduan == 2 and data[2] == 8)) then
	-- 		for i = 1,#G_SKILL_REDCHECK+1 do
	-- 			if G_SKILL_REDCHECK[i] == data[1] then
	-- 				break
	-- 			end
	-- 			if i == #G_SKILL_REDCHECK+1 then
	-- 				table.insert(G_SKILL_REDCHECK,data[1])
	-- 				break
	-- 			end
	-- 		end
	-- 		return true
	-- 	end
	-- end
	checkWingSkillRed()
	return G_SKILL_REDCHECK[2][data[1]]
end

function wingSKillLayer:reload(how,skillID,skillEXP,sld)
	if how then
		if how == 1 then
			self:init()
			self.tab1.load_data = self.skills1
			offsetTemp = self.tab1:getTableView():getContentOffset()
			self.tab1:getTableView():reloadData()
			if offsetTemp then
				self.tab1:getTableView():setContentOffset(offsetTemp)
			end
		elseif how ==2 and skillID and sld and skillEXP and self.tab1.expLabel[skillID] and self.tab1.bar[skillID] then
			local tmpLabel = tolua.cast(self.tab1.expLabel[skillID], "cc.Label")
			if tmpLabel then
				tmpLabel:setString(tostring(math.floor(10000*skillEXP/sld)/100).."%")
			end
			local tmpBar =  tolua.cast(self.tab1.bar[skillID], "cc.ProgressTimer")
			if tmpBar then
				tmpBar:setPercentage(100*skillEXP/sld)
			end
		end
	end
end

function wingSKillLayer:init()
	self.skills1 = {}   --已学技能表
	self.skills12 = {}   --未学技能表
	self.specialSkill = 1	--已学技能数量（名字不改了）
	self.specialSkill1 = 0   --已学特殊技能数量(神戒技能等，现在没有了)
	local MskillOp = require "src/config/skillOp"
	self.skills12 = MskillOp:allWingSkills()
	self.skillGrayNum = 0
	for k,v in ipairs(G_ROLE_MAIN.wingskills)do
		local jnfenlie = getConfigItemByKey("SkillCfg","skillID",v[1],"jnfenlie")
		local s_type = getConfigItemByKey("SkillCfg","skillID",v[1],"skillspecialtype")
		local use_type = getConfigItemByKey("SkillCfg","skillID",v[1],"useType")
		if jnfenlie and jnfenlie == 7 and s_type and use_type == 2 then
			if s_type == 1 then
				table.insert(self.skills1,v)				
				self.specialSkill = self.specialSkill + 1
			end
		end	
		for m,n in ipairs(self.skills12) do
			if n[1] == v[1] then
				table.remove(self.skills12,m)
				break
			end
		end
	end
	table.sort(self.skills12,function(a,b) return a[2]>b[2] end)  --未学光翼技能来个排序
	for k,v in ipairs(self.skills12) do
		table.insert(self.skills1,self.specialSkill,v[1])
	end
	self.skillGrayNum = tablenums(self.skills12)

end

function wingSKillLayer:initTouch() 
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    	local pos = touch:getLocation()
    	if  500 >= pos.y and pos.x > (g_scrCenter.x-480) and pos.x < 960 and self:isVisible() then
       		return true
       	end
       	return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)

end

return wingSKillLayer
