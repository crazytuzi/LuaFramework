-- 排行榜
local TopTypeConst = require("app.const.TopTypeConst")
local TopScene = class("TopScene", UFCCSBaseScene)
require("app.cfg.knight_info")

function TopScene:ctor(...)
    self.super.ctor(self,...)
    
    self._layer = CCSNormalLayer:create("ui_layout/top_Main.json")
    self:addUILayerComponent("TopLayer", self._layer, true)
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedBar, true)
    self:adapterLayerHeight(self._layer, nil, self._speedBar, -8, -56)
    
    
    self.topListview = nil
    -- 当前选择类型
    self.selectType = TopTypeConst.TYPE_FIGHT
    -- 当前选择的列表
    self.selectList = nil
    -- 排行榜列表
    self.topList = {} 
    -- 我的排名
    self.myRank = {}
    
    self.isEnd = {}

    self.isEnd[TopTypeConst.TYPE_FIGHT] = false
     self.isEnd[TopTypeConst.TYPE_LV] = false
    --刷新长度
    self.updateLen = 9
    
    self._layer:registerBtnClickEvent("Button_Back",function(widget)
        uf_sceneManager:replaceScene(require("app.scenes.hallofframe.HallOfFrameScene").new())
    end)
    
    self._layer:getLabelByName("Label_Fight"):setText(G_lang:get("LANG_INFO_FIGHT"))
    self._layer:getLabelByName("Label_Lv"):setText(G_lang:get("LANG_INFO_LV"))
    self:_setTabColor(TopTypeConst.TYPE_FIGHT)
    
    self:_setUserInfo(0)
    self._layer:getImageViewByName("Image_WeiShangBang"):setVisible(false)
end

function TopScene:onSceneEnter(...)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HALLOFFRAME_TOP, self._recvRankInfo, self)
    if #self.topList == 0 then
        G_HandlersManager.hallOfFrameHandler:sendRequestRankInfo(TopTypeConst.TYPE_FIGHT,0,self.updateLen)
        self:_initCheckBox()
        self._layer:getLabelByName("Label_MyRank"):createStroke(Colors.strokeBrown,2)
    end
end

function TopScene:_setEnd(value,top_type)
    self.isEnd[top_type] = value
end

function TopScene:onSceneExit()
     uf_eventManager:removeListenerWithTarget(self)
end

