local YXBDRebateView = classGc(view, function(self,_msg)
    self.m_rewardScheduler={}
    self.msg = _msg
end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 20
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78)
local turnNum = 0000
local oldone = 0
local oldtwo = 0
local oldthr = 0
local oldfou = 0
local id_tag = 23101

function YXBDRebateView.create(self,tag,_data)
    print("----->>data",_data.endtime,_data.count)
	self.m_container = cc.Node:create() 

    self.rightbg = cc.Sprite : create("ui/bg/rebate_yxbd.jpg")
    self.rightbg : setPosition(rightSize.width/2-21,-181)
    self.m_container : addChild(self.rightbg)

	local rebateStr= _G.Util : createLabel("活动时间：", FONTSIZE)
    -- rebateStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    rebateStr : setPosition(60, rightSize.height-25)
    self.rightbg : addChild(rebateStr)
    
    local endtime = self : getTimeStr(_data.endtime)
    local startime = self : getTimeStr(_data.start) or ""
    if endtime ~= nil then
        local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
        endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
        endTimeLab : setPosition(115, rightSize.height-25)
        endTimeLab : setAnchorPoint(cc.p(0.0,0.5))
        self.rightbg : addChild(endTimeLab)
    end
    -- local action=cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,150),cc.FadeTo:create(0.5,255)))
    -- local leftSpr=cc.Sprite:createWithSpriteFrameName("general_jiantou.png")
    -- leftSpr:setRotation(180)
    -- leftSpr:setPosition(27,rightSize.height/2)
    -- leftSpr : runAction(action:clone())
    -- self.rightbg:addChild(leftSpr,10)

    -- local rightSpr=cc.Sprite:createWithSpriteFrameName("general_jiantou.png")
    -- -- rightSpr:setRotation(180)
    -- rightSpr:setPosition(553,rightSize.height/2)
    -- rightSpr : runAction(action:clone())
    -- self.rightbg:addChild(rightSpr,10)

    self.tipsStr= _G.Util : createLabel("花费", FONTSIZE)
    self.tipsStr : setPosition(160, 25)
    self.tipsStr : setAnchorPoint(cc.p(0,0.5))
    self.rightbg : addChild(self.tipsStr)

    self.awardStr1= _G.Util : createLabel("10", FONTSIZE)
    self.awardStr1: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    self.awardStr1 : setAnchorPoint(cc.p(0,0.5))
    self.rightbg : addChild(self.awardStr1)

    self.tips1Str= _G.Util : createLabel("钻石，至少转出", FONTSIZE)
    self.tips1Str : setAnchorPoint(cc.p(0,0.5))
    self.rightbg : addChild(self.tips1Str)

    self.awardStr2= _G.Util : createLabel("15", FONTSIZE)
    self.awardStr2: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    self.awardStr2 : setAnchorPoint(cc.p(0,0.5))
    self.rightbg : addChild(self.awardStr2)

    self.tips2Str= _G.Util : createLabel("钻石", FONTSIZE)
    self.tips2Str : setAnchorPoint(cc.p(0,0.5))
    self.rightbg : addChild(self.tips2Str)

    local function onButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local widTag = sender:getTag()
            print("点击开始",_data.id,widTag)
            local msg = REQ_ART_CONSUME_GET()
            msg:setArgs(_data.id, widTag)
            _G.Network:send(msg)
        end
    end

    self.drawBtn = gc.CButton : create("general_btn_gold.png")
    self.drawBtn : setTitleText("开 始")
    self.drawBtn : setTitleFontName(_G.FontName.Heiti)
    self.drawBtn : setTitleFontSize(FONTSIZE+6)
    self.drawBtn : setPosition(cc.p(rightSize.width/2, 70))
    self.drawBtn : addTouchEventListener(onButtonCallBack)
    --self.drawBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.rightbg : addChild(self.drawBtn)

    local id_tag = self:DataMsg2(_data.msg2) or 23108
    self.drawBtn : setTag(id_tag)

    local isGameOver=true
    for k,v in pairs(self.msg.msg2) do
        if v.id_sub==id_tag then
            print("jindasdas")
            self.awardStr1:setString(v.value)
            local tab = {}
            for i=1,#v.msg do
            	tab[i]={v.msg[i].id,v.msg[i].num}
            end
            if tab[1][2]<tab[2][2] then
                self.awardStr2:setString(tab[1][2])
            else
                self.awardStr2:setString(tab[2][2])
            end
            local LabWidth = self.tipsStr:getContentSize().width
            self.awardStr1 : setPosition(160+LabWidth, 25)
            LabWidth=LabWidth+self.awardStr1:getContentSize().width
            self.tips1Str : setPosition(160+LabWidth, 25)
            LabWidth = LabWidth+self.tips1Str:getContentSize().width
            self.awardStr2 : setPosition(160+LabWidth, 25)
            LabWidth=LabWidth+self.awardStr2:getContentSize().width
            self.tips2Str : setPosition(160+LabWidth, 25)

            isGameOver=false
        end
    end
    if isGameOver then
        self.awardStr1:setVisible(false)
        self.awardStr2:setVisible(false)
        self.tips1Str:setVisible(false)
        self.tips2Str:setVisible(false)

        local tempLabel = _G.Util : createLabel("本次活动的所有次数已用完", FONTSIZE)
        tempLabel : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
        tempLabel : setPosition(rightSize.width*0.5,25)
        self.rightbg:addChild(tempLabel)
    end

    self : ThereTurnNum()
    return self.m_container
