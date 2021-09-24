local BagHeChengLayer = classGc(view, function(self,_panelType,_numbtn)
  self.m_allData  = {}
  self.m_oldBtn   = {}
  self.m_maxCount = 0 
  self.oneTru = true
  self.number = _numbtn or 1
end)

local FONT_SIZE  = 20

BagHeChengLayer.ADD_TAG      = 1
BagHeChengLayer.REDUCE_TAG   = 2
BagHeChengLayer.EDITBOX_TAG  = 3
BagHeChengLayer.MAX_TAG      = 4
BagHeChengLayer.HECHENG_TAG  = 5
local winSize=cc.Director:getInstance():getWinSize()

function BagHeChengLayer.__create(self)
   self.m_container = cc.Node:create()
   -- self.m_container : setPosition(winSize.width/2,0)

  self.m_rootBgSize = cc.size( 828, 492) 

  self.m_leftSprSize= cc.size(212,480)
  self.m_leftSpr    = ccui.Scale9Sprite : createWithSpriteFrameName( "general_login_dawaikuan.png" ) 
  self.m_leftSpr    : setPreferredSize( self.m_leftSprSize )
  self.m_container  : addChild(self.m_leftSpr)
  self.m_leftSpr    : setPosition(-309,-55)

  self.m_rightSprSize= cc.size(614,480)
  self.m_rightSpr    = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double.png" ) 
  self.m_rightSpr    : setPreferredSize( self.m_rightSprSize )
  self.m_container   : addChild(self.m_rightSpr)
  self.m_rightSpr    : setPosition(109,-55)

  self.m_rightNode   = cc.Node : create()
  self.m_rightNode   : setContentSize(self.m_rightSprSize)
  -- self.m_rightNode   : setVisible(false)
  self.m_rightSpr    : addChild(self.m_rightNode)

  self.m_oldBtn.no1=self.number
  self:__checkAllHeCheng()
  self:__createRightPanel()
  self:__createLeftPanel(self.number)

  return self.m_container
end

local ONEPAGECOUNT = 9 
local ONEHEIGHT    = 66 

