local RingSkillList = class("RingSkillList", require ("src/TabViewLayer") )

function RingSkillList:ctor( p_bg )
	-- body
	local msgids = {RINGSKILL_SC_UPRET}
	local callbacks = {function(buff) self:ringSkillUpdateRet(buff) end}
	require("src/MsgHandler").new(self, msgids, callbacks)

	local skilldata = require("src/layers/spiritring/ringskilldata")
	local server_data = skilldata:getServerData()
	skilldata:init()

	self.parent = p_bg
	if self.parent then
		self.parent:addChild(self)
	end
	local skill_id = 750000
	local cur_lucky = 0
	--dump(server_data, "ringskillserverlist")
	if server_data[1] then
		skill_id = server_data[1].id
 		cur_lucky = server_data[1].lucky
 	else
 		return
 	end
	self.cellchooseidx = 0
	createSprite(self, "res/layers/task/6.png", cc.p(666, 246))
	--bg_h:setScaleY(1.10)
	local bg_kuang = createScale9Sprite(self, "res/layers/spiritring/kuang.png", cc.p(665,386), cc.size(556, 344))
	createSprite(self, "res/layers/spiritring/bg1.jpg", cc.p(665, 386))
	self.skilltextbox = createSprite(self, "res/layers/spiritring/textbar.png", cc.p(665, 258))

	bg_kuang:setLocalZOrder(10)
	self:createTableView(self, cc.size(366,526), cc.p(24, 28), true)

	self.propbg = createScale9Sprite(self, "res/common/31.png", cc.p(850, 410), cc.size(150, 170))
	--createSprite(self, "res/layers/spiritring/bar.png", cc.p(850, 390))
	self.propnode = cc.Node:create()
	self:addChild(self.propnode)

	if not skilldata[skill_id] then
		return
	end
	local MRoleStruct = require("src/layers/role/RoleStruct")
	self.rolejob = MRoleStruct:getAttr(ROLE_SCHOOL)
	local props = {}
	if self.rolejob == 1 then
		props = skilldata[skill_id].soldier_prop
	elseif self.rolejob == 2 then
		props = skilldata[skill_id].master_prop
	else
		props = skilldata[skill_id].taoist_prop
	end
	self:skillPropertyShow(props, self.propnode)

	createSprite(self, "res/layers/spiritring/propertyadd.png", cc.p(850, 516))
	local sp_2 = createSprite(self, "res/layers/skill/2.png", cc.p(480, 307))
	sp_2:setScaleY(0.6)
	self.skillname = createSprite(self, "res/layers/spiritring/7500.png", cc.p(460, 307))
	self.skilldegree = createLabel(self, "LV2", cc.p(524, 307),cc.p(0.5, 0.5),18)
	self.skilldegree:setColor(cc.c3b(202,184,24))
	--进度条
	local spritebg = createSprite(self, "res/common/progress/bg.png", cc.p(690, 135))
	local s_p = cc.Sprite:create("res/common/progress/p.png")
	local label_lucky = createLabel(self, game.getStrByKey("ringskill_lucky"), cc.p(440, 135),cc.p(0.5, 0.5),20)
 	label_lucky:setColor(cc.c3b(211,189,26))
	--s_p:setScaleX(1.7)
	self.progress1 = cc.ProgressTimer:create(s_p)
	self.progress1:setPosition(cc.p(27, 11))
	self.progress1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.progress1:setAnchorPoint(cc.p(0.0,0.0))
	self.progress1:setBarChangeRate(cc.p(1, 0))
 	self.progress1:setMidpoint(cc.p(0,1))

 	--self.skill_effecttext =  createRichText(self.skilltextbox, cc.p(), cc.size(480, 50))
	--addRichTextItem( self.skill_effecttext, skilldata[skill_id].skilldes)
	self.skill_textdes = createLabel(self,  skilldata[skill_id].skilldes , cc.p(420, 265),cc.p(0, 0.5),20)
	self.skill_textdes:setDimensions(480,0)
 	--当前选中技能id upgrade
 	self.chooseskillid = skill_id
 	local percent = 0
 	if skill_id and cur_lucky then
		percent = math.floor(cur_lucky*100/skilldata[skill_id].luckymax)
 	end
 	self.progress1:setPercentage(percent)
 	spritebg:addChild( self.progress1 )
 	local cur_1_lucky = 0
 	if server_data[1] then
 		cur_1_lucky = server_data[1].lucky
 	else
 	end
 	self.label_curlucky = createLabel(spritebg, cur_1_lucky.."/"..skilldata[skill_id].luckymax, cc.p(167, 25),cc.p(0.5, 0.5),18)

 	--local starboard = createSprite(self, "res/layers/spiritring/starbar.png", cc.p(665, 180))
	local label_update = createLabel(self, game.getStrByKey("ringskill_upneed"), cc.p(470, 100),cc.p(0.5, 0.5),20)
 	label_update:setColor(cc.c3b(211,189,26))
 	self.label_need = createLabel(self, ""..skilldata[skill_id].updateneed..game.getStrByKey("ringskill_zhenqi"), cc.p(538, 100),cc.p(0, 0.5),20)
 	self.label_need:setColor(cc.c3b(238,52,29))
 	local label_jindu = createLabel(self, game.getStrByKey("ringskill_jindu"), cc.p(430, 180),cc.p(0.5, 0.5),20)
 	label_jindu:setColor(cc.c3b(211,189,26))
 	self.stars = {}
 	for i = 1, 5 do
 		self.stars[i] = createSprite(self, "res/group/star/s0.png", cc.p(535 + 45*i, 180)) --cc.p(30 + 26*i, 23)
 	end
 	local menuautoupdate = MenuButton:create("res/component/button/4.png")
	menuautoupdate:setPosition(cc.p(585,50))
	menuautoupdate:registerScriptTapHandler(function () return self:skillAutoUpdate() end)
	local label_1 = createLabel(menuautoupdate,game.getStrByKey("ringouto_update"),cc.p(63,30),cc.p(0.5,0.5), 22, true)
	label_1:setColor(cc.c3b(207,184,132))

	local menuupdate = MenuButton:create("res/component/button/4.png")
	menuupdate:setPosition(cc.p(745,50))
	menuupdate:registerScriptTapHandler(function () return self:skillUpdate() end)
	local label_2 = createLabel(menuupdate,game.getStrByKey("upgrade"),cc.p(63,30),cc.p(0.5,0.5), 22, true)
	label_2:setColor(cc.c3b(207,184,132))

	local  menu = cc.Menu:create()
	menu:setPosition(0,0)
	menu:addChild(menuautoupdate)
	menu:addChild(menuupdate)
    	self:addChild(menu)


 	local list = self:getTableView()
	local cell = list:cellAtIndex(0)
	--cell:getIdx()
	if cell then
		self:tableCellTouched(list, cell)
	end
	self:setStar(skilldata[skill_id].starlevel,1)

	local zhenqi_kuang = createSprite(self, "res/layers/spiritring/zqk.png", cc.p(500, 510))
	createSprite(self, "res/layers/spiritring/zhenqi.png", cc.p(440, 516))
	self.zhenqi_value = createLabel(zhenqi_kuang, ""..G_ROLE_MAIN.base_data.vital, cc.p(26, 15), cc.p(0, 0.5),18)
	self.zhenqi_value:setColor(cc.c3b(255,85,0))
	self.outoupdate = 0
