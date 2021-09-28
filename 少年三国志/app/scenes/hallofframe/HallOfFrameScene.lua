-- 排行榜
local TopTypeConst = require("app.const.TopTypeConst")
local HallOfFrameScene = class("HallOfFrameScene", UFCCSBaseScene)
local knightPic = require("app.scenes.common.KnightPic")

function HallOfFrameScene:ctor(...)
    self.super.ctor(self,...)
    
    self._layer = CCSNormalLayer:create("ui_layout/top_HallOfFrame.json")
    self:addUILayerComponent("HallOfFrameLayer", self._layer, true)
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedBar, true)
    self:adapterLayerHeight(self._layer, nil, self._speedBar, 0, -56)
    self._layer:getPanelByName("Panel_4"):setVisible(false)
    --战力列表
    self.FightList = {}
    
    self.pt = {}
    --等级列表
    self.LvList = {}
    
    self.tipsList = {}
    
    self.selectType = TopTypeConst.TYPE_FIGHT
    -- 点赞次数
    self.num = G_Me.userData.hof_points
       
    self._layer:registerBtnClickEvent("Button_Top",function()
        uf_sceneManager:replaceScene(require("app.scenes.hallofframe.TopScene").new())
    end)
    for i = 1 , 6 do 
        self._layer:registerBtnClickEvent("Button_Heart" .. i,function (widget )
            self:_onClickKnight(widget)
        end)
    end
        
    local confirmLabel =  self._layer:getLabelByName("Label_Confirm")
    if confirmLabel then
        confirmLabel:setText(G_lang:get("LANG_TOP_NUM"))
        confirmLabel:createStroke(Colors.strokeBrown,2)
    end
    
    self:_initCheckBox()
end

function HallOfFrameScene:onSceneEnter(...)
    self:_setConfrimNum()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HALLOFFRAME_INFO, self._recvInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HALLOFFRAME_CONFRIM, self._recvConfrim, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HALLOFFRAME_SIGN, self._recvSign, self)
    G_HandlersManager.hallOfFrameHandler:sendRequestUIInfo(TopTypeConst.TYPE_FIGHT)
end

function HallOfFrameScene:onSceneExit()
     uf_eventManager:removeListenerWithTarget(self)
end

--@desc 收到签名
function HallOfFrameScene:_recvSign(data)
     if data.ret == G_NetMsgError.RET_OK then
        local list = nil
        if self.selectType == TopTypeConst.TYPE_FIGHT then
            list = self.FightList
        else
            list = self.LvList
        end
        
        for i=1,#list do 
            if list[i].id == G_Me.userData.id then
                list[i].info = data.info
                self._layer:getLabelByName("Label_Tips" .. i):setText(data.info)
            end
        end
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOP_SETSIGN_SUCC"))
    else
        --G_MovingTip:showMovingTip(require("app.cfg.net_msg_error").get(data.ret))
     end
end
--@desc 收到点赞
function HallOfFrameScene:_recvConfrim(data)
    if data.ret == G_NetMsgError.RET_OK then
        local list = nil
        if self.selectType == TopTypeConst.TYPE_FIGHT then
            list = self.FightList
        else
            list = self.LvList
        end
        for i=1,#list do 
            if list[i].id == data.id then
                list[i].points = list[i].points+1
            end
        end
        
        for i=1,6 do
            local heartNumLabel = self._layer:getLabelByName("Label_Num" .. i)
            if heartNumLabel and heartNumLabel:getTag() == data.id then
                heartNumLabel:setText(list[i].points)
                self:_showHeartAction(i)
                break
            end
        end
    end
    
    self.num = self.num - 1
    G_MovingTip:showMovingTip(G_lang:get("LANG_TOP_CONFIRM_SUCC"))
    self:_setConfrimNum()
    
end

--@点赞特效
function HallOfFrameScene:_showHeartAction(_index)
       local  _effect = require("app.common.effects.EffectNode").new("effect_heart")
       local _panel = self._layer:getPanelByName("Panel_4")
        _panel:addNode(_effect, 10,10)
        _effect:play()
        local heart = self._layer:getButtonByName("Button_Heart" .. _index)
        if heart then
            local pt = heart:getPositionInCCPoint()
            local _x,_y = 0,0
            local _ptx,_pty = 0,0 
            _x,_y = heart:getParent():convertToWorldSpaceXY(pt.x-30,pt.y+70,_x,_y)
            _ptx,_pty = _panel:convertToNodeSpaceXY(_x,_y,_ptx,_pty)
            _effect:setPosition(ccp(_ptx,_pty))
        end