function BagHeChengLayer.__createLeftPanel( self,_root )
    print("__createLeftPanel",_root)
    if self.m_leftScrollView~=nil then
        self.m_leftScrollView:removeFromParent(true)
        self.m_leftScrollView=nil 
    end
    if self.m_barView~=nil then
        self.m_barView:remove()
        self.m_barView=nil
    end

    local rootCount   = 0 
    local secondCount = 0 
    local thirdCount  = 0 

    local allCount = 0 
    local allData  = {}

    local rootNode = _G.Cfg.pearl_com
    if rootNode==nil then return end
    local rootCount=#rootNode or 0 --第一层的按钮
    if rootCount<=0 then return end

    if _root~=nil then 
        --第一层按钮（开始部分）
        for i=1,_root do
            allCount=allCount+1
            allData[allCount]      = {}
            allData[allCount].name = rootNode[i].big_name
            allData[allCount].no   = allCount
            allData[allCount].tag1 = i
            allData[allCount].tag2 = nil
            allData[allCount].lv   = 1
            allData[allCount].gemid= nil 
            allData[allCount].make = nil
        end

        -- local firstNode=rootNode[k]
        -- if firstNode==nil or firstNode.talbe==nil then return end
        -- --第二层开始----------------------------------------------------------------
        -- local secondNode=firstNode.talbe
        -- if secondNode~=nil then
        --    secondCount = #secondNode

        --     if k~=nil and secondCount>0  then --有按到第二层的按钮
        --         --第二层按钮（开始部分）
        --         for i=1,k do
        --             allCount=allCount+1
        --             allData[allCount]      = {}
        --             allData[allCount].name = secondNode[i].small_name
        --             allData[allCount].no   = allCount
        --             allData[allCount].tag1 = _root
        --             allData[allCount].tag2 = i
        --             allData[allCount].lv   = 2
        --             allData[allCount].gemid= nil
        --             allData[allCount].make = nil 
        --         end

                --第三层开始----------------------------------------------------------------
                local m_thirdNode = rootNode[_root]
                local tableData = m_thirdNode.talbe
                if m_thirdNode~=nil and tableData~=nil then

                    local testdata = {}
                    for k,v in pairs(tableData) do
                        table.insert(testdata,v)
                    end
                    local function sort( data1, data2 )
                        if data1.pearl_id<data2.pearl_id then
                            return true
                        end
                    end
                    table.sort( testdata , sort )

                    for k,v in pairs(testdata) do
                        thirdCount=thirdCount+1
                        allCount=allCount+1
                        allData[allCount]      = {}
                        allData[allCount].no   = allCount
                        allData[allCount].tag1 = _root
                        allData[allCount].tag2 = k
                        allData[allCount].lv   = 2
                        allData[allCount].gemid= v.pearl_id
                        allData[allCount].make = v.goods_make
                        local node = _G.Cfg.goods[v.pearl_id]
                        local name = v.pearl_id
                        if node~=nil then
                            name = node.name
                        end
                        allData[allCount].name = name
                    end
                end 
                print("----d-fdfd444444-",m_thirdNode.small_name)
                --第三层结束----------------------------------------------------------------

                -- --第二层按钮(剩下部分)
                -- if _second+1<=secondCount then
                --   for i=_second+1,secondCount do
                --       allCount=allCount+1
                --       allData[allCount]      = {}
                --       allData[allCount].name = secondNode[i].small_name
                --       allData[allCount].no   = allCount
                --       allData[allCount].tag1 = _root
                --       allData[allCount].tag2 = i
                --       allData[allCount].lv   = 2
                --       allData[allCount].gemid= nil
                --       allData[allCount].make = nil 

                --   end  
                -- end 

           --  elseif _second==nil and secondCount>0  then --即只按了第一层的按钮
           --      --只有次父级按钮 即第二层全部按钮
           --      for i=1,secondCount do
           --          allCount=allCount+1
           --          allData[allCount]      = {}
           --          allData[allCount].name = secondNode[i].small_name
           --          allData[allCount].no   = allCount
           --          allData[allCount].tag1 = _root
           --          allData[allCount].tag2 = i
           --          allData[allCount].lv   = 2
           --          allData[allCount].gemid= nil
           --          allData[allCount].make = nil 

           --      end
           -- end
        -- end
        --第二层结束----------------------------------------------------------------
        --第一层按钮(剩下部分)
        if _root+1<=rootCount then
            for i=_root+1,rootCount do
                allCount=allCount+1
                allData[allCount]      = {}
                allData[allCount].name = rootNode[i].big_name
                allData[allCount].no   = allCount
                allData[allCount].tag1 = i
                allData[allCount].tag2 = nil
                allData[allCount].lv   = 1
                allData[allCount].gemid= nil
                allData[allCount].make = nil 
            end  
        end 
    else
        --只有父级按钮 即第一层全部按钮
        for i=1,rootCount do
            allCount=allCount+1
            allData[allCount]      = {}
            allData[allCount].name = rootNode[i].big_name
            allData[allCount].no   = allCount
            allData[allCount].tag1 = i
            allData[allCount].tag2 = nil
            allData[allCount].lv   = 1
            allData[allCount].gemid= nil
            allData[allCount].make = nil 
        end         
    end

    --------------------------------------------------------------------------------------------
    --全空是默认都不按任意一个父级按钮
    local innerHeight=ONEHEIGHT*allCount
    local pageViewSize=cc.size(self.m_leftSprSize.width-6,self.m_leftSprSize.height-14)
    if innerHeight<pageViewSize.height then
      innerHeight=pageViewSize.height
    end
    local innerViewSize=cc.size(pageViewSize.width,innerHeight)
    local nOffHeight=innerHeight-pageViewSize.height
    local nnnn=_root or 0
    local mmmm=(nnnn-1)*ONEHEIGHT

    if mmmm>0 then
      print("BBBBBBBBBB  1>>>>>>>>",nnnn,mmmm,nOffHeight)
      nOffHeight=nOffHeight-mmmm
      nOffHeight=nOffHeight>=0 and nOffHeight or 0
      print("BBBBBBBBBB  2>>>>>>>>",nOffHeight)
    end

    -- nOffHeight=nOffHeight>preOffHieght and nOffHeight or preOffHieght

    local pageView = cc.ScrollView:create()
    -- pageView:setBounceable(false)
    pageView:setTouchEnabled(true)
    pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    pageView:setContentSize(innerViewSize)  
    pageView:setViewSize(pageViewSize) 
    pageView:setPosition(cc.p(3,7))     
    pageView:setContentOffset(cc.p(0,-nOffHeight)) -- 设置初始位置
    self.m_leftSpr:addChild(pageView)
    self.m_leftScrollView=pageView
    self.m_barView=require("mod.general.ScrollBar")(pageView)
    self.m_barView:setPosOff(cc.p(-5,0))

    local function l_btnCallBack(sender, eventType)
        self:__onbtnCallBack(sender, eventType)
    end

    local nFontSize=FONT_SIZE+4
    for i=1,allCount do
        local oneData=allData[i]
        local rootbtn=gc.CButton:create()
        rootbtn:setTag(i)
        rootbtn:setSwallowTouches(false)
        rootbtn:addTouchEventListener(l_btnCallBack)
        pageView:addChild(rootbtn)
        oneData.btn=rootbtn  

        local floorLv=oneData.lv
        local nTag1=oneData.tag1
        local nTag2=oneData.tag2
        local fontsize=24
        local labColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN)
        if floorLv==1 then
            rootbtn:loadTextures("general_title_one.png")
            local btnsize=rootbtn:getContentSize()

            if self.m_floorCountArray[nTag1].count>0 then
                self:__addHeChengNoticSpr(rootbtn,floorLv)
            end

            local iconSprite=cc.Sprite:createWithSpriteFrameName("general_down.png")
            iconSprite:setScale(188/220)
            iconSprite:setRotation(-90)
            iconSprite:setPosition(25,32)
            rootbtn:addChild(iconSprite)

            fontsize=24
            labColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN)

            if allData[i+1]~=nil and allData[i+1].lv==2 then
                iconSprite:setRotation(0)
                rootbtn:loadTextures("general_title_two.png")
            end

        -- elseif floorLv==2 then
        --     rootbtn:loadTextures("general_title_two.png")
        --     rootbtn:setTitleFontSize(nFontSize-2)
        --     local btnsize=rootbtn:getContentSize()
        --     -- rootbtn:setScaleX(205/btnsize.width)
        --     -- rootbtn:setScaleY(40/btnsize.height)
            
        --     local iconSprite=cc.Sprite:createWithSpriteFrameName("general_down.png")
        --     iconSprite:setScale(188/220*0.8)
        --     iconSprite:setRotation(-90)
        --     iconSprite:setPosition(25,26)
        --     rootbtn:addChild(iconSprite)
            
        --     if self.m_floorCountArray[nTag1][nTag2]>0 then
        --         self:__addHeChengNoticSpr(rootbtn,floorLv)
        --     end

        --     if allData[i+1]~=nil and allData[i+1].lv==3 then
        --         iconSprite:setRotation(0)
        --     end
        --     rootbtn:setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
        elseif floorLv==2 then
            local goodId=oneData.gemid
            rootbtn:loadTextures("general_btn_pblue.png")
            rootbtn:setTitleFontSize(nFontSize-4)
            local btnsize=rootbtn:getContentSize()
            local compoundCount=self.m_pearDataArray[goodId].canCount
            if compoundCount>0 then
                self:__addHeChengNoticLabel(rootbtn,compoundCount)
            end

            local goodCnf=_G.Cfg.goods[goodId]
            local nColorIdx=goodCnf and goodCnf.name_color or _G.Const.CONST_COLOR_DARKPURPLE
            fontsize=20
            labColor=_G.ColorUtil:getRGBA(nColorIdx)
            rootbtn:setScaleY(50/btnsize.height)
            print("self.oneTru",self.oneTru)
            if self.oneTru==true then
                self:onebtnCallBack(rootbtn,i,allData)
            end
            self.oneTru=false
        end

        local btnSize=rootbtn:getContentSize()
        local lab=_G.Util:createLabel(oneData.name,fontsize)
        lab:setColor(labColor)
        lab:setPosition(btnSize.width/2,btnSize.height/2)
        rootbtn:addChild(lab)

        local posX=pageViewSize.width/2
        local posY=innerHeight-3-(i-0.5)*(ONEHEIGHT)
        rootbtn:setPosition(posX,posY)
        if floorLv==1 then
            if allData[i+1]~=nil and allData[i+1].lv==2 then
                rootbtn:setPosition(posX+3,posY)
            end
        end
        -- rootbtn:setButtonScale(200/188)
    end
    self.m_allData=allData
