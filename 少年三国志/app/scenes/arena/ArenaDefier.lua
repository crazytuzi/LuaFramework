local ArenaDefier = class("ArenaDefier",function()
    return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/arena_ArenaDefier.json")
end)

local FunctionLevelConst = require "app.const.FunctionLevelConst"
local AwardConst = require("app.const.AwardConst")
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.knight_info")

function ArenaDefier:ctor(user,layer,challengesFunc,...)

    self._user = nil
    self._rankLabel = UIHelper:seekWidgetByName(self,"Label_rank")
    -- self._shengwangLabel = UIHelper:seekWidgetByName(self,"Label_shengwang")
    -- self._moneyLabel = UIHelper:seekWidgetByName(self,"Label_money")
    self._awardLabel = UIHelper:seekWidgetByName(self,"Label_awards")
    self._levelLabel = UIHelper:seekWidgetByName(self,"Label_level")
    self._nameLabel = UIHelper:seekWidgetByName(self,"Label_name")	
    self._knightPanel = UIHelper:seekWidgetByName(self,"Panel_knight")
    self._effectPanel = UIHelper:seekWidgetByName(self,"Panel_effect")
    -- self._knightImage = UIHelper:seekWidgetByName(self,"ImageView_knight")
    self._petPanel = UIHelper:seekWidgetByName(self, "Panel_Pet")
    
    
    self._rankLabel = tolua.cast(self._rankLabel,"Label")
    self._levelLabel = tolua.cast(self._levelLabel,"Label")
    self._nameLabel = tolua.cast(self._nameLabel,"Label")
    self._awardLabel = tolua.cast(self._awardLabel,"Label")
    -- self._knightImage = tolua.cast(self._knightImage,"ImageView")

    --旗帜
    self._qizhiButton =  UIHelper:seekWidgetByName(self,"Button_qizhi")
    self._qizhiButton = tolua.cast(self._qizhiButton,"Button")

    --描边
    self._awardLabel:createStroke(Colors.strokeBrown,1)
    self._rankLabel:createStroke(Colors.strokeBrown,1)
    self._levelLabel:createStroke(Colors.strokeBrown,1)
    self._nameLabel:createStroke(Colors.strokeBrown,1)

    -- 战五次按钮
    self._fiveChallengesBtn = UIHelper:seekWidgetByName(self, "Button_Fight_5Times")
    self._fiveChallengesBtn = tolua.cast(self._fiveChallengesBtn, "Button")

    -- 战胜以后的笑脸
    self._faceWin = UIHelper:seekWidgetByName(self, "Image_Face_Win")
    self._faceWin:setScale(0.9)
    self._faceWin:setVisible(false)
    -- 防守成功的吐舌卖萌
    self._faceDefenseWin = UIHelper:seekWidgetByName(self, "Image_Defense_Win")
    self._faceDefenseWin:setScale(0.9)
    self._faceDefenseWin:setVisible(false)
    self._leftPos = ccp(70, 176)
    self._rightPos = ccp(170, 176)

    -- 垃圾话
    self._trashTalkDialog = UIHelper:seekWidgetByName(self, "Image_Dialog")
    self._trashTalkLabel = UIHelper:seekWidgetByName(self, "Label_Dialog")
    self._trashTalkLabel = tolua.cast(self._trashTalkLabel, "Label")

    self._trashTalkDialogPosX = 157

    self._fiveChallengesPosLeft = 60
    self._fiveChallengesPosRight = 210

end

--[[
	challengesFunc 发起挑战函数
]]
function ArenaDefier:update(isLeft,user,layer,challengesFunc)
    self:removeKnight()
    self:stopEffect()
    self._user = user
    local petBaseId = 0
    local petInfo = nil
    if rawget(user, "pet_base_id") then
        petBaseId = user.pet_base_id
        require("app.cfg.pet_info")
        petInfo = pet_info.get(user.pet_base_id)
    end
    if petBaseId > 0 and petInfo then        
        self._petPanel:removeAllNodes()
        self._petPanel:setVisible(true)
        local petPath = G_Path.getPetReadyEffect(petInfo.ready_id)
        self._petImg = EffectNode.new(petPath)
        self._petImg:setScale(0.3)
        self._petPanel:addNode(self._petImg)
        self._petImg:play()
    else
        self._petPanel:setVisible(false)
    end
    
    local knightPic = require("app.scenes.common.KnightPic")
