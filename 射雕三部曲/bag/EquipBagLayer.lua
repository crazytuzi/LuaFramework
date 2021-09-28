--[[
	文件名：EquipBagLayer.lua
	描述：装备背包界面
	创建人：lengjiazhi
	创建时间：2017.5.9
--]]

local EquipBagLayer = class("EquipBagLayer", function(params)
	return display.newLayer()
end)

function EquipBagLayer:ctor(params)
	self.mCurTag = params.subPageType or BagType.eEquipBag
    self.mParent = params.parent 

	--子页面父节点
	self.mSubParentLayer = display.newLayer()
	self:addChild(self.mSubParentLayer)

    --创建分页
    self:showTabLayer()

    -- 播放音效
    MqAudio.playEffect("zhuangbei_open.mp3")
end


function EquipBagLayer:showTabLayer()
	local tabInfo = {
		{
			text = TR("装备"),
            fontSize = 22,
            titlePosRateY = 0.5,
			tag = BagType.eEquipBag,
		},
		{
			text = TR("装备碎片"),
            fontSize = 22,
            titlePosRateY = 0.5,
            needRedDot = true,
			tag = BagType.eEquipDebrisBag,
		},
	}

	-- 创建tablayer
    self.tableLayer = ui.newTabLayer({
        btnInfos = tabInfo,
        defaultSelectTag = self.mCurTag,
        space = 10,
        btnSize = cc.size(103, 49),
        viewSize = cc.size(320, 80),
        normalImage = "c_155.png",
        lightedImage = "c_154.png",
        needLine = false,
        onSelectChange = function (selectBtnTag)
            self:addElements(selectBtnTag)
        end,
    })
    self.tableLayer:setAnchorPoint(0, 0.5)
    self.tableLayer:setPosition(10, 945)
    self:addChild(self.tableLayer)

    -- 装备碎片添加小红点
    local debrisBtn = self.tableLayer:getTabBtnByTag(BagType.eEquipDebrisBag)
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eBagEquipDebris))
    end
    ui.createAutoBubble({parent = debrisBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eBagEquipDebris), refreshFunc = dealRedDotVisible, position = cc.p(0.9, 0.8)})
end

function EquipBagLayer:addElements(tag)
	--清空子节点
	self.mSubParentLayer:removeAllChildren()

	if tag == BagType.eEquipBag then
		self.mCurTag = BagType.eEquipBag
		self.hadViewedEquip = true
		local equipLayer = require("bag.BagEquipLayer"):create({parent = self.mParent})
		self.mSubParentLayer:addChild(equipLayer)
	elseif tag == BagType.eEquipDebrisBag then
		self.mCurTag = BagType.eEquipDebrisBag
		self.hadViewedDebris = true
		local debrisLayer = require("bag.BagEquipDebrisLayer"):create({parent = self.mParent})
		self.mSubParentLayer:addChild(debrisLayer)
	end
end

function EquipBagLayer:onExit()
	-- if self.hadViewedEquip then
 --        EquipObj:getNewIdObj():clearNewId()
 --        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagEquipDebris)
 --    end

 --    if self.hadViewedDebris then
 --        GoodsObj:getNewZhenjueDebrisIdObj():clearNewId()
 --    end
end

return EquipBagLayer
