local RankingView=classGc(view,function(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_mainSize=cc.size(626,492)
	self.m_rankSize=cc.size(self.m_mainSize.width,492)
	self.m_allTypeMsg={}

	local mainplay=_G.GPropertyProxy:getMainPlay()
    self.m_myUid=mainplay:getUid()
end)

local P_TITLE_ARRAY={
	[_G.Const.CONST_TOP_TYPE_LV]={sort=1,name={"排名","职业","角色名","等级"},value={"rank","pro","name","lv"}},
	[_G.Const.CONST_TOP_TYPE_POWER]={sort=2,name={"排名","职业","角色名","总战力"},value={"rank","pro","name","power"}},
	[_G.Const.CONST_TOP_TYPE_ARENA]={sort=3,name={"排名","职业","角色名","总战力"},value={"rank","pro","name","power"}},
	[_G.Const.CONST_TOP_TYPE_CLAN]={sort=4,name={"排名","门派名称","门派等级","门派经验"},value={"rank","clan_name","clan_lv","power_clan"}},
	-- [_G.Const.CONST_TOP_TYPE_EQUIP]={sort=7,name={"排名","角色名","等级","饰品战力"},value={"rank","name","power_equip"}},
	[_G.Const.CONST_TOP_TYPE_MAGIC]={sort=15,name={"排名","角色名","等级","神兵战力"},value={"rank","pro","name","power_magic"}},
	-- [_G.Const.CONST_TOP_TYPE_MATRIX]={sort=8,name={"排名","角色名","等级","经脉战力"},value={"rank","name","power_matrix"}},
	[_G.Const.CONST_TOP_TYPE_MOUNT]={sort=10,name={"排名","职业","角色名","坐骑战力"},value={"rank","pro","name","power_mount"}},
	[_G.Const.CONST_TOP_TYPE_BAQI]={sort=12,name={"排名","职业","角色名","卦象战力"},value={"rank","pro","name","power_baqi"}},
	-- [_G.Const.CONST_TOP_TYPE_MEIREN]={sort=12,name={"排名","角色名","美人战力"},value={"rank","name","meiren"}},
	[_G.Const.CONST_TOP_TYPE_FIGHTERS]={sort=6,name={"排名","职业","角色名","层数"},value={"rank","pro","name","fighter"}},
	[_G.Const.CONST_TOP_TYPE_WING]={sort=13,name={"排名","职业","角色名","宠物战力"},value={"rank","pro","name","power_wing"}},
	[_G.Const.CONST_TOP_TYPE_STAR]={sort=5,name={"排名","职业","角色名","副本星数"},value={"rank","pro","name","star"}},
	[_G.Const.CONST_TOP_TYPE_EQUIP_GEM]={sort=9,name={"排名","职业","角色名","宝石战力"},value={"rank","pro","name","power_equip_gem"}},
	[_G.Const.CONST_TOP_TYPE_EQUIP_STRENG]={sort=8,name={"排名","职业","角色名","元魄战力"},value={"rank","pro","name","power_equip_streng"}},
	[_G.Const.CONST_TOP_TYPE_EQUIP_EQUIP]={sort=7,name={"排名","职业","角色名","饰品战力"},value={"rank","pro","name","power_equip_equip"}},
	[_G.Const.CONST_TOP_TYPE_WUQI]={sort=14,name={"排名","角色名","等级","武器战力"},value={"rank","pro","name","power_wuqi"}},
	-- [_G.Const.CONST_TOP_TYPE_FEATHER]={sort=14,name={"排名","角色名","等级","翅膀战力"},value={"rank","name","lv","power_feather"}},
	[_G.Const.CONST_TOP_TYPE_LINGYAO]={sort=11,name={"排名","角色名","等级","灵妖战力"},value={"rank","pro","name","power_lingyao"}},
}

local P_TITLE_POS={60,170,260,425}

local P_TAG_CKXX=1
local P_TAG_FQSL=2
local P_TAG_JWHY=3
local P_TAG_SCHY=4
local P_TAG_JRHMD=5
local P_TAG_JCHMD=6
local P_TAG_ZLDB=7
local P_TAG_JRDF=11
local P_TAG_TCDF=12
local P_TAG_CKDF=13
local P_TAG_CKZY=14
local P_TAG_CKZQ=15
local P_TAG_CKXL=16
local P_TAG_CKBG=17
local P_TAG_CKJS=18
local P_TAG_CKSB=19
local P_TAG_CKQL=20
local P_TAG_CKSY=21
local P_TAG_CKYP=22
local P_TAG_CKLY=23

local P_FONT_NAME=_G.FontName.Heiti

local P_COLOR_BRIGHTYELLOW=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW)
local P_COLOR_ORANGE=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE)
local P_COLOR_RED=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED)
local P_COLOR_BROWN=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
local P_COLOR_GOLD=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
local P_RANK_COLOR_ARRAY={P_COLOR_RED,P_COLOR_GOLD,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE)}

