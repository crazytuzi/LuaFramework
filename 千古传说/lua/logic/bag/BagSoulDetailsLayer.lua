--[[
******背包中侠魂类别的物品显示图层*******

	-- by david.dai
	-- 2014/5/27
]]

local BagSoulDetailsLayer = class("BagSoulDetailsLayer", BaseLayer)

function BagSoulDetailsLayer:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagSoulDetails")
end

function BagSoulDetailsLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.panel_root             = TFDirector:getChildByPath(ui, 'panel_root')
    self.panel_details_bg       = TFDirector:getChildByPath(ui, 'panel_details_bg')

	--左侧详情
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_Num			= TFDirector:getChildByPath(ui, 'txt_number')
	self.txt_name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_quality 		= TFDirector:getChildByPath(ui, 'img_quality')
	self.txt_description    = TFDirector:getChildByPath(ui, 'txt_description')


	--招募按钮
	self.btn_recruit 		= TFDirector:getChildByPath(ui, 'btn_recruit')
    self.btn_recruit.logic  = self
end

function BagSoulDetailsLayer:setHomeLayer(homeLayer)
    self.homeLayer = homeLayer
end

function BagSoulDetailsLayer:removeUI()
	self.panel_root = nil
	self.btn_icon = nil
	self.img_icon = nil
	self.txt_Num = nil
	self.txt_name = nil
	self.img_quality = nil
	self.txt_description = nil
	self.btn_recruit = nil
	self.tableView = nil
	self.panel_table = nil
    self.panel_details_bg = nil
    self.super.removeUI(self)
end

function BagSoulDetailsLayer:refreshUI()
     if not self.id then
        return
    end

    local data = BagManager:getItemById(self.id)
    if not data then
        return
    end
    self:isRecruitEnabled(data)
end

--设置物品数据
function BagSoulDetailsLayer:setData(data)
	if data == nil  then
		return false
	end

	self.id = data.id
	self.txt_name:setText(data.name)
    if data.type == EnumGameItemType.Soul and data.kind == 2 then
        self.img_icon:setTexture(MainPlayer:getIconPath())
    else
        self.img_icon:setTexture(data:GetTextrue())
    end
	self.btn_icon:setTextureNormal(GetBackgroundForGoods(data:getData()))
	self.txt_Num:setText(data.num)
	self.txt_description:setText(data.itemdata.details)
    self.img_quality:setTexture(GetFontByQuality(data.itemdata.quality))

    local rewardItem = {itemid = data.id}

    if data.kind == 3 then
        Public:addPieceImg(self.img_icon,rewardItem,false);
        self.img_quality:setVisible(false)
        self:setRecruitButtonEnabled(false,true)
    else
        Public:addPieceImg(self.img_icon,rewardItem,true);
        self.img_quality:setVisible(true)
        self:isRecruitEnabled(data)
    end
    

end

--[[
    验证是否可招募
]]
function BagSoulDetailsLayer:isRecruitEnabled(data)
    local canRecruit, alreadyHasRole = BagManager:isRecruitEnabled(data)
    self:setRecruitButtonEnabled(canRecruit, alreadyHasRole)
    return canRecruit
end

--合成按钮点击事件处理方法
function BagSoulDetailsLayer.recruitButtonClickHandle(sender)
    local self = sender.logic
    self:requestSummonPaladin(self.id)
end

function BagSoulDetailsLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_recruit:addMEListener(TFWIDGET_CLICK,audioClickfun(self.recruitButtonClickHandle),1)
    self.summonPaladinSuccessCallback = function(event)
        local unitInstance = event.data[1]
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(BagManager.SUMMON_PALADIN,self.summonPaladinSuccessCallback)
end

function BagSoulDetailsLayer:removeEvents()
    --按钮事件
    self.btn_recruit:removeMEListener(TFWIDGET_CLICK)
    TFDirector:removeMEGlobalListener(BagManager.SUMMON_PALADIN,self.summonPaladinSuccessCallback)

    self.super.removeEvents(self)
end

--销毁方法
function BagSoulDetailsLayer:dispose()
    self.super.dispose(self)
end

--变更招募按钮状态
function BagSoulDetailsLayer:setRecruitButtonEnabled(enabled, alreadyHasRole)
    if enabled then
        --设置为可招募
        self.btn_recruit:setTouchEnabled(true)
        self.btn_recruit:setGrayEnabled(false)
    else
        --设置为不可招募
        self.btn_recruit:setTouchEnabled(false)
        self.btn_recruit:setGrayEnabled(true)
    end

    self.btn_recruit:setVisible(not alreadyHasRole)
end

--请求服务器召唤侠士
function BagSoulDetailsLayer:requestSummonPaladin(soulId)
    BagManager:requestSummonPaladin(soulId)
end

return BagSoulDetailsLayer
