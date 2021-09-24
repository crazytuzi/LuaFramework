local QiLingView=classGc(view,function(self,_uid)
	self.uid=_uid or 0
	self.Tag=0
	self.m_mony = nil
	self.m_spineResArray={}
end)

local FONT_SIZE=20
local m_winSize  	= cc.Director:getInstance() : getWinSize()
local leftSize=cc.size(295,507)
local rightSize=cc.size(546,507)
local qiling=_G.Cfg.wuqi

function QiLingView.create(self)
	self.m_normalView=require("mod.general.NormalView")()
	self.m_rootLayer=self.m_normalView:create()

	self:__initView()

	self.m_mediator=require("mod.smodule.QiLingMediator")(self)

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	local msg = REQ_WUQI_REQUEST()
	msg       : setArgs(self.uid)
	_G.Network: send(msg)
	return tempScene
end

function QiLingView.__initView(self)
	local function nCloseFun()
		self:closeWindow()
	end
	self.m_normalView:addCloseFun(nCloseFun)
	-- self.m_normalView:showSecondBg()
	self.m_normalView:setTitle("专属武器")

	local container=cc.Node:create()
	container:setPosition(m_winSize.width/2,m_winSize.height/2)
	self.m_rootLayer:addChild(container)

	local leftSpr=cc.Sprite : create("ui/bg/qiling_leftbg.jpg")
	-- leftSpr : setPreferredSize(leftSize)
	leftSpr : setPosition(cc.p(-275,-42))
	container : addChild(leftSpr)
	self.leftSpr=leftSpr

	local rightSpr=cc.Sprite : create("ui/bg/qiling_rightbg.jpg")
	-- rightSpr : setPreferredSize(rightSize)
	rightSpr : setPosition(cc.p(150,-42))
	container : addChild(rightSpr)

	local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
	attrFryNode:setPosition(leftSize.width/2,leftSize.height/2)
	leftSpr:addChild(attrFryNode,1000)
	
	self.nameLab=_G.Util:createLabel("",36)
	self.nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	self.nameLab:setPosition(rightSize.width/2,rightSize.height-35)
	rightSpr:addChild(self.nameLab)

	self.starSpr={}
	self.attrLab={}
	for i=1,10 do
		self.starSpr[i]=gc.GraySprite:createWithSpriteFrameName("general_star.png")
		self.starSpr[i]:setPosition(30,rightSize.height-65-i*33)
		self.starSpr[i]:setScale(1.3)
		self.starSpr[i]:setGray()
		rightSpr:addChild(self.starSpr[i])

		local buffdata=qiling[i].bfb[1]
		local jdzdata1 =qiling[i].jdz[1]
		local jdzdata2 =qiling[i].jdz[2]
		local jdzdata3 =qiling[i].jdz[3]
		local attr=string.format("%s+%d%s",_G.Lang.type_name[buffdata[1]],buffdata[2]/100,"%")
		if jdzdata1~=nil then
			attr=string.format("%s %s+%d",attr,_G.Lang.type_name[jdzdata1[1]],jdzdata1[2])
		end
		if jdzdata2~=nil then
			attr=string.format("%s %s+%d",attr,_G.Lang.type_name[jdzdata2[1]],jdzdata2[2])
		end
		if jdzdata3~=nil then
			attr=string.format("%s %s+%d",attr,_G.Lang.type_name[jdzdata3[1]],jdzdata3[2])
		end
		self.attrLab[i]=_G.Util:createLabel(attr,FONT_SIZE+2)
		-- self.attrLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRAY))
		self.attrLab[i]:setPosition(50,rightSize.height-65-i*33)
		self.attrLab[i]:setAnchorPoint(cc.p(0,0.5))
		rightSpr:addChild(self.attrLab[i])
        
        local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_line_white.png")
        lineSpr : setPreferredSize(cc.size(526,2))
        lineSpr : setAnchorPoint(0,0.5)
        lineSpr : setPosition(12,86)
        rightSpr : addChild(lineSpr)
        self.m_rightSpr = rightSpr

       --[[
       --]]
        --[[
        local jiaoBiaoSize = jiaobiaoSpr : getContentSize()
        local line1 = ccui.Scale9Sprite : createWithSpriteFrameName("general_title_hight.png")
        line1 : setAnchorPoint(0,0.5)
        line1 : setRotation (-30)
        line1 : setPreferredSize(cc.size(60,2))
        line1 : setPosition(0,41)
        jiaobiaoSpr : addChild(line1)
        local line2 = ccui.Scale9Sprite : createWithSpriteFrameName("general_title_hight.png")
        line2 : setAnchorPoint(0,0.5)
        line2 : setPreferredSize(cc.size(140,2))
        line2 : setRotation (-30)
        line2 : setPosition(0,0)
        jiaobiaoSpr : addChild(line2)
        --]]
        ----[[

      -- self : upDataDownKuang()
        --]]
	end



	local function BtnCallBackEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			print("BtnCallBackEvent---->>",self.Tag)
			if self.Tag==0 then
				local function sure()
					print("激活")
					local msg = REQ_WUQI_LV_UP()
					_G.Network: send(msg)
				end

				if self.m_mony then self.rmbNum = self.m_mony  end
				local tipsStr=string.format("花费%d钻石激活武器？\n(可获得一星属性加成)",self.rmbNum)
			    _G.Util : showTipsBox(tipsStr,sure)
			else
				local function sure()
					print("提升")
					local msg = REQ_WUQI_LV_UP()
					_G.Network: send(msg)
				end
				if self.m_mony then self.rmbNum = self.m_mony  end
				local tipsStr=string.format("花费%d钻石提升武器？",self.rmbNum)
			    _G.Util : showTipsBox(tipsStr,sure)
			end
		end
	end 
  
  ---[[
	self.m_button  = gc.CButton:create()
	self.m_button  : addTouchEventListener(BtnCallBackEvent)
	self.m_button  : loadTextures("general_btn_gold.png")
	self.m_button  : setTitleText("激 活")
	self.m_button  : setTitleFontSize(24)
	--self.m_button  : setContentSize(0.8)
	self.m_button  : setTitleFontName(_G.FontName.Heiti)
	self.m_button  : setPosition(cc.p(rightSize.width/2,37))
	rightSpr : addChild(self.m_button,10)
 
	if self.uid~=0 then
		self.m_button:setBright(false)
		self.m_button:setEnabled(false)
	end
--]]
	-- local tipsLab=_G.Util:createLabel("消耗:",FONT_SIZE)
	-- tipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	-- tipsLab:setPosition(rightSize.width/2+90,27)
	-- rightSpr:addChild(tipsLab)

	self.NumLab=_G.Util:createLabel("",FONT_SIZE)
	-- self.NumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	self.NumLab:setAnchorPoint(cc.p(0,0.5))
	self.NumLab:setPosition(rightSize.width/2+80,27)
	rightSpr:addChild(self.NumLab)