function RankingView.create(self)
	self.m_leftTabView=require("mod.general.TabLeftView")(1)
	self.m_rootLayer=self.m_leftTabView:create("排行榜",true)

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	self:__initView()
	self:__requestAllMsg()

	self.m_mediator=require("mod.smodule.RankingMediator")(self)

	return tempScene
end

function RankingView.__initView(self)
	local function nCloseFun()
		self:closeWindow()
	end
	local function nTabFun(_tag)
		self:__removeScheduler()
		self:__chuangeTabByTag(_tag)
	end
	self.m_leftTabView:addCloseFun(nCloseFun)
	self.m_leftTabView:addTabFun(nTabFun)

	self.m_mainNode=cc.Node:create()
	self.m_mainNode:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5)
	self.m_rootLayer:addChild(self.m_mainNode)

	local leftSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    leftSpr:setPreferredSize(cc.size(217,488))
    leftSpr:setPosition(-314,-27)
    self.m_mainNode:addChild(leftSpr)

	local rightSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	rightSpr:setPreferredSize(cc.size(626,488))
	rightSpr:setPosition(115,-27)
	self.m_mainNode:addChild(rightSpr)

	local mainBgSpr=cc.Node:create()
	
	-- mainBgSpr:setContentSize(self.m_mainSize)
	mainBgSpr:setPosition(106 - self.m_mainSize.width*0.5,-20 - self.m_mainSize.height*0.5)
	self.m_mainNode:addChild(mainBgSpr)
	self.m_mainBgSpr=mainBgSpr

	local rankBgSpr=cc.Node:create()
	-- rankBgSpr:setContentSize(self.m_rankSize)
	rankBgSpr:setPosition(104 - self.m_rankSize.width*0.5,-20 - self.m_rankSize.height*0.5)
	self.m_mainNode:addChild(rankBgSpr)
	self.m_rankBgSpr=rankBgSpr

	-- local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	-- local lineSize=lineSpr:getPreferredSize()
	-- lineSpr:setPreferredSize(cc.size(self.m_mainSize.width-4,lineSize.height))
	-- lineSpr:setPosition(self.m_mainSize.width*0.5,402)
	-- mainBgSpr:addChild(lineSpr)

	local nPosY=-27
	local myRankNoticLabel=_G.Util:createLabel("我的排名: ",20)
	local nLabelSize=myRankNoticLabel:getContentSize()
	myRankNoticLabel:setAnchorPoint(cc.p(0,0.5))
	myRankNoticLabel:setPosition(80,nPosY)
	myRankNoticLabel:setColor(P_COLOR_BRIGHTYELLOW)
	mainBgSpr:addChild(myRankNoticLabel)

	self.m_myRankLabel=_G.Util:createLabel("500+",20)
	self.m_myRankLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_myRankLabel:setPosition(80+nLabelSize.width,nPosY)
	self.m_myRankLabel:setColor(P_COLOR_RED)
	mainBgSpr:addChild(self.m_myRankLabel)

	self.mypowLabel=_G.Util:createLabel("战力: ",20)
	local npowSize=self.mypowLabel:getContentSize()
	self.mypowLabel:setAnchorPoint(cc.p(0,0.5))
	self.mypowLabel:setPosition(self.m_mainSize.width/2+80,nPosY)
	self.mypowLabel:setColor(P_COLOR_BRIGHTYELLOW)
	mainBgSpr:addChild(self.mypowLabel)

	-- local mypower=_G.GPropertyProxy:getMainPlay():getPowerful()
	-- self.m_mypowLabel=_G.Util:createLabel(mypower,20)
	-- self.m_mypowLabel:setAnchorPoint(cc.p(0,0.5))
	-- self.m_mypowLabel:setPosition(self.m_mainSize.width/2+80+npowSize.width,nPosY)
	-- self.m_mypowLabel:setColor(P_COLOR_BRIGHTYELLOW)
	-- mainBgSpr:addChild(self.m_mypowLabel)

	-- self.m_rankTypeSpr=cc.Sprite:create()
	-- self.m_rankTypeSpr:setPosition(self.m_mainSize.width*0.5,nPosY)
	-- mainBgSpr:addChild(self.m_rankTypeSpr)
	-- self.m_rankTypeLabel=_G.Util:CreateTraceLabel("",22,1,P_COLOR_BROWN)
	-- self.m_rankTypeLabel:setPosition(self.m_mainSize.width*0.5,nPosY)
	-- mainBgSpr:addChild(self.m_rankTypeLabel)


	-- nPosY=400

	-- self.m_titleLabelArray={}
	-- local bColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)
	-- for i=1,4 do
	-- 	local posX=P_TITLE_POS[i] or 0
	-- 	local tempLabel=_G.Util:createLabel("",20)
	-- 	tempLabel:setColor(P_COLOR_BRIGHTYELLOW)
	-- 	tempLabel:setPosition(posX,nPosY)
	-- 	mainBgSpr:addChild(tempLabel)

	-- 	self.m_titleLabelArray[i]=tempLabel
	-- end