end

function YXBDRebateView.DataMsg2(self,msg2)
    local function sort(m1,m2)
        if m1.id_sub < m2.id_sub then
            -- print("paixu",m1.id_sub,m2.id_sub)
            return true
        end
        return false
    end
    table.sort( msg2, sort )

    local id_sub=23101
    for k,v in pairs(msg2) do
        print("_data.msg2",k,v.id_sub,v.state)
        if v.state==2 then
            self.drawBtn:setEnabled(true)
            self.drawBtn:setBright(true)
            id_sub = v.id_sub
            return id_sub
        elseif v.state==3 then
            self.drawBtn:setEnabled(false)
            self.drawBtn:setBright(false)
        end
    end
end

function YXBDRebateView.ThereTurnNum(self)
    local turnSize = cc.size(130,228)
    self.ScrollView={}
    for i=1, 4 do
        

        self.oneHeight = turnSize.height/2
        self.viewSize = turnSize
        self.containerSize = cc.size(turnSize.width, self.oneHeight*11)
        local ScrollView  = cc.ScrollView : create()
        ScrollView : setViewSize(self.viewSize)
        ScrollView : setContentSize(self.containerSize)
        ScrollView : setPosition(39+(i-1)*139.4, rightSize.height/2-126)
        ScrollView : setTouchEnabled(false)
        self.rightbg : addChild(ScrollView)

        self.ScrollView[i]=ScrollView
        -- local boxSize = cc.size(66,80)
        -- local posX = {-15,boxSize.height+2}
        for j=1,12 do
            local advertBg = cc.Sprite:createWithSpriteFrameName("advert_numbg.png")
            -- advertBg : setContentSize(boxSize)
            advertBg : setPosition(turnSize.width/2, self.containerSize.height-self.oneHeight*(j-1))
            ScrollView : addChild(advertBg)

            local bgSize = advertBg :getContentSize()
            local turnLab = _G.Util : createLabel(j-2, FONTSIZE+70,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORANGE))
            -- turnLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
            turnLab : setPosition(bgSize.width/2, bgSize.height/2)
            turnLab : enableGlow(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORANGE))
            turnLab : disableEffect(10)
            advertBg : addChild(turnLab)
            if j==1 then turnLab:setString(9)
            elseif j==12 then turnLab:setString(0)
            end
        end
        local framSpr = cc.Sprite:createWithSpriteFrameName("rebate_fram.png")
        framSpr:setPosition(104+(i-1)*139.4,rightSize.height/2-10.5)
        self.rightbg : addChild(framSpr)
    end
end

