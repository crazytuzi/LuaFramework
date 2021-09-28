require("app.cfg.hard_dungeon_info")

require("app.cfg.item_info")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
require("app.cfg.function_level_info")
local Colors = require("app.setting.Colors")

local HardDungeonEnterGateLayer = class("HardDungeonEnterGateLayer", UFCCSModelLayer)

local function _setStroke(parent,labelName,num)
    local _name = parent:getLabelByName(labelName)
    if _name then 
        _name:createStroke(Colors.strokeBrown,num)
    end
end

function HardDungeonEnterGateLayer:onBackKeyEvent( ... )
    self:_closeWindow()
    return true
end

function HardDungeonEnterGateLayer.create(stageId,lastStarNum,callback, ...)
    return HardDungeonEnterGateLayer.new("ui_layout/dungeon_Hard_DungeonEnterGateLayer.json",Colors.modelColor,stageId,lastStarNum,callback, ...)
end

function HardDungeonEnterGateLayer:ctor(json, color, stageId, lastStarNum, callback, ...)
    self.super.ctor(self, json, color, ...)
    self:adapterWithScreen()
    self._timer = nil
    self._callback = callback
    self._stageId = stageId
    self._lastStarNum = lastStarNum
    self:registerBtnClickEvent("closebtn",handler(self,self._closeWindow))
    self:registerBtnClickEvent("Button_Challenge",handler(self,self._onChallenge))
    self:registerBtnClickEvent("Button_Seckill",handler(self,self._onSeckill))
    self:registerBtnClickEvent("Button_BuZhen",handler(self,self._onBuZhen))
    self.fastTimes = 0
    local _stageData = hard_dungeon_stage_info.get(self._stageId)
    local _dungeonInfo = G_GlobalFunc.getHardDungeonData(_stageData.value)
    self:registerKeypadEvent(true)
    -- 关卡名称
    self:showTextWithLabel("Label_Name", _stageData.name)
    --关卡执行次数
    local _data = G_Me.hardDungeonData:getStageById(self._stageId)
    
    for i=1,3 do
        if i <= _data._star then
            local _starImg = self:getImageViewByName("ImageView_star" .. i)
            _starImg:loadTexture(G_Path.DungeonIcoType.STAR,UI_TEX_TYPE_PLIST)
        end
    end
    
    -- 显示怪物图片
    local head = require("app.scenes.common.KnightPic").createKnightPic(_stageData.image,self:getPanelByName("Panel_4"),"head",false)
    head:setScale(0.8)
    head:setPositionX(self:getPanelByName("Panel_4"):getContentSize().width*0.4)
    head:setPositionY(self:getPanelByName("Panel_4"):getContentSize().height*0.56)
    
    -- 体力消耗
    require("app.cfg.role_info")
    local roleData = role_info.get(G_Me.userData.level)
    self:showTextWithLabel("Label_Silver",G_lang:get("LANG_SILVER") .. "：")
    self:showTextWithLabel("Label_Exp",G_lang:get("LANG_EXP") .. "：")
    if roleData then
        -- 经验获得
        local nExp = math.floor(_dungeonInfo.cost / 5) * roleData.pve_exp
        self:showTextWithLabel("Label_ExperienceValue", nExp)
        -- 获得银两
        local nMoney = math.floor(_dungeonInfo.cost / 5) * roleData.pve_money
        self:showTextWithLabel("Label_SilverValue", nMoney) 

        self:getLabelByName("Label_rookieBuffValue"):setText(G_Me.userData:getExpAdd(nExp))
    end
    
    self:showTextWithLabel("Label_TiCost", G_lang:get("LANG_DUNGEON_COSTVIT"))
    self:showTextWithLabel("Label_TiCostValue", _dungeonInfo.cost)
    self:showTextWithLabel("Label_MaybeGet", G_lang:get("LANG_DUNGEON_MAYBEGET"))
    self:showTextWithLabel("Label_TongGuanJiangLi",G_lang:get("LANG_STORYDUNGEON_PASSBOUNS"))
    self:showTextWithLabel("Label_Desc", _dungeonInfo.talk)
    self:showTextWithLabel("Label_PassGet", G_lang:get("LANG_DUNGEON_PASSGET"))
    self:showTextWithLabel("Label_config", G_lang:get("LANG_HARD_DUNGEON_DOUBLE"))

    local x,y = self:getLabelByName("Label_TiCostValue"):getPosition()
    self:getLabelByName("Label_TiCostValue"):setPosition(ccp(x, y-2))

    if G_Me.activityData.custom.isDungeonActive and G_Me.activityData.custom:isDungeonActive() then
        self:getLabelByName("Label_config"):setVisible(true)
    else
        self:getLabelByName("Label_config"):setVisible(false)
    end
    
    _setStroke(self, "Label_PingJia",1)
    _setStroke(self, "Label_TongGuanJiangLi",1)
    _setStroke(self, "Label_Name",2)