end

function RankingView.__requestAllMsg(self)
	local msg=REQ_TOP_REQUEST()
	_G.Network:send(msg)
end
function RankingView.allTypeMsgBack(self,_typeArray)
	print("allTypeMsgBack============>>>>>>>AAAAAA")
	if #_typeArray==0 then return end

	local nTypeNameArray=_G.Lang.rank_type
	local newArray={}
	local newCount=0
	for i=#_typeArray,1,-1 do
		local nType=_typeArray[i].type
		local typeName=nTypeNameArray[nType]
		if P_TITLE_ARRAY[nType] and typeName then
			_typeArray[i].sort=P_TITLE_ARRAY[nType].sort
			newCount=newCount+1
			newArray[newCount]=_typeArray[i]
		end
	end

	local function nSort(v1,v2)
		if v1.sort==v2.sort then
			return v1.type<v2.type
		else
			return v1.sort<v2.sort
		end
	end
	table.sort(newArray,nSort)

	local tempNode=cc.Node:create()
	tempNode:setPosition(-258,-320)
	self.m_mainNode:addChild(tempNode)

	local firstType
	self.m_tabBtnArray={}
	for i=1,#newArray do
		local nType=newArray[i].type
		local typeName=nTypeNameArray[nType]
		if not firstType then
			firstType=nType
		end
		self.m_leftTabView:addTabButton(typeName.." 排 行",nType)
	end
	
	if not firstType then return end
	self:__chuangeTabByTag(firstType)
end

function RankingView.msgCallBack(self,_ackMsg)
	self:__createTypeContainer(_ackMsg.type,_ackMsg.data)
	self.m_allTypeMsg[_ackMsg.type]=_ackMsg
	self:__updateMyRank(_ackMsg.self_rank)
end

function RankingView.__chuangeTabByTag(self,_tag)
	print("__chuangeTabByTag===>>>>>>",_tag)
	self.m_leftTabView:selectTagByTag(_tag)
	self.m_curType=_tag

	if self.m_typeContainer~=nil then
		self.m_typeContainer:removeAllChildren()
	else
		self.m_typeContainer=cc.Node:create()
		self.m_rankBgSpr:addChild(self.m_typeContainer)
	end
	if self.m_allTypeMsg[_tag]~=nil then
		self:msgCallBack(self.m_allTypeMsg[_tag])
	else
		local msg=REQ_TOP_RANK()
		msg:setArgs(_tag)
		_G.Network:send(msg)
	end

	if self.m_allTypeMsg[_tag] then
		local myRank=self.m_allTypeMsg[_tag].self_rank
		self:__updateMyRank(myRank)
	end

	-- local titleNameArray=P_TITLE_ARRAY[_tag].name
	-- for i=1,#titleNameArray do
	-- 	self.m_titleLabelArray[i]:setString(titleNameArray[i])
	-- end

 	-- local szTypeName=_G.Lang.rank_type[_tag]
 	-- if szTypeName then
 	-- 	self.m_rankTypeLabel:setString(szTypeName.."排行")
 	-- end
end

function RankingView.__updateMyRank(self,_myRank)
	local szRank
	if not _myRank or _myRank==0 then
		szRank="500+"
	else
		szRank=tostring(_myRank)
	end
	self.m_myRankLabel:setString(szRank)
end

