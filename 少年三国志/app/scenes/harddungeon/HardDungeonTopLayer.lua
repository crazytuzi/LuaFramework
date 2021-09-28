local HardDungeonTopLayer = class("HardDungeonTopLayer",  UFCCSModelLayer)

local ListType =
{
    TYPE_TOPRANK = 1,
    TYPE_BOUNSRANK = 2,
}

local _type = ListType.TYPE_TOPRANK

function HardDungeonTopLayer.create(...)
    return HardDungeonTopLayer.new("ui_layout/dungeon_DungeonTopLayer.json",Colors.modelColor, ...)
end


function HardDungeonTopLayer:ctor(json, color, ...)
    self.super.ctor(self, json, color, ...)
    self:adapterWithScreen()
    self:registerBtnClickEvent("closebtn",handler(self,self._onClick))
    self:registerBtnClickEvent("Button_TopClose",handler(self,self._onClick))
    self.topPanel = self:getPanelByName("Panel_Top")
    --self.bounsListViewPanel:setTouchEnable(false)
    _type = ListType.TYPE_TOPRANK
    self._selectCell = nil
    self:registerKeypadEvent(true)
--    self:getLabelByName("Label_StarTop"):setText(G_lang:get("LANG_DUNGEON_STARTOP"))
--    self:getLabelByName("Label_DungeonTop"):setText(G_lang:get("LANG_DUNGEON_DUNGEONTOP"))
    
end

function HardDungeonTopLayer:onBackKeyEvent( ... )
    self:_onClick()
    return true
end

local function _setText(cell,labelName,txt)
        local _name = cell:getLabelByName(labelName) 
    if _name then _name:setText(txt) end
end

function HardDungeonTopLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_GETDUNGEONRANK, self._getStarBous, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_FINISHSTARBOUNS, self._getBounsSucc, self)
    G_HandlersManager.hardDungeonHandler:sendGetDungeonRank()
    
     require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("bg"), "smoving_bounce")

     self:closeAtReturn(true)
end

function HardDungeonTopLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end


-- @desc领取奖励完成
function HardDungeonTopLayer:_getBounsSucc(data)
    G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEONTOP_FINISHSTARBOUNS"))
    self:_showTips()
    if self._selectCell then
        local _finishImg = self._selectCell:getImageViewByName("ImageView_GetStatus")
        _finishImg:loadTexture(G_Path.DungeonIcoType.YILINGQU, UI_TEX_TYPE_LOCAL)
    end
end