function TopScene:_recvRankInfo(data)
    
    if self.topList[self.selectType] == nil then
        self.topList[self.selectType] = {}
    end
    local listlen =  #self.topList[self.selectType]
    for k,v in pairs(data.infos) do
        table.insert(self.topList[self.selectType],v)
    end 
    
    self.myRank[self.selectType] = data.self_rank
    
    self.selectList = self.topList[self.selectType]
    if self.topListview == nil then
            self:_initTopListView()
    else
        if listlen == 0 then -- 第一次收到消息
            self.topListview:initChildWithDataLength(#self.selectList,0.2)
        else
            self.topListview:reloadWithLength(#self.selectList,#self.selectList-self.updateLen-1)
        end
    end
    if #data.infos < self.updateLen+1  then
        self:_setEnd(true,self.selectType)
    end
    
    self:_setUserInfo(self.myRank[self.selectType])
end

function TopScene:_initCheckBox()
    self._layer:addCheckBoxGroupItem(1, "CheckBox_Fight")
    self._layer:addCheckBoxGroupItem(1, "CheckBox_Lv")
    self._layer:setCheckStatus(1, "CheckBox_Fight")
    
    self._layer:registerCheckboxEvent("CheckBox_Fight", function ( widget, type, isCheck )
            if self.selectType == TopTypeConst.TYPE_LV then
                self:switchType(TopTypeConst.TYPE_FIGHT)
            end
    end)
    self._layer:registerCheckboxEvent("CheckBox_Lv", function ( widget, type, isCheck )
            if self.selectType == TopTypeConst.TYPE_FIGHT then
                self:switchType(TopTypeConst.TYPE_LV)
            end
    end)
end

--@desc 设置排名 颜色and 次序
function TopScene:_setRank(rankLabel,num,hatPic)
    if hatPic == nil then
        return
    end
    
    if hatPic then
        hatPic:setVisible(num<4)
        if num <4 then
            rankLabel:setVisible(false)
            hatPic:loadTexture(G_Path.getRankIco(num))
            if num == 1 then
                hatPic:setScale(0.8)
            elseif num == 2 then
                hatPic:setScale(0.88)
            else
                hatPic:setScale(0.97)
            end
        else
            rankLabel:setText(tostring(num))
            rankLabel:setColor(ccc3(254,246,216))
            rankLabel:setVisible(true)
        end
    end

   

end

function TopScene:_setTabColor(top_type)
    local lvLabel = self._layer:getLabelByName("Label_Lv")
    local fightLabel = self._layer:getLabelByName("Label_Fight")
    lvLabel:setColor(top_type == TopTypeConst.TYPE_LV and Colors.TAB_DOWN or Colors.TAB_NORMAL)
    fightLabel:setColor(top_type == TopTypeConst.TYPE_FIGHT and Colors.TAB_DOWN or Colors.TAB_NORMAL)
    if top_type == TopTypeConst.TYPE_LV then
        lvLabel:createStroke(Colors.strokeBrown,2)
        fightLabel:disableStrokeEx()
    else
        fightLabel:createStroke(Colors.strokeBrown,2)
        lvLabel:disableStrokeEx()
    end
end

function TopScene:_moveToBottomEvent(list,event_type, index)
    if event_type == LISTVIEW_EVENT_UPDATE_CHILD then
        
        -- 滑到底并且还没有到底
        if index+1 == #self.selectList then
            if  self.isEnd[self.selectType] == false  and #self.selectList < 50   then
                    G_HandlersManager.hallOfFrameHandler:sendRequestRankInfo(self.selectType,#self.selectList,#self.selectList+self.updateLen)
            end
        end
    end
end

--@desc 初始化当前排行榜类型
function TopScene:_initTopListView()
    
    local panel = self._layer:getPanelByName("Panel_TopList")
    self._layer:adapterWidgetHeight("Panel_TopList", "Image_TabBg","Image_25", -10, 0)
    if panel then
        self.topListview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self.topListview:setCreateCellHandler( function(list, index)
        self._layer:registerListViewEvent("Panel_TopList",handler(self, self._moveToBottomEvent))
        
        local cell = CCSItemCellBase:create("ui_layout/top_PlayerItem.json")
            cell:registerBtnClickEvent("Button_Head",function(widget)
            if widget:getTag() ~= G_Me.userData.id then
                self:addChild(require("app.scenes.friend.FriendInfoLayer").createByName(widget:getTag(), "", nil, 
                    function ( ... )
                            uf_sceneManager:replaceScene(require("app.scenes.hallofframe.TopScene").new())
                    end))
            end
            end)
            return cell
	end )

	self.topListview:setUpdateCellHandler(function(list, index, cell)
            
            -- 排名
            local rankLabel = cell:getLabelBMFontByName("BitmapLabel_Rank")
            if rankLabel then
                self:_setRank(rankLabel,index+1,cell:getImageViewByName("Image_Hat"))
            end
            
            --等级
            local lvLabel = cell:getLabelByName("Label_PlayerLv")
            if lvLabel and self.selectList[index+1].level then
                if self.selectType == TopTypeConst.TYPE_LV then
                    lvLabel:setText(G_lang:get("LANG_INFO_FIGHT") .. " " .. GlobalFunc.ConvertNumToCharacter(self.selectList[index+1].fv))
                else
                    lvLabel:setText(G_lang:get("LANG_INFO_LV") .. " " .. self.selectList[index+1].level)
                end
            end
            
            --帮会
            local unionLabel = cell:getLabelByName("Label_Union")
            local sept_name = self.selectList[index+1].sept_name
            sept_name = string.len(sept_name)> 0 and sept_name or G_lang:get("LANG_FRIEND_ZANWU")
            if unionLabel and sept_name then
                unionLabel:setText(G_lang:get("LANG_FRIEND_BANGHUI")..sept_name)
            end
            
            --排行类型
            local typeImg = cell:getImageViewByName("Image_Type")
            if typeImg  then
                local data = G_Path.getTopValueIco(self.selectType)
                if data then
                    typeImg:loadTexture(data.txt,data.textype)
                end
            end
            
            local knightInfo = knight_info.get(self.selectList[index+1].base_id)
            if knightInfo then
                --头像
                local head = cell:getButtonByName("Button_Head")
                if head  then
                    local resid = G_Me.dressData:getDressedResidWithClidAndCltm(self.selectList[index+1].base_id,self.selectList[index+1].dress_id,
                        self.selectList[index+1].clid,self.selectList[index+1].cltm,self.selectList[index+1].clop)
                    head:loadTextureNormal(G_Path.getKnightIcon(resid))
                    head:setTag(self.selectList[index+1].id)
                end
                
                -- 角色品质
                local qualityImg = cell:getImageViewByName("Image_HeadQuality")
                if qualityImg then
                    qualityImg:loadTexture(G_Path.getEquipColorImage(knightInfo.quality))
                end
                
                --玩家名字
                local nameLabel = cell:getLabelByName("Label_PlayerName")
                if nameLabel and self.selectList[index+1].name then
                    nameLabel:setText(self.selectList[index+1].name)
                    nameLabel:setColor(Colors.qualityColors[knightInfo.quality])
                    nameLabel:createStroke(Colors.strokeBrown,1)
                end
            end
            
            --cell:getImageViewByName("Image_FightBg"):setVisible((self.selectType == TopTypeConst.TYPE_FIGHT) or (self.selectType == TopTypeConst.TYPE_ARENA))
            --排行类型值
            local typeValueLabel = cell:getLabelByName("Label_TypeValue")
            if typeValueLabel and self.selectList[index+1].fv then
                if self.selectType == TopTypeConst.TYPE_FIGHT then
                    typeValueLabel:setText(GlobalFunc.ConvertNumToCharacter(self.selectList[index+1].fv))
                else
                    typeValueLabel:setText(self.selectList[index+1].level)
                end
                typeValueLabel:createStroke(Colors.strokeBrown,1)
            end
            
        end)
        
        self.topListview:initChildWithDataLength(#self.selectList,0.2)
    end
end

--@desc 切换排行榜类型
function TopScene:switchType(top_type)
    self.selectType = top_type
    self:_setTabColor(top_type)
    if self.topList[top_type] == nil then
        G_HandlersManager.hallOfFrameHandler:sendRequestRankInfo(top_type,0,self.updateLen)
    else
        self.selectList = self.topList[top_type]
        self.topListview:initChildWithDataLength(#self.selectList,0.2)
        self:_setUserInfo(self.myRank[self.selectType])
    end

end

--@desc 添加列表
function TopScene:_addTopList(list,top_type)
    if self.topList[top_type] == nil then
        self.topList[top_type] = {}
    end
    self.topList[top_type] = list
end

--@desc 设置玩家信息
function TopScene:_setUserInfo(rank)
    local rankLabel = self._layer:getLabelBMFontByName("BitmapLabel_MyRank")
    local weiShangBangImg = self._layer:getImageViewByName("Image_WeiShangBang")

    if rank == 0 then
        weiShangBangImg:setVisible(true)
        rankLabel:setVisible(false)
        self._layer:getImageViewByName("Image_Heart"):setVisible(false)
    else
        if rankLabel and rank > 0 then
            self:_setRank(rankLabel,rank,self._layer:getImageViewByName("Image_Heart"))
        end
        weiShangBangImg:setVisible(false)
    end

    
        --排行类型
    local typeImg = self._layer:getImageViewByName("Image_Type")
    if typeImg  then
        local data = G_Path.getTopValueIco(self.selectType)
        if data then
            typeImg:loadTexture(data.txt,data.textype)
        end
    end
    
    self._layer:getLabelByName("Label_MyRank"):setText(G_lang:get("LANG_TOP_RANK"))
    
    local typeValueLabel = self._layer:getLabelByName("Label_TypeValue")
    if typeValueLabel  then
        typeValueLabel:setText(GlobalFunc.ConvertNumToCharacter(self.selectType == TopTypeConst.TYPE_FIGHT and G_Me.userData.fight_value or G_Me.userData.level))
        typeValueLabel:createStroke(Colors.strokeBrown,2)
    end
end


return TopScene



