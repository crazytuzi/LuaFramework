--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-8-14
-- Time: 下午4:49
-- To change this template use File | Settings | File Templates.
--




local RankListScene = class("RankListScene", function()

    display.addSpriteFramesWithFile("ui/rank_list.plist", "ui/rank_list.png")

    return require("game.BaseSceneExt").new({

        bottomFile = "public/bottom_frame.ccbi",
        topFile    = "nbhuodong/nbhuodong_top.ccbi"
    })
end)





function RankListScene:ctor()



    self.layerTable = {}



    self.listType = 1

    local viewSize = CCSizeMake(display.width, self:getContentHeight()) 
    self.baseNode = display.newNode()
    self.baseNode:setContentSize(viewSize)
    self.baseNode:setPosition(display.width/2,self:getBottomHeight())
    self:addChild(self.baseNode)

    local proxy = CCBProxy:create()
    -- self._rootnode = {}

    -- 创建UI 
    local contentNode = CCBuilderReaderLoad("rankList/rank_list_bg.ccbi", proxy, self._rootnode,self,viewSize)
    self.baseNode:addChild(contentNode) 

    self.tableScaleBgSize = CCSizeMake(display.width*0.95, self:getContentHeight() - self._rootnode["up_node"]:getContentSize().height)

    self.tableViewSize = CCSizeMake(self.tableScaleBgSize.width, self.tableScaleBgSize.height*0.96)

    local listWorldPos = self._rootnode["table_bg"]:convertToWorldSpace(ccp(0,0))
    self.tableRect = CCRect(listWorldPos.x, listWorldPos.y, display.width, self.tableScaleBgSize.height)

    self._rootnode["table_scale_bg"]:setContentSize(self.tableScaleBgSize)
    self:initHead()
    self:updateLayer()
end 


function RankListScene:sendListReq(type)
    RankListModel.sendListReq({
        callback = function()
            self:initListByType(type)
            self:initUpDetail(type)
        end,
        listType = type
        })    
end

function RankListScene:initUpDetail(type)
    local myRankData = RankListModel.getMyRank(type)


    local curRank = myRankData.rank
    if curRank ~= nil and curRank ~= 0 then
        self._rootnode["ttf_"..type.."_1"]:setString(curRank)
    else
        self._rootnode["ttf_"..type.."_1"]:setString("")
        local norecord =  ResMgr.createShadowMsgTTF({text = "2000名以外",color = ccc3(255,222,0),size = 24})--n
        norecord:setPosition(self._rootnode["ttf_"..type.."_1"]:getPositionX(),self._rootnode["ttf_"..type.."_1"]:getPositionY())
        self._rootnode["ttf_"..type.."_1"]:getParent():addChild(norecord)
    end


    local rightTTF 
    if type == 1 then
        rightTTF = myRankData.grade
    elseif type == 2 then
        rightTTF = myRankData.attack
    elseif type == 3 then
        rightTTF = myRankData.battleStars
    elseif type == 4 then
        rightTTF = myRankData.prestige
    end
    self._rootnode["ttf_"..type.."_2"]:setString(rightTTF)

    if self._rootnode["right_icon_"..type] ~= nil then
        local iconPos = ccp(self._rootnode["ttf_"..type.."_2"]:getPositionX() + self._rootnode["ttf_"..type.."_2"]:getContentSize().width,self._rootnode["ttf_"..type.."_2"]:getPositionY())
        self._rootnode["right_icon_"..type]:setPosition(iconPos)
    end 

    -- local curZhanli = myRankData.


end



function RankListScene:initListByType(type)
    local listData = RankListModel.getList(type)



    --初始化各个列表
    local function createFunc(idx)
        local item = require("game.RankListScene.RankListCell").new(i)
        return item:create({
            tableViewRect = self.tableRect,
            id = idx + 1,
            cellType = type
        })
    end

    local function refreshFunc(cell, idx)
        cell:refresh(idx+1)
    end
    local cellSize = require("game.RankListScene.RankListCell").new():getContentSize()

    local expandSize = CCSizeMake(cellSize.width, cellSize.height + 10)

    local itemList = require("utility.TableViewExt").new({
        size        = self.tableViewSize, 
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #listData,
        cellSize    = expandSize,
    })
    self._rootnode["table_bg"]:addChild(itemList)
    itemList:setPosition(0,5)
    self.layerTable[type] = itemList


end

function RankListScene:uptoIndexByCheck(index)

    if index == 4 then
        ResMgr.runFuncByOpenCheck({
            openKey = OPENCHECK_TYPE.JingJiChang,
            openFunc = function()
                self:updateByIndex(index)
            end})
    else
        self:updateByIndex(index)
    end

end

function RankListScene:updateByIndex(index)
    if self.listType ~= index then  
        self.listType = index               
        self:updateLayer()  
    end
end


function RankListScene:initHead()
    local icons = {"lvl_rank_icon","battle_rank_icon","jianghu_rank_icon","arena_rank_icon"}

    self._data = {}

    for i = 1,#icons do
        local curData = {}
        curData.icon = icons[i]
        self._data[#self._data + 1] = curData
    end


    local function createFunc(index)
        local item = require("game.nbactivity.ActivityItem").new()
        return item:create({
            viewSize = CCSizeMake(self._rootnode["headList"]:getContentSize().width, self._rootnode["headList"]:getContentSize().height),
            itemData = self._data[index + 1] 
        })
    end 

    local function refreshFunc(cell, index) 
        local selected = false
        if index == self._cellIndex then 
            selected = true
        end
        cell:refresh(self._data[index + 1], selected) 
    end

    self._scrollItemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(self._rootnode["headList"]:getContentSize().width, self._rootnode["headList"]:getContentSize().height), 
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #self._data,
        cellSize    = require("game.nbactivity.ActivityItem").new():getContentSize(), 
        touchFunc = function(cell)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
            local id = cell:getId()
            local index = cell:getIdx() + 1


            self:uptoIndexByCheck(index)

        end
    })

    self._rootnode["headList"]:addChild(self._scrollItemList)
end


function RankListScene:updateLayer()  

    self._cellIndex = self.listType - 1 
    for i = 0, self._scrollItemList:getCellNum() - 1 do 
        local item = self._scrollItemList:cellAtIndex(i) 
        if item ~= nil then 
            if self._cellIndex == i then 
                item:setSelected(true) 
            else
                item:setSelected(false) 
            end 
        end 
    end 

   for i = 1, 4 do
        if self.listType == i then
            if self.layerTable[i] ~= nil then 
                self.layerTable[i]:setVisible(true)
                self.layerTable[i]:reloadData()
            else
                self:sendListReq(i)
            end
            self._rootnode["node_"..i]:setVisible(true)
        else
            if self.layerTable[i] ~= nil then
                self.layerTable[i]:setVisible(false)
            end
            self._rootnode["node_"..i]:setVisible(false)
        end
    end   
end 


function RankListScene:onEnter()
    ResMgr.removeBefLayer()
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end


function RankListScene:onExit()
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    self:unregNotice() 
end


return RankListScene

