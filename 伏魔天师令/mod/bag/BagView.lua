local BagView = classGc(view,function(self,_pageno,_numbtn)
    print("_pageno",_pageno,_numbtn)
    self.m_panelType = _pageno or 1
    self.numberBtn=_numbtn
end)

local TAG_PROPS = 1
local TAG_GEM   = 2
local TAG_EQUIP = 3
local TAG_BUY   = 4
local TAG_ALLOY = 5
local m_winSize= cc.Director:getInstance():getWinSize()

function BagView.create(self)
    self.m_bagView=require("mod.general.TabUpView")()
    self.m_rootlayer=self.m_bagView:create("背 包",true)

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootlayer)

    self:__init()

    _G.Util:playAudioEffect("ui_bag_open")

    return tempScene
end

function BagView.__init( self )
    self.di2kuanSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    self.di2kuanSpr:setPreferredSize(cc.size(847,442))
    self.di2kuanSpr:setPosition(m_winSize.width/2,290)
    self.m_rootlayer:addChild(self.di2kuanSpr)

    self:register()
    self:__initView()
end

function BagView.register(self)
    self.pMediator=require("mod.bag.BagMediator")()
    self.pMediator:setView(self)
end
function BagView.unregister(self)
    self.pMediator:destroy()
    self.pMediator=nil 
end

function BagView.__initView(self)
    local function closeFun()
        self:closeViewByCommand()
    end

    local function tabBtnCallBack(tag)
        self:tabOperate(tag)
    end
    self.m_bagView:addCloseFun(closeFun)
    self.m_bagView:addTabFun(tabBtnCallBack)
    -- self.m_bagView:showUpRightSpr()

    self.m_bagView:addTabButton("道  具",TAG_PROPS)
    self.m_bagView:addTabButton("宝  石",TAG_GEM)
    self.m_bagView:addTabButton("饰  品",TAG_EQUIP)
    self.m_bagView:addTabButton("购  回",TAG_BUY)
    self.m_bagView:addTabButton("合  成",TAG_ALLOY)
    
    local signArray=_G.GOpenProxy:getSysSignArray()
    if signArray[_G.Const.CONST_FUNC_OPEN_BAG_COMPOSE] then
      self.m_bagView:addSignSprite(TAG_ALLOY,_G.Const.CONST_FUNC_OPEN_BAG_COMPOSE)
    end

    local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_BAG)
    if rewardIconCount>0 then
      self.m_bagView:setTagIconNum(self.TAG_ALLOY,rewardIconCount)
    end

    local winSize=cc.Director:getInstance():getVisibleSize()
    self.m_mainContainer=cc.Node:create()
    self.m_mainContainer:setPosition(winSize.width/2,winSize.height/2)
    self.m_rootlayer:addChild(self.m_mainContainer,9)

    --五个容器五个页面
    self.m_tagcontainer ={1,2,3,4,5}
    self.m_tagPanel     ={}
    self.m_tagPanelClass={}   

    local downSize=cc.size(760,395)
    for i=1,5 do
        self.m_tagcontainer[i]=cc.Node:create()
        -- self.m_tagcontainer[i]:setPosition(-downSize.width*0.53,-downSize.height*0.65-3)
        -- self.m_tagcontainer[i]:setPosition(-winSize.width/2,-winSize.height/2)
        self.m_mainContainer:addChild(self.m_tagcontainer[i])
    end

    self.m_bagView:selectTagByTag(self.m_panelType)

    self:initViewData(self.m_panelType,true)
    self:setNowPageTag(self.m_panelType)
    self:tabOperate(self.m_panelType)
end

function BagView.chuangIconNum(self,_sysId,_number)
  if _G.Const.CONST_FUNC_OPEN_BAG==_sysId then
    self.m_bagView:setTagIconNum(self.TAG_ALLOY,_number)
  end
end

