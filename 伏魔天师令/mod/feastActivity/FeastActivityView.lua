local FeastActivityView = classGc(view, function(self,_data1)
	self.m_mediator =require("mod.feastActivity.FeastActivityMediator")() 
    self.m_mediator:setView(self)
    self.feastData={} 
    self.feastId = {}
    self.feastdata = {}
    self._feID = _data1 or 1 
end)

local winSize  = cc.Director : getInstance() : getVisibleSize()
local mainSize = cc.size(800, 528)
local rightSize= cc.size(570,450)
local tag_SJ = 61
local tag_ZP = 71
local tag_ZX = 81
local tag_TS = 91

function FeastActivityView.create( self )
	self.m_tabLeftView = require("mod.general.TabLeftView")()
	self.mainLayer=self.m_tabLeftView:create("节日活动") 

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.mainLayer)

	self:initView()
    self:networksend()
	return tempScene
end
function FeastActivityView.initView( self )
	local function closeFun()
		print("关闭节日活动")
        self : unregister()

        if self.tagPanelClass~=nil and self.tagPanelClass[tag_ZP]~=nil then
        	self.tagPanelClass[tag_ZP]:removeRewardScheduler()
        end
        if self.mainLayer == nil then return end
        self.mainLayer=nil
        cc.Director:getInstance():popScene()
	end
	self.m_tabLeftView : addCloseFun(closeFun)

    local activityNode = cc.Node:create()
    activityNode : setAnchorPoint(0,0)
	activityNode : setPosition(winSize.width*0.5,winSize.height*0.5)
	self.mainLayer : addChild(activityNode)

	self.rightdown = ccui.Widget:create()
	self.rightdown : setContentSize( rightSize )
	self.rightdown : setPosition(105,-20)
	activityNode : addChild(self.rightdown)
end

function FeastActivityView.LeftBtnView( self,count,msg )
	local function tabOfFun(tag)
		self : tabOperate(tag,msg)
	end
	self.m_tabLeftView : addTabFun(tabOfFun)
	self.leftBtn = {}
	self.tagContainer = {}
	self.tagPanel = {}
	self.tagPanelClass = {}
	for k,v in pairs(msg) do
		self.feastId[k] = v.id
		self.feastdata[v.id] = v
		local BtnA = _G.Cfg.gala_total[v.id].a
		self.m_tabLeftView : addTabButton(BtnA.tag, v.id)
		self.leftBtn[v.id] = self.m_tabLeftView:getObjByTag(v.id)

		self.tagContainer[v.id] = cc.Node:create()
    	self.rightdown : addChild(self.tagContainer[v.id])
	end

	-- 默认页面
    print("dasdasd",self._feID)
    if self.feastId[self._feID]==nil then
        local command=CErrorBoxCommand("活动未开启")
        controller:sendCommand(command)  
        self._feID=1
    end
	self.m_tabLeftView : selectTagByTag(self.feastId[self._feID])
	self : initViewData(self.feastId[self._feID])
end

function FeastActivityView.tabOperate( self, _tag,msg )
	print("SettingView --- tag --->",_tag,msg)
	for k,v in pairs(msg) do
        if v.id ~= _tag then
            print("self.tagContainer setVisible false----------",v)
            -- self.leftSpr[i] : setSpriteFrame(self.leftimg1[i])
            self.tagContainer[v.id] : setVisible(false)
        else
            print("self.tagContainer setVisible true--------",v)
            -- self.leftSpr[i] : setSpriteFrame(self.leftimg2[i])
            self.tagContainer[v.id] : setVisible(true)
            self : initViewData(v.id)
        end
    end
end

function FeastActivityView.initViewData( self,_tag )
    if _tag==nil then return end 
	local floorID = math.floor(_tag/10)
  	if self.tagPanel[floorID] == nil then
    	print("创建 panel type visible",floorID)
    	local view = nil
        if floorID == tag_SJ then
            view = require "mod.feastActivity.YZQJActivityView"()
    	elseif floorID == tag_ZP then
            view = require "mod.feastActivity.DZPActivityView"()
    	elseif floorID == tag_ZX then
    		view = require "mod.feastActivity.ZXJLActivityView"()
        elseif floorID == tag_TS then
            view = require "mod.feastActivity.TSLXActivityView"()
    	end
    	if view == nil then return end
    	
    	self.tagPanelClass[floorID] = view
    	self.tagPanel[floorID] = view : create (_tag,self.feastdata[_tag])

    	self.tagContainer[_tag] : addChild(self.tagPanel[floorID])
    	self.tagContainer[_tag] : setVisible(true)     
  	end
end

function FeastActivityView.setDZPData( self,_data )
    print("大转盘数据")
    self.tagPanelClass[tag_ZP]:getDZPdata(_data)
end

function FeastActivityView.DZPRewardData( self,id_sub,type,id )
    print("大转盘获奖数据",id_sub,type,id)
    self.tagPanelClass[tag_ZP]:DZPReward(id_sub,type,id)
end

function FeastActivityView.DZPRankData( self,_data )
    print("大转盘排名")
    self.tagPanelClass[tag_ZP]:DZPRank(_data)
end

function FeastActivityView.FESTIVALOK( self,_id  )
    print("一字千金礼包领取")
    self.tagPanelClass[tag_SJ]:FESTIVALOK(_id)
    _G.Util:playAudioEffect("ui_receive_awards")
end

function FeastActivityView.FESTIVALOPEN( self,_id )
    print("一字千金礼包购买")
    self.tagPanelClass[tag_SJ]:FESTIVALOPEN(_id)
    _G.Util:playAudioEffect("ui_receive_awards")
end

function FeastActivityView.YZQJCOLLECT( self,count,packslist )
    print("一字千金礼包数据")
    self.tagPanelClass[tag_SJ]:YZQJCOLLECT(packslist)
end

function FeastActivityView.LoginReply( self,_data )
    print("登录奖励数据")
    self.tagPanelClass[tag_ZX]:LoginReply(_data)
end

function FeastActivityView.LoginReward( self )
    print("登录奖励领取返回")
    self.tagPanelClass[tag_ZX]:LoginReward()
    _G.Util:playAudioEffect("ui_receive_awards")
end

function FeastActivityView.networksend( self )   -- 大转盘面板请求
    print("发送节日节日活动请求")
    local msg = REQ_GALATURN_OPEN()
    _G.Network :send(msg)  
end

function FeastActivityView.ReturnTimes(self, count, msg)
    for k,v in pairs(msg) do
        print("ReturnTimes-->>",v.id,v.times)
        self.m_tabLeftView : setTagIconNum(v.id,v.times)
    end
end

function FeastActivityView.COPY_TIME( self,_data )
    print("铜钱副本挑战次数")
    self.tagPanelClass[tag_TS]:COPY_TIME(_data)
end
 
function FeastActivityView.unregister( self )
   self.m_mediator : destroy()
   self.m_mediator = nil 
end

return FeastActivityView