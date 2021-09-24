local RebateView = classGc(view, function(self)
	self.pMediator = require("mod.rebate.RebateMediator")()
    self.pMediator : setView(self)

    self.rebateData= {}
    self.teamData  = {}
    self.ranksData = {}
    self.teamId = {}
end)

local FONTSIZE= 20
local winSize  = cc.Director : getInstance() : getVisibleSize()
local id_tag = 0

function RebateView.create(self)
	self.rebateView = require("mod.general.TabLeftView")()
	self.m_rootLayer= self.rebateView : create("精彩活动")

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	local function closeCallBack()
		print("关闭精彩活动")
		self:CloseWindow()
        self:removeScheduler(id_tag)
	end
	self.rebateView : addCloseFun(closeCallBack)

  	self : ranknetwork()
  	self : networksend()
  	self : initView()
	return tempScene
end

function RebateView.networksend( self )
    local msg = REQ_ART_CONSUME()
    _G.Network : send( msg)
end

function RebateView.ranknetwork( self )
	local msg = REQ_ART_FULL()
	_G.Network : send( msg)
end

function RebateView.pushData( self, count, msg )
	self.rebateData={}
	for k,v in pairs(msg) do
		print("活动id",k,v.id,v.start,v.endtime,v.count,v.msg2)
		self.teamData[v.id] = v
		local str = tostring(v.id)
		local newStr = string.sub(str,1,2)
		local m_id = tonumber(newStr)
		print("<新id>:",m_id)
		self.rebateData[m_id] = v
	end

	local m_msg = REQ_ART_ICON_TIME()
    _G.Network : send( m_msg)

	self : LeftBtnView(count,msg)
end

function RebateView.rankData( self,msg )
	print("paihangpaihang",msg)
	for k,v in pairs(msg) do
		-- print("排名id",k,v.id,v.selfrank,v.start,v.endtime,v.count,v.msg)
		self.ranksData[v.id] = v
	end
end

function RebateView.iconData( self, count, msg )
	for k,v in pairs(msg) do
		self.rebateView : setTagIconNum(v.id,v.count)
	end
end

function RebateView.initView( self )
	print("创建界面",self.rebateView,self.m_rootLayer)
	self.rebateNode = cc.Node:create()
	self.rebateNode : setPosition(winSize.width*0.5,winSize.height*0.5)
	self.m_rootLayer : addChild(self.rebateNode,10)

	self.rightup = _G.ImageAsyncManager:createNormalSpr("ui/bg/rebate_logo1.png")
    self.rightup : setVisible(false)
	self.rightup : setPosition(110,170)
	self.rebateNode : addChild(self.rightup)
end

function RebateView.LeftBtnView( self,count,msg )
    print("LeftBtnView",count,msg)
	local function tabOfFun(tag)
        self : removeScheduler(id_tag)
		self : tabOperate(tag,msg)
        id_tag = tag
	end
	self.rebateView : addTabFun(tabOfFun)
	self.leftBtn = {}
	self.tagContainer = {}
	self.tagPanel = {}
	self.tagPanelClass = {}
	for k,v in pairs(msg) do
		print("sadasdasda==>",v.id)
		self.teamId[k] = v.id
		self.rebateData[v.id] = _G.Cfg.sales_total[v.id]
		self.rebateView : addTabButton(self.rebateData[v.id].tag, v.id)
		self.leftBtn[v.id] = self.rebateView:getObjByTag(v.id)
		self.tagContainer[v.id] = cc.Node:create()
        self.tagContainer[v.id]:setPosition(-179,139)
    	self.rebateNode : addChild(self.tagContainer[v.id])
	end

	-- 默认页面
	self.rebateView : selectTagByTag(self.teamId[1])
    self : VisibleTrue(self.teamId[1])
	self : initViewData(self.teamId[1])
end

function RebateView.VisibleTrue( self, _tag )
    local _type=_G.Cfg.sales_total[_tag].type
    if _type==21 or _type==23 or _type==25 or _type==35 or _type==36 or _type==37 then
        self.rightup:setVisible(false)
    else
        self.rightup:setVisible(true)
    end
end

