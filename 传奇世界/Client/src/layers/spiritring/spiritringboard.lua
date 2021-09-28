local SpiritRingBoard = class("SpiritRingBoard", function( ) return cc.Layer:create() end)

function SpiritRingBoard:ctor( p )

	self.spiritringSum = #require("src/config/spiritring")
	self.tagColor = 1
	self.ringLabel = {}
	local msgids = {SKILL_SC_UPGRADESKILL}
	require("src/MsgHandler").new(self, msgids)

	-- body
	self.parent = p
	local sdata = require("src/layers/spiritring/ringdata")
	sdata:init()
	local sv_data = sdata:getServerData()
	self.sv_data = sv_data
	--dump(sv_data)
	--神戒解锁签到天数
	self.needday = sdata:getNeedDayData()

	local resPath = "res/layers/spiritring/"

	self.bg, self.closeBtn = createBgSprite(self,game.getStrByKey("title_GodRing"))
	G_TUTO_NODE:setTouchNode(self.closeBtn, TOUCH_RING_CLOSE) 
	self.bgsize =  self.bg:getBoundingBox()
	self.bg1 = createSprite(self.bg , "res/layers/spiritring/bg2.png", cc.p(self.bgsize.width/2+1 , self.bgsize.height/2 - 35))
	self.bg1size = self.bg1:getBoundingBox()

	--默认选择第一个神戒
	self.choosering = 1

	--动画
	createSprite(self.bg1 , "res/layers/spiritring/ring_k.png", cc.p(self.bg1size.width/2+10 , self.bg1size.height - 182))

	self.ring_effect = Effects:create(false)
	self.ring_effect:setCleanCache()
	self.ring_effect:setAnchorPoint(cc.p(0.5,0.5))
	self.ring_effect:setPosition(cc.p(self.bg1size.width/2 + 8 , self.bg1size.height - 182))
	self.ring_effect:playActionData("ringeffect"..self.choosering,7,0.8,-1)
	self.bg1:addChild(self.ring_effect)

	--激活按钮
	local menuupdate = createMenuItem(self.bg1, "res/component/button/50.png", cc.p(self.bg1size.width/2+10,50), function() self:ringUpdate() end)
	G_TUTO_NODE:setTouchNode(menuupdate, TOUCH_RING_ACTIVE)

	--createScale9Sprite(self.bg1, "res/common/31.png", cc.p(140, 270), cc.size(270, 440))
	createSprite(self.bg1,"res/common/kuang.png",cc.p(785,265))
	self.ringlayer = cc.Layer:create()
	self.ringlayer:setPosition(0,0)
	self.bg1:addChild(self.ringlayer)

	self.rupdatef = false --升级标志
	g_EventHandler["ringflash"] = function()
		local sdata = require("src/layers/spiritring/ringdata").rdata
		local sv_data = require("src/layers/spiritring/ringdata"):getServerData()
		cclog("神戒解锁成功！！！")
		if self.rupdatef then
			self:ringUpdateChange()
			self:showProperty()
		else

			self.ringlayer:removeAllChildren()
			self:ringShow()
		end
		self.updatesprite:setString(game.getStrByKey("updateRing"))
		self.sign:setVisible(false)
		self.theRedPoint:setVisible(false)
	end

	local function callSignIn()
		-- body
		--local layer = require("src/layers/activity/cell/sign_in").new()
	end
  	self.sign = createTouchItem(self.bg1 , "res/common/bg/titleLine2.png", cc.p(self.bg1size.width/2, 230), callSignIn)

  	local signsize = self.sign:getContentSize()
  	self.qiandaoTip = createLabel(self.sign, game.getStrByKey("ring_days"), cc.p(signsize.width/2, 15), cc.p(0.5, 0.5), 18,nil,nil,nil,MColor.lable_yellow)
  	local ldate = sv_data.logindate or 0
  	self.jiandaodays = createLabel(self.sign, ldate.."/"..self.needday[self.choosering], cc.p(signsize.width/2 - 55, 15),cc.p(0.5, 0.5),20)
  	self.jiandaodays:setColor(cc.c3b(0, 255, 0))
  	if self:isRingOn(self.choosering) then
		self.updatesprite = createLabel(menuupdate,game.getStrByKey("updateRing"),cc.p(menuupdate:getContentSize().width/2,menuupdate:getContentSize().height/2),cc.p(0.5,0.5),21,nil,nil,nil,MColor.lable_yellow)
		self.sign:setVisible(false)
	else
		self.updatesprite = createLabel(menuupdate,game.getStrByKey("activityRing"),cc.p(menuupdate:getContentSize().width/2,menuupdate:getContentSize().height/2),cc.p(0.5,0.5),21,nil,nil,nil,MColor.lable_yellow)
	end

	self.qiandaoTip:setString(game.getStrByKey("ring_level"))
	self.jiandaodays:setString("17")

	self.theRedPoint = createSprite(self.updatesprite,"res/component/flag/red.png",cc.p(135,35),cc.p(0.5,0.5))	
	self.theRedPoint:setVisible(false)
  	--关闭按钮
  	self.ringlayer:removeAllChildren()
  	self:ringShow()
  	self.propnode = cc.Node:create()
  	self.bg1:addChild(self.propnode)
  	createSprite(self.propnode, "res/common/bg/titleBg-3.png", cc.p(780, 480))
  	createSprite(self.propnode, "res/common/bg/titleBg-3.png", cc.p(780, 380))
  	createSprite(self.propnode, "res/common/bg/titleBg-3.png", cc.p(780, 190))
  	createLabel(self.propnode,game.getStrByKey("ring_property"),cc.p(780, 380),cc.p(0.5,0.5),25,nil,nil,nil,MColor.lable_yellow)
  	createLabel(self.propnode,game.getStrByKey("ring_result"),cc.p(780, 190),cc.p(0.5,0.5),25,nil,nil,nil,MColor.lable_yellow)
  	local Mnode = require "src/young/node"
  	Mnode.listenTouchEvent({
	node = self,
	begin = function(touch)
		return true
	end,})
	self.propertynode = cc.Layer:create()
	self.bg1:addChild(self.propertynode)
	self:showProperty()

 	self.updateprog = 0

 	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_RING)
		elseif event == "exit" then
			g_EventHandler["ringflash"] = nil
		end
	end)
