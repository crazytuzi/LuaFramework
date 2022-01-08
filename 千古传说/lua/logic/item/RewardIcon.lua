--[[
******奖励 图标层*******

    -- by Stephen.tao
    -- 2014/2/19
]]

local RewardIcon = class("RewardIcon", BaseLayer)

--CREATE_SCENE_FUN(RewardIcon)
CREATE_PANEL_FUN(RewardIcon)


function RewardIcon:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.item.RewardIcon")
end


function RewardIcon:initUI(ui)
	self.super.initUI(self,ui)

    self.img_icon       = TFDirector:getChildByPath(ui, 'img_icon')
    self.img_quality    = TFDirector:getChildByPath(ui, 'img_quality')
    self.txt_num       = TFDirector:getChildByPath(ui, 'txt_num')

end

function RewardIcon:removeUI()
	self.super.removeUI(self)

    self.img_icon       = nil
    self.img_quality    = nil
    self.txt_num       = nil
end

function RewardIcon:setReward( reward )
--[[
message RewardItem
{
    required int32 type = 1; //资源类型：1、物品；2、卡牌；3、铜币;等…………
    required int32 number =2 ; //数量
    optional int32 itemId = 3; //资源id ，在非数值资源类型的情况下会发送，即有多种情况的时候会通过这个字段描述具体的id。当type为物品时表示物品id，为卡牌时表示卡牌id
}
]]
    local icon_info = BaseDataManager:getReward(reward)
    self.img_icon:setTexture(icon_info.path)
    self.img_quality:setTexture(GetColorIconByQuality(icon_info.quality))
    self.txt_num:setText("x" .. icon_info.number)

    Public:addPieceImg(self.img_icon,reward);
end

function RewardIcon:registerEvents()
    self.super.registerEvents(self)
end


return RewardIcon
