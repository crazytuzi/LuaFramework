--[[
******杀戮信息层*******

    -- by Chikui Peng
    -- 2016/3/21
]]

local ShaLuInfoLayer = class("ShaLuInfoLayer", BaseLayer)

function ShaLuInfoLayer:ctor(data)
    self.super.ctor(self, data)

    self.info = nil
    self:init("lua.uiconfig_mango_new.youli.ShaLuInfo")
end

function ShaLuInfoLayer:initUI(ui)
    self.super.initUI(self, ui)
    self.headIcon   = TFDirector:getChildByPath(ui, "Img_icon")
    self.txt_name   = TFDirector:getChildByPath(ui, "txt_name")
    self.txt_rank   = TFDirector:getChildByPath(ui, "txt_rank")
    self.txt_score  = TFDirector:getChildByPath(ui, "txt_score")
    self.panel_bg   = TFDirector:getChildByPath(ui, "bg")
    self.txt_res    = {}
    self.icon_res   = {}
    self.img_bg     = {}
    for i=1,2 do
        local panel = TFDirector:getChildByPath(ui, "panel_res"..i)
        self.txt_res[i]  = TFDirector:getChildByPath(panel, "txt_num")
        self.icon_res[i] = TFDirector:getChildByPath(panel, "img_res_icon")
    end

    self.btn_rank   = TFDirector:getChildByPath(ui, "btn_rank")
    self.btn_record = TFDirector:getChildByPath(ui, "btn_record")
    self.btn_help   = TFDirector:getChildByPath(ui, 'btn_help')
    self.btn_reward = TFDirector:getChildByPath(ui, 'Button_ShaLuInfo_1')
end

function ShaLuInfoLayer:onShow()
    self.super.onShow(self)
end

function ShaLuInfoLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(ShaLuInfoLayer.OnRuleClick,self)))
    self.btn_record:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(ShaLuInfoLayer.OnRecordClick,self)))
    self.btn_rank:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(ShaLuInfoLayer.OnRankClick,self)))
    self.btn_reward:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(ShaLuInfoLayer.OnShowRewardClick,self)))
end

function ShaLuInfoLayer:OnShowRewardClick( sender )
    local layer  = require("lua.logic.youli.ShaLuRewardLayer"):new(self.info.ranking)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function ShaLuInfoLayer:OnRuleClick( sender )
    CommonManager:showRuleLyaer('youlishaluxinxi')
end

function ShaLuInfoLayer:OnRecordClick( sender )
    AdventureManager:openFightRecordLayer()
end

function ShaLuInfoLayer:OnRankClick( sender )
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.leaderboard.Leaderboard.lua")
    layer:setIndex(13)
    AlertManager:show();
end

function ShaLuInfoLayer:removeEvents()
    self.super.removeEvents(self)
end

function ShaLuInfoLayer:dispose()
    self.super.dispose(self)
end

function ShaLuInfoLayer:setInfo(info)
    print(" ShaLuInfoLayer info = ",info)
    self.info = info
    self.headIcon:setTexture(MainPlayer:getIconPath())
    Public:addFrameImg(self.headIcon,MainPlayer:getHeadPicFrameId())
    self.txt_res[1]:setText(info.coin)
    self.txt_res[2]:setText(info.experience)
    self.txt_rank:setText(info.ranking.."")
    if info.ranking == 0 then
        info.ranking = 999999
        self.txt_rank:setText(localizable.shalu_info_txt1)
    end
    local rankConfig = ChampionsAwardData:getRewardData(4,info.ranking)
    if rankConfig ~= nil then
        local rewardList = rankConfig:getReward()
        for k,v in ipairs(rewardList) do
            local rewardItem = BaseDataManager:getReward({type = v.type,number = v.number,itemId = v.itemid})
            local node = Public:createIconNumNode(rewardItem)
            self.panel_bg:addChild(node)
            node:setScale(0.7)
            node:setPosition(ccp((k-1)*114 - (#rewardList)*114/2 + 11,-180))
        end
    end
    
    self.txt_name:setText(MainPlayer:getPlayerName())
    
    self.txt_score:setText(info.massacre.."")
end

return ShaLuInfoLayer