end

function SpiritRingBoard:isRingOn(id)
	local sdata = require("src/layers/spiritring/ringdata"):getServerData()
	for k,v in pairs(sdata) do
		if type(v) == "table" then
			if v.id ~=nil and v.id == id then
				return true
			end
		end
	end

	return false
end

function SpiritRingBoard:getRingData(id)
	for k,v in pairs(require("src/layers/spiritring/ringdata"):getServerData()) do
		if type(v) == "table" then
			if v.id ~=nil and v.id == id then
				return v
			end
		end
	end

	return nil
end

function SpiritRingBoard:networkHander(buff,msgid)
	local switch = {
		[SKILL_SC_UPGRADESKILL] = function()
			log("receive SKILL_SC_UPGRADESKILL")
			local skills = {buff:popShort(),buff:popChar(),buff:popChar()}
			log("skills[i]"..skills[1].."///"..skills[2].."//"..skills[3])
			for k,v in pairs(G_ROLE_MAIN.skills)do
				if v[1] == skills[1] then
					v[2] = skills[2]
					break
				end
			end
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function SpiritRingBoard:call_func(tag)
	-- body
	cclog("touched ,当前选中戒指id:"..tag)
	if self.ringLabel[tag] then
		self.ringLabel[tag]:setColor(MColor.lable_yellow)
		if self.tagColor ~= tag then
			if self.ringLabel[self.tagColor] then
				self.ringLabel[self.tagColor]:setColor(MColor.lable_black)
			end
		end
		self.tagColor = tag
	end
	self.choosering = tag
	self.islock = false
	self:showProperty()
	self.ring_effect:playActionData("ringeffect"..self.choosering,7,0.8,-1)
	self.ring_effect:setPositionY(self.bg1size.height - 182)
	self.sign:setVisible(false)
	self.theRedPoint:setVisible(false)
	--self.updatesprite:setTexture("res/layers/spiritring/update.png")
	self.updatesprite:setString(game.getStrByKey("updateRing"))
end

function SpiritRingBoard:call_func_no( tag )
	-- body
	cclog("touched ,当前选中戒指id:"..tag)
	if self.ringLabel[self.tagColor] then
		self.ringLabel[self.tagColor]:setColor(MColor.lable_black)
	end
	self.choosering = tag --self.ringnum + 1 -
	self.islock = true
	self:showProperty()
	local sdata = require("src/layers/spiritring/ringdata")
	local sv_data = sdata:getServerData()
	local ldate = sv_data.logindate or 0
	if self.needday and ldate >= tonumber(self.needday[tag]) then
		self.theRedPoint:setVisible(true)
	else
		self.theRedPoint:setVisible(false)
	end
	self.ring_effect:playActionData("ringeffect"..self.choosering,7,0.8,-1)

	self.ring_effect:setPositionY(self.bg1size.height - 182)

	self.updatesprite:setString(game.getStrByKey("activityRing"))
	local sdata = require("src/layers/spiritring/ringdata")
	local sv_data = sdata:getServerData()
	local ldate = sv_data.logindate or 0
	self.sign:setVisible(true)
	self.jiandaodays:setString(ldate.."/"..self.needday[self.choosering])
	if self.choosering == 1 then
		self.qiandaoTip:setString(game.getStrByKey("ring_level"))
		self.jiandaodays:setString("17")
	else
		self.qiandaoTip:setString(game.getStrByKey("ring_days"))
		self.jiandaodays:setString(ldate.."/"..self.needday[self.choosering])
	end
end

function SpiritRingBoard:ringShow()
	local tab_control = {}
	for i = 1,5 do
		if self:isRingOn(i) then
			local tab = {}
			--local name = "res/layers/spiritring/name"..i..".png"
			local namer = "res/layers/spiritring/"..i..".png"
			local menu_item1 = cc.MenuItemImage:create("res/layers/spiritring/rshow_k.png", "res/layers/spiritring/rshow_k2.png")
			if i == 1 then
				G_TUTO_NODE:setTouchNode(menu_item1, TOUCH_RING_FIRST)
			end
			--menu_item1:setPosition(self.bg1size.width - 800, self.bg1size.height  + 30 - 100 * i)
			menu_item1:setPosition(cc.p(self.bg1size.width - 800, self.bg1size.height  + 30 - 100 * i))
			--menu_item1:runAction(cc.Sequence:create(cc.MoveTo:create(0.5+(i*0.05),cc.p(self.bg1size.width - 800, self.bg1size.height  + 30 - 100 * i))))
			tab.menu_item = menu_item1
			tab.callback = function(tag) self:call_func(tag) end
			table.insert(tab_control, tab)
			--createSprite(menu_item1, name, cc.p(145, 40))
			self.ringLabel[i] = createLabel(menu_item1,game.getStrByKey("ring"..i),cc.p(94,40),cc.p(0,0.5),25)
			if i == 1 then
				self.ringLabel[i]:setColor(MColor.lable_yellow)
			else
				self.ringLabel[i]:setColor(MColor.lable_black)
			end
			createSprite(menu_item1, namer, cc.p(45, 45),nil,nil,0.8)
		else
			local tab = {}
			--local name = "res/layers/spiritring/name"..i.."_1.png"
			--createSprite(self.bg1, "res/layers/spiritring/rshow_k1.png", cc.p(self.bg1size.width - 150, self.bg1size.height - 600 + 100 * i))
			local menu_item1 = cc.MenuItemImage:create("res/layers/spiritring/rshow_k1.png", "res/layers/spiritring/rshow_k1.png")
			if i == 1 then
				G_TUTO_NODE:setTouchNode(menu_item1, TOUCH_RING_FIRST)
			end
			local sdata = require("src/layers/spiritring/ringdata")
			local sv_data = sdata:getServerData()
			local ldate = sv_data.logindate or 0
			local redPoint = createSprite(menu_item1,"res/component/flag/red.png",cc.p(220,80),cc.p(0.5,0.5))
			if self.needday and ldate >= tonumber(self.needday[i]) then
				redPoint:setVisible(true)
			else
				redPoint:setVisible(false)
			end

			--menu_item1:setPosition(self.bg1size.width - 800, self.bg1size.height + 30 - 100 * i) --600 +
			menu_item1:setPosition(self.bg1size.width - 800, self.bg1size.height  + 30 - 100 * i)
			--menu_item1:runAction(cc.Sequence:create(cc.MoveTo:create(0.5+(i*0.05),cc.p(self.bg1size.width - 800, self.bg1size.height  + 30 - 100 * i))))
			tab.menu_item = menu_item1
			tab.callback = function(tag) self:call_func_no(tag) end
			--table.insert(tab_control, tab)
			tab_control[i]=tab
			-- createSprite(self.ringlayer, "res/layers/spiritring/r_hui.png", cc.p(self.bg1size.width - 865, self.bg1size.height + 30 - 100 * i), cc.p(0.5, 0.5), 10)
			-- createSprite(self.ringlayer, "res/layers/spiritring/lian.png", cc.p(self.bg1size.width - 797, self.bg1size.height + 30 - 100 * i), cc.p(0.5, 0.5), 10)
			-- --createSprite(self.ringlayer, name, cc.p(self.bg1size.width - 761, self.bg1size.height + 25 - 100 * i), cc.p(0.5, 0.5), 10)
			-- createLabel(self.ringlayer,game.getStrByKey("ring"..i),cc.p(self.bg1size.width - 815, self.bg1size.height + 25 - 100 * i),cc.p(0,0.5),25,nil,nil,nil,MColor.gray)
			createSprite(self.ringlayer, "res/layers/spiritring/r_hui.png", cc.p(self.bg1size.width - 865, self.bg1size.height  + 30 - 100 * i), cc.p(0.5, 0.5), 10)--:runAction(cc.Sequence:create(cc.MoveTo:create(0.5+(i*0.05),cc.p(self.bg1size.width - 865, self.bg1size.height  + 30 - 100 * i))))
			createSprite(self.ringlayer, "res/layers/spiritring/lian.png", cc.p(self.bg1size.width - 797, self.bg1size.height  + 30 - 100 * i), cc.p(0.5, 0.5), 10)--:runAction(cc.Sequence:create(cc.MoveTo:create(0.5+(i*0.05),cc.p(self.bg1size.width - 797, self.bg1size.height  + 30 - 100 * i))))
			--createSprite(self.ringlayer, name, cc.p(self.bg1size.width - 761, self.bg1size.height + 25 - 100 * i), cc.p(0.5, 0.5), 10)
			createLabel(self.ringlayer,game.getStrByKey("ring"..i),cc.p(self.bg1size.width - 815, self.bg1size.height  + 25 - 100 * i),cc.p(0,0.5),25,nil,nil,nil,MColor.gray)--:runAction(cc.Sequence:create(cc.MoveTo:create(0.5+(i*0.05),cc.p(self.bg1size.width - 815, self.bg1size.height  + 25 - 100 * i))))
		end
	end
	creatTabControlMenu(self.ringlayer, tab_control, 1)
end

function SpiritRingBoard:bagShow(num)
	-- body
	self.parent:addChild(self, 200)
	self.choosering = num
	if self:isRingOn(self.choosering) then
		MessageBox(game.getStrByKey("ring_noGet"))
		return
	end
	self:ringUpdate()
end

function SpiritRingBoard:ringUpdate()
	self.rupdatef = true
	--升级
	local sdata = require("src/layers/spiritring/ringdata").rdata
	--local serverdata = require("src/layers/spiritring/ringdata"):getServerData()
	local ringid = 1
	local ringTemp = 0
	local ringData = self:getRingData(self.choosering)
	local ringData_1 = self:getRingData(self.choosering-1)
	if ringData_1 then
		self.lvTemp = ringData_1.lvl
	end
	if ringdata then
		if ringData.lvl == 9 then
			ringTemp = 1
		end
	end
	--限制条件
	if ringTemp == 0 and self.choosering-1 ~= 0 and (self:isRingOn(self.choosering-1) == false or (ringData and ringData_1 and ringData_1.lvl <= ringData.lvl)) and ringData.lvl < 9 then
		local ringName_1 = getConfigItemByKey("spiritring","q_id",(self.choosering-1)*9,"q_name")
		local ringName = getConfigItemByKey("spiritring","q_id",self.choosering*9,"q_name")
		local ringTip = string.format(game.getStrByKey("ring_up"),ringName,ringName_1)
		self.rupdatef = false
		TIPS( { type = 1 , str = ringTip }  )
		return 
	end
	-- body 激活
	if self:isRingOn(self.choosering) == false then
		self.rupdatef = false
		g_msgHandlerInst:sendNetDataByFmtExEx(TALISMAN_CS_ACTIVE, "ic", G_ROLE_MAIN.obj_id, self.choosering)
		return
	end

	if ringData then
		ringid = (self.choosering-1)*9 + ringData.lvl
	end
	self.rupdatelayer = cc.Layer:create()
	self.rupdatelayer:setPosition(0, 0)
	--self:addChild(self.rupdatelayer, 10)
	Manimation:transit(
		{
			ref = self,
			node = self.rupdatelayer,
			curve = "-",
			sp = cc.p(display.width/2, 0),
			zOrder = 10,
			swallow = true,
		})
	local bg = createSprite(self.rupdatelayer, "res/layers/spiritring/ring_update.png", cc.p(display.width/2, display.height/2))
	local bg_Size = bg:getContentSize()
	createSprite(bg,"res/common/bg/titleLine2.png",cc.p(bg_Size.width/2, bg_Size.height - 60))
	createLabel(bg, game.getStrByKey("ringupdatetext"), cc.p(bg_Size.width/2, bg_Size.height - 60),cc.p(0.5, 0.5),22,true,nil,nil,MColor.lable_yellow)
	local label1 = createLabel(bg, game.getStrByKey("ringupdatepro"), cc.p(80, bg_Size.height - 280),cc.p(0.5, 0.5),22,true,nil,nil,MColor.lable_yellow)
	local label2 = createLabel(bg, game.getStrByKey("ringupdatetext1"), cc.p(bg_Size.width/2, 170),cc.p(0.5, 0.5),18,true,nil,nil,MColor.red)
	createSprite(bg,"res/common/bg/bg2-1.png",cc.p(bg_Size.width/2, bg_Size.height/2 +15))

 --    	--触控机制
 registerOutsideCloseFunc(bg, function() if self.rupdatelayer then removeFromParent(self.rupdatelayer) self.rupdatelayer = nil end end)
 	function closeFunc()
 		if self.rupdatelayer then 
 			removeFromParent(self.rupdatelayer) 
 			self.rupdatelayer = nil 
 		end
 	end
 	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-30,bg:getContentSize().height-30), closeFunc, nil)
 	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_RING_UPDATE_CLOSE)
 	-- closeBtn:setScale(0.8)

    local p1 = {}
	local p2 = {}
	local s1, s2
	local rid1 = 0
	--dump(serverdata)
	--dump(self.choosering)
	if ringData.lvl <9 then
		rid1 = ringid + 1
		self.isTopLevel = false
	else
		rid1 = ringid
		self.isTopLevel = true
	end
	self.ringLv = ringData.lvl

	dump(sdata[ringid])
	dump(sdata[rid1])
	--根据职业选择属性数据
    if self.rolejob == 1 then
		p1 = sdata[ringid].soldier_prop
		p2 = sdata[rid1].soldier_prop
	elseif self.rolejob == 2 then
		p1 = sdata[ringid].master_prop
		p2 = sdata[rid1].master_prop
	else
		p1 = sdata[ringid].taoist_prop
		p2 = sdata[rid1].taoist_prop
	end
	s1 = getConfigItemByKey("spiritring", "q_id", sdata[ringid].id, "q_skillID")--sdata[ringid].q_skillID
	s2 = getConfigItemByKey("spiritring", "q_id", sdata[rid1].id, "q_skillID")--sdata[nextlvl].q_skillID

	--战斗力计算
	local ft1 = self:getBattle(p1, s1)
	local ft2 = self:getBattle(p2, s2)
	local arrowSprite = createSprite(bg, "res/layers/spiritring/ring_update1.png", cc.p(bg_Size.width/2+3, bg_Size.height - 125))
	self.arrowSprite = arrowSprite
	--弹出戒指属性
	local function call_ringprop1()
		-- body
		cclog("ringprop1")
		local tip = require("src/layers/task/tips").new()
		tip:showRingProps(self.choosering, sdata[ringid].level, ft1)
		G_MAINSCENE:addChild(tip, 230)
	end

	--弹出戒指属性
	local function call_ringprop2()
		-- body
		cclog("ringprop2")
		local tip = require("src/layers/task/tips").new()
		local rid1 = 1
		if ringData.lvl <9 then
			rid1 = ringid + 1
		else
			rid1 = ringid
		end
		tip:showRingProps(self.choosering, sdata[rid1].level, ft2)
		G_MAINSCENE:addChild(tip, 230)
	end

	--左边戒指图标
	local item1 = require( "src/layers/task/taskrewards" ).new()
	item1:setRingUpdate("res/layers/spiritring/"..self.choosering..".png", call_ringprop1)
	bg:addChild(item1)
	item1:setPosition(bg_Size.width/2-135, bg_Size.height - 163)
	self.leftRing = item1

	--右边戒指图标
	if not self.isTopLevel then
		local item2 = require( "src/layers/task/taskrewards" ).new()
		item2:setRingUpdate("res/layers/spiritring/"..self.choosering..".png", call_ringprop2)
		bg:addChild(item2)
		item2:setPosition(bg_Size.width/2+65, bg_Size.height - 163)
		self.rightRing = item2
	end
	--进度条
	local progressbg = createSprite(bg, "res/common/progress/cj3.png", cc.p(bg_Size.width/2, 215))
	local s_p = cc.Sprite:create("res/common/progress/cj4.png")
	--s_p:setScaleX(1.7)
	self.progress1 = cc.ProgressTimer:create(s_p)
	self.progress1:setPosition(cc.p(bg_Size.width/2, 215))
	self.progress1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.progress1:setAnchorPoint(cc.p(0.5, 0.5))
	self.progress1:setBarChangeRate(cc.p(1, 0))
 	self.progress1:setMidpoint(cc.p(0,1))
 	self.progress1:setPercentage(math.floor(ringData.updateneed * 100 / sdata[ringid].need1))--
 	bg:addChild(self.progress1) -- ringData.updateneed.."/"..sdata[ringid].need1
 	self.label_lucky = createLabel(bg, ringData.updateneed.."/"..sdata[ringid].need1, cc.p(bg_Size.width/2, 215),cc.p(0.5, 0.5),20)

 	--获取两种碎片数量
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	self.need1num = pack:countByProtoId(sdata[ringid].need2)
	local need2num = pack:countByProtoId(sdata[ringid].need3)

	local function updateNormalFun()
		--顶级判断
		if self.isTopLevel then
			self.label_lucky:setVisible(false)
			MessageBox(game.getStrByKey("ring_top_level"), nil, nil)
			return
		end
		
		if self.choosering-1 ~= 0 and self.propLV >= self.lvTemp and not self.isTopLevel then
			local ringName_1 = getConfigItemByKey("spiritring","q_id",(self.choosering-1)*9,"q_name")
			local ringName = getConfigItemByKey("spiritring","q_id",self.choosering*9,"q_name")
			local ringTip = string.format(game.getStrByKey("ring_up"),ringName,ringName_1)
			TIPS( { type = 1 , str = ringTip }  )
			return 
		end
		-- body专属碎片
		log("call_update1")
		if self.need1num > 0 then
			--addUpdateEffect(item1)
			--g_msgHandlerInst:sendNetDataByFmtExEx(TALISMAN_CS_CHARGE, "icii", G_ROLE_MAIN.obj_id, self.choosering, sdata[ringid].need2, 1)
			local surplus = math.ceil((self.allPower - self.havePower)/4)
			if surplus > self.need1num then
				--g_msgHandlerInst:sendNetDataByFmtExEx(TALISMAN_CS_CHARGE, "icii", G_ROLE_MAIN.obj_id, self.choosering, sdata[ringid].need2, self.need1num)
			else
				--g_msgHandlerInst:sendNetDataByFmtExEx(TALISMAN_CS_CHARGE, "icii", G_ROLE_MAIN.obj_id, self.choosering, sdata[ringid].need2, surplus)
			end
		else
			local message = string.format(game.getStrByKey("ring_tip_needMore"), sdata[ringid].name..game.getStrByKey("ringneed1"))
			MessageBox(message,nil,nil)
			return
		end
	end

	local function updateAlllFun()
		--顶级判断
		if self.isTopLevel then
			self.label_lucky:setVisible(false)
			if not getRunScene():getChildByTag(1201) then
				local msgbox = MessageBox(game.getStrByKey("ring_top_level"), nil, nil)
				msgbox:setTag(1201)
			end
			return
		end

		if self.choosering-1 ~= 0 and self.propLV >= self.lvTemp and not self.isTopLevel then
			local ringName_1 = getConfigItemByKey("spiritring","q_id",(self.choosering-1)*9,"q_name")
			local ringName = getConfigItemByKey("spiritring","q_id",self.choosering*9,"q_name")
			local ringTip = string.format(game.getStrByKey("ring_up"),ringName,ringName_1)
			TIPS( { type = 1 , str = ringTip }  )
			return 
		end
		-- body万能碎片
		log("call_update1")
		if need2num > 0 then
			--addUpdateEffect(item1)
			--g_msgHandlerInst:sendNetDataByFmtExEx(TALISMAN_CS_CHARGE, "icii", G_ROLE_MAIN.obj_id, self.choosering, sdata[ringid].need3, 1)
		else
			local message = string.format(game.getStrByKey("ring_tip_needMore"), sdata[ringid].name..game.getStrByKey("ringneed2"))
			MessageBox(message,nil,nil)
			return
		end
	end

	--对应碎片
	self.item3 = require( "src/layers/task/taskrewards" ).new()
	self.havePower = ringData.updateneed
	self.allPower = sdata[ringid].need1
	self.item3:setItems(sdata[ringid].need2, self.need1num, updateNormalFun, 4)
	bg:addChild(self.item3)
	self.item3:setPosition(bg_Size.width/2-135,65)
	self.lbnd3 = createLabel(bg, sdata[ringid].name..game.getStrByKey("ringneed1"), cc.p(bg_Size.width/2-95,40),cc.p(0.5, 0.5),20,true,nil,nil,MColor.blue)
	
	G_TUTO_NODE:setTouchNode(self.item3:getBgNode(), TOUCH_RING_UPDATE_STONE_1)

	--万能碎片
	self.item4 = require( "src/layers/task/taskrewards" ).new()
	self.item4:setItems(sdata[ringid].need3, need2num, updateAlllFun, 1)
	bg:addChild(self.item4)
	self.item4:setPosition(bg_Size.width/2 + 65,65)
	local lbnd4 = createLabel(bg, game.getStrByKey("ringneed2"), cc.p(bg_Size.width/2+100,40),cc.p(0.5, 0.5),20,true,nil,nil,MColor.purple)
	

	G_TUTO_NODE:setTouchNode(self.item4:getBgNode(), TOUCH_RING_UPDATE_STONE_2)

	--左边戒指名字等级战斗力
	local pos = {}
	if self.isTopLevel then
		pos = {cc.p(133, 335),cc.p(215, 335),cc.p(133, 305),cc.p(190, 305)}
	else
		pos = {cc.p(33, 335),cc.p(115, 335),cc.p(33, 305),cc.p(90, 305)}
	end
	self.ringlvl1 = createLabel(bg, sdata[ringid].name,pos[1], cc.p(0, 0), 20,true,nil,nil,MColor.lable_yellow)
	self.ringlvl11 = createLabel(bg, "Lv"..sdata[ringid].level, pos[2], cc.p(0, 0), 20,true,nil,nil,MColor.lable_yellow)
	self.fightlabe1 = createLabel(bg, game.getStrByKey("combat_power"), pos[3], cc.p(0, 0), 20,true,nil,nil,MColor.yellow)
	self.ringb1 = createLabel(bg, "  +"..self:getBattle(p1, s1), pos[4], cc.p(0, 0) ,20,true,nil,nil,MColor.yellow)

	--右边戒指名字等级战斗力
	if not self.isTopLevel then
		self.ringlvl2 = createLabel(bg, sdata[ringid].name, cc.p(233, 335), cc.p(0, 0), 20,true,nil,nil,MColor.lable_yellow)
		self.ringlvl22 = createLabel(bg, "Lv"..sdata[rid1].level, cc.p(315, 335), cc.p(0, 0), 20,true,nil,nil,MColor.lable_yellow)
		self.fightlabe2 = createLabel(bg, game.getStrByKey("combat_power"), cc.p(233, 305), cc.p(0, 0), 20,true,nil,nil,MColor.yellow)
		self.ringb2 = createLabel(bg, "  +"..self:getBattle(p2, s2), cc.p(290, 305), cc.p(0, 0) ,20,true,nil,nil,MColor.yellow)
	end
	--当戒指为顶级时
 	if self.isTopLevel then
 		item1:setPositionX(bg:getContentSize().width/2 - 35)

 		label1:setVisible(false)
 		progressbg:setVisible(false)
 		self.progress1:setVisible(false)
 		self.label_lucky:setVisible(false)
 		-- item2:setVisible(false)
 		-- rightInfoBg:setVisible(false)
 		arrowSprite:setVisible(false)
 	end

 	local dataSourceChanged = function(observable, event, pos, pos1, gird)
 		log("dataSourceChanged *************************************")
		--获取两种碎片数量
		local MPackStruct = require "src/layers/bag/PackStruct"
		local MPackManager = require "src/layers/bag/PackManager"
		local pack = MPackManager:getPack(MPackStruct.eBag)
		self.need1num = pack:countByProtoId(sdata[ringid].need2)
		local need2num = pack:countByProtoId(sdata[ringid].need3)
		log("need1num = "..self.need1num)
		log("need2num = "..need2num)
		self.item3:setNum(self.need1num)
		self.item4:setNum(need2num)
	end

	G_TUTO_NODE:setShowNode(self, SHOW_RING_UPDATE)

 	self.rupdatelayer:registerScriptHandler(function(event)
		if event == "enter" then
			MPackManager:getPack(MPackStruct.eBag):register(dataSourceChanged)
		elseif event == "exit" then
			MPackManager:getPack(MPackStruct.eBag):unregister(dataSourceChanged)
		end
	end)
end

--进阶特效
function SpiritRingBoard:addUpdateEffect(isSuccess)
	if self.leftRing then
		local effect = Effects:create(false)
		--effect:setCleanCache()
		self.leftRing:addChild(effect)
	    effect:setAnchorPoint(cc.p(0.5, 0.5))
	    effect:setPosition(36, 36)
		if isSuccess then
			--进阶成功特效
		    effect:playActionData("equipstreng", 7, 1, 1)
		else
			--进阶特效
		    effect:playActionData("equipuplv", 7, 1, 1)
		end
		performWithDelay(effect,function() removeFromParent(effect) effect = nil end,1)
	end
end

--更新升级界面信息
function SpiritRingBoard:ringUpdateChange()
	log("SpiritRingBoard:ringUpdateChange")
	-- body
	self.updateprog = 0
	local sdata = require("src/layers/spiritring/ringdata").rdata
	--local s_data = require("src/layers/spiritring/ringdata"):getServerData()
	local ringid = 1
	local ringData = self:getRingData(self.choosering)
	if ringData then
		ringid = (self.choosering-1)*9 + ringData.lvl
	end

	local lv = sdata[ringid].level
	if lv == 9 then
		self.isTopLevel = true
		local pos = self.leftRing:getPositionX()
		self.arrowSprite:setVisible(false)
		self.leftRing:setPositionX(pos+102)
		self.ringlvl1:setPosition(cc.p(133, 335))
		self.ringlvl11:setPosition(cc.p(215, 335))
		self.fightlabe1:setPosition(cc.p(133, 305))
		self.ringb1:setPosition(cc.p(190, 305))
		self.ringlvl2:setVisible(false)
		self.ringlvl22:setVisible(false)
		self.fightlabe2:setVisible(false)
		self.ringb2:setVisible(false)
		self.rightRing:setVisible(false)
	end
	if self.ringLv ~= lv then
		self:addUpdateEffect(true)
		AudioEnginer.playEffect("sounds/uiMusic/ui_up.mp3",false)
		self.ringLv = lv
	else
		self:addUpdateEffect(false)
	end
	self.ringlvl11:setString("Lv"..lv)
	self.proplvl:setString("Lv"..lv)
	local nextlvl = 0
	if sdata[ringid].level < 9 then
		nextlvl = sdata[ringid].level + 1
	else
		nextlvl = sdata[ringid].level
	end
	local p1 = {}
	local p2 = {}
	local s1, s2
	if self.rolejob == 1 then
		p1 = sdata[ringid].soldier_prop
		p2 = sdata[nextlvl].soldier_prop
	elseif self.rolejob == 2 then
		p1 = sdata[ringid].master_prop
		p2 = sdata[nextlvl].master_prop
	else
		p1 = sdata[ringid].taoist_prop
		p2 = sdata[nextlvl].taoist_prop
	end
	s1 = getConfigItemByKey("spiritring", "q_id", sdata[ringid].id, "q_skillID")--sdata[ringid].q_skillID
	s2 = getConfigItemByKey("spiritring", "q_id", sdata[nextlvl].id, "q_skillID")--sdata[nextlvl].q_skillID

	self.ringlvl22:setString("Lv"..nextlvl)
	self.progress1:setPercentage(math.floor(ringData.updateneed * 100 / sdata[ringid].need1))
 	self.label_lucky:setString(ringData.updateneed.."/"..sdata[ringid].need1)
 	if self.isTopLevel or lv == 9 then
		self.label_lucky:setVisible(false)
	end
 	self.havePower = ringData.updateneed
	self.allPower = sdata[ringid].need1
 	self.ringb1:setString("  +"..self:getBattle(p1, s1))
 	self.ringb2:setString("  +"..self:getBattle(p2, s2))

 	--获取两种碎片数量
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	self.need1num = pack:countByProtoId(sdata[ringid].need2)
	local need2num = pack:countByProtoId(sdata[ringid].need3)
	log("need1num = "..self.need1num)
	log("need2num = "..need2num)
	self.item3:setNum(self.need1num)
	self.item4:setNum(need2num)