function RebateView.tabOperate( self, _tag,msg )
	print("SettingView --- tag --->",_tag,msg)
    self : VisibleTrue(_tag)
	for k,v in pairs(msg) do
        if v.id ~= _tag then
            print("self.tagContainer setVisible false----------",v)
            self.tagContainer[v.id] : setVisible(false)
        else
            print("self.tagContainer setVisible true--------",v)
            self.tagContainer[v.id] : setVisible(true)
            self : initViewData(v.id)
        end
    end
end

function RebateView.initViewData( self,_tag )
    if _tag==nil then return end
  	if self.tagPanel[_tag] == nil then
    	local view = nil
        local m_tag=self.rebateData[_tag].type
        print("创建 panel type visible",_tag,m_tag)
    	if m_tag == 11 then
    		view = require "mod.rebate.DBCZRebateView"(self.rebateData[11])
    	elseif m_tag == 12 then
    		view = require "mod.rebate.LJCZRebateView"(self.rebateData[12])
    	elseif m_tag == 13 then
    		view = require "mod.rebate.MRCZRebateView"(self.rebateData[13])
    	elseif m_tag == 14 then
    		view = require "mod.rebate.CZPHRebateView"(self.rebateData[14])
    	elseif m_tag == 15 then
    		view = require "mod.rebate.QFXFRebateView"(self.rebateData[15])
    	elseif m_tag == 16 then
    		view = require "mod.rebate.LJXFRebateView"(self.rebateData[16])
    	elseif m_tag == 17 then
    		view = require "mod.rebate.MRXFRebateView"(self.rebateData[17])
    	elseif m_tag == 18 then
    		view = require "mod.rebate.XFPHRebateView"(self.rebateData[18])
    	elseif m_tag == 19 then
    		view = require "mod.rebate.TTHLRebateView"(self.rebateData[19])
    	elseif m_tag == 21 then
    		view = require "mod.rebate.CZFLRebateView"(self.rebateData[21])
        elseif m_tag == 22 then
            view = require "mod.rebate.HHQDRebateView"(self.rebateData[22])
        elseif m_tag == 23 then
            view = require "mod.rebate.YXBDRebateView"(self.rebateData[23])
        elseif m_tag == 24 then
            view = require "mod.rebate.FZWMRebateView"(self.rebateData[24])
        elseif m_tag == 25 then
            self.grabid=_tag
            view = require "mod.rebate.GrabRedView"()     		
    	elseif m_tag == 31 then
    		view = require "mod.rebate.CZFLRebateView"(self.rebateData[31])
    	elseif m_tag == 32 then
    		view = require "mod.rebate.ZSWWRebateView"(self.rebateData[32])
    	elseif m_tag == 33 then
    		view = require "mod.rebate.JJPHRebateView"(self.rebateData[33])
    	elseif m_tag == 34 then
    		view = require "mod.rebate.ZLPHRebateView"()
        elseif m_tag == 35 then
            view = require "mod.rebate.CZFLRebateView"(self.rebateData[35])
        elseif m_tag == 36 then
            view = require "mod.rebate.CZFLRebateView"(self.rebateData[36])
        elseif m_tag == 37 then
            self.shopid=_tag
            view = require "mod.rebate.TimeShopView"()
        elseif m_tag == 38 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[38])
        elseif m_tag == 39 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[39])
        elseif m_tag == 40 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[40])
        elseif m_tag == 41 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[41])
        elseif m_tag == 42 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[42])
        elseif m_tag == 43 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[43])
        elseif m_tag == 44 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[44])
        elseif m_tag == 45 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[45])
        elseif m_tag == 46 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[46])
        elseif m_tag == 47 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[47])
        elseif m_tag == 48 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[48])
        elseif m_tag == 49 then
            view = require "mod.rebate.FBSBRebateView"(self.rebateData[49])
        elseif m_tag == 50 then
            view = require "mod.rebate.FHZPRebateView"()
        elseif m_tag == 51 then
            view = require "mod.rebate.NFZPRebateView"()
        elseif m_tag == 61 or m_tag == 62 or m_tag == 63 then
            view = require "mod.rebate.FCFLRebateView"(self.rebateData[m_tag])
    	end

    	if view == nil then return end
    	
        id_tag = _tag
    	self.tagPanelClass[_tag] = view
    	if self.ranksData[_tag]~=nil and _tag == self.ranksData[_tag].id  then
    		print("self.ranksData",self.ranksData[_tag].id )
    		self.tagPanel[_tag] = view : create (_tag,self.ranksData[_tag])
    	else
    		self.tagPanel[_tag] = view : create (_tag,self.teamData[_tag])
    	end

    	self.tagContainer[_tag] : addChild(self.tagPanel[_tag])
    	self.tagContainer[_tag] : setVisible(true)       
  	end