end

function BagHeChengLayer.onebtnCallBack( self,sender, curNo,_data )
    print("onebtnCallBack",curNo)
    self.m_editbox:setString(1) 
    local nowdata=_data[curNo]
    if nowdata~=nil then
        local tabLv=nowdata.lv 

        if tabLv==2 then
            -- self.m_rightNode:setVisible(true)
            print("--拿到那个物品 ID==",nowdata.gemid or 0,nowdata.make[1][2] )
            self:createscelectSpr(sender)
            self:updateRightPanel(nowdata.gemid,nowdata.make)
            self:setNowGoodId(nowdata.gemid)
            self:setNowheChengData(nowdata.make)
        end
    end
end

function BagHeChengLayer.__addHeChengNoticSpr(self,_btn,_floorLv)
    local btnsize=_btn:getContentSize()
    local tanhaoSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips1.png")
    tanhaoSpr:setPosition(btnsize.width-15, btnsize.height-15)
    tanhaoSpr:setTag(699)
    _btn:addChild(tanhaoSpr)
end
function BagHeChengLayer.__addHeChengNoticLabel(self,_btn,_nCount)
    local btnsize=_btn:getContentSize()

    local tanhaoSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips2.png")
    tanhaoSpr:setPosition(btnsize.width-15, btnsize.height-15)
    tanhaoSpr:setTag(699)
    _btn:addChild(tanhaoSpr)

    local Count = _nCount>9 and "N" or _nCount
    local width = _nCount>9 and 13 or 15
    local countLab=_G.Util:createLabel(Count,FONT_SIZE)
    countLab:setPosition(btnsize.width-width, btnsize.height-17)
    countLab:setTag(799)
    _btn:addChild(countLab)