function BagView.initViewData( self,_type,_isVisible )
  if self.m_tagPanel[_type]==nil then
      local view = nil 
      if _type<=TAG_BUY then
          view=require "mod.bag.BagPanelLayer"(_type)
      else
          view=require "mod.bag.BagHeChengLayer"(_type,self.numberBtn)
      end

      self.m_tagPanelClass[_type]=view
      self.m_tagPanel[_type]=view:__create()

      self.m_tagcontainer[_type]:addChild(self.m_tagPanel[_type])
      self.m_tagcontainer[_type]:setVisible(_isVisible)
  end
end

function BagView.tabOperate(self,_tag)
  for i=1,5 do
      if i~=_tag then
          self.m_tagcontainer[i]:setVisible(false)
      else
          self.m_tagcontainer[i]:setVisible(true)
          self:initViewData(i,true)
          self:setNowPageTag(i)
          if i==5 then
              self.di2kuanSpr:setPreferredSize(cc.size(847,492))
              self.di2kuanSpr:setPosition(m_winSize.width/2,265)
          else
              self.di2kuanSpr:setPreferredSize(cc.size(847,442))
              self.di2kuanSpr:setPosition(m_winSize.width/2,290)
          end
      end
  end 
end

function BagView.delTagPanelByType( self,_type )
    if self.m_tagPanelClass[_type] ~= nil then
       self.m_tagPanelClass[_type] = nil 
    end

    if self.m_tagPanel[_type] ~= nil then
       self.m_tagPanel[_type] : removeFromParent(true)
       self.m_tagPanel[_type] = nil 
    end
end

function BagView.setNowPageTag(self,_data)
    self.m_NowPageTag = _data
end

function BagView.getNowPageTag(self)
    return self.m_NowPageTag
end

--命令更新背包
function BagView.updateBagData( self )
    local nTag = self : getNowPageTag()
    print("BagView.updateBagData nTag",nTag)
    for i=1,TAG_BUY do
        self:delTagPanelByType(i)
    end 

    for i=1,TAG_BUY do
        if nTag==i and nTag<=TAG_BUY then 
            self:initViewData(i,true)
            self:setNowPageTag(i)
        end
    end
end

function BagView.OpenHeCheng( self )
  self:tabOperate(TAG_ALLOY)
  self.m_bagView:selectTagByTag(TAG_ALLOY)
end


function BagView.closeViewByCommand( self )
    print("BagView.closeViewByCommand")
    self:unregister()
    if self.m_rootlayer==nil then return end
    self.m_rootlayer=nil
    cc.Director:getInstance():popScene()

    _G.Util:playAudioEffect("ui_bag_close")
end

function BagView.heChengOK(self,_isHecheng)
    print("合成成功了,通知一下子页面刷新一下")
    if self.m_tagPanelClass[TAG_ALLOY]~=nil then
        self.m_tagPanelClass[TAG_ALLOY]:updatePanelFromSever()
        if _isHecheng then
            self.m_tagPanelClass[TAG_ALLOY]:HeChengSuccEffect()
        end
    end
    _G.Util:playAudioEffect("ui_compose")
end

function BagView.TransferSuccess(self)
    local szUrl = _G.SysInfo:urlRoleList(_G.GLoginPoxy:getServerId())
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("GET", szUrl)
    print("httpRequestRole->  url="..szUrl)

    local function http_handler()
        _G.Util:hideLoadCir()

        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            response = string.gsub(response,'\\','')
            print("http_handler response="..response)

            local output = json.decode(response,1)
            if output.ref==1 then
                local roleList=output.role_list
        RESTART_GAME(_G.Const.kResetGameTypeChuangRole,roleList)
            else
                _G.Util:showTipsBox(string.format("获取角色列表失败:%s(%d)",output.msg,output.error))
            end
        else
            _G.Util:showTipsBox(string.format("HTTP请求失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status))
        end
    end

    xhrRequest:registerScriptHandler(http_handler)
    xhrRequest:send()

    _G.Util:showLoadCir()
end

return BagView