function RankingView.__createTypeContainer(self,_type,_dataArray)
	if self.m_curType~=_type then return end

	local tempNode=self.m_typeContainer
	local rankInfo=P_TITLE_ARRAY[_type]
	if rankInfo==nil then return end

	for k,v in pairs(_dataArray) do
		print("__createTypeContainer===>>>111111",k,v.rank,v.pro)
		if v.rank==0 then
			print("__createTypeContainer===>>>222222",_dataArray.rank)
		end
	end
	

	local valueNameArray=rankInfo.value
	local szValueArray={}

	local mydata=_dataArray[1]
	if _G.Const.CONST_TOP_TYPE_STAR==_type then
		print("CONST_TOP_TYPE_STAR")
		self.mypowLabel:setString("副本星数: "..mydata[rankInfo.value[4]])
	elseif _G.Const.CONST_TOP_TYPE_FIGHTERS==_type then
		print("CONST_TOP_TYPE_FIGHTERS")
		local iTemp=mydata.fighter%5
		local iCeng=iTemp==0 and mydata.fighter/5 or math.ceil(mydata.fighter/5)
		local iGuan=iTemp==0 and 5 or iTemp
		local szCeng=string.format("%d层 %d关",iCeng,iGuan)
		if #_dataArray==1 then
			szCeng="0层 0关"
		end
		self.mypowLabel:setString(szCeng)
	elseif _G.Const.CONST_TOP_TYPE_CLAN==_type then
		print("CONST_TOP_TYPE_CLAN")
		self.mypowLabel:setString("门派等级: "..mydata[rankInfo.value[3]])
	elseif _G.Const.CONST_TOP_TYPE_LV==_type then
		print("CONST_TOP_TYPE_LV")
		self.mypowLabel:setString("等级: "..mydata[rankInfo.value[4]])
	else
		self.mypowLabel:setString("战力: "..mydata[rankInfo.value[4]])
	end

	for i=1,#_dataArray-1 do
		local tData=_dataArray[i+1]
		szValueArray[i]={}
		for j=1,4 do
			if j==4 and _G.Const.CONST_TOP_TYPE_STAR==_type then
				print("CONST_TOP_TYPE_STAR")
				if tData.rank==0 then
					self.mypowLabel:setString("副本星数: "..tData[valueNameArray[j]])
				end
				szValueArray[i][j]="副本星数: "..tData[valueNameArray[j]]
			elseif j==4 and _G.Const.CONST_TOP_TYPE_FIGHTERS==_type then
				print("CONST_TOP_TYPE_FIGHTERS")
				local fighter=szValueArray[i][j]
				local iTemp=tData.fighter%5
				local iCeng=iTemp==0 and tData.fighter/5 or math.ceil(tData.fighter/5)
				local iGuan=iTemp==0 and 5 or iTemp
				local szCeng=string.format("%d层 %d关",iCeng,iGuan)
				szValueArray[i][j]=szCeng
				if tData.rank==0 then
					self.mypowLabel:setString(szCeng)
				end
			elseif j==3 and _G.Const.CONST_TOP_TYPE_CLAN==_type then
				print("CONST_TOP_TYPE_CLAN")
				szValueArray[i][j]="门派等级: "..tData[valueNameArray[j]]
				if tData.rank==0 then
					self.mypowLabel:setString("门派等级: "..tData[valueNameArray[j]])
				end
			elseif j==4 and _G.Const.CONST_TOP_TYPE_CLAN==_type then
				print("CONST_TOP_TYPE_CLAN")
				szValueArray[i][j]="经验: "..tData[valueNameArray[j]]
			elseif j==4 and _G.Const.CONST_TOP_TYPE_LV==_type then
				print("CONST_TOP_TYPE_LV")
				szValueArray[i][j]="等级: "..tData[valueNameArray[j]]
				if tData.rank==0 then
					self.mypowLabel:setString("等级: "..tData[valueNameArray[j]])
				end
			elseif j==4 and valueNameArray[j]~="fighter" then
				szValueArray[i][j]="战力: "..tData[valueNameArray[j]]
				if tData.rank==0 then
					self.mypowLabel:setString("战力: "..tData[valueNameArray[j]])
				end
			elseif j==4 and valueNameArray[j]~="star" then
				szValueArray[i][j]="战力: "..tData[valueNameArray[j]]
				if tData.rank==0 then
					self.mypowLabel:setString("战力: "..tData[valueNameArray[j]])
				end
			-- elseif valueNameArray[j]=="pro" then
			-- 	if szValueArray[i][j]==0 then
			-- 		szValueArray[i][j]=1
			-- 	end
			else
				szValueArray[i][j]=tData[valueNameArray[j]]
			end

			-- if j==4 and _G.Const.CONST_TOP_TYPE_FIGHTERS==_type then
			-- 	local fighter=szValueArray[i][j]
			-- 	local iTemp=tData.fighter%5
			-- 	local iCeng=iTemp==0 and tData.fighter/5 or math.ceil(tData.fighter/5)
			-- 	local iGuan=iTemp==0 and 5 or iTemp
			-- 	local szCeng=string.format("%d层 %d关",iCeng,iGuan)
			-- 	szValueArray[i][j]=szCeng
			-- end
		end
	end

	local nCount=#szValueArray
	if nCount==0 then
		local nohaveSpr1 = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
		nohaveSpr1 : setPosition(self.m_mainSize.width/2,self.m_mainSize.height/2+20)
		tempNode : addChild(nohaveSpr1)

		local tipsLab1 = _G.Util : createLabel("暂无排名", 24)
		-- tipsLab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
		tipsLab1 : setPosition(self.m_mainSize.width/2,self.m_mainSize.height/2-50)
		tempNode : addChild(tipsLab1)
		return
	end

	local pUtil=_G.Util
	local scoSize=cc.size(self.m_rankSize.width,self.m_rankSize.height-15) -- cc.size(self.m_mainSize.width,340)
	local oneHeight=86
	local contentHeight=oneHeight*(nCount>5 and nCount or 5)-4

	local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setBounceable(false)
    scoView:setViewSize(scoSize)
    scoView:setContentSize(cc.size(scoSize.width,contentHeight))
    scoView:setContentOffset(cc.p(0,scoSize.height-contentHeight))
    scoView:setPosition(cc.p(10,1))
    -- scoView:setDelegate()
    tempNode:addChild(scoView)
	
	if nCount>5 then
		local scrollBar=require("mod.general.ScrollBar")(scoView)
		scrollBar:setPosOff(cc.p(-7,0))
	end

	local nnPos=scoView:convertToWorldSpace(cc.p(0,0))
	local nRect=cc.rect(nnPos.x,nnPos.y,scoSize.width,scoSize.height)
    local function c(sender,eventType)
    	if eventType == ccui.TouchEventType.began then
            self.myMove = sender : getWorldPosition().y
            -- sender:setOpacity(180)
        elseif eventType == ccui.TouchEventType.ended then
            local posY = sender : getWorldPosition().y
            local move = posY - self.myMove
            print( "isMove = ", move, posY, self.myMove )
            if move > 5 or move < -5 then
                return
            end
        	-- sender:setOpacity(255)

            local tag=sender:getTag()
            local worldPos=sender:getWorldPosition()
            if not cc.rectContainsPoint(nRect,worldPos) then
            	return
            end

            local roleData=_dataArray[tag]
            self:__showTipsView(roleData)
        elseif eventType==ccui.TouchEventType.canceled then
            -- sender:setOpacity(255)
        end
    end

  --   for i=1,nCount do
  --   	local uid=_dataArray[i].uid
  --   	local posY=contentHeight-(0.5+i-1)*oneHeight
  --   	local color=P_RANK_COLOR_ARRAY[i]

  --   	for j=1,#szValueArray[i] do
  --   		local szValue=tostring(szValueArray[i][j])
  --   		local posX=P_TITLE_POS[j] or 0
		-- 	local sColor=color or P_COLOR_BROWN
		-- 	-- print("NMMNMNMNMNMNMNMNMNMNM>>>>",szValue)
  --   		local tempLabel=pUtil:createLabel(szValue,20)
		-- 	tempLabel:setColor(sColor)
		-- 	tempLabel:setPosition(posX,posY)
		-- 	scoView:addChild(tempLabel)
  --   	end

		-- local tempBtn=ccui.Button:create()
  --       tempBtn:setScale9Enabled(true)
  --       tempBtn:loadTextures("general_double2.png","general_double2.png","general_double2.png",1)
  --       tempBtn:setContentSize(cc.size(scoSize.width-4,oneHeight-4))
  --       tempBtn:setPosition(scoSize.width*0.5,posY)
  --       tempBtn:addTouchEventListener(c)
  --       tempBtn:setSwallowTouches(false)
  --       tempBtn:setTag(i)
  --       scoView:addChild(tempBtn,-1)
  --   end

    local index=1
    local function nFun()
    	if index>nCount then
    		self:__removeScheduler()
    		return
    	end

    	local uid=_dataArray[index].uid
    	local posY=contentHeight-(0.5+index-1)*oneHeight
    	-- local color=P_RANK_COLOR_ARRAY[index]

    	for j=1,#szValueArray[index] do
    		local szValue=tostring(szValueArray[index][j])
    		local posX=P_TITLE_POS[j] or 0
			local sColor=color or P_COLOR_BROWN
			-- print("NMMNMNMNMNMNMNMNMNMNM>>>>",szValue)
			if index>3 or j~=1 then 
				if j==2 then
					if _G.Const.CONST_TOP_TYPE_CLAN~=_type then
						if szValue=="0" then szValue="1" end
						-- print("szValue====>>>",szValue)
						local szProImg=string.format("general_role_head%s.png",szValue)
						local playerSpr = gc.GraySprite:createWithSpriteFrameName(szProImg)
						playerSpr : setPosition(posX,posY)
						playerSpr : setScale(0.75)
						scoView:addChild(playerSpr)
					else
						local tempLabel=pUtil:createLabel(szValue,20)
						tempLabel:setColor(sColor)
						if j~=1 then
							tempLabel:setAnchorPoint(cc.p(0,0.5))
						end
						tempLabel:setPosition(posX-60,posY)
						scoView:addChild(tempLabel)
					end
				else
		    		local tempLabel=pUtil:createLabel(szValue,20)
					tempLabel:setColor(sColor)
					if j~=1 then
						tempLabel:setAnchorPoint(cc.p(0,0.5))
					end
					tempLabel:setPosition(posX,posY)
					scoView:addChild(tempLabel)
				end
			end
    	end

    	if index<4 then
    		local NumberSpr=cc.Sprite:createWithSpriteFrameName(string.format("general_number%d.png",index))
    		NumberSpr:setPosition(60,posY)
    		scoView:addChild(NumberSpr)
    	end

		local tempBtn=ccui.Button:create()
        tempBtn:setScale9Enabled(true)
        tempBtn:loadTextures("general_nothis.png","general_isthis.png","general_isthis.png",1)
        tempBtn:setContentSize(cc.size(scoSize.width-16,oneHeight-5))
        tempBtn:setPosition(scoSize.width*0.5,posY)
        tempBtn:addTouchEventListener(c)
        tempBtn:setSwallowTouches(false)
        tempBtn:setTag(index+1)
        tempBtn:enableSound()
        scoView:addChild(tempBtn,-1)

    	index=index+1
    end
    local firstEnd=nCount>5 and 5 or nCount
    for i=1,firstEnd do
    	nFun()
    end
    self.m_mySchedule=_G.Scheduler:schedule(nFun,0)