end
function RingSkillList:setStar(num, image)
	if num == 0 then
		return
	end
	--local image_name = "star"..image..".png"
	--local num1 = num
	cclog("当前技能等级为:"..num)
	local anum = num / 2
	local hnum = num % 2
	for i = 1, anum do
		self.stars[i]:setTexture("res/group/star/s2.png")--..image_name
	end
	if anum < 5 then
		self.stars[anum + 1]:setTexture("res/group/star/s"..hnum..".png")
	end
end
function RingSkillList:luckyShow( lucky, maxlucky )
	-- body
	local Percentage = math.floor(lucky * 100 / maxlucky)
	self.progress1:setPercentage(Percentage)
end

function RingSkillList:skillPropertyShow(props, p)
	-- body
	p:removeAllChildren()
	local num = #props
	local py = 500
	for i = 1, num do
		--if i == 5 then
			--py = 480
		--end
		if props[i][1]  == "2" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("life_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "3" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("magic_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "5" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("physical_attack"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3],cc.c3b(0, 255, 0) )
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "7" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("magic_attack"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0) )
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "9" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("taoism_attack"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0))
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "11" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("physical_defense"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0) )
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "13" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("magic_defense"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0) )
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "16" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("hit_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		elseif props[i][1]  == "17" then
			local target1 = require( "src/layers/task/tasktargetlabel" ).new(16)
			target1:setText1(game.getStrByKey("blink_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
			p:addChild(target1)
			target1:setPosition( 790, py - 22 * i )
		end
	end
end

--发送技能升级消息
function RingSkillList:sendForSkillUpdate(roleId, skillid)
	-- body
	--g_msgHandlerInst:sendNetDataByFmtExEx(RINGSKILL_CS_LEVELUP  , "ii", roleId, skillid)
end

--神戒技能升级结果
function RingSkillList:ringSkillUpdateRet( luaBuff )
	-- body
	local skillid = luaBuff:popInt()
	local lucky_value = luaBuff:popInt()
	self:recvSkillUpdate(skillid, lucky_value)
end
--技能升级效果
function RingSkillList:skillDoUpdate()
	-- body
	local newid = self.chooseskillid
	local skilldata = require("src/layers/spiritring/ringskilldata")
	self:setStar(10, 2)
	self:setStar(skilldata[newid].starlevel, 1)
	self.label_need:setString(""..skilldata[newid].updateneed..game.getStrByKey("ringskill_zhenqi"))
	self.skill_textdes:setString( skilldata[newid].skilldes )
	self.skilldegree:setString("LV"..skilldata[newid].skilllevel)
	local props = {}
	if self.rolejob == 1 then
		props = skilldata[newid].soldier_prop
	elseif self.rolejob == 2 then
		props = skilldata[newid].master_prop
	else
		props = skilldata[newid].taoist_prop
	end
	self:skillPropertyShow(props, self.propnode)
	self:CellByIndex(self.cellchooseidx)
	self:luckyShow(0, skilldata[newid].luckymax)
	self.label_curlucky:setString("0/"..skilldata[newid].luckymax)
	self.zhenqi_value:setString(""..G_ROLE_MAIN.base_data.vital)
end
--接收技能升级结果
function RingSkillList:recvSkillUpdate(newid, lucky)
	-- body
	cclog("技能升级后id:"..newid.."--祝福值:"..lucky)
	local skilldata = require("src/layers/spiritring/ringskilldata")
	local server_data = skilldata:getServerData()
	server_data[self.cellchooseidx+1].id = newid
	server_data[self.cellchooseidx+1].lucky = lucky
	if self.chooseskillid ~= newid then
		self.chooseskillid = newid
		local list = self:getTableView()
		local cell = list:cellAtIndex(self.cellchooseidx)
		cell:setTag(newid)
		--if skilldata[newid].starlevel == 1 then
			--self:setStar(10, 1)
			--self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function() self:skillDoUpdate() end)))
			--return
		--end
		self:setStar(10, 2)
		self:setStar(skilldata[newid].starlevel, 1)
		self.label_need:setString(""..skilldata[newid].updateneed..game.getStrByKey("ringskill_zhenqi"))
		self.skill_textdes:setString( skilldata[newid].skilldes )
		self.skilldegree:setString("LV"..skilldata[newid].skilllevel)
		local props = {}
		if self.rolejob == 1 then
			props = skilldata[newid].soldier_prop
		elseif self.rolejob == 2 then
			props = skilldata[newid].master_prop
		else
			props = skilldata[newid].taoist_prop
		end
		self:skillPropertyShow(props, self.propnode)
	end
	self:CellByIndex(self.cellchooseidx)
	self:luckyShow(lucky, skilldata[newid].luckymax)
	self.label_curlucky:setString(lucky.."/"..skilldata[newid].luckymax)
	self.zhenqi_value:setString(""..G_ROLE_MAIN.base_data.vital)