-- @desc 得到排名
function HardDungeonTopLayer:_getStarBous(data)
    local _rankList = G_Me.hardDungeonData:getDungeonRankList()
    self.topListViewPanel = self:_creatListView("toppanel","ui_layout/dungeon_DungeonTopItem.json",self._updateTopRank,#_rankList)
    local _panel = tolua.cast(self.bounsListViewPanel,"CCNode")
    
    local label_StarNum = self:getLabelByName("Label_StarNum")
    label_StarNum:setText(tostring(G_Me.hardDungeonData:getAllStar()))
    label_StarNum:setVisible(true)
    label_StarNum:createStroke(Colors.strokeBrown,1)
    
    if G_Me.hardDungeonData:getMyRank() >0 then
        self:getLabelBMFontByName("LabelBMFont_WeiShangBang"):setText(tostring(G_Me.hardDungeonData:getMyRank()))
    end
    
    self:getLabelBMFontByName("LabelBMFont_WeiShangBang"):setVisible(G_Me.hardDungeonData:getMyRank() >0)
    self:getLabelByName("Label_WeiShangBang"):setVisible(G_Me.hardDungeonData:getMyRank() <= 0)
    self:getLabelByName("Label_WeiShangBang"):createStroke(Colors.strokeBrown,1)
    _setText(self, "Label_PlayerName", G_Me.userData.name)
    self:getLabelByName("Label_PlayerName"):setVisible(true)
    
    self:getImageViewByName("ImageView_Star"):setVisible(true)
    
--    if data then
--        self.bounsListViewPanel:refreshWithStart()
--        self:_showTips()
--    end
    
--    self:addCheckBoxGroupItem(1, "CheckBox_Top")
--    self:addCheckBoxGroupItem(1, "CheckBox_StarBouns")
--    self:setCheckStatus(1, "CheckBox_Top")
--    self:registerCheckBoxGroupEvent(handler(self,self._changeTab))
end

function HardDungeonTopLayer:_changeTab(groupId, oldName, newName, widget)
    if groupId == 1 then
        if newName == "CheckBox_Top" then   
            self.topPanel:setVisible(true)
            self.starBounsPanel:setVisible(false)
             _type = ListType.TYPE_TOPRANK
        elseif newName == "CheckBox_StarBouns" then  
            self.topPanel:setVisible(false)
            self.starBounsPanel:setVisible(true)
            self:_showTips()
             _type = ListType.TYPE_BOUNSRANK
        end
    end
end
 -- @desc 提示有奖励
function HardDungeonTopLayer:_showTips()
    local _tips = self:getWidgetByName("ImageView_Tip")
    if _tips then
        local _starNum = G_Me.hardDungeonData:getAllStar()
         _tips:setVisible(false)
        for k=1,dungeon_allstar_info.getLength() do
            local v = dungeon_allstar_info.indexOf(k)
            if _starNum >= v.allstar_num then
                if not G_Me.hardDungeonData:getBounsById(v.id) then
                    _tips:setVisible(true)
                end
            else
                break
            end
        end
    end
end


function HardDungeonTopLayer:_creatListView(panelName,json,updateFunc,listnum)
    local panel = self:getWidgetByName(panelName)
    tolua.cast(panel,"Layout")
    local _listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL) 
    _listview:setCreateCellHandler(
    function ( list, index) 
        local cell = CCSItemCellBase:create(json)
            cell:regisgerWidgetTouchEvent("ImageView_Bg",function ( widget, _touchtype)
                if _touchtype == TOUCH_EVENT_ENDED then -- 点击事件
                    G_HandlersManager.hardDungeonHandler:sendFinishChapterAchvRwd(widget:getTag())
                    self._selectCell = cell
                end
                end)
    	return cell
    end)

    
    _listview:setUpdateCellHandler(updateFunc)
    _listview:initChildWithDataLength(listnum)   -- 一共显示10项item出来。
    return _listview
end

--local function setText(widget,childName,txt)
--        local _name = widget:getWidgetByName(childName) 
--        _name = tolua.cast(_name,"Label")
--    if _name then _name:setText(txt) end
--end

function HardDungeonTopLayer._updateTopRank(list, index, cell)
    local _rankList = G_Me.hardDungeonData:getDungeonRankList()
    if _rankList then
        local num = index + 1
        _setText(cell, "playername", _rankList[num].name)
        local label_StarNum = cell:getLabelByName("Label_StarNum")
        label_StarNum:setText(_rankList[num].star)
        label_StarNum:createStroke(Colors.strokeBrown,1)
        
        -- 1,2,3排名显示不同颜色
        local rankLabel = cell:getLabelBMFontByName("LabelBMFont_Rank")
        if num == 1 then 
            rankLabel:setText("1st")
            rankLabel:setColor(ccc3(255,0,255))
        elseif num == 2 then 
            rankLabel:setText("2nd")
            rankLabel:setColor(ccc3(0,205,255))
        elseif num == 3 then 
            rankLabel:setText("3rd")
            rankLabel:setColor(ccc3(165,254,2))
        else
            rankLabel:setText(tostring(num))
            rankLabel:setColor(ccc3(254,246,216))
        end
        
        local leftImg = cell:getImageViewByName("ImageView_Left")
        local rightImg = cell:getImageViewByName("ImageView_Right")
        if leftImg then
            if _rankList[num].name == G_Me.userData.name then
                leftImg:loadTexture(G_Path.DungeonIcoType.MINGCI_3)
                rightImg:loadTexture(G_Path.DungeonIcoType.INFO_3)
            else
                if num < 4 then
                    leftImg:loadTexture(G_Path.DungeonIcoType.MINGCI_1)
                    rightImg:loadTexture(G_Path.DungeonIcoType.INFO_1)
                else
                    leftImg:loadTexture(G_Path.DungeonIcoType.MINGCI_2)
                    rightImg:loadTexture(G_Path.DungeonIcoType.INFO_2)
                end
            end
        end
    end
end



function HardDungeonTopLayer:_onClick(widget)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_UPDATETIPS, nil, false,nil)
    self:animationToClose()
end

return HardDungeonTopLayer