--    _setStroke(self, "Label_ChallengeTimesValue")
    self:showExeCount()
    self:_initDrop(_stageData)
    self:_initSeckillStatus()
end


function HardDungeonEnterGateLayer:showExeCount()
    local _stageData = hard_dungeon_stage_info.get(self._stageId)
    local _dungeonInfo = G_GlobalFunc.getHardDungeonData(_stageData.value)
    local _data = G_Me.hardDungeonData:getStageById(self._stageId)
    -- 1.先根据当前体力，算出可扫荡次数
    --2.当剩余挑战次数>可扫荡次数时，显示可扫荡次数
    --3.当剩余挑战次数<可扫荡次数时，显示剩余挑战次数
    self.fastTimes = _data._executeCount> 10 and 10 or _data._executeCount
    local nums = math.modf(G_Me.userData.vit/_dungeonInfo.cost)
    if nums <  self.fastTimes and nums > 0 then
         self.fastTimes = nums
    end
    self:getLabelBMFontByName("BitmapLabel_Times"):setText(_data._executeCount > 0 and G_lang:get("LANG_DUNGEON_FASTTIMES",
    {num=  self.fastTimes}) or G_lang:get("LANG_DUNGEON_RESET"))
    self:showTextWithLabel("Label_ChallengeTimes", G_lang:get("LANG_DUNGEON_TODAYCHALLENGE",{num = string.format("%d/%d",_data._executeCount,_dungeonInfo.num)}))
end


function HardDungeonEnterGateLayer:_restDungeon()
    --self:close()
      local _seckillBtn = self:getButtonByName("Button_Seckill")
      if _seckillBtn then
        _seckillBtn:setTouchEnabled(false)
      end
    G_HandlersManager.hardDungeonHandler:sendResetDungeonExecution(self._stageId)
end


function HardDungeonEnterGateLayer:_closeWindow()
    self:animationToClose() 
end

function HardDungeonEnterGateLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

function HardDungeonEnterGateLayer:onLayerEnter()
    self:closeAtReturn(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_DUNGEONRESTSUCC, self.restDungeonSucc, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self.showExeCount, self)
    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_762"), "smoving_bounce")

    -- 播放NPC声音
    self:_playStageSound()
end

function HardDungeonEnterGateLayer:restDungeonSucc()
     self:showExeCount()
     self:_initSeckillStatus()
    local _seckillBtn = self:getButtonByName("Button_Seckill")

    if _seckillBtn then
    _seckillBtn:setTouchEnabled(true)
    end

end
-- 秒杀状态
function HardDungeonEnterGateLayer:_initSeckillStatus()
    local _stageData = G_Me.hardDungeonData:getStageById(self._stageId)
    if _stageData then
        local _seckillBtn = self:getButtonByName("Button_Seckill")
        _seckillBtn:setVisible(_stageData._isFinished)
        
        -- 如果没有通关，则将挑战按钮放置在中间位置
        if _stageData._isFinished == false then
            local _challengeBtn = self:getButtonByName("Button_Challenge")
            _challengeBtn:setPositionX(0)
        end
        
    end
end

