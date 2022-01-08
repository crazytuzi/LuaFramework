--[[
******老玩家回归任务*******
    -- by yao
    -- 2016/2/16
]]

local PlayerBackCell = class("PlayerBackCell", BaseLayer)

function PlayerBackCell:ctor(data)
    self.super.ctor(self,data)
    self.btn_lingqu     = nil       --领取按钮
    self.btn_qianwang   = nil       --前往按钮
    self.img_tu         = nil       --任务标志图片
    self.ui             = nil
    self.oneTaskList    = {}        --需要显示的任务
    self:init("lua.uiconfig_mango_new.playerback.PlayerBackCell1")
end

function PlayerBackCell:initUI(ui)
	self.super.initUI(self,ui)
    self.ui             = ui
    self.btn_lingqu     = TFDirector:getChildByPath(ui, "btn_lingqu")
    self.btn_qianwang   = TFDirector:getChildByPath(ui, "btn_qianwang")
    self.img_tu         = TFDirector:getChildByPath(ui, "img_tu")
    self.txt_name       = TFDirector:getChildByPath(ui, "txt_name")
    self.txt_neirong    = TFDirector:getChildByPath(ui, "txt_neirong")
    self.img_ditu       = TFDirector:getChildByPath(ui, "img_ditu")
    self.load_bar       = TFDirector:getChildByPath(ui, "load_bar")
    self.txt_jindu      = TFDirector:getChildByPath(ui, "txt_jindu")
    
    self.btn_lingqu.logic   = self
    self.btn_qianwang.logic = self
end

function PlayerBackCell:setData(list)
    self.oneTaskList = list
    self:showRenwu(list)
end

function PlayerBackCell:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function PlayerBackCell:onShow()
    self.super.onShow(self)
end

function PlayerBackCell:registerEvents()
    self.super.registerEvents(self)
    self.btn_lingqu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onLingquBtnCallBack))
    self.btn_qianwang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQianwangBtnCallBack))
end

function PlayerBackCell:removeEvents()
    self.btn_lingqu:removeMEListener(TFWIDGET_CLICK)
    self.btn_qianwang:removeMEListener(TFWIDGET_CLICK)
    
    self.super.removeEvents(self)
end

function PlayerBackCell:dispose()
    self.super.dispose(self)
end

--领取按钮回调
function PlayerBackCell.onLingquBtnCallBack(sender)
    local self = sender.logic
    local taskid = self.oneTaskList.taskid
    PlayBackManager:getReward(taskid)
end

--前往按钮回调
function PlayerBackCell.onQianwangBtnCallBack(sender)
    local self      = sender.logic
    local taskdata  = sender.taskdata
    PlayBackManager:gotoTask(taskdata,true)
end

--显示任务
function PlayerBackCell:showRenwu(list)
    local taskid    = list.taskid
    local state     = list.state
    local currstep  = list.currstep
    local totalstep = list.totalstep
    local tasktype  = list.type

    --表配置信息
    --local list = PlayBackManager:getTaskSetData(taskid)

    if state == 0 then
        self.img_ditu:setVisible(true)
        self.btn_qianwang:setVisible(true)
        self.btn_lingqu:setVisible(false)
        if tasktype == 3003 or tasktype == 3004 then
            self.btn_qianwang:setVisible(false)
        end
    elseif state == 1 then
        self.img_ditu:setVisible(false)
        self.btn_qianwang:setVisible(false)
        self.btn_lingqu:setVisible(true)
    end

    local percent = currstep/totalstep*100
    self.load_bar:setPercent(percent)
    self.txt_jindu:setText(currstep .. "/" .. totalstep)  
    self.txt_name:setText(list.name)
    self.txt_neirong:setText(list.title)
    self.img_tu:setTexture("icon/task/"..list.icon_id..".png")

    self.btn_qianwang.taskdata = list
    self:showReward(list)
end

--显示奖励图片
function PlayerBackCell:showReward(list)
    local reward_id = list.reward_id
    local itemList = RewardConfigureData:GetRewardItemListById(reward_id)

    for i=1,2 do
        local img_bg    = TFDirector:getChildByPath(self.ui, "img_bg"..3-i)
        local img_icon_1= TFDirector:getChildByPath(img_bg, "img_icon_1")
        local txt_number= TFDirector:getChildByPath(img_bg, "txt_number_1")
        img_bg:setVisible(false)
        if itemList then
            local rewardItem = itemList:objectAt(i)
            if rewardItem == nil then
                return
            end
            img_bg:setVisible(true)
            local itemInfo  = BaseDataManager:getReward(rewardItem)

            if itemInfo.type == EnumDropType.ROLE then
                local role      = RoleData:objectByID(itemInfo.itemid)
                local headIcon  = role:getIconPath()
                img_icon_1:setTexture(headIcon)
            else
                img_icon_1:setTexture(itemInfo.path)
            end

            local path = GetColorIconByQuality(itemInfo.quality)
            if itemInfo.type == EnumDropType.GOODS then
                local itemDetail = ItemData:objectByID(itemInfo.itemid)
                if itemDetail ~= nil and itemDetail.type == EnumGameItemType.Piece then
                    path =  GetBackgroundForFragmentByQuality(itemInfo.quality)
                else
                    path =  GetColorIconByQuality(itemInfo.quality)
                end
            end

            txt_number:setText(string.format("%d", itemInfo.number))
            img_bg:setTexture(path)

            Public:addPieceImg(img_icon_1,{type = itemInfo.type, itemid = itemInfo.itemid})
            img_bg.itemid = rewardItem.itemid
            img_bg.type   = rewardItem.type
            img_bg:addMEListener(TFWIDGET_CLICK,
                audioClickfun(function(sender)
                    Public:ShowItemTipLayer(sender.itemid, sender.type)
            end),1)
        end
    end
end

return PlayerBackCell