--    __LogTag(TAG,"user.base_id = %s",user.base_id)
    local knight = knight_info.get(user.base_id)
    if not knight then
        return
    end
    local goods01 = AwardConst.getAwardGoods01(user.rank)
    local goods02 = AwardConst.getAwardGoods02(user.rank)
    local text = ""
    if goods01 ~= nil then
        text = goods01.name .. " " .. goods01.size .. ","
    end
    if goods02 ~= nil then
        text = text .. goods02.name .. " " .. goods02.size
    end


    self._rankLabel:setText(G_lang:get("LANG_RANK",{rank=user.rank}))
    if self:isMySelf(user) then
        --如果是自己，采用自己的战力，避免战力值不一致
        local fight_value = G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.fight_value)
        self._levelLabel:setText(G_lang:get("LANG_MOSHEN_ATTACK_VALUE",{rank=fight_value}))

        -- 战5次
        self._fiveChallengesBtn:setVisible(false)

        self:hideTrashTalkDialog()
    else
        local fight_value = G_GlobalFunc.ConvertNumToCharacter(user.fight_value)
        self._levelLabel:setText(G_lang:get("LANG_MOSHEN_ATTACK_VALUE",{rank=fight_value}))

        -- 战5次
        if layer.getMyRank and user.rank < layer:getMyRank() then
            self._fiveChallengesBtn:setVisible(false)
        elseif G_moduleUnlock:canPreviewModule(FunctionLevelConst.ARENA_FIVE_CHALLENGE) then 
            self._fiveChallengesBtn:setVisible(true)
        else
            self._fiveChallengesBtn:setVisible(false)
        end

        -- 垃圾话
        if layer.getTrashDialogRank and layer:getTrashDialogRank() == user.rank then
            -- self:showTrashTalkDialog()
        else
            self:hideTrashTalkDialog()
        end

    end

    if isLeft then
        self._fiveChallengesBtn:setPositionX(self._fiveChallengesPosLeft)
    else
        self._fiveChallengesBtn:setPositionX(self._fiveChallengesPosRight)
    end

    self._nameLabel:setText(user.name)
    if user.rank <= 1000 then
        self._awardLabel:setText(G_lang:get("LANG_ARENA_AWARD_PER_DAY",{text=text}))
    else
        self._awardLabel:setText(G_lang:get("LANG_NO_AWARD_TIPS"))
    end

    --不显示了,排名奖励
    self._awardLabel:setVisible(false)

    if self._knightImageView ~= nil then
        self._knightPanel:removeAllChildrenWithCleanup(true)
    end 
    self._qizhiButton:setName("qizi" .. user.user_id .. user.rank)
    layer:registerBtnClickEvent(self._qizhiButton:getName(),function()
        if challengesFunc ~= nil then
            challengesFunc(self)
        end
        end)

    local res_id = G_Me.dressData:getDressedResidWithClidAndCltm(user.base_id,user.dress_base,user.clid,user.cltm,user.clop)
    self._knightImageView = knightPic.createKnightButton(res_id,self._knightPanel,"" .. user.user_id .. user.rank,layer,function()
        if challengesFunc ~= nil then
            challengesFunc(self)
        end
    end,true)

    if self:isMySelf(user) then 
        if user.rank <= 10 then
            self._qizhiButton:loadTextureNormal("ui/arena/qizi_own_qianshi.png",UI_TEX_TYPE_LOCAL)
        else
            self._qizhiButton:loadTextureNormal("ui/arena/qizi_own.png",UI_TEX_TYPE_LOCAL)
        end 
    else
        if user.rank <= 10 then
            self._qizhiButton:loadTextureNormal("ui/arena/qizi_normal_qianshi.png",UI_TEX_TYPE_LOCAL)
        else
            self._qizhiButton:loadTextureNormal("ui/arena/qizi_normal.png",UI_TEX_TYPE_LOCAL)
        end 
    end

    -- challenge five times button
    self._fiveChallengesBtn:setName("five_challenges" .. user.user_id .. user.rank)
    layer:registerBtnClickEvent(self._fiveChallengesBtn:getName(), function ( ... )
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.ARENA_FIVE_CHALLENGE) then
            -- do nothing
        elseif G_Me.userData.spirit < 2 then
            G_GlobalFunc.showPurchasePowerDialog(2)
            return
        else
            local scene = require("app.scenes.arena.ArenaChallenge5TimesScene").new(user.rank)
            -- uf_sceneManager:replaceScene(scene)
            uf_sceneManager:pushScene(scene)
        end
    end)

    self._knightPanel:setScale(0.35)
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    self._smovingEffect = EffectSingleMoving.run(self._knightPanel, "smoving_idle", nil, {})
end

function ArenaDefier:playDefierAnimation(user01,user02,isLeft,callback)
    if self.ani == nil then
        local isLeftString = (isLeft == true) and "left" or "right"
        local res01 = 0;
        local res02 = 0;
        local kni01 = knight_info.get(user01.base_id)
        if not kni01 then
            return
        end
        res01 = G_Me.dressData:getDressedResidWithClidAndCltm(user01.base_id,user01.dress_base,user01.clid,user01.cltm , user01.clop)

        local kni02 = knight_info.get(user02.base_id)
        if not kni02 then
            return
        end
        res02 = G_Me.dressData:getDressedResidWithClidAndCltm(user02.base_id,user02.dress_base , user02.clid, user02.cltm ,user02.clop)


        local kni01 = knight_info.get(id01)
        local kni02 = knight_info.get(id02)
        self.ani = require("app.scenes.arena.ArenaHeroAnimation").create(res01, res02, isLeftString, function() 
            self._knightPanel:setVisible(true)
            if callback  ~= nil then 
                callback() 
            end
            self.ani:removeFromParentAndCleanup(true)
            self.ani = nil
            end)
        self._knightPanel:setVisible(false)
        self._effectPanel:addNode(self.ani)
    end