function YXBDRebateView.runRewardAction(self,_idx,_tag,_old,_num)
    print("runRewardAction--->>>",_idx,_tag)
    local curIdx=_old
    local turnTimes=1
    local jiangeTimes=0.05
    local curTims=0
    local stopTims=2
    if _tag==2 then stopTims=3
    elseif _tag==3 then stopTims=4
    elseif _tag==4 then stopTims=5
    end

    cc.Director:getInstance():getEventDispatcher():setEnabled(false)

    local function onFram(_dTimes)
        if jiangeTimes>0 then
            curTims=curTims+_dTimes
            if curTims<jiangeTimes then
                return
            end
            curTims=0
        end
        if turnTimes>stopTims then
            if curIdx==_idx then
                self:removeRewardScheduler(_tag)
                _G.Util:playAudioEffect("ui_gem")
                if _tag==4 then
                    print("id_tagid_tagid_tag",id_tag)
                    if id_tag==0 then
                        self.drawBtn : setEnabled(false)
                        self.drawBtn : setBright(false)
                    else
                        self.drawBtn : setEnabled(true)
                        self.drawBtn : setBright(true)
                    end
                    local command=CErrorBoxCommand({t={ {t=[[获得钻石+]],c=_G.Const.CONST_COLOR_GREEN},
                                            {t=_num,c=_G.Const.CONST_COLOR_GREEN},
                                           }
                                        })
                    _G.controller:sendCommand(command)
                    for k,v in pairs(self.msg.msg2) do
                        if v.id_sub==id_tag then
                            print("id_subid_sub",id_tag)
                            self.awardStr1:setString(v.value)
                            local tab = {}
				            for i=1,#v.msg do
				            	tab[i]={v.msg[i].id,v.msg[i].num}
				            end
                            print("aaaaaaa",tab[1][2],tab[2][2])
                            if tab[1][2]<tab[2][2] then
                                self.awardStr2:setString(tab[1][2])
                            else
                                self.awardStr2:setString(tab[2][2])
                            end
                            local LabWidth = self.tipsStr:getContentSize().width
                            self.awardStr1 : setPosition(160+LabWidth, 25)
                            LabWidth=LabWidth+self.awardStr1:getContentSize().width
                            self.tips1Str : setPosition(160+LabWidth, 25)
                            LabWidth = LabWidth+self.tips1Str:getContentSize().width
                            self.awardStr2 : setPosition(160+LabWidth, 25)
                            LabWidth=LabWidth+self.awardStr2:getContentSize().width
                            self.tips2Str : setPosition(160+LabWidth, 25)
                        end
                    end
                end
                return
            end
        end

        if curIdx==9 then
            curIdx=0
            turnTimes=turnTimes+1
        else
            curIdx=curIdx+1
        end
        self:resetRewardEffectPos(curIdx,_tag)
    end
    self:resetRewardEffectPos(curIdx,_tag)
    self.m_rewardScheduler[_tag]=_G.Scheduler:schedule(onFram,0.2)
end

function YXBDRebateView.resetRewardEffectPos(self,_idx,_tag)
    -- print("resetRewardEffectPos",_idx)
    self.ScrollView[_tag]:setContentOffsetInDuration( cc.p( 0, -(9-_idx)*self.oneHeight),0.2)
    if _tag==4 then
        _G.Util:playAudioEffect("Dong")
    end
end

function YXBDRebateView.removeRewardScheduler(self,_tag)
    print("removeRewardScheduler-->",_tag)
    if self.m_rewardScheduler[_tag]~=nil then
        _G.Scheduler:unschedule(self.m_rewardScheduler[_tag])
        self.m_rewardScheduler[_tag]=nil
    end
    if not next(self.m_rewardScheduler) then
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
    end
end
function YXBDRebateView.removeAllRewardScheduler(self)
    for k,v in pairs(self.m_rewardScheduler) do
        _G.Scheduler:unschedule(v)
    end
    self.m_rewardScheduler={}
end

function YXBDRebateView.tagfullData(self,id_sub, state,_num)
    print("刷新",id_sub,state,_num)
    if _num~=nil then turnNum=_num end
    
    self.drawBtn : setEnabled(false)
    self.drawBtn : setBright(false)
    self.drawBtn : setTag(id_sub)
    id_tag = id_sub
    local oneNum = math.floor(turnNum/1000)
    local twoNum = math.floor(math.fmod(turnNum,1000)/100)
    local threeNum = math.floor(math.fmod(turnNum,100)/10)
    local fourNum = math.fmod(turnNum,10)
    print("数值one、two、three、four",oneNum,twoNum,threeNum,fourNum)
    self:runRewardAction(oneNum,1,oldone)
    self:runRewardAction(twoNum,2,oldtwo)
    self:runRewardAction(threeNum,3,oldthr)
    self:runRewardAction(fourNum,4,oldfou,_num)
    oldone=oneNum
    oldtwo=twoNum
    oldthr=threeNum
    oldfou=fourNum
end

function YXBDRebateView.getTimeStr( self, _time)
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

function YXBDRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return YXBDRebateView