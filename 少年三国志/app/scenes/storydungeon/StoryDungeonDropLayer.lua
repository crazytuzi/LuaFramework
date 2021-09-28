local StoryDungeonDropLayer = class("StoryDungeonDropLayer",UFCCSModelLayer)


function StoryDungeonDropLayer:ctor( ...)
    self.super.ctor(self, ...)
    self:adapterWithScreen()
    local _knightId = G_Me.storyDungeonData:getCurrBarrierId()
    local _data = story_barrier_info.get(_knightId)
    

--    local head = require("app.scenes.common.KnightPic").getHalfNode(_data.res_id,0, true)
    local head = require("app.scenes.common.KnightPic").createKnightPic(_data.res_id,self:getPanelByName("Panel_Knight"),"head",false)
    head:setScale(0.8)

    head:setPositionX(self:getPanelByName("Panel_Knight"):getContentSize().width*0.4)
    head:setPositionY(self:getPanelByName("Panel_Knight"):getContentSize().height*0.56)

    self:showTextWithLabel("Label_knight_name", _data.name)
    

    self:getLabelByName("Label_VitValue"):setText(G_lang:get("LANG_STORYDUNGEON_COSTVIT",{num=_data.strenth_cost}))

    self:getLabelByName("Label_PassBouns"):setText(G_lang:get("LANG_STORYDUNGEON_PASSBOUNS"))
    
    
    -- 布阵
    self:registerBtnClickEvent("Button_BuZhen",function()
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
    end)
    
    require("app.cfg.role_info")
    local roleData = role_info.get(G_Me.userData.level)
    self:getLabelByName("Label_Comment"):setText(_data.direction)
    self:getLabelByName("Label_GoldValue"):setText(_data.first_down_money)

    local nPveMoney = _data.strenth_cost / 5 * roleData.pve_money
    local nPveExp = _data.strenth_cost / 5 * roleData.pve_exp
    self:getLabelByName("Label_MoneyValue"):setText(nPveMoney)
    self:getLabelByName("Label_ExpValue"):setText(nPveExp)

    --新手光环经验
    self:getLabelByName("Label_rookieInfo"):setText(
        G_Me.rookieBuffData:checkInBuff() and G_lang:get("LANG_ROOKIE_BUFF_PERIOD") or "")
    self:getLabelByName("Label_rookieBuffValue"):setText(G_Me.userData:getExpAdd(nPveExp)) 
  
    local gateNameLabel = self:getLabelByName("Label_GateName")
    if gateNameLabel then
        gateNameLabel:setText(_data.name)
        gateNameLabel:createStroke(Colors.strokeBrown,2)
    end
    self:getLabelByName("Label_GoldValue"):createStroke(Colors.strokeBrown,2)
    --self:getLabelByName("Label_PassBouns"):createStroke(Colors.strokeBrown,2)

    
    self:registerKeypadEvent(true)
    self:registerBtnClickEvent("Button_Close",handler(self,self.onClose))
    
    -- 把按钮上的文字图片绑定在按钮上使其具有相同的灰态效果
    self:attachImageTextForBtn("Button_Battle", "ImageView_6607")
    self:attachImageTextForBtn("Button_Battle", "Image_48")
    self:registerBtnClickEvent("Button_Battle",handler(self,self.onBattle))
    

    for i=1, 2 do
        local _info = G_Goods.convert(_data["drop" .. i .. "_type"],_data["drop" .. i .. "_value"])
        if _info then
            local _Img = self:getImageViewByName("ImageView_GoodBg" .. i)
            if _data["drop" .. i .. "_type"] > 0 then
                
                local double = 1
                
                local goodNameLabel = self:getLabelByName("Label_BounsName" .. i)
                if goodNameLabel then
                    goodNameLabel:setColor(Colors.getColor(_info.quality))
                    goodNameLabel:setText(_info.name)
                    goodNameLabel:createStroke(Colors.strokeBrown,2)
                end
                
                local numLabel = self:getLabelByName("Label_BounsNum" .. i)
                if numLabel then
                    numLabel:setText(G_lang:get("LANG_STORYDUNGEON_DROPINFO",{num=(_data["drop" ..i ..  "_num"]*double) .. "~" .. (_data["drop" ..i ..  "_num_2"]*double)}))
                end

                self:getImageViewByName("ImageView_Goods" .. i):loadTexture(_info.icon)
                _Img:loadTexture(G_Path.getEquipColorImage(_info.quality,_info.type))
                _Img:setTag(i)
                self:getImageViewByName("ImageView_GoodBaseBg" .. i):setVisible(true)
                self:registerWidgetTouchEvent("ImageView_GoodBg" .. i,handler(self,self._onTuchGoods))

                self:getImageViewByName("ImageView_GoodBaseBg" .. i):loadTexture(G_Path.getEquipIconBack(_info.quality))
            end
        else
            self:getImageViewByName("ImageView_GoodBaseBg" .. i):setVisible(false)
            self:getImageViewByName("Image_GoodBorderBg" .. i):setVisible(false)
        end
    end
    
end

function StoryDungeonDropLayer:onBackKeyEvent( ... )
    self:onClose()
    return true
end

-- @desc 点击物品，查看具体信息
function StoryDungeonDropLayer:_onTuchGoods(widget,_type)
     if _type == TOUCH_EVENT_ENDED then
         
        local _knightId = G_Me.storyDungeonData:getCurrBarrierId()
        local _data = story_barrier_info.get(_knightId)
         require("app.scenes.common.dropinfo.DropInfo"
         ).show(_data["drop" .. widget:getTag() .. "_type"],_data["drop" .. widget:getTag() .. "_value"])
     end
end

function StoryDungeonDropLayer.create()
    return StoryDungeonDropLayer.new("ui_layout/storydungeon_StoryDungeonDropLayer.json",Colors.modelColor)
end

function StoryDungeonDropLayer:onClose(widget)
    self:animationToClose()
end

function StoryDungeonDropLayer:onBattle(widget)
    local CheckFunc = require("app.scenes.common.CheckFunc")
    --[[
    if CheckFunc.checkKnightFull() == true then
        return
    end
    ]]
    local scenePack = G_GlobalFunc.sceneToPack("app.scenes.storydungeon.StoryDungeonMainScene", {})
    if CheckFunc.checkEquipmentFull(scenePack) == true then
        return
    end
    
    -- 检查体力是否足够
    local _knightId = G_Me.storyDungeonData:getCurrBarrierId()
    local _data = story_barrier_info.get(_knightId)
    if G_Me.userData.vit >= _data.strenth_cost then
        if G_Me.storyDungeonData:getExecutecount() > 0 then
            if G_Me.storyDungeonData:isChallenge(G_Me.storyDungeonData:getCurrDungeonId(),_data.id) == true then
                 -- 每天只能挑战一次
                 G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_MINGTIANZAILAI"))
            else
                local StoryDungeonConst = require("app.const.StoryDungeonConst")
                G_Me.storyDungeonData:setBranch(StoryDungeonConst.BRANCH.NORMAL)
                widget:setTouchEnabled(false)
                uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_STORYDUNGEON_REQUESTBATTLE, nil, false, nil)
            end
        else
             -- 挑战次数不足，今天已经不能挑战
            G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_TIANZHANCISHUYONGWAN"))
        end

        self:animationToClose() 
    else 
        -- 体力不足,提示购买体力
        G_GlobalFunc.showPurchasePowerDialog(1)
    end

end

function StoryDungeonDropLayer:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_110"), "smoving_bounce")
end
return StoryDungeonDropLayer

