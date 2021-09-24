local ZhaoCaiMediator = classGc(mediator,function(self, _view)
	-- here??
	self.name = "ZhaoCaiMediator"
	self.view = _view
	self:regSelf() 
end)

ZhaoCaiMediator.protocolsList = {
   _G.Msg.ACK_WEAGOD_REPLY,           --财神面板（32020） 
   _G.Msg.ACK_WEAGOD_WEAGOD_R_MSG,    --招财信息块（32025）
   _G.Msg.ACK_WEAGOD_SUCCESS,         --招财成功返回（32060）  
   _G.Msg.ACK_ART_HOLIDAY,           --[16725]精彩活动节日奖励翻倍     
}


function ZhaoCaiMediator.ACK_WEAGOD_REPLY( self, _ackMsg )
	print("32020-get-->",_ackMsg)
	local data1     = {}
    data1.free_time = _ackMsg.free_time  -- 剩余免费招财次数
    data1.times     = _ackMsg.times      -- 总剩余次数
    data1.max_times = _ackMsg.max_times  -- 总次数（vip次数+免费次数）
    data1.gold      = _ackMsg.gold       -- 单倍金钱数
    data1.count     = _ackMsg.count      -- 信息块数量
    -- self:ACK_WEAGOD_WEAGOD_R_MSG(_ackMsg.data) 
    self:getView():setLeftTime(data1.times ,data1.max_times) -- 设置（剩余次数/总次数）   
    self:getView():setleaveTimes(data1.times)   -- 剩余招财次数
    if self.zhaocaiType==nil then
        self:getView():setRecordMsg(_ackMsg.data)
    end
    
    if self.zhaocaiType==1 then
        self:getView():gainOneTongqian(_ackMsg.data)
        print("倍数,铜钱树",_ackMsg.data[1].adds,_ackMsg.data[1].gold)
    end
    if self.zhaocaiType==2 then
        print("不应该到这里")
        self:getView():gainTenTongqian(_ackMsg.data)
    end
end

function ZhaoCaiMediator.ACK_ART_HOLIDAY( self,_ackMsg)
    self:getView():isDouble(_ackMsg.value)
end

function ZhaoCaiMediator.ACK_WEAGOD_SUCCESS( self,_ackMsg )
    self:getView():Net_GetMoney( _ackMsg.type )
	-- body
    print("还是这里先",self.zhaocaiType)
	self.zhaocaiType=_ackMsg.type
    local function voice( )
       _G.Util:playAudioEffect("ui_wealth_money")
    end

    if _ackMsg.type == 1 then
        _G.Util:playAudioEffect("ui_wealth_money")
    elseif _ackMsg.type == 2 then
        local node = cc.Node : create()
        cc.Director:getInstance():getRunningScene():addChild(node)
        node : runAction( cc.Sequence:create( cc.CallFunc:create( voice ), cc.DelayTime:create(0.2), cc.CallFunc:create( voice ), cc.DelayTime:create(0.2), cc.CallFunc:create( voice ), 
            cc.DelayTime:create(0.2), cc.CallFunc:create( voice ), cc.DelayTime:create(0.2), cc.CallFunc:create( voice )) )
        
    end

end

return ZhaoCaiMediator