end
function QiLingView.upDataDownKuang(self,Msgtiem,lv)

	   -- local time = os.time(Msgtiem)
	    local data = self : getZheKouAndTime(Msgtiem)
	    if data == nil  or lv >= 10 then return end
	    --print ("data-->",data.zhekou,data.time,lv) 
        local downKuangBg = ccui.Scale9Sprite :createWithSpriteFrameName("general_noit.png")
        downKuangBg : setPreferredSize(cc.size(530,66))
        downKuangBg : setAnchorPoint(0,0.5)
        downKuangBg : setPosition(8,46)
        self.m_rightSpr : addChild(downKuangBg) 
        self.m_button : setPosition (cc.p(rightSize.width/2,46))
        local SprSize = downKuangBg : getContentSize()
        --self.m_downKuangBg = downKuangBg

        
        local xiaoHaoLab = _G.Util : createLabel("消耗：",FONT_SIZE-4)
         xiaoHaoLab : setAnchorPoint(0,0.5)
         xiaoHaoLab : setPosition(cc.p(SprSize.width/2+70,SprSize.height/2-13))
         downKuangBg : addChild(xiaoHaoLab) 

         local priceSpr = cc.Sprite : createWithSpriteFrameName("general_xianYu.png")
         --priceSpr : setPreferredSize(cc.size(10,10))
         priceSpr : setScale(0.8)
         priceSpr : setPosition(cc.p(SprSize.width/2+116,SprSize.height/2-13))
         downKuangBg : addChild(priceSpr)          
         
        if data == nil or lv >= 10 then 
           xiaoHaoLab : setPosition(cc.p(SprSize.width/2+90,SprSize.height/2))
           priceSpr : setPosition(cc.p(SprSize.width/2+138,SprSize.height/2)) 
          local priceLab = _G.Util : createLabel(string.format("%d",self.rmbNum), FONT_SIZE-4)
          priceLab : setPosition(cc.p(SprSize.width/2+170,SprSize.height/2))
          downKuangBg : addChild(priceLab)          
          return 
        end

        local rmbNum = qiling[lv + 1].cost
        local jiaobiaoSpr = cc.Sprite : createWithSpriteFrameName("qiling_jiaobiao.png")
        --jiaobiaoSpr : setContentSize(cc.size(1,2))
        jiaobiaoSpr : setAnchorPoint(0,0.5)
        jiaobiaoSpr : setPosition(0,44)
        self.m_rightSpr : addChild(jiaobiaoSpr,2)

        local num1 = rmbNum/10000  *   data.zhekou
        --if num2 >= 0.5 then num1 =  num1 + 1 end 
        print("numlab--->",num1,10*num1/rmbNum)
        local zkPrice = rmbNum - num1

        local zhekou =(10*num1/rmbNum)
        local strZK = string.format("%.1f折",zhekou) 

        local xianshiLab = _G.Util : createLabel("限时：",FONT_SIZE-4)
         xianshiLab : setAnchorPoint(0,0.5)
         xianshiLab : setPosition(cc.p(SprSize.width/2+70,SprSize.height/2+13))
         downKuangBg : addChild(xianshiLab)  
        
     
         
         local timeLab = _G.Util : createLabel(data.Time, FONT_SIZE-4)
         timeLab : setPosition(cc.p(SprSize.width/2+182,SprSize.height/2+13))
         downKuangBg : addChild(timeLab)
 
         
         local priceLab = _G.Util : createLabel(string.format("%d",rmbNum), FONT_SIZE-4)
         priceLab : setPosition(cc.p(SprSize.width/2+150,SprSize.height/2-13))
         downKuangBg : addChild(priceLab)
         
         local s = priceLab : getContentSize()
         local line = ccui.Scale9Sprite : createWithSpriteFrameName("general_line_white.png")
         line : setPreferredSize(cc.size(s.width,2))
         line : setPosition(cc.p(SprSize.width/2+150,SprSize.height/2-13))
         downKuangBg : addChild(line)

         local zkPriceLab = _G.Util : createLabel(string.format(num1),FONT_SIZE-4)
         zkPriceLab : setPosition(cc.p(SprSize.width/2+200,SprSize.height/2-13))
         downKuangBg : addChild(zkPriceLab)
         self.m_mony = num1

       --[[
       local zhekouSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_isthis.png")
       local jiaBiaoSize = jiaobiaoSpr : getContentSize()
       zhekouSpr : setPreferredSize(cc.size(12,8))
       zhekouSpr : setPosition(cc.p(jiaBiaoSize.width/2,jiaBiaoSize.height/2))
       jiaobiaoSpr : addChild(zhekouSpr)
       --]]
       local zhekouLab = _G.Util : createLabel(strZK,FONT_SIZE)
       local zhekouSize = jiaobiaoSpr : getContentSize()
       zhekouLab : setRotation(-30)
       zhekouLab : setPosition(cc.p(zhekouSize.width/2-12,zhekouSize.height/2+14))
       jiaobiaoSpr : addChild(zhekouLab)         

   end 