end

function RebateView.ART_FZTX_CB( self, _data )
    print("ART_FZTX_CB--->>>",_data.id,_data.count,_data.msg)

    self.tagPanelClass[_data.id] : fzwmData(_data)
end

function RebateView.ART_GET_FZTX_CB( self, _data )
    print("ART_GET_FZTX_CB--->>>",_data.id,_data.idsub,_data.viplv,_data.times)

    self.tagPanelClass[_data.id] : fzwmReturnReward(_data.idx,_data.times)
end

function RebateView.ART_GET_FZTX_CB( self, _data )
    print("ART_GET_FZTX_CB--->>>",_data.id,_data.idsub,_data.viplv,_data.times)

    self.tagPanelClass[_data.id] : fzwmReturnReward(_data.idx,_data.times)
end

function RebateView.FHZPData( self, _data )
    print("放回转盘数据",_data.id,_data.count)
    self.tagPanelClass[_data.id] : FHZPData(_data)
end

function RebateView.ZPRewardData( self, _data )
    print("放回一次抽奖",_data.id)
    self.tagPanelClass[_data.id] : runRewardAction(_data.idx,1)
end

function RebateView.FCRewardReturn( self, _type )
    print("领取奖励成功",_type)
    self.tagPanelClass[_type] : SuccessReward()
end

function RebateView.FHZPTenData( self, _data )
    print("放回十次抽奖",_data.id)
    for k,v in pairs(_data.msg) do
        print("DDDDDDD",v.idx,k)
        self.tagPanelClass[_data.id] : FHZPTenData(v.idx, k)
    end
end

function RebateView.NFZPData( self, _data )
    print("不放回数据",_data.id,_data.count)
    self.tagPanelClass[_data.id] : NFZPData(_data)
end

-- function RebateView.NFZPReward( self, _data )
--     print("不放回抽奖",_data.id)
--     self.tagPanelClass[_data.id] : runRewardAction(_data.idx)
-- end

function RebateView.GrabData( self, _data )
    print("抢红包数据",self.grabid)
	self.tagPanelClass[self.grabid] : GrabData(_data)
end

function RebateView.GrabShop( self )
    print("抢红包数据",self.grabid)
    self.tagPanelClass[self.grabid] : SHOP_BUY_SUCC()
end

function RebateView.TimeShopData( self, _data )
    print("开服商城数据",self.shopid)
    self.tagPanelClass[self.shopid] : TimeShopData(_data)
end

function RebateView.TimeShopBuyReturn( self )
    print("开服商城数据",self.shopid)
    self.tagPanelClass[self.shopid] : SHOP_BUY_SUCC()
end

function RebateView.fullData( self, id, id_sub, state,_num )
    print("领取后返回",id,id_sub,state,self.rebateData[id].type)
    self.tagPanelClass[id] : tagfullData(id_sub, state, _num)
    local m_msg = REQ_ART_ICON_TIME()
    _G.Network : send( m_msg)
    -- _G.Util:playAudioEffect("ui_receive_awards")
    if self.rebateData[id].type~=23 then
        _G.Util:playAudioEffect("ui_wealth_money")
    end
end

function RebateView.removeScheduler( self, id)
    print("关闭计时器",id)
    if id==0 then return end
    self.tagPanelClass[id] : __removeScheduler()
end

function RebateView.CloseWindow(self)
    if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
   	self : unregister()
    if self.tagPanelClass~=nil then
        for k,view in pairs(self.tagPanelClass) do
            if view.unregister then
                view:unregister()
            end
            if view.__removeScheduler then
                view:__removeScheduler()
            end
            if view.removeAllRewardScheduler then
                view:removeAllRewardScheduler()
            end
        end
    end

	cc.Director:getInstance():popScene()
end

function RebateView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return RebateView