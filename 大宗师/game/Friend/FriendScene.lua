
--
local FriendScene = class("FriendScene", function()

    return require("game.BaseScene").new({
        contentFile = "friend/friend_list_bg.ccbi",
        subTopFile = "friend/friend_up_tab.ccbi"
    })
end)

local ORANGE_COLOR = ccc3(255, 210, 0)
local GREEN_COLOR = ccc3(0,219,52)

local FRIEND_TYPE       = 1
local RECOMMEND_TYPE    = 2
local NAILI_TYPE        = 3
local REQUEST_TYPE      = 4



function FriendScene:ctor(tag)
    ResMgr.removeBefLayer()
    game.runningScene = self
    self.tab = 1

    self.tableViewVec = {}

    FriendModel.initReq({
        callback = function() 
            self:init()
            self:updateTab()
       end})
end

function FriendScene:init()
    self:initTableviews()
    self:initDetailNode()
    self:initTab()

    self:initTimeNode()

end

function FriendScene:initTimeNode()
    self.timeNode = display.newNode()
    self:addChild(self.timeNode)
    
    FriendModel.chatListReq()

    self.timeNode:schedule(function()        
        FriendModel.chatListReq()
        end, FriendModel.REQ_INTERVAL)
end

function FriendScene:initTab()
    self.tabBtns = require("utility.BaseTab").new({
        tabs            = {"friend_mine_sel.png","friend_recommend_sel.png","friend_claim_nali_sel.png","friend_apply_sel.png"},
        unSelImage      = {"friend_mine_unsel.png","friend_recommend_unsel.png","friend_claim_nali_unsel.png","friend_apply_unsel.png"},
        tabListener     = function(id)
            self.tab = id
            self:updateTab()
        end,
        checkFunc = function()
            return self.isAllow 
        end,
        spaceInCells    = -10
        })
    self._rootnode["tab_bg"]:addChild(self.tabBtns)
    -- self.tabBtns:setVisible(false)

    for i = 1,4 do
         self:updateTabNum(i)
    end
end

function FriendScene:initTableviews()
    self.initTabAlready = true
    for i = 1,4 do
        self._rootnode["node_"..i]:retain()

        local tableBgSize = self._rootnode["list_view"]:getContentSize()

        local curTablePosY = 0

        for nodeCount = 1, 2 do
            --1代表的是下面的节点
            --2代表的是上面的节点
            local curNode = self._rootnode["node_"..i.."_"..nodeCount]
            -- curNode:retain()
            if curNode ~= nil then
                tableBgSize.height = tableBgSize.height - curNode:getContentSize().height
                if nodeCount == 1 then
                    curTablePosY = curNode:getContentSize().height
                end
            end
        end



        local listWorldPos = self._rootnode["list_view"]:convertToWorldSpace(ccp(0,curTablePosY))
        local tableRect = CCRect(listWorldPos.x, listWorldPos.y, tableBgSize.width, tableBgSize.height)

        local function createFunc(idx)
            local item = require("game.Friend.FriendCell").new(i)
            return item:create({
                tableViewRect = tableRect,
                id = idx+1
            })
        end

        local function refreshFunc(cell, idx)
            cell:refresh(idx+1)
        end
        local dataList = FriendModel.getList(i)


        local itemList = require("utility.TableViewExt").new({
            size        = tableBgSize, 
            direction   = kCCScrollViewDirectionVertical,
            createFunc  = createFunc,
            refreshFunc = refreshFunc,
            cellNum     = #dataList,
            cellSize    = require("game.Friend.FriendCell").new(i):getContentSize(),
        })
        self._rootnode["list_view"]:addChild(itemList)
        itemList:setPosition(0,curTablePosY)
        self.tableViewVec[i] = itemList

    end
end

function FriendScene:onMoreBtn()
    --发送请求，更新列表
    FriendModel.updateRecommendList()
end

function FriendScene:onRecieveAll()
    --全部领取并回赠
    FriendModel.getAllNailiReq()
end

function FriendScene:onAgreeAll()
    --全部同意
    FriendModel.acceptAllReq()    
end

function FriendScene:onRejectAll()
    --全部拒绝
    FriendModel.rejectAll()
end


function FriendScene:upSearchType()    

    for i = 1,2 do
        if i == FriendModel.searchType+1 then
            self._rootnode["search_" ..tostring(i)]:selected()
        else
            self._rootnode["search_" ..tostring(i)]:unselected()
        end
    end