end

function HallOfFrameScene:_setConfrimNum()
    G_Me.userData:setHofPoints(self.num)
    local numLabel = self._layer:getLabelByName("Label_ConfirmNum")
    if numLabel then
        numLabel:setText(GlobalFunc.ConvertNumToCharacter(self.num))
        numLabel:createStroke(Colors.strokeBrown,2)
    end
 
end

--@desc 收到名人堂信息
function HallOfFrameScene:_recvInfo(data)
    self.num = data.points
    if data.kind == TopTypeConst.TYPE_FIGHT then
        for i=1,#data.infos do
            table.insert(self.FightList,data.infos[i])
        end
        self:_initInfo(self.FightList)
    else
        for i=1,#data.infos do
            table.insert(self.LvList,data.infos[i])
        end
        self:_initInfo(self.LvList)
    end
    self:_setConfrimNum()
end

function HallOfFrameScene:_initCheckBox()
    self._layer:addCheckBoxGroupItem(1, "CheckBox_Fight")
    self._layer:addCheckBoxGroupItem(1, "CheckBox_Lv")
    self._layer:setCheckStatus(1, "CheckBox_Fight")
    self._layer:getImageViewByName("Image_Lv"):setOpacity(self.selectType == TopTypeConst.TYPE_LV and 255 or 150)
    self._layer:registerCheckboxEvent("CheckBox_Fight", function ( widget, type, isCheck )
            if self.selectType == TopTypeConst.TYPE_LV then
                self:_switchType()
            end
    end)
    self._layer:registerCheckboxEvent("CheckBox_Lv", function ( widget, type, isCheck )
            if self.selectType == TopTypeConst.TYPE_FIGHT then
                self:_switchType()
            end
    end)
    
end

--战力与等级切换
function HallOfFrameScene:_switchType()
    if self.selectType == TopTypeConst.TYPE_FIGHT then
        self.selectType = TopTypeConst.TYPE_LV
        if #self.LvList == 0 then
            G_HandlersManager.hallOfFrameHandler:sendRequestUIInfo(TopTypeConst.TYPE_LV)
        else
            self:_initInfo(self.LvList)
        end
    else
        self.selectType = TopTypeConst.TYPE_FIGHT
        self:_initInfo(self.FightList)
    end
    self._layer:getImageViewByName("Image_Lv"):setOpacity(self.selectType == TopTypeConst.TYPE_LV and 255 or 150)
    self._layer:getImageViewByName("Image_Fight"):setOpacity(self.selectType == TopTypeConst.TYPE_FIGHT and 255 or 150)
end

