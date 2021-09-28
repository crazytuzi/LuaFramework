--

--
local HandBook = class("HandBook", function()

    return require("game.BaseScene").new({
        contentFile = "handbook/handbook_bg.ccbi",
        subTopFile = "handbook/handbook_up_tab.ccbi"
    })
end)


local XIAKE = 1
local EQUIP = 2
local WUXUE = 3 

function HandBook:SendReq()
    RequestHelper.getHandBook({
        callback = function(data)
            -- dump(data)
            HandBookModel.init(data)
            self:init()
        end})
end

function HandBook:init()
    self.subTag = {}
    self.subNode = {}
    self.mainNode = {}
     --    选项卡切换
    
    local function onMainTabBtn(tag)
        if self.curTag  ~= tag then
            self.curTag = tag
            self:changeTabTo(tag)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 

            for i = 1,3 do
                if i == tag then 
                    self._rootnode["tab"..i]:selected()
                    self._rootnode["tag_node_"..i]:setZOrder(10)
                    self._rootnode["btns_"..i]:setVisible(true)
                    self.mainNode[i]:setVisible(true)
                else
                    self._rootnode["tab"..i]:unselected()
                    self._rootnode["tag_node_"..i]:setZOrder(0)
                    self._rootnode["btns_"..i]:setVisible(false)
                    self.mainNode[i]:setVisible(false)
                end
            end
        else
            self._rootnode["tab"..tag]:selected()
        end
    end

    HandBookModel.viewBg  = self._rootnode["dark_bg"]

    local darkHeight =  self.centerHeight - self._rootnode["up_bar"]:getContentSize().height - self._rootnode["mid_node"]:getContentSize().height -96 - 30
    local darkWidth = self._rootnode["dark_bg"]:getContentSize().width
    self.innerBgSize = CCSizeMake(darkWidth, darkHeight)
    self._rootnode["dark_bg"]:setPreferredSize(self.innerBgSize)

    --初始化各个子选项卡

    for i = 1, 3 do
        self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onMainTabBtn)
        self.subNode[i] = {}
        self.mainNode[i] = display.newNode()
        self._rootnode["cur_bar_bg"]:addChild(self.mainNode[i])
        self._rootnode["cur_bar_bg"]:setTouchEnabled(true)
        self._rootnode["cur_bar_bg"]:setTouchSwallowEnabled(true)
        for j = 1 , 4 do
            if self._rootnode["tab_" ..i.."_"..j] ~= nil then
                self.subNode[i][j] = display.newNode()

                self._rootnode["tab_" ..i.."_"..j]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, 
                    function() 
                        self:onSubBtn(i,j)
                        end)
            else
                break
            end
        end

        self:initMainBar(i)
        self:onSubBtn(i, 1)
    end

    onMainTabBtn(1)
    
end

function HandBook:initSubNode(i,j)
    
    local subNode = display.newNode()
    subNode:setTag(j)
    self.mainNode[i]:addChild(subNode)


    local exNum,maxNum = HandBookModel.getSubTabNum(i,j)
    local subBar =  display.newProgressTimer("#hand_green_bar.png", display.PROGRESS_TIMER_BAR)
    subBar:setMidpoint(ccp(0,0.5))
    subBar:setBarChangeRate(ccp(1,0))
    subBar:setPosition(self._rootnode["cur_bar_bg"]:getContentSize().width/2,self._rootnode["cur_bar_bg"]:getContentSize().height/2)
    subBar:setPercentage(exNum/maxNum*100)
    subNode:addChild(subBar)


    local numTTF = ui.newTTFLabelWithShadow({
        text = "完成度"..exNum.."/"..maxNum,
        size = 16,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER,
        })
    numTTF:setPosition(self._rootnode["cur_bar_bg"]:getContentSize().width/2,self._rootnode["cur_bar_bg"]:getContentSize().height/2-2)
    subNode:addChild(numTTF)

    local curData = HandBookModel.getSubData(i,j)

    local curScroll = require("game.HandBook.HandBookScroll").new({size = self.innerBgSize,data = curData})

    curScroll:setPosition(-28,45-self.innerBgSize.height)

    subNode:addChild(curScroll)

    --
end

function HandBook:initMainBar(i)
    local curNum,maxNum = HandBookModel.getMainTabNum(i)
    local numBar =  display.newProgressTimer("#hand_blue_bar.png", display.PROGRESS_TIMER_BAR)
    numBar:setMidpoint(ccp(0,0.5))
    numBar:setBarChangeRate(ccp(1,0))
    numBar:setAnchorPoint(ccp(0,0))

    numBar:setPercentage(curNum/maxNum*100)
    self._rootnode["bar_bg_"..i]:addChild(numBar)

    local numTTF = ui.newTTFLabelWithShadow({
        text = curNum.."/"..maxNum,
        size = 16,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER,
        })
    self._rootnode["bar_bg_"..i]:addChild(numTTF)
    numTTF:setPosition(self._rootnode["bar_bg_"..i]:getContentSize().width/2,self._rootnode["bar_bg_"..i]:getContentSize().height/2-2)    

end

function HandBook:changeTabTo(tag)
end


function HandBook:ctor()
    game.runningScene = self
    ResMgr.removeBefLayer()
   
    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 

    end,
    CCControlEventTouchUpInside)
    -- self:init()
   self:SendReq()
end



function HandBook:onSubBtn(tag,subTag)

    if self.subTag[tag] ~= subTag then
        self.subTag[tag] = subTag
        for j = 1 , 4 do
            local curBtn = self._rootnode["tab_" ..tag.."_"..j]
            if  curBtn ~= nil then
                if j == subTag then
                    curBtn:selected()
                    if self.mainNode[tag]:getChildByTag(j) == nil then


                        self:initSubNode(tag, j)
                    end

                    self.mainNode[tag]:getChildByTag(j):setVisible(true)
                else
                    curBtn:unselected()
                    if self.mainNode[tag]:getChildByTag(j) ~= nil then
                        self.mainNode[tag]:getChildByTag(j):setVisible(false)
                    end
                end
            else
                break
            end
        end
    else
        self._rootnode["tab_" ..tag.."_"..subTag]:selected()
    end
end

-- 重新加载广播
function HandBook:reloadBroadcast()
    local broadcastBg = self._rootnode["broadcast_tag"] 

        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
end

function HandBook:onEnter()

    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)

    -- 广播
    if self._bExit then
        self._bExit = false
        local broadcastBg = self._rootnode["broadcast_tag"] 
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end
end

function HandBook:onExit()
    self:unregNotice()
    self._bExit = true
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end








return HandBook