end

function FriendScene:initSearch()
    FriendModel.searchType = FRIEND_SERACH.BY_ID
    for i = 1 ,2 do
        self._rootnode["search_" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function()
            if FriendModel.searchType ~= i - 1 then
                FriendModel.searchType = i - 1 
                FriendModel.isSearch = false
                self:cleanSearchContent()
                if i == 1 then
                    self._editBox:setPlaceHolder("输入好友ID进行搜索")
                else
                    self._editBox:setPlaceHolder("输入好友昵称进行搜索")
                end
            end
            self:upSearchType()
        end)
    end
    ResMgr.setControlBtnEvent(self._rootnode["search_btn"], function()
            self:startSearch()
        end)
    self:initEditBox()

    self:upSearchType()
end

function FriendScene:cleanSearchContent()
    FriendModel.searchContent = ""
    self._editBox:setText("")
end

function FriendScene:startSearch()
    FriendModel.searchContent = tostring(self._editBox:getText())
    FriendModel.startSearch()
end

function FriendScene:cleanEditBox()
    if self._editBox ~= nil then
        self._editBox:removeSelf()
        self._editBox = nil
    end
end

function FriendScene:initEditBox()
    local boxSize = self._rootnode["ed_box"]:getContentSize()
    self._editBox = ui.newEditBox({
        image = "#text_frame.png",
        size = boxSize,
        x = self._rootnode["ed_box"]:getPositionX() + boxSize.width/2, 
        y = self._rootnode["ed_box"]:getPositionY() ,
    })
    self._rootnode["ed_box"]:getParent():addChild(self._editBox)

    self._editBox:setFont(FONTS_NAME.font_fzcy, 22)
    self._editBox:setFontColor(FONT_COLOR.WHITE)
    self._editBox:setMaxLength(FriendModel.MAX_NAME_LEN)


    self._editBox:setPlaceHolder("输入好友ID进行搜索")
    self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 22)
    self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
    
    self._editBox:setReturnType(1)
    self._editBox:setInputMode(0)
    self.isAllow = true

    -- self._editBox:setEnabled(false)

    local function editboxEventHandler(eventType)
         if eventType == "began" then
            self.isAllow = false
            self._editBox:setEnabled(false)
             -- triggered when an edit box gains focus after keyboard is shown
             self.tabBtns:setTouchState(false)
         elseif eventType == "ended" then
            self.isAllow = true
            self._editBox:setEnabled(true)
            self.isAllow = true
            self.tabBtns:setTouchState(true)
             -- triggered when an edit box loses focus after keyboard is hidden.
         elseif eventType == "changed" then
         elseif eventType == "return" then

             -- triggered when the return button was pressed or the outside area of keyboard was touched.
         end
     end
    

     self._editBox:registerScriptEditBoxHandler(editboxEventHandler)


end




function FriendScene:initDetailNode()  
    --搜索的俩按钮
    self:initSearch()

    --更多好友
    ResMgr.setControlBtnEvent(self._rootnode["more_btn"], function()
        self:onMoreBtn()
    end)

    --全部领取并回赠    
    ResMgr.setControlBtnEvent(self._rootnode["receive_all"], function()
        self:onRecieveAll()
    end)

    --全部同意    
    ResMgr.setControlBtnEvent(self._rootnode["agree_all"], function()
        self:onAgreeAll()
    end)

    --全部拒绝
    ResMgr.setControlBtnEvent(self._rootnode["reject_all"], function()
        self:onRejectAll()
    end)    
    

    local orX,orY = self._rootnode["rest_claim_time"]:getPosition()
    local orNode =  self._rootnode["rest_claim_time"]:getParent()

    self.restNaili = ResMgr.createShadowMsgTTF({size = 26,text = "今日剩余领取次数：",color = ccc3(255,255,255)})
    orNode:addChild(self.restNaili)
    self.restNaili:setPosition(orX ,orY)

    self.restNailiNum = ResMgr.createShadowMsgTTF({size = 26,text = "0",color = ccc3(0,219,52)})
    orNode:addChild(self.restNailiNum)
    self.restNailiNum:setPosition(self.restNaili:getPositionX() + self.restNaili:getContentSize().width/2 + self.restNailiNum:getContentSize().width/2,orY)

    for i = 1,4 do
        self:updateDownByIndex(i)
    end
