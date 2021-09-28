
local skyArenaEnergy = class("skyArenaEnergy", function() return cc.Node:create() end)
local commConst = require("src/config/CommDef");
local CDTouchButton = class("CDTouchButton", function() return cc.Node:create() end)
local energySkillBtns={}
--符文能量按钮
function CDTouchButton:ctor(params)
	self.params=params
	if params.pos then
		self:setPosition(params.pos)
	end
	if params.parent then
		self.parent = params.parent
		params.parent:addChild(self)
	end
	local addTouchEffect = function(add_node,pos)
		local touch_effect = Effects:create(false)
		touch_effect:setScale(0.8)
		add_node:addChild(touch_effect , 101)
		touch_effect:setPosition(pos)
		touch_effect:playActionData("toucheffect", 4, 0.25,1)
			local removeFunc = function()
				removeFromParent(touch_effect)
				touch_effect = nil
			end
			performWithDelay(touch_effect,removeFunc,1)
	end
	
	local cb = function()
		addTouchEffect(self,cc.p(0, 0))
		if G_SKYARENA_DATA.EnergyData.energy<=0 then
			TIPS( {type=1,str=game.getStrByKey("sky_arena_energy_empty") } ) 
			return	
		end
		local coolTime =getConfigItemByKey("SkillLevelCfg","skillID",params.skillID*1000+1,"coolTime")
		local cd=coolTime and coolTime/1000 or 0
	   	local cdShare=getConfigItemByKey("SkillCfg","skillID",params.skillID,"coolTimeShare")/1000
		self:addCdEffect(math.max(cd,cdShare))
		for k,v in pairs(energySkillBtns) do
			if k~=params.type then
				v:addCdEffect(cdShare)
			end
		end
		if params.cb then
			params.cb()	
		end
		if params.type then
			print("params.type="..params.type)
			g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_USE_FLAG, "P3V3UseFlagProtocol", {type=params.type})
		end
	end
	local btn = createTouchItem(self,"res/mainui/skill/skillbg.png",cc.p(0, 0),cb)
	local icon=createSprite(self, params.icon, cc.p(0,0), cc.p(0.5, 0.5))
	icon:setScale(0.7)
	self:setScale(0.9)
end
function CDTouchButton:addCdEffect(cd)
	--添加进度条
	local sprite = cc.Sprite:create("res/mainui/shadow.png")

    local ss = cc.ProgressTimer:create(sprite)
    ss:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    ss:setReverseDirection(true)
   	ss:setPercentage(50)
  
	local actions={}
    actions[#actions+1] = cc.ProgressFromTo:create(cd,100,0)
    actions[#actions+1] = cc.CallFunc:create(function()
    	removeFromParent(ss)
	end)
	ss:setScale(0.8)
	ss:runAction(cc.Sequence:create(actions))
	self:addChild(ss)
	
	--local icon=createSprite(self, "res/mainui/skill/skillbg.png", cc.p(display.cx,display.cy), cc.p(0.5, 0.5))
		Mnode.listenTouchEvent(
	{
		node = ss,
		swallow = true,
		begin = function(touch, event)
			print("touch")
			local touchOutside = Mnode.isTouchInNodeAABB(ss, touch)
			return touchOutside
		end,
	})
end
local rescompath = "res/layers/skyArena/"

local function createEnergyProgerss( ... )
	local energy_dark="res/layers/skyArena/energy/energy_dark.png"
	local energy_light="res/layers/skyArena/energy/energy_light.png"
	local progress= createSprite(nil, "res/layers/skyArena/energy/energy_bg.png", cc.p(0 , 0), cc.p(0.5, 0.5))
	local curEnergyNum=0
	local energyItems={}
	for i=1,5 do
		energyItems[i]=createSprite(progress, energy_dark, cc.p(120+(i-1)*30, 23), cc.p(0.5, 0.5))
	end

	function progress:setEnergyNum( num )
		if num and curEnergyNum~= num then
			for i=1,5 do
				if i<=num then
					energyItems[i]:setTexture(energy_light)
					if num>curEnergyNum and i>curEnergyNum then
						if i==num then
							TIPS({str = game.getStrByKey("get_energy"), type = 1})
						end
						energyItems[i]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.3),cc.ScaleTo:create(0.2,1)))
					end
				else
					energyItems[i]:setTexture(energy_dark)	
				end
			end
			curEnergyNum=num
		end
	end

	return progress
end

function skyArenaEnergy:ctor(parent)
	if parent then
		self.parent = parent
		parent:addChild(self)
	end
	local progressNode=cc.Node:create()
	self:addChild(progressNode)
	local progress=createEnergyProgerss()
	progress:setPosition(cc.p(display.width-122 , display.height-146))
	progressNode:addChild(progress)
	self.energyProgress=progress
	progress:setScale(0.9)
	-----------------------------------------------------------
	progress:setEnergyNum(0)
	self:energyUpdate()
	
	-- g_TestEffect={}
	-- local firePos={cc.p(29,24),cc.p(52,26)}
	-- for k,v in pairs(firePos) do
	-- 	local effect = Effects:create(false)
	--     effect:setPlistNum(-1)
	--     effect:setAnchorPoint(cc.p(0.5,0.5))
	--    	effect:playActionData2("petefire", 100, -1, 0)

	-- 	effect:setPosition(G_MAINSCENE.map_layer:tile2Space(v))
	-- 	G_MAINSCENE.map_layer.item_Node:addChild(effect, 0)
	-- 	g_TestEffect[#g_TestEffect+1]=effect
	-- end
	-- local clodPos={cc.p(19,52),cc.p(20,24),cc.p(44,11),cc.p(58,25)}
	-- for k,v in pairs(clodPos) do
	-- 	local effect = Effects:create(false)
	--     effect:setPlistNum(-1)
	--     effect:setAnchorPoint(cc.p(0.5,0.5))
	--    	effect:playActionData2("petewind", 250, -1, 0)
	-- 	effect:setPosition(G_MAINSCENE.map_layer:tile2Space(v))
	-- 	effect:setFlippedY(true)
	-- 	effect:setFlippedX(true)
	-- 	G_MAINSCENE.map_layer.item_Node:addChild(effect, 910)
	-- 	g_TestEffect[#g_TestEffect+1]=effect
	-- end
	energySkillBtns={}
	energySkillBtns[1]=CDTouchButton.new({skillID=10052,type=1,parent=progressNode,pos=cc.p(display.width-40, display.height-200),icon="res/layers/skyArena/energy/double.png"})
	energySkillBtns[2]=CDTouchButton.new({skillID=10051,type=2,parent=progressNode,pos=cc.p(display.width-120, display.height-200),icon="res/layers/skyArena/energy/wudi.png"})
	energySkillBtns[3]=CDTouchButton.new({skillID=10053,type=3,parent=progressNode,pos=cc.p(display.width-200, display.height-200),icon="res/layers/skyArena/energy/recoverhp.png"})
    
    -------------------------------------------------------

    local menu, exit_btn = require("src/component/button/MenuButton").new(
    {
	    parent = self,
	    pos = cc.p(display.width-69, display.height-100),
        src = {"res/component/button/1.png", "res/component/button/1_sel.png", "res/component/button/1_gray.png"},
	    label = {
		    src = game.getStrByKey("exit"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)


	    	MessageBoxYesNo(nil,"主动退出视为逃跑，是否继续?",
			function() 
				g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_EXIT_MATCH, "P3V3ExitMatchProtocol", {type = 1})
			end,
			function() 
			end ,
			game.getStrByKey("sure"),game.getStrByKey("cancel") )

        	
	    end,
    })
    self:registerScriptHandler(function(event)
		if event == "enter" then
			-- if G_MAINSCENE.taskBaseNode then
			-- 	G_MAINSCENE.taskBaseNode:setVisible(false)
			-- end
		elseif event == "exit" then
			if G_MAINSCENE then
				G_SKYARENA_DATA.tipsLimit={}
				G_SKYARENA_DATA.tipsLimit.levelUpStopTimes=0
				G_SKYARENA_DATA.tipsLimit.functionOpenStopTimes=0
				G_SKYARENA_DATA.tipsLimit.fightPowerUpStopTimes=0
				startTimerAction(G_MAINSCENE, 2, false, function() G_SKYARENA_DATA.tipsLimit=nil end )   
			end
			--去掉已经激活的技能
			G_ROLE_MAIN.base_data.spe_skill={}
			isInArenaScene=false
			G_SKYARENA_DATA.EnergyData.energy=0
			--人物外观还原
			if G_ROLE_MAIN then
				local MRoleStruct = require("src/layers/role/RoleStruct")
			  	local MPropOp = require("src/config/propOp")
			  	local MPackManager = require "src/layers/bag/PackManager"
			  	local MPackStruct = require "src/layers/bag/PackStruct"
			  	local pack = MPackManager:getPack(MPackStruct.eDress)
			  	local eClothing = pack:getGirdByGirdId(MPackStruct.eClothing)
			  	local eWeapon = pack:getGirdByGirdId(MPackStruct.eWeapon)
				local clothesId =2020501
				local weaponId = nil
				local wingId=nil
				local sex=MRoleStruct:getAttr(PLAYER_SEX)
				if sex==2 then
					clothesId =2031501
				end
				if eClothing then
					clothesId = MPackStruct.protoIdFromGird(eClothing)
				end
				if eWeapon then
					weaponId = MPackStruct.protoIdFromGird(eWeapon)
				else
					G_ROLE_MAIN:removeActionChildByTag(PLAYER_EQUIP_WEAPON)
				end
				if G_WING_INFO.id and G_WING_INFO.state == 1 then
					wingId=G_WING_INFO.id
				else
					G_ROLE_MAIN:removeActionChildByTag(PLAYER_EQUIP_WING)
				end
				G_ROLE_MAIN:setEquipments(clothesId,weaponId,wingId)
			end
			--停止录制视频
			if getLocalRecordByKey(3,"isAutoRecorder") and isSupportReplay() then
				stopRecording()
			end
			if G_MAINSCENE.taskBaseNode then
				G_MAINSCENE.taskBaseNode:setVisible(true)
			end

			
		end
	end)
end

function skyArenaEnergy:energyUpdate()
	if G_SKYARENA_DATA.EnergyData then
		self.energyProgress:setEnergyNum(G_SKYARENA_DATA.EnergyData.energy)
	end
end
function skyArenaEnergy:timeUpdate()



end



--------------
return skyArenaEnergy