-- 物品掉落
function HardDungeonEnterGateLayer:_initDrop(_stageData)
    if _stageData.type == 1 then
        -- 掉落道具
        local _dungeonInfo = G_GlobalFunc.getHardDungeonData(_stageData.value)
                
        function initGoods(_index,data)
            
            local _bg = self:getImageViewByName("ImageView_bouns" .. tostring(_index))
            local borderBg = self:getImageViewByName("Image_Border_Bg" .. tostring(_index))
            if data == nil then
                _bg:setVisible(false)
                borderBg:setVisible(false)
            elseif (G_Me.activityData.holiday.isHardActivate and (not G_Me.activityData.holiday:isHardActivate())) and G_Goods.checkHolidayGood(data)==1 then
                _bg:setVisible(false)
                borderBg:setVisible(false)
            elseif not G_Me.specialActivityData:isInActivityTime() and G_Goods.checkHolidayGood(data) == 2 then
                _bg:setVisible(false)
                borderBg:setVisible(false)
            else
                borderBg:setVisible(true)
                _bg:loadTexture(G_Path.getEquipIconBack(data.quality))
                local _parent = self:getImageViewByName("bouns" .. tostring(_index))
                _parent:loadTexture(G_Path.getEquipColorImage(data.quality,data.type))
                _parent:setTag(_index)
                 
                 local _numLabel = _parent:getChildByName("bounsnum")
                _numLabel = tolua.cast(_numLabel,"Label")
                _numLabel:setText("x" .. data.size)

                _numLabel:createStroke(Colors.strokeBrown,1)
                
                local _ico = self:getImageViewByName("ico" .. _index)
                _ico = tolua.cast(_ico,"ImageView")
                _ico:loadTexture(data.icon)
                self:registerWidgetTouchEvent("bouns" .. tostring(_index),handler(self,self.onClickGoods))

            end
        end
        
        initGoods(1,G_Goods.convert(_dungeonInfo.item1_type,_dungeonInfo.item1_value,_dungeonInfo.item1_size))
        initGoods(2,G_Goods.convert(_dungeonInfo.item2_type,_dungeonInfo.item2_value,_dungeonInfo.item2_size))
        initGoods(3,G_Goods.convert(_dungeonInfo.item3_type,_dungeonInfo.item3_value,_dungeonInfo.item3_size))
        initGoods(4,G_Goods.convert(_dungeonInfo.item4_type,_dungeonInfo.item4_value,_dungeonInfo.item4_size))
        initGoods(5,G_Goods.convert(_dungeonInfo.item5_type,_dungeonInfo.item5_value,_dungeonInfo.item5_size))
        initGoods(6,G_Goods.convert(_dungeonInfo.item6_type,_dungeonInfo.item6_value,_dungeonInfo.item6_size))
    else
        -- 掉落宝箱
    end
end

function HardDungeonEnterGateLayer:_showRestDungeonBox(cost,count)
    if count > 0 then
        local box = require("app.scenes.tower.TowerSystemMessageBox")
        box.showMessage( box.TypeMain,
            cost, count,
            self._restDungeon,
        nil, 
        self )
    else
        -- if G_Me.vipData:getNextData(7) ~= -1 then
        --     MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"),G_lang:get("LANG_DUGEON_REST_VIP",{num=G_Me.vipData:getNextData(7)}))
        -- else
        --     MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"),G_lang:get("LANG_DUNGEON_NOT_REST"))
        -- end
        G_GlobalFunc.showVipNeedDialog(require("app.const.VipConst").DUNGONRESET)
    end

end

function HardDungeonEnterGateLayer:_onChallenge(widget)
        --G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)

    local CheckFunc = require("app.scenes.common.CheckFunc")
    -- 没有武将掉落，所以不用检查
    --[[
    if CheckFunc.checkKnightFull() == true then
        return
    end
    ]]
    local nChapterId = G_Me.hardDungeonData:getCurrChapterId()
    -- 如果传nil则设备上会有问题
    local scenePack = G_GlobalFunc.sceneToPack("app.scenes.harddungeon.HardDungeonMainScene", {_, _, self._stageId, nChapterId})
    if CheckFunc.checkEquipmentFull(scenePack) == true then
        return
    end
    
    if self:_isEnoughVit(1) then
        local _stageData = G_Me.hardDungeonData:getStageById(self._stageId)
        if _stageData._executeCount >= 1 then
