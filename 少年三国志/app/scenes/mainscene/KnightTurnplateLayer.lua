local _knightPic = require("app.scenes.common.KnightPic")
local TurnplateLayer = require("app.scenes.common.turnplate.TurnplateLayer")
local KnightTurnNode = require("app.scenes.mainscene.KnightTurnNode")

local KnightTurnplateLayer = class("KnightTurnplateLayer", TurnplateLayer)


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"




--6个侠客的角度

local angles = {55, 90, 125, 200, 270, 340}


function KnightTurnplateLayer:init(size, playVoice)
    self._lastTurnPlate = nil
    self._mainKnightPanel = nil
    self.super.init(self, size, angles, 4)

   
    self._wordsLayer = display.newNode()

    self:addChild(self._wordsLayer)

    for i=1,6 do
         local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, i)



         local _panel = KnightTurnNode.create()
         _panel:setData(knightId, baseId, i)

         -- 将主角的panel保存下来
         if i == 1 then
            self._mainKnightPanel = _panel
         end

         --不同的阵容位对应于圆盘的不同pos
         local _pos = 0
         if i == 1 then
             _pos = 1
         elseif i == 3 then
            _pos = 2
         elseif i == 2 then
              _pos = 6
         elseif i == 4 then
             _pos = 3
         elseif i == 5 then
            _pos = 5
         else
            _pos = 4
         end

         self:addNode(_panel, _pos)
         if playVoice and _pos == 1 then 
            self:saySomething()
            _panel:playKnightCommonAudio()
         end
    end
end

function KnightTurnplateLayer:onLayerEnter(  )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_ROLE_NAME_SUCCEED, self._onChangeRoleNameSucceed, self)
end

function KnightTurnplateLayer:_onChangeRoleNameSucceed()
    if self._mainKnightPanel then
        self._mainKnightPanel:changeName()
    end
end


function KnightTurnplateLayer:onLayerExit()

    self.super.onLayerExit(self)
end



function KnightTurnplateLayer:onMove()
    self:_clearSaySomething()
end

function KnightTurnplateLayer:onMoveStop(reason)
    if reason == "back" then
        self:saySomething()
    end
    
end


-- @desc 点击武将
function KnightTurnplateLayer:onClick(pt)
   local _list = self:getOrderList()
   local clickNode = nil
   for k,v in pairs(_list) do
        if v:containsPt(pt) then
            local _angle = v.angle
            if _angle < 0 then _angle = _angle + 360 end
            if _angle > 360 then _angle = _angle - 360 end

            if _angle == 270 or _angle == 340 or _angle == 200 then
                clickNode = v
            else
                --旋转到整中间, 找到需要往哪个方向转, 转几步, 中间那个方向在angles数组里是固定第5个
                --local angles = {55, 90, 125, 200, 270, 340}

                -- local dir 
                -- local step 
                -- for i,v in ipairs(angles) do 
                --     if 
                -- end
                if _angle == 55 then
                    self:judgeNeedMoveBack(-1, 2)
                elseif  _angle == 90 then
                    self:judgeNeedMoveBack(1, 3)
                elseif  _angle == 125 then
                    self:judgeNeedMoveBack(1, 2)
                elseif  _angle == 200 then
                    self:judgeNeedMoveBack(1, 1)
                elseif  _angle == 340 then
                    self:judgeNeedMoveBack(-1, 1)
                end
                
            end

        end

   end

   --正中间3个位置
   -- print( " clicknode " .. tostring(clickNode)  )

   if clickNode   then 
        if not clickNode:hasKnight() then
            local levelArr = G_Me.userData:getTeamSlotOpenLevel()
            if G_Me.userData.level < levelArr[clickNode:getSlotTag()] then -- 检查槽位是否开启
                G_MovingTip:showMovingTip(G_lang:get("LANG_MAINPAGE_OPENLEVEL",{level=levelArr[clickNode:getSlotTag()]}))
                return
            end

           
        end

        
        
        G_commonLayerModel:getSpeedbarLayer():setSelectBtn("Button_LineUp")
        uf_sceneManager:replaceScene(require("app.scenes.hero.HeroScene").new(clickNode:getSlotTag()))  
   end
end




function KnightTurnplateLayer:_clearSaySomething()
    -- if self._sayEffect ~= nil then
    --     self._sayEffect:stop()
    --     self._sayEffect = nil
    --     self._knightSayLayer:setVisible(false)

    -- end
    if self._knightSayLayer then
        self._knightSayLayer:getImageViewByName('Image_desc'):setVisible(false)
        self._knightSayLayer:getImageViewByName('Image_desc'):stopAllActions()
    end
end
function KnightTurnplateLayer:saySomething()
    if self._knightSayLayer == nil then
        self._knightSayLayer  = UFCCSNormalLayer.new("ui_layout/mainscene_KnightSayLayer.json")
        self._knightSayLayer:setPosition(ccp(350,305))     
        self._knightSayLayer:setVisible(false)

        self._wordsLayer:addChild(self._knightSayLayer)
    end

    self:_clearSaySomething()

    if self._lastTurnPlate then 
        self._lastTurnPlate:stopKnightCommonAudio()
        self._lastTurnPlate = nil
    end

    --取到最前面那个侠客
    local _list = self:getOrderList()

    for k,v in pairs(_list) do
        if v.pos == 1 then
            if v:hasKnight() then
                self._lastTurnPlate = v
                local str = v:getSomethingToSay()
                v:playKnightCommonAudio()
                self._knightSayLayer:getLabelByName("Label_desc"):setText(str)
                self._knightSayLayer:getLabelByName("Label_desc"):setFontName("res/ui/font/FZYiHei-M20S.TTF")
                self._knightSayLayer:setVisible(true)
                self._knightSayLayer:getImageViewByName('Image_desc'):setScale(1)
                -- self._sayEffect = EffectSingleMoving.run(self._knightSayLayer:getImageViewByName('Image_desc'), "smoving_say", function(event) 
                --     self:_clearSaySomething()
                
                -- end, {position=true})
                GlobalFunc.sayAction(self._knightSayLayer:getImageViewByName('Image_desc'),true)
            end
            
            break
        end
    end

end

return KnightTurnplateLayer
