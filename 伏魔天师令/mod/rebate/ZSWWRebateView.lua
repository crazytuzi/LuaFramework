local ZSWWRebateView = classGc(view, function(self,_msg)
	self.msg =_msg
end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 20
local R_ROWNO	= 3 --列数
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78)

function ZSWWRebateView.create(self,tag,_data)
    local endtime = self : getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""
    print("----->>data",_data.endtime,_data.count,tag)
	self.m_container = cc.Node:create() 

	local rebateStr= _G.Util : createLabel("第一门派额外奖励", FONTSIZE+6)
    rebateStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    rebateStr : setPosition(rightSize.width/2-21, 50)
    self.m_container : addChild(rebateStr)
    
    local timeLab= _G.Util : createLabel("活动时间：", FONTSIZE)
    -- timeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    timeLab : setPosition(35, 13)
    self.m_container : addChild(timeLab)

    local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
    endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    endTimeLab  : setPosition(90, 13)
    endTimeLab  : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(endTimeLab)

    local explainStr= _G.Util : createLabel("说明：", FONTSIZE)
    -- explainStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    explainStr : setPosition(20, -40)
    self.m_container : addChild(explainStr)

    local explainLab= _G.Util : createLabel("活动期间，每天的第一门派可以获得以下奖励，奖励在活动结算后通过邮件发放。", FONTSIZE)
    -- explainLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    explainLab : setPosition(45, -57)
    explainLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	explainLab : setDimensions(rightSize.width-90, 60)
	explainLab : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(explainLab)

    local awardStr= _G.Util : createLabel("奖励：", FONTSIZE)
    -- awardStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    awardStr : setPosition(20, -190)
    self.m_container : addChild(awardStr)

    local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    floorSpr:setContentSize(cc.size(375,100))
    floorSpr:setPosition(rightSize.width/2-65,-250)
    self.m_container : addChild(floorSpr)

	local roleBg = {1,2,3}
	local function roleCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local role_tag = sender : getTag()
            local Position = sender : getWorldPosition() 
            print("－－－－选中role_tag:", role_tag)
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    local icondata = nil
    for k,v in pairs(self.msg.msg2) do
        --if v.id == tag then
            --print("subCfgsubCfg",v.id,v.id_sub)
            local tab = {}
            for i=1,#v.msg do
            	tab[i]={v.msg[i].id,v.msg[i].num}
            end
            icondata = tab
        --end
    end

	for j=1, 3 do
        roleBg[j] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        roleBg[j] : setPosition(cc.p(132+(j-1)*(iconSize.width+35), -250))
        self.m_container : addChild(roleBg[j])

        if icondata~=nil and icondata[j] ~= nil then
            print("请求物品图片", icondata[j][1])
            local goodId      = icondata[j][1]
            local goodCount   = icondata[j][2]
            local goodsdata   = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
                iconSpr       : setSwallowTouches(false)
                iconSpr       : setPosition(iconSize.width/2, iconSize.height/2)
                roleBg[j]     : addChild(iconSpr)
            end
        end
    end

    return self.m_container
end

function ZSWWRebateView.getTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min
    print("endtime",time)

    return time
end

function ZSWWRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return ZSWWRebateView