--            widget:setTouchEnabled(false)
--            self:getImageViewByName("ImageView_4774"):showAsGray(true)
                G_Me.hardDungeonData:setCurrStageId(self._stageId)
                G_Me.hardDungeonData:setCurrStageLastStar(self._lastStarNum)
                if self._callback then
                    self._callback()
                end
            self:close()
        else
            self:_showRestDungeonBox(_stageData.reset_cost,_stageData.reset_count)
        end
    else
        self:_showVit()
    end

    --widget:setTouchEnabled(false)
end

-- 体力不足
function HardDungeonEnterGateLayer:_showVit()
    G_GlobalFunc.showPurchasePowerDialog(1)
end


 -- 检查是否有足够体力
function HardDungeonEnterGateLayer:_isEnoughVit(times)
    if times > 10 then times = 10 end
    local  _stage_data = hard_dungeon_stage_info.get(self._stageId)
    
    if _stage_data == nil then 
        return false 
    end
    
    local _info = G_GlobalFunc.getHardDungeonData(_stage_data.value)
    if _info then
        if G_Me.userData.vit >= _info.cost*times then 
            return true  
        else
            return false
        end
    end
    return false
end

-- 布阵
function HardDungeonEnterGateLayer:_onBuZhen(widget)
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
    require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end

-- 扫荡
function HardDungeonEnterGateLayer:_onSeckill(widget)

        local _stageData = G_Me.hardDungeonData:getStageById(self._stageId)
    -- 重置
   if self:getLabelBMFontByName("BitmapLabel_Times"):getStringValue() == G_lang:get("LANG_DUNGEON_RESET") then
       self:_showRestDungeonBox(_stageData.reset_cost,_stageData.reset_count)
   else
        if _stageData._star < 3 then -- 三星才能扫荡
                G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_SECKILL_LIMIT"))
            return
        end

        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
        if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.DUNGEON_SAODANG) == true then -- 扫荡等级限制
            if _stageData._isFinished == true then -- 是否通关
                if _stageData._executeCount >= 1 then -- 是否超过挑战次数
                    if self:_isEnoughVit( self.fastTimes) then
                            local CheckFunc = require("app.scenes.common.CheckFunc")
                        --    if CheckFunc.checkKnightFull() == false then
                                G_Me.hardDungeonData:setCurrStageId(self._stageId)
                                G_Me.hardDungeonData:setCurrStageLastStar(self._lastStarNum)
                                uf_sceneManager:getCurScene():addChild(require("app.scenes.harddungeon.HardDungeonFastBounsLayer").create())
                                self:_closeWindow()
                        --    end
                    else
                        self:_showVit()
                    end
                else
                    self:_showRestDungeonBox(_stageData.reset_cost,_stageData.rest_count)
                end

            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_CANNOTSECKILL"))
            end
        end
   end




    --widget:setTouchEnabled(false)
end



-- @desc 点击物品信息
function HardDungeonEnterGateLayer:onClickGoods(widget,_type)
    if  _type == TOUCH_EVENT_ENDED then
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
        local _stageData = hard_dungeon_stage_info.get(self._stageId)
        local _dungeonInfo = G_GlobalFunc.getHardDungeonData(_stageData.value)
        require("app.scenes.common.dropinfo.DropInfo"
         ).show(_dungeonInfo["item" .. tostring(widget:getTag()) .. "_type"],_dungeonInfo["item" .. tostring(widget:getTag()) .. "_value"])
    end

    --widget:setTouchEnabled(false)
end

-- 播放NPC声音
function HardDungeonEnterGateLayer:_playStageSound( ... )
  local tStageTmpl = hard_dungeon_stage_info.get(self._stageId)
  if tStageTmpl then
    local szSound = tStageTmpl.sound 
    G_SoundManager:playSound(szSound)
  end
end


return HardDungeonEnterGateLayer

