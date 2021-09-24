local ZXJLActivityView = classGc(view, function(self)

end)
local rightSize= cc.size(580,456)
local iconSize = cc.size(79,79)
local FONTSIZE = 20

function ZXJLActivityView.create( self, _id, _time )
	print("在线奖励界面")
	self.m_container = cc.Node:create() 

	local logoLab = _G.Util:createLabel("在线奖励",FONTSIZE+10)
	logoLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	logoLab : setPosition(rightSize.width/2,rightSize.height-22)
	self.m_container : addChild(logoLab,1)

	local updoubleSpr = cc.Sprite:create("ui/bg/feast_upbg.png")
	updoubleSpr : setPosition(rightSize.width/2,rightSize.height-42)
    self.m_container:addChild(updoubleSpr)

    local tipsLab = _G.Util:createLabel("说明: 只需在活动时间内登录，即可获得奖励",FONTSIZE)
	-- tipsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
	tipsLab : setAnchorPoint(cc.p(0,0.5))
	tipsLab : setPosition(0,rightSize.height-130)
	self.m_container : addChild(tipsLab)

	local rechargeLab = _G.Util:createLabel("奖励:",FONTSIZE)
	-- rechargeLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	rechargeLab : setPosition(0,rightSize.height/2)
	rechargeLab : setAnchorPoint(cc.p(0,0.5))
	self.m_container : addChild(rechargeLab)

	local goodsbgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	goodsbgSpr:setContentSize(cc.size(430,110))
	goodsbgSpr:setPosition(rightSize.width/2,rightSize.height/2-70)
	self.m_container : addChild(goodsbgSpr)

	local msg = REQ_REWARD_LOGIN_REQUEST()
	_G.Network :send(msg)  

	return self.m_container
end

function ZXJLActivityView.LoginReply( self,_data )
	if _data == nil then return end
	local endTime= self:getTimeStr(_data.end_time) or "2016/5/20 21:00"
    local startTime=self:getTimeStr(_data.start_time) or "2016/5/20 21:00"
	local timestrLab = _G.Util:createLabel("活动时间: ",FONTSIZE)
	-- timestrLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	timestrLab : setPosition(0,rightSize.height-63)
	timestrLab : setAnchorPoint(cc.p(0,0.5))
	self.m_container : addChild(timestrLab)

	local LabWidth=timestrLab:getContentSize().width
	local timeLab = _G.Util:createLabel(string.format("%s-%s",startTime,endTime),FONTSIZE)
	timeLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	timeLab : setPosition(0+LabWidth,rightSize.height-63)
	timeLab : setAnchorPoint(cc.p(0,0.5))
	self.m_container : addChild(timeLab)

	local function cFun(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local role_tag = sender : getTag()
		    local Position = sender : getWorldPosition()
	        if role_tag <= 0 then return end
			local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
		    cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
		end
	end

	local icondata = {}
	for k,v in pairs(_data.m_msg) do
		print("LoginReply",k,v)
		icondata[k] = v
	end
	for i=1,4 do
		local kuangSpr = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		kuangSpr:setPosition(130+(i-1)*105,rightSize.height/2-73)
		self.m_container:addChild(kuangSpr)

		print("icondata",icondata,icondata[i])
		if icondata~=nil and icondata[i]~=nil then
            print("请求物品图片",icondata[i].goods_id)
            local goodId    = icondata[i].goods_id
            local goodCount = icondata[i].count
            local goodsdata = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodId,goodCount)
                iconSpr     : setPosition(iconSize.width/2, iconSize.height/2)
                kuangSpr : addChild(iconSpr)
            end
        end 
	end

	local function onBtnReturn(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
        	print("领取")
        	local msg = REQ_REWARD_LOGIN_GET()
			_G.Network :send(msg)  
        end
    end
    self.gotoBtn=gc.CButton:create("general_btn_gold.png")
    self.gotoBtn:setTitleText("领 取")
    self.gotoBtn:setTitleFontName(_G.FontName.Heiti)
    self.gotoBtn:setTitleFontSize(FONTSIZE+4)
    self.gotoBtn:setPosition(rightSize.width/2,45)
    self.gotoBtn:addTouchEventListener(onBtnReturn)
    self.m_container:addChild(self.gotoBtn)

    -- self.haveSpr=cc.Sprite:createWithSpriteFrameName("main_already.png")
    -- self.haveSpr:setPosition(rightSize.width/2,rightSize.height/2-80)
    -- self.m_container:addChild(self.haveSpr)

    if _data.state~=nil and _data.state==1 then
    	self.gotoBtn:setBright(false)
    	self.gotoBtn:setEnabled(false)
    	self.gotoBtn:setTitleText("已领取")
    else
    	self.gotoBtn:setBright(true)
    	self.gotoBtn:setEnabled(true)
    end
end

function ZXJLActivityView.LoginReward( self )
	self.gotoBtn:setBright(false)
    self.gotoBtn:setEnabled(false)
    self.gotoBtn:setTitleText("已领取")
end

function ZXJLActivityView.getTimeStr( self, _time)
    local time = os.date("*t",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min

    print("nowendtime",time)
    return time
end

return ZXJLActivityView