end

function RankingView.__removeScheduler(self)
	if self.m_mySchedule~=nil then
		_G.Scheduler:unschedule(self.m_mySchedule)
		self.m_mySchedule=nil
	end
end

function RankingView.__hideTipsView(self)
	if self.m_roleTipsNode==nil then return end
	local function f(_node)
		_node:removeFromParent(true)
	end
	-- cc.ScaleTo:create(0.3,0.05)
	local action=cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(f))
	self.m_roleTipsNode:runAction(action)
	self.m_roleTipsNode=nil
end
function RankingView.__showTipsView(self,_roleData)
	self:__hideTipsView()

	if self.m_myUid==_roleData.uid then
		local command=CErrorBoxCommand(15001)
		controller:sendCommand(command)
		return
	end

	self.m_curShowRoleData=_roleData
	local winSize=cc.Director:getInstance():getWinSize()
	self.m_roleTipsNode=cc.LayerColor:create(cc.c4b(0,0,0,150))
	-- self.m_roleTipsNode:setPosition(winSize.width*0.5,winSize.height*0.5)

	local btnInfoArray={}
	local btnInfoCount=0

	local szTitle
	if self.m_curType==_G.Const.CONST_TOP_TYPE_CLAN then
		szTitle=_roleData.clan_name
		local myClanId=_G.GPropertyProxy:getMainPlay():getClan()
		if myClanId==_roleData.clan_id then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_TCDF,"退出门派"}
		else
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_JRDF,"加入门派"}
		end
		btnInfoCount=btnInfoCount+1
		btnInfoArray[btnInfoCount]={P_TAG_CKDF,"查看门派"}
	else
		btnInfoCount=btnInfoCount+1
		btnInfoArray[btnInfoCount]={P_TAG_ZLDB,"战力对比"}
		szTitle=_roleData.name
		if not _G.GFriendProxy:hasThisBlackFriend(_roleData.uid) then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_JRHMD,"加黑名单"}
		else
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_JCHMD,"解除黑名"}
		end
		if not _G.GFriendProxy:hasThisFriend(_roleData.uid) then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_JWHY,"加为好友"}
		else
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_SCHY,"删除好友"}
		end
		btnInfoCount=btnInfoCount+1
		btnInfoArray[btnInfoCount]={P_TAG_FQSL,"发起私聊"}
		
		if self.m_curType==_G.Const.CONST_TOP_TYPE_WING then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKZY,"查看宠物"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_MOUNT then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKZQ,"查看坐骑"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_MEIREN then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKXL,"查看美人"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_BAQI then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKBG,"查看八卦"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_STAR then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKJS,"查看经脉"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_MAGIC then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKSB,"查看神兵"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_WUQI then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKQL,"查看武器"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_FEATHER then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKSY,"查看翅膀"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_EQUIP_STRENG then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKYP,"查看元魄"}
		elseif self.m_curType==_G.Const.CONST_TOP_TYPE_LINGYAO then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKLY,"查看灵妖"}
		else
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={P_TAG_CKXX,"查看信息"}
		end
	end

	local buttonCount=#btnInfoArray
	local oneHeight=55
	local tipsSize=cc.size(176,55+(oneHeight)*buttonCount)
	local backFrameSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendkuang.png")
	backFrameSpri:setPosition(winSize.width*0.5,winSize.height*0.5)
	backFrameSpri:setPreferredSize(tipsSize)
	self.m_roleTipsNode:addChild(backFrameSpri)

	local midPos=tipsSize.width*0.5
	local nameLabel=_G.Util:createLabel(szTitle,20)
	nameLabel:setPosition(midPos,tipsSize.height-30)
	nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	backFrameSpri:addChild(nameLabel)

	-- local btnSize=cc.size(midPos,(oneHeight*buttonCount+35)/buttonCount-5)
	for i=1,#btnInfoArray do
		self:createLightButton(i,btnInfoArray[i][1],btnInfoArray[i][2],backFrameSpri,tipsSize)
	end

	local function onTouchBegan()
		self:__hideTipsView()
		return true 
	end
	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listerner:setSwallowTouches(true)
	self.m_roleTipsNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_roleTipsNode)
	cc.Director:getInstance():getRunningScene():addChild(self.m_roleTipsNode,999)