function HallOfFrameScene:_initInfo(data)
    if data ==nil or #data == 0 then
        return
    end
    local panel = self._layer:getPanelByName("Panel_4")
    panel:setVisible(true)
    self._layer:adapterWidgetHeightWithOffset("Panel_4", 80, 20)
    self.tipsList = {}
    
    for i=1,6 do
        local basePanel = self._layer:getPanelByName("Panel_Player" .. i)
        if data[i] == nil then
            basePanel:setVisible(false)
        else
            basePanel:setVisible(true)

            -- 形象
            local knightInfo = knight_info.get(data[i].base_id)
            if knightInfo then
                local headImg = self._layer:getImageViewByName("head_" .. i)
                if headImg then
                    headImg:removeFromParent()
                else
                    
                end

                local resid = G_Me.dressData:getDressedResidWithClidAndCltm(data[i].base_id,data[i].dress_id,data[i].clid,data[i].cltm,data[i].clop)
                -- local node = knightPic.createKnightButton(resid, basePanel, "head_" .. i,self._layer,nil, true)
                local node = knightPic.createBattleKnightPic(resid, basePanel, "head_" .. i, true)
                -- node:setScale(0.5)     
                node:setScale(1)     
                local posx,posy = node:getPosition()
                node:setPosition(ccp(posx,posy+100))

                self._layer:getImageViewByName("head_" .. i):setTag(data[i].id)
                self._layer:getButtonByName("Button_Heart" .. i):setTag(data[i].id)
                
                local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
                EffectSingleMoving.run(node, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*30))
                
                --玩家名字
                local nameLabel = self._layer:getLabelByName("Label_Name" .. i)
                if nameLabel then
                    nameLabel:setText(data[i].name)
                    nameLabel:setColor(Colors.qualityColors[knightInfo.quality])
                    nameLabel:createStroke(Colors.strokeBrown,2)
                end

                --玩家名字
                local leaveMsgLabel = self._layer:getLabelByName("Label_Title" .. i)
                if leaveMsgLabel then
                    leaveMsgLabel:setText(G_lang:get("LANG_TOP_LEAVEMSG"))
                    leaveMsgLabel:createStroke(Colors.strokeBrown,2)
                end
                
                --战力或等级
                local valueLabel = self._layer:getLabelByName("Label_FightValue" .. i)
                if valueLabel then
                    if self.selectType == TopTypeConst.TYPE_FIGHT then
                        valueLabel:setText(G_lang:get("LANG_INFO_FIGHT") .. " " .. GlobalFunc.ConvertNumToCharacter(data[i].value))
                    else
                        valueLabel:setText(G_lang:get("LANG_INFO_LV") .. " " .. GlobalFunc.ConvertNumToCharacter(data[i].value))
                    end
                    valueLabel:createStroke(Colors.strokeBrown,2)
                end
            
                -- 添加tips动画列表
                local imgTips = self._layer:getImageViewByName("Image_Tips" .. i)
                self._layer:getImageViewByName("Image_Tips" .. i):setVisible(false)
                if imgTips   then
                    imgTips:stopAllActions()
                    if data[i].info ~= "" then
                        table.insert(self.tipsList,imgTips)
                    end
                    local pt = valueLabel:getPositionInCCPoint()
                    local _x,_y = 0,0
                    local _ptx,_pty = 0,0 
                    _x,_y = valueLabel:getParent():convertToWorldSpaceXY(pt.x,pt.y-20,_x,_y)
                    _ptx,_pty = panel:convertToNodeSpaceXY(_x,_y,_ptx,_pty)
                    imgTips:setPositionY(_pty)
                end
            end

            -- 编辑签名
            self._layer:getButtonByName("Button_Sign" .. i):setVisible(G_Me.userData.id  == data[i].id)
            
            --点赞数量
            local numLabel = self._layer:getLabelByName("Label_Num" .. i)
            if numLabel then
                numLabel:setText(data[i].points)
                numLabel:setTag(data[i].id)
                numLabel:createStroke(Colors.strokeBrown,2)
            end

            --宣言
            local tipsLabel = self._layer:getLabelByName("Label_Tips" .. i)
            if tipsLabel then
                tipsLabel:setText(data[i].info)
                tipsLabel:setVisible(true)
            end
            
            
            end
    end
    
    if #self.tipsList > 0 then
        self:_playShowTips()
    end

        
end

function HallOfFrameScene:_playShowTips()
    for i=1,#self.tipsList do
        self.tipsList[i]:stopAllActions()
        self.tipsList[i]:setScale(0)
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create((i-1)*4))
        arr:addObject(CCShow:create())
        -- arr:addObject(CCScaleTo:create(0.25,1))
        arr:addObject(CCEaseBounceOut:create(CCScaleTo:create(0.5,1)))
        -- arr:addObject(CCDelayTime:create(2.5))
        arr:addObject(CCDelayTime:create(2.25))
        arr:addObject(CCScaleTo:create(0.25,0))
        if #self.tipsList == 1 then
            arr:addObject(CCDelayTime:create(4))
        else
            arr:addObject(CCDelayTime:create((#self.tipsList-i)*4))
        end
        self.tipsList[i]:runAction(CCRepeatForever:create(CCSequence:create(arr)))
    end
end

function HallOfFrameScene:_onClickKnight(widget)
    if widget then
         local tag = widget:getTag()
         if tag == G_Me.userData.id then
             self:addChild(require("app.scenes.hallofframe.TopManifestoLayer").create())
         else
             if self.num>0 then
                 G_HandlersManager.hallOfFrameHandler:sendRequestConfirm(tag)
             else -- 点赞次数用完
                 G_MovingTip:showMovingTip(G_lang:get("LANG_TOP_CONFIRM_OUT"))
             end
         end
     end 
end

return HallOfFrameScene