end

function FriendScene:updateTab()
    --更新tab
    for i = 1,4 do
        -- if i == 2 then
        --     if self.tabBtns ~= nil then
        --       self.tabBtns:setVisible(false)
        --   end
        -- end 

        --tab
        if i == self.tab then
            if self._rootnode["node_"..i]:getParent() == nil then
                self._rootnode["infoView"]:addChild(self._rootnode["node_"..i])
                self._rootnode["node_"..i]:setVisible(true)
            end
            self.tableViewVec[i]:setVisible(true)   
        else
            self._rootnode["node_"..i]:removeSelf()
            self.tableViewVec[i]:setVisible(false)
        end
    end


end

function FriendScene:updateTabNum(index)
    local dataList = FriendModel.getList(index)
    if index  == 1 then
        local chatNum = FriendModel.getChatNum()
         print("index "..chatNum)
        self.tabBtns:setNum(index, chatNum)
    elseif index == 2 then
        --推荐列表没有小红点，永远不更新
    else
        self.tabBtns:setNum(index, #dataList)
    end
end

function FriendScene:updateByIndex(index)
    local dataList = FriendModel.getList(index)



    self.tableViewVec[index]:reArrangeCell(#dataList)

    self:updateTabNum(index)

    self:updateDownByIndex(index)
end

function FriendScene:updateDownByIndex(index)
    if index == FRIEND_TYPE then
        self:updateFriendNum()
    elseif index == NAILI_TYPE then
        self:updateNailiDown()
    elseif index == REQUEST_TYPE then
        self:updateReqDown()
    end
end

function FriendScene:updateFriendNum()
    local data_config_config = require("data.data_config_config")
    local dataList = FriendModel.getList(FRIEND_TYPE)
    local curNum = #dataList
    local maxNum = data_config_config[1].max_friend_num

    self._rootnode["curNum"]:setString(curNum)
    self._rootnode["maxNum"]:setString(maxNum)
    local xiedai = self._rootnode["xiedai"]
    local curNum = self._rootnode["curNum"]
    local sign  = self._rootnode["sign"]
    local maxNum = self._rootnode["maxNum"]

    curNum:setPosition(xiedai:getPositionX()+xiedai:getContentSize().width,xiedai:getPositionY())
    sign:setPosition(curNum:getPositionX()+curNum:getContentSize().width,xiedai:getPositionY())
    maxNum:setPosition(sign:getPositionX()+sign:getContentSize().width,xiedai:getPositionY())    
end

function FriendScene:updateNailiDown()
    local restNum = FriendModel.restNailiNum
    self.restNailiNum:setString(restNum)

    self.restNailiNum:setPosition(self.restNaili:getPositionX() + self.restNaili:getContentSize().width + self.restNailiNum:getContentSize().width/2,self.restNaili:getPositionY())

    if restNum > 0 then
        self._rootnode["receive_all"]:setEnabled(true)
    else
        self._rootnode["receive_all"]:setEnabled(false)
    end 
end

function FriendScene:updateReqDown()
    local dataList = FriendModel.getList(REQUEST_TYPE)
    if #dataList > 0 then
        -- self._rootnode["agree_all"]:setDisab
    else
    end
end







-- 重新加载广播
function FriendScene:reloadBroadcast()
    local broadcastBg = self._rootnode["broadcast_tag"] 

    if game.broadcast:getParent() ~= nil then 
        game.broadcast:removeFromParentAndCleanup(true)
    end
    broadcastBg:addChild(game.broadcast)
end

function FriendScene:updateLabel()
    self._rootnode["goldLabel"]:setString(game.player:getGold())
    self._rootnode["silverLabel"]:setString(game.player:getSilver())
end



function FriendScene:onEnter()
    RegNotice(self,
        function(timeStr, indexData)
           local curIndex = indexData:getValue()
           self:updateByIndex(curIndex)      
        end,
        NoticeKey.UPDATE_FRIEND)


    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)

        -- 广播
    if self._bExit then
        self._bExit = false
        self:reloadBroadcast()
    end
end


function FriendScene:onExit()
    self._bExit = true
    self:unregNotice()
    UnRegNotice(self, NoticeKey.UPDATE_FRIEND)
    if self.initTabAlready == true then 
        for i = 1,4 do
            self._rootnode["node_"..i]:release()
        end
    end
end



return FriendScene