end

function BagHeChengLayer.__checkAllHeCheng(self)
    local pearArrayCnf=_G.Cfg.pearl_com
    if pearArrayCnf==nil then return end

    local bagGemCountArray={}
    local bagGemArray=_G.GBagProxy:getGemandmaterialist()
    for i=1,#bagGemArray do
        local goodId=bagGemArray[i].goods_id
        if bagGemCountArray[goodId]==nil then
            bagGemCountArray[goodId]={}
            bagGemCountArray[goodId].count=0
            bagGemCountArray[goodId].useArray={}
        end
        bagGemCountArray[goodId].count=bagGemCountArray[goodId].count+bagGemArray[i].goods_num
    end

    local pearDataArray={}
    local floorCountArray={}
    for i=1,#pearArrayCnf do
        local scenedArray=pearArrayCnf[i].talbe
        floorCountArray[i]={}
        floorCountArray[i].count=0
        -- for secondIdx=1,#scenedArray do
            -- floorCountArray[i][secondIdx]=0
            for pearId,data in pairs(pearArrayCnf[i].talbe) do
                local nId=data.goods_make[1][1]
                local nCount=data.goods_make[1][2]

                if bagGemCountArray[nId]==nil then
                    bagGemCountArray[nId]={}
                    bagGemCountArray[nId].count=0
                    bagGemCountArray[nId].useArray={}
                    bagGemCountArray[nId].useArray[pearId]=true
                else
                    bagGemCountArray[nId].useArray[pearId]=true
                end
                local hCount=bagGemCountArray[nId].count
                local cCount=math.floor(hCount/nCount)

                pearDataArray[pearId]={}
                pearDataArray[pearId].goodId=pearId
                pearDataArray[pearId].needId=nId
                pearDataArray[pearId].needCount=nCount
                pearDataArray[pearId].haveCount=hCount
                pearDataArray[pearId].canCount=cCount
                if cCount>0 then
                    floorCountArray[i].count=floorCountArray[i].count+1
                end
            end
            -- if floorCountArray[i][secondIdx]>0 then
                -- floorCountArray[i].count=floorCountArray[i].count+1
            -- end
        -- end
    end

    if self.m_allData~=nil then
        for i=1,#self.m_allData do
            local oneData=self.m_allData[i]
            local floorLv=oneData.lv
            local nTag1=oneData.tag1
            local nTag2=oneData.tag2
            local nBtn=oneData.btn

            local showCount=nil
            local isShowSpr=nil
            if floorLv==1 then
                if floorCountArray[nTag1].count>0 then
                    isShowSpr=true
                else
                    isShowSpr=false
                end
            elseif floorLv==2 then
                local goodId=oneData.gemid
                showCount=pearDataArray[goodId].canCount
            -- elseif floorLv==3 then
            --     local goodId=oneData.gemid
            --     showCount=pearDataArray[goodId].canCount
            end
            if isShowSpr==true then
                if nBtn:getChildByTag(699) then
                    nBtn:getChildByTag(699):setVisible(true)
                else
                    self:__addHeChengNoticSpr(nBtn,floorLv)
                end
            elseif isShowSpr==false then
                if nBtn:getChildByTag(699) then
                    nBtn:getChildByTag(699):setVisible(false)
                end
            elseif showCount~=nil then
                if showCount>0 then
                    if nBtn:getChildByTag(699) then
                        nBtn:getChildByTag(699):setVisible(true)
                        nBtn:getChildByTag(699):setVisible(true)
                        local Count = showCount>9 and "N" or showCount
                        nBtn:getChildByTag(799):setString(Count)
                    else
                        self:__addHeChengNoticLabel(nBtn,showCount)
                    end
                else
                    if nBtn:getChildByTag(699) then
                        nBtn:getChildByTag(699):setVisible(false)
                        nBtn:getChildByTag(799):setVisible(false)
                    end
                end
            end
        end
    end

    self.m_pearDataArray=pearDataArray
    self.m_floorCountArray=floorCountArray
    self.m_bagGemCountArray=bagGemCountArray
end