end
function RankingView.createLightButton(self,_no,_tag,_szName,_parent,_size)
	local function c(sender,eventType)
		if eventType==ccui.TouchEventType.began then
            sender:setOpacity(180)
		elseif eventType==ccui.TouchEventType.ended then
			sender:setOpacity(255)
			local tag=sender:getTag()
			local uid=self.m_curShowRoleData.uid
			print("createLightButton=========>>>>>",tag,uid)
			if tag==P_TAG_CKXX then
				_G.GLayerManager:showPlayerView(uid)
			elseif tag==P_TAG_FQSL then
				local chatData={}
				chatData.dataType=_G.Const.kChatDataTypeSL
				chatData.chatName=self.m_curShowRoleData.name
				chatData.chatId=uid
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_CHATTING,nil,chatData)
			elseif tag==P_TAG_JWHY then
				local msg = REQ_FRIEND_ADD()
				msg:setArgs(_G.Const.CONST_FRIEND_FRIEND,1,{uid})
				_G.Network:send(msg)
			elseif tag==P_TAG_SCHY then
				local msg=REQ_FRIEND_DEL()
				msg:setArgs(uid,_G.Const.CONST_FRIEND_FRIEND)
				_G.Network:send(msg)
			elseif tag==P_TAG_JRHMD then
				local msg = REQ_FRIEND_ADD()
				msg:setArgs(_G.Const.CONST_FRIEND_BLACKLIST,1,{uid})
				_G.Network:send(msg)
			elseif tag==P_TAG_JCHMD then
				local msg=REQ_FRIEND_DEL()
				msg:setArgs(uid,_G.Const.CONST_FRIEND_BLACKLIST)
				_G.Network:send(msg)
			elseif tag==P_TAG_ZLDB then
				_G.GLayerManager:openLayer(_G.Cfg.UI_BattleCompareView,nil,uid)
			elseif tag==P_TAG_TCDF then
				-- 退出门派
				local szMsg="确定要退出门派吗？\n(门派技能保留)"
				local function fun1()
					local msg=REQ_CLAN_ASK_OUT_CLAN()
					msg:setArgs(1)        -- {1 退出门派| 0 解散门派}
					_G.Network:send(msg)
				end
				_G.Util:showTipsBox(szMsg,fun1)
			elseif tag==P_TAG_JRDF then
				-- 加入门派
				local msg=REQ_CLAN_ASK_CANCEL()
		        msg:setArgs(1,self.m_curShowRoleData.clan_id)
		        _G.Network:send(msg)
			elseif tag==P_TAG_CKDF then
				-- 查看门派
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_GANGS,nil,self.m_curShowRoleData.clan_id)
			elseif tag==P_TAG_CKZY then
				-- 查看宠物
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_WING,nil,uid)
			elseif tag==P_TAG_CKZQ then
				-- 查看坐骑
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_MOUNT,nil,uid)
			elseif tag==P_TAG_CKXL then
				-- 查看美人
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_BEAUTY,nil,uid)
			elseif tag==P_TAG_CKBG then
				-- 查看八卦
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_SHEN,nil,_G.Const.CONST_FUNC_OPEN_SHEN_UP,uid)
			elseif tag==P_TAG_CKJS then
				-- 查看经脉
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_ROLE,nil,4,uid)
			elseif tag==P_TAG_CKSB then
				-- 查看神兵
				_G.GLayerManager:showPlayerView(uid,true)
			elseif tag==P_TAG_CKQL then
				-- 查看武器
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_QILING,nil,uid)
			elseif tag==P_TAG_CKSY then
				-- 查看翅膀
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_FEATHER,nil,uid)
			elseif tag==P_TAG_CKYP then
				-- 查看元魄
				_G.GLayerManager:showPlayerView(uid,nil,true)
			elseif tag==P_TAG_CKLY then
				-- 查看灵妖
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_PARTNER,nil,uid)
			end
			self:__hideTipsView()
		elseif eventType==ccui.TouchEventType.canceled then
            sender:setOpacity(255)
        end
	end
	local widget=gc.CButton:create("general_btn_gray.png")
	-- widget:setScale9Enabled(true)
	-- widget:setContentSize)
	widget:addTouchEventListener(c)
	widget:setPosition(_size.width/2,5+(_no-0.5)*55)
	widget:setTag(_tag)
	_parent:addChild(widget)

	widget : setTitleText(_szName)
	widget : setTitleFontSize(22)
	widget : setTitleFontName(_G.FontName.Heiti)
	-- local btnNameLabel=_G.Util:createLabel(_szName,22)
	-- btnNameLabel:setPosition(_size.width*0.5,_size.height*0.5)
	-- btnNameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	-- widget:addChild(btnNameLabel)

	return widget
