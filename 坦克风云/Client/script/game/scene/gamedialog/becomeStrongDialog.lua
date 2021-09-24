
becomeStrongDialog=commonDialog:new()

function becomeStrongDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    infoTab={}
    return nc
end

function becomeStrongDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    -- self.panelLineBg:setVisible(false)
    self:initLayer()
end	

function becomeStrongDialog:initLayer()
	

	-- 关卡
	local function callback1()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		storyScene:setShow()
	end

	-- 玩家信息
	local function callback2()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		-- local td=playerDialog:new(1,3)
		-- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
		-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,3)
		-- sceneGame:addChild(dialog,3)
		local td=playerVoApi:showPlayerDialog(1,3)
	end

	-- 技能
	local function callback3()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		-- PlayEffect(audioCfg.mouseClick)
		-- activityAndNoteDialog:closeAllDialog()
		-- local td=playerDialog:new(2,3)
		-- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
		-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,3)
		-- sceneGame:addChild(dialog,3)
		local td=playerVoApi:showPlayerDialog(2,3)
	end

	-- 世界地图
	local function callback4()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		mainUI:changeToWorld()
	end

	-- 世界地图
	local function callback5()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		mainUI:changeToWorld()
	end

	-- 世界地图
	local function callback6()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		mainUI:changeToWorld()
	end

	-- 装置车间
	local function callback7()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		local bName=getlocal("propBuilding")
		local level = buildingVoApi:getBuildiingVoByBId(6).level
        buildingVoApi:showWorkshop(6,9,3,level)
	end

	-- 科研中心
	local function callback8()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		local tabbuildings=buildingVoApi:getBuildingVoByBtype(8)
		local nbid=0;
		local nlevel=0
		for k,v in pairs(tabbuildings) do
			nbid=v.id
			nlevel=v.level
		end

		require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
        local td=techCenterDialog:new(nbid,3)
		local bName=getlocal(buildingCfg[8].buildName)
		local tbArr={getlocal("building"),getlocal("startResearch")}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..nlevel..")",true)
		td:tabClick(0)
		sceneGame:addChild(dialog,3)
	end

	-- 金币购买
	local function callback9()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(3)
	end

	-- Vip礼包
	local function callback10()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
	            if ret==true then
	              if sData and sData.data and sData.data.vipRewardCfg then
	                vipVoApi:setVipReward(sData.data.vipRewardCfg)
	                local vf = vipVoApi:getVf(vf)
	                for k,v in pairs(vf) do
	                  vipVoApi:setRealReward(v)
	                end                
	                vipVoApi:setVipFlag(true)
	                -- require "luascript/script/game/scene/gamedialog/vipDialogNew"    
	                -- local tabTb = {getlocal("playerInfo"), getlocal("vip_tequanlibao")}
	                -- local vd1 = vipDialogNew:new()
	                -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("vipTitle"),true,3)       
	                -- sceneGame:addChild(vd,3)
	                local vd1=vipVoApi:openVipDialog(3,true)
	                vd1:tabClick(1)                
	              end              
	            end            
	        end
          if vipVoApi:getVipFlag()==false then
            socketHelper:vipgiftreward(callback)
          else
            -- require "luascript/script/game/scene/gamedialog/vipDialogNew" 
            -- local tabTb = {getlocal("playerInfo"), getlocal("vip_tequanlibao")}
            -- local vd1 = vipDialogNew:new()
            -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,  getlocal("vipTitle"),true,3)       
            -- sceneGame:addChild(vd,3);
            local vd1=vipVoApi:openVipDialog(3,true)
            vd1:tabClick(1)
          end
	end

	-- 军需卡
	local function callback11()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(3,1)
	end

	-- 坦克工厂
	local function callback12()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		local bid=11;
		local tankSlot1=tankSlotVoApi:getSoltByBid(11)
		local tankSlot2=tankSlotVoApi:getSoltByBid(12)
		if SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)==0 then
		bid=11;
		elseif SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)>0 then
		bid=11;
		elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)==0 then
		bid=12;
		elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)>0 then
		bid=11;
		end

		local buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
		if buildingVo.level==0 then
		bid=11;
		buildingVo=nil
		buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
		end
        require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
		local td=tankFactoryDialog:new(bid,3)
		local bName=getlocal(buildingCfg[6].buildName)

		local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildingVo.level..")",true,3)
		td:tabClick(1)
		sceneGame:addChild(dialog,3)
	end

	-- 补给线
	local function callback13()
		PlayEffect(audioCfg.mouseClick)
		if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
        else
        	accessoryVoApi:showSupplyDialog(self.layerNum+1)
        end
	end

	-- 配件界面
	local function callback14()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		accessoryVoApi:showAccessoryDialog(sceneGame,3)
	end

	-- 配件界面
	local function callback15()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		accessoryVoApi:showAccessoryDialog(sceneGame,3)
	end

	-- 军事学院
	local function callback16()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		local function openHeroTotalDialog( ... )
			require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
			local td=heroTotalDialog:new()
			local tbArr={}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("sample_build_name_12"),true,3)
			sceneGame:addChild(dialog,3)
		end
		if base.he==1 then
          if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest==true then
              local function callbackHandler4()
              		openHeroTotalDialog()
              end
              heroEquipVoApi:equipGet(callbackHandler4)
          else
              openHeroTotalDialog()
          end
        else
          openHeroTotalDialog()
        end

	end

	-- 远征界面
	local function callback17()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		local function callback(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
	            require "luascript/script/game/scene/gamedialog/expedition/expeditionDialog"
	            local vrd=expeditionDialog:new()
	            local vd = vrd:init(3)
	        end
	    end
	    socketHelper:expeditionGet(callback)
	end

	--德国需求的客服按钮
	local function callback18()
		PlayEffect(audioCfg.mouseClick)
		local tmpTb={}
		tmpTb["action"]="openUrl"
		tmpTb["parms"]={}
		tmpTb["parms"]["url"]="http://bit.ly/2ASmV6P"
		local cjson=G_Json.encode(tmpTb)
		G_accessCPlusFunction(cjson)
	end

	self.infoTab={
	{id=1,btnLb=getlocal("become_strong_des",{getlocal("sample_general_exp")}),callback=callback1,sortId=1},
	{id=2,btnLb=getlocal("become_strong_des",{getlocal("become_strong_commander")}),callback=callback2,sortId=2},
	{id=3,btnLb=getlocal("become_strong_des",{getlocal("skillTab")}),callback=callback3,sortId=3},
	{id=4,btnLb=getlocal("become_strong_des",{getlocal("alliance_medals")}),callback=callback4,sortId=4},
	{id=5,btnLb=getlocal("become_strong_des",{getlocal("help2_t1_t5")}),callback=callback5,sortId=5},
	{id=6,btnLb=getlocal("become_strong_des",{getlocal("resource")}),callback=callback6,sortId=6},
	{id=7,btnLb=getlocal("become_strong_des",{getlocal("allianceShop_tab1")}),callback=callback7,sortId=7},
	{id=8,btnLb=getlocal("become_strong_des",{getlocal("alliance_skill")}),callback=callback8,sortId=8},
	{id=9,btnLb=getlocal("become_strong_des",{getlocal("gem")}),callback=callback9,sortId=9},
	{id=10,btnLb=getlocal("become_strong_des",{getlocal("become_strong_VIP_libao")}),callback=callback10,sortId=10},
	{id=11,btnLb=getlocal("become_strong_des",{getlocal("vip_monthlyCard")}),callback=callback11,sortId=11},
	{id=12,btnLb=getlocal("become_strong_des",{getlocal("tanke")}),callback=callback12,sortId=12},
	{id=13,btnLb=getlocal("become_strong_des",{getlocal("accessory")}),callback=callback13,sortId=13},
	{id=14,btnLb=getlocal("become_strong_des",{getlocal("accessory_stronger")}),callback=callback14,sortId=14},
	{id=15,btnLb=getlocal("become_strong_des",{getlocal("accessory_change")}),callback=callback15,sortId=15},
	{id=16,btnLb=getlocal("become_strong_des",{getlocal("heroTitle")}),callback=callback16,sortId=16},
	{id=17,btnLb=getlocal("become_strong_des",{getlocal("become_expedition")}),callback=callback17,sortId=17},
	}

	if playerVoApi:getPlayerLevel()<3 then
		for k,v in pairs(self.infoTab) do
			if v.id==4 then
				table.remove(self.infoTab,k)
			end
		end
		for k,v in pairs(self.infoTab) do
			if v.id==5 then
				table.remove(self.infoTab,k)
			end
		end
		for k,v in pairs(self.infoTab) do
			if v.id==6 then
				table.remove(self.infoTab,k)
			end
		end
	end

	if buildingVoApi:getBuildiingVoByBId(6).status<1 then
		for k,v in pairs(self.infoTab) do
			if v.id==7 then
				table.remove(self.infoTab,k)
			end
		end
	end

	if buildingVoApi:getBuildiingVoByBId(3).status<1 then
		for k,v in pairs(self.infoTab) do
			if v.id==8 then
				table.remove(self.infoTab,k)
			end
		end
	end
	--vip礼包开关
	if base.vipshop==0 or base.heroSwitch==0 then
		for k,v in pairs(self.infoTab) do
			if v.id==10 then
				table.remove(self.infoTab,k)
			end
		end

		
	end

	local cardCfg = vipVoApi:getMonthlyCardCfg()
	if base.monthlyCardOpen==0 or cardCfg==nil then
		for k,v in pairs(self.infoTab) do
			if v.id==11 then
				table.remove(self.infoTab,k)
			end
		end
	end

	if buildingVoApi:getBuildiingVoByBId(11).status<1 then
		for k,v in pairs(self.infoTab) do
			if v.id==12 then
				table.remove(self.infoTab,k)
			end
		end
	end



	if playerVoApi:getPlayerLevel()<8  then
		for k,v in pairs(self.infoTab) do
			if v.id==13 then
				table.remove(self.infoTab,k)
			end
		end
		for k,v in pairs(self.infoTab) do
			if v.id==14 then
				table.remove(self.infoTab,k)
			end
		end
		for k,v in pairs(self.infoTab) do
			if v.id==15 then
				table.remove(self.infoTab,k)
			end
		end
	end

	local openlevel=base.heroOpenLv or 20
	if playerVoApi:getPlayerLevel()<openlevel or base.heroSwitch==0 then
		for k,v in pairs(self.infoTab) do
			if v.id==16 then
				table.remove(self.infoTab,k)
			end
		end
	end

	if playerVoApi:getPlayerLevel()<25 or base.expeditionSwitch==0 then
		for k,v in pairs(self.infoTab) do
			if v.id==17 then
				table.remove(self.infoTab,k)
			end
		end
	end
	if(G_curPlatName()=="androidsevenga" or G_curPlatName()=="11" or G_curPlatName()=="0")then
		local tmpTb={id=18,btnLb=getlocal("setting_gm_question"),callback=callback18,sortId=0}
		table.insert(self.infoTab,tmpTb)
	end

	local function sortFunc(a,b)
		return a.sortId<=b.sortId
	end
	table.sort(self.infoTab,sortFunc)
	for k,v in pairs(self.infoTab) do
		print("id: "..v.id)
	end
end


--设置对话框里的tableView
function becomeStrongDialog:initTableView()
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 150),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,40)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end

function becomeStrongDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return  SizeOfTable(self.infoTab)
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(520,90)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end

		local hei =90-4

		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)

		local desLb = GetTTFLabelWrap(self.infoTab[idx+1].btnLb,25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb:setPosition(ccp(20,backSprie:getContentSize().height/2))
		desLb:setAnchorPoint(ccp(0,0.5))
		backSprie:addChild(desLb)

		local btnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",self.infoTab[idx+1].callback,10,getlocal("jumpButton"),24,100)
		btnItem:setScaleX(0.65)
		btnItem:setScaleY(0.7)
		local btnMenu = CCMenu:createWithItem(btnItem);
         btnMenu:setPosition(ccp(500,backSprie:getContentSize().height/2));
         btnMenu:setTouchPriority(-(self.layerNum-1)*20-4);
         backSprie:addChild(btnMenu,1)
         local lb = btnItem:getChildByTag(100)
         if lb then
         	lb = tolua.cast(lb,"CCLabelTTF")
         	lb:setScaleX(1.35)
         	lb:setScaleY(1.3)
         end


		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function becomeStrongDialog:dispose()
	self.infoTab=nil
end