function QiLingView.getZheKouAndTime(self,openTime)

	    local zheKouLab = _G.Cfg.wuqi_dz
	  --  local nowtime = os.time()          --当前时间戳
         local nowtime     = _G.TimeUtil:getServerTimeSeconds() --当前时间戳
	    nowtimeT = os.date("*t",nowtime) 
	    print("nowtimeT  -->",nowtimeT.year,nowtimeT.month,nowtimeT.day,nowtimeT.hour,nowtimeT.min,nowtimeT.sec)
	    --[[
	    local lastTime = zheKouLab[7].times+openTime 
	    local SurTime = lastTime - nowtime
        if SurTime <= 0 then return end
	    lastTimeLab = os.date("*t",lastTime) 
       -- strTime = string.format("%d天%")
	    --local strTime = self : toStrtime(SurTime)
	   -- print("strTime-->",strTime)
	   -- print("ntimeLab   -->",ntimeLab.year,ntimeLab.month,ntimeLab.day,ntimeLab.hour,ntimeLab.min,ntimeLab.sec) 
	   --]]
	    for i=1,#zheKouLab do 
	       print("#zheKouLab",#zheKouLab,i)
	       local zktime = zheKouLab[i].times 
	       local endTime = openTime + zktime  
	       local SurTime = endTime - nowtime
	       local strTime = self : toStrtime(SurTime)
	       if endTime >= nowtime then   
              return {zhekou = zheKouLab[i].zhekou, Time = strTime }
	       end 
         
        end 
                
	    return  
end
--转化时间倒计时字符串
function QiLingView.toStrtime(self,time)
    local day =  math.floor(time / (24*3600))
    local hour =  math.floor((time % (24*3600)) /3600)
    local min  =  math.floor(((time % (24*3600)) % 3600)/60)
    --local sec =  ((time % (24*3600)) % 3600) % 60
    return string.format("%d天%d小时%d分",day,hour,min)
 end
   
function QiLingView.updateMsg(self,_lv,_pro,_msgtime)
	print("updateMsg",_lv)
	-- _pro=_G.GPropertyProxy:getMainPlay():getPro()
	local nowjie=string.format("灵阶%s段",_G.Lang.number_Chinese[_lv])
	if _lv==0 then nowjie="灵阶初段" end
	self.nameLab:setString(nowjie)
    
	for i=1,_lv do
		self.starSpr[i]:setDefault()
		self.attrLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
	end
	if _lv>0 then
		self.Tag=1
		self.m_button:setTitleText("提 升")
		
	end

	if _lv+1<=10 then
		self.rmbNum=qiling[_lv+1].cost
		self.NumLab:setString(string.format("消耗:%d钻石",self.rmbNum))
	else
		--self.m_button:setVisible(false)
	    self.m_button : setEnabled(false)
		self.m_button : setBright(false)		
		self.NumLab:setString("")
	end

	if self.isTrue~=nil then
		_G.Util:playAudioEffect("ui_strengthen_success")
	else
		-- _pro=_G.GPropertyProxy:getMainPlay():getPro()
		-- fazhenName=string.format("spine/wuqifazhen_%d",m_pro)
		-- self.m_spineResArray[fazhenName]=true
		-- local fazhenspine = _G.SpineManager.createSpine(fazhenName,1)
		-- fazhenspine:setAnimation(0,"idle",true)
		-- fazhenspine:setPosition(leftSize.width/2,70)
		-- self.leftSpr:addChild(fazhenspine)
	end
    self : upDataDownKuang(_msgtime,_lv)
	self:updateBody(_pro)

	self.isTrue=1
end

-- function QiLingView.updateAttr(self)

-- end

function QiLingView.updateBody(self,_pro)
-- local _pro=2
	print("updateBody===>>>",_pro)
	if self.rolespine~=nil then
		self.rolespine:removeFromParent(true)
		self.rolespine=nil
	end
	-- if _lv>=10 then _lv=9 end
	local m_pro=_pro or _G.GPropertyProxy:getMainPlay():getPro()
	local roleName = string.format("spine/wq_100%d",m_pro)
	local scale=1
	local Height=leftSize.height/2-150
	if m_pro==1 then
	 	scale=0.7
	 	Height=leftSize.height/2-180
	elseif m_pro==2 then 
		scale=0.43
		Height=leftSize.height/2-180
    elseif m_pro==3 then
		scale=0.75
		Height=leftSize.height/2-220
    elseif m_pro==4 then
		scale=0.65
		Height=leftSize.height/2-200
	end
	self.m_spineResArray[roleName]=true
	self.rolespine = _G.SpineManager.createSpine(roleName,scale)
	self.rolespine:setAnimation(0,"idle",true)
	self.rolespine:setPosition(leftSize.width/2,Height)
	self.leftSpr:addChild(self.rolespine)

	local nameSpr=cc.Sprite:createWithSpriteFrameName(string.format("qiling_name%d.png",m_pro))
	nameSpr:setPosition(55,leftSize.height-80)
	self.leftSpr:addChild(nameSpr)
end

function QiLingView.closeWindow(self)
	if self.m_rootLayer==nil then return end
	self.m_rootLayer=nil
	self.m_rightSpr = nil 
	self.m_mony = nil
	_G.SpineManager.releaseSpineInView(self.m_spineResArray)
	cc.Director:getInstance():popScene()
	self:destroy()
end

return QiLingView