end



function ArenaDefier:stopEffect()
    if self.effectNode ~= nil then
        self:getEffectNode():removeChild(self.effectNode)
    end
end

function ArenaDefier:destory()
    self:removeKnight()
    if self.effectNode ~= nil then
        self:removeChild(self.effectNode)
    end
    if self._qizhiButton ~= nil then
        self:removeChild(self._qizhiButton)
    end
end



function ArenaDefier:isMySelf(user)
    if user == nil then
        return false
    end
    return user.user_id == G_Me.userData.id
end

function ArenaDefier:setQiZhiVisible(visible)
    self._qizhiButton:setVisible(visible)
end


function ArenaDefier:removeKnight()
    if self._knightImageView ~= nil then
        self._knightPanel:removeChild(self._knightImageView)
        self._knightImageView = nil
    end
end



function ArenaDefier:getWidth()
    return self:getContentSize().width
end
function ArenaDefier:getHeight()
    return self:getContentSize().height
end

function ArenaDefier:getEffectNode()
	return UIHelper:seekWidgetByName(self,"Panel_dipan")  
end

function ArenaDefier:getQizhi()
    return self._qizhiButton
end

function ArenaDefier:setFaceWinVisible( isVisible, isLeft, isDefenseWin )
    local face = nil
    if isDefenseWin then
        face = UIHelper:seekWidgetByName(self, "Image_Defense_Win")
    else
        face = UIHelper:seekWidgetByName(self, "Image_Face_Win")
    end

    face:stopAllActions()
    face:setVisible(isVisible)
    if isVisible then

        face:setOpacity(255)

        if isLeft then
            face:setPosition(self._leftPos)
        else
            face:setPosition(self._rightPos)
        end

        local arr = CCArray:create()

        local moveUp = CCMoveBy:create(0.8, ccp(0, 10))
        local moveDown = CCMoveBy:create(0.8, ccp(0, -10))
        local moveUpAndDown = CCSequence:createWithTwoActions(moveUp, moveDown)
        local repeatMove = CCRepeatForever:create(moveUpAndDown)
        face:runAction(repeatMove)
        
        local delay = CCDelayTime:create(2.0)
        local fadeOut = CCFadeOut:create(1)
        arr:addObject(delay)
        arr:addObject(fadeOut)

        local seqAction = CCSequence:create(arr)
        face:runAction(seqAction)
    end
end

function ArenaDefier:showTrashTalkDialog(isRankHigher, isLeft )

    -- __Log("=================ArenaDefier:showTrashTalkDialog======================")

    if isLeft then
        self._trashTalkDialog:setRotationY(180)
        self._trashTalkLabel:setRotationY(180)
        local width = self._trashTalkDialog:getSize().width
        local prePos = self._trashTalkDialog:getPositionX()
        self._trashTalkDialog:setPositionX(prePos - 60)
    end

    self._trashTalkDialog:setVisible(true)
    self._trashTalkDialog:setScale(0.2)

    local bounceOut = CCEaseBounceOut:create(CCScaleTo:create(0.5, 0.8))
    self._trashTalkDialog:runAction(bounceOut)

    require ("app.cfg.arena_chat_info")

    local chatType1List = {}
    local chatType2List = {}
    for i = 1, arena_chat_info.getLength() do
        local chatInfo = arena_chat_info.get(i)
        if chatInfo.type == 1 then
            table.insert(chatType1List, chatInfo)
        else
            table.insert(chatType2List, chatInfo)
        end
    end

    math.randomseed(os.time())
    if isRankHigher then 
        local index = math.random(1, #chatType1List)
        self._trashTalkLabel:setText(chatType1List[index].chat)
    else
        local index = math.random(1, #chatType2List)
        self._trashTalkLabel:setText(chatType2List[index].chat)
    end

end

function ArenaDefier:hideTrashTalkDialog( ... )
    self._trashTalkDialog:setVisible(false)

    self._trashTalkDialog:setPositionX(self._trashTalkDialogPosX)
    self._trashTalkDialog:setRotationY(0)
    self._trashTalkLabel:setRotationY(0)
end

--获取武将的矩形,世界坐标系
function ArenaDefier:getKnightRect()
    if self._knightImageView == nil then
        return CCRectMake(0,0,0,0)
    end
    local point = self._knightPanel:getParent():convertToWorldSpace(ccp(self._knightPanel:getPosition()))
    local size = self._knightImageView:getContentSize()
    local scale = self._knightImageView:getScale()
    return CCRectMake(point.x-size.width*scale/2,point.y/2,size.width*scale,size.height*scale)
end


return ArenaDefier