function BagHeChengLayer.__onbtnCallBack( self,sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        local Position  = sender : getWorldPosition()
        print("__onbtnCallBack-->>",Position.y,winSize.height/2+self.m_rootBgSize.height/2-80,winSize.height/2-self.m_rootBgSize.height/2-25)
        if Position.y>winSize.height/2+self.m_rootBgSize.height/2-80 or Position.y<winSize.height/2-self.m_rootBgSize.height/2-25 then
            return
        end
        local curNo=sender:getTag()

        self.m_editbox:setString(1) 

        local nowdata=self.m_allData[curNo]
        local tabLv=nowdata.lv 

        if tabLv==1 then
          self.scelectBtn = nil
          self.oneTru=true
          -- self.m_rightNode:setVisible(false)
          if self.m_oldBtn.no1==curNo then
              self:__createLeftPanel()
              self.m_oldBtn={}
              return
          end
          print("拿到那个大类准备重新创建",nowdata.tag1)
          self:__createLeftPanel(nowdata.tag1)
          self.m_oldBtn.no1=curNo
          self.m_oldBtn.tag1=nowdata.tag1
        elseif tabLv==2 then
          -- self.m_rightNode:setVisible(true)
          print("--拿到那个物品 ID==",nowdata.gemid or 0,nowdata.make[1][2] )
          self:createscelectSpr(sender)
          self:updateRightPanel(nowdata.gemid,nowdata.make)
          self:setNowGoodId(nowdata.gemid)
          self:setNowheChengData(nowdata.make)
        -- elseif tabLv==3 then
          -- self.m_rightNode:setVisible(true)
        --   print("--拿到那个物品 ID==",nowdata.gemid or 0,nowdata.make[1][2] )
        --   self:createscelectSpr(sender)
        --   self:updateRightPanel(nowdata.gemid,nowdata.make)
        --   self:setNowGoodId(nowdata.gemid)
        --   self:setNowheChengData(nowdata.make)
        end
    end
end

--现在的物品框id
function BagHeChengLayer.setNowGoodId( self,_data )
    self.NowGoodId = _data
end
function BagHeChengLayer.getNowGoodId( self )
    return self.NowGoodId
end
--现在的物品合成数据
function BagHeChengLayer.setNowheChengData( self,_data )
    self.NowheChengData = _data
end
function BagHeChengLayer.getNowheChengData( self )
    return self.NowheChengData
end

function BagHeChengLayer.REQ_MAKE_MAKE_COMPOSE( self,_count )
    local _id = self : getNowGoodId()
    if _id==nil or _id==nil or _count<1 then return end

    local msg = REQ_MAKE_MAKE_COMPOSE()
    msg:setArgs(_id, _count)
    _G.Network:send(msg)
end

function BagHeChengLayer.updatePanelFromSever( self )
  print("准备更新右边的面板")
  local id  =self:getNowGoodId()
  local data=self:getNowheChengData()

  self:__checkAllHeCheng()
  self:updateRightPanel(id,data)

  local oldnum=tonumber(self.m_editbox:getString())  
  if oldnum~=nil and self.m_maxCount<oldnum then
      self.m_editbox:setString(self.m_maxCount)
  end
end


function BagHeChengLayer.updateRightPanel( self,_id,_data )
   local function cFun(sender,eventType)
      if eventType==ccui.TouchEventType.ended then
        local btn_tag=sender:getTag()
        local _pos = sender:getWorldPosition()
        local temp = _G.TipsUtil:createById(btn_tag,nil,_pos)
        cc.Director:getInstance():getRunningScene():addChild(temp,1000)
      end
   end

   self.m_heChengLab:setString("")
   if  self.m_heChengSpr~=nil then
      self.m_heChengSpr:removeFromParent(true)
      self.m_heChengSpr=nil 
   end
   for i=1,4 do
      self.m_materialNameLab[i]  : setString("")
      self.m_materialCountLab[i] : setString("")
      self.m_materialBtn[i]      : setVisible(false)

      if self.m_materialSpr~=nil and  self.m_materialSpr[i]~=nil then
          self.m_materialSpr[i]:removeFromParent(true)
          self.m_materialSpr[i]=nil 
      end
   end

   local gemNode = nil 
   if _id~=nil then
      gemNode=_G.Cfg.goods[_id]
   end
   if gemNode~=nil then 
      local btnSize       = self.m_heChengBgSpr:getContentSize()
      self.m_heChengSpr   = _G.ImageAsyncManager:createGoodsBtn(gemNode,cFun,_id)
      self.m_heChengSpr   : setPosition(btnSize.width/2,btnSize.height/2)
      self.m_heChengBgSpr : addChild(self.m_heChengSpr,3)

      self.m_heChengLab   : setString(gemNode.name)
      self.m_heChengLab   : setColor(_G.ColorUtil:getRGB(gemNode.name_color))
  end

  if _data==nil or _data[1]==nil then return end

  local count=#_data
  if count==1 then
      local goodId=_data[1][1]
      local nCount=_data[1][2]
      local needNode=_G.Cfg.goods[goodId]

      if needNode~=nil then
          local i=2
          self.m_materialBtn[i]:setVisible(true)  
          local btnSize=self.m_materialBtn[i]:getContentSize()
          self.m_materialSpr[i]=_G.ImageAsyncManager:createGoodsBtn(needNode,cFun,goodId)
          self.m_materialSpr[i]:setPosition(btnSize.width/2,btnSize.height/2)
          self.m_materialBtn[i]:addChild(self.m_materialSpr[i])

          self.m_materialNameLab[i]:setString(needNode.name)
          self.m_materialNameLab[i]:setColor(_G.ColorUtil:getRGB(needNode.name_color))

          local hCount=self.m_pearDataArray[_id].haveCount
          local gemNode=_G.Cfg.goods[_id]
          print("self.m_maxCount-->3",gemNode.stack,self.m_pearDataArray[_id].canCount)
          self.m_maxCount=gemNode.stack<self.m_pearDataArray[_id].canCount and gemNode.stack or self.m_pearDataArray[_id].canCount
          self.m_material=self.m_materialCountLab[i]:setString(hCount.."/"..nCount)

          if hCount < nCount then
            self.m_materialCountLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
          else
            self.m_materialCountLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
          end

          print("self.m_maxCount-->1",self.m_maxCount)
          self.m_editbox:setString(self.m_maxCount) 
      end
  elseif count>1 then
      local finalmaxCount=99999 
      for i=1,count do
          local goodId=_data[i][1]
          local nCount=_data[i][2]
          local needNode  = _G.Cfg.goods[goodId]

          if needNode ~=nil then
              self.m_materialBtn[i] : setVisible(true)
              local btnSize = self.m_materialBtn[i] : getContentSize()
              self.m_materialSpr[i]=_G.ImageAsyncManager:createGoodsBtn(needNode,cFun,goodId)
              self.m_materialSpr[i]:setPosition(btnSize.width/2,btnSize.height/2)
              self.m_materialBtn[i]:addChild(self.m_materialSpr[i])

              self.m_materialNameLab[i]:setString(needNode.name)
              self.m_materialNameLab[i]:setColor(_G.ColorUtil:getRGB(needNode.name_color))

              local hCount=self.m_pearDataArray[_id].haveCount
              local maxCount=self.m_pearDataArray[_id].canCount
              if maxCount>0 and maxCount<finalmaxCount then
                finalmaxCount=maxCount
              end

              local gemNode=_G.Cfg.goods[_id]
              if gemNode.stack<maxCount then
                finalmaxCount=gemNode.stack
              end
              self.m_materialCountLab[i]:setString(hCount.."/"..nCount)
          end
      end
      if finalmaxCount~=99999 then
          self.m_maxCount=finalmaxCount
      end
  end
end

function BagHeChengLayer.createscelectSpr(self,_obj )
    if self.scelectBtn~=nil then
        self.scelectBtn : loadTextures("general_btn_pblue.png")
    end

    if _obj==nil then return end

    _obj : loadTextures("general_title_three.png")
    self.scelectBtn = _obj
end

function BagHeChengLayer.__createRightPanel( self )
  --当前属性
  local function local_tipscallback(sender, eventType) 
      if eventType==ccui.TouchEventType.ended then
        print("点击了图片")
      end
  end
  self.m_heChengBgSpr  = cc.Sprite:createWithSpriteFrameName("general_teshu_tubiaokuan.png")
  self.m_heChengBgSpr  : setPosition(cc.p(self.m_rightSprSize.width/2,self.m_rightSprSize.height-105))
  self.m_rightNode      : addChild(self.m_heChengBgSpr)

  local size = self.m_heChengBgSpr : getContentSize ()
  self.m_heChengLab   = _G.Util:createLabel("",FONT_SIZE)
  self.m_heChengLab   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.m_heChengLab   : setPosition(size.width/2,size.height+20)
  self.m_heChengBgSpr : addChild(self.m_heChengLab)

  local m_lineSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  local lHeight       = m_lineSpr:getContentSize().height
  m_lineSpr           : setPreferredSize( cc.size(self.m_rightSprSize.width-30,lHeight ))
  -- m_lineSpr           : setScaleX(1.5)
  self.m_rightNode    : addChild(m_lineSpr)
  m_lineSpr           : setPosition(self.m_rightSprSize.width/2,self.m_rightSprSize.height/2+60)

  local m_infoLab  = _G.Util:createLabel("所需材料:",FONT_SIZE)
  m_infoLab        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  m_infoLab        : setPosition(95,self.m_rightSprSize.height/2-5)
  self.m_rightNode  : addChild(m_infoLab)

  self.m_materialBtn      = {}
  self.m_materialNameLab  = {}
  self.m_materialCountLab = {}
  self.m_materialSpr      = {}

  for i=1,4 do
      self.m_materialBtn[i] = gc.CButton:create()
      self.m_materialBtn[i] : loadTextures("general_tubiaokuan.png")
      self.m_materialBtn[i] : setVisible(false)  
      self.m_materialBtn[i] : addTouchEventListener(local_tipscallback)
      local oneSize = self.m_materialBtn[i] : getContentSize()
      local m_poX   = self.m_rightSprSize.width/2 + (oneSize.width+15)*(i-2)
      self.m_materialBtn[i] : setPosition(cc.p(m_poX,self.m_rightSprSize.height/2-30))
      self.m_rightNode     : addChild(self.m_materialBtn[i])

      self.m_materialNameLab[i]  = _G.Util:createLabel("",FONT_SIZE)
      self.m_materialNameLab[i]  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
      self.m_materialNameLab[i]  : setPosition(oneSize.width/2,oneSize.height+25)
      self.m_materialBtn[i]      : addChild(self.m_materialNameLab[i])

      self.m_materialCountLab[i]  = _G.Util:createLabel("",FONT_SIZE)
      -- self.m_materialCountLab[i]  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
      self.m_materialCountLab[i]  : setPosition(oneSize.width/2,-20)
      self.m_materialBtn[i]       : addChild(self.m_materialCountLab[i])
  end

  local countLab = _G.Util:createLabel("合成次数:",FONT_SIZE)
  countLab       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  countLab       : setPosition(95,110)
  self.m_rightNode  : addChild(countLab)


  local function local_btncallback(sender, eventType) 
      return self : __eventCallBack(sender, eventType)
  end

  local reduceBtn = gc.CButton:create() 
  reduceBtn  : loadTextures("general_btn_reduce.png")
  reduceBtn  : addTouchEventListener(local_btncallback)
  reduceBtn  : ignoreContentAdaptWithSize(false)
  reduceBtn  : setContentSize(cc.size(80,80))
  reduceBtn  : setTag(self.REDUCE_TAG)   
  --输入框
  local boxSpr1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_input.png" ) 
  local boxSpr1Size = boxSpr1 : getContentSize()
  boxSpr1 : setPreferredSize(cc.size(90,boxSpr1Size.height)) 
  local boxSpr1Size = boxSpr1 : getContentSize()
  local function textFieldEvent(sender, eventType)
      if eventType==ccui.TextFiledEventType.attach_with_ime then
      elseif eventType==ccui.TextFiledEventType.detach_with_ime then
        local num = self.m_editbox : getString()
        print("--textFieldEvent---",num)
        local nums = string.match(num , "%d*")
        print("--textFieldEvent2222---",nums)
        if tostring(num)~=tostring(nums) or tostring(num)=="" then
            print("重新设置")
            self.m_editbox : setString(tostring(0))
            local command = CErrorBoxCommand(8)
            controller : sendCommand( command )
            return
        end
        print("self.m_maxCount",self.m_maxCount)
        if tonumber (nums)>self.m_maxCount then
          nums = tostring(self.m_maxCount)
          if self.m_maxCount==0 then
            nums = 1
          end
          self.m_editbox : setString(tostring(nums))
        end
      elseif eventType==ccui.TextFiledEventType.insert_text then
      end
  end
  self.m_editbox = ccui.TextField:create("",_G.FontName.Heiti,FONT_SIZE)
  -- self.m_editbox : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.m_editbox : setMaxLengthEnabled(true)
  self.m_editbox : setMaxLength(4)
  self.m_editbox : addEventListener(textFieldEvent)
  self.m_editbox : ignoreContentAdaptWithSize(false)
  self.m_editbox : setContentSize(cc.size(boxSpr1Size.width,boxSpr1Size.height))
  self.m_editbox : setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
  self.m_editbox : setString(1) 

  local addBtn  = gc.CButton:create() 
  addBtn  : loadTextures("general_btn_add.png")
  addBtn  : addTouchEventListener(local_btncallback)
  addBtn  : ignoreContentAdaptWithSize(false)
  addBtn  : setContentSize(cc.size(80,80))
  addBtn  : setTag(self.ADD_TAG) 

  local maxButton  = gc.CButton:create() 
  maxButton  : loadTextures("general_max.png")
  maxButton  : addTouchEventListener(local_btncallback)
  maxButton  : ignoreContentAdaptWithSize(false)
  maxButton  : setContentSize(cc.size(80,80))
  maxButton  : setTag(self.MAX_TAG) 

  local heChengBtn  = gc.CButton:create() 
  heChengBtn  : setTitleFontName(_G.FontName.Heiti)
  heChengBtn  : loadTextures(szNormal2)
  heChengBtn  : setTitleText("合 成")
  heChengBtn  : loadTextures("general_btn_gold.png")
  heChengBtn  : addTouchEventListener(local_btncallback)
  --heChengBtn  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  heChengBtn  : setTitleFontSize(FONT_SIZE+4)
  heChengBtn  : setTag(self.HECHENG_TAG) 

  self.m_rightNode : addChild(reduceBtn)
  self.m_rightNode : addChild(boxSpr1)
  self.m_rightNode : addChild(self.m_editbox)
  self.m_rightNode : addChild(addBtn)
  self.m_rightNode : addChild(maxButton)
  self.m_rightNode : addChild(heChengBtn)

  local nPosY = 110 
  local nPosX = 105 
  reduceBtn    : setPosition(self.m_rightSprSize.width/2-100,nPosY)
  boxSpr1      : setPosition(self.m_rightSprSize.width/2,nPosY)
  self.m_editbox : setPosition(self.m_rightSprSize.width/2,nPosY-7)
  addBtn       : setPosition(self.m_rightSprSize.width/2+100,nPosY)
  maxButton    : setPosition(self.m_rightSprSize.width/2+190,nPosY)
  heChengBtn   : setPosition(self.m_rightSprSize.width/2,nPosY-70)

end

function BagHeChengLayer.__eventCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        local TAG_value = sender :getTag()

        if TAG_value==self.MAX_TAG then
           if self.m_maxCount>0 then
             local szMaxNum = tostring(self.m_maxCount)
              self.m_editbox : setString(szMaxNum)
           end
        elseif TAG_value==self.REDUCE_TAG then
          local num =  self.m_editbox : getString() 
          num = string.match(num , "%d*")
          if num==nil then
                self.m_editbox :setString("")
                local command = CErrorBoxCommand(8)
                controller :sendCommand( command )
                return
            end
            num = tonumber( num )

          if num~=nil and num>1 then
            self.m_editbox : setString( tostring(num-1) )
          end

        elseif TAG_value==self.ADD_TAG then
           local num =  self.m_editbox :getString() 
            num = string.match(num , "%d*")
            if num==nil then
                self.m_editbox :setString("")
                local command = CErrorBoxCommand(8)
                controller :sendCommand( command )
                return
            end
            num = tonumber( num )
          if num~=nil and num<self.m_maxCount then
            self.m_editbox : setString( tostring(num+1) )
          end
        elseif TAG_value==self.HECHENG_TAG then
          local buyNum = tonumber( self.m_editbox :getString() )
          local num = string.match(buyNum , "%d*")
          print("self.HECHENG_TAG",buyNum)
          if num==nil then
              self.m_editbox : setString(tostring(self.m_defaultNum))
              local command = CErrorBoxCommand(8)
              controller :sendCommand( command )
              return
          elseif buyNum<=0 then
            local command = CErrorBoxCommand("合成材料不足")
            controller :sendCommand( command )
          end
          num = tonumber( num )

          self : REQ_MAKE_MAKE_COMPOSE(num)
        end  
    end
end

function BagHeChengLayer.HeChengSuccEffect(self)
  print("合成成功特效")
    if self.hechengSuccSpr~=nil then return end
    self.hechengSuccSpr=cc.Sprite:createWithSpriteFrameName("main_effect_word_hc.png")
    self.hechengSuccSpr:setScale(0.05)
    self.hechengSuccSpr:setPosition(0,0)
    -- self.m_container:addChild(self.hechengSuccSpr,1000)
    local sizes          = self.m_heChengBgSpr : getContentSize ()  
    self.m_heChengBgSpr     : addChild(self.hechengSuccSpr,1000)    
    self.hechengSuccSpr : setPosition(sizes.width/4,sizes.height/2)


    local addSpr =  cc.Sprite:createWithSpriteFrameName("main_effect_word_cg1.png") 
    self.hechengSuccSpr : addChild(addSpr)
    local sprsize  = self.hechengSuccSpr : getContentSize()
    local sprsize2 = addSpr : getContentSize()
    addSpr : setPosition(sprsize.width+sprsize2.width/2,sprsize.height/2)

    local function f1()
        self.hechengSuccSpr:removeFromParent(true)
        self.hechengSuccSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
        self.hechengSuccSpr:runAction(action)
    end
    local function f3()
        local szPlist="anim/task_finish.plist"
        local szFram="task_finish_"
        local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.12)
        local act2=cc.CallFunc:create(f2)

        local sprSize=self.hechengSuccSpr:getContentSize()
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(sprSize.width,sprSize.height*0.5)
        effectSpr:runAction(cc.Sequence:create(act1,act2))
        self.hechengSuccSpr:addChild(effectSpr)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    self.hechengSuccSpr:runAction(action)
end

return BagHeChengLayer