end

function SpiritRingBoard:showProperty()
	local MRoleStruct = require("src/layers/role/RoleStruct")
	self.rolejob = MRoleStruct:getAttr(ROLE_SCHOOL)
	local sdata = require("src/layers/spiritring/ringdata").rdata
	local serverdata = require("src/layers/spiritring/ringdata"):getServerData()
	self.propertynode:removeAllChildren()

	local ringData = self:getRingData(self.choosering)

	local ringid = 1
	if ringData then
		ringid = (self.choosering-1)*9 + ringData.lvl
	else
		ringid = (self.choosering-1)*9 + 1
	end
	local props = sdata[ringid].soldier_prop

	local ringp = {}
	local skill
	ringp.school = self.rolejob
	if ringp.school == 1 then
		props = sdata[ringid].soldier_prop
	elseif ringp.school == 2 then
		props = sdata[ringid].master_prop
	else
		props = sdata[ringid].taoist_prop
	end
	local num = #props
	for i = 1 ,num do
		local target1 = require("src/layers/task/tasktargetlabel").new(19)
		if num > 4 then
			if i > 4 then
				target1:setPosition( 780, 360 - 30*(i-4))
			else
				target1:setPosition( 650, 360 - 30*i)
			end
		else
			target1:setPosition( 710, 360 - 30*i)
		end
		self.propertynode:addChild(target1)


		target1:setText1("gjl", cc.c3b(221, 136, 71), "+1000", cc.c3b(255, 255, 255))
		if props[i][1]  == "2" then
			target1:setText1(game.getStrByKey("life_num"), MColor.lable_black, "+"..props[i][2], MColor.lable_black)
			ringp.hp = props[i][2]
		elseif props[i][1]  == "3" then
			target1:setText1(game.getStrByKey("magic_num"), MColor.lable_black, "+"..props[i][2], MColor.lable_black)
		elseif props[i][1]  == "5" then
			target1:setText1(game.getStrByKey("physical_attack"), MColor.lable_black, "+"..props[i][2].."~"..props[i][3],MColor.lable_black )
			ringp.attack = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "7" then
			target1:setText1(game.getStrByKey("magic_attack"), MColor.lable_black, "+"..props[i][2].."~"..props[i][3], MColor.lable_black )
			ringp.attack = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "9" then
			target1:setText1(game.getStrByKey("taoism_attack"), MColor.lable_black, "+"..props[i][2].."~"..props[i][3], MColor.lable_black)
			ringp.attack = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "11" then
			target1:setText1(game.getStrByKey("physical_defense"), MColor.lable_black, "+"..props[i][2].."~"..props[i][3], MColor.lable_black )
			ringp.pDefense = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "13" then
			target1:setText1(game.getStrByKey("magic_defense"), MColor.lable_black, "+"..props[i][2].."~"..props[i][3], MColor.lable_black )
			ringp.mDefense = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "16" then
			target1:setText1(game.getStrByKey("hit_num"), MColor.lable_black, "+"..props[i][2], MColor.lable_black)
			ringp.hit = props[i][2]
		elseif props[i][1]  == "17" then
			target1:setText1(game.getStrByKey("blink_num"), MColor.lable_black, "+"..props[i][2], MColor.lable_black)
			ringp.dodge = props[i][2]
		end
	end
	skill = getConfigItemByKey("spiritring", "q_id", sdata[ringid].id, "q_skillID")
	
	ringp.skill = {}

	if skill then
		skill = tonumber(skill)
		if skill then
			ringp.skill[1] = {id=math.floor(skill/1000), lv=skill%1000}
		end
	end

	local Mnumerical = require "src/functional/numerical"
	local z_num = Mnumerical:calcCombatPowerRange(ringp) or 0

	local ring_eff_text = createLabel(self.propertynode, sdata[ringid].text, cc.p(783, 115),cc.p(0.5, 0.5),19)
	ring_eff_text:setDimensions(250,0)
	ring_eff_text:setColor(MColor.lable_black)
	self.proplvl = createLabel(self.propertynode, sdata[ringid].name.." Lv"..sdata[ringid].level, cc.p(780, 480),cc.p(0.5, 0.5),25,nil,nil,nil,MColor.lable_yellow)
	self.propLV = sdata[ringid].level

	createSprite(self.propertynode,"res/layers/spiritring/fightNum.png",cc.p(720,432))
	local labe1 = MakeNumbers:create("res/component/number/14.png",z_num,-1)
    labe1:setPosition(cc.p(800, 432))
    self.propertynode:addChild(labe1)
end

function SpiritRingBoard:getBattle(props, skill)
	dump(skill)
	local paramTab = {}
	paramTab.school = self.rolejob
	local num = #props
	for i = 1, num do
		if props[i][1]  == "2" then
			paramTab.hp = props[i][2]
		elseif props[i][1]  == "5" then
			paramTab.attack = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "7" then
			paramTab.attack = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "9" then
			paramTab.attack = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "11" then
			paramTab.pDefense = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "13" then
			paramTab.mDefense = {["["]=props[i][2], ["]"]=props[i][3]}
		elseif props[i][1]  == "16" then
			paramTab.hit = props[i][2]
		elseif props[i][1]  == "17" then
			paramTab.dodge = props[i][2]
		end
	end

	paramTab.skill = {}

	if skill then
		skill = tonumber(skill)
		if skill then
			paramTab.skill[1] = {id=math.floor(skill/1000), lv=skill%1000}
		end
	end

	dump(paramTab)
	local Mnumerical = require "src/functional/numerical"
	local z_num = Mnumerical:calcCombatPowerRange(paramTab) or 0
	return z_num
end

return SpiritRingBoard