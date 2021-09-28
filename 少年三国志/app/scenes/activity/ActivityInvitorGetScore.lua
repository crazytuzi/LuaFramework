
local ActivityInvitorGetScore = class("ActivityInvitorGetScore", UFCCSModelLayer)

function ActivityInvitorGetScore:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self._scoreLabel1 = self:getLabelByName("Label_score1")
    self._scoreLabel2 = self:getLabelByName("Label_score2")
    self._scoreLabel3 = self:getLabelByName("Label_score3")
    self._scoreLabel4 = self:getLabelByName("Label_score4")
    self._sayLabel = self:getLabelByName("Label_talk")
    self._listPanel = self:getPanelByName("Panel_list")

    self._scoreLabel1:setText(G_lang:get("LANG_INVITOR_GET_SCORE1"))
    self._scoreLabel2:setText(G_lang:get("LANG_INVITOR_GET_SCORE2"))
    self._scoreLabel3:setText(G_lang:get("LANG_INVITOR_GET_SCORE3"))

    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_get", function()
        if G_Me.activityData.invitor.furScore > 0 then
            G_HandlersManager.activityHandler:sendInvitorDrawScoreReward()
        end
    end)
end

function ActivityInvitorGetScore.create(...)
    local layer = ActivityInvitorGetScore.new("ui_layout/activity_ActivityInvitorGetScore.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function ActivityInvitorGetScore:onLayerEnter()
    self:closeAtReturn(true)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_INVITORDRAWSCOREREWARD, self._onGetScoreRsp, self)

    self:updateView()
end

function ActivityInvitorGetScore:updateView()
    local score = G_Me.activityData.invitor.furScore
    local sayTxt = score>0 and G_lang:get("LANG_INVITOR_GET_TALK1") or G_lang:get("LANG_INVITOR_GET_TALK2")
    self._sayLabel:setText(sayTxt)

    self._scoreLabel4:setText(G_Me.userData.invitor_score)
    self:updateList()
end

function ActivityInvitorGetScore:updateList( )
    GlobalFunc.createIconInPanel({panel=self._listPanel,award={{type=G_Goods.TYPE_INVITOR_SCORE,value=0,size=G_Me.activityData.invitor.furScore,forceSize=true}},click=true,left=true})
end

function ActivityInvitorGetScore:_onGetScoreRsp( )
    self:updateView()
end

function ActivityInvitorGetScore:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return ActivityInvitorGetScore

