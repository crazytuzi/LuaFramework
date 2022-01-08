--[[
******礼包信息层*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local GeneralMoreReward = class("GeneralMoreReward", BaseLayer)

--CREATE_SCENE_FUN(GeneralMoreReward)
CREATE_PANEL_FUN(GeneralMoreReward)


function GeneralMoreReward:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.message.GeneralMoreReward")
end


function GeneralMoreReward:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok         = TFDirector:getChildByPath(ui, 'btn_ok')
    self.txt_name   = {}
    self.txt_num    = {}

    for i=1,4 do
        local str = "txt_name_"..i
        self.txt_name[i]  = TFDirector:getChildByPath(ui, str)
        str = "txt_num_"..i
        self.txt_num[i]  = TFDirector:getChildByPath(ui, str)
    end

    self.btn_ok.logic       = self
end

function GeneralMoreReward:removeUI()
	self.super.removeUI(self)
    self.btn_ok    = nil
    self.txt_name  = nil
    self.txt_num   = nil
end


function GeneralMoreReward:setReward( reward )
    local index = 1
    for _,v in pairs(reward) do
        self.txt_name[index]:setVisible(true)
        self.txt_num[index]:setVisible(true)
        self:setInfo(index , v)
        index = index + 1
    end

    while index <= 4 do
        self.txt_name[index]:setVisible(false)
        self.txt_num[index]:setVisible(false)
        index = index + 1       
    end
end

function GeneralMoreReward:setInfo( index,reward )
    if reward.type == EnumDropType.GOODS then
        if reward.itemId ~= nil then
            local item = ItemData:objectByID( itemid )
            if item ~= nil  then
                self.txt_name[index]:setText(item.name)
            end
        end
    elseif reward.type == EnumDropType.ROLE then
        if reward.itemId ~= nil then
            local role =  RoleData:objectByID(roleid)
            if role ~= nil  then
                self.txt_name[index]:setText(role.name)
            end
        end
    elseif reward.type == EnumDropType.COIN then
        --self.txt_name[index]:setText("铜币")
        self.txt_name[index]:setText(localizable.common_coin)
    elseif reward.type == EnumDropType.SYCEE then
        --self.txt_name[index]:setText("元宝")
        self.txt_name[index]:setText(localizable.common_gold)
    elseif reward.type == EnumDropType.GENUINE_QI then
        --self.txt_name[index]:setText("真气")
        self.txt_name[index]:setText(localizable.common_zhenqi)
    elseif reward.type == EnumDropType.SOUL then
        --self.txt_name[index]:setText("魂魄")
        self.txt_name[index]:setText(localizable.common_hunpo)
    elseif reward.type == EnumDropType.EXP then
        --self.txt_name[index]:setText("经验")
        self.txt_name[index]:setText(localizable.common_level)
    end
    self.txt_num[index]:setText("x" .. reward.number)
end

function GeneralMoreReward.onOpenBtnClickHandle(sender)

    AlertManager:close(AlertManager.TWEEN_1);
end


function GeneralMoreReward:registerEvents()
    self.super.registerEvents(self)
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOpenBtnClickHandle),1)
end


return GeneralMoreReward
