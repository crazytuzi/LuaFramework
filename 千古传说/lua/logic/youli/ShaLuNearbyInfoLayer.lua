--[[
******杀戮附近的人信息层*******

    -- by Chikui Peng
    -- 2016/3/28
]]

local ShaLuNearbyInfoLayer = class("ShaLuNearbyInfoLayer", BaseLayer)

function ShaLuNearbyInfoLayer:ctor(data)
    self.super.ctor(self, data)

    self.info = nil
    self:init("lua.uiconfig_mango_new.youli.ShaLuNearbyInfo")
end

function ShaLuNearbyInfoLayer:initUI(ui)
    self.super.initUI(self, ui)
    self.headIcon   = TFDirector:getChildByPath(ui, "Img_icon")
    self.txt_name   = TFDirector:getChildByPath(ui, "txt_name")
    self.txt_faction   = TFDirector:getChildByPath(ui, "txt_faction")
    self.txt_zhanli  = TFDirector:getChildByPath(ui, "txt_zhanli")
    self.txt_lvl  = TFDirector:getChildByPath(ui, "txt_lvl")
    self.txt_shalu  = TFDirector:getChildByPath(ui, "txt_shalu")
    self.txt_Count = TFDirector:getChildByPath(ui, "txt_Count")
    self.txt_res    = {}
    for i=1,3 do
        local panel = TFDirector:getChildByPath(ui, "panel_res"..i)
        self.txt_res[i]  = TFDirector:getChildByPath(panel, "txt_num")
    end
    self.btn_fight   = TFDirector:getChildByPath(ui, "btn_fight")

    self.txt_fight_Count = TFDirector:getChildByPath(ui, "txt_fight_Count")
end

function ShaLuNearbyInfoLayer:onShow()
    self.super.onShow(self)

    --剩余挑战次数
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.SHALU_COUNT)
    local currCount = challengeInfo:getLeftChallengeTimes()
    self.txt_fight_Count:setText(currCount .. '/5')
end

function ShaLuNearbyInfoLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_fight:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(ShaLuNearbyInfoLayer.OnFightClick,self)))

    self.ChallengeTimesChangeCallBack = function(event)
        local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.SHALU_COUNT)
        local currCount = challengeInfo:getLeftChallengeTimes()
        self.txt_fight_Count:setText(currCount .. '/5')    
    end
    TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange, self.ChallengeTimesChangeCallBack)    
end

function ShaLuNearbyInfoLayer:OnFightClick( sender )

    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.SHALU_COUNT)
    local currCount = challengeInfo:getLeftChallengeTimes()
    if currCount <= 0 then
        VipRuleManager:showReplyLayer(EnumRecoverableResType.SHALU_COUNT)
        return
    end
    TFFunction.call(self.clickCallBack,self.info.id)
end

function ShaLuNearbyInfoLayer:removeEvents()
    self.super.removeEvents(self)
    if self.ChallengeTimesChangeCallBack then
        TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.ChallengeTimesChangeCallBack)
        self.ChallengeTimesChangeCallBack = nil
    end
end

function ShaLuNearbyInfoLayer:dispose()
    self.super.dispose(self)
end

function ShaLuNearbyInfoLayer:setInfo(info,clickCallBack)
    print(" ShaLuNearbyInfoLayer info = ",info)
    self.info = info

    local role = RoleData:objectByID(info.icon)
    if role then
        self.headIcon:setTexture(role:getIconPath())
    end
    Public:addFrameImg(self.headIcon,info.headPicFrame)
    Public:addInfoListen(self.headIcon,true,2,info.id)

    self.txt_res[1]:setText(info.rewardCoin)
    self.txt_res[2]:setText(info.rewardExperience)
    self.txt_res[3]:setText(info.rewardMassacre)
    local txt = localizable.shalu_nearby_txt2
    if info.name == "" then
        info.name = localizable.shalu_nearby_txt1
        txt = localizable.shalu_nearby_txt3
    end
    self.txt_Count:setText(txt)
    self.txt_name:setText(info.name)
    self.txt_shalu:setText(info.massacreValue.."")
    self.txt_faction:setText(info.guildName.."")
    self.txt_zhanli:setText(info.power.."")
    self.txt_lvl:setText(info.level.."")
    self.clickCallBack = clickCallBack

    --剩余挑战次数
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.SHALU_COUNT)
    local currCount = challengeInfo:getLeftChallengeTimes()
    self.txt_fight_Count:setText(currCount .. '/5')
end

return ShaLuNearbyInfoLayer