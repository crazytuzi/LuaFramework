local MoShenGongXunAward = class("MoShenGongXunAward",UFCCSModelLayer)
require("app.cfg.rebel_exploit_reward_info")
--注意添加json文件

--[[myExploitValue 传入我的当前功勋值]]
function MoShenGongXunAward.create(...)
    local layer = MoShenGongXunAward.new("ui_layout/moshen_MoShenGongXunAward.json",Colors.modelColor,...)
    layer:adapterLayer()
    return layer
end

--适配写在这里
function MoShenGongXunAward:adapterLayer()
    self:adapterWidgetHeight("","","",0,0)
end

function MoShenGongXunAward:ctor(...)
    self._gongxunListView = nil
    self._gongxunList = {}
    self.super.ctor(self,...)
    self:showAtCenter(true)
    uf_eventManager:addEventListener(EventMsgID.EVENT_MOSHEN_GET_EXPLOIT_AWARD_TYPE, self._getAwardType, self)
    uf_eventManager:addEventListener(EventMsgID.EVENT_MOSHEN_GET_EXPLOIT_AWARD, self._getAward, self)
    self:_initBtnEvent()
    self:_initWidgets()
    self:setVisible(false)
    if G_Me.moshenData:checkEnterAward() then
        self:_getAwardType()
    else
        G_HandlersManager.moshenHandler:sendGetExploitAwardType() 
    end 
end

function MoShenGongXunAward:_initWidgets()
    self:getLabelByName("Label_listnote"):createStroke(Colors.strokeBrown,1)
end

function MoShenGongXunAward:_initListView()
    if self._gongxunListView == nil then
        local panel = self:getPanelByName("Panel_awardList")
        self._gongxunListView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._gongxunListView:setCreateCellHandler(function ()
            local cell = require("app.scenes.moshen.MoShenGongXunAwardItem").new()
            return cell
        end)
        self._gongxunListView:setUpdateCellHandler(function ( list, index, cell)
            local _exploit = self._gongxunList[index+1]
            cell:updateItem(self._gongxunList[index+1])
            cell:setOnClick(function()
                if _exploit== nil or G_Me.moshenData:getGongXun() == nil  then
                    return
                end
                if G_Me.moshenData:checkAwardSign(_exploit.id) == true then --已领取
                    return
                end
                if G_Me.moshenData:getGongXun() < _exploit.exploit then   --未达成
                    return
                end
                --设置界面不可点击，避免快速点击bug
                self:setTouchEnabled(false)
                G_HandlersManager.moshenHandler:sendGetExploitAward(_exploit.id)
                end)
        end)

    end
end

function MoShenGongXunAward:_initBtnEvent()
    self:enableAudioEffectByName("Button_close", false)
    self:enableAudioEffectByName("Button_close02", false)
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    self:registerBtnClickEvent("Button_close02",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
end

function MoShenGongXunAward:_getAwardType()
    self:setVisible(true)
    for i=1, rebel_exploit_reward_info.getLength() do
        local v = rebel_exploit_reward_info.indexOf(i)
        if v.rebel_exploit_type == G_Me.moshenData:getAwardMode() then 
            if v.holiday == 0 or G_Me.specialActivityData:isInActivityTime() then
                self._gongxunList[#self._gongxunList+1]=v
            end
        end
    end
    self:_sortAwardData()
    self:_initListView()
    self._gongxunListView:initChildWithDataLength(#self._gongxunList)
end


--[[
    message S2C_GetExploitAward {
      required uint32 ret = 1;
      required uint32 id = 2;
    }
]]
function MoShenGongXunAward:_getAward(data)
    self:setTouchEnabled(true)
    if data.ret == 1 then
        if rawget(data,"award") then
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({data.award})
            uf_notifyLayer:getModelNode():addChild(_layer)
        end 
        self:_sortAwardData()
        -- self._gongxunListView:refreshAllCell()
        self._gongxunListView:reloadWithLength(#self._gongxunList,self._gongxunListView:getShowStart())
    else
        
    end
end

--奖励排序
function MoShenGongXunAward:_sortAwardData()
    if self._gongxunList == nil or #self._gongxunList == 0 then
        return
    end
    local sortFunc = function(a,b)
        if G_Me.moshenData:checkAwardSign(a.id) ~= G_Me.moshenData:checkAwardSign(b.id) then
            local A = G_Me.moshenData:checkAwardSign(a.id) and 1 or 0
            local B = G_Me.moshenData:checkAwardSign(b.id) and 1 or 0
            return A < B
        end
        if a.arrange ~= b.arrange then
            return a.arrange < b.arrange
        end
        return a.id < b.id
    end
    table.sort(self._gongxunList,sortFunc)
end

function MoShenGongXunAward:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

function MoShenGongXunAward:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return MoShenGongXunAward