end

function RingSkillList:skillUpdate()
	-- body
	local skilldata = require("src/layers/spiritring/ringskilldata")
	self:sendForSkillUpdate(G_ROLE_MAIN.obj_id, skilldata[self.chooseskillid].skillid)
	local newid = self.chooseskillid
	local skilldata = require("src/layers/spiritring/ringskilldata")
	if G_ROLE_MAIN.base_data.vital < skilldata[newid].updateneed then
		self:stopAllActions()
		self.outoupdate = 0
		return
	end
end

function RingSkillList:skillAutoUpdate( ... )
	-- body
	if self.outoupdate == 0 then
		local action = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function () self:skillUpdate() end))
		self:runAction(cc.RepeatForever:create(action))
		self.outoupdate = 1
	else
		self:stopAllActions()
		self.outoupdate = 0
	end
end

function RingSkillList:cellSizeForTable(table,idx)
	-- body
	return 112, 364
end
function RingSkillList:reflashTFList()
	-- body
	self:getTableView():reloadData()
end

function RingSkillList:CellByIndex(idx)
	-- body
	local list = self:getTableView()
	local cell = list:cellAtIndex(idx)
	if cell then
		local skilldata = require("src/layers/spiritring/ringskilldata")
		local server_data = skilldata:getServerData()
		local skillid = server_data[idx+1].id
		local spr1 = cell:getChildByTag(100)
		--spr1:setTexture("layers/task/12.png")
		local label_level = spr1:getChildByTag(120)
		label_level:setString("LV"..skilldata[skillid].skilllevel)
	end
end

function RingSkillList:tableCellTouched(table,cell)

	if self.cellchooseidx ~= cell:getIdx() and table:cellAtIndex(self.cellchooseidx) then
		table:cellAtIndex(self.cellchooseidx):getChildByTag(100 ):setTexture("res/layers/task/11.png")
	end

	cell:getChildByTag(100):setTexture("res/layers/task/12.png")
	self.cellchooseidx = cell:getIdx()
	self.chooseskillid = cell:getTag()
	local skilldata = require("src/layers/spiritring/ringskilldata")
	local server_data = skilldata:getServerData()
	self:setStar(10, 2)
	self.skillname:setTexture("res/layers/spiritring/"..skilldata[self.chooseskillid].skillid..".png")
	self.skilldegree:setString("LV"..skilldata[self.chooseskillid].skilllevel)
	self:setStar(skilldata[self.chooseskillid].starlevel, 1)
	self:luckyShow(server_data[self.cellchooseidx + 1].lucky, skilldata[self.chooseskillid].luckymax)
	self.label_need:setString(""..skilldata[self.chooseskillid].updateneed..game.getStrByKey("ringskill_zhenqi"))
	self.skill_textdes:setString( skilldata[self.chooseskillid].skilldes )
	self.label_curlucky:setString(server_data[self.cellchooseidx + 1].lucky.."/"..skilldata[self.chooseskillid].luckymax)

	local props = {}
	if self.rolejob == 1 then
		props = skilldata[self.chooseskillid].soldier_prop
	elseif self.rolejob == 2 then
		props = skilldata[self.chooseskillid].master_prop
	else
		props = skilldata[self.chooseskillid].taoist_prop
	end
	self:skillPropertyShow(props, self.propnode)
end

function RingSkillList:numberOfCellsInTableView(table)
	local skilldata = require("src/layers/spiritring/ringskilldata")
	local server_data = skilldata:getServerData()
   	return #server_data
end

function RingSkillList:tableCellAtIndex(table, idx)
	local skilldata = require("src/layers/spiritring/ringskilldata")
	local server_data = skilldata:getServerData()
	local skillid = server_data[idx+1].id
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end
	cell:setTag(skillid)
	createSprite(cell,"res/layers/skill/1.png",cc.p(0,0),cc.p(0,0))
	local sprite = createSprite(cell,"res/layers/task/11.png",cc.p(0,0),cc.p(0, 0))
	createLabel(sprite, skilldata[skillid].name,cc.p(200,70),cc.p(0.0,0.5),20)
	createLabel(sprite, "LV"..skilldata[skillid].skilllevel,cc.p(200,40),cc.p(0.0,0.5),20)
	skillname:setColor(cc.c3b(0, 255, 0))
	createSprite(sprite,"res/layers/skill/1.png",cc.p(0,0),cc.p(0, 0))
	createSprite(sprite,"res/layers/spiritring/icon"..skilldata[skillid].skillid..".png",cc.p(12,12),cc.p(0, 0))

	return cell
end

return RingSkillList