end

function RankingView.__showWaitPKView(self)
	-- self.tipSprite:setVisible(false)
	P_VIEW_SIZE=cc.size(300,200)
	P_MID_X=P_VIEW_SIZE.width*0.5

	if self.m_frameSpr~=nil then return end


	self.m_frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
	self.m_frameSpr:setPreferredSize(P_VIEW_SIZE)
	self.m_mainNode:addChild(self.m_frameSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(P_VIEW_SIZE.width/2, P_VIEW_SIZE.height-5)
	self.m_frameSpr : addChild(tipslogoSpr)

	local logoSize = tipslogoSpr:getContentSize()
	local logoLab= _G.Util : createLabel("切磋请求", 20)
	logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	logoLab : setPosition(logoSize.width/2, logoSize.height/2)
	tipslogoSpr : addChild(logoLab)

	local noticLabel=_G.Util:createLabel("等待对方响应",24)
	noticLabel:setPosition(P_MID_X,P_VIEW_SIZE.height-50)
	self.m_frameSpr:addChild(noticLabel)

	local tempX=P_MID_X-15
	local tempY=P_VIEW_SIZE.height*0.5
	local tempLabel=_G.Util:createLabel("邀请倒计时:",20)
	tempLabel:setPosition(tempX,tempY)
	self.m_frameSpr:addChild(tempLabel)

	local waitTimes=30
	local tempSize=tempLabel:getContentSize()
	self.m_waitPKTimesLabel=_G.Util:createLabel(tostring(waitTimes),20)
	self.m_waitPKTimesLabel:setAnchorPoint(cc.p(0,0.5))
	-- self.m_waitPKTimesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	self.m_waitPKTimesLabel:setPosition(tempX+tempSize.width*0.5+5,tempY)
	self.m_frameSpr:addChild(self.m_waitPKTimesLabel)

	local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		self:__hideWaitPKView()
    	end
    end
    local tempBtn=gc.CButton:create("general_btn_gold.png")
	tempBtn:addTouchEventListener(c)
	tempBtn:setPosition(P_MID_X,45)
	tempBtn:setTitleFontName(_G.FontName.Heiti)
	tempBtn:setTitleText("取 消")
	tempBtn:setTitleFontSize(24)
	tempBtn:setButtonScale(0.85)
	self.m_frameSpr:addChild(tempBtn)

	self.m_waitPKTimes=_G.TimeUtil:getTotalSeconds()+waitTimes

	self:__runTimesScheduler()
end
function RankingView.__hideWaitPKView(self)
	if self.m_frameSpr~=nil then
		self.m_frameSpr:removeFromParent(true)
		self.m_frameSpr=nil
	end
	self.m_waitPKTimes=nil
	self.m_waitPKTimesLabel=nil

	-- self.m_infoNode:setVisible(true)

	self:__removeTimesScheduler()

	local msg=REQ_WAR_PK_CANCEL()
   	_G.Network:send(msg)
end

function RankingView.__runTimesScheduler(self)
	if self.m_timesScheduler then return end

	local nTimeUtil=_G.TimeUtil
	local function onSchedule()
		local curTime=nTimeUtil:getTotalSeconds()
		local subTime=self.m_waitPKTimes-curTime
		local szTimes=tostring(subTime)
		self.m_waitPKTimesLabel:setString(szTimes)

		if subTime<=0 then
			self:__hideWaitPKView()
		end
	end

	self.m_timesScheduler=_G.Scheduler:schedule(onSchedule,1)
end
function RankingView.__removeTimesScheduler(self)
	if self.m_timesScheduler~=nil then
		_G.Scheduler:unschedule(self.m_timesScheduler)
		self.m_timesScheduler=nil
	end
end

function RankingView.closeWindow(self)
	if self.m_rootLayer==nil then return end
	self.m_rootLayer=nil

	cc.Director:getInstance():popScene()

	self:destroy()
	self:__removeScheduler()
end